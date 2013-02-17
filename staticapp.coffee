#!/usr/bin/env coffee
express = require('express')
http = require('http')
app = express()
app.use(express.directory(__dirname + "/bin", {icons:true}))
app.use(express.static(__dirname + "/bin"))
http.createServer(app).listen(8080, ()-> console.log('listening on 8080'))