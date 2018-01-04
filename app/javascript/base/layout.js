/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// This allows the footer to stick to the bottom of viewport
// if the page content is shorter then the viewport

var $ = require('jquery');
window.jQuery = $;

//= require breakpoints.js

const initialize_layout = function() {

    // Set breakpoints for responsive function calls
    const $window = $(window);
    $window.setBreakpoints({
        distinct: true,
        breakpoints: [ 768, 992, 1200 ]});

    const body_container = $('#body-container');
    const $footer = body_container.find('footer');

    const set_footer_margin = function() {
        const footer_height = $footer.outerHeight(true);
        return body_container.css({'margin-bottom': footer_height});
    };

    $window.bind('enterBreakpoint768 exitBreakpoint768', set_footer_margin);
    return set_footer_margin();
};

$(document).on('page:load ready', initialize_layout);

