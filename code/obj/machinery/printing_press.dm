/// makes books and pamphlets.
/obj/machinery/printing_press
	name = "\improper Academy automated printing press"
	desc = "This is an Aurora Lithographics 'Academy' model automated printing press, used to reproduce books and pamphlets. This doesn't still use stone plates, does it?"
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "printing_press" //proper icon is set in UpdateIcon
	anchored = ANCHORED
	density = 1
	bound_width = 64 //the game just handles xtra wide objects already halleluiah

	var/const/paper_max = 70
	var/const/ink_max = 500

	/// empty by default, 0 to 70
	var/paper_amt = 0
	/// workaround for now, need to update icon if paper_amt is 0 to clear overlay
	var/was_paper = 0
	/// TRUE if its working, FALSE when idle/depowered
	var/is_running = FALSE
	/// FALSE by default, set to TRUE when ink colors upgrade is installed
	var/colors_upgrade = FALSE
	/// FALSE by default, set to TRUE when custom book covers upgrade is installed
	var/books_upgrade = FALSE
	/// FALSE by default, set to TRUE when forbidden covers/symbols/styles upgrade is installed
	var/forbidden_upgrade = FALSE
	/// decrements by 2 for each book printed, can be refilled (expensively)
	var/ink_level = 100
	/// the default modes, can be expanded to have "Ink Colors" and "Custom Cover"
	var/list/press_modes = list("Choose book cover", "Set book info", "Set book contents",
	"Set newspaper info", "Set newspaper contents", "Amount to make", "Print", "View Information")

	/// how many books to make?
	var/book_amount = 0
	/// what cover design to use?
	var/book_cover = ""
	/// what text will the made books have?
	var/book_info = ""
	/// raw version of the text, for editing.
	var/book_info_raw = ""
	/// whats the made book's name?
	var/book_name = ""
	/// 64 character titles/author names max
	var/const/info_len_lim = 64
	/// who made the book?
	var/book_author = ""
	/// what color is the text written in?
	var/ink_color = "#000000"
	/// list of covers to choose from
	var/list/cover_designs = list("Grey", "Dull red", "Red", "Blue", "Green", "Yellow", "Dummies", "Robuddy", "Skull", "Latch", "Bee",\
	"Albert", "Surgery", "Law", "Nuke", "Rat", "Pharma", "Bar")
	/// just the bible for now. add covers to this list if their icon file isnt icons/obj/writing.dmi
	var/list/non_writing_icons = list("bible")

	/// white by default, what colour will our book be?
	var/cover_color = "#FFFFFF"
	/// what symbol is on our front cover?
	var/cover_symbol = ""
	/// white by default, if our symbol is colourable, what colour is it?
	var/symbol_color = "#FFFFFF"
	/// whats the "flair" thing on the book?
	var/cover_flair = ""
	/// white by default, whats the color of the flair (if its colorable)?
	var/flair_color = "#FFFFFF"
	/// this is a bugfix for non-colourable symbols being coloured
	var/symbol_colorable = FALSE
	/// this is a bugfix for non-colourable flairs being coloured
	var/flair_colorable = FALSE

	/// symbols that can't be coloured
	var/list/standard_symbols = list("None", "Bee", "Blood", "Eye", "No", "Clown", "Wizhat", "CoolS", "Brimstone", "Duck", "Planet+Moon", "Sol",\
	"Candle", "Shelterbee")
	/// list of symbols that can be coloured
	var/list/colorable_symbols = list("None", "Skull", "Drop", "Shortcross", "Smile", "One", "FadeCircle", "Square", "NT", "Ghost", "Bone",\
	"Heart", "Pentagram", "Key", "Lock")
	/// alchemical symbols (because theres a lot of them)
	var/list/alchemical_symbols = list("None", "Mercury", "Salt", "Sulfur", "Water", "Fire", "Air", "Earth", "Calcination", "Congelation",\
	"Fixation", "Dissolution", "Digestion", "Distillation", "Sublimation", "Seperation", "Ceration", "Fermentation", "Multiplication",\
	"Projection")
	var/list/alphanumeric_symbols = list("None", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",\
	"T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
	/// flairs that can't be coloured
	var/list/standard_flairs = list("None", "Gold", "Latch", "Dirty", "Scratch", "Torn")
	/// flairs that can be coloured
	var/list/colorable_flairs = list("None", "Corners", "Bookmark", "RightCover", "SpineCover")

	// ------------- Newspaper vars
	/// headline of the newspaper. Saved separately to book details.
	var/newspaper_headline = ""
	/// the name of the newspaper e.g. Nanotrasen Daily.
	var/newspaper_publisher = ""
	/// The contents of the article
	var/newspaper_info = ""
	/// raw version of newspaper_info, for editing
	var/newspaper_info_raw = ""
	/// False by default, set to true when newspaper printing upgrade is installed.
	var/newspaper_upgrade = TRUE // fuckit lets just start with newspapers for now
	/// headlines can be 128 characters max, unlike book titles
	var/const/headline_len_lim = 128
	/// Amount of newspapers to print
	var/newspaper_amount = 0

////////////////////
//Appearance stuff//
////////////////////

	update_icon() //this runs every time something would change the amt of paper, or if its working or done working, handles paper overlay and work animation
		if (src.paper_amt || src.was_paper)
			if (GetOverlayImage("paper"))
				ClearSpecificOverlays("paper")
			var/image/I = SafeGetOverlayImage("paper", src.icon, "paper-[round(src.paper_amt / 10)]")
			src.UpdateOverlays(I, "paper")
			src.was_paper = 0
		if (src.ink_level)
			if (GetOverlayImage("ink"))
				ClearSpecificOverlays("ink")
			var/ink_num = round(src.ink_level / 100) //idk, this should probably work
			var/image/I = SafeGetOverlayImage("ink", src.icon, "ink-[ink_num]")
			src.UpdateOverlays(I, "ink")
		if (src.is_running)
			FLICK("printing_press-work", src)
			return
		icon_state = "printing_press-idle"

	get_desc(var/dist)
		if (dist > 6)
			return
		var/press_desc = ""
		switch(src.paper_amt / src.paper_max * 100)
			if (0)
				press_desc += "The paper bin is empty!"
			if (0 to 15)
				press_desc += "The paper bin is nearly empty!"
			if (15 to 30)
				press_desc += "The paper bin is about a quarter full."
			if (30 to 45)
				press_desc += "The paper bin is nearly half full."
			if (45 to 60)
				press_desc += "The paper bin is over half full."
			if (60 to 75)
				press_desc += "The paper bin is nearly three-quarters full."
			if (75 to 90)
				press_desc += "The paper bin is over three-quarters full."
			if (90 to 99)
				press_desc += "The paper bin is nearly full."
			if (99 to INFINITY)
				press_desc += "The paper bin is totally full!"
			else
				press_desc += "how the fuck did you even do this."

		if ((src.ink_level / src.ink_max) < 0.1)
			press_desc += " The ink is running low."

		if (src.is_running)
			press_desc += " \The [src] is currently making books!"

		return press_desc

	New()
		..()
		// theres probably a way to do this that isnt stupid but: fuck u i dont give a shite
		if (is_fuckled(EAST))
			// there's shit on the east turf. what about the west one?
			if (is_fuckled(WEST))
				// shit there's crap there too, guess we're really fuckled.
				src.visible_message("[src] fails to deploy! You blew it! Everything is <em>totally fucked!</em>")
				new/obj/effect/supplyexplosion(src.loc)
				playsound(src.loc, 'sound/effects/ExplosionFirey.ogg', 100, 1)
				for(var/mob/M in view(7, src.loc))
					shake_camera(M, 20, 16)

				sleep(2 SECONDS)
				new /obj/item/electronics/frame/press_frame(src.loc)
				src.visible_message("[src] finishes deploying its you-blew-it payload and folds back up into a frame so you can try again.")
				qdel(src)
				return

			src.x -= 1
		AddComponent(/datum/component/transfer_output)
		UpdateIcon()

	// this bad boy requires two tiles of space so we'll check it out
	proc/is_fuckled(var/where)
		var/turf/T = get_step(src, where) //gets the turf that will be under the right side of the machine, so we can abort construction if itll be weird
		if(!T)
			return
		if (T.density) //is the turf a wall/dense?
			return 1
		for (var/obj/O in T) // are we dealing with some other jerk of an object
			if (O.density && O != src)
				return 1
		// nope we're good. fuckled: no.
		return 0


/////////////////////
//Interaction stuff//
/////////////////////

/obj/machinery/printing_press/attackby(var/obj/item/W, mob/user)
	if (istype(W, /obj/item/paper_bin))
		var/obj/item/paper_bin/P = W
		if (P.amount_left > 0 && src.paper_amt <= src.paper_max) //if the paper bin has paper, and adding the paper bin doesnt add too much paper
			boutput(user, "You load \the [P] into \the [src].")
			var/amount_to_take = src.paper_max - src.paper_amt
			var/amount_taken = min(amount_to_take, P.amount_left)
			src.paper_amt += amount_taken
			UpdateIcon()
			P.amount_left = P.amount_left - amount_taken
			P.update()
			return
		else
			if (P.amount_left <= 0)
				if (length(P.contents) > 0)
					boutput(user, "\The [P] has no unsoiled sheets left in it.") // someone put junk paper in the bin
				else
					boutput(user, "\The [P] has no paper left in it.") // its just plain empty
				return
			boutput(user, "\The [src] is already fully loaded with paper!")
	else if (istype(W, /obj/item/paper) && !istype(W, /obj/item/paper/book)) //should also exclude all other weird paper subtypes, but i think books are the only one
		if (src.paper_amt < src.paper_max)
			var/obj/item/paper/sheet = W
			if(length(sheet.info))
				boutput(user, SPAN_ALERT("\The [src] only takes blank paper!"))
				return
			boutput(user, "You load \the [W] into \the [src].")
			src.paper_amt ++
			UpdateIcon()
			user.drop_item()
			qdel(W)
		else
			boutput(user, "\The [src] is too full for that!")
			return

	else if (istype(W, /obj/item/press_upgrade))
		switch (W.icon_state)
			if ("press_colors")
				if (src.colors_upgrade)
					src.visible_message("\The [src] already has that upgrade installed.")
					return
				src.colors_upgrade = TRUE
				src.press_modes += "Ink color"
				src.visible_message("\The [src] accepts the upgrade.")

			if ("press_books")
				if (src.books_upgrade)
					src.visible_message("\The [src] already has that upgrade installed.")
					return
				src.books_upgrade = TRUE
				src.press_modes += "Customise cover"
				src.visible_message("\The [src] accepts the upgrade.")

			if ("press_forbidden")
				if (src.forbidden_upgrade)
					src.visible_message("\The [src] already has that upgrade installed.")
					return
				src.forbidden_upgrade = TRUE
				src.standard_symbols += list("Anarchy", "Syndie")
				src.colorable_symbols += list("FixMe")
				src.standard_flairs += list("Fire")
				src.cover_designs += list("Necronomicon", "Old", "Bible")
				src.visible_message("\The [src] accepts the upgrade.")

			if ("press_ink")
				if ((src.ink_level + 100) <= src.ink_max) //500ink internal resevoir
					src.ink_level += 100
					boutput(user, "Ink refilled.")
					UpdateIcon() //to show ink level change
				else
					boutput(user, "\The [src] doesn't need an ink refill yet.")
					return

			if ("press_newspaper")
				if (src.newspaper_upgrade)
					src.visible_message("\The [src] already has that upgrade installed.")
					return
				src.press_modes += "Set newspaper info"
				src.press_modes += "Set newspaper contents"
				src.newspaper_upgrade = TRUE
				src.visible_message("\The [src] accepts the upgrade.")

			else //in case some wiseguy tries the parent im watching u
				boutput(user, "no good, asshole >:\[")
				return
		qdel(W)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

/obj/machinery/printing_press/attack_hand(var/mob/user) //all of our mode controls and setters here, these control what the books are/look like/have as contents
	if (src.is_running)
		boutput(user, "\The [src] is busy.") //machine is running
		return
	var/mode_sel = input("What would you like to do?", "Mode Control") as null|anything in src.press_modes
	if (!mode_sel) //just in case? idk if this is necessary
		return

	switch (lowertext(mode_sel))
		if ("choose book cover")
			var/cover_sel = input("What book cover design would you like?", "Cover Control", src.book_cover) as null|anything in src.cover_designs
			if (!cover_sel)
				src.book_cover = "book0"
			else
				switch (lowertext(cover_sel))
					if ("grey")
						src.book_cover = "book0"
					if ("dull red")
						src.book_cover = "book1"
					if ("red")
						src.book_cover = "book7"
					if ("blue")
						src.book_cover = "book2"
					if ("green")
						src.book_cover = "book3"
					if ("yellow")
						src.book_cover = "book6"
					if ("dummies")
						src.book_cover = "book4"
					if ("robuddy")
						src.book_cover = "book5"
					if ("skull")
						src.book_cover = "sbook"
					if ("latch")
						src.book_cover = "bookcc"
					if ("bee")
						src.book_cover = "booktth"
					if ("albert")
						src.book_cover = "bookadps"
					if ("surgery")
						src.book_cover = "surgical_textbook"
					if ("law")
						src.book_cover = "spacelaw"
					if ("nuke")
						src.book_cover = "nuclearguide"
					if ("rat")
						src.book_cover = "ratbook"
					if ("pharma")
						src.book_cover = "pharmacopia"
					if ("bar")
						src.book_cover = "barguide"
					if ("necronomicon")
						src.book_cover = "necronomicon"
					if ("bible")
						src.book_cover = "bible"
					if ("old")
						src.book_cover = "oldbook"
					else
						src.book_cover = "book0"
			boutput(user, "Book cover set.")
			return

		if ("set newspaper info")
			if (!src.newspaper_upgrade)
				boutput(user, "Your free trial of newspaper printing has expired. Please enter Newspaper Printing Upgrade.")
				return
			var/name_sel = input("What do you want the headline to be?", "Information Control", src.newspaper_headline)
			if (length(name_sel) > src.headline_len_lim)
				boutput(user, "Aborting, headline too long.")
				return
			src.newspaper_headline = strip_html(name_sel)
			phrase_log.log_phrase("newspaperheadline", name_sel, TRUE, user, TRUE)
			var/publisher_sel = input("Who is the publisher of your newspaper? What's the paper's name?", "Information Control", src.newspaper_publisher)
			if (length(publisher_sel) > src.info_len_lim)
				boutput(user, "Aborting, publisher name too long.")
				return
			src.newspaper_publisher = strip_html(publisher_sel)
			phrase_log.log_phrase("newspaperpublisher", publisher_sel, TRUE, user, TRUE)
			boutput(user, "Information set.")
			return
		if ("set newspaper contents")
			var/info_sel = input(user, "What do you want the article to say?", "Information Control", src.newspaper_info_raw) as null|message
			if (!info_sel)
				return
			info_sel = src.trim_input(info_sel)
			src.newspaper_info_raw = info_sel
			src.newspaper_info = src.convert_input(info_sel)
			phrase_log.log_phrase("newspaperarticle", src.newspaper_info, TRUE, user, FALSE)
			boutput(user, "Newspaper contents set.")
			return
		if ("set book info")
			var/name_sel = input("What do you want the title of your book to be?", "Information Control", src.book_name) //total information control! the patriots control the memes, snake!
			if (length(name_sel) > src.info_len_lim)
				boutput(user, "Aborting, title too long.")
				return
			src.book_name = strip_html(name_sel)
			phrase_log.log_phrase("booktitle", name_sel, TRUE, user, TRUE)
			var/author_sel = input("Who is the author of your book?", "Information Control", book_author)
			if (length(author_sel) > src.info_len_lim)
				boutput(user, "Aborting, author name too long.")
				return
			src.book_author = strip_html(author_sel)
			phrase_log.log_phrase("bookauthor", author_sel, TRUE, user, TRUE)
			boutput(user, "Information set.")
			return

		if ("set book contents")
			var/info_sel = input("What do you want your book to say?", "Content Control", src.book_info_raw) as null|message
			if (!info_sel)
				return
			info_sel = src.trim_input(info_sel)
			src.book_info_raw = info_sel
			src.book_info = src.convert_input(info_sel)
			phrase_log.log_phrase("bookcontent", src.book_info, TRUE, user, FALSE)
			boutput(user, "Book contents set.")
			return

		if ("amount to make")
			if (src.newspaper_upgrade)
				var/mode_select = input("Books or newspapers?", "Mode Select", "Books") as anything in list("Books", "Newspapers")
				if (mode_select == "Newspapers")
					var/newspaper_amount_sel = input("How many newspapers do you want to print? ([round(src.paper_amt / 2)] max)", "Ream Control", src.newspaper_amount) as num
					if (newspaper_amount_sel > 0 && newspaper_amount_sel <= (src.paper_amt / 2)) //is the number in range?
						boutput(user, "Newspaper amount set.")
						src.newspaper_amount = newspaper_amount_sel
					else
						boutput(user, "Amount out of range.")
					return
				else if (mode_select == "Books")
					var/amount_sel = input("How many books do you want to make? ([round(src.paper_amt / 2)] max)", "Ream Control", src.book_amount) as num
					if (amount_sel > 0 && amount_sel <= (src.paper_amt / 2)) //is the number in range?
						boutput(user, "Book amount set.")
						src.book_amount = amount_sel
					else
						boutput(user, "Amount out of range.")
					return
			else
				var/amount_sel = input("How many books do you want to make? ([round(src.paper_amt / 2)] max)", "Ream Control", src.book_amount) as num
				if (amount_sel > 0 && amount_sel <= (src.paper_amt / 2)) //is the number in range?
					boutput(user, "Book amount set.")
					src.book_amount = amount_sel
				else
					boutput(user, "Amount out of range.")

		if ("print")
			if (src.is_running)
				boutput(user, "\The [src] is busy.")
				return
			var/printmode = "Book"
			if (src.newspaper_upgrade)
				printmode = input(user, "Books or Newspapers?", "Print Mode", "Book") as anything in list("Book", "Newspaper")
			if (printmode == "Book")
				if (!src.book_amount)
					boutput(user, "Invalid book amount.")
					return
				if (src.ink_level < 2)
					// you can't even print a single book. nice one, doofus
					src.visible_message("Not enough ink.")
					return
				logTheThing(LOG_SAY, user, "made some books with the name: [src.book_name] | the author: [src.book_author] | the contents: [src.book_info]") //book logging
				make_books()
				return
			else if (printmode == "Newspaper")
				if (!src.newspaper_amount)
					boutput(user, "Invalid newspaper amount.")
					return
				if (src.ink_level < 1)
					src.visible_message("Not enough ink.")
					return
				logTheThing(LOG_SAY, user, "made some newspapers with the headline: [src.book_name] | the author: [src.book_author] | the contents: [src.book_info]") //book logging
				make_newspapers()
			else
				CRASH("Printing press somehow not having print mode selected.")

		if ("ink color")
			if (src.colors_upgrade) //can never be too safe
				var/color_sel = input("What colour would you like the Book ink to be?", "Ink Control") as color
				if (color_sel)
					src.ink_color = color_sel

		if ("customise cover")
			if (src.books_upgrade) //can never be too safe
				src.book_cover = "custom" //so we can bypass normal cover selection in the bookmaking process
				var/cover_color_sel = input("What colour would you like the book cover to be?", "Cover Control") as color
				if (cover_color_sel)
					src.cover_color = cover_color_sel

				var/s_cat_sel = input("What type of symbol would you like?", "Cover Control") as null|anything in list("Standard", "Colorable", "Alchemical", "Alphanumeric")
				switch (lowertext(s_cat_sel))
					if ("standard")
						var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in src.standard_symbols
						if (symbol_sel)
							src.cover_symbol = lowertext(symbol_sel)
							src.symbol_colorable = FALSE
						else
							src.cover_symbol = "none"

					if ("colorable")
						var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in src.colorable_symbols
						if (symbol_sel)
							src.cover_symbol = lowertext(symbol_sel)
							var/color_sel = input("What color would you like the symbol to be?", "Cover Control") as color
							if (color_sel)
								src.symbol_color = color_sel
								src.symbol_colorable = TRUE
						else
							src.cover_symbol = "none"

					if ("alchemical")
						var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in src.alchemical_symbols
						if (symbol_sel)
							src.cover_symbol = lowertext(symbol_sel)
							src.symbol_colorable = FALSE
						else
							src.cover_symbol = "none"

					if ("alphanumeric")
						var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in src.alphanumeric_symbols
						if (symbol_sel)
							src.cover_symbol = lowertext(symbol_sel)
							var/color_sel = input("What color would you like the symbol to be?", "Cover Control") as color
							if (color_sel)
								src.symbol_color = color_sel
								src.symbol_colorable = TRUE
						else
							src.cover_symbol = "none"

				var/f_cat_sel = input("What type of flair would you like?", "Cover Control") as null|anything in list("Standard", "Colorable")

				if (f_cat_sel == "Standard")
					var/flair_sel = input("What would you like the flair to be?", "Cover Control") as null|anything in src.standard_flairs
					if (flair_sel)
						src.cover_flair = lowertext(flair_sel)
						src.flair_colorable = FALSE
					else
						src.cover_flair = "none"

				else if (f_cat_sel == "Colorable")
					var/flair_sel = input("What would you like the flair to be?", "Cover Control") as null|anything in src.colorable_flairs
					if (flair_sel)
						src.cover_flair = lowertext(flair_sel)
						var/color_sel = input("What color would you like the flair to be?", "Cover Control") as color
						if (color_sel)
							src.flair_color = color_sel
							src.flair_colorable = TRUE
					else
						src.cover_flair = "none"

		if ("view information")
			boutput(user, "There are [src.paper_amt] sheets of paper left, and [src.ink_level] units of ink.")
			if (src.book_author)
				boutput(user, "The author of the book is [src.book_author].")
			else
				boutput(user, "There is no book author set.")
			if (src.book_name)
				boutput(user, "The title of the book is [src.book_name].")
			else
				boutput(user, "There is no book title set.")
			if (src.newspaper_upgrade)
				if (src.newspaper_publisher)
					boutput(user, "The publisher of the newspaper is [src.newspaper_publisher].")
				else
					boutput(user, "There is no newspaper publisher set.")
				if (src.newspaper_headline)
					boutput(user, "The newspaper headline reads: [src.newspaper_headline]")
				else
					boutput(user, "There is no newspaper headline set.")
			return

		else //just in case, yell at me if this is bad
			return

/// HTML encodes input and converts bbcode to HTML
/obj/machinery/printing_press/proc/convert_input(var/info_sel)
	info_sel = html_encode(info_sel)
	info_sel = replacetext(info_sel, "\n", "<BR>")
	info_sel = replacetext(info_sel, "\[b\]", "<B>")
	info_sel = replacetext(info_sel, "\[/b\]", "</B>")
	info_sel = replacetext(info_sel, "\[i\]", "<I>")
	info_sel = replacetext(info_sel, "\[/i\]", "</I>")
	info_sel = replacetext(info_sel, "\[u\]", "<U>")
	info_sel = replacetext(info_sel, "\[/u\]", "</U>")
	info_sel = replacetext(info_sel, "\[hr\]", "<HR>")
	info_sel = replacetext(info_sel, "\[/hr\]", "</HR>")
	info_sel = replacetext(info_sel, "\[sup\]", "<SUP>")
	info_sel = replacetext(info_sel, "\[/sup\]", "</SUP>")
	info_sel = replacetext(info_sel, "\[h1\]", "<H1>")
	info_sel = replacetext(info_sel, "\[/h1\]", "</H1>")
	info_sel = replacetext(info_sel, "\[h2\]", "<H2>")
	info_sel = replacetext(info_sel, "\[/h2\]", "</H2>")
	info_sel = replacetext(info_sel, "\[h3\]", "<H3>")
	info_sel = replacetext(info_sel, "\[/h3\]", "</H3>")
	info_sel = replacetext(info_sel, "\[h4\]", "<H4>")
	info_sel = replacetext(info_sel, "\[/h4\]", "</H4>")
	info_sel = replacetext(info_sel, "\[li\]", "<LI>")
	info_sel = replacetext(info_sel, "\[/li\]", "</LI>")
	info_sel = replacetext(info_sel, "\[bq\]", "<BLOCKQUOTE>")
	info_sel = replacetext(info_sel, "\[/bq\]", "</BLOCKQUOTE>")
	return info_sel

/// trim text down to max length for contents
/obj/machinery/printing_press/proc/trim_input(var/info_sel)
	return copytext(info_sel, 1, 4*MAX_MESSAGE_LEN) //for now this is ~700 words, 4096 characters, please increase if people say that its too restrictive/low

/////////////////////
//Book making stuff//
/////////////////////

/obj/machinery/printing_press/proc/make_books() //alright so this makes our books
	src.is_running = TRUE
	var/books_to_make = src.book_amount
	while (books_to_make)

		if (src.paper_amt < 2 || src.ink_level < 2) // can we keep doin printing?
			if (src.paper_amt < 2) // If we don't have enough paper to print...
				src.visible_message("\The [src] runs out of paper and stops printing.")
			if (src.ink_level < 2) // ...or enough ink
				src.visible_message("\The [src] runs out of ink and stops printing.")

			src.is_running = FALSE
			UpdateIcon()
			break

		playsound(src.loc, 'sound/machines/printer_press.ogg', 50, 1)
		UpdateIcon()

		var/obj/item/paper/book/custom/B = new

		if (src.book_name)
			B.name = src.book_name
		else
			B.name = "unnamed book"

		B.desc = "A book printed by a machine! The future is now! (if you live in the 15th century)"
		if (src.book_author)
			B.desc += " It says it was written by [src.book_author]."
		else
			B.desc += " It says it was written by... anonymous."

		if (src.book_cover)
			if (src.book_cover == "custom")
				B.custom_cover = 1
				B.cover_color = src.cover_color
				B.cover_symbol = src.cover_symbol
				B.symbol_color = src.symbol_color
				B.cover_flair = src.cover_flair
				B.flair_color = src.flair_color
				B.symbol_colorable = src.symbol_colorable
				B.flair_colorable = src.flair_colorable
			B.info = src.book_info
			B.ink_color = src.ink_color
			B.book_cover = src.book_cover
			B.build_custom_book()
			B.layer = src.layer + 0.1
		TRANSFER_OR_DROP(src, B)
		books_to_make--
		src.ink_level -= 2
		src.paper_amt -= 2

	src.is_running = FALSE
	UpdateIcon() //just in case?
	src.visible_message("\The [src] finishes printing and shuts down.")

/obj/machinery/printing_press/proc/make_newspapers()
	src.is_running = TRUE
	var/newspapers_to_print = src.newspaper_amount
	while (newspapers_to_print)
		if (src.paper_amt < 2 || src.ink_level < 1) // can we keep doin printing?
			if (src.paper_amt < 2) // If we don't have enough paper to print...
				src.visible_message("\The [src] runs out of paper and stops printing.")
			if (src.ink_level < 1) // ...or enough ink
				src.visible_message("\The [src] runs out of ink and stops printing.")
			src.is_running = FALSE
			UpdateIcon()
			break

		var/obj/item/paper/newspaper/rolled/NP = new
		NP.info = ""
		// it can auto generate headlines and publisher if left alone, that's handled in New() and overwritten here.
		if (src.newspaper_publisher)
			NP.publisher = src.newspaper_publisher
		NP.name = "[NP.publisher]"
		if (src.newspaper_headline)
			NP.headline = src.newspaper_headline
		NP.info += "<b>[src.newspaper_headline]</b><br>"
		if (src.newspaper_info)
			NP.info += src.newspaper_info
		else
			NP.info += NP.generate_article()
		NP.update_desc()
		TRANSFER_OR_DROP(src, NP)
		newspapers_to_print--
		src.ink_level -= 1
		src.paper_amt -= 2

	src.is_running = FALSE
	UpdateIcon()
	src.visible_message("\The [src] finishes printing and shuts down.")


/obj/item/press_upgrade //parent just to i dont have to set name and icon a bunch i am PEAK lazy
	name = "printing press upgrade module"
	icon = 'icons/obj/module.dmi'

/obj/item/press_upgrade/colors //custom font color upgrade
	desc = "Looks like this upgrade module is for letting your press use colored ink!"
	icon_state = "press_colors"

/obj/item/press_upgrade/books //custom covers upgrade
	desc = "Looks like this upgrade module is for letting your press customise book covers!"
	icon_state = "press_books"

/obj/item/press_upgrade/ink //using press_upgrade so i dont have to set icon i really am the laziest coder
	name = "ink cartridge"
	desc = "Looks like this is an ink restock cartridge for the printing press!"
	icon_state = "press_ink"

/obj/item/press_upgrade/forbidden //has some crazy wacky book covers, symbols, flairs
	name = "bootleg printing press upgrade module"
	desc = "This press upgrade looks sketchy as fuck."
	icon_state = "press_forbidden"

/obj/item/press_upgrade/newspaper //allows you to print newspapers
	desc = "Looks like this upgrade module is for letting you print newspapers!"
	icon_state = "press_newspaper"

/obj/item/electronics/frame/press_frame //this is really dumb dont kill me, just wanna make it qm orderable
	name = "Printing Press frame"
	store_type = /obj/machinery/printing_press
	viewstat = 2
	secured = 2
	icon_state = "dbox"

/obj/item/paper/press_warning
	name = "printing press setup warning"
	info = {"
<b>WARNING BEFORE INSTALLING your new ACADEMY PRINTING PRESS by AURORA LITHOGRAPHICS</b>
<br>In this shipment you received a frame for your new Academy automated offset Printing Press.
<br>This device takes up 2 standard floor tiles once fully deployed.
<br>If you are seeking to set up your own Academy Printing Press, be aware:
<ul>
	<li>The left side of the device will be deployed on the tile where the frame is.
	<li>The right side of the device will be one tile to the right of the frame.
	<li>If the device cannot fit, it will attempt to deploy one tile to the left.
	<li>If there is no space available at all, the device will fail to deploy.
</ul>
<br>Congratulations on your new adventure in self-publishing!
<br><i>Aurora Lithographics</i>
<br><i>Aurora-on-Cayuga, NY</i>
"}
