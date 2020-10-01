/datum/hud/ghost_observer
	var/mob/dead/observer/master
	var/obj/screen/hud/rhand
#ifdef HALLOWEEN
	var/hand_pos = "CENTER,SOUTH+1"
#endif

	New(I)
		master = I
		..()
		update_ability_hotbar()
#ifdef HALLOWEEN
		SPAWN_DBG(0)
			rhand = create_screen("rhand", "right hand", 'icons/mob/hud_human_new.dmi', "handr0", hand_pos, HUD_LAYER+1)
#endif
	clear_master()
		master = null
		..()

	proc/update_ability_hotbar()
		if (!master.client)
			return

		for(var/obj/ability_button/B in master.client.screen)
			master.client.screen -= B

		if (master.abilityHolder) //abilities come first. no overlap from the upcoming buttons!
			master.abilityHolder.updateButtons()

#ifdef HALLOWEEN
/mob/dead/observer/click(atom/target, params, location, control)
	. = ..()
	if (. == 100)
		return 100

	if (params["middle"])
		// src.swap_hand()
		return

	if (src.icon_state == "doubleghost")
		return


	var/obj/item/equipped = src.equipped()
	var/use_delay = !(target in src.contents) && !istype(target,/obj/screen) && (!disable_next_click || ismob(target) || (target && target.flags & USEDELAY) || (equipped && equipped.flags & USEDELAY))
	var/grace_penalty = 0
	if ((target == equipped || use_delay) && world.time < src.next_click) // if we ignore next_click on attack_self we get... instachoking, so let's not do that
		var/time_left = src.next_click - world.time
		// since we're essentially encouraging players to click as soon as they possibly can, and how clicking strongly depends on lag, having a strong cutoff feels like bullshit
		// the grace window gives people a small amount of leeway without increasing the overall click rate by much
		if (time_left > CLICK_GRACE_WINDOW || (equipped && (equipped.flags & EXTRADELAY))) // also let's not enable this for guns.
			return time_left
		else
			grace_penalty = time_left

	if (target == equipped)
		equipped.attack_self(src, params, location, control)
	// else if (params["ctrl"])
	// 	var/atom/movable/movable = target
	// 	if (istype(movable))
	// 		movable.pull()

	// 		if (mob_flags & AT_GUNPOINT)
	// 			for(var/obj/item/grab/gunpoint/G in grabbed_by)
	// 				G.shoot()

	// 		.= 0
	// 		return
	else
		var/reach = can_reach(src, target)
		if (src.pre_attack_modify())
			equipped = src.equipped() //might have changed from successful modify
		if (reach || (equipped && equipped.special) || (equipped && (equipped.flags & EXTRADELAY))) //Fuck you, magic number prickjerk //MBC : added bit to get weapon_attack->pixelaction to work for itemspecial
			if (use_delay)
				src.next_click = world.time + (equipped ? equipped.click_delay : src.click_delay)

			if (src.invisibility > 0 && get_dist(src, target) > 0) // dont want to check for a cloaker every click if we're not invisible
				for (var/obj/item/cloaking_device/I in src)
					if (I.active)
						I.deactivate(src)
						src.visible_message("<span class='notice'><b>[src]'s cloak is disrupted!</b></span>")

			if (equipped)
				weapon_attack(target, equipped, reach, params)
			else
				hand_attack(target, params, location, control)

			//If lastattacked was set, this must be a combat action!! Use combat click delay ||  the other condition is whether a special attack was just triggered.
			if ((lastattacked != null && (src.lastattacked == target || src.lastattacked == equipped || src.lastattacked == src) && use_delay) || (equipped && equipped.special && equipped.special.last_use >= world.time - src.click_delay))
				src.next_click = world.time + (equipped ? max(equipped.click_delay,src.combat_click_delay) : src.combat_click_delay)
				src.lastattacked = null

		else if (!equipped)
			hand_range_attack(target, params, location, control)

			if (lastattacked != null && (src.lastattacked == target || src.lastattacked == equipped || src.lastattacked == src) && use_delay)
				src.next_click = world.time + src.combat_click_delay
				src.lastattacked = null



	if (src.next_click >= world.time) // since some of these attack functions go wild with modifying next_click, we implement the clicking grace window with a penalty instead of changing how next_click is set
		src.next_click += grace_penalty


/mob/dead/observer/proc/weapon_attack(atom/target, obj/item/W, reach, params)
	var/usingInner = 0
	if (W.useInnerItem && W.contents.len > 0)
		var/obj/item/held = W.holding
		if (!held)
			held = pick(W.contents)
		if (held && !istype(held, /obj/ability_button))
			W = held
			usingInner = 1

	if (isliving(target))
		if (istype(abilityHolder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GAH = abilityHolder
			if (!GAH.spooking)
				return 0


	if (reach)
		target.attackby(W, src, params)
	if (W && (equipped() == W || usingInner))
		var/pixelable = isturf(target)
		if (!pixelable)
			if (istype(target, /atom/movable) && isturf(target:loc))
				pixelable = 1
		if (pixelable)
			if (!W.pixelaction(target, params, src, reach))
				if (W)
					W.afterattack(target, src, reach, params)
		else if (!pixelable && W)
			W.afterattack(target, src, reach, params)

/mob/dead/observer/proc/hand_attack(atom/target, params, location, control, origParams)
	target.attack_hand(src, params, location, control, origParams)

/mob/dead/observer/proc/hand_range_attack(atom/target, params, location, control, origParams)
	.= 1
	src.lastattacked = src

/mob/dead/observer/proc/pre_attack_modify()
	.=0
	var/obj/item/grab/block/G = src.check_block()
	if (G)
		qdel(G)
		.= 1

/mob/dead/observer/put_in_hand(obj/item/I, hand)
	if (!istype(I))
		return 0
	if (I.two_handed) //MARKER1
		boutput(src, "This is too big to pick up, or something...")
		return 0
	
	if (isnull(hand))
		if (src.put_in_hand(I, src.hand))
			return 1
		if (src.put_in_hand(I, !src.hand))
			return 1
		return 0
	else
		if (hand)
			if (!src.r_hand)
				if (I == src.l_hand && I.cant_self_remove)
					return 0
				src.r_hand = I
				I.pickup(src)
				I.add_fingerprint(src)
				I.set_loc(src)
				src.update_inhands()
				hud.add_object(I, HUD_LAYER+2, src.hud.hand_pos)
				return 1
			else
				return 0

#endif
