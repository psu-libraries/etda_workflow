/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

initialize_toggle_caret = function() {
    const pointer = $('#reports_menu').find('span');
    $('#reports_list').on('shown.bs.collapse', () => pointer.removeClass('caret-right')).on('hidden.bs.collapse', () => pointer.addClass('caret-right'));
};

$(document).ready(initialize_toggle_caret);