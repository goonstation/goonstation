/obj/decal/poster/flag
	name = "flag"
	desc = "Neat!"
	icon = 'icons/obj/decals/flag.dmi'
	icon_state = "blank"
	/// Must by a type path of `/obj/item/flag`.
	var/starting_flag = /obj/item/flag
	var/obj/item/flag/flag_item = null

	New()
		src.flag_item = new src.starting_flag(src)
		..()

	disposing()
		src.flag_item = null
		..()

	attack_hand(mob/user)
		if (tgui_alert(user, "Are you sure you want to take down the flag?", "Confirmation", list("Take", "Leave")) == "Take")
			src.take_flag(user)

	proc/take_flag(mob/user)
		if (src.flag_item)
			src.flag_item.add_fingerprint(user)
			user.put_in_hand_or_drop(src.flag_item)
			src.flag_item = null
			user.visible_message("<span class='notice'>[user] takes down the [src.name] in [src.loc]!.</span>", "<span class='notice'>You take down the [src.name] in [src.loc]!</span>")
			logTheThing(LOG_STATION, user, "Takes down a flag ([src.name]) in [src.loc] at [log_loc(user)].")
			qdel(src)

	ace
		name = "asexual pride flag"
		icon_state = "ace"
		starting_flag = /obj/item/flag/ace

	aro
		name = "aromantic pride flag"
		icon_state = "aro"
		starting_flag = /obj/item/flag/aro

	bisexual
		name = "bisexual pride flag"
		icon_state = "bisexual"
		starting_flag = /obj/item/flag/bisexual

	demisexual
		name = "demisexual pride flag"
		icon_state = "demisexual"
		starting_flag = /obj/item/flag/demisexual

	genderqueer
		name = "genderqueer pride flag"
		icon_state = "genderqueer"
		starting_flag = /obj/item/flag/genderqueer

	intersex
		name = "intersex pride flag"
		icon_state = "intersex"
		starting_flag = /obj/item/flag/intersex

	lesb //lesbeean prefab thingy - subtle environmental storytelling, you know?
		name = "lesbian pride flag"
		icon_state = "lesb"
		starting_flag = /obj/item/flag/lesb

	nb
		name = "non-binary pride flag"
		icon_state = "nb"
		starting_flag = /obj/item/flag/nb

	pan
		name = "pansexual pride flag"
		icon_state = "pan"
		starting_flag = /obj/item/flag/pan

	polysexual
		name = "polysexual pride flag"
		icon_state = "polysexual"
		starting_flag = /obj/item/flag/polysexual

	progressive
		name = "progressive pride flag"
		icon_state = "progressive"
		starting_flag = /obj/item/flag/progressive

	rainbow
		name = "rainbow flag"
		icon_state = "rainbow"
		starting_flag = /obj/item/flag/rainbow

	trans
		name = "transgender pride flag"
		icon_state = "trans"
		starting_flag = /obj/item/flag/trans

	mlmvinc
		name = "\improper Vincian MLM pride flag"
		icon_state = "mlmvinc"
		starting_flag = /obj/item/flag/mlmvinc

	mlmachi
		name = "\improper Achilean MLM pride flag"
		icon_state = "mlmachi"
		starting_flag = /obj/item/flag/mlmachi
