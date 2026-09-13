use crate::defines::*;
use crate::types::*;
use crate::world::*;
use grid::Grid;
use rayon::prelude::*;

pub(crate) struct Zlevel {
    pub(crate) tiles: Grid<Tile>,
}

impl Zlevel {
    pub(crate) fn new(maxx: usize, maxy: usize) -> Self {
        Self {
            tiles: Grid::new(maxx as usize, maxy as usize),
        }
    }

    pub(crate) fn set_size(&mut self, maxx: usize, maxy: usize) {
        if maxx > self.tiles.cols() {
            let diff = maxx - self.tiles.cols();
            self.tiles.expand_cols(diff)
        } else if maxx < self.tiles.cols() {
            let diff = self.tiles.cols() - maxx;
            (0..diff).for_each(|_| {
                self.tiles.delete_col(self.tiles.cols() - 1);
            });
        }

        if maxy > self.tiles.rows() {
            let diff = maxx - self.tiles.rows();
            self.tiles.expand_rows(diff)
        } else if maxy < self.tiles.rows() {
            let diff = self.tiles.rows() - maxx;
            (0..diff).for_each(|_| {
                self.tiles.delete_col(self.tiles.cols() - 1);
            });
        }
    }

    pub(crate) fn try_get_coords(&self, x: usize, y: usize) -> Option<&Tile> {
        self.tiles.get(x, y)
    }

    pub(crate) fn precalculate_values(
        &self,
        low_x: usize,
        low_y: usize,
        high_x: usize,
        high_y: usize,
    ) {
        self.tiles
            .flatten()
            .par_iter()
            .enumerate()
            .filter_map(|(idx, tile)| {
                let row = idx / self.tiles.cols();
                let col = idx % self.tiles.cols();
                if (low_x..=high_x).contains(&row) && (low_y..=high_y).contains(&col) {
                    Some((row, col, tile))
                } else {
                    None
                }
            })
            .for_each(|(row, col, tile)| {
                let mut count = 1.0;
                if let TileStatus::Exposed(_) = tile.status.get() {
                    count += 1.0
                }
                if self
                    .try_get_coords(row, col + 1)
                    .is_some_and(|neighbor| !neighbor.wall.get())
                {
                    count += 1.0;
                }
                if self
                    .try_get_coords(row + 1, col)
                    .is_some_and(|neighbor| !neighbor.wall.get())
                {
                    count += 1.0;
                }
                if col > 0
                    && self
                        .try_get_coords(row, col - 1)
                        .is_some_and(|neighbor| !neighbor.wall.get())
                {
                    count += 1.0;
                }
                if row > 0
                    && self
                        .try_get_coords(row - 1, col)
                        .is_some_and(|neighbor| !neighbor.wall.get())
                {
                    count += 1.0;
                }

                tile.sharing_coefficent.replace(1.0 / count);
            });
    }

    pub(crate) fn set_wall(&self, row: usize, col: usize, wall: bool) {
        let tile = self.try_get_coords(row, col).unwrap();
        if tile.wall.get() == wall {
            return;
        }
        tile.wall.replace(wall);
        let change = if wall { -1.0 } else { 1.0 };

        let update_sharer = |neighbor: &Tile| {
            let old = (1.0 / neighbor.sharing_coefficent.get()).round();
            neighbor.sharing_coefficent.replace(1.0 / (old + change));
            Some(())
        };

        self.try_get_coords(row, col + 1).and_then(update_sharer);
        self.try_get_coords(row + 1, col).and_then(update_sharer);
        if col > 0 {
            self.try_get_coords(row, col - 1).and_then(update_sharer);
        }
        if row > 0 {
            self.try_get_coords(row - 1, col).and_then(update_sharer);
        }

        if wall {
            tile.gas.zero_out();
            tile.hotspot_temperature.replace(0.0);
            tile.hotspot_volume.replace(0.0);
        }
    }

    pub(crate) fn process_flow(&self) -> Vec<((u16, u16), (u8, f32))> {
        let deltas: Grid<GasMixtureDelta> = Grid::new(self.tiles.rows(), self.tiles.cols());

        let moving_tiles = self
            .tiles
            .flatten()
            .par_iter()
            .enumerate()
            .map(|(idx, tile)| (idx / self.tiles.cols(), idx % self.tiles.cols(), tile))
            .filter_map(|(row, col, tile)| {
                if !(tile.wall.get()
                    || matches!(
                        tile.status.get(),
                        TileStatus::Immutable | TileStatus::Sealed
                    ))
                {
                    let our_coeff = tile.sharing_coefficent.get();
                    let mut delta_ps: (f32, f32) = Default::default();

                    if let TileStatus::Exposed(idx) = tile.status.get()
                        && let Some(environment) =
                            GOONMOS.read().unwrap().try_get_environment(idx as usize)
                        && let Some((delta, _)) = tile.share(&environment, our_coeff, 0.5)
                    {
                        deltas[(row, col)].subtract(&delta);
                    }

                    if let Some(neighbor) = self.try_get_coords(row, col + 1)
                        && let Some((delta, delta_p)) =
                            tile.share(neighbor, our_coeff, neighbor.sharing_coefficent.get())
                    {
                        deltas[(row, col)].subtract(&delta);
                        delta_ps.1 += delta_p;
                    }

                    if let Some(neighbor) = self.try_get_coords(row + 1, col)
                        && let Some((delta, delta_p)) =
                            tile.share(neighbor, our_coeff, neighbor.sharing_coefficent.get())
                    {
                        deltas[(row, col)].subtract(&delta);
                        delta_ps.0 += delta_p;
                    }

                    if col > 0 {
                        if let Some(neighbor) = self.try_get_coords(row, col - 1)
                            && let Some((delta, delta_p)) =
                                tile.share(neighbor, our_coeff, neighbor.sharing_coefficent.get())
                        {
                            deltas[(row, col)].subtract(&delta);
                            delta_ps.1 -= delta_p;
                        }
                    }

                    if row > 0 {
                        if let Some(neighbor) = self.try_get_coords(row - 1, col)
                            && let Some((delta, delta_p)) =
                                tile.share(neighbor, our_coeff, neighbor.sharing_coefficent.get())
                        {
                            deltas[(row, col)].subtract(&delta);
                            delta_ps.0 -= delta_p;
                        }
                    }

                    if delta_ps.0.abs() < MINIMUM_DELTA_PRESSURE
                        && delta_ps.1.abs() < MINIMUM_DELTA_PRESSURE
                    {
                        None
                    } else {
                        let (dir, pressure) = if delta_ps.0.abs() > delta_ps.1.abs() {
                            if delta_ps.0 > 0.0 {
                                (4, delta_ps.0.abs())
                            } else {
                                (8, delta_ps.0.abs())
                            }
                        } else {
                            if delta_ps.1 > 0.0 {
                                (1, delta_ps.1.abs())
                            } else {
                                (2, delta_ps.1.abs())
                            }
                        };
                        Some(((row as u16, col as u16), (dir, pressure)))
                    }
                } else {
                    None
                }
            })
            .collect::<Vec<((u16, u16), (u8, f32))>>();

        self.tiles
            .flatten()
            .par_iter()
            .zip(deltas.flatten())
            .for_each(|(grid, delta)| match grid.status.get() {
                TileStatus::Sealed => (),
                TileStatus::Immutable => (),
                _ => {
                    if !grid.wall.get() {
                        grid.apply(delta);
                        grid.check_superconduction(true);
                    }
                }
            });

        moving_tiles
    }

    fn process_reactions(&self) -> Vec<usize> {
        self.tiles
            .flatten()
            .par_iter()
            .enumerate()
            .filter_map(|(index, tile)| if tile.react() { Some(index) } else { None })
            .collect::<Vec<usize>>()
    }

    fn process_superconduction(&self) {
        let deltas: Grid<TrustMe<f32>> = Grid::new(self.tiles.rows(), self.tiles.cols());

        self.tiles
            .flatten()
            .par_iter()
            .enumerate()
            .map(|(idx, tile)| (idx / self.tiles.cols(), idx % self.tiles.cols(), tile))
            .filter(|(row, col, _)| (row + col) % 2 == 0)
            .for_each(|(row, col, tile)| {
                if tile.superconducting.get() {
                    let wall = tile.wall.get();
                    let mut our_heat_delta = deltas[(row, col)].get();
                    let our_coefficient = tile.conduction_coefficient.get() as f32;

                    let up = self.try_get_coords(row, col + 1);
                    if let Some(neighbor) = up
                        && (wall || neighbor.wall.get())
                        && neighbor.status.get() != TileStatus::Sealed
                    {
                        let delta = tile.temperature_share(
                            neighbor,
                            (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                / 120.0,
                        );
                        our_heat_delta -= delta;
                        deltas[(row, col + 1)].replace(deltas[(row, col + 1)].get() + delta);
                    }

                    let right = self.try_get_coords(row + 1, col);
                    if let Some(neighbor) = right
                        && (wall || neighbor.wall.get())
                        && neighbor.status.get() != TileStatus::Sealed
                    {
                        let delta = tile.temperature_share(
                            neighbor,
                            (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                / 120.0,
                        );
                        our_heat_delta -= delta;
                        deltas[(row + 1, col)].replace(deltas[(row + 1, col)].get() + delta);
                    }

                    if col > 0 {
                        let down = self.try_get_coords(row, col - 1);
                        if let Some(neighbor) = down
                            && (wall || neighbor.wall.get())
                            && neighbor.status.get() != TileStatus::Sealed
                        {
                            let delta = tile.temperature_share(
                                neighbor,
                                (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                            our_heat_delta -= delta;
                            deltas[(row, col - 1)].replace(deltas[(row, col - 1)].get() + delta);
                        }
                    }

                    if row > 0 {
                        let left = self.try_get_coords(row - 1, col);
                        if let Some(neighbor) = left
                            && (wall || neighbor.wall.get())
                            && neighbor.status.get() != TileStatus::Sealed
                        {
                            let delta = tile.temperature_share(
                                neighbor,
                                (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                            our_heat_delta -= delta;
                            deltas[(row - 1, col)].replace(deltas[(row - 1, col)].get() + delta);
                        }
                    }

                    if tile.get_temperature() > T_0C {
                        if let TileStatus::Exposed(idx) = tile.status.get()
                            && let Some(environment) =
                                GOONMOS.read().unwrap().try_get_environment(idx as usize)
                            && (wall || environment.wall.get())
                        {
                            our_heat_delta -= tile.temperature_share(
                                &environment,
                                (our_coefficient + environment.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                        } else {
                            our_heat_delta -= tile.temperature_expose(
                                T_CMB,
                                7.0,
                                (our_coefficient + 1.0) / 120.0,
                            );
                        }
                    }

                    deltas[(row, col)].replace(our_heat_delta);
                }
            });

        self.tiles
            .flatten()
            .par_iter()
            .enumerate()
            .map(|(idx, tile)| (idx / self.tiles.cols(), idx % self.tiles.cols(), tile))
            .filter(|(row, col, _)| (row + col) % 2 == 1)
            .for_each(|(row, col, tile)| {
                if tile.superconducting.get() {
                    let wall = tile.wall.get();
                    let mut our_heat_delta = deltas[(row, col)].get();
                    let our_coefficient = tile.conduction_coefficient.get() as f32;

                    let up = self.try_get_coords(row, col + 1);
                    if let Some(neighbor) = up
                        && (wall || neighbor.wall.get())
                        && neighbor.status.get() != TileStatus::Sealed
                    {
                        let delta = tile.temperature_share(
                            neighbor,
                            (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                / 120.0,
                        );
                        our_heat_delta -= delta;
                        deltas[(row, col + 1)].replace(deltas[(row, col + 1)].get() + delta);
                    }

                    let right = self.try_get_coords(row + 1, col);
                    if let Some(neighbor) = right
                        && (wall || neighbor.wall.get())
                        && neighbor.status.get() != TileStatus::Sealed
                    {
                        let delta = tile.temperature_share(
                            neighbor,
                            (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                / 120.0,
                        );
                        our_heat_delta -= delta;
                        deltas[(row + 1, col)].replace(deltas[(row + 1, col)].get() + delta);
                    }

                    if col > 0 {
                        let down = self.try_get_coords(row, col - 1);
                        if let Some(neighbor) = down
                            && (wall || neighbor.wall.get())
                            && neighbor.status.get() != TileStatus::Sealed
                        {
                            let delta = tile.temperature_share(
                                neighbor,
                                (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                            our_heat_delta -= delta;
                            deltas[(row, col - 1)].replace(deltas[(row, col - 1)].get() + delta);
                        }
                    }

                    if row > 0 {
                        let left = self.try_get_coords(row - 1, col);
                        if let Some(neighbor) = left
                            && (wall || neighbor.wall.get())
                            && neighbor.status.get() != TileStatus::Sealed
                        {
                            let delta = tile.temperature_share(
                                neighbor,
                                (our_coefficient + neighbor.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                            our_heat_delta -= delta;
                            deltas[(row - 1, col)].replace(deltas[(row - 1, col)].get() + delta);
                        }
                    }

                    if tile.get_temperature() > T_0C {
                        if let TileStatus::Exposed(idx) = tile.status.get()
                            && let Some(environment) =
                                GOONMOS.read().unwrap().try_get_environment(idx as usize)
                            && (wall || environment.wall.get())
                        {
                            our_heat_delta -= tile.temperature_share(
                                &environment,
                                (our_coefficient + environment.conduction_coefficient.get() as f32)
                                    / 120.0,
                            );
                        } else {
                            our_heat_delta -= tile.temperature_expose(
                                T_CMB,
                                7.0,
                                (our_coefficient + 1.0) / 120.0,
                            );
                        }
                    }

                    deltas[(row, col)].replace(our_heat_delta);
                }
            });

        self.tiles
            .flatten()
            .par_iter()
            .zip(deltas.flatten())
            .for_each(|(tile, delta)| match tile.status.get() {
                TileStatus::Immutable => (),
                TileStatus::Sealed => (),
                _ => {
                    tile.change_thermal_energy(delta.get());
                    tile.check_superconduction(true);
                }
            });
    }

    pub(crate) fn tick(&self) -> (Vec<((u16, u16), (u8, f32))>, Vec<usize>) {
        let fires = self.process_reactions();
        let movement = self.process_flow();
        self.process_superconduction();
        (movement, fires)
    }
}
