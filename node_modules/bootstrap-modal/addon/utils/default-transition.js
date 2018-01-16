const options = {
  duration: 400,
  easing: 'easeInOutQuint'
};
const crossOptions = {
  duration: 400,
  maxOpacity: 0.8
};

export default function defaultTransition(context) {
  if (!context || typeof context.transition !== 'function') {
    throw new Error('[bootstrap-modal] Invalid transitions context supplied');
  }

  return context.transition(
    context.hasClass('bootstrap-modal'),
    // hack to get reverse working..
    context.toValue(true),
    context.use('explode', {
      pick: '.modal-dialog',
      use: ['to-down', options]
    }, {
      pick: '.modal-backdrop',
      use: ['crossFade', crossOptions]
    }),
    context.reverse('explode', {
      pick: '.modal-dialog',
      use: ['to-up', options]
    }, {
      pick: '.modal-backdrop',
      use: ['crossFade', crossOptions]
    })
  );
}
