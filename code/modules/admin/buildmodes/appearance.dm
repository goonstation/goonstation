/datum/buildmode/appearance
	name = "Appearance"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Apply Appearance<br>
Ctrl + LMB mob/obj/turf            = *Attempts* to restore initial appearance (CANNOT USE ON HUMANS - MAY NOT RESTORE CORRECT ICON)<br>
Right Mouse Button on mob/obj/turf = Copy Appearance<br>
***********************************************************"}
	icon_state = "buildappearance"
	var/mutable_appearance/MA = null


	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl)
			if (ishuman(object))
				boutput(usr, "You cannot use this feature on human mobs!")
				return
			object.appearance = initial(object.appearance)
		else
			object.appearance = MA
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		MA = object.appearance
		blink(get_turf(object))
		update_button_text(object.name)
