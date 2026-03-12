ABSTRACT_TYPE(/obj/item/flag)
/obj/item/flag
	name = "flag"
	desc = "Neat! It's folded up, ready to deploy."
	icon = 'icons/obj/items/flag.dmi'
	icon_state = "blank"
	burn_possible = FALSE //sigh
	/// Must be a type path of `/obj/decal/poster/flag`.
	var/associated_flag = null
	/// Some flags can be used in-hand to switch to an alternate version. Must be a type path of `/obj/decal/poster/flag`.
	var/altside_flag = null
	/// Some flags can be converted into capes; clothing items for the suit or back slot. Must be a type path of `/obj/item/clothing/suit/flag`
	var/associated_cape = null

/obj/item/flag/attack_self(mob/user)
	if (!ispath(src.altside_flag, /obj/item/flag))
		. = ..()
		return
	if (src.loc == user)
		user.u_equip(src)
	user.show_text("You flip [src] around.")
	user.put_in_hand_or_drop(new src.altside_flag)
	qdel(src)

/obj/item/flag/attackby(obj/item/W, mob/user, params)
	if (!src.associated_cape)
		. = ..()
		return
	if (!istype(W, /obj/item/cable_coil))
		. = ..()
		return
	var/obj/item/cable_coil/coil = W
	coil.use(1)
	if (src.loc == user)
		user.u_equip(src)
	user.put_in_hand_or_drop(new src.associated_cape())
	boutput(user, "You tie [src] into a cape.")
	qdel(src)

/obj/item/flag/afterattack(turf/simulated/T, mob/user)
	if (locate(/obj/decal/poster/flag) in T)
		. = ..()
		return
	if (!istype(T, /turf/simulated/wall/) && !istype(T, /turf/unsimulated/wall))
		. = ..()
		return
	var/obj/decal/poster/flag/new_flag = new src.associated_flag(T)
	qdel(new_flag.flag_item)
	new_flag.flag_item = src
	user.u_equip(src)
	src.set_loc(new_flag)
	logTheThing(LOG_STATION, user, "Hangs up a flag ([new_flag.name]) in [T] at [log_loc(user)].")
	user.visible_message(SPAN_NOTICE("[user] hangs up a [new_flag.name] in [T]!."), SPAN_NOTICE("You hang up a [new_flag.name] in [T]!"))

/obj/item/flag/ace
	name = "asexual pride flag"
	icon_state = "ace"
	associated_flag = /obj/decal/poster/flag/ace
	associated_cape = /obj/item/clothing/suit/flag/ace

/obj/item/flag/aro
	name = "aromantic pride flag"
	icon_state = "aro"
	associated_flag = /obj/decal/poster/flag/aro
	associated_cape = /obj/item/clothing/suit/flag/aro

/obj/item/flag/bisexual
	name = "bisexual pride flag"
	icon_state = "bisexual"
	associated_flag = /obj/decal/poster/flag/bisexual
	associated_cape = /obj/item/clothing/suit/flag/bisexual

/obj/item/flag/demisexual
	name = "demisexual pride flag"
	icon_state = "demisexual"
	associated_flag = /obj/decal/poster/flag/demisexual
	associated_cape = /obj/item/clothing/suit/flag/demisexual

/obj/item/flag/genderqueer
	name = "genderqueer pride flag"
	icon_state = "genderqueer"
	associated_flag = /obj/decal/poster/flag/genderqueer
	associated_cape = /obj/item/clothing/suit/flag/genderqueer

/obj/item/flag/intersex
	name = "intersex pride flag"
	icon_state = "intersex"
	associated_flag = /obj/decal/poster/flag/intersex
	associated_cape = /obj/item/clothing/suit/flag/intersex

/obj/item/flag/lesb
	name = "lesbian pride flag"
	icon_state = "lesb"
	associated_flag = /obj/decal/poster/flag/lesb
	associated_cape = /obj/item/clothing/suit/flag/lesb

/obj/item/flag/nb
	name = "non-binary pride flag"
	icon_state = "nb"
	associated_flag = /obj/decal/poster/flag/nb
	associated_cape = /obj/item/clothing/suit/flag/nb

/obj/item/flag/pan
	name = "pansexual pride flag"
	icon_state = "pan"
	associated_flag = /obj/decal/poster/flag/pan
	associated_cape = /obj/item/clothing/suit/flag/pan

/obj/item/flag/polysexual
	name = "polysexual pride flag"
	icon_state = "polysexual"
	associated_flag = /obj/decal/poster/flag/polysexual
	associated_cape = /obj/item/clothing/suit/flag/polysexual

/obj/item/flag/progressive
	name = "progressive pride flag"
	icon_state = "progressive"
	associated_flag = /obj/decal/poster/flag/progressive
	associated_cape = /obj/item/clothing/suit/flag/progressive
	altside_flag = /obj/item/flag/rainbow

/obj/item/flag/rainbow
	name = "rainbow flag"
	icon_state = "rainbow"
	associated_flag = /obj/decal/poster/flag/rainbow
	associated_cape = /obj/item/clothing/suit/flag/rainbow
	altside_flag = /obj/item/flag/progressive

/obj/item/flag/trans
	name = "transgender pride flag"
	icon_state = "trans"
	associated_flag = /obj/decal/poster/flag/trans
	associated_cape = /obj/item/clothing/suit/flag/trans

/obj/item/flag/mlmvinc
	name = "\improper Vincian MLM pride flag"
	icon_state = "mlmvinc"
	associated_flag = /obj/decal/poster/flag/mlmvinc
	altside_flag = /obj/item/flag/mlmachi
	associated_cape = /obj/item/clothing/suit/flag/mlmvinc

/obj/item/flag/mlmachi
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

/obj/item/clothing/suit/flag/attack_self(mob/user as mob)
	if (!ispath(src.altside_cape, /obj/item/clothing/suit/flag))
		. = ..()
		return
	if (src.loc == user)
		user.u_equip(src)
	user.show_text("You flip [src] around.")
	user.put_in_hand_or_drop(new src.altside_cape)
	qdel(src)

/obj/item/clothing/suit/flag/bisexual
	name = "bisexual pride cape"
	icon_state = "bisexual-cape"

/obj/item/clothing/suit/flag/lesb
	name = "lesbian pride cape"
	icon_state = "lesb-cape"

/obj/item/clothing/suit/flag/rainbow
	name = "rainbow cape"
	icon_state = "rainbow-cape"
	altside_cape = /obj/item/clothing/suit/flag/progressive

/obj/item/clothing/suit/flag/progressive
	name = "progressive pride cape"
	icon_state = "progressive-cape"
	altside_cape = /obj/item/clothing/suit/flag/rainbow

/obj/item/clothing/suit/flag/polysexual
	name = "polysexual pride cape"
	icon_state = "polysexual-cape"

/obj/item/clothing/suit/flag/pan
	name = "pansexual pride cape"
	icon_state = "pan-cape"

/obj/item/clothing/suit/flag/intersex
	name = "intersex pride cape"
	icon_state = "intersex-cape"

/obj/item/clothing/suit/flag/trans
	name = "transgender pride cape"
	icon_state = "trans-cape"

/obj/item/clothing/suit/flag/nb
	name = "non-binary pride cape"
	icon_state = "nb-cape"

/obj/item/clothing/suit/flag/demisexual
	name = "demisexual pride cape"
	icon_state = "demisexual-cape"

/obj/item/clothing/suit/flag/genderqueer
	name = "genderqueer pride cape"
	icon_state = "genderqueer-cape"

/obj/item/clothing/suit/flag/mlmvinc
	name = "\improper Vincian MLM pride cape"
	icon_state = "mlmvinc-cape"
	altside_cape = /obj/item/clothing/suit/flag/mlmachi

/obj/item/clothing/suit/flag/mlmachi
	name = "\improper Achilean MLM pride cape"
	icon_state = "mlmachi-cape"
	altside_cape = /obj/item/clothing/suit/flag/mlmvinc

/obj/item/clothing/suit/flag/ace
	name = "asexual pride flag"
	icon_state = "ace-cape"

/obj/item/clothing/suit/flag/aro
	name = "aromantic pride flag"
	icon_state = "aro-cape"
