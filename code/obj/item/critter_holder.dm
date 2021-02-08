/obj/item/critter_shell
	name = "some kind of thing that holds a critter"
	desc = "oh"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	inhand_image_icon = 'icons/mob/inhand/hand_critters.dmi'
	flags = CONDUCT | USEDELAY | NOSPLASH | EXTRADELAY
	var/mob/living/critter/held_mobcritter = null
	w_class = 1
	var/static/list/showoff_adj = list("a cool", "a creepy", "a yucky", "an awesome", "a gnarly", "a grody", "a funky", "a cute", "a cutie-pie", "a slimy", "a horpy", "a very unremarkable", "a super-star", "an unmistakable", "a shockingly hideous")
	var/showoff_word
	var/click_cooldown = COMBAT_CLICK_DELAY

	disposing()
		if(length(src.contents))
			for(var/atom/movable/AM in src.contents)
				AM.set_loc(get_turf(src))
		if(src.held_mobcritter)
			UnregisterSignal(src.held_mobcritter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_MOB_DEATH, COMSIG_MOVABLE_MOVED))
			src.held_mobcritter.metaholder = null
			src.held_mobcritter.grabber = null
			src.held_mobcritter.set_loc(get_turf(src))
			src.held_mobcritter = null
		. = ..()

	/// Pass right through the critter shell to the critter
	attackby(obj/item/W, mob/user, params)
		if(!istype(src.held_mobcritter))
			src.unshellify()
			return
		if(ON_COOLDOWN(src, "respect_USEDELAY_darnit", src.click_cooldown))
			return
		src.held_mobcritter.attackby(W, user)
		src.update_icon()

	/// Pass it through to the critter
	attack_ai(mob/user)
		if(!istype(src.held_mobcritter))
			src.unshellify()
			return
		if(ON_COOLDOWN(src, "respect_USEDELAY_darnit", src.click_cooldown))
			return
		src.held_mobcritter.attack_ai(user)
		src.update_icon()

	/// Punch / pet / tussle with the critter inside the shell
	attack_hand(mob/user)
		if(!istype(src.held_mobcritter))
			src.unshellify()
			return
		if(user.a_intent == INTENT_GRAB)
			. = ..() // Don't grab the critter, grab the item
		else
			if(ON_COOLDOWN(src, "respect_USEDELAY_darnit", src.click_cooldown))
				return
			src.held_mobcritter.attack_hand(user)
			src.update_icon()

	/// Show off this silly critter you've found
	attack(mob/M, mob/user, def_zone, is_special)
		if(!istype(src.held_mobcritter))
			src.unshellify()
			return
		if(prob(1))
			src.showoff_word = pick(src.showoff_adj)
		if(M == user)
			user.visible_message("[user] shows off [src.showoff_word] [src.held_mobcritter].[prob(10) ? " Wow!" : ""]", "You show off [src.showoff_word] [src.held_mobcritter] you caught!")
		else
			user.visible_message("[user] shows [M] [src.showoff_word] [src.held_mobcritter].[prob(10) ? " Wow!" : ""]", "You show [M] [src.showoff_word] [src.held_mobcritter] you caught!")
		src.update_icon()

	relaymove(mob/user)
		. = ..()
		if(istype(src.held_mobcritter) && src.held_mobcritter.check_metaholder())
			src.held_mobcritter.resist()
			src.update_icon()
		else
			src.unshellify()

	/// Unshell the mob if it happens to not be in your hands anymore
	dropped(mob/user)
		. = ..()
		if(!istype(src.loc, /mob))
			if(istype(src.loc, /obj/item/storage))
				boutput(src.held_mobcritter, "<span class='notice'>\The [src.loc] is way too dark and cramped for your liking! You jump out the moment [user] lets go.</span>")
				user.visible_message("<span class='notice'>Just as [user] puts \the [src.held_mobcritter] into \the [src.loc], \the [src.held_mobcritter] jumps right back out!</span>",\
				"<span class='notice'>[prob(1) && prob(1) ? "You try to put [src.held_mobcritter] into [src.loc], but it hasn't been implemented yet! It jumps free of your grip." : "The moment you let go of \the [src.held_mobcritter], it jumps away!</span>"]")
			src.unshellify()
		else
			src.update_icon()

	/// Handles just about everything related to stuffing a critter into a shell and placing it in someone's hand
	proc/shellify_critter(mob/living/critter/mob_critter, mob/living/grabber)
		if(!istype(mob_critter) || !grabber)
			src.unshellify()
			return FALSE

		src.icon = mob_critter.icon
		src.icon_state = mob_critter.icon_state
		src.name = mob_critter.name
		src.desc = mob_critter.desc
		mob_critter.grabber = grabber
		mob_critter.metaholder = src
		src.held_mobcritter = mob_critter
		src.inhand_image_icon = mob_critter.icon_inhand
		src.item_state = mob_critter.item_state_inhand
		src.update_icon()

		if(!grabber.put_in_hand(src)) // If they can't hold this, then they can't hold the critter
			grabber.u_equip(src)
			boutput(grabber, "<span class='alert'>You can't seem to get a good grip on [mob_critter], try emptying your hands.</span>")
			src.unshellify()
			return FALSE

		mob_critter.set_loc(src)
		RegisterSignal(src.held_mobcritter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_MOB_DEATH), .proc/update_icon)
		src.showoff_word = pick(src.showoff_adj)
		return TRUE // it worked!

	/// Handles safe release of the critter and their leavings, then self-destructs. Also returns the mob, for throwing purposed
	proc/unshellify()
		if(length(src.contents))
			for(var/atom/movable/AM in src.contents)
				AM.set_loc(get_turf(src))
		if(src.held_mobcritter)
			. = src.held_mobcritter
			UnregisterSignal(src.held_mobcritter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_MOB_DEATH, COMSIG_MOVABLE_MOVED))
			src.held_mobcritter.metaholder = null
			src.held_mobcritter.grabber = null
			src.held_mobcritter.set_loc(get_turf(src))
			src.held_mobcritter = null
		qdel(src)

	/// Makes the object look more like the critter when it moves
	proc/update_icon()
		if(src.held_mobcritter)
			src.name = src.held_mobcritter.name
			src.desc = src.held_mobcritter.desc
			src.icon = src.held_mobcritter.icon
			src.icon_state = src.held_mobcritter.icon_state
			var/image/critter_overlays = image(src.held_mobcritter.icon, src.held_mobcritter.icon_state)
			var/image/overlay_eyes = src.held_mobcritter.GetOverlayImage("eyes")
			if(overlay_eyes)
				critter_overlays.overlays += overlay_eyes
			var/image/overlay_hair = src.held_mobcritter.GetOverlayImage("hair")
			if(overlay_hair)
				critter_overlays.overlays += overlay_hair
			src.UpdateOverlays(critter_overlays, "critter_overlays")
		else
			src.unshellify()
