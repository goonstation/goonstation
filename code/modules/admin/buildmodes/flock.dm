/datum/buildmode/flock
	name = "Flock convert"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Flock convert that turf<br>
Right Mouse Button on buildmode    = Toggle fancy mode (colour matrixing things)<br>
***********************************************************"}
	icon_state = "buildmode_transmute"
	var/fancy = FALSE

	click_mode_right(var/ctrl, var/alt, var/shift)
		src.fancy = !src.fancy
		boutput(usr, "Toggled fancy conversion [src.fancy ? "on" : "off"]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		flock_convert_turf(get_turf(object), force = TRUE, fancy = src.fancy)
