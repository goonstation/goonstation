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
	w_class = W_CLASS_HUGE
	anchored = 1
	var/prob_mod = 1
	var/assailant_stam_drain = 30
	var/affecting_stam_drain = 20
	var/resist_count = 0
	var/item_grab_overlay_state = "grab_small"
	var/can_pin = 1
	var/dropped = 0
	var/irresistible = 0

	New(atom/loc, mob/assailant = null, mob/affecting = null)
		..()
		if(!affecting || affecting.disposed)
			qdel(src)
			return

		var/icon/hud_style = hud_style_selection[get_hud_style(src.assailant)]
		if (isicon(hud_style))
			src.icon = hud_style

		if (isitem(src.loc))
			var/obj/item/I = src.loc

			var/image/ima = SafeGetOverlayImage("grab", src.icon, item_grab_overlay_state)
			ima.layer = src.loc.layer + 1
			ima.appearance_flags = RESET_COLOR | KEEP_APART | RESET_TRANSFORM

			I.UpdateOverlays(ima, "grab", 0, 1)
		src.assailant = assailant
		src.affecting = affecting
		src.affecting.grabbed_by += src
		RegisterSignal(src.assailant, COMSIG_ATOM_HITBY_PROJ, .proc/check_hostage)
		if (assailant != affecting)
			SEND_SIGNAL(affecting, COMSIG_MOB_GRABBED, src)

	proc/post_item_setup()//after grab is done being made with item
		return

	disposing()
		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.ClearSpecificOverlays("grab")
			I.chokehold = null

		if(assailant)	//drop that grab to avoid the sticky behavior
			REMOVE_ATOM_PROPERTY(src.assailant, PROP_MOB_CANTMOVE, src)
			if (src in assailant.equipped_list() && !dropped)
				if (assailant.equipped() == src)
					assailant.drop_item()
				else
					assailant.hand = !assailant.hand
					assailant.drop_item()
					assailant.hand = !assailant.hand

		if(affecting)
			if (state >= GRAB_AGGRESSIVE)
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

			if (state == GRAB_CHOKE)
				logTheThing(LOG_COMBAT, src.assailant, "releases their choke on [constructTarget(src.affecting,"combat")] after [choke_count] cycles at [log_loc(src.affecting)]")
			else if (state == GRAB_PIN)
				logTheThing(LOG_COMBAT, src.assailant, "drops their pin on [constructTarget(src.affecting,"combat")] at [log_loc(src.affecting)]")
			else if(!istype(src, /obj/item/grab/block))
				logTheThing(LOG_COMBAT, src.assailant, "drops their grab on [constructTarget(src.affecting,"combat")] at [log_loc(src.affecting)]")
			if (affecting.grabbed_by)
				affecting.grabbed_by -= src

			REMOVE_ATOM_PROPERTY(src.affecting, PROP_MOB_CANTMOVE, src) // in case they were stronggrabbed
			affecting.update_canmove()

			affecting = null
		UnregisterSignal(assailant, COMSIG_ATOM_HITBY_PROJ)
		assailant = null
		..()

		if (src.disposed)
			src.set_loc(null)

	set_loc() //never ever ever ever!!!
		..()
		if (src.loc && !istype(src.loc, /mob))
			set_loc(null)

	dropped()
		..()
		dropped += 1
		if(src.assailant)
			REMOVE_ATOM_PROPERTY(src.assailant, PROP_MOB_CANTMOVE, src)
			qdel(src)

	process(var/mult = 1)
		if (check())
			return

		var/mob/living/carbon/human/H
		if(ishuman(src.affecting))
			H = src.affecting

		if (src.state >= GRAB_AGGRESSIVE)
			if(H) H.remove_stamina(STAMINA_REGEN * 0.5 * mult)
			src.affecting.set_density(0)

		if (src.state == GRAB_CHOKE)
			//src.affecting.losebreath++
			//if (src.affecting.paralysis < 2)
			//	src.affecting.paralysis = 2
			process_kill(H, mult)

		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.process_grab(mult)

		UpdateIcon()

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
			H.stamina_stun(mult)
			if(H.stamina <= -75)
				H.losebreath += (3 * mult)
				H.setStatusMin("paralysis", STAMINA_NEG_CAP_STUN_TIME * mult) //not ideal
			else if(H.stamina <= -50)
				H.losebreath += (1.5 * mult)
			else if(H.stamina <= -33)
				if(prob(33)) H.losebreath += (1 * mult)
			else
				if(prob(33)) H.losebreath += (0.2 * mult)

	proc/set_affected_loc()
		if (!isturf(src.assailant.loc) || !(BOUNDS_DIST(src.assailant, src.affecting) == 0))
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
		src.affecting.set_dir(src.assailant.dir)
		src.affecting.set_density(0)

	attack_self(mob/user)
		if (!user)
			return
		if (check())
			return
		switch (src.state)
			if (GRAB_PASSIVE)
				if (src.affecting.buckled)
					src.affecting.buckled.Attackhand(src.assailant)
					src.affecting.force_laydown_standup() //safety because buckle code is a mess
					if (src.affecting.targeting_ability == src.affecting.chair_flip_ability) //fuCKKK
						src.affecting.end_chair_flip_targeting()
					src.affecting.buckled = null

				else
					logTheThing(LOG_COMBAT, src.assailant, "'s grip upped to aggressive on [constructTarget(src.affecting,"combat")]")
					for(var/mob/O in AIviewers(src.assailant, null))
						O.show_message("<span class='alert'>[src.assailant] has grabbed [src.affecting] aggressively (now hands)!</span>", 1)
					icon_state = "reinforce"
					src.state = GRAB_AGGRESSIVE //used to be '1'. SKIP LEVEL 1
					set_affected_loc()

					user.next_click = world.time + user.combat_click_delay //+ rand(6,11) //this was utterly disgusting, leaving it here in memorial
			if (GRAB_STRONG)
				icon_state = "!reinforce"
				src.state = GRAB_AGGRESSIVE
				if (!src.affecting.buckled)
					set_affected_loc()
				src.assailant.lastattacked = src.affecting
				src.affecting.lastattacker = src.assailant
				src.affecting.lastattackertime = world.time
				logTheThing(LOG_COMBAT, src.assailant, "'s grip upped to aggressive on [constructTarget(src.affecting,"combat")]")
				user.next_click = world.time + user.combat_click_delay
				src.assailant.visible_message("<span class='alert'>[src.assailant] has reinforced [his_or_her(assailant)] grip on [src.affecting] (now aggressive)!</span>")
			if (GRAB_AGGRESSIVE)
				if (ishuman(src.affecting))
					var/mob/living/carbon/human/H = src.affecting
					for (var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
						if (C.c_flags & (BLOCKCHOKE))
							boutput(src.assailant, "<span class='notice'>You have to take off [src.affecting]'s [C.name] first!</span>")
							return
				actions.start(new/datum/action/bar/icon/strangle_target(src.affecting, src), src.assailant)
				//user.next_click = world.time + 1 //mbc : wow. this makes so much sense as to why i would always toggle killchoke off immediately
				// this is also gross enough to leave in memorial. lol
				user.next_click = world.time + user.combat_click_delay
			if (GRAB_CHOKE)
				src.state = GRAB_AGGRESSIVE
				logTheThing(LOG_COMBAT, src.assailant, "releases their choke on [constructTarget(src.affecting,"combat")] after [choke_count] cycles")
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span class='alert'>[src.assailant] has loosened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
				user.next_click = world.time + user.combat_click_delay
		UpdateIcon()

	proc/upgrade_to_choke(var/msg_overridden = 0)
		if (!assailant || !affecting)
			return

		icon_state = "disarm/kill"
		logTheThing(LOG_COMBAT, src.assailant, "chokes [constructTarget(src.affecting,"combat")]")
		choke_count = 0

		if (!msg_overridden)
			if (isitem(src.loc))
				var/obj/item/I = src.loc
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span class='alert'>[src.assailant] has tightened [I] on [src.affecting]'s neck!</span>", 1)
			else
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span class='alert'>[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
		src.state = GRAB_CHOKE
		REMOVE_ATOM_PROPERTY(src.assailant, PROP_MOB_CANTMOVE, src)
		src.assailant.lastattacked = src.affecting
		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time
		if (!src.affecting.buckled)
			set_affected_loc()
		//src.affecting.losebreath++
		//if (src.affecting.paralysis < 2)
		//	src.affecting.paralysis = 2
		//src.affecting.stunned = max(src.affecting.stunned, 3)
		if (ishuman(src.affecting))
			var/mob/living/carbon/human/H = src.affecting
			H.set_stamina(min(0, H.stamina))

		if (isliving(src.affecting))
			src.affecting:was_harmed(src.assailant)

	proc/upgrade_to_pin(var/turf/T)
		if (!assailant || !affecting)
			return

		icon_state = "pin"
		logTheThing(LOG_COMBAT, src.assailant, "pins [constructTarget(src.affecting,"combat")]")

		for (var/mob/O in AIviewers(src.assailant, null))
			O.show_message("<span class='alert'>[src.assailant] has pinned [src.affecting] to [get_turf(T)]!</span>", 1)

		src.state = GRAB_PIN

		src.assailant.lastattacked = src.affecting
		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time

		step_to(src.assailant,T)

		src.affecting.setStatus("pinned", duration = INFINITE_STATUS)
		src.affecting.force_laydown_standup()
		if (!src.affecting.buckled)
			set_affected_loc()

		if (ishuman(src.assailant))
			var/mob/living/carbon/human/H = src.assailant
			APPLY_ATOM_PROPERTY(H, PROP_MOB_CANTMOVE, src)
			H.update_canmove()

		if (isliving(src.affecting))
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

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && BOUNDS_DIST(assailant, affecting) > 0) )
			qdel(src)
			return 1

		return 0

	update_icon()

		switch (src.state)
			if (GRAB_PASSIVE)
				icon_state = "reinforce"
			if (GRAB_STRONG)
				icon_state = "!reinforce"
			if (GRAB_AGGRESSIVE)
				icon_state = "disarm/kill"
			if (GRAB_CHOKE)
				icon_state = "disarm/kill1"
			if (GRAB_PIN)
				icon_state = "pin"

	proc/do_resist()
		hit_twitch(src.assailant)
		src.affecting.set_dir(pick(alldirs))
		resist_count += 1

		if (irresistible)
			prob_mod = 0
		else if (is_incapacitated(src.affecting))
			prob_mod = 0.7
		else
			prob_mod = 1

		playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)

		if ((src.state == GRAB_PASSIVE && prob(STAMINA_P_GRAB_RESIST_CHANCE * prob_mod)))
			for (var/mob/O in AIviewers(src.affecting, null))
				O.show_message(text("<span class='alert'>[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
			qdel(src)
		else if ((src.state == GRAB_STRONG && prob(STAMINA_S_GRAB_RESIST_CHANCE * prob_mod)))
			affecting.visible_message("<span class='alert'>[src.affecting] has broken free of [src.assailant]'s powerful grip!</span>")
			qdel(src)
		else if (src.state == GRAB_PIN)
			var/succ = 0

			if (resist_count >= 8 && prob(7 * prob_mod)) //after 8 resists, start rolling for breakage. this is to make sure people with stamina buffs cant infinite-pin someone
				succ = 1
			else if (ishuman(src.assailant))
				src.assailant.remove_stamina(19)
				src.affecting.remove_stamina(10)
				var/mob/living/carbon/human/H = src.assailant
				if (H.stamina <= 0)
					succ = 1
			else if (prob(13 * prob_mod)) //the grabber must be a critter or some shit
				succ = 1


			if (succ)
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span class='alert'>[] has broken free of []'s pin!</span>", src.affecting, src.assailant), 1, group = "resist")
				qdel(src)
			else
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span class='alert'>[] attempts to break free of []'s pin!</span>", src.affecting, src.assailant), 1, group = "resist")

		else
			if (prob(STAMINA_U_GRAB_RESIST_CHANCE * prob_mod))
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span class='alert'>[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
				qdel(src)
			else
				src.assailant.remove_stamina(assailant_stam_drain)
				src.affecting.remove_stamina(affecting_stam_drain)

				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span class='alert'>[] attempts to break free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")

	/// Helper for allowing people to move again for strong grabs so I can listen for the grab being deleted and run this
	proc/on_strong_grab_drop()
		src.affecting.update_canmove()

	//returns an atom to be thrown if any
	proc/handle_throw(var/mob/living/user, var/atom/target)
		if (!src.affecting) return 0
		if (BOUNDS_DIST(user, src.affecting) > 0)
			return 0
		if ((src.state < 1 && !(src.affecting.getStatusDuration("paralysis") || src.affecting.getStatusDuration("weakened") || src.affecting.stat)) || !isturf(user.loc))
			user.visible_message("<span class='alert'>[src.affecting] stumbles a little!</span>")
			user.u_equip(src)
			return 0

		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time
		.= src.affecting
		user.u_equip(src)


	proc/check_hostage(owner, obj/projectile/P)
		var/mob/hostage = null
		if(src.affecting && src.state >= 2 && P.shooter != src.affecting) //If you grab someone they can still shoot you
			hostage = src.affecting
		if (hostage && (!hostage.lying || GET_COOLDOWN(hostage, "lying_bullet_dodge_cheese") || prob(P.proj_data?.hit_ground_chance)))
			P.collide(hostage)
			//moved here so that it displays after the bullet hit message
			if(prob(25)) //This should probably not be bulletproof, har har
				hostage.visible_message("<span class='combat bold'>[hostage] is knocked out of [owner]'s grip by the force of the [P.name]!</span>")
				qdel(src)

//////////////////////
//PROGRESS BAR STUFF//
//////////////////////

/datum/action/bar/icon/strangle_target
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "strangle_target"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "neck_over"
	color_active = "#d37610"
	var/mob/living/target
	var/obj/item/grab/G

	New(Target, Grab)
		target = Target
		G = Grab
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!G || !istype(G) || G.affecting != target || G.state < GRAB_AGGRESSIVE)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && G && BOUNDS_DIST(owner, target) == 0)
			G.upgrade_to_choke()
		else
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>You have been interrupted!</span>")
		G = null
		target = null

/datum/action/bar/icon/pin_target
	duration = 25
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "pin_target"
	icon = 'icons/ui/actions.dmi'
	icon_state = "pin"
	color_active = "#d37610"
	var/mob/living/target
	var/obj/item/grab/G
	var/turf/T

	New(Target, Grab, Turf)
		target = Target
		G = Grab
		T = Turf

		if (ishuman(target) && target:stamina < target:stamina_max/2)
			duration -= 15 * (1-(target:stamina/(target:stamina_max/2)))

		if (G.state < GRAB_AGGRESSIVE)
			duration += 25 //takes longer if you dont have a good gripp

		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || BOUNDS_DIST(owner, T) > 0 || GET_ATOM_PROPERTY(target, PROP_MOB_CANT_BE_PINNED))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!G || !istype(G) || G.affecting != target)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || BOUNDS_DIST(owner, T) > 0 || GET_ATOM_PROPERTY(target, PROP_MOB_CANT_BE_PINNED))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && G && BOUNDS_DIST(owner, target) == 0 && BOUNDS_DIST(owner, T) == 0 || !GET_ATOM_PROPERTY(target, PROP_MOB_CANT_BE_PINNED))
			G.upgrade_to_pin(T)
		else
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>You have been interrupted!</span>")
		G = null
		target = null


/////////////
//GRABSMASH//
/////////////

/atom/proc/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (BOUNDS_DIST(src, M) > 0)
		return 0

	user.visible_message("<span class='alert'><B>[M] has been smashed against [src] by [user]!</B></span>")
	logTheThing(LOG_COMBAT, user, "smashes [constructTarget(M,"combat")] against [src]")

	src.Bumped(M)
	random_brute_damage(G.affecting, rand(2,3))
	G.affecting.TakeDamage("chest", rand(4,5))
	playsound(G.affecting.loc, "punch", 25, 1, -1)

	user.u_equip(G)
	G.dispose()
	return 1


/turf/simulated/floor/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (BOUNDS_DIST(src, M) > 0)
		return 0

	if (!G.can_pin)
		return 0

	if (isliving(G.affecting))
		G.affecting:was_harmed(G.assailant)

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)

/turf/unsimulated/floor/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (BOUNDS_DIST(src, M) > 0)
		return 0

	if (!G.can_pin)
		return 0

	if (isliving(G.affecting))
		G.affecting:was_harmed(G.assailant)

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)

/obj/fluid/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (BOUNDS_DIST(src, M) > 0)
		return 0

	if (!G.can_pin)
		return 0

	if (isliving(G.affecting))
		G.affecting:was_harmed(G.assailant)

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)

/obj/decal/cleanable/grab_smash(obj/item/grab/G as obj, mob/user as mob)
	var/mob/M = G.affecting

	if  (!(ismob(G.affecting)))
		return 0

	if (BOUNDS_DIST(src, M) > 0)
		return 0

	if (!G.can_pin)
		return 0

	if (isliving(G.affecting))
		G.affecting:was_harmed(G.assailant)

	actions.start(new/datum/action/bar/icon/pin_target(G.affecting, G, src), G.assailant)
	attack_particle(user,src)

///////////////////////
//SPECIAL GRABS BELOW//
///////////////////////

/obj/item/proc/process_grab(var/mult = 1) //items override for unique behaviorse
	.= 0
	if (src.chokehold && src.chokehold.state == GRAB_CHOKE)
		if (tool_flags & TOOL_CUTTING && hit_type == DAMAGE_CUT)		//bleed em a bit
			src.chokehold.affecting.TakeDamage(zone="All", brute=(1 * mult))  //hurt em a bit
			take_bleeding_damage(src.chokehold.affecting, src.chokehold.assailant, 1.4 * mult, bloodsplatter = 0)

/obj/item/proc/try_grab(var/mob/living/target, var/mob/living/user)
	.= 0
	if(!chokehold && istype(target) && istype(user) && target != user)
		src.chokehold = user.grab_other(target, hide_attack, src)
		chokehold?.post_item_setup()
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

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && BOUNDS_DIST(assailant, affecting) > 0) )
			qdel(src)
			return 1

		return 0

/obj/item/grab/force_mask

	proc/get_breath(volume_needed)
		.= null
		if (src.state == GRAB_CHOKE)
			for (var/obj/item/tank/use_internal in src.assailant.equipped_list(check_for_magtractor = 0))
				return use_internal.remove_air_volume(volume_needed)

	upgrade_to_choke()
		var/list/clothing = list(src.affecting.wear_mask)
		if(ishuman(src.affecting))
			var/mob/living/carbon/human/H = src.affecting
			clothing += H.wear_suit
			clothing += H.w_uniform
			clothing += H.head
		for (var/obj/item/clothing/C in clothing)
			if (C.c_flags & (COVERSMOUTH | MASKINTERNALS))
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span class='alert'>[src.assailant] fails to choke [src.affecting] with [src.loc] because their [C] is in the way!</span>", 1)
				return 0

		..(msg_overridden = 1)

		var/obj/item/tank/use_internal = null
		for (var/obj/item/tank/T in src.assailant.equipped_list(check_for_magtractor = 0))
			use_internal = T
			break

		if (use_internal)
			for (var/mob/O in AIviewers(src.assailant, null))
				O.show_message("<span class='alert'>[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck, forcing them to inhale from [use_internal]!</span>", 1)
		else
			for (var/mob/O in AIviewers(src.assailant, null))
				O.show_message("<span class='alert'>[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck with no internals tank attached!</span>", 1)



	check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && BOUNDS_DIST(assailant, affecting) > 0) )
			qdel(src)
			return 1

		if (!ishuman(affecting))
			qdel(src)
			return 1

		return 0



/obj/item/gun/try_grab(var/mob/living/target, var/mob/living/user)
	src.hide_attack = ATTACK_FULLY_HIDDEN

	if (..())
		for (var/mob/O in AIviewers(user, null))
			if (O.client)
				O.show_message("<span class='alert'><B>[user] presses the barrel of [src] right against [target]!</B></span>")
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
					O.show_message("<span class='alert'>[src.assailant] lowers [src.loc].</span>")

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
		if(src.shot)
			return
		src.shot = TRUE
		if (src.affecting && src.assailant && isitem(src.loc))
			var/obj/item/gun/G = src.loc
			G.shoot_point_blank(src.affecting,src.assailant,1) //don't shoot an offhand gun

		qdel(src)


/obj/item/grab/block
	c_flags = EQUIPPED_WHILE_HELD
	item_grab_overlay_state = "grab_block_small"
	icon_state = "grab_block"
	name = "block"
	desc = "By holding this in your active hand, you are blocking!"
	can_pin = 0
	hide_attack = ATTACK_FULLY_HIDDEN


	New()
		..()
		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.c_flags |= HAS_GRAB_EQUIP
			I.tooltip_rebuild = 1
		setProperty("I_disorient_resist", 20)

	disposing()
		for(var/datum/objectProperty/equipment/P in src.properties)
			P.removeFromMob(src, src.assailant)

		if (isitem(src.loc))
			var/obj/item/I = src.loc
			I.c_flags &= ~HAS_GRAB_EQUIP
			I.tooltip_rebuild = 1
			SEND_SIGNAL(I, COMSIG_ITEM_BLOCK_END, src)
		else
			if (assailant)
				SEND_SIGNAL(src.assailant, COMSIG_UNARMED_BLOCK_END, src)


		if (assailant)
			assailant.visible_message("<span class='alert'>[assailant] lowers their defenses!</span>")
			assailant.delStatus("blocking")
			assailant.last_resist = world.time + COMBAT_BLOCK_DELAY
		..()

/obj/item/grab/block/attack(atom/target, mob/user)
	qdel(src)

/obj/item/grab/block/attack_self(mob/user)
	qdel(src)

/obj/item/grab/block/update_icon()
	return

/obj/item/grab/block/do_resist()
	.= 0
	if (assailant)
		playsound(assailant.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, 0, 1.5)
	qdel(src)

/obj/item/grab/block/setProperty(propId, propVal)
	var/datum/objectProperty/equipment/P = ..()
	if(istype(P))
		P.updateMob(src, src.assailant, propVal)

/obj/item/grab/block/delProperty(propId)
	var/propVal = getProperty(propId)
	var/datum/objectProperty/equipment/P = ..()
	if(istype(P))
		P.removeFromMob(src, src.assailant, propVal)

/obj/item/grab/block/proc/can_block(var/hit_type = null, real_hit = 1)
	.= UNARMED_BLOCK_PROTECTION_BONUS
	if (isitem(src.loc) && hit_type)
		var/obj/item/I = src.loc

		var/prop = DAMAGE_TYPE_TO_STRING(hit_type)
		if(real_hit && prop == "burn" && I?.reagents)
			I.reagents.temperature_reagents(4000,10)
		.= src.getProperty("I_block_[prop]")
	if(real_hit)
		var/ret = list(.)
		SEND_SIGNAL(src, COMSIG_BLOCK_BLOCKED, hit_type, ret)
		. = ret[1]
		block_spark(src.assailant)
		fuckup_attack_particle()


/obj/item/grab/block/proc/play_block_sound(var/hit_type = DAMAGE_BLUNT)
	switch(hit_type)
		if (DAMAGE_BLUNT)
			playsound(src, 'sound/impact_sounds/block_blunt.ogg', 50, 1, -1)
		if (DAMAGE_CUT)
			playsound(src, 'sound/impact_sounds/block_cut.ogg', 50, 1, -1)
		if (DAMAGE_STAB)
			playsound(src, 'sound/impact_sounds/block_stab.ogg', 50, 1, -1)
		if (DAMAGE_BURN)
			playsound(src, 'sound/impact_sounds/block_burn.ogg', 50, 1, -1)

/obj/item/grab/block/handle_throw(mob/living/user, atom/target)
	if (isturf(user.loc) && target)
		var/turf/T = user.loc
		var/target_dir = get_dir(user,target)
		if(!target_dir)
			target_dir = user.dir
		if (!(T.turf_flags & CAN_BE_SPACE_SAMPLE) && !(user.lying) && can_act(user) && !HAS_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE) && target_dir)

			user.changeStatus("weakened", max(user.movement_delay()*2, 0.5 SECONDS))
			user.force_laydown_standup()
			var/turf/target_turf = get_step(user, target_dir)
			if (!target_turf)
				target_turf = T
			step_to(user, target_turf)
			var/mob/living/dive_attack_hit = null
			if(get_turf(user) == target_turf)

				for (var/mob/living/L in target_turf)
					if (user == L || isintangible(L)) continue
					dive_attack_hit = L
					break

				if (dive_attack_hit)
					var/damage = rand(1,6)
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.shoes)
							damage += H.shoes.kick_bonus
						else if (H.limbs.r_leg)
							damage += H.limbs.r_leg.limb_hit_bonus
						else if (H.limbs.l_leg)
							damage += H.limbs.l_leg.limb_hit_bonus

					dive_attack_hit.TakeDamageAccountArmor("chest", damage, 0, 0, DAMAGE_BLUNT)
					playsound(user, 'sound/impact_sounds/Generic_Hit_2.ogg', 50, 1, -1)
					for (var/mob/O in AIviewers(user))
						O.show_message("<span class='alert'><B>[user] slides into [dive_attack_hit]!</B></span>", 1)
					logTheThing(LOG_COMBAT, user, "slides into [dive_attack_hit] at [log_loc(dive_attack_hit)].")


				else
					// Slidekick to throw items on the turf
					var/item_num_to_throw = 0
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						item_num_to_throw += !!H.limbs.r_leg
						item_num_to_throw += !!H.limbs.l_leg
					else if (ismobcritter(user))
						//TODO: When mobcritters keep track of how many legs they have, replace the below.
						item_num_to_throw += 2

					if (item_num_to_throw)
						for (var/obj/item/itm in target_turf) // We want to kick items only
							if (itm.w_class >= W_CLASS_HUGE)
								continue

							var/cardinal_throw_dir = target_dir
							if (!is_cardinal(cardinal_throw_dir))
								if(prob(50))
									cardinal_throw_dir &= NORTH | SOUTH
								else
									cardinal_throw_dir &= EAST | WEST

							var/atom/throw_target = get_edge_target_turf(itm, cardinal_throw_dir)
							if (throw_target)
								item_num_to_throw--
								playsound(itm, "swing_hit", 50, 1)
								itm.throw_at(throw_target, W_CLASS_HUGE - itm.w_class, (1 / itm.w_class) + 0.8) // Range: 1-4, Speed: 1-2

							if (!item_num_to_throw)
								break
			if(!dive_attack_hit)
				for (var/mob/O in AIviewers(user))
					O.show_message("<span class='alert'><B>[user] slides to the ground!</B></span>", 1, group = "resist")


	user.u_equip(src)

////////////////////////////
//SPECIAL GRAB ITEMS STUFF//
////////////////////////////

/obj/item/material_piece/cloth
	event_handler_flags = USE_GRAB_CHOKE | USE_FLUID_ENTER
	special_grab = /obj/item/grab/rag_muffle

	New()
		..()
		src.create_reagents(10)

	disposing()
		..()
		if(reagents)
			reagents.clear_reagents()

	process_grab(var/mult = 1)
		..()
		if (src.chokehold && src.reagents && src.reagents.total_volume > 0 && chokehold.state == GRAB_CHOKE && iscarbon(src.chokehold.affecting))
			src.reagents.reaction(chokehold.affecting, INGEST, 0.5 * mult)
			src.reagents.trans_to(chokehold.affecting, 0.5 * mult)

	is_open_container()
		.= 1



/obj/item/cable_coil/process_grab(var/mult = 1)
	..()
	if (src.chokehold?.state == GRAB_CHOKE)
		if (ishuman(src.chokehold.affecting))
			var/mob/living/carbon/human/H = src.chokehold.affecting
			H.losebreath += (0.5 * mult)
