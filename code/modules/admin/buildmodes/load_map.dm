#define LOAD_MODE_DEFAULT 0
#define LOAD_MODE_DEL_OBJS 1
#define LOAD_MODE_DEL_ALL 2

datum/buildmode/load_map
	name = "Load Area"
	desc = {"***********************************************************<br>
Left Mouse Button on turf/mob/obj      = Load a .dmm file (with the tile clicked being the bottom left corner)<br>
Right Mouse Button on the mode         = Cycle loading modes<br>
***********************************************************"}
	icon_state = "buildmode5"
	var/tmp/loading = 0
	var/tmp/dmm_suite/dmm_suite
	var/mode_number = 0
	var/static/list/mode_names = list("no deleting", "delete objects first (slow!)", "delete objects AND MOBS first (slow!)")

	selected()
		. = ..()
		update_mode()

	click_mode_right(var/ctrl, var/alt, var/shift)
		mode_number = (mode_number + 1) % length(mode_names)
		update_mode()

	proc/update_mode()
		update_button_text(mode_names[mode_number + 1])

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if(!dmm_suite)
			dmm_suite = new(debug_id="buildmode")
		var/turf/A = get_turf(object)
		if (!A) return
		blink(A)
		if(loading)
			boutput(usr, "<span class='alert'>Already loading a map!</span>")
			return
		var/target = input("Select the map to load.", "Saved map upload", null) as null|file
		if(!target)
			loading = 0
			return
		dmm_suite.debug_id = "buildmode [target]"
		var/text = file2text(target)
		if(!text)
			loading = 0
			return
		loading = 1
		boutput(usr, "<span class='notice'>Loading started.</span>")
		var/overwrite_flags = 0
		if(mode_number == LOAD_MODE_DEL_OBJS)
			overwrite_flags |= DMM_OVERWRITE_OBJS
		else if(mode_number == LOAD_MODE_DEL_ALL)
			overwrite_flags |= DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS
		dmm_suite.read_map(text, A.x, A.y, A.z, flags = overwrite_flags)
		boutput(usr, "<span class='notice'>Loading finished.</span>")
		loading = 0


#undef LOAD_MODE_DEFAULT
#undef LOAD_MODE_DEL_OBJS
#undef LOAD_MODE_DEL_ALL
