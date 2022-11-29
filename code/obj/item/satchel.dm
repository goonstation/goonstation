/obj/item/satchel
	name = "satchel"
	desc = "A leather satchel for holding things."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "satchel"
	c_flags = ONBELT
	health = 6
	w_class = W_CLASS_TINY
	event_handler_flags = USE_FLUID_ENTER | NO_MOUSEDROP_QOL
	var/maxitems = 50
	var/list/allowed = list(/obj/item/)
	var/itemstring = "items"
	inventory_counter_enabled = 1


	New()
		..()
		src.UpdateIcon()

	attackby(obj/item/W, mob/user)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path) && W.w_class < W_CLASS_BULKY)
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span class='alert'>[src] cannot hold that kind of item!</span>")
			return

		if (src.contents.len < src.maxitems)
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			boutput(user, "<span class='notice'>You put [W] in [src].</span>")
			W.add_fingerprint(user)
			if (src.contents.len == src.maxitems) boutput(user, "<span class='notice'>[src] is now full!</span>")
			src.UpdateIcon()
			tooltip_rebuild = 1
		else boutput(user, "<span class='alert'>[src] is full!</span>")

	attack_self(var/mob/user as mob)
		if (length(src.contents))
			var/turf/T = user.loc
			logTheThing(LOG_STATION, user, "dumps the contents of [src] ([length(src.contents)] items) out at [log_loc(T)].")
			for (var/obj/item/I in src.contents)
				I.set_loc(T)
				I.add_fingerprint(user)
			boutput(user, "<span class='notice'>You empty out [src].</span>")
			src.UpdateIcon()
			tooltip_rebuild = 1
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

				if (src.contents.len > 1)
					if (user.a_intent == INTENT_GRAB)
						getItem = src.search_through(user)

					else
						user.visible_message("<span class='notice'><b>[user]</b> rummages through \the [src].</span>",\
						"<span class='notice'>You rummage through \the [src].</span>")

						getItem = pick(src.contents)

				else if (src.contents.len == 1)
					getItem = src.contents[1]

				if (getItem)
					user.visible_message("<span class='notice'><b>[user]</b> takes \a [getItem.name] out of \the [src].</span>",\
					"<span class='notice'>You take \a [getItem.name] from [src].</span>")
					user.put_in_hand_or_drop(getItem)
					src.UpdateIcon()
			tooltip_rebuild = 1
		return ..(user)

	proc/search_through(mob/user as mob)

		if(!istype(user))
			return

		// attack_hand does all the checks for if you can do this
		user.visible_message("<span class='notice'><b>[user]</b> looks through through \the [src]...</span>",\
		"<span class='notice'>You look through \the [src].</span>")
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
		if (!chosenItem)
			return
		return satchel_contents[chosenItem]


	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (!in_interact_range(src, user)  || BOUNDS_DIST(O, user) > 0 || !can_act(user))
			return
		var/proceed = 0
		for(var/check_path in src.allowed)
			var/obj/item/W = O
			if(istype(O, check_path) && W.w_class < W_CLASS_BULKY)
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span class='alert'>\The [src] can't hold that kind of item.</span>")
			return

		if (src.contents.len < src.maxitems)
			user.visible_message("<span class='notice'>[user] begins quickly filling \the [src].</span>")
			var/staystill = user.loc
			var/interval = 0
			for(var/obj/item/I in view(1,user))
				if (!matches(I, O)) continue
				if (I in user)
					continue
				I.set_loc(src)
				I.add_fingerprint(user)
				if (!(interval++ % 5))
					src.UpdateIcon()
					sleep(0.2 SECONDS)
				if (user.loc != staystill) break
				if (src.contents.len >= src.maxitems)
					boutput(user, "<span class='notice'>\The [src] is now full!</span>")
					break
			boutput(user, "<span class='notice'>You finish filling \the [src].</span>")
		else boutput(user, "<span class='alert'>\The [src] is already full!</span>")
		src.UpdateIcon()
		tooltip_rebuild = 1

	proc/matches(atom/movable/inserted, atom/movable/template)
		. = istype(inserted, template.type)

	update_icon()

		var/perc
		if (src.contents.len > 0 && src.maxitems > 0)
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
		allowed = list(/obj/item/seed,
		/obj/item/plant,
		/obj/item/reagent_containers/food/snacks,
		/obj/item/organ,
		/obj/item/clothing/head/butt,
		/obj/item/parts/human_parts/arm,
		/obj/item/parts/human_parts/leg,
		/obj/item/raw_material/cotton,
		/obj/item/feather)
		itemstring = "items of produce"

		matches(atom/movable/inserted, atom/movable/template)
			. = ..()
			if(. && istype(template, /obj/item/seed))
				var/obj/item/seed/inserted_seed = inserted
				var/obj/item/seed/template_seed = template
				. = (inserted_seed.planttype?.type == template_seed.planttype?.type) && \
					(inserted_seed.plantgenes.mutation?.type == template_seed.plantgenes.mutation?.type)

		large
			desc = "A leather satchel for carrying around crops and seeds. This one happens to be <em>really</em> big."
			maxitems = 200


	mining
		name = "mining satchel"
		desc = "A leather satchel for holding various ores."
		icon_state = "miningsatchel"
		allowed = list(/obj/item/raw_material/)
		itemstring = "ores"

		large
			name = "large mining satchel"
			desc = "A leather satchel for holding various ores. This one's pretty big."
			maxitems = 100

		compressed
			name = "spatially-compressed mining satchel"
			desc = "A ... uh. Well, whatever it is, it's a <em>really fucking big satchel</em> for holding ores."
			maxitems = 500


	figurines
		name = "figurine case"
		desc = "A cool plastic case for storing little figurines!"
		icon_state = "figurinecase"
		maxitems = 30
		allowed = list(/obj/item/toy/figure)
		flags = null
		w_class = W_CLASS_NORMAL

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
		tooltip_rebuild = 1

