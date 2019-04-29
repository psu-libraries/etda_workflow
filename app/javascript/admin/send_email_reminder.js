/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

$(function(){
    $("#email_reminder_button").submit(function(){
        var dataSet = $(this).serialize();
        $.ajax({
            type: "POST",
            url: $(this).attr("send_email_reminder"),
            data: { committee_member_id: id },
            complete: function(){
                alert("Sent!");
            },
            error: function(){
                alert("Something went wrong!");
            }
        });
        return false;
    });
})