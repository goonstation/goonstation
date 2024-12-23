
/// for when you want something that "contains" a certain amount of an item
/obj/item/item_box
	name = "box"
	desc = "A little cardboard box for keeping stuff in. Woah! We're truly in the future with technology like this."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "item_box"
	force = 1
	throwforce = 1
	w_class = W_CLASS_SMALL
	inventory_counter_enabled = 1
	var/contained_item = /obj/item/sticker/gold_star
	var/list/contained_items = null
	var/contained_items_proc = 0
	var/item_amount = -1 // how many of thing to start with, -1 for infinite
	var/max_item_amount = -1 // how many can the thing hold total, -1 for infinite
	var/open = 0
	var/icon_closed = "item_box"
	var/icon_open = "item_box-open"
	var/icon_empty = "item_box-empty"
	var/icon_closed_empty = null
	var/reusable = 1

	gold_star
		name = "box of gold star stickers"

	banana
		name = "box of banana stickers"
		contained_item = /obj/item/sticker/banana

	clover
		name = "box of clover stickers"
		contained_item = /obj/item/sticker/clover

	umbrella
		name = "box of umbrella stickers"
		contained_item = /obj/item/sticker/umbrella

	skull
		name = "box of skull stickers"
		contained_item = /obj/item/sticker/skull

	no
		name = "box of \"no\" stickers"
		contained_item = /obj/item/sticker/no

	left_arrow
		name = "box of left arrow stickers"
		contained_item = /obj/item/sticker/left_arrow

	right_arrow
		name = "box of right arrow stickers"
		contained_item = /obj/item/sticker/right_arrow

	heart
		name = "box of heart stickers"
		contained_item = /obj/item/sticker/heart

	moon
		name = "box of moon stickers"
		contained_item = /obj/item/sticker/moon

	smile
		name = "box of smile stickers"
		contained_item = /obj/item/sticker/smile

	frown
		name = "box of frown stickers"
		contained_item = /obj/item/sticker/frown

	balloon
		name = "box of red balloon stickers"
		contained_item = /obj/item/sticker/balloon

	rainbow
		name = "box of rainbow stickers"
		contained_item = /obj/item/sticker/rainbow

	horseshoe
		name = "box of horseshoe stickers"
		contained_item = /obj/item/sticker/horseshoe

	bee
		name = "box of bee stickers"
		contained_item = /obj/item/sticker/bee

	contraband
		name = "contraband adjustment sticker box"
		desc = "Contains stickers which can adjust the effective level of contraband an item is detected as."
		contained_items_proc = FALSE
		contained_item = /obj/item/sticker/contraband
		item_amount = 10
		max_item_amount = 10

	glow_sticker
		name = "glow stickers"
		desc = "A box of stickers that glow when stuck to things."
		contained_item = null
		item_amount = 20

		New()
			. = ..()
			contained_item = pick(concrete_typesof(/obj/item/sticker/glow))

	googly_eyes
		name = "box of googly eyes"
		desc = "If you give it googly eyes, it immediately becomes better!"
		contained_item = /obj/item/sticker/googly_eye

		angry
			name ="box of angry googly eyes"
			contained_item = /obj/item/sticker/googly_eye/angry

	award_ribbon
		name = "box of award ribbons"
		contained_item = /obj/item/sticker/ribbon

		first_place
			name = "box of 1st place ribbons"
			contained_item = /obj/item/sticker/ribbon/first_place
		second_place
			name = "box of 2nd place ribbons"
			contained_item = /obj/item/sticker/ribbon/second_place
		third_place
			name = "box of 3rd place ribbons"
			contained_item = /obj/item/sticker/ribbon/third_place
		participant
			name = "box of participation ribbons"
			contained_item = /obj/item/sticker/ribbon/participant

	postit
		name = "box of sticky notes"
		desc = "It's like a box that a pile of sticky notes would come in, but it's actually the pile, too. So there's a pile in the box. Or the pile... IS the box? Quantum sticky note pile-box? Whatever, I've been trying to get this to work for a few hours and making a special little sticky note container is the last thing I want to do right now. Fuck."
		contained_item = /obj/item/sticker/postit
		max_item_amount = 20
		item_amount = 20

	crayon // stonepillar's crayon project
		name = "rapid crayon creation device"
		desc = "It's the StephiMatic(tm) rapid crayon creation device! Perfect for the budding artist. Ages 5 and up!"
		contained_item = /obj/item/pen/crayon

		add_to(var/obj/item/I)
			if(..())
				qdel(I)
				return 1
			return 0

		take_from()
			var/newColor = input("Pick crayon color:","Crayon color") as null|color
			if(!isnull(newColor))
				var/obj/item/pen/crayon/newCrayon = new /obj/item/pen/crayon
				newCrayon.color = newColor
				newCrayon.font_color = newColor
				newCrayon.name = "cheap-looking [hex2color_name(newColor)] crayon"
				return newCrayon
			return 0


	assorted
		name = "box of assorted things"
		desc = "Wow! A marvel of technology, this box doesn't store just ONE item, but an assortment of items! The future really is here."
		contained_items_proc = 1

		stickers
			icon_state = "sticker_box_assorted"
			icon_closed = "sticker_box_assorted"
			icon_open = "sticker_box_assorted-open"
			icon_empty = "sticker_box_assorted-open"
			name = "box of assorted stickers"
			desc = "Oh my god.. ALL THE STICKERS! ALL IN ONE PLACE? WHAT CAN THIS MEAN!!!"

			set_contained_items()
				// i hate this
				contained_items = concrete_typesof( /obj/item/sticker/ ) - /obj/item/sticker/spy - typesof( /obj/item/sticker/barcode, /obj/item/sticker/glow )  - /obj/item/sticker/contraband

			robot//this type sticks things by clicking on them with a cooldown
				name = "box shaped sticker dispenser"
				New()
					.=..()
					flags |= SUPPRESSATTACK
				var/next_use = 0
				var/use_delay = 15//admemes
				afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
					if (!A) return 0
					if(world.timeofday < next_use || use_delay > world.timeofday)
						user.show_message("Patience! The Stickerening can wait!")
						return 0
					next_use = world.timeofday + use_delay
					var/obj/item/sticker/stikur = take_from()
					if(!stikur) return
					var/ret = stikur.AfterAttack(A, user, reach, params)
					if(!ret)
						qdel(stikur)
					return
				attack_self()
				attack_hand()
				attack()

				science //For the science module
					name = "box shaped artifact form dispensor"
					desc = "A box full of forms for classifying alien artifacts"
					icon_state = "item_box"
					icon_closed = "item_box"
					icon_open = "item_box-open"
					set_contained_items()
						contained_items = list(/obj/item/sticker/postit/artifact_paper)

			stickers_limited
				desc = "This box contains a small assortment of stickers. Remember to share!"
				item_amount = 10
				max_item_amount = 10

				set_contained_items()
					// i hate this even more
					contained_items = concrete_typesof( /obj/item/sticker/ ) - typesof( /obj/item/sticker/barcode, /obj/item/sticker/glow ) - /obj/item/sticker/spy - /obj/item/sticker/ribbon/first_place - /obj/item/sticker/ribbon/second_place - /obj/item/sticker/ribbon/third_place - /obj/item/sticker/contraband

			glow_sticker
				name = "glow stickers"
				desc = "A box of stickers that glow various colors when stuck to things."
				contained_item = null
				item_amount = 20

				set_contained_items()
					contained_items = concrete_typesof(/obj/item/sticker/glow)

		ornaments
			name = "box of assorted ornaments"
			desc = "A box of festive little Spacemas ornaments you can decorate with!"
			icon_state = "xmas_box"
			icon_closed = "xmas_box"
			icon_open = "xmas_box-open"
			icon_empty = "xmas_box-open"

			set_contained_items()
				contained_items = typesof(/obj/item/sticker/xmas_ornament)

			ornaments_limited
				item_amount = 10
				max_item_amount = 10

				set_contained_items()
					contained_items = typesof(/obj/item/sticker/xmas_ornament)


		take_from()
			if( !contained_items.len )
				boutput( usr, "Dag, this box has nothing special about it. Oh well." )
				logTheThing(LOG_DEBUG, src, "has no items in it!")
				return
			src.contained_item = pick( contained_items )
			return ..()//TODO: hack?

	medical_patches
		name = "box of patches"
		contained_item = /obj/item/reagent_containers/patch
		item_amount = 0
		icon_state = "patchbox-med"
		icon_closed = "patchbox-med"
		icon_open = "patchbox-med-open"
		icon_empty = "patchbox-med-empty"
		var/icon_color = "patchbox-med-coloring"
		var/image/box_color
		flags = TABLEPASS | EXTRADELAY

		proc/build_overlay(var/datum/color/average = null) //ChemMasters provide average for medical boxes
			var/obj/item/reagent_containers/patch/temp = src.take_from()
			if (temp)
				src.item_amount++
				if (temp.medical && temp.reagents.total_volume)
					average = temp.reagents.get_average_color()
				else
					return
			else if (!average)
				return
			if (!src.box_color)
				src.box_color = image('icons/obj/items/storage.dmi', icon_color, -1)
			average.a = 255;
			src.box_color.color = average.to_rgba()
			src.UpdateOverlays(src.box_color, "reagentcolour")

		New()
			..()
			build_overlay()

		attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
			if (src.open)
				src.add_fingerprint(user)
				var/obj/item/I = src.take_from()
				if (I)
					if (!I.attack(target, user))
						src.item_amount++ // You didn't stick it on someone so it's still in the box
					return
			..()

		styptic
			name = "box of healing patches"
			contained_item = /obj/item/reagent_containers/patch/bruise
			item_amount = 10
			max_item_amount = 10
		silver_sulf
			name = "box of burn patches"
			contained_item = /obj/item/reagent_containers/patch/burn
			item_amount = 10
			max_item_amount = 10
		synthflesh
			name = "box of synthflesh patches"
			contained_item = /obj/item/reagent_containers/patch/synthflesh
			item_amount = 10
			max_item_amount = 10
		nicotine
			name = "box of nicotine patches"
			contained_item = /obj/item/reagent_containers/patch/nicotine
			item_amount = 5
			max_item_amount = 10

		mini_styptic
			name = "box of mini healing patches"
			contained_item = /obj/item/reagent_containers/patch/mini/bruise
			item_amount = 10
			max_item_amount = 10
		mini_silver_sulf
			name = "box of mini burn patches"
			contained_item = /obj/item/reagent_containers/patch/mini/burn
			item_amount = 10
			max_item_amount = 10
		mini_synthflesh
			name = "box of mini synthflesh patches"
			contained_item = /obj/item/reagent_containers/patch/mini/synthflesh
			item_amount = 10
			max_item_amount = 10

	pens
		name = "box of pens"
		contained_item = /obj/item/pen
		icon_state = "pen_box"
		icon_closed = "pen_box"
		icon_open = "pen_box-open"
		icon_empty = "pen_box-empty"

	heartcandy
		name = "Cupid Dan's Candy Hearts"
		desc = "May contain traces of real hearts, bone meal, and earwig honey."
		icon_state = "heart_box"
		contained_item = /obj/item/reagent_containers/food/snacks/candy/candyheart
		item_amount = 10
		max_item_amount = 10
		icon_closed = "heart_box"
		icon_open = "heart_box-open"
		icon_empty = "heart_box-empty"

	New()
		..()
		if (src.contained_items_proc)
			src.set_contained_items()
			src.inventory_counter.update_number(src.item_amount)
		else
			SPAWN(1 SECOND)
				if (QDELETED(src)) return
				if (!ispath(src.contained_item))
					logTheThing(LOG_DEBUG, src, "has a non-path contained_item, \"[src.contained_item]\", and is being disposed of to prevent errors")
					qdel(src)
					return
				else if (src.item_amount == 0 && length(src.contents)) // count if we already have things inside!
					for (var/obj/item/thing in src.contents)
						if (istype(thing, src.contained_item))
							src.item_amount++
				src.inventory_counter.update_number(src.item_amount)

	get_desc()
		if (src.item_amount > 15 || src.item_amount == -1)
			. += "There's a whole, whole lot of things inside. Dang!"
		else if (src.item_amount >= 1)
			. += "There's [src.item_amount] thing[src.item_amount == 1 ? "" : "s"] inside."
		else
			. += "It's empty."

	attack_self(mob/user as mob)
		if (src.reusable)
			src.open = !src.open
		else if (!src.open)
			src.open = 1
		else
			boutput(user, SPAN_ALERT("[src] is already open!"))
		src.UpdateIcon()
		return

	attackby(obj/item/W, mob/living/user)
		if (!src.add_to(W, user))
			return ..()

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if (user.is_in_hands(src))
			if (!src.open)
				src.AttackSelf(user)
				if (!src.open)
					return ..()
			var/obj/item/I = src.take_from()
			if (I)
				user.put_in_hand_or_drop(I)
				boutput(user, "You take \an [I] out of [src].")
				src.UpdateIcon()
				return
			else
				boutput(user, SPAN_ALERT("[src] is empty!"))
				return ..()
		else
			return ..()

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (usr?.is_in_hands(src))
			if (!src.open)
				boutput(usr, SPAN_ALERT("[src] isn't open, you goof!"))
				return
			if (!src.item_amount)
				boutput(usr, SPAN_ALERT("[src] is empty!"))
				return
			var/turf/T = over_object
			if (istype(T, /obj/table))
				T = get_turf(T)
			if (!(usr in range(1, T)))
				return
			if (istype(T))
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					usr.visible_message(SPAN_ALERT("[usr] dumps a bunch of patches from [src] onto [T]!"))
					for (var/i = rand(3,8), i>0, i--)
						var/obj/item/I = src.take_from()
						if (!I)
							break
						I.set_loc(T)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (user.restrained() || user.getStatusDuration("unconscious") || user.sleeping || user.stat || user.lying)
			return
		if (!in_interact_range(user, src) || !in_interact_range(user, O))
			boutput(user, SPAN_ALERT("That's too far away!"))
			return
		if (!istype(O, src.contained_item))
			boutput(user, SPAN_ALERT("[O] doesn't fit in [src]!"))
			return
		if (!src.open)
			boutput(user, SPAN_ALERT("[src] isn't open, you goof!"))
			return

		user.visible_message(SPAN_NOTICE("[user] begins quickly filling [src]!"))
		var/staystill = user.loc
		for (var/obj/item/thing in view(1,user))
			if (src.item_amount >= src.max_item_amount && !(src.max_item_amount == -1))
				break
			if (!istype(thing, src.contained_item))
				continue
			if (thing in user)
				continue
			if (thing in src)
				continue
			src.add_to(thing, user, 0)
			sleep(0.2 SECONDS)
			if (user.loc != staystill)
				break
		boutput(user, SPAN_NOTICE("You finish filling [src]!"))


	proc/set_contained_items()

	proc/take_from()
		var/obj/item/myItem = locate(src.contained_item) in src
		if (myItem)
			if (src.item_amount >= 1)
				src.item_amount--
				tooltip_rebuild = 1
			src.UpdateIcon()
			return myItem
		else if (src.item_amount != 0) // should be either a positive number or -1
			if (src.item_amount >= 1)
				src.item_amount--
				tooltip_rebuild = 1
			var/obj/item/newItem = new src.contained_item(src)
			src.UpdateIcon()
			return newItem
		else
			return 0

	proc/add_to(var/obj/item/I, var/mob/user, var/show_messages = 1)
		if (!I)
			return 0
		if (!user && usr)
			user = usr
		if (islist(src.contained_item) && !(I.type in src.contained_item))
			if (user && show_messages)
				boutput(user, SPAN_ALERT("[I] doesn't fit in [src]!"))
			return 0
		if (!istype(I, src.contained_item))
			if (user && show_messages)
				boutput(user, SPAN_ALERT("[I] doesn't fit in [src]!"))
			return 0
		if (src.reusable && (!(src.item_amount >= src.max_item_amount) || src.max_item_amount == -1))
			if (!src.open)
				if (user && show_messages)
					boutput(user, SPAN_ALERT("[src] isn't open, you goof!"))
				return 0
			if (src.item_amount != -1)
				src.item_amount ++
				tooltip_rebuild = 1
			src.UpdateIcon()
			if (user && show_messages)
				boutput(user, "You stuff [I] into [src].")
				user.u_equip(I)
			I.set_loc(src)
			return 1
		else
			if (user && show_messages)
				boutput(user, SPAN_ALERT("You can't seem to make [I] fit into [src]."))
			return 0

	update_icon()

		src.inventory_counter.update_number(src.item_amount)
		if (src.open && !src.item_amount)
			src.icon_state = src.icon_empty
		else if (src.open && src.item_amount)
			src.icon_state = src.icon_open
		else if (!src.open && !src.item_amount)
			if (src.icon_closed_empty)
				src.icon_state = src.icon_closed_empty
			else
				src.icon_state = src.icon_closed
		else
			src.icon_state = src.icon_closed
