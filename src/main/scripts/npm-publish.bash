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
    fi
    shift

    local target="target/.atomist/node_modules/@atomist/$module_name"

    # npm honors this
    rm -f "$target/.gitignore"

    local registry
    if [[ $module_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [[ $NPM_TOKEN ]]; then
            msg "creating local .npmrc using NPM token from environment"
            if ! ( umask 077 && echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > "$HOME/.npmrc" ); then
                err "failed to create $HOME/.npmrc"
                return 1
            fi
        else
            msg "assuming your .npmrc is setup correctly for this project"
        fi
    elif [[ $TRAVIS_BRANCH == master ]]; then
        if ! npm install @atomist/rug@latest -S --registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local; then
            err "Failed to install latest @atomist/rug from https://atomist.jfrog.io/atomist/api/npm/npm-dev-local"
            return 1
        fi
        if [[ $ATOMIST_REPO_TOKEN && $ATOMIST_REPO_USER ]]; then
            msg "creating local .npmrc using auth details pulled from Artifactory"
            if ! ( curl --quiet -u"$ATOMIST_REPO_USER:$ATOMIST_REPO_TOKEN" https://atomist.jfrog.io/atomist/api/npm/auth > "$HOME/.npmrc" ); then
                err "failed to create $HOME/.npmrc"
                return 1
            fi
        else
            msg "assuming your .npmrc is setup correctly for this project"
        fi
    else
        registry=--registry=https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
    fi

    if ! ( cd "$target" && npm publish --access=public $registry ); then
        err "failed to publish node module"
        cat "$target/npm-debug.log"
        return 1
    fi
}

function main() {
    publish "$@" || return 1
}

main "$@" || exit 1
exit 0
