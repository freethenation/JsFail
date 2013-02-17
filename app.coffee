#!/usr/bin/env coffee
express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
ect = require('ect')
common = require('./common')
nconf = common.nconf
logger = common.logger
fs = require('fs')

# create app
app = express()
ectRenderer = ect({ watch: nconf.get("debug"), root: __dirname + '/views' })
logger.info('App Created!')

# create compiler
compiler = require('connect-compiler')({
    enabled:['snockets','less']
    src:['assets','assets/bootstrap/']
    dest:'public'
    options:{
        snockets:{minify:!nconf.get("debug")}
        less:{paths:["./assets/bootstrap/css","./assets/css"],compress:!nconf.get("debug")}
    }
})

# create tool list
tmp = (tool.replace(".coffee","") for tool in fs.readdirSync('./tools') when /\.coffee$/.test(tool))
logger.info("Tools Found! " + tmp)
tmp = (require('./tools/' + tool) for tool in tmp)
tools = {length:tmp.length}
for i in [0...tmp.length] by 1
    tools[i]=tmp[i]
    tools[tmp[i].page]=tmp[i]
global.tools = tools
logger.info("Tools Loaded!")

app.configure(()->
    app.set('port', nconf.get("httpPort"))
    app.set('views', __dirname + '/views')
    app.engine('ect', ectRenderer.render)
    if !nconf.get("debug") then app.use(express.compress())
    app.use(express.favicon())
    app.use(express.logger('dev'))
    # app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(compiler)
    # app.use(express.cookieParser('braSP8pUpR5XuDapHAT9e87ecHUtHufr'))
    # app.use(express.cookieSession({cookie: { maxAge: 60 * 60 * 1000 }}))
    app.use(app.router)
    app.use(express.static(path.join(__dirname, 'public')))
    app.use((err, req, res, next)-> # Handle any unhandled errors
        if err
            logger.error(err.stack)
            res.send(500, 'Somthing went quite wrong!')
            # res.redirect(500, "500")
        else next()
    )
)
logger.info('App Configured!')

app.get(/\/tools\/.*\.html/, routes.tool)
app.get('/index.html', routes.simple("index"))
app.get('/', routes.simple("index"))

http.createServer(app).listen(nconf.get("httpPort"), ()->
    logger.info("Server listening on port #{nconf.get('httpPort')}!")
)
