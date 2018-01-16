/*jshint node:true*/
module.exports = {
  description: 'Add LiquidFire to the consumers app',

  // So we don't see the entity name error
  normalizeEntityName: function() {},

  afterInstall: function() {
    return this.addAddonToProject({
      name: 'liquid-fire',
      version: '0.26.5'
    });
  }
};
