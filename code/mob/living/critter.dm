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

	var/can_burn = 1
	var/can_throw = 0
	var/can_choke = 0
	var/in_throw_mode = 0

	var/can_help = 0
	var/can_grab = 0
	var/can_disarm = 0

	var/metabolizes = 1

	var/reagent_capacity = 50
	max_health = 0
	health = 0

	var/ultravision = 0
	var/tranquilizer_resistance = 0
	explosion_resistance = 0

	var/list/inhands = list()
	var/list/healthlist = list()

	var/list/implants = list()
	var/can_implant = 1

	var/death_text = null // can use %src%
	var/pet_text = "pets" // can be a list

	// moved up from critter/small_animal
	var/butcherable = 0
	var/meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	var/name_the_meat = 0
	var/skinresult = /obj/item/material_piece/cloth/leather //YEP
	var/max_skins = 0

	var/fits_under_table = 0
	var/table_hide = 0

	var/old_canmove
	var/dormant = 0

	var/custom_brain_type = null

	var/ghost_spawned = 0 //Am i inhabited by a ghost player who used the respawn critter option?
	var/original_name = null

	var/yeet_chance = 1 //yeet

	New()
		src.abilityHolder = new /datum/abilityHolder/critter(src)
		if (islist(src.add_abilities) && src.add_abilities.len)
			for (var/abil in src.add_abilities)
				if (ispath(abil))
					abilityHolder.addAbility(abil)
//		if (ispath(default_task))
//			default_task = new default_task
//		if (ispath(current_task))
//			current_task = new current_task

		setup_hands()
		post_setup_hands()
		setup_equipment_slots()
		setup_reagents()
		setup_healths()
		if (!healthlist.len)
			message_coders("ALERT: Critter [type] ([name]) does not have health holders.")
		count_healths()

		hud = new custom_hud_type(src)
		src.attach_hud(hud)
		src.zone_sel = new(src, "CENTER[hud.next_right()], SOUTH")
		SPAWN_DBG(0)
			src.zone_sel.change_hud_style('icons/mob/hud_human.dmi')
			src.attach_hud(zone_sel)

		for (var/datum/equipmentHolder/EE in equipment)
			EE.after_setup(hud)

		burning_image.icon = 'icons/misc/critter.dmi'
		burning_image.icon_state = null

		updatehealth()

		src.old_canmove = src.canmove

		if(!isnull(src.custom_organHolder_type))
			src.organHolder = new src.custom_organHolder_type(src, custom_brain_type)
		else
			src.organHolder = new/datum/organHolder/critter(src, custom_brain_type)
		..()

		SPAWN_DBG(0.5 SECONDS) //mbc what the fuck. i dont know why but if i don't spawn, no abilities even show up
			if (abilityHolder)
				abilityHolder.updateButtons()

	proc/setup_healths()
		// add_health_holder(/datum/healthHolder/flesh)
		// etc..

	proc/setup_overlays()
		//used for critters that have overlays for their bioholder (hair color eye color etc)

	proc/add_health_holder(var/T)
		var/datum/healthHolder/HH = new T
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

	proc/get_health_percentage()
		var/hp = 0
		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			if (HH.count_in_total)
				hp += HH.value
		if (max_health > 0)
			return hp / max_health
		return 0

	proc/count_healths()
		max_health = 0
		health = 0
		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			if (HH.count_in_total)
				max_health += HH.maximum_value
				health += HH.maximum_value

	// begin convenience procs
	proc/add_hh_flesh(var/min, var/max, var/mult)
		var/datum/healthHolder/Brute = add_health_holder(/datum/healthHolder/flesh)
		Brute.maximum_value = max
		Brute.value = max
		Brute.last_value = max
		Brute.damage_multiplier = mult
		Brute.depletion_threshold = min
		Brute.minimum_value = min
		return Brute

	proc/add_hh_flesh_burn(var/min, var/max, var/mult)
		var/datum/healthHolder/Burn = add_health_holder(/datum/healthHolder/flesh_burn)
		Burn.maximum_value = max
		Burn.value = max
		Burn.last_value = max
		Burn.damage_multiplier = mult
		Burn.depletion_threshold = min
		Burn.minimum_value = min
		return Burn

	proc/add_hh_robot(var/min, var/max, var/mult)
		var/datum/healthHolder/Brute = add_health_holder(/datum/healthHolder/structure)
		Brute.maximum_value = max
		Brute.value = max
		Brute.last_value = max
		Brute.damage_multiplier = mult
		Brute.depletion_threshold = min
		Brute.minimum_value = min
		return Brute

	proc/add_hh_robot_burn(var/min, var/max, var/mult)
		var/datum/healthHolder/Burn = add_health_holder(/datum/healthHolder/wiring)
		Burn.maximum_value = max
		Burn.value = max
		Burn.last_value = max
		Burn.damage_multiplier = mult
		Burn.depletion_threshold = min
		Burn.minimum_value = min
		return Burn

	// end convenience procs

	on_reagent_react(var/datum/reagents/R, var/method = 1, var/react_volume)
		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			HH.on_react(R, method, react_volume)

	proc/equip_click(var/datum/equipmentHolder/EH)
		if (!handcheck())
			return
		var/obj/item/I = equipped()
		var/obj/item/W = EH.item
		if (I && W)
			W.attackby(I, src) // fix runtime for null.find_type_in_hand - cirr
		else if (I)
			if (EH.can_equip(I))
				u_equip(I)
				EH.equip(I)
				hud.add_object(I, HUD_LAYER+2, EH.screenObj.screen_loc)
			else
				boutput(src, "<span style='color:red'>You cannot equip [I] in that slot!</span>")
			update_clothing()
		else if (W)
			if (!EH.remove())
				boutput(src, "<span style='color:red'>You cannot remove [W] from that slot!</span>")
			update_clothing()

	proc/handcheck()
		if (!hand_count)
			return 0
		if (!active_hand)
			return 0
		if (hands.len >= active_hand)
			return 1
		return 0

	attackby(var/obj/item/I, var/mob/M)
		if (isdead(src)) 	//Just copied from pets_small_animals.dm with only small modifications. yep!
			if (src.skinresult && max_skins)
				if (istype(I, /obj/item/circular_saw) || istype(I, /obj/item/kitchen/utensil/knife) || istype(I, /obj/item/scalpel) || istype(I, /obj/item/raw_material/shard) || istype(I, /obj/item/sword) || istype(I, /obj/item/saw) || istype(I, /obj/item/wirecutters))
					for (var/i, i<rand(1, max_skins), i++)
						var/obj/item/S = unpool(src.skinresult)
						S.set_loc(src.loc)
					src.skinresult = null
					M.visible_message("<span style='color:red'>[M] skins [src].</span>","You skin [src].")
					return
			if (src.butcherable && (istype(I, /obj/item/circular_saw) || istype(I, /obj/item/kitchen/utensil/knife) || istype(I, /obj/item/scalpel) || istype(I, /obj/item/raw_material/shard) || istype(I, /obj/item/sword) || istype(I, /obj/item/saw) || istype(I, /obj/item/wirecutters)))
				actions.start(new/datum/action/bar/icon/butcher_living_critter(src), M)
				return

		var/rv = 1
		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			rv = min(HH.on_attack(I, M), rv)
		if (!rv)
			return
		else
			..()

	proc/butcher(var/mob/M)
		var/i = rand(2,4)
		var/transfer = src.reagents.total_volume / i

		while (i-- > 0)
			var/obj/item/reagent_containers/food/newmeat = new meat_type
			newmeat.set_loc(src.loc)
			src.reagents.trans_to(newmeat, transfer)
			if (name_the_meat)
				newmeat.name = "[src.name] meat"
				newmeat.real_name = newmeat.name

		if (src.organHolder)
			src.organHolder.drop_organ("brain",src.loc)

		src.ghostize()
		qdel (src)
		return

	// The throw code is a direct copy-paste from humans
	// pending better solution.
	proc/toggle_throw_mode()
		if (src.in_throw_mode)
			throw_mode_off()
		else
			throw_mode_on()

	proc/throw_mode_off()
		src.in_throw_mode = 0
		src.update_cursor()
		hud.update_throwing()

	proc/throw_mode_on()
		if (!can_throw)
			return
		src.in_throw_mode = 1
		src.update_cursor()
		hud.update_throwing()

	proc/throw_item(atom/target, list/params)
		if (!can_throw)
			return
		src.throw_mode_off()
		if (usr.stat)
			return

		var/atom/movable/item = src.equipped()

		if (isitem(item) && item:cant_self_remove)
			return

		if (!item) return

		u_equip(item)

		if (istype(item, /obj/item/grab))
			var/obj/item/grab/grab = item
			var/mob/M = grab.affecting
			if (grab.state < 1 && !(M.getStatusDuration("paralysis") || M.getStatusDuration("weakened") || M.stat))
				src.visible_message("<span style='color:red'>[M] stumbles a little!</span>")
				qdel(grab)
				return
			M.lastattacker = src
			M.lastattackertime = world.time
			item = M
			qdel(grab)

		item.set_loc(src.loc)

		if (isitem(item))
			item:dropped(src) // let it know it's been dropped

		//actually throw it!
		if (item)
			item.layer = initial(item.layer)
			if(prob(yeet_chance))
				src.visible_message("<span style=\"color:red\">[src] yeets [item].</span>")
			else
				src.visible_message("<span style=\"color:red\">[src] throws [item].</span>")
			if (iscarbon(item))
				var/mob/living/carbon/C = item
				logTheThing("combat", src, C, "throws %target% at [log_loc(src)].")
				if ( ishuman(C) )
					C.changeStatus("weakened", 1 SECOND)
			else
				// Added log_reagents() call for drinking glasses. Also the location (Convair880).
				logTheThing("combat", src, null, "throws [item] [item.is_open_container() ? "[log_reagents(item)]" : ""] at [log_loc(src)].")
			if (istype(src.loc, /turf/space)) //they're in space, move em one space in the opposite direction
				src.inertia_dir = get_dir(target, src)
				step(src, inertia_dir)
			if (istype(item.loc, /turf/space) && ismob(item))
				var/mob/M = item
				M.inertia_dir = get_dir(src,target)
			item.throw_at(target, item.throw_range, item.throw_speed, params)

			playsound(src.loc, 'sound/effects/throw.ogg', 50, 1, 0.1)

	click(atom/target, list/params)
		if (((src.client && src.client.check_key(KEY_THROW)) || src.in_throw_mode) && src.can_throw)
			src.throw_item(target,params)
			return
		return ..()

	update_cursor()
		if (((src.client && src.client.check_key(KEY_THROW)) || src.in_throw_mode) && src.can_throw)
			src.set_cursor('icons/cursors/throw.dmi')
			return
		return ..()

	movement_delay()
		if (src.m_intent == "walk")
			return src.base_walk_delay + movement_delay_modifier
		else
			return src.base_move_delay + movement_delay_modifier

	Move(var/turf/NewLoc, direct)
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
		..()

	update_clothing()
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

	find_in_equipment(var/eqtype)
		for (var/datum/equipmentHolder/EH in equipment)
			if (EH.item && istype(EH.item, eqtype))
				return EH.item
		return null

	find_type_in_hand(var/eqtype)
		for (var/datum/handHolder/HH in hands)
			if (HH.item && istype(HH.item, eqtype))
				return HH.item
		return null

	is_in_hands(var/obj/O)
		for (var/datum/handHolder/HH in hands)
			if (HH.item && HH.item == O)
				return 1
		return 0

	find_in_hand(var/obj/item/I, var/this_hand)
		return is_in_hands(I) // vOv

	find_tool_in_hand(var/tool_flag, var/hand)
		for (var/datum/handHolder/HH in hands)
			var/obj/item/I = HH.item
			if (istype(I) && (I.tool_flags & tool_flag))
				return I
		return 0

	// helper proc for mobcritter AI
	proc/set_hand(var/new_hand)
		if (!handcheck())
			return 0
		if (new_hand == active_hand)
			return 1
		if (new_hand > 0 && new_hand <= hands.len)
			active_hand = new_hand
			hand = active_hand
			hud.update_hands()
			return 1
		return 0

	swap_hand()
		if (!handcheck())
			return
		if (active_hand < hands.len)
			active_hand++
			hand = active_hand
		else
			active_hand = 1
			hand = active_hand
		hud.update_hands()

	hand_range_attack(atom/target, params)
		.= 0
		var/datum/handHolder/ch = get_active_hand()
		if (ch && (ch.can_range_attack || ch.can_special_attack()) && ch.limb)
			ch.limb.attack_range(target, src, params)
			ch.set_cooldown_overlay()
			.= 1
			src.lastattacked = src

	hand_attack(atom/target, params)
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
		if (!HH.can_attack && (HH.can_range_attack || HH.can_special_attack()))
			hand_range_attack(target, params)
		else if (HH.can_attack)
			if (ismob(target))
				if (a_intent != INTENT_HELP)
					if (mob_flags & AT_GUNPOINT)
						for(var/obj/item/grab/gunpoint/G in grabbed_by)
							G.shoot()
				switch (a_intent)
					if (INTENT_HELP)
						if (can_help)
							L.help(target, src)
					if (INTENT_DISARM)
						if (can_disarm)
							L.disarm(target, src)
					if (INTENT_HARM)
						if (HH.can_attack)
							L.harm(target, src)
					if (INTENT_GRAB)
						if (HH.can_hold_items && can_grab)
							L.grab(target, src)
			else
				L.attack_hand(target, src)
				HH.set_cooldown_overlay()
		else
			boutput(src, "<span style='color:red'>You cannot attack with your [HH.name]!</span>")

	proc/melee_attack_human(var/mob/living/carbon/human/M, var/extra_damage) // non-special limb attack
		if (check_target_immunity(src, 0, M))
			visible_message("<b><span style='color:red'>[src]'s attack bounces uselessly off [M]!</span></b>")
			playsound_local(M, "punch", 50, 0)
			return
		src.visible_message("<b><span style='color:red'>[src] punches [M]!</span></b>")
		playsound_local(M, "punch", 50, 0)
		M.TakeDamageAccountArmor(zone_sel.selecting, rand(3,6), 0, 0, DAMAGE_BLUNT)

	can_strip(mob/M, showInv = 0)
		var/datum/handHolder/HH = get_active_hand()
		if(!showInv && check_target_immunity(src, 0, M))
			return 0
		if (!HH)
			return 0
		if (HH.can_hold_items)
			return 1
		else
			boutput(src, "<span style='color:red'>You cannot strip other people with your [HH.name].</span>")

	attack_hand(var/mob/living/M)
		M.lastattacked = src
		attack_particle(M,src)
		switch (M.a_intent)
			if (INTENT_HELP)
				src.on_pet(M)
			if (INTENT_DISARM)
				actions.interrupt(src, INTERRUPT_ATTACKED)
				if (src.hands.len)
					M.disarm(src)
			if (INTENT_HARM)
				if(check_target_immunity(src, 0, M))
					visible_message("<b><span style='color:red'>[M]'s attack bounces off [src] uselessly!</span></b>")
					return
				actions.interrupt(src, INTERRUPT_ATTACKED)
				src.TakeDamageAccountArmor(M.zone_sel.selecting, rand(1,3), 0)
				playsound(src.loc, "punch", 50, 1)
				visible_message("<b><span style='color:red'>[M] punches [src]!</span></b>")
			if (INTENT_GRAB)
				if (M == src)
					M.grab_self()
					return
				var/datum/limb/L = M.equipped_limb()
				if (!L)
					return
				L.grab(src, M)
				message_admin_on_attack(M, "grabs")

	proc/on_pet(mob/user)
		if (!user)
			return 1 // so things can do if (..())
		var/pmsg = islist(src.pet_text) ? pick(src.pet_text) : src.pet_text
		src.visible_message("<span style='color:blue'><b>[user] [pmsg] [src]!</b></span>",\
		"<span style='color:blue'><b>[user] [pmsg] you!</b></span>")
		return

	proc/get_active_hand()
		RETURN_TYPE(/datum/handHolder)
		if (!handcheck())
			return null
		return hands[active_hand]

	proc/setup_hands()
		if (hand_count)
			for (var/i = 1, i <= hand_count, i++)
				var/datum/handHolder/HH = new
				HH.holder = src
				hands += HH
			active_hand = 1
			hand = active_hand

	proc/post_setup_hands()
		if (hand_count)
			for (var/datum/handHolder/HH in hands)
				if (!HH.limb)
					HH.limb = new /datum/limb
				HH.spawn_dummy_holder()

	proc/setup_equipment_slots()

	proc/setup_reagents()
		reagent_capacity = max(0, reagent_capacity)
		var/datum/reagents/R = new(reagent_capacity)
		R.my_atom = src
		reagents = R

	equipped()
		if (active_hand)
			if (hands.len >= active_hand)
				var/datum/handHolder/HH = hands[active_hand]
				return HH.item
		return null

	u_equip(var/obj/item/I)
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
				EH.item = null
				hud.remove_object(I)
				clothing = 1
		if (clothing)
			update_clothing()

	put_in_hand(obj/item/I, t_hand)
		if (!hands.len)
			return 0
		if (t_hand)
			if (t_hand > hands.len)
				return 0
			var/datum/handHolder/HH = hands[t_hand]
			if (HH.item || !HH.can_hold_items)
				return 0
			HH.item = I
			hud.add_object(I, HUD_LAYER+2, HH.screenObj.screen_loc)
			update_inhands()
			I.pickup(src) // attempted fix for flashlights not working - cirr
			return 1
		else if (active_hand)
			var/datum/handHolder/HH = hands[active_hand]
			if (HH.item || !HH.can_hold_items)
				return 0
			HH.item = I
			hud.add_object(I, HUD_LAYER+2, HH.screenObj.screen_loc)
			update_inhands()
			I.pickup(src) // attempted fix for flashlights not working - cirr
			return 1
		return 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (getStatusDuration("burning"))
			if (isturf(src.loc))
				var/turf/location = src.loc
				location.hotspot_expose(T0C + 400, 400)
			var/damage = 1
			if (getStatusDuration("burning") > 400)
				damage = 3
			else if (getStatusDuration("burning") > 200)
				damage = 2
			TakeDamage("All", 0, damage)
			update_burning(-2)

		if (isdead(src))
			return 0

		src.handle_digestion()

		if (src.get_eye_blurry())
			src.change_eye_blurry(-1)

		if (src.drowsyness)
			src.drowsyness = max(0, src.drowsyness - 1)
			if (src.drowsyness >= tranquilizer_resistance)
				src.change_eye_blurry(2)
				if (prob(5 + src.drowsyness - tranquilizer_resistance))
					src.sleeping = 2
					src.setStatus("paralysis", 70)

		handle_hud_overlays()
		src.antagonist_overlay_refresh(0, 0)

		if (getStatusDuration("paralysis") || getStatusDuration("stunned") || getStatusDuration("weakened") || getStatusDuration("dormant"))
			canmove = 0
		else
			canmove = 1

		update_stunned_icon(canmove)

		if (sleeping)
			sleeping = max(0, sleeping - 1)
			setStatus("paralysis", 2 SECONDS)
			if (!sleeping)
				src.on_wake()

		var/may_deliver_recovery_warning = (getStatusDuration("paralysis") || getStatusDuration("stunned") || getStatusDuration("weakened"))

		if (may_deliver_recovery_warning)
			empty_hands()
			actions.interrupt(src, INTERRUPT_STUNNED)

		if (getStatusDuration("paralysis"))
			if (isalive(src))
				setunconscious(src)
		else if (isunconscious(src))
			setalive(src)

		if (stuttering)
			stuttering = max(0, stuttering-2)

		if (misstep_chance > 0)
			change_misstep_chance(-1)

		if (reagents && metabolizes)
			reagents.metabolize(src)

		for (var/T in healthlist)
			var/datum/healthHolder/HH = healthlist[T]
			HH.Life()

		for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
			G.process()

		if (stat)
			return 0

//		if (!client && istype(current_task))

	proc/handle_hud_overlays()
		var/color_mod_r = 255
		var/color_mod_g = 255
		var/color_mod_b = 255
		if (src.druggy)
			vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
		else
			vision.set_color_mod(rgb(color_mod_r, color_mod_g, color_mod_b))

		if (isunconscious(src) || (!src.sight_check(1) && !isdead(src)))
			src.addOverlayComposition(/datum/overlayComposition/blinded) //ov1
		else
			src.removeOverlayComposition(/datum/overlayComposition/blinded) //ov1
		vision.animate_dither_alpha(src.get_eye_blurry() / 10 * 255, 15)
		return 1

	death(var/gibbed)
		if (src.organHolder)
			// believe me i hate this as much as you do
			// There is some sort of behavior on living critters that ejects all of their contents at the moment of death. We want to avoid that - brain should stay inside. HOWEVER I can't find where the ejection happens for the life of me!
			// So now we do this dumb re-insertion of the brain (until the issue can be addressed properly)
			var/obj/item/organ/O = src.organHolder.get_organ("brain")
			if (O)
				O.set_loc(src)
		if(src.mind)
			src.mind.register_death() // it'd be nice if critters get a time of death too tbh
		set_density(0)
		if (src.can_implant)
			for (var/obj/item/implant/H in src.implants)
				H.on_death()
			src.can_implant = 0
		if (!gibbed)
			if (src.death_text)
				src.tokenized_message(src.death_text, null, "red")
			else
				src.visible_message("<span style='color:red'><b>[src]</b> dies!</span>")
			setdead(src)
			icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead"
		empty_hands()
		drop_equipment()
		hud.update_health()

	proc/get_health_holder(var/assoc)
		if (assoc in healthlist)
			return healthlist[assoc]
		return null

	TakeDamage(zone, brute, burn)
		hit_twitch(src)
		if (nodamage)
			return
		var/datum/healthHolder/Br = get_health_holder("brute")
		if (Br)
			Br.TakeDamage(brute)
		var/datum/healthHolder/Bu = get_health_holder("burn")
		if (Bu && (burn < 0 || !is_heat_resistant()))
			Bu.TakeDamage(burn)
		updatehealth()

	take_brain_damage(var/amount)
		if (..())
			return 1
		if (nodamage)
			return
		var/datum/healthHolder/Br = get_health_holder("brain")
		if (Br)
			Br.TakeDamage(amount)
		return 0

	take_toxin_damage(var/amount)
		if (..())
			return 1
		if (nodamage)
			return
		var/datum/healthHolder/Tx = get_health_holder("toxin")
		if (Tx)
			Tx.TakeDamage(amount)
		return 0

	take_oxygen_deprivation(var/amount)
		if (..())
			return 1
		if (nodamage)
			return
		var/datum/healthHolder/Ox = get_health_holder("oxy")
		if (Ox)
			Ox.TakeDamage(amount)
		return 0

	get_brute_damage()
		var/datum/healthHolder/Br = get_health_holder("brute")
		if (Br)
			return Br.maximum_value - Br.value
		else
			return 0

	get_burn_damage()
		var/datum/healthHolder/Bu = get_health_holder("burn")
		if (Bu)
			return Bu.maximum_value - Bu.value
		else
			return 0

	get_brain_damage()
		var/datum/healthHolder/Br = get_health_holder("brain")
		if (Br)
			return Br.maximum_value - Br.value
		else
			return 0

	get_toxin_damage()
		var/datum/healthHolder/Tx = get_health_holder("toxin")
		if (Tx)
			return Tx.maximum_value - Tx.value
		else
			return 0

	get_oxygen_deprivation()
		var/datum/healthHolder/Ox = get_health_holder("oxy")
		if (Ox)
			return Ox.maximum_value - Ox.value
		else
			return 0

	lose_breath(var/amount)
		if (..())
			return 1
		var/datum/healthHolder/suffocation/Ox = get_health_holder("oxy")
		if (!istype(Ox))
			return 0
		Ox.lose_breath(amount)
		return 0

	HealDamage(zone, brute, burn, tox)
		..()
		TakeDamage(zone, -brute, -burn)
		updatehealth()

	updatehealth()
		if (src.nodamage)
			if (health != max_health)
				full_heal()
			src.health = max_health
			setalive(src)
			icon_state = icon_state_alive ? icon_state_alive : initial(icon_state)
		else
			health = max_health
			for (var/T in healthlist)
				var/datum/healthHolder/HH = healthlist[T]
				if (HH.count_in_total)
					health -= (HH.maximum_value - HH.value)
		hud.update_health()
		if (health <= 0 && stat < 2)
			death()

	proc/specific_emotes(var/act, var/param = null, var/voluntary = 0)
		return null

	proc/specific_emote_type(var/act)
		return 1

	update_inhands()
		var/handcount = 0
		for (var/datum/handHolder/HH in hands)
			handcount++
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
	proc/empty_hand(var/hand_to_empty)
		if(hand_to_empty > 0 && hand_to_empty <= hands.len)
			var/datum/handHolder/HH = hands[hand_to_empty]
			if (HH.item)
				if (istype(HH.item, /obj/item/grab))
					qdel(HH.item)
					return
				var/obj/item/I = HH.item
				I.loc = src.loc
				I.master = null
				I.layer = initial(I.layer)
				u_equip(I)

	proc/empty_hands()
		for (var/datum/handHolder/HH in hands)
			if (HH.item)
				if (istype(HH.item, /obj/item/grab))
					qdel(HH.item)
					continue
				var/obj/item/I = HH.item
				I.loc = src.loc
				I.master = null
				I.layer = initial(I.layer)
				u_equip(I)

	proc/drop_equipment()
		for (var/datum/equipmentHolder/EH in equipment)
			if (EH.item)
				EH.drop(1)

	emote(var/act, var/voluntary = 0)
		var/param = null

		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/message = specific_emotes(act, param, voluntary)
		var/m_type = specific_emote_type(act)
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
									if ("glare","stare","look","leer")
										message = "<B>[src]</B> [act]s at [param]."
									else
										message = "<B>[src]</B> [act]s [param]."
							else
								switch(act)
									if ("hug")
										message = "<B>[src]</b> [act]s itself."
									else
										message = "<B>[src]</b> [act]s."
						else
							message = "<B>[src]</B> struggles to move."
						m_type = 1
				if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
					// basic visible single-word emotes
					if (src.emote_check(voluntary, 10))
						message = "<B>[src]</B> [act]s."
						m_type = 1
				if ("gasp","cough","laugh","giggle","sigh")
					// basic hearable single-word emotes
					if (src.emote_check(voluntary, 10))
						message = "<B>[src]</B> [act]s."
						m_type = 2
				if ("customv")
					if (!param)
						param = input("Choose an emote to display.")
						if(!param) return
					param = html_encode(sanitize(param))
					message = "<b>[src]</b> [param]"
					m_type = 1
				if ("customh")
					if (!param)
						param = input("Choose an emote to display.")
						if(!param) return
					param = html_encode(sanitize(param))
					message = "<b>[src]</b> [param]"
					m_type = 2
				if ("me")
					if (!param)
						return
					param = html_encode(sanitize(param))
					message = "<b>[src]</b> [param]"
					m_type = 1
				if ("flip")
					if (src.emote_check(voluntary, 50) && !src.shrunk)
						if (istype(src.loc,/obj/))
							var/obj/container = src.loc
							boutput(src, "<span style='color:red'>You leap and slam your head against the inside of [container]! Ouch!</span>")
							src.changeStatus("paralysis", 30)
							src.changeStatus("weakened", 4 SECONDS)
							container.visible_message("<span style='color:red'><b>[container]</b> emits a loud thump and rattles a bit.</span>")
							playsound(src.loc, "sound/impact_sounds/Metal_Hit_Heavy_1.ogg", 50, 1)
							var/wiggle = 6
							while(wiggle > 0)
								wiggle--
								container.pixel_x = rand(-3,3)
								container.pixel_y = rand(-3,3)
								sleep(1)
							container.pixel_x = 0
							container.pixel_y = 0
							if (prob(33))
								if (istype(container, /obj/storage))
									var/obj/storage/C = container
									if (C.can_flip_bust == 1)
										boutput(src, "<span style='color:red'>[C] [pick("cracks","bends","shakes","groans")].</span>")
										C.bust_out()
						else
							message = "<b>[src]</B> does a flip!"
							animate_spin(src, pick("L", "R"), 1, 0)
		if (message)
			logTheThing("say", src, null, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message("<span style='color:#605b59'>[message]</span>", m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message("<span style='color:#605b59'>[message]</span>", m_type)
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message("<span style='color:#605b59'>[message]</span>", m_type)


	talk_into_equipment(var/mode, var/message, var/param)
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

	update_burning()
		if (can_burn)
			..()

	update_burning_icon(var/force_remove)
		var/datum/statusEffect/simpledot/burning/B = hasStatus("burning")

		if (!B || force_remove)
			UpdateOverlays(null, "burning")
			return
		else if (B.stage == 1)
			burning_image.icon_state = "fire1_[burning_suffix]"
		else if (B.stage == 2)
			burning_image.icon_state = "fire2_[burning_suffix]"
		else if (B.stage == 3)
			burning_image.icon_state = "fire3_[burning_suffix]"
		UpdateOverlays(burning_image, "burning")

	proc/update_stunned_icon(var/canmove)
		if(canmove != src.old_canmove)
			src.old_canmove = canmove
			if (canmove)
				src.UpdateOverlays(null, "dizzy")
				return
			else
				var/image/dizzyStars = src.SafeGetOverlayImage("dizzy", src.icon, "dizzy", MOB_OVERLAY_BASE+20) // why such a big boost? because the critter could have a bunch of overlays, that's why
				if (dizzyStars)
					src.UpdateOverlays(dizzyStars, "dizzy")

	proc/get_head_armor_modifier()
		var/armor_mod = 0
		for (var/datum/equipmentHolder/EH in equipment)
			if ((EH.armor_coverage & HEAD) && istype(EH.item, /obj/item/clothing))
				var/obj/item/clothing/C = EH.item
				armor_mod = max(C.getProperty("meleeprot"), armor_mod)
		return armor_mod

	proc/get_chest_armor_modifier()
		var/armor_mod = 0
		for (var/datum/equipmentHolder/EH in equipment)
			if ((EH.armor_coverage & TORSO) && istype(EH.item, /obj/item/clothing))
				var/obj/item/clothing/C = EH.item
				armor_mod = max(C.getProperty("meleeprot"), armor_mod)
		return armor_mod

	get_melee_protection(zone)//critters and stuff, I suppose
		if(zone=="head")
			return get_head_armor_modifier()
		else
			return get_chest_armor_modifier()

	full_heal()
		..()
		icon_state = icon_state_alive ? icon_state_alive : initial(icon_state)
		density = initial(density)
		src.can_implant = initial(src.can_implant)

	does_it_metabolize()
		return metabolizes

	is_heat_resistant()
		if (!get_health_holder("burn"))
			return 1
		return 0

	get_explosion_resistance()
		var/ret = explosion_resistance
		for (var/datum/equipmentHolder/EH in equipment)
			if (EH.armor_coverage & TORSO)
				var/obj/item/clothing/suit/S = EH.item
				if (istype(S))
					ret += S.getProperty("exploprot")
		return ret

	ex_act(var/severity)
		..() // Logs.
		var/ex_res = get_explosion_resistance()
		if (ex_res >= 15 && prob(ex_res * 3.5))
			severity++
		if (ex_res >= 30 && prob(ex_res * 1.5))
			severity++
		switch(severity)
			if (1)
				gib()
			if (2)
				if (health < max_health * 0.35 && prob(50))
					gib()
				else
					TakeDamage("All", rand(10, 30), rand(10, 30))
			if (3)
				TakeDamage("All", rand(20, 20))

	ghostize()
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

		if (src.bioHolder) //Not necessary for ghost appearance, but this will be useful if the ghost decides to respawn as critter
			var/datum/bioHolder/newbio = new/datum/bioHolder(O)
			newbio.CopyOther(src.bioHolder)
			O.bioHolder = newbio

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

	drop_item()
		..()
		src.update_inhands()

	proc/on_wake()
		return

/mob/living/critter/hotkey(name)
	switch (name)
		if ("help")
			src.a_intent = INTENT_HELP
			hud.update_intent()
		if ("disarm")
			src.a_intent = INTENT_DISARM
			hud.update_intent()
		if ("grab")
			src.a_intent = INTENT_GRAB
			hud.update_intent()
		if ("harm")
			src.a_intent = INTENT_HARM
			hud.update_intent()
		if ("drop")
			src.drop_item()
		if ("swaphand")
			src.swap_hand()
		if ("attackself")
			var/obj/item/W = src.equipped()
			if (W)
				src.click(W, list())
		if ("togglethrow")
			src.toggle_throw_mode()
		else
			return ..()

/mob/living/critter/build_keymap(client/C)
	var/datum/keymap/keymap = ..()
	keymap.merge(client.get_keymap("human"))
	return keymap

/mob/living/critter/proc/tokenized_message(var/message, var/target, var/mcolor)
	if (!message || !length(message))
		return
	var/msg = replacetext(message, "%src%", "<b>[src]</b>")
	if (target)
		msg = replacetext(msg, "%target%", "[target]")
	if (mcolor)
		msg = "<span style='color:[mcolor]'>" + msg + "</span>"
	src.visible_message(msg)

/mob/living/critter/say(var/message)
	message = copytext(message, 1, MAX_MESSAGE_LEN)

	if (dd_hasprefix(message, "*") || isdead(src))
		..(message)
		return

	if (src.robot_talk_understand && !src.stat)
		if (length(message) >= 2)
			if (copytext(lowertext(message), 1, 3) == ":s")
				message = copytext(message, 3)
				src.robot_talk(message)
				return
	..()

/mob/living/critter/blob_act(var/power)
	logTheThing("combat", src, null, "is hit by a blob")

	if (isdead(src) || src.nodamage)
		return

	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	if (src.spellshield)
		shielded = 1

	var/modifier = power / 20
	var/damage = rand(modifier, 12 + 8 * modifier)

	if (shielded)
		damage /= 4
		//src.paralysis += 1

	src.show_message("<span style=\"color:red\">The blob attacks you!</span>")

	if (src.spellshield)
		boutput(src, "<span style=\"color:red\"><b>Your Spell Shield absorbs some damage!</b></span>")

	if (damage > 4.9)
		if (prob(50))
			changeStatus("weakened", 5 SECONDS)
			for (var/mob/O in viewers(src, null))
				O.show_message("<span style=\"color:red\"><B>The blob has knocked down [src]!</B></span>", 1, "<span style=\"color:red\">You hear someone fall.</span>", 2)
		else
			src.changeStatus("stunned", 50)
			for (var/mob/O in viewers(src, null))
				if (O.client)	O.show_message("<span style=\"color:red\"><B>The blob has stunned [src]!</B></span>", 1)
		if (isalive(src))
			src.lastgasp() // calling lastgasp() here because we just got knocked out

	src.TakeDamage("All", damage, 0)
	return
