// This is a manifest file that'll be compiled into base.js, which will include all the files
// listed below.
//
//= require bootstrap-sprockets   */

var $ = require('jquery');
window.jQuery = $;

require('jquery-ui');
require('jquery-ujs');

//require('jquery-ui/ui/widgets/tooltip');
require('jquery-ui/ui/widgets/spinner');
require('jquery-ui/ui/widgets/button');

require('bootstrap3');
require('bootstrap-modal');
require('../../../vendor/assets/javascripts/tag-it.js');
require('../../../vendor/assets/javascripts/breakpoints.js');
require('../base/cocoon.js');
require('../styles/base/_base.scss');
require('../base/alerts.js');
require('../base/collapse_indicators.js');
require('../base/display_first_nested_field.js');
require('../base/layout.js');
require('jquery-ui/ui/widgets/autocomplete');
require('../base/ldap_lookup.js');
require('../base/tagit.js');
require('../base/toggle_caret.js');
require('../images/PS_HOR_REV_RGB_2C.png');



