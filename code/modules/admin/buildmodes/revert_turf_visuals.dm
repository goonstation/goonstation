/datum/buildmode/revert_turf
	name = "Revert turf visuals"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Revert (underlying) turf<br>
Right Mouse Button on mob/obj/turf = Revert block (with 2 clicks)<br>
Ctrl + RMB on buildmode button     = Reset selection<br>
***********************************************************"}
	icon_state = "revertturf"
	var/tmp/turf/A

	deselected()
		..()
		A = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = object
		if (!istype(T))
			T = get_turf(T)
		if (!T)
			return
		revert(T)

	click_right(atom/object, var/ctrl, var/alt, var/shift) //adapted from wide clipboard
		if (!A)
			A = get_turf(object)
			boutput(usr, "<span class='notice'>Corner 1 set.</span>")
			update_button_text("Corner 1 set.")
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>Corners must be on the same Z-level!</span>")
				return
			SPAWN(0)
				for (var/turf/Q in block(A,B))
					revert(Q)
				A = null
				update_button_text("Done.")
				boutput(usr, "<span class='notice'>Turfs reverted.</span>")

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			A = null
			update_button_text("Ready.")
			boutput(usr, "<span class='notice'>Selection reset.</span>")

	proc/revert(turf/object)
		if (istype(object, /turf/simulated/floor))
			if (!object.intact)
				return
			var/turf/simulated/floor/F = object
			F.icon = initial(F.icon)
			F.icon_state = F.roundstart_icon_state
			F.set_dir(F.roundstart_dir)
		else if (istype(object, /turf/simulated/wall))
			object.icon = initial(object.icon)
			if (istype(object, /turf/simulated/wall/auto))
				var/turf/simulated/wall/auto/W = object
				W.UpdateIcon()
				W.update_neighbors()
