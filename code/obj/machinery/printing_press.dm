/obj/machinery/printing_press //this makes books
	name = "\improper Academy automated printing press"
	desc = "This is an Aurora Lithographics 'Academy' model automated printing press, used to reproduce books and pamphlets. This doesn't still use stone plates, does it?"
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "printing_press" //proper icon is set in UpdateIcon
	anchored = ANCHORED
	density = 1
	bound_width = 64 //the game just handles xtra wide objects already halleluiah

	var/const/paper_max = 70
	var/const/ink_max = 500

	var/paper_amt = 0 //empty by default, 0 to 70
	var/was_paper = 0 //workaround for now, need to update icon if paper_amt is 0 to clear overlay
	var/is_running = 0 //1 if its working, 0 when idle/depowered
	var/colors_upgrade = 0 //0 by default, set to 1 when ink colors upgrade is installed
	var/books_upgrade = 0 //0 by default, set to 1 when custom book covers upgrade is installed
	var/forbidden_upgrade = 0 //0 by default, set to 1 when forbidden covers/symbols/styles upgrade is installed
	var/ink_level = 100 //decrements by 2 for each book printed, can be refilled (expensively)
	var/list/press_modes = list("Choose cover", "Set book info", "Set book contents",\
	"Amount to make", "Print books", "View Information") //default, can be expanded to have "Ink Colors" and "Custom Cover"

	var/book_amount = 0 //how many books to make?
	var/book_cover = "" //what cover design to use?
	var/book_info = "" //what text will the made books have?
	var/book_info_raw = "" // raw version of the text, for editing.
	var/book_name = "" //whats the made books name?
	var/const/info_len_lim = 64 //64 character titles/author names max
	var/book_author = "" //who made the book?
	var/ink_color = "#000000" //what color is the text written in?
	var/list/cover_designs = list("Grey", "Dull red", "Red", "Blue", "Green", "Yellow", "Dummies", "Robuddy", "Skull", "Latch", "Bee",\
	"Albert", "Surgery", "Law", "Nuke", "Rat", "Pharma", "Bar") //list of covers to choose from
	var/list/non_writing_icons = list("bible") //just the bible for now. !!!add covers to this list if their icon file isnt icons/obj/writing.dmi!!!

	var/cover_color = "#FFFFFF" //white by default, what colour will our book be?
	var/cover_symbol = "" //what symbol is on our front cover?
	var/symbol_color = "#FFFFFF" //white by default, if our symbol is colourable, what colour is it?
	var/cover_flair = "" //whats the "flair" thing on the book?
	var/flair_color = "#FFFFFF" //white by default, whats the color of the flair (if its colorable)?
	var/symbol_colorable = 0 //this is a bugfix for non-colourable symbols being coloured
	var/flair_colorable = 0 //this is a bugfix for non-colourable flairs being coloured

	var/list/standard_symbols = list("None", "Bee", "Blood", "Eye", "No", "Clown", "Wizhat", "CoolS", "Brimstone", "Duck", "Planet+Moon", "Sol",\
	"Candle", "Shelterbee")//symbols that cant be colored
	var/list/colorable_symbols = list("None", "Skull", "Drop", "Shortcross", "Smile", "One", "FadeCircle", "Square", "NT", "Ghost", "Bone",\
	"Heart", "Pentagram", "Key", "Lock") //list of symbols that can be coloured
	var/list/alchemical_symbols = list("None", "Mercury", "Salt", "Sulfur", "Urine", "Water", "Fire", "Air", "Earth", "Calcination", "Congelation",\
	"Fixation", "Dissolution", "Digestion", "Distillation", "Sublimation", "Seperation", "Ceration", "Fermentation", "Multiplication",\
	"Projection") //alchemical symbols (because theres a lot of them)
	var/list/alphanumeric_symbols = list("None", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",\
	"T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
	var/list/standard_flairs = list("None", "Gold", "Latch", "Dirty", "Scratch", "Torn") //flairs that cant be coloured
	var/list/colorable_flairs = list("None", "Corners", "Bookmark", "RightCover", "SpineCover") //flairs that can be coloured

////////////////////
//Appearance stuff//
////////////////////

	update_icon() //this runs every time something would change the amt of paper, or if its working or done working, handles paper overlay and work animation
		if (paper_amt || was_paper)
			if (GetOverlayImage("paper"))
				ClearSpecificOverlays("paper")
			var/image/I = SafeGetOverlayImage("paper", src.icon, "paper-[round(paper_amt / 10)]")
			src.UpdateOverlays(I, "paper")
			was_paper = 0
		if (ink_level)
			if (GetOverlayImage("ink"))
				ClearSpecificOverlays("ink")
			var/ink_num = round(ink_level / 100) //idk, this should probably work
			var/image/I = SafeGetOverlayImage("ink", src.icon, "ink-[ink_num]")
			src.UpdateOverlays(I, "ink")
		if (is_running)
			flick("printing_press-work", src)
			return
		icon_state = "printing_press-idle"

	get_desc(var/dist)
		if (dist > 6)
			return
		var/press_desc = ""
		switch(paper_amt / paper_max * 100)
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

		if ((ink_level / ink_max) < 0.1)
			press_desc += " The ink is running low."

		if (is_running)
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

	attackby(var/obj/item/W, mob/user)
		if (istype(W, /obj/item/paper_bin))
			var/obj/item/paper_bin/P = W
			if (P.amount > 0 && paper_amt <= paper_max) //if the paper bin has paper, and adding the paper bin doesnt add too much paper
				boutput(user, "You load \the [P] into \the [src].")
				var/amount_to_take = paper_max - paper_amt
				var/amount_taken = min(amount_to_take, P.amount)
				paper_amt += amount_taken
				UpdateIcon()
				P.amount = P.amount - amount_taken
				P.update()
				return
			else
				if (P.amount <= 0)
					if (P.contents.len > 0)
						boutput(user, "\The [P] has no unsoiled sheets left in it.") // someone put junk paper in the bin
					else
						boutput(user, "\The [P] has no paper left in it.") // its just plain empty
					return
				boutput(user, "\The [src] is already fully loaded with paper!")

		else if (istype(W, /obj/item/paper) && !istype(W, /obj/item/paper/book)) //should also exclude all other weird paper subtypes, but i think books are the only one
			if (paper_amt < paper_max)
				boutput(user, "You load \the [W] into \the [src].")
				paper_amt++
				UpdateIcon()
				user.drop_item()
				qdel(W)
			else
				boutput(user, "\The [src] is too full for that!")
				return

		else if (istype(W, /obj/item/press_upgrade))
			switch (W.icon_state)
				if ("press_colors")
					if (colors_upgrade)
						src.visible_message("\The [src] already has that upgrade installed.")
						return
					colors_upgrade = 1
					press_modes += "Ink color"
					src.visible_message("\The [src] accepts the upgrade.")
				if ("press_books")
					if (books_upgrade)
						src.visible_message("\The [src] already has that upgrade installed.")
						return
					books_upgrade = 1
					press_modes += "Customise cover"
					src.visible_message("\The [src] accepts the upgrade.")
				if ("press_forbidden")
					if (forbidden_upgrade)
						src.visible_message("\The [src] already has that upgrade installed.")
						return
					forbidden_upgrade = 1
					standard_symbols += list("Anarchy", "Syndie")
					colorable_symbols += list("FixMe")
					standard_flairs += list("Fire")
					cover_designs += list("Necronomicon", "Old", "Bible")
					src.visible_message("\The [src] accepts the upgrade.")
				if ("press_ink")
					if ((ink_level + 100) <= ink_max) //500ink internal resevoir
						ink_level += 100
						boutput(user, "Ink refilled.")
						UpdateIcon() //to show ink level change
					else
						boutput(user, "\The [src] doesn't need an ink refill yet.")
						return
				else //in case some wiseguy tries the parent im watching u
					boutput(user, "no good, asshole >:\[")
					return
			qdel(W)
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

		else
			..()

	attack_hand(var/mob/user) //all of our mode controls and setters here, these control what the books are/look like/have as contents
		if (is_running)
			boutput(user, "\The [src] is busy.") //machine is running
			return
		var/mode_sel = input("What would you like to do?", "Mode Control") as null|anything in press_modes
		if (!mode_sel) //just in case? idk if this is necessary
			return

		switch (lowertext(mode_sel))

			if ("choose cover")
				var/cover_sel = input("What cover design would you like?", "Cover Control", book_cover) as null|anything in cover_designs
				if (!cover_sel)
					book_cover = "book0"
				else
					switch (lowertext(cover_sel))
						if ("grey")
							book_cover = "book0"
						if ("dull red")
							book_cover = "book1"
						if ("red")
							book_cover = "book7"
						if ("blue")
							book_cover = "book2"
						if ("green")
							book_cover = "book3"
						if ("yellow")
							book_cover = "book6"
						if ("dummies")
							book_cover = "book4"
						if ("robuddy")
							book_cover = "book5"
						if ("skull")
							book_cover = "sbook"
						if ("latch")
							book_cover = "bookcc"
						if ("bee")
							book_cover = "booktth"
						if ("albert")
							book_cover = "bookadps"
						if ("surgery")
							book_cover = "surgical_textbook"
						if ("law")
							book_cover = "spacelaw"
						if ("nuke")
							book_cover = "nuclearguide"
						if ("rat")
							book_cover = "ratbook"
						if ("pharma")
							book_cover = "pharmacopia"
						if ("bar")
							book_cover = "barguide"
						if ("necronomicon")
							book_cover = "necronomicon"
						if ("bible")
							book_cover = "bible"
						if ("old")
							book_cover = "oldbook"
						else
							book_cover = "book0"
				boutput(user, "Book cover set.")
				return

			if ("set book info")
				var/name_sel = input("What do you want the title of your book to be?", "Information Control", book_name) //total information control! the patriots control the memes, snake!
				if (length(name_sel) > info_len_lim)
					boutput(user, "Aborting, title too long.")
					return
				book_name = strip_html(name_sel)
				var/author_sel = input("Who is the author of your book?", "Information Control", book_author)
				if (length(author_sel) > info_len_lim)
					boutput(user, "Aborting, author name too long.")
					return
				book_author = strip_html(author_sel)
				boutput(user, "Information set.")
				return

			if ("set book contents")
				var/info_sel = input("What do you want your book to say?", "Content Control", book_info_raw) as null|message
				if (!info_sel)
					return
				info_sel = copytext(html_encode(info_sel), 1, 4*MAX_MESSAGE_LEN) //for now this is ~700 words, 4096 characters, please increase if people say that its too restrictive/low
				book_info_raw = info_sel
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
				book_info = info_sel
				boutput(user, "Book contents set.")
				return

			if ("amount to make")
				var/amount_sel = input("How many books do you want to make? ([round(paper_amt / 2)] max)", "Ream Control", book_amount) as num
/*				if ((amount_sel * 2) > paper_amt) //2*amount sel is the amount of paper
					boutput(user, "Not enough paper.")
					return*/
				if (amount_sel > 0 && amount_sel <= (paper_amt / 2)) //is the number in range?
					boutput(user, "Book amount set.")
					book_amount = amount_sel
				else
					boutput(user, "Amount out of range.")

			if ("print books")
				if (is_running)
					boutput(user, "\The [src] is busy.")
					return
				if (!book_amount)
					boutput(user, "Invalid book amount.")
					return
				if (ink_level < 2)
					// you can't even print a single book. nice one, doofus
					src.visible_message("Not enough ink.")
					return
				logTheThing(LOG_SAY, user, "made some books with the name: [book_name] | the author: [book_author] | the contents: [book_info]") //book logging
				make_books()
				return

			if ("ink color")
				if (colors_upgrade) //can never be too safe
					var/color_sel = input("What colour would you like the ink to be?", "Ink Control") as color
					if (color_sel)
						ink_color = color_sel

			if ("customise cover")
				if (books_upgrade) //can never be too safe
					book_cover = "custom" //so we can bypass normal cover selection in the bookmaking process
					var/cover_color_sel = input("What colour would you like the cover to be?", "Cover Control") as color
					if (cover_color_sel)
						cover_color = cover_color_sel

					var/s_cat_sel = input("What type of symbol would you like?", "Cover Control") as null|anything in list("Standard", "Colorable", "Alchemical", "Alphanumeric")
					switch (lowertext(s_cat_sel))
						if ("standard")
							var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in standard_symbols
							if (symbol_sel)
								cover_symbol = lowertext(symbol_sel)
								symbol_colorable = 0
							else
								cover_symbol = "none"

						if ("colorable")
							var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in colorable_symbols
							if (symbol_sel)
								cover_symbol = lowertext(symbol_sel)
								var/color_sel = input("What color would you like the symbol to be?", "Cover Control") as color
								if (color_sel)
									symbol_color = color_sel
									symbol_colorable = 1
							else
								cover_symbol = "none"

						if ("alchemical")
							var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in alchemical_symbols
							if (symbol_sel)
								cover_symbol = lowertext(symbol_sel)
								symbol_colorable = 0
							else
								cover_symbol = "none"

						if ("alphanumeric")
							var/symbol_sel = input("What would you like the symbol to be?", "Cover Control") as null|anything in alphanumeric_symbols
							if (symbol_sel)
								cover_symbol = lowertext(symbol_sel)
								var/color_sel = input("What color would you like the symbol to be?", "Cover Control") as color
								if (color_sel)
									symbol_color = color_sel
									symbol_colorable = 1
							else
								cover_symbol = "none"

					var/f_cat_sel = input("What type of flair would you like?", "Cover Control") as null|anything in list("Standard", "Colorable")

					if (f_cat_sel == "Standard")
						var/flair_sel = input("What would you like the flair to be?", "Cover Control") as null|anything in standard_flairs
						if (flair_sel)
							cover_flair = lowertext(flair_sel)
							flair_colorable = 0
						else
							cover_flair = "none"

					else if (f_cat_sel == "Colorable")
						var/flair_sel = input("What would you like the flair to be?", "Cover Control") as null|anything in colorable_flairs
						if (flair_sel)
							cover_flair = lowertext(flair_sel)
							var/color_sel = input("What color would you like the flair to be?", "Cover Control") as color
							if (color_sel)
								flair_color = color_sel
								flair_colorable = 1
						else
							cover_flair = "none"

			if ("view information")
				if (book_author)
					boutput(user, "The author is [book_author].")
				else
					boutput(user, "There is no author set.")
				if (book_name)
					boutput(user, "The title is [book_name].")
				else
					boutput(user, "There is no title set.")
				return

			else //just in case, yell at me if this is bad
				return

/////////////////////
//Book making stuff//
/////////////////////

	proc/make_books() //alright so this makes our books
		is_running = 1
		var/books_to_make = book_amount
		while (books_to_make)

			if (paper_amt < 2 || ink_level < 2) // can we keep doin printing?
				if (paper_amt < 2) // If we don't have enough paper to print...
					src.visible_message("\The [src] runs out of paper and stops printing.")
				if (ink_level < 2) // ...or enough ink
					src.visible_message("\The [src] runs out of ink and stops printing.")

				is_running = 0
				UpdateIcon()
				break

			playsound(src.loc, 'sound/machines/printer_press.ogg', 50, 1)
			UpdateIcon()

			var/obj/item/paper/book/custom/B = new(get_turf(src))

			if (book_name)
				B.name = src.book_name
			else
				B.name = "unnamed book"

			B.desc = "A book printed by a machine! The future is now! (if you live in the 15th century)"
			if (book_author)
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
					B.flair_color = src.cover_flair
					B.symbol_colorable = src.symbol_colorable
					B.flair_colorable = src.flair_colorable
				B.info = src.book_info
				B.ink_color = src.ink_color
				B.book_cover = src.book_cover
				B.build_custom_book()
/*					if (cover_color) //should always be yes
						var/image/I = SafeGetOverlayImage("cover", B.icon, "base-colorable")
						I.color = cover_color
						B.UpdateOverlays(I, "cover")
					if (cover_symbol)
						var/image/I = SafeGetOverlayImage("symbol", B.icon, "symbol-[cover_symbol]")
						if (symbol_colorable)
							I.color = symbol_color
						B.UpdateOverlays(I, "symbol")
					if (cover_flair)
						var/image/I = SafeGetOverlayImage("flair", B.icon, "flair-[cover_flair]")
						if (flair_colorable)
							I.color = flair_color
						B.UpdateOverlays(I, "flair")
				else
					if (book_cover in non_writing_icons) //for our non-writing.dmi icons
						switch (book_cover)
							if ("bible")
								B.icon = 'icons/obj/items/storage.dmi'
								B.icon_state = book_cover
					else
						B.icon_state = book_cover
			else
				B.icon_state = "book0"
			if (book_info)
				B.info = "<span style=\"color:[src.ink_color]\">[src.book_info]</span>"*/

			books_to_make--
			ink_level -= 2
			paper_amt -= 2

		is_running = 0
		UpdateIcon() //just in case?
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
