#!/bin/bash

set -o pipefail

declare Pkg=npm-publish
declare Version=0.2.0

function msg() {
    echo "$Pkg: $*"
}

function err() {
    msg "$*" 1>&2
}

# publish node module, default MODULE=rug
# usage: publish MODULE_VERSION [MODULE]
function publish() {
    local module_version=$1
    if [[ ! $module_version ]]; then
        err "publish: missing required parameter: MODULE_VERSION"
        return 10
    fi
    shift
    local module_name=$1
    if [[ ! $module_name ]]; then
        err "publish: missing required parameter: MODULE_NAME"
        return 10
    else
        shift
    fi

    local target="target/.atomist/node_modules/@atomist/$module_name"
    local package="$target/package.json"
    if ! sed "s/REPLACE_ME/$module_version/g" "$package.in" > "$package"; then
        err "failed to set version in $package"
        return 1
    fi
    rm -f "$package.in"

    # npm honors this
    rm -f "$target/.gitignore"

    if [[ $module_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [[ $NPM_TOKEN ]]; then
            msg "Creating local .npmrc using API key from environment"
            if ! ( umask 077 && echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > "$HOME/.npmrc" ); then
                err "failed to create $HOME/.npmrc"
                return 1
            fi
        else
            msg "assuming your .npmrc is setup correctly for this project"
        fi
        if ! ( cd "$target" && npm publish --access=public ); then
           err "failed to publish node module"
           cat "$target/npm-debug.log"
           return 1
        fi
    elif [[ $TRAVIS_BRANCH == master ]]; then
        # install latest rug dev version in package.json
        if ! npm install @atomist/rug@latest -S --registry https://atomist.jfrog.io/atomist/api/npm/npm-dev; then
            err "Failed to install latest @atomist/rug from https://atomist.jfrog.io/atomist/api/npm/npm-dev"
            return 1
        fi
        if [[ $ATOMIST_REPO_TOKEN  && $ATOMIST_REPO_USER ]]; then
            msg "Creating local .npmrc using API key from environment"
            if ! ( curl -u"${ATOMIST_REPO_USER}":"${ATOMIST_REPO_TOKEN}" "https://atomist.jfrog.io/atomist/api/npm/auth" >  "$HOME/.npmrc"); then
                err "failed to create $HOME/.npmrc"
                return 1
            fi
        else
            msg "assuming your .npmrc is setup correctly for this project"
        fi

        if ! ( cd "$target" && npm publish --registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local --access=public ); then
            err "failed to publish node module"
            cat "$target/npm-debug.log"
            return 1
        fi
    fi
}

function main() {
    publish "$@" || return 1
}

main "$@" || exit 1
exit 0
