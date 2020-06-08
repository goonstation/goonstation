/*
Should mirror stuff done in FEA_turf_tile
*/

obj
	movable/floor

		New()
			..()

			#define _MOVABLE_TILE_COPY_AIR(GAS, ...) air.GAS = GAS;
			APPLY_TO_GASES(_MOVABLE_TILE_COPY_AIR)
			#undef _MOVABLE_TILE_COPY_AIR

			air.temperature = temperature

		assume_air(datum/gas_mixture/giver)
			if(parent&&parent.group_processing)
				if(!parent.air.check_then_merge(giver))
					parent.suspend_group_processing()
					air.merge(giver)
			else
				air.merge(giver)

			return 1

		archive()
			air.archive()

			archived_cycle = air_master.current_cycle

		share_air_with_tile(turf/simulated/sharer)
			air.share(sharer.air)

		mimic_air_with_tile(turf/model)
			air.mimic(model)

		return_air()
			if(parent&&parent.group_processing)
				return parent.air
			else return air

		remove_air(amount as num)
			var/datum/gas_mixture/removed = null

			if(parent&&parent.group_processing)
				removed = parent.air.check_then_remove(amount)
				if(!removed)
					parent.suspend_group_processing()
					removed = air.remove(amount)
			else
				removed = air.remove(amount)

			return removed

		update_air_properties()//OPTIMIZE
			air_check_directions = 0

			for(var/direction in cardinal)
				if(loc.CanPass(null, get_step(loc,direction), 0, 0))
					air_check_directions |= direction

			if(parent)
				if(parent.borders)
					parent.borders -= src

				group_border = 0
				for(var/direction in cardinal)
					if(air_check_directions&direction)
						var/turf/T = get_step(src,direction)
						var/obj/movable/floor/O = locate(/obj/movable/floor) in T
						if(!istype(O) || (O.parent!=parent))
							if(parent.borders)
								parent.borders -= src
								parent.borders += src
							else
								parent.borders = list(src)
							group_border |= direction

			if(air_check_directions)
				processing = 1
				if(!parent)
					air_master.add_singleton(src)
			else
				processing = 0

		process_cell()
			if(processing)
				if(archived_cycle < air_master.current_cycle) //archive self if not already done
					archive()
				current_cycle = air_master.current_cycle

				for(var/direction in cardinal)
					if(air_check_directions&direction) //Grab all valid bordering tiles
						var/turf/simulated/enemy_tile = get_step(src, direction)
						var/obj/movable/floor/movable_on_enemy = locate(/obj/movable/floor) in enemy_tile
						if(movable_on_enemy)
							if(movable_on_enemy.archived_cycle < archived_cycle) //archive bordering tile information if not already done
								movable_on_enemy.archive()
							if(movable_on_enemy.parent && movable_on_enemy.parent.group_processing) //apply tile to group sharing
								if(movable_on_enemy.parent.current_cycle < current_cycle)
									if(movable_on_enemy.parent.air.check_gas_mixture(air))
										air.share(movable_on_enemy.parent.air)
									else
										movable_on_enemy.parent.suspend_group_processing()
										air.share(movable_on_enemy.air)
										//group processing failed so interact with individual tile
							else
								if(movable_on_enemy.current_cycle < current_cycle)
									share_air_with_tile(movable_on_enemy)
						else
							if(istype(enemy_tile))
								if(enemy_tile.archived_cycle < archived_cycle) //archive bordering tile information if not already done
									enemy_tile.archive()
								if(enemy_tile.parent && enemy_tile.parent.group_processing) //apply tile to group sharing
									if(enemy_tile.parent.current_cycle < current_cycle)
										if(enemy_tile.parent.air.check_gas_mixture(air))
											air.share(enemy_tile.parent.air)
										else
											enemy_tile.parent.suspend_group_processing()
											air.share(enemy_tile.air)
											//group processing failed so interact with individual tile
								else
									if(enemy_tile.current_cycle < current_cycle)
										share_air_with_tile(enemy_tile)
							else
								mimic_air_with_tile(enemy_tile) //bordering a tile with fixed air properties

				return 1
			else
				air_master.active_singletons -= src //not active if not processing!
			return 0
