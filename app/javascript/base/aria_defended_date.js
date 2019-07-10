/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

aria_defended_date = function() {

    $('select[id="submission_defended_at_1i"]').attr("aria-label", "Date to be defended* Year");
    $('select[id="submission_defended_at_2i"]').attr("aria-label", "Date to be defended* Month");
    $('select[id="submission_defended_at_3i"]').attr("aria-label", "Date to be defended* Day");
};

$(document).ready(aria_defended_date);