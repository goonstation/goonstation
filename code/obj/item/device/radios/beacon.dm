TYPEINFO(/obj/item/device/radio/beacon)
	start_listen_effects = null

/obj/item/device/radio/beacon
	name = "tracking beacon"
	icon_state = "beacon"
	item_state = "signaler"
	desc = "A small beacon that is tracked by the Teleporter Computer, allowing things to be sent to its general location."
	burn_possible = FALSE
	anchored = ANCHORED

	var/list/obj/portals_pointed_at_us

/obj/item/device/radio/beacon/New()
	. = ..()
	START_TRACKING

/obj/item/device/radio/beacon/disposing()
	STOP_TRACKING
	. = ..()

/obj/item/device/radio/beacon/receive_signal()
	return

/obj/item/device/radio/beacon/attack_hand(mob/user)
	if (src.anchored)
		boutput(user, "You need to unscrew the [src.name] from the floor first!")
		return

	. = ..()

/obj/item/device/radio/beacon/proc/add_portal(obj/portal)
	LAZYLISTADD(src.portals_pointed_at_us, portal)
	if (length(src.portals_pointed_at_us) != 1)
		return

	src.AddOverlays(SafeGetOverlayImage("portal_indicator", src.icon, icon_state = "beacon-portal_indicator"), "portal_indicator")
	src.AddOverlays(SafeGetOverlayImage("portal_indicator_light", src.icon, icon_state = "beacon-portal_indicator",
		plane = PLANE_SELFILLUM, blend_mode = BLEND_ADD, alpha = 100), "portal_indicator_light")

/obj/item/device/radio/beacon/proc/remove_portal(obj/portal)
	if (!(portal in src.portals_pointed_at_us))
		return

	LAZYLISTREMOVE(portals_pointed_at_us, portal)
	if(!length(src.portals_pointed_at_us))
		src.ClearSpecificOverlays("portal_indicator", "portal_indicator_light")

/obj/item/device/radio/beacon/attackby(obj/item/I, mob/user)
	if (!isscrewingtool(I))
		return ..()

	if (src.anchored)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		user.visible_message("[user] unscrews [src] from the floor.", "You unscrew [src] from the floor.", "You hear a screwdriver.")
		src.anchored = UNANCHORED

	else if (isturf(src.loc))
		var/turf/T = get_turf(src)
		if (istype(T, /turf/space))
			user.show_text("What exactly are you gonna secure [src] to?", "red")

		else
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user.visible_message("[user] screws [src] to the floor, anchoring it in place.", "You screw [src] to the floor, anchoring it in place.", "You hear a screwdriver.")
			src.anchored = ANCHORED
