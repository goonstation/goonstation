/datum/targetable/steal_shoes
	name = "Steal Shoes"
	desc = "Attempt to steal the shoes of an unsuspecting victim."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "power_kick"
	cooldown = 2 SECONDS
	targeted = TRUE
	target_anything = TRUE

	tryCast()
		if (is_incapacitated(holder.owner))
			boutput(holder.owner, SPAN_ALERT("You cannot cast this ability while you are incapacitated."))
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		. = ..()

	cast(atom/target)
		if(..())
			return 1
		if(target == holder.owner || !ishuman(target))
			return 1
		if(!(BOUNDS_DIST(holder.owner, target) == 0))
			boutput(holder.owner, SPAN_ALERT("Target is too far away."))
			return 1

		var/mob/living/carbon/human/H = target
		var/obj/item/shoes = H.get_slot(SLOT_SHOES)
		if(!shoes)
			boutput(holder.owner, SPAN_ALERT("[target] has no shoes!"))
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
			boutput(source, SPAN_ALERT("[target] has no shoes!"))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(!isturf(target.loc))
			boutput(source, SPAN_ALERT("You can't remove [shoes] from [target] when [(he_or_she(target))] is in [target.loc]!"))
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing(LOG_COMBAT, source, "tries to remove \an [shoes] from [constructTarget(target,"combat")] at [log_loc(target)].")
		var/name = "something"
		icon = shoes.icon
		icon_state = shoes.icon_state
		name = shoes.name
		for(var/mob/O in AIviewers(owner))
			O.show_message(SPAN_ALERT("<B>[source] tries to remove [name] from [target]!</B>"), 1)

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
					O.show_message(SPAN_ALERT("<B>[source] removes [shoes] from [target]!</B>"), 1)

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
				boutput(source, SPAN_ALERT("You fail to remove [shoes] from [target]."))
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

/obj/item/shoethief_bag
	name = "Bottomless bag of shoes"
	desc = "This bag is pretty deep!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "moneybag"
	item_state = "moneybag"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	attackby(obj/item/W, mob/user)
		if(!istype(W, /obj/item/clothing/shoes))
			boutput(user, SPAN_ALERT("\The [W] doesn't seem to fit in the bag. Weird!"))
			return
		user.u_equip(W)
		W.set_loc(src)
		playsound(src.loc, "rustle", 50, 1, -5)
		boutput(user, "You stuff [W] into [src].")

	attack_hand(mob/user)
		if (!user.find_in_hand(src))
			return ..()
		if (!src.contents.len)
			boutput(user, SPAN_ALERT("\The [src] is empty!"))
			return
		else
			var/obj/item/I = pick(src.contents)
			playsound(src.loc, "rustle", 50, 1, -5)
			boutput(user, "You rummage around in [src] and pull out [I].")
			user.put_in_hand_or_drop(I)
