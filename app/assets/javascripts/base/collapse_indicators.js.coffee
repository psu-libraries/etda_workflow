 initialize_collapse_indicators = () ->

   collapsible_content = $('.collapse')

   return unless collapsible_content.length

   collapsible_content.on('show.bs.collapse', ->
     content_id = '#' + $(this).attr('id')
     indicator = $('[data-toggle="collapse"][data-target="' + content_id + '"] .hide-show-indicator')
     indicator.addClass 'fa-rotate-90').on('hide.bs.collapse', ->
     content_id = '#' + $(this).attr('id')
     indicator = $('[data-toggle="collapse"][data-target="' + content_id + '"] .hide-show-indicator')
     indicator.removeClass 'fa-rotate-90'
   )

 $(document).on('page:load ready', initialize_collapse_indicators)