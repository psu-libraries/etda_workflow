var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    $("input[name='federal_funding_author[training_support_used]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_1")
            if ($("#federal_funding_author_training_support_used_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#federal_funding_author_training_support_used_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    $("input[name='federal_funding_author[other_funds_used]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_2")
            if ($("#federal_funding_author_other_funds_used_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#federal_funding_author_other_funds_used_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    $("input[name='federal_funding_author[training_confirmation]']").on("change",
        function() {
            var conf = $("#fed_funding_error_message_author_1")
            if ($("#federal_funding_author_training_confirmation_true").is(":checked")) {
                conf.collapse('hide')
           }
            if ($("#federal_funding_author_training_confirmation_false").is(":checked")) {
                conf.collapse('show')
            }
        }
    )

    $("input[name='federal_funding_author[other_funds_confirmation]']").on("change",
        function() {
            var conf = $("#fed_funding_error_message_author_2")
            if ($("#federal_funding_author_other_funds_confirmation_true").is(":checked")) {
                conf.collapse('hide')
           }
            if ($("#federal_funding_author_other_funds_confirmation_false").is(":checked")) {
                conf.collapse('show')
            }
        }
    )
    
};

$(document).ready(initialize_federal_funding_radios);