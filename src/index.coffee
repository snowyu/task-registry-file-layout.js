fs                = require 'graceful-fs'
path              = require 'path.js'
Task              = require 'task-registry'
renderLayouts     = require 'layouts'
defineProperty    = require 'util-ex/lib/defineProperty'
isFunction        = require 'util-ex/lib/is/type/function'
register          = Task.register
aliases           = Task.aliases
defineProperties  = Task.defineProperties

getBaseName = (aFileName)->
  result = path.basename aFileName
  i = result.indexOf '.'
  result.substr 0, i


MISSING_OPTIONS   = 'missing path'

module.exports    = class FileLayoutTask
  register FileLayoutTask
  aliases FileLayoutTask, ['layout']

  @layouts: {} # the registered layouts

  defineProperty @, 'layouts', @layouts

  @defineProperties: defineProperties
  defineProperties @,
    path: # the file to be processed/apply.
      type: 'String'
    layout:
      type: 'String'
    isDefaultLayout: # set the layout as the default layout
      type: 'Boolean'
    defaultLayout:
      type: 'String'
    overwrite:
      type: 'Boolean'
    layoutBase:
      type: 'String'
    layoutTag:
      type: 'String'
      value: 'body'
    layoutDelims:
      type: 'String'

  constructor: ->return super

  getContentSync = (aFile)->
    if aFile.path?
      if isFunction(aFile.getContentSync)
        if !aFile.hasOwnProperty('_contents') && aFile.parent && !aFile.parent.isDirectory()
          # the inherited file resource object use the parent's contents if parent is a file(not folder) and no contents on itself.
          vFile = aFile.parent
        else
          vFile = aFile
        contents = vFile.getContentSync(text:true)
      else
        encoding = aFile.encoding
        encoding ?= 'utf8'
        contents = fs.readFileSync aFile.path, encoding:encoding
    else
      throw new TypeError MISSING_OPTIONS
    contents

  getContent = (aFile, done)->
    if aFile.path?
      if isFunction(aFile.getContent)
        if !aFile.hasOwnProperty('_contents') && aFile.parent && !aFile.parent.isDirectory()
          vFile = aFile.parent
        else
          vFile = aFile
        vFile.getContent text:true, done
      else
        encoding = aFile.encoding
        encoding ?= 'utf8'
        fs.readFile aFile.path, encoding:encoding, done
    else
      done new TypeError MISSING_OPTIONS

  renderLayout: (aFile, contents) ->
    if aFile.layout # apply the layout to contents
      result = renderLayouts contents, aFile.layout, @layouts,
        defaultLayout: aFile.defaultLayout
        tag: aFile.layoutTag
        layoutDelims: aFile.layoutDelims
      result = result.result if result
      if result and aFile.contents
        vCfg = if aFile.skipSize then aFile.contents.toString().slice(0, aFile.skipSize) else ''
        aFile.contents = vCfg + result
    else if contents # it's a layout to add
      vLayoutName = aFile.name
      vLayoutName = getBaseName(aFile.path) unless vLayoutName
      if !aFile.overwrite and @layouts.hasOwnProperty vLayoutName
        throw new TypeError 'the layout name is already exists:' + vLayoutName
      result = content: contents
      result.layout = aFile.layoutBase if aFile.layoutBase
      if aFile.isDefaultLayout
        @defaultLayout = vLayoutName
        @logger.notice 'default layout changed:' + vLayoutName  if @logger
      @layouts[vLayoutName] = result
    result

  _executeSync: (aFile)->
    contents = getContentSync(aFile)
    @renderLayout aFile, contents

  _execute: (aFile, done)->
    getContent aFile, (error, contents)=>
      return done(error) if error

      done(null, @renderLayout aFile, contents)
