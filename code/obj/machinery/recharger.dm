#define CHARGE_AMOUNT 20
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

obj/machinery/recharger
	anchored = 1.0
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	name = "recharger"
	mats = 16
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
						src.dir = dir
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


/obj/machinery/recharger/attackby(obj/item/G as obj, mob/user as mob)
	if (isrobot(user)) return
	if (src.charging)
		return

	//Type validation
	var/obj/item/to_charge = null
	for(var/type in accepted_types)
		if ( istype(G, type) )
			to_charge = G
			continue

	if(to_charge)
		SubscribeToProcess()

		user.drop_item()
		to_charge.set_loc(src)
		if (to_charge.loc == src)
			src.charging = to_charge
			charge_status = STATUS_ACTIVE
			update_icon()
	else
		boutput(user, "<span class='alert'>That [G.name] won't fit in \the [src]!")

/obj/machinery/recharger/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	remove_charging()

/obj/machinery/recharger/proc/remove_charging()
	//Remove the currently charging item
	if (src.charging)
		try
			//Some items will want to update their icons after a charge. Try doing so here
			src.charging:update_icon()
		catch
			//Pass

		src.charging.set_loc(src.loc)
		src.charging = null

		UnsubscribeProcess()
		power_usage = 50
		charge_status = STATUS_INACTIVE
		src.update_icon()

/obj/machinery/recharger/proc/update_icon()
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


/obj/machinery/recharger/process(var/mult)
	// what the fuck
	// why
	// why the fuck
	// why
	// WHY
	// WHYYYYYYYYYYYYYYYYYYYYYYYYYY?Y?Y?Y?Y?Y?Y?Y????!!?G?!G!?
	// WHO
	// WHO DID THIS
	// WHY DID YOU DO THIS
	// die
	if(status & NOPOWER)
		src.icon_state = sprite_empty
		update_icon()
		return


	if (src.charging && charge_status != STATUS_INACTIVE)
		power_usage = ACTIVE_POWER_DRAIN * mult
	else
		power_usage = 50 * mult


	if(charge_status == STATUS_ACTIVE && src.charging)
		try
			//Do the charging - all items to be recharged should implement proc/charge()
			switch(src.charging:charge(CHARGE_AMOUNT * mult))
				if(REPORT_FINISH)
					// Charge complete
					charge_status = STATUS_COMPLETE
					playsound(src, 'sound/machines/ping.ogg', 50)
					update_icon()
				if(REPORT_ERROR)
					// Charge failed - the item does not want to be recharged
					charge_status = STATUS_ERRORED
					src.visible_message("<span class='alert'>[src.charging] is not compatible with \the [src].</span>")
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
					update_icon()

		catch
			//This item was on accepted_items, but didn't have a proc/charge()
			src.visible_message("<span class='alert'>[src] could not interface with \the [src.charging].</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
			charge_status = STATUS_ERRORED
			update_icon()



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
