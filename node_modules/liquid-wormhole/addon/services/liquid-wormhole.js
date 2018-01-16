import Ember from 'ember';
import HashMap from 'perf-primitives/hash-map';

const { getOwner } = Ember;

export default Ember.Service.extend({
  init() {
    this._super(...arguments);

    this.destination = new HashMap();
  },

  appendWormhole(wormhole, destinationName = 'default') {
    let destination = this.destination.get(destinationName);

    if (destination === undefined) {
      if (destinationName === 'default') {
        destination = this.addDefaultDestination();
      } else {
        throw new Error('Liquid Wormhole destination does not exist');
      }
    }

    destination.appendWormhole(wormhole);
  },

  removeWormhole(wormhole, destinationName = 'default') {
    const destination = this.destination.get(destinationName);

    if (destination === undefined) {
      throw new Error('Liquid Wormhole destination does not exist');
    }

    destination.removeWormhole(wormhole);
  },

  registerDestination(destinationName, destination) {
    if (this.destination.get(destinationName)) {
      throw new Error(`Liquid Wormhole destination '${destinationName}' already created`);
    }
    this.destination.set(destinationName, destination);
  },

  unregisterDestination(destinationName) {
    this.destination.delete(destinationName);
  },

  willDestroy() {
    this.removeDefaultDestination();
  },

  addDefaultDestination() {
    const instance = getOwner(this);
    const destination = instance.lookup('component:liquid-destination');
    destination.set('classNames', ['liquid-destination', 'default-liquid-destination']);

    if (instance.rootElement) {
      destination.appendTo(instance.rootElement);
    } else if (Ember.$('.ember-application').length > 0) {
      destination.appendTo(Ember.$('.ember-application')[0]);
    } else {
      destination.appendTo(document);
    }

    this.defaultDestination = destination;

    return destination;
  },

  removeDefaultDestination() {
    if (this.defaultDestination) {
      this.defaultDestination.destroy();
    }
  }

});
