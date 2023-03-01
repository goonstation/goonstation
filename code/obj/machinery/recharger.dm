#define CHARGE_AMOUNT 30
#define ACTIVE_POWER_DRAIN 500

#define STATUS_INACTIVE 0
#define STATUS_ACTIVE 1
#define STATUS_ERRORED 2
#define STATUS_COMPLETE 3

#define REPORT_ACTIVE 1
#define REPORT_FINISH 0
#define REPORT_ERROR -1

/*
	This is where the table rechargers live. If you want YOUR item and/or doodad to be rechargeable, follow these simple steps:
	1) Add the type to accepted_types list (not an exact type check, so child items work fine too)
	2) Implement a proc/charge(var/amt) on the item you have, with the below return values:
		0	=	Charging is complete
		1	=	Not finished charging yet
		-1	=	Error. For instance, a child object might not support recharging for whatever reason.

	3) Done.
*/

TYPEINFO(/obj/machinery/recharger)
	mats = 16

/obj/machinery/recharger
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	name = "recharger"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_MULTITOOL
	desc = "An anchored minature recharging device, used to recharge small, hand-held objects that don't require much electrical charge."
	power_usage = 50
	// So we can have rechargers with different sprites, let's use their icon states as variables!
	// This way we won't have to make a new proc altogether just so we can have different sprites
	var/sprite_empty = "recharger0"
	var/sprite_charging = "recharger1"
	var/sprite_complete = "recharger2"
	var/sprite_error = "recharger3"

	var/accepted_types = list( /obj/item/gun/energy, \
								/obj/item/baton, \
								/obj/item/cargotele, \
								/obj/item/mining_tool/power_pick, \
								/obj/item/mining_tool/powerhammer, \
								/obj/item/ammo/power_cell, \
								/obj/item/mining_tool/power_shovel
								)

	var/obj/item/charging = null
	var/charge_amount = 0
	var/charge_status = 0

	//wall rechargers!!
	wall
		icon_state = "wall_recharger0"
		name = "wall mounted recharger"
		desc = "A recharger, refitted to be mounted onto a wall. Handy!"
		sprite_empty = "wall_recharger0"
		sprite_charging = "wall_recharger1"
		sprite_complete = "wall_recharger2"
		sprite_error = "wall_recharger3"

		//this version just autopositions itself onto walls depending what direction it's facing
		sticky
			New()
				..()
				var/turf/T = null
				for (var/dir in cardinal)
					T = get_step(src,dir)
					if (istype(T,/turf/simulated/wall))
						src.set_dir(dir)
						switch(src.dir)
							if(NORTH)
								src.pixel_y = 28
								break
							if(SOUTH)
								src.pixel_y = -22
								break
							if(EAST)
								src.pixel_x = 23
								break
							if(WEST)
								src.pixel_x = -23
								break
						break
				T = null

/obj/machinery/recharger/attackby(obj/item/G, mob/user)
	if (isrobot(user)) return
	if (src.charging)
		return

	var/ret = SEND_SIGNAL(G, COMSIG_CELL_CAN_CHARGE)

	if(ret & CELL_UNCHARGEABLE)
		boutput(user, "<span class='alert'>[G] is not compatible with \the [src]!</span>")
	else if(ret & CELL_CHARGEABLE)
		user.drop_item(G)
		G.set_loc(src)
		if (G.loc == src)
			src.charging = G
			charge_status = STATUS_ACTIVE
			UpdateIcon()
	else
		boutput(user, "<span class='alert'>That [G.name] won't fit in \the [src]!</span>")

/obj/machinery/recharger/attack_hand(mob/user)
	src.add_fingerprint(user)
	remove_charging()

/obj/machinery/recharger/proc/remove_charging()
	//Remove the currently charging item
	if (src.charging)
		try
			//Some items will want to update their icons after a charge. Try doing so here
			src.charging:UpdateIcon()
		catch
			//Pass

		src.charging.set_loc(src.loc)
		src.charging = null

		charge_status = STATUS_INACTIVE
		src.UpdateIcon()

/obj/machinery/recharger/update_icon()
	if (status & NOPOWER || charge_status == STATUS_INACTIVE)
		// No power - show blank machine
		src.icon_state = sprite_empty
	else if(charge_status == STATUS_COMPLETE)
		// Charge is complete - flashing green
		src.icon_state = sprite_complete
	else if (charge_status == STATUS_ACTIVE)
		// Charge NOT complete, but charger working
		src.icon_state = sprite_charging
	else if (charge_status == STATUS_ERRORED)
		// Something wrong with the item we inserted. Report an error
		src.icon_state = sprite_error

/obj/machinery/recharger/get_desc(dist)
	. = ..()
	if(dist > 2)
		return
	. += "<br> <span class='notice'> It is currently recharging:"
	if(charge_status == STATUS_ACTIVE || charge_status == STATUS_COMPLETE)
		var/list/charge = list();
		if(SEND_SIGNAL(src.charging, COMSIG_CELL_CHECK_CHARGE, charge) & CELL_RETURNED_LIST)
			. += "<br> <span class='notice'> \The [charging.name]! Progress: [charge["charge"]]/[charge["max_charge"]]PU </span>"
	else
		. += "<br>Nothing! </span>"
	return


/obj/machinery/recharger/process(var/mult)
	if(status & NOPOWER)
		src.icon_state = sprite_empty
		UpdateIcon()
		return

	if(charge_status == STATUS_ACTIVE && src.charging)
		var/ret = SEND_SIGNAL(src.charging, COMSIG_CELL_CHARGE, CHARGE_AMOUNT * mult)
		if(ret & CELL_FULL)
			// Charge complete
			charge_status = STATUS_COMPLETE
			playsound(src, 'sound/machines/ping.ogg', 50)
			UpdateIcon()
		else if(ret & CELL_UNCHARGEABLE)
			// Charge failed - the item does not want to be recharged
			charge_status = STATUS_ERRORED
			src.visible_message("<span class='alert'>[src.charging] is not compatible with \the [src].</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			UpdateIcon()

	if(src.charging && charge_status != STATUS_INACTIVE)
		use_power(ACTIVE_POWER_DRAIN)
	..()

#undef CHARGE_AMOUNT
#undef ACTIVE_POWER_DRAIN

#undef STATUS_INACTIVE
#undef STATUS_ACTIVE
#undef STATUS_ERRORED
#undef STATUS_COMPLETE

#undef REPORT_ACTIVE
#undef REPORT_FINISH
#undef REPORT_ERROR
