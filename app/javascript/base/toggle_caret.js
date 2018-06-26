/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

initialize_toggle_caret =  () =>

    $('a.caret-link').on('keypress, click', function(e) {
        var pointer = $(this).find('span.caret');

        if (pointer.hasClass('caret-right'))
        {
            pointer.removeClass('caret-right');
        }else
        {
            pointer.addClass('caret-right');
        }
    });
$(document).ready(initialize_toggle_caret);
