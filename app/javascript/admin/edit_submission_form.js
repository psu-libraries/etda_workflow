/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

setup_edit_submission_form = function() {

    const form = $('.admin-edit-submission');

    if (!form.length) { return; }

    const program_information = form.find('#program-information');
    const committee = form.find('#committee');
    const format_review_files = form.find('#format-review-files');

    if (form.hasClass('waiting-for-format-review-response')) {
        program_information.collapse();
        committee.collapse();
    }

    if (form.hasClass('waiting-for-final-submission-response')) {
        program_information.collapse();
        committee.collapse();
        format_review_files.collapse();
    }


    // Add snazzy "Marked as deleted" and undo capabilities to Cocoon, rather than
    // remove the element from the page (which makes it incorrectly appear that
    // files can be deleted without submitting the form)
    return $('#format-review-file-fields, #final-submission-file-fields')
        .on('cocoon:after-remove', function(e,file){
            const $marked_for_deletion = $('<span class="marked-for-deletion text-danger"><i class="fa fa-exclamation-circle"></i> Marked for deletion </span>');
            const $undo_delete = $('<a href="#">[undo]</a>')
                .appendTo($marked_for_deletion)
                .click( function() {
                    file.parent().trigger('cocoon:undo-remove', [file]);
                    return false;
                });
            file.show();
            file.find('.remove_fields').hide().after($marked_for_deletion);
            return file.find('.file-link').addClass('danger');
        })
        .on('cocoon:undo-remove', function(e,file){
            file.find('.remove_fields').prev("input[type=hidden]").val("false");

            file.find('.remove_fields').show();
            file.find('.marked-for-deletion').remove();
            return file.find('.file-link').removeClass('danger');
        });
};



$(document).ready(setup_edit_submission_form);


