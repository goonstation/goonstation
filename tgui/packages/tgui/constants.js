/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

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
    oxy: 'rgba(52, 152, 219, 0.5)',
    toxin: 'rgba(46, 204, 113, 0.5)',
    burn: 'rgba(230, 126, 34, 0.5)',
    brute: 'rgba(231, 76, 60, 0.5)',
  },
};

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

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
];

const GASES = [
  {
    'id': 'o2',
    'name': 'Oxygen',
    'label': 'O₂',
    'color': 'blue',
  },
  {
    'id': 'n2',
    'name': 'Nitrogen',
    'label': 'N₂',
    'color': 'red',
  },
  {
    'id': 'co2',
    'name': 'Carbon Dioxide',
    'label': 'CO₂',
    'color': 'grey',
  },
  {
    'id': 'plasma',
    'name': 'Plasma',
    'label': 'Plasma',
    'color': 'pink',
  },
  {
    'id': 'n2o',
    'name': 'Nitrous Oxide',
    'label': 'N₂O',
    'color': 'red',
  },
];

export const getGasLabel = (gasId, fallbackValue) => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find(gas => gas.id === gasSearchString
    || gas.name.toLowerCase() === gasSearchString);
  return gas && gas.label
    || fallbackValue
    || gasId;
};

export const getGasColor = gasId => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find(gas => gas.id === gasSearchString
    || gas.name.toLowerCase() === gasSearchString);
  return gas && gas.color;
};
