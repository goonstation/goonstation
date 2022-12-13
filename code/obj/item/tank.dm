/*
Contains:
-Base Tank
-Anesthetic/N2O Tank
-Jetpacks
-Oxygen Tank
-Emergency Oxygen Tank
-Air Tank
-Plasma Tank
*/

/obj/item/tank
	name = "tank"
	desc = "A portable tank for holding pressurized gas. It can be worn on the back, or hooked up to a compatible receptacle."
	icon = 'icons/obj/items/tank.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT | TGUI_INTERACTIVE
	c_flags = ONBACK

	pressure_resistance = ONE_ATMOSPHERE * 5

	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	stamina_damage = 55
	stamina_cost = 23
	stamina_crit_chance = 10

	abilities = list(/obj/ability_button/tank_valve_toggle)

	/// This value is read by get_desc(), and is used by subtypes instead of copy-pasting the entire description with minor changes.
	var/extra_desc = null
	/// The air contents of this tank.
	var/datum/gas_mixture/air_contents = null
	/// This tank's contents will be released at this pressure. Most subtypes use the minimum breathable value here.
	var/distribute_pressure = ONE_ATMOSPHERE
	/// Decremented over time when the tank is overpressurized. A damaged tank will leak or even rupture.
	var/integrity = 3
	/// Whether or not this tank can be used in a tank transfer valve.
	var/compatible_with_TTV = TRUE

	New()
		..()
		src.air_contents = new /datum/gas_mixture
		src.air_contents.vacuum()
		src.air_contents.volume = 70 //liters
		src.air_contents.temperature = T20C
		processing_items |= src
		src.create_inventory_counter()
		BLOCK_SETUP(BLOCK_TANK)
		return

	disposing()
		if(air_contents)
			qdel(air_contents)
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

	attack_self(mob/user)
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
		return TRUE

	proc/using_internal()
		if (iscarbon(src.loc))
			var/mob/living/carbon/location = loc
			return location.internal == src
		return FALSE

	proc/set_release_pressure(pressure)
		distribute_pressure = clamp(pressure, 0, TANK_MAX_RELEASE_PRESSURE)

	proc/toggle_valve()
		if (iscarbon(src.loc))
			var/mob/living/carbon/location = loc
			if (!location)
				return
			playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, TRUE)
			if(location.internal == src)
				for (var/obj/ability_button/tank_valve_toggle/T in location.internal.ability_buttons)
					if(T.the_item == src)
						T.icon_state = "airoff"
				location.internal = null
				if (location.internals)
					location.internals.icon_state = "internal0"
				boutput(location, "<span class='notice'>You close the tank release valve.</span>")
				return FALSE
			else
				if(location.wear_mask && (location.wear_mask.c_flags & MASKINTERNALS))
					if(!isnull(location.internal)) //you're already using a tank and it's not this one
						location.internal.toggle_valve()
						boutput(location, "<span class='notice'>After closing the valve on your other tank, you switch to this one.</span>")
					location.internal = src

					for (var/obj/ability_button/tank_valve_toggle/T in location.internal.ability_buttons)
						if(T.the_item == src)
							T.icon_state = "airon"
					if (location.internals)
						location.internals.icon_state = "internal1"
					boutput(location, "<span class='notice'>You open the tank release valve.</span>")
					return TRUE
				else
					boutput(location, "<span class='alert'>The valve immediately closes! You need to put on a mask first.</span>")
					playsound(src.loc, 'sound/items/penclick.ogg', 50, TRUE)
					return FALSE

	proc/remove_air_volume(volume_to_return)
		if(!air_contents)
			return null
		var/tank_pressure = MIXTURE_PRESSURE(air_contents)
		var/moles_needed = min(distribute_pressure, tank_pressure) *volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
		return remove_air(moles_needed)

	process()
		//Allow for reactions
		if (air_contents)
			air_contents.react()
			src.inventory_counter.update_text("[round(MIXTURE_PRESSURE(air_contents))]\nkPa")
		check_status()

	proc/check_status()
		//Handle exploding, leaking, and rupturing of the tank
		if(!air_contents)
			return FALSE
		var/pressure = MIXTURE_PRESSURE(air_contents)
		if(pressure > TANK_FRAGMENT_PRESSURE) // 50 atmospheres, or: 5066.25 kpa under current _setup.dm conditions
			//Give the gas a chance to build up more pressure through reacting
			playsound(src.loc, 'sound/machines/hiss.ogg', 50, TRUE)
			air_contents.react()
			air_contents.react()
			air_contents.react()
			pressure = MIXTURE_PRESSURE(air_contents)

			var/range = (pressure - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE
			// (pressure - 5066.25 kpa) divided by 1013.25 kpa
			range = min(range, 12)

			if(src in bible_contents)
				for_by_tcl(B, /obj/item/storage/bible)
					var/turf/T = get_turf(B.loc)
					if(T)
						logTheThing(LOG_BOMBING, src, "exploded at [log_loc(T)], range: [range], last touched by: [src.fingerprintslast]")
						explosion(src, T, round(range * 0.25), round(range * 0.5), round(range), round(range * 1.5))
				bible_contents.Remove(src)
				qdel(src)
				return
			var/turf/epicenter = get_turf(loc)
			logTheThing(LOG_BOMBING, src, "exploded at [log_loc(epicenter)], , range: [range], last touched by: [src.fingerprintslast]")
			src.visible_message("<span class='alert'><b>[src] explosively ruptures!</b></span>")
			explosion(src, epicenter, round(range * 0.25), round(range * 0.5), round(range), round(range * 1.5))
			qdel(src)

		else if(pressure > TANK_RUPTURE_PRESSURE)
			if(integrity <= 0)
				loc.assume_air(air_contents)
				air_contents = null
				src.visible_message("<span class='alert'>[src] violently ruptures!</span>")
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, TRUE)
				qdel(src)
			else
				integrity--

		else if(pressure > TANK_LEAK_PRESSURE)
			if(integrity <= 0)
				playsound(src.loc, 'sound/effects/spray.ogg', 50, TRUE)
				var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
				loc.assume_air(leaked_gas)
			else
				integrity--

		else if(integrity < 3)
			integrity++

	get_desc(dist, mob/user)
		var/list/extras = list()
		if (extra_desc)
			extras += extra_desc
		extras += " It is labeled to have a volume of [src.air_contents.volume] litres. " + ..()
		return extras.Join(" ")

	examine(mob/user)
		. = list()
		var/can_interact = in_interact_range(src, user) || isobserver(user)
		var/celsius_temperature = TO_CELSIUS(src.air_contents.temperature)
		var/descriptive = "buggy. Report this to a coder."
		switch (celsius_temperature)
			if (-INFINITY to -1)
				descriptive = "freezing cold!"
			if (-1 to 19)
				descriptive = "cold."
			if (19 to 39)
				descriptive = "room temperature."
			if (39 to 79)
				descriptive = "lukewarm."
			if (79 to 99)
				descriptive = "warm."
			if (99 to 299)
				descriptive = "hot."
			if (299 to INFINITY)
				descriptive = "furiously hot!"
		// this call is kind of gross, but it's necessary to show data about the tank used for an assembly
		// examining an assembly from afar should show nothing about the tank; up close, it should show its temperature info
		// examining a tank on its own from afar should still show the tank's normal examine,
		// even if the user is too far away to get temperature info.
		// thus, we need some tangled logic here to make it work as intended
		if (istype(src.loc, /obj/item/assembly))
			if (in_interact_range(src.loc, user) || isobserver(user))
				. += "<span class='notice'>[bicon(src)] [src] feels [descriptive]</span>"
			return .
		. += ..()
		if (!can_interact)
			return .
		. += "<br><span class='notice'>It feels [descriptive]</span>"
		var/cur_pressure = MIXTURE_PRESSURE(air_contents)
		if (cur_pressure >= TANK_RUPTURE_PRESSURE)
			. += "<span class='alert'><b>It's starting to rupture! Better get rid of it quick!</b></span>"
		else if (cur_pressure >= TANK_LEAK_PRESSURE)
			. += "<br><span class='alert'>It's leaking air!</span>"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/mask/breath))
			var/obj/item/clothing/mask/breath/B = W
			boutput(user, "<span class='notice'>You hook up [B] to [src].</span>")
			B.auto_setup(src, user)
		else
			..()

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GasTank", name)
		ui.open()

/obj/item/tank/ui_static_data(mob/user)
	. = list(
		"maxPressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
		"maxRelease" = TANK_MAX_RELEASE_PRESSURE
	)

/obj/item/tank/ui_data(mob/user)
	. = list(
		"pressure" = MIXTURE_PRESSURE(air_contents),
		"valveIsOpen" = using_internal(),
		"releasePressure" = distribute_pressure,
	)

/obj/item/tank/ui_act(action, params)
	. = ..()
	if (.)
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
	name = "gas tank (sleeping agent)"
	icon_state = "anesthetic"
	extra_desc = "It's labeled as containing an anesthetic capable of keeping somebody unconscious while they breathe it."
	distribute_pressure = 81

	New()
		..()
		src.air_contents.oxygen = (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
		var/datum/gas/sleeping_agent/trace_gas = src.air_contents.get_or_add_trace_gas_by_type(/datum/gas/sleeping_agent)
		trace_gas.moles = (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD
		return

////////////////////////////////////////////////////////////

TYPEINFO(/obj/item/tank/jetpack)
	mats = 16

/obj/item/tank/jetpack
	name = "jetpack (oxygen)"
	uses_multiple_icon_states = TRUE
	w_class = W_CLASS_BULKY
	force = 8
	desc = "A jetpack that can use oxygen as a propellant, allowing the wearer to maneuver freely in space. It can also be used as a gas source for internals like a regular tank."
	distribute_pressure = 17
	compatible_with_TTV = FALSE
	abilities = list(/obj/ability_button/jetpack_toggle, /obj/ability_button/tank_valve_toggle)

	/// Is our propulsion enabled?
	var/on = FALSE

	// base_icon_state is used when updating the jetpack's icon, with "1" or "0" appended depending on if the jetpack is on or not
	// jetpacks have special behavior on Manta, hence the overrides here
	#if defined(MAP_OVERRIDE_MANTA)
	icon_state = "jetpack_mag0"
	item_state = "jetpack_mag"
	c_flags = IS_JETPACK
	var/base_icon_state = "jetpack_mag"
	#else
	icon_state = "jetpack0"
	item_state = "jetpack"
	var/base_icon_state = "jetpack"
	#endif

	New()
		..()
		src.air_contents.oxygen = (6 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

	update_wear_image(mob/living/carbon/human/H, override)
		src.wear_image.overlays = list(image(src.wear_image.icon, "[override ? "back-" : ""][base_icon_state][on]"))

	proc/toggle()
		src.on = !(src.on)
		src.icon_state = "[base_icon_state][src.on]"
		boutput(usr, "<span class='notice'>You [src.on ? "" : "de"]activate [src]'s propulsion.</span>")
		playsound(src.loc, 'sound/machines/click.ogg', 30, TRUE)
		update_icon()
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.update_clothing() // Immediately update the worn icon
		return

	proc/allow_thrust(num, mob/user)
		#if defined(MAP_OVERRIDE_MANTA)
		if (MagneticTether != 1)
			return 0
		#endif

		if (!(src.on))
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

/obj/item/tank/jetpack/jetpackmk2
	name = "jetpack MKII (oxygen)"
	icon_state = "jetpack_mk2_0"
	base_icon_state = "jetpack_mk2_"
	item_state = "jetpack_mk2_0"
	desc = "Suitable for underwater work, this back-mounted DPV lets you glide through the ocean depths with ease."
	extra_desc = "It comes pre-loaded with oxygen, which is used for internals as well as to power its propulsion system."

	New()
		..()
		setProperty("negate_fluid_speed_penalty", 0.6)

/obj/item/tank/jetpack/syndicate
	name = "jetpack (oxygen)"
	icon_state = "sjetpack_mag0"
	base_icon_state = "sjetpack_mag"
	item_state = "redjetpack"
	extra_desc = "It's painted in a sinister yet refined shade of red."

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

TYPEINFO(/obj/item/tank/jetpack/micro)
	mats = 8

/obj/item/tank/jetpack/micro
	name = "micro-lite jetpack (oxygen)"
	icon_state = "microjetpack0"
	item_state = "microjetpack0"
	base_icon_state = "microjetpack"
	extra_desc = "This one is the smaller variant, suiable for shorter ranged activities."
	force = 6

	New()
		..()
		src.air_contents.volume = 18
		src.air_contents.oxygen = (1.7 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return
////////////////////////////////////////////////////////////

/obj/item/tank/oxygen
	name = "gas tank (oxygen)"
	icon_state = "oxygen"
	extra_desc = "The deep blue paintwork indicates that it contains oxygen."
	distribute_pressure = 17

	New()
		..()
		src.air_contents.oxygen = (6 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

////////////////////////////////////////////////////////////

/obj/item/tank/emergency_oxygen
	name = "pocket oxygen tank"
	icon_state = "pocket_oxtank"
	flags = FPRINT | TABLEPASS | CONDUCT
	health = 5
	w_class = W_CLASS_TINY
	force = 1
	stamina_damage = 20
	stamina_cost = 8
	desc = "A tiny personal oxygen tank meant to keep you alive in an emergency. To use, put on a secure mask and open the tank's release valve."
	distribute_pressure = 17

	New()
		..()
		src.air_contents.volume = 3
		src.air_contents.oxygen = (ONE_ATMOSPHERE / 9) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

/obj/item/tank/emergency_oxygen/extended
	name = "extended capacity pocket oxygen tank"
	desc = "A an extended capacity version of the pocket emergency oxygen tank."
	icon_state = "ex_pocket_oxtank"

	New()
		..()
		src.air_contents.volume = 6
		src.air_contents.oxygen = (ONE_ATMOSPHERE / 4) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

	empty

		New()
			..()
			src.air_contents.oxygen = null
			return



/obj/item/tank/mini_oxygen
	name = "mini oxygen tank"
	icon_state = "mini_oxtank"
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	health = 5
	w_class = W_CLASS_NORMAL
	force = 3
	stamina_damage = 30
	stamina_cost = 16
	desc = "A personal oxygen tank meant to keep you alive in an emergency. To use, put on a secure mask and open the tank's release valve."
	wear_image_icon = 'icons/mob/clothing/belt.dmi'
	distribute_pressure = 17

	New()
		..()
		src.air_contents.volume = 8
		src.air_contents.oxygen = (ONE_ATMOSPHERE / 5) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

////////////////////////////////////////////////////////////

/obj/item/tank/air
	name = "gas tank (air mix)"
	icon_state = "airmix"
	item_state = "airmix"
	extra_desc = "The white paintwork indicates a breathable air mix."
	distribute_pressure = 81

	New()
		..()
		src.air_contents.oxygen = (6 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
		src.air_contents.nitrogen = (6 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD
		return

////////////////////////////////////////////////////////////

/obj/item/tank/plasma
	name = "gas tank (BIOHAZARD)"
	desc = "This heavy orange gas tank is used to contain toxic, volatile plasma. You can technically breathe from it, but you probably shouldn't without a very good reason."
	icon_state = "plasma"
	item_state = "plasma"

	New()
		..()
		src.air_contents.toxins = (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C)
		return

	proc/release()
		var/datum/gas_mixture/removed = air_contents.remove(TOTAL_MOLES(air_contents))
		loc.assume_air(removed)

	proc/ignite()
		if (QDELETED(src))
			return
		var/fuel_moles = air_contents.toxins + air_contents.oxygen/6
		var/strength = 1
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, TRUE)

		if(src in bible_contents)
			strength = fuel_moles/20
			for_by_tcl(B, /obj/item/storage/bible)//world)
				var/turf/T = get_turf(B.loc)
				if(T)
					explosion(src, T, 0, strength, strength*2, strength*3)
			if(src.master)
				qdel(src.master)
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

	attackby(obj/item/W, mob/user)
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
