/*/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;

const setup_tooltips = function()
{ $('[data-toggle="tooltip"]').tooltip(); };

$(document).on('page load:ready', setup_tooltips);
