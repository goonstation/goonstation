/datum/buildmode/location
	name = "Location"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Set location turf<br>
Ctrl + LMB mob/obj                 = Set location inside of mob or object<br>
Right Mouse Button on mob/obj      = Select Target<br>
***********************************************************"}
	icon_state = "buildlocation"
	var/tmp/atom/movable/target = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!src.target || !object) return
		if (!get_turf(object)) return

		if (ctrl)
			if (!ismob(object) && !isobj(object))
				return
			if (ismob(target))
				var/mob/M = target
				M.set_loc(object)
			else if (isobj(target))
				var/obj/O = target
				O.set_loc(object)
			else
				boutput(usr, "<span class='alert'>ERROR - You somehow have a non mob/obj target!</span>")
		else
			var/turf/T = null
			if (isturf(object))
				T = object
			else
				T = get_turf(object)
			if (ismob(target))
				var/mob/M = target
				M.set_loc(T)
			else if (isobj(target))
				var/obj/O = target
				O.set_loc(T)
			else
				boutput(usr, "<span class='alert'>ERROR - You somehow have a non mob/obj target!</span>")
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (isobj(object) || ismob(object))
			src.target = object
			blink(get_turf(object))
			update_button_text(object.name)
