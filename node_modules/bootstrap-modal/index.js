/* jshint node: true */
'use strict';

module.exports = {
  name: 'bootstrap-modal',

  included: function(app) {
    this._super.included(app);

    // see: https://github.com/ember-cli/ember-cli/issues/3718
    if (typeof app.import !== 'function' && app.app) {
      app = app.app;
    }

    app.import('vendor/bootstrap-modal/styles.css');
  }
};
