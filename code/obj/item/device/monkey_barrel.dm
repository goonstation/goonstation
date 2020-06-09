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
		var/obj/item/barrel_signaller/M = new /obj/item/barrel_signaller(src.loc)
		SPAWN_DBG(0)
			M.my_barrel = src


/obj/item/barrel_signaller
	name = "mysterious signaller"
	desc = "For monkey business only."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "barrel_signaller"
	w_class = 1.0
	var/obj/storage/monkey_barrel/my_barrel = null
	is_syndicate = 1

	attack_self()
		if (isliving(usr))
			if (my_barrel)
				var/turf/location = get_turf(my_barrel.loc)
				if(location)
					var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
					s.set_up(5, 1, my_barrel)
					s.start()
					playsound(my_barrel.loc, "sound/effects/Explosion1.ogg", 75, 1)
				logTheThing("combat", usr, null, "explodes a barrel of monkeys at [log_loc(src.my_barrel.loc)].")
				my_barrel.visible_message("<span style=\"color:red\">\The [my_barrel] explodes!</span>")
				my_barrel.dump_contents()
				qdel(my_barrel)
				qdel(src)

