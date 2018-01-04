/* Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const select_degree = () =>
    $( "form.plan-information" ).submit(function( event ) {
        const selected_lp_degree_code = $('#submission_lion_path_degree_code option:selected').val();
        let i=0;
        while (i < plan.length) {
            const this_plan = plan[i];
            if (this_plan['lp_degree_code'] === selected_lp_degree_code) {
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


$(document).ready(select_degree);