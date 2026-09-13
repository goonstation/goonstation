use crate::{
    defines::{CELL_VOLUME, GAS_COUNT},
    world::*,
};
use meowtonin::*;

#[byond_fn]
pub fn set_panic_location(path: ByondValue) {
    panic::set_panic_output_folder(path.get_string().unwrap());
}

#[byond_fn]
pub fn initialize(maxx: ByondValue, maxy: ByondValue, maxz: ByondValue) -> ByondResult<()> {
    let maxx = maxx.get_number()? as usize;
    let maxy = maxy.get_number()? as usize;
    let maxz = maxz.get_number()? as usize;

    let lock = GOONMOS.write().unwrap_or_else(|mut e| {
        //kill fuckin everything, we starting over
        **e.get_mut() = World::new();
        GOONMOS.clear_poison();
        e.into_inner()
    });

    lock.set_size(maxx, maxy);
    lock.set_zlevels(maxz);

    Ok(())
}

#[byond_fn]
pub fn initialize_all_zlevels() {
    let lock = GOONMOS.read().unwrap();
    lock.initialize_all_zlevels_to_map();
}

#[byond_fn]
pub fn initialize_zlevel_to_map(z: ByondValue) -> ByondResult<()> {
    let z = z.get_number()? as usize - 1;
    let lock = GOONMOS.read().unwrap();
    lock.initialize_zlevel_to_map(z);
    Ok(())
}

#[byond_fn]
pub fn initialize_block_to_map(
    low_x: ByondValue,
    low_y: ByondValue,
    high_x: ByondValue,
    high_y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let low_x = low_x.get_number()? as u16 - 1;
    let low_y = low_y.get_number()? as u16 - 1;
    let high_x = high_x.get_number()? as u16 - 1;
    let high_y = high_y.get_number()? as u16 - 1;
    let z = z.get_number()? as usize - 1;
    let lock = GOONMOS.read().unwrap();
    lock.initialize_block_to_map(low_x, low_y, high_x, high_y, z);
    Ok(())
}

#[byond_fn]
pub fn set_wall(wall: ByondValue, x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<()> {
    let wall = wall.get_number()? as usize != 0;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    let lock = GOONMOS.read().unwrap();
    lock.set_wall_at_coords(x, y, z, wall);
    Ok(())
}

#[byond_fn]
pub fn get_gas(index: ByondValue, x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let index = index.get_number()? as usize;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().get_gas_at_coords(index, x, y, z))
}

#[byond_fn]
pub fn set_gas(
    value: ByondValue,
    index: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let value = value.get_number()?;
    let index = index.get_number()? as usize;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    GOONMOS
        .read()
        .unwrap()
        .set_gas_at_coords(value, index, x, y, z);
    Ok(())
}

#[byond_fn]
pub fn adjust_gas(
    value: ByondValue,
    index: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let value = value.get_number()?;
    let index = index.get_number()? as usize;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    GOONMOS
        .read()
        .unwrap()
        .adjust_gas_at_coords(value, index, x, y, z);
    Ok(())
}

#[byond_fn]
pub fn get_pressure(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().get_pressure_at_coords(x, y, z))
}

#[byond_fn]
pub fn set_temperature(
    value: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let value = value.get_number()?;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    GOONMOS
        .read()
        .unwrap()
        .set_temperature_at_coords(value, x, y, z);
    Ok(())
}

#[byond_fn]
pub fn get_temperature(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().get_temperature_at_coords(x, y, z))
}

#[byond_fn]
pub fn get_energy(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS
        .read()
        .unwrap()
        .get_thermal_energy_at_coords(x, y, z))
}

#[byond_fn]
pub fn set_energy(
    value: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let value = value.get_number()?;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    GOONMOS
        .read()
        .unwrap()
        .set_thermal_energy_at_coords(value, x, y, z);
    Ok(())
}

#[byond_fn]
pub fn adjust_energy(
    value: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<()> {
    let value = value.get_number()?;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    GOONMOS
        .read()
        .unwrap()
        .change_thermal_energy_at_coords(value, x, y, z);
    Ok(())
}

#[byond_fn]
pub fn get_total_moles(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().get_moles_at_coords(x, y, z))
}

#[byond_fn]
pub fn get_heat_capacity(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<f32> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().get_heat_capacity_at_coords(x, y, z))
}

#[byond_fn]
pub fn get_tile_info(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<Vec<f32>> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    let mut info: Vec<f32> = Vec::new();
    let tile = GOONMOS.read().unwrap().clone_tile_at_coords(x, y, z);
    tile.gas
        .get_as_array()
        .iter()
        .for_each(|idx| info.push(*idx));
    info.push(tile.get_temperature());
    info.push(CELL_VOLUME);

    Ok(info)
}

#[byond_fn]
pub fn mimic_temperature_exchange(
    temperature: ByondValue,
    heat_capacity: ByondValue,
    coefficient: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<f32> {
    let temperature = temperature.get_number()?;
    let heat_capacity = heat_capacity.get_number()?;
    let coefficient = coefficient.get_number()?;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    Ok(GOONMOS.read().unwrap().mimic_temperature_exchange(
        temperature,
        heat_capacity,
        coefficient,
        x,
        y,
        z,
    ))
}

#[byond_fn]
pub fn assume_air(air: ByondValue, x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<()> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;
    let air: Vec<f32> = air
        .read_list()
        .unwrap()
        .into_iter()
        .map(|item| item.get_number().unwrap() as f32)
        .collect();
    let gases: [f32; GAS_COUNT] = core::array::from_fn(|idx| air[idx]);
    let temperature: f32 = air[GAS_COUNT];

    let lock = GOONMOS.read().unwrap();
    (0..GAS_COUNT).for_each(|gas_idx| {
        lock.adjust_gas_at_coords(gases[gas_idx], gas_idx, x, y, z);
    });

    lock.adjust_temperature_at_coords(temperature, x, y, z);

    Ok(())
}

#[byond_fn]
pub fn remove_ratio(
    ratio: ByondValue,
    x: ByondValue,
    y: ByondValue,
    z: ByondValue,
) -> ByondResult<Vec<f32>> {
    let ratio = ratio.get_number()?;
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    let mut removed: Vec<f32> = Vec::new();
    let tile = GOONMOS
        .read()
        .unwrap()
        .remove_ratio_at_coords(ratio, x, y, z);
    tile.get_as_array()
        .iter()
        .for_each(|idx| removed.push(*idx));
    removed.push(tile.get_temperature());
    removed.push(CELL_VOLUME);
    Ok(removed)
}

#[byond_fn]
pub fn get_tile_info_debug(x: ByondValue, y: ByondValue, z: ByondValue) -> ByondResult<Vec<f32>> {
    let x = x.get_number()? as usize - 1;
    let y = y.get_number()? as usize - 1;
    let z = z.get_number()? as usize - 1;

    let mut info: Vec<f32> = Vec::new();
    let tile = GOONMOS.read().unwrap().clone_tile_at_coords(x, y, z);
    (0..GAS_COUNT).for_each(|idx| info.push(tile.gas.get_gas(idx)));
    info.push(tile.heat_capacity());
    info.push(tile.get_temperature());
    info.push(tile.sharing_coefficent.get());
    info.push(tile.pressure());
    info.push(tile.get_thermal_energy());
    info.push(tile.conduction_coefficient.get() as f32);

    Ok(info)
}

#[byond_fn]
pub fn is_goonmos_fucked() -> bool {
    match GOONMOS.try_read() {
        Ok(_) => false,
        Err(_) => true,
    }
}

#[byond_fn]
pub fn tick_zlevel(z: ByondValue) -> ByondResult<f32> {
    let z = z.get_number()? as usize - 1;
    let time = std::time::Instant::now();
    GOONMOS.read().unwrap().process_zlevel(z);
    Ok(time.elapsed().as_micros() as f32 / 1000.0)
}
