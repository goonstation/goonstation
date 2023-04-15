TYPEINFO(/obj/machinery/photocopier)
	mats = 16 //just to make photocopiers mech copyable, how could this possibly go wrong?

/obj/machinery/photocopier
	name = "photocopier"
	desc = "This machine uses paper to copy photos, work documents... anything paper-based, really. "
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/machines/photocopier.dmi'
	icon_state = "close_sesame"
	pixel_x = 2 //its just a bit limited by sprite width, needs a small offset
	power_usage = 10
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/use_state = 0 //0 is closed, 1 is open, 2 is busy, closed by default
	var/paper_amount = 0.0 //starts at 0.0, increments by one for every paper added, max of... 30 sheets
	var/make_amount = 0 //from 0 to 30, amount of copies the photocopier will copy, copy?

	var/list/paper_info = list()//index 1 is name, index 2 is desc, index 3 is info
	var/list/photo_info = list()//index 1 is name, index 2 is desc, index 3 is fullImage, index 4 is fullIcon
	var/list/paper_photo_info = list() //index 1 is desc, index 2 is print_icon, index 3 is print_icon_state
	var/butt_stuff = 0 //uwu its me im the funniest joke queen

	get_desc(dist)
		var/desc_string = ""

		if (dist > 4)
			desc_string += "It's too far away to make out anything specific!"
			return desc_string

		switch(use_state)
			if (0)
				desc_string += "\The [src] is closed. "
			if (1)
				desc_string += "\The [src] is open. "
			if (2)
				desc_string += "\The [src] is busy! "
			else //just in case
				desc_string += "call 1-800-coder today (mention use_state) "

		if (make_amount)
			desc_string += "The counter shows that \the [src] is set to make [make_amount] "
			if (make_amount > 1)
				desc_string += "copies."
			else
				desc_string += "copy."

		if (paper_amount <= 0)
			desc_string += "There's no paper left! "
			return desc_string
		desc_string += "It's "
		if (paper_amount <= 5)
			desc_string += "less than 1/3 "
		else if (paper_amount <= 10)
			desc_string += "about 1/3 "
		else if (paper_amount <= 15)
			desc_string += "less than 2/3 "
		else if (paper_amount <= 20)
			desc_string += "about 2/3 "
		else if (paper_amount <= 25)
			desc_string += "close to being "
		else if (paper_amount == 30)
			desc_string += ""
		else
			desc_string += "nearly "
		desc_string += "full. "

		return desc_string

	attackby(var/obj/item/w, var/mob/user) //handles reloading with paper, scanning paper, scanning photos, scanning paper photos
		if (src.use_state == 2) //photocopier is busy?
			boutput(user, "<span class='alert'>/The [src] is busy! Try again later!</span>")
			return

		else if (src.use_state == 1) //is the photocopier open?
			if (istype(w, /obj/item/paper) || istype(w, /obj/item/clothing/head/butt) || istype(w, /obj/item/photo)) //what items can we scan on the photocopier?
				if (istype(w, /obj/item/paper/book)) //all subtypes of paper that ARENT printout should go here, but book might be the only one? this is hopefully good for now
					return
				src.reset_all()
				src.use_state = 2
				user.drop_item()
				w.set_loc(src)
				if (istype(w, /obj/item/clothing/head/butt))
					src.icon_state = "buttt"
					boutput(user, "You slap the ass (hot) on the scan bed, close the lid, and press start...")
				else
					src.icon_state = "papper"
					if (istype(w, /obj/item/paper/printout) || istype(w, /obj/item/photo))
						boutput(user, "You put the picture on the scan bed, close the lid, and press start...")
					else
						boutput(user, "You put the paper on the scan bed, close the lid, and press start...")
				sleep(0.3 SECONDS)
				src.icon_state = "close_sesame"
				flick("scan", src)
				playsound(src.loc, 'sound/machines/scan.ogg', 50, 1)
				sleep(1.8 SECONDS)
				src.icon_state = "open_sesame"
				w.set_loc(get_turf(src))
				src.visible_message("\The [src] finishes scanning and opens automatically!")
				src.use_state = 1

				if (istype(w, /obj/item/paper/printout))
					var/obj/item/paper/printout/P = w
					src.paper_photo_info += P.desc
					src.paper_photo_info += P.print_icon
					src.paper_photo_info += P.print_icon_state

				else if (istype(w, /obj/item/paper))
					var/obj/item/paper/P = w
					src.paper_info["name"] = P.name
					src.paper_info["desc"] = P.desc
					src.paper_info["info"] = P.info
					src.paper_info["stamps"] = P.stamps.Copy()
					src.paper_info["form_fields"] = P.form_fields
					src.paper_info["field_counter"] = P.field_counter
					src.paper_info["icon_state"] = P.icon_state
					src.paper_info["overlays"] = P.overlays

				else if (istype(w, /obj/item/clothing/head/butt))
					src.butt_stuff = 1

				else if (istype(w, /obj/item/photo))
					var/obj/item/photo/P = w
					src.photo_info += P.name
					src.photo_info += P.desc
					src.photo_info += P.fullImage
					src.photo_info += P.fullIcon
			return

		else //photocopier is closed? if someone varedits use state this'll screw up but if they do theyre dumb so
			if (istype(w, /obj/item/paper))
				if (src.paper_amount >= 30.0)
					boutput(user, "<span class='alert'>You can't fit any more paper into \the [src].</span>")
					return
				var/obj/item/paper/P = w
				if (P.info != "" && tgui_alert(user, "This paper has writing on it, are you sure you want to put it in the inlet tray?", "Warning", list("Yes", "No")) == "No")
					return
				boutput(user, "You load the sheet of paper into \the [src].")
				src.paper_amount++
				qdel(w)
				return

			else if (istype(w, /obj/item/paper_bin))
				if ((w.amount + src.paper_amount) > 30.0)
					boutput(user, "<span class='alert'>You can't fit any more paper into \the [src].</span>")
					return
				boutput(user, "You load the paper bin into \the [src].")
				var/obj/item/paper_bin/P = w
				src.paper_amount += w.amount
				P.amount = 0
				P.update()
				return

		..()

	attack_hand(var/mob/user) //handles choosing amount, printing, scanning
		if (src.use_state == 2)
			boutput(user, "<span class='alert'>\The [src] is busy right now! Try again later!</span>")
			return
		var/mode_sel = tgui_input_list(user, "Which do you want to do?", "Photocopier Controls", list("Reset Memory", "Print Copies", "Adjust Amount", "Toggle Lid"))
		if (BOUNDS_DIST(user, src) == 0)
			if (!mode_sel)
				return
			switch(mode_sel)
				if ("Reset Memory")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					src.reset_all()
					playsound(src.loc, 'sound/machines/bweep.ogg', 20, 1)
					boutput(user, "<span class='notice'>You reset \the [src]'s memory.</span>")
					return

				if ("Print Copies")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					src.icon_state = "close_sesame"
					src.visible_message("\The [src] starts printing copies!")
					make_amount = min(make_amount, 30)
					if (paper_amount <= 0)
						src.visible_message("No more paper in tray!")
						return
					src.use_state = 2
					for (var/i = 1, i <= src.make_amount, i++)
						if (paper_amount <= 0)
							break
						flick("print", src)
						sleep(1.8 SECONDS)
						playsound(src.loc, 'sound/machines/printer_thermal.ogg', 30, 1)
						use_power(5)
						paper_amount --
						src.print_stuff()
					src.use_state = 0
					src.icon_state = "close_sesame"
					src.visible_message("\The [src] finishes its print job.")
					return

				if ("Adjust Amount")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					var/num_sel = input("How many copies do you want to make?", "Photocopier Controls") as num
					if (isnum_safe(num_sel) && num_sel && BOUNDS_DIST(user, src) == 0)
						if (num_sel <= src.paper_amount)
							src.make_amount = num_sel
							playsound(src.loc, 'sound/machines/ping.ogg', 20, 1)
							boutput(user, "Amount set to: [num_sel] sheets.")
							return
						else
							boutput(user, "<span class='alert'>There's not enough paper for that!</span>")
							return

				if ("Toggle Lid")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					if (src.icon_state == "open_sesame")
						src.icon_state = "close_sesame"
						src.use_state = 0
					else
						src.icon_state = "open_sesame"
						src.use_state = 1

	proc/print_stuff() //handles printing photos, papers
		if (src.paper_info.len)
			var/obj/item/paper/P = new(get_turf(src))
			P.name = src.paper_info["name"]
			P.desc = src.paper_info["desc"]
			P.info = src.paper_info["info"]
			P.stamps = src.paper_info["stamps"]
			P.stamps = P.stamps.Copy()
			P.form_fields = src.paper_info["form_fields"]
			P.field_counter = src.paper_info["field_counter"]
			P.icon_state = src.paper_info["icon_state"]
			P.overlays = src.paper_info["overlays"]

		else if (src.photo_info.len)
			var/obj/item/photo/P = new(get_turf(src))
			P.name = src.photo_info[1]
			P.desc = src.photo_info[2]
			P.fullImage = src.photo_info[3]
			P.fullIcon = src.photo_info[4]
//			i just copypasted all this garbage over from pictures because thats the only way this worked, idk if any of this is extraneous sorry
			var/oldtransform = P.fullImage.transform
			P.fullImage.transform = matrix(0.6875, 0.625, MATRIX_SCALE)
			P.fullImage.pixel_y = 1
			P.overlays += P.fullImage
			P.fullImage.transform = oldtransform
			P.fullImage.pixel_y = 0

		else if (src.paper_photo_info.len)
			var/obj/item/paper/printout/P = new(get_turf(src))
			P.desc = src.paper_photo_info[1]
			P.print_icon = src.paper_photo_info[2]
			P.print_icon_state = src.paper_photo_info[3]

		else if (src.butt_stuff)
			var/obj/item/paper/P = new(get_turf(src))
			P.name = "butt"
			P.desc = "butt butt butt"
			P.info = "{<b>butt butt butt butt butt butt<br>butt butt<br>butt</b>}" //6 butts then 2 butts then 1 butt haha
			P.icon = 'icons/obj/surgery.dmi'
			P.icon_state = "butt"

		else
			new/obj/item/paper(get_turf(src))

		return

	proc/reset_all()
		paper_info = list()
		photo_info = list()
		paper_photo_info = list()
		butt_stuff = 0
