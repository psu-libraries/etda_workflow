/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;

const initialize_tagit = function() {

    $('input.tagit').tagit({allowSpaces: true});
    $('span.tagit-label').each(function(i,k) {
        const delete_msg=`Delete keyword ${k.textContent}`;
        const close_link=k.nextSibling;
        close_link.setAttribute('role', 'button');
        close_link.setAttribute('aria-label', delete_msg);
        close_link.setAttribute('data-taglabel', k.textContent);
        close_link.firstChild.setAttribute('alt', delete_msg);
        $('.tagit-new input').attr({role: 'textbox'});
    });


    $('input.tagit').tagit({beforeTagRemoved(event, ui) {
            if ($(document.activeElement).hasClass('modal') || $(document.activeElement).hasClass('btn-primary delete')) {
                $('#ConfirmModal').modal('hide');
                return event.preventDefault();
            } else {
                $('#ConfirmModal').find('div.modal-body p').text(`Are you sure you want to delete keyword \"${ui.tagLabel}\"?`);
                $('#ConfirmModal').data('taglabel', ui.tagLabel);
                $('#ConfirmModal').modal('show');
                return false;
            }
        }
    });

    $('input.tagit').tagit({afterTagAdded(event, ui) {
            const newlabel=`Delete keyword ${ui.tagLabel}`;
            const k = $('a.tagit-close').last();
            k.attr('data-taglabel', ui.tagLabel);
            k.attr({ role: 'button', 'aria-label': newlabel});
            $('.tagit-new input').attr({role: 'textbox'});
        }
    });

    $('button#delete').on('keypress, click', function(e) {
        const tag_label = $('#ConfirmModal').data('taglabel');
        return $('input.tagit').tagit('removeTagByLabel',tag_label);
    });

    return $('#ConfirmModal').on('hidden.bs.modal', e => $('input.ui-widget-content').focus());
};


$(document).on('page:load ready', initialize_tagit);

$('.tagit-new input').on('keydown', function(e) {
//looking for tab key; when found, move focus to next form element
    if (e.which === 9) {
        const next_item = $(this).closest('form').find(':input');
        next_item.eq( next_item.index(this)+ 1 ).focus();
        return e.preventDefault();
    }
});