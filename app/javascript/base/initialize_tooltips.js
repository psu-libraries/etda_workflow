/*/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;

const initialize_tooltips = function () {
    $('[data-toggle="tooltip"]').tooltip();
};

const reinitialize_tooltips = function () {
    $('.add_field').click(setTimeout(initialize_tooltips, 500));
    $('.add_field').click(setTimeout(reinitialize_tooltips, 500));
};

$(document).ready(initialize_tooltips);
$(document).ready(reinitialize_tooltips);