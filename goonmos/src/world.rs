use crate::defines::*;
use crate::types::*;
use crate::zlevel::*;
use meowtonin::ByondXYZ;
use meowtonin::misc::block;
use rayon::prelude::*;
use std::sync::{Mutex, RwLock};

/// make sure your on the main thread using this bud
pub(crate) static GOONMOS: RwLock<World> = RwLock::new(World::new());

pub(crate) struct World {
    zlevels: Mutex<Vec<Zlevel>>,
    maxx: TrustMe<u16>,
    maxy: TrustMe<u16>,
    pub(crate) environments: RwLock<Vec<Tile>>,
}

impl World {
    pub(crate) const fn new() -> Self {
        World {
            zlevels: Mutex::new(Vec::new()),
            maxx: TrustMe::new(0),
            maxy: TrustMe::new(0),
            environments: RwLock::new(Vec::new()),
        }
    }

    pub(crate) fn set_zlevels(&self, new_z: usize) {
        let mut lock = self.zlevels.lock().unwrap();
        if new_z == lock.len() {
            return;
        }
        if new_z > lock.len() {
            (0..(new_z - lock.len())).for_each(|_| {
                lock.push(Zlevel::new(
                    self.maxx.get() as usize,
                    self.maxy.get() as usize,
                ));
            });
        } else {
            self.zlevels.lock().unwrap().truncate(new_z);
        }
    }

    pub(crate) fn set_size(&self, maxx: usize, maxy: usize) {
        self.maxx.replace(maxx as u16);
        self.maxy.replace(maxy as u16);
        self.zlevels
            .lock()
            .unwrap()
            .iter_mut()
            .for_each(|x| x.set_size(maxx, maxy));
    }

    pub(crate) fn initialize_all_zlevels_to_map(&self) {
        let zlevels = self.zlevels.lock().unwrap().len();
        (0..zlevels).for_each(|i| self.initialize_zlevel_to_map(i));
    }

    pub(crate) fn initialize_zlevel_to_map(&self, z: usize) {
        self.initialize_block_to_map(1, 1, self.maxx.get(), self.maxy.get(), z);
    }

    pub(crate) fn initialize_block_to_map(
        &self,
        low_x: u16,
        low_y: u16,
        high_x: u16,
        high_y: u16,
        z: usize,
    ) {
        let lock = &self.zlevels.lock().unwrap()[z];
        let z = z + 1;
        block(
            ByondXYZ::from((low_x, low_y, z as u16)),
            ByondXYZ::from((high_x, high_y, z as u16)),
        )
        .expect("Can't find that block!")
        .iter()
        .map(|turf| {
            let coords = turf.xyz().unwrap();
            let default: Vec<f32> = turf.call("goonmos_init", [()]).unwrap();
            let gas: [f32; GAS_COUNT] = core::array::from_fn(|idx| default[idx]);
            let other: [f32; 6] = core::array::from_fn(|idx| default[GAS_COUNT + idx]);
            (
                (coords.x() as usize - 1, coords.y() as usize - 1),
                gas,
                other,
            )
        })
        .collect::<Vec<((usize, usize), [f32; GAS_COUNT], [f32; 6])>>()
        .par_iter()
        .for_each(|((x, y), gases, other)| {
            let tile = lock.try_get_coords(*x, *y).unwrap();
            (0..GAS_COUNT).for_each(|gas_idx| {
                tile.gas.set_gas(gas_idx, gases[gas_idx]);
            });

            tile.heat_capacity.replace(other[0]);
            tile.set_temperature(other[1]);
            tile.status.replace(match other[2] as usize {
                0 => TileStatus::Normal,
                1 => TileStatus::Exposed(other[3] as u8),
                2 => TileStatus::Immutable,
                3 => TileStatus::Sealed,
                _ => panic!("dumb fuck!"),
            });
            tile.wall.replace(other[4] != 0.0);
            tile.conduction_coefficient.replace(other[5] as u8);
        });
        lock.precalculate_values(
            low_x as usize - 1,
            low_y as usize - 1,
            high_x as usize - 1,
            high_y as usize - 1,
        );
    }

    pub(crate) fn try_get_environment(&self, idx: usize) -> Option<Tile> {
        self.environments.read().unwrap().get(idx).cloned()
    }

    pub(crate) fn get_gas_at_coords(&self, index: usize, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .gas
            .get_gas(index)
    }

    pub(crate) fn set_gas_at_coords(&self, value: f32, index: usize, x: usize, y: usize, z: usize) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .gas
            .set_gas(index, value);
    }

    pub(crate) fn adjust_gas_at_coords(
        &self,
        value: f32,
        index: usize,
        x: usize,
        y: usize,
        z: usize,
    ) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .gas
            .adjust_gas(index, value);
    }

    pub(crate) fn clone_tile_at_coords(&self, x: usize, y: usize, z: usize) -> Tile {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .clone()
    }

    pub(crate) fn get_pressure_at_coords(&self, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .pressure()
    }

    pub(crate) fn get_moles_at_coords(&self, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .gas
            .moles()
    }

    pub(crate) fn get_temperature_at_coords(&self, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .get_temperature()
    }

    pub(crate) fn set_temperature_at_coords(&self, value: f32, x: usize, y: usize, z: usize) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .set_temperature(value);
    }

    pub(crate) fn adjust_temperature_at_coords(&self, value: f32, x: usize, y: usize, z: usize) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .adjust_temperature(value);
    }

    pub(crate) fn get_heat_capacity_at_coords(&self, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .heat_capacity()
    }

    pub(crate) fn get_thermal_energy_at_coords(&self, x: usize, y: usize, z: usize) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .get_thermal_energy()
    }

    pub(crate) fn set_thermal_energy_at_coords(&self, value: f32, x: usize, y: usize, z: usize) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .set_thermal_energy(value);
    }

    pub(crate) fn change_thermal_energy_at_coords(&self, value: f32, x: usize, y: usize, z: usize) {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .change_thermal_energy(value);
    }

    pub(crate) fn mimic_temperature_exchange(
        &self,
        temperature: f32,
        heat_capacity: f32,
        coefficient: f32,
        x: usize,
        y: usize,
        z: usize,
    ) -> f32 {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .temperature_expose(temperature, heat_capacity, coefficient)
    }

    pub(crate) fn remove_ratio_at_coords(
        &self,
        ratio: f32,
        x: usize,
        y: usize,
        z: usize,
    ) -> GasMixtureDelta {
        self.zlevels.lock().unwrap()[z]
            .tiles
            .get(x, y)
            .expect("Tile doesn't exist!")
            .remove_ratio(ratio)
    }

    pub(crate) fn set_wall_at_coords(&self, x: usize, y: usize, z: usize, wall: bool) {
        self.zlevels.lock().unwrap()[z].set_wall(x, y, wall);
    }

    pub(crate) fn process_zlevel(&self, z: usize) {
        let (movement, fires) = self.zlevels.lock().unwrap()[z].tick();
    }
}
