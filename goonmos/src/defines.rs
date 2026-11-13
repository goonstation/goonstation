pub(crate) const GAS_COUNT: usize = 8;

pub(crate) const GAS_OXYGEN: usize = 0;
pub(crate) const _GAS_NITROGEN: usize = 1;
pub(crate) const GAS_CARBON_DIOXIDE: usize = 2;
pub(crate) const GAS_TOXINS: usize = 3;
pub(crate) const GAS_FARTS: usize = 4;
pub(crate) const _GAS_RADGAS: usize = 5;
pub(crate) const _GAS_NITROUS_OXIDE: usize = 6;
pub(crate) const GAS_AGENT_B: usize = 7;

pub(crate) const _GASES: [usize; GAS_COUNT] = [
    GAS_OXYGEN,
    _GAS_NITROGEN,
    GAS_CARBON_DIOXIDE,
    GAS_TOXINS,
    GAS_FARTS,
    _GAS_RADGAS,
    _GAS_NITROUS_OXIDE,
    GAS_AGENT_B,
];

// KJ/mol
pub(crate) const SPECIFIC_HEAT_OXYGEN: f32 = 0.04;
pub(crate) const SPECIFIC_HEAT_NITROGEN: f32 = 0.05;
pub(crate) const SPECIFIC_HEAT_CARBON_DIOXIDE: f32 = 0.04;
pub(crate) const SPECIFIC_HEAT_TOXINS: f32 = 0.15;
pub(crate) const SPECIFIC_HEAT_FARTS: f32 = 0.069;
pub(crate) const SPECIFIC_HEAT_RADGAS: f32 = 0.005;
pub(crate) const SPECIFIC_HEAT_NITROUS_OXIDE: f32 = 0.06;
pub(crate) const SPECIFIC_HEAT_AGENT_B: f32 = 0.3;

// order must match with GASES
pub(crate) const SPECIFIC_HEATS: [f32; GAS_COUNT] = [
    SPECIFIC_HEAT_OXYGEN,
    SPECIFIC_HEAT_NITROGEN,
    SPECIFIC_HEAT_CARBON_DIOXIDE,
    SPECIFIC_HEAT_TOXINS,
    SPECIFIC_HEAT_FARTS,
    SPECIFIC_HEAT_RADGAS,
    SPECIFIC_HEAT_NITROUS_OXIDE,
    SPECIFIC_HEAT_AGENT_B,
];

pub(crate) const ATMOS_EPSILON: f32 = 0.0001;

pub(crate) const MINIMUM_HEAT_CAPACITY: f32 = 0.0001;

pub(crate) const MINIMUM_DELTA_PRESSURE: f32 = 20.0;

pub(crate) const T_CMB: f32 = 2.7;

pub(crate) const T_0C: f32 = 273.15;

pub(crate) const CELL_VOLUME: f32 = 2500.0;

pub(crate) const IDEAL_GAS_CONSTANT: f32 = 8.314_463;

pub(crate) const MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER: f32 = 1.0;

pub(crate) const PLASMA_MINIMUM_BURN_TEMPERATURE: f32 = T_0C + 100.0;

pub(crate) const FIRE_MINIMUM_TEMPERATURE_TO_EXIST: f32 = T_0C + 100.0;

pub(crate) const PLASMA_UPPER_TEMPERATURE: f32 = T_0C + 2730.0;

pub(crate) const PLASMA_OXYGEN_FULLBURN: f32 = 10.0;

pub(crate) const FIRE_PLASMA_ENERGY_RELEASED: f32 = 3000.0;

pub(crate) const MINIMUM_TEMPERATURE_START_SUPERCONDUCTION: f32 = T_0C + 220.0;

pub(crate) const MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION: f32 = T_0C + 30.0;
