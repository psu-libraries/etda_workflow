/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

send_email_reminder = function() {
    $('#committee').on("click", "button", function (e) {
        e.preventDefault();
        $.ajax({
            type: "POST",
            url: `send_email_reminder`,
            data: {
                committee_member_id: $(this).val()
            },
            success: function(data) {
                alert(data);
            }
        });
    });
};

$(document).ready(send_email_reminder);