//MBC NOTE : we entirely skip over grab level 1. it is not needed but also i am afraid to remove it entirely right now.
/obj/item/grab //TODO : pool grabs
	flags = SUPPRESSATTACK
	var/mob/living/assailant
	var/mob/living/affecting
	var/state = 0 // 0 = passive, 1 aggressive, 2 neck, 3 kill, 4 pin (setup.dm. any state above KILL is considered an alt state that is also an 'end point' in the tree of options. ok
	var/choke_count = 0
	icon = 'icons/mob/hud_human_new.dmi'
	icon_state = "reinforce"
	name = "grab"
	w_class = 5
	anchored = 1
	var/break_prob = 45
	var/assailant_stam_drain = 30
	var/affecting_stam_drain = 20
	var/resist_count = 0

	New(atom/loc)
		..()

		var/icon/hud_style = hud_style_selection[get_hud_style(src.assailant)]
		if (isicon(hud_style))
			src.icon = hud_style

		if (isitem(src.loc))
			var/obj/item/I = src.loc

			var/image/ima = SafeGetOverlayImage("grab", src.icon, "grab_small")
			ima.layer = src.loc.layer + 1
			ima.appearance_flags = RESET_COLOR | KEEP_APART | RESET_TRANSFORM

			I.UpdateOverlays(ima, "grab", 0, 1)

	proc/post_item_setup()//after grab is done being made with item
		return

	disposing()
		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.ClearSpecificOverlays("grab")
			I.chokehold = null

		if(assailant)	//drop that grab to avoid the sticky behavior
			if (src in assailant.equipped_list())
				if (assailant.equipped() == src)
					assailant.drop_item()
				else
					assailant.hand = !assailant.hand
					assailant.drop_item()
					assailant.hand = !assailant.hand

		if(affecting)
			if (state >= GRAB_NECK)
				if (assailant)
					affecting.layer = assailant.layer
				else
					affecting.layer = initial(affecting.layer)
				affecting.pixel_x = initial(affecting.pixel_x)
				affecting.pixel_y = initial(affecting.pixel_y)
				affecting.set_density(1)


			if (state == GRAB_PIN)
				assailant.changeStatus("weakened",2 SECONDS)
				affecting.changeStatus("weakened",1 SECOND)
				assailant.force_laydown_standup()
				affecting.force_laydown_standup()

			if (state == GRAB_KILL)
				logTheThing("combat", src.assailant, src.affecting, "releases their choke on %target% after [choke_count] cycles")
			else if (state == GRAB_PIN)
				logTheThing("combat", src.assailant, src.affecting, "drops their pin on %target%")
			else
				logTheThing("combat", src.assailant, src.affecting, "drops their grab on %target%")
			if (affecting.grabbed_by) affecting.grabbed_by -= src
			affecting = null

		assailant = null
		..()

	dropped()
		qdel(src)

	process(var/mult = 1)
		if (check())
			return

		var/mob/living/carbon/human/H
		if(ishuman(src.affecting))
			H = src.affecting

		if (src.state >= GRAB_NECK)
			if(H) H.remove_stamina(STAMINA_REGEN * 0.5 * mult)
			src.affecting.set_density(0)

		if (src.state == GRAB_PIN)
			if (ishuman(src.assailant))
				var/mob/living/carbon/human/HH = src.assailant
				HH.remove_stamina(STAMINA_REGEN * 0.5 * mult)

		if (src.state == GRAB_KILL)
			//src.affecting.losebreath++
			//if (src.affecting.paralysis < 2)
			//	src.affecting.paralysis = 2
			process_kill(H, mult)

		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.process_grab(mult)

		update_icon()

	attack(atom/target, mob/user)
		if (check())
			return
		if (target == src.affecting)
			attack_self(user)
			return

	attack_hand(mob/user)
		return


	proc/process_kill(var/mob/living/carbon/human/H, mult = 1)
		if(H)
			choke_count += 1 * mult
			H.remove_stamina((STAMINA_REGEN+8.5) * mult)
			H.stamina_stun()
			if(H.stamina <= -75)
				H.losebreath += (3 * mult)
			else if(H.stamina <= -50)
				H.losebreath += (1.5 * mult)
			else if(H.stamina <= -33)
				if(prob(33)) H.losebreath += (1 * mult)
			else
				if(prob(33)) H.losebreath += (0.2 * mult)

	proc/set_affected_loc()
		if (!isturf(src.assailant.loc))
			return

		actions.interrupt(src.affecting, INTERRUPT_ALWAYS)

		var/pxo = 0
		var/pyo = 0
		switch(src.assailant.dir)
			if (EAST)
				pxo = 8
			if (WEST)
				pxo = -8
			if (NORTH)
				pxo = 5
				pyo = 2
			if (SOUTH)
				pxo = -5
				pyo = -1

		if (src.assailant.l_hand == src && pyo != 0) //change pixel position based on which hand the assailant are grabbing with
			pxo *= -1

		src.assailant.pixel_x = 0
		src.assailant.pixel_y = 0
		if (!src.affecting.lying)
			src.affecting.pixel_x = src.assailant.pixel_x + pxo
			src.affecting.pixel_y = src.assailant.pixel_y + pyo
		src.affecting.set_loc(src.assailant.loc)
		src.affecting.layer = src.assailant.layer + (src.assailant.dir == NORTH ? -0.1 : 0.1)
		src.affecting.dir = src.assailant.dir
		src.affecting.set_density(0)

	attack_self(mob/user)
		if (!user)
			return
		if (check())
			return
		switch (src.state)
			if (GRAB_PASSIVE)
				if (src.affecting.buckled)
					src.affecting.buckled.attack_hand(src.assailant)
					src.affecting.force_laydown_standup() //safety because buckle code is a mess
					if (src.affecting.targeting_ability == src.affecting.chair_flip_ability) //fuCKKK
						src.affecting.end_chair_flip_targeting()
					src.affecting.buckled = null

				else if (user.is_hulk() || prob(75))
					logTheThing("combat", src.assailant, src.affecting, "'s grip upped to aggressive on %target%")
					for(var/mob/O in AIviewers(src.assailant, null))
						O.show_message("<span style=\"color:red\">[src.assailant] has grabbed [src.affecting] aggressively (now hands)!</span>", 1)
					icon_state = "reinforce"
					src.state = GRAB_NECK //used to be '1'. SKIP LEVEL 1
					if (!src.affecting.buckled)
						set_affected_loc()

					user.next_click = world.time + user.combat_click_delay //+ rand(6,11) //this was utterly disgusting, leaving it here in memorial
				else
					for(var/mob/O in AIviewers(src.assailant, null))
						O.show_message("<span style=\"color:red\">[src.assailant] has failed to grab [src.affecting] aggressively!</span>", 1)
					user.next_click = world.time + rand(6,11)
			if (GRAB_AGGRESSIVE)
				if (ishuman(src.affecting))
					var/mob/living/carbon/human/H = src.affecting
					if (H.bioHolder.HasEffect("fat"))
						boutput(src.assailant, "<span style=\"color:blue\">You can't strangle [src.affecting] through all that fat!</span>")
						return
					for (var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
						if (C.body_parts_covered & HEAD)
							boutput(src.assailant, "<span style=\"color:blue\">You have to take off [src.affecting]'s [C.name] first!</span>")
							return
				icon_state = "!reinforce"
				src.state = GRAB_NECK
				if (!src.affecting.buckled)
					set_affected_loc()
				src.assailant.lastattacked = src.affecting
				src.affecting.lastattacker = src.assailant
				src.affecting.lastattackertime = world.time
				logTheThing("combat", src.assailant, src.affecting, "'s grip upped to neck on %target%")
				user.next_click = world.time + user.combat_click_delay
				src.assailant.visible_message("<span style=\"color:red\">[src.assailant] has reinforced [his_or_her(assailant)] grip on [src.affecting] (now neck)!</span>")
			if (GRAB_NECK)
				if (ishuman(src.affecting))
					var/mob/living/carbon/human/H = src.affecting
					for (var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
						if (C.body_parts_covered & HEAD)
							boutput(src.assailant, "<span style=\"color:blue\">You have to take off [src.affecting]'s [C.name] first!</span>")
							return
				actions.start(new/datum/action/bar/icon/strangle_target(src.affecting, src), src.assailant)
				//user.next_click = world.time + 1 //mbc : wow. this makes so much sense as to why i would always toggle killchoke off immediately
				// this is also gross enough to leave in memorial. lol
				user.next_click = world.time + user.combat_click_delay
			if (GRAB_KILL)
				src.state = GRAB_NECK
				logTheThing("combat", src.assailant, src.affecting, "releases their choke on %target% after [choke_count] cycles")
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has loosened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
				user.next_click = world.time + user.combat_click_delay
		update_icon()

	proc/upgrade_to_kill(var/msg_overridden = 0)
		icon_state = "disarm/kill"
		logTheThing("combat", src.assailant, src.affecting, "chokes %target%")
		choke_count = 0

		if (!msg_overridden)
			if (isitem(src.loc))
				var/obj/item/I = src.loc
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has tightened [I] on [src.affecting]'s neck!</span>", 1)
			else
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
		src.state = GRAB_KILL
		src.assailant.lastattacked = src.affecting
		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time
		if (!src.affecting.buckled)
			set_affected_loc()
		if (src.assailant.bioHolder.HasEffect("fat"))
			src.affecting.unlock_medal("Bear Hug", 1)
		//src.affecting.losebreath++
		//if (src.affecting.paralysis < 2)
		//	src.affecting.paralysis = 2
		//src.affecting.stunned = max(src.affecting.stunned, 3)
		if (ishuman(src.affecting))
			var/mob/living/carbon/human/H = src.affecting
			H.set_stamina(min(0, H.stamina))

		if (ishuman(src.affecting))
			src.affecting:was_harmed(src.assailant)

	proc/upgrade_to_pin(var/turf/T)
		icon_state = "pin"
		logTheThing("combat", src.assailant, src.affecting, "pins %target%")

		for (var/mob/O in AIviewers(src.assailant, null))
			O.show_message("<span style=\"color:red\">[src.assailant] has pinned [src.affecting] to [T]!</span>", 1)

		src.state = GRAB_PIN

		src.assailant.lastattacked = src.affecting
		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time

		step_to(src.assailant,T)

		src.affecting.setStatus("pinned", duration = INFINITE_STATUS)
		src.affecting.force_laydown_standup()
		if (!src.affecting.buckled)
			set_affected_loc()
		if (src.assailant.bioHolder.HasEffect("fat"))
			src.affecting.unlock_medal("Bear Hug", 1)

		if (ishuman(src.assailant))
			var/mob/living/carbon/human/H = src.assailant
			H.update_canmove()

		if (ishuman(src.affecting))
			src.affecting:was_harmed(src.assailant)

	proc/stunned_targets_can_break()
		.= (src.state == GRAB_PIN)

	proc/check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if (isitem(src.loc))
			if(!assailant.is_in_hands(src.loc))
				qdel(src)
				return 1
		else
			if(!assailant.is_in_hands(src))
				qdel(src)
				return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 1

		return 0

	proc/update_icon()
		switch (src.state)
			if (GRAB_PASSIVE)
				icon_state = "reinforce"
			if (GRAB_AGGRESSIVE)
				icon_state = "!reinforce"
			if (GRAB_NECK)
				icon_state = "disarm/kill"
			if (GRAB_KILL)
				icon_state = "disarm/kill1"
			if (GRAB_PIN)
				icon_state = "pin"

	proc/do_resist()
		hit_twitch(src.assailant)
		src.affecting.dir = pick(alldirs)
		resist_count += 1

		if (src.state == GRAB_PASSIVE)
			for (var/mob/O in AIviewers(src.affecting, null))
				O.show_message(text("<span style=\"color:red\">[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
			qdel(src)
		else if (src.state == GRAB_PIN)
			var/succ = 0

			if (resist_count >= 8 && prob(7)) //after 8 resists, start rolling for breakage. this is to make sure people with stamina buffs cant infinite-pin someone
				succ = 1
			else if (ishuman(src.assailant))
				src.assailant.remove_stamina(29)
				src.affecting.remove_stamina(10)
				var/mob/living/carbon/human/H = src.assailant
				if (H.stamina <= 0)
					succ = 1
			else if (prob(13)) //the grabber must be a critter or some shit
				succ = 1


			if (succ)
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] has broken free of []'s pin!</span>", src.affecting, src.assailant), 1, group = "resist")
				qdel(src)
			else
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] attempts to break free of []'s pin!</span>", src.affecting, src.assailant), 1, group = "resist")

		else
			if (prob(break_prob))
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
				qdel(src)
			else
				src.assailant.remove_stamina(assailant_stam_drain)
				src.affecting.remove_stamina(affecting_stam_drain)

				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] attempts to break free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")


//////////////////////
//PROGRESS BAR STUFF//
//////////////////////

/datum/action/bar/icon/strangle_target
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "strangle_target"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "neck_over"
	var/mob/living/target
	var/obj/item/grab/G

	New(Target, Grab)
		target = Target
		G = Grab
		..()

	onUpdate()
		..()

		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!G || !istype(G) || G.affecting != target || G.state < GRAB_NECK)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && G && get_dist(owner, target) <= 1)
			G.upgrade_to_kill()
		else
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		boutput(owner, "<span style=\"color:red\">You have been interrupted!</span>")
		G = null
		target = null

/datum/action/bar/icon/pin_target
	duration = 30
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "pin_target"
	icon = 'icons/ui/actions.dmi'
	icon_state = "pin"
	var/mob/living/target
	var/obj/item/grab/G
	var/turf/T

	New(Target, Grab, Turf)
		target = Target
		G = Grab
		T = Turf

		if (ishuman(target) && target:stamina < target:stamina_max/2)
			duration -= 15 * (1-(target:stamina/(target:stamina_max/2)))

		if (G.state < GRAB_NECK)
			duration += 25 //takes longer if you dont have a good gripp

		..()

	onUpdate()
		..()

		if(get_dist(owner, target) > 1 || target == null || owner == null || get_dist(owner,T) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!G || !istype(G) || G.affecting != target)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null || get_dist(owner,T) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && G && get_dist(owner, target) <= 1 || get_dist(owner,T) > 1)
			G.upgrade_to_pin(T)
		else
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		boutput(owner, "<span style=\"color:red\">You have been interrupted!</span>")
		G = null
		target = null


/////////////
//GRABSMASH//
/////////////

/atom/proc/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (get_dist(src, M) > 1)
		return 0

	user.visible_message("<span style=\"color:red\"><B>[M] has been smashed against [src] by [user]!</B></span>")
	logTheThing("combat", user, M, "smashes %target% against [src]")

	src.Bumped(M)
	random_brute_damage(G.affecting, rand(2,3))
	G.affecting.TakeDamage("chest", 0, rand(4,5))
	playsound(G.affecting.loc, "punch", 25, 1, -1)

	user.u_equip(G)
	G.dispose()
	return 1


/turf/simulated/floor/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (get_dist(src, M) > 1)
		return 0

	if (ishuman(G.affecting))
		G.affecting:was_harmed(G.assailant)

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)

/turf/unsimulated/floor/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (get_dist(src, M) > 1)
		return 0

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)


///////////////////////
//SPECIAL GRABS BELOW//
///////////////////////

/obj/item/proc/process_grab(var/mult = 1) //items override for unique behaviorse
	.= 0
	if (src.chokehold && src.chokehold.state == GRAB_KILL)
		if (tool_flags & TOOL_CUTTING && hit_type == DAMAGE_CUT)		//bleed em a bit
			take_bleeding_damage(src.chokehold.affecting, src.chokehold.assailant, 0.5 * mult, bloodsplatter = 0)

/obj/item/proc/try_grab(var/mob/living/target, var/mob/living/user)
	.= 0
	if(!chokehold && istype(target) && istype(user))
		src.chokehold = user.grab_other(target, hide_attack, src)
		if(chokehold)
			chokehold.post_item_setup()
		.= 1

/obj/item/proc/drop_grab()
	if(src.chokehold)
		qdel(chokehold)
		chokehold = null


/obj/item/grab/rag_muffle
	check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 1

		return 0

/obj/item/grab/force_mask

	proc/get_breath(volume_needed)
		.= null
		if (src.state == GRAB_KILL)
			for (var/obj/item/tank/use_internal in src.assailant.equipped_list(check_for_magtractor = 0))
				return use_internal.remove_air_volume(volume_needed)

	upgrade_to_kill()
		if (src.assailant.wear_mask && src.assailant.wear_mask.c_flags & COVERSMOUTH | MASKINTERNALS)
			for (var/mob/O in AIviewers(src.assailant, null))
				O.show_message("<span style=\"color:red\">[src.assailant] fails to choke [src.affecting] with [src.loc] because they are already wearing [src.assailant.wear_mask]!</span>", 1)
			return 0
		else
			..(msg_overridden = 1)

			var/obj/item/tank/use_internal = null
			for (var/obj/item/tank/T in src.assailant.equipped_list(check_for_magtractor = 0))
				use_internal = T
				break

			if (use_internal)
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck, forcing them to inhale from [use_internal]!</span>", 1)
			else
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck with no internals tank attached!</span>", 1)



	check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 1

		if (!ishuman(affecting))
			qdel(src)
			return 1

		return 0



/obj/item/gun/try_grab(var/mob/living/target, var/mob/living/user)
	src.hide_attack = 1

	if (..())
		for (var/mob/O in AIviewers(user, null))
			if (O.client)
				O.show_message("<span style=\"color:red\"><B>[user] presses the barrel of [src] right against [target]!</B></span>")
		target.show_text("<span style='color:red;font-weight:bold;font-size:130%'>[user] is ready to fire if you try to move or make any sudden movements!</span>")

	src.hide_attack = initial(src.hide_attack)

/obj/item/grab/gunpoint
	var/shot = 0

	New()
		..()

	post_item_setup()
		..()
		if (!(src.affecting.mob_flags & AT_GUNPOINT))
			src.affecting.mob_flags |= AT_GUNPOINT

	disposing()
		if (!shot && src.assailant && isitem(src.loc))
			for (var/mob/O in AIviewers(src.assailant, null))
				if (O.client)
					O.show_message("<span style=\"color:red\">[src.assailant] lowers [src.loc].</span>")

		if (src.affecting)
			var/found = 0
			for (var/obj/item/grab/gunpoint/G in src.affecting.grabbed_by)
				if (G != src)
					found = 1
					break
			if (!found)
				src.affecting.mob_flags &= ~AT_GUNPOINT
		..()

	proc/shoot()
		shot = 1

		if (affecting && assailant && isitem(src.loc))
			var/obj/item/gun/G = src.loc
			G.shoot_point_blank(src.affecting,src.assailant,1) //don't shoot an offhand gun

		qdel(src)

////////////////////////////
//SPECIAL GRAB ITEMS STUFF//
////////////////////////////

/obj/item/material_piece/cloth
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/rag_muffle

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src

	disposing()
		..()
		if(reagents)
			reagents.clear_reagents()

	process_grab(var/mult = 1)
		..()
		if (src.chokehold && src.reagents && src.reagents.total_volume > 0 && chokehold.state == GRAB_KILL && iscarbon(src.chokehold.affecting))
			src.reagents.reaction(chokehold.affecting, INGEST, 0.5 * mult)
			src.reagents.trans_to(chokehold.affecting, 0.5 * mult)

	is_open_container()
		.= 1



/obj/item/cable_coil/process_grab(var/mult = 1)
	..()
	if (src.chokehold && chokehold.state == GRAB_KILL)
		if (ishuman(src.chokehold.affecting))
			var/mob/living/carbon/human/H = src.chokehold.affecting
			H.losebreath += (0.5 * mult)
