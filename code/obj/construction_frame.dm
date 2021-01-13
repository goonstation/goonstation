/obj/construction_frame
	icon = 'icons/obj/construction_frame.dmi'
	anchored = 0
	density = 1
	proc/updateicon()

/obj/item/circuit // not to be confused with /obj/item/circuitboard (i'll merge these someday okay)
	name = "circuit board"
	icon = 'icons/obj/module.dmi'

	smes
		name = "SMES control circuit"
		icon_state = "smes"

/obj/construction_frame/smes
	name = "SMES frame"
	desc = "An unfinished SMES."
	icon_state = "smes0"

	var/obj/item/coil/large/coil
	var/obj/item/circuit/circuitboard
	var/circuit_secured = 0
	var/wired = 0

	updateicon()
		if (!coil)
			icon_state = "smes0"
		else if (!circuitboard)
			icon_state = "smes2"
		else if (!wired)
			icon_state = "smes3"
		else
			icon_state = "smes4"

	attackby(obj/item/W, mob/user)
		if (!coil)
			if (istype(W, /obj/item/coil/large))
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				user.drop_item()
				W.set_loc(src)
				coil = W
				boutput(user, "<span class='notice'>You insert the coil.</span>")
		else if (!circuitboard)
			if (istype(W, /obj/item/circuit/smes))
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				user.drop_item()
				W.set_loc(src)
				circuitboard = W
				circuit_secured = 0
				boutput(user, "<span class='notice'>You insert the control circuitry.</span>")
		else if (!circuit_secured)
			if (isscrewingtool(W))
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				circuit_secured = 1
				boutput(user, "<span class='notice'>You secure the control circuitry.</span>")
		else if (!wired)
			if (istype(W, /obj/item/cable_coil))
				var/obj/item/cable_coil/coil = W
				if (coil.amount >= 5)
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					coil.amount -= 5
					if (!coil.amount)
						qdel(coil)
					wired = 1
					boutput(user, "<span class='notice'>You wire up the circuitry.</span>")
				else
					boutput(user, "<span class='notice'>You're going to need more cable for this.</span>")
		else
			if (istype(W, /obj/item/sheet))
				var/obj/item/sheet/sheet = W
				if (!sheet.material)
					boutput(user, "<span class='notice'>This kind of sheets wont work!</span>")
					return
				if (sheet.amount >= 3)
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					sheet.amount -= 3
					if (!sheet.amount)
						qdel(sheet)
					boutput(user, "<span class='notice'>You add the outer shell.</span>")
					var/obj/machinery/power/smes/smes = new(src.loc)
					smes.setMaterial(sheet.material)
					qdel(src)
				else
					boutput(user, "<span class='notice'>You're going to need more sheets for this.</span>")

		src.updateicon()
