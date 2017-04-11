# Atomist 'cortex'

[![Build Status](https://travis-ci.org/atomist/cortex.svg?branch=master)](https://travis-ci.org/atomist/cortex)
[![Slack Status](https://join.atomist.com/badge.svg)](https://join.atomist.com)

Dynamically generate the [TypeScript][typescript] NPM
module [`@atomist/cortex`][cortex-npm].

[cortex-npm]: https://www.npmjs.com/package/@atomist/cortex
[typescript]: https://www.typescriptlang.org/

## Developing

Building this project requires downloading the latest version of the
cortex schema from the model service.  The `travis-build.bash` script
in `src/main/scripts` shows how this can be done.  This schema is used
by the `CortexTypeGeneratorApp` in [rug][], which is brought in via a
dependency, to generate the TypeScript sources during
the [Maven][maven] build, see the [POM][pom].

Running through to the compile phase of the build will install the
needed JVM and Node.js dependencies and generate the needed files
under the build directory, typically `target`.

```
$ mvn compile
```

The generated TypeScript sources can be found under
`target/.atomist/node_modules/@atomist/cortex`.

[travis-yml]: .travis.yml
[rug]: https://github.com/atomist/rug
[maven]: https://maven.apache.org/
[pom]: pom.xml

Running through the test phase of the build will do all of the above
and use the TypeScript compiler to compile the generated sources.

```
$ mvn test
```

Running through the package phase will generate the [TypeDoc][typedoc]
for the TypeScript module.

```
$ mvn package
```

The resulting documentation can be found under `target/typedoc`.

[typedoc]: http://typedoc.org/

By default builds will use the version of the `@atomist/rug` node
module set in `src/main/typescript/package.json` and will use the
production version of the cortex model, available at
https://api.atomist.com/model/schema .

## Releasing

Releasing cortex often needs to be done in coordination with a Rug
release.  To allow some flexibility, there are a few ways to release
it.

Once a new version of this repository has been released, you will need
to update its version in the dependencies of the [rugs][] repository
`package.json` and initiate a new release of that repository to
publish a new version of the `@atomist/rugs` TypeScript module, which
is the dependency everyone uses to bring in rug and cortex.

[rugs]: https://github.com/atomist/rugs

### Production release

To create a new release of the project, simply push a tag of the form
`M.N.P` where `M`, `N`, and `P` are integers that form the next
appropriate [semantic version][semver] for release.  For example:

[semver]: http://semver.org

```
$ git tag -a 1.2.3
```

The Travis CI build (see badge at the top of this page) will upload
the needed artifacts:

-   Node module [`@atomist/cortex`][cortex-npm] to [NPM][npm]
-   TypeDoc to the gh-pages branch of this repository, which can be
    viewed at http://cortex.atomist.com/

The build will also automatically create a GitHub release using the
tag name for the release and the comment provided on the annotated tag
as the contents of the release notes.

[npm]: https://www.npmjs.com/

### Production release using staging mode

To create a new release of the project based on `staging` cortex,
simply push a tag of the form `M.N.P-staging`.  For example:

```
$ git tag -a 1.2.3-staging
```

**NOTE:** the published npm module version will _not_ include
`-staging` in its name and will be published to npmjs.org.

The Travis CI build will upload the needed artifacts:

-   Node module [`@atomist/cortex`][cortex-npm] to [NPM][npm]
-   TypeDoc to the gh-pages branch of this repository, which can be
    viewed at http://cortex.atomist.com/

The build will also automatically create a GitHub release using the
tag name for the release and the comment provided on the annotated tag
as the contents of the release notes.

### Development release

To create a new snapshot/development release of the project based on
the development version of @atomist/rug, simply push a tag of the form
`M.N.P-snapshotI`.  For example:

```
$ git tag -a 1.2.3-snapshot0
```

**NOTE:** the published npm module version string will have
`-snapshotI` replaced with a timestamp and will be published to
https://atomist.jfrog.io/atomist/api/npm/npm-dev-local

The snapshot build will be based on the `staging` cortex model.  The
Travis CI build will upload the node
module [`@atomist/cortex`][cortex-npm] to the development repository.
The TypeDocs will not be published.  No GitHub release will be
created.

If you would like to use the development version of the cortex module,
the most straightforward way to get these versions without making
changes to your configuration is:

```bash
$ npm install @atomist/cortex@latest --registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
```

Alternatively, if you always want the latest snapshots, you can change
your config for the @atomist scope:

```
$ npm config set @atomist:registry https://atomist.jfrog.io/atomist/api/npm/npm-dev-local
```

---
Created by [Atomist][atomist].
Need Help?  [Join our Slack team][slack].

[atomist]: https://www.atomist.com/
[slack]: https://join.atomist.com/
