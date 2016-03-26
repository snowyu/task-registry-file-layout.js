## task-registry-file-layout [![npm](https://img.shields.io/npm/v/task-registry-file-layout.svg)](https://npmjs.org/package/task-registry-file-layout)

[![Build Status](https://img.shields.io/travis/snowyu/task-registry-file-layout.js/master.svg)](http://travis-ci.org/snowyu/task-registry-file-layout.js)
[![Code Climate](https://codeclimate.com/github/snowyu/task-registry-file-layout.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/task-registry-file-layout.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/task-registry-file-layout.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/task-registry-file-layout.js/coverage)
[![downloads](https://img.shields.io/npm/dm/task-registry-file-layout.svg)](https://npmjs.org/package/task-registry-file-layout)
[![license](https://img.shields.io/npm/l/task-registry-file-layout.svg)](https://npmjs.org/package/task-registry-file-layout)

* Apply a layout to the file contents.
* Register a layout to the system.
* add the layout search path for directory.

## Usage

```coffee
Task = require 'task-registry'
require 'task-registry-file-layout'

layout = Task 'layout'

# register the layout as 'main' layout
# the name is optional, the file base name is the name if no name.
layout.executeSync path: 'main.layout', isDefaultLayout: true, overwrite: true

# apply the layout to the file contents.
# the layout could be a name or a file path.
layout.executeSync path: 'hi.md', layout: 'main'
```

## API

* `executeSync(aFile)` or `execute(aFile, done)`:
  * the `aFile` should be a json object or the [File][file] object.
    * `path` *String*: the file path
    * apply the layout to the file contents
      * `layout` *String*: apply the layout to the file
    * the file contents as a layout to register
      * `name` *String*: the layout name to register (optional). the file basename is the layout name unless exists.
      * `isDefaultLayout` *Boolean*: whether this is the default layout. defaults to false.
      * `overwrite` *Boolean*: whether overwrite if the layout name has already exists. defaults to false.
      * `layoutBase` *String*: this layoutBase will wrap(nest) the layout.
      * `layoutTag` *String*: the name of the placeholder tag. defaults to 'body'
      * `layoutDelims` *Array of String|Regex*:  the placeholder delimiters to use. This can be a regex, like `/\{{([^}]+)\}}/`, or an array of delimiter strings, like `['{{', '}}']`. defaults to `{% body %}` is used as the placeholder (insertion point) for content.


## TODO


## License

MIT

[file]:https://github.com/snowyu/abstract-file.js