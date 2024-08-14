var $ = require('jquery');
window.jQuery = $;

initialize_federal_funding_radios = function() {
    toggles_and_hidden_areas = { 
        "#federal_funding_details_training_support_funding_true" : "#fed_funding_confirmation_author_1",
        "#federal_funding_details_other_funding_true" : "#fed_funding_confirmation_author_2",
        "#federal_funding_details_training_support_acknowledged_false" : "#fed_funding_error_message_author_1",
        "#federal_funding_details_other_funding_acknowledged_false" : "#fed_funding_error_message_author_2",
        "#committee_member_federal_funding_used_true" : "#fed_funding_confirmation_approver",
        "#committee_member_federal_funding_confirmation_false": "#fed_funding_error_approver"
    };
    // Start the page with the hidden fields shown if the relevant radio button is checked
    $.each( toggles_and_hidden_areas, function(toggle, field){
        if ($(toggle).is(":checked")) {
            $(field).collapse('show')
        };
    })


    // Author/Admin - Training Support Funding, Acknowledgment
    $("input[name='federal_funding_details[training_support_funding]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_1")
            if ($("#federal_funding_details_training_support_funding_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#federal_funding_details_training_support_funding_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    // Author/Admin - Other Funding, Acknowledgment
    $("input[name='federal_funding_details[other_funding]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_author_2")
            if ($("#federal_funding_details_other_funding_true").is(":checked")) {
                conf.collapse('show')
           }
            if ($("#federal_funding_details_other_funding_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    // Author/Admin - Training Support Error Message
    $("input[name='federal_funding_details[training_support_acknowledged]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_1")
            if ($("#federal_funding_details_training_support_acknowledged_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#federal_funding_details_training_support_acknowledged_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )

    // Author/Admin - Other Funding Error Message
    $("input[name='federal_funding_details[other_funding_acknowledged]']").on("change",
        function() {
            var error = $("#fed_funding_error_message_author_2")
            if ($("#federal_funding_details_other_funding_acknowledged_true").is(":checked")) {
                error.collapse('hide')
           }
            if ($("#federal_funding_details_other_funding_acknowledged_false").is(":checked")) {
                error.collapse('show')
            }
        }
    )

    // Approver – Federal Funding Used Acknowledgment
    $("input[name='committee_member[federal_funding_used]']").on("change",
        function() {
            var conf = $("#fed_funding_confirmation_approver")
            if ($("#committee_member_federal_funding_used_true").is(":checked")) {
                conf.collapse('show')
            }
            if ($("#committee_member_federal_funding_used_false").is(":checked")) {
                conf.collapse('hide')
            }
        }
    )

    // Approver – Federal Funding Error message
    $("input[name='committee_member[federal_funding_confirmation]']").on("change",
        function() {
            var conf = $("#fed_funding_error_approver")
            if ($("#committee_member_federal_funding_confirmation_true").is(":checked")) {
                conf.collapse('hide')
            }
            if ($("#committee_member_federal_funding_confirmation_false").is(":checked")) {
                conf.collapse('show')
            }
        }
    )
};

$(document).ready(initialize_federal_funding_radios);