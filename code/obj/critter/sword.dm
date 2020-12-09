/obj/critter/sword
	name = "Deep Space Beacon"
	var/transformation_name = "Syndicate Locator Beacon"
	var/true_name = "Syndicate Weapon: Orion Retribution Device"
	desc = "A huge beacon, seemingly constructed for broadcasting long-range signals."
	var/transformation_desc = "A huge beacon, seemingly constructed for baiting Nanotrasen personnel into thinking it's just a beacon."
	var/true_desc = "An automated miniature doomsday device constructed by the Syndicate."
	icon = 'icons/misc/retribution/SWORD/base.dmi'
	icon_state = "beacon"
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
	aggressive = 1
	seekrange = 256					//A perk of being a high-tech prototype - incredibly large detection range.
	var/mode = 0					//0 - Beacon. 1 - Unanchored. 2 - Anchored.
	var/changing_modes = false		//Used to prevent some things during transformation sequences.
	var/rotation_locked = false		//Used to lock the SWORD's rotation in place, for example during transformations or in the second stage of Linear Purge.
	var/current_ability = null		//Used to keep track of what ability the SWORD is currently using.
	var/previous_ability = null		//Used to prevent using the same ability twice in a row.
	var/rotation_current = 0		//Used to keep track which of the 16 different orientations the SWORD is currently facing.
	var/image/glow

	New()
		..()
		mobile = 0
		firevuln = 0
		brutevuln = 0
		miscvuln = 0

		glow.plane = PLANE_SELFILLUM
	
	attackby(obj/item/W as obj, mob/living/user as mob)
		..()
		if(mode == 0 && !changing_modes)
			SPAWN_DBG(2 MINUTES)
				transformation(0)


//-TRANSFORMATIONS-//
	
	proc/transformation(var/transformation_id)		//0 - Beacon. 1 - Unanchored. 2 - Anchored.		
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

	proc/configuration_swap()						//Swaps between anchored and unanchored forms, if possible.
		if(mode == 0)
			return

		var/pathable_turfs = 0
		for (var/turf/T in range(1, src))
			if (T && (T.pathable || istype(T, /turf/space)))
				pathable_turfs++

		if(mode == 1 && pathable_turfs >= 4)
			transformation(2)
			return

		else
			if(pathable_turfs <= 3)
				transformation(1)
				return


	proc/stifling_vacuum()							//In a T-shape in front of it, trips and attracts closer all mobs affected.
		walk_towards(src, src.target)
		walk(src,0)
		mobile = 0
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "stiflingVacuum")
		src.UpdateOverlays(glow, "glow")
		SPAWN_DBG(4)
			var/increment
			switch (src.dir)
				if (1)	//N
					var/turf/T = locate(src.loc.x,src.loc.y + 2,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + increment,src.loc.y + 3,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (4)	//E
					var/turf/T = locate(src.loc.x + 2,src.loc.y,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + 3,src.loc.y + increment,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (2)	//S
					var/turf/T = locate(src.loc.x,src.loc.y - 2,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x + increment,src.loc.y - 3,src.loc.z))
							M.changeStatus("stunned", 2 SECONDS)
							M.changeStatus("weakened", 4 SECONDS)
							M.throw_at(T, 3, 1)

				if (8)	//W
					var/turf/T = locate(src.loc.x - 2,src.loc.y,src.loc.z)
					for (var/mob/M in T)
						M.changeStatus("stunned", 2 SECONDS)
						M.changeStatus("weakened", 4 SECONDS)
					for(increment = -1; increment <= 1; increment++)
						for(var/mob/M in locate(src.loc.x - 3,src.loc.y + increment,src.loc.z))
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

	proc/linear_purge()								//After 1.5 seconds, unleashes a destructive beam.
		mobile = 0
		firevuln = 1.5
		brutevuln = 1.5
		miscvuln = 0.4

		walk_towards(src, src.target)
		walk(src,0)
		mobile = 0
		glow = image('icons/misc/retribution/SWORD/abilities_o.dmi', "linearPurge")
		src.UpdateOverlays(glow, "glow")

		var/increment
		var/turf/T

		switch (src.dir)
			if (1)	//N
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x,src.loc.y + increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						tile_purge(src.loc.x,src.loc.y + increment)

			if (4)	//E
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x + increment,src.loc.y,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						tile_purge(src.loc.x + increment,src.loc.y)

			if (2)	//S
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x,src.loc.y - increment,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						tile_purge(src.loc.x,src.loc.y - increment)

			if (8)	//W
				for(increment = 2; increment <= 9; increment++)
					T = locate(src.loc.x - increment,src.loc.y,src.loc.z)
					leavepurge(T, increment, src.dir)
					SPAWN_DBG(15)
						tile_purge(src.loc.x - increment,src.loc.y)

		SPAWN_DBG(10)
			rotation_locked = true

		SPAWN_DBG(20)
			mobile = 1
			if(mode == 1)
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "unanchored")
			else
				glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
			src.UpdateOverlays(glow, "glow")
			rotation_locked = false
			mobile = 1
			firevuln = 1
			brutevuln = 1
			miscvuln = 0.2	
		
	proc/tile_purge(var/point_x, var/point_y)	//A helper proc for Linear Purge.
		for (var/mob/M in locate(point_x,point_y,src.z))
			if (isrobot(M))
				M.health = M.health * rand(0.10, 0.20)
			else
				random_burn_damage(M, 80)
			M.changeStatus("weakened", 4 SECOND)
			M.changeStatus("stunned", 1 SECOND)
			INVOKE_ASYNC(M, /mob.proc/emote, "scream")
			playsound(M.loc, "sound/impact_sounds/burn_sizzle.ogg", 70, 1)
		var/turf/simulated/T = locate(point_x,point_y,src.z)
		if(T && prob(90))
			T.ex_act(1)
		for (var/obj/S in locate(point_x,point_y,src.z))
			if(prob(45))
				S.ex_act(1)
		return


//	proc/gyrating_edge()


//	proc/destructive_leap()


//-UNANCHORED ABILITIES-//

//	proc/heat_reallocation()


//	proc/energy_absorption()


//	proc/destructive_flight()