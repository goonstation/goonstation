export const MobStatus = {
  Conscious: 0,
  Unconscious: 1,
  Dead: 2,
};

export const MobStatuses = {
  [MobStatus.Conscious]: {
    name: 'Conscious',
    color: 'good',
    icon: 'check',
  },
  [MobStatus.Unconscious]: {
    name: 'Unconscious',
    color: 'average',
    icon: 'bed',
  },
  [MobStatus.Dead]: {
    name: 'Dead',
    color: 'bad',
    icon: 'skull',
  },
};
