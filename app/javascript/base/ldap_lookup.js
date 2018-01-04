/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

initialize_ldap_autocomplete = function() {
    const input_fields = $('input.ldap-lookup');
    if (!input_fields.length) { return; }
    return autocomplete_it(input_fields);
};

initialize_addon_autocomplete = () =>
$('#add_member').on('cocoon:after-insert', function(e, committee_members) {
    const input_fields=committee_members.find('input.ldap-lookup');
    if (!input_fields.length) { return; }
    autocomplete_it(input_fields);
} );

var autocomplete_it = function(input_fields) {
    let last_selected_ui = null;

    return input_fields.autocomplete({

        source: '<%= Rails.application.routes.url_helpers.committee_members_autocomplete_path %>',

        minLength: 2,

        // save off the last ui element selected incase the user moves around in the fields before leaving
        select(event, ui) {
            return last_selected_ui = ui;
        },
        change(event, ui) {
            return complete_email(ui, last_selected_ui,  this);
        },
        create() {
            return $(this).data('ui-autocomplete')._renderItem = (ul, item) => $('<li>').append( `<span>${item.label}<br>-- ${item.dept}</span>`  ).appendTo(ul);
        }

    });
};

var complete_email = function(ui, last_selected_ui, field_ref) {
    // the item could be nil if the user moves around in the field,
    // but if the value is the same as the last selected item do the email
    // with the last selected value
    if ((ui.item === null) && (last_selected_ui !== null) && (field_ref.value === last_selected_ui.item.label)) {
        ui = last_selected_ui;
    }

    if (ui.item) {
        const email_address = ui.item.id;
        // use index of current name field to find the next input field which is the email
        const email_field = $(':input')[$(field_ref).index(':input') + 1];
        return email_field.value = email_address;
    }
};

$(document).ready(initialize_addon_autocomplete);
$(document).ready(initialize_ldap_autocomplete);
