#define PHOTOCOPIER_MAX_SHEETS 30
#define PHOTOCOPIER_RADIO_RANGE 16

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
	var/use_state = 0 // 0 is closed, 1 is open, 2 is busy, closed by default
	var/paper_amount = 15 // amount of paper currently in the photocopier
	var/print_amount = 1 // from 1 to PHOTOCOPIER_MAX_SHEETS, amount of copies the photocopier will copy, copy?
	var/emagged = FALSE
	var/ignore_paper = FALSE // Ignore all paper costs
	var/obj/item/scan_peek = null // A copy of the scanned item for silicons to look at

	var/list/print_info = list() // Data of the item to print
	var/print_type = "" // The type of item to print
	var/sheets_per_item = 1 // how many sheets each item costs. Each sheet uses its own printing cycle
	var/sheets_left = 1 // how many sheets have been printed for this item

	var/net_id = ""
	var/frequency = FREQ_FREE

	New()
		..()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

	get_desc(dist)
		var/desc_string = ""

		if (dist > 4)
			desc_string += "It's too far away to make out anything specific!"
			return desc_string

		switch(use_state)
			if (0)
				desc_string += "The scanner is closed. "
			if (1)
				desc_string += "The scanner is open. "
			if (2)
				desc_string += "\The [src] is busy! "
			else //just in case
				desc_string += "call 1-800-coder today (mention use_state) "

		if (print_amount)
			desc_string += "The counter shows that \the [src] is set to make [print_amount] "
			if (print_amount > 1)
				desc_string += "copies. "
			else
				desc_string += "copy. "

		if (paper_amount <= 0)
			desc_string += "The paper tray is empty"
		else if (paper_amount <= (PHOTOCOPIER_MAX_SHEETS/6))
			desc_string += "The paper tray is less than 1/3 full"
		else if (paper_amount <= (PHOTOCOPIER_MAX_SHEETS/6) * 2)
			desc_string += "The paper tray is about 1/3 full"
		else if (paper_amount <= (PHOTOCOPIER_MAX_SHEETS/6) * 3)
			desc_string += "The paper tray is less than 2/3 full"
		else if (paper_amount <= (PHOTOCOPIER_MAX_SHEETS/6) * 4)
			desc_string += "The paper tray is about 2/3 full"
		else if (paper_amount <= (PHOTOCOPIER_MAX_SHEETS/6) * 5)
			desc_string += "The paper tray is close to being full"
		else if (paper_amount < PHOTOCOPIER_MAX_SHEETS)
			desc_string += "The paper tray is nearly full"
		else
			desc_string += "The paper tray is full"

		desc_string += ". "
		return desc_string

	//handles reloading with paper, scanning paper, scanning photos, scanning paper photos
	attackby(var/obj/item/w, var/mob/user)
		if (src.use_state == 2) //photocopier is busy?
			boutput(user, SPAN_ALERT("\The [src] is busy! Try again later!"))
			return
		else if (src.use_state == 1) //is the photocopier open?
			if(istype(w, /obj/item/paper_bin))
				load_stuff(w, user) // Can load using the bin even if the scanner is open
			else
				scanning(w, user)
		else
			load_stuff(w, user)
		// Doesn't matter if the scanner is open or closed here
		if(src.use_state != 2)
			if(istype(w, /obj/item/device/reagentscanner))
				var/obj/item/device/reagentscanner/R = w
				if(R.scan_results != null)
					scan_reagent_scanner(R,user)
					playsound(src.loc, 'sound/machines/ping.ogg', 5, 1)
			else if(istype(w, /obj/item/folder))
				user.drop_item()
				w.set_loc(get_turf(src))
			else if(istype(w, /obj/item/bible))
				faith_print(user)



	attack_hand(var/mob/user) //handles choosing amount, printing, scanning
		if (src.use_state == 2)
			boutput(user, SPAN_ALERT("\The [src] is busy right now! Try again later!"))
			return
		var/isUserSilicon = issilicon(user) || isAI(user)
		var/lid_str
		if (src.use_state == 0)
			lid_str = "Open Scanner"
		else if (src.use_state == 1)
			lid_str = "Close Scanner"
		var/list/sel_list = list("Print Copies", "Set Amount", lid_str, "Misc Settings")
		var/mode_sel = tgui_input_list(user, "What do you want to do?", "Photocopier Controls", sel_list)
		if (BOUNDS_DIST(user, src) == 0 || isUserSilicon)
			if (!mode_sel)
				return
			switch(mode_sel)
				if ("Print Copies")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					if(isUserSilicon)
						effect_radio()
					print_action(user)
					return

				if ("Set Amount")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					var/amount_str = "How many copies do you want to make? ([src.paper_amount] sheets available)"
					var/num_sel = input(amount_str, "Photocopier Controls") as num
					if (isnum_safe(num_sel) && num_sel && (BOUNDS_DIST(user, src) == 0 || isUserSilicon))
						src.print_amount = min(max(num_sel, 1), PHOTOCOPIER_MAX_SHEETS)
						playsound(src.loc, 'sound/machines/ping.ogg', 10, 1)
						boutput(user, "Amount set to: [num_sel] sheets.")
						if(isUserSilicon)
							effect_radio()
						return

				if ("Open Scanner")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					src.icon_state = "open_sesame"
					src.use_state = 1
					if(isUserSilicon)
						boutput(user, "You open the lid on \the [src].")
						effect_radio()
					else
						boutput(user, "You open the lid on \the [src]. You can now scan items for printing.")
				if("Close Scanner")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					src.icon_state = "close_sesame"
					src.use_state = 0
					if(isUserSilicon)
						effect_radio()
				if ("Misc Settings")
					interact_settings(user)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		. = ..()
		if(emagged)
			return
		if (src.use_state == 2) //photocopier is busy?
			boutput(user, SPAN_ALERT("\The [src] is busy! Try again later!"))
			return
		var/prev_use_state = src.use_state
		var/prev_icon = src.icon_state
		src.use_state = 2
		emagged = TRUE
		playsound(src, 'sound/effects/sparks6.ogg', 50)
		playsound(src, 'sound/machines/glitch4.ogg', 20)
		logTheThing(LOG_ADMIN, user, "emagged the photocopier at \[[log_loc(src)]]")
		if(prev_use_state == 0)
			src.icon_state = "emag_closed"
		else
			src.icon_state = "emag_open"
		sleep(4.5 * 3)
		src.icon_state = prev_icon
		src.use_state = prev_use_state

		if(user)
			boutput(user, "You disable \the [src]'s anti-counterfeiting measures.")

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (src.use_state == 2) //photocopier is busy?
			boutput(user, SPAN_ALERT("\The [src] is busy! Try again later!"))
			return
		emagged = FALSE
		src.reset_all() // reset the scan data in case an ID was scanned
		playsound(src, 'sound/effects/sparks6.ogg', 30)
		if(use_state == 0)
			flick("emag_closed",src)
		else
			flick("emag_open",src)
		if (user)
			boutput(user, SPAN_NOTICE("You reset the security settings on the [src]."))
		return 1

	proc/interact_settings(var/mob/user) // Aditional settings in a seperate menu
		var/isUserSilicon = issilicon(user) || isAI(user)
		var/list/sel_list = list("Reset Memory", "Print Network Data")
		if(isUserSilicon) // Additional option for AI & Cyborgs
			sel_list.Add("Read Scanned Data")
		var/mode_sel = tgui_input_list(user, "What do you want to do?", "Photocopier Settings", sel_list)
		if (BOUNDS_DIST(user, src) == 0 || isUserSilicon)
			if (!mode_sel)
				return
			switch(mode_sel)
				if ("Reset Memory")
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					effect_fail()
					src.reset_all()
					playsound(src.loc, 'sound/machines/bweep.ogg', 20, 1)
					boutput(user, SPAN_NOTICE("You reset \the [src]'s memory."))
					return
				if("Print Network Data")
					// Print an informative sheet detailing how to send packets to this photocopier
					if (src.use_state == 2)
						boutput(user, "\The [src] is busy right now! Try again later!")
						return
					var/prev_amount = src.print_amount // Ignore the normal copy settings. Just print one sheet.
					src.print_amount = 1
					if(isUserSilicon)
						effect_radio()
					scan_network_info()
					print_action()
					src.print_amount = prev_amount
				if("Read Scanned Data")
					if(issilicon(user) || isAI(user))
						ai_peek(user)

	proc/ai_peek(var/mob/user) // Allow silicons to see what was scanned without printing anything
		switch(src.print_type)
			if ("paper")
				if(src.scan_peek == null)
					src.scan_peek = create_paper(src.print_info)
				var/obj/item/paper/P = src.scan_peek
				P.ui_interact(user)
			if ("photo")
				var/photo_desc = src.print_info["desc"]
				boutput(user, "A scan of a photograph is stored inside \the [src]'s memory banks. [photo_desc]")
			if ("paper_photo")
				if(src.scan_peek == null)
					src.scan_peek = create_paper_photo(src.print_info)
				var/obj/item/paper/printout/P = src.scan_peek
				P.ui_interact(user)
			if("butt")
				boutput(user, "The scanned data is just an image of someone's bottom pressed against the scanner. Very mature.")
			if ("poster_wanted")
				if(src.scan_peek == null)
					src.scan_peek = create_wanted_poster(src.print_info)
				var/obj/item/poster/titled_photo/W = src.scan_peek
				W.examine(user)
			if ("booklet")
				if(src.scan_peek == null)
					src.scan_peek = create_booklet()
				var/obj/item/paper_booklet/B = src.scan_peek
				B.is_virtual = TRUE
				B.display_booklet_contents(user)
			if("folder")
				if(src.scan_peek == null)
					src.scan_peek = create_folder()
				var/obj/item/folder/F = src.scan_peek
				F.show_window(user, "peek")
			if ("cash_fake")
				var/cash_amount = src.print_info[1]
				var/plurality = (cash_amount == 1 ? " is" : "s are")
				boutput(user, "Data to print [cash_amount] discount-dan credit[plurality] stored inside \the [src]'s memory banks.")
			if ("cash")
				var/cash_amount = src.print_info[1]
				var/plurality = (cash_amount == 1 ? " is" : "s are")
				boutput(user, "Data to print [cash_amount] credit[plurality] stored inside \the [src]'s memory banks. \
				The printing of this currency is illegal under space law.")
			if("")
				boutput(user, "There are no scans stored inside \the [src]'s memory banks.")
			else
				boutput(user, "You can only tell that the scanned data is marked as '[src.print_type]'.")
	proc/faith_print(var/mob/user) // Bible can print using faith instead of paper
		var/chaplain = 0
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
			chaplain = 1
		if(chaplain == 0)
			return
		var/faith_cost = sheets_per_item * 20
		if(get_chaplain_faith(user) < 2000 + faith_cost)
			boutput(user, "\The [src] does nothing. You need more faith!")
			return
		flick("print_light", src)
		modify_chaplain_faith(user, faith_cost * -1)
		var/prev_amount = src.print_amount
		src.print_amount = 1
		src.ignore_paper = TRUE
		boutput(user, "You power the photocopier with your unwavering faith!")
		print_action(user)
		src.ignore_paper = FALSE
		src.print_amount = prev_amount

	// --------------- Printing & Loading ----------------

	proc/print_action(var/mob/user) // The printing loop
		if (src.paper_amount <= 0 && !src.ignore_paper)
			src.visible_message("No more paper in the tray!")
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 10, 1)
			effect_fail()
			return
		else if(src.paper_amount < src.sheets_per_item && !src.ignore_paper)
			src.visible_message("Need more paper to print that!")
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 10, 1)
			effect_fail()
			return

		src.icon_state = "close_sesame"
		src.visible_message("\The [src] starts printing copies!")
		var/print_cycles = src.print_amount * src.sheets_per_item
		print_cycles = min(print_cycles, PHOTOCOPIER_MAX_SHEETS)
		src.use_state = 2
		var/isFail = FALSE
		src.sheets_left = src.sheets_per_item
		for (var/i = 1, i <= print_cycles, i++)
			if (paper_amount < sheets_left && !src.ignore_paper)
				isFail = TRUE
				break
			use_power(5)
			if(!src.ignore_paper)
				src.paper_amount--
			src.sheets_left--
			src.print_stuff(user)
			if(sheets_left == 0)
				src.sheets_left = src.sheets_per_item
		src.use_state = 0
		if(isFail)
			src.visible_message("\The [src] cancels its print job.")
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 5, 1)
			effect_fail()
		else
			src.visible_message("\The [src] finishes its print job.")
			if(src.print_amount > 1 || src.sheets_per_item > 1)
				playsound(src.loc, 'sound/machines/ping.ogg', 5, 1)
		src.icon_state = "close_sesame"

	proc/print_stuff(var/mob/user) // Creates the actual items being printed
		// Check what type of item it is that is being printed
		switch(src.print_type)
			if ("paper")
				effect_printing("print")
				var/obj/item/paper/P = create_paper(src.print_info)
				P.set_loc(get_turf(src))
				try_put_in_folder(P)
			if ("photo")
				effect_printing("print")
				var/obj/item/photo/P = create_photo(src.print_info)
				P.set_loc(get_turf(src))
				try_put_in_folder(P)
			if ("paper_photo")
				effect_printing("print")
				var/obj/item/paper/printout/P = create_paper_photo(src.print_info)
				P.set_loc(get_turf(src))
				try_put_in_folder(P)
			if ("butt")
				effect_printing("print")
				var/obj/item/paper/P = new(get_turf(src))
				P.name = "butt"
				P.desc = "butt butt butt"
				P.info = "{<b>butt butt butt butt butt butt<br>butt butt<br>butt</b>}" //6 butts then 2 butts then 1 butt haha
				P.icon = 'icons/obj/items/organs/butt.dmi'
				P.icon_state = "butt"
			if ("poster_wanted")
				effect_printing("print")
				var/obj/item/poster/titled_photo/W = create_wanted_poster(src.print_info)
				W.set_loc(get_turf(src))
				try_put_in_folder(W)
			if("booklet")
				effect_printing("print")
				if(src.sheets_left != src.sheets_per_item - 1)
					playsound(user,'sound/impact_sounds/Generic_Snap_1.ogg', 30, TRUE) // Auto-staple booklet for now
				if(src.sheets_left == 0)
					var/obj/item/paper_booklet/B = create_booklet()
					B.set_loc(get_turf(src))
			if("folder")
				effect_printing("print")
				var/sheet_index = sheets_per_item - sheets_left
				var/list/sheet_info = src.print_info["page_[sheet_index]"]
				var/obj/item/P = create_subitem(sheet_info)
				P.set_loc(get_turf(src))
				try_put_in_folder(P)
			if ("cash_fake")
				effect_printing("print_cash")
				var/print_amount = src.print_info[1]
				var/obj/item/currency/fakecash/C = new(get_turf(src), print_amount)
				for(var/obj/item/currency/fakecash/other_cash in C.loc.contents)
					if(other_cash == C)
						continue
					else if(other_cash.stack_item(C))
						break
			if ("cash")
				// Like having a license to printing money, except without a license.
				effect_printing("print_cash")
				var/print_amount = src.print_info[1]
				var/obj/item/currency/spacecash/C = new(get_turf(src), print_amount)
				for(var/obj/item/currency/spacecash/other_cash in C.loc.contents)
					if(other_cash == C)
						continue
					else if(other_cash.stack_item(C))
						break
			else
				effect_printing("print")
				new/obj/item/paper(get_turf(src))

	proc/create_subitem(var/sub_info) // For items that contain other items (folders, booklets)
		switch(sub_info["print_type"])
			if("paper")
				return create_paper(sub_info)
			if ("paper_photo")
				return create_paper_photo(sub_info)
			if ("poster_wanted")
				return create_wanted_poster(sub_info)
			if("photo")
				return create_photo(sub_info)
			else
				return null

	proc/create_paper(var/list/paper_info)
		var/obj/item/paper/P = new/obj/item/paper(src)
		P.name = paper_info["name"]
		P.desc = paper_info["desc"]
		P.info = paper_info["info"]
		var/list/new_stamps = paper_info["stamps"]
		P.stamps = new_stamps?.Copy()
		P.form_fields = paper_info["form_fields"]
		P.field_counter = paper_info["field_counter"]
		P.icon_state = paper_info["icon_state"]
		P.sizex = paper_info["sizex"]
		P.sizey = paper_info["sizey"]
		P.scrollbar = paper_info["scrollbar"]
		P.overlays = paper_info["overlays"]
		return P

	proc/create_paper_photo(var/list/paper_info)
		var/obj/item/paper/printout/P = new/obj/item/paper/printout(src)
		P.desc = paper_info["desc"]
		P.print_icon = paper_info["print_icon"]
		P.print_icon_state = paper_info["print_icon_state"]
		return P
	proc/create_photo(var/list/photo_info)
		var/obj/item/photo/P = new/obj/item/photo(src)
		P.name = photo_info["name"]
		P.desc = photo_info["desc"]
		P.fullImage = photo_info["fullImage"]
		P.fullIcon = photo_info["fullIcon"]
		//	i just copypasted all this garbage over from pictures because thats the only way this worked, idk if any of this is extraneous sorry
		var/oldtransform = P.fullImage.transform
		P.fullImage.transform = matrix(0.6875, 0.625, MATRIX_SCALE)
		P.fullImage.pixel_y = 1
		P.overlays += P.fullImage
		P.fullImage.transform = oldtransform
		P.fullImage.pixel_y = 0
		return P
	proc/create_wanted_poster(var/list/poster_info)
		var/obj/item/poster/titled_photo/W = new/obj/item/poster/titled_photo(src)
		W.name = poster_info["name"]
		W.desc = poster_info["desc"]
		W.icon_state = poster_info["icon_state"]
		W.poster_image = poster_info["poster_image"]
		W.poster_image_old = poster_info["poster_image_old"]
		W.photo = poster_info["photo"] = W.photo
		W.line_title = poster_info["line_title"]
		W.poster_HTML = poster_info["poster_HTML"]
		W.line_photo_subtitle = poster_info["line_photo_subtitle"]
		W.line_below_photo = poster_info["line_below_photo"]
		W.line_b1 = poster_info["line_b1"]
		W.line_b2 = poster_info["line_b2"]
		W.line_b3 = poster_info["line_b3"]
		W.author = poster_info["author"]
		var/list/plist = poster_info["plist"]
		W.plist = plist?.Copy()
		return W
	proc/create_booklet()
		var/obj/item/paper_booklet/B = new/obj/item/paper_booklet(src)
		B.name = src.print_info["name"]
		B.desc = src.print_info["desc"]
		B.icon = src.print_info["icon"]
		B.icon_state = src.print_info["icon_state"]
		var/page_count = src.print_info["page_count"]
		for(var/i=1, i<= page_count, i++)
			var/list/sub_info = src.print_info["page_[i]"]
			var/obj/item/paper/P = create_subitem(sub_info)
			P.set_loc(B)
			B.pages += P
		return B
	proc/create_folder() // Create a folder with the scanned items (for ai_peek() while a folder is scanned)
		var/obj/item/folder/F = new/obj/item/folder(src)
		F.name = src.print_info["name"]
		F.desc = src.print_info["desc"]
		F.icon = src.print_info["icon"]
		F.icon_state = src.print_info["icon_state"]
		var/page_count = src.print_info["page_count"]
		for(var/i=1, i<= page_count, i++)
			var/list/sub_info = src.print_info["page_[i]"]
			var/obj/item/paper/P = create_subitem(sub_info)
			P.set_loc(F)
			F.amount++
		F.is_virtual = TRUE
		F.tooltip_rebuild = 1
		return F
	proc/load_stuff(var/obj/item/w, var/mob/user) // Load paper into the copier here
		if (istype(w, /obj/item/paper))
			if (istype(w, /obj/item/paper/book) || istype(w, /obj/item/paper/newspaper))
				return;
			if (src.paper_amount >= PHOTOCOPIER_MAX_SHEETS)
				boutput(user, SPAN_ALERT("You can't fit any more paper into \the [src]."))
				effect_fail()
				return
			var/obj/item/paper/P = w
			if (P.info != "" && tgui_alert(user, "This paper has writing on it, are you sure you want to put it in the inlet tray?", "Warning", list("Yes", "No")) == "No")
				return
			boutput(user, "You load the sheet of paper into \the [src].")
			src.paper_amount++
			qdel(w)
		else if(istype(w, /obj/item/paper_bin/artifact_paper))
			return
		else if (istype(w, /obj/item/paper_bin))
			var/obj/item/paper_bin/P = w
			if (src.paper_amount >= PHOTOCOPIER_MAX_SHEETS)
				boutput(user, SPAN_ALERT("You can't fit any more paper into \the [src]."))
			else if ((P.amount_left + src.paper_amount) >= PHOTOCOPIER_MAX_SHEETS)
				P.amount_left -= PHOTOCOPIER_MAX_SHEETS - src.paper_amount
				P.update()
				src.paper_amount = PHOTOCOPIER_MAX_SHEETS
				boutput(user, SPAN_ALERT("You fill the paper tray in \the [src]."))
			else
				src.paper_amount += P.amount_left
				P.amount_left = 0
				P.update()
				boutput(user, "You load the paper into \the [src].")
	proc/try_put_in_folder(var/obj/item/w)
		for(var/obj/item/folder/F in src.loc.contents)
			if(F.contents.len < FOLDER_MAX_ITEMS)
				F.place_inside(w, null)
				break
	proc/effect_printing(var/print_icon)
		sleep(0.25 SECONDS)
		playsound(src.loc, 'sound/machines/printer_thermal.ogg', 30, 1)
		sleep(0.25 SECONDS)
		flick(print_icon, src)
		sleep(2.5 SECONDS)

	proc/effect_fail()
		// Just displays a red light to give the user additional feedback when needed
		if(src.use_state == 1)
			flick("fail_open", src)
		else
			flick("fail_closed", src)

	// --------------- Scanning Items ----------------

	proc/scanning(var/obj/item/w, var/mob/user)
		if(istype(w, /obj/item/paper))
			var/obj/item/paper/P = w
			scan_paper(P, user)
		else if(istype(w, /obj/item/photo))
			var/obj/item/photo/P = w
			scan_photo(P, user)
		else if(istype(w, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/B = w
			scan_butt(B, user)
		else if(istype(w, /obj/item/currency/fakecash))
			var/obj/item/currency/fakecash/C = w
			scan_fakecash(C, user)
		else if(istype(w, /obj/item/poster/titled_photo))
			var/obj/item/poster/P = w
			scan_poster(P, user)
		else if(istype(w, /obj/item/paper_booklet))
			var/obj/item/poster/B = w
			scan_booklet(B, user)
		else if(istype(w, /obj/item/currency/spacecash))
			var/obj/item/currency/spacecash/C = w
			scan_cash(C, user)
		else if(istype(w, /obj/item/card/id))
			var/obj/item/card/id/I = w
			scan_id_data(I, user)
		else if(istype(w, /obj/item/folder))
			var/obj/item/folder/F = w
			if(F.contents.len == 0)
				user.drop_item()
				F.set_loc(get_turf(src))
			else
				scan_folder(F, user)
	proc/scan_setup(var/obj/item/w, var/mob/user) // Run this before scanning items using an animation
		src.reset_all()
		src.use_state = 2
		user.drop_item()
		w.set_loc(src)
	proc/scan_subitem(var/obj/item/w) // For items with multiple pages.
		var/list/sheet_info = new/list()
		if (istype(w, /obj/item/paper))
			var/obj/item/paper/P = w
			sheet_info = scan_paper_data(P)
		else if (istype(w, /obj/item/poster/titled_photo))
			var/obj/item/poster/titled_photo/P = w
			sheet_info = scan_poster_data(P)
		else if(istype(w, /obj/item/photo))
			var/obj/item/photo/P = w
			sheet_info = scan_photo_data(P)
		return sheet_info
	proc/scan_paper(var/obj/item/paper/P, var/mob/user)
		scan_setup(P, user)
		src.icon_state = "papper"
		if (istype(P, /obj/item/paper/printout))
			boutput(user, "You put the picture on the scan bed, close the lid, and press start...")
		else if (istype(P, /obj/item/paper/book))
			boutput(user, "You open the book, press its contents onto the scan bed, and press start...")
			src.icon_state = "scan_book"
		else if (istype(P, /obj/item/paper/newspaper))
			boutput(user, "You put the newspaper onto the scan bed, close the lid, and press start...")
			src.icon_state = "scan_news"
		else
			boutput(user, "You put the paper on the scan bed, close the lid, and press start...")
		effects_scanning(P)
		src.print_info = scan_paper_data(P)
		src.print_type = src.print_info["print_type"]
	proc/scan_paper_data(var/obj/item/paper/P)
		var/list/scan_info = new/list()
		if (istype(P, /obj/item/paper/printout))
			var/obj/item/paper/printout/Pout = P
			scan_info["desc"] = Pout.desc
			scan_info["print_icon"] = Pout.print_icon
			scan_info["print_icon_state"] = Pout.print_icon_state
			scan_info["print_type"] = "paper_photo"
		else if (istype(P, /obj/item/paper/book))
			scan_info["name"] = P.name
			scan_info["desc"] = "A paper copy of '" + P.name + "'. " + P.desc
			scan_info["info"] = P.info
			scan_info["stamps"] = P.stamps?.Copy()
			scan_info["form_fields"] = P.form_fields
			scan_info["field_counter"] = P.field_counter
			scan_info["icon_state"] = "paper_blank"
			scan_info["sizex"] = 0
			scan_info["sizey"] = 0
			scan_info["scrollbar"] = TRUE
			scan_info["overlays"] = list()
			scan_info["print_type"] = "paper"
		else if (istype(P, /obj/item/paper/newspaper))
			var/obj/item/paper/newspaper/news = P
			scan_info["name"] = "Copy of " + news.publisher
			scan_info["desc"] = "A photocopy of a newspaper article. " + news.desc
			scan_info["info"] = news.info
			scan_info["stamps"] = news.stamps?.Copy()
			scan_info["form_fields"] = news.form_fields
			scan_info["field_counter"] = news.field_counter
			scan_info["icon_state"] = "paper_blank"
			scan_info["sizex"] = 0
			scan_info["sizey"] = 0
			scan_info["scrollbar"] = TRUE
			scan_info["overlays"] = list()
			scan_info["print_type"] = "paper"
		else
			scan_info["name"] = P.name
			scan_info["desc"] = P.desc
			scan_info["info"] = P.info
			scan_info["stamps"] = P.stamps?.Copy()
			scan_info["form_fields"] = P.form_fields
			scan_info["field_counter"] = P.field_counter
			scan_info["icon_state"] = P.icon_state
			scan_info["sizex"] = P.sizex
			scan_info["sizey"] = P.sizey
			scan_info["scrollbar"] = P.scrollbar
			scan_info["overlays"] = P.overlays
			scan_info["print_type"] = "paper"
		return scan_info
	proc/scan_photo(var/obj/item/photo/P, var/mob/user)
		// Photo: index 1 is name, index 2 is desc, index 3 is fullImage, index 4 is fullIcon
		scan_setup(P, user)
		src.icon_state = "papper"
		boutput(user, "You put the photo on the scan bed, close the lid, and press start...")
		effects_scanning(P)
		src.print_info = scan_photo_data(P)
		src.print_type = src.print_info["print_type"]
	proc/scan_photo_data(var/obj/item/photo/P)
		var/list/scan_info = new/list()
		scan_info["name"] = P.name
		scan_info["desc"] = P.desc
		scan_info["fullImage"] = P.fullImage
		scan_info["fullIcon"] = P.fullIcon
		scan_info["print_type"] = "photo"
		return scan_info

	proc/scan_butt(var/obj/item/clothing/head/butt/B, var/mob/user)
		scan_setup(B, user)
		src.icon_state = "buttt"
		boutput(user, "You slap the ass (hot) on the scan bed, close the lid, and press start...")
		effects_scanning(B)
		src.print_type = "butt"

	proc/scan_cash(var/obj/item/currency/spacecash/C, var/mob/user)
		scan_setup(C, user)
		src.icon_state = "scan_cash"
		boutput(user, "You put the cash on the scan bed, close the lid, and press start...")
		effects_scanning(C)
		if(emagged)
			src.print_info += min(C.amount, 10) // index 1 is the amount of cash to print per sheet of paper
			src.print_type = "cash"
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 10, 1)
			effect_fail()

	proc/scan_fakecash(var/obj/item/currency/fakecash/C, var/mob/user)
		scan_setup(C, user)
		src.icon_state = "scan_cash"
		boutput(user, "You lay out the credit-like currency over the area of the scan bed, close the lid, and press start...")
		effects_scanning(C)
		src.print_info += min(C.amount, 10000) // index 1 is the amount of fake cash to print per sheet of paper
		src.print_type = "cash_fake"

	proc/scan_id_data(var/obj/item/card/id/I, var/mob/user)
		scan_setup(I, user)
		if(I.icon_state == "gold")
			src.icon_state = "scan_id_gold"
		else
			src.icon_state = "scan_id"
		boutput(user, "You put the card on the scan bed, close the lid, and press start...")
		effects_scanning(I)
		src.print_info["name"] = "[I.name] Scan"
		src.print_info["desc"] = "A scan of [I.name]"
		var/scan_info = "<li><h4>[I.name]</h4></li> \
			<body><hr> \
			<li><b>Name:</b> [I.registered]</li> \
			<li><b>Assignment:</b> [I.assignment]</li> \
			<li><b>Pronouns:</b> [I.pronouns]</li> \
			<li><b>Access:</b>"

		var/access_count = 0
		for(var/i = 1, i <= I.access.len, i++)
			var/access_desc = get_access_desc(I.access[i])
			if(access_desc != null)
				if(access_count != 0)
					scan_info += " | "
				else
					scan_info += "</li>"
				scan_info += access_desc
				access_count++
		if(access_count == 0)
			scan_info += " None</li>"

		scan_info += "</body>"
		src.print_info["info"] = scan_info
		src.print_info["stamps"] = null
		src.print_info["form_fields"] = list()
		src.print_info["field_counter"] = 1
		src.print_info["icon_state"] = "paper_blank"
		src.print_info["sizex"] = 0
		src.print_info["sizey"] = 0
		src.print_info["scrollbar"] = TRUE
		src.print_info["overlays"] = list()
		src.print_type = "paper"


	proc/scan_poster(var/obj/item/poster/titled_photo/W, var/mob/user)
		scan_setup(W, user)
		src.icon_state = "papper"
		boutput(user, "You put the poster on the scan bed, close the lid, and press start...")
		effects_scanning(W)
		src.print_info = scan_poster_data(W)
		src.print_type = src.print_info["print_type"]
	proc/scan_poster_data(var/obj/item/poster/titled_photo/W)
		var/list/scan_info = new/list()
		scan_info["name"] = W.name
		scan_info["desc"] = W.desc
		scan_info["icon_state"] = W.icon_state
		scan_info["poster_image"] = W.poster_image
		scan_info["poster_image_old"] = W.poster_image_old
		scan_info["photo"] = W.photo
		scan_info["line_title"] = W.line_title
		scan_info["poster_HTML"] = W.poster_HTML
		scan_info["line_photo_subtitle"] = W.line_photo_subtitle
		scan_info["line_below_photo"] = W.line_below_photo
		scan_info["line_b1"] = W.line_b1
		scan_info["line_b2"] = W.line_b2
		scan_info["line_b3"] = W.line_b3
		scan_info["author"] = W.author
		scan_info["plist"] = W.plist?.Copy()
		scan_info["print_type"] = "poster_wanted"
		return scan_info
	proc/scan_booklet(var/obj/item/paper_booklet/B, var/mob/user)
		scan_setup(B, user)
		src.icon_state = "scan_news"
		boutput(user, "You put the booklet on the scan bed, close the lid, and press start...")
		effects_scanning(B)
		src.print_info["name"] = B.name
		src.print_info["desc"] = B.desc
		src.print_info["icon"] = B.icon
		src.print_info["icon_state"] = B.icon_state
		src.print_info["page_count"] = B.pages.len
		for(var/i=1, i<= B.pages.len, i++)
			var/obj/item/paper/P = B.pages[i]
			src.print_info["page_[i]"] = scan_subitem(P)
		src.sheets_per_item = B.pages.len
		src.print_type = "booklet"
	proc/scan_folder(var/obj/item/folder/F, var/mob/user)
		scan_setup(F, user)
		src.icon_state = "papper"
		boutput(user, "You put the contents of the folder onto the scan bed, close the lid, and press start...")
		effects_scanning(F)
		src.print_info["page_count"] = F.contents.len
		for(var/i = 1, i <= F.contents.len, i++)
			src.print_info["page_[i]"] = scan_subitem(F.contents[i])
		src.sheets_per_item = F.contents.len
		src.print_type = "folder"

	proc/scan_reagent_scanner(var/obj/item/device/reagentscanner/R, var/mob/user)
		src.reset_all()
		boutput(user, "You upload the reagent scanner's previous results to the photocopier.")
		src.print_info["name"] = "Reagent Scanner Results"
		src.print_info["desc"] = "List of past results from a reagent scanner."
		var/scan_data = "<li><h3>Reagent Scanner Results</h3></li><hr>" + R.scan_results
		src.print_info["info"] = scan_data
		src.print_info["stamps"] = null
		src.print_info["form_fields"] = list()
		src.print_info["field_counter"] = 1
		src.print_info["icon_state"] = "paper_blank"
		src.print_info["sizex"] = 0
		src.print_info["sizey"] = 0
		src.print_info["scrollbar"] = TRUE
		src.print_info["overlays"] = list()
		src.print_type = "paper"

	proc/scan_network_info() // Used to print data on how to interact with this photocopier via packets
		src.reset_all()
		var/network_info = "<li><h3>Photocopier Network Information Sheet</h3></li> \
			<body><hr> \
			<li><b>Frequency:</b> [src.frequency]</li>	\
			<li><b>NetID:</b> address_1 = [src.net_id]</li>	\
			<li><b>Commands:</b></li> \
			<li><u>print</u></li> \
			<font size=1><li>○ data = <i>Number of copies for this printing cycle (optional)</i></li></font> \
			<li><u>amount</u></li> \
			<font size=1><li>○ data = <i>Number of copies to print</i></li></font> \
			<li><u>reset</u></li> \
			<font size=1><li>○ <i>Clears all scanning data</i></li></font> \
			<li><u>help</u></li> \
			<li>○ <i>Print a copy of this sheet</i></li></font> \
			</font></body>"
		src.print_info["name"] = "Photocopier Network Information"
		src.print_info["desc"] = "Notes on how to interact with the photocopier remotely."
		src.print_info["info"] = network_info
		src.print_info["stamps"] = null
		src.print_info["form_fields"] = list()
		src.print_info["field_counter"] = 1
		src.print_info["icon_state"] = "paper_blank"
		src.print_info["sizex"] = 0
		src.print_info["sizey"] = 0
		src.print_info["scrollbar"] = TRUE
		src.print_info["overlays"] = list()
		src.print_type = "paper"

	proc/effects_scanning(var/obj/item/w)
		sleep(0.3 SECONDS)
		src.icon_state = "close_sesame"
		flick("scan", src)
		playsound(src.loc, 'sound/machines/scan.ogg', 50, 1)
		sleep(1.8 SECONDS)
		src.icon_state = "open_sesame"
		w.set_loc(get_turf(src))
		src.visible_message("\The [src] finishes scanning and opens automatically!")
		src.use_state = 1
	proc/reset_all()
		// Clear the scanning data, usually before a new scan.
		src.print_info = list()
		src.print_type = ""
		src.sheets_per_item = 1
		src.sheets_left = 1
		if(src.scan_peek)
			qdel(src.scan_peek)
		src.scan_peek = null

	// --------------- Packets ----------------

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return
		if(lowertext(signal.data["sender"]) == src.net_id)
			return
		var/is_address_mine = lowertext(signal.data["address_1"]) == src.net_id
		if (!is_address_mine)
			if (lowertext(signal.data["address_1"]) == "ping")
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "PHOTOCOPIER"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["sender"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, PHOTOCOPIER_RADIO_RANGE)
				return
		if (is_address_mine && signal.data["command"])
			recieve_command(signal)
			return

	proc/recieve_command(datum/signal/signal)
		if (src.use_state == 2)
			return
		// var/senderid = signal.data["sender"]
		switch(lowertext(signal.data["command"]))
			if("help")
				var/prev_amount = src.print_amount
				src.print_amount = 1
				effect_radio()
				scan_network_info()
				print_action()
				src.print_amount = prev_amount
			if("print")
				var/prev_amount = src.print_amount
				if(signal.data["data"])
					var/signal_data = text2num_safe(lowertext(signal.data["data"]))
					if(isnum_safe(signal_data))
						print_amount = min(max(signal_data, 1), PHOTOCOPIER_MAX_SHEETS)
				effect_radio()
				print_action()
				src.print_amount = prev_amount
			if("amount")
				var/signal_data = text2num_safe(lowertext(signal.data["data"]))
				if(isnum_safe(signal_data))
					print_amount = min(max(signal_data, 1), PHOTOCOPIER_MAX_SHEETS)
				playsound(src.loc, 'sound/machines/ping.ogg', 20, 1)
				effect_radio()
			if("reset")
				effect_fail()
				src.reset_all()
				playsound(src.loc, 'sound/machines/bweep.ogg', 20, 1)

	proc/effect_radio()
		// A flashing blue light to visually display packet commands
		if(src.use_state == 1)
			flick("net_open", src)
		else
			flick("net_closed", src)
