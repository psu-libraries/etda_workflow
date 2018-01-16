import Constraint from 'liquid-fire/constraint';

export function target(name) {
  return new Constraint('parentElementClass', `${name}`);
}

export function onOpenWormhole() {
  return new Constraint('newValue', (value) => value !== null);
}

export function onCloseWormhole() {
  return new Constraint('newValue', (value) => value === null);
}
