/datum/buildmode/clipboard
	name = "Clipboard"
	desc = {"***********************************************************<br>
Left Mouse Button                      = Paste object<br>
Right Mouse Button                     = Select object to copy<br>
***********************************************************"}
	icon_state = "buildmode11"
	var/tmp/atom/cloned = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!cloned)
			return
		var/turf/T = get_turf(object)
		if (isobj(cloned))
			var/obj/O = cloned:clone()
			O.set_loc(T)
			O.appearance = cloned.appearance
			O.set_dir(cloned.dir)
		else if (isturf(cloned))
			var/turf/t = new cloned.type(T)
			t.appearance = cloned.appearance
		blink(T)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (isturf(object))
			cloned = object
			boutput(usr, "<span class='notice'>Selected [object] for copying by reference.</span>")
			update_button_text("Copying [object] by reference.")
		else if (isobj(object))
			cloned = object:clone()
			boutput(usr, "<span class='notice'>Selected [object] for copying.</span>")
			update_button_text("Copying [object].")
