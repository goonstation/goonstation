/*
 * Copyright (C) 2025 DisturbHerb
 *
 * Originally contributed to the 35 Below Project
 * Made available under the terms of the CC BY-NC-SA 3.0
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 *
 * This file was wholly contributed by author(s) who
 * indicated at the time of release an unwillingness
 * to provide this file under any terms except the
 * CreativeCommons license above.
 */

TYPEINFO(/obj/medical_privacy_divider)
	var/list/connects_to_turf = list()
	var/list/connects_to_obj = list()
TYPEINFO_NEW(/obj/medical_privacy_divider)
	. = ..()
	src.connects_to_turf = typecacheof(list(
		/turf/simulated/shuttle/wall,
		/turf/simulated/wall/auto,
		/turf/simulated/wall/auto/reinforced,
		/turf/unsimulated/wall,
	))
	src.connects_to_obj = typecacheof(list(
		/obj/medical_privacy_divider,
		/obj/indestructible/shuttle_corner,
		/obj/window,
	))
/obj/medical_privacy_divider
	name = "medical privacy divider"
	desc = "Sanitary divider curtains to give medbay patients some semblance of privacy. At least, when it comes to being gawked at."
	opacity = TRUE
	density = TRUE
	anchored = ANCHORED
	icon_state = "medical_privacy_divider"
	icon = 'icons/obj/medical_privacy_divider.dmi'
	HELP_MESSAGE_OVERRIDE("Click to open/close the curtains. Use a <b>screwdriver</b> to (un)tighten the castors and (un)anchor the divider.")
	var/tmp/open = FALSE

/obj/medical_privacy_divider/New()
	..()
	src.update_neighbours()
	SPAWN(0)
		src.UpdateIcon()

/obj/medical_privacy_divider/disposing()
	src.update_neighbours()
	. = ..()

/obj/medical_privacy_divider/attack_hand(mob/user)
	. = ..()
	if (can_act(user))
		src.toggle_curtain(user)

/obj/medical_privacy_divider/attackby(obj/item/I, mob/user)
	if (!isscrewingtool(I))
		. = ..()
		return
	playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
	src.anchored = !src.anchored
	src.visible_message(SPAN_ALERT("<b>[user]</b> [src.anchored ? "fastens" : "unfastens"] [src]."))
	src.update_neighbours()
	SPAWN(0)
		src.UpdateIcon()

/obj/medical_privacy_divider/update_icon(...)
	var/typeinfo/obj/medical_privacy_divider/typeinfo = src.get_typeinfo()
	var/connect_bitflag = get_connected_directions_bitflag(typeinfo.connects_to_turf | typeinfo.connects_to_obj, connect_diagonal = FALSE)
	var/base_icon_state = "[initial(src.icon_state)][src.open ? "-open" : ""]"
	src.icon_state = src.anchored ? "[base_icon_state]-[connect_bitflag || 0]" : "[base_icon_state]"

/obj/medical_privacy_divider/proc/toggle_curtain(mob/user)
	if (ON_COOLDOWN(src, "toggle_curtain", 1 SECOND))
		return
	src.open = !src.open
	if (ismob(user))
		src.visible_message(SPAN_NOTICE("[user] [src.open ? "opens" : "closes"] [src]."))
	if (src.open)
		src.opacity = FALSE
		src.density = FALSE
	else
		src.opacity = TRUE
		src.density = TRUE
	src.UpdateIcon()

/obj/medical_privacy_divider/proc/update_neighbours()
	for (var/obj/medical_privacy_divider/medical_privacy_divider in orange(1, src))
		medical_privacy_divider.UpdateIcon()
