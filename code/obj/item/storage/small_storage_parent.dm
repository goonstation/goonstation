
// haine wuz here and tore this file to bits!!!  f u we can have things in their own files and we SHOULD
// rather than EVERYTHING BEING IN HALLOWEEN.DM AND KEELINSSTUFF.DM OKAY THINGS CAN BE IN OTHER FILES

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "box_blank"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	// variables here are copied from /datum/storage
	var/list/can_hold = null
	var/list/can_hold_exact = null
	var/list/prevent_holding = null
	var/check_wclass = 0
	var/datum/hud/storage/hud
	var/sneaky = 0
	var/stealthy_storage = FALSE
	var/opens_if_worn = FALSE
	var/max_wclass = W_CLASS_SMALL
	var/slots = 7
	var/list/spawn_contents = list()
	move_triggered = 1
	flags = TABLEPASS | NOSPLASH
	w_class = W_CLASS_NORMAL
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL

		//cogwerks - burn vars
	burn_point = 2500
	burn_output = 2500
	burn_possible = TRUE
	health = 10

	New()
		src.create_storage(/datum/storage, spawn_contents, can_hold, can_hold_exact, prevent_holding, check_wclass, max_wclass, slots, sneaky, stealthy_storage, opens_if_worn)
		src.make_my_stuff()
		..()

	// override this with specific additions to add to the storage
	proc/make_my_stuff()
		return

	combust()
		..()
		for (var/obj/item/I as anything in src.storage.get_contents())
			I.temperature_expose(null, src.burn_output)

	process_burning()
		for (var/obj/item/I as anything in src.storage.get_contents())
			I.temperature_expose(null, src.burn_output)
		. = ..()

	combust_ended()
		if (src.health <= 0) // okay lets make sure it actually fully burned and not just got extinguished
			for (var/obj/item/I as anything in src.storage.get_contents())
				src.storage.transfer_stored_item(I, get_turf(src))
		. = ..()

/obj/item/storage/box
	name = "box"
	icon_state = "box"
	desc = "A box that can hold a number of small items."
	max_wclass = W_CLASS_SMALL

/obj/item/storage/box/starter // the one you get in your backpack
	icon_state = "emergbox"
	spawn_contents = list(/obj/item/clothing/mask/breath, /obj/item/tank/emergency_oxygen)
	make_my_stuff(onlyMaskAndOxygen)
		..()
		if (prob(15) || ticker?.round_elapsed_ticks > 20 MINUTES && !onlyMaskAndOxygen) //aaaaaa
			src.storage.add_contents(new /obj/item/tank/emergency_oxygen(src))
		if (ticker?.round_elapsed_ticks > 20 MINUTES && !onlyMaskAndOxygen)
			src.storage.add_contents(new /obj/item/crowbar/red(src))
#ifdef MAP_OVERRIDE_NADIR //guarantee protective gear
		src.storage.add_contents(new /obj/item/clothing/head/emerg(src))
		src.storage.add_contents(new /obj/item/emergencysuitfolded(src))
#else
		if (prob(10)) // put these together
			src.storage.add_contents(new /obj/item/clothing/head/emerg(src))
			src.storage.add_contents(new /obj/item/emergencysuitfolded(src))
#endif


/obj/item/storage/box/starter/withO2 //use this if the box should not get additional items after the round has passed 20 min
	spawn_contents = list(/obj/item/clothing/mask/breath, /obj/item/tank/emergency_oxygen)
	make_my_stuff()
		..(TRUE)

/obj/item/storage/pill_bottle
	name = "pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	can_hold = list(/obj/item/reagent_containers/pill)
	w_class = W_CLASS_SMALL
	max_wclass = W_CLASS_TINY
	desc = "A small bottle designed to carry pills. Does not come with a child-proof lock, as that was determined to be too difficult for the crew to open."
	/// A reference to the action currently in use if eating pills from the bottle.
	var/datum/action/bar/icon/consume_pill_from_bottle_regular/consumption_action

	mouse_drop(atom/over_object, src_location, over_location, src_control, over_control, params)
		if (usr == over_object && istype(usr, /mob/living/carbon) && (src.loc == usr || src.loc?.loc == usr))
			if(usr.restrained())
				boutput(usr, SPAN_ALERT("You can't get into the [src] in your current state."))
				return FALSE
			if (!usr.is_in_hands(src))
				if (!usr.is_in_hands(null))
					boutput(usr, SPAN_ALERT("You need a free hand to do that."))
					return FALSE
				usr.drop_item(src) // this is just to prevent an item ghost in the inventory, but there might be a better way to do that.
				usr.put_in_hand(src)
			start_consuming_pills(usr)
			return
		..()

	proc/start_consuming_pills(mob/user)
		if (!contents.len)
			boutput(user, SPAN_ALERT("[src] is empty!"))
			return
		if (!consumption_action)
			consumption_action = new /datum/action/bar/icon/consume_pill_from_bottle_regular(user, src)
			actions.start(consumption_action, user)
		else
			consumption_action.consume_input_buffer++

	/// Returns true if a pill was successfully swallowed.
	proc/consume_next_pill(mob/user)
		if (!contents.len)
			return FALSE
		// take the last pill in the list because it'll be the most recent pill added, and that makes it easier to spike pill bottles.
		var/obj/item/reagent_containers/pill/Pill = contents[contents.len]
		if (!Pill)
			user.visible_message(
				SPAN_NOTICE("[user] chokes on something from [src]!"),
				SPAN_NOTICE("You choke on [contents[contents.len]]!"),
				SPAN_NOTICE("Someone chokes on something.")
			)
			user.drop_item(contents[contents.len])
			return FALSE
		Pill.pill_action(user, user)
		return TRUE

	/// consume_next_pill() wrapper that handles sounds, clumsiness and majority of messaging.
	/// Returns true if a pill was successfully swallowed.
	proc/try_consume_from_bottle(mob/user)
		if (!contents.len)
			boutput(user, SPAN_ALERT("[src] is empty!"))
			return FALSE
		// clumsy and braindamaged people have a chance to consume multiple pills and spill the rest onto the floor.
		if(contents.len > 1 && ((user.bioHolder && user.bioHolder.HasEffect("clumsy")) || user.get_brain_damage() > 40) && prob(20))
			playsound(src.loc, 'sound/effects/pop_pills.ogg', rand(10,50), 1) //range taken from drinking/eating
			user.visible_message(SPAN_NOTICE("[user] throws the contents of [src] at their own face!"),
								null, SPAN_NOTICE("Someone pops some pills."))
			var pillSwallowed = FALSE
			for(var/i = 0; i < rand(1, max(contents.len, 3)); i++)
				if (consume_next_pill(user)) pillSwallowed = TRUE
			while (contents.len > 0)
				user.drop_item(contents[contents.len])
			return pillSwallowed
		else
			playsound(src.loc, 'sound/effects/pop_pills.ogg', rand(10,50), 1) //range taken from drinking/eating
			user.visible_message(SPAN_NOTICE("[user] pops a pill from [src]!"), null, SPAN_NOTICE("Someone pops a pill."))
			return consume_next_pill(user)


/datum/action/bar/icon/consume_pill_from_bottle_regular
	duration = 0.75 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	var/mob/bottleholder
	var/mob/target
	var/obj/item/storage/pill_bottle/bottle
	var/consume_input_buffer = 1

	New(mob/Target, obj/item/storage/pill_bottle/Bottle)
		..()
		target = Target
		bottle = Bottle
		icon = bottle.icon
		icon_state = bottle.icon_state

	proc/checkContinue()
		if (bottle.contents.len <= 0 || !isalive(bottleholder) || !bottleholder.find_in_hand(bottle))
			return FALSE
		return TRUE

	onStart()
		..()
		bottleholder = src.owner
		loopStart()
		return

	loopStart()
		..()
		if(!checkContinue()) interrupt(INTERRUPT_ALWAYS)
		return

	onUpdate()
		..()
		if(!checkContinue()) interrupt(INTERRUPT_ALWAYS)
		return

	onInterrupt(flag)
		..()
		if (flag & (INTERRUPT_ATTACKED | INTERRUPT_STUNNED))
			if (bottle.contents.len > 0) bottleholder.drop_item(bottle.contents[bottle.contents.len])
		bottle.consumption_action = null

	onEnd()
		consume_input_buffer--
		if (bottle.try_consume_from_bottle(target))
			eat_twitch(target)
		else // if a pill was not successfully swallowed something is probably wrong, so don't let the loop restart
			bottle.consumption_action = null
			..()
			return
		var/pillsRemainingInBottle = bottle.contents.len
		if (pillsRemainingInBottle > 0 && consume_input_buffer > 0)
			onRestart()
			return
		if(pillsRemainingInBottle <= 0)
			boutput(usr, SPAN_ALERT("The [src] is empty."))
		bottle.consumption_action = null
		..()
		return


/obj/item/storage/briefcase
	name = "briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	flags = TABLEPASS| CONDUCT | NOSPLASH
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	desc = "A fancy synthetic leather-bound briefcase, capable of holding a number of small objects, with style."
	stamina_damage = 40
	stamina_cost = 17
	stamina_crit_chance = 10
	spawn_contents = list(/obj/item/paper = 2,/obj/item/pen)
	// Don't use up more slots, certain job datums put items in the briefcase the player spawns with.
	// And nobody needs six sheets of paper right away, realistically speaking.

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	onMaterialChanged()
		. = ..()
		if(istype_exact(src, /obj/item/storage/briefcase) && src.material.getID() == "leather")
			src.desc = "A fancy natural leather-bound briefcase, capable of holding a number of small objects, with exquisite style."
			src.tooltip_rebuild = TRUE

/obj/item/storage/briefcase/toxins
	name = "toxins research briefcase"
	icon_state = "briefcase_rd"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "rd-case"
	max_wclass = W_CLASS_BULKY// parity with secure briefcase
	desc = "A large briefcase for experimental toxins research."
	spawn_contents = list(/obj/item/raw_material/molitz_beta = 2, /obj/item/paper/hellburn)

/obj/item/storage/rockit
	name = "\improper Rock-It Launcher"
	desc = "Huh..."
	icon = 'icons/obj/items/guns/gimmick.dmi'
	icon_state = "rockit"
	item_state = "gun"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	var/fire_delay = 0.4 SECONDS

	New()
		..()
		src.setItemSpecial(null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (target == loc)
			return
		if (!length(src.storage.get_contents()))
			return
		if (ON_COOLDOWN(src, "rockit_firerate", src.fire_delay))
			return
		var/obj/item/I = pick(src.storage.get_contents())
		if (!I)
			return

		src.storage.transfer_stored_item(I, get_turf(src.loc))
		I.dropped(user)
		I.layer = initial(I.layer)
		I.throw_at(target, 8, 2, bonus_throwforce=8)

		playsound(src, 'sound/effects/singsuck.ogg', 40, TRUE)
