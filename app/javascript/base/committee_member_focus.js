var $ = require('jquery');
window.jQuery = $;
//For accessibility, position cursor on Committee Member name drop-down
$(document).on('click', 'a.add_fields', function(e) {
    e.preventDefault();
    $('.form-control.select').focus();
});