/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

var autocomplete_it, complete_email, initialize_addon_autocomplete, initialize_ldap_autocomplete;

initialize_ldap_autocomplete = function() {
    var input_fields;
    input_fields = $('input.ldap-lookup');
    if (!input_fields.length) {
        return;
    }
    return autocomplete_it(input_fields);
};

initialize_addon_autocomplete = function() {
    $('#add_member').on('cocoon:after-insert', function(e, committee_members) {
        var input_fields;
        input_fields = committee_members.find('input.ldap-lookup');
        if (!input_fields.length) {
            return;
        }
        return autocomplete_it(input_fields);
    });
};

autocomplete_it = function(input_fields) {
    var last_selected_ui;
    last_selected_ui = null;
    input_fields.autocomplete({
        source: '/committee_members/autocomplete',
        minLength: 2,
        select: function(event, ui) {
            return last_selected_ui = ui;
        },
        change: function(event, ui) {
            return complete_email(ui, last_selected_ui, this);
        },
        create: function() {
            $(this).data('ui-autocomplete')._renderItem = function(ul, item) {
                return $('<li>').append("<span>" + item.label + "<br>-- " + item.dept + "</span>").appendTo(ul);
            };
        }
    });
};

complete_email = function(ui, last_selected_ui, field_ref) {
    var email_address;
    var email_field;

    if ((ui.item === null) && (last_selected_ui !== null) && (field_ref.value === last_selected_ui.item.label)) {
        ui = last_selected_ui;
    }
    if (ui.item) {
        email_address = ui.item.id;
        email_field = $(':input')[$(field_ref).index(':input') + 1];
        return email_field.value = email_address;
    }
};

$(document).ready(initialize_ldap_autocomplete);
$(document).ready(initialize_addon_autocomplete);
