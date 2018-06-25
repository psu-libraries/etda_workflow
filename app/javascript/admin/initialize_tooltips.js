/*/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;
require('bootstrap3/js/tooltip.js');

$(function () {
    $('[data-toggle="tooltip"]').tooltip()
})