// This is a manifest file that'll be compiled into base.js, which will include all the files
// listed below.
//
/*
/= require jquery-ui/widgets/autocomplete
//= require cocoon
//= require bootstrap-sprockets   */

var $ = require('jquery');
window.jQuery = $;

require('jquery-ujs');
require('bootstrap-modal');
require('bootstrap3');
require('../styles/base/_base.scss');
require('../base/ldap_lookup.js');
require('../base/alerts.js');
require('../base/collapse_indicators.js');
require('../base/display_first_nested_field.js');
require('../base/layout.js');
require('../base/tagit.js');
require('../base/toggle_caret.js');

require('../images/PS_HOR_REV_RGB_2C.png');





