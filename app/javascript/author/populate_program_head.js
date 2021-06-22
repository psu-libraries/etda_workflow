var $ = require('jquery');
window.jQuery = $;

autofill_program_head = function () {
    $('#program-head-name').on('change', function(e){
        let email = $('#program-head-name option:selected').attr("member_email");
        let committee_role_id = $('#program-head-name option:selected').attr("committee_role_id");
        let committee_role_id_form = $(this).closest('div.row').prev().prev().find('input');
        document.getElementById('member-email').value = '';
        if(typeof(email) != "undefined"){
            document.getElementById('member-email').value = email;
        }
        if(typeof(committee_role_id) != "undefined"){
            committee_role_id_form.val(committee_role_id);
        }
    });
};

$(document).ready(autofill_program_head);