/* ================================================================ */
/* ------------------------- Implant Case ------------------------- */
/* ================================================================ */

/obj/item/implantcase
	name = "glass case"
	desc = "A glass case containing the labelled implant. An implanting tool is used to extract the implant from this case, and then into a person."
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "implantcase-b"
	var/obj/item/implant/imp = null
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/implant_type = /obj/item/implant/tracking
	tooltip_flags = REBUILD_DIST
	//Whether this is the paper type that goes away when emptied
	var/disposable = FALSE

/obj/item/implantcase/attack_self(mob/user)
	. = ..()
	src.imp?.AttackSelf(user)

/obj/item/implantcase/tracking
	name = "glass case - 'Tracking'"

/obj/item/implantcase/health
	name = "glass case - 'Health'"
	implant_type = /obj/item/implant/health

/obj/item/implantcase/sec
	name = "glass case - 'Security Access'"
	implant_type = /obj/item/implant/sec
/*
/obj/item/implantcase/nt
	name = "glass case - 'Weapon Auth 2'"
	implant_type = /obj/item/implant/nt

/obj/item/implantcase/ntc
	name = "glass case - 'Weapon Auth 3'"
	implant_type = /obj/item/implant/ntc
*/
/obj/item/implantcase/freedom
	name = "glass case - 'Freedom'"
	implant_type = /obj/item/implant/emote_triggered/freedom

/obj/item/implantcase/signaler
	name = "glass case - 'Signaler'"
	implant_type = /obj/item/implant/emote_triggered/signaler

/obj/item/implantcase/counterrev
	name = "glass case - 'Counter-Rev'"
	implant_type = /obj/item/implant/counterrev

/obj/item/implantcase/microbomb
	name = "glass case - 'Microbomb'"
	implant_type = /obj/item/implant/revenge/microbomb

/obj/item/implantcase/robotalk
	name = "glass case - 'Machine Translator'"
	implant_type = /obj/item/implant/robotalk

/obj/item/implantcase/bloodmonitor
	name = "glass case - 'Blood Monitor'"
	implant_type = /obj/item/implant/bloodmonitor

/obj/item/implantcase/mindhack
	name = "glass case - 'Mindhack'"
	implant_type = /obj/item/implant/mindhack

/obj/item/implantcase/super_mindhack
	name = "glass case - 'Mindhack DELUXE'"
	implant_type = /obj/item/implant/mindhack/super

/obj/item/implantcase/robust
	name = "glass case - 'Robusttec'"
	implant_type = /obj/item/implant/robust

/obj/item/implantcase/antirot
	name = "glass case - 'Rotbusttec'"
	implant_type = /obj/item/implant/antirot

/obj/item/implantcase/access
	name = "glass case - 'Electronic Access'"
	implant_type = /obj/item/implant/access

	get_desc(dist)
		if (dist <= 1 && src.imp)
			var/obj/item/implant/access/I = imp
			if (imp)
				. += "It appears to contain \a [src.imp.name] with [I.uses] charges."

	unlimited
		implant_type = /obj/item/implant/access/infinite
		get_desc(dist)
			if (dist <= 1 && src.imp)
				. += "It appears to contain \a [src.imp.name] with unlimited charges."

/obj/item/implantcase/New(obj/item/implant/usedimplant = null)
	if (usedimplant && istype(usedimplant))
		src.imp = usedimplant
		imp.set_loc(src)
		disposable = TRUE
		name = "removed implant"
		desc = "A paper wad containing an implant extracted from someone. An implanting tool can reuse the implant."
	else
		src.imp = new implant_type(src)
	update()
	..()
	return

/obj/item/implantcase/get_desc(dist)
	if (dist <= 1 && src.imp)
		. += "It appears to contain \a [src.imp.name]."

/obj/item/implantcase/proc/update()
	tooltip_rebuild = TRUE
	if (src.imp)
		if (disposable)
			src.icon_state = src.imp.impcolor ? "implantpaper-[imp.impcolor]" : "implantpaper-g"
		else
			src.icon_state = src.imp.impcolor ? "implantcase-[imp.impcolor]" : "implantcase-g"
	else
		if (disposable) //ditch that grody paper "case"
			qdel(src)
			return
		src.icon_state = "implantcase-0"
	return

/obj/item/implantcase/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", null, "[src.name]") as null|text
		if (user.equipped() != I)
			return
		if ((!in_interact_range(src, user) && src.loc != user))
			return
		t = copytext(adminscrub(t),1,128)
		if (t)
			src.name = "glass case - '[t]'"
		else
			src.name = "glass case"
		tooltip_rebuild = TRUE
		return
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/Imp = I
		if (Imp.imp)
			if (src.imp || Imp.imp.implanted)
				return
			Imp.imp.set_loc(src)
			src.imp = Imp.imp
			Imp.imp = null
			src.update()
			Imp.update()
			user.show_text("You insert [Imp]'s implant into [src].")
		else
			if (src.imp)
				if (Imp.imp)
					return
				src.imp.set_loc(I)
				Imp.imp = src.imp
				src.imp = null
				update()
				Imp.update()
				user.show_text("You insert [src]'s implant into [Imp].")
		return
	else if (istype(I, /obj/item/implant))
		if (src.imp)
			return
		user.u_equip(I)
		I.set_loc(src)
		src.imp = I
		src.update()
		user.show_text("You insert [I] into [src].")
		return
	else
		return ..()
