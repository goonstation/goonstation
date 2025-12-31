//So much fun!

/obj/monkey_barrel
	name = "mysterious barrel"
	desc = "More fun than a ValuChimp!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel"
	throwforce = 50
	p_class = 3
	is_syndicate = 1
	var/number_of_monkeys = 6
	var/list/hats
	var/list/unders
	var/list/suits
	var/list/masks
	var/list/shoes
	var/list/ears
	var/list/gloves

	New()
		..()
		var/obj/item/barrel_signaller/M = new /obj/item/barrel_signaller(src.loc)
		new /obj/item/clothing/suit/monkey(src.loc)
		SPAWN(0)
			M.my_barrel = src

	update_icon()

		return

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/clothing))
			user.drop_item(I)
			src.contents += I
			I.set_loc(src)

	verb/Eject_Clothes()
		set src in oview(1)
		set category = "Local"
		src.drop_contents()

	proc/monkey_go()
		var/turf/targetTurf = get_turf(src)
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(targetTurf)

		for (var/obj/item/clothing/item in src.contents) // TELL me if there's a better way to do this without putting a dummy mob in the barrel
			if (istype(item, /obj/item/clothing/head))
				src.hats += item
				continue
			if (istype(item, /obj/item/clothing/under))
				src.unders += item
				continue
			if (istype(item, /obj/item/clothing/suit))
				src.suits += item
				continue
			if (istype(item, /obj/item/clothing/mask))
				src.masks += item
				continue
			if (istype(item, /obj/item/clothing/shoes))
				src.shoes += item
				continue
			if (istype(item, /obj/item/clothing/ears))
				src.ears += item
				continue
			if (istype(item, /obj/item/clothing/gloves))
				src.gloves += item
		// might have to create the clothing after changing its icons (ughghghghgh)
		for (var/i = src.number_of_monkeys,i>=0,i--)
			var/mob/living/carbon/human/npc/monkey/angry/barrel/monke = new /mob/living/carbon/human/npc/monkey/angry/barrel (targetTurf)
			sleep(0.2 SECONDS)
			for (var/slot in all_slots)
				var/obj/item/clothing/holo = monke.get_slot(slot)
				if (!holo)
					continue
				if (!holo.holographic)
					continue
				var/obj/item/clothing/transmog
				switch (slot)
					if (SLOT_HEAD)
						transmog = pick(src.hats)
					if (SLOT_W_UNIFORM)
						transmog = pick(src.unders)
				if (transmog)
					holo.wear_image_icon = transmog.wear_image_icon
					holo.wear_state = transmog.wear_state

		src.drop_contents()
		qdel(src)

	proc/drop_contents()
		for (var/atom/movable/thing in src.contents)
			src.contents -= thing
			thing.set_loc(get_turf(src))

/obj/item/barrel_signaller
	name = "mysterious signaller"
	desc = "For monkey business only."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel_signaller"
	w_class = W_CLASS_TINY
	var/obj/monkey_barrel/my_barrel = null
	is_syndicate = 1

	attack_self()
		if (isliving(usr))
			if (my_barrel)
				var/turf/location = get_turf(my_barrel.loc)
				if(location)
					elecflash(my_barrel,power=3)
					playsound(my_barrel.loc, 'sound/effects/Explosion1.ogg', 75, 1)
				logTheThing(LOG_COMBAT, usr, "explodes a barrel of monkeys at [log_loc(src.my_barrel.loc)].")
				my_barrel.visible_message(SPAN_ALERT("\The [my_barrel] explodes!"))
				my_barrel.monkey_go()
				qdel(src)

/obj/item/clothing/head/holohat
	name = "Holographic Hat"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE // ooohh my god

/obj/item/clothing/under/holojumpsuit
	name = "Holographic Jumpsuit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE // I'm doing this cause I don't think I can just insert a holo type to check for after clothing but before the clothing type

/obj/item/clothing/suit/holosuit
	name = "Holographic Suit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE

/obj/item/clothing/mask/holomask
	name = "Holographic Mask"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE

/obj/item/clothing/shoes/holoshoes
	name = "Holographic Shoes"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE

/obj/item/clothing/ears/holoears
	name = "Holographic Earpiece"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE

/obj/item/clothing/gloves/hologloves
	name = "Holographic Gloves"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	wear_state = "bald"
	holographic = TRUE

