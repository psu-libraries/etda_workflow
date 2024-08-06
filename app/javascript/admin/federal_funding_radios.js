var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    var i = $('#fed_funding_confirmation_admin')

    if ($("#federal_funding_admin_funds_used_true").is(":checked")) {
        i.collapse('show')
    };

    $("input[name='federal_funding_admin[funds_used]']").on("change",
        function() {
            if ($("#federal_funding_admin_funds_used_true").is(":checked")) {
                i.collapse('show')
           }
            if ($("#federal_funding_admin_funds_used_false").is(":checked")) {
                i.collapse('hide')
            }
        }
    )

};

$(document).ready(initialize_federal_funding_radios);