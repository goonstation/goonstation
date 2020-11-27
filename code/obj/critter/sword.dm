/obj/critter/sword
	name = "Deep Space Beacon"
	var/transformation_name = "Syndicate Locator Beacon"
	var/true_name = "Syndicate Weapon: Orion Retribution Device"
	desc = "A huge beacon, seemingly constructed for broadcasting long-range signals."
	var/transformation_desc = "A huge beacon, seemingly constructed for baiting Nanotrasen personnel into thinking it's just a beacon."
	var/true_desc = "An automated miniature doomsday device constructed by the Syndicate."
	icon = 'icons/misc/retribution/SWORD/base.dmi'
	icon_state = "beacon"
	can_burn = 0
	reagent_capacity = 0
	can_implant = 0
	death_text = "The Syndicate Weapon violently explodes, leaving wreckage in it's wake."
	pet_text = "tries to get the attention of"
	max_health = 6000
	health = 6000
	bound_height = 96
	bound_width = 96
	layer = MOB_LAYER + 5
	emote_allowed = 0
	canmove = 0
	innate_temp_resistance = 0
	suicide_alert = 1
	var/mode = 0					//0 - Beacon. 1 - Unanchored. 2 - Anchored.
	var/changing_modes = false		//Used to prevent some things during transformation sequences.
	var/current_ability = null		//Used to keep track of what ability the SWORD is currently using.
	var/previous_ability = null		//Used to prevent using the same ability twice in a row.
	var/rotation_locked = false		//Used to lock the SWORD's rotation in place, for example during transformations or in the second stage of Linear Purge.
	var/rotation_current = 0		//Used to keep track which of the 16 different orientations the SWORD is currently facing.
	var/mob/living/carbon/target
	var/image/glow

	New()
		..()
		src.see_in_dark = SEE_DARK_FULL
		src.nodamage = 1
		glow.plane = PLANE_SELFILLUM

//-TRANSFORMATIONS-//
	
	proc/transformation(var/transformation_id)	//0 - Beacon. 1 - Unanchored. 2 - Anchored.
		switch(transformation_id)
			if(0)
				rotation_locked = true
				changing_modes = true
				icon = 'icons/misc/retribution/SWORD/transformations.dmi'
				icon_state = "beacon"
				glow = image('icons/misc/retribution/SWORD/transformations_o.dmi', "beacon")
				src.UpdateOverlays(glow, "glow")
				spawn(18)
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
				spawn(11)
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
				spawn(11)
					icon = 'icons/misc/retribution/SWORD/base.dmi'
					icon_state = "anchored"
					glow = image('icons/misc/retribution/SWORD/base_o.dmi', "anchored")
					src.UpdateOverlays(glow, "glow")
					changing_modes = false
					rotation_locked = false
		return

//-ABILITIES-//

	proc/manual_rotation()
		if(rotation_locked)
			return
		if(src.target.z == src.z)
			if('bunch of fucking bullshit dude, like how do I even do this stuff')
				rotation_current += 22.5
				src.transform.turn(22.5)
			else
				rotation_current -= 22.5
				src.transform.turn(-22.5)
			if(rotation_current > 360)
				rotation_current -= 360
			if(rotation_current < 0)
				rotation_current += 360
		else
			src.target = null

	proc/configuration_swap()
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


	proc/stifling_vacuum()
		//src.target something something

//-PATHFINDING-//
