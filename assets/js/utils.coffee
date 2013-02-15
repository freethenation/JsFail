if not window.jstools? then window.jstools = {}
jstools = window.jstools
isArray=(o) -> o? && Array.isArray o
jstools.isArray=isArray
debounce=(func, wait, immediate)->
    timeout = null
    result = null
    return ()->
      context = this
      args = arguments
      later = ()->
        timeout = null
        if !immediate then result = func.apply(context, args)
      callNow = immediate && !timeout
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
      if callNow then result = func.apply(context, args)
      return result
jstools.debounce = debounce