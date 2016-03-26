chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
path            = require 'path.js'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

FileLayout    = require '../src'
Resource        = require 'resource-file'
fs              = require 'graceful-fs'

fs.cwd = process.cwd
fs.path = path
Resource.setFileSystem fs

describe 'FileLayoutTask', ->
  task = FileLayout()

  describe 'register layout', ->
    beforeEach ->
      task.layouts = {}
      task.defaultLayout = null
    describe 'sync', ->
      it 'should register a layout via resource object', ->
        file = Resource './fixture/main.layout.md', cwd:__dirname
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
      it 'should register a layout with specified name via resource object', ->
        file = Resource './fixture/main.layout.md', name: 'MainO', cwd:__dirname
        task.executeSync file
        expect(task.layouts).to.have.property 'MainO'
        expect(task.layouts.MainO).to.have.property('content').include 'main before'
      it 'should register a layout', ->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
      it 'should register a default layout', ->
        file = isDefaultLayout: true, path: path.join __dirname, './fixture/main.layout.md'
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
        expect(task.defaultLayout).to.be.equal 'main'
      it 'should register a layout with layoutBase option', ->
        file = layoutBase: 'one', path: path.join __dirname, './fixture/main.layout.md'
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
        expect(task.layouts.main).to.have.property('layout').equal 'one'
      it 'should not register the same name layout', ->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
        expect(task.executeSync.bind task, file).to.be.throw 'name is already exist'
      it 'should register the same name layout with overwrite option', ->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.executeSync file
        expect(task.layouts).to.have.property 'main'
        expect(task.layouts.main).to.have.property('content').include 'main before'
        file.overwrite = true
        task.layouts.main = {}
        task.executeSync file
        expect(task.layouts.main).to.have.property('content').include 'main before'
    describe 'async', ->
      it 'should register a layout via resource object', (done)->
        file = Resource './fixture/main.layout.md', cwd:__dirname
        task.execute file, (err,result)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          done(err)
      it 'should register a layout with specified name via resource object', (done)->
        file = Resource './fixture/main.layout.md', name: 'MainO', cwd:__dirname
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'MainO'
          expect(task.layouts.MainO).to.have.property('content').include 'main before'
          done(err)
      it 'should register a layout', (done)->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          done(err)
      it 'should register a default layout', (done)->
        file = isDefaultLayout:true, path: path.join __dirname, './fixture/main.layout.md'
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          expect(task.defaultLayout).to.be.equal 'main'
          done(err)
      it 'should register a layout with layoutBase option', (done)->
        file = layoutBase: 'one', path: path.join __dirname, './fixture/main.layout.md'
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          expect(task.layouts.main).to.have.property('layout').equal 'one'
          done(err)
      it 'should not register the same name layout', (done)->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          expect(task.executeSync.bind task, file).to.be.throw 'name is already exist'
          done(err)
      it 'should register the same name layout with overwrite option', (done)->
        file = path: path.join __dirname, './fixture/main.layout.md'
        task.execute file, (err)->
          expect(task.layouts).to.have.property 'main'
          expect(task.layouts.main).to.have.property('content').include 'main before'
          file.overwrite = true
          task.layouts.main = {}
          task.execute file, (err)->
            expect(task.layouts.main).to.have.property('content').include 'main before'
            done(err)
  describe 'apply layout', ->
    beforeEach ->
      task.layouts =
        one: {content: 'one before\n{% body %}\none after', layout: 'two'}
        two: {content: 'two before\n{% body %}\ntwo after'}
        main: {content: 'main before\n{% body %}\nmain after'}
      task.defaultLayout = null

    describe 'sync', ->
      it 'should apply a layout via resource object', ->
        file = Resource './fixture/README.md', cwd:__dirname, layout: 'main'
        result = task.executeSync file
        expect(result).to.be.match /main before[\n\r]+this is the test folder.[\n\r]+main after/
      it 'should apply a layout', ->
        file = layout: 'main', path: path.join __dirname, './fixture/README.md'
        result = task.executeSync file
        expect(result).to.be.equal 'main before\nthis is the test folder.\nmain after'
      it 'should apply a wrap layout', ->
        file = layout: 'one', path: path.join __dirname, './fixture/README.md'
        result = task.executeSync file
        expect(result).to.be.equal 'two before\none before\nthis is the test folder.\none after\ntwo after'
      it 'should apply a layout with default layout', ->
        task.defaultLayout = 'main'
        file = layout: 'two', path: path.join __dirname, './fixture/README.md'
        result = task.executeSync file
        expect(result).to.be.equal 'main before\ntwo before\nthis is the test folder.\ntwo after\nmain after'
    describe 'async', ->
      it 'should apply a layout via resource object', (done)->
        file = Resource './fixture/README.md', cwd:__dirname, layout: 'main'
        task.execute file, (err, result)->
          expect(result).to.be.match /main before[\n\r]+this is the test folder.[\n\r]+main after/
          done(err)
      it 'should apply a layout', (done)->
        file = layout: 'main', path: path.join __dirname, './fixture/README.md'
        task.execute file, (err, result)->
          expect(result).to.be.equal 'main before\nthis is the test folder.\nmain after'
          done(err)
      it 'should apply a wrap layout', (done)->
        file = layout: 'one', path: path.join __dirname, './fixture/README.md'
        task.execute file, (err, result)->
          expect(result).to.be.equal 'two before\none before\nthis is the test folder.\none after\ntwo after'
          done(err)
