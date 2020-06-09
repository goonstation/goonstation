/obj/machinery/tripod
	name = "tripod"
	icon = 'icons/obj/tripod.dmi'
	icon_state = "tripod"
	density = 1
	anchored = 1

	machine_registry_idx = MACHINES_MISC
	var/obj/item/tripod_bulb/bulb = null

	attack_hand(mob/user)
		if (can_reach(user,src))
			if (bulb)
				bulb.removed(src)
				user.put_in_hand_or_drop(bulb)
				bulb = null
				src.updateicon()
			else
				boutput(user, "<span style=\"color:blue\">You fold up the tripod.</span>")
				var/obj/item/tripod/I = new()
				if (src.material)
					I.setMaterial(src.material)
				user.put_in_hand_or_drop(I)
				qdel(src)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tripod_bulb) && !bulb)
			user.drop_item()
			bulb = W
			W.loc = src
			bulb.inserted(src)
			src.updateicon()

	process()
		if (bulb)
			bulb.process(src)

	proc
		updateicon()
			src.overlays.len = 0
			if (bulb)
				bulb.updateicon(src)

/obj/item/tripod
	name = "folded tripod"
	icon = 'icons/obj/tripod.dmi'
	icon_state = "folded"

	attack_self(mob/user)
		var/obj/machinery/tripod/tripod = new(user.loc)
		if (src.material)
			tripod.setMaterial(src.material)
		user.u_equip(src)
		qdel(src)

/obj/item/tripod_bulb // TODO: draw power from the tripod battery or w/e
	name = "bulb"
	icon = 'icons/obj/tripod.dmi'

	proc
		removed()
		inserted()
		updateicon()

	light
		name = "big bulb"
		icon_state = "light_bulb"
		var
			datum/light/light

		New()
			..()
			light = new /datum/light/point
			light.set_brightness(1.2)
			light.set_height(1.5)

		inserted(obj/machinery/tripod/tripod)
			light.attach(tripod)
			light.enable()

		removed(obj/machinery/tripod/tripod)
			light.disable()
			light.detach()

		updateicon(obj/machinery/tripod/tripod)
			tripod.overlays += "tripod_light"

	beacon
		name = "beacon bulb"
		icon_state = "beacon_bulb"
		var
			beacon_name = "beacon"
			datum/light/light

		New()
			..()
			light = new /datum/light/point
			light.set_brightness(0.6)
			light.set_color(0.2, 0.2, 0.7)
			light.set_height(1.5)

		inserted(obj/machinery/tripod/tripod)
			tripod.name = src.beacon_name
			light.attach(tripod)
			light.enable()

		removed(obj/machinery/tripod/tripod)
			tripod.name = initial(tripod.name)
			light.disable()
			light.detach()

		updateicon(obj/machinery/tripod/tripod)
			tripod.overlays += "tripod_beacon"

		attack_self(mob/user)
			var/name = copytext(input(user, "What would you like to name this beacon?", "Beacon name", src.beacon_name), 1, 26)
			if (length(name) > 0)
				src.beacon_name = name
				src.name = "beacon bulb ([src.beacon_name])"
