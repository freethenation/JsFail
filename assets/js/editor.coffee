#= require codemirror
CodeMirror.defineInitHook((editor)->
    if editor.options.fill
        $(window).resize(()->
            height = $(window).height() - $('#header').outerHeight(true)
            $.each($('#content>div:not(#editordiv)'),(i,ele)->height-=$(ele).outerHeight(true))
            editor.setSize("100%","#{height-10}px")
        )
        $(window).trigger("resize")
)