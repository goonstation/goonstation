
/obj/item/decoration
	icon = 'icons/obj/decoration.dmi'
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_SMALL

/obj/item/decoration/flower_vase
	name = "flower vase"
	desc = "Some pretty flowers that really brighten up the room."
	icon_state = "vase"
	pixel_y = 18

	New()
		..()
		if (src.icon_state == "vase")
			src.icon_state = "vase[rand(1,8)]"

	vase7
		icon_state = "vase7"

/obj/item/decoration/ashtray
	name = "ashtray"
	desc = "The rarely visited graveyard for cigarettes."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "ashtray"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_TINY
	var/butts = 0 // heh

	New()
		..()
		src.update_icon()

	attack_self(mob/user as mob)
		if (src.butts)
			user.visible_message("<b>[user]</b> tips out [src] onto the floor.",\
			"You tip out [src] onto the floor.")
			var/turf/T = get_turf(src)
			make_cleanable( /obj/decal/cleanable/ash,T)
			for (var/i = 0, i < src.butts, i++)
				new /obj/item/cigbutt(T)
			src.butts = 0 // pff
			src.update_icon()
			src.overlays = null

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/mask/cigarette) && W:on)
			W:put_out(user, "<b>[user]</b> puts out [W] in [src].")
			user.u_equip(W)
			qdel(W)
			src.butts ++ // hehhh
			src.update_icon()
			src.overlays = null
			src.overlays += "ashtray-smoke"
			SPAWN_DBG(80 SECONDS)
				src.overlays -= "ashtray-smoke"
		else
			return ..()

	proc/update_icon()
		if (src.butts <= 0)
			src.icon_state = "ashtray"
		else if (src.butts == 1)
			src.icon_state = "ashtray2"
		else if (src.butts == 2)
			src.icon_state = "ashtray3"
		else
			src.icon_state = "ashtray4"
