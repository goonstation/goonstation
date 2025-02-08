/*
CONTAINS:
GETLINEEEEEEEEEEEEEEEEEEEEE
(well not really but it should)
A Flamethrower
A Flamethrower that uses a backpack fuel/gas tank
A Flamethrower backpack fuel/gas tank
A Flamethrower in various states of assembly

*/
#define FLAMER_DEFAULT_TEMP 700 KELVIN
#define FLAMER_BACKTANK_TEMP 1000 KELVIN + T0C
#define FLAMER_MIN_TEMP T0C
#define FLAMER_MAX_TEMP 1000 KELVIN + T0C
#define FLAMER_DEFAULT_CHEM_AMT 40
#define FLAMER_BACKTANK_CHEM_AMT 40
#define FLAMER_MIN_CHEM_AMT 35
#define FLAMER_MAX_CHEM_AMT 100
#define FLAMER_MODE_AUTO 1
#define FLAMER_MODE_BURST 2
#define FLAMER_MODE_SINGLE 3
#define FLAMER_MODE_BACKTANK 4

#define MODE_TO_STRING(mode) mode == FLAMER_MODE_AUTO ? "auto" : mode == FLAMER_MODE_BURST ? "burst" :  mode == FLAMER_MODE_SINGLE ? "single" :  mode == FLAMER_MODE_BACKTANK ? "backtank" : "error"

/obj/item/gun/flamethrower
	name = "flamethrower"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "flamethrower_no_oxy_no_fuel"
	item_state = "flamethrower0"
	desc = "You are a firestarter!"
	flags = TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = null
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	var/mode = FLAMER_MODE_SINGLE
	var/processing = 0
	var/lit = 0	//on or off
	/// Set the projectile to make the reagents be this hot
	var/base_temperature = FLAMER_DEFAULT_TEMP
	/// Minimum temperature this thing'll set the reagents to
	var/min_temperature = FLAMER_MIN_TEMP
	/// Maximum temperature this thing'll set the reagents to
	var/max_temperature = FLAMER_MAX_TEMP
	/// Can this thing vary the temperature?
	var/adjustable_temp = 1
	/// How much chem to try to stuff into the projectile
	var/amt_chem = FLAMER_DEFAULT_CHEM_AMT
	/// Maximum volume this thing can shoot per shot
	var/amt_chem_max = FLAMER_MAX_CHEM_AMT
	/// Can this thing vary the amount of stuff loaded?
	var/adjustable_chem_amt = 1
	var/obj/item/tank/gastank = null
	var/obj/item/fueltank = null // Honestly, anything with reagents'll do. Just needs sprites!
	/// Can we swap out the tanks? Mainly so backpack flamers don't lose their flamer
	var/swappable_tanks = 1
	/// Divisor for chem amount - make all modes use chems at around the same rate
	var/chem_divisor = 1
	contraband = 5 //Heh
	m_amt = 500
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 1
	move_triggered = 1
	spread_angle = 0
	shoot_delay = 1 SECOND
	recoil_strength = 6

	New()
		..()
		BLOCK_SETUP(BLOCK_LARGE)
		setItemSpecial(null)
		set_current_projectile(new/datum/projectile/special/shotchem)
		AddComponent(/datum/component/holdertargeting/fullauto, src.shoot_delay)

	/// Just check if there's a usable air and fuel tank
	canshoot(mob/user)
		if(istype(src.gastank) && src.gastank.air_contents && istype(src.fueltank) && src.fueltank.reagents)
			return TRUE

	log_shoot(mob/user, turf/T, obj/projectile/P)
		logTheThing(LOG_COMBAT, user, "fires \a [src] ([lit ? "lit, " : ""][MODE_TO_STRING(mode)]) from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, T))]</I>, reagents: [log_reagents(src.fueltank)] with chamber volume [amt_chem]")

	/// allow refilling the fuel tank by simply clicking the reagent dispensers
	afterattack(atom/target, mob/user, flag)
		if(is_reagent_dispenser(target)&& in_interact_range(src,target))
			if(src.fueltank?.reagents)
				var/obj/tank = target
				tank.reagents.trans_to(src.fueltank, (src.fueltank.reagents.maximum_volume - (src.fueltank.reagents.total_volume)))
				inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)
				boutput(user, SPAN_NOTICE("You refill the flamethrower's fuel tank."))
				playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
				user.lastattacked = target
			else
				boutput(user, SPAN_NOTICE("Load the fuel tank first!"))

	/// check for tank, pressure in tank, fuelltank, fuel in tank, and... then dump the stuff into it!
	process_ammo(var/mob/user)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/T_env = T.return_air()
		if(!src.fueltank)
			boutput(user, SPAN_ALERT("[capitalize("[src]")] doesn't have a fuel source!"))
			return FALSE
		else if(!(src.fueltank in src.contents) && !(src.fueltank in user.get_equipped_items())) // Tank is loaded
			boutput(user, SPAN_ALERT("You need to either wear [src]'s fuel source or load it into the weapon!"))
			return FALSE
		else if(src.fueltank?.reagents.total_volume <= 0)
			boutput(user, SPAN_ALERT("[capitalize("[src]")]'s fuel source is empty!"))
			return FALSE
		else if(T_env && src.gastank?.air_contents && ((src.gastank in src.contents) || (src.gastank in user.get_equipped_items())))
			if(MIXTURE_PRESSURE(T_env) > MIXTURE_PRESSURE(gastank.air_contents))
				boutput(user, SPAN_ALERT("Not enough pressure in [src]'s gas tank to operate!"))
				return FALSE
		return TRUE

	alter_projectile(var/obj/projectile/P)
		if(!P.proj_data)
			return

		if(!canshoot(null)) //null because I can't be assed
			return

		var/list/P_special_data = P.special_data
		var/datum/reagents/fueltank_reagents = src.fueltank.reagents
		var/datum/gas_mixture/gastank_aircontents = src.gastank.air_contents

		var/chem_amount = min(src.fueltank?.reagents.total_volume, src.amt_chem/chem_divisor)
		if(!P.reagents)
			P.create_reagents(chem_amount)
		fueltank_reagents.trans_to_direct(P.reagents, chem_amount)

		P_special_data["proj_color"] = P.reagents.get_average_color().to_rgb()
		P_special_data["IS_LIT"] = src.lit //100
		P_special_data["burn_temp"] = src.base_temperature

		var/rem_ratio = 0.004
		switch(mode)
			if(FLAMER_MODE_AUTO)
				rem_ratio = 0.01
			if(FLAMER_MODE_BURST)
				rem_ratio = 0.02
			if(FLAMER_MODE_SINGLE)
				rem_ratio = 0.03
			if(FLAMER_MODE_BACKTANK)
				rem_ratio = 0.004
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/airgas = new /datum/gas_mixture
		airgas.volume = 1
		airgas.merge(gastank_aircontents.remove_ratio(rem_ratio * 0.9))
		T.assume_air(gastank_aircontents.remove_ratio(rem_ratio * 0.1))
		if(src.lit)
			airgas.temperature = P_special_data["burn_temp"]
		P_special_data["airgas"] = airgas

		P_special_data["temp_pct_loss_atom"] = 0.02 // keep the heat, more or less

		/// sets the projectile's chem-transfer percent per tile and speed
		switch(mode)
			if(FLAMER_MODE_AUTO)
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.15
			if(FLAMER_MODE_BURST)
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.20
			if(FLAMER_MODE_SINGLE)
				P_special_data["speed_mult"] = 1
				P_special_data["chem_pct_app_tile"] = 0.1
			else //default to backtank??
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.15
		inventory_counter?.update_percent(src.fueltank?.reagents?.total_volume, src.fueltank?.reagents?.maximum_volume)

/obj/item/gun/flamethrower/return_air(direct = FALSE)
	return src.gastank?.return_air()

/obj/item/gun/flamethrower/assembled
	name = "flamethrower"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	desc = "You are a firestarter!"
	flags = TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	var/obj/item/weldingtool/welder = null
	var/obj/item/rods/rod = null
	var/obj/item/device/igniter/igniter = null
	inventory_counter_enabled = 1

	setupProperties()
		. = ..()
		setProperty("carried_movespeed", 0.5)

/obj/item/tank/jetpack/backtank
	name = "fuelpack"
	icon_state = "syndflametank0"
	base_icon_state = "syndflametank"
	desc = "A back mounted fueltank/jetpack system for use with a tactical flamethrower."
	flags = TABLEPASS | CONDUCT | OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	c_flags = ONBACK
	var/obj/item/gun/flamethrower/backtank/linkedflamer
	inventory_counter_enabled = 1
	move_triggered = 1

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
		src.create_reagents(4000)
		inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

	on_reagent_change(add)
		..()
		inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

	equipped(mob/user, slot)
		..()
		inventory_counter?.show_count()

	examine()
		. = ..()
		if(linkedflamer && (linkedflamer in src.contents))
			. += "<br>\A [linkedflamer] is stowed away neatly in a compartment."

	attackby(obj/item/W, mob/user)
		if (src.loc == user && W != linkedflamer && istype(W, /obj/item/gun/flamethrower/backtank))
			if (linkedflamer && (linkedflamer in src.contents))
				boutput(user, SPAN_NOTICE("There already a flamethrower stowed in your [src.name]."))
			else
				var/obj/item/gun/flamethrower/backtank/flamer = W
				if (flamer.fueltank != null)
					var/obj/item/tank/jetpack/backtank/B = flamer.fueltank
					B.linkedflamer = null
				if (linkedflamer != null)
					linkedflamer.gastank = null
					linkedflamer.fueltank = null
				linkedflamer = flamer
				flamer.gastank = src
				flamer.fueltank = src
		if(src.loc == user && linkedflamer && W == linkedflamer)
			boutput(user, SPAN_NOTICE("You stow [W] into your [src.name]."))
			user.u_equip(W)
			W.set_loc(src)
			tooltip_rebuild = TRUE
		else
			..()

	attack_hand(mob/user)
		if(src.loc == user && linkedflamer && (linkedflamer in src.contents))
			boutput(user, SPAN_NOTICE("You retrieve [linkedflamer] from your [src.name]."))
			user.put_in_hand_or_drop(linkedflamer)
			tooltip_rebuild = TRUE
		else
			..()

	move_trigger(mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	mouse_drop(over_object, src_location, over_location)
		..()
		if(!isliving(usr))
			return
		var/atom/movable/screen/hud/S = over_object
		if (istype(S)) //for if we have a flamer attached
			if (!usr.restrained() && !usr.stat && src.loc == usr)
				if (S.id == "rhand")
					if (!usr.r_hand)
						usr.u_equip(src)
						usr.put_in_hand(src, 0)
				else
					if (S.id == "lhand")
						if (!usr.l_hand)
							usr.u_equip(src)
							usr.put_in_hand(src, 1)
				return

		if(BOUNDS_DIST(src, usr) > 0)
			boutput(usr, SPAN_ALERT("You need to be closer to empty \the [src] out!"))
			return

		if (!src.reagents)
			boutput(usr, SPAN_ALERT("The little cap on the fuel tank is stuck. Uh oh."))
			return

		if(src.reagents.total_volume)
			if(alert(usr, "Do you wish to empty internal fuel reservoir?", "Empty fuel", "Yes", "Cancel")=="Yes")
				src.reagents.clear_reagents()
				boutput(usr, SPAN_NOTICE("You dump out \the [src]'s stored reagents."))
				return
		else
			boutput(usr, SPAN_ALERT("There's nothing inside to drain!"))

	disposing()
		linkedflamer?.gastank = null
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

ABSTRACT_TYPE(/obj/item/gun/flamethrower/backtank)
/obj/item/gun/flamethrower/backtank
	name = "\improper Vega flamethrower"
	desc = "A military-grade flamethrower, supplied with fuel and propellant from a back-mounted fuelpack. Developed by Almagest Weapons Fabrication."
	icon_state = "syndthrower_0"
	item_state = "syndthrower_0"
	force = 6
	contraband = 7
	two_handed = 1
	swappable_tanks = 0 // Backpack or bust
	spread_angle = 10
	amt_chem = FLAMER_BACKTANK_CHEM_AMT // About 100 shots
	mode = FLAMER_MODE_BACKTANK
	can_dual_wield = 0
	shoot_delay = 5 DECI SECONDS

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		var/obj/item/tank/jetpack/backtank/B = new /obj/item/tank/jetpack/backtank(src.loc)
		src.link_tank(B)
		..()
		src.current_projectile.fullauto_valid = 1
		src.set_current_projectile(src.current_projectile)

	proc/link_tank(obj/item/tank/jetpack/backtank/tank)
		src.gastank = tank
		src.fueltank = tank
		tank.linkedflamer = src

	process_ammo(mob/user)
		var/list/equipped_list = user.get_equipped_items()
		if (!(src.gastank in equipped_list))
			var/obj/item/tank/jetpack/backtank/tank = locate() in equipped_list
			if (tank)
				src.link_tank(tank)
		return ..()


	disposing()
		if(istype(gastank, /obj/item/tank/jetpack/backtank/))
			var/obj/item/tank/jetpack/backtank/B = gastank
			B.linkedflamer = null
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	try_specific_equip(mob/user)
		. = FALSE
		if (istype(user.back, /obj/item/tank/jetpack/backtank))
			user.back.Attackby(src, user)
			return TRUE

/obj/item/gun/flamethrower/backtank/napalm
	New()
		..()
		gastank.reagents.add_reagent("syndicate_napalm", 4000)

/obj/item/gun/flamethrower/assembled/New()
	..()
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods
	igniter = new /obj/item/device/igniter
	if (fueltank)
		inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)

/obj/item/gun/flamethrower/assembled/disposing()

	qdel(src.welder)
	qdel(src.rod)
	qdel(src.igniter)
	qdel(src.gastank)
	qdel(src.fueltank)
	..()
	return

/obj/item/gun/flamethrower/assembled/loaded
	icon_state = "flamethrower_oxy_fuel"

	New()
		if(!fueltank)
			fueltank = new /obj/item/reagent_containers/food/drinks/fueltank(src)
		gastank = new /obj/item/tank/oxygen(src)
		..()

/obj/item/gun/flamethrower/assembled/loaded/napalm
	icon_state = "flamethrower_oxy_fuel"

	New()
		fueltank = new /obj/item/reagent_containers/food/drinks/fueltank/napalm(src)
		..()

// PantsNote: Dumping this shit in here until I'm sure it works.
// Lord_Earthfire: It worked for a few years, now lets make it look cleaner

/obj/item/flamethrower_construction
	icon = 'icons/obj/items/assemblies.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	desc = "A welding torch with metal rods attached to the flame tip."
	name = "Welder/Rods Assembly"
	icon_state = "welder-rods"
	item_state = "welder"
	var/list/assembly_contents = null
	var/state = 0
	flags = TABLEPASS | CONDUCT
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 10
	w_class = W_CLASS_SMALL

/obj/item/flamethrower_construction/New(var/new_location, var/obj/item/weldingtool/new_welder, var/obj/item/rods/new_rods, var/obj/item/device/igniter/new_igniter)
	..()
	if(!new_welder)
		new_welder = new /obj/item/weldingtool
	if(!new_rods)
		new_rods = new /obj/item/rods
	src.assembly_contents = list(new_rods, new_welder)
	new_welder.set_loc(src)
	new_rods.set_loc(src)
	var/new_state = 0
	if (new_igniter)
		src.assembly_contents += new_igniter
		new_igniter.set_loc(src)
		new_state = 1
	src.set_construction_state(new_state)

/obj/item/flamethrower_construction/proc/set_construction_state(var/new_state)
	// reset the assembly-components to readd the ones we want
	src.RemoveComponentsOfType(/datum/component/assembly)
	// Welder/Rods Assembly + wrench  -> deconstruction
	src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(deconstruction), FALSE)
	if (new_state == 1)
		src.state = 1
		src.name = "Welder/Rods/Igniter Assembly"
		src.desc = "A welding torch and igniter connected by metal rods."
		src.icon_state = "welder-rods-igniter"
		// Welder/Rods/igniter Assembly + screwdriver  -> assembly-completition
		src.AddComponent(/datum/component/assembly, TOOL_SCREWING, PROC_REF(completition), FALSE)
	else
		src.state = 0
		src.desc = "A welding torch with metal rods attached to the flame tip."
		src.name = "Welder/Rods Assembly"
		src.icon_state = "welder-rods"
		// Welder/Rods Assembly + igniter  -> Welder/Rods/Igniter Assembly
		src.AddComponent(/datum/component/assembly, /obj/item/device/igniter, PROC_REF(igniter_attachment), TRUE)
	src.tooltip_rebuild = TRUE

/obj/item/flamethrower_construction/disposing()
	. = ..()
	for(var/obj/item/affected_object in src.assembly_contents)
		src.assembly_contents -= affected_object
		qdel(affected_object)
	src.assembly_contents = null


/obj/item/flamethrower_construction/get_help_message(dist, mob/user)
	switch(src.state)
		if (0) // Default state
			return "You can use a <b>wrench</b> to disassemble this object or a <b>igniter</b> to continue the construction of a flamethrower."
		if (1) // with igniter
			return "You can use a <b>wrench</b> to disassemble this object or a <b>screwdriver</b> to finish the construction of a flamethrower."


// ----------------------- Assembly-procs -----------------------

/// igniter attachment
/obj/item/flamethrower_construction/proc/igniter_attachment(var/atom/to_combine_atom, var/mob/user)
	boutput(user, SPAN_NOTICE("You put the igniter in place, it still needs to be firmly attached."))
	var/obj/item/used_igniter = to_combine_atom
	user.u_equip(used_igniter)
	src.assembly_contents += used_igniter
	used_igniter.set_loc(src)
	src.set_construction_state(1)
	// Since the assembly was done, return TRUE
	return TRUE

/// deconstruction
/obj/item/flamethrower_construction/proc/deconstruction(var/atom/to_combine_atom, var/mob/user)
	boutput(user, SPAN_NOTICE("You deconstruct the [src.name]."))
	var/turf/chosen_turf = get_turf(src)
	for(var/obj/item/affected_object in src.assembly_contents)
		affected_object.set_loc(chosen_turf)
		src.assembly_contents -= affected_object
	user.u_equip(src)
	qdel(src)
	// Since the assembly was done, return TRUE
	return TRUE

/// securing-completition
/obj/item/flamethrower_construction/proc/completition(var/atom/to_combine_atom, var/mob/user)
	boutput(user, SPAN_NOTICE("The igniter is now secured."))
	user.u_equip(src)
	var/obj/item/gun/flamethrower/assembled/new_flamethrower = new/obj/item/gun/flamethrower/assembled
	for(var/obj/item/chosen_item in src.assembly_contents)
		switch(chosen_item.type)
			if(/obj/item/weldingtool)
				new_flamethrower.welder = chosen_item
			if(/obj/item/rods)
				new_flamethrower.rod = chosen_item
			if(/obj/item/device/igniter)
				new_flamethrower.igniter = chosen_item
		src.assembly_contents -= chosen_item
		chosen_item.set_loc(new_flamethrower)
	user.put_in_hand_or_drop(new_flamethrower)
	qdel(src)
	// Since the assembly was done, return TRUE
	return TRUE


// ----------------------- -------------- -----------------------

/obj/item/gun/flamethrower/process()
	if(!lit)
		processing_items.Remove(src)
		return null

	var/turf/location = src.loc
	if(ismob(location))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc

	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)

/// Swaps out the fuel tank
/obj/item/gun/flamethrower/proc/swap_any(obj/item/F, mob/user as mob)
	if(!istype(F) || !F)
		boutput(user, SPAN_ALERT("The thing you want to load into \the [src] doesn't seem to exist! Huh. That's odd. Maybe call 1-800-IM-CODER!"))
		return FALSE

	if(istype(F, /obj/item/tank))
		. = "tank"
	else if (F.reagents && F.reagents.maximum_volume >= 50)
		. = "fuel"
	if(!.)
		return FALSE

	/// put the thing in our thing
	F.set_loc(src)
	if(ismob(user))
		user.u_equip(F)

	/// dump the thing on the ground
	var/obj/item/old_thing = (. == "tank") ? src.gastank : src.fueltank
	playsound(src, 'sound/weapons/gunload_light.ogg', 25, TRUE)
	if(ismob(user))
		user.put_in_hand_or_drop(old_thing)
	else
		old_thing.set_loc(get_turf(src))

	/// Hook the thing in our thing up to our thing
	if(. == "tank")
		src.gastank = F
	else
		src.fueltank = F

	if (src.fueltank)
		src.inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)

	src.icon_state = "flamethrower[src.gastank ? "_oxy" : "_no_oxy"][src.fueltank ? "_fuel" : "_no_fuel"]"

	tgui_process.update_uis(src)
	SPAWN(0.5 SECONDS)
		playsound(src, 'sound/effects/valve_creak.ogg', 40, TRUE)
	return TRUE

/obj/item/gun/flamethrower/assembled/attackby(obj/item/W, mob/user as mob)
	if (!W || user.stat || user.restrained() || user.lying)
		return

	if (src.swappable_tanks && (istype(W,/obj/item/tank/oxygen) || istype(W,/obj/item/tank/air) || istype(W,/obj/item/tank/anesthetic) || istype(W,/obj/item/tank/empty) || istype(W,/obj/item/reagent_containers/food/drinks/fueltank)))
		if(src.lit)
			boutput(user, SPAN_NOTICE("You turn off \the [src]'s igniter. Safety first!"))
			lit = 0
			force = 3
			hit_type = DAMAGE_BLUNT
		src.swap_any(W, user)

	// PantsNote: Flamethrower disassmbly.
	else if (isscrewingtool(W))
		var/obj/item/gun/flamethrower/assembled/S = src
		if (( S.gastank ))
			return
		var/obj/item/flamethrower_construction/new_construction = new /obj/item/flamethrower_construction (null, S.welder, S.rod, S.igniter)
		user.u_equip(S)
		user.put_in_hand_or_drop(new_construction)
		S.welder = null
		S.rod = null
		S.igniter = null
		qdel(S)
		boutput(user, SPAN_NOTICE("The igniter is now unsecured!"))

	else
		return	..()

/obj/item/gun/flamethrower/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user
	if(ismob(usr))
		user = usr
	if(is_incapacitated(user) || !(src in user.equipped_list()))
		return
	switch (action)
		if ("light")
			if(!src.gastank || !src.fueltank)
				return
			lit = !lit
			playsound(src, 'sound/misc/lightswitch.ogg', 20, TRUE)
			if(lit)
				icon_state = "flamethrower_ignite_on"
				item_state = "flamethrower1"
				force =  10
				hit_type = DAMAGE_BURN
				processing_items |= src
			else
				icon_state = "flamethrower_oxy_fuel"
				force = 3
				hit_type = DAMAGE_BLUNT
			tooltip_rebuild = TRUE

		if ("remove_gas")
			if(!src.gastank || !src.swappable_tanks)
				return
			var/obj/item/tank/A = src.gastank
			A.set_loc(get_turf(src))
			A.layer = initial(A.layer)
			user.put_in_hand_or_drop(A)
			src.gastank = null
			lit = FALSE
			force = 3
			hit_type = DAMAGE_BLUNT
			var/fuel = "_no_fuel"
			if(src.fueltank)
				fuel = "_fuel"
			icon_state = "flamethrower_no_oxy[fuel]"
			item_state = "flamethrower0"
			playsound(src, 'sound/effects/valve_creak.ogg', 15, TRUE)
			var/remove_sound = "sound/items/pickup_[clamp(round(src.w_class), 1, 3)].ogg"
			if(A?.pickup_sfx)
				remove_sound = A.pickup_sfx
			SPAWN(0.2 SECONDS)
				if(src)
					playsound(src, remove_sound, 30, TRUE)


		if ("remove_fuel")
			if(!src.fueltank || !src.swappable_tanks)
				return
			var/obj/item/reagent_containers/food/drinks/fueltank/A = src.fueltank
			A.set_loc(get_turf(src))
			A.layer = initial(A.layer)
			user.put_in_hand_or_drop(A)
			src.fueltank = null
			lit = FALSE
			force = 3
			hit_type = DAMAGE_BLUNT
			var/oxy = "_no_oxy"
			if(src.gastank)
				oxy = "_oxy"
			icon_state = "flamethrower[oxy]_no_fuel"
			item_state = "flamethrower0"
			var/remove_sound = "sound/items/pickup_[clamp(round(src.w_class), 1, 3)].ogg"
			if(A?.pickup_sfx)
				remove_sound = A.pickup_sfx
			playsound(src, remove_sound, 30, TRUE)
			SPAWN(0.5 SECONDS)
				if(src)
					playsound(src, 'sound/effects/valve_creak.ogg', 15, TRUE)

		if ("change_mode")
			var/new_mode = params["mode"]
			playsound(src, 'sound/effects/valve_creak.ogg', 15, TRUE)
			src.current_projectile.fullauto_valid = 1
			src.current_projectile.shot_number = 1
			switch(new_mode)
				if("auto") // mid-range automatic
					src.mode = FLAMER_MODE_AUTO
					src.spread_angle = 15
					src.shoot_delay = 4 DECI SECONDS
					src.chem_divisor = 2
					src.current_projectile.shot_number = 2
					src.current_projectile.shot_delay = 2 DECI SECONDS
				if("burst") // close range burst
					src.mode = FLAMER_MODE_BURST
					src.spread_angle = 33
					src.current_projectile.shot_number = 4
					src.chem_divisor = 4 //4 shots per burst
					src.shoot_delay = 1 SECOND
					src.current_projectile.fullauto_valid = 0
				if("semi_auto") // single line (default)
					src.mode = FLAMER_MODE_SINGLE
					src.current_projectile.fullauto_valid = 0
					src.spread_angle = 0
					src.shoot_delay = 1 SECOND
					src.chem_divisor = 1 //1 line per second
				else //default to backtank flamer???
					src.spread_angle = 5
					src.shoot_delay = 2 DECI SECONDS
					src.chem_divisor = 1 //hehehe

			AddComponent(/datum/component/holdertargeting/fullauto, src.shoot_delay)
			set_current_projectile(src.current_projectile)

		if ("change_temperature")
			if (!src.lit)
				return
			var/tempnum = text2num_safe(params["temperature"])
			src.base_temperature = clamp(tempnum, src.min_temperature, src.max_temperature)
			playsound(src, 'sound/misc/lightswitch.ogg', 20, TRUE)

		if ("change_volume")
			var/tempnum = text2num_safe(params["volume"])
			src.amt_chem = clamp(tempnum, FLAMER_MIN_CHEM_AMT, src.amt_chem_max)
			playsound(src, 'sound/effects/valve_creak.ogg', 10, 0.2)

	inventory_counter?.update_percent(src.fueltank?.reagents?.total_volume, src.fueltank?.reagents?.maximum_volume)
	return TRUE

/obj/item/gun/flamethrower/assembled/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.ui_interact(user)

/obj/item/gun/flamethrower/backtank/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.lit = !src.lit
	if(src.lit)
		icon_state = "syndthrower_1"
		item_state = "syndthrower_1"
		user.update_inhands()
		force = 12
		hit_type = DAMAGE_BURN
		processing_items |= src
		boutput(user, SPAN_NOTICE("You activate \the [src]'s pilot light!"))
	else
		icon_state = "syndthrower_0"
		item_state = "syndthrower_0"
		user.update_inhands()
		hit_type = DAMAGE_BLUNT
		force = 6
		boutput(user, SPAN_NOTICE("You extinguish \the [src]'s pilot light!"))
	return

/obj/item/gun/flamethrower/ui_interact(mob/user, datum/tgui/ui)
	if (src.fueltank)
		SEND_SIGNAL(src.fueltank.reagents, COMSIG_REAGENTS_ANALYZED, user)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Flamethrower")
		ui.open()

/obj/item/gun/flamethrower/ui_data(mob/user)
	. = list(
		"lit" = src.lit,
		"maxTemp" = src.max_temperature,
		"minTemp" = src.min_temperature,
		"gasTank" = src.gastank?.ui_describe(),
		"fuelTank" = ui_describe_reagents(src.fueltank),
		"minVolume" = FLAMER_MIN_CHEM_AMT,
		"maxVolume" = src.amt_chem_max,
		"chamberVolume" = src.amt_chem,
	)
	var/gastank_in_range = ((src.gastank in src.contents) || (src.gastank in user.get_equipped_items()))
	var/spraytemp = 20 + T0C
	if(istype(src.fueltank) && gastank_in_range)
		if(src.lit)
			spraytemp = src.base_temperature
		else if(src.fueltank?.reagents)
			spraytemp = src.fueltank.reagents.total_temperature
	.["sprayTemp"] = spraytemp
	switch (src.mode)
		if (FLAMER_MODE_AUTO)
			.["mode"] = "auto"
		if (FLAMER_MODE_BURST)
			.["mode"] = "burst"
		if (FLAMER_MODE_SINGLE)
			.["mode"] = "semi_auto"

/obj/item/gun/flamethrower/move_trigger(var/mob/M, kindof)
	if (..())
		for (var/obj/O in src.contents)
			if (O.move_triggered)
				O.move_trigger(M, kindof)

#undef FLAMER_DEFAULT_TEMP
#undef FLAMER_BACKTANK_TEMP
#undef FLAMER_MIN_TEMP
#undef FLAMER_MAX_TEMP
#undef FLAMER_DEFAULT_CHEM_AMT
#undef FLAMER_BACKTANK_CHEM_AMT
#undef FLAMER_MIN_CHEM_AMT
#undef FLAMER_MAX_CHEM_AMT
#undef FLAMER_MODE_AUTO
#undef FLAMER_MODE_BURST
#undef FLAMER_MODE_SINGLE
#undef FLAMER_MODE_BACKTANK
