/obj/item/chem_pill_bottle
	name = "pill bottle"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	w_class = W_CLASS_SMALL
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	rand_pos = 1
	inventory_counter_enabled = 1
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	var/pname
	var/pvol
	var/pcount
	var/datum/reagents/reagents_internal
	var/average
	var/consume_input_buffer
	/// A reference to the action currently in use if eating pills from the bottle.
	var/datum/action/bar/icon/consume_pill_from_bottle_chemmaster/consumption_action

	// setup this pill bottle from some reagents
	proc/create_from_reagents(var/datum/reagents/R, var/pillname, var/pillvol, var/pillcount)
		var/volume = pillcount * pillvol

		reagents_internal = new/datum/reagents(volume)
		reagents_internal.my_atom = src

		R.trans_to_direct(reagents_internal,volume)

		src.average = reagents_internal.get_average_color().to_rgb()

		src.name = "[pillname] pill bottle"
		src.desc = "Contains [pillcount] [pillname] pills."
		src.pname = pillname
		src.pvol = pillvol
		src.pcount = pillcount

	// spawn a pill, returns a pill or null if there aren't any left in the bottle
	proc/create_pill()
		if(total_pills() <= 0)
			return null

		var/obj/item/reagent_containers/pill/P = null

		// give back stored pills first
		if (src.contents.len)
			for (var/i = src.contents.len; i > 0 && !istype(P, /obj/item/reagent_containers/pill), i--)
				P = src.contents[i]

		// otherwise create a new one from the reagent holder
		else if (pcount)
			LAGCHECK(LAG_LOW)
			if (src)
				if (src.reagents_internal.total_volume < src.pvol)
					src.pcount = 0
				else
					P = new /obj/item/reagent_containers/pill
					P.set_loc(src)
					P.name = "[pname] pill"

					src.reagents_internal.trans_to(P,src.pvol)
					if (P?.reagents)
						P.color_overlay = image('icons/obj/items/pills.dmi', "pill0")
						P.color_overlay.color = src.average
						P.color_overlay.alpha = P.color_overlay_alpha
						P.overlays += P.color_overlay
					src.pcount--
		// else return null

		return P

	proc/rebuild_desc()
		var/totalpills = total_pills()
		if(totalpills > 15)
			src.desc = "A [src.pname] pill bottle. There are too many to count."
			src.inventory_counter.update_text("**")
		else if (totalpills <= 0)
			src.desc = "A [src.pname] pill bottle. It looks empty."
			src.inventory_counter.update_number(0)
		else
			src.desc = "A [src.pname] pill bottle. There [totalpills==1? "is [totalpills] pill." : "are [totalpills] pills." ]"
			src.inventory_counter.update_number(totalpills)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/pill))
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			boutput(user, SPAN_NOTICE("You put [W] in [src]."))
			rebuild_desc()
		else ..()

	attack_self(var/mob/user as mob)
		tip_out(user, user.loc)

	/// returns the total number of remaining pills
	proc/total_pills()
		return src.pcount + length(src.contents)

	proc/tip_out(var/mob/user as mob, atom/location, var/skip_messages = FALSE)
		var/obj/item/reagent_containers/pill/P = src.create_pill()
		if (istype(P))
			var/i = rand(3,8)
			while(istype(P) && i > 0)
				P.set_loc(get_turf(location))
				P = src.create_pill()
				i--
			if (!skip_messages)
				if (src.pcount + length(src.contents) > 0)
					boutput(user, SPAN_NOTICE("You tip out a bunch of pills from [src] onto [location]."))
				else
					boutput(user, SPAN_NOTICE("You tip out all the pills from [src] onto [location]."))
			rebuild_desc()
		else
			if (!skip_messages)
				boutput(user, SPAN_ALERT("It's empty."))

	attack_hand(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			var/obj/item/reagent_containers/pill/P = src.create_pill()
			if(istype(P))
				user.put_in_hand_or_drop(P)
				boutput(user, "You take [P] from [src].")
				rebuild_desc()
			else
				boutput(user, SPAN_ALERT("It's empty."))
				return

		else
			return ..()

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (user.restrained() || user.getStatusDuration("unconscious") || user.sleeping || user.stat || user.lying)
			return
		if (!in_interact_range(user, src) || !in_interact_range(user, O))
			user.show_text("That's too far away!", "red")
			return
		if (!istype(O, /obj/item/reagent_containers/pill))
			if (istype(O, /obj/item) && O != src) // don't display this message if its a mob or something obvious
				boutput(usr, SPAN_ALERT("[src] can't hold anything but pills!"))
			return

		user.visible_message(SPAN_NOTICE("[user] begins quickly filling [src]!"))
		var/staystill = user.loc
		for (var/obj/item/reagent_containers/pill/P in view(1,user))
			if (P in user)
				continue
			P.set_loc(src)
			P.dropped(user)
			src.rebuild_desc()
			sleep(0.2 SECONDS)
			if (user.loc != staystill)
				break
		boutput(user, SPAN_NOTICE("You finish filling [src]!"))

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
			start_eating_from_bottle(usr)
			return

		else if (istype(over_object,/obj/table) && total_pills() > 0)
			// Perhaps it is bad form to use params like this, but it is pretty useful for communicating between mouse_drop() and MouseDrop_T().
			// The alternatives in this situation are putting the tip_out() call into the table's MouseDrop_T() - but I would personally prefer item logic
			// to remain in said item's class - or use a SPAWN(0) to wait out MouseDrop_T().
			if (!islist(params)) params = params2list(params)
			if (params) params["dumped"] = 1
			tip_out(usr, over_object)
			return
		..()

	proc/start_eating_from_bottle(mob/user)
		if (total_pills() <= 0)
			boutput(user, SPAN_ALERT("[src] is empty!"))
			return
		if (!consumption_action)
			consumption_action = new /datum/action/bar/icon/consume_pill_from_bottle_chemmaster(user, src)
			actions.start(consumption_action, user)
		else
			consumption_action.consume_input_buffer++



	/// Returns true if a pill was successfully swallowed.
	proc/eat_pill_from_bottle(mob/user)
		if (total_pills() < 1)
			boutput(user, SPAN_ALERT("[src] is empty!"))
			return FALSE

		playsound(src.loc, 'sound/effects/pop_pills.ogg', rand(10,50), 1) //range taken from drinking/eating

		// clumsy and braindamaged people have a chance to consume multiple pills at once and drop others on the floor.
		if(total_pills() > 0 && ((user.bioHolder && user.bioHolder.HasEffect("clumsy")) || user.get_brain_damage() > 40) && prob(20))
			user.visible_message(SPAN_NOTICE("[user] throws the contents of [src] at their own face!"),
								null, SPAN_NOTICE("Someone pops some pills."))
			for(var/i = 1; i <= rand(1, 4); i++) // pop multiple pills at once
				var/obj/item/reagent_containers/pill/newPill = src.create_pill()
				if (isnull(newPill)) break
				newPill.pill_action(user, user)
			if (total_pills() > 0)
				tip_out(user, user.loc, TRUE)
		else
			var/obj/item/reagent_containers/pill/pill = src.create_pill()
			if (isnull(pill)) return FALSE
			user.visible_message(SPAN_NOTICE("[user] pops a pill from [src]!"),
								null, SPAN_NOTICE("Someone pops a pill."))
			pill.pill_action(user, user)
		rebuild_desc()
		return TRUE



	// Don't dump the bottle onto the table if using drag-and-drop to dump out pills.
	should_place_on(obj/target, params)
		if (istype(target, /obj/table) && islist(params) && params["dumped"])
			return FALSE
		. = ..()


/datum/action/bar/icon/consume_pill_from_bottle_chemmaster
	duration = 0.75 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	var/mob/bottleholder
	var/mob/target
	var/obj/item/chem_pill_bottle/bottle
	var/consume_input_buffer = 1

	New(mob/Target, obj/item/chem_pill_bottle/Bottle)
		..()
		target = Target
		bottle = Bottle
		icon = bottle.icon
		icon_state = bottle.icon_state

	proc/checkContinue()
		if (bottle.total_pills() <= 0 || !isalive(bottleholder) || !bottleholder.find_in_hand(bottle))
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
		// if attacked or stunned while trying to take a pill, drop the pill you would take
		if (flag & (INTERRUPT_ATTACKED | INTERRUPT_STUNNED))
			var/pill = bottle.create_pill()
			if (!isnull(pill)) bottleholder.drop_item(pill)
			bottle.rebuild_desc()
		bottle.consumption_action = null

	onEnd()
		consume_input_buffer--
		if (bottle.eat_pill_from_bottle(target))
			eat_twitch(target)
		else // if a pill was not successfully swallowed something is probably wrong, so don't let the loop restart
			bottle.consumption_action = null
			..()
			return
		var/pillsRemainingInBottle = bottle.total_pills()
		if (pillsRemainingInBottle > 0 && consume_input_buffer > 0)
			onRestart()
			return
		if(pillsRemainingInBottle <= 0)
			boutput(usr, SPAN_ALERT("The [src] is empty."))
		bottle.consumption_action = null
		..()
		return


