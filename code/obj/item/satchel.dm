/obj/item/satchel
	name = "satchel"
	desc = "A leather satchel for holding things."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "satchel"
	item_state = "satchel"
	c_flags = ONBELT
	health = 6
	w_class = W_CLASS_TINY
	event_handler_flags = USE_FLUID_ENTER | NO_MOUSEDROP_QOL
	soundproofing = 20
	var/maxitems = 50
	var/max_stack_scoop = 20 //! if you try to put stacks inside the item, this one limits how much you can in one action. Creating 100 items out of a stack in a single action should not happen.
	var/list/allowed = null
	var/list/exceptions = null //! this list are for items that are in the allowed-list for other reasons, but should not be able to be put in satchels
	var/maximal_w_class = W_CLASS_BULKY //! the maximum weight class the satchels should be able to carry.
	var/itemstring = "items"
	inventory_counter_enabled = 1

	HELP_MESSAGE_OVERRIDE("Click on it to pull out a random item, or click on it with <b>Grab Intent</b> to search for a specific item.")


	New()
		..()
		allowed = list(/obj/item/)
		exceptions = list()
		src.UpdateIcon()

	attackby(obj/item/W, mob/user)

		if (!src.check_valid_content(W))
			boutput(user, SPAN_ALERT("[src] cannot hold that kind of item!"))
			return

		if (length(src.contents) < src.maxitems)
			var/max_stack_reached = FALSE
			if (W.amount > 1)
				boutput(user, SPAN_NOTICE("You begin to fill [src] with [W]."))
				var/amount_of_stack_splits = src.split_stack_into_satchel(W, user)
				if (amount_of_stack_splits == src.max_stack_scoop)
					max_stack_reached = TRUE
			else
				boutput(user, SPAN_NOTICE("You put [W] in [src]."))
			W.add_fingerprint(user)
			if (!max_stack_reached && (length(src.contents) < src.maxitems)) // if we split up the item and it was more than the satchel can find we should not add the rest
				user.u_equip(W)
				W.set_loc(src)
				W.dropped(user)
			if (length(src.contents) == src.maxitems)
				boutput(user, SPAN_NOTICE("[src] is now full!"))
			src.UpdateIcon()
			tooltip_rebuild = TRUE
			RANDOMIZE_PIXEL_OFFSET(W, 10)
		else
			boutput(user, SPAN_ALERT("[src] is full!"))

	attack_self(var/mob/user as mob)
		if (length(src.contents))
			var/turf/T = user.loc
			logTheThing(LOG_STATION, user, "dumps the contents of [src] ([length(src.contents)] items) out at [log_loc(T)].")
			for (var/obj/item/I in src.contents)
				I.set_loc(T)
				I.add_fingerprint(user)
			boutput(user, SPAN_NOTICE("You empty out [src]."))
			src.UpdateIcon()
			tooltip_rebuild = TRUE
		else ..()

	attack_hand(mob/user)
		// There's a hilarious bug in here - if you're searching through the container
		// and then throw it, after you finish searching the container will just.
		// warp back to your hands.
		// This is probably easily fixable by just running the check again
		// but to be honest this is one of those funny bugs that can be fixed later

		if (GET_DIST(user, src) <= 0 && length(src.contents))
			if (user.l_hand == src || user.r_hand == src)
				var/obj/item/getItem = null

				if (length(src.contents) > 1)
					if (user.a_intent == INTENT_GRAB)
						getItem = src.search_through(user)
						if (!getItem) // prevents the satchel teleporting back to the hand if the search is cancelled
							return

					else
						user.visible_message(SPAN_NOTICE("<b>[user]</b> rummages through \the [src]."),\
						SPAN_NOTICE("You rummage through \the [src]."))

						getItem = pick(src.contents)

				else if (length(src.contents) == 1)
					getItem = src.contents[1]

				if (getItem)
					user.visible_message(SPAN_NOTICE("<b>[user]</b> takes \a [getItem.name] out of \the [src]."),\
					SPAN_NOTICE("You take \a [getItem.name] from [src]."))
					user.put_in_hand_or_drop(getItem)
					src.UpdateIcon()
			tooltip_rebuild = TRUE
		return ..(user)

	proc/search_through(mob/user as mob)

		if(!istype(user))
			return

		// attack_hand does all the checks for if you can do this
		user.visible_message(SPAN_NOTICE("<b>[user]</b> looks through \the [src]..."),\
		SPAN_NOTICE("You look through \the [src]."))
		var/list/satchel_contents = list()
		var/list/has_dupes = list()
		var/temp = ""
		for (var/obj/item/I in src.contents)
			temp = ""
			if (satchel_contents[I.name])
				if (has_dupes[I.name])
					has_dupes[I.name] = has_dupes[I.name] + 1
				else
					has_dupes[I.name] = 2
				temp = "[I.name] ([has_dupes[I.name]])"
				satchel_contents += temp
				satchel_contents[temp] = I
			else
				temp = "[I.name]"
				satchel_contents += temp
				satchel_contents[temp] = I
		sortList(satchel_contents, /proc/cmp_text_asc)
		var/chosenItem = input("Select an item to pull out.", "Choose Item") as null|anything in satchel_contents
		if (!chosenItem || !(satchel_contents[chosenItem] in src.contents))
			return
		if (!user.is_in_hands(src))
			boutput(user, SPAN_ALERT("You could have sworn [src] was just in your hand a moment ago."))
			return
		return satchel_contents[chosenItem]


	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (!in_interact_range(src, user)  || BOUNDS_DIST(O, user) > 0 || !can_act(user))
			return
		var/proceed = 0
		for(var/check_path in src.allowed)
			var/obj/item/W = O
			if(istype(O, check_path) && W.w_class < src.maximal_w_class)
				proceed = 1
				break
		if (proceed && length(src.exceptions) > 0)
			for(var/check_path in src.exceptions)
				var/obj/item/checked_item = O
				if(istype(checked_item, check_path))
					proceed = 0
					break
		if (!proceed)
			boutput(user, SPAN_ALERT("\The [src] can't hold that kind of item."))
			return

		if (length(src.contents) < src.maxitems)
			user.visible_message(SPAN_NOTICE("[user] begins quickly filling \the [src]."))
			var/staystill = user.loc
			var/interval = 0
			for(var/obj/item/I in view(1,user))
				if (!matches(I, O) || QDELETED(I)) continue
				if (I in user)
					continue
				var/max_stack_reached = FALSE
				if (I.amount > 1)
					var/amount_of_stack_splits = src.split_stack_into_satchel(I, user)
					if (amount_of_stack_splits == src.max_stack_scoop)
						max_stack_reached = TRUE
				I.add_fingerprint(user)
				if (!max_stack_reached && (length(src.contents) < src.maxitems)) // if we split up the item and it was more than the satchel can find we should not add the rest
					I.set_loc(src)
					SEND_SIGNAL(I, COMSIG_ITEM_STORED, user)
					RANDOMIZE_PIXEL_OFFSET(I, 10)
				if (!(interval++ % 5))
					src.UpdateIcon()
					sleep(0.2 SECONDS)
				if (user.loc != staystill) break
				if (length(src.contents) >= src.maxitems)
					boutput(user, SPAN_NOTICE("\The [src] is now full!"))
					break
			boutput(user, SPAN_NOTICE("You finish filling \the [src]."))
		else boutput(user, SPAN_ALERT("\The [src] is already full!"))
		src.UpdateIcon()
		tooltip_rebuild = TRUE

	mouse_drop(atom/over_object, src_location, over_location, src_control, over_control, params)
		if (!in_interact_range(src, usr) || !can_act(usr))
			return

		if (istype(over_object,/obj/table) || istype(over_object, /obj/surgery_tray))
			if (BOUNDS_DIST(over_object, usr) > 0)
				boutput(usr, SPAN_ALERT("You need to be closer to [over_object] to do that."))
				return
			if (length(src.contents) < 1)
				boutput(usr, SPAN_ALERT("There's nothing in [src]!"))
			else
				var/obj/table = over_object
				usr.visible_message(SPAN_NOTICE("[usr] dumps out [src]'s contents onto [over_object]!"))
				for (var/obj/item/thing in src.contents)
					table.place_on(thing)
				src.tooltip_rebuild = TRUE
				src.UpdateIcon()
				params["satchel_dumped"] = TRUE
				return

		if (istype(over_object, /obj/machinery/disposal))
			disposals_dump(over_object, usr)
			return
		. = ..()

	/// The user tries to place all of the satchel's contents into the given disposal chute.
	proc/disposals_dump(var/obj/machinery/disposal/chute, mob/user)
		if (BOUNDS_DIST(chute, user) > 0)
			boutput(user, SPAN_ALERT("You need to be closer to [chute] to do that."))
			return
		if (!length(src.contents))
			boutput(user, SPAN_ALERT("There's nothing in [src] to dump out!"))
			return
		if (!(src in user.equipped_list()))
			if (!isrobot(user))
				boutput(user, SPAN_ALERT("You need to be holding [src] to do that."))
			return
		for(var/obj/item/item in src.contents)
			if (chute.fits_in(item))
				item.set_loc(chute)
		user.set_dir(get_dir(user, chute))
		src.UpdateIcon()
		src.tooltip_rebuild = TRUE
		chute.play_item_insert_sound(src)
		user.visible_message("<b>[user.name]</b> dumps out [src] into [chute].")
		chute.update()

	// Don't place the satchel onto the table if we've dumped out its contents with the same command.
	should_place_on(obj/target, params)
		if (istype(target, /obj/table) && islist(params) && params["satchel_dumped"])
			return FALSE
		. = ..()

	should_suppress_attack(var/object, mob/user)
		// chance to smack satchels against a table when dumping stuff out of them, because that can be kinda funny
		if (istype(object, /obj/table) && (user.get_brain_damage() <= BRAIN_DAMAGE_MODERATE && rand(1, 10) < 10))
			return TRUE
		..()

	proc/split_stack_into_satchel(var/obj/item/item_to_split, mob/user)
		// This proc splits an object with multiple stacks and stuff it into the satchel until either
		// The satchel is full
		// all but the origin item of the stack is in the satchel
		// the safety-amount of items were stuffed to prevent laggs.
		// The proc returns the amount of times splits were created and stuffed
		if (!(item_to_split) || (item_to_split.amount <= 1))
			return 0
		var/increment = 0
		//since we need to add additional manipulation to the item in hand, we won't touch the last item here
		var/amount_of_stack_splits = min(src.maxitems - length(src.contents), item_to_split.amount - 1, src.max_stack_scoop)
		for (increment = 0, increment < amount_of_stack_splits, increment++)
			var/obj/item/splitted_stack = item_to_split.split_stack(1)
			splitted_stack.set_loc(src)
			if (user)
				splitted_stack.add_fingerprint(user)
		return amount_of_stack_splits

	proc/check_valid_content(var/obj/item/item_to_check)
		// this proc checks if an item is able to be added to the satchel
		// returns TRUE when it is able to be stuffed, returns FALSE when it is unable to
		var/proceed = FALSE
		for(var/check_path in src.allowed)
			if(istype(item_to_check, check_path) && item_to_check.w_class < src.maximal_w_class)
				proceed = TRUE
				break
		if (proceed && length(src.exceptions) > 0)
			for(var/check_path in src.exceptions)
				if(istype(item_to_check, check_path))
					proceed = FALSE
					break
		return proceed


	proc/matches(atom/movable/inserted, atom/movable/template)
		. = istype(inserted, template.type)

	update_icon()

		var/perc
		if (length(src.contents) > 0 && src.maxitems > 0)
			perc = (src.contents.len / src.maxitems) * 100
		else
			perc = 0
		src.overlays = null
		switch(perc)
			if (-INFINITY to 0)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter0")
			if (1 to 24)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter1")
			if (25 to 49)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter2")
			if (50 to 74)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter3")
			if (75 to 99)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter4")
			if (100 to INFINITY)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter5")

		signal_event("icon_updated")
		src.inventory_counter?.update_number(src.contents.len)

	get_desc()
		return "It contains [src.contents.len]/[src.maxitems] [src.itemstring]."



	hydro
		name = "produce satchel"
		desc = "A leather satchel for carrying around crops and seeds."
		icon_state = "hydrosatchel"
		item_state = "hydrosatchel"
		itemstring = "items of produce"
		maxitems = 50

		New()
			..()
			allowed = list(/obj/item/seed,
			/obj/item/plant,
			/obj/item/clothing/head/flower,
			/obj/item/reagent_containers/food/snacks,
			/obj/item/organ,
			/obj/item/clothing/head/butt,
			/obj/item/parts/human_parts/arm,
			/obj/item/parts/human_parts/leg,
			/obj/item/raw_material/cotton,
			/obj/item/feather,
			/obj/item/bananapeel)
			exceptions = list(/obj/item/plant/tumbling_creeper, /obj/item/reagent_containers/food/snacks/ingredient/egg)
			// tumbling creeper have size restrictions and should not be carried in large amount
			// eggs are just a bit too powerful to fit in your pocket

		matches(atom/movable/inserted, atom/movable/template)
			. = ..()
			if(. && istype(template, /obj/item/seed))
				var/obj/item/seed/inserted_seed = inserted
				var/obj/item/seed/template_seed = template
				. = (inserted_seed.planttype?.type == template_seed.planttype?.type) && \
					(inserted_seed.plantgenes.mutation?.type == template_seed.plantgenes.mutation?.type)

		large
			name = "large produce satchel"
			desc = "A leather satchel for carrying around crops and seeds. This one happens to be <em>really</em> big."
			icon_state = "hydrosatchel-large"
			maxitems = 200

		compressed
			name = "spatially-compressed produce satchel"
			desc = "A ... uh. Well, whatever it is, it's a <em>really fucking big satchel</em> for holding crops and seeds."
			icon_state = "hydrosatchel-compressed"
			maxitems = 1000


	mining
		name = "mining satchel"
		desc = "A leather satchel for holding various ores."
		icon_state = "miningsatchel"
		item_state = "miningsatchel"
		itemstring = "ores"

		New()
			..()
			allowed = list(/obj/item/raw_material/)

		large
			name = "large mining satchel"
			desc = "A leather satchel for holding various ores. This one's pretty big."
			icon_state = "miningsatchel-large"
			maxitems = 100

		compressed
			name = "spatially-compressed mining satchel"
			desc = "A ... uh. Well, whatever it is, it's a <em>really fucking big satchel</em> for holding ores."
			icon_state = "miningsatchel-compressed"
			maxitems = 500

	mail
		name = "mail bag"
		desc = "A leather bag for holding mail. It's totally not just a produce/mining satchel!"
		icon_state = "mailsatchel"
		item_state = "mailsatchel"
		itemstring = "mail"

		New()
			..()
			allowed = list(/obj/item/random_mail)

		large
			name = "large mail satchel"
			desc = "A leather satchel for carrying around mail. This one happens to be <em>really</em> big."
			icon_state = "mailsatchel-large"
			maxitems = 100

		compressed
			name = "spatially-compressed mail satchel"
			desc = "A ... uh. Well, whatever it is, it's a <em>really fucking big satchel</em> for holding mail."
			icon_state = "mailsatchel-compressed"
			maxitems = 250

	figurines
		name = "figurine case"
		desc = "A cool plastic case for storing little figurines!"
		icon_state = "figurinecase"
		maxitems = 30
		flags = null
		w_class = W_CLASS_NORMAL

		New()
			..()
			allowed = list(/obj/item/toy/figure)

		update_icon()

			return

		// ITS GONNA BE CLICKY AND OPEN OK   SHUT UP
		attackby(obj/item/W, mob/user)
			src.open_it_up(1)
			..()
			src.open_it_up(0)

		attack_self(var/mob/user as mob)
			src.open_it_up(1)
			..()
			src.open_it_up(0)

		attack_hand(mob/user)
			if (GET_DIST(user, src) <= 0 && src.contents.len && (user.l_hand == src || user.r_hand == src))
				src.open_it_up(1)
			..()
			src.open_it_up(0)

		MouseDrop_T(atom/movable/O as obj, mob/user as mob)
			src.open_it_up(1)
			..()
			src.open_it_up(0)

		// clicky open close
		proc/open_it_up(var/open)
			if (open && icon_state == "figurinecase")
				playsound(src, 'sound/misc/lightswitch.ogg', 50, pitch = 1.2)
				icon_state = "figurinecase-open"
				sleep(0.4 SECONDS)

			else if (!open && icon_state == "figurinecase-open")
				sleep(0.5 SECONDS)
				playsound(src, 'sound/misc/lightswitch.ogg', 50, pitch = 0.9)
				icon_state = "figurinecase"

/obj/item/satchel/figurines/full
	New()
		. = ..()
		for(var/i = 0, i < maxitems, i++)
			var/obj/item/toy/figure/F = new()
			F.set_loc(src)
			src.UpdateIcon()
		tooltip_rebuild = TRUE

