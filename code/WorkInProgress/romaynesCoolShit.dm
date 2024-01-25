
/obj/item/devbutton
	name = "Romayne's Coding Button"
	desc = "What's it do? Who the fuck knows? Do you want to find out?"
	icon = 'icons/obj/items/bell.dmi'
	icon_state = "bell_kitchen"

/obj/item/devbutton/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bell_ring.ogg', 30, FALSE)
	// Code fuckery goes here
	src.mult_test(user)

/// Used to create tanks which react and explode at different speeds to test reaction speed shenanagains
/obj/item/devbutton/proc/mult_test(mob/user)

	var/obj/item/tank/imcoder/tank1 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank2 = new /obj/item/tank/imcoder()
	var/obj/item/tank/imcoder/tank3 = new /obj/item/tank/imcoder()

	tank1.creator = user
	tank2.creator = user
	tank3.creator = user

	tank1.air_contents.toxins = 3 MOLES
	tank1.air_contents.oxygen = 24 MOLES
	tank1.air_contents.temperature = 500 KELVIN
	tank1.name = "Mult = 1"

	tank2.air_contents.toxins = 3 MOLES
	tank2.air_contents.oxygen = 24 MOLES
	tank2.air_contents.temperature = 500 KELVIN
	tank2.air_contents.test_mult = 2
	tank2.name = "Mult = 2"

	tank3.air_contents.toxins = 3 MOLES
	tank3.air_contents.oxygen = 24 MOLES
	tank3.air_contents.temperature = 500 KELVIN
	tank3.air_contents.test_mult = 0.5
	tank3.name = "Mult = 0.5"

	tank1.loc = user.loc
	tank2.loc = user.loc
	tank3.loc = user.loc
