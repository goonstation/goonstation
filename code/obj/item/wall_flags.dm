ABSTRACT_TYPE(/obj/item/flag)
/obj/item/flag
	name = "flag"
	desc = "Neat! It's folded up, ready to deploy."
	icon = 'icons/obj/items/flag.dmi'
	icon_state = "blank"
	/// Must be a type path of `/obj/decal/poster/flag`.
	var/associated_flag = /obj/decal/poster/flag
	/// Must be a type path of `/obj/item/clothing/suit/flag`
	var/associated_cape = /obj/item/clothing/suit/flag
	var/altside_flag
	burn_possible = FALSE //sigh

	attack_self(mob/user as mob)
		if(altside_flag)
			user.show_text("You flip the [src] around.")
			if(src.loc == user)
				user.u_equip(src)
			qdel(src)
			user.put_in_hand_or_drop(new altside_flag)

	attackby(var/obj/item/cable_coil/coil, mob/user)
		if (istype(coil))
			coil.use(1)
			qdel(src)
			user.put_in_hand_or_drop(new src.associated_cape())
			boutput(user, "You tie the flag into a cape.")
			return
		. = ..()

	afterattack(turf/simulated/T, mob/user)
		if (locate(/obj/decal/poster/flag) in T)
			return
		if (istype(T, /turf/simulated/wall/) || istype(T, /turf/unsimulated/wall))
			var/obj/decal/poster/flag/new_flag = new src.associated_flag(T)
			qdel(new_flag.flag_item)
			new_flag.flag_item = src
			user.u_equip(src)
			src.set_loc(new_flag)
			logTheThing(LOG_STATION, user, "Hangs up a flag ([new_flag.name]) in [T] at [log_loc(user)].")
			user.visible_message("<span class='notice'>[user] hangs up a [new_flag.name] in [T]!.</span>", "<span class='notice'>You hang up a [new_flag.name] in [T]!</span>")

	ace
		name = "asexual pride flag"
		icon_state = "ace"
		associated_flag = /obj/decal/poster/flag/ace
		associated_cape = /obj/item/clothing/suit/flag/ace

	aro
		name = "aromantic pride flag"
		icon_state = "aro"
		associated_flag = /obj/decal/poster/flag/aro
		associated_cape = /obj/item/clothing/suit/flag/aro

	bisexual
		name = "bisexual pride flag"
		icon_state = "bisexual"
		associated_flag = /obj/decal/poster/flag/bisexual
		associated_cape = /obj/item/clothing/suit/flag/bisexual

	demisexual
		name = "demisexual pride flag"
		icon_state = "demisexual"
		associated_flag = /obj/decal/poster/flag/demisexual
		associated_cape = /obj/item/clothing/suit/flag/demisexual

	genderqueer
		name = "genderqueer pride flag"
		icon_state = "genderqueer"
		associated_flag = /obj/decal/poster/flag/genderqueer
		associated_cape = /obj/item/clothing/suit/flag/genderqueer

	intersex
		name = "intersex pride flag"
		icon_state = "intersex"
		associated_flag = /obj/decal/poster/flag/intersex
		associated_cape = /obj/item/clothing/suit/flag/intersex

	lesb
		name = "lesbian pride flag"
		icon_state = "lesb"
		associated_flag = /obj/decal/poster/flag/lesb
		associated_cape = /obj/item/clothing/suit/flag/lesb

	nb
		name = "non-binary pride flag"
		icon_state = "nb"
		associated_flag = /obj/decal/poster/flag/nb
		associated_cape = /obj/item/clothing/suit/flag/nb

	pan
		name = "pansexual pride flag"
		icon_state = "pan"
		associated_flag = /obj/decal/poster/flag/pan
		associated_cape = /obj/item/clothing/suit/flag/pan

	polysexual
		name = "polysexual pride flag"
		icon_state = "polysexual"
		associated_flag = /obj/decal/poster/flag/polysexual
		associated_cape = /obj/item/clothing/suit/flag/polysexual

	progressive
		name = "progressive pride flag"
		icon_state = "progressive"
		associated_flag = /obj/decal/poster/flag/progressive
		associated_cape = /obj/item/clothing/suit/flag/progressive
		altside_flag = /obj/item/flag/rainbow

	rainbow
		name = "rainbow flag"
		icon_state = "rainbow"
		associated_flag = /obj/decal/poster/flag/rainbow
		associated_cape = /obj/item/clothing/suit/flag/rainbow
		altside_flag = /obj/item/flag/progressive

	trans
		name = "transgender pride flag"
		icon_state = "trans"
		associated_flag = /obj/decal/poster/flag/trans
		associated_cape = /obj/item/clothing/suit/flag/trans

	mlmvinc
		name = "\improper Vincian MLM pride flag"
		icon_state = "mlmvinc"
		associated_flag = /obj/decal/poster/flag/mlmvinc
		altside_flag = /obj/item/flag/mlmachi
		associated_cape = /obj/item/clothing/suit/flag/mlmvinc

	mlmachi
		name = "\improper Achilean MLM pride flag"
		icon_state = "mlmachi"
		associated_flag = /obj/decal/poster/flag/mlmachi
		altside_flag = /obj/item/flag/mlmvinc
		associated_cape = /obj/item/clothing/suit/flag/mlmachi

ABSTRACT_TYPE(/obj/item/clothing/suit/flag)
/obj/item/clothing/suit/flag
	wear_layer = MOB_BACK_LAYER + 0.2
	desc = "A makeshift cape made out of a pride flag. Still creased, of course."
	icon = 'icons/obj/items/flag.dmi'
	burn_possible = FALSE
	c_flags = ONBACK
	var/altside_cape

	attack_self(mob/user as mob)
		if(src.altside_cape)
			user.show_text("You flip the [src] around.")
			if(src.loc == user)
				user.u_equip(src)
			qdel(src)
			user.put_in_hand_or_drop(new src.altside_cape())

	bisexual
		name = "bisexual pride cape"
		icon_state = "bisexual-cape"

	lesb
		name = "lesbian pride cape"
		icon_state = "lesb-cape"

	rainbow
		name = "rainbow cape"
		icon_state = "rainbow-cape"
		altside_cape = /obj/item/clothing/suit/flag/progressive

	progressive
		name = "progressive pride cape"
		icon_state = "progressive-cape"
		altside_cape = /obj/item/clothing/suit/flag/rainbow

	polysexual
		name = "polysexual pride cape"
		icon_state = "polysexual-cape"

	pan
		name = "pansexual pride cape"
		icon_state = "pan-cape"

	intersex
		name = "intersex pride cape"
		icon_state = "intersex-cape"

	trans
		name = "transgender pride cape"
		icon_state = "trans-cape"

	nb
		name = "non-binary pride cape"
		icon_state = "nb-cape"

	demisexual
		name = "demisexual pride cape"
		icon_state = "demisexual-cape"

	genderqueer
		name = "genderqueer pride cape"
		icon_state = "genderqueer-cape"

	mlmvinc
		name = "\improper Vincian MLM pride cape"
		icon_state = "mlmvinc-cape"
		altside_cape = /obj/item/clothing/suit/flag/mlmachi

	mlmachi
		name = "\improper Achilean MLM pride cape"
		icon_state = "mlmachi-cape"
		altside_cape = /obj/item/clothing/suit/flag/mlmvinc

	ace
		name = "asexual pride flag"
		icon_state = "ace-cape"

	aro
		name = "aromantic pride flag"
		icon_state = "aro-cape"
