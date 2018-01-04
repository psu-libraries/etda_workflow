/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;

display_etd_values = () =>
    $('body').on('change', '.program-information-admin #submission_lion_path_degree_code', function(e) {
        const selected_lp_degree_code = $('.program-information-admin #submission_lion_path_degree_code option:selected').val();
        let i=0;
        while (i < plan.length) {
            const this_plan = plan[i];
            if (this_plan['lp_degree_code'] === selected_lp_degree_code) {
                $('li span.degree').text(this_plan['etd_degree_name']);
                $('li span.program').text(this_plan['etd_program_name']);
                $('li span.semester').text(this_plan['etd_semester']);
                $('li span.year').text(this_plan['etd_year']);
                $('li span.defended').text(this_plan['etd_defense_date']);
                $('#submission_degree_id').attr('value', this_plan['etd_degree']);
                $('#submission_program_id').attr('value', this_plan['etd_program']);
                $('#submission_defended_at').attr('value', this_plan['etd_defense_date']);
                $('#submission_semester').attr('value', this_plan['etd_semester']);
                $('#submission_year').attr('value', this_plan['etd_year']);
                break;
            } else {
                i++;
            }
        }
        return e.preventDefault();
    })
;

$(document).ready(display_etd_values);