//So much fun!

/obj/monkey_barrel
	name = "mysterious barrel"
	desc = "More fun than a ValuChimp!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel"
	throwforce = 50
	p_class = 3
	is_syndicate = 1
	density = 1
	open_inv_anywhere = TRUE
	var/mob/living/carbon/human/npc/monkey/angry/dummy
	var/monkeys_to_spawn = 5

	New()
		..()
		var/obj/item/barrel_signaller/M = new /obj/item/barrel_signaller(src.loc)
		new /obj/item/clothing/suit/monkey(src.loc)
		src.dummy = new/mob/living/carbon/human/npc/monkey/angry
		SPAWN(0)
			src.dummy.loc = src
			src.contents += src.dummy
			M.my_barrel = src

	update_icon()

		return

	verb/Holographic_Clothing()
		set src in oview(1)
		set category = "Local"
		if (ishuman(usr) && src.dummy)
			var/mob/living/carbon/human/user = usr
			src.dummy.show_inv(user)

	proc/monkey_go()
		var/turf/targetTurf = get_turf(src)
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(targetTurf)
		for (var/i = src.monkeys_to_spawn,i>=0,i--)
			var/mob/living/carbon/human/npc/monkey/angry/barrel/monke = new /mob/living/carbon/human/npc/monkey/angry/barrel (targetTurf)
			monke.copy_clothes(src.dummy)
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

/obj/item/clothing/head/holohat // not the best way to do this maybe?
	name = "Holographic Hat"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/under/holojumpsuit
	name = "Holographic Jumpsuit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/suit/holosuit
	name = "Holographic Suit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/mask/holomask
	name = "Holographic Mask"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/shoes/holoshoes
	name = "Holographic Shoes"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/ears/holoears
	name = "Holographic Earpiece"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)

/obj/item/clothing/gloves/hologloves
	name = "Holographic Gloves"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(src.loc)
		qdel(src)
