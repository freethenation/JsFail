#= require ../esprima
#= require ../escodegen.browser
#= require ../utils
if not window.jstools? then window.jstools = {}
jstools = window.jstools
widgets=[]
clearErrors=(editor,errorMsgEle)->
    while widgets.length > 0
        editor.removeLineWidget(widgets.pop())
    #hide error div if supplied
    if errorMsgEle 
        $(errorMsgEle).css('visibility','hidden')
        #$(window).trigger("resize") #make text area fill after hide
displayErrors=(editor,errors,errorMsgEle)->
    errors = errors.errors if !jstools.isArray errors
    if !(errors?.length > 0) then return
    for err in errors
        msg = $("<div class='alert alert-error no-margin std-padding'><b>Error: </b><span></span></div>")
        msg.find("span").text(err.description)
        widgets.push(editor.addLineWidget(err.lineNumber - 1, msg[0], {coverGutter: false, noHScroll: true}));
    #display error div if supplied
    if errorMsgEle 
        $(errorMsgEle).css('visibility','visible')
        #$(window).trigger("resize") #make text area fill after show
    #maintain scroll position
    info = editor.getScrollInfo()
    after = editor.charCoords({line: editor.getCursor().line + 1, ch: 0}, "local").top
    if info.top + info.clientHeight < after
        editor.scrollTo(null, after - info.clientHeight + 3)
parseJs=(editor)->
    str = editor.getValue()
    #parse the source
    try
        ast = esprima.parse(str,{
            comment:true
            tolerant:true #adds an extra array containing all errors found,
        })
    catch err
        return {errors:[err],success:false} #critical error... bail
    ast.success = true
    return ast
prettyPrintJs=(editor, options={})->
    str = editor.getValue()
    ast = parseJs(editor)
    if !ast.success then return ast
    #format the source
    newStr = escodegen.generate(ast,$.extend({
        comment:true
        semicolons:false
    },options))
    editor.setValue(newStr)
    #if there was formatting done redo prettyPrintJs to get new error line numbers
    if str != newStr then return prettyPrintJs(editor, options)
    else return ast

#export stuff so someone else can see them
jstools.prettyPrintJs = prettyPrintJs
jstools.clearErrors = clearErrors
jstools.displayErrors = displayErrors
jstools.parseJs = parseJs