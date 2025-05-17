/*
CONTAINS:
SPACE CLEANER
MOP
SPONGES??
WET FLOOR SIGN
HANDHELD VACUUM
TRASH BAG

*/
/obj/item/spraybottle
	desc = "An unlabeled spray bottle."
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	name = "spray bottle"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = TABLEPASS|OPENCONTAINER|EXTRADELAY|SUPPRESSATTACK|ACCEPTS_MOUSEDROP_REAGENTS
	c_flags = ONBELT
	item_function_flags = OBVIOUS_INTERACTION_BAR
	var/rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	throwforce = 3
	w_class = W_CLASS_SMALL
	throw_speed = 2
	throw_range = 10
	tooltip_flags = REBUILD_DIST | REBUILD_SPECTRO
	move_triggered = 1
	var/initial_volume = 100

/obj/item/spraybottle/move_trigger(var/mob/M, kindof)
	if (..() && reagents)
		reagents.move_trigger(M, kindof)

/obj/item/spraybottle/pixelaction(atom/target, params, mob/user, reach)
	..()
	return FALSE // this needs to be here for ranged clicking I think, I hate it

/obj/item/spraybottle/New()
	..()
	create_reagents(initial_volume)


/obj/item/spraybottle/clown_flower
	name = "suspicious flower"
	icon = 'icons/obj/clothing/item_hats.dmi'
	icon_state = "flower_gard"
	item_state = "flower_gard"
	desc = "A delicate flower from the Gardenia shrub native to Earth, trimmed for you to wear. These white flowers are known for their strong and sweet floral scent. Wait, do these all have nozzles?"

/obj/item/spraybottle/detective
	name = "luminol bottle"
	desc = "A spray bottle labeled 'Luminol - Blood Detection Agent'. That's what those fancy detectives use to see blood!"
	rc_flags = RC_VISIBLE | RC_SPECTRO | RC_SCALE

	New()
		..()
		reagents.add_reagent("luminol", initial_volume)

/obj/item/spraybottle/cleaner
	name = "cleaner spray bottle"
	desc = "A spray bottle labeled 'Poo-b-Gone Space Cleaner'."

	New()
		..()
		reagents.add_reagent("cleaner", initial_volume)

/obj/item/spraybottle/cleaner/robot
	name = "cybernetic cleaner spray bottle"
	desc = "A cleaner spray bottle jury-rigged to synthesize space cleaner."
	icon_state = "cleaner_robot"
	var/refill_speed = 2.5
	initial_volume = 50
	disposing()
		..()
		processing_items.Remove(src)

	on_reagent_change()
		..()
		if (src.reagents.total_volume < src.reagents.maximum_volume)
			processing_items |= src

	process()
		..()
		if (src.reagents.total_volume < src.reagents.maximum_volume)
			src.reagents.add_reagent("cleaner", refill_speed)
		else
			processing_items.Remove(src)
		return 0

/obj/item/spraybottle/cleaner/robot/drone
	name = "cybernetic cleaning spray bottle"
	desc = "A small spray bottle that slowly synthesises space cleaner."
	icon_state = "cleaner_robot"
	initial_volume = 25
	refill_speed = 0.75

/obj/item/spraybottle/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	return

/obj/item/spraybottle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (A.storage)
		return
	if(istype(A,/obj/ability_button))
		return
	if (!isturf(user.loc)) // Hi, I'm hiding in a closet like a wuss while spraying people with death chems risk-free.
		return
	if (src.reagents.total_volume < 1)
		boutput(user, SPAN_NOTICE("The spray bottle is empty!"))
		return

	if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
		JOB_XP(user, "Janitor", 2)
	playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
	// Make sure we clean an item that was sprayed directly in case it is in contents
	if (!isturf(A.loc))
		if (istype(A, /obj/item))
			src.reagents.reaction(A, TOUCH, 5)
			src.reagents.remove_any(5)
			return
	var/obj/decal/D = new/obj/decal(get_turf(src))
	D.name = "chemicals"
	D.icon = 'icons/obj/chemical.dmi'
	D.icon_state = "chempuff"
	D.create_reagents(5) // cogwerks: lowered from 10 to 5
	src.reagents.trans_to(D, 5)
	var/log_reagents = log_reagents(src)
	var/travel_distance = clamp(GET_DIST(get_turf(src), A), 1, 3)
	SPAWN(0)
		for (var/i=0, i<travel_distance, i++)
			step_towards(D,A)
			var/turf/theTurf = get_turf(D)
			D.reagents.reaction(theTurf, react_volume=1)
			D.reagents.remove_any(1)
			for (var/atom/T in theTurf)
				if (istype(T, /obj/overlay/tile_effect) || T.invisibility >= INVIS_ALWAYS_ISH || D==T)
					continue
				D.reagents.reaction(T, react_volume=1)
				if (ismob(T))
					logTheThing(LOG_COMBAT, user, "'s spray hits [constructTarget(T,"combat")] [log_reagents] at [log_loc(user)].")
				D.reagents.remove_any(1)
			if (!D.reagents.total_volume)
				break
			sleep(0.3 SECONDS)
		qdel(D)
	var/turf/logTurf = get_turf(D)
	logTheThing(LOG_CHEMISTRY, user, "sprays [src] at [constructTarget(logTurf,"combat")] [log_reagents] at [log_loc(user)].")

	return

/obj/item/spraybottle/get_desc(dist, mob/user)
	if (dist > 2)
		return
	if (!reagents)
		return
	. = "<br>[SPAN_NOTICE("[reagents.get_description(user,rc_flags)]")]"
	return

// MOP

/obj/item/mop
	desc = "The world of janitorial paraphernalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3
	throwforce = 10
	throw_speed = 5
	throw_range = 10
	w_class = W_CLASS_NORMAL
	stamina_damage = 40
	stamina_cost = 15
	stamina_crit_chance = 10

/obj/item/mop/orange
	desc = "The world of janitorial paraphernalia wouldn't be complete without a mop. This one comes in orange!"
	name = "orange mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop_orange"
	item_state = "mop_orange"

/obj/item/mop/orange/battleworn
	desc = "It's been through some shit."
	name = "battleworn mop"
	rarity = 6
	force = 6
	quality = 80

	New()
		..()
		src.setProperty("impact", 2)
		src.setProperty("block", 20)
		src.setProperty("frenzy", 1)
		setItemSpecial(/datum/item_special/whirlwind)


/obj/item/mop/New()
	..()
	src.create_reagents(20)
	src.setItemSpecial(/datum/item_special/rangestab)
	START_TRACKING
	BLOCK_SETUP(BLOCK_ROD)

/obj/item/mop/disposing()
	. = ..()
	STOP_TRACKING

/obj/item/mop/examine()
	. = ..()
	if(reagents?.total_volume)
		. += SPAN_NOTICE("[src] is wet!")

/obj/item/mop/afterattack(atom/A, mob/user)// the main utility of all moppage and mopkind
	if (ismob(A))
		return
	if (CHECK_LIQUID_CLICK(A))
		var/turf/T = get_turf(A)
		A = T.active_liquid || A // if we target a turf with an active liquid, target the liquid. else target the initial target

	if ((src.reagents.total_volume < 1 || mopcount >= 9) && !istype(A, /obj/fluid))
		boutput(user, SPAN_NOTICE("Your mop is dry!"), group = "mop")
		return

	if (istype(A, /turf/simulated) || istype(A, /obj/decal/cleanable) || istype(A, /obj/fluid))
		actions.start(new/datum/action/bar/icon/mop_thing(src, A), user)

/obj/item/mop/proc/clean(atom/A, mob/user as mob)
	var/turf/T = get_turf(A)
	JOB_XP(user, "Janitor", 2)
	playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

	// Some people use mops for heat-delayed fireballs and stuff.
	// Mopping the floor with just water isn't of any interest, however (Convair880).
	if (src.reagents.total_volume && (!src.reagents.has_reagent("water") || (src.reagents.has_reagent("water") && length(src.reagents.reagent_list) > 1)))
		logTheThing(LOG_CHEMISTRY, user, "mops [T && isturf(T) ? "[T]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

	var/obj/fluid/target_fluid = T.active_liquid || A // we check for existing fluid here because we create a fluid below if there isn't one

	if (T)
		src.reagents.reaction(T, 1, 5)
		src.reagents.remove_any(5)
		mopcount++
		if (istype(T, /turf/simulated))
			var/turf/simulated/S = T
			if (S.wet < 1)
				S.wetify(1, rand(20, 35) SECONDS)

	if (istype(target_fluid))
		user.show_text("You soak up [target_fluid] with [src].", "blue", group = "mop")
		if (src.reagents && target_fluid.group)
			target_fluid.group.drain(target_fluid, 1, src)
		if (mopcount > 0)
			mopcount--
	T.clean_forensic()

	if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
		SPAWN(0.5 SECONDS)
			if (src?.reagents)
				src.reagents.clear_reagents()
				mopcount = 0

/obj/item/mop/attack_self(mob/user as mob)
	if (istype(user.loc, /obj/vehicle/segway))
		var/obj/vehicle/segway/S = user.loc
		if (S.joustingTool == src) // already raised as a lance, lower it
			user.visible_message("[user] lowers the jousting mop.", "You lower the mop. Everybody lets out a sigh of relief.")
			S.joustingTool = null
		else // Lances up!
			user.visible_message("[user] raises a mop as a lance!", "You raise the mop into jousting position.")
			S.joustingTool = src
	else
		if (isturf(user.loc))
			src.AfterAttack(user.loc, user)

/obj/item/mop/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (user.a_intent == INTENT_HELP)
		user.visible_message("[user] pokes [target] with \the [src].", "You poke [target] with \the [src].")
		return
	return ..()

// Its the old mop. It makes floors slippery
/obj/item/mop/old
	name = "antique mop"
	icon_state = "mop_old"
	item_state = "mop_old"
	desc = "This thing looks ancient, but it sure does get the job done!"

	afterattack(atom/A, mob/user)
		if (src.reagents.total_volume < 1 || mopcount >= 5)
			boutput(user, SPAN_NOTICE("Your mop is dry!"))
			return

		if (istype(A, /turf) || istype(A, /obj/decal/cleanable))
			user.visible_message(SPAN_ALERT("<B>[user] begins to clean [A]</B>"))
			var/turf/U = get_turf(A)

			if (do_after(user, 4 SECONDS))
				if (BOUNDS_DIST(A, user) > 0)
					user.show_text("You were interrupted.", "red")
					return
				user.show_text("You have finished mopping!", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				if (U && isturf(U))
					U.clean_forensic()
				else
					A.clean_forensic()
			else
				user.show_text("You were interrupted.", "red")
				return

			// Some people use mops for heat-delayed fireballs and stuff.
			// Mopping the floor with just water isn't of any interest, however (Convair880).
			if (src.reagents.total_volume && (!src.reagents.has_reagent("water") || (src.reagents.has_reagent("water") && length(src.reagents.reagent_list) > 1)))
				logTheThing(LOG_COMBAT, user, "mops [U && isturf(U) ? "[U]" : "[A]"] with chemicals [log_reagents(src)] at [log_loc(user)].")

			mopcount++

			if(istype(U,/turf/simulated))
				var/turf/simulated/T = U
				T.wetify(1, 75 SECONDS)

		if (mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN(0.5 SECONDS)
				if (src?.reagents)
					src.reagents.clear_reagents()
					mopcount = 0

		return

	clean(atom/A, mob/user as mob)
		var/turf/U = get_turf(A)
		JOB_XP(user, "Janitor", 2)
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

		if (U && isturf(U))
			src.reagents.remove_any(5)
			mopcount++

		if (mopcount >= 9) //Okay this stuff is an ugly hack and i feel bad about it.
			SPAWN(0.5 SECONDS)
				if (src?.reagents)
					src.reagents.clear_reagents()
					mopcount = 0

// SPONGES? idk

/datum/reagents/sponge
	update_total()
		..()
		var/obj/item/sponge/S = src.my_atom
		if (S)
			var/size = 1
			if (src.total_volume > 0)
				size += (src.total_volume / src.maximum_volume) * 0.6
			sponge_size(S, size)
		return 0

#define SPONGE_SOAK "Soak up"
#define SPONGE_DRY "Dry"
#define SPONGE_WIPE "Wipe down"
#define SPONGE_WRING "Wring out"
#define SPONGE_WET "Wet"
/obj/item/sponge
	name = "sponge"
	desc = "After careful analysis, you've come to the conclusion that the strange object is, in fact, a sponge."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "sponge"
	item_state = "sponge"
	force = 0
	stamina_damage = 5
	throwforce = 0
	w_class = W_CLASS_SMALL // gross why would you put a sponge in your pocket
	item_function_flags = OBVIOUS_INTERACTION_BAR

	var/hit_face_prob = 30 // MODULAR SPONGES
	var/spam_flag = 0 // people spammed snapping their fucking fingers, so this is probably necessary

/obj/item/sponge/New()
	..()
	// We use this instead of create_reagents because sponges need a special reagent holder to grow in size
	reagents = new/datum/reagents/sponge(50)
	reagents.my_atom = src
	processing_items |= src

/obj/item/sponge/disposing()
	processing_items -= src
	..()

/obj/item/sponge/examine()
	. = ..()
	if(reagents?.total_volume)
		. += SPAN_NOTICE("[src] is wet!")

/obj/item/sponge/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (user.a_intent == INTENT_HELP)
		return
	return ..()

/obj/item/sponge/attack_self(mob/user as mob)
	if(spam_flag)
		return
	. = ..()
	var/turf/location = get_turf(user)
	spam_flag = 1
	if (location)
		src.reagents.reaction(location, TOUCH, src.reagents.total_volume)
	//somepotato note: wtf is the thing below this
	//mbc note : yeah that's dumb! I moved spam_flag up top to prevent reagent duplication
	SPAWN(1 DECI SECOND) // to make sure the reagents actually react before they're cleared
	src.reagents.clear_reagents()
	SPAWN(1 SECOND)
	spam_flag = 0

/obj/item/sponge/attackby(obj/item/W, mob/user)
	if (istool(W, TOOL_CUTTING | TOOL_SNIPPING))
		if (src.loc == user && isrobot(user))
			boutput(user, "You can't quite angle your [W.name] into your [src.name].")
			return
		if (src.cant_drop || src.cant_self_remove)
			boutput(user, "You can't bring yourself to cut away your own personal [src.name]!")
			return
		user.visible_message(SPAN_NOTICE("[user] cuts [src] into the shape of... cheese?"))
		if(src.loc == user)
			user.u_equip(src)
		src.set_loc(user)
		var/obj/item/sponge/cheese/I = new /obj/item/sponge/cheese
		src.reagents.trans_to(I, reagents.total_volume)
		user.put_in_hand_or_drop(I)
		qdel(src)

/obj/item/sponge/throw_impact(atom/hit, datum/thrown_thing/thr)
	if(hit && ishuman(hit))
		if(prob(hit_face_prob))
			var/mob/living/carbon/human/DUDE = hit
			hit.visible_message(SPAN_ALERT("<b>[src] hits [DUDE] squarely in the face!</b>"))
			playsound(DUDE.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			if(DUDE.wear_mask || (DUDE.head && DUDE.head.c_flags & COVERSEYES))
				boutput(DUDE, SPAN_ALERT("Your headgear protects you! PHEW!!!"))
				SPAWN(1 DECI SECOND) src.reagents.clear_reagents()
				return
			src.reagents.reaction(DUDE, TOUCH)
			src.reagents.trans_to(DUDE, reagents.total_volume)
			SPAWN(1 DECI SECOND) src.reagents.clear_reagents()
	..()


/obj/item/sponge/process()
	if (!src.reagents) return
	if (src.reagents.total_volume >= src.reagents.maximum_volume) return
	if (isfloor(src.loc))
		var/turf/T = src.loc
		if (T.active_liquid && T.active_liquid.group)
			T.active_liquid.group.drain(T.active_liquid,1,src)
	else if (istype(src.loc, /turf/space/fluid))
		src.reagents.add_reagent(ocean_reagent_id,10)

/obj/item/sponge/proc/get_action_options(atom/target)
	if (CHECK_LIQUID_CLICK(target))
		var/turf/T = get_turf(target)
		if (T.active_liquid)
			return list(SPONGE_SOAK) // only soak if we click a fluid

	. = list()
	if (CHECK_LIQUID_CLICK(target))
		var/turf/simulated/T = get_turf(target)
		if (T.reagents?.total_volume)
			. |= SPONGE_SOAK
		else if (T.wet)
			. |= SPONGE_DRY
	if (src.reagents.total_volume)
		. |= SPONGE_WIPE
		if ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink) || istype(target, /obj/mopbucket))
			. |= SPONGE_WRING
	if (src.reagents.total_volume < src.reagents.maximum_volume && ((istype(target, /obj/item/reagent_containers/glass) && target.is_open_container()) || istype(target, /obj/machinery/bathtub) || istype(target, /obj/submachine/chef_sink)) || istype(target, /obj/mopbucket))
		if (istype(target, /obj/submachine/chef_sink) || (target.reagents && target.reagents.total_volume))
			. |= SPONGE_WET

/obj/item/sponge/afterattack(atom/target, mob/user)
	if (!src.reagents)
		return ..()

	var/list/choices = src.get_action_options(target)

	if (!length(choices))
		boutput(user, SPAN_NOTICE("You can't think of anything to do with [src]."))
		return

	var/selection
	if (length(choices) == 1) // at spy's request the sponge will default to the only thing it can do ARE YOU HAPPY NOW SPY
		selection = choices[1]
	else
		selection = input(user, "What do you want to do with [src]?", "Selection") as null|anything in choices
	if (isnull(selection) || user.equipped() != src || BOUNDS_DIST(user, target) > 0)
		return

	switch (selection)
		if (SPONGE_SOAK)
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				user.show_text("[src] is full! Wring it out first.", "blue")
				return

			var/turf/T = get_turf(target)
			var/obj/fluid/F

			if (T.active_liquid)
				F = T.active_liquid

			if (F)
				if (F.group)
					F.group.drain(F,1,src)
				else
					F.removed()
			else
				target.reagents.trans_to(src, 15)

			JOB_XP(user, "Janitor", 1)

		if (SPONGE_DRY)
			if (!istype(target, /turf/simulated)) // really, how?? :I
				return
			var/turf/simulated/T = target
			JOB_XP(user, "Janitor", 1)
			src.reagents.add_reagent("water", rand(5,15))
			T.dryify()

		if (SPONGE_WIPE)
			if (src.reagents.has_reagent("water"))
				target.clean_forensic()
			src.reagents.reaction(target, TOUCH, 5)
			src.reagents.remove_any(5)
			JOB_XP(user, "Janitor", 3)
			if (target.reagents)
				target.reagents.trans_to(src, 5)
			target.remove_filter(list("paint_color", "paint_pattern"))
			playsound(src, 'sound/items/sponge.ogg', 20, TRUE)
			if (ismob(target))
				animate_smush(target)

		if (SPONGE_WRING)
			if (target.reagents)
				src.reagents.trans_to(target, src.reagents.total_volume)
			else if(istype(target, /obj/submachine/chef_sink))
				src.reagents.clear_reagents()

		if (SPONGE_WET)
			var/fill_amt = (src.reagents.maximum_volume - src.reagents.total_volume)
			if (target.reagents)
				target.reagents.trans_to(src, fill_amt)
			else
				src.reagents.add_reagent("water", fill_amt)
				JOB_XP(user, "Janitor", 1)
/obj/item/sponge/ghostdronesafe
	name = "Integrated sponge"
	desc = "A cleaning utensil with an associated drainage system to prevent excess fluids from dripping when wrung out."

/obj/item/sponge/ghostdronesafe/attack_self(mob/user as mob)
	if (ON_COOLDOWN(user, "ghostdrone sponge wringing", 5 SECONDS))// Wtihout the cooldown, this is stupid powerful
		boutput(user, SPAN_NOTICE(" The [src] is still processing fluids, please wait!"))
		return
	user.visible_message(SPAN_NOTICE("[user] drains the [src]."))
	src.reagents.clear_reagents()

/obj/item/sponge/cheese
	name = "cheese-shaped sponge"
	desc = "Wait a minute! This isn't cheese..."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "sponge-cheese"
	item_state = "sponge"

#undef SPONGE_SOAK
#undef SPONGE_DRY
#undef SPONGE_WIPE
#undef SPONGE_WRING
#undef SPONGE_WET




/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "caution"
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	stamina_damage = 15
	stamina_cost = 4
	stamina_crit_chance = 10

	New()
		..()
		BLOCK_SETUP(BLOCK_SOFT)

	dropped()
		. = ..()
		JOB_XP(usr, "Janitor", 2)
		return

	attackby(obj/item/W, mob/user, params)
		if(iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/anchor_or_unanchor(src, W, duration=2 SECONDS), user)
			return
		. = ..()

/obj/item/caution/traitor
	item_function_flags = IMMUNE_TO_ACID
	var/obj/item/reagent_containers/payload

	New()
		. = ..()
		payload = new /obj/item/reagent_containers/glass/bucket/red(src)
		payload.reagents.add_reagent("invislube", payload.reagents.maximum_volume)
		src.create_reagents(1)
		src.AddComponent(/datum/component/proximity)

	attackby(obj/item/W, mob/user, params)
		var/mob/living/carbon/human/H = user
		if(istype(W, /obj/item/reagent_containers) && istype(H) && istype(H.gloves, /obj/item/clothing/gloves/long))
			boutput(user, SPAN_NOTICE("You stealthily replace the hidden [payload.name] with [W]."))
			user.drop_item(W)
			src.payload.set_loc(src.loc)
			user.put_in_hand_or_drop(src.payload)
			src.payload = W
			W.set_loc(src)
			return
		else if (isscrewingtool(W))
			user.show_message("You [src.anchored ? "un" : ""]screw [src] [src.anchored ? "from" : "to"] the floor.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.anchored = !src.anchored
			return
		. = ..()

	EnteredProximity(atom/movable/AM)
		if(iscarbon(AM) && isturf(src.loc) && !ON_COOLDOWN(src, "spray", 1.5 SECONDS) && src.payload?.reagents)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if(istype(H.shoes, /obj/item/clothing/shoes/galoshes))
					return
			var/turf/T = AM.loc
			src.payload.reagents.trans_to(src, 1)
			src.reagents.reaction(T)
			src.reagents.clear_reagents()
		else
			. = ..()


/obj/item/holoemitter
	name = "Holo-emitter"
	desc = "A compact holo emitter pre-loaded with various holographic signs. Fits into pockets and boxes."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "emitter-off"
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	throw_pixel = 0
	throw_spin = 0
	var/currentSelection = "wet"
	var/ownerKey = null
	anchored = UNANCHORED

	attack_hand(mob/user)
		if(user.key != ownerKey && ownerKey != null)
			boutput(user, "<span style='color: red; font-weight: bold'>The [src.name] makes a grumpy buzzing sound and delivers a small electric shock! You drop it.</span>")
			return
		..()

	pull(mob/user)
		if (!istype(user))
			return
		if(user.key != ownerKey && ownerKey != null)
			boutput(user, "<span style='color: red; font-weight: bold'>The [src.name] makes a grumpy buzzing sound and delivers a small electric shock! You drop it.</span>")
			return
		return ..()

	attack_self(mob/user as mob)
		switch(currentSelection)
			if("wet")
				currentSelection = "cone"
			if("cone")
				currentSelection = "spray"
			if("spray")
				currentSelection = "text"
			if("text")
				currentSelection = "wet"
		boutput(user, "Set to '[currentSelection]'")

	set_loc(var/atom/movable/_loc)
		if(_loc)
			if(!isturf(src.loc) && isturf(_loc)) //From inside somewhere to outside on floor
				icon_state = "emitter-on"
				var/obj/holosign/H = new/obj/holosign(_loc)
				H.icon_state = "holo-[currentSelection]"
				attached_objs = list(H)
				pixel_y = 0
			else if(isturf(src.loc) && !isturf(_loc)) //From floor into something
				if(isobj(_loc) && isturf(_loc.loc))
					_loc = src.loc
					pixel_y = 0
				else
					icon_state = "emitter-off"
					pixel_y = 16
					if(attached_objs)
						for(var/atom/A in attached_objs)
							attached_objs -= A
							qdel(A)
		. = ..(_loc)
		pixel_x = 0


	dropped()
		. = ..()
		JOB_XP(usr, "Janitor", 2)
		return

/obj/holosign
	desc = "..."
	name = "Hologram"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holo-wet"
	alpha = 230
	pixel_y = 16
	anchored = ANCHORED
	layer = EFFECTS_LAYER_BASE
	var/datum/light/light
	var/obj/holoparticles/holoparticles

	New(var/_loc)
		set_loc(_loc)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.5, 0.6, 0.94)
		light.set_brightness(0.7)
		light.enable()

		SPAWN(1 DECI SECOND)
			animate(src, alpha=180, color="#DDDDDD", time=7, loop=-1)
			animate(alpha=230, color="#FFFFFF", time=1)
			animate(src, pixel_y=10, time=15, flags=ANIMATION_PARALLEL, easing=SINE_EASING, loop=-1)
			animate(pixel_y=16, easing=SINE_EASING, time=15)

		holoparticles = new/obj/holoparticles(src.loc)
		attached_objs = list(holoparticles)
		..(_loc)

	disposing()
		if(holoparticles)
			holoparticles.invisibility = INVIS_ALWAYS
			qdel(holoparticles)
			holoparticles = null
		..()

/obj/holoparticles
	desc = ""
	name = ""
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holoparticles"
	anchored = ANCHORED
	alpha= 230
	pixel_y = 14
	layer = EFFECTS_LAYER_BASE


// handheld vacuum

TYPEINFO(/obj/item/handheld_vacuum)
	mats = list("bamboo" = 3,
				"metal" = 10)
/obj/item/handheld_vacuum
	name = "handheld vacuum"
	desc = "Sucks smoke. Sucks small items. Sucks just in general!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "handvac"
	health = 7
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | SUPPRESSATTACK
	item_function_flags = USE_SPECIALS_ON_ALL_INTENTS
	var/obj/item/reagent_containers/glass/bucket/bucket
	var/obj/item/trash_bag/trashbag

	New()
		..()
		src.setItemSpecial(/datum/item_special/suck)
		src.bucket = new(src)
		src.trashbag = new(src)

	get_desc(dist, mob/user)
		. = ..()
		if(src.trashbag)
			. += "<br>It contains \the [src.trashbag]. [src.trashbag.get_desc(dist, user)]"
		else
			. += "<br>The trashbag is missing."
		if(src.bucket)
			. += "<br>It contains \the [src.bucket]. [src.bucket.get_desc(dist, user)]"
		else
			. += "<br>The bucket is missing."

	attack_self(mob/user)
		. = ..()
		var/list/removed_things = list()
		if(src.trashbag)
			removed_things += src.trashbag
			src.trashbag.set_loc(user.loc)
			user.put_in_hand_or_drop(src.trashbag)
			src.trashbag = null
		if(src.bucket)
			removed_things += src.bucket
			src.bucket.set_loc(user.loc)
			user.put_in_hand_or_drop(src.bucket)
			src.bucket = null
		if(length(removed_things) == 0)
			boutput(user, SPAN_NOTICE("\The [src] has no bucket nor trashbag."))
		else if(length(removed_things) == 1)
			boutput(user, SPAN_NOTICE("You remove \the [removed_things[1]] from \the [src]"))
		else
			boutput(user, SPAN_NOTICE("You remove \the [removed_things[1]] and \the [removed_things[2]] from \the [src]"))
		src.tooltip_rebuild = 1

	attack_hand(mob/user)
		if(!(src.loc == user && user.find_in_hand(src)))
			. = ..()
		else if(src.trashbag)
			src.trashbag.set_loc(user.loc)
			user.put_in_hand_or_drop(src.trashbag)
			boutput(user, SPAN_NOTICE("You remove \the [src.trashbag] from \the [src]"))
			src.trashbag = null
		else if(src.bucket)
			src.bucket.set_loc(user.loc)
			user.put_in_hand_or_drop(src.bucket)
			boutput(user, SPAN_NOTICE("You remove \the [src.bucket] from \the [src]"))
			src.bucket = null
		else
			boutput(user, SPAN_ALERT("\The [src] has neither trashbag nor bucket."))

	afterattack(atom/target, mob/user, reach, params)
		if(!isturf(user.loc))
			return
		if(ismob(target))
			special.pixelaction(target, params, user, reach) // a hack to let people disarm when clicking at close range
		else if(istype(target, /obj/storage) && src.trashbag)
			var/obj/storage/storage = target
			if (storage.secure && storage.locked)
				return // storage provides user feedback
			for(var/obj/item/I in src.trashbag.storage.get_contents())
				I.set_loc(storage)
			boutput(user, SPAN_NOTICE("You empty \the [src] into \the [target]."))
			src.tooltip_rebuild = 1
			return
		else if(istype(target, /obj/machinery/disposal))
			var/obj/machinery/disposal/disposal = target
			if(src.trashbag)
				for(var/obj/item/I in src.trashbag.storage.get_contents())
					I.set_loc(disposal)
				boutput(user, SPAN_NOTICE("You empty \the [src] into \the [target]."))
				src.tooltip_rebuild = 1
				disposal.update()
				return
		else if(istype(target, /obj/submachine/chef_sink))
			if(src.bucket.reagents.total_volume > 0)
				boutput(user, SPAN_NOTICE("You empty \the [src] into \the [target]."))
				src.bucket.reagents.clear_reagents()
				src.tooltip_rebuild = 1
			else
				boutput(user, SPAN_NOTICE("[src]'s bucket is empty."))
			return
		else if(istype(target, /obj/mopbucket) && src.bucket)
			if(src.bucket.reagents.total_volume > 0)
				boutput(user, SPAN_NOTICE("You empty \the [src] into \the [target]."))
				src.bucket.transfer_all_reagents(target, user)
				src.tooltip_rebuild = 1
			else
				boutput(user, SPAN_NOTICE("[src]'s bucket is empty."))
			return
		if(ON_COOLDOWN(src, "suck", 0.3 SECONDS))
			return
		var/turf/T = get_turf(target)
		if(isnull(T)) // fluids getting disposed or something????
			return
		new/obj/effect/suck(T, get_dir(T, user))
		if(src.suck(T, user))
			playsound(T, 'sound/effects/suck.ogg', 20, TRUE, 0, 1.5)
		else
			playsound(T, 'sound/effects/brrp.ogg', 20, TRUE, 0, 0.8)

	proc/suck(turf/T, mob/user)
		. = TRUE
		var/success = FALSE
		if(T.active_airborne_liquid && T.active_airborne_liquid.group)
			if(isnull(src.bucket))
				boutput(user, SPAN_ALERT("\The [src] tries to suck up \the [T.active_airborne_liquid] but has no bucket!"))
				. = FALSE
			else if(src.bucket.reagents.is_full())
				boutput(user, SPAN_ALERT("\The [src] tries to suck up \the [T.active_airborne_liquid] but its bucket is full!"))
				. = FALSE
			else
				var/obj/fluid/airborne/F = T.active_airborne_liquid
				F.group.reagents.skip_next_update = TRUE
				F.group.update_amt_per_tile()
				var/amt = min(F.group.amt_per_tile, src.bucket.reagents.maximum_volume - src.bucket.reagents.total_volume)
				F.group.drain(F, amt / max(1, F.group.amt_per_tile), src.bucket)
				if(src.bucket.reagents.is_full())
					boutput(user, SPAN_NOTICE("[src]'s [src.bucket] is now full."))
				success = TRUE

		var/obj/reagent_dispensers/cleanable/ants/ants = locate(/obj/reagent_dispensers/cleanable/ants) in T
		if(ants)
			if(isnull(src.bucket))
				boutput(user, SPAN_ALERT("\The [src] tries to suck up the ants but has no bucket!"))
				. = FALSE
			else if(src.bucket.reagents.is_full())
				boutput(user, SPAN_ALERT("\The [src] tries to suck up the ants but its bucket is full!"))
				. = FALSE
			else
				qdel(ants)
				src.bucket.reagents.add_reagent("ants", 5)
				success = TRUE

		var/list/obj/item/items_to_suck = list()
		for(var/obj/item/I in T)
			if((I.w_class <= W_CLASS_TINY || istype(I, /obj/item/raw_material/shard)) && !I.anchored)
				items_to_suck += I
		if(length(items_to_suck))
			var/item_desc = length(items_to_suck) > 1 ? "some items" : "\the [items_to_suck[1]]"
			if(isnull(src.trashbag))
				boutput(user, SPAN_ALERT("\The [src] tries to suck up [item_desc] but has no trashbag!"))
				. = FALSE
			else if(src.trashbag.storage.is_full())
				boutput(user, SPAN_ALERT("\The [src] tries to suck up [item_desc] but its [src.trashbag] is full!"))
				. = FALSE
			else
				for(var/obj/item/I as anything in items_to_suck)
					if(!I.anchored)
						I.set_loc(get_turf(user))
				success = TRUE
				SPAWN(0.5 SECONDS)
					for(var/obj/item/I as anything in items_to_suck)
						src.trashbag.storage.add_contents_safe(I)
						if(src.trashbag.storage.is_full())
							boutput(user, SPAN_NOTICE("[src]'s [src.trashbag] is now full."))
							break

		src.tooltip_rebuild = 1
		. |= success

	attackby(obj/item/W, mob/user, params, is_special=0)
		if(istype(W, /obj/item/trash_bag))
			if(isnull(src.trashbag))
				boutput(user, SPAN_NOTICE("You insert \the [W] into \the [src]."))
				src.trashbag = W
				src.trashbag.set_loc(src)
			else
				boutput(user, SPAN_NOTICE("You swap the trash bags."))
				var/obj/item/old_trashbag = src.trashbag
				src.trashbag = W
				src.trashbag.set_loc(src)
				old_trashbag.set_loc(user.loc)
				user.put_in_hand_or_drop(old_trashbag)
			user.u_equip(W)
			W.dropped(user)
			src.tooltip_rebuild = 1
		else if(istype(W, /obj/item/reagent_containers/glass/bucket))
			if(isnull(src.bucket))
				boutput(user, SPAN_NOTICE("You insert \the [W] into \the [src]."))
				src.bucket = W
				src.bucket.set_loc(src)
			else
				boutput(user, SPAN_NOTICE("You swap the buckets."))
				var/obj/item/old_bucket = src.bucket
				src.bucket = W
				src.bucket.set_loc(src)
				old_bucket.set_loc(user.loc)
				user.put_in_hand_or_drop(old_bucket)
			user.u_equip(W)
			W.dropped(user)
			src.tooltip_rebuild = 1
		else
			. = ..()

TYPEINFO(/obj/item/handheld_vacuum/overcharged)
	mats = list("neutronium" = 3,
				"metal" = 10)
/obj/item/handheld_vacuum/overcharged
	name = "overcharged handheld vacuum"
	color = list(0,0,1, 0,1,0, 1,0,0)
	New()
		..()
		var/datum/item_special/suck/suck = src.special
		suck.suck_mobs = TRUE
		suck.range = 10
		suck.suck_in_range = 3
		suck.throw_range = 10
		suck.throw_speed = 1
		suck.moveDelayDuration = 5
		suck.moveDelay = 4

/datum/item_special/suck
	cooldown = 30
	staminaCost = 10
	moveDelay = 8
	moveDelayDuration = 10
	var/range = 3
	var/suck_in_range = 1
	var/throw_range = 2
	var/throw_speed = 0.3
	var/suck_mobs = FALSE

	image = "suck"
	name = "Suck"
	desc = "Suck stuff towards you in a 3 tile range."

	pixelaction(atom/target, params, mob/user, reach)
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user)) return
		if(!isturf(user.loc)) return
		var/turf/target_turf = get_turf(target)
		var/turf/master_turf = get_turf(master)
		if(params["left"] && master && (BOUNDS_DIST(master_turf, target_turf) > 0 || ismob(target) && target != user))
			if(ON_COOLDOWN(master, "suck", src.cooldown)) return
			preUse(user)
			var/direction = get_dir_pixel(user, target, params)

			var/list/turf_list = list()
			var/turf/last = get_turf(master)
			var/hit_target = FALSE
			for(var/i = 1 to src.range)
				if(last == target)
					hit_target = TRUE
				var/turf/current
				if(hit_target)
					current = get_step(last, direction)
				else
					current = get_step_towards(last, target)
				turf_list += current
				last = current

			last = get_turf(master)
			var/sucking_in = src.suck_in_range
			for(var/turf/T in turf_list)
				if(T.density)
					break
				if(sucking_in && istype(master, /obj/item/handheld_vacuum))
					sucking_in--
					var/obj/item/handheld_vacuum/vacuum = master
					vacuum.suck(T, user)
				var/end_now
				for(var/atom/movable/A in T)
					if(A.density && !istype(A, /obj/table))
						end_now = TRUE
					if(!A.anchored)
						if(!ismob(A) || src.suck_mobs)
							A.throw_at(T == turf_list[1] ? get_turf(master) : turf_list[1], src.throw_range, src.throw_speed)
							if(ismob(A))
								var/mob/M = A
								M.changeStatus("knockdown", 0.9 SECONDS)
								M.force_laydown_standup()
								boutput(M, SPAN_ALERT("You are pulled by the force of [user]'s [master]."))
						else
							var/mob/M = A
							if(!issilicon(M) && M.equipped() && prob(25))
								var/obj/item/I = M.equipped()
								if(!I.cant_drop)
									I.set_loc(M.loc)
									M.u_equip(I)
									I.dropped(user)
									boutput(M, SPAN_ALERT("Your [I] is pulled from your hands by the force of [user]'s [master]."))
				new/obj/effect/suck(T, get_dir(T, last))
				last = T
				if(end_now)
					break

			afterUse(user)
			playsound(master, 'sound/effects/suck.ogg', 40, TRUE, 0, 0.5)

/obj/effect/suck
	anchored = ANCHORED_ALWAYS
	mouse_opacity = FALSE
	plane = PLANE_NOSHADOW_BELOW
	icon = 'icons/effects/effects.dmi'
	icon_state = "push"

	New(atom/loc, dir)
		..()
		src.dir = dir
		src.alpha = 0
		animate(src, alpha=255, time=0.21 SECONDS, easing=SINE_EASING)
		animate(alpha=0, time=0.21 SECONDS, easing=SINE_EASING)
		SPAWN(0.5 SECONDS)
			qdel(src)


/obj/item/trash_bag
	name = "trash bag"
	desc = "A flimsy bag for filling with things that are no longer wanted."
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'	// Avoid icon duplication with the clothing
	icon_state = "trashbag-f"
	item_state = "trashbag"
	w_class = W_CLASS_TINY
	rand_pos = TRUE
	flags = TABLEPASS | NOSPLASH
	tooltip_flags = REBUILD_DIST
	var/base_state = "trashbag"
	var/clothing_type = /obj/item/clothing/under/gimmick/trashsinglet

	New()
		..()
		src.create_storage(/datum/storage/no_hud, prevent_holding = list(/obj/item/trash_bag), max_wclass = W_CLASS_NORMAL, slots = 20,
			params = list("use_inventory_counter" = TRUE, "variable_weight" = TRUE, "max_weight" = 20))

	attackby(obj/item/I, mob/user)
		if (issnippingtool(I))
			var/action = tgui_input_list(user, "What do you want to do with [src]?", "Trash Bag", list("Cut into an outfit", "Add to contents"))
			if (!action)
				return
			if (action == "Cut into an outfit")
				boutput(user, "You begin cutting up [src].")
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				else
					var/obj/item/clothing/under/gimmick/trashsinglet/trash_outfit = new clothing_type(get_turf(src))
					playsound(src.loc, 'sound/items/Scissor.ogg', 100, 1)
					user.u_equip(src)
					for(var/obj/item/contents as anything in src.storage.get_contents())
						src.storage.transfer_stored_item(contents, trash_outfit, TRUE)
					usr.put_in_hand_or_drop(trash_outfit)
					user.visible_message(SPAN_NOTICE("[user] cuts their [src] into an outfit of questionably fashionable."))
					qdel(src)
					return
		..()

	update_icon(mob/user)
		if (!src.storage || !length(src.storage.get_contents()))
			src.icon_state = src.base_state + "-f"

		else if (length(src.storage.get_contents()))
			src.icon_state = src.base_state

		if (ismob(user))
			user.update_inhands()

	get_desc(dist)
		..()
		if (dist > 2)
			return
		if (src.storage.is_full())
			. += "It's totally full."
		else
			. += "There's still some room to hold something."

/obj/item/trash_bag/biohazard
	name = "hazardous waste bag"
	desc = "A flimsy bag for filling with things that are no longer wanted and are also covered in blood or puke or other gross biohazards. It's not any sturdier than a normal trash bag, though, so be careful with the needles!"
	icon_state = "biobag-f"
	item_state = "biobag"
	base_state = "biobag"
	clothing_type = /obj/item/clothing/under/gimmick/trashsinglet/biohazard

/obj/item/gun/sprayer
	name = "\improper WA-V3 Cleaning Device" //name and desc suggested by tekotheteapot
	desc = "The Wide Area V3 Cleaning Device, holy grail of space janitorial hardware.<br>\
		Must ONLY be used with Nanotrasen™ licensed WA-V3 back tanks."
	icon_state = "sprayer"
	item_state = "janitor_sprayer"
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	shoot_delay = 2 SECONDS
	recoil_enabled = FALSE
	click_sound = 'sound/effects/tinyhiss.ogg'
	click_msg = "*hisss*"
	contraband = 0 //lol
	var/clogged = FALSE

	New()
		. = ..()
		src.set_current_projectile(new /datum/projectile/special/shotchem/wave)
		add_firemode(null, current_projectile)
		add_firemode(null, new /datum/projectile/special/shotchem/wave/wide)
		add_firemode(null, new /datum/projectile/special/shotchem/wave/single)
		src.UpdateIcon()

	get_help_message(dist, mob/user)
		if (src.clogged)
			return "Can be unclogged in a <b>sink</b>."

	pickup(mob/user)
		..()
		src.connect(user)

	proc/connect(user)
		if (src.get_tank(user) && !src.GetComponent(/datum/component/reagent_overlay/other_target))
			src.AddComponent(/datum/component/reagent_overlay/other_target, src.icon, "sprayer", reagent_overlay_states = 4, reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR, queue_updates = TRUE, target = src.get_tank(user))

	dropped(mob/user)
		..()
		src.disconnect()

	proc/disconnect()
		src.RemoveComponentsOfType(/datum/component/reagent_overlay/other_target)

	proc/get_tank(mob/user)
		RETURN_TYPE(/obj/item/reagent_containers/glass/backtank)
		if (!user)
			user = src.loc
		if (!ismob(user))
			return null
		if (istype(user.back, /obj/item/reagent_containers/glass/backtank))
			return user.back
		return null

	update_icon(...)
		switch(src.current_firemode_num)
			if (1)
				src.icon_state = "[initial(src.icon_state)]-normal"
			if (2)
				src.icon_state = "[initial(src.icon_state)]-wide"
			if (3)
				src.icon_state = "[initial(src.icon_state)]-narrow"

	set_current_projectile(datum/projectile/newProj)
		. = ..()
		src.UpdateIcon()

	attack_self(mob/user)
		. = ..()
		playsound(src.loc, 'sound/machines/button.ogg', 40, 1, -10, 1.3)

	canshoot(mob/user)
		return src.get_tank()?.reagents.total_volume >= src.current_projectile.cost && !src.clogged

	shoot_point_blank(atom/target, mob/user, second_shot) //point blanking this doesn't really make sense
		if (target == user)
			return
		shoot(target, get_turf(user), user, 0, 0)

	process_ammo(mob/user)
		if (!src.canshoot(user))
			boutput(user, SPAN_ALERT("[src] makes a sad little pffft noise."))
			return FALSE
		var/obj/item/reagent_containers/glass/backtank/tank = src.get_tank()
		if (tank.reagents.has_any(global.extinguisher_blacklist_clog))
			boutput(user, SPAN_ALERT("[src] sputters and clogs up!"))
			src.clogged = TRUE
			return FALSE
		if(tank.reagents.has_reagent("water") || tank.reagents.has_reagent("cleaner"))
			JOB_XP(user, "Janitor", 2)
		return TRUE

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target)
		if(!..())
			return
		SPAWN(1.3 SECONDS)
			playsound(start, 'sound/machines/windup.ogg', 80, FALSE, -10)
			eat_twitch(src)
			sleep(0.4 SECONDS)
			eat_twitch(src)

	alter_projectile(obj/projectile/P)
		if(!P.reagents)
			P.create_reagents(src.current_projectile.cost)
		src.get_tank().reagents.trans_to_direct(P.reagents, src.current_projectile.cost)

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.firemodes) //we're already emagged
			return
		boutput(user, SPAN_ALERT("You short out the pressure lock on [src]!"))
		src.set_current_projectile(new /datum/projectile/special/shotchem/wave/wide/emagged)
		src.firemodes = null

//Why are all the sane reagent container behaviour on /glass?!!!?
/obj/item/reagent_containers/glass/backtank
	name = "\improper WA-V3 back tank"
	desc = "A little label on the side reads \"not for use with corrosive substances\"."
	icon = 'icons/obj/janitor.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "janitor_tank"
	item_state = "janitor_tank"
	initial_volume = 500
	initial_reagents = list("cleaner" = 500)
	incompatible_with_chem_dispensers = TRUE
	shatter_immune = TRUE
	w_class = W_CLASS_BULKY
	c_flags = ONBACK
	wear_layer = MOB_BACK_LAYER + 0.3
	fluid_overlay_states = 0 //we want to add our own component, thanks
	HELP_MESSAGE_OVERRIDE("You can use a <b>wrench</b> to empty the <i>high pressure</i> tank.")

	New(loc, new_initial_reagents)
		..()

		src.AddComponent(/datum/component/reagent_overlay/worn_overlay/janitor_tank, src.icon, src.icon_state,\
			reagent_overlay_states = 6, reagent_overlay_scaling = RC_REAGENT_OVERLAY_SCALING_LINEAR, queue_updates = TRUE,\
			worn_overlay_icon = src.wear_image_icon, worn_overlay_icon_state = src.icon_state, worn_overlay_states = 1)

		src.create_storage(/datum/storage, max_wclass = W_CLASS_SMALL, slots = 3, opens_if_worn = TRUE)

	is_open_container(input)
		return input

	on_reagent_change(add)
		..()
		if (src.reagents.has_any(global.extinguisher_blacklist_melt) && !src.hasStatus("acid"))
			src.setStatus("acid", 5 SECONDS)

	equipped(mob/user, slot)
		. = ..()
		var/obj/item/gun/sprayer/sprayer = user.find_type_in_hand(/obj/item/gun/sprayer)
		sprayer?.connect(user)

	unequipped(mob/user)
		. = ..()
		var/obj/item/gun/sprayer/sprayer = user.find_type_in_hand(/obj/item/gun/sprayer)
		sprayer?.disconnect(user)

	attackby(obj/item/W, mob/user, params)
		//stupid hack to make reagents transfer before storage datums yoink the item
		//blame the entirety of reagent transfer code being stuffed into two copy-pasted afterattack stacks
		if (W.is_open_container(FALSE) && W.reagents?.total_volume > 0)
			return
		if (iswrenchingtool(W))
			if (src.cant_drop)
				return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			boutput(user, SPAN_NOTICE("You loosen the pressure retaining bolts on [src]..."))
			src.cant_drop = TRUE //I want a pause for dramatic effect goddamnit
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, src)
			SPAWN(0.5 SECONDS)
				src.cant_drop = FALSE
				REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, src)
				if (!src.reagents.total_volume)
					boutput(user, SPAN_NOTICE("...but nothing happens."))
					return
				if (src.reagents.total_volume > 100)
					playsound(src.loc, 'sound/effects/bigsplash.ogg', 50, 1)
					user.changeStatus("knockdown", 5 SECONDS)
				boutput(user, SPAN_ALERT("You get splashed in the face by the pressurized contents of [src]!"))
				src.reagents.reaction(user, TOUCH, src.reagents.total_volume/2, FALSE)
				src.reagents.reaction(get_turf(src), TOUCH, 0, TRUE)
				src.reagents.clear_reagents()
			return
		. = ..()

/datum/projectile/special/shotchem/wave
	name = "chemicals"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "tsunami"
	cost = 20
	sname = "wave"
	projectile_speed = 16
	shot_sound = 'sound/effects/bigwave.ogg'
	shot_volume = 60 //this is a loud sound
	can_spawn_fluid = TRUE //so if we shoot water it will make a puddle, but cleaner is *clean*!
	goes_through_mobs = TRUE
	smashes_glasses = FALSE
	/// How far to either side of the central path does the projectile extend
	var/size = 1
	/// Percentage of total reagents applied to each turf affected
	var/chem_pct_app_tile = 1/12
	/// What type of things can we push around?
	var/push_type = /obj/item

	cross_turf(obj/projectile/O, turf/T)
		if (QDELETED(O))
			return
		var/dir = angle2dir(O.angle)
		//clean the center turf
		src.turf_effect(O, T, dir)
		if (QDELETED(O))
			return
		if (size <= 0)
			return
		for (var/sign in list(-1, 1))
			for (var/i in 1 to size)
				var/turf/side_turf
				side_turf = get_steps(T, turn(dir, 90), i * sign)
				//clean regardless
				src.turf_effect(O, side_turf, dir)
				if (QDELETED(O))
					return
				//now check collision
				var/turf/prev_turf = get_steps(T, turn(dir, 90), (i - 1) * sign)
				if (!jpsTurfPassable(side_turf, prev_turf, O))
					//we hit a wall, discard any reagents we *would* have spent on the missed tiles
					O.reagents.remove_any((size - i) * src.chem_pct_app_tile * O.reagents.maximum_volume)
					break
		//if we're going diagonally, clean the cardinally adjacent tiles too to avoid skipping
		if (!(dir in cardinal))
			for (var/side_dir in cardinal)
				var/turf/side_turf = get_step(T, side_dir)
				src.turf_effect(O, side_turf, dir)
				if (QDELETED(O))
					return

	turf_effect(obj/projectile/O, turf/T, dir)
		if (T in O.special_data["visited"])
			return
		..(O, T)
		src.push_stuff(O, T, dir)
		if (QDELETED(O))
			return
		LAZYLISTADD(O.special_data["visited"], T)

	proc/push_stuff(obj/projectile/O, turf/T, dir)
		var/count = 0
		for (var/atom/movable/AM in T)
			if (AM == O.shooter)
				continue
			if (ismob(AM))
				var/mob/M = AM
				M.lastgasp() //heeheehoohoo
				if (M.get_oxygen_deprivation() == 0)
					M.take_oxygen_deprivation(5)
			if (!istype(AM, src.push_type))
				continue
			if (!AM.anchored)
				step(AM, dir)
			count++
			if (count > 50) //panic clause for TOO MUCH STUFF
				return

	on_launch(obj/projectile/O)
		. = ..()
		O.alpha = 175
		O.special_data["chem_pct_app_tile"] = src.chem_pct_app_tile

/datum/projectile/special/shotchem/wave/single
	sname = "narrow"
	cost = 10
	size = 0
	scale = 1/3
	chem_pct_app_tile = 0.1
	projectile_speed = 24
	shot_pitch = 1.1
	shot_volume = 45

/datum/projectile/special/shotchem/wave/wide
	sname = "wide"
	cost = 30
	size = 2
	scale = 5/3
	chem_pct_app_tile = 0.05
	projectile_speed = 8
	push_type = /atom/movable //hehehe
	shot_pitch = 0.9

/datum/projectile/special/shotchem/wave/wide/emagged
	projectile_speed = 24
	shot_pitch = 0.7

	post_setup(obj/projectile/O)
		. = ..()
		var/turf/throw_target = get_steps(O.shooter, turn(angle2dir(O.angle), 180), 10)
		var/atom/movable/shooter = O.shooter
		if (!istype(shooter)) //yeah just in case an area fired the projectile (????)
			return
		shooter.throw_at(throw_target, 4, 2, thrown_from = get_turf(O))

	turf_effect(obj/projectile/O, turf/simulated/floor/T, dir)
		if (istype(T))
			if (prob(30))
				T.pry_tile()
			else if (prob(30))
				T.burn_tile()
		..()


/obj/item/spraybottle/cleaner/tsunami
	name = "Tsunami-P3 spray bottle"
	desc = "A highly over-engineered spray bottle with all kinds of actuators, pumps and matter-generators. Never runs out of cleaner and has a remarkable range."
	icon_state = "tsunami"
	item_state = "tsunami"
	var/lastUse = null

	afterattack(atom/A as mob|obj, mob/user as mob)
		if (A.storage)
			return
		if (!isturf(user.loc))
			return

		if(lastUse)
			var/actual = (world.timeofday - lastUse)
			if(actual < 0) actual += 864000
			if(actual < 40) return

		lastUse = world.timeofday

		reagents.clear_reagents()
		reagents.add_reagent("cleaner", 100)

		if(src.reagents.has_reagent("water") || src.reagents.has_reagent("cleaner"))
			JOB_XP(user, "Janitor", 2)

		var/datum/projectile/proj_data = new /datum/projectile/special/shotchem/wave

		var/obj/projectile/projectile = shoot_projectile_ST_pixel_spread(user, proj_data, A)
		if(!projectile.reagents)
			projectile.create_reagents(100)
		src.reagents.trans_to_direct(projectile.reagents, 100)
		playsound(src.loc, 'sound/effects/bigwave.ogg', 50, 1)
