import Ember from 'ember';
import layout from '../templates/components/liquid-wormhole';

const { computed, inject, generateGuid } = Ember;

const { service } = inject;
const { reads } = computed;

export default Ember.Component.extend({
  layout,

  to: reads('destination'),
  liquidWormholeService: service('liquid-wormhole'),

  stack: computed(() => generateGuid()),

  // Truthy value by default
  value: true,

  init() {
    const wormholeClass = this.get('class');
    const wormholeId = this.get('stack') || this.get('id');

    this.set('wormholeClass', wormholeClass);
    this.set('wormholeId', wormholeId);

    if (Ember.typeOf(this.get('send')) !== 'function') {
      this.set('hasSend', true);
    }

    this._super(...arguments);
  },

  didUpdateAttrs() {
    this._super(...arguments);
    this.get('liquidWormholeService').removeWormhole(this, this.get('to'));
    this.get('liquidWormholeService').appendWormhole(this, this.get('to'));
  },

  didInsertElement() {
    const nodes = this.$().children();
    this.set('nodes', nodes);

    this.element.className = 'liquid-wormhole-container';
    this.element.id = '';

    this.get('liquidWormholeService').appendWormhole(this, this.get('to'));

    this._super.apply(this, arguments);
  },

  willDestroyElement() {
    this.get('liquidWormholeService').removeWormhole(this, this.get('to'));

    this._super.apply(this, arguments);
  }
});
