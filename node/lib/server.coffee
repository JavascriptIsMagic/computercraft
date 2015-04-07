koala = require 'koala'
send = require 'koa-send'

app = module.exports = new koala
app.use (next) ->
  if @request.is 'json'
    @data = yield @request.json()
    yield next
  else
    if /\/[^\/\.]*$/.test @path
      yield send @, '/index.html', root: "#{__dirname}/../dist"
    else
      yield send @, @path, root: "#{__dirname}/../dist"

new (require './monitoring') app
