/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;
var DataTable = require('datatables.net-bs4');

setup_report_tables = function () {

    let custom_report_options

    table = $('.datatable');

    if (table === null) { return; }

    const report_common_options = {
        deferRender: true,
        processing: true,
        stateDuration: 60 * 60 * 24,
        paginate: false,
        language: {
            sSearch: "<div class='form-inline'><strong>Search:</strong> _INPUT_</div>",
            loadingRecords: '&nbsp;',
            processing: "<div class='spinner'><div class='spinner-info'>Loading Data...</div></div>",
        }
    };

    const column_options = () =>
        table.find('th').map(function () {
            const column = $(this);
            return { "name": column.data('name'), "orderable": column.data('orderable'), "visible": column.data('visible') };
        })
        ;

    const default_semester = $('table').attr('data-default-semester');
    const select = $('.semester');
    select.val(default_semester);
    const degree_type = $('.degree_type');

    $('.custom-report-index.datatable').dataTable(
        (custom_report_options = {
            ajax: {
                url: (table.attr('data-ajax-url') + '.json'),
                data: {
                    semester: function selected_semester() {
                        return select.val();
                    },
                    degree_type: function selected_degree_type() {
                        return degree_type.val();
                    }
                }
            },
            columns: column_options(),
            rowCallback(row, custom_report_data) {
                const id = custom_report_data[0];
                return $(row).attr('data-submission-id', id);
            },
            initComplete() {
                this.api().column(0).visible(false);
                select.change(function () {
                    const table = $('.custom-report-index.datatable').DataTable()
                    table.clear().draw();
                    table.ajax.reload();
                });
                degree_type.change(function () {
                    const table = $('.custom-report-index.datatable').DataTable()
                    table.clear().draw();
                    table.ajax.reload();
                });
            }
        }),
        $.extend(custom_report_options, report_common_options)
    );
};

$(document).ready(setup_report_tables);