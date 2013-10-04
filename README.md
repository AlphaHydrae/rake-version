# rake-version

**Simple rake tasks for version management.**

[![Gem Version](https://badge.fury.io/rb/rake-version.png)](http://badge.fury.io/rb/rake-version)
[![Dependency Status](https://gemnasium.com/AlphaHydrae/rake-version.png)](https://gemnasium.com/AlphaHydrae/rake-version)
[![Build Status](https://secure.travis-ci.org/AlphaHydrae/rake-version.png?branch=master)](http://travis-ci.org/AlphaHydrae/rake-version)
[![Coverage Status](https://coveralls.io/repos/AlphaHydrae/rake-version/badge.png?branch=master)](https://coveralls.io/r/AlphaHydrae/rake-version?branch=master)

**rake-version** helps you manage your `VERSION` file according to the rules of [semantic versioning](http://semver.org).
It does nothing more.
It does not create tags; it does not commit; it does not push; it does not release.

## Installation

Add to your Gemfile and `bundle install`:

```rb
gem "rake-version", "~> 0.0"
```

Add the tasks to your Rakefile:

```rb
require 'rake-version'
RakeVersion::Tasks.new
```

## Usage

```bash
# show current version
rake version              #=> 1.0.0

# bump version
rake version:bump:patch   #=> 1.0.1
rake version:bump:minor   #=> 1.1.0
rake version:bump:major   #=> 2.0.0

# set version
rake "version:set[1.2.3]" #=> 1.2.3
```

### Auto-update other files

When you add the rake version tasks in your Rakefile, you may specify additional files to update with the new version.

```rb
require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'lib/my-gem.rb'          # update single file
  v.copy 'lib/a.rb', 'lib/b.rb'   # update multiple files
  v.copy 'lib/*.rb'               # update all files matching a glob pattern
  v.copy /lib/                    # update all files whose path matches a regexp
end
```

By default, **rake-version** will replace the first occurrence of a semantic version pattern (`number.number.number(-prerelease)(+build)`) with the new version.
It will not modify the prerelease version or build metadata.
For example, when bumping the minor version from 1.0.0, it will change the contents of this file:

```rb
class Thing
  VERSION = '1.0.0'
end
```

To this:

```rb
class Thing
  VERSION = '1.1.0'
end
```

You can customize this behavior as follows:

```rb
RakeVersion::Tasks.new do |v|
  v.copy 'lib/my-gem.rb', all: true   # replace all occurrences
end
```

### Semantic versioning

**rake-version** partially supports [semantic versioning v2.0.0](http://semver.org/spec/v2.0.0.html).
You can add prerelease (e.g. `-beta`) and build (e.g. `+20131313`) information to your versions,
but there are currently no tasks to update them other than `version:set`.

## Meta

* **Author:** Simon Oulevay (Alpha Hydrae)
* **License:** MIT (see [LICENSE.txt](https://raw.github.com/AlphaHydrae/rake-version/master/LICENSE.txt))
