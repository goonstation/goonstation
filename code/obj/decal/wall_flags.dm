/obj/decal/poster/flag
	name = "flag"
	desc = "Neat!"
	icon = 'icons/obj/decals/flag.dmi'
	icon_state = "blank"
	/// Must by a type path of `/obj/item/flag`.
	var/starting_flag = /obj/item/flag
	var/obj/item/flag/flag_item = null

/obj/decal/poster/flag/New()
	src.flag_item = new src.starting_flag(src)
	..()

/obj/decal/poster/flag/disposing()
	src.flag_item = null
	..()

/obj/decal/poster/flag/attack_hand(mob/user)
	if (!(tgui_alert(user, "Are you sure you want to take down the flag?", "Confirmation", list("Take", "Leave")) == "Take"))
		return
	src.take_flag(user)

/obj/decal/poster/flag/proc/take_flag(mob/user)
	if (src.flag_item)
		src.flag_item.add_fingerprint(user)
		user.put_in_hand_or_drop(src.flag_item)
		src.flag_item = null
	user.visible_message(SPAN_NOTICE("[user] takes down the [src.name] in [src.loc]!"), SPAN_NOTICE("You take down the [src.name] in [src.loc]!"))
	logTheThing(LOG_STATION, user, "Takes down a flag ([src.name]) in [src.loc] at [log_loc(user)].")
	qdel(src)

/obj/decal/poster/flag/ace
	name = "asexual pride flag"
	icon_state = "ace"
	starting_flag = /obj/item/flag/ace

/obj/decal/poster/flag/aro
	name = "aromantic pride flag"
	icon_state = "aro"
	starting_flag = /obj/item/flag/aro

/obj/decal/poster/flag/bisexual
	name = "bisexual pride flag"
	icon_state = "bisexual"
	starting_flag = /obj/item/flag/bisexual

/obj/decal/poster/flag/demisexual
	name = "demisexual pride flag"
	icon_state = "demisexual"
	starting_flag = /obj/item/flag/demisexual

/obj/decal/poster/flag/genderqueer
	name = "genderqueer pride flag"
	icon_state = "genderqueer"
	starting_flag = /obj/item/flag/genderqueer

/obj/decal/poster/flag/intersex
	name = "intersex pride flag"
	icon_state = "intersex"
	starting_flag = /obj/item/flag/intersex

/obj/decal/poster/flag/lesb //lesbeean prefab thingy - subtle environmental storytelling, you know?
	name = "lesbian pride flag"
	icon_state = "lesb"
	starting_flag = /obj/item/flag/lesb

/obj/decal/poster/flag/nb
	name = "non-binary pride flag"
	icon_state = "nb"
	starting_flag = /obj/item/flag/nb

/obj/decal/poster/flag/pan
	name = "pansexual pride flag"
	icon_state = "pan"
	starting_flag = /obj/item/flag/pan

/obj/decal/poster/flag/polysexual
	name = "polysexual pride flag"
	icon_state = "polysexual"
	starting_flag = /obj/item/flag/polysexual

/obj/decal/poster/flag/progressive
	name = "progressive pride flag"
	icon_state = "progressive"
	starting_flag = /obj/item/flag/progressive

/obj/decal/poster/flag/rainbow
	name = "rainbow flag"
	icon_state = "rainbow"
	starting_flag = /obj/item/flag/rainbow

/obj/decal/poster/flag/trans
	name = "transgender pride flag"
	icon_state = "trans"
	starting_flag = /obj/item/flag/trans

/obj/decal/poster/flag/mlmvinc
	name = "\improper Vincian MLM pride flag"
	icon_state = "mlmvinc"
	starting_flag = /obj/item/flag/mlmvinc

/obj/decal/poster/flag/mlmachi
	name = "\improper Achilean MLM pride flag"
	icon_state = "mlmachi"
	starting_flag = /obj/item/flag/mlmachi
