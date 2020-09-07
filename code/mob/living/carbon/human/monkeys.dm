
/mob/living/carbon/human/monkey //Please ignore how silly this path is.
	name = "monkey"
	static_type_override = /datum/mutantrace/monkey

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				cust_one_state = "None"
				src.bioHolder.AddEffect("monkey")
				src.get_static_image()
				if (src.name == "monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name

// special monkeys.
/mob/living/carbon/human/npc/monkey/mr_muggles
	name = "Mr. Muggles"
	real_name = "Mr. Muggles"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/blue, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/mrs_muggles
	name = "Mrs. Muggles"
	real_name = "Mrs. Muggles"
	gender = "female"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/magenta, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/mr_rathen
	name = "Mr. Rathen"
	real_name = "Mr. Rathen"
	gender = "male"
#if ASS_JAM
	unkillable = 1
#endif
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/engineer, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/albert
	name = "Albert"
	real_name = "Albert"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, slot_head)

/mob/living/carbon/human/npc/monkey/von_braun
	name = "Von Braun"
	real_name = "Von Braun"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space/syndicate, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, slot_head)

/mob/living/carbon/human/npc/monkey/horse
	name = "????"
	real_name = "????"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/mask/horse_mask/cursed/monkey, slot_wear_mask)

/mob/living/carbon/human/npc/monkey/tanhony
	name = "Tanhony"
	real_name = "Tanhony"
	gender = "female"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/paper_hat, slot_head)

/mob/living/carbon/human/npc/monkey/krimpus
	name = "Krimpus"
	real_name = "Krimpus"
	gender = "female"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/hydroponics, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/stirstir
	name = "Monsieur Stirstir"
	real_name = "Monsieur Stirstir"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/orange, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/head/beret/prisoner, slot_head)

/mob/living/carbon/human/npc/monkey // :getin:
	name = "monkey"
	static_type_override = /datum/mutantrace/monkey
	ai_aggressive = 0
	ai_calm_down = 1
	ai_default_intent = INTENT_HELP
	var/list/shitlist = list()
	var/ai_aggression_timeout = 600

	New()
		..()
		START_TRACKING
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				src.bioHolder.mobAppearance.customization_first = "None"
				src.cust_one_state = "None"
				src.bioHolder.AddEffect("monkey")
				if (src.name == "monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name

	disposing()
		STOP_TRACKING
		..()

	ai_action()
		if(ai_aggressive)
			return ..()

		if (src.ai_state == 2 && src.done_with_you(src.ai_target))
			return
		..()
		if (src.ai_state == 0)
			if (prob(10))
				src.ai_pickpocket()
			else if (prob(10))
				src.ai_knock_from_hand()

	ai_findtarget_new()
		if (ai_aggressive || ai_aggression_timeout == 0 || (world.timeofday - ai_threatened) < ai_aggression_timeout)
			..()

	was_harmed(var/atom/T as mob|obj, var/obj/item/weapon = 0, var/special = 0)
		//src.ai_aggressive = 1
		src.target = T
		src.ai_state = 2
		src.ai_threatened = world.timeofday
		src.ai_target = T
		src.shitlist[T] ++
		if (prob(40))
			src.emote("scream")
		var/pals = 0
		for (var/mob/living/carbon/human/npc/monkey/pal in by_type[/mob/living/carbon/human/npc/monkey])
			if (get_dist(src, pal) > 7)
				continue
			if (pals >= 5)
				return
			if (prob(10))
				continue
			//pal.ai_aggressive = 1
			pal.target = T
			pal.ai_state = 2
			pal.ai_threatened = world.timeofday
			pal.ai_target = T
			pal.shitlist[T] ++
			pals ++
			if (prob(40))
				src.emote("scream")

	proc/shot_by(var/atom/A as mob|obj)
		if (src.ai_state == 2)
			return
		if (ishuman(A))
			src.was_harmed(A)
		else
			walk_away(src, A, 10, 1)
			SPAWN_DBG(1 SECOND)
				walk(src, 0)

	proc/done_with_you(var/atom/T as mob|obj)
		if (!T)
			return 0
		if (src.health <= 0 || (get_dist(src, T) >= 7))
			src.target = null
			src.ai_state = 0
			src.ai_target = null
			src.ai_frustration = 0
			walk_towards(src,null)
			return 1
		if (src.shitlist[T] && src.shitlist[T] > 10)
			return 0
		if (ismob(T))
			var/mob/M = T
			if (M.health <= 0)
				src.target = null
				src.ai_state = 0
				src.ai_target = null
				src.ai_frustration = 0
				walk_towards(src,null)
				return 1
		else
			return 0

	proc/ai_pickpocket()
		if (src.getStatusDuration("weakened") || src.getStatusDuration("stunned") || src.getStatusDuration("paralysis") || src.stat || src.ai_picking_pocket)
			return
		var/list/possible_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				continue
			if (!H.l_store && !H.r_store)
				continue
			possible_targets += H
		if (!possible_targets.len)
			return
		var/mob/living/carbon/human/theft_target = pick(possible_targets)
		var/obj/item/thingy
		var/slot = 15
		if (theft_target.l_store && theft_target.r_store)
			thingy = pick(theft_target.l_store, theft_target.r_store)
			if (thingy == theft_target.r_store)
				slot = 16
		else if (theft_target.l_store)
			thingy = theft_target.l_store
		else if (theft_target.r_store)
			thingy = theft_target.r_store
			slot = 16
		else // ???
			return
		walk_towards(src, null)
		src.say("[pick("Gimme", "Want", "Need")] [thingy.name].") // Monkeys don't know grammar!
		actions.start(new/datum/action/bar/icon/filthyPickpocket(src, theft_target, slot), src)

	proc/ai_knock_from_hand()
		if (src.getStatusDuration("weakened") || src.getStatusDuration("stunned") || src.getStatusDuration("paralysis") || src.stat || src.ai_picking_pocket || src.r_hand)
			return
		var/list/possible_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				continue
			if (!H.l_hand && !H.r_hand)
				continue
			possible_targets += H
		if (!possible_targets.len)
			return
		var/mob/living/carbon/human/theft_target = pick(possible_targets)
		walk_towards(src, null)
		src.a_intent = INTENT_DISARM
		theft_target.attack_hand(src)
		src.a_intent = src.ai_default_intent

/datum/action/bar/icon/filthyPickpocket
	id = "pickpocket"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/carbon/human/npc/source  //The npc doing the action
	var/mob/living/carbon/human/target  	//The target of the action
	var/slot						    	//The slot number

	New(var/Source, var/Target, var/Slot)
		source = Source
		target = Target
		slot = Slot

		var/obj/item/I = target.get_slot(slot)
		if(I)
			if(I.duration_remove > 0)
				duration = I.duration_remove
			else
				duration = 25
		..()

	onStart()
		..()

		target.add_fingerprint(source) // Added for forensics (Convair880).
		var/obj/item/I = target.get_slot(slot)

		if(!I)
			source.show_text("There's nothing in that slot.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!I.handle_other_remove(source, target))
			source.show_text("[I] can not be removed.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing("combat", source, target, "tries to pickpocket \an [I] from [constructTarget(target,"combat")]")

		for(var/mob/O in AIviewers(owner))
			O.show_message("<B>[source]</B> rifles through [target]'s pockets!", 1)

		source.ai_picking_pocket = 1

	onEnd()
		..()

		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/obj/item/I = target.get_slot(slot)

		if(I.handle_other_remove(source, target))
			logTheThing("combat", source, target, "successfully pickpockets \an [I] from [constructTarget(target,"combat")]!")
			for(var/mob/O in AIviewers(owner))
				O.show_message("<B>[source]</B> grabs [I] from [target]'s pockets!", 1)
			target.u_equip(I)
			I.dropped(target)
			I.layer = initial(I.layer)
			I.add_fingerprint(source)
			source.put_in_hand_or_drop(I)
		else
			source.show_text("You fail to remove [I] from [target].", "red")

		source.ai_picking_pocket = 0

	onUpdate()
		..()
		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.get_slot(slot=slot))
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		source.ai_picking_pocket = 0

/mob/living/carbon/human/npc/monkey/angry
	ai_aggressive = 1
	ai_calm_down = 0
	ai_default_intent = INTENT_HARM
	ai_aggression_timeout = null
	max_health = 150

	New()
		..()
		SPAWN_DBG(1 SECOND)
			var/head = pick(/obj/item/clothing/head/bandana/red, /obj/item/clothing/head/bandana/random_color)
			src.equip_new_if_possible(head, slot_head)

// sea monkeys
/mob/living/carbon/human/npc/monkey/sea
	name = "sea monkey"
	max_health = 150
	static_type_override = /datum/mutantrace/monkey/seamonkey

	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				cust_one_state = "None"
				src.bioHolder.AddEffect("seamonkey")
				src.get_static_image()
				if (src.name == "sea monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name


/mob/living/carbon/human/npc/monkey/sea/gang
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "male"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/under, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/sea/gang_gun
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/gun/kinetic/detectiverevolver, slot_l_hand)
			src.equip_new_if_possible(/obj/item/clothing/under, slot_w_uniform)

/mob/living/carbon/human/npc/monkey/sea/rich
	//name = "sea monkey"
	//real_name = "sea monkey"
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/crown, slot_head)

/mob/living/carbon/human/npc/monkey/sea/lab
	name = "Kimmy"
	real_name = "Kimmy"
	gender = "female"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/scientist, slot_w_uniform)

// non-AI monkeys
/mob/living/carbon/human/monkey/mr_wigglesby
	name = "Mr. Wigglesby"
	real_name = "Mr. Wigglesby"
	gender = "male"
	New()
		..()
		SPAWN_DBG(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/suit, src.slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, src.slot_shoes)
