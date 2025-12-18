var $ = require('jquery');
window.jQuery = $;

var toggles_and_hidden_areas = { 
      "#submission_federal_funding_details_attributes_training_support_funding_true" : "#fed_funding_confirmation_author_1",
      "#submission_federal_funding_details_attributes_other_funding_true" : "#fed_funding_confirmation_author_2",
      "#submission_federal_funding_details_attributes_training_support_acknowledged_false" : "#fed_funding_error_message_author_1",
      "#submission_federal_funding_details_attributes_other_funding_acknowledged_false" : "#fed_funding_error_message_author_2",
      "#committee_member_federal_funding_used_true" : "#fed_funding_confirmation_approver",
      "#committee_member_federal_funding_confirmation_false": "#fed_funding_error_approver"
  };

// Start the page with the hidden fields shown if the relevant radio button is checked
  $.each( toggles_and_hidden_areas, function(toggle, field){
      if ($(toggle).is(":checked")) {
          $(field).collapse('show')
      };
  })

var errorMessage = "It is a federal requirement that all funding used to support research be acknowledged. Your thesis/dissertation cannot be submitted without this acknowledgment. Please upload a revised document. If you have any questions, please contact your advisor or the head of your graduate program."  

// For screen readers...lets the user know something new has appeared 
function announce(message) {
  var $announcer = $('#federal-funding-announcer');
  $announcer.text('');
  setTimeout(function () { $announcer.text(message); }, 100);
}

function togglePanel($radio, $panel, show, message) {
  if (show) {
    $panel.collapse('show');
    $radio.attr('aria-expanded', 'true');
    announce(message);
  } else {
    $panel.collapse('hide');
    $radio.attr('aria-expanded', 'false');
    // No announcement needed for hide – screen reader already says “collapsed”
  }
}

$.each(toggles_and_hidden_areas, function (radioSelector, panelSelector){
  var $radio = $(radioSelector)
  var $panel = $(panelSelector)

  $radio.attr('aria-controls', $panel.attr('id'));

  // Set initial expanded state based on whether the radio is checked
  $radio.attr('aria-expanded', $radio.is(':checked') ? 'true' : 'false');

  // If the radio starts checked, make sure the panel is visible
  if ($radio.is(':checked')) {
    $panel.collapse('show');
  }
});

  // Author/Admin - Training Support Funding, Acknowledgment
  $("input[name='submission[federal_funding_details_attributes][training_support_funding]']").on("change",
    function() {
      var $yesButton = $("#submission_federal_funding_details_attributes_training_support_funding_true");
      var $panelId = $yesButton.attr('aria-controls');
      var $panel = $("#" + $panelId);
      togglePanel($yesButton, $panel, $yesButton.is(':checked'), 'Please confirm below that your federal funding has been acknowledged');
    }
  )

  // Author/Admin - Other Funding, Acknowledgment
  $("input[name='submission[federal_funding_details_attributes][other_funding]']").on("change",
      function() {
        var $yesButton = $("#submission_federal_funding_details_attributes_other_funding_true");
      var $panelId = $yesButton.attr('aria-controls');
      var $panel = $("#" + $panelId);
      togglePanel($yesButton, $panel, $yesButton.is(':checked'), 'Please confirm below that your federal funding has been acknowledged');
      }
  )

  // Author/Admin - Training Support Error Message
  $("input[name='submission[federal_funding_details_attributes][training_support_acknowledged]']").on("change",
      function() {
      var $noButton = $("#submission_federal_funding_details_attributes_training_support_acknowledged_false");
      var $panelId = $noButton.attr('aria-controls');
      var $panel = $("#" + $panelId);
      togglePanel($noButton, $panel, $noButton.is(':checked'), errorMessage);
      }
  )

  // Author/Admin - Other Funding Error Message
  $("input[name='submission[federal_funding_details_attributes][other_funding_acknowledged]']").on("change",
      function() {
        var $noButton = $("#submission_federal_funding_details_attributes_other_funding_acknowledged_false");
        var $panelId = $noButton.attr('aria-controls');
        var $panel = $("#" + $panelId);
        togglePanel($noButton, $panel, $noButton.is(':checked'), errorMessage);
      }
  )

  // Approver – Federal Funding Used Acknowledgment
  $("input[name='committee_member[federal_funding_used]']").on("change",
      function() {
          var conf = $("#fed_funding_confirmation_approver")
          if ($("#committee_member_federal_funding_used_true").is(":checked")) {
              conf.collapse('show')
          }
          if ($("#committee_member_federal_funding_used_false").is(":checked")) {
              conf.collapse('hide')
          }
      }
  )

  // Approver – Federal Funding Error message
  $("input[name='committee_member[federal_funding_confirmation]']").on("change",
      function() {
          var conf = $("#fed_funding_error_approver")
          if ($("#committee_member_federal_funding_confirmation_true").is(":checked")) {
              conf.collapse('hide')
          }
          if ($("#committee_member_federal_funding_confirmation_false").is(":checked")) {
              conf.collapse('show')
          }
      }
  )

$(document).ready(function () {
  // Ensure the live‑region exists (in case the HTML snippet was omitted)
  if (!$('#federal-funding-announcer').length) {
    $('body').prepend(
      '<div id="federal-funding-announcer" class="sr-only" aria-live="polite" aria-atomic="true"></div>'
    );
  }
});