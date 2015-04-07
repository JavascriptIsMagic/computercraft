require 'cake-gulp'
path = require 'path'

browserify = require 'browserify'
watchify = require 'watchify'

cjsx = require 'coffee-reactify'
uglify = require 'uglifyify'

jquery = "#{path.dirname require.resolve 'jquery/dist/jquery'}"
semantic = "#{path.dirname require.resolve 'semantic-ui/dist/semantic'}"

option '-w', '--watch', 'Watchify files.'

task 'build:clean', 'Delete all auto-generated files.', (options, callback) ->
  del ["#{__dirname}/dist/**/*"], (error, files) ->
    if error
      throw error
    log "[#{green 'Deleted'}]\n#{files.map(fancypath).join '\n'}"
    callback()

task 'build:files', 'Copies static files.', ['build:clean'], (options, callback) ->
  files = [
    "#{__dirname}/src/**/*.html"
    "#{__dirname}/src/**/*.png"
    "#{__dirname}/src/**/*.min.*"
    "#{jquery}/**/jquery.min.*"
    "#{semantic}/**/semantic.min.*"
    "#{semantic}/**/icons.*"
  ]
  # if options.watch
  #   watch files, 'build:files'
  src files
    .pipe dest "#{__dirname}/dist"

task 'build', 'Browserify all the things!', ['build:files'], (options, callback) ->
  config =
    entry: './src/bundle.cjsx'
    path: "#{__dirname}/dist"
    debug: options.watch
  if options.watch
    for own key of watchify.args
      unless key of options
        config[key] = watchify.args[key]
  for own key of options
    config[key] = options[key]
  bundler = if options.watch then watchify browserify config else browserify config

  bundler.transform [cjsx, extension: 'cjsx']
  unless options.watch
    bundler.transform [uglify, global: yes]
  bundler.require require.resolve(config.entry), entry: yes

  rebuild = (files) ->
    if Array.isArray files
      files = files
        .map fancypath
        .join '\n'
    log "[#{green if options.watch then 'Watchify!' else 'Browserify!'}]\n#{files or '...'}"
    bundler
      .bundle()
      .on 'error', log.bind 'Browserify Error: '
      .pipe source config.entry
      .pipe rename 'bundle.min.js'
      .pipe dest config.path

  bundler
    .on 'update', rebuild
    .on 'log', log

  rebuild()
