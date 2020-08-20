/*
CONTAINS:
GETLINEEEEEEEEEEEEEEEEEEEEE
(well not really but it should)

*/

/obj/item/flamethrower/
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
	var/base_temperature = 700
	var/temp_loss_per_tile = 35
	var/obj/item/tank/gastank = null
	contraband = 5 //Heh
	m_amt = 500
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 1
	move_triggered = 1

	proc/get_reagsource(mob/user)
		return null

	New()
		..()
		BLOCK_LARGE
		setItemSpecial(null)

/obj/item/flamethrower/assembled
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
	var/obj/item/reagent_containers/food/drinks/fueltank/fueltank = null
	inventory_counter_enabled = 1

	get_reagsource()
		return fueltank?.reagents

/obj/item/tank/jetpack/backtank
	name = "fuelpack"
	icon_state = "syndflametank"
	desc = "A back mounted fueltank/jetpack system for use with a tactical flamethrower."
	flags = FPRINT | TABLEPASS | CONDUCT | ONBACK | OPENCONTAINER
	var/obj/item/flamethrower/backtank/linkedflamer
	inventory_counter_enabled = 1

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(4000)
		reagents = R
		R.my_atom = src
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
		var/obj/screen/hud/S = over_object
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
			if(alert(usr, "Do you wish to empty internal fuel resivoir?", "Empty fuel", "Yes", "Cancel")=="Yes")
				src.reagents.clear_reagents()
				boutput(usr, "<span class='notice'>You dump out \the [src]'s stored reagents.</span>")
				return
		else
			boutput(usr, "<span class='alert'>There's nothing inside to drain!</span>")

	disposing()
		if(linkedflamer)
			linkedflamer.gastank = null
		..()

/obj/item/flamethrower/backtank
	name = "tactical flamethrower"
	desc = "A military-grade flamethrower, supplied with fuel and propellant from a back-mounted fuelpack."
	icon_state = "syndthrower_0"
	item_state = "syndthrower_0"
	uses_multiple_icon_states = 1
	force = 6
	two_handed = 1

	New()
		..()
		gastank = new /obj/item/tank/jetpack/backtank(src.loc)
		var/obj/item/tank/jetpack/backtank/B = gastank
		B.linkedflamer = src

	get_reagsource(mob/user)
		if(gastank in user.get_equipped_items())
			return gastank?.reagents
		else
			boutput(user, "<span class='alert'>You need to be wearing this flamer's fuelpack to fire it!</span>")

	disposing()
		if(istype(gastank, /obj/item/tank/jetpack/backtank/))
			var/obj/item/tank/jetpack/backtank/B = gastank
			B.linkedflamer = null
		..()

/obj/item/flamethrower/backtank/napalm
	New()
		..()
		gastank.reagents.add_reagent("napalm_goo", 4000)

/obj/item/flamethrower/assembled/loaded/
	icon_state = "flamethrower_oxy_fuel"

/obj/item/flamethrower/assembled/loaded/napalm
	icon_state = "flamethrower_oxy_fuel"

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
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods
	igniter = new /obj/item/device/igniter

/obj/item/flamethrower/assembled/New()
	..()
	welder = new /obj/item/weldingtool
	rod = new /obj/item/rods
	igniter = new /obj/item/device/igniter
	if (fueltank)
		inventory_counter.update_percent(src.fueltank.reagents.total_volume, src.fueltank.reagents.maximum_volume)

/obj/item/flamethrower/assembled/loaded/New()
	if(!fueltank)
		fueltank = new /obj/item/reagent_containers/food/drinks/fueltank
	gastank = new /obj/item/tank/oxygen
	..()

/obj/item/flamethrower/assembled/loaded/napalm/New()
	fueltank = new /obj/item/reagent_containers/food/drinks/fueltank/napalm
	..()

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

/obj/item/flamethrower/assembled/disposing()

	//src.welder = null
	qdel(src.welder)
	qdel(src.rod)
	qdel(src.igniter)
	qdel(src.gastank)
	qdel(src.fueltank)
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
		var/obj/item/flamethrower/assembled/R = new /obj/item/flamethrower/assembled(src.loc)
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

/obj/item/flamethrower/process()
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

/obj/item/flamethrower/assembled/attackby(obj/item/W, mob/user as mob)
	if (!W || user.stat || user.restrained() || user.lying)
		return
	if (istype(W,/obj/item/tank/air) || istype(W,/obj/item/tank/oxygen))
		if(src.gastank)
			boutput(user, "<span class='alert'>There already is an air tank loaded in the flamethrower!</span>")
			return
		src.gastank = W
		W.set_loc(src)
		user.u_equip(W)
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/fuel = "_no_fuel"
		if(src.fueltank)
			fuel = "_fuel"
		icon_state = "flamethrower_oxy[fuel]"

	if (istype(W,/obj/item/reagent_containers/food/drinks/fueltank))
		if(src.fueltank)
			boutput(user, "<span class='alert'>There already is a fuel tank loaded in the flamethrower!</span>")
			return
		src.fueltank = W
		W.set_loc(src)
		user.u_equip(W)
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/oxy = "_no_oxy"
		if(src.gastank)
			oxy = "_oxy"
		icon_state = "flamethrower[oxy]_fuel"

// PantsNote: Flamethrower disassmbly.
	else if (isscrewingtool(W))
		var/obj/item/flamethrower/assembled/S = src
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


	else	return	..()
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, inrange)
	if (inrange)
		return
	user.lastattacked = src
	src.flame_turf(getline(user, target), user, target)


/obj/item/flamethrower/assembled/Topic(href,href_list[])
	if (href_list["close"])
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying || src.loc != usr)
		return
	src.add_dialog(usr)
	if (href_list["light"])
		if(!src.gastank || !src.fueltank)	return
		lit = !(lit)
		if(lit)
			icon_state = "flamethrower_ignite_on"
			item_state = "flamethrower1"
			force = 10
			hit_type = DAMAGE_BURN
			if (!(src in processing_items))
				processing_items.Add(src)
		else
			icon_state = "flamethrower_oxy_fuel"
			force = 3
			hit_type = DAMAGE_BLUNT
		tooltip_rebuild = 1
	if (href_list["removeair"])
		if(!src.gastank)	return
		var/obj/item/tank/A = src.gastank
		A.set_loc(get_turf(src))
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
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
	if (href_list["removefuel"])
		if(!src.fueltank)	return
		var/obj/item/reagent_containers/food/drinks/fueltank/A = src.fueltank
		A.set_loc(get_turf(src))
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
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
	if (href_list["mode"])
		mode = text2num(href_list["mode"])

	src.updateDialog()
	return


/obj/item/flamethrower/assembled/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.add_dialog(user)
	var/dat = text("<TT><B>Flamethrower")
	if(src.gastank && src.fueltank)
		dat += text("(<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>")
	else
		dat += text("</B><BR>")
	if (src.gastank)
		dat += text("<br>Air Tank Pressure: [MIXTURE_PRESSURE(src.gastank.air_contents)] (<A HREF='?src=\ref[src];removeair=1'>Remove Air Tank</A>)<BR>")
	else
		dat += text("<br>No Air Tank Attached!<BR>")
	if(src.fueltank)
		dat += text("<br>Fuel Tank: [src.fueltank.reagents.total_volume] units of fuel mixture (<A HREF='?src=\ref[src];removefuel=1'>Remove Fuel Tank</A>)<BR>")
	else
		dat += text("<br>No Fuel Tank Attached!<BR>")
	dat += "<BR><B>Spray mode:</B> "
	if (mode == 1)
		dat += "<B>Incremental</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=1'>Incremental</a> | "
	if (mode == 2)
		dat += "<B>Stream of 5</B> | "
	else
		dat += "<a href='?src=\ref[src];mode=2'>Stream of 5</a> | "
	if (mode == 3)
		dat += "<B>Stream of 10 (dangerous)</B>"
	else
		dat += "<a href='?src=\ref[src];mode=3'>Stream of 10 (dangerous)</a>"
	dat += text("<BR><br><A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user.Browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return

/obj/item/flamethrower/backtank/attack_self(mob/user as mob)
	lit = !(lit)
	boutput(user, "<span class='notice'>The [src] is now [lit?"lit":"unlit"]</span>")
	if(lit)
		force = 12
		hit_type = DAMAGE_BURN
		if (!(src in processing_items))
			processing_items.Add(src)
	else
		force = 6
		hit_type = DAMAGE_BLUNT
	icon_state = "syndthrower_[lit]"
	item_state = "syndthrower_[lit]"
	user.update_inhands()
	tooltip_rebuild = 1

// gets this from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(var/list/turflist, var/mob/user, var/atom/target) //Passing user and target for logging purposes
	if(operating)	return
	operating = 1
	//get up to 25 reagent
	var/datum/reagents/reagsource = get_reagsource(user)
	if(!reagsource)
		operating = 0
		return
	var/turf/own = get_turf(src)
	var/turfs_to_spray = turflist.len - 1
	if (!turfs_to_spray)
		operating = 0
		return



	var/increment
	var/reagentlefttotransfer
	var/reagentperturf

	if (reagsource.total_volume < 5)
		boutput(usr, "<span class='alert'>The fuel tank is empty.</span>")
		operating = 0
		return

	if(user && target)
		var/turf/T = get_turf(target)
		if (T) //Wire: Fix for Cannot read null.x
			logTheThing("combat", user, null, "fires a flamethrower [log_reagents(reagsource)] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, target))]</I>")
			particleMaster.SpawnSystem(new /datum/particleSystem/chemspray(src.loc, T, reagsource))

	if (mode == 1)
		increment = turfs_to_spray > 1 ? (7.5 / (turfs_to_spray - 1)) : 0
		// a + (a + i) + (a + 2i) + (a + 3i) = T * a +  (T * (T - 1)) / 2
		var/total_needed = increment == 0 ? 12.5 : (turfs_to_spray * (7.5 + (turfs_to_spray - 1) * 0.5 * increment))
		reagentlefttotransfer = min(total_needed,reagsource.total_volume)
		var/ratio = reagentlefttotransfer / total_needed
		increment *= ratio
		//distribute if we can
		reagentperturf = increment == 0 ? reagentlefttotransfer : 5 * ratio
	else if (mode == 2 || mode == 3)
		reagentperturf = mode == 2 ? 5 : 10
		increment = 0
		var/total_needed = turfs_to_spray * reagentperturf
		reagentlefttotransfer = min(total_needed,reagsource.total_volume)
		if (reagentlefttotransfer < total_needed)
			reagentperturf = reagentlefttotransfer / turfs_to_spray
	var/turf/currentturf = null
	var/turf/previousturf = null
	var/halt = 0
	playsound(src.loc, "sound/effects/spray.ogg", 50, 1, 0, 0.75)
	var/spray_temperature = base_temperature
	var/mobHitList

	for(var/turf/T in turflist)
		previousturf = currentturf
		currentturf = T
		if (T == own)
			continue
		//Too little pressure to spray
		var/datum/gas_mixture/environment = currentturf.return_air()
		if(!gastank ||!gastank.air_contents || !environment) break
		if(MIXTURE_PRESSURE(environment) > MIXTURE_PRESSURE(gastank.air_contents))
			if(!previousturf && length(turflist)>1)
				break
			reagentperturf = reagentlefttotransfer
			currentturf = previousturf
			halt = 1
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		//Dense object -> dump the rest at the previous turf.
		if(currentturf.density || istype(currentturf, /turf/space))
			//reagentperturf = reagentlefttotransfer
			currentturf = previousturf
			halt = 1
		var/obj/blob/B = locate() in currentturf
		if(B)
			if (B.opacity)
				reagsource.reaction(B, TOUCH, reagentperturf, 0)
				reagsource.remove_any(reagentperturf)

				halt = 1
		if(previousturf && LinkBlocked(previousturf, currentturf))
			// reagentperturf = reagentlefttotransfer
			currentturf = previousturf
			halt = 1

		// if (halt)
		// break

		reagentlefttotransfer -= reagentperturf
		spray_turf(currentturf,reagentperturf, reagsource)
		reagentperturf += increment
		if(lit)
			//currentturf.hotspot_expose(spray_temperature,2)
			currentturf.reagents.set_reagent_temp(spray_temperature, TRUE)
			spray_temperature = max(0,min(spray_temperature - temp_loss_per_tile, 700))

		var/logString = log_reagents(reagsource)
		for (var/mob/living/carbon/human/theMob in currentturf.contents)
			logTheThing("combat", usr, theMob, "blasts [constructTarget(theMob,"combat")] with a flamethrower [logString] at [log_loc(theMob)].")
			mobHitList += "[key_name(theMob)], "

		inventory_counter?.update_percent(reagsource.total_volume, reagsource.maximum_volume)

		if(halt)
			break
		sleep(0.1 SECONDS)

	operating = 0
	src.updateSelfDialog()
	return 1

/obj/item/flamethrower/proc/spray_turf(turf/target,var/transferamt, var/datum/reagents/reagsource)
	var/rem_ratio = 0.01
	if (mode == 1)
		rem_ratio = 0.02
	if (mode == 3)
		rem_ratio = 0.03
	if(istype(src, /obj/item/flamethrower/backtank))
		rem_ratio = 0.0033 //otherwise we run through our air way too quickly
	var/datum/gas_mixture/air_transfer = gastank.air_contents.remove_ratio(rem_ratio)
	target.assume_air(air_transfer)

	//Transfer reagents
	var/datum/reagents/copied = new/datum/reagents(transferamt)
	copied = reagsource.copy_to(copied, transferamt/reagsource.maximum_volume)
	if(!target.reagents)
		target.create_reagents(50)
	for(var/atom/A in target.contents)
		copied.reaction(A, TOUCH, 0, 0)
		if(A.reagents)
			copied.copy_to(A.reagents, 1)
	copied.reaction(target, TOUCH, 0, 0)
	reagsource.trans_to(target, transferamt, 1, 0)

/obj/item/flamethrower/move_trigger(var/mob/M, kindof)
	if (..())
		for (var/obj/O in contents)
			if (O.move_triggered)
				O.move_trigger(M, kindof)
