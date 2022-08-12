/obj/bookshelf
	name = "bookshelf"
	desc = "A storage unit designed to fit a lot of books. Been a while since you've seen one of these!"
	icon = 'icons/obj/furniture/bookshelf.dmi'
	icon_state = "bookshelf_small"
	anchored = 1
	density = 1
	var/capacity = 30 //how many books can it hold?
	var/list/obj/item/paper/bookshelf_contents = list() //ordered list of books

/obj/bookshelf/New()
	..()
	src.UpdateIcon()

/obj/bookshelf/update_icon()
	var/icon_state_suffix
	if (length(src.bookshelf_contents) == 0)
		icon_state_suffix = ""
	else if (length(src.bookshelf_contents) < 3) //from 0 to 2 books
		icon_state_suffix = "-1"
	else if (length(src.bookshelf_contents) < 6) //from 3 to 5 books
		icon_state_suffix = "-2"
	else if (length(src.bookshelf_contents) < 9) // 6 to 8 books
		icon_state_suffix = "-3"
	else if (length(src.bookshelf_contents) < 14) // 9 to 13 books
		icon_state_suffix = "-4"
	else if (length(src.bookshelf_contents) < 19) // 14 to 18 books
		icon_state_suffix = "-5"
	else if (length(src.bookshelf_contents) < 25) // 19 to 24 books
		icon_state_suffix = "-6"
	else if (length(src.bookshelf_contents) < 30) // 25 to 29 books
		icon_state_suffix = "-7"
	else // 30+ books, or - books
		icon_state_suffix = "-8"

	src.set_icon_state("[initial(src.icon_state)][icon_state_suffix]")

/obj/bookshelf/proc/add_to_bookshelf(var/obj/item/I)
	src.bookshelf_contents.Add(I)
	I.set_loc(src)
	src.UpdateIcon()

/obj/bookshelf/proc/take_off_bookshelf(var/obj/item/I)
	src.bookshelf_contents.Remove(I)
	I.set_loc(get_turf(src))
	src.UpdateIcon()

/obj/bookshelf/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/bible))
		boutput(user, "\The [W] is too holy to be put on a shelf with non-holy books.")
		return

	proc/update_icon()
		ClearSpecificOverlays("top_shelf", "middle_shelf", "bottom_shelf") //lets avoid any weird ghosts
		var/image/top_image = null //initialise these 3 so we can set them inside of the conditionals
		var/image/middle_image = null
		var/image/bottom_image = null

		if (bookshelf_contents.len) //were almost always drawing the top shelf
			var/icon/top = new(src.icon, "bookshelf_full_[update_icon_suffix]") //makes a new icon that we can crop from the full bookshelf icon
			var/list/top_crop = list() //creating this rn so we can modify it in an if thing while also being able to reference it outside of those ifs
			if (bookshelf_contents.len > top_shelf_cap) //lets see how to call our crop location proc, it returns a list of pixels that we crop to
				top_crop = book_overlay_logic_center(top_shelf_cap) //if theres more books on the shelf than on the top row, just generate the top row
			else
				top_crop = book_overlay_logic_center(bookshelf_contents.len) //if theres less than the shelf capacity, lets get the pixel locations for that
			if ("sideways" in top_crop) //some shelves have sideways books, i have custom icons for that scenario that we'll use instead of a crop
				if (bookshelf_contents.len == 1) //values for which there are sideways books in the full book icon
					top_image = SafeGetOverlayImage("top_shelf", src.icon, "2_sideways_1")
				else
					top_image = SafeGetOverlayImage("top_shelf", src.icon, "2_sideways_2")
			else
				top.Crop(top_crop[1], top_crop[2], top_crop[3], top_crop[4]) //this crops our icon, but it resets offsets back to 1,1
				top_image = image(top) //sets the image we made at the beginning to our cropped icon, we'll fix the offsets later

		if (bookshelf_contents.len > top_shelf_cap) //is the top shelf full? move onto the middle shelf
			var/icon/middle = new(src.icon, "bookshelf_full_[update_icon_suffix]")
			var/list/middle_crop = list()
			if (bookshelf_contents.len > (top_shelf_cap + middle_shelf_cap))
				middle_crop = book_overlay_logic_center(top_shelf_cap + middle_shelf_cap)
			else
				middle_crop = book_overlay_logic_center(bookshelf_contents.len)
			if ("sideways" in middle_crop)
				switch(bookshelf_contents.len)
					if (8)
						middle_image = SafeGetOverlayImage("middle_shelf", src.icon, "2_sideways_3")
					if (9)
						middle_image = SafeGetOverlayImage("middle_shelf", src.icon, "2_sideways_4")
					if (10)
						middle_image = SafeGetOverlayImage("middle_shelf", src.icon, "wall_sideways_1")
					if (11)
						middle_image = SafeGetOverlayImage("middle_shelf", src.icon, "wall_sideways_2")
			else
				middle.Crop(middle_crop[1], middle_crop[2], middle_crop[3], middle_crop[4])
				middle_image = image(middle)

		if (bookshelf_contents.len > (top_shelf_cap + middle_shelf_cap)) //is the middle shelf full? move onto the bottom shelf
			var/icon/bottom = new(src.icon, "bookshelf_full_[update_icon_suffix]")
			var/list/bottom_crop = book_overlay_logic_center(bookshelf_contents.len) //dont need the if because the bottom shelf is the last shelf!!
			if ("sideways" in bottom_crop)
				if (bookshelf_contents.len == 26)
					bottom_image = SafeGetOverlayImage("bottom_shelf", src.icon, "wall_sideways_3")
				else
					bottom_image = SafeGetOverlayImage("bottom_shelf", src.icon, "wall_sideways_4")
			else
				bottom.Crop(bottom_crop[1], bottom_crop[2], bottom_crop[3], bottom_crop[4])
				bottom_image = image(bottom)

		if (top_image) //now we handle offsets and updating the icon
			switch(update_icon_suffix) //theres so many variants with different pixel offsets that this is best, i think
				if ("1")
					top_image.pixel_x += 6
					top_image.pixel_y += 15
				if ("2")
					top_image.pixel_x += 6
					top_image.pixel_y += 15
				if ("wall")
					top_image.pixel_y += 16
				if ("L")
					top_image.pixel_x += 1
					top_image.pixel_y += 16
				if ("R")
					top_image.pixel_y += 16
			UpdateOverlays(top_image, "top_shelf")

		if (middle_image)
			switch(update_icon_suffix)
				if ("1")
					middle_image.pixel_x += 6
					middle_image.pixel_y += 8
				if ("2")
					middle_image.pixel_x += 6
					middle_image.pixel_y += 8
				if ("wall")
					middle_image.pixel_y += 9
				if ("L")
					middle_image.pixel_x += 1
					middle_image.pixel_y += 9
				if ("R")
					middle_image.pixel_x += 1
					middle_image.pixel_y += 9
			UpdateOverlays(middle_image, "middle_shelf")

		if (bottom_image)
			switch(update_icon_suffix)
				if ("1")
					bottom_image.pixel_x += 6
					bottom_image.pixel_y += 1
				if ("2")
					bottom_image.pixel_x += 6
					bottom_image.pixel_y += 1
				if ("wall")
					bottom_image.pixel_y += 2
				if ("L")
					bottom_image.pixel_x += 1
					bottom_image.pixel_y += 2
				if ("R")
					bottom_image.pixel_x += 1
					bottom_image.pixel_y += 2
			UpdateOverlays(bottom_image, "bottom_shelf")

	proc/book_overlay_logic_center(var/book_count) //this proc lets us just go through and get coordinates of where to crop our book image to
		if (variant && update_icon_suffix == "2")
			book_count += 17 //to deal with variants on the og bookshelves
		return shelf_overlay_list[book_count]

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/bible))
			boutput(user, "\The [W] is too holy to be put on a shelf with non-holy books.")
		else if (istype(W, /obj/item/paper/book))
			if (!(bookshelf_contents.len >= capacity))
				boutput(user, "You shelf the book.")
				user.drop_item()
				add_to_bookshelf(W)
				update_icon()
			else
				boutput(user, "\The [src] is too full!")
		else if (istype(W, /obj/item/wrench))
			if (src.contents.len > 0)
				boutput(user, "You can't take apart \the [src] if there's still books on it.")
				return
			user.visible_message("[user] starts to take apart \the [src].", "You start to take apart \the [src].")
			if (!do_after(user, 2 SECONDS))
				return
			user.visible_message("[user] takes \the [src] apart.", "You take \the [src] apart.")
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			new /obj/item/furniture_parts/bookshelf(src.loc)
			qdel(src)
		else
			boutput(user, "\The [src] is too full!")
			return

	else if (istype(W, /obj/item/wrench))
		if (length(src.bookshelf_contents) > 0)
			boutput(user, "You can't take apart \the [src] if there's still books on it.")
			return

		user.visible_message("[user] starts to take apart \the [src].", "You start to take apart \the [src].")
		SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/bookshelf/proc/deconstruct, list(), W.icon, W.icon_state,\
		"[user] takes \the [src] apart.", null)
		return

	else
		boutput(user, "You can't shelf that!")
		return

/obj/bookshelf/attack_hand(mob/user)
	if (length(src.bookshelf_contents) > 0)
		var/book_sel = input("What book would you like to take off \the [src]?", "[src]") as null|anything in src.bookshelf_contents
		if (!book_sel)
			return
		boutput(user, "You take the book off the shelf.")
		src.take_off_bookshelf(book_sel)
		user.put_in_hand_or_drop(book_sel)
		src.UpdateIcon()
	else
		boutput(user, "There's nothing to take off the shelf!")

/obj/bookshelf/proc/deconstruct()
	playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
	var/obj/parts = new /obj/item/furniture_parts/bookshelf
	parts.set_loc(src.loc)
	qdel(src)

/obj/bookshelf/persistent
	desc = "This bookshelf doesn't get cleaned out between shifts. Neat!"
	var/file_name = "data/persistent_bookshelf.json"

	New()
		..()
		for_by_tcl(other_bookshelf, /obj/bookshelf/persistent)
			if(other_bookshelf.file_name == src.file_name)
				CRASH("Two persistent bookshelves targeting the same file [file_name].")
		START_TRACKING
		src.load_old_books()

	disposing()
		STOP_TRACKING
		..()

	proc/load_old_books()
		var/list/old_contents = list()
		if (fexists(file_name))
			old_contents = json_decode(file2text(file_name))
			build_old_contents(old_contents)

	proc/file_curr_books(var/list/curr_contents)
		if (!curr_contents.len)
			return
		if(fexists(file_name))
			fdel(file_name) //we rly dont want a duplicate, or to accidentally output twice to the file, it could screw the whole thing up
		text2file(json_encode(curr_contents), file_name)

	proc/build_old_contents(var/list/old_contents) //this goes and takes our giant weird list and makes it into books
		for (var/list/book_vars in old_contents)
			if (book_vars["custom_cover"] == 0) //0 means this isnt a custom book
				var/obj/item/paper/book/B = new(get_turf(src))
				B.name = book_vars["name"]
				B.desc = book_vars["desc"]
				// B.icon = icon(book_vars["icon"])
				B.icon_state = book_vars["icon_state"]
				B.info = book_vars["info"]
				src.add_to_bookshelf(B)
			else //so it has to be a custom book now
				var/obj/item/paper/book/custom/B = new(get_turf(src))
				B.name = book_vars["name"]
				B.desc = book_vars["desc"]
				// B.icon = icon(book_vars["icon"])
				B.icon_state = book_vars["icon_state"]
				B.info = book_vars["info"]
				B.custom_cover = book_vars["custom_cover"]
				B.ink_color = book_vars["ink_color"]
				B.book_cover = book_vars["book_cover"]
				B.cover_color = book_vars["cover_color"]
				B.cover_symbol = book_vars["cover_symbol"]
				B.symbol_color = book_vars["symbol_color"]
				B.cover_flair = book_vars["cover_flair"]
				B.flair_color = book_vars["flair_color"]
				B.symbol_colorable = book_vars["symbol_colorable"]
				B.flair_colorable = book_vars["flair_colorable"]
				B.build_custom_book()
				src.add_to_bookshelf(B)
		src.UpdateIcon()

	proc/build_curr_contents() //this takes our books and makes it into a giant weird list
		var/list/curr_contents = list()
		if (src.contents.len)
			for (var/i = 1, i <= src.contents.len, i++)
				if (istype(src.contents[i], /obj/item/paper/book)) //just in case
					var/obj/item/paper/book/B = src.contents[i]
					var/list/book_vars = list()
					book_vars["name"] = B.name
					book_vars["desc"] = B.desc
					// book_vars["icon"] = "[B.icon]"
					book_vars["icon_state"] = B.icon_state
					book_vars["info"] = B.info
					if (istype(B, /obj/item/paper/book/custom))
						var/obj/item/paper/book/custom/C = B
						book_vars["custom_cover"] = C.custom_cover
						book_vars["ink_color"] = C.ink_color
						book_vars["book_cover"] = C.book_cover
						book_vars["cover_color"] = C.cover_color
						book_vars["cover_symbol"] = C.cover_symbol
						book_vars["symbol_color"] = C.symbol_color
						book_vars["cover_flair"] = C.cover_flair
						book_vars["flair_color"] = C.flair_color
						book_vars["symbol_colorable"] = C.symbol_colorable
						book_vars["flair_colorable"] = C.flair_colorable
					else
						book_vars["custom_cover"] = 0 //this stops build_old_contents early
					curr_contents.Add(list(book_vars))
			file_curr_books(curr_contents)

/obj/item/furniture_parts/bookshelf
	name = "bookshelf parts"
	desc = "A collection of parts that can be used to construct a bookshelf."
	icon = 'icons/obj/furniture/bookshelf.dmi'
	icon_state = "bookshelf_parts"
	furniture_type = /obj/bookshelf
	furniture_name = "bookshelf"
