/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-+WANTED-POSTER+-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

// so things don't have to grab a new instance of this every time they need it
var/global/icon/wanted_poster_unknown = icon('icons/obj/decals/posters.dmi', "wanted-unknown")

// admin poster generation thing
/proc/gen_poster(var/target)
	if (!usr)
		return
	var/p_title = input(usr, "Enter title line", "Enter Title") as null|text
	if( p_title == null ) return//shoo
	var/p_image
	if (alert(usr, "Include picture of atom in poster?", "Add Image", "Yes", "No") == "Yes")
		if (!target)
			target = input(usr, "Select target", "Select target") as anything in world
		if (target)
			if (ismob(target))
				p_image = target:build_flat_icon(SOUTH)
			else if (isobj(target) || isturf(target) || isarea(target))
				p_image = getFlatIcon(target, SOUTH)
			else
				p_image = wanted_poster_unknown
		else
			p_image = wanted_poster_unknown

	var/p_i_sub = input(usr, "Enter subtitle to appear below image", "Enter Image Subtitle") as null|text
	var/p_l_title = input(usr, "Enter title to appear below image", "Enter Lower Title") as null|text
	var/p_l1 = input(usr, "Line 1 text", "Line 1 text") as null|text
	var/p_l2 = input(usr, "Line 2 text", "Line 2 text") as null|text
	var/p_l3 = input(usr, "Line 3 text", "Line 3 text") as null|text

	var/obj/item/poster/titled_photo/preview_np = new
	if (p_title)
		preview_np.line_title = p_title
	if (p_image)
		preview_np.poster_image = p_image
	if (p_i_sub)
		preview_np.line_photo_subtitle = p_i_sub
	if (p_l_title)
		preview_np.line_below_photo = p_l_title
	if (p_l1)
		preview_np.line_b1 = p_l1
	if (p_l2)
		preview_np.line_b2 = p_l2
	if (p_l3)
		preview_np.line_b3 = p_l3
	preview_np.generate_poster()
	preview_np.show_popup_win(usr)

	var/print_or_place = alert(usr, "Print out at all printers or place on your tile?", "Selection", "Place", "Print")
	if (alert(usr, "Confirm poster creation", "Confirmation", "OK", "Cancel") == "OK")
		if (print_or_place == "Print")
			for_by_tcl(P, /obj/machinery/networked/printer)
				if (P.status & (NOPOWER|BROKEN))
					continue
				FLICK("printer-printing",P)
				playsound(P.loc, 'sound/machines/printer_dotmatrix.ogg', 50, 1)
				SPAWN(3.2 SECONDS)
					var/obj/item/poster/titled_photo/np = new(get_turf(P))
					if (p_title)
						np.line_title = p_title
					if (p_image)
						np.poster_image = p_image
					if (p_i_sub)
						np.line_photo_subtitle = p_i_sub
					if (p_l_title)
						np.line_below_photo = p_l_title
					if (p_l1)
						np.line_b1 = p_l1
					if (p_l2)
						np.line_b2 = p_l2
					if (p_l3)
						np.line_b3 = p_l3
					np.generate_poster()
		else
			var/obj/item/poster/titled_photo/np = new(get_turf(usr))
			if (p_title)
				np.line_title = p_title
			if (p_image)
				np.poster_image = p_image
			if (p_i_sub)
				np.line_photo_subtitle = p_i_sub
			if (p_l_title)
				np.line_below_photo = p_l_title
			if (p_l1)
				np.line_b1 = p_l1
			if (p_l2)
				np.line_b2 = p_l2
			if (p_l3)
				np.line_b3 = p_l3
			np.generate_poster()

		logTheThing(LOG_ADMIN, usr, "created a poster[print_or_place == "Print" ? " at all printers" : null]")
		message_admins("[key_name(usr)] created a poster[print_or_place == "Print" ? " at all printers" : null]")

/proc/create_jailbird_wanted_poster(mob/living/carbon/human/H)
	var/reason = "Previous criminal activity."
	if (H.job == "Stowaway")
		reason = "Unauthorized boarding of a Nanotrasen [station_or_ship()]."
	else
		var/datum/db_record/sec_record = data_core.security.find_record("id", H.datacore_id)
		if (sec_record)
			reason = "[sec_record["ma_crim"]] [sec_record["mi_crim"]]"
	mass_print_wanted_poster(
		uppertext(H.real_name),
		H.build_flat_icon(),
		"FROM CAMERA FOOTAGE",
		"WANTED: ALIVE",
		null, // no bounty
		"<b>WANTED FOR:</b> [reason]",
		"<center><i>NANOTRASEN AUTOMATED NOTICE</i></center>"
	)

/// Print a wanted poster to all station-level printers
/proc/mass_print_wanted_poster(name, wanted_image, subtitle, dead_or_alive, bounty, wanted_for, notes)
	for_by_tcl(P, /obj/machinery/networked/printer)
		if (P.status & (NOPOWER|BROKEN))
			continue
		if (P.z != Z_LEVEL_STATION)
			continue
		FLICK("printer-printing",P)
		playsound(P.loc, 'sound/machines/printer_dotmatrix.ogg', 50, 1)
		SPAWN(3.2 SECONDS)
			var/obj/item/poster/titled_photo/wp = new(get_turf(P))
			if (name)
				wp.line_title = name
			if (wanted_image)
				wp.poster_image = wanted_image
			if (subtitle)
				wp.line_photo_subtitle = subtitle
			if (dead_or_alive)
				wp.line_below_photo = dead_or_alive
			if (bounty)
				wp.line_b1 = bounty
			if (wanted_for)
				wp.line_b2 = wanted_for
			if (notes)
				wp.line_b3 = notes
			wp.generate_poster()

// admin wanted poster gen
/proc/gen_wp(var/target)
	if (!usr)
		return
	if (!target)
		target = input(usr, "Enter custom name", "Enter Name") as null|text
	var/w_name
	var/w_image
	var/w_sub
	if (target)
		if (ismob(target))
			w_name = uppertext(target:real_name)
			w_image = target:build_flat_icon()
			w_sub = "FILE PHOTO"
		else if (isobj(target) || isturf(target) || isarea(target))
			w_name = uppertext(target:name)
			w_image = getFlatIcon(target, SOUTH)
			w_sub = "FILE PHOTO"
		else
			w_name = uppertext(target)
			w_image = wanted_poster_unknown
	else
		w_name = "UNKNOWN"
		w_image = wanted_poster_unknown
		w_sub = "FILE PHOTO"

	var/doa = input(usr, "Dead or Alive", "Dead or Alive", "DEAD OR ALIVE") as null|text
	if (doa)
		doa = "WANTED: [uppertext(doa)]"
	var/w_bounty = input(usr, "Bounty", "Bounty", 0) as null|num
	if (w_bounty)
		w_bounty = "<center><b>[w_bounty] CREDIT REWARD</b></center>"
	var/w_for = input(usr, "Wanted For", "Wanted For") as null|text
	if (w_for)
		w_for = "<b>WANTED FOR:</b> [uppertext(w_for)]"
	var/w_notes = input(usr, "Notes", "Notes") as null|text
	if (w_notes)
		w_notes = "<b>NOTES:</b> [uppertext(w_notes)]"

	var/obj/item/poster/titled_photo/preview_wp = new
	if (w_name)
		preview_wp.line_title = w_name
	if (w_image)
		preview_wp.poster_image = w_image
	if (w_sub)
		preview_wp.line_photo_subtitle = w_sub
	if (doa)
		preview_wp.line_below_photo = doa
	if (w_bounty)
		preview_wp.line_b1 = w_bounty
	if (w_for)
		preview_wp.line_b2 = w_for
	if (w_notes)
		preview_wp.line_b3 = w_notes
	preview_wp.generate_poster()
	preview_wp.show_popup_win(usr)

	var/print_or_place = alert(usr, "Print out at all printers or place on your tile?", "Selection", "Place", "Print")
	if (alert(usr, "Confirm poster creation", "Confirmation", "OK", "Cancel") == "OK")
		if (print_or_place == "Print")
			mass_print_wanted_poster(
				w_name,
				w_image,
				w_sub,
				doa,
				w_bounty,
				w_for,
				w_notes
			)
		else
			var/obj/item/poster/titled_photo/wp = new(get_turf(usr))
			if (w_name)
				wp.line_title = w_name
			if (w_image)
				wp.poster_image = w_image
			if (w_sub)
				wp.line_photo_subtitle = w_sub
			if (doa)
				wp.line_below_photo = doa
			if (w_bounty)
				wp.line_b1 = w_bounty
			if (w_for)
				wp.line_b2 = w_for
			if (w_notes)
				wp.line_b3 = w_notes
			wp.generate_poster()

		logTheThing(LOG_ADMIN, usr, "created a wanted poster targeting [w_name][print_or_place == "Print" ? " at all printers" : null]")
		message_admins("[key_name(usr)] created a wanted poster targeting [w_name][print_or_place == "Print" ? " at all printers" : null]")

/mob/proc/build_flat_icon(var/direction)
	var/icon/comp = getFlatIcon(src, direction ? direction : null)
	return comp

/mob/living/carbon/human/build_flat_icon(var/direction)
	var/icon/return_icon
	if (src.mutantrace) //TODO: #14465
		return_icon = icon(src.mutantrace.get_typeinfo().icon, src.mutantrace.icon_state, direction ? direction : null)
	else
		return_icon = icon('icons/mob/human.dmi', "body_[src.gender == MALE ? "m" : "f"]", direction ? direction : null)

	if (src.bioHolder && src.bioHolder.mobAppearance)
		return_icon.Blend(src.bioHolder.mobAppearance.s_tone ? src.bioHolder.mobAppearance.s_tone : "#FFFFFF", ICON_MULTIPLY)

		var/icon/undies = icon('icons/mob/human_underwear.dmi', src.bioHolder.mobAppearance.underwear, direction ? direction : null)
		undies.Blend(src.bioHolder.mobAppearance.u_color ? src.bioHolder.mobAppearance.u_color : "#FFFFFF", ICON_MULTIPLY)
		return_icon.Blend(undies, ICON_OVERLAY)
		undies = null
	var/image/I = image(src)
	I.dir = direction // force the direction to prevent it differing from the other icons
	var/icon/comp = getFlatIcon(I, direction)
	return_icon.Blend(comp, ICON_OVERLAY)
	return return_icon

/obj/item/poster
	name = "poster"
	desc = null
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "wall_poster_nt"
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER+1

	//cogwerks - burning vars (stolen from paper - haine)
	burn_point = 220
	burn_output = 900
	burn_possible = TRUE
	health = 15

	var/imgw = 400
	var/imgh = 450
	var/pixel_var = 1
	var/popup_win = 1
	var/no_spam = null
	var/can_put_up = 1

	New()
		..()
		if (src.pixel_var)
			src.pixel_y = rand(-9,9)
			src.pixel_x = rand(-8,8)

	examine(mob/user)
		if (src.popup_win)
			src.show_popup_win(user)
			return list()
		else
			return ..()

	proc/show_popup_win(var/client/C)
		return
	ex_act(var/severity)
		qdel(src)
	attack_hand(mob/user)
		if (!src.anchored)
			return ..()
		if (user.a_intent != INTENT_HARM)
			src.show_popup_win(user.client)
			return
		var/turf/T = src.loc
		user.visible_message(SPAN_ALERT("<b>[user]</b> rips down [src] from [T]!"),\
		SPAN_ALERT("You rip down [src] from [T]!"))
		var/obj/decal/cleanable/ripped_poster/decal = make_cleanable(/obj/decal/cleanable/ripped_poster,T)
		decal.icon_state = "[src.icon_state]-rip2"
		decal.pixel_x = src.pixel_x
		decal.pixel_y = src.pixel_y
		src.anchored = UNANCHORED
		src.icon_state = "[src.icon_state]-rip1"
		src.can_put_up = 0
		user.put_in_hand_or_drop(src)

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		if (src.can_put_up && (istype(A, /turf/simulated/wall) || istype(A, /turf/simulated/shuttle/wall) || istype(A, /turf/unsimulated/wall)))
			user.visible_message("<b>[user]</b> attaches [src] to [A].",\
			"You attach [src] to [A].")
			user.u_equip(src)
			src.set_loc(A)
			src.anchored = ANCHORED
		else
			return ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.popup_win && !ON_COOLDOWN(target, "poster_spam", 8 SECONDS))
			user.tri_message(target, SPAN_ALERT("<b>[user]</b> shoves [src] in [user == target ? "[his_or_her(user)] own" : "[target]'s"] face!"),\
				SPAN_ALERT("You shove [src] in [user == target ? "your own" : "[target]'s"] face!"),\
				SPAN_ALERT("[target == user ? "You shove" : "<b>[user]</b> shoves"] [src] in your[target == user ? " own" : null] face!"))
			if (target.client)
				SETUP_GENERIC_ACTIONBAR(user, target, 2 SECONDS, PROC_REF(show_popup_win), target.client, src.icon, src.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED)
			src.no_spam = ticker.round_elapsed_ticks
		else
			return // don't attack people with the poster thanks

/obj/item/poster/titled_photo
	icon_state = "wanted"

	var/icon/poster_image = null // for file photos from the database
	var/poster_image_old = null
	var/obj/item/photo/photo = null // other photos - currently unused
	var/line_title = null
	var/poster_HTML = null
	var/line_photo_subtitle = null
	var/line_below_photo = null
	var/line_b1 = null
	var/line_b2 = null
	var/line_b3 = null
	var/author = null

	var/list/plist = null

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (!src.poster_HTML)
				src.generate_poster()

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/photo))
			var/obj/item/photo/new_p = W
			if (src.photo)
				user.show_text("You replace [src.photo] with [new_p].")
				var/obj/item/photo/old_p = src.photo
				src.photo = new_p
				user.u_equip(new_p)
				new_p.set_loc(src)
				user.put_in_hand_or_drop(old_p)
				src.poster_image = new_p.fullIcon
			else
				user.show_text("You stick [new_p] to [src].")
				src.photo = new_p
				user.u_equip(new_p)
				new_p.set_loc(src)
				src.poster_image_old = src.poster_image
				src.poster_image = new_p.fullIcon
			src.generate_poster()
		else
			return ..()

	attack_hand(mob/user)
		if (src.photo)
			if (src.anchored && user.a_intent == INTENT_HARM)
				return ..()
			user.show_text("You remove [src.photo] from [src].")
			var/obj/item/photo/old_p = src.photo
			src.photo = null
			user.put_in_hand_or_drop(old_p)
			if (src.poster_image_old)
				src.poster_image = src.poster_image_old
			else
				src.poster_image = null
			src.generate_poster()
		else
			return ..()

	show_popup_win(var/client/C)
		if (!C || !src.popup_win || !src.poster_HTML)
			return
		C << browse_rsc(src.poster_image, "posterimage.png")
		C.Browse(src.poster_HTML, "window=[src.line_title]_poster;size=[src.imgw]x[src.imgh];title=[src.line_title]")

	proc/generate_poster()
		src.poster_HTML = {"<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=8\"/></head><body><title>Poster</title>\
		[src.line_title ? "<h2><center><b>[src.line_title]</b></center></h2>" : null]<hr>\
		[src.poster_image ? "<center><img style=\"-ms-interpolation-mode:nearest-neighbor;\" src=posterimage.png height=96 width=96></center><br>" : null]\
		[src.line_photo_subtitle ? "<center><small><sup>[src.line_photo_subtitle]</sup></small></center>" : null]<hr>\
		[src.line_below_photo ? "<b><big><center>[src.line_below_photo]</center></big></b><br>" : null]\
		[src.line_b1 ? "[src.line_b1]<br>" : null]\
		[src.line_b2 ? "[src.line_b2]<br>" : null]\
		[src.line_b3 ? "[src.line_b3]" : null]"}

/obj/decal/cleanable/ripped_poster
	name = "ripped poster"
	desc = "Someone didn't want this here, but a little bit is always left."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "wall_poster_nt-rip2"

TYPEINFO(/obj/submachine/poster_creator)
	mats = 6

/obj/submachine/poster_creator
	name = "wanted poster station"
	desc = "A machine that can design and print out wanted posters."
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL
	icon = 'icons/obj/objects.dmi'
	icon_state = "poster_printer"
	var/pdata = null
	var/list/plist = null
	var/papers = 20

	get_desc()
		. += "There's [src.papers] paper[s_es(src.papers)] loaded into it."

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if (user.client)
			src.add_dialog(user)
			show_window(user.client)
			onclose(user, "wp_station")

	attackby(var/obj/item/W, var/mob/user)
		src.add_fingerprint(user)
		if (istype(W, /obj/item/paper))
			user.visible_message("[user] loads [W] into [src].",\
			"You load [W] into [src].")
			src.papers ++
			user.u_equip(W)
			qdel(W)
			return

		else if (istype_exact(W, /obj/item/paper_bin)) // no artifact or robots pls
			var/obj/item/paper_bin/bin = W
			var/total_amount = bin.amount_left
			for(var/obj/item/paper/P in bin)
				total_amount += 1
				qdel(P)
			if (total_amount <= 0)
				boutput(user, SPAN_ALERT("\The [bin] is empty!"))
				return
			user.visible_message("[user] loads [bin] into [src].",\
			"You load [total_amount] sheets from [bin] into [src].")
			src.papers += total_amount
			bin.amount_left -= bin.amount_left
			bin.update()

		else if (istype(W, /obj/item/photo))
			var/obj/item/photo/P = W
			if (!istype(P.fullIcon))
				boutput(user, SPAN_ALERT("\The [src] fails to scan [P]!"))
				return
			src.ensure_plist()
			src.plist["image"] = P.fullIcon
			src.plist["subtitle"] = "RECENT PHOTO"
			user.visible_message("[user] scans [P] into [src].",\
			"You scan [P] into [src].")
			src.generate_html()
			return

		else if (istype(W, /obj/item/poster/titled_photo))
			var/obj/item/poster/titled_photo/P = W
			if (!islist(P.plist))
				boutput(user, SPAN_ALERT("\The [src] fails to scan [P]!"))
				return
			src.plist = P.plist.Copy()
			user.visible_message("[user] scans [P] into [src].",\
			"You scan [P] into [src].")
			src.generate_html()
			return

		else
			return ..()

	proc/show_window(var/client/C)
		if (!C)
			return
		src.ensure_plist()
		if (!src.pdata)
			src.generate_html()
		C << browse_rsc(src.plist["image"], "pm_posterimage.png")
		C.Browse(src.pdata, "window=wp_station;size=400x450;title=[src.plist["name"]]")

	proc/generate_html()
		src.ensure_plist()

		src.pdata = "<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=8\"/></head><body><title>Wanted Poster</title>"
		src.pdata += "<right><A href='?src=\ref[src];print=1'>PRINT</A></right><br>"
		src.pdata += "<h2><center><b><A href='?src=\ref[src];entername=1'>NAME: [src.plist["name"]]</A></b></center></h2><hr>"
		src.pdata += "<center><img style=\"-ms-interpolation-mode:nearest-neighbor;\" src=pm_posterimage.png height=96 width=96></center><br>"
		src.pdata += "<center><small><sup>[src.plist["subtitle"]]<br>"
		src.pdata += "<A href='?src=\ref[src];selectphoto=1'>\[SEARCH\]</A> <A href='?src=\ref[src];resetphoto=1'>\[X\]</A></sup></small></center><hr>"
		src.pdata += "<b><big><center><A href='?src=\ref[src];enterdoa=1'>WANTED: [src.plist["wanted"]]</A></center></big></b><br>"
		src.pdata += "<center><b><A href='?src=\ref[src];enterreward=1'>[src.plist["reward"]] CREDIT REWARD</A></b></center><br>"
		src.pdata += "<A href='?src=\ref[src];enterfor=1'><b>WANTED FOR:</b> [src.plist["for"]]</A><br>"
		src.pdata += "<A href='?src=\ref[src];enternotes=1'><b>NOTES:</b> [src.plist["notes"]]</A><br>"
		src.pdata += "</body></html>"

	proc/print_poster(mob/user as mob)
		if (src.papers <= 0)
			boutput(user, SPAN_ALERT("\The [src] is out of paper!"))
			return
		if (!islist(src.plist))
			boutput(user, SPAN_ALERT("\The [src] buzzes grumpily!"))
			return
		src.papers --
		playsound(src, 'sound/machines/printer_dotmatrix.ogg', 30, TRUE)
		var/obj/item/poster/titled_photo/P = new (src.loc)
		P.author = user.key
		P.name = "Wanted: [src.plist["name"]]"
		P.line_title = "NAME: [src.plist["name"]]"
		P.poster_image = src.plist["image"]
		P.line_photo_subtitle = src.plist["subtitle"]
		P.line_below_photo = "WANTED: [src.plist["wanted"]]"
		P.line_b1 = "<center><b>[src.plist["reward"]] CREDIT REWARD</b></center>"
		P.line_b2 = "<b>WANTED FOR:</b> [src.plist["for"]]"
		P.line_b3 = "<b>NOTES:</b> [src.plist["notes"]]"
		P.plist = src.plist.Copy()

	proc/ensure_plist()
		if (!islist(src.plist))
			src.plist = list("name"="UNKNOWN","image"= wanted_poster_unknown,"subtitle"="NO PHOTO","wanted"="DEAD OR ALIVE","reward"=0,"for"="UNKNOWN","notes"="NONE")

	Topic(href, href_list)
		if (!usr || !usr.client)
			return ..()
		if (BOUNDS_DIST(usr, src) > 0)
			boutput(usr, SPAN_ALERT("You need to be closer to [src] to do that!"))
			return
		src.ensure_plist()

		if (href_list["print"])
			var/pnum = input(usr, "Enter amount to print:", "Print Amount", 1) as null|num
			if (isnull(pnum) || BOUNDS_DIST(usr, src) > 0)
				return
			logTheThing(LOG_STATION, usr, "printed out [pnum] wanted poster(s) [log_loc(src)] contents: name [src.plist["name"]], subtitle [src.plist["subtitle"]], wanted [src.plist["wanted"]], for [src.plist["for"]], notes [src.plist["notes"]]")
			for (var/i = clamp(pnum, 1, src.papers), i>0, i--)
				if (src.papers <= 0)
					break
				src.print_poster(usr)
				sleep(1 SECOND)
			return

		else if (href_list["entername"])
			var/ptext = scrubbed_input(usr, "Enter name:", "Name", src.plist["name"])
			if (isnull(ptext) || !length(ptext) || BOUNDS_DIST(usr, src) > 0)
				return
			src.plist["name"] = ptext
			logTheThing(LOG_STATION, usr, "edited wanted poster's name: [ptext]")

		else if (href_list["selectphoto"])
			var/ptext = scrubbed_input(usr, "Enter name or ID of crew to search for:", "Locate File Photo", src.plist["name"])
			if (isnull(ptext) || !length(ptext) || BOUNDS_DIST(usr, src) > 0)
				return
			var/datum/db_record/R
			for (var/datum/db_record/rec as anything in data_core.general.records)
				if ((ckey(rec["name"]) == ckey(ptext) || rec["id"] == ptext))
					R = rec
					break
			if (!istype(R))
				boutput(usr, SPAN_ALERT("No record found for \"[ptext]\"."))
				return
			var/datum/computer/file/image/IMG = R["file_photo"]
			if (!istype(IMG) || !IMG.ourIcon)
				boutput(usr, SPAN_ALERT("No photo exists on file for \"[ptext]\"."))
				return
			src.plist["image"] = IMG.ourIcon
			src.plist["subtitle"] = "FILE PHOTO"

		else if (href_list["resetphoto"])
			src.plist["image"] = wanted_poster_unknown
			src.plist["subtitle"] = "NO PHOTO"

		else if (href_list["enterdoa"])
			var/ptext = scrubbed_input(usr, "Enter wanted level:", "Wanted Level", src.plist["wanted"])
			if (isnull(ptext) || !length(ptext) || BOUNDS_DIST(usr, src) > 0)
				return
			src.plist["wanted"] = ptext
			logTheThing(LOG_STATION, usr, "edited wanted poster's wanted: [ptext]")

		else if (href_list["enterreward"])
			var/pnum = input(usr, "Enter reward amount:", "Reward", src.plist["reward"]) as null|num
			if (isnull(pnum) || BOUNDS_DIST(usr, src) > 0)
				return
			src.plist["reward"] = pnum

		else if (href_list["enterfor"])
			var/ptext = scrubbed_input(usr, "Enter wanted information:", "Wanted For", src.plist["for"])
			if (isnull(ptext) || !length(ptext) || BOUNDS_DIST(usr, src) > 0)
				return
			src.plist["for"] = ptext
			logTheThing(LOG_STATION, usr, "edited wanted poster's for: [ptext]")

		else if (href_list["enternotes"])
			var/ptext = scrubbed_input(usr, "Enter notes:", "Notes", src.plist["notes"])
			if (isnull(ptext) || !length(ptext) || BOUNDS_DIST(usr, src) > 0)
				return
			src.plist["notes"] = ptext
			logTheThing(LOG_STATION, usr, "edited wanted poster's notes: [ptext]")

		else
			return

		src.generate_html()
		src.show_window(usr.client)
