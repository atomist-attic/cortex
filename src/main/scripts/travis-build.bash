#!/bin/bash
# build, test, and publish maven projects on Travis CI

set -o pipefail

declare Pkg=travis-build-mvn
declare Version=0.4.0

function msg() {
    echo "$Pkg: $*"
}

function err() {
    msg "$*" 1>&2
}

function main() {
    msg "branch is ${TRAVIS_BRANCH}"

    local mvn="mvn --settings .settings.xml -B -V"
    local project_version

    local schema_dir=src/main/resources/com/atomist/rug/ts
    if ! mkdir -p "$schema_dir"; then
        err "failed to create ts resource directory"
        return 1
    fi
    local schema_path=$schema_dir/cortex.json
    local schema_url=https://api.atomist.com/model/schema

    if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+(-(m|rc)\.[0-9]+)?$ ]]; then
            project_version="$TRAVIS_TAG"
            msg "releasing cortex version $project_version"
        elif [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+-staging$ ]]; then
            project_version=${TRAVIS_TAG:0:-8}
            schema_url=https://api-staging.atomist.services/model/schema
            msg "releasing cortex version $project_version using staging cortex model"
        elif [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+-snapshot[0-9]*$ ]]; then
            project_version=${TRAVIS_TAG%%-snapshot*}-$(date -u +%Y%m%d%H%M%S)
            if [[ $? -ne 0 || ! $project_version ]]; then
                err "failed to create timestamp version for snapshot release: $project_version"
                return 1
            fi
            schema_url=https://api-staging.atomist.services/model/schema
            local rug_version
            rug_version=$(mvn help:evaluate -Dexpression=rug.version | grep -v "^\[")
            if [[ $? != 0 || ! $rug_version ]]; then
                err "failed to parse rug version from POM"
                return 1
            fi
            mvn="$mvn -Drug.version=[$rug_version,) -U"
            msg "releasing cortex version $project_version using staging cortex model and @atomist/rug snapshot version"
        else
            err "unrecognized semver like-tag: $TRAVIS_TAG"
            return 1
        fi
        if ! mvn build-helper:parse-version versions:set -DnewVersion="$project_version" versions:commit; then
            err "failed to set project version to $project_version"
            return 1
        fi
    else
        if ! mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-\${timestamp} versions:commit
        then
            err "failed to set timestamped project version"
            return 1
        fi
        project_version=$(mvn help:evaluate -Dexpression=project.version | grep -v "^\[")
        if [[ $? != 0 || ! $project_version ]]; then
            err "failed to parse project version"
            return 1
        fi
        msg "building non-release cortex version $project_version"
    fi

    if ! wget "$schema_url" -O "$schema_path"; then
        err "failed to download cortex json schema from $schema_url to $schema_path"
        return 1
    fi

    if ! $mvn compile; then
        err "maven compile failed"
        return 1
    fi

    local module_target=target/.atomist/node_modules/@atomist/cortex
    if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+-snapshot[0-9]*$ ]]; then
        local registry=https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
        if ! ( cd "$module_target" && npm install '@atomist/rug@latest' --save --registry="$registry" ); then
            err "failed to npm install latest @atomist/rug from $registry"
            return 1
        fi
    else
        if ! ( cd "$module_target" && npm install ); then
            err "npm install failed"
            return 1
        fi
    fi

    if ! $mvn install -DskipTests -Dmaven.javadoc.skip=true; then
        err "maven install failed"
        return 1
    fi

    if [[ $TRAVIS_PULL_REQUEST != false ]]; then
        msg "not publishing or tagging pull request"
        return 0
    fi

    if [[ $TRAVIS_BRANCH == master || $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            if ! bash src/main/scripts/npm-publish.bash "$project_version" cortex; then
                err "failed to publish NPM module for tag $TRAVIS_TAG and version $project_version"
                return 1
            fi
        fi

        if ! git config --global user.email "travis-ci@atomist.com"; then
            err "failed to set git user email"
            return 1
        fi
        if ! git config --global user.name "Travis CI"; then
            err "failed to set git user name"
            return 1
        fi
        local git_tag=$project_version+travis$TRAVIS_BUILD_NUMBER
        if ! git tag "$git_tag" -m "Generated tag from TravisCI build $TRAVIS_BUILD_NUMBER"; then
            err "failed to create git tag: $git_tag"
            return 1
        fi
        if ! git push --quiet --tags "https://$GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG" > /dev/null 2>&1; then
            err "failed to push git tags"
            return 1
        fi
    fi
}

main "$@" || exit 1
exit 0
