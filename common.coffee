# some util methods
_ = require 'underscore'
module.exports.flatten = _.flatten
module.exports.extend = _.extend

# load config
nconf = require('nconf')
nconf.env().argv() # process.env and process.argv
nconf.file('config.json')
nconf.defaults({
    httpPort:3001
    debug:true
    logFile:'notify.log'
    appName:'JSTools'
})
module.exports.nconf = nconf

# setup logger
logger = require('winston')
logger.add(logger.transports.File, { filename: nconf.get('logFile'), handleExceptions:!nconf.get('debug'), exitOnError: false })
logger.debug('Logger Initialized!')
module.exports.logger = logger
