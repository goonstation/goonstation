
#define IS_NPC_HATED_ITEM(x) ( \
		istype(x, /obj/item/handcuffs) || \
		istype(x, /obj/item/device/radio/electropack) || \
		istype(x, /obj/item/reagent_containers/balloon) || \
		x:block_vision \
	)

/mob/living/carbon/human/monkey //Please ignore how silly this path is.
	name = "monkey"
	real_name = "monkey"
#ifdef IN_MAP_EDITOR
	icon = 'icons/mob/map_mob.dmi'
	icon_state = "monkey"
#endif
	default_mutantrace = /datum/mutantrace/monkey

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (!src.disposed)
				if (src.name == "monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name

	initializeBioholder()
		randomize_look(src, 1, 1, 1, 0, 1, 0)
		. = ..()

// special monkeys.
/mob/living/carbon/human/npc/monkey/mr_muggles
	name = "Mr. Muggles"
	real_name = "Mr. Muggles"
#ifdef IN_MAP_EDITOR
	icon_state = "mr_muggles"
#endif
	gender = "male"
	ai_offhand_pickup_chance = 1 // very civilized
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/blue, SLOT_W_UNIFORM)

/mob/living/carbon/human/npc/monkey/mrs_muggles
	name = "Mrs. Muggles"
	real_name = "Mrs. Muggles"
#ifdef IN_MAP_EDITOR
	icon_state = "mrs_muggles"
#endif
	gender = "female"
	ai_offhand_pickup_chance = 1 // also very civilized
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/color/magenta, SLOT_W_UNIFORM)

/mob/living/carbon/human/npc/monkey/mr_rathen
	name = "Mr. Rathen"
	real_name = "Mr. Rathen"
#ifdef IN_MAP_EDITOR
	icon_state = "mr_rathen"
#endif
	gender = "male"
	ai_offhand_pickup_chance = 2 // learned that there's dangerous stuff in engineering!
	ai_poke_thing_chance = 0.3 // don't mess up the engine too much
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/engineer, SLOT_W_UNIFORM)

/mob/living/carbon/human/npc/monkey/albert
	name = "Albert"
	real_name = "Albert"
#ifdef IN_MAP_EDITOR
	icon_state = "albert"
#endif
	gender = "male"
	ai_offhand_pickup_chance = 10 // more curious than most monkeys
	ai_poke_thing_chance = 3
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space, SLOT_WEAR_SUIT)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, SLOT_HEAD)

/mob/living/carbon/human/npc/monkey/von_braun
	name = "Von Braun"
	real_name = "Von Braun"
	gender = "male"
#ifdef IN_MAP_EDITOR
	icon_state = "oppenheimer" // Close enough
#endif
	ai_offhand_pickup_chance = 40 // went through training as a spy thief, skilled at snatching stuff
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/suit/space/syndicate, SLOT_WEAR_SUIT)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, SLOT_HEAD)

/mob/living/carbon/human/npc/monkey/oppenheimer
	name = "Oppenheimer"
	real_name = "Oppenheimer"
#ifdef IN_MAP_EDITOR
	icon_state = "oppenheimer"
#endif
	gender = "male"
	ai_offhand_pickup_chance = 40 // went through training as a spy thief, skilled at snatch- wait, I'm getting a feeling of deja vu
	ai_poke_thing_chance = 2
	ai_aggressive = TRUE
	ai_calm_down = FALSE
	ai_default_intent = INTENT_HARM
	ai_aggression_timeout = 0
	var/preferred_card_type = /obj/item/card/id/syndicate

	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/syndicate, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/suit/space/syndicate, SLOT_WEAR_SUIT)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/space, SLOT_HEAD)

			var/obj/item/card/id/ID = new/obj/item/card/id(src)
			ID.name = "Oppenheimer's ID Card"
			ID.assignment = "Syndicate Monkey"
			ID.registered = "Oppenheimer"
			ID.icon = 'icons/obj/items/card.dmi'
			ID.icon_state = "id_syndie"
			ID.desc = "Oppenheimer's identification card."

			src.equip_if_possible(ID, SLOT_WEAR_ID)


	ai_is_valid_target(mob/M)
		if(!isliving(M) || !isalive(M))
			return FALSE
		return !istype(M.get_id(), preferred_card_type)

/mob/living/carbon/human/npc/monkey/oppenheimer/pod_wars
	preferred_card_type = /obj/item/card/id/pod_wars/syndicate

	New()
		START_TRACKING_CAT(TR_CAT_PW_PETS)
		..()
	disposing()
		STOP_TRACKING_CAT(TR_CAT_PW_PETS)
		..()

	ai_is_valid_target(mob/M)
		var/team_num = get_pod_wars_team_num(M)
		switch(team_num)
			if (TEAM_NANOTRASEN)	//1
				return TRUE
			if (TEAM_SYNDICATE)		//2
				return FALSE
			else
				return ..()

/mob/living/carbon/human/npc/monkey/horse
	name = "????"
	real_name = "????"
#ifdef IN_MAP_EDITOR
	icon_state = "horse"
#endif
	gender = "male"
	New()
		..()
		ai_offhand_pickup_chance = rand(100) // an absolute wildcard
		ai_poke_thing_chance = rand(50)
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/mask/horse_mask/cursed/monkey, SLOT_WEAR_MASK)

/mob/living/carbon/human/npc/monkey/tanhony
	name = "Tanhony"
	real_name = "Tanhony"
#ifdef IN_MAP_EDITOR
	icon = 'icons/mob/map_mob.dmi'
	icon_state = "tanhony"
#endif
	gender = "female"
	ai_offhand_pickup_chance = 5 // your base monkey
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/paper_hat, SLOT_HEAD)

/mob/living/carbon/human/npc/monkey/krimpus
	name = "Krimpus"
	real_name = "Krimpus"
#ifdef IN_MAP_EDITOR
	icon_state = "krimpus"
#endif
	gender = "female"
	ai_offhand_pickup_chance = 2.5 // some of the botany fruit is very dangerous, Krimpus learned not to eat
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/hydroponics, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/suit/apron/botanist, SLOT_WEAR_SUIT)

/mob/living/carbon/human/npc/monkey/stirstir
	name = "Monsieur Stirstir"
	real_name = "Monsieur Stirstir"
#ifdef IN_MAP_EDITOR
	icon_state = "stirstir"
#endif
	gender = "male"
	ai_offhand_pickup_chance = 4 // a filthy thief but he's trying to play nice for now
	ai_poke_thing_chance = 5 // maybe finds tools... breaks out of prison...
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/prisoner, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/head/beret/prisoner, SLOT_HEAD)
			if(prob(10))
				// he can have a little treat
				src.equip_new_if_possible(/obj/item/reagent_containers/food/snacks/candy/swirl_lollipop, SLOT_R_HAND)
			if(prob(80)) // couldnt figure out how to hide it in the debris field, so i just chucked it in a monkey
				var/obj/item/disk/data/cartridge/ringtone_numbers/idk = new
				idk.set_loc(src)
				src.chest_item = idk
				src.chest_item_sewn = 1

TYPEINFO(/mob/living/carbon/human/npc/monkey)
	start_listen_effects = list(LISTEN_EFFECT_MONKEY)

/mob/living/carbon/human/npc/monkey // :getin:
	name = "monkey"
	real_name = "monkey"
#ifdef IN_MAP_EDITOR
	icon = 'icons/mob/map_mob.dmi'
	icon_state = "monkey"
#endif
	ai_aggressive = 0
	ai_calm_down = 1
	ai_default_intent = INTENT_HELP
	var/list/shitlist = list()
	var/ai_aggression_timeout = 600
	var/ai_poke_thing_chance = 1
	var/ai_delay_move = FALSE //! Delays the AI from moving a single time if set
	default_mutantrace = /datum/mutantrace/monkey

	New()
		..()
		START_TRACKING
		if (!src.disposed)
			src.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
			if (src.name == "monkey" || !src.name)
				src.name = pick_string_autokey("names/monkey.txt")
			src.real_name = src.name

	disposing()
		STOP_TRACKING
		..()

	initializeBioholder()
		if (src.name == "monkey" || !src.name)
			randomize_look(src, 1, 1, 1, 0, 1, 0)
			src.gender = src.bioHolder?.mobAppearance.gender
		. = ..()

	ai_action()
		if(ai_aggressive)
			return ..()

		if (src.ai_state == AI_ATTACKING && src.done_with_you(src.ai_target))
			return
		..()
		if (src.ai_state == 0)
			if (istype(src.equipped(),/obj/item/implant/projectile/body_visible/dart/bardart))
				for (var/obj/item/reagent_containers/balloon/balloon in view(7, src))
					src.throw_item(balloon, list("npc_throw"))
					src.ai_delay_move = TRUE
					break
			else if (!src.equipped())
				for (var/obj/item/implant/projectile/body_visible/dart/bardart/dart in view(1, src))
					src.hand_attack(dart)
					break
			if (prob(50))
				src.ai_pickpocket(priority_only=prob(80))
			else if (prob(50))
				src.ai_knock_from_hand(priority_only=prob(80))
			if(!ai_target && prob(20))
				for(var/obj/fitness/speedbag/bag in view(1, src))
					if(!ON_COOLDOWN(src, "ai monkey punching bag", 1 MINUTE))
						src.ai_target = bag
						src.target = bag
						src.ai_set_state(AI_ATTACKING)
						break
			if(prob(1))
				src.emote(pick("dance", "flip", "laugh"))
			if(prob(ai_poke_thing_chance))
				var/list/atom/things_to_pick = list()
				for(var/obj/O in range(1, get_turf(src)))
					if(istype(O, /obj/overlay) || istype(O, /obj/effect) || O.invisibility > 0 || !O.mouse_opacity)
						continue
					if(istype(O, /obj/machinery/light) && prob(90)) // don't break lights too often pls
						continue
					things_to_pick += O
				if(prob(15))
					for(var/mob/M in range(1, get_turf(src)))
						things_to_pick += M
				if(!length(things_to_pick))
					src.emote(pick("whimper", "growl", "scowl", "grimace", "sulk", "pout", "shrug", "yawn"))
				else if(prob(15) && src.bioHolder.HasOneOfTheseEffects("midas", "inkglands", "healingtouch")) // this monkey's all gene'd up
					var/atom/thing_to_poke = pick(things_to_pick)
					var/datum/bioEffect/power/healing_touch/healing_touch = src.bioHolder.GetEffect("healing_touch")
					var/datum/bioEffect/power/midas/midas_touch = src.bioHolder.GetEffect("midas")
					var/datum/bioEffect/power/ink/ink_glands = src.bioHolder.GetEffect("inkglands")
					if (ismob(thing_to_poke) && healing_touch && healing_touch.ability.last_cast < world.time)
						healing_touch.ability.handleCast(thing_to_poke)
					else if (!ismob(thing_to_poke) && midas_touch && midas_touch?.ability.last_cast < world.time)
						midas_touch.ability.handleCast(thing_to_poke)
					else
						ink_glands?.ability.handleCast(thing_to_poke)
				else if(src.equipped())
					var/atom/thing_to_poke = pick(things_to_pick)
					src.weapon_attack(thing_to_poke, src.equipped(), TRUE)
				else
					var/atom/thing_to_poke = pick(things_to_pick)
					src.hand_attack(thing_to_poke)
			if(prob(0.5))
				var/list/priority_targets = list()
				var/list/targets = list()
				for(var/atom/movable/AM in view(5, src))
					if(ismob(AM) && AM != src)
						priority_targets += AM
					else if(isobj(AM) && isturf(AM.loc) && !istype(AM, /obj/overlay))
						targets += AM
				if(length(priority_targets) && prob(55))
					src.point_at(pick(priority_targets))
					if(prob(20))
						src.emote("laugh")
				else if(length(targets))
					src.point_at(pick(targets))

	ai_findtarget_new()
		if (ai_aggressive || ai_aggression_timeout == 0 || (world.timeofday - ai_threatened) < ai_aggression_timeout)
			..()

	was_harmed(var/atom/T as mob|obj, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		// Dead monkeys can't hold a grude and stops emote
		if(isdead(src) || T == src)
			return ..()
		if(isintangible(T))
			if(!iswraith(T))
				return ..()
			else
				if(!T.density)
					return ..()
		if(isobserver(T))
			return ..()
		if(ismonkey(T) && T:ai_active && prob(90))
			return ..()
		//src.ai_aggressive = 1
		var/aggroed = src.ai_state != AI_ATTACKING
		src.target = T
		if (src.ai_set_state(AI_ATTACKING))
			src.ai_target = T
			src.shitlist[T] ++
		src.ai_threatened = world.timeofday
		if (prob(40))
			if(!ON_COOLDOWN(src, "monkey_harmed_scream", 5 SECONDS))
				src.emote("scream")
		var/pals = 0
		for_by_tcl(pal, /mob/living/carbon/human/npc/monkey)
			if (pal == src)
				continue
			if (GET_DIST(src, pal) > 7)
				continue
			if (pals >= 5)
				return
			if (prob(10))
				continue
			if (!pal.ai_set_state(AI_ATTACKING))
				continue
			pal.target = T
			pal.ai_set_state(AI_ATTACKING)
			pal.ai_threatened = world.timeofday
			pal.ai_target = T
			pal.shitlist[T] ++
			pals ++
			if (prob(40))
				if(!ON_COOLDOWN(pal, "monkey_harmed_scream", 5 SECONDS))
					pal.emote("scream")
			if(src.client)
				break

		if(aggroed)
			walk_towards(src, ai_target, ai_movedelay)

	ai_is_valid_target(mob/M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (istype(H.wear_suit, /obj/item/clothing/suit/monkey))
				return FALSE
		return ..()

	proc/shot_by(var/atom/A as mob|obj)
		if (src.ai_state == AI_ATTACKING)
			return
		if (ishuman(A))
			src.was_harmed(A)
		else
			walk_away(src, A, 10, 1)
			SPAWN(1 SECOND)
				walk(src, 0)

	proc/done_with_you(var/atom/T as mob|obj)
		if (!T)
			return 0
		if(isintangible(T))
			if(!iswraith(T))
				src.ai_set_state(AI_PASSIVE)
				src.target = null
				src.ai_target = null
				src.ai_frustration = 0
				walk_towards(src,null)
				return 1
			else
				if(!T.density)
					src.ai_set_state(AI_PASSIVE)
					src.target = null
					src.ai_target = null
					src.ai_frustration = 0
					walk_towards(src,null)
					return 1
		if (src.health <= 0 || (GET_DIST(src, T) >= 11))
			if(src.health <= 0)
				src.ai_set_state(AI_FLEEING)
			else
				src.ai_set_state(AI_PASSIVE)
				src.target = null
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
				src.ai_set_state(AI_PASSIVE)
				src.ai_target = null
				src.ai_frustration = 0
				walk_towards(src,null)
				return 1
		else
			return 0

	proc/ai_pickpocket(priority_only=FALSE)
		if (src.getStatusDuration("knockdown") || src.getStatusDuration("stunned") || src.getStatusDuration("unconscious") || src.stat || src.ai_picking_pocket)
			return
		var/list/possible_targets = list()
		var/list/priority_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if(H == src)
				continue
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				if(H.handcuffs)
					priority_targets += H
					continue
				for(var/obj/item/thing in H)
					if(IS_NPC_HATED_ITEM(thing) && thing.equipped_in_slot)
						priority_targets += H
						break
				continue
			if (!H.l_store && !H.r_store && isalive(H))
				continue
			possible_targets += H
		if(length(possible_targets) == 0 && length(priority_targets) == 0)
			return
		var/mob/living/carbon/human/theft_target
		if(length(priority_targets))
			theft_target = pick(priority_targets)
		else if(!priority_only)
			theft_target = pick(possible_targets)
		var/obj/item/thingy
		var/slot = 15
		if(!theft_target)
			return
		if(ismonkey(theft_target))
			if(theft_target.handcuffs)
				actions.start(new/datum/action/bar/icon/handcuffRemovalOther(theft_target), src)
				return
			for(var/obj/item/thing in theft_target)
				if(IS_NPC_HATED_ITEM(thing) && thing.equipped_in_slot)
					thingy = thing
					slot = thing.equipped_in_slot
					break
		if(!thingy)
			if(!isalive(theft_target))
				var/list/choices = theft_target.get_equipped_items()
				if(!length(choices))
					return
				thingy = pick(choices)
			else if (theft_target.l_store && theft_target.r_store)
				thingy = pick(theft_target.l_store, theft_target.r_store)
			else if (theft_target.l_store)
				thingy = theft_target.l_store
			else if (theft_target.r_store)
				thingy = theft_target.r_store
			else // ???
				return
		slot = theft_target.get_slot_from_item(thingy)
		walk_towards(src, null)
		if(ismonkey(theft_target))
			src.say("I help!")
		else if(isalive(theft_target))
			src.say("[pick("Gimme", "Want", "Need")] [thingy.name].") // Monkeys don't know grammar!
		actions.start(new/datum/action/bar/icon/filthyPickpocket(src, theft_target, slot), src)

	ai_move()
		if(src.ai_picking_pocket)
			return
		if(src.ai_delay_move)
			src.ai_delay_move = FALSE
			return
		. = ..()

	proc/ai_knock_from_hand(priority_only=FALSE)
		if (src.getStatusDuration("knockdown") || src.getStatusDuration("stunned") || src.getStatusDuration("unconscious") || src.stat || src.ai_picking_pocket || src.r_hand)
			return
		var/list/possible_targets = list()
		var/list/priority_targets = list()
		for (var/mob/living/carbon/human/H in view(1, src))
			if (istype(H, /mob/living/carbon/human/npc/monkey))
				continue
			if (!H.l_hand && !H.r_hand)
				continue
			possible_targets += H
			if(H.equipped() && IS_NPC_HATED_ITEM(H.equipped()) || istype(H.equipped(), /obj/item/gun) && prob(60))
				priority_targets += H
		if(length(possible_targets) == 0 && length(priority_targets) == 0)
			return
		var/mob/living/carbon/human/theft_target
		if(length(priority_targets))
			theft_target = pick(priority_targets)
		else if(!priority_only)
			theft_target = pick(possible_targets)
		if(!theft_target)
			return
		walk_towards(src, null)
		src.set_a_intent(INTENT_DISARM)
		theft_target.Attackhand(src)
		src.set_a_intent(src.ai_default_intent)

	proc/pursuited_by(atom/movable/AM)
		src.ai_set_state(AI_FLEEING)
		src.ai_target = AM
		src.target = AM

/datum/action/bar/icon/filthyPickpocket
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	/// NPC who is pickpocketing
	var/mob/living/carbon/human/npc/source
	/// The pick-pocketing victim
	var/mob/living/carbon/human/target
	/// The SLOT_* define (i.e. SLOT_BACK)
	var/slot

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

		if (!(source.has_hand(1) || source.has_hand(0)))
			source.show_text("You can't take something without hands.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing(LOG_COMBAT, source, "tries to pickpocket \an [I] from [constructTarget(target,"combat")]")

		if(slot == SLOT_L_STORE || slot == SLOT_R_STORE)
			source.visible_message("<B>[source]</B> rifles through [target]'s pockets!", "You rifle through [target]'s pockets!")
		else
			source.visible_message("<B>[source]</B> rifles through [target]!", "You rifle through [target]!")

		source.ai_picking_pocket = 1

	onEnd()
		..()

		if(BOUNDS_DIST(source, target) > 0 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/obj/item/I = target.get_slot(slot)
		if(!I)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(I.handle_other_remove(source, target))
			logTheThing(LOG_COMBAT, source, "successfully pickpockets \an [I] from [constructTarget(target,"combat")]!")
			if(slot == SLOT_L_STORE || slot == SLOT_R_STORE)
				source.visible_message("<B>[source]</B> grabs [I] from [target]'s pockets!", "You grab [I] from [target]'s pockets!")
			else
				source.visible_message("<B>[source]</B> grabs [I] from [target]!", "You grab [I] from [target]!")
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
		if(BOUNDS_DIST(source, target) > 0 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.get_slot(slot=slot))
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		source.ai_picking_pocket = 0

/mob/living/carbon/human/npc/monkey/friendly

	ai_set_state(var/state)
		if (state == AI_ANGERING || state == AI_ATTACKING)
			return FALSE
		else
			return ..()

/mob/living/carbon/human/npc/monkey/angry
	ai_aggressive = 1
	ai_calm_down = 0
	ai_default_intent = INTENT_HARM
	ai_aggression_timeout = null
	max_health = 150

	New()
		..()
		SPAWN(1 SECOND)
			var/head = pick(/obj/item/clothing/head/bandana/red, /obj/item/clothing/head/bandana/random_color)
			src.equip_new_if_possible(/obj/item/clothing/shoes/tourist, SLOT_SHOES)
			src.equip_new_if_possible(head, SLOT_HEAD)
			var/weap = pick(/obj/item/saw/active, /obj/item/extinguisher, /obj/item/ratstick, /obj/item/razor_blade, /obj/item/bat, /obj/item/kitchen/utensil/knife/cleaver, /obj/item/nunchucks, /obj/item/tinyhammer, /obj/item/storage/toolbox/mechanical/empty, /obj/item/kitchen/rollingpin)
			src.put_in_hand_or_drop(new weap)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "angry_monkey", 5)
		src.add_stam_mod_max("angry_monkey", 100)

	get_disorient_protection()
		. = ..()
		return clamp(.+25, 80, .)

	ai_is_valid_target(mob/M)
		return ..() && !(istype(M, /mob/living/carbon/human/npc/monkey/angry))

/mob/living/carbon/human/npc/monkey/angry/testing
	ai_attacknpc = TRUE

	ai_is_valid_target(mob/M)
		return isalive(M)

// sea monkeys
/mob/living/carbon/human/npc/monkey/sea
	name = "sea monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "sea"
#endif
	max_health = 150
	ai_useitems = FALSE // or they eat all the floor pills and die before anyone visits
	default_mutantrace = /datum/mutantrace/monkey/seamonkey

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (!src.disposed)
				if (src.name == "sea monkey" || !src.name)
					src.name = pick_string_autokey("names/monkey.txt")
				src.real_name = src.name


/mob/living/carbon/human/npc/monkey/sea/gang
	//name = "sea monkey"
	//real_name = "sea monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "sea_gang"
#endif
	gender = "male"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, SLOT_GLASSES)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/mobster/alt, SLOT_W_UNIFORM)

/mob/living/carbon/human/npc/monkey/sea/gang_gun
	//name = "sea monkey"
	//real_name = "sea monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "sea_gang"
#endif
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, SLOT_GLASSES)
			src.equip_new_if_possible(/obj/item/gun/kinetic/detectiverevolver, SLOT_L_HAND)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/mobster/alt, SLOT_W_UNIFORM)

/mob/living/carbon/human/npc/monkey/sea/rich
	//name = "sea monkey"
	//real_name = "sea monkey"
#ifdef IN_MAP_EDITOR
	icon_state = "sea_rich"
#endif
	gender = "female"
	ai_aggressive = 1
	ai_calm_down = 0
	ai_aggression_timeout = null
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/head/crown, SLOT_HEAD)

/mob/living/carbon/human/npc/monkey/sea/lab
	name = "Kimmy"
	real_name = "Kimmy"
	gender = "female"
#ifdef IN_MAP_EDITOR
	icon_state = "sea_sci"
#endif
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, SLOT_GLASSES)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/scientist, SLOT_W_UNIFORM)

// non-AI monkeys
/mob/living/carbon/human/monkey/mr_wigglesby
	name = "Mr. Wigglesby"
	real_name = "Mr. Wigglesby"
#ifdef IN_MAP_EDITOR
	icon_state = "mr_wigglesby"
#endif
	gender = "male"
	New()
		..()
		SPAWN(1 SECOND)
			src.equip_new_if_possible(/obj/item/clothing/under/suit/black, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)

#undef IS_NPC_HATED_ITEM
