/obj/item/device/lollipopmaker
	name = "lollipop synthesizer"
	desc = "A portable synthesizer used to make fruity treats."
	icon_state = "lollipop-h"
	var/rechargeable = false
	var/swappable = false
	var/cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	var/cost = 40


	New()
		. = ..()
		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable, cost, rechargeable)

	examine(mob/user)
		. = ..()
		if (isrobot(user))
			return // Drains battery instead.
		var/list/ret = list()
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
			. += "<span class='alert'>No power cell installed.</span>"
		else
			. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each use will consume [cost]PU."

	attack_self(var/mob/user as mob)

		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(usr, "<span class='alert'>It's out of charge.</span>")
			return

		if (ON_COOLDOWN(src, "vend_cooldown", 10 SECONDS))
			user.show_text("It's still recharging, give it a moment.", "red")
			return

		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			R.cell.charge -= cost * 10
			SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
			new /obj/item/reagent_containers/food/snacks/lollipop/fruit(get_turf(src))
			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			user.visible_message("<span class='notice'>[user] dispenses a lollipop.</span>")
		else
			SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
			new /obj/item/reagent_containers/food/snacks/lollipop/fruit(get_turf(src))
			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			user.visible_message("<span class='notice'>[user] dispenses a lollipop.</span>")

/obj/item/device/lollipopmaker/md
		name = "NT Lollipop Synthesizer"
		desc = "It's like the green ones but the Medical Director owns this one."
		icon_state = "lollipop-hmd"
