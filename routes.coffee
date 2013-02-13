_=require('underscore')

createParms=(additionalParms={})->
    return _.extend({
        tools:global.tools
        nconf:require('./common').nconf
    },additionalParms)

exports.tool=(req, res, next)->
    #check to ensure tool request is valid
    toolName = req.url.replace('.html','').replace('/tools/','')
    if not global.tools[toolName]? then return next()
    #do tool request
    parms = createParms({
        tool:global.tools[toolName]
        page:"tools/#{toolName}"
    })
    res.render("tools/#{toolName}.ect", parms)

exports.simple=(viewName)->
    return (req, res)->
        res.render("#{viewName}.ect", createParms({page:viewName}))