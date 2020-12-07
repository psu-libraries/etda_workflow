var $ = require('jquery');
window.jQuery = $;

const initialize_fees_dialog = function() {
    $('#submit-final-submission').on('click', function() {
        $('#dialog-confirm').modal('show');
    });

    $('#final-submit-cancel').on('click', function() {
        $('#dialog-confirm').modal('hide');
    });

    $('#final-submit').on('click', function() {
        $('.simple_form.edit_submission').submit();
    });
};

$(document).ready(initialize_fees_dialog);
