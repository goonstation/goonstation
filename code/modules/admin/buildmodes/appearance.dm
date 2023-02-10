/datum/buildmode/appearance
	name = "Appearance"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Apply Appearance<br>
Ctrl + LMB mob/obj/turf            = *Attempts* to restore initial appearance (CANNOT USE ON HUMANS - MAY NOT RESTORE CORRECT ICON)<br>
Right Mouse Button on mob/obj/turf = Copy Appearance<br>
***********************************************************"}
	icon_state = "buildappearance"
	var/tmp/mutable_appearance/MA = null
	var/tmp/datum/appearanceHolder/AH = null


	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl)
			if (ishuman(object))
				boutput(usr, "You cannot use this feature on human mobs!")
				return
			object.appearance = initial(object.appearance)
			REMOVE_ATOM_PROPERTY(object, PROP_ATOM_NO_ICON_UPDATES, "buildmode")
		else if (AH && ishuman(object))
			var/mob/living/carbon/human/H = object
			if (!H.bioHolder) return
			H.real_name = MA.name
			H.name = MA.name
			if(AH.mutant_race)
				H.set_mutantrace(AH.mutant_race)
			else
				H.set_mutantrace(null)
			H.bioHolder.mobAppearance.CopyOther(AH)
			H.bioHolder.mobAppearance.UpdateMob()
			H.update_colorful_parts()
		else
			object.appearance = MA
			APPLY_ATOM_PROPERTY(object, PROP_ATOM_NO_ICON_UPDATES, "buildmode")
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (ishuman(object))
			var/mob/living/carbon/human/H = object
			AH = H.bioHolder?.mobAppearance
		else
			AH = null
		MA = object.appearance
		blink(get_turf(object))
		update_button_text(object.name)
