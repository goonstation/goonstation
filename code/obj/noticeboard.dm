/obj/noticeboard
	name = "notice board"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	pixel_y = 32
	plane = PLANE_NOSHADOW_BELOW
	desc = "A board for pinning important notices upon."
	density = 0
	anchored = ANCHORED
	var/notices = 0

/obj/noticeboard/north
	pixel_y = 32

/obj/noticeboard/east
	dir = EAST
	pixel_x = 32
	pixel_y = 0

/obj/noticeboard/west
	dir = WEST
	pixel_x = -32
	pixel_y = 0
/obj/noticeboard/ex_act()
	qdel(src)


/obj/noticeboard/attackby(var/obj/item/O, var/mob/user)
	if (istype(O, /obj/item/paper) || istype(O, /obj/item/canvas))
		if (src.notices < 15)
			O.add_fingerprint(user)
			src.add_fingerprint(user)
			user.drop_item()
			O.set_loc(src)
			src.notices++
			src.UpdateIcon()
			boutput(user, SPAN_NOTICE("You pin \the [O] to the noticeboard."))
			src.updateUsrDialog()
		else
			boutput(user, SPAN_ALERT("You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached."))


/obj/noticeboard/update_icon()
	src.icon_state = "nboard0[min(src.notices, 5)]"


/obj/noticeboard/attack_hand(mob/user)
	var/dat = "<B>Noticeboard</B><BR>"
	for(var/obj/item/item in src)
		if(istype(item, /obj/item/paper) || istype(item, /obj/item/canvas))
			dat += "<A href='byond://?src=\ref[src];read=\ref[item]'>[item]</A> <A href='byond://?src=\ref[src];remove=\ref[item]'>Remove</A><BR>"
	user.Browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")

/obj/noticeboard/attack_ai(mob/user)
	src.Attackhand(user)

/obj/noticeboard/Topic(href, href_list)
	if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
		return
	if (is_incapacitated(usr) || usr.restrained())
		return

	..()

	src.add_dialog(usr)
	if (href_list["remove"])
		var/obj/item/I = locate(href_list["remove"])
		if (I?.loc == src)
			usr.put_in_hand_or_drop(I)
			I.add_fingerprint(usr)
			src.add_fingerprint(usr)
			src.notices--
			src.UpdateIcon()
			src.updateUsrDialog()

	if (href_list["read"])
		var/obj/item/I = locate(href_list["read"])
		if (I?.loc == src)
			if(istype(I, /obj/item/canvas))
				var/obj/item/canvas/canvas = I
				canvas.pop_open_a_browser_box(usr)
			else
				I.ui_interact(usr)


#define PERSISTENT_NOTICEBOARD_VERSION 1

/obj/noticeboard/persistent
	name = "persistent notice board"
	desc = "A board for pinning important notices upon. Looks like this one doesn't get cleared out at the end of the shift."
	var/static/file_name = "data/persistent_noticeboards.json"
	var/static/data = null
	var/persistent_id = null

/obj/noticeboard/persistent/north
	pixel_y = 32

/obj/noticeboard/persistent/east
	dir = EAST
	pixel_x = 32
	pixel_y = 0

/obj/noticeboard/persistent/west
	dir = WEST
	pixel_x = -32
	pixel_y = 0

/obj/noticeboard/persistent/New()
	. = ..()
	if(isnull(src.persistent_id))
		CRASH("A noticeboard has null id.")
	for_by_tcl(other_noticeboard, /obj/noticeboard/persistent)
		if(other_noticeboard.persistent_id == src.persistent_id)
			CRASH("Two persistent noticeboards share the id: [persistent_id].")
	START_TRACKING
	src.load_stuff()

/obj/noticeboard/persistent/disposing()
	STOP_TRACKING
	. = ..()

/obj/noticeboard/persistent/proc/load_stuff()
	if(isnull(src.data))
		if(fexists(src.file_name))
			src.data = json_decode(file2text(src.file_name))
	if(isnull(src.data))
		src.data = list("_version" = PERSISTENT_NOTICEBOARD_VERSION)
	if(src.persistent_id in src.data)
		var/list/our_data = src.data[src.persistent_id]
		var/version = our_data["_version"] || 0
		if(version == 0)
			for(var/list/book_info in our_data)
				var/obj/item/paper/paper = new(src)
				paper.name = book_info[1]
				paper.info = book_info[2]
				paper.fingerprintslast = book_info[3]
				if(length(book_info) >= 4) // Gotta love adding a line that will be useful exactly once on each server...
					paper.color = book_info[4]
		if(version == 1)
			for(var/list/info in our_data["things"])
				var/obj/item/item = null
				switch(info["type"])
					if("paper")
						var/obj/item/paper/paper = new(src)
						item = paper
						paper.info = info["info"]
						paper.color = info["color"]
					if("canvas")
						var/obj/item/canvas/lazy_restore/canvas = new(src, info["id"])
						item = canvas
				if(isnull(item))
					continue
				item.name = info["name"]
				item.fingerprintslast = info["fingerprintslast"]

	src.notices = length(src.contents)
	src.UpdateIcon()

/obj/noticeboard/persistent/proc/save_stuff()
	src.data[src.persistent_id] = list("things" = list())
	for(var/obj/item/paper/paper in src)
		src.data[src.persistent_id]["things"] += list(list(
			"type" = "paper",
			"name" = paper.name,
			"info" = paper.info,
			"fingerprintslast" = paper.fingerprintslast,
			"color" = paper.color
			))
	var/i = 0
	for(var/obj/item/canvas/canvas in src)
		i++
		var/canvas_id = "[src.persistent_id]_[i]"
		canvas.save_to_id(canvas_id)
		src.data[src.persistent_id]["things"] += list(list(
			"type" = "canvas",
			"name" = canvas.name,
			"id" = canvas_id,
			"fingerprintslast" = canvas.fingerprintslast
			))
	src.data[src.persistent_id]["_version"] = PERSISTENT_NOTICEBOARD_VERSION

proc/save_noticeboards()
	var/obj/noticeboard/persistent/some_board = null
	for_by_tcl(board, /obj/noticeboard/persistent)
		board.save_stuff()
		some_board = board
	if(isnull(some_board))
		logTheThing(LOG_DEBUG, null, "No persistent noticeboards to save.")
		return
	rustg_file_write(json_encode(some_board.data), some_board.file_name)


#undef PERSISTENT_NOTICEBOARD_VERSION
