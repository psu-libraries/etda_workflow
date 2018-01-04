 /*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

 var $ = require('jquery');
 window.jQuery = $;
 
initialize_collapse_indicators = function() {

   const collapsible_content = $('.collapse');

   if (!collapsible_content.length) { return; }

   return collapsible_content.on('show.bs.collapse', function() {
     const content_id = `#${$(this).attr('id')}`;
     const indicator = $(`[data-toggle="collapse"][data-target="${content_id}"] .hide-show-indicator`);
     return indicator.addClass('fa-rotate-90');
 }).on('hide.bs.collapse', function() {
     const content_id = `#${$(this).attr('id')}`;
     const indicator = $(`[data-toggle="collapse"][data-target="${content_id}"] .hide-show-indicator`);
     return indicator.removeClass('fa-rotate-90');
   });
 };

 $(document).ready(initialize_collapse_indicators);