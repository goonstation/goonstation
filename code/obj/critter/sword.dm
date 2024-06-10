#define SWORD_ATTACKING_RANGE 4
/* ================================================== */
/* --- Syndicate Weapon: Orion Retribution Device --- */
/* ================================================== */

/obj/critter/sword
	name = "Deep Space Beacon"
	var/transformation_name = "Syndicate Locator Beacon"
	var/true_name = "Syndicate Weapon: Orion Retribution Device"
	desc = "A huge beacon, seemingly constructed for broadcasting long-range signals."
	var/transformation_desc = "A huge beacon, seemingly constructed for baiting Nanotrasen personnel into thinking it's just a beacon."
	var/true_desc = "An automated miniature doomsday device constructed by the Syndicate."
	icon = 'icons/misc/retribution/SWORD/base.dmi'
	icon_state = "beacon"
	dead_state = "anchored"
	death_text = "The Syndicate Weapon stops moving, leaving wreckage in it's wake."
	pet_text = "tries to get the attention of"
	angertext = "focuses on"
	atk_text = "bumps into"
	chase_text = "chases after"
	crit_text = "slams into"
	alpha = 0
	atk_delay = 50
	crit_chance = 25
	health = 5400
	bound_height = 96
	bound_width = 96
	layer = MOB_LAYER + 5
	atkcarbon = 1
	atksilicon = 1
	flying = 1
	generic = 0
	///A perk of being a high-tech prototype - large detection range.
	seekrange = 128
	///0 - Beacon. 1 - Unanchored. 2 - Anchored.
	var/mode = 0
	///Used to prevent the SWORD from using abilities all the time.
	var/cooldown = 0
	///Used to only allow transforming after at least one ability has been used.
	var/used_ability = 0
	///Used to keep track of the SWORD's heat for Heat Reallocation.
	var/current_heat_level = 0
	///Used to check if the initial transformation has already been started or not.
	var/transformation_triggered = FALSE
	///Used to lock the SWORD's rotation in place. Or, at the very least, attempt to.
	var/rotation_locked = FALSE
	///Used to prevent some things during transformation sequences.
	var/changing_modes = FALSE
	///Used to prevent spam-reporting the death of the SWORD.
	var/died_already = FALSE
	///Used to prevent the SWORD from using Destructive Leap/Destructive Flight in the same direction twice in a row, at a 75% efficiency.
	var/past_destructive_rotation = null
	///Used to keep track of what ability the SWORD is currently using.
	var/current_ability = null
	///Used to prevent the SWORD from getting stuck too much.
	var/stuck_location = null
	///Used to prevent the SWORD from getting stuck too much.
	var/stuck_timer = null
	///The glow overlay.
	var/image/glow

	New()
		..()
		anchored = ANCHORED
		firevuln = 0
		brutevuln = 0
		miscvuln = 0

		step(src, 2)	//Spawn location correction.
		step(src, 8)	//Ditto.

		var/increment
		for(increment in 0 to 14)
			SPAWN(increment)
				src.alpha += 17

		SPAWN(rand(15, 30) SECONDS)
			src.alpha = 255
			if(mode == 0 && !changing_modes && !transformation_triggered)	//If in Beacon form and not already transforming...
				transformation_countdown()									//...the countdown starts.
		return

	CritterDeath()
		..()
		if (!died_already)
			died_already = TRUE
			SPAWN(5 SECONDS)
				command_announcement("<br><b>[SPAN_ALERT("The Syndicate Weapon has been eliminated.")]</b>", "Safety Update", 'sound/misc/announcement_1.ogg')
				logTheThing(LOG_COMBAT, src, "has been defeated.")
				message_admins("The Syndicate Weapon: Orion Retribution Device has been defeated.")

			playsound(src, 'sound/effects/ship_engage.ogg', 100, TRUE)

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			var/death_loc = get_center()
			var/death_loc_x = src.loc.x + 1
			var/death_loc_y = src.loc.y + 1
			var/death_loc_z = src.loc.z

			smoke.set_up(rand(12, 15), 0, death_loc)
			smoke.start()

			SPAWN(45)
				explosion_new(death_loc, death_loc, rand(6, 12))
				fireflash(death_loc, 2, chemfire = CHEM_FIRE_RED)

			SPAWN(50)
				for(var/board_count = rand(4, 8), board_count > 0, board_count--)
					new/obj/item/factionrep/ntboard(locate(death_loc_x + rand(-2, 2), death_loc_y + rand(-2, 2), death_loc_z))
					board_count--

			SPAWN(55)
				for(var/alloy_count = rand(2, 4), alloy_count > 0, alloy_count--)
					new/obj/item/material_piece/iridiumalloy(locate(death_loc_x + rand(-1, 1), death_loc_y + rand(-1, 1), death_loc_z))
					alloy_count--

			SPAWN(60)
				new/obj/machinery/power/sword_engine(locate(death_loc_x, death_loc_y, death_loc_z))

			SPAWN(65)
				elecflash(death_loc)
				qdel(src)

	process()
		anchored = ANCHORED
		if (!src.alive) return 0

		if(sleeping > 0)
			sleeping--
			return 0

		check_health()

		if(prob(5))
			playsound(src, 'sound/machines/giantdrone_boop1.ogg', 55, TRUE)

		if(task == "following path" && mode)
			follow_path()
		else if(task == "sleeping" && mode)
			var/waking = 0

			for (var/client/C)
				var/mob/living/M = C.mob
				if (isintangible(M)) continue
				if (IN_RANGE(src, M, 64))
					if (!isdead(M))
						waking = 1
						break

			for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
				var/atom/A = atom
				if (IN_RANGE(src, A, 64))
					waking = 1
					break

			if(waking)
				task = "thinking"
			else
				sleeping = 5
				return 0
		else if(sleep_check <= 0 && mode)
			sleep_check = 5

			var/stay_awake = 0

			if(src.target) stay_awake = TRUE
			for (var/client/C)
				var/mob/living/M = C.mob
				if (isintangible(M)) continue
				if (IN_RANGE(src, M, seekrange))
					if (!isdead(M))
						stay_awake = 1
						break

			for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
				var/atom/A = atom
				if (IN_RANGE(src, A, 32))
					stay_awake = 1
					break

			if(!stay_awake)
				sleeping = 5
				task = "sleeping"
				return 0

		else
			sleep_check--

		return ai_think()

	filter_target(var/mob/living/M)
		return is_valid_target(M)

	ai_think()
		if(mode)
			switch(task)
				if("thinking")
					src.attack = 0
					src.target = null

					walk_to(src,0)
					seek_target()
					if (!src.target) src.task = "wandering"
				if("chasing")
					if (src.frustration >= rand(16,32) || !is_valid_target(src.target))
						clear_target()
						src.task = "thinking"
						walk_to(src,0)
					if (src.target)
						if (IN_RANGE(get_center(), src.target, SWORD_ATTACKING_RANGE))
							var/mob/living/M = src.target
							if (M)
								if(!src.attacking) ChaseAttack(M)
								src.task = "attacking"
								src.target_lastloc = M.loc

						else
							if(!stuck_timer)
								stuck_timer = 12 SECONDS + TIME
								stuck_location = get_center()

							if(stuck_timer <= TIME && stuck_location == get_center())
								cooldown = 4 SECONDS + TIME
								stuck_timer = null
								for(var/stuck_increment in 1 to 3)
									SPAWN(stuck_increment SECONDS)
										for (var/turf/simulated/OV in oview(get_center(),stuck_increment))
											tile_purge(OV.loc.x,OV.loc.y,3)

							for (var/turf/simulated/wall/WT in range(2,get_center()))
								if(IS_ARRIVALS(WT.loc)) continue
								leavescan(WT, 1)
								new /obj/item/raw_material/scrap_metal(WT)
								if(prob(50))
									WT.ReplaceWithLattice()
								else
									WT.ReplaceWithSpace()

							var/turf/olddist = GET_DIST(src, src.target)
							walk_to(src, src.target,1,5)
							SPAWN(5 DECI SECOND)
								if ((GET_DIST(src, src.target)) >= (olddist))
									src.frustration++
									if(src.z == get_step(src.target, 0).z)
										step_towards(src, src.target)
								else
									src.frustration = 0

							ability_selection()

					else src.task = "thinking"
				if("attacking")
					if(!is_valid_target(src.target))
						src.task = "thinking"
						src.attacking = 0
					else if (!IN_RANGE(get_center(), src.target, SWORD_ATTACKING_RANGE) || (src.target:loc != src.target_lastloc))
						src.task = "chasing"
					else if (IN_RANGE(get_center(), src.target, SWORD_ATTACKING_RANGE))
						var/mob/living/carbon/M = src.target
						if (!src.attacking) CritterAttack(src.target)
						if(M != null)
							if (M.health <= 0)
								clear_target()
								src.task = "thinking"
								src.attacking = 0
							else
								ability_selection()
					else
						src.attacking = 0
						src.task = "chasing"
				if("wandering")
					patrol_step()
		return 1


//-ABILITY SELECTION-//

	proc/ability_selection()
		if(cooldown <= TIME && mode && !current_ability && !changing_modes)
			cooldown = rand(20,30) + TIME
			if(prob(36) && used_ability)
				used_ability = 0
				configuration_swap()
			else
				switch(task)
					if("chasing")
						used_ability = 1
						current_heat_level = current_heat_level + 20
						if(mode == 1)						//Unanchored.
							destructive_flight()
						else								//Anchored.
							if (prob(32) && IN_RANGE(src, src.target, 9))
								linear_purge()
							else
								destructive_leap()

					if("attacking")
						used_ability = 1
						current_heat_level = current_heat_level + 20
						if(prob(20))
							stifling_vacuum()
						else if(mode == 1)					//Unanchored.
							if(current_heat_level > 100)
								current_heat_level = 100
							if(prob(current_heat_level))
								heat_reallocation()
							else
								energy_absorption()
						else								//Anchored.
							if(prob(48))
								linear_purge()
							else
								gyrating_edge()
			anchored = ANCHORED


//-TRANSFORMATIONS-//

	proc/transformation(var/transformation_id)				//0 - Beacon. 1 - Unanchored. 2 - Anchored.
		firevuln = 1.25
		brutevuln = 1.25
		miscvuln = 0.25
		current_ability = "transformation"

		switch(transformation_id)
			if(0)
				rotation_locked = TRUE
				changing_modes = TRUE
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "beacon"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "beacon")
				glow.plane = PLANE_SELFILLUM
				src.UpdateOverlays(glow, "glow")
				SPAWN(18)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "unanchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
					glow.plane = PLANE_SELFILLUM
					src.UpdateOverlays(glow, "glow")
					changing_modes = FALSE
					rotation_locked = FALSE
					name = true_name
					desc = true_desc
					aggressive = 1							//Only after exiting the beacon form will the SWORD become aggressive.
					health = 6000
					mode = 1

			if(1)
				rotation_locked = TRUE
				changing_modes = TRUE
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "anchored"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "anchored")
				glow.plane = PLANE_SELFILLUM
				src.UpdateOverlays(glow, "glow")
				SPAWN(11)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "unanchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
					glow.plane = PLANE_SELFILLUM
					src.UpdateOverlays(glow, "glow")
					changing_modes = FALSE
					rotation_locked = FALSE
					mode = 1

			else
				rotation_locked = TRUE
				changing_modes = TRUE
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "unanchored"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "unanchored")
				glow.plane = PLANE_SELFILLUM
				src.UpdateOverlays(glow, "glow")
				SPAWN(11)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "anchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
					glow.plane = PLANE_SELFILLUM
					src.UpdateOverlays(glow, "glow")
					changing_modes = FALSE
					rotation_locked = FALSE
					mode = 2

		SPAWN(10)
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null
		return


//-GENERAL ABILITIES-//

	proc/configuration_swap()								//Swaps between anchored and unanchored forms, if possible.
		if(mode == 0)
			return

//		var/pathable_turfs = 0
//		for (var/turf/T in range(1, get_center()))
//			if (T && (T.pathable || istype(T, /turf/space)))
//				pathable_turfs++

		if(mode == 1)
			transformation(2)
			return

		else
			if(mode == 2)
				transformation(1)
				return


	proc/stifling_vacuum()									//In a T-shape in front of it, trips and attracts closer all mobs affected.
		current_ability = "stifling_vacuum"
		walk_towards(src, src.target)
		walk(src,0)
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "stiflingVacuum")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")
		SPAWN(4)
			var/increment
			switch (src.dir)
				if (1)	//N
					var/turf/T = locate(src.loc.x + 1,src.loc.y + 3,src.loc.z)
					for (var/mob/living/M in T)
						if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("knockdown", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/living/M in locate(src.loc.x + 1 + increment,src.loc.y + 4,src.loc.z))
							if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("knockdown", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (4)	//E
					var/turf/T = locate(src.loc.x + 3,src.loc.y + 1,src.loc.z)
					for (var/mob/living/M in T)
						if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("knockdown", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/living/M in locate(src.loc.x + 4,src.loc.y + 1 + increment,src.loc.z))
							if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("knockdown", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (2)	//S
					var/turf/T = locate(src.loc.x + 1,src.loc.y - 1,src.loc.z)
					for (var/mob/living/M in T)
						if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("knockdown", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/living/M in locate(src.loc.x + 1 + increment,src.loc.y - 2,src.loc.z))
							if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("knockdown", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (8)	//W
					var/turf/T = locate(src.loc.x - 1,src.loc.y + 1,src.loc.z)
					for (var/mob/living/M in T)
						if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("knockdown", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/living/M in locate(src.loc.x - 2,src.loc.y + 1 + increment,src.loc.z))
							if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("knockdown", 4 SECONDS)
							M.throw_at(T, 3, 1)

		SPAWN(8)
			if(mode == 1)
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			else
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			current_ability = null
		return


//-ANCHORED ABILITIES-//

	proc/linear_purge()										//After 1.5 seconds, unleashes a destructive beam.
		firevuln = 1.5
		brutevuln = 1.5
		miscvuln = 0.4
		current_ability = "linear_purge"

		walk_towards(src, src.target)
		walk(src,0)
		playsound(get_center(), 'sound/weapons/heavyioncharge.ogg', 75, 1)

		var/increment
		var/turf/T

		switch (src.dir)
			if (1)	//N
				for(increment in 2 to 9)
					T = locate(src.loc.x,src.loc.y + increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1,src.loc.y + 1 + increment,0)

			if (4)	//E
				for(increment in 2 to 9)
					T = locate(src.loc.x + increment,src.loc.y,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1 + increment,src.loc.y + 1,0)

			if (2)	//S
				for(increment in 2 to 9)
					T = locate(src.loc.x,src.loc.y - increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1,src.loc.y + 1 - increment,0)

			if (8)	//W
				for(increment in 2 to 9)
					T = locate(src.loc.x - increment,src.loc.y,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1 - increment,src.loc.y + 1,0)

		SPAWN(10)
			rotation_locked = TRUE

		SPAWN(20)
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


	proc/gyrating_edge()									//Spins, dealing mediocre damage to anyone nearby.
		rotation_locked = TRUE
		firevuln = 0.5
		brutevuln = 0.5
		miscvuln = 0.1
		current_ability = "gyrating_edge"

		var/spin_dir = prob(50) ? "L" : "R"
		animate_spin(src, spin_dir, 5, 0)
		playsound(get_center(), 'sound/effects/flameswoosh.ogg', 60, 1)
		if(spin_dir == "L")
			glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "gyratingEdge_L")
		else
			glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "gyratingEdge_R")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")

		SPAWN(0.5 SECONDS)
			animate_spin(src, spin_dir, 5, 0)

		SPAWN(1 SECOND)
			for (var/mob/living/M in range(5,get_center()))
				if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_brute_damage(M, 16)
				random_burn_damage(M, 16)

			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


	proc/destructive_leap()									//Leaps at the target using it's thrusters, dealing damage at the landing location and probably gibbing anyone at the center of said location.
		walk_towards(src, src.target)
		walk(src,0)
		for (var/mob/B in range(3,get_center()))
			random_burn_damage(B, 30)
			B.changeStatus("burning", 3 SECONDS)
		icon = 'icons/misc/retribution/SWORD/abilities.dmi'
		icon_state = "destructiveLeap"
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "destructive")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")
		rotation_locked = TRUE
		firevuln = 0.75
		brutevuln = 0.75
		miscvuln = 0.15
		current_ability = "destructive_leap"
		playsound(get_center(), 'sound/effects/flame.ogg', 80, 1)

		SPAWN(2)
			if(past_destructive_rotation == src.dir)
				src.dir = pick(1,2,4,8)
			for(var/i in 0 to 7)
				step(src, src.dir)
				if(i <= 3)
					src.alpha -= 17
					src.pixel_y += 4
				else
					src.alpha += 17
					src.pixel_y -= 4
				sleep(5)
			for (var/mob/living/M in range(3,get_center()))
				if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_brute_damage(M, 60)
			tile_purge(src.loc.x + 1,src.loc.y + 1,1)
			for (var/mob/living/M in get_center())
				if (isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				if(prob(69))								//Nice.
					logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
					M.gib()
				else
					random_brute_damage(M, 120)
			past_destructive_rotation = src.dir

		SPAWN(10)
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "anchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


//-UNANCHORED ABILITIES-//

	proc/heat_reallocation()								//Sets anyone nearby on fire while dealing increasing burning damage.
		rotation_locked = TRUE
		firevuln = 1.25
		brutevuln = 1.25
		miscvuln = 0.25
		current_ability = "heat_reallocation"

		playsound(get_center(), 'sound/effects/gust.ogg', 60, 1)
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "heatReallocation")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")

		SPAWN(0.2 SECONDS)
			for (var/mob/living/M in range(3,get_center()))
				if(isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_burn_damage(M, (current_heat_level / 5))
				M.changeStatus("burning", 4 SECONDS)

		SPAWN(0.4 SECONDS)
			for (var/mob/living/M in range(3,get_center()))
				if(isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_burn_damage(M, (current_heat_level / 4))
				M.changeStatus("burning", 6 SECONDS)

		SPAWN(0.6 SECONDS)
			for (var/mob/living/M in range(3,get_center()))
				if(isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_burn_damage(M, (current_heat_level / 3))
				M.changeStatus("burning", 8 SECONDS)

		SPAWN(0.8 SECONDS)
			current_heat_level = 0
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


	proc/energy_absorption()								//Becomes immune to burn damage for the duration. Creates a snapshot of it's health during activation, returning to it after 1.2 seconds. Increases the heat value by damage taken during the duration.
		rotation_locked = TRUE
		firevuln = 0
		brutevuln = 1.25
		miscvuln = 0.25
		current_ability = "energy_absorption"

		var/health_before_absorption = health
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "energyAbsorption")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")

		SPAWN(1.2 SECONDS)
			if(health_before_absorption > health)
				current_heat_level = current_heat_level + health_before_absorption - health
				health = health_before_absorption

			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


	proc/destructive_flight()								//Charges at the target using it's thrusters twice, dealing damage at the locations of each one's end.
		walk_towards(src, src.target)
		walk(src,0)
		for (var/mob/B in range(3,get_center()))
			if(IS_ARRIVALS(get_area(B))) continue
			random_burn_damage(B, 30)
		icon = 'icons/misc/retribution/SWORD/abilities.dmi'
		icon_state = "destructiveFlight"
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "destructive")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")
		rotation_locked = TRUE
		firevuln = 0.75
		brutevuln = 0.75
		miscvuln = 0.15
		current_ability = "destructive_flight"
		playsound(get_center(), 'sound/effects/flame.ogg', 80, 1)

		var/increment
		var/turf/T

		SPAWN(0)
			if(past_destructive_rotation == src.dir)
				src.dir = pick(cardinal)
			for(var/i in 1 to 8)
				switch (src.dir)
					if (NORTH)	//N
						for(increment in -1 to 1)
							T = locate(src.loc.x + 1 + increment,src.loc.y + 3,src.loc.z)
							if(T && prob(33))
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y + 3,0)

					if (EAST)	//E
						for(increment in -1 to 1)
							T = locate(src.loc.x + 3,src.loc.y + 1 + increment,src.loc.z)
							if(T && prob(33))
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 3,src.loc.y + 1 + increment,0)

					if (SOUTH)	//S
						for(increment in -1 to 1)
							T = locate(src.loc.x + 1 + increment,src.loc.y - 1,src.loc.z)
							if(T && prob(33))
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y - 1,0)

					if (WEST)	//W
						for(increment in -1 to 1)
							T = locate(src.loc.x - 1,src.loc.y + 1 + increment,src.loc.z)
							if(T && prob(33))
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x - 1,src.loc.y + 1 + increment,0)
				step(src, src.dir)
				sleep(0.1 SECONDS)
			for (var/mob/living/M in range(3,get_center()))
				if(isintangible(M) || IS_ARRIVALS(get_area(M))) continue
				random_brute_damage(M, 60)
			past_destructive_rotation = src.dir

		SPAWN(0.8 SECONDS)
			if(past_destructive_rotation == src.dir)
				src.dir = pick(cardinal)
			walk_towards(src, src.target)
			walk(src,0)
			for(var/l in 1 to 8)
				switch (src.dir)
					if (NORTH)	//N
						for(increment in -1 to 1)
							T = locate(src.loc.x + 1,src.loc.y + 3,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y + 3,0)

					if (EAST)	//E
						for(increment in -1 to 1)
							T = locate(src.loc.x + 3,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 3,src.loc.y + 1 + increment,0)

					if (SOUTH)	//S
						for(increment in -1 to 1)
							T = locate(src.loc.x + 1,src.loc.y - 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y - 1,0)

					if (WEST)	//W
						for(increment in -1 to 1)
							T = locate(src.loc.x - 1,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 70, 1)
								tile_purge(src.loc.x - 1,src.loc.y + 1 + increment,0)
				step(src, src.dir)
				sleep(0.1 SECONDS)
			for (var/mob/O in range(3,get_center()))
				random_brute_damage(O, 45)
			past_destructive_rotation = src.dir

		SPAWN(1.5 SECONDS)
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			glow.plane = PLANE_SELFILLUM
			src.UpdateOverlays(glow, "glow")
			rotation_locked = FALSE
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
			current_ability = null


//-MISCELLANEOUS-//

	proc/tile_purge(var/point_x, var/point_y, var/dam_type)	//A helper proc for Linear Purge, Destructive Leap and Destructive Flight.
		if(IS_ARRIVALS(get_area(locate(point_x,point_y,src.z)))) return

		for (var/mob/living/M in locate(point_x,point_y,src.z))
			if(isintangible(M)) continue
			if(!dam_type)
				if (isrobot(M))
					M.health = M.health * randfloat(0.1, 0.2)
				else
					random_burn_damage(M, 80)
				playsound(M.loc, 'sound/impact_sounds/burn_sizzle.ogg', 70, 1)
			else
				if (isrobot(M))
					M.health = M.health * randfloat(0.1 / dam_type, 0.2 / dam_type)
				else
					random_brute_damage(M, 80 / dam_type)
			M.changeStatus("knockdown", 4 SECOND)
			M.changeStatus("stunned", 1 SECOND)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), "scream")
		var/turf/simulated/T = locate(point_x,point_y,src.z)
		if(dam_type == 2 && istype(T, /turf/simulated/wall))
			leavescan(T, 1)
			fireflash(locate(point_x,point_y,src.z), 0, chemfire = CHEM_FIRE_RED)
			if(prob(64))
				new /obj/item/raw_material/scrap_metal(T)
				if(prob(32))
					new /obj/item/raw_material/scrap_metal(T)
			if(prob(50))
				T.ReplaceWithLattice()
			else
				T.ReplaceWithSpace()
		else
			if(T && prob(90) && !istype(T, /turf/space))
				new /obj/item/raw_material/scrap_metal(T)
				if(prob(48))
					new /obj/item/raw_material/scrap_metal(T)
				if(prob(32))
					T.ReplaceWithLattice()
				else
					T.ReplaceWithSpace()
			for (var/obj/S in locate(point_x,point_y,src.z))
				if(dam_type == 3 && !istype(S, /obj/critter))
					leavescan(get_turf(S), 1)
					fireflash(locate(point_x,point_y,src.z), 0, chemfire = CHEM_FIRE_RED)
					qdel(S)
				else if(prob(64) && !istype(S, /obj/critter))
					leavescan(get_turf(S), 1)
					fireflash(locate(point_x,point_y,src.z), 0, chemfire = CHEM_FIRE_RED)
					S.ex_act(1)
		return


	proc/transformation_countdown()							//Starts the initial transformation's countdown.
		transformation_triggered = TRUE
		name = transformation_name
		desc = transformation_desc
		glow = image('icons/misc/retribution/SWORD/base_o.dmi', "beacon")
		glow.plane = PLANE_SELFILLUM
		src.UpdateOverlays(glow, "glow")
		command_announcement("<br><b>[SPAN_ALERT("An unidentified long-range beacon has been detected near the station. Await further instructions.")]</b>", "Alert", 'sound/vox/alert.ogg')
		SPAWN(2 MINUTES)
			command_announcement("<br><b>[SPAN_ALERT("The station is under siege by the Syndicate-made object detected earlier. Survive any way possible.")]</b>", "Alert", 'sound/vox/alert.ogg')
			transformation(0)


	proc/get_center()										//Returns the central turf.
		var/turf/center_tile = get_step(get_turf(src), NORTHEAST)
		return center_tile

	proc/is_valid_target(var/target)
		var/mob/living/M = target
		if(!istype(M) || IS_ARRIVALS(get_area(M)))
			return FALSE
		return TRUE

	proc/clear_target()
		src.target = null
		src.last_found = TIME
		src.frustration = 0
		return

#undef SWORD_ATTACKING_RANGE
