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
#define FLAMER_MIN_CHEM_AMT 25
#define FLAMER_MAX_CHEM_AMT 100
#define FLAMER_MODE_AUTO 1
#define FLAMER_MODE_BURST 2
#define FLAMER_MODE_SINGLE 3
#define FLAMER_MODE_BACKTANK 4

#define MODE_TO_STRING(mode) mode == FLAMER_MODE_AUTO ? "auto" : mode == FLAMER_MODE_BURST ? "burst" :  mode == FLAMER_MODE_SINGLE ? "single" :  mode == FLAMER_MODE_BACKTANK ? "backtank" : "error"

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

	New()
		..()
		BLOCK_SETUP(BLOCK_LARGE)
		setItemSpecial(null)
		set_current_projectile(new/datum/projectile/special/shotchem)
		AddComponent(/datum/component/holdertargeting/fullauto, src.shoot_delay, src.shoot_delay, 1)

	/// Just check if there's a usable air and fuel tank
	canshoot()
		if(istype(src.gastank) && src.gastank.air_contents && istype(src.fueltank) && src.fueltank.reagents)
			return TRUE

	log_shoot(mob/user, turf/T, obj/projectile/P)
		logTheThing("combat", user, null, "fires \a [src] ([lit ? "lit, " : ""][MODE_TO_STRING(mode)]) from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, T))]</I>, reagents: [log_reagents(src.fueltank)] with chamber volume [amt_chem]")

	/// allow refilling the fuel tank by simply clicking the reagent dispensers
	afterattack(atom/target, mob/user, flag)
		if(istype(target, /obj/reagent_dispensers) && in_interact_range(src,target))
			if(src.fueltank?.reagents)
				var/obj/tank = target
				tank.reagents.trans_to(src.fueltank, (src.fueltank.reagents.maximum_volume - (src.fueltank.reagents.total_volume)))
				inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)
				boutput(user, "<span class='notice'>You refill the flamethrower's fuel tank.</span>")
				playsound(src.loc, "sound/effects/zzzt.ogg", 50, 1, -6)
				user.lastattacked = target
			else
				boutput(user, "<span class='notice'>Load the fuel tank first!</span>")

	/// check for tank, pressure in tank, fuelltank, fuel in tank, and... then dump the stuff into it!
	process_ammo(var/mob/user)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/T_env = T.return_air()
		if(!src.fueltank)
			boutput(user, "<span class='alert'>[capitalize("[src]")] doesn't have a fuel source!</span>")
			return FALSE
		else if(!(src.fueltank in src.contents) && !(src.fueltank in user.get_equipped_items())) // Tank is loaded
			boutput(user, "<span class='alert'>You need to either wear [src]'s fuel source or load it into the weapon!</span>")
			return FALSE
		else if(src.fueltank?.reagents.total_volume <= 0)
			boutput(user, "<span class='alert'>[capitalize("[src]")]'s fuel source is empty!</span>")
			return FALSE
		else if(T_env && src.gastank?.air_contents && ((src.gastank in src.contents) || (src.gastank in user.get_equipped_items())))
			if(MIXTURE_PRESSURE(T_env) > MIXTURE_PRESSURE(gastank.air_contents))
				boutput(user, "<span class='alert'>Not enough pressure in [src]'s gas tank to operate!</span>")
				return FALSE
		return TRUE

	alter_projectile(var/obj/projectile/P)
		if(!P.proj_data)
			return

		if(!canshoot())
			return

		var/list/P_special_data = P.special_data
		var/datum/reagents/fueltank_reagents = src.fueltank.reagents
		var/datum/gas_mixture/gastank_aircontents = src.gastank.air_contents

		var/chem_amount = min(src.fueltank?.reagents.total_volume, src.amt_chem/chem_divisor)
		var/datum/reagents/chems = new(chem_amount)
		if(!P.reagents)
			P.create_reagents(chem_amount)
		fueltank_reagents.trans_to_direct(P.reagents, chem_amount)

		P_special_data["proj_color"] = chems.get_average_color()
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
		var/datum/gas_mixture/airgas = unpool(/datum/gas_mixture)
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
				P_special_data["speed_mult"] = 0.5
				P_special_data["chem_pct_app_tile"] = 0.25
			if(FLAMER_MODE_SINGLE)
				P_special_data["speed_mult"] = 1
				P_special_data["chem_pct_app_tile"] = 0.10
			else //default to backtank??
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.15
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
	spread_angle = 10
	amt_chem = FLAMER_BACKTANK_CHEM_AMT // About 100 shots
	mode = FLAMER_MODE_BACKTANK
	can_dual_wield = 0
	shoot_delay = 5 DECI SECONDS


	New()
		var/obj/item/tank/jetpack/backtank/B = new /obj/item/tank/jetpack/backtank(src.loc)
		src.gastank = B
		src.fueltank = B
		B.linkedflamer = src
		..()
		src.current_projectile.fullauto_valid = 1
		src.set_current_projectile(src.current_projectile)

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
	qdel(src.welder)
	qdel(src.rod)
	..()
	return


/obj/item/assembly/w_r_ignite/disposing()

	qdel(src.welder)
	qdel(src.rod)
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

/obj/item/gun/flamethrower/assembled/attackby(obj/item/W, mob/user as mob)
	if (!W || user.stat || user.restrained() || user.lying)
		return

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
		qdel(S)
		boutput(user, "<span class='notice'>The igniter is now unsecured!</span>")

	else
		return	..()

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
		playsound(get_turf(src), "sound/misc/lightswitch.ogg", 20, 1)
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
		tooltip_rebuild = 1

	if (href_list["removeair"])
		if(!src.gastank || !src.swappable_tanks)
			return
		var/obj/item/tank/A = src.gastank
		A.set_loc(get_turf(src))
		A.layer = initial(A.layer)
		user.put_in_hand_or_drop(A)
		src.gastank = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/fuel = "_no_fuel"
		if(src.fueltank)
			fuel = "_fuel"
		icon_state = "flamethrower_no_oxy[fuel]"
		item_state = "flamethrower0"
		playsound(get_turf(src), "sound/effects/valve_creak.ogg", 15, 1)
		var/remove_sound = "sound/items/pickup_[max(min(src.w_class,3),1)].ogg"
		if(A?.pickup_sfx)
			remove_sound = A.pickup_sfx
		SPAWN_DBG(0.2 SECONDS)
			if(src)
				playsound(get_turf(src), remove_sound, 30, 1)


	if (href_list["removefuel"])
		if(!src.fueltank || !src.swappable_tanks)
			return
		var/obj/item/reagent_containers/food/drinks/fueltank/A = src.fueltank
		A.set_loc(get_turf(src))
		A.layer = initial(A.layer)
		user.put_in_hand_or_drop(A)
		src.fueltank = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/oxy = "_no_oxy"
		if(src.gastank)
			oxy = "_oxy"
		icon_state = "flamethrower[oxy]_no_fuel"
		item_state = "flamethrower0"
		var/remove_sound = "sound/items/pickup_[max(min(src.w_class,3),1)].ogg"
		if(A?.pickup_sfx)
			remove_sound = A.pickup_sfx
		playsound(get_turf(src), remove_sound, 30, 1)
		SPAWN_DBG(0.5 SECONDS)
			if(src)
				playsound(get_turf(src), "sound/effects/valve_creak.ogg", 15, 1)

	if (href_list["mode"])
		mode = text2num(href_list["mode"])
		playsound(get_turf(src), "sound/effects/valve_creak.ogg", 15, 1)
		src.current_projectile.fullauto_valid = 1
		src.current_projectile.shot_number = 1
		switch(src.mode)
			if(FLAMER_MODE_AUTO) // mid-range automatic
				src.spread_angle = 15
				src.shoot_delay = 2 DECI SECONDS
				src.chem_divisor = 5 //5 shots per second
			if(FLAMER_MODE_BURST) // close range burst
				src.spread_angle = 30
				src.current_projectile.shot_number = 4
				src.chem_divisor = 4 //4 shots per burst
				src.shoot_delay = 1 SECOND
			if(FLAMER_MODE_SINGLE) // single line (default)
				src.current_projectile.fullauto_valid = 0
				src.spread_angle = 0
				src.shoot_delay = 1 SECOND
				src.chem_divisor = 1 //1 line per second
			else //default to backtank flamer???
				src.spread_angle = 5
				src.shoot_delay = 2 DECI SECONDS
				src.chem_divisor = 1 //hehehe

		AddComponent(/datum/component/holdertargeting/fullauto, src.shoot_delay, src.shoot_delay, 1)
		set_current_projectile(src.current_projectile)

	if (href_list["temp"])
		if (href_list["temp"] == "reset")
			src.base_temperature = FLAMER_DEFAULT_TEMP
		else
			var/tempnum = text2num(href_list["temp"])
			src.base_temperature = clamp(src.base_temperature += tempnum, src.min_temperature, src.max_temperature)
		playsound(get_turf(src), "sound/misc/lightswitch.ogg", 20, 1)

	if (href_list["c_amt"])
		if (href_list["c_amt"] == "reset")
			src.amt_chem = FLAMER_DEFAULT_CHEM_AMT
		else
			var/tempnum = text2num(href_list["c_amt"])
			src.amt_chem = clamp(src.amt_chem += tempnum, FLAMER_MIN_CHEM_AMT, src.amt_chem_max)
		playsound(get_turf(src), "sound/effects/valve_creak.ogg", 10, 0.2)

	inventory_counter?.update_percent(src.fueltank?.reagents?.total_volume, src.fueltank?.reagents?.maximum_volume)
	src.updateSelfDialog()
	return

/obj/item/gun/flamethrower/assembled/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.flamewindow(user)
	return

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
		boutput(user, "<span class='notice'>You activate \the [src]'s pilot light!</span>")
	else
		icon_state = "syndthrower_0"
		item_state = "syndthrower_0"
		user.update_inhands()
		hit_type = DAMAGE_BLUNT
		force = 6
		boutput(user, "<span class='notice'>You extinguish \the [src]'s pilot light!</span>")
	return

/obj/item/gun/flamethrower/proc/flamewindow(mob/user)
	src.add_dialog(user)
	var/dat = "<TT><B>Flamethrower - <A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a></B><BR>"
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
		dat += "<B>Full Auto</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=1'>Full Auto</a> | "
	if (mode == 2)
		dat += "<B>Wide Burst</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=2'>Wide Burst</a> | "
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
		dat += "| <a href='?src=\ref[src];c_amt=-5'>-5</a> | <a href='?src=\ref[src];c_amt=-1'>-1</a> | <a href='?src=\ref[src];c_amt=reset'>reset (10)</a> | <a href='?src=\ref[src];c_amt=1'>+1</a> | <a href='?src=\ref[src];c_amt=5'>+5</a> |"

	dat += "<BR><br><A HREF='?src=\ref[src];close=1'>Close</A></TT>"
	user.Browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")

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
