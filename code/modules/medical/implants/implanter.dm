/* ============================================================= */
/* ------------------------- Implanter ------------------------- */
/* ============================================================= */

/obj/item/implanter
	name = "implanter"
	desc = "An implanting tool, used to implant people or animals with various implants."
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "implanter0"
	var/obj/item/implant/imp = null
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	var/sneaky = 0
	tooltip_flags = REBUILD_DIST

	New()
		..()
		src.update()
		return

	get_desc(dist)
		if (dist <= 1 && src.imp)
			. += "It appears to contain \a [src.imp.name]."

	proc/update()
		tooltip_rebuild = TRUE
		if (src.imp)
			src.icon_state = src.imp.impcolor ? "implanter1-[imp.impcolor]" : "implanter1-g"
		else
			src.icon_state = "implanter0"
		return

	proc/implant(mob/M as mob, mob/user as mob)
		if(!in_interact_range(M, user))
			boutput(user, SPAN_ALERT("You are too far away from [M]!"))
			return

		if (M == user)
			if (sneaky)
				boutput(user, SPAN_ALERT("You implanted yourself."))
			else
				user.visible_message(SPAN_ALERT("[user] has implanted [him_or_her(user)]self."),\
					SPAN_ALERT("You implanted yourself."))
		else
			if (sneaky)
				boutput(user, SPAN_ALERT("You implanted the implant into [M]."))
			else
				M.tri_message(user, SPAN_ALERT("[M] has been implanted by [user]."),\
					SPAN_ALERT("You have been implanted by [user]."),\
					SPAN_ALERT("You implanted the implant into [M]."))

		src.imp.implanted(M, user)

		src.imp = null
		src.update()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!ishuman(target) && !ismobcritter(target))
			return ..()

		if (src.imp && !src.imp.can_implant(target, user))
			return

		if (user && src.imp)
			if(src.imp.instant)
				src.implant(target, user)
			else
				actions.start(new/datum/action/bar/icon/implanter(src,target), user)
			return

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/implant))
			if (src.imp)
				user.show_text("[src] already has an implant loaded.")
				return
			else
				user.u_equip(W)
				W.set_loc(src)
				src.imp = W
				src.update()
				user.show_text("You insert [W] into [src].")
			return
		else if (istype(W,/obj/item/implantcase))
			var/obj/item/implantcase/Imp = W
			if (Imp.imp)
				if (src.imp)
					user.show_text("[src] already has an implant loaded.")
					return
				Imp.imp.set_loc(src)
				src.imp = Imp.imp
				Imp.imp = null
				src.update()
				Imp.update()
				user.show_text("You insert [Imp]'s implant into [src].")
			else if (src.imp)
				if (Imp.imp)
					user.show_text("[Imp] already has an implant loaded.")
					return
				src.imp.set_loc(Imp)
				Imp.imp = src.imp
				src.imp = null
				src.update()
				Imp.update()
				user.show_text("You insert [src]'s implant into [Imp].")
			return
		else
			return ..()

	attack_self(mob/user)
		. = ..()
		src.imp?.AttackSelf(user)

/datum/action/bar/icon/implanter
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	icon = 'icons/obj/surgery.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "implanter1-g"
	var/mob/living/target
	var/obj/item/implanter/implanter

	New(Implanter, Target)
		implanter = Implanter
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(owner && target)
			implanter.implant(target, owner)

/obj/item/implanter/sec
	icon_state = "implanter1-g"
	name = "Security Implanter"

	New()
		src.imp = new /obj/item/implant/sec( src )
		..()

/obj/item/implanter/freedom
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/emote_triggered/freedom( src )
		..()

/obj/item/implanter/signaler
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/emote_triggered/signaler( src )
		..()

/obj/item/implanter/mindhack
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/mindhack( src )
		..()

/obj/item/implanter/super_mindhack
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/mindhack/super( src )
		..()

/obj/item/implanter/microbomb
	name = "microbomb implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE

	New()
		src.imp = new /obj/item/implant/revenge/microbomb( src )
		..()

/obj/item/implanter/uplink_microbomb
	name = "microbomb implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, an explosion relative to the amount of microbombs in them will occur. Suiciding will likely cause no explosion, but succumbing while in crit will."})

	New()
		var/obj/item/implant/revenge/microbomb/newbomb = new/obj/item/implant/revenge/microbomb( src )
		newbomb.power = prob(75) ? 2 : 3
		src.imp = newbomb
		..()

/obj/item/implanter/zappy
	name = "flyzapper implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, a ball of lightning relative to the amount of flyzapper implants in them will occur. Suiciding will cause no lightning."})

	New()
		src.imp = new /obj/item/implant/revenge/zappy(src)
		..()

/obj/item/implanter/wasp
	name = "wasp implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, they will explode into a cloud of angry wasps. Suiciding will cause no cloud of wasps to appear. This implant will also make wasps friendly to the user."})

	New()
		src.imp = new /obj/item/implant/revenge/wasp(src)
		..()

/obj/item/implanter/marionette
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"Allows remote signals to exert limited control over the implanted target. Compatible with packets. \
	You can hit this implanter with a marionette implant remote to scan it, causing the contained implant to send status updates to it."})

	New()
		src.imp = new /obj/item/implant/marionette(src)
		..()

	get_desc(dist)
		. = ..()
		var/obj/item/implant/marionette/P = src.imp
		if (istype(P))
			if (P.burned_out)
				. += "<br>[SPAN_ALERT("The implant is completely melted and will not function.")]"
			else
				if (P.linked_address)
					. += "<br>[SPAN_NOTICE("This implant is linked to a remote of network address [P.linked_address].")]"
				. += "<br>[SPAN_NOTICE("Frequency: [P.alert_frequency]")]"
				. += "<br>[SPAN_NOTICE("Network address: [P.net_id]")]"
				. += "<br>[SPAN_NOTICE("Passkey: [P.passkey]")]"
