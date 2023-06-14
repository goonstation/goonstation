/*
		Oxygen and plasma tank dispenser
*/

//This stuff is kinda ugly/hard to parse on its own
#define TOTAL_O2_TANKS (o2tanks + length(inserted_o2))
#define TOTAL_PL_TANKS (pltanks + length(inserted_pl))

TYPEINFO(/obj/machinery/dispenser)
	mats = 24

/obj/machinery/dispenser
	desc = "A storage device for gas tanks. Holds 10 plasma and 10 oxygen tanks."
	name = "Tank Storage Unit"
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser-empty"
	density = 1
	status = REQ_PHYSICAL_ACCESS
	var/o2tanks = 10
	var/pltanks = 10
	anchored = ANCHORED
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	//These keep track of tanks that people have inserted back into the machine (for shenanigans!)
	var/list/inserted_o2 = list()
	var/list/inserted_pl = list()

/obj/machinery/dispenser/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(25))
				while(TOTAL_O2_TANKS > 0)
					pop_o2()
				while(TOTAL_PL_TANKS > 0)
					pop_pl()
		else
	return

/obj/machinery/dispenser/blob_act(var/power)
	if (prob(25 * power / 20))
		while(TOTAL_O2_TANKS > 0)
			pop_o2()
		while(TOTAL_PL_TANKS > 0)
			pop_pl()
		qdel(src)

/obj/machinery/dispenser/meteorhit()
	while(TOTAL_O2_TANKS > 0)
		pop_o2()
	while(TOTAL_PL_TANKS > 0)
		pop_pl()
	qdel(src)
	return

/obj/machinery/dispenser/New()
	..()
	UnsubscribeProcess()
	UpdateIcon()

/obj/machinery/dispenser/process()
	return

/obj/machinery/dispenser/disposing()
	for (var/obj/tank as anything in inserted_o2)
		qdel(tank)
	for (var/obj/tank as anything in inserted_pl)
		qdel(tank)
	inserted_o2 = null
	inserted_pl = null
	..()

/obj/machinery/dispenser/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/dispenser/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/tank/oxygen))
		if (TOTAL_O2_TANKS < initial(src.o2tanks))
			inserted_o2 += W
			user.u_equip(W)
			W.set_loc(src)
			user.visible_message("<span class='alert'><b>[user] inserts [W] into [src]!</b></span>")
			UpdateIcon()
			return
	else if (istype(W, /obj/item/tank/plasma))
		if (TOTAL_PL_TANKS < initial(src.pltanks))
			inserted_pl += W
			user.u_equip(W)
			W.set_loc(src)
			user.visible_message("<span class='alert'><b>[user] inserts [W] into [src]!</b></span>")
			UpdateIcon()
			return
	..()

/obj/machinery/dispenser/update_icon()
	if (TOTAL_O2_TANKS > 0 && TOTAL_PL_TANKS > 0)
		icon_state = "dispenser-both"
	else
		icon_state = "dispenser-empty"
		if (TOTAL_O2_TANKS > 0)
			icon_state = "dispenser-oxygen"
		if (TOTAL_PL_TANKS > 0)
			icon_state = "dispenser-plasma"

///Return an inserted oxy tank if avaiable, otherwise a new one if available, null if there's neither
/obj/machinery/dispenser/proc/pop_o2()
	var/obj/item/tank/oxygen/a_tank = null
	if (length(inserted_o2))
		a_tank = inserted_o2[length(inserted_o2)] //LIFO (hopefully)
		inserted_o2.Remove(a_tank)
		a_tank.set_loc(src.loc) //to match behaviour of spawning a new tank
	else if (o2tanks > 0)
		a_tank = new /obj/item/tank/oxygen( src.loc )
		src.o2tanks--
	return a_tank

///Return an inserted plasma tank if avaiable, otherwise a new one if available, null if there's neither
/obj/machinery/dispenser/proc/pop_pl()
	var/obj/item/tank/plasma/a_tank = null
	if (length(inserted_pl))
		a_tank = inserted_pl[length(inserted_pl)] //LIFO (hopefully)
		inserted_pl.Remove(a_tank)
		a_tank.set_loc(src.loc)
	else if (pltanks > 0)
		a_tank = new /obj/item/tank/plasma( src.loc )
		src.pltanks--
	return a_tank

/* INTERFACE */

/obj/machinery/dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TankDispenser", name)
		ui.open()

/obj/machinery/dispenser/ui_data(mob/user)
	. = list(
		"oxygen" = TOTAL_O2_TANKS,
		"plasma" = TOTAL_PL_TANKS,
	)

/obj/machinery/dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("dispense-plasma")
			var/newtank = pop_pl()
			if (newtank)
				use_power(5)
				usr.put_in_hand_or_eject(newtank)
			. = TRUE
		if("dispense-oxygen")
			var/newtank = pop_o2()
			if (newtank)
				use_power(5)
				usr.put_in_hand_or_eject(newtank)
			. = TRUE
	UpdateIcon()

#undef TOTAL_O2_TANKS
#undef TOTAL_PL_TANKS
