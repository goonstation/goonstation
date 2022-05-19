/obj/machinery/networked/custom
	name = "Server"
	desc = "A Nanotrasen Programmable Power Networking Interface, what a mouthful."
	density = 1
	anchored = 1
	icon_state = "custom_servere"
	device_tag = "PNET_CUSTOM_SERVER"
	timeout = 30

	var/locked = 0
	var/obj/item/disk/data/tape = null

	var/list/globalVariables //A list of all the variables and their stored values
	var/list/privateVariables //A list of all the variables and their stored values, used in functions

	proc/readingorwriting()
		flick("custom_server1")

		var/turf/T = get_turf()
		if (!T)
			return

		playsound(T, pick(ambience_computer), 50, 1)

	//Load program from tape
	proc/load_program()
		if (!src.tape)
			return
		src.program = src.tape.contents

	proc/clear_variables()
		src.globalVariables.Cut()
		src.privateVariables.Cut()

	proc/inteperet_line(var/line)
		switch (string)

	power_change()
		if (!src.tape)
			icon_state = "custom_servere"
			return

		else if (powered())
			icon_state = "custom_server"
			status &= ~NOPOWER

		else
			SPAWN(rand(0, 15))
				icon_state = "custom_server0"
				status |= NOPOWER

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/disk/data/tape/)) //INSERT SOME TAPES
			if (src.tape)
				boutput(user, "<span class='alert'>There is already a tape in the drive.</span>")
				return
			if (src.locked)
				boutput(user, "<span class='alert'>The cover is screwed shut.</span>")
				return
			user.drop_item()
			W.set_loc(src)
			src.tape = W
			boutput(user, "You insert [W].")
			src.power_change()
			return

		else if (isscrewingtool(W))
			playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
			src.locked = !src.locked
			src.panel_open = !src.locked
			boutput(user, "You [src.locked ? "secure" : "unscrew"] the cover.")
			return

		else
			..()

		return
