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

## Releasing

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

[semver]: http://semver.org
[cortex-npm]: https://www.npmjs.com/package/@atomist/cortex
[npm]: https://www.npmjs.com/

---
Created by [Atomist][atomist].
Need Help?  [Join our Slack team][slack].

[atomist]: https://www.atomist.com/
[slack]: https://join.atomist.com/
