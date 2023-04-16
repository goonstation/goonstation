//So much fun!

/obj/storage/monkey_barrel
	name = "mysterious barrel"
	desc = "More fun than a ValuChimp!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel"
	throwforce = 50
	p_class = 3
	locked = 1
	is_syndicate = 1
	spawn_contents = list(/mob/living/carbon/human/npc/monkey/angry = 6)

	New()
		..()
		var/obj/item/barrel_signaller/M = new /obj/item/barrel_signaller(src.loc)
		new /obj/item/clothing/suit/monkey(src.loc)
		SPAWN(0)
			M.my_barrel = src

	is_acceptable_content(atom/A)
		return istype(A, /mob/living/carbon/human/npc/monkey)

	update_icon()

		return


/obj/item/barrel_signaller
	name = "mysterious signaller"
	desc = "For monkey business only."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel_signaller"
	w_class = W_CLASS_TINY
	var/obj/storage/monkey_barrel/my_barrel = null
	is_syndicate = 1

	attack_self()
		if (isliving(usr))
			if (my_barrel)
				var/turf/location = get_turf(my_barrel.loc)
				if(location)
					elecflash(my_barrel,power=3)
					playsound(my_barrel.loc, 'sound/effects/Explosion1.ogg', 75, 1)
				logTheThing(LOG_COMBAT, usr, "explodes a barrel of monkeys at [log_loc(src.my_barrel.loc)].")
				my_barrel.visible_message("<span class='alert'>\The [my_barrel] explodes!</span>")
				my_barrel.dump_contents()
				qdel(my_barrel)
				qdel(src)

