TYPEINFO(/obj/machinery/cell_charger)
	mats = 8

/obj/machinery/cell_charger
	name = "cell charger"
	desc = "A charging unit for power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	var/obj/item/cell/charging = null
	var/chargerate = 250 // power per tick
	var/chargelevel = -1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	power_usage = 50

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user)
	if(status & BROKEN)
		return

	if(istype(W, /obj/item/cell))
		if(istype(W, /obj/item/cell/potato)) //kubius potato battery: no recharging by such conventional means
			boutput(user, "The charger is incompatible with the cell.")
			return
		if(charging)
			boutput(user, "There is already a cell in the charger.")
			return
		else
			user.drop_item()
			W.set_loc(src)
			charging = W
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		UpdateIcon()

/obj/machinery/cell_charger/update_icon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(status & (BROKEN|NOPOWER)) )

		var/newlevel = 	round( charging.percent() * 4.0 / 99 )
		//boutput(world, "nl: [newlevel]")

		if(chargelevel != newlevel)
			src.UpdateOverlays(image('icons/obj/power.dmi', "ccharger-o[newlevel]"), "charge")

			chargelevel = newlevel
	else
		src.UpdateOverlays(null, "charge")

/obj/machinery/cell_charger/attack_hand(mob/user)
	add_fingerprint(user)

	if(status & BROKEN)
		return

	if(charging)
		charging.add_fingerprint(user)
		charging.UpdateIcon()
		if(iscarbon(user))
			user.put_in_hand_or_drop(charging)
		else
			charging.set_loc(src.loc)
		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		UpdateIcon()

/obj/machinery/cell_charger/process(mult)
	if (status & BROKEN)
		return
	..()
	//boutput(world, "ccpt [charging] [stat]")
	if(status & NOPOWER)
		if(src.overlays && length(src.overlays))
			src.UpdateIcon()
		return
	if(!charging)
		src.UpdateIcon()
		return

	var/added = charging.give(src.chargerate * mult)
	use_power(added)

	src.UpdateIcon()


/obj/machinery/cell_charger/Exited(Obj, newloc)
	. = ..()
	if(Obj == src.charging)
		src.charging = null

/obj/machinery/cell_charger/get_desc(dist)
	. = ..()
	if(!charging)
		return
	. += "<br><span class='notice'>\The [src] is currently charging \the [src.charging]! It is [round(src.charging.percent())]% charged and has [round(src.charging.charge)]/[src.charging.maxcharge] PUs. </span>"
