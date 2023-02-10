/mob/proc/make_floor_goblin()
	if (!(ishuman(src) && src.bioHolder && src.mind))
		return
	var/mob/living/carbon/human/H = src

	message_admins("[key_name(usr)] made [key_name(H)] a floor goblin.")
	logTheThing(LOG_ADMIN, usr, "made [constructTarget(H,"admin")] a floor goblin.")

	var/datum/abilityHolder/floor_goblin/abilityHolder = H.add_ability_holder(/datum/abilityHolder/floor_goblin)
	H.bioHolder.age = -200
	H.Scale(0.5, 0.5)
	H.real_name = "Floor Goblin"
	H.bioHolder.AddEffect("breathless", 0, 0, 0, 1)
	H.bioHolder.AddEffect("nightvision", 0, 0, 0, 1)
	H.bioHolder.mobAppearance.s_tone = "#00FF1B"
	H.bioHolder.mobAppearance.s_tone_original = "#00FF1B"
	H.bioHolder.mobAppearance.UpdateMob()
	H.update_colorful_parts()

	abilityHolder.addAbility(/datum/targetable/steal_shoes)
	abilityHolder.addAbility(/datum/targetable/hide_between_floors)
	abilityHolder.addAbility(/datum/targetable/ankle_bite)
	ticker.mode.Agimmicks.Add(H)

	H.unequip_all()
	H.equip_new_if_possible(/obj/item/clothing/shoes/sandal/wizard, SLOT_SHOES)
	H.equip_new_if_possible(/obj/item/clothing/under/gimmick/viking, SLOT_W_UNIFORM)
	H.equip_new_if_possible(/obj/item/clothing/head/helmet/viking, SLOT_HEAD)
	H.equip_new_if_possible(/obj/item/storage/backpack/, SLOT_BACK)
	H.equip_new_if_possible(/obj/item/card/id/syndicate, SLOT_WEAR_ID)
	H.equip_new_if_possible(/obj/item/tank/emergency_oxygen/extended, SLOT_R_STORE)
	H.equip_new_if_possible(/obj/item/device/radio/headset/command, SLOT_EARS)
	H.equip_new_if_possible(/obj/item/storage/fanny, SLOT_BELT)
	H.equip_new_if_possible(/obj/item/shoethief_bag, SLOT_IN_BELT)


/obj/item/shoethief_bag
	name = "Bottomless bag of shoes"
	desc = "This bag is pretty deep!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "moneybag"
	item_state = "moneybag"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	attackby(obj/item/W, mob/user)
		if(!istype(W, /obj/item/clothing/shoes))
			boutput(user, "<span class='alert'>\The [W] doesn't seem to fit in the bag. Weird!</span>")
			return
		user.u_equip(W)
		W.set_loc(src)
		playsound(src.loc, "rustle", 50, 1, -5)
		boutput(user, "You stuff [W] into [src].")

	attack_hand(mob/user)
		if (!user.find_in_hand(src))
			return ..()
		if (!src.contents.len)
			boutput(user, "<span class='alert'>\The [src] is empty!</span>")
			return
		else
			var/obj/item/I = pick(src.contents)
			playsound(src.loc, "rustle", 50, 1, -5)
			boutput(user, "You rummage around in [src] and pull out [I].")
			user.put_in_hand_or_drop(I)

/datum/abilityHolder/floor_goblin
	usesPoints = 1
	pointName = "Shoes stolen"
	regenRate = 0
	tabName = "Floor Goblin"
	var/shoes_stolen = 0

	onAbilityStat()
		..()
		.= list()
		.["Shoes stolen:"] = points
		return

/datum/targetable/hide_between_floors
	name = "Toggle Reveal"
	desc = "Toggle your ability to hide between the floor tiles."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "floorgoblin_hide"
	targeted = 0
	cooldown = 0

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = 0
			return 999
		. = ..()

	cast(atom/T)
		var/mob/M = src.holder.owner
		if (!M) return
		var/turf/floorturf = get_turf(M)
		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

		if(M.layer == BETWEEN_FLOORS_LAYER)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_HIDE_ICONS, "underfloor")
			M.flags &= ~(NODRIFT | DOORPASS | TABLEPASS)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
			REMOVE_ATOM_PROPERTY(M, PROP_ATOM_NEVER_DENSE, "floorswitching")
			M.set_density(initial(M.density))
			if (floorturf.intact)
				animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(M)
					M.layer = MOB_LAYER
					M.plane = PLANE_DEFAULT
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
				if(floorturf?.intact)
					animate_slide(floorturf, 0, 0, 4)

		else
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_HIDE_ICONS, "underfloor")
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
			if (floorturf.intact)
				animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				if(M)
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "floorswitching")
					APPLY_ATOM_PROPERTY(M, PROP_MOB_NO_MOVEMENT_PUFFS, "floorswitching")
					APPLY_ATOM_PROPERTY(M, PROP_ATOM_NEVER_DENSE, "floorswitching")
					M.flags |= NODRIFT | DOORPASS | TABLEPASS
					M.set_density(0)
					M.layer = BETWEEN_FLOORS_LAYER
					M.plane = PLANE_FLOOR
				if(floorturf?.intact)
					animate_slide(floorturf, 0, 0, 4)

/datum/targetable/ankle_bite
	name = "Ankle Bite"
	desc = "Trip a target by biting at their ankles."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "clown_spider_bite"
	cooldown = 20 SECONDS
	targeted = 1
	target_anything = 1

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = 0
			return 999
		. = ..()

	cast(atom/target)
		if(..())
			return 1
		if(target == holder.owner || !ishuman(target))
			return 1
		if(!(BOUNDS_DIST(holder.owner, target) == 0))
			boutput(holder.owner, "<span class='alert'>Target is too far away.</span>")
			return 1
		var/mob/living/carbon/human/target_human = target
		if(!target_human?.limbs?.l_leg || !target_human?.limbs?.r_leg)
			boutput(holder.owner, "<span class='alert'>[target_human] has no ankles to bite!</span>")
			return 1

		var/x_coeff = rand(0, 1)	// open the floor horizontally
		var/y_coeff = !x_coeff // or vertically but not both - it looks weird
		var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath
		var/turf/floorturf = get_turf(holder.owner)

		if(holder.owner.layer == BETWEEN_FLOORS_LAYER)
			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			APPLY_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
			SPAWN(0.4 SECONDS)
				if(holder.owner && target_human && (BOUNDS_DIST(holder.owner, target) == 0))
					playsound(floorturf, 'sound/impact_sounds/Flesh_Tear_3.ogg', 50, 1, pitch = 1.3)
					target_human.changeStatus("weakened", 2 SECONDS)
					target_human.force_laydown_standup()
					holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites at [target_human]'s ankles!</b></span>",\
					"<span class='combat'><b>You bite at [target_human]'s ankles!</b></span>")
					REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
				else
					boutput(holder.owner, "<span class='alert'>[target_human] moved out of reach!</span>")
					REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "floorbiting")
				sleep(0.4 SECONDS)
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)
		else
			playsound(floorturf, 'sound/impact_sounds/Flesh_Tear_3.ogg', 50, 1, pitch = 1.3)
			target_human.changeStatus("weakened", 2 SECONDS)
			target_human.force_laydown_standup()
			holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites at [target_human]'s ankles!</b></span>",\
			"<span class='combat'><b>You bite at [target_human]'s ankles!</b></span>")
		return 0

/datum/targetable/steal_shoes
	name = "Steal Shoes"
	desc = "Attempt to steal the shoes of an unsuspecting victim."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "power_kick"
	cooldown = 20
	targeted = 1
	target_anything = 1

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are incapacitated.</span>")
			src.holder.locked = 0
			return 999
		. = ..()

	cast(atom/target)
		if(..())
			return 1
		if(target == holder.owner || !ishuman(target))
			return 1
		if(!(BOUNDS_DIST(holder.owner, target) == 0))
			boutput(holder.owner, "<span class='alert'>Target is too far away.</span>")
			return 1

		var/mob/living/carbon/human/H = target
		var/obj/item/shoes = H.get_slot(SLOT_SHOES)
		if(!shoes)
			boutput(holder.owner, "<span class='alert'>[target] has no shoes!</span>")
			return 1

		var/mob/living/carbon/human/target_human = target
		var/turf/floorturf = get_turf(holder.owner)
		if(holder.owner.layer == BETWEEN_FLOORS_LAYER && floorturf)
			var/x_coeff = rand(0, 1)	// open the floor horizontally
			var/y_coeff = !x_coeff // or vertically but not both - it looks weird
			var/slide_amount = 22 // around 20-25 is just wide enough to show most of the person hiding underneath

			animate_slide(floorturf, x_coeff * -slide_amount, y_coeff * -slide_amount, 4)
			SPAWN(0.4 SECONDS)
				actions.start(new/datum/action/bar/icon/steal_shoes(usr, target_human, floorturf) , usr)
		else
			actions.start(new/datum/action/bar/icon/steal_shoes(usr, target_human, floorturf) , usr)

		return 1

/datum/action/bar/icon/steal_shoes//Putting items on or removing items from others.
	id = "stealshoes"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	duration = 5

	var/mob/living/carbon/human/source  //The shoe tief
	var/mob/living/carbon/human/target  //The victim
	var/turf/floorturf

	New(var/Source, var/Target, var/turf/starting_turf, var/ExtraDuration = 0)
		source = Source
		target = Target
		duration += ExtraDuration
		floorturf = starting_turf
		..()

	onStart()
		var/obj/item/shoes = target.get_slot(SLOT_SHOES)
		if(!shoes)
			boutput(source, "<span class='alert'>[target] has no shoes!</span>")
			interrupt(INTERRUPT_ALWAYS)
			return
		if(!isturf(target.loc))
			boutput(source, "<span class='alert'>You can't remove [shoes] from [target] when [(he_or_she(target))] is in [target.loc]!</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing(LOG_COMBAT, source, "tries to remove \an [shoes] from [constructTarget(target,"combat")] at [log_loc(target)].")
		var/name = "something"
		icon = shoes.icon
		icon_state = shoes.icon_state
		name = shoes.name
		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[source] tries to remove [name] from [target]!</B></span>", 1)

		..() // we call our parents here because we need to set our icon and icon_state before calling them

	onEnd()
		..()

		if(!(BOUNDS_DIST(source, target) == 0) || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/obj/item/shoes = target.get_slot(SLOT_SHOES)

		if(shoes)
			if(shoes.handle_other_remove(source, target))
				logTheThing(LOG_COMBAT, source, "successfully removes \an [shoes] from [constructTarget(target,"combat")] at [log_loc(target)].")
				for(var/mob/O in AIviewers(owner))
					O.show_message("<span class='alert'><B>[source] removes [shoes] from [target]!</B></span>", 1)

				target.u_equip(shoes)
				shoes.set_loc(target.loc)
				shoes.dropped(target)
				shoes.layer = initial(shoes.layer)
				shoes.add_fingerprint(source)
				source.put_in_hand_or_drop(shoes)
				var/datum/abilityHolder/floor_goblin/abilityHolder = source.get_ability_holder(/datum/abilityHolder/floor_goblin)
				if(abilityHolder)
					abilityHolder.addPoints(1)
			else
				boutput(source, "<span class='alert'>You fail to remove [shoes] from [target].</span>")
			SPAWN(0.4 SECONDS)
				if(floorturf)
					animate_slide(floorturf, 0, 0, 4)

	onUpdate()
		..()

		if(!(BOUNDS_DIST(source, target) == 0) || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.get_slot(SLOT_SHOES))
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt(var/flag)
		..()

		if(floorturf)
			animate_slide(floorturf, 0, 0, 4)
