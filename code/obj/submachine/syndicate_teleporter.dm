/obj/submachine/syndicate_teleporter
	name = "Syndicate Teleporter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	density = 0
	opacity = 0
	anchored = ANCHORED
	layer = FLOOR_EQUIP_LAYER1
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	proc/teleport(mob/user)
		for_by_tcl(S, /obj/submachine/syndicate_teleporter)
			if(S.id == src.id && S != src)
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					SPAWN(recharge)
						S.recharging = 0
						src.recharging = 0
				return

/obj/item/remote/syndicate_teleporter
	name = "Syndicate Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "Allows one to use a syndicate teleporter when standing on it."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = UNANCHORED
	w_class = W_CLASS_SMALL

	attack_self(mob/user as mob)
		for(var/obj/submachine/syndicate_teleporter/S in get_turf(src))
			S.teleport(user)
