var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    toggles_and_hidden_areas = { 
        "#submission_training_support_funding_true" : "#fed_funding_confirmation_author_1",
        "#submission_other_funding_true" : "#fed_funding_confirmation_author_2",
        "#funding_confirmation_training_funding_confirmation_false" : "#fed_funding_error_message_author_1",
        "#funding_confirmation_other_funding_confirmation_false" : "#fed_funding_error_message_author_2"
    };
    $.each( toggles_and_hidden_areas, function(toggle, field){
        if ($(toggle).is(":checked")) {
            $(field).collapse('show')
        };
    })



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

    $("input[name='funding_confirmation[training_funding_confirmation]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_1")
            if ($("#funding_confirmation_training_funding_confirmation_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#funding_confirmation_training_funding_confirmation_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )

    $("input[name='funding_confirmation[other_funding_confirmation]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_2")
            if ($("#funding_confirmation_other_funding_confirmation_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#funding_confirmation_other_funding_confirmation_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )
    
};

$(document).ready(initialize_federal_funding_radios);