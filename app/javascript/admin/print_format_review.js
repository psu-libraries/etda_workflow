/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var $ = require('jquery');
window.jQuery = $;

initialize_print_page = function() {
    $('#print-button a').click(() => window.print());

    if (window.matchMedia) {
        const mediaQueryList = window.matchMedia('print');
        mediaQueryList.addListener(function(mql) {
            if (mql.matches) {
                beforePrint();
            } else {
                afterPrint();
            }
        });
    }

    var afterPrint = function() {
        window.opener.location.focus();
        return window.close();
    };


    var beforePrint = () => $('#print-form-page').submit();


    window.onbeforeprint = beforePrint;
    return window.onafterprint = afterPrint;
};

click_it = function() {
    $('#print-button a').trigger('click');
    //window.close()
    return false;
};

$(document).ready(initialize_print_page);
$(document).ready(click_it);