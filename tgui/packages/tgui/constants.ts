/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Gas = {
  id: string;
  // path: string; |GOONSTATION-CHANGE|
  name: string;
  label: string;
  color: string;
};

// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#548b55', // |GOONSTATION-CHANGE|
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    service: '#7cc46a',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
  damageTypeFill: {
    // |GOONSTATION-CHANGE|
    oxy: 'rgba(52, 152, 219, 0.5)',
    toxin: 'rgba(46, 204, 113, 0.5)',
    burn: 'rgba(230, 126, 34, 0.5)',
    brute: 'rgba(231, 76, 60, 0.5)',
  },
  // reagent / chemistry related colours
  reagent: {
    acidicbuffer: '#fbc314',
    basicbuffer: '#3853a4',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'average',
  'bad',
  'black',
  'blue',
  'brown',
  'good',
  'green',
  'grey',
  'label',
  'olive',
  'orange',
  'pink',
  'purple',
  'red',
  'teal',
  'transparent',
  'violet',
  'white',
  'yellow',
] as const;

export type CssColor = (typeof CSS_COLORS)[number];

/* IF YOU CHANGE THIS KEEP IT IN SYNC WITH CHAT CSS */
// |GOONSTATION-CHANGE|
export const RADIO_CHANNELS = [
  {
    name: 'Syndicate',
    freq: 1352,
    color: '#BB3333',
  },
  {
    name: 'CentCom',
    freq: 1451,
    color: '#2681a5',
  },
  {
    name: 'Catering',
    freq: 1485,
    color: '#C16082',
  },
  {
    name: 'Civilian',
    freq: 1355,
    color: '#6ca729',
  },
  {
    name: 'Research',
    freq: 1354,
    color: '#153E9E',
  },
  {
    name: 'Command',
    freq: 1356,
    color: '#5177ff',
  },
  {
    name: 'Medical',
    freq: 1445,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 1441,
    color: '#BBBB00',
  },
  {
    name: 'Security',
    freq: 1485,
    color: '#dd3535',
  },
  {
    name: 'AI',
    freq: 1447,
    color: '#333399',
  },
  {
    name: 'Bridge',
    freq: 1442,
    color: '#339933',
  },
] as const;

// |GOONSTATION-CHANGE|
const GASES = [
  {
    id: 'o2',
    name: 'Oxygen',
    label: 'O₂',
    color: 'blue',
  },
  {
    id: 'n2',
    name: 'Nitrogen',
    label: 'N₂',
    color: 'red',
  },
  {
    id: 'co2',
    name: 'Carbon Dioxide',
    label: 'CO₂',
    color: 'grey',
  },
  {
    id: 'plasma',
    name: 'Plasma',
    label: 'Plasma',
    color: 'pink',
  },
  {
    id: 'n2o',
    name: 'Nitrous Oxide',
    label: 'N₂O',
    color: 'red',
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  if (!gasId) return fallbackValue || 'None';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].label;
    }
  }

  return fallbackValue || 'None';
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  if (!gasId) return 'black';

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx].color;
    }
  }

  return 'black';
};

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  if (!gasId) return;

  const gasSearchString = gasId.toLowerCase();

  for (let idx = 0; idx < GASES.length; idx++) {
    if (GASES[idx].id === gasSearchString) {
      return GASES[idx];
    }
  }
};
