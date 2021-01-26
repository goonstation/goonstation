/*
CONTAINS:
GETLINEEEEEEEEEEEEEEEEEEEEE
(well not really but it should)
A Flamethrower
A Flamethrower that uses a backpack fuel/gas tank
A Flamethrower backpack fuel/gas tank
A Flamethrower in various states of assembly

*/
#define FLAMER_DEFAULT_TEMP 700
#define FLAMER_MIN_TEMP T0C
#define FLAMER_MAX_TEMP 1000
#define FLAMER_DEFAULT_CHEM_AMT 10
#define FLAMER_MIN_CHEM_AMT 5
#define FLAMER_MAX_CHEM_AMT 20

/obj/item/gun/flamethrower/
	name = "flamethrower"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "flamethrower_no_oxy_no_fuel"
	item_state = "flamethrower0"
	desc = "You are a firestarter!"
	flags = FPRINT | TABLEPASS | CONDUCT | EXTRADELAY
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 4
	var/mode = 1
	var/processing = 0
	var/operating = 0
	var/throw_amount = 100
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
	/// Is this a fancy combat flamethrower? Boosts melee damage
	var/combat_flamer = 0
	current_projectile = new/datum/projectile/special/shotchem
	contraband = 5 //Heh
	m_amt = 500
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 1
	move_triggered = 1
	/// Burstfire, but actually
	use_shootloop = 1
	refire_delay = 4 DECI SECONDS
	burst_count = 3
	spread_angle = 5

	New()
		..()
		BLOCK_SETUP(BLOCK_LARGE)
		setItemSpecial(null)

	/// Just check if there's a usable air and fuel tank
	canshoot()
		if(istype(src.gastank) && src.gastank.air_contents && istype(src.fueltank) && src.fueltank.reagents)
			return TRUE

	/// check for tank, pressure in tank, fuelltank, fuel in tank, and... then dump the stuff into it!
	process_ammo(var/mob/user)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/T_env = T.return_air()
		if(!src.fueltank)
			boutput(user, "<span class='alert'>This [src] doesn't have a fuel source!</span>")
			return FALSE
		else if(!(src.fueltank in src.contents) && !(src.fueltank in user.get_equipped_items())) // Tank is loaded
			boutput(user, "<span class='alert'>You need to either wear [src]'s fuel source or load it into the weapon!</span>")
			return FALSE
		else if(src.fueltank?.reagents.total_volume <= 0)
			boutput(user, "<span class='alert'>This [src]'s fuel source is empty!</span>")
			return FALSE
		else if(T_env && src.gastank?.air_contents)
			if(MIXTURE_PRESSURE(T_env) > MIXTURE_PRESSURE(gastank.air_contents))
				boutput(user, "<span class='alert'>Not enough pressure in [src]'s gas tank to operate!</span>")
				return FALSE
		return TRUE

		// else if(IN_RANGE(get_turf(src), get_turf(src.fueltank), 1))
		// 	return TRUE

	alter_projectile(var/obj/projectile/P)
		if(!P.proj_data)
			return

		if(!canshoot())
			return

		var/obj/projectile/SD = P.special_data
		var/datum/reagents/FR = src.fueltank.reagents
		var/datum/gas_mixture/GTAC = src.gastank.air_contents

		var/chem_amount = min(src.fueltank?.reagents.total_volume, src.amt_chem)
		var/datum/reagents/chems = new(chem_amount)
		FR.trans_to_direct(chems, chem_amount)
		SD["crossed_turfs"] = list()
		SD["FT_reagents"] = chems
		SD["proj_color"] = chems.get_average_color()

		SD["IS_LIT"] = src.lit //100
		SD["burn_temp"] = src.base_temperature

		var/rem_ratio = 0.008
		var/rem_mod = 1
		if(istype(src, /obj/item/gun/flamethrower/backtank))
			rem_mod = 0.1 //otherwise we run through our air way too quickly
		switch(mode)
			if(1)
				rem_ratio = 0.02 * rem_mod
			if(2)
				rem_ratio = 0.03 * rem_mod
			if(3)
				rem_ratio = 0.10 * rem_mod
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/airgas = unpool(/datum/gas_mixture)
		airgas.volume = 1
		airgas.temperature = SD["burn_temp"]
		airgas.merge(GTAC.remove_ratio(rem_ratio * 0.5))
		T.assume_air(GTAC.remove_ratio(rem_ratio * 0.5))
		SD["airgas"] = airgas

		SD["temp_pct_loss_atom"] = 0.02 // keep the heat, more or less

		/// sets the projectile's chem-transfer percent per tile and speed
		/// More vigor is more fasterer, less chem-transferier, also more cool-off
		switch(mode)
			if(1)
				SD["speed_mult"] = 0.5
				SD["chem_pct_app_tile"] = 0.25
			if(2)
				SD["speed_mult"] = 0.6
				SD["chem_pct_app_tile"] = 0.15
			if(3)
				SD["speed_mult"] = 0.7
				SD["chem_pct_app_tile"] = 0.10
			else
				SD["speed_mult"] = mode
				SD["chem_pct_app_tile"] = mode * 0.01
		inventory_counter?.update_percent(src.fueltank?.reagents?.total_volume, src.fueltank?.reagents?.maximum_volume)
		src.updateSelfDialog()

/obj/item/gun/flamethrower/assembled
	name = "flamethrower"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	desc = "You are a firestarter!"
	flags = FPRINT | TABLEPASS | CONDUCT | EXTRADELAY
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 4
	var/obj/item/weldingtool/welder = null
	var/obj/item/rods/rod = null
	var/obj/item/device/igniter/igniter = null
	inventory_counter_enabled = 1

/obj/item/tank/jetpack/backtank
	name = "fuelpack"
	icon_state = "syndflametank"
	desc = "A back mounted fueltank/jetpack system for use with a tactical flamethrower."
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK | OPENCONTAINER
	var/obj/item/gun/flamethrower/backtank/linkedflamer
	inventory_counter_enabled = 1
	move_triggered = 1

	New()
		..()
		src.create_reagents(4000)
		inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

	on_reagent_change(add)
		..()
		inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

	equipped(mob/user, slot)
		..()
		inventory_counter?.show_count()
	get_desc()
		. = ..()
		if(linkedflamer && (linkedflamer in src.contents))
			. += " There is a flamethrower stowed neatly away in a compartment."

	attackby(obj/item/W, mob/user)
		if(src.loc == user && linkedflamer && W == linkedflamer)
			boutput(user, "<span class='notice'>You stow the the [W] into your fuelpack.</span>")
			user.u_equip(W)
			W.set_loc(src)
			tooltip_rebuild = 1
		else
			..()

	attack_hand(mob/user)
		if(src.loc == user && linkedflamer && (linkedflamer in src.contents))
			boutput(user, "<span class='notice'>You retrieve the [linkedflamer] from your fuelpack.</span>")
			user.put_in_hand_or_drop(linkedflamer)
			tooltip_rebuild = 1
		else
			..()

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	toggle()
		src.on = !( src.on )
		if(src.on)
			boutput(usr, "<span class='notice'>The fuelpack's integrated jetpack is now on</span>")
		else
			boutput(usr, "<span class='notice'>The fuelpack's integrated jetpack is now off</span>")
		return

	MouseDrop(over_object, src_location, over_location)
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

		if(get_dist(src, usr) > 1)
			boutput(usr, "<span class='alert'>You need to be closer to empty \the [src] out!</span>")
			return

		if (!src.reagents)
			boutput(usr, "<span class='alert'>The little cap on the fuel tank is stuck. Uh oh.</span>")
			return

		if(src.reagents.total_volume)
			if(alert(usr, "Do you wish to empty internal fuel reservoir?", "Empty fuel", "Yes", "Cancel")=="Yes")
				src.reagents.clear_reagents()
				boutput(usr, "<span class='notice'>You dump out \the [src]'s stored reagents.</span>")
				return
		else
			boutput(usr, "<span class='alert'>There's nothing inside to drain!</span>")

	disposing()
		linkedflamer?.gastank = null
		..()

/obj/item/gun/flamethrower/backtank
	name = "Vega flamethrower"
	desc = "A military-grade flamethrower, supplied with fuel and propellant from a back-mounted fuelpack. Developed by Almagest Weapons Fabrication."
	icon_state = "syndthrower_0"
	item_state = "syndthrower_0"
	uses_multiple_icon_states = 1
	force = 6
	two_handed = 1
	swappable_tanks = 0 // Backpack or bust
	combat_flamer = 1
	amt_chem_max = 500 // shrug

	New()
		..()
		var/obj/item/tank/jetpack/backtank/B = new /obj/item/tank/jetpack/backtank(src.loc)
		src.gastank = B
		src.fueltank = B
		B.linkedflamer = src

	// get_reagsource(mob/user)
	// 	if(gastank in user.get_equipped_items())
	// 		return gastank?.reagents
	// 	else
	// 		boutput(user, "<span class='alert'>You need to be wearing this flamer's fuelpack to fire it!</span>")

	disposing()
		if(istype(gastank, /obj/item/tank/jetpack/backtank/))
			var/obj/item/tank/jetpack/backtank/B = gastank
			B.linkedflamer = null
		..()
/obj/item/gun/flamethrower/backtank/napalm
	New()
		..()
		gastank.reagents.add_reagent("napalm_goo", 4000)

/obj/item/gun/flamethrower/assembled/New()
	..()
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods
	igniter = new /obj/item/device/igniter
	if (fueltank)
		inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)

/obj/item/gun/flamethrower/assembled/disposing()

	//src.welder = null
	qdel(src.welder)
	qdel(src.rod)
	qdel(src.igniter)
	qdel(src.gastank)
	qdel(src.fueltank)
	..()
	return

/obj/item/gun/flamethrower/assembled/loaded/
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

/obj/item/assembly/weld_rod
	desc = "A welding torch with metal rods attached to the flame tip."
	name = "Welder/Rods Assembly"
	icon_state = "welder-rods"
	item_state = "welder"
	var/obj/item/weldingtool/welder = null
	var/obj/item/rods/rod = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/weld_rod/New()
	..()
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods

/obj/item/assembly/w_r_ignite
	desc = "A welding torch and igniter connected by metal rods."
	name = "Welder/Rods/Igniter Assembly"
	icon_state = "welder-rods-igniter"
	item_state = "welder"
	var/obj/item/weldingtool/welder = null
	var/obj/item/rods/rod = null
	var/obj/item/device/igniter/igniter = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/w_r_ignite/New()
	..()
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods
	igniter = new /obj/item/device/igniter

/obj/item/assembly/weld_rod/disposing()
	//src.welder = null
	qdel(src.welder)
	//src.rod = null
	qdel(src.rod)
	..()
	return


/obj/item/assembly/w_r_ignite/disposing()

	//src.welder = null
	qdel(src.welder)
	//src.rod = null
	qdel(src.rod)
	//src.igniter = null
	qdel(src.igniter)
	..()
	return



/obj/item/assembly/weld_rod/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.welder.set_loc(T)
		src.rod.set_loc(T)
		src.welder.master = null
		src.rod.master = null
		src.welder = null
		src.rod = null

		qdel(src)

	if (istype(W, /obj/item/device/igniter))
		if (src.loc != user)
			boutput(user, "<span class='alert'>You need to be holding [src] to work on it!</span>")
			return
		var/obj/item/device/igniter/I = W
		if (!( I.status ))
			return
		var/obj/item/assembly/weld_rod/S = src
		var/obj/item/assembly/w_r_ignite/R = new /obj/item/assembly/w_r_ignite( user )
		R.welder = S.welder
		S.welder.set_loc(R)
		S.welder.master = R
		R.rod = S.rod
		S.rod.set_loc(R)
		S.rod.master = R
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		I.master = R
		I.layer = initial(I.layer)
		user.u_equip(I)
		I.set_loc(R)
		src.set_loc(R)
		R.igniter = I
		S.welder = null
		S.rod = null
		//S = null
		qdel(S)

	src.add_fingerprint(user)
	return

/obj/item/assembly/w_r_ignite/attackby(obj/item/W as obj, mob/user as mob)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.welder.set_loc(T)
		src.rod.set_loc(T)
		src.igniter.set_loc(T)
		src.welder.master = null
		src.rod.master = null
		src.igniter.master = null
		src.welder = null
		src.rod = null
		src.igniter = null

		qdel(src)
		return
	if (isscrewingtool(W))
		user.show_message("<span class='notice'>The igniter is now secured!</span>", 1)
		var/obj/item/gun/flamethrower/assembled/R = new /obj/item/gun/flamethrower/assembled(src.loc)
		var/obj/item/assembly/w_r_ignite/S = src
		R.welder = S.welder
		S.welder.set_loc(R)
		S.welder.master = R
		R.rod = S.rod
		S.rod.set_loc(R)
		S.rod.master = R
		R.igniter = S.igniter
		S.igniter.set_loc(R)
		S.igniter.master = R
		S.layer = initial(S.layer)
		S.master = R
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		S.set_loc(R)
		S.welder = null
		S.rod = null
		S.igniter = null
		//S = null
		qdel(S)
		return

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
		boutput(user, "<span class='alert'>The thing you want to load into \the [src] doesn't seem to exist! Huh. That's odd. Maybe call 1-800-IM-CODER!</span>")
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
	playsound(get_turf(src), 'sound/weapons/gunload_light.ogg', 25, 1)
	if(ismob(user))
		user.put_in_hand_or_drop(old_thing)
	else
		old_thing.set_loc(get_turf(src))

	/// Hook the thing in our thing up to our thing
	if(. == "tank")
		src.gastank = F
	else
		src.fueltank = F
	src.inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)

	var/fuel = "_no_fuel"
	if(src.fueltank)
		fuel = "_fuel"
	src.icon_state = "flamethrower_oxy[fuel]"
	var/oxy = "_no_oxy"
	if(src.gastank)
		oxy = "_oxy"
	src.icon_state = "flamethrower[oxy]_fuel"

	src.updateSelfDialog()
	SPAWN_DBG(0.5 SECONDS)
		playsound(get_turf(src), "sound/effects/valve_creak.ogg", 40, 1)
	return TRUE


/obj/item/gun/flamethrower/attackby(obj/item/W, mob/user as mob)
	if (!W || user.stat || user.restrained() || user.lying)
		return

	if(istype(src, /obj/item/gun/flamethrower/assembled))
		if (src.swappable_tanks && (istype(W,/obj/item/tank/oxygen) || istype(W,/obj/item/tank/air) || istype(W,/obj/item/tank/anesthetic) || istype(W,/obj/item/reagent_containers/food/drinks/fueltank)))
			if(src.lit)
				boutput(user, "<span class='notice'>You turn off \the [src]'s igniter. Safety first!</span>")
				lit = 0
				force = 3
				hit_type = DAMAGE_BLUNT
			src.swap_any(W, user)

		// PantsNote: Flamethrower disassmbly.
		else if (isscrewingtool(W))
			var/obj/item/gun/flamethrower/assembled/S = src
			if (( S.gastank ))
				return
			var/obj/item/assembly/w_r_ignite/R = new /obj/item/assembly/w_r_ignite( user )
			R.welder = S.welder
			S.welder.set_loc(R)
			S.welder.master = R
			R.rod = S.rod
			S.rod.set_loc(R)
			S.rod.master = R
			R.igniter = S.igniter
			S.igniter.set_loc(R)
			S.igniter.master = R
			S.layer = initial(S.layer)
			user.u_equip(S)
			user.put_in_hand_or_drop(R)
			src.master = R
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(R)
			S.welder = null
			S.rod = null
			S.igniter = null
			//S = null
			qdel(S)
			boutput(user, "<span class='notice'>The igniter is now unsecured!</span>")

	else if (istype(src, /obj/item/gun/flamethrower/backtank))
		if(lit)
			force = 12
			hit_type = DAMAGE_BURN
			processing_items |= src
		else
			force = 6
			hit_type = DAMAGE_BLUNT
		icon_state = "syndthrower_[lit]"
		item_state = "syndthrower_[lit]"
		user.update_inhands()
		tooltip_rebuild = 1

	else
		return	..()

// /obj/item/gun/flamethrower/afterattack(atom/target, mob/user, inrange)
// 	if (inrange)
// 		return
// 	if(istype(user)) user.lastattacked = src
// 	src.flame_turf(getline(user, target), user, target)


/obj/item/gun/flamethrower/Topic(href,href_list[])
	var/mob/user
	if(ismob(usr))
		user = usr
	if (href_list["close"])
		src.remove_dialog(user)
		user.Browse(null, "window=flamethrower")
		return
	if(user.stat || user.restrained() || user.lying || src.loc != user)
		return
	src.add_dialog(user)

	if (href_list["light"])
		if(!src.gastank || !src.fueltank)	return
		lit = !(lit)
		if(lit)
			if (istype(src, /obj/item/gun/flamethrower/backtank))
				icon_state = "syndthrower_1"
				item_state = "syndthrower_1"
				user.update_inhands()
			else
				icon_state = "flamethrower_ignite_on"
				item_state = "flamethrower1"
			force = src.combat_flamer ? 12 : 10
			hit_type = DAMAGE_BURN
			processing_items |= src
		else
			if (istype(src, /obj/item/gun/flamethrower/backtank))
				icon_state = "syndthrower_0"
				item_state = "syndthrower_0"
				user.update_inhands()
			else
				icon_state = "flamethrower_oxy_fuel"
			force = src.combat_flamer ? 6 : 3
			hit_type = DAMAGE_BLUNT
		tooltip_rebuild = 1

	if (href_list["removeair"])
		if(!src.gastank || !src.swappable_tanks)
			return
		var/obj/item/tank/A = src.gastank
		A.set_loc(get_turf(src))
		user.put_in_hand_or_drop(A)
		A.layer = initial(A.layer)
		src.gastank = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/fuel = "_no_fuel"
		if(src.fueltank)
			fuel = "_fuel"
		icon_state = "flamethrower_no_oxy[fuel]"
		item_state = "flamethrower0"
		src.remove_dialog(user)
		user.Browse(null, "window=flamethrower")

	if (href_list["removefuel"])
		if(!src.fueltank || !src.swappable_tanks)
			return
		var/obj/item/reagent_containers/food/drinks/fueltank/A = src.fueltank
		A.set_loc(get_turf(src))
		user.put_in_hand_or_drop(A)
		A.layer = initial(A.layer)
		src.fueltank = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/oxy = "_no_oxy"
		if(src.gastank)
			oxy = "_oxy"
		icon_state = "flamethrower[oxy]_no_fuel"
		item_state = "flamethrower0"
		src.remove_dialog(user)
		user.Browse(null, "window=flamethrower")

	if (href_list["mode"])
		mode = text2num(href_list["mode"])
		playsound(get_turf(src), "sound/effects/valve_creak.ogg", 10, 1)
		switch(src.mode)
			if(1) // short-range, high fire-rate
				src.burst_count = 5
				if(src.combat_flamer)
					src.spread_angle = 20
				else
					src.spread_angle = 35
				src.refire_delay = 1.5 DECI SECONDS
			if(2) // mid-range, low fire-rate
				src.burst_count = 3
				if(src.combat_flamer)
					src.spread_angle = 10
				else
					src.spread_angle = 20
				src.refire_delay = 2.5 DECI SECONDS
			if(3) // semi-auto
				src.burst_count = 1
				if(src.combat_flamer)
					src.spread_angle = 0
				else
					src.spread_angle = 0
				src.refire_delay = 4 DECI SECONDS
			else // ???
				src.burst_count = src.mode
				if(src.combat_flamer)
					src.spread_angle = src.mode
				else
					src.spread_angle = src.mode * 2
				src.refire_delay = src.mode DECI SECONDS

	if (href_list["temp"])
		if (href_list["temp"] == "reset")
			src.base_temperature = FLAMER_DEFAULT_TEMP
		else
			var/tempnum = text2num(href_list["temp"])
			src.base_temperature = clamp(src.base_temperature += tempnum, src.min_temperature, src.max_temperature)

	if (href_list["c_amt"])
		if (href_list["c_amt"] == "reset")
			src.amt_chem = FLAMER_DEFAULT_CHEM_AMT
		else
			var/tempnum = text2num(href_list["c_amt"])
			src.amt_chem = clamp(src.amt_chem += tempnum, FLAMER_MIN_CHEM_AMT, src.amt_chem_max)

	inventory_counter?.update_percent(src.fueltank?.reagents?.total_volume, src.fueltank?.reagents?.maximum_volume)
	src.updateSelfDialog()
	return

/obj/item/gun/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.flamewindow(user)
	return

/obj/item/gun/flamethrower/proc/flamewindow(mob/user)
	src.add_dialog(user)
	var/dat = "<TT><B>Flamethrower - <A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a></B><BR>"
	// var/fueltemp = src.fueltank?.reagents ? (src.fueltank.reagents.total_temperature - T0C) : "NaN"
	var/fueltank_in_range = ((src.fueltank in src.contents) || (src.fueltank in user.get_equipped_items()))
	var/gastank_in_range = ((src.gastank in src.contents) || (src.gastank in user.get_equipped_items()))
	var/spraytemp = "!NaN!"
	if(istype(src.fueltank) && fueltank_in_range)
		if(src.lit)
			spraytemp = src.base_temperature - T0C
		else if(src.fueltank?.reagents)
			spraytemp = src.fueltank.reagents.total_temperature - T0C
	dat += "<BR><B>Spray Temp:</B> [spraytemp]&deg;C<BR>"
	if(src.adjustable_temp && src.lit)
		dat += " <a href='?src=\ref[src];temp=-100'>-100</a> <a href='?src=\ref[src];temp=-10'>-10</a> <a href='?src=\ref[src];temp=-1'>-1</a>"
		dat += " <a href='?src=\ref[src];temp=reset'>reset ([FLAMER_DEFAULT_TEMP - (T0C)]&deg;C)</a>"
		dat += " <a href='?src=\ref[src];temp=1'>+1</a> <a href='?src=\ref[src];temp=10'>+10</a> <a href='?src=\ref[src];temp=100'>+100</a>"

	if (src.gastank && gastank_in_range)
		dat += "<br>Air Tank Pressure: [MIXTURE_PRESSURE(src.gastank.air_contents)]"
		if (src.swappable_tanks)
			dat += " (<A HREF='?src=\ref[src];removeair=1'>Remove Air Tank</A>)"
		dat += "<BR>"
	else
		dat += "<br>No Air Tank Attached!<BR>"

	dat += "<BR><B>Connector Valve Mode:</B> "
	if (mode == 1)
		dat += "<B>Wide Spray</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=1'>Wide Spray</a> | "
	if (mode == 2)
		dat += "<B>Narrow Spray</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=2'>Narrow Spray</a> | "
	if (mode == 3)
		dat += "<B>Semi-Auto</B>"
	else
		dat += "<a href='?src=\ref[src];mode=3'>Semi-Auto</a>"

	if (src.fueltank && fueltank_in_range)
		dat += "<br>Fuel Tank: [src.fueltank.reagents.total_volume] units of fuel mixture"
		if (src.swappable_tanks)
			dat += " (<A HREF='?src=\ref[src];removefuel=1'>Remove Fuel Tank</A>)"
		dat += "<BR>"
	else
		dat += "<br>No Fuel Tank Attached!<BR>"

	dat += "<br>Launcher Chamber Volume: [src.amt_chem]<BR>"
	if(src.adjustable_chem_amt)
		dat += "| <a href='?src=\ref[src];c_amt=-1'>-1</a> | <a href='?src=\ref[src];c_amt=reset'>reset (10)</a> | <a href='?src=\ref[src];c_amt=1'>+1</a> |"

	dat += "<BR><br><A HREF='?src=\ref[src];close=1'>Close</A></TT>"
	user.Browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")

// //gets this from turf.dm turf/dblclick
// /obj/item/gun/flamethrower/proc/flame_turf(var/list/turflist, var/mob/user, var/atom/target) //Passing user and target for logging purposes
// 	if(operating)	return
// 	operating = 1
// 	//get up to 25 reagent
// 	var/datum/reagents/reagsource = get_reagsource(user)
// 	if(!reagsource)
// 		operating = 0
// 		return
// 	var/turf/own = get_turf(src)
// 	var/turfs_to_spray = turflist.len - 1
// 	if (!turfs_to_spray)
// 		operating = 0
// 		return



// 	var/increment
// 	var/reagentlefttotransfer
// 	var/reagentperturf

// 	if (reagsource.total_volume < 5)
// 		boutput(usr, "<span class='alert'>The fuel tank is empty.</span>")
// 		operating = 0
// 		return

// 	if(user && target)
// 		var/turf/T = get_turf(target)
// 		if (T) //Wire: Fix for Cannot read null.x
// 			logTheThing("combat", user, null, "fires a flamethrower [log_reagents(reagsource)] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, target))]</I>")
// 			particleMaster.SpawnSystem(new /datum/particleSystem/chemspray(src.loc, T, reagsource))

// 	if (mode == 1)
// 		increment = turfs_to_spray > 1 ? (7.5 / (turfs_to_spray - 1)) : 0
// 		// a + (a + i) + (a + 2i) + (a + 3i) = T * a +  (T * (T - 1)) / 2
// 		var/total_needed = increment == 0 ? 12.5 : (turfs_to_spray * (7.5 + (turfs_to_spray - 1) * 0.5 * increment))
// 		reagentlefttotransfer = min(total_needed,reagsource.total_volume)
// 		var/ratio = reagentlefttotransfer / total_needed
// 		increment *= ratio
// 		//distribute if we can
// 		reagentperturf = increment == 0 ? reagentlefttotransfer : 5 * ratio
// 	else if (mode == 2 || mode == 3)
// 		reagentperturf = mode == 2 ? 5 : 10
// 		increment = 0
// 		var/total_needed = turfs_to_spray * reagentperturf
// 		reagentlefttotransfer = min(total_needed,reagsource.total_volume)
// 		if (reagentlefttotransfer < total_needed)
// 			reagentperturf = reagentlefttotransfer / turfs_to_spray
// 	var/turf/currentturf = null
// 	var/turf/previousturf = null
// 	var/halt = 0
// 	playsound(src.loc, "sound/effects/spray.ogg", 50, 1, 0, 0.75)
// 	var/spray_temperature = base_temperature
// 	var/mobHitList

// 	for(var/turf/T in turflist)
// 		previousturf = currentturf
// 		currentturf = T
// 		if (T == own)
// 			continue
// 		//Too little pressure to spray
// 		var/datum/gas_mixture/environment = currentturf.return_air()
// 		if(!gastank ||!gastank.air_contents || !environment) break
// 		if(MIXTURE_PRESSURE(environment) > MIXTURE_PRESSURE(gastank.air_contents))
// 			if(!previousturf && length(turflist)>1)
// 				break
// 			reagentperturf = reagentlefttotransfer
// 			currentturf = previousturf
// 			halt = 1
// 		if(!previousturf && length(turflist)>1)
// 			previousturf = get_turf(src)
// 			continue	//so we don't burn the tile we be standin on
// 		//Dense object -> dump the rest at the previous turf.
// 		if(currentturf.density || istype(currentturf, /turf/space))
// 			//reagentperturf = reagentlefttotransfer
// 			currentturf = previousturf
// 			halt = 1
// 		var/obj/blob/B = locate() in currentturf
// 		if(B)
// 			if (B.opacity)
// 				reagsource.reaction(B, TOUCH, reagentperturf, 0)
// 				reagsource.remove_any(reagentperturf)

// 				halt = 1
// 		if(previousturf && LinkBlocked(previousturf, currentturf))
// 			// reagentperturf = reagentlefttotransfer
// 			currentturf = previousturf
// 			halt = 1

// 		// if (halt)
// 		// break

// 		reagentlefttotransfer -= reagentperturf
// 		spray_turf(currentturf,reagentperturf, reagsource)
// 		reagentperturf += increment
// 		if(lit)
// 			currentturf?.reagents?.set_reagent_temp(spray_temperature, TRUE)
// 			spray_temperature = max(0,min(spray_temperature - temp_loss_per_tile, 700))

// 		var/logString = log_reagents(reagsource)
// 		for (var/mob/living/carbon/human/theMob in currentturf.contents)
// 			logTheThing("combat", usr, theMob, "blasts [constructTarget(theMob,"combat")] with a flamethrower [logString] at [log_loc(theMob)].")
// 			mobHitList += "[key_name(theMob)], "

// 		inventory_counter?.update_percent(reagsource.total_volume, reagsource.maximum_volume)

// 		if(halt)
// 			break
// 		sleep(0.1 SECONDS)

// 	operating = 0
// 	src.updateSelfDialog()
// 	return 1

// /obj/item/gun/flamethrower/proc/spray_turf(turf/target,var/transferamt, var/datum/reagents/reagsource)
// 	var/rem_ratio = 0.01
// 	if (mode == 1)
// 		rem_ratio = 0.02
// 	if (mode == 3)
// 		rem_ratio = 0.03
// 	if(istype(src, /obj/item/gun/flamethrower/backtank))
// 		rem_ratio = 0.0033 //otherwise we run through our air way too quickly
// 	var/datum/gas_mixture/air_transfer = gastank.air_contents.remove_ratio(rem_ratio)
// 	target.assume_air(air_transfer)

// 	//Transfer reagents
// 	var/datum/reagents/copied = new/datum/reagents(transferamt)
// 	copied = reagsource.copy_to(copied, transferamt/reagsource.maximum_volume, copy_temperature = 1)
// 	if(!target.reagents)
// 		target.create_reagents(50)
// 	for(var/atom/A in target.contents)
// 		if(!istype(A, /obj/overlay))
// 			copied.reaction(A, TOUCH, 0, 0)
// 			if(A.reagents)
// 				copied.copy_to(A.reagents, 1, copy_temperature = 1)
// 	copied.reaction(target, TOUCH, 0, 0)
// 	reagsource.trans_to(target, transferamt, 1, 0)

/obj/item/gun/flamethrower/move_trigger(var/mob/M, kindof)
	if (..())
		for (var/obj/O in src.contents)
			if (O.move_triggered)
				O.move_trigger(M, kindof)
