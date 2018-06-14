var $ = require('jquery');
window.jQuery = $;


setup_delete_file_link = () =>
    $('a#file_delete_link').on('keypress, click', function(e){
        fname = jQuery.trim($(this).next('a.file-link').html()).split('\n')[0];
        put_msg_here = $(this).closest('div.links.cocoon-links');
        put_msg_here.prepend("<p class='alert-danger'>The file, " + fname + ", will be deleted when the form is submitted.  Click 'Cancel' if you do not want to delete the file.</p>")
    });

$(document).ready(setup_delete_file_link);

