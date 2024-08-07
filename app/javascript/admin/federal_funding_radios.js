var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    var i = $('#fed_funding_confirmation_admin')
    var j = $('#fed_funding_error_admin')

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

    if ($("#federal_funding_admin_admin_funding_confirmation_false").is(":checked")) {
        j.collapse('show')
    };

    $("input[name='federal_funding_admin[admin_funding_confirmation]']").on("change",
        function() {
            if ($("#federal_funding_admin_admin_funding_confirmation_true").is(":checked")) {
                j.collapse('hide')
           }
            if ($("#federal_funding_admin_admin_funding_confirmation_false").is(":checked")) {
                j.collapse('show')
            }
        }
    )

};

$(document).ready(initialize_federal_funding_radios);