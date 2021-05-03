var $ = require('jquery');
window.jQuery = $;

autofill_program_head = function () {
    $('#program-head-name').on('change', function(e){
        email = $('#program-head-name option:selected').attr("member_email");
        document.getElementById('member-email').value = '';
        if(typeof(email) != "undefined"){
            document.getElementById('member-email').value = email
        }
    });
};

$(document).ready(autofill_program_head);