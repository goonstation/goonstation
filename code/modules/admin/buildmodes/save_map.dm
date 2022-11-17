#define SAVE_MODE_DEFAULT 0
#define SAVE_MODE_NO_SPACE 1
#define SAVE_MODE_PREFAB 2
#define SAVE_MODE_PREFAB_UNSIM 3
#define SAVE_MODE_NO_TURFS 4

/datum/buildmode/save_map
	name = "Save Area"
	desc = {"***********************************************************<br>
Left Mouse Button on turf/mob/obj      = Mark corners of area with two clicks<br>
Right Mouse Button                     = Cancel the first corner<br>
Right Mouse Button on the mode         = Cycle saving modes<br>
***********************************************************"}
	icon_state = "buildmode5"
	var/tmp/turf/A = null
	var/tmp/saving = 0
	var/tmp/dmm_suite/dmm_suite
	var/mode_number = 0
	var/static/list/mode_names = list("default", "don't save space", "save as prefab", "save as unsimulated prefab", "don't save turfs")

	deselected()
		..()
		A = null

	selected()
		. = ..()
		update_mode()

	click_mode_right(var/ctrl, var/alt, var/shift)
		mode_number = (mode_number + 1) % length(mode_names)
		update_mode()

	proc/update_mode()
		if(mode_number == SAVE_MODE_PREFAB)
			src.dmm_suite = new/dmm_suite/prefab_saving
		else if(mode_number == SAVE_MODE_PREFAB_UNSIM)
			src.dmm_suite = new/dmm_suite/prefab_saving/unsimulate
		else
			src.dmm_suite = new/dmm_suite
		update_button_text(mode_names[mode_number + 1])

	proc/mark_corner(atom/object)
		A = get_turf(object)
		boutput(usr, "<span class='notice'>Corner set!</span>")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!A)
			mark_corner(object)
			blink(A)
		else
			var/turf/B = get_turf(object)
			blink(B)
			if (!B || A.z != B.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
				return
			if(saving)
				boutput(usr, "<span class='alert'>Already saving a map!</span>")
				return
			if(alert("Are you sure you want to save an area of size [abs(A.x - B.x) + 1]x[abs(A.y - B.y) + 1]?",,"Yes","No") != "Yes")
				boutput(usr, "<span class='alert'>Saving cancelled!</span>")
				A = null
				return
			saving = 1
			var/fname = "adventure/map_save_[usr.client.ckey].dmm"
			if (fexists(fname))
				fdel(fname)
			var/target = file(fname)
			boutput(usr, "<span class='notice'>Saving started.</span>")
			var/flags = DMM_IGNORE_MOBS | DMM_IGNORE_OVERLAYS
			if(mode_number == SAVE_MODE_NO_SPACE)
				flags |= DMM_IGNORE_SPACE
			else if(mode_number == SAVE_MODE_NO_TURFS)
				flags |= DMM_IGNORE_AREAS | DMM_IGNORE_TURFS
			else if(mode_number == SAVE_MODE_PREFAB || mode_number == SAVE_MODE_PREFAB_UNSIM)
				flags |= DMM_IGNORE_AREAS
			var/text = dmm_suite.write_map(A, B, flags)
			target << text
			boutput(usr, "<span class='notice'>Saving finished.</span>")
			usr << ftp(target)
			saving = 0
			A = null

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		A = null
		boutput(usr, "<span class='notice'>Corner cancelled!</span>")

#undef SAVE_MODE_DEFAULT
#undef SAVE_MODE_NO_SPACE
#undef SAVE_MODE_PREFAB
#undef SAVE_MODE_PREFAB_UNSIM
#undef SAVE_MODE_NO_TURFS
