use crate::defines::*;

// my greatest sin.
// ok so you might wonder, why do we have this?
// well all our functions never cause threads to touch the same tiles at once
// but rust doesnt know that
// we cant just use the raw type, cause rust doesnt allow multiple mutable references
// atomics work, but they ruin optimisations cause llvm doesnt like messing with em
// cells dont work, because theyre single threaded only
// so this type holds a cell that we tell rust ong bro this is send and sync
// this is technically severely ungodly UB but im too cool and know all my code
// if you EVER break the assumption that no tiles overlap woe upon you data race.

#[derive(Eq, PartialEq, Debug, Clone, Default)]
pub(crate) struct TrustMe<T: Copy>(std::cell::Cell<T>);

impl<T: Copy> TrustMe<T> {
    #[inline(always)]
    pub(crate) const fn new(val: T) -> Self {
        Self(std::cell::Cell::new(val))
    }

    #[inline(always)]
    pub(crate) fn get(&self) -> T {
        self.0.get()
    }

    #[inline(always)]
    pub(crate) fn replace(&self, value: T) -> T {
        self.0.replace(value)
    }
}

impl<T: Copy> From<T> for TrustMe<T> {
    fn from(value: T) -> Self {
        TrustMe(value.into())
    }
}

// we never let the tiles overlap, so lets appease rust
unsafe impl<T: Copy> Send for TrustMe<T> {}
unsafe impl<T: Copy> Sync for TrustMe<T> {}

#[derive(Default, Debug, Clone)]
#[repr(align(64))]
pub(crate) struct GasMixtureDelta {
    pub(crate) gases: [TrustMe<f32>; GAS_COUNT],
    pub(crate) thermal_energy: TrustMe<f32>,
}

impl GasMixtureDelta {
    pub(crate) fn new(gases: [f32; GAS_COUNT], thermal_energy: f32) -> Self {
        GasMixtureDelta {
            gases: unsafe {
                std::mem::transmute::<[f32; GAS_COUNT], [TrustMe<f32>; GAS_COUNT]>(gases)
            },
            thermal_energy: thermal_energy.into(),
        }
    }

    #[inline]
    pub fn get_as_array(&self) -> &[f32; GAS_COUNT] {
        unsafe { std::mem::transmute(&self.gases) }
    }

    #[inline]
    pub(crate) fn add(&self, adder: &GasMixtureDelta) {
        let array = adder.get_as_array();
        (0..GAS_COUNT).for_each(|i| {
            self.gases[i].replace(self.gases[i].get() + array[i]);
        });

        self.thermal_energy
            .replace(self.thermal_energy.get() + adder.thermal_energy.get());
    }

    #[inline]
    pub(crate) fn get_temperature(&self) -> f32 {
        self.thermal_energy.get()
            / self
                .get_as_array()
                .iter()
                .zip(SPECIFIC_HEATS)
                .map(|(gas, heat)| gas * heat)
                .sum::<f32>()
    }

    #[inline]
    pub(crate) fn subtract(&self, adder: &GasMixtureDelta) {
        let array = adder.get_as_array();
        (0..GAS_COUNT).for_each(|i| {
            self.gases[i].replace(self.gases[i].get() - array[i]);
        });

        self.thermal_energy
            .replace(self.thermal_energy.get() - adder.thermal_energy.get());
    }
}

#[derive(Default, Debug, Clone)]
#[repr(align(64))]
pub(crate) struct GasMixture {
    gases: [TrustMe<f32>; GAS_COUNT],
    heat_capacity: TrustMe<f32>,
    moles: TrustMe<f32>,
    recalculate: TrustMe<bool>,
}

impl GasMixture {
    #[inline]
    pub(crate) fn get_gas(&self, index: usize) -> f32 {
        self.gases[index].get()
    }

    #[inline]
    pub(crate) fn set_gas(&self, index: usize, value: f32) {
        self.recalculate.replace(true);
        self.gases[index].replace(value);
    }

    #[inline]
    pub(crate) fn adjust_gas(&self, index: usize, value: f32) {
        let current = self.get_gas(index);
        let value = current + value;
        self.set_gas(index, value);
    }

    #[inline]
    pub fn get_as_array(&self) -> &[f32; GAS_COUNT] {
        unsafe { std::mem::transmute(&self.gases) }
    }

    pub(crate) fn refresh_cache(&self) {
        let mut moles_sum = 0.0;
        let mut heat_capacity_sum = 0.0;
        let our_gas = self.get_as_array();
        (0..GAS_COUNT).for_each(|idx| {
            moles_sum += our_gas[idx];
            heat_capacity_sum += our_gas[idx] * SPECIFIC_HEATS[idx];
        });
        self.moles.replace(moles_sum);
        self.heat_capacity.replace(heat_capacity_sum);
        self.recalculate.replace(false);
    }

    #[inline]
    pub(crate) fn moles(&self) -> f32 {
        if self.recalculate.get() {
            self.refresh_cache();
        }
        self.moles.get()
    }

    #[inline]
    pub(crate) fn heat_capacity(&self) -> f32 {
        if self.recalculate.get() {
            self.refresh_cache();
        }
        self.heat_capacity.get()
    }

    #[inline]
    pub(crate) fn zero_out(&self) {
        self.gases.iter().for_each(|item| {
            item.replace(0.0);
        });
        self.recalculate.replace(true);
    }
}

impl From<[TrustMe<f32>; GAS_COUNT]> for GasMixture {
    fn from(value: [TrustMe<f32>; GAS_COUNT]) -> Self {
        GasMixture {
            gases: value,
            heat_capacity: 0.0.into(),
            moles: 0.0.into(),
            recalculate: true.into(),
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////

#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum TileStatus {
    /// Open tile
    Normal,
    /// Constantly shares with an environment
    Exposed(u8),
    /// Does not change, is able to transfer to others
    Immutable,
    /// Pure obstacle, shares NOTHIN
    Sealed,
}

#[derive(Debug, Clone)]
#[repr(align(64))]
pub(crate) struct Tile {
    pub(crate) gas: GasMixture,
    pub(crate) status: TrustMe<TileStatus>,
    pub(crate) heat_capacity: TrustMe<f32>,
    pub(crate) thermal_energy: TrustMe<f32>,
    pub(crate) wall: TrustMe<bool>,
    pub(crate) sharing_coefficent: TrustMe<f32>,
    pub(crate) superconducting: TrustMe<bool>,
    pub(crate) conduction_coefficient: TrustMe<u8>,
    pub(crate) hotspot_temperature: TrustMe<f32>,
    pub(crate) hotspot_volume: TrustMe<f32>,
}

impl Default for Tile {
    fn default() -> Self {
        Tile {
            gas: GasMixture::default(),
            status: TileStatus::Sealed.into(), // reduces performance hit of processing a newly made zlevel
            heat_capacity: 20000.0.into(),
            thermal_energy: 0.0.into(),
            wall: false.into(),
            sharing_coefficent: 0.2.into(),
            superconducting: false.into(),
            conduction_coefficient: 6.into(),
            hotspot_temperature: 0.0.into(),
            hotspot_volume: 0.0.into(),
        }
    }
}

impl Tile {
    #[inline]
    pub(crate) fn heat_capacity(&self) -> f32 {
        self.heat_capacity.get() + self.gas.heat_capacity()
    }

    #[inline]
    pub(crate) fn get_thermal_energy(&self) -> f32 {
        self.thermal_energy.get()
    }

    #[inline]
    pub(crate) fn set_thermal_energy(&self, value: f32) {
        self.thermal_energy.replace(value);
    }

    #[inline]
    pub(crate) fn change_thermal_energy(&self, value: f32) {
        let new_value = self.get_thermal_energy() + value;
        self.thermal_energy.replace(new_value);
    }

    #[inline]
    pub(crate) fn get_temperature(&self) -> f32 {
        self.get_thermal_energy() / self.heat_capacity()
    }

    #[inline]
    pub(crate) fn set_temperature(&self, value: f32) {
        let new_value = value * self.heat_capacity();
        self.thermal_energy.replace(new_value);
    }

    #[inline]
    pub(crate) fn adjust_temperature(&self, value: f32) {
        let new_value = value * self.heat_capacity();
        self.thermal_energy
            .replace(self.thermal_energy.get() + new_value);
    }

    #[inline]
    pub(crate) fn pressure(&self) -> f32 {
        (self.gas.moles() * IDEAL_GAS_CONSTANT * self.get_temperature()) / CELL_VOLUME
    }

    pub(crate) fn share(
        &self,
        sharer: &Tile,
        our_coeff: f32,
        sharer_coeff: f32,
    ) -> Option<(GasMixtureDelta, f32)> {
        if sharer.wall.get() || sharer.status.get() == TileStatus::Sealed {
            return None;
        }

        let our_gas = self.gas.get_as_array();
        let sharer_gas = sharer.gas.get_as_array();

        let deltas: [f32; GAS_COUNT] = core::array::from_fn(|idx| {
            let delta = our_gas[idx] - sharer_gas[idx];
            if delta > 0.0 {
                delta * our_coeff
            } else {
                delta * sharer_coeff
            }
        });

        let mut exchange_energy = 0.0;
        if (self.get_temperature() - sharer.get_temperature()).abs()
            > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER
        {
            let self_temp = self.get_temperature();
            let sharer_temp = sharer.get_temperature();
            let partial_heat_capacities: [f32; GAS_COUNT] =
                core::array::from_fn(|idx| deltas[idx] * SPECIFIC_HEATS[idx]);

            exchange_energy += partial_heat_capacities
                .iter()
                .map(|heat_capacity| {
                    heat_capacity
                        * if *heat_capacity > 0.0 {
                            self_temp
                        } else {
                            sharer_temp
                        }
                })
                .sum::<f32>();

            if (partial_heat_capacities
                .iter()
                .fold(0.0, |acc, partial_heat_capacity| {
                    acc - partial_heat_capacity.min(0.0)
                })
                / sharer.heat_capacity())
                < 0.1
            {
                exchange_energy += self.temperature_share(sharer, 0.4);
            }
        }

        let delta_p = self.get_temperature() * (self.gas.moles() + deltas.iter().sum::<f32>())
            - sharer.get_temperature() * (sharer.gas.moles() - deltas.iter().sum::<f32>());

        Some((
            GasMixtureDelta::new(deltas, exchange_energy),
            delta_p * IDEAL_GAS_CONSTANT / CELL_VOLUME,
        ))
    }

    /// positive means us to them

    #[inline]
    pub(crate) fn temperature_share(&self, sharer: &Tile, coeff: f32) -> f32 {
        self.temperature_expose(sharer.get_temperature(), sharer.heat_capacity(), coeff)
    }

    #[inline]
    pub(crate) fn temperature_expose(
        &self,
        sharer_temperature: f32,
        sharer_heat_capacity: f32,
        coeff: f32,
    ) -> f32 {
        let delta = self.get_temperature() - sharer_temperature;
        let mut heat = 0.0;
        if delta.abs() > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER {
            let our = self.heat_capacity();
            if our > MINIMUM_HEAT_CAPACITY && sharer_heat_capacity > MINIMUM_HEAT_CAPACITY {
                heat = (coeff * delta * our * sharer_heat_capacity) / (our + sharer_heat_capacity);
            }
        }
        heat
    }

    pub(crate) fn react(&self) -> bool {
        if matches!(
            self.status.get(),
            TileStatus::Immutable | TileStatus::Sealed
        ) {
            return false;
        }

        let temperature = self.get_temperature();
        let gas_array = self.gas.get_as_array();

        if temperature > 900.0
            && gas_array[GAS_TOXINS] > ATMOS_EPSILON
            && gas_array[GAS_CARBON_DIOXIDE] > ATMOS_EPSILON
        {
            if gas_array[GAS_AGENT_B] > ATMOS_EPSILON {
                let reaction_rate = (gas_array[GAS_CARBON_DIOXIDE] * 0.75)
                    .min((gas_array[GAS_TOXINS] * 0.25).min(gas_array[GAS_AGENT_B] * 0.05));
                if reaction_rate > ATMOS_EPSILON {
                    self.gas.adjust_gas(GAS_CARBON_DIOXIDE, -reaction_rate);
                    self.gas.adjust_gas(GAS_OXYGEN, reaction_rate);
                    self.gas.adjust_gas(GAS_AGENT_B, -reaction_rate * 0.05);
                    self.change_thermal_energy(20.0 * reaction_rate);
                }
            }

            if gas_array[GAS_FARTS] > ATMOS_EPSILON {
                let reaction_rate = (gas_array[GAS_CARBON_DIOXIDE] * 0.75)
                    .min((gas_array[GAS_TOXINS] * 0.25).min(gas_array[GAS_FARTS] * 0.05));
                if reaction_rate > ATMOS_EPSILON {
                    self.gas.adjust_gas(GAS_CARBON_DIOXIDE, -reaction_rate);
                    self.gas.adjust_gas(GAS_TOXINS, reaction_rate);
                    self.gas.adjust_gas(GAS_FARTS, -reaction_rate * 0.05);
                    self.change_thermal_energy(10.0 * reaction_rate);
                }
            }
        }

        if gas_array[GAS_TOXINS] > ATMOS_EPSILON && temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST
        {
            let temperature_scale = if self.get_temperature() > PLASMA_UPPER_TEMPERATURE {
                1.0
            } else {
                (temperature - PLASMA_MINIMUM_BURN_TEMPERATURE)
                    / (PLASMA_UPPER_TEMPERATURE - PLASMA_MINIMUM_BURN_TEMPERATURE)
            };
            let oxygen_burn_rate = 1.4 - temperature_scale;
            let plasma_burn_rate =
                if gas_array[GAS_OXYGEN] > gas_array[GAS_TOXINS] * PLASMA_OXYGEN_FULLBURN {
                    gas_array[GAS_TOXINS] * temperature_scale / 4.0
                } else {
                    (gas_array[GAS_OXYGEN] / PLASMA_OXYGEN_FULLBURN) * temperature_scale / 4.0
                };

            if plasma_burn_rate > ATMOS_EPSILON {
                self.gas.adjust_gas(GAS_TOXINS, -plasma_burn_rate / 3.0);
                self.gas
                    .adjust_gas(GAS_OXYGEN, -plasma_burn_rate * oxygen_burn_rate);
                self.gas
                    .adjust_gas(GAS_CARBON_DIOXIDE, plasma_burn_rate / 3.0);
                self.change_thermal_energy(FIRE_PLASMA_ENERGY_RELEASED * plasma_burn_rate);
                return true;
            }
        }
        false
    }

    #[inline]
    pub(crate) fn check_superconduction(&self, starting: bool) {
        if self.superconducting.get() {
            self.superconducting
                .replace(self.get_temperature() > MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION);
            return;
        }

        match self.status.get() {
            TileStatus::Immutable => return,
            TileStatus::Sealed => return,
            _ => (),
        }

        self.superconducting.replace(
            self.get_temperature()
                > if starting {
                    MINIMUM_TEMPERATURE_START_SUPERCONDUCTION
                } else {
                    MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION
                },
        );
    }

    #[inline]
    pub(crate) fn apply(&self, adder: &GasMixtureDelta) {
        self.change_thermal_energy(adder.thermal_energy.get());

        let gases = adder.get_as_array();
        (0..GAS_COUNT).for_each(|i| {
            self.gas.adjust_gas(i, gases[i]);
        });
    }

    pub(crate) fn remove_ratio(&self, ratio: f32) -> GasMixtureDelta {
        let ratio = ratio.clamp(0.0, 1.0);
        if ratio == 0.0 {
            return GasMixtureDelta::default();
        }
        let mut deltas: [f32; GAS_COUNT] = [0.0; GAS_COUNT];
        let mut thermal_energy = 0.0;
        let temperature = self.get_temperature();
        SPECIFIC_HEATS
            .iter()
            .enumerate()
            .for_each(|(idx, specific_heat)| {
                let delta = self.gas.get_gas(idx) * ratio;
                deltas[idx] = delta;
                thermal_energy += delta * specific_heat * temperature;
            });

        if matches!(
            self.status.get(),
            TileStatus::Normal | TileStatus::Exposed(_)
        ) {
            (0..GAS_COUNT).for_each(|idx| self.gas.adjust_gas(idx, -deltas[idx]));
            self.change_thermal_energy(-thermal_energy);
        }

        GasMixtureDelta::new(deltas, thermal_energy)
    }
}
