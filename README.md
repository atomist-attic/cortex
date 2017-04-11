# Atomist 'cortex'

[![Build Status](https://travis-ci.org/atomist/cortex.svg?branch=master)](https://travis-ci.org/atomist/cortex)
[![Slack Status](https://join.atomist.com/badge.svg)](https://join.atomist.com)

Dynamically generate the TypeScript NPM module `@atomist/cortex`.

## Developing

Building this project requires downloading the latest version of the
cortex schema from the model service.  The `install` step of the
Travis CI build, see [`.travis.yml`][travis-yml], shows how this can
be done.  This schema is used by the `CortexTypeGeneratorApp`
in [rug][], which is brought in via a dependency, to generate the
TypeScript sources during the [Maven][maven] build, see
the [POM][pom].

```
$ mvn compile
```

The generated TypeScript sources can be found under
`target/.atomist/node_modules/@atomist/cortex`.

[travis-yml]: .travis.yml
[rug]: https://github.com/atomist/rug
[maven]: https://maven.apache.org/
[pom]: pom.xml

If you run the tests, the build will also generated
the [TypeDoc][typedoc] for the TypeScript module.

```
$ mvn test
```

The resulting documentation can be found under `target/typedoc`.

[typedoc]: http://typedoc.org/

## Releasing

### Full production release 

To create a new release of the project, simply push a tag of the form
`M.N.P` where `M`, `N`, and `P` are integers that form the next
appropriate [semantic version][semver] for release.  For example:

```
$ git tag -a 1.2.3
```

The Travis CI build (see badge at the top of this page) will
automatically create a GitHub release using the tag name for the
release and the comment provided on the annotated tag as the contents
of the release notes.  It will also automatically upload the needed
artifacts:

-   Node module [`@atomist/cortex`][cortex-npm] to [NPM][npm]
-   TypeDoc to the gh-pages branch of this repository, which can be
    viewed at http://cortex.atomist.com/

### Staging release

To create a new release of the project based on `staging` cortex, 
simply push a tag of the form `M.N.P-staging` where `M`, `N`, and `P` 
are integers that form the next appropriate [semantic version][semver]
for release, and the `-staging` indicates that cortex from the Staging
environment should be used. For example:

```
$ git tag -a 1.2.3-staging
```

**NOTE: the published npm module version will _not_ include `-staging` in
 its name but will be published to npmjs.org**

The Travis CI build (see badge at the top of this page) will
automatically create a GitHub release using the tag name for the
release and the comment provided on the annotated tag as the contents
of the release notes.  It will also automatically upload the needed
artifacts:

-   Node module [`@atomist/cortex`][cortex-npm] to [NPM][npm]
-   TypeDoc to the gh-pages branch of this repository, which can be
    viewed at http://cortex.atomist.com/

### Development release

To create a new snapshot/development release of the project based 
on the development version of @atomist/rug, simply push a tag of the
form `M.N.P-snapshots` where `M`, `N`, and `P` are integers that form
the next appropriate [semantic version][semver] for release, and the 
`-snapshots` indicates that snapshot release of `@atomist/rug` should
be used. For example:

```
$ git tag -a 1.2.3-snapshots
```

**NOTE: the published npm module version string will _not_ include `-snapshots`
and will be published to https://atomist.jfrog.io/atomist/api/npm/npm-dev-local**

The most straightforward way to get these versions without making changes to
your configuration is:

```bash
$ npm install @atomist/cortex --registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
```

Alternatively, if you always want the latest snapshots, you can change
your config for the @atomist scope:

```
npm config set @atomist:registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
```

[semver]: http://semver.org
[cortex-npm]: https://www.npmjs.com/package/@atomist/cortex
[npm]: https://www.npmjs.com/

---
Created by [Atomist][atomist].
Need Help?  [Join our Slack team][slack].

[atomist]: https://www.atomist.com/
[slack]: https://join.atomist.com/
