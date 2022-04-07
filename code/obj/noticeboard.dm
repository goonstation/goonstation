/obj/noticeboard
	name = "notice board"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	pixel_y = 32
	flags = FPRINT
	plane = PLANE_NOSHADOW_BELOW
	desc = "A board for pinning important notices upon."
	density = 0
	anchored = 1
	var/notices = 0


/obj/noticeboard/ex_act()
	qdel(src)


/obj/noticeboard/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/paper))
		if (src.notices < 15)
			O.add_fingerprint(user)
			src.add_fingerprint(user)
			user.drop_item()
			O.set_loc(src)
			src.notices++
			src.UpdateIcon()
			boutput(user, "<span class='notice'>You pin the paper to the noticeboard.</span>")
			src.updateUsrDialog()
		else
			boutput(user, "<span class='alert'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>")


/obj/noticeboard/update_icon()
	src.icon_state = "nboard0[min(src.notices, 5)]"


/obj/noticeboard/attack_hand(mob/user as mob)
	var/dat = "<B>Noticeboard</B><BR>"
	for(var/obj/item/paper/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P)
	user.Browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")


/obj/noticeboard/Topic(href, href_list)
	if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
		return
	if (is_incapacitated(usr) || usr.restrained())
		return

	..()

	src.add_dialog(usr)
	if (href_list["remove"])
		var/obj/item/P = locate(href_list["remove"])
		if ((P && P.loc == src))
			P.set_loc(get_turf(src)) //dump paper on the floor because you're a clumsy fuck
			P.layer = HUD_LAYER
			P.add_fingerprint(usr)
			src.add_fingerprint(usr)
			src.notices--
			src.UpdateIcon()
			src.updateUsrDialog()

	if (href_list["read"])
		var/obj/item/paper/P = locate(href_list["read"])
		if ((P && P.loc == src))
			P.ui_interact(usr)

/obj/noticeboard/persistent
	name = "persistent notice board"
	desc = "A board for pinning important notices upon. Looks like this one doesn't get cleared out at the end of the shift."
	var/static/file_name = "data/persistent_noticeboards.json"
	var/static/data = null
	var/persistent_id = null

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
		src.data = list()
	if(src.persistent_id in src.data)
		for(var/list/book_info in src.data[src.persistent_id])
			var/obj/item/paper/paper = new(src)
			paper.name = book_info[1]
			paper.info = book_info[2]
			paper.fingerprintslast = book_info[3]
			if(book_info.len >= 4) // Gotta love adding a line that will be useful exactly once on each server...
				paper.color = book_info[4]
	src.notices = length(src.contents)
	src.UpdateIcon()

/obj/noticeboard/persistent/proc/save_stuff()
	src.data[src.persistent_id] = list()
	for(var/obj/item/paper/paper in src)
		src.data[src.persistent_id] += list(list(paper.name, paper.info, paper.fingerprintslast, paper.color))

proc/save_noticeboards()
	var/obj/noticeboard/persistent/some_board = null
	for_by_tcl(board, /obj/noticeboard/persistent)
		board.save_stuff()
		some_board = board
	if(isnull(some_board))
		logTheThing("debug", null, null, "No persistent noticeboards to save.")
		return
	fdel(some_board.file_name)
	var/json_data = json_encode(some_board.data)
//	logTheThing("debug", null, null, "Persistent noticeboard save data: [json_data]")
	text2file(json_data, some_board.file_name)
