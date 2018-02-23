/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

initialize_nested_fields = function() {

    const cocoon_link = $('.cocoon-links .add_fields');

    if (!cocoon_link.length) { return; }

    const fields = $('.nested-fields');

    if (!fields.length) {
        return cocoon_link.click();
    }
};
$(document).ready(initialize_nested_fields);

