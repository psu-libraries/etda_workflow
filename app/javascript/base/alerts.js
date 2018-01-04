/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

var $ = require('jquery');
window.jQuery = $;

initialize_alerts = function() {

  if (!$('.alert-dismissable').length)
      { return; }

  $('.alert-dismissable').on('click', '.close', () => $('.alert').alert('close'));
};

$(document).ready(initialize_alerts);