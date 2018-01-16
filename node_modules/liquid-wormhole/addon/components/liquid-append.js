import Ember from 'ember';

export default Ember.Component.extend({
  didUpdateAttrs() {
    if (this.get('replaceNodes')) {
      const nodes = this.get('nodes');

      this.$().children().remove();
      this.$().append(nodes);
    }
  },

  didInsertElement() {
    const notify = this.get('notify');
    const nodes = this.get('nodes');

    if (notify && notify.willAppendNodes) {
      notify.willAppendNodes(this.element);
    }

    this.$().append(nodes);

    if (notify && notify.didAppendNodes) {
      notify.didAppendNodes(this.element);
    }
  }
});
