fs = require 'fs'
funcflow = require 'funcflow'
_ = require 'underscore'
childProcess = require 'child_process'
flatten = _.flatten

runStaticSteps = [
    (step,err)->
        callback = ()->require('./staticapp')
        setTimeout(callback,0)
        step.next()
]

runSteps = [
    (step,err)->
        callback = ()->require('./app')
        setTimeout(callback,0)
        step.next()
]

buildSteps=()-> return [
    runSteps
    (step,err)-> # wait for server to start
        setTimeout(step.next, 3000)
    (step,err)->
        childProcess.exec('wget --no-host-directories  --directory-prefix ./bin -r http://localhost:3001/', step.next)
    (step,err, error, stdout, stderr)->
        if error
            console.log(error.stack);
            console.log('Error code: '+error.code);
            console.log('Signal received: '+error.signal);
        console.log('wget STDOUT:\n'+stdout);
        console.log('wget STDERR:\n'+stderr);
        step.next()
]

exitStep = (step,err)->process.exit()

createMinJsSteps=()->
    createCompileSteps=(filename)->
        return [
            (step, err)->readFile(filename, step.next)
            (step, err, file)->compress(file, step.next)
            (step, err, file)->writeFile(filename, file, step.next)
        ]
    return [
        (step, err)->require('glob')("bin/**/*.js", step.next)
        (step, err, er, files)->
            console.log "Minifying the following js files:"
            console.log files
            funcflow(flatten(createCompileSteps(f) for f in files), {catchExceptions:false}, step.next)
    ]

createMinJsCss=()->
    createCompileSteps=(filename)->
        return [
            (step, err)->readFile(filename, step.next)
            (step, err, file)->compressCss(file, step.next)
            (step, err, file)->writeFile(filename, file, step.next)
        ]
    return [
        (step, err)->require('glob')("bin/**/*.css", step.next)
        (step, err, er, files)->
            console.log "Minifying the following css files:"
            console.log files
            funcflow(flatten(createCompileSteps(f) for f in files), {catchExceptions:false}, step.next)
    ]

task 'build', 'builds a static version of the website', (options)->
    funcflow(flatten([buildSteps(),exitStep]), {catchExceptions:false, "options":options}, ()->)

task 'build:min', 'builds a static minimized version of the website', (options)->
    funcflow(flatten([buildSteps(),createMinJsSteps(),createMinJsCss(),exitStep]), {catchExceptions:false, "options":options}, ()->)

task 'run', 'runs the website on port 3001', (options)->
    funcflow(flatten(runSteps), {catchExceptions:false, "options":options}, ()->)

task 'run:static', 'runs the built static version of the website on port 8080', (options)->
    funcflow(flatten(runStaticSteps), {catchExceptions:false, "options":options}, ()->)

compile = (inputFile, callback) ->
    coffee = require 'coffee-script'
    callback?(coffee.compile(inputFile))

compress = (inputFile, callback) ->
    UglifyJS = require "uglify-js"
    toplevel = UglifyJS.parse(inputFile)
    toplevel.figure_out_scope()
    compressor = UglifyJS.Compressor()
    compressed_ast = toplevel.transform(compressor)
    compressed_ast.figure_out_scope()
    compressed_ast.compute_char_frequency()
    compressed_ast.mangle_names()
    callback?(compressed_ast.print_to_string())

compressCss = (inputFile, callback) ->
    callback?(require('clean-css').process(inputFile))
    
readFile = (filename, callback) ->
    data = fs.readFile(filename, 'utf8', (err, data)-> if err then throw err else callback(data))
 
writeFile = (filename, data, callback) ->
    fs.writeFile(filename, data, 'utf8', (err)-> if err then throw err else callback())

test = (inputFile, throwException, callback) ->
    tests = require(inputFile)
    tests.RunAll(throwException)
    callback()