ABSTRACT_TYPE(/mob/living/critter)
ADMIN_INTERACT_PROCS(/mob/living/critter, proc/modify_health, proc/admincmd_attack, proc/admincmd_reset_task)
/mob/living/critter
	name = "critter"
	desc = "A beastie!"
	icon = 'icons/misc/critter.dmi'
	icon_state = "lavacrab"
	var/icon_state_alive = null
	var/icon_state_dead = null
	var/icon_state_ghost = null
	abilityHolder = null
	var/list/add_abilities = null

	var/datum/hud/critter/hud
	var/datum/hud/critter/custom_hud_type = /datum/hud/critter
	var/datum/organHolder/custom_organHolder_type = null

	var/hand_count = 0		// Used to ease setup. Setting this in-game has no effect.
	var/list/hands = list()
	var/list/equipment = list()
	var/image/equipment_image = new
	var/image/burning_image = new
	var/burning_suffix = "generic"
	var/active_hand = 0		// ID of the active hand
	var/base_move_delay = 2
	var/base_walk_delay = 3
	var/stepsound = null
	///area where the mob ai is registered when hibernating
	var/area/registered_area = null
	///time when mob last awoke from hibernation
	var/last_hibernation_wake_tick = 0
	var/is_hibernating = FALSE

	var/can_burn = TRUE
	var/can_throw = FALSE
	var/can_choke = FALSE
	var/in_throw_mode = FALSE
	var/health_brute = null
	var/health_burn = null
	var/health_brute_vuln = null
	var/health_burn_vuln = null

	var/can_help = FALSE
	var/can_grab = FALSE
	var/can_disarm = FALSE

	var/reagent_capacity = 50
	max_health = 0
	health = 0

	var/ultravision = 0
	var/tranquilizer_resistance = 0
	explosion_resistance = 0
	var/has_genes = FALSE

	var/list/inhands = list()
	var/list/healthlist = list()

	var/list/implants = list()
	var/can_implant = TRUE

	var/death_text = null // can use %src%
	var/pet_text = "pets" // can be a list

	// moved up from critter/small_animal
	var/butcherable = BUTCHER_NOT_ALLOWED
	var/butcher_time = 1.2 SECONDS
	/// The mob who is butchering this critter
	var/mob/butcherer = null
	var/meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	var/name_the_meat = FALSE
	var/skinresult = /obj/item/material_piece/cloth/leather //YEP
	var/max_skins = FALSE

	// for critters with removable arms(brullbar, bear)
	var/left_arm = null
	var/right_arm = null

	var/fits_under_table = FALSE
	var/table_hide = FALSE

	var/old_canmove
	var/dormant = FALSE

	var/custom_brain_type = null

	var/ghost_spawned = FALSE //Am i inhabited by a ghost player who used the respawn critter option?
	var/original_name = null

	var/yeet_chance = 1 //yeet

	var/last_life_process = 0
	var/use_stunned_icon = TRUE

	var/list/friends = list()

	var/pull_w_class = W_CLASS_SMALL

	///Whether or not we attack mobs with the neutral faction flag
	var/ai_attacks_neutral = FALSE
	///If the mob has an ai, turn this to TRUE if you want it to fight back upon being attacked
	var/ai_retaliates = FALSE
	///If the mob has an ai, and ai_retaliates is TRUE, how many attacks should we endure before attacking back?
	var/ai_retaliate_patience = 2
	////INTERNAL used for mob ai retaliation patience counting
	var/_ai_patience_count = 2
	///If the mob has an ai, and is currently retaliating against being attacked, how long should we do that for? (deciseconds)
	///Special values: RETALIATE_ONCE = Attack once, RETALIATE_UNTIL_INCAP = Attack until the target is incapacitated, RETALIATE_UNTIL_DEAD = Attck until the target is dead
	var/ai_retaliate_persistence = RETALIATE_ONCE
	///Counts the number of attacks this critter has performed without using an ability
	var/ai_attack_count = 0
	///The number of basic attacks this critter will perform in between using abilities
	var/ai_attacks_per_ability = 2

	blood_id = "blood"

/mob/living/critter/New()
	_ai_patience_count = ai_retaliate_patience
	setup_hands()
	post_setup_hands()
	setup_equipment_slots()
	setup_reagents()
	setup_healths()
	if (!length(healthlist))
		stack_trace("Critter [type] ([name]) \[\ref[src]\] does not have health holders.")
	count_healths()


	for (var/datum/equipmentHolder/EE in equipment)
		EE.after_setup(hud)

	burning_image.icon = 'icons/mob/critter/overlays.dmi'
	burning_image.icon_state = null

	src.old_canmove = src.canmove

	if(!isnull(src.custom_organHolder_type))
		src.organHolder = new src.custom_organHolder_type(src, custom_brain_type)
	else
		src.organHolder = new/datum/organHolder/critter(src, custom_brain_type)

	..()

	hud = new custom_hud_type(src)
	src.attach_hud(hud)
	src.zone_sel = new(src, "CENTER[hud.next_right()], SOUTH")
	src.zone_sel.change_hud_style('icons/mob/hud_human.dmi')

	if (src.stamina_bar)
		hud.add_object(src.stamina_bar, initial(src.stamina_bar.layer), "EAST-1, NORTH")

	health_update_queue |= src

	if(!src.abilityHolder)
		src.abilityHolder = new /datum/abilityHolder/composite(src)
	if (islist(src.add_abilities) && length(src.add_abilities))
		for (var/abil in src.add_abilities)
			if (ispath(abil))
				abilityHolder.addAbility(abil)

	if(src.bioHolder)
		src.bioHolder.genetic_stability = 50

	SPAWN(0.5 SECONDS) //if i don't spawn, no abilities even show up
		if (abilityHolder)
			abilityHolder.updateButtons()

	#ifdef NO_CRITTERS
	START_TRACKING_CAT(TR_CAT_DELETE_ME)
	#endif

/mob/living/critter/disposing()
	if(organHolder)
		organHolder.dispose()
		organHolder = null

	if(hud)
		if(src.stamina_bar)
			hud.remove_object(stamina_bar)

		hud.dispose()
		hud = null

	for(var/datum/handHolder/hh in hands)
		hh.dispose()
	hands.len = 0
	hands = null

	for(var/datum/equipmentHolder/eh in equipment)
		eh.dispose()
	equipment.len = 0
	equipment = null

	for(var/obj/item/I in implants)
		I.dispose()
	implants.len = 0
	implants = null

	for(var/damage_type in healthlist)
		var/datum/healthHolder/hh = healthlist[damage_type]
		hh.dispose()
	healthlist.len = 0
	healthlist = null

	if (src.is_npc)
		src.registered_area?.registered_mob_critters -= src
		src.registered_area = null
	if (ai)
		qdel(ai)
		ai = null
	..()

///enables mob ai that was disabled by a hibernation task
/mob/living/critter/proc/wake_from_hibernation()
	if(src.is_npc && !src.client)
		src.ai?.enable()
		src.last_hibernation_wake_tick = TIME
		src.registered_area?.registered_mob_critters -= src
		src.registered_area = null
		src.is_hibernating = FALSE

/mob/living/critter/proc/setup_healths()
	// add_health_holder(/datum/healthHolder/flesh)
	// etc..

/mob/living/critter/proc/setup_overlays()
	//used for critters that have overlays for their bioholder (hair color eye color etc)

/mob/living/critter/proc/add_health_holder(var/T)
	var/datum/healthHolder/HH = new T(src)
	if (!istype(HH))
		return null
	if (HH.associated_damage_type in healthlist)
		var/datum/healthHolder/OH = healthlist[HH.associated_damage_type]
		if (OH.type == T)
			return OH
		return null
	HH.holder = src
	healthlist[HH.associated_damage_type] = HH
	return HH

/mob/living/critter/proc/get_health_percentage()
	var/hp = 0
	for (var/T in healthlist)
		var/datum/healthHolder/HH = healthlist[T]
		if (HH.count_in_total)
			hp += HH.value
	if (max_health > 0)
		return hp / max_health
	return 0

/mob/living/critter/proc/count_healths()
	max_health = 0
	health = 0
	for (var/T in healthlist)
		var/datum/healthHolder/HH = healthlist[T]
		if (HH.count_in_total)
			max_health += HH.maximum_value
			health += HH.maximum_value

///admin varediting proc
/mob/living/critter/proc/modify_health()
	set name = "Modify critter health"
	var/chosen = input(usr, "Pick health type") in (src.healthlist + "All")
	if (!chosen)
		return
	var/value = input(usr, "Input new value") as num
	if (!value)
		return
	var/to_update = list()
	if (chosen == "All")
		to_update = src.healthlist
	else
		to_update = list("chosen" = src.healthlist[chosen])
	for (var/holder_id in to_update)
		var/datum/healthHolder/holder = to_update[holder_id]
		holder.maximum_value = value
		holder.value = value
		holder.last_value = value

	src.count_healths()

// begin convenience procs
/mob/living/critter/proc/add_hh_flesh(var/max, var/mult)
	var/datum/healthHolder/Brute = add_health_holder(/datum/healthHolder/flesh)
	Brute.maximum_value = max
	Brute.value = max
	Brute.last_value = max
	Brute.damage_multiplier = mult
	return Brute

/mob/living/critter/proc/add_hh_flesh_burn(var/max, var/mult)
	var/datum/healthHolder/Burn = add_health_holder(/datum/healthHolder/flesh_burn)
	Burn.maximum_value = max
	Burn.value = max
	Burn.last_value = max
	Burn.damage_multiplier = mult
	return Burn

/mob/living/critter/proc/add_hh_robot(var/max, var/mult)
	var/datum/healthHolder/Brute = add_health_holder(/datum/healthHolder/structure)
	Brute.maximum_value = max
	Brute.value = max
	Brute.last_value = max
	Brute.damage_multiplier = mult
	return Brute

/mob/living/critter/proc/add_hh_robot_burn(var/max, var/mult)
	var/datum/healthHolder/Burn = add_health_holder(/datum/healthHolder/wiring)
	Burn.maximum_value = max
	Burn.value = max
	Burn.last_value = max
	Burn.damage_multiplier = mult
	return Burn

// end convenience procs
/mob/living/critter/was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
	if (src.ai)
		src._ai_patience_count--
		src.ai.was_harmed(weapon,M)
		if(src.is_hibernating)
			if (src.registered_area)
				src.registered_area.wake_critters(M)
			else
				src.wake_from_hibernation()
		// We were harmed, and our ai wants to fight back. Also we don't have anything else really important going on
		if (src.ai_retaliates && src.ai.enabled && length(src.ai.priority_tasks) <= 0 && src.should_critter_retaliate() && M != src && src.is_npc)
			var/datum/aiTask/sequence/goalbased/retaliate/task_instance = src.ai.get_instance(/datum/aiTask/sequence/goalbased/retaliate, list(src.ai, src.ai.default_task))
			task_instance.targetted_mob = M
			task_instance.start_time = TIME
			src.ai.priority_tasks += task_instance
			src.ai.interrupt()
	..()

/mob/living/critter/on_reagent_react(var/datum/reagents/R, var/method = 1, var/react_volume)
	for (var/T in healthlist)
		var/datum/healthHolder/HH = healthlist[T]
		HH.on_react(R, method, react_volume)

/mob/living/critter/proc/equip_click(var/datum/equipmentHolder/EH)
	if (!handcheck())
		return
	var/obj/item/I = equipped()
	var/obj/item/W = EH.item
	if (I && W)
		W.Attackby(I, src) // fix runtime for null.find_type_in_hand - cirr
	else if (I)
		if (EH.can_equip(I))
			u_equip(I)
			EH.equip(I)
			hud.add_object(I, HUD_LAYER+2, EH.screenObj.screen_loc)
		else
			boutput(src, SPAN_ALERT("You cannot equip [I] in that slot!"))
		update_clothing()
	else if (W)
		if (!EH.remove())
			boutput(src, SPAN_ALERT("You cannot remove [W] from that slot!"))
		update_clothing()

/mob/living/critter/proc/handcheck()
	if (!hand_count)
		return 0
	if (!active_hand)
		return 0
	if (length(hands) >= active_hand)
		return 1
	return 0

/mob/living/critter/attackby(var/obj/item/I, var/mob/M)
	if (isdead(src)) 	//Just copied from pets_small_animals.dm with only small modifications. yep!
		if (src.skinresult && max_skins)
			if (issawingtool(I) || iscuttingtool(I))
				for (var/i, i<rand(1, max_skins), i++)
					var/obj/item/S = new src.skinresult
					S.set_loc(src.loc)
				src.skinresult = null
				M.visible_message(SPAN_ALERT("[M] skins [src]."),"You skin [src].")
				return
		if (src.butcherable && (issawingtool(I) || iscuttingtool(I)))
			actions.start(new/datum/action/bar/icon/butcher_living_critter(src,src.butcher_time), M)
			return

	var/rv = 1
	for (var/T in healthlist)
		var/datum/healthHolder/HH = healthlist[T]
		rv = min(HH.on_attack(I, M), rv)
	if (!rv)
		return
	else
		..()

/// Creates meat and a brain named after the mob containing reagents. Both can be skipped to allow custom butchering at the mob level
/mob/living/critter/proc/butcher(var/mob/M, drop_brain = TRUE, drop_meat = TRUE)
	if (drop_meat)
		var/i = rand(2,4)
		var/transfer = src.reagents ? src.reagents.total_volume / i : 0

		while (i-- > 0)
			var/obj/item/reagent_containers/food/newmeat = new meat_type
			newmeat.set_loc(src.loc)
			src.reagents?.trans_to(newmeat, transfer)
			if (name_the_meat)
				newmeat.name = "[src.name] meat"
				newmeat.real_name = newmeat.name

	if (src.organHolder && src.last_ckey)
		src.organHolder.drop_organ("brain",src.loc)

	src.ghostize()
	qdel (src)

/mob/living/critter/proc/remove_arm(var/left_or_right) // for removing the arms of brullbars and bears
	switch(left_or_right)
		if("left")
			if(!src.left_arm)
				return
			var/datum/handHolder/HH = hands[1]
			if(!HH.limb)
				return //in case two action bars are running at the same time, don't duplicate arms
			qdel(HH)
			new src.left_arm(src.loc)
			src.update_dead_icon()
			return
		if("right")
			if(!src.right_arm)
				return
			var/datum/handHolder/HH = hands[2]
			if(!HH.limb)
				return //in case two action bars are running at the same time, don't duplicate arms
			qdel(HH)
			new src.right_arm(src.loc)
			src.update_dead_icon()
			return

/mob/living/critter/proc/update_dead_icon() // for brullbar and bear missing arm sprites
	return

// The throw code is a direct copy-paste from humans
// pending better solution.
/mob/living/critter/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/critter/proc/throw_mode_off()
	src.in_throw_mode = 0
	src.update_cursor()
	hud.update_throwing()

/mob/living/critter/proc/throw_mode_on()
	if (!can_throw)
		return
	src.in_throw_mode = 1
	src.update_cursor()
	hud.update_throwing()

/mob/living/critter/throw_item(atom/target, list/params)
	..()
	if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANTTHROW))
		return
	if (!can_throw)
		return
	if (usr.stat)
		return

	var/obj/item/I = src.equipped()
	var/turf/thrown_from = get_turf(src)
	src.throw_mode_off()

	if (!I || !isitem(I) || I.cant_drop)
		return

	if (istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		I = G.handle_throw(src,target)
		if (G && !G.qdeled) //make sure it gets qdeled because our u_equip function sucks and doesnt properly call dropped()
			qdel(G)
		if (!I) return

	I.set_loc(src.loc)

	u_equip(I)

	if (isitem(I))
		I.dropped(src) // let it know it's been dropped

	//actually throw it!
	if (I)
		attack_twitch(src)
		I.layer = initial(I.layer)
		var/throw_dir = get_dir(src, target)
		if(prob(yeet_chance))
			src.say("YEET")
			src.visible_message(SPAN_ALERT("[src] yeets [I]."))
			new/obj/effect/supplyexplosion(I.loc)

			playsound(I.loc, 'sound/effects/ExplosionFirey.ogg', 100, 1)

			for(var/mob/M in view(7, I.loc))
				shake_camera(M, 20, 8)

		else
			src.visible_message(SPAN_ALERT("[src] throws [I]."))
		if (iscarbon(I))
			var/mob/living/carbon/C = I
			logTheThing(LOG_COMBAT, src, "throws [constructTarget(C,"combat")] [dir2text(throw_dir)] at [log_loc(src)].")
			if ( ishuman(C) )
				C.changeStatus("knockdown", 1 SECOND)
		else
			// Added log_reagents() call for drinking glasses. Also the location (Convair880).
			logTheThing(LOG_COMBAT, src, "throws [I] [I.is_open_container() ? "[log_reagents(I)]" : ""] [dir2text(throw_dir)] at [log_loc(src)].")
		if (istype(src.loc, /turf/space) || src.no_gravity) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src) // Float opposite direction from throw
			step(src, inertia_dir)
		if ((istype(I.loc, /turf/space) || I.no_gravity) && ismob(I))
			var/mob/M = I
			M.inertia_dir = throw_dir

		playsound(src.loc, 'sound/effects/throw.ogg', 50, 1, 0.1)

		adjust_throw(I.throw_at(target, I.throw_range, I.throw_speed, params, thrown_from, src))

		SEND_SIGNAL(src, COMSIG_MOB_TRIGGER_THREAT)

/mob/living/critter/proc/can_pull(atom/A)
	if (!src.ghost_spawned) //if its an admin or wizard made critter, just let them pull everythang
		return 1
	if (ismob(A))
		return (src.pull_w_class >= W_CLASS_NORMAL)
	else if (isobj(A))
		if (istype(A,/obj/item))
			var/obj/item/I = A
			return (pull_w_class >= I.w_class)
		else
			return (src.pull_w_class >= W_CLASS_BULKY)
	return 0

/mob/living/critter/click(atom/target, list/params)
	var/obj/item/thing = src.equipped() || src.l_hand || src.r_hand
	if (src.client?.check_key(KEY_THROW) && src.a_intent == "help" && thing && isliving(target) && BOUNDS_DIST(src, target) <= 0)
		usr = src
		var/mob/living/living_target = target
		living_target.give_item()
		return
	else if (src.client.check_key(KEY_THROW) && !src.equipped() && BOUNDS_DIST(src, target) <= 0)
		if (src.auto_pickup_item(target))
			return
	else if ((src.client?.check_key(KEY_THROW) || src.in_throw_mode) && src.can_throw)
		src.throw_item(target,params)
		return
	return ..()

/mob/living/critter/update_cursor()
	if (((src.client && src.client.check_key(KEY_THROW)) || src.in_throw_mode) && src.can_throw)
		src.set_cursor('icons/cursors/throw.dmi')
		return
	return ..()

//just adjust by whatever the critter var says the movedelay should be
/mob/living/critter/special_movedelay_mod(delay,space_movement,aquatic_movement)
	.= delay
	if (src.m_intent == "walk")
		. += src.base_walk_delay - (BASE_SPEED + WALK_DELAY_ADD)
	else
		. += src.base_move_delay - (BASE_SPEED)
	if (src.lying)
		. += 14

/mob/living/critter/Move(var/turf/NewLoc, direct)
	if (!src.lying && isturf(NewLoc) && NewLoc.turf_flags & MOB_STEP)
		if (NewLoc.active_liquid)
			if (NewLoc.active_liquid.step_sound)
				if (src.m_intent == "run" || src.m_intent == "walk" )
					if (src.footstep >= 4)
						src.footstep = 0
					else
						src.footstep++
					if (src.footstep == 0)
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 50, 1)
				else
					if (src.footstep >= 2)
						src.footstep = 0
					else
						src.footstep++
					if (src.footstep == 0)
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 20, 1)
		else if (src.stepsound)
			if (src.m_intent == "run" || src.m_intent == "walk" )
				if (src.footstep >= 2)
					src.footstep = 0
				else
					src.footstep++
				if (src.footstep == 0)
					playsound(NewLoc, src.stepsound, 50, 1)
			else
				playsound(NewLoc, src.stepsound, 20, 1)
	. = ..()

/mob/living/critter/update_clothing()
	equipment_image.overlays.len = 0
	for (var/datum/equipmentHolder/EH in equipment)
		EH.on_update()
		if (EH.item && EH.show_on_holder)
			var/obj/item/I = EH.item
			var/image/w_image = I.wear_image
			w_image.icon_state = "[I.icon_state]"
			w_image.layer = EH.equipment_layer
			w_image.alpha = I.alpha
			w_image.color = I.color
			w_image.pixel_x = EH.offset_x
			w_image.pixel_y = EH.offset_y
			equipment_image.overlays += w_image
	UpdateOverlays(equipment_image, "equipment")

/mob/living/critter/find_in_equipment(var/eqtype)
	for (var/datum/equipmentHolder/EH in equipment)
		if (EH.item && istype(EH.item, eqtype))
			return EH.item
	return null

/mob/living/critter/find_type_in_hand(var/eqtype)
	for (var/datum/handHolder/HH in hands)
		if (HH.item && istype(HH.item, eqtype))
			return HH.item
	return null

/mob/living/critter/is_in_hands(var/obj/O)
	for (var/datum/handHolder/HH in hands)
		if (HH.item && HH.item == O)
			return 1
	return 0

/mob/living/critter/find_in_hand(var/obj/item/I, var/this_hand)
	return is_in_hands(I) // vOv

/mob/living/critter/find_tool_in_hand(var/tool_flag, var/hand)
	for (var/datum/handHolder/HH in hands)
		var/obj/item/I = HH.item
		if (istype(I) && (I.tool_flags & tool_flag))
			return I
	return 0

// helper proc for mobcritter AI
/mob/living/critter/proc/set_hand(var/new_hand)
	if (!handcheck())
		return 0
	if (new_hand == active_hand)
		return 1
	if (new_hand > 0 && new_hand <= hands.len)
		var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
		if(B)
			qdel(B)

		var/obj/item/old = src.equipped()
		active_hand = new_hand
		hand = active_hand
		hud.update_hands()
		if(old != src.equipped())
			if(old)
				SEND_SIGNAL(old, COMSIG_ITEM_SWAP_AWAY, src)
			if(src.equipped())
				SEND_SIGNAL(src.equipped(), COMSIG_ITEM_SWAP_TO, src)
		return 1
	return 0

/mob/living/critter/proc/get_ranged_hands(var/mob/user)
	var/list/ranged_hands = null
	for (var/datum/handHolder/HH as anything in hands)
		if (HH.can_range_attack)
			ranged_hands.Add(HH)
	return ranged_hands

/mob/living/critter/proc/get_melee_hands(var/mob/user)
	var/list/melee_hands = null
	for (var/datum/handHolder/HH as anything in hands)
		if (HH.can_attack)
			melee_hands.Add(HH)
	return melee_hands

/mob/living/critter/swap_hand()
	if (!handcheck())
		return
	var/obj/item/old = src.equipped()

	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B)
		qdel(B)

	if (active_hand < hands.len)
		set_hand(active_hand + 1)
	else
		set_hand(1)
	hud.update_hands()
	src.update_inhands()
	if (old != src.equipped())
		if(old)
			SEND_SIGNAL(old, COMSIG_ITEM_SWAP_AWAY, src)
		if(src.equipped())
			SEND_SIGNAL(src.equipped(), COMSIG_ITEM_SWAP_TO, src)

/mob/living/critter/hand_range_attack(atom/target, params) // Returns true for successful attack false if on cooldown or HH is incorrect
	var/datum/handHolder/HH = get_active_hand()
	if (HH && (HH.can_range_attack || HH.can_special_attack()) && HH.limb)
		HH.limb.attack_range(target, src, params)
		HH.set_cooldown_overlay()
		src.lastattacked = src
		return TRUE
	return FALSE

/mob/living/critter/weapon_attack(atom/target, obj/item/W, reach, params)
	if (isobj(target))
		var/obj/O = target
		if(issmallanimal(src) && src.ghost_spawned && HAS_FLAG(O.object_flags, NO_GHOSTCRITTER))
			return
	. = ..()

/mob/living/critter/hand_attack(atom/target, params)
	if (src.fits_under_table && (istype(target, /obj/machinery/optable) || istype(target, /obj/table) || istype(target, /obj/stool/bed)))
		if (src.loc == target.loc)
			if (table_hide)
				table_hide = 0
				src.layer = MOB_LAYER
				src.visible_message("[src] crawls on top of [target]!")
			else
				table_hide = 1
				src.layer = target.layer - 0.01
				src.visible_message("[src] hides under [target]!")
			return
	var/datum/limb/L = equipped_limb()
	var/datum/handHolder/HH = get_active_hand()
	if (!L || !HH)
		return
	if ((HH.can_range_attack || HH.can_special_attack()))
		if (GET_DIST(src, target) > 1)
			hand_range_attack(target, params)
			return
	if (HH.can_attack)
		L.attack_hand(target, src)
		HH.set_cooldown_overlay()
	else
		boutput(src, SPAN_ALERT("You cannot attack with your [HH.name]!"))

/mob/living/critter/can_strip(mob/M)
	var/datum/handHolder/HH = get_active_hand()
	if(check_target_immunity(src, 1, M))
		return 0
	if (!HH)
		return 0
	if (HH.can_hold_items)
		return 1
	else
		boutput(src, SPAN_ALERT("You cannot strip other people with your [HH.name]."))

/mob/living/critter/proc/on_pet(mob/user)
	if (!user)
		return 1 // so things can do if (..())
	var/pmsg = islist(src.pet_text) ? pick(src.pet_text) : src.pet_text
	src.visible_message(SPAN_NOTICE("<b>[user] [pmsg] [src]!</b>"),\
		SPAN_NOTICE("<b>[user] [pmsg] you!</b>"), group="critter_pet")
	user.add_karma(0.5)
	return

/mob/living/critter/proc/get_active_hand()
	RETURN_TYPE(/datum/handHolder)
	if (!handcheck())
		return null
	return hands[active_hand]

/mob/living/critter/proc/setup_hands()
	if (hand_count)
		for (var/i = 1, i <= hand_count, i++)
			var/datum/handHolder/HH = new
			HH.holder = src
			hands += HH
		active_hand = 1
		set_hand(1)

/mob/living/critter/proc/post_setup_hands()
	if (hand_count)
		for (var/datum/handHolder/HH in hands)
			if (!HH.limb)
				HH.limb = new /datum/limb
			HH.spawn_dummy_holder()

/mob/living/critter/proc/setup_equipment_slots()

/mob/living/critter/proc/setup_reagents()
	reagent_capacity = max(0, reagent_capacity)
	var/datum/reagents/R = new(reagent_capacity)
	R.my_atom = src
	reagents = R

/mob/living/critter/equipped()
	RETURN_TYPE(/obj/item)
	if (active_hand)
		if (length(src.hands) >= active_hand)
			var/datum/handHolder/HH = hands[active_hand]
			return HH.item
	return null

/mob/living/critter/u_equip(var/obj/item/I)
	var/inhand = 0
	var/clothing = 0
	for (var/datum/handHolder/HH in hands)
		if (HH.item == I)
			HH.item = null
			hud.remove_object(I)
			inhand = 1
	if (inhand)
		update_inhands()
	for (var/datum/equipmentHolder/EH in equipment)
		if (EH.item == I)
			EH.on_unequip()
			EH.item = null
			hud.remove_object(I)
			clothing = 1
	if (clothing)
		update_clothing()
	if(isitem(I))
		I.dropped(src)

/mob/living/critter/has_any_hands()
	. = length(hands)

/mob/living/critter/put_in_hand(obj/item/I, t_hand)
	if (!hands.len)
		return 0
	if (t_hand)
		if (t_hand > hands.len)
			return 0
		var/datum/handHolder/HH = hands[t_hand]
		if (HH.item || !HH.can_hold_items)
			return 0
		if(istype(HH.limb, /datum/limb/small_critter))
			var/datum/limb/small_critter/L = HH.limb
			if(I.w_class > L.max_wclass && !istype(I,/obj/item/grab)) //shitty grab check
				return 0
		HH.item = I
		I.set_loc(src)
		hud.add_object(I, HUD_LAYER+2, HH.screenObj.screen_loc)
		update_inhands()
		I.pickup(src) // attempted fix for flashlights not working - cirr
		return 1
	else if (active_hand)
		var/datum/handHolder/HH = hands[active_hand]
		if (HH.item || !HH.can_hold_items)
			return 0
		if(istype(HH.limb, /datum/limb/small_critter))
			var/datum/limb/small_critter/L = HH.limb
			if(I.w_class > L.max_wclass && !istype(I,/obj/item/grab)) //shitty grab check
				return 0
		HH.item = I
		if (I.stored)
			I.stored.transfer_stored_item(I, src, user = src)
		else
			I.set_loc(src)
		hud.add_object(I, HUD_LAYER+2, HH.screenObj.screen_loc)
		update_inhands()
		I.pickup(src) // attempted fix for flashlights not working - cirr
		return 1
	return 0

/mob/living/critter/death(var/gibbed, var/do_drop_equipment = 1)
	if (src.organHolder)
		// believe me i hate this as much as you do
		// There is some sort of behavior on living critters that ejects all of their contents at the moment of death. We want to avoid that - brain should stay inside. HOWEVER I can't find where the ejection happens for the life of me!
		// So now we do this dumb re-insertion of the brain (until the issue can be addressed properly)
		var/obj/item/organ/O = src.organHolder.get_organ("brain")
		if (O)
			O.set_loc(src)
	src.mind?.register_death() // it'd be nice if critters get a time of death too tbh
	set_density(0)
	if (src.can_implant)
		for (var/obj/item/implant/H in src.implants)
			H.on_death()
		src.can_implant = 0
	if (!gibbed)
		if (src.death_text)
			src.tokenized_message(src.death_text, null, "red")
		else
			src.visible_message(SPAN_ALERT("<b>[src]</b> dies!"))
		setdead(src)
		icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead"
		src.update_body()
	empty_hands()
	if (do_drop_equipment)
		drop_equipment()
	hud?.update_health()
	update_stunned_icon(canmove=1)//force it to go away
	reduce_lifeprocess_on_death()
	return ..(gibbed)

/mob/living/critter/proc/reduce_lifeprocess_on_death() //quit doing stuff when you're dead
	remove_lifeprocess(/datum/lifeprocess/blood)
	remove_lifeprocess(/datum/lifeprocess/disability)
	remove_lifeprocess(/datum/lifeprocess/hud)
	remove_lifeprocess(/datum/lifeprocess/mutations)
	remove_lifeprocess(/datum/lifeprocess/organs)
	remove_lifeprocess(/datum/lifeprocess/sight)
	remove_lifeprocess(/datum/lifeprocess/statusupdate)
	remove_lifeprocess(/datum/lifeprocess/radiation)

/mob/living/critter/proc/get_health_holder(var/assoc)
	if (assoc in healthlist)
		return healthlist[assoc]
	return null

/mob/living/critter/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()
	src.visible_message(SPAN_ALERT("[src] has been hit by [AM]."))
	random_brute_damage(src, AM.throwforce, TRUE)
	if (src.client)
		logTheThing(LOG_COMBAT, src, "is struck by [AM] [AM.is_open_container() ? "[log_reagents(AM)]" : ""] at [log_loc(src)] (likely thrown by [thr?.user ? constructName(thr.user) : "a non-mob"]).")
	if(thr?.user)
		src.was_harmed(thr.user, AM)

/mob/living/critter/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	if (brute > 0 || burn > 0 || tox > 0)
		hit_twitch(src)
	if (nodamage)
		return
	var/datum/healthHolder/Br = get_health_holder("brute")
	if (Br)
		Br.TakeDamage(brute)
	var/datum/healthHolder/Bu = get_health_holder("burn")
	if (src.bioHolder?.HasEffect("fire_resist") > 1)
		burn /= 2
	if (Bu)
		Bu.TakeDamage(burn)
	take_toxin_damage(tox)

/mob/living/critter/take_brain_damage(var/amount)
	if (..())
		return 1
	if (nodamage)
		return
	var/datum/healthHolder/Br = get_health_holder("brain")
	if (Br)
		Br.TakeDamage(amount)
	return 0

/mob/living/critter/take_toxin_damage(var/amount)
	if (..())
		return 1
	if (nodamage)
		return
	var/datum/healthHolder/Tx = get_health_holder("toxin")
	if (Tx)
		Tx.TakeDamage(amount)
	return 0

/mob/living/critter/take_oxygen_deprivation(var/amount)
	if (..())
		return 1
	if (nodamage)
		return
	var/datum/healthHolder/Ox = get_health_holder("oxy")
	if (Ox)
		Ox.TakeDamage(amount)
	return 0

/mob/living/critter/get_brute_damage()
	var/datum/healthHolder/Br = get_health_holder("brute")
	if (Br)
		return Br.maximum_value - Br.value
	else
		return 0

/mob/living/critter/get_burn_damage()
	var/datum/healthHolder/Bu = get_health_holder("burn")
	if (Bu)
		return Bu.maximum_value - Bu.value
	else
		return 0

/mob/living/critter/get_brain_damage()
	var/datum/healthHolder/Br = get_health_holder("brain")
	if (Br)
		return Br.maximum_value - Br.value
	else
		return 0

/mob/living/critter/get_toxin_damage()
	var/datum/healthHolder/Tx = get_health_holder("toxin")
	if (Tx)
		return Tx.maximum_value - Tx.value
	else
		return 0

/mob/living/critter/get_oxygen_deprivation()
	var/datum/healthHolder/Ox = get_health_holder("oxy")
	if (Ox)
		return Ox.maximum_value - Ox.value
	else
		return 0

/mob/living/critter/lose_breath(var/amount)
	if (..())
		return 1
	var/datum/healthHolder/suffocation/Ox = get_health_holder("oxy")
	if (!istype(Ox))
		return 0
	Ox.lose_breath(amount)
	return 0

/mob/living/critter/HealDamage(zone, brute, burn, tox)
	..()
	TakeDamage(zone, -brute, -burn, -tox)


/mob/living/critter/updatehealth()
	if (src.nodamage)
		if (src.health != src.max_health)
			full_heal()
		src.health = src.max_health
		setalive(src)
		src.icon_state = src.icon_state_alive ? src.icon_state_alive : initial(src.icon_state)
	else
		src.health = src.max_health
		for (var/T in src.healthlist)
			var/datum/healthHolder/HH = src.healthlist[T]
			if (HH.count_in_total)
				src.health -= (HH.maximum_value - HH.value)
	src.hud.update_health()
	if (src.health <= 0 && !isdead(src))
		death()

/mob/living/critter/proc/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	return null

/mob/living/critter/proc/specific_emote_type(var/act)
	return 1

/mob/living/critter/update_inhands()
	var/handcount = 0
	for (var/datum/handHolder/HH as anything in src.hands)
		handcount++
		if (HH.object_for_inhand)
			var/obj/item/I = new HH.object_for_inhand
			var/image/inhand = image(icon = I.inhand_image_icon, icon_state = "[I.item_state][HH.suffix]",
									layer = HH.render_layer, pixel_x = HH.offset_x, pixel_y = HH.offset_y)
			qdel(I)
			src.UpdateOverlays(inhand, "inhands_[handcount]")
			continue // If we have inhands we probably can't hold things
		var/obj/item/I = HH.item
		if (HH.show_inhands)
			if (!I)
				src.UpdateOverlays(null, "inhands_[handcount]")
				continue
			if (!I.inhand_image)
				I.inhand_image = image(I.inhand_image_icon, "", HH.render_layer)
			I.inhand_image.icon_state = I.item_state ? "[I.item_state][HH.suffix]" : "[I.icon_state][HH.suffix]"
			I.inhand_image.pixel_x = HH.offset_x
			I.inhand_image.pixel_y = HH.offset_y
			I.inhand_image.layer = HH.render_layer
			src.UpdateOverlays(I.inhand_image, "inhands_[handcount]")

// helper proc for AI
/mob/living/critter/proc/empty_hand(var/hand_to_empty)
	if(hand_to_empty > 0 && hand_to_empty <= hands.len)
		var/datum/handHolder/HH = hands[hand_to_empty]
		if (HH.item)
			if (!HH.item.qdeled && !HH.item.disposed && istype(HH.item, /obj/item/grab))
				qdel(HH.item)
				return
			var/obj/item/I = HH.item
			I.set_loc(src.loc)
			I.layer = initial(I.layer)
			u_equip(I)

/mob/living/critter/empty_hands()
	for (var/datum/handHolder/HH in hands)
		if (HH.item)
			if (!HH.item.qdeled && !HH.item.disposed && istype(HH.item, /obj/item/grab))
				qdel(HH.item)
				continue
			var/obj/item/I = HH.item
			I.set_loc(src.loc)
			I.layer = initial(I.layer)
			u_equip(I)

/mob/living/critter/proc/drop_equipment()
	for (var/datum/equipmentHolder/EH in equipment)
		if (EH.item)
			EH.drop(1)

/mob/living/critter/emote(var/act, var/voluntary = 0)
	..()
	var/param = null
	if (src.hasStatus("paralysis"))
		return //aaaa
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/maptext_out = 0
	var/message = specific_emotes(act, param, voluntary)
	var/m_type = specific_emote_type(act)
	var/custom = 0 //Sorry, gotta make this for chat groupings.
	if (!message)
		switch (lowertext(act))
			if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
				if (src.emote_check(voluntary, 10))
					// visible targeted emotes
					if (!src.restrained())
						var/M = null
						if (param)
							for (var/mob/A in view(null, null))
								if (ckey(param) == ckey(A.name))
									M = A
									break
						if (!M)
							param = null

						act = lowertext(act)
						if (param)
							switch(act)
								if ("bow","wave","nod")
									message = "<B>[src]</B> [act]s to [param]."
									maptext_out = "<I>[act]s to [M]</I>"
								if ("glare","stare","look","leer")
									message = "<B>[src]</B> [act]s at [param]."
									maptext_out = "<I>[act]s at [M]</I>"
								else
									message = "<B>[src]</B> [act]s [param]."
									maptext_out = "<I>[act]s [M]</I>"
						else
							switch(act)
								if ("hug")
									message = "<B>[src]</b> [act]s itself."
									maptext_out = "<I>[act]s itself</I>"
								else
									message = "<B>[src]</b> [act]s."
									maptext_out = "<I>[act]s [M]</I>"
					else
						message = "<B>[src]</B> struggles to move."
						maptext_out = "<I>[src] struggles to move</I>"
					m_type = 1
			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
				// basic visible single-word emotes
				if (src.emote_check(voluntary, 10))
					message = "<B>[src]</B> [act]s."
					maptext_out = "<I>[act]s</I>"
					m_type = 1
			if ("gasp","cough","laugh","giggle","sigh")
				// basic hearable single-word emotes
				if (src.emote_check(voluntary, 10))
					message = "<B>[src]</B> [act]s."
					maptext_out = "<I>[act]s</I>"
					m_type = 2
			if ("customv")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				custom = copytext(param, 1, 10)
				m_type = 1
			if ("customh")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				custom = copytext(param, 1, 10)
				m_type = 2
			if ("me")
				if (!param)
					return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[regex({"(&#34;.*?&#34;)"}, "g").Replace(param, "</i>$1<i>")]</I>"
				custom = copytext(param, 1, 10)
				m_type = 1
			if ("flip")
				if (src.emote_check(voluntary, 50))
					if (isobj(src.loc))
						var/obj/container = src.loc
						container.mob_flip_inside(src)
					else
						message = "<b>[src]</B> does a flip!"
						animate_spin(src, pick("L", "R"), 1, 0)
	if (maptext_out && !ON_COOLDOWN(src, "emote maptext", 0.5 SECONDS))
		var/image/chat_maptext/chat_text = null
		SPAWN(0) //blind stab at a life() hang - REMOVE LATER
			if (speechpopups && src.chat_text)
				chat_text = make_chat_maptext(src, maptext_out, "color: #C2BEBE;" + src.speechpopupstyle, alpha = 140)
				if(chat_text)
					if(m_type & 1)
						chat_text.plane = PLANE_NOSHADOW_ABOVE
						chat_text.layer = 420
					chat_text.measure(src.client)
					for(var/image/chat_maptext/I in src.chat_text.lines)
						if(I != chat_text)
							I.bump_up(chat_text.measured_height)
			if (message)
				logTheThing(LOG_SAY, src, "EMOTE: [message]")
				act = lowertext(act)
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (m_type & 2)
					for (var/mob/O in hearers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (!isturf(src.loc))
					var/atom/A = src.loc
					for (var/mob/O in A.contents)
						O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
	else
		if (message)
			logTheThing(LOG_SAY, src, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message(SPAN_EMOTE("[message]"), m_type)


/mob/living/critter/talk_into_equipment(var/mode, var/message, var/param)
	switch (mode)
		if ("left hand")
			for (var/i = 1, i <= hands.len, i++)
				var/datum/handHolder/HH = hands[i]
				if (HH.can_hold_items)
					if (HH.item)
						HH.item.talk_into(src, message, param, src.real_name)
					return
		if ("right hand")
			for (var/i = hands.len, i >= 1, i--)
				var/datum/handHolder/HH = hands[i]
				if (HH.can_hold_items)
					if (HH.item)
						HH.item.talk_into(src, message, param, src.real_name)
					return
		else
			..()

/mob/living/critter/update_burning()
	if (can_burn)
		..()

/mob/living/critter/update_burning_icon(var/force_remove)
	var/datum/statusEffect/simpledot/burning/B = hasStatus("burning")

	if (!B || force_remove)
		UpdateOverlays(null, "burning")
		return
	burning_image.icon_state = "fire[B.getStage()]-[burning_suffix]"
	UpdateOverlays(burning_image, "burning")

/mob/living/critter/force_laydown_standup()
	..()
	update_stunned_icon(canmove)

/mob/living/critter/proc/update_stunned_icon(var/canmove)
	if (use_stunned_icon)
		if (canmove != src.old_canmove)
			src.old_canmove = canmove
			if (canmove || isdead(src))
				src.UpdateOverlays(null, "dizzy")
				return
			var/image/dizzyStars = src.SafeGetOverlayImage("dizzy", 'icons/mob/critter/overlays.dmi', "dizzy", MOB_OVERLAY_BASE + 20) // why such a big boost? because the critter could have a bunch of overlays, that's why
			if (dizzyStars)
				src.UpdateOverlays(dizzyStars, "dizzy")

/mob/living/critter/proc/get_head_armor_modifier()
	var/armor_mod = 0
	for (var/datum/equipmentHolder/EH in equipment)
		if ((EH.armor_coverage & HEAD) && istype(EH.item, /obj/item/clothing))
			var/obj/item/clothing/C = EH.item
			armor_mod = max(C.getProperty("meleeprot"), armor_mod)
	return armor_mod

/mob/living/critter/proc/get_chest_armor_modifier()
	var/armor_mod = 0
	for (var/datum/equipmentHolder/EH in equipment)
		if ((EH.armor_coverage & TORSO) && istype(EH.item, /obj/item/clothing))
			var/obj/item/clothing/C = EH.item
			armor_mod = max(C.getProperty("meleeprot"), armor_mod)
	return armor_mod

/mob/living/critter/get_melee_protection(zone, damage_type)//critters and stuff, I suppose
	var/add = 0
	var/obj/item/grab/block/G = src.check_block()
	if (G)
		add += 1
		if (G != src.equipped())
			add += G.can_block(damage_type)

	if(zone == "head")
		return get_head_armor_modifier() + add
	else
		return get_chest_armor_modifier() + add

/mob/living/critter/full_heal()
	..()
	icon_state = icon_state_alive ? icon_state_alive : initial(icon_state)
	density = initial(density)
	src.can_implant = initial(src.can_implant)
	blood_volume = initial(blood_volume)

/mob/living/critter/does_it_metabolize()
	return metabolizes

/mob/living/critter/is_heat_resistant()
	if (!get_health_holder("burn"))
		return TRUE
	return ..()

/mob/living/critter/ex_act(var/severity)
	..() // Logs.
	var/ex_res = get_explosion_resistance()
	if (ex_res >= 0.35 && prob(ex_res * 100))
		severity++
	if (ex_res >= 0.8 && prob(ex_res * 75))
		severity++
	switch(severity)
		if (1)
			SPAWN(0)
				gib()
		if (2)
			if (health < max_health * 0.35 && prob(50))
				SPAWN(0)
					gib()
			else
				TakeDamage("All", rand(10, 30), rand(10, 30))
		if (3)
			TakeDamage("All", rand(20, 20))

/mob/living/critter/ghostize()
	var/ghost_icon = src.icon
	if (isnull(src.icon))
		ghost_icon = initial(src.icon)
	var/ghost_icon_state
	if (src.icon_state_ghost)
		ghost_icon_state = src.icon_state_ghost
	else if (src.icon_state_alive)
		ghost_icon_state = src.icon_state_alive
	else
		ghost_icon_state = initial(src.icon_state)

	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon = ghost_icon
	O.icon_state = ghost_icon_state

	animate_fade_grayscale(O, 1)
	O.pixel_y = initial(src.pixel_y) // byond's animation system is dumb so this needs to be done to fix things
	animate_bumble(O)
	O.alpha = 160
	if(src.ghost_spawned && src.original_name)
		O.name = src.original_name
		O.real_name = src.original_name
	return O

/mob/living/critter/drop_item()
	. = ..()
	src.update_inhands()

/mob/living/critter/proc/on_sleep()
	return

/mob/living/critter/proc/on_wake()
	return

//the following procs are used to make transitioning from /obj/critter to /mob/living/critter easier. If you don't have to use them, you probably shouldn't.

/// Used for generic critter mobAI - targets returned from this proc will be chased and attacked. Return a list of potential targets, one will be picked based on distance.
/mob/living/critter/proc/seek_target(var/range = 5)
	. = list()
	//default behaviour, return all alive, tangible, not-our-type, not-our-faction mobs in range
	for (var/mob/living/C in hearers(range, src))
		if (src.valid_target(C))
			. += C

/mob/living/critter/proc/valid_target(var/mob/living/C)
	if (isintangible(C)) return FALSE
	if (isdead(C)) return FALSE
	if (istype(C, src.type)) return FALSE
	if (isghostcritter(C) || isghostdrone(C)) return FALSE
	if (C in src.friends) return FALSE
	return faction_check(src, C, src.ai_attacks_neutral)

/// Used for generic critter mobAI - targets returned from this proc will be chased and scavenged. Return a list of potential targets, one will be picked based on distance.
/mob/living/critter/proc/seek_scavenge_target(var/range = 5)
	. = list()
	for (var/mob/living/carbon/human/H in view(range, get_turf(src)))
		if (isdead(H) && H.decomp_stage <= 3 && !H.bioHolder?.HasEffect("husk")) //is dead, isn't a skeleton, isn't a grody husk
			. += H

/// Used for generic critter mobAI - targets returned from this proc will be chased and eaten. Return a list of potential targets, one will be picked based on distance.
/mob/living/critter/proc/seek_food_target(var/range = 5)
	. = list()
	for (var/obj/item/reagent_containers/food/snacks/S in view(range, get_turf(src)))
		. += S

/// Used for generic critter mobAI - override if your critter needs special attack behaviour. If you need super special attack behaviour, you'll want to create your own attack aiTask
/mob/living/critter/proc/critter_attack(var/mob/target)
	if (src.ai_attack_count >= src.ai_attacks_per_ability)
		if (src.critter_ability_attack(target))
			src.ai_attack_count = 0 //ability used successfully, reset the count
			return
	//Check if we can range attack, if not default to a basic attack
	var/datum/handHolder/hand = src.get_active_hand()
	if (hand && hand.can_range_attack)
		if (src.critter_range_attack(target))
			src.ai_attack_count += 1
	else
		if (src.critter_basic_attack(target))
			src.ai_attack_count += 1

/// Used for generic critter mobAI - override if your critter needs additional behaviour for eating
/mob/living/critter/proc/critter_eat(var/obj/item/target)
	target.Eat(src, src, TRUE)


/// How the critter should attack normally
/mob/living/critter/proc/critter_basic_attack(var/mob/target)
	src.set_a_intent(INTENT_HARM)
	src.hand_attack(target)
	return TRUE

/// How the critter should attack from range (Only applicable for ranged limbs)
/mob/living/critter/proc/critter_range_attack(var/mob/target)
	src.set_a_intent(INTENT_HARM)
	src.hand_attack(target)
	return TRUE

///How the critter should use abilities, return TRUE to indicate ability usage success
/mob/living/critter/proc/critter_ability_attack(var/mob/target)
	return FALSE

/// Used for generic critter mobAI - override if your critter needs special scavenge behaviour. If you need super special attack behaviour, you'll want to create your own attack aiTask
/mob/living/critter/proc/critter_scavenge(var/mob/target)
	src.set_a_intent(INTENT_HARM)
	src.hand_attack(target)
	return TRUE

/// Used for generic critter mobAI - override if you need special retailation behaviour
/mob/living/critter/proc/critter_retaliate(var/mob/target)
	src.critter_attack(target)

/// Used for generic critter mobAI - returns TRUE when the mob is able to attack. For handling cooldowns, or other attack blocking conditions.
/mob/living/critter/proc/can_critter_attack()
	var/datum/handHolder/HH = get_active_hand()
	if(HH?.limb)
		return !HH.limb.is_on_cooldown() && can_act(src,TRUE) //if we have limb cooldowns, use that, otherwise use can_act()
	return can_act(src,TRUE)

/// Used for generic critter mobAI - returns TRUE when the mob is able to scavenge. For handling cooldowns, or other scavenge blocking conditions.
/mob/living/critter/proc/can_critter_scavenge()
	return can_act(src,TRUE)

/// Used for generic critter mobAI - returns TRUE when the mob is able to eat. For handling cooldowns, or other eat blocking conditions.
/mob/living/critter/proc/can_critter_eat()
	return can_act(src,TRUE)

/// Used for generic critter mobAI - returns TRUE when the mob should retaliate to this attack. Only used if ai_retaliates = TRUE
/mob/living/critter/proc/should_critter_retaliate(var/mob/attcker, var/obj/attcked_with)
	return src.ai_retaliates && (src._ai_patience_count <= 0)


/mob/living/critter/bump(atom/A)
	var/atom/movable/AM = A
	if(issmallanimal(src) && src.ghost_spawned && istype(AM) && !AM.anchored)
		return
	. = ..()

/mob/living/critter/set_a_intent(intent)
	. = ..()
	src.hud?.update_intent()

/mob/living/critter/hotkey(name)
	switch (name)
		if ("help")
			src.set_a_intent(INTENT_HELP)
		if ("disarm")
			src.set_a_intent(INTENT_DISARM)
		if ("grab")
			src.set_a_intent(INTENT_GRAB)
		if ("harm")
			src.set_a_intent(INTENT_HARM )
		if ("drop")
			src.drop_item(null, TRUE)
		if ("swaphand")
			src.swap_hand()
		if ("attackself")
			var/obj/item/W = src.equipped()
			if (W)
				src.click(W, list())
			else
				var/datum/handHolder/HH = src.get_active_hand()
				if(HH?.limb)
					HH.limb.attack_self(src)
		if ("togglethrow")
			src.toggle_throw_mode()
		if ("walk")
			if (src.m_intent == "run")
				src.m_intent = "walk"
			else
				src.m_intent = "run"
			boutput(src, "You are now [src.m_intent == "walk" ? "walking" : "running"].")
			hud.update_mintent()
		else
			return ..()

/mob/living/critter/build_keybind_styles(client/C)
	..()
	C.apply_keybind("human")

	if (!C.preferences.use_wasd)
		C.apply_keybind("human_arrow")

	if (C.preferences.use_azerty)
		C.apply_keybind("human_azerty")
	if (C.tg_controls)
		C.apply_keybind("human_tg")
		if (C.preferences.use_azerty)
			C.apply_keybind("human_tg_azerty")

/mob/living/critter/proc/tokenized_message(var/message, var/target, var/mcolor)
	if (!message || !length(message))
		return
	var/msg = replacetext(message, "%src%", "<b>[src]</b>")
	if (target)
		msg = replacetext(msg, "[constructTarget(target,"combat")]", "[target]")
	if (mcolor)
		msg = "<span style='color:[mcolor]'>" + msg + "</span>"
	src.visible_message(msg)

/mob/living/critter/say(var/message)
	message = copytext(message, 1, MAX_MESSAGE_LEN)

	if (dd_hasprefix(message, "*") || isdead(src))
		..(message)
		return

	if (src.robot_talk_understand && !src.stat && !ghost_spawned)
		if (length(message) >= 2)
			if (copytext(lowertext(message), 1, 3) == ":s")
				message = copytext(message, 3)
				src.robot_talk(message)
				return
	..()

/mob/living/critter/blob_act(var/power)
	logTheThing(LOG_COMBAT, src, "is hit by a blob")

	if (isdead(src) || src.nodamage)
		return

	var/shielded = 0
	if (src.spellshield)
		shielded = 1

	var/modifier = power / 20
	var/damage = rand(modifier, 12 + 8 * modifier)

	var/list/shield_amt = list()
	SEND_SIGNAL(src, COMSIG_MOB_SHIELD_ACTIVATE, damage * 2, shield_amt)
	damage *= max(0, (1-shield_amt["shield_strength"]))

	if (shielded)
		damage /= 4
		//src.paralysis += 1

	src.show_message(SPAN_ALERT("The blob attacks you!"))

	if (src.spellshield)
		boutput(src, SPAN_ALERT("<b>Your Spell Shield absorbs some damage!</b>"))

	if (damage > 4.9)
		if (prob(50))
			changeStatus("knockdown", 5 SECONDS)
			for (var/mob/O in viewers(src, null))
				O.show_message(SPAN_ALERT("<B>The blob has knocked down [src]!</B>"), 1, SPAN_ALERT("You hear someone fall."), 2)
		else
			src.changeStatus("stunned", 5 SECONDS)
			for (var/mob/O in viewers(src, null))
				if (O.client)	O.show_message(SPAN_ALERT("<B>The blob has stunned [src]!</B>"), 1)
		if (isalive(src))
			src.lastgasp() // calling lastgasp() here because we just got knocked out

	src.TakeDamage("All", damage, 0)
	return

/mob/living/critter/Logout()
	..()
	//no key should mean that they transferred somewhere else and aren't just temporarily logged out
	if (src.ai && !src.ai.enabled && src.is_npc && !src.key && !QDELETED(src))
		ai.enable()

/mob/living/critter/Login()
	..()
	if (src.ai?.enabled && src.is_npc)
		ai.disable()
		var/datum/targetable/A = src.abilityHolder?.getAbility(/datum/targetable/ai_toggle)
		A?.updateObject()

/mob/living/critter/proc/admincmd_attack()
	set name = "Start Attacking"
	if(isnull(src.ai))
		boutput(src, SPAN_ALERT("This mob has no AI."))
		return
	var/mob/living/target = pick_ref(usr)
	if(!istype(target))
		boutput(usr, SPAN_ALERT("Invalid target."))
		return
	if(!src.ai.enabled)
		src.ai.enable()
	var/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/task = \
		src.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/fixed_target, list(src.ai, src.ai.default_task, target))
	task.transition_task = task
	src.ai.interrupt_to_task(task)

/mob/living/critter/proc/admincmd_reset_task()
	set name = "Reset AI Task"
	if(isnull(src.ai))
		boutput(src, SPAN_ALERT("This mob has no AI."))
		return
	if(!src.ai.enabled)
		src.ai.enable()
	src.ai.interrupt()

/mob/living/critter/was_built_from_frame(mob/user, newly_built)
	. = ..()
	wake_from_hibernation()

/mob/living/critter/can_hold_two_handed()
	return TRUE // critters can hold two handed items in one hand

/mob/living/critter/get_genetic_traits()
	if(has_genes)
		switch(rand(1,10))
			if(1)
				. = list(2,0,0)
			if(2)
				. = list(1,1,0)
			if(3 to 4)
				. = list(0,2,0)
			if(5 to 7)
				. = list(0,1,0)
			else
				. = list()

/mob/living/critter/has_genetics()
	return has_genes

ABSTRACT_TYPE(/mob/living/critter/robotic)
/// Parent for robotic critters. Handles some traits that robots should have- damaged by EMPs, immune to fire and rads
/mob/living/critter/robotic
	name = "a fucked up robot"
	butcherable = BUTCHER_NOT_ALLOWED
	can_bleed = FALSE
	can_throw = TRUE
	metabolizes = FALSE
	var/emp_vuln = 1
	blood_id = null

	New()
		..()
		src.reagents = null
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_HEATPROT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANNOT_VOMIT, src)

	/// EMP does 10 brute and 10 burn by default, can be adjusted linearly with emp_vuln
	emp_act()
		src.emag_act() // heh
		src.TakeDamage(10 * emp_vuln, 10 * emp_vuln)
		//gunbots have a LOT of disorient resist which is usually good but we want to bypass it here because EMPs are meant to mess with robots goddamnit!
		src.changeStatus("disorient", 4 SECONDS)

	can_eat()
		return FALSE

	can_drink()
		return FALSE

	isBlindImmune()
		return TRUE

	shock(var/atom/origin, var/wattage, var/zone = "chest", var/stun_multiplier = 1, var/ignore_gloves = 0)
		return 0

	electric_expose(var/power = 1)
		return 0

	is_heat_resistant()
		return TRUE
