/*
Contains:
-Base Tank
-Anesthetic/N2O Tank
-Jetpack
-Oxygen Tank
-Emergency Oxygen Tank
-Air Tank
-Plasma Tank
*/

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/items/tank.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	wear_image_icon = 'icons/mob/back.dmi'

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK | TGUI_INTERACTIVE

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	stamina_damage = 55
	stamina_cost = 23
	stamina_crit_chance = 10

	New()
		..()
		src.air_contents = unpool(/datum/gas_mixture)
		src.air_contents.volume = 70 //liters
		src.air_contents.temperature = T20C
		if (!(src in processing_items))
			processing_items.Add(src)
		BLOCK_TANK
		return

	disposing()
		if(air_contents)
			pool(air_contents)
			air_contents = null
		processing_items.Remove(src)
		..()

	blob_act(var/power)
		if(prob(25 * power / 20))
			var/turf/location = src.loc
			if (!( istype(location, /turf) ))
				qdel(src)
			if(src.air_contents)
				location.assume_air(air_contents)
				air_contents = null
			qdel(src)


	proc/using_internal()
		.= 0
		if(iscarbon(src.loc))
			var/mob/living/carbon/location = loc
			if(location.internal==src)
				.= 1

	attack_self(mob/user as mob)
		if (!(src.air_contents))
			return

		return ui_interact(user)

	remove_air(amount)
		return air_contents.remove(amount)

	return_air()
		return air_contents

	assume_air(datum/gas_mixture/giver)
		air_contents.merge(giver)

		check_status()
		return 1

	proc/set_release_pressure(var/pressure as num)
		distribute_pressure = min(max(0, pressure), TANK_MAX_RELEASE_PRESSURE)

	proc/toggle_valve()
		if(iscarbon(src.loc))
			var/mob/living/carbon/location = loc
			if (!location) return
			playsound(src.loc, "sound/effects/valve_creak.ogg", 50, 1)
			if(location.internal == src)
				for (var/obj/ability_button/tank_valve_toggle/T in location.internal.ability_buttons)
					T.icon_state = "airoff"
				location.internal = null
				if (location.internals) location.internals.icon_state = "internal0"
				boutput(usr, "<span class='notice'>You close the tank release valve.</span>")
				return 0
			else
				if(location.wear_mask && (location.wear_mask.c_flags & MASKINTERNALS))
					location.internal = src
					for (var/obj/ability_button/tank_valve_toggle/T in location.internal.ability_buttons)
						T.icon_state = "airon"
					if (location.internals) location.internals.icon_state = "internal1"
					boutput(usr, "<span class='notice'>You open the tank valve.</span>")
					return 1
				else
					boutput(usr, "<span class='notice'>The valve immediately closes. You must put on a mask first.</span>")
					playsound(src.loc, "sound/items/penclick.ogg", 50, 1)
					return 0

	proc/remove_air_volume(volume_to_return)
		if(!air_contents)
			return null

		var/tank_pressure = MIXTURE_PRESSURE(air_contents)
		//if(tank_pressure < distribute_pressure)
		//	distribute_pressure = max(tank_pressure,17)


		var/moles_needed = min(distribute_pressure, tank_pressure) *volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

		return remove_air(moles_needed)

	process()
		//Allow for reactions
		if (air_contents) //Wire: Fix for Cannot execute null.react().
			air_contents.react()
		check_status()

	proc/check_status()
		//Handle exploding, leaking, and rupturing of the tank

		if(!air_contents)
			return 0

		var/pressure = MIXTURE_PRESSURE(air_contents)
		if(pressure > TANK_FRAGMENT_PRESSURE) // 50 atmospheres, or: 5066.25 kpa under current _setup.dm conditions
			//boutput(world, "<span class='notice'>[x],[y] tank is exploding: [pressure] kPa</span>")
			//Give the gas a chance to build up more pressure through reacting
			playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)
			air_contents.react()
			air_contents.react()
			air_contents.react()
			pressure = MIXTURE_PRESSURE(air_contents)

			var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
			// (pressure - 5066.25 kpa) divided by 1013.25 kpa
			range = min(range, 12)		// was 8

			if(src in bible_contents)
				for(var/obj/item/storage/bible/B in by_type[/obj/item/storage/bible])//world)
					var/turf/T = get_turf(B.loc)
					if(T)
						logTheThing("bombing", src, null, "exploded at [showCoords(T.x, T.y, T.z)], range: [range], last touched by: [src.fingerprintslast]")
						explosion(src, T, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
				bible_contents.Remove(src)
				qdel(src)
				return
			var/turf/epicenter = get_turf(loc)

			//boutput(world, "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>")


			logTheThing("bombing", src, null, "exploded at [showCoords(epicenter.x, epicenter.y, epicenter.z)], , range: [range], last touched by: [src.fingerprintslast]")
			explosion(src, epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
			qdel(src)

		else if(pressure > TANK_RUPTURE_PRESSURE)
			//boutput(world, "<span class='notice'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>")
			if(integrity <= 0)
				loc.assume_air(air_contents)
				air_contents = null
				//TODO: make pop sound
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 60, 1) // consider it TO DID
				qdel(src)
			else
				integrity--

		else if(pressure > TANK_LEAK_PRESSURE)
			//boutput(world, "<span class='notice'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>")
			if(integrity <= 0)
				var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
				loc.assume_air(leaked_gas)
			else
				integrity--

		else if(integrity < 3)
			integrity++

	examine()
		if (istype(src.loc, /obj/item/assembly))
			var/obj/item/icon = src
			. = list()
			icon = src.loc
			if (!in_range(src, usr))
				if (icon == src)
					. += "<span class='notice'>It's a [bicon(icon)]! If you want any more information you'll need to get closer.</span>"
				return

			var/celsius_temperature = src.air_contents.temperature-T0C
			var/descriptive

			if (celsius_temperature < 20)
				descriptive = "cold"
			else if (celsius_temperature < 40)
				descriptive = "room temperature"
			else if (celsius_temperature < 80)
				descriptive = "lukewarm"
			else if (celsius_temperature < 100)
				descriptive = "warm"
			else if (celsius_temperature < 300)
				descriptive = "hot"
			else
				descriptive = "furiously hot"

			. += "<span class='notice'>The [bicon(icon)] feels [descriptive]</span>"
		else
			return ..()


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/clothing/mask/breath))
			var/obj/item/clothing/mask/breath/B = W
			B.auto_setup(src,user)
		else
			..()

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GasTank", name)
		ui.open()

/obj/item/tank/ui_data(mob/user)
	var/list/data = list()
	data["pressure"] = MIXTURE_PRESSURE(air_contents)
	data["maxPressure"] = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE
	data["valveIsOpen"] = using_internal()
	data["releasePressure"] = distribute_pressure
	data["maxRelease"] = TANK_MAX_RELEASE_PRESSURE

	return data

/obj/item/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle-valve")
			toggle_valve()
			. = TRUE
		if("set-pressure")
			var/target_pressure = params["releasePressure"]
			if(isnum(target_pressure))
				set_release_pressure(params["releasePressure"])
				. = TRUE

/obj/item/tank/ui_state(mob/user)
	return tgui_physical_state

/obj/item/tank/ui_status(mob/user)
  return min(
		tgui_physical_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

////////////////////////////////////////////////////////////

/obj/item/tank/anesthetic
	name = "Gas Tank (Sleeping Agent)"
	icon_state = "anesthetic"
	desc = "This tank is labelled that it contains an anaesthetic capable of keeping somebody unconscious while they breathe it."
	module_research = list("atmospherics" = 3, "metals" = 1, "medicine" = 2)
	distribute_pressure = 81 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
		var/datum/gas/sleeping_agent/trace_gas = new()
		trace_gas.moles = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
		if(!src.air_contents.trace_gases)
			src.air_contents.trace_gases = list()
		src.air_contents.trace_gases += trace_gas
		return

////////////////////////////////////////////////////////////

#if defined(MAP_OVERRIDE_MANTA)
/obj/item/tank/jetpack
	name = "Jetpack (Oxygen)"
	icon_state = "jetpack_mag0"
	uses_multiple_icon_states = 1
	var/on = 0.0
	w_class = 4.0
	item_state = "jetpack_mag"
	mats = 16
	force = 8
	stamina_damage = 55
	stamina_cost = 30
	desc = "A jetpack that can be toggled on, letting the user use the gas inside as a propellant. Can also be hooked up to a compatible mask to allow you to breathe the gas inside. This is labelled to contain oxygen."
	module_research = list("atmospherics" = 4)
	distribute_pressure = 17 // setting these things to start at the minimum pressure needed to breathe - Haine
	c_flags = IS_JETPACK

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
		return

	proc/toggle()
		src.on = !( src.on )
		src.icon_state = text("jetpack_mag[]", src.on)
		if(src.on)
			boutput(usr, "<span class='notice'>The jetpack is now on</span>")
		else
			boutput(usr, "<span class='notice'>The jetpack is now off</span>")
		return

	proc/allow_thrust(num, mob/user as mob)
		if (MagneticTether != 1)
			return 0

		if (!( src.on ))
			return 0
		if ((num < 0.01 || TOTAL_MOLES(src.air_contents) < num))
			return 0

		var/datum/gas_mixture/G = src.air_contents.remove(num)

		if (G.oxygen >= 0.01)
			return 1
		if (G.toxins > 0.001)
			if (user)
				var/d = G.toxins / 2
				d = min(abs(user.health + 100), d, 25)
				user.TakeDamage("chest", 0, d)
			return (G.oxygen >= 0.0075 ? 0.5 : 0)
		else
			if (G.oxygen >= 0.0075)
				return 0.5
			else
				return 0
		//G = null
		qdel(G)
		return

/obj/item/tank/jetpack/abilities = list(/obj/ability_button/jetpack_toggle, /obj/ability_button/tank_valve_toggle)

#else
/obj/item/tank/jetpack
	name = "Jetpack (Oxygen)"
	icon_state = "jetpack0"
	uses_multiple_icon_states = 1
	var/on = 0.0
	w_class = 4.0
	item_state = "jetpack"
	mats = 16
	force = 8
	desc = "A jetpack that can be toggled on, letting the user use the gas inside as a propellant. Can also be hooked up to a compatible mask to allow you to breathe the gas inside. This is labelled to contain oxygen."
	module_research = list("atmospherics" = 4)
	distribute_pressure = 17 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
		return

	proc/toggle()
		src.on = !( src.on )
		src.icon_state = text("jetpack[]", src.on)
		if(src.on)
			boutput(usr, "<span class='notice'>The jetpack is now on</span>")
		else
			boutput(usr, "<span class='notice'>The jetpack is now off</span>")
		return

	proc/allow_thrust(num, mob/user as mob)
		if (!( src.on ))
			return 0
		if ((num < 0.01 || TOTAL_MOLES(src.air_contents) < num))
			return 0

		var/datum/gas_mixture/G = src.air_contents.remove(num)

		if (G.oxygen >= 0.01)
			return 1
		if (G.toxins > 0.001)
			if (user)
				var/d = G.toxins / 2
				d = min(abs(user.health + 100), d, 25)
				user.TakeDamage("chest", 0, d)
			return (G.oxygen >= 0.0075 ? 0.5 : 0)
		else
			if (G.oxygen >= 0.0075)
				return 0.5
			else
				return 0

/obj/item/tank/jetpack/abilities = list(/obj/ability_button/jetpack_toggle, /obj/ability_button/tank_valve_toggle)
#endif

////////////////////////////////////////////////////////////

/obj/item/tank/oxygen
	name = "Gas Tank (Oxygen)"
	icon_state = "oxygen"
	desc = "This is a tank that can be worn on one's back, as well as hooked up to a compatible receptacle. When a mask is worn and the release valve on the tank is open, the user will breathe the gas inside the tank. This is labelled to contain oxygen."
	module_research = list("atmospherics" = 2)
	distribute_pressure = 17 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
		return

/obj/item/tank/oxygen/abilities = list(/obj/ability_button/tank_valve_toggle)

////////////////////////////////////////////////////////////

/obj/item/tank/emergency_oxygen
	name = "emergency oxygentank"
	icon_state = "em_oxtank"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT
	w_class = 2.0
	force = 3.0
	stamina_damage = 30
	stamina_cost = 16
	desc = "A small tank that is labelled to contain oxygen. In emergencies, wear a mask that can be used to transfer air, such as a breath mask, turn on the release valve on the oxygen tank, and put it on your belt."
	wear_image_icon = 'icons/mob/belt.dmi'
	module_research = list("atmospherics" = 1)
	distribute_pressure = 17 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.volume = 6 // Change to 3 once atmos is fixed
		src.air_contents.oxygen = (ONE_ATMOSPHERE / 4.5)*70/(R_IDEAL_GAS_EQUATION*T20C) // cogwerks: drastically reduced capacity of emerg tanks
		return

/obj/item/tank/emergency_oxygen/abilities = list(/obj/ability_button/tank_valve_toggle)

////////////////////////////////////////////////////////////

/obj/item/tank/air
	name = "Gas Tank (Air Mix)"
	icon_state = "airmix"
	item_state = "airmix"
	desc = "This is a tank that can be worn on one's back, as well as hooked up to a compatible recepticle. When a mask is worn and the release valve on the tank is open, the user will breathe the gas inside the tank. This is labelled to contain nitrogen and oxygen."
	module_research = list("atmospherics" = 2)
	distribute_pressure = 81 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
		src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
		return

/obj/item/tank/air/abilities = list(/obj/ability_button/tank_valve_toggle)

////////////////////////////////////////////////////////////

/obj/item/tank/plasma
	name = "Gas Tank (BIOHAZARD)"
	icon_state = "plasma"
	desc = "This is a tank that can be hooked up to a compatible recepticle. When a mask is worn and the release valve on the tank is open, the user will breathe the gas inside the tank. This is labelled to contain deadly plasma."
	module_research = list("atmospherics" = 2)

	New()
		..()
		src.air_contents.toxins = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
		return

	proc/release()
		var/datum/gas_mixture/removed = air_contents.remove(TOTAL_MOLES(air_contents))
		loc.assume_air(removed)

	proc/ignite()
		if (!src) return
		var/fuel_moles = air_contents.toxins + air_contents.oxygen/6
		var/strength = 1
		playsound(src.loc, "sound/machines/hiss.ogg", 50, 1)

		if(src in bible_contents)
			strength = fuel_moles/20
			for(var/obj/item/storage/bible/B in by_type[/obj/item/storage/bible])//world)
				var/turf/T = get_turf(B.loc)
				if(T)
					explosion(src, T, 0, strength, strength*2, strength*3)
			if(src.master) qdel(src.master)
			bible_contents.Remove(src)
			qdel(src)
			return

		var/turf/ground_zero = get_turf(loc)

		if(air_contents.temperature > (T0C + 400))
			strength = fuel_moles/15

			explosion(src, ground_zero, strength, strength*2, strength*4, strength*5)

		else if(air_contents.temperature > (T0C + 250))
			strength = fuel_moles/20

			explosion(src, ground_zero, -1, -1, strength*3, strength*4)
			ground_zero.assume_air(air_contents)
			air_contents = null
			ground_zero.hotspot_expose(1000, 125)

		else if(air_contents.temperature > (T0C + 100))
			strength = fuel_moles/25

			explosion(src, ground_zero, -1, -1, strength*2, strength*3)
			ground_zero.assume_air(air_contents)
			air_contents = null
			ground_zero.hotspot_expose(1000, 125)

		else
			ground_zero.assume_air(air_contents)
			air_contents = null
			ground_zero.hotspot_expose(1000, 125)

		if(src.master) qdel(src.master)
		qdel(src)

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if (istype(W, /obj/item/assembly/rad_ignite))
			var/obj/item/assembly/rad_ignite/S = W
			if (!( S.status ))
				return
			var/obj/item/assembly/radio_bomb/R = new /obj/item/assembly/radio_bomb( user )
			R.part1 = S.part1
			S.part1.set_loc(R)
			S.part1.master = R
			R.part2 = S.part2
			S.part2.set_loc(R)
			S.part2.master = R
			S.layer = initial(S.layer)
			user.u_equip(S)
			user.put_in_hand_or_drop(R)
			src.master = R
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(R)
			R.part3 = src
			S.part1 = null
			S.part2 = null
			//S = null
			qdel(S)

		if (istype(W, /obj/item/assembly/prox_ignite))
			var/obj/item/assembly/prox_ignite/S = W
			if (!( S.status ))
				return
			var/obj/item/assembly/proximity_bomb/R = new /obj/item/assembly/proximity_bomb( user )
			R.part1 = S.part1
			S.part1.set_loc(R)
			S.part1.master = R
			R.part2 = S.part2
			S.part2.set_loc(R)
			S.part2.master = R
			S.layer = initial(S.layer)
			user.u_equip(S)
			user.put_in_hand_or_drop(R)
			src.master = R
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(R)
			R.part3 = src
			S.part1 = null
			S.part2 = null
			//S = null
			qdel(S)

		if (istype(W, /obj/item/assembly/time_ignite))
			var/obj/item/assembly/time_ignite/S = W
			if (!( S.status ))
				return
			var/obj/item/assembly/time_bomb/R = new /obj/item/assembly/time_bomb( user )
			R.part1 = S.part1
			S.part1.set_loc(R)
			S.part1.master = R
			R.part2 = S.part2
			S.part2.set_loc(R)
			S.part2.master = R
			S.layer = initial(S.layer)
			user.u_equip(S)
			user.put_in_hand_or_drop(R)
			src.master = R
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(R)
			R.part3 = src
			S.part1 = null
			S.part2 = null
			//S = null
			qdel(S)

/*/obj/item/tank/supersoaker
	name = "Super Soaker"
	icon_state = "jetpack0"
	var/on = 0.0
	w_class = 4.0
	item_state = "jetpack"*/


/obj/item/tank/jetpack/jetpackmk2
	name = "Jetpack MKII (Oxygen)"
	icon_state = "jetpack_mk2_0"
	uses_multiple_icon_states = 1
	on = 0.0
	w_class = 4.0
	item_state = "jetpack_mk2_0"
	mats = 16
	force = 8
	desc = "An upgraded jetpack that can be toggled on, letting the user use the gas inside as a propellant. Can also be hooked up to a compatible mask to allow you to breathe the gas inside. This is labelled to contain oxygen."
	module_research = list("atmospherics" = 4)
	distribute_pressure = 17 // setting these things to start at the minimum pressure needed to breathe - Haine

	New()
		..()
		src.air_contents.volume = 100
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*100/(R_IDEAL_GAS_EQUATION*T20C)
		setProperty("negate_fluid_speed_penalty",0.6)
		return

	toggle()
		src.on = !( src.on )
		src.icon_state = text("jetpack_mk2_[]", src.on)
		if(src.on)
			boutput(usr, "<span class='notice'>The jetpack is now on</span>")
			playsound(src.loc, "sound/misc/JetpackMK2on.ogg", 50, 1)
		else
			boutput(usr, "<span class='notice'>The jetpack is now off</span>")
		return

	allow_thrust(num, mob/user as mob)
		if (!( src.on ))
			return 0
		if ((num < 0.01 || TOTAL_MOLES(src.air_contents) < num))
			return 0

		var/datum/gas_mixture/G = src.air_contents.remove(num)

		if (G.oxygen >= 0.01)
			return 1
		if (G.toxins > 0.001)
			if (user)
				var/d = G.toxins / 2
				d = min(abs(user.health + 100), d, 25)
				user.TakeDamage("chest", 0, d)
			return (G.oxygen >= 0.0075 ? 0.5 : 0)
		else
			if (G.oxygen >= 0.0075)
				return 0.5
			else
				return 0

/obj/item/tank/jetpack/jetpackmk2/abilities = list(/obj/ability_button/jetpack2_toggle, /obj/ability_button/tank_valve_toggle)

/obj/item/tank/jetpack/syndicate
	name = "Jetpack (Oxygen)"
	icon_state = "sjetpack_mag0"
	item_state = "redjetpack"
	desc = "A syndicate jetpack that can be toggled on, letting the user use the gas inside as a propellant. Can also be hooked up to a compatible mask to allow you to breathe the gas inside. This is labelled to contain oxygen."

	New()
		..()
		src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
		return

	toggle()
		src.on = !( src.on )
		src.icon_state = text("sjetpack_mag[]", src.on)
		if(src.on)
			boutput(usr, "<span class='notice'>The jetpack is now on</span>")
		else
			boutput(usr, "<span class='notice'>The jetpack is now off</span>")
		return

/obj/item/tank/jetpack/abilities = list(/obj/ability_button/jetpack_toggle, /obj/ability_button/tank_valve_toggle)
