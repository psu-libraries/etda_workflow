var $ = require('jquery');
window.jQuery = $;

$('#committee-form-div').on('keypress', e => {
    if (e.keyCode == 13) {
        return false;
    }
});
