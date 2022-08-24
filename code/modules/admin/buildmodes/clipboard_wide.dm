/datum/clipboardTurf
	var/rel_x = 0
	var/rel_y = 0
	var/turf_type = null
	var/turf_appearance = null
	var/turf_dir = 0
	var/list/objects = list()
	//var/list/objectAppearances (TODO)

/datum/buildmode/clipboard_wide
	name = "Wide Area Clipboard"
	desc = {"***********************************************************<br>
Ctrl + RMB on buildmode button         = Reset (if the copier bugs up)<br>
Left Mouse Button                      = Paste selected area. Selected tile will be the LOWER LEFT corner.<br>
Right Mouse Button                     = Select area to copy with two clicks<br>
***********************************************************"}
	icon_state = "buildmode11"
	var/tmp/turf/A
	var/tmp/list/clipboard = list()
	var/tmp/copying = 0

	deselected()
		..()
		A = null
		copying = 0

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			A = null
			copying = 0
			clipboard.len = 0
			boutput(usr, "<span class='alert'>Reset.</span>")
			update_button_text("Clipboard empty.")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!clipboard.len)
			return
		if (copying)
			boutput(usr, "<span class='alert'>Copying, please wait.</span>")
			return
		var/turf/T = get_turf(object)
		var/tx = T.x
		var/ty = T.y
		var/tz = T.z
		update_button_text("Pasting...")
		for (var/datum/clipboardTurf/CBT in clipboard)
			var/turf/TheOneToReplace = locate(tx + CBT.rel_x, ty + CBT.rel_y, tz)
			if (!TheOneToReplace)
				continue
			var/turf/R = TheOneToReplace.ReplaceWith(CBT.turf_type, FALSE, TRUE, FALSE, TRUE)
			R.appearance = CBT.turf_appearance
			R.set_dir(CBT.turf_dir)
			for (var/obj/O in CBT.objects)
				O.clone(R)
			blink(R)
		update_button_text("Ready to paste.")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (copying)
			boutput(usr, "<span class='alert'>Copying, please wait.</span>")
			return
		if (!A)
			A = get_turf(object)
			boutput(usr, "<span class='notice'>Corner 1 set.</span>")
			update_button_text("Corner 1 set.")
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
				return
			update_button_text("Copying...")
			copying = 1
			clipboard.len = 0
			var/minx = min(A.x, B.x)
			var/miny = min(A.y, B.y)
			var/workgroup = 0
			SPAWN(0)
				for (var/turf/Q in block(A,B))
					var/datum/clipboardTurf/CBT = new()
					CBT.rel_x = Q.x - minx
					CBT.rel_y = Q.y - miny
					CBT.turf_type = Q.type
					CBT.turf_appearance = Q.appearance
					CBT.turf_dir = Q.dir
					for (var/obj/O in Q)
						if (istype(O, /obj/overlay/tile_effect) || (O.loc != Q))
							continue
						CBT.objects += O.clone()
					clipboard += CBT
					workgroup++
					blink(Q)// NO. NO MORE LAG.
					if (workgroup > 8)
						workgroup = 0
						sleep(0.1 SECONDS)
				boutput(usr, "<span class='notice'>Copying complete!</span>")
				update_button_text("Ready to paste.")
				copying = 0
				A = null
