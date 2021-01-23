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
	death_text = "The Syndicate Weapon violently explodes, leaving wreckage in it's wake."
	pet_text = "tries to get the attention of"
	angertext = "focuses on"
	atk_text = "bumps into"
	chase_text = "chases after"
	crit_text = "slams into"
	atk_delay = 50
	crit_chance = 25
	health = 6000
	bound_height = 96
	bound_width = 96
	layer = MOB_LAYER + 5
	atkcarbon = 1
	atksilicon = 1
	flying = 1
	generic = 0
	seekrange = 256						//A perk of being a high-tech prototype - incredibly large detection range.
	var/mode = 0						//0 - Beacon. 1 - Unanchored. 2 - Anchored.
	var/transformation_triggered = false//Used to check if the initial transformation has already been started or not.
	var/changing_modes = false			//Used to prevent some things during transformation sequences.
	var/rotation_locked = false			//Used to lock the SWORD's rotation in place, for example during transformations or in the second stage of Linear Purge.
	var/current_ability = null			//Used to keep track of what ability the SWORD is currently using.
	var/previous_ability = null			//Used to prevent using the same ability twice in a row.
	var/rotation_current = 0			//Used to keep track which of the 16 different orientations the SWORD is currently facing.
	var/current_heat_level = 0			//Used to keep track of the SWORD's heat for Heat Reallocation.
	var/image/glow

	New()
		..()
		mobile = 0
		firevuln = 0
		brutevuln = 0
		miscvuln = 0
		glow.plane = PLANE_SELFILLUM

		SPAWN_DBG(1 MINUTE)
			if(mode == 0 && !changing_modes && !transformation_triggered)	//If in Beacon form and not already transforming...
				transformation_countdown()									//...the countdown starts.
		return
	
	CritterDeath()
		..()
		SPAWN_DBG(5 SECONDS)
			command_announcement("<br><b><span class='alert'>The Syndicate Weapon has been eliminated.</span></b>", "Safety Update", "sound/misc/announcement_1.ogg")
			logTheThing("combat", src, null, "has been defeated.")
			message_admins("The Syndicate Weapon: Orion Retribution Device has been defeated.")

		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, get_center())
		smoke.attach(src)
		smoke.start()

		explosion_new(get_center(), get_center(), rand(6, 12))
		fireflash(get_center(), 2)

		for(var/board_count = rand(4, 8), board_count > 0, board_count--)
        	new/obj/item/factionrep/ntboard(locate(src.loc.x + rand(-1, 3), src.loc.y + rand(-1, 3), src.loc.z))
			board_count--
		for(var/alloy_count = rand(1, 3), alloy_count > 0, alloy_count--)
        	new/obj/item/material_piece/iridiumalloy(locate(src.loc.x + rand(0, 2), src.loc.y + rand(0, 2), src.loc.z))
			alloy_count--
		new/obj/machinery/power/sword_engine(get_center())

		SPAWN_DBG(1 SECOND)
			elecflash(get_center())
			qdel(src)

	attackby(obj/item/W as obj, mob/living/user as mob)
		..()
		if(mode == 0 && !changing_modes && !transformation_triggered)		//If in Beacon form and not already transforming...
			transformation_countdown()										//...the countdown starts.
		return


//-ABILITY SELECTION-//

	//Some proc.


//-TRANSFORMATIONS-//
	
	proc/transformation(var/transformation_id)				//0 - Beacon. 1 - Unanchored. 2 - Anchored.		
		mobile = 0
		firevuln = 1.25
		brutevuln = 1.25
		miscvuln = 0.25

		switch(transformation_id)
			if(0)
				rotation_locked = true
				changing_modes = true
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "beacon"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "beacon")
				src.UpdateOverlays(glow, "glow")
				SPAWN_DBG(18)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "unanchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
					src.UpdateOverlays(glow, "glow")
					changing_modes = false
					rotation_locked = false
					name = true_name
					desc = true_desc
					aggressive = 1							//Only after exiting the beacon form will the SWORD become aggressive.
					health = 6000

			if(1)
				rotation_locked = true
				changing_modes = true
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "unanchored"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "unanchored")
				src.UpdateOverlays(glow, "glow")
				SPAWN_DBG(11)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "unanchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
					src.UpdateOverlays(glow, "glow")
					changing_modes = false
					rotation_locked = false

			else
				rotation_locked = true
				changing_modes = true
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "anchored"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "anchored")
				src.UpdateOverlays(glow, "glow")
				SPAWN_DBG(11)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "anchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
					src.UpdateOverlays(glow, "glow")
					changing_modes = false
					rotation_locked = false

		SPAWN_DBG(10)
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2
		return


//-GENERAL ABILITIES-//

	proc/configuration_swap()								//Swaps between anchored and unanchored forms, if possible.
		if(mode == 0)
			return

		var/pathable_turfs = 0
		for (var/turf/T in range(1, get_center()))
			if (T && (T.pathable || istype(T, /turf/space)))
				pathable_turfs++

		if(mode == 1 && pathable_turfs >= 4)
			transformation(2)
			return

		else
			if(pathable_turfs <= 3)
				transformation(1)
				return


	proc/stifling_vacuum()									//In a T-shape in front of it, trips and attracts closer all mobs affected.
		walk_towards(src, src.target)
		walk(src,0)
		mobile = 0
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "stiflingVacuum")
		src.UpdateOverlays(glow, "glow")
		SPAWN_DBG(4)
			var/increment
			switch (src.dir)
				if (1)	//N
					var/turf/T = locate(src.loc.x + 1,src.loc.y + 3,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + 1 + increment,src.loc.y + 4,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (4)	//E
					var/turf/T = locate(src.loc.x + 3,src.loc.y + 1,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + 4,src.loc.y + 1 + increment,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (2)	//S
					var/turf/T = locate(src.loc.x + 1,src.loc.y - 1,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + 1 + increment,src.loc.y - 2,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (8)	//W
					var/turf/T = locate(src.loc.x - 1,src.loc.y + 1,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x - 2,src.loc.y + 1 + increment,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

		SPAWN_DBG(8)
			mobile = 1
			if(mode == 1)
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			else
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			src.UpdateOverlays(glow, "glow")
		return


//-ANCHORED ABILITIES-//

	proc/linear_purge()										//After 1.5 seconds, unleashes a destructive beam.
		firevuln = 1.5
		brutevuln = 1.5
		miscvuln = 0.4

		walk_towards(src, src.target)
		walk(src,0)
		playsound(get_center(), "sound/weapons/heavyioncharge.ogg", 75, 1)
		mobile = 0

		var/increment
		var/turf/T

		switch (src.dir)
			if (1)	//N
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x + 1,src.loc.y + 1 + increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1,src.loc.y + 1 + increment,0)

			if (4)	//E
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x + 1 + increment,src.loc.y + 1,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1 + increment,src.loc.y + 1,0)

			if (2)	//S
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x + 1,src.loc.y + 1 - increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1,src.loc.y + 1 - increment,0)

			if (8)	//W
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x + 1 - increment,src.loc.y + 1,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						playsound(get_center(), 'sound/weapons/laserultra.ogg', 100, 1)
						tile_purge(src.loc.x + 1 - increment,src.loc.y + 1,0)

		SPAWN_DBG(10)
			rotation_locked = true

		SPAWN_DBG(20)
			mobile = 1
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


	proc/gyrating_edge()									//Spins, dealing mediocre damage to anyone nearby.
		rotation_locked = true
		mobile = 0
		firevuln = 0.5
		brutevuln = 0.5
		miscvuln = 0.1

		var/spin_dir = prob(50) ? "L" : "R"
		animate_spin(src, spin_dir, 5, 0)
		playsound(get_center(), "sound/effects/flameswoosh.ogg", 60, 1)
		if(spin_dir == "L")
			glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "gyratingEdge_L")
		else
			glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "gyratingEdge_R")
		src.UpdateOverlays(glow, "glow")

		SPAWN_DBG(1)
			for (var/mob/M in range(5,get_center()))
				random_brute_damage(M, 32)
				random_burn_damage(M, 16)

		SPAWN_DBG(5)
			animate_spin(src, spin_dir, 5, 0)

		SPAWN_DBG(6)
			for (var/mob/M in range(5,get_center()))
				random_brute_damage(M, 16)
				random_burn_damage(M, 32)

		SPAWN_DBG(10)
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


	proc/destructive_leap()									//Leaps at the target using it's thrusters, dealing damage at the landing location and probably gibbing anyone at the center of said location.
		walk_towards(src, src.target)
		walk(src,0)
		for (var/mob/B in range(3,get_center()))
			random_burn_damage(B, 30)
			B.changeStatus("burning", 3 SECONDS)
		icon = 'icons/misc/retribution/SWORD/abilities.dmi'
		icon_state = "destructiveLeap"
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "destructive")
		src.UpdateOverlays(glow, "glow")
		rotation_locked = true
		mobile = 0
		firevuln = 0.75
		brutevuln = 0.75
		miscvuln = 0.15
		animate_float(src, -1, 5, 1)
		playsound(get_center(), "sound/effects/flame.ogg", 80, 1)

		SPAWN_DBG(2)
			for(var/i=0, i < 6, i++)
				step(src, src.dir)
				if(i < 3)
					src.pixel_y += 4
				else
					src.pixel_y -= 4
				sleep(1)
			for (var/mob/M in range(3,get_center()))
				random_brute_damage(M, 60)
			tile_purge(src.loc.x + 1,src.loc.y + 1,1)
			for (var/mob/M in get_center())
				if(prob(69))								//Nice.
					M.gib()
				else
					random_brute_damage(M, 120)

		SPAWN_DBG(10)
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "anchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


//-UNANCHORED ABILITIES-//

	proc/heat_reallocation()								//Sets anyone nearby on fire while dealing increasing burning damage.
		rotation_locked = true
		mobile = 0
		firevuln = 1.25
		brutevuln = 1.25
		miscvuln = 0.25

		playsound(get_center(), "sound/effects/gust.ogg", 60, 1)
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "heatReallocation")
		src.UpdateOverlays(glow, "glow")

		SPAWN_DBG(2)
			for (var/mob/M in range(3,get_center()))
				random_burn_damage(M, (current_heat_level / 5))
				M.changeStatus("burning", 4 SECONDS)

		SPAWN_DBG(4)
			for (var/mob/M in range(3,get_center()))
				random_burn_damage(M, (current_heat_level / 4))
				M.changeStatus("burning", 6 SECONDS)

		SPAWN_DBG(6)
			for (var/mob/M in range(3,get_center()))
				random_burn_damage(M, (current_heat_level / 3))
				M.changeStatus("burning", 8 SECONDS)

		SPAWN_DBG(8)
			current_heat_level = 0
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


	proc/energy_absorption()								//Becomes immune to burn damage for the duration. Creates a snapshot of it's health during activation, returning to it after 1.2 seconds. Increases the heat value by damage taken during the duration.
		rotation_locked = true
		mobile = 0
		firevuln = 0
		brutevuln = 1.25
		miscvuln = 0.25

		var/health_before_absorption = health
		playsound(get_center(), "sound/effects/shieldup.ogg", 80, 1)
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "energyAbsorption")
		src.UpdateOverlays(glow, "glow")

		SPAWN_DBG(12)
			if(health_before_absorption > health)
				current_heat_level = current_heat_level + health_before_absorption - health
				health = health_before_absorption

			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


	proc/destructive_flight()								//Charges at the target using it's thrusters twice, dealing damage at the locations of each one's end.
		walk_towards(src, src.target)
		walk(src,0)
		for (var/mob/B in range(3,get_center()))
			random_burn_damage(B, 30)
		icon = 'icons/misc/retribution/SWORD/abilities.dmi'
		icon_state = "destructiveFlight"
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "destructive")
		src.UpdateOverlays(glow, "glow")
		rotation_locked = true
		mobile = 0
		firevuln = 0.75
		brutevuln = 0.75
		miscvuln = 0.15
		animate_float(src, -1, 5, 1)
		playsound(get_center(), "sound/effects/flame.ogg", 80, 1)

		var/increment
		var/turf/T

		SPAWN_DBG(1)
			for(var/i=0, i < 6, i++)
				switch (src.dir)
					if (1)	//N
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 1,src.loc.y + 3,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y + 3,0)

					if (4)	//E
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 3,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 3,src.loc.y + 1 + increment,0)

					if (2)	//S
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 1,src.loc.y - 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y - 1,0)

					if (8)	//W
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x - 1,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x - 1,src.loc.y + 1 + increment,0)
				step(src, src.dir)
				sleep(0.5)
			for (var/mob/M in range(3,get_center()))
				random_brute_damage(M, 60)

		SPAWN_DBG(8)
			walk_towards(src, src.target)
			walk(src,0)
			for(var/l=0, l < 6, l++)
				switch (src.dir)
					if (1)	//N
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 1,src.loc.y + 3,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y + 3,0)

					if (4)	//E
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 3,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 3,src.loc.y + 1 + increment,0)

					if (2)	//S
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x + 1,src.loc.y - 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x + 1 + increment,src.loc.y - 1,0)

					if (8)	//W
						for(increment = -1; increment <= 1; increment++)
							T = locate(src.loc.x - 1,src.loc.y + 1,src.loc.z)
							if(T)
								playsound(get_center(), 'sound/effects/smoke_tile_spread.ogg', 20, 1)
								tile_purge(src.loc.x - 1,src.loc.y + 1 + increment,0)
				step(src, src.dir)
				sleep(0.5)
			for (var/mob/O in range(3,get_center()))
				random_brute_damage(O, 45)

		SPAWN_DBG(15)
			icon = 'icons/misc/retribution/SWORD/base.dmi'
			icon_state = "unanchored"
			glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2


//-MISCELLANEOUS-//
		
	proc/tile_purge(var/point_x, var/point_y, var/dam_type)	//A helper proc for Linear Purge, Destructive Leap and Destructive Flight.
		for (var/mob/M in locate(point_x,point_y,src.z))
			if(!dam_type)
				if (isrobot(M))
					M.health = M.health * rand(0.10, 0.20)
				else
					random_burn_damage(M, 80)
				playsound(M.loc, "sound/impact_sounds/burn_sizzle.ogg", 70, 1)
			else
				if (isrobot(M))
					M.health = M.health * rand(0.10 / dam_type, 0.20 / dam_type)
				else
					random_brute_damage(M, 80 / dam_type)
			M.changeStatus("weakened", 4 SECOND)
			M.changeStatus("stunned", 1 SECOND)
			INVOKE_ASYNC(M, /mob.proc/emote, "scream")
		var/turf/simulated/T = locate(point_x,point_y,src.z)
		if(dam_type == 2 && istype(T, /turf/simulated/wall))
			T.ex_act(1)
		else
			if(T && prob(90))
				T.ex_act(1)
			for (var/obj/S in locate(point_x,point_y,src.z))
				if(prob(45) && istype(S, /obj/critter/sword))
					S.ex_act(1)
		return


	proc/transformation_countdown()							//Starts the initial transformation's countdown.
		transformation_triggered = true
		name = transformation_name
		desc = transformation_desc
		glow = image('icons/misc/retribution/SWORD/base_o.dmi', "beacon")
		command_announcement("<br><b><span class='alert'>An unidentified long-range beacon has been detected near the station. Await further instructions.</span></b>", "Alert", "sound/vox/alert.ogg")
		SPAWN_DBG(2 MINUTES)
			command_announcement("<br><b><span class='alert'>The station is under siege by the Syndicate-made object detected earlier. Survive any way possible.</span></b>", "Alert", "sound/vox/alert.ogg")
			transformation(0)


	proc/get_center()										//Returns the central turf.
		var/turf/center_tile = get_step(get_turf(src), NORTHEAST)
		return center_tile