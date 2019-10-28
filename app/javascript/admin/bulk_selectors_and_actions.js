/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

setup_bulk_selectors_and_actions = function() {

    const bulk_actions = $('#bulk-actions');
    const table = $('.bulk-actions');

    const number_of_rows_selected = function() {
        let count = 0;
        const data_table = new $.fn.dataTable.Api(table);
        data_table.rows().nodes().to$().each( function() {
            if ($(this).find('.row-checkbox').prop('checked')) {
                return count++;
            }
        });
        return count;
    };

    const number_of_visible_rows_selected = function() {
        let count = 0;
        const data_table = new $.fn.dataTable.Api(table);
        data_table.$('tr', {
                order:  'current',
                search: 'applied',
                page:   'current'
            }
        ).each( function() {
            if ($(this).find('.row-checkbox').prop('checked')) {
                return count++;
            }
        });
        return count;
    };

    const selected_ids = function() {
        const array = [];
        const data_table = new $.fn.dataTable.Api(table);
        data_table.rows().nodes().to$().each( function() {
            const id = $(this).attr('data-submission-id');
            if ($(this).find('.row-checkbox').prop('checked')) {
                return array.push(id);
            }
        });
        return array;
    };

    const selected_names = function() {
        const array = [];
        const data_table = new $.fn.dataTable.Api(table);
        data_table.rows().nodes().to$().each( function() {
            const first_name = $(this).children()[4].firstChild.data;
            const last_name = $(this).children()[3].firstChild.data;
            if ($(this).find('.row-checkbox').prop('checked')) {
                return array.push(`- ${first_name} ${last_name}\n`);
            }
        });
        return array.join("");
    };

    const update_selected_submission_ids_field = function() {
        const fields = bulk_actions.find('input[name="submission_ids"]');
        const ids = selected_ids();
        return fields.val(ids);
    };

    const update_selected_release_date = function() {
        const parent_form = $(this).closest('form');
        const date_field = parent_form.find('input[name="date_to_release"]');
        const date_prefix = $(this).data('date-prefix');
        const month_select = $(`#${date_prefix}_month`);
        const day_select = $(`#${date_prefix}_day`);
        const year_select = $(`#${date_prefix}_year`);
        if (!date_field.length) { return; }
        const mo_da_yr = month_select.val()+'/'+day_select.val()+'/'+year_select.val();
        return date_field.val(mo_da_yr);
    };

    const update_confirm_delete_messages = function() {
        const confirm_message = `Are you sure you want to permanently delete the ${number_of_rows_selected()} selected submission(s)?`;
        const delete_submits = bulk_actions.find('input[type="submit"].btn-danger');
        return delete_submits.attr('data-confirm', confirm_message);
    };

    const update_confirm_release_messages = function() {
        const names = selected_names();
        const confirm_message = `Are you sure you want to release the submissions(s) for authors:\n\n${names}\n as Open Access?`;
        const release_as_open_access = bulk_actions.find('input[value="Release as Open Access"].release-btn');
        return release_as_open_access.attr('data-confirm', confirm_message);
    };

    const update_bulk_actions = function() {
        const selected = number_of_rows_selected();
        bulk_actions.find('h5 .number-of-selected-rows').html(selected);
        const visible = number_of_visible_rows_selected();
        bulk_actions.find('h5 .number-of-visible-selected-rows').html(visible);
        update_confirm_delete_messages();
        if (selected > 0) {
            return bulk_actions.slideDown();
        } else {
            return bulk_actions.slideUp();
        }
    };

    table.on( 'page.dt length.dt search.dt', () => update_bulk_actions());

    table.on('change', 'tr .row-checkbox', function() {
        update_selected_submission_ids_field();
        update_confirm_release_messages();
        return update_bulk_actions();
    });

    const selection_buttons = $('#row-selection-buttons');

    if (!selection_buttons.length) { return; }

    const select_visible_buttons = $('.select-visible-button');
    const deselect_visible_buttons = $('.deselect-visible-button');
    const select_releasable_buttons = $('.select-releasable-button');


    select_visible_buttons.on('click', function() {
        $('.row-checkbox').prop('checked', true);
        update_selected_submission_ids_field();
        return update_bulk_actions();
    });

    deselect_visible_buttons.on('click', function() {
        $('.row-checkbox').prop('checked', false);
        update_selected_submission_ids_field();
        return update_bulk_actions();
    });

    select_releasable_buttons.on('click', function() {
        const data_table = new $.fn.dataTable.Api(table);
        const column_index = data_table.column('ok_to_release:name').index();
        data_table.rows( function(i, data, node){
            const ok_to_release = data[column_index];
            return $(node).find('.row-checkbox').prop('checked', ok_to_release);
        });
        update_selected_submission_ids_field();
        update_bulk_actions();
        return $(this).blur();
    });
    $('.release-button').on('click', update_selected_release_date);
    $('.extend-button').on('click',  update_selected_release_date);
    return $('.csv').on('click',  function() {
        const fields = $('#row-selection-buttons').find('input[name="submission_ids"]');
        const ids = selected_ids();
        return fields.val(ids);
    });
};

$(document).ready(setup_bulk_selectors_and_actions);