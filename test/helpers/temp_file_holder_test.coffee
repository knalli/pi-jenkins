fs = require 'fs'

{TempFileHolder} = require "#{__dirname}/../../lib/helpers/temp_file_holder"

exports['Helper.TempFileHolder'] =
  setUp: (done) ->
    done()

  tearDown: (done) ->
    done()

  'Write data and verify write': (test) ->
    holder = new TempFileHolder()
    promise = holder.write ['abc']
    promise.then ((path) ->
      result = fs.readFileSync path, 'utf-8'
      test.equal result, 'abc', 'The file was written successfully.'
    ), ((err) ->
      test.equal true, false, "Test was not completed correctly: #{err}"
    )
    promise.fin ->
      test.equal promise.isFulfilled(), true, 'Promise (write) should not be rejected.'
      test.done()

  'Write nothing and verify error': (test) ->
    holder = new TempFileHolder()
    promise = holder.write()
    promise.fin ->
      test.equal promise.isFulfilled(), false, 'Promise (write) should be rejected.'
      test.done()

  'Write, and delete it again': (test) ->
    holder = new TempFileHolder()
    promise = holder.write('abc')
    promise.then (path) ->
      holder.delete path
    promise.then (path) ->
      # verify that the file is not available
      # test.equal fs.existsSync(path), false, 'File should not be exist anymore.'
      # verify that another call of delete doest not throw any errors.
      holder.delete(path)
    promise.fin ->
      test.equal promise.isFulfilled(), true, 'Promise (write) should not be rejected.'
      test.done()

