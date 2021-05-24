#define FAN_OFF 0
#define FAN_ON_INLET 1
#define FAN_ON_OUTLET 2


/obj/machinery/portable_atmospherics/pressurizer
	name = "Extreme-Pressure Pressurization Device"
	desc = "Some kind of nightmare contraption to make a lot of noise or pressurize rooms."

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "pressurizer"
	density = 1

	var/fan_state = FAN_OFF
	var/process_materials = FALSE
	var/material_progress = 0
	var/obj/item/target_material = null
	var/inlet_flow = 100 // percentage
	var/whitelist = list()
	mats = 12
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL

	var/target_inlet_pressure
	var/target_outlet_pressure

	volume = 750
	p_class = 3

	process()
		..()
		if(!loc) return
		if(src.contained) return

		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		switch( fan_state )
			if( FAN_ON_OUTLET )
				var/pressure_delta = target_outlet_pressure - MIXTURE_PRESSURE(environment)
				//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(air_contents.temperature > 0)
					transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

					//Actually transfer the gas
					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

					if(holding)
						environment.merge(removed)
					else
						loc.assume_air(removed)
			if( FAN_ON_INLET )
				var/pressure_delta = target_inlet_pressure - MIXTURE_PRESSURE(air_contents)
				//Can not have a pressure delta that would cause environment pressure > tank pressure

				var/transfer_moles = 0
				if(environment.temperature > 0)
					transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

					//Actually transfer the gas
					var/datum/gas_mixture/removed
					if(holding)
						removed = environment.remove(transfer_moles)
					else
						removed = loc.remove_air(transfer_moles)

					air_contents.merge(removed)

		if( process_materials )
			src.process_raw_materials()

			src.updateDialog()
		src.update_icon()
		return

	update_icon()
		. = ..()
		if(src.fan_state != FAN_OFF)
			UpdateOverlays(image('icons/obj/atmospherics/atmos.dmi', "pressurizer-fan"), "fan")
		else
			UpdateOverlays(null, "fan")

	proc/process_raw_materials()
		if(!target_material)
			material_progress = 0
			if(length(src.contents))
				target_material = pick(src.contents)
				// check material... eject if invalid
				target_material.set_loc(null)
			else
				process_materials = FALSE

		if(material_progress < 100)
			var/progress = 10
			var/datum/gas_mixture/GM = unpool(/datum/gas_mixture)
			GM.temperature = T20C
			switch(target_material.material?.name)
				if("molitz")
					GM.oxygen += 1870 * progress / 100
				if("viscerite")
					GM.temperature = 80
					GM.nitrogen += 6858 * progress / 100
				if("char")
					GM.carbon_dioxide += 1870 * progress / 100
				if("plasmastone")
					GM.toxins += 1870 * progress / 100
				//if("koshmarite")
			src.air_contents.merge(GM)
			material_progress += progress
		else
			qdel(target_material)
			target_material = null

	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		if(status & BROKEN)
			return
		if (istype(I,/obj/item/electronics/scanner) || istype(I,/obj/item/deconstructor))
			user.visible_message("<span class='alert'><B>[user] hits [src] with [I]!</B></span>")
			return
		if (istype(I, /obj/item/handheld_vacuum))
			return
		if (istype(I,/obj/item/satchel/))
			var/action = input(user, "What do you want to do with the satchel?") in list("Empty it into the Chute","Place it in the Chute","Never Mind")
			if (!action || action == "Never Mind") return
			if (get_dist(src,user) > 1)
				boutput(user, "<span class='alert'>You need to be closer to the chute to do that.</span>")
				return
			if (action == "Empty it into the Chute")
				var/obj/item/satchel/S = I
				for(var/obj/item/O in S.contents) O.set_loc(src)
				S.satchel_updateicon()
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				return
		if (istype(I,/obj/item/storage/))
			var/action = input(user, "What do you want to do with [I]?") as null|anything in list("Empty it into the chute","Place it in the Chute")
			if (!in_interact_range(src, user))
				boutput(user, "<span class='alert'>You need to be closer to the chute to do that.</span>")
				return
			if (action == "Empty it into the chute")
				var/obj/item/storage/S = I
				for(var/obj/item/O in S)
					O.set_loc(src)
					S.hud.remove_object(O)
				user.visible_message("<b>[user.name]</b> dumps out [S] into [src].")
				return
			if (isnull(action)) return
		var/obj/item/magtractor/mag
		if (istype(I.loc, /obj/item/magtractor))
			mag = I.loc
		else if (issilicon(user))
			boutput(user, "<span class='alert'>You can't put that in the trash when it's attached to you!</span>")
			return

		var/obj/item/grab/G = I
		if(istype(G))	// handle grabbed mob
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if (istype(src, /obj/machinery/disposal/mail) && !GM.canRideMailchutes())
					boutput(user, "<span class='alert'>That won't fit!</span>")
					return
		else
			if (istype(mag))
				actions.stopId("magpickerhold", user)
			else if (!user.drop_item())
				return
			else if(I.w_class > W_CLASS_NORMAL)
				boutput(user, "<span class='alert'>That won't fit!</span>")
				return
			I.set_loc(src)
			user.visible_message("[user.name] places \the [I] into \the [src].",\
			"You place \the [I] into \the [src].")

			process_materials = TRUE //Azrun TODO REMOVE HACK UNTIL UI IMPLEMENTED

			actions.interrupt(user, INTERRUPT_ACT)

	// eject the contents of the unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)

	proc/blast_visual_effects(pressure)
		//if meets jump threshold
		var/orig_x = src.pixel_x
		var/orig_y = src.pixel_y
		animate(src, pixel_x=orig_x, pixel_y=orig_y, flags=ANIMATION_PARALLEL, time=0.01 SECONDS)
		for(var/i in 1 to 3)
			animate(pixel_x=orig_x + rand(-2, 2), pixel_y=orig_y + rand(-2, 2), easing=JUMP_EASING, time=0.1 SECONDS)
		animate(pixel_x=orig_x, pixel_y=orig_y)


		var/obj/overlay/poof = new/obj/overlay(get_turf(src))
		poof.icon = 'icons/obj/atmospherics/atmos.dmi'
		//Azrun TODO adjust color based on gas composition
		poof.color="#00EDFF"
		//Azrun TODO adjust alpha based on pressure
		//clamp( , 90, 200)
		poof.alpha = 180
		flick("pressurizer-poof", poof)
		SPAWN_DBG(0.8 SECONDS)
			if (poof) qdel(poof)

	proc/blast_release()
		var/pressure = MIXTURE_PRESSURE(src.air_contents) KILO PASCALS
		src.blast_visual_effects(pressure)

		var/volume = clamp(pressure / 206 MEGA PASCAL * 35, 5, 35 )
		playsound(src, "sound/weapons/flashbang.ogg", volume, 1)

		var/turf/simulated/T = get_turf(src)
		if (T && istype(T))
			if (T.air)
				if (T.parent?.group_processing)
					T.parent.air.merge(src.air_contents)
				else
					var/count = length(T.parent?.members)
					if (count)
						if(count>1)
							src.air_contents = src.air_contents.remove_ratio(count-1/count)
						var/datum/gas_mixture/GM
						for (var/turf/simulated/MT as() in T.parent.members)
							GM = unpool(/datum/gas_mixture)
							GM.copy_from(src.air_contents)
							MT.assume_air(GM)
					else
						T.assume_air(src.air_contents)

			for (var/mob/living/HH in range(8, src))
				var/checkdist = get_dist(HH.loc, T)
				var/misstep = clamp(1 + 10 * (5 - checkdist), 0, 40)
				var/ear_damage = max(0, 5 * 0.2 * (3 - checkdist))
				var/ear_tempdeaf = max(0, 5 * 0.2 * (5 - checkdist))
				var/stamina = clamp(5 * (5 + 1 * (7 - checkdist)), 0, 120)
				HH.apply_sonic_stun(0, 0, misstep, 0, 2, ear_damage, ear_tempdeaf, stamina)

	return_air()
		return air_contents
