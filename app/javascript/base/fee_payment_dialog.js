var $ = require('jquery');
window.jQuery = $;

const initialize_fee_payment_dialog = function() {
    if ($('#fee-dialog').length) {
        $('#dialog-confirm').modal('show');
    }

    $('#final-submit').on('click', function() {
        $('#dialog-confirm').modal('hide');
    });
};

document.addEventListener("DOMContentLoaded", function(){
    initialize_fee_payment_dialog();
});
