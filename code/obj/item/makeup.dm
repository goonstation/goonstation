/datum/action/bar/icon/apply_blush
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "blush_brush"
	var/mob/living/carbon/human/target
	var/obj/item/makeup/blush

	New(ntarg, nblush, ndur)
		target = ntarg
		blush = nblush
		duration = ndur
		..()

	onUpdate()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || blush == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (blush != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || blush == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (blush != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("[owner] begins applying [blush] to [owner == target ? "[him_or_her(owner)]self" : target]!", 1)

	onInterrupt(var/flag)
		..()
		if (prob(owner == target ? 50 : 60))
			target.blush = 0
			for (var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("[owner] messes up [owner == target ? "[his_or_her(owner)]" : "[target]'s"] makeup!"), 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && blush && blush == ownerMob.equipped() && BOUNDS_DIST(owner, target) == 0)
			target.blush = 1
			target.blush_color = "#ffbaba"
			target.update_body()
			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("[owner] applies [blush] to [target ]!", 1)

/datum/action/bar/icon/apply_eyeshadow
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "eyeshadow_brush"
	var/mob/living/carbon/human/target
	var/obj/item/makeup/eyeshadow

	New(ntarg, neyeshadow, ndur)
		target = ntarg
		eyeshadow = neyeshadow
		duration = ndur
		..()

	onUpdate()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || eyeshadow == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (eyeshadow != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || eyeshadow == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/ownerMob = owner
		if (eyeshadow != ownerMob.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("[owner] begins applying [eyeshadow] to [owner == target ? "[him_or_her(owner)]self" : target]!", 1)

	onInterrupt(var/flag)
		..()
		if (prob(owner == target ? 50 : 60))
			target.eyeshadow = 2
			target.eyeshadow_color = "#000000"
			target.update_body()
			for (var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("[owner] messes up [owner == target ? "[his_or_her(owner)]" : "[target]'s"] makeup!"), 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && eyeshadow && eyeshadow == ownerMob.equipped() && BOUNDS_DIST(owner, target) == 0)
			target.eyeshadow = 1
			target.eyeshadow_color = "#000000"
			target.update_body()
			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("[owner] applies [eyeshadow] to [target ]!", 1)

/obj/item/pen/crayon/lipstick/fancy
	name = "lipstick"
	desc = "A tube of wax, oil and pigment that is intended to be used to color a person's lips."
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "dark_lipstick0"
	click_delay = 0.7 SECONDS


	New()
		..()
		src.ColorOverride()
		src.IconOverride()

	attack_self(var/mob/user)
		src.open = !src.open
		src.IconOverride()
		if (!src.open)
			src.deactivate(user)
		else
			src.activate(user)
		return

	proc/ColorOverride() //really crusty workaround until I can refactor lipstick
		src.font_color = "#e00d31"
		src.color_name = hex2color_name(src.font_color)
		src.name = "lipstick"
		return

	proc/IconOverride() //also really crusty workaround
		src.icon_state = "dark_lipstick[src.open]"
		if (src.open)
			ENSURE_IMAGE(src.image_stick, src.icon, "dark_lipstick")
			return

	proc/activate(mob/user as mob)
		src.open = 1
		flick("[icon_state]_open", src)
		playsound(user, 'sound/items/zippo_open.ogg', 30, TRUE)

	proc/deactivate(mob/user as mob)
		src.open = 0
		flick("[icon_state]_close", src)
		playsound(user, 'sound/items/zippo_close.ogg', 30, TRUE)

/datum/action/bar/icon/apply_makeup/fancy
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "lipstick_dark1"

	var/item_state_base = "dark_lipstick0"
	var/icon_open = "dark_lipstick1"
	var/icon_closed = "dark_lipstick0"

///obj/item/storage/makeup_pouch
//	name = "make-up pouch"
//	icon_state = "mpouch"
//	desc = "A sturdy fabric pouch used to carry several grenades."
//	w_class = W_CLASS_TINY
//	slots = 3
//	can_hold = list(/obj/item/old_grenade, /obj/item/chem_grenade)
//	prevent_holding = list(/obj/item/storage)
/obj/item/makeup
	name = "makeup"
	desc = "this is makeup"
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "blush_light"
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	click_delay = 0.7 SECONDS
	var/spam_flag_sound = 0
	var/spam_flag_message = 0
	var/spam_timer = 20
	var/open = 0
	var/makeuptype = "blush_light"

	New()
		src.icon_state = "[src.makeuptype][src.open]"
		return ..()

	attack_self(var/mob/user)
		src.open = !src.open
		src.UpdateIcon()
		if (!src.open)
			src.deactivate(user)
		else
			src.activate(user)
		return

	update_icon()
		src.icon_state = "[src.makeuptype][src.open]"
		return

	proc/activate(mob/user as mob)
		src.open = 1
		flick("[makeuptype]_open", src)
		playsound(user, 'sound/items/penclick.ogg', 30, TRUE)

	proc/deactivate(mob/user as mob)
		src.open = 0
		flick("[makeuptype]_close", src)
		playsound(user, 'sound/items/penclick.ogg', 30, TRUE)


/////blush
/obj/item/makeup/blush
	name = "Blush"
	desc = "this is blush"
	var/blush_color = "#8888f8"
	makeuptype = "blush_light"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target))
			if (!src.open)
				user.show_text("You need to open it first!")
			else
				actions.start(new /datum/action/bar/icon/apply_blush(target, src, target == user ? 40 : 60), user)
				return
		else
			return ..()

/obj/item/makeup/blush/dark
	name = "Blush"
	desc = "this is blush"
	makeuptype = "blush_dark"

/obj/item/makeup/blush/gold
	name = "Blush"
	desc = "this is blush"
	makeuptype = "blush_gold"

///// EYESHADOW
/obj/item/makeup/eyeshadow
	name = "Eyeshadow"
	desc = "this is eyeshadow"
	var/blush_color = "#8888f8"
	makeuptype = "eyeshadow_light"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target))
			if (!src.open)
				user.show_text("You need to open it first!")
			else
				actions.start(new /datum/action/bar/icon/apply_eyeshadow(target, src, target == user ? 40 : 60), user)
				return
		else
			return ..()

/obj/item/makeup/eyeshadow/dark
	name = "Eyeshadow"
	desc = "this is eyeshadow"
	makeuptype = "eyeshadow_dark"

/obj/item/makeup/eyeshadow/gold
	name = "Eyeshadow"
	desc = "this is eyeshadow"
	makeuptype = "eyeshadow_gold"
