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
	open_inv_within = TRUE
	var/mob/living/carbon/human/npc/monkey/angry/template_monkey // spawns first, copies clothing icons to spawned monkeys
	var/monkeys_to_spawn = 5

	New()
		..()
		var/obj/item/barrel_signaller/M = new /obj/item/barrel_signaller(src.loc)
		new /obj/item/clothing/suit/monkey(src.loc)
		src.template_monkey = new/mob/living/carbon/human/npc/monkey/angry(src)
		src.contents += src.template_monkey
		src.template_monkey.real_name = "Holo-Clothes Template"
		M.my_barrel = src

	update_icon()

		return

	verb/Holographic_Clothing()
		set src in oview(1)
		set category = "Local"
		if (ishuman(usr) && src.template_monkey)
			var/mob/living/carbon/human/user = usr
			src.template_monkey.show_inv(user)

	proc/monkey_go()
		var/turf/targetTurf = get_turf(src)
		var/obj/itemspecialeffect/poof/poof = new /obj/itemspecialeffect/poof
		poof.setup(targetTurf)
		for (var/i in 1 to src.monkeys_to_spawn)
			var/mob/living/carbon/human/npc/monkey/angry/barrel/monke = new (targetTurf)
			monke.copy_clothes(src.template_monkey)

		for (var/atom/movable/thing in src.contents)// remove anything inside when deleting
			if (src.template_monkey == thing)
				var/mob/living/carbon/human/monke = thing
				monke.unequip_all(FALSE, src.loc) // get your clothes back!
				qdel(thing)
				continue
			src.contents -= thing
			thing.set_loc(get_turf(src))
		qdel(src)

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
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/under/holojumpsuit
	name = "Holographic Jumpsuit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/suit/holosuit
	name = "Holographic Suit"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/mask/holomask
	name = "Holographic Mask"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/shoes/holoshoes
	name = "Holographic Shoes"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/ears/holoears
	name = "Holographic Earpiece"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)

/obj/item/clothing/gloves/hologloves
	name = "Holographic Gloves"
	desc = "At what point is it just cheaper to give them real clothes..?"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bald"

	unequipped(mob/user)
		. = ..()
		SPAWN(1 SECONDS)
			qdel(src)
