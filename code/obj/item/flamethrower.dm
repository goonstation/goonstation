/*
CONTAINS:
GETLINEEEEEEEEEEEEEEEEEEEEE
(well not really but it should)

*/


/obj/item/flamethrower
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
	inventory_counter_enabled = 1
	var/mode = 1
	var/processing = 0
	var/operating = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/base_temperature = 700
	var/temp_loss_per_tile = 35
	var/obj/item/weldingtool/part1 = null
	var/obj/item/rods/part2 = null
	var/obj/item/device/igniter/part3 = null
	var/obj/item/tank/part4 = null
	var/obj/item/reagent_containers/food/drinks/fueltank/part5 = null
	contraband = 5 //Heh
	m_amt = 500
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 1
	move_triggered = 1

	New()
		..()
		BLOCK_LARGE

/obj/item/flamethrower/loaded/
	icon_state = "flamethrower_oxy_fuel"

/obj/item/flamethrower/loaded/napalm
	icon_state = "flamethrower_oxy_fuel"

// PantsNote: Dumping this shit in here until I'm sure it works.

/obj/item/assembly/weld_rod
	desc = "A welding torch with metal rods attached to the flame tip."
	name = "Welder/Rods Assembly"
	icon_state = "welder-rods"
	item_state = "welder"
	var/obj/item/weldingtool/part1 = null
	var/obj/item/rods/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/weld_rod/New()
	part1 = new /obj/item/weldingtool
	part2 = new /obj/item/rods

/obj/item/assembly/w_r_ignite
	desc = "A welding torch and igniter connected by metal rods."
	name = "Welder/Rods/Igniter Assembly"
	icon_state = "welder-rods-igniter"
	item_state = "welder"
	var/obj/item/weldingtool/part1 = null
	var/obj/item/rods/part2 = null
	var/obj/item/device/igniter/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/w_r_ignite/New()
	part1 = new /obj/item/weldingtool
	part2 = new /obj/item/rods
	part3 = new /obj/item/device/igniter

/obj/item/flamethrower/New()
	part1 = new /obj/item/weldingtool
	part2 = new /obj/item/rods
	part3 = new /obj/item/device/igniter
	..()
	if (part5)
		inventory_counter.update_percent(src.part5.reagents.total_volume, src.part5.reagents.maximum_volume)
	setItemSpecial(null)

/obj/item/flamethrower/loaded/New()
	if (!part5)
		part5 = new /obj/item/reagent_containers/food/drinks/fueltank
	part4 = new /obj/item/tank/oxygen
	..()

/obj/item/flamethrower/loaded/napalm/New()
	part5 = new /obj/item/reagent_containers/food/drinks/fueltank/napalm
	..()

/obj/item/assembly/weld_rod/disposing()
	//src.part1 = null
	qdel(src.part1)
	//src.part2 = null
	qdel(src.part2)
	..()
	return


/obj/item/assembly/w_r_ignite/disposing()

	//src.part1 = null
	qdel(src.part1)
	//src.part2 = null
	qdel(src.part2)
	//src.part3 = null
	qdel(src.part3)
	..()
	return

/obj/item/flamethrower/disposing()

	//src.part1 = null
	qdel(src.part1)
	qdel(src.part2)
	qdel(src.part3)
	qdel(src.part4)
	qdel(src.part5)
	..()
	return

/obj/item/assembly/weld_rod/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

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
		R.part1 = S.part1
		S.part1.set_loc(R)
		S.part1.master = R
		R.part2 = S.part2
		S.part2.set_loc(R)
		S.part2.master = R
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		I.master = R
		I.layer = initial(I.layer)
		user.u_equip(I)
		I.set_loc(R)
		src.set_loc(R)
		R.part3 = I
		S.part1 = null
		S.part2 = null
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
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part3.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part3.master = null
		src.part1 = null
		src.part2 = null
		src.part3 = null

		qdel(src)
		return
	if (isscrewingtool(W))
		user.show_message("<span class='notice'>The igniter is now secured!</span>", 1)
		var/obj/item/flamethrower/R = new /obj/item/flamethrower(src.loc)
		var/obj/item/assembly/w_r_ignite/S = src
		R.part1 = S.part1
		S.part1.set_loc(R)
		S.part1.master = R
		R.part2 = S.part2
		S.part2.set_loc(R)
		S.part2.master = R
		R.part3 = S.part3
		S.part3.set_loc(R)
		S.part3.master = R
		S.layer = initial(S.layer)
		S.master = R
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		S.set_loc(R)
		S.part1 = null
		S.part2 = null
		S.part3 = null
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

/obj/item/flamethrower/attackby(obj/item/W, mob/user as mob)
	if (!W || user.stat || user.restrained() || user.lying)
		return
	if (istype(W,/obj/item/tank/air) || istype(W,/obj/item/tank/oxygen))
		if(src.part4)
			boutput(user, "<span class='alert'>There already is an air tank loaded in the flamethrower!</span>")
			return
		src.part4 = W
		W.set_loc(src)
		user.u_equip(W)
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/fuel = "_no_fuel"
		if(src.part5)
			fuel = "_fuel"
		icon_state = "flamethrower_oxy[fuel]"

	if (istype(W,/obj/item/reagent_containers/food/drinks/fueltank))
		if(src.part5)
			boutput(user, "<span class='alert'>There already is a fuel tank loaded in the flamethrower!</span>")
			return
		src.part5 = W
		W.set_loc(src)
		user.u_equip(W)
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/oxy = "_no_oxy"
		if(src.part4)
			oxy = "_oxy"
		icon_state = "flamethrower[oxy]_fuel"

// PantsNote: Flamethrower disassmbly.
	else if (isscrewingtool(W))
		var/obj/item/flamethrower/S = src
		if (( S.part4 ))
			return
		var/obj/item/assembly/w_r_ignite/R = new /obj/item/assembly/w_r_ignite( user )
		R.part1 = S.part1
		S.part1.set_loc(R)
		S.part1.master = R
		R.part2 = S.part2
		S.part2.set_loc(R)
		S.part2.master = R
		R.part3 = S.part3
		S.part3.set_loc(R)
		S.part3.master = R
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		S.part1 = null
		S.part2 = null
		S.part3 = null
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


/obj/item/flamethrower/Topic(href,href_list[])
	if (href_list["close"])
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying || src.loc != usr)
		return
	src.add_dialog(usr)
	if (href_list["light"])
		if(!src.part4 || !src.part5)	return
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
		if(!src.part4)	return
		var/obj/item/tank/A = src.part4
		A.set_loc(get_turf(src))
		A.layer = initial(A.layer)
		src.part4 = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/fuel = "_no_fuel"
		if(src.part5)
			fuel = "_fuel"
		icon_state = "flamethrower_no_oxy[fuel]"
		item_state = "flamethrower0"
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
	if (href_list["removefuel"])
		if(!src.part5)	return
		var/obj/item/reagent_containers/food/drinks/fueltank/A = src.part5
		A.set_loc(get_turf(src))
		A.layer = initial(A.layer)
		src.part5 = null
		lit = 0
		force = 3
		hit_type = DAMAGE_BLUNT
		var/oxy = "_no_oxy"
		if(src.part4)
			oxy = "_oxy"
		icon_state = "flamethrower[oxy]_no_fuel"
		item_state = "flamethrower0"
		src.remove_dialog(usr)
		usr.Browse(null, "window=flamethrower")
	if (href_list["mode"])
		mode = text2num(href_list["mode"])

	src.updateDialog()
	return


/obj/item/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	src.add_dialog(user)
	var/dat = text("<TT><B>Flamethrower")
	if(src.part4 && src.part5)
		dat += text("(<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>")
	else
		dat += text("</B><BR>")
	if (src.part4)
		dat += text("<br>Air Tank Pressure: [MIXTURE_PRESSURE(src.part4.air_contents)] (<A HREF='?src=\ref[src];removeair=1'>Remove Air Tank</A>)<BR>")
	else
		dat += text("<br>No Air Tank Attached!<BR>")
	if(src.part5)
		dat += text("<br>Fuel Tank: [src.part5.reagents.total_volume] units of fuel mixture (<A HREF='?src=\ref[src];removefuel=1'>Remove Fuel Tank</A>)<BR>")
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


// gets this from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(var/list/turflist, var/mob/user, var/atom/target) //Passing user and target for logging purposes
	if(operating)	return
	operating = 1
	//get up to 25 reagent
	if(!part5 || !part5.reagents)
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

	if (part5.reagents.total_volume < 5)
		boutput(usr, "<span class='alert'>The fuel tank is empty.</span>")
		operating = 0
		return

	if(user && target)
		var/turf/T = get_turf(target)
		if (T) //Wire: Fix for Cannot read null.x
			logTheThing("combat", user, null, "fires a flamethrower [log_reagents(part5)] from [log_loc(user)], vector: ([T.x - user.x], [T.y - user.y]), dir: <I>[dir2text(get_dir(user, target))]</I>")
			particleMaster.SpawnSystem(new /datum/particleSystem/chemspray(src.loc, T, part5.reagents))

	if (mode == 1)
		increment = turfs_to_spray > 1 ? (7.5 / (turfs_to_spray - 1)) : 0
		// a + (a + i) + (a + 2i) + (a + 3i) = T * a +  (T * (T - 1)) / 2
		var/total_needed = increment == 0 ? 12.5 : (turfs_to_spray * (7.5 + (turfs_to_spray - 1) * 0.5 * increment))
		reagentlefttotransfer = min(total_needed,part5.reagents.total_volume)
		var/ratio = reagentlefttotransfer / total_needed
		increment *= ratio
		//distribute if we can
		reagentperturf = increment == 0 ? reagentlefttotransfer : 5 * ratio
	else if (mode == 2 || mode == 3)
		reagentperturf = mode == 2 ? 5 : 10
		increment = 0
		var/total_needed = turfs_to_spray * reagentperturf
		reagentlefttotransfer = min(total_needed,part5.reagents.total_volume)
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
		if(!part4 ||!part4.air_contents || !environment) break
		if(MIXTURE_PRESSURE(environment) > MIXTURE_PRESSURE(part4.air_contents))
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
				part5.reagents.reaction(B, TOUCH, reagentperturf, 0)
				part5.reagents.remove_any(reagentperturf)

				halt = 1
		if(previousturf && LinkBlocked(previousturf, currentturf))
			// reagentperturf = reagentlefttotransfer
			currentturf = previousturf
			halt = 1

		// if (halt)
		// break

		reagentlefttotransfer -= reagentperturf
		spray_turf(currentturf,reagentperturf)
		reagentperturf += increment
		if(lit)
			//currentturf.hotspot_expose(spray_temperature,2)
			currentturf.reagents.set_reagent_temp(spray_temperature, TRUE)
			spray_temperature = max(0,min(spray_temperature - temp_loss_per_tile, 700))

		var/logString = log_reagents(part5)
		for (var/mob/living/carbon/human/theMob in currentturf.contents)
			logTheThing("combat", usr, theMob, "blasts [constructTarget(theMob,"combat")] with a flamethrower [logString] at [log_loc(theMob)].")
			mobHitList += "[key_name(theMob)], "

		inventory_counter.update_percent(src.part5.reagents.total_volume, src.part5.reagents.maximum_volume)

		if(halt)
			break
		sleep(0.1 SECONDS)

	operating = 0
	src.updateSelfDialog()
	return 1

/obj/item/flamethrower/proc/spray_turf(turf/target,var/transferamt)
	var/rem_ratio = 0.01
	if (mode == 1)
		rem_ratio = 0.02
	if (mode == 3)
		rem_ratio = 0.03
	var/datum/gas_mixture/air_transfer = part4.air_contents.remove_ratio(rem_ratio)
	target.assume_air(air_transfer)

	//Transfer reagents
	var/datum/reagents/copied = new/datum/reagents(transferamt)
	copied = part5.reagents.copy_to(copied, transferamt/part5.reagents.maximum_volume)
	if(!target.reagents)
		target.create_reagents(50)
	for(var/atom/A in target.contents)
		copied.reaction(A, TOUCH, 0, 0)
		if(A.reagents)
			copied.copy_to(A.reagents, 1)
	copied.reaction(target, TOUCH, 0, 0)
	part5.reagents.trans_to(target, transferamt, 1, 0)

/obj/item/flamethrower/move_trigger(var/mob/M, kindof)
	if (..())
		for (var/obj/O in contents)
			if (O.move_triggered)
				O.move_trigger(M, kindof)
