#= require ../modes/javascript
#= require ../esprima
#= require ../escodegen.browser
window.jstools={}
extern=(name,value)->window.jstools[name]=value

prettyPrintJs=(str,options={})->
    ast = esprima.parse(str,{
        comment:true
        #tolerant:true #An extra array containing all errors found, attempts to continue parsing when an error is encountered
    })
    escodegen.generate(ast,$.extend({
        comment:true
        semicolons:false
    },options))
extern("prettyPrintJs",prettyPrintJs)