var $ = require('jquery');
window.jQuery = $;

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

//require('../base/cocoon.js');
const setup_edit_submission_form = function() {

    const form = $('.admin-edit-submission');

    if (!form.length) { return; }

    // Add snazzy "Marked as deleted" and undo capabilities to Cocoon, rather than
    // remove the element from the page (which makes it incorrectly appear that
    // files can be deleted without submitting the form)
    $('#format-review-file-fields, #final-submission-file-fields').on('cocoon:after-remove', function(e,file){
            const $marked_for_deletion = $('<span class="marked-for-deletion text-danger"><i class="fa fa-exclamation-circle"></i> Marked for deletion </span>');
            const $undo_delete = $('<a href="#">[undo]</a>').appendTo($marked_for_deletion).click( function() {
                file.parent().trigger('cocoon:undo-remove', [file]);
                return false;
            });

            file.show();
            file.find('.remove_fields').hide().after($marked_for_deletion);

            file.find('.file-link').addClass('danger');}).on('cocoon:undo-remove', function(e,file){
                file.find('.remove_fields').prev("input[type=hidden]").val("false");
                file.find('.remove_fields').show();
                file.find('.marked-for-deletion').remove();
                file.find('.file-link').removeClass('danger');
            });
    };


$(document).ready(setup_edit_submission_form);
