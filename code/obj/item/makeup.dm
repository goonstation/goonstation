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
		if (owner && ownerMob && target && blush == ownerMob.equipped() && BOUNDS_DIST(owner, target) == 0)
			target.blush = 1
			target.blush_color = blush.makeup_color
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
			O.show_message("[owner] begins applying eyeshadow to [owner == target ? "[him_or_her(owner)]self" : target]!", 1)

	onInterrupt(var/flag)
		..()
		if (prob(owner == target ? 50 : 60))
			target.eyeshadow = 2
			target.eyeshadow_color = eyeshadow.makeup_color
			target.update_body()
			for (var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("[owner] messes up [owner == target ? "[his_or_her(owner)]" : "[target]'s"] makeup!"), 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && eyeshadow == ownerMob.equipped() && BOUNDS_DIST(owner, target) == 0)
			target.eyeshadow = 1
			target.eyeshadow_color = eyeshadow.makeup_color
			target.update_body()
			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("[owner] applies eyeshadow to [target ]!", 1)

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

/obj/item/pen/crayon/lipstick/fancy/gold
	icon_state = "gold_lipstick"

/obj/item/pen/crayon/lipstick/fancy/light
	icon_state = "light_lipstick"

/datum/action/bar/icon/apply_makeup/fancy
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "lipstick_dark1"

	var/item_state_base = "dark_lipstick0"
	var/icon_open = "dark_lipstick1"
	var/icon_closed = "dark_lipstick0"

/obj/item/makeup
	name = "makeup"
	desc = "this is makeup"
	icon = 'icons/obj/items/makeup.dmi'
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	click_delay = 0.7 SECONDS
	var/makeup_color = "#ffffff"
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
	name = "blush"
	desc = "A container full of ultra-fine powder intended to be used to tiny a person's cheeks."
	makeuptype = "blush_light"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!src.open)
				user.show_text("You need to open it first!")
				return
			if (H.blush == 2)
				user.show_text("Gurl, [H == user ? "you" : H] a hot mess right now. That all needs to be cleaned up first.", "red")
				return
			else
				actions.start(new /datum/action/bar/icon/apply_blush(target, src, target == user ? 40 : 60), user)
				return
		else
			return ..()

/obj/item/makeup/blush/light
	name = "blush"
	makeuptype = "blush_light"
	makeup_color = "#fda7f6"

/obj/item/makeup/blush/dark
	name = "blush"
	makeuptype = "blush_dark"
	makeup_color = "#d63f3f"

/obj/item/makeup/blush/gold
	name = "blush"
	makeuptype = "blush_gold"
	makeup_color = "#ff5b8c"

///// EYESHADOW
/obj/item/makeup/eyeshadow
	name = "eyeshadow"
	desc = "A palette of pigmented powders that is intended to be used around a person's eyes."
	makeuptype = "eyeshadow_light"
	var/list/eyeshadow_light_colors = list("#ff9eb6", "#f8aaaa", "#ff757b", "#de3862", "#dd506b", "#ffd6da", "#ab1e42", "#8a3e3e",
	"#e253de", "#bc88bb")
	var/list/eyeshadow_dark_colors = list("#87a2ad", "#4d5a96", "#c2eeff", "#64b0ce", "#6a9b95", "#3e4746", "#00000000", "#dbeff5",
	"#3b2c5e", "#28527d")
	var/list/eyeshadow_gold_colors = list("#be5e51", "#e95c2c", "#f38e26", "#ffe2a7", "#c98b0d", "#ffff", "#605131", "#8e4f0e",
	"#ffa200")


	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!src.open)
				user.show_text("You need to open it first!")
				return
			if (H.eyeshadow == 2)
				user.show_text("Gurl, [H == user ? "you" : H] a hot mess right now. That all needs to be cleaned up first.", "red")
				return
			if(src.makeuptype == "eyeshadow_light")
				makeup_color = pick(eyeshadow_light_colors)
			if(src.makeuptype == "eyeshadow_dark")
				makeup_color = pick(eyeshadow_dark_colors)
			if(src.makeuptype == "eyeshadow_gold")
				makeup_color = pick(eyeshadow_gold_colors)
			actions.start(new /datum/action/bar/icon/apply_eyeshadow(target, src, target == user ? 40 : 60), user)
			return
		else
			return ..()

/obj/item/makeup/eyeshadow/light
	name = "eyeshadow"
	desc = "this is eyeshadow"
	makeuptype = "eyeshadow_light"

/obj/item/makeup/eyeshadow/dark
	name = "eyeshadow"
	desc = "this is eyeshadow"
	makeuptype = "eyeshadow_dark"

/obj/item/makeup/eyeshadow/gold
	name = "eyeshadow"
	desc = "this is eyeshadow"
	makeuptype = "eyeshadow_gold"

//Makeup Bags
/obj/item/storage/makeup_bag
	name = "cute makeup bag"
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "light_makeupbag"
	desc = "A cute fabric pouch meant to keep all of your expensive beauty products safe while traveling."
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "light_makeupbag"
	w_class = W_CLASS_SMALL
	slots = 3
	can_hold = list(/obj/item/makeup, /obj/item/pen/crayon/lipstick)
	prevent_holding = list(/obj/item/storage)

/obj/item/storage/makeup_bag/dark
	name = "mysterious makeup bag"
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "dark_makeupbag"
	item_state = "dark_makeupbag"
	desc = "A fabric pouch with a mysterious design meant to keep all of your expensive beauty products safe while traveling."

/obj/item/storage/makeup_bag/gold
	name = "luxury makeup bag"
	icon = 'icons/obj/items/makeup.dmi'
	icon_state = "gold_makeupbag"
	item_state = "gold_makeupbag"
	desc = "An extravagant fabric pouch meant to keep all of your expensive beauty products safe while traveling."

/obj/item/storage/makeup_bag/gold/full
	spawn_contents = list(/obj/item/pen/crayon/lipstick/fancy/gold,
	/obj/item/makeup/eyeshadow/gold,
	/obj/item/makeup/blush/gold)

/obj/item/storage/makeup_bag/dark/full
	spawn_contents = list(/obj/item/pen/crayon/lipstick/fancy,
	/obj/item/makeup/eyeshadow/dark,
	/obj/item/makeup/blush/dark)

/obj/item/storage/makeup_bag/full
	spawn_contents = list(/obj/item/pen/crayon/lipstick/fancy/light,
	/obj/item/makeup/eyeshadow,
	/obj/item/makeup/blush)
