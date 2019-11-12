var $ = require('jquery');
window.jQuery = $;

$(document).ready(function() {
    $(window).keydown(function(event){
        if((event.keyCode === 13) && $(".ldap-lookup").is(':focus')) {
            event.preventDefault();
            return false;
        }
    });
});
