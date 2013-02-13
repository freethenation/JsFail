#= require codemirror
CodeMirror.defineInitHook((editor)->
    if editor.options.fill
        $(window).resize(()->
            height = $(window).height() - $('#header').height()
            $.each($('#content>div:not(#editordiv)'),(i,ele)->height-=$(ele).height())
            editor.setSize("100%","#{height-10}px")
        )
        $(window).trigger("resize")
)