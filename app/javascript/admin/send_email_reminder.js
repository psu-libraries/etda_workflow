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
            success: function (result) {
                alert('Email successfully sent.');
            },
            error: function (xhr) {
                if (xhr.status == '500') {
                    alert('Email was not sent.  Email reminders may only be sent once a day; a reminder was recently sent to this committee member.');
                } else {
                    alert("An error occured: " + xhr.status + " " + xhr.statusText);
                }
            }
        });
    });
};

$(document).ready(send_email_reminder);