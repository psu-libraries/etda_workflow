// This is a manifest file that'll be compiled into author.js, which will include all the files
// listed below.
//

var $ = require('jquery');
window.jQuery = $;

require('bootstrap3/dist/css/bootstrap.css');
require('../author/invention_disclosure.js');
require('../author/lionpath_degree.js');
require('../styles/author/committee.scss');
require('../styles/author/screen.scss');
// Must be included last in order for close icon to appear on keyword tag
require('../styles/author/tag-it.scss');
