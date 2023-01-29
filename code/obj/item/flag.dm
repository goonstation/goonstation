/obj/item/flag
	name = "flag"
	desc = "Neat! It's folded up, ready to deploy."
	icon = 'icons/obj/items/flag.dmi'
	icon_state = "blank"

	afterattack(turf/simulated/T, mob/user)
		if (locate(/obj/decal/poster/flag, T))
			return
		if (istype(T, /turf/simulated/wall/))
			var/obj/decal/poster/flag/new_flag = new(T)
			new_flag.name = src.name
			new_flag.icon_state = src.icon_state
			new_flag.flag_item = src
			user.u_equip(src)
			src.loc = new_flag
			logTheThing(LOG_STATION, user, "Hangs up a flag ([new_flag.name]) in [T] at [log_loc(user)].")
			user.visible_message("<span class='notice'>[user] hangs up a [new_flag.name] in [T]!.</span>", "<span class='notice'>You hang up a [new_flag.name] in [T]!</span>")

	ace
		name = "asexual pride flag"
		icon_state = "ace"

	aro
		name = "aromantic pride flag"
		icon_state = "aro"

	bisexual
		name = "bisexual pride flag"
		icon_state = "bisexual"

	demisexual
		name = "demisexual pride flag"
		icon_state = "demisexual"

	genderqueer
		name = "genderqueer pride flag"
		icon_state = "genderqueer"

	intersex
		name = "intersex pride flag"
		icon_state = "intersex"

	lesb
		name = "lesbian pride flag"
		icon_state = "lesb"

	nb
		name = "non-binary pride flag"
		icon_state = "nb"

	pan
		name = "pansexual pride flag"
		icon_state = "pan"

	polysexual
		name = "polysexual pride flag"
		icon_state = "polysexual"

	progressive
		name = "progressive pride flag"
		icon_state = "progressive"

	rainbow
		name = "rainbow flag"
		icon_state = "rainbow"

	trans
		name = "transgender pride flag"
		icon_state = "trans"
