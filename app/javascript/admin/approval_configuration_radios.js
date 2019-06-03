/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

approval_configuration_radios = function () {
    if ($("#approval_configuration_use_percentage_true").is(":checked")) {
        $("label[for='approval_configuration_configuration_threshold']").text("Percentage for approval*");
    }

    if ($("#approval_configuration_use_percentage_false").is(":checked")) {
        $("label[for='approval_configuration_configuration_threshold']").text("Rejections permitted*");
    }

    $("input:radio[name='approval_configuration[use_percentage]']").change(
        function() {
            if ($("#approval_configuration_use_percentage_true").is(":checked")) {
                $("label[for='approval_configuration_configuration_threshold']").text("Percentage for approval*");
            }

            if ($("#approval_configuration_use_percentage_false").is(":checked")) {
                $("label[for='approval_configuration_configuration_threshold']").text("Rejections permitted*");
            }
        }
    )
};

$(document).ready(approval_configuration_radios);
