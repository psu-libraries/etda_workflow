/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

approval_configuration_radios = function () {
    if ($("#approval_configuration_use_percentage_true").is(":checked")) {
        $("#approval_configuration_rejections_permitted").attr("type", "hidden");
        $("label[for='approval_configuration_rejections_permitted']").attr("style", "display: none;");

        $("#approval_configuration_percentage_for_approval").attr("type", "");
        $("label[for='approval_configuration_percentage_for_approval']").attr("style", "");
    }

    if ($("#approval_configuration_use_percentage_false").is(":checked")) {
        $("#approval_configuration_percentage_for_approval").attr("type", "hidden");
        $("label[for='approval_configuration_percentage_for_approval']").attr("style", "display: none;");

        $("#approval_configuration_rejections_permitted").attr("type", "");
        $("label[for='approval_configuration_rejections_permitted']").attr("style", "");
    }

    $("input:radio[name='approval_configuration[use_percentage]']").change(
        function() {
            if ($("#approval_configuration_use_percentage_true").is(":checked")) {
                $("#approval_configuration_rejections_permitted").attr("type", "hidden");
                $("label[for='approval_configuration_rejections_permitted']").attr("style", "display: none;");

                $("#approval_configuration_percentage_for_approval").attr("type", "");
                $("label[for='approval_configuration_percentage_for_approval']").attr("style", "");
            }

            if ($("#approval_configuration_use_percentage_false").is(":checked")) {
                $("#approval_configuration_percentage_for_approval").attr("type", "hidden");
                $("label[for='approval_configuration_percentage_for_approval']").attr("style", "display: none;");

                $("#approval_configuration_rejections_permitted").attr("type", "");
                $("label[for='approval_configuration_rejections_permitted']").attr("style", "");
            }
        }
    )
};

$(document).ready(approval_configuration_radios);
