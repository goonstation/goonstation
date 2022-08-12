/datum/buildmode/copy
	name = "Copy Paste"
	desc = {"***********************************************************<br>
Right Mouse Button on mob/obj = Select object for copying (right click on turf to clear)<br>
Left Mouse Button on turf  = Paste object on the turf you clicked<br>
Ctrl + Right Mouse Button on build mode  = Spawn for every living player<br>
***********************************************************"}
	icon_state = "copy"
	var/tmp/atom/copied_object

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl && src.copied_object && alert("Are you sure you want to give everyone \a [src.copied_object]?", "Give stuff???", "Yes", "No") == "Yes")
			for (var/client/cl as anything in clients)
				var/mob/living/L = cl.mob
				if(!istype(L) || isdead(L))
					continue
				semi_deep_copy(src.copied_object, L.loc)
				LAGCHECK(LAG_LOW)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = get_turf(object)
		if(src.copied_object && istype(T))
			blink(T)
			semi_deep_copy(src.copied_object, T)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if(isobj(object) || ismob(object))
			src.copied_object = object
			boutput(holder.owner, "Selected [src.copied_object] for copying.")
		else
			boutput(holder.owner, "Unselected copied object.")
			src.copied_object = null
		update_button_text(src.copied_object)
