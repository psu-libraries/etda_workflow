var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    $("input[name='submission[training_support_funding]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_1")
            if ($("#submission_training_support_funding_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#submission_training_support_funding_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    $("input[name='submission[other_funding]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_2")
            if ($("#submission_other_funding_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#submission_other_funding_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    $("input[name='federal_funding_author[training_funding_confirmation]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_1")
            if ($("#federal_funding_author_training_funding_confirmation_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#federal_funding_author_training_funding_confirmation_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )

    $("input[name='federal_funding_author[other_funding_confirmation]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_2")
            if ($("#federal_funding_author_other_funding_confirmation_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#federal_funding_author_other_funding_confirmation_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )
    
};

$(document).ready(initialize_federal_funding_radios);