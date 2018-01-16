import Ember from 'ember';
import layout from './template';

export default Ember.Component.extend({
  layout: layout,
  actions: {
    overlayClick() {
      var allow = this.get('closeOnOverlayClick');

      if (allow && this.get('close')) {
        this.sendAction('close', true);
      }
    }
  }
});
