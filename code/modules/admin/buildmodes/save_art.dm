/datum/buildmode/save_art
	name = "Save Art"
	desc = {"***********************************************************<br>
Left Mouse Button      = Mark corners of area with two clicks<br>
Right Mouse Button     = Cancel the first corner<br>
***********************************************************"}
	icon_state = "buildmode5"
	var/turf/A = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!A)
			A = get_turf(object)
			boutput(usr, SPAN_NOTICE("Corner set!"))
			blink(A)
		else
			var/turf/B = get_turf(object)
			blink(B)
			if (!B || A.z != B.z)
				boutput(usr, SPAN_ALERT("Corners must be on the same Z-level!"))
				return
			var/x_size = (abs(A.x - B.x) + 1)
			var/y_size = (abs(A.y - B.y) + 1)
			if(alert("Are you sure you want to save the art in an area of size [x_size]x[y_size]?",,"Yes","No") != "Yes")
				boutput(usr, SPAN_ALERT("Saving cancelled!"))
				A = null
				return
			var/icon/I = icon('icons/misc/flatBlank.dmi')
			I.Crop(1, 1, x_size * world.icon_size, y_size * world.icon_size)
			for (var/turf/T in block(A, B))
				var/x_offset = (T.x - min(A.x, B.x)) * world.icon_size
				var/y_offset = (T.y - min(A.y, B.y)) * world.icon_size
				for (var/obj/decal/cleanable/writing/W in T.contents)
					I.Blend(getFlatIcon(W), ICON_OVERLAY, x= x_offset + W.pixel_x, y= y_offset + W.pixel_y)
			usr.client << ftp(I, "art_save_[world.timeofday].png")
			boutput(usr, SPAN_NOTICE("Art saved."))
			A = null

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		A = null
		boutput(usr, SPAN_NOTICE("Corner cancelled!"))
