/datum/buildmode/meteor
	name = "Meteor"
	desc = {"***********************************************************<br>
Left Mouse Button                 = Lob a meteor<br>
Right Mouse Button on buildmode button = Select meteor type
Ctrl-RMB on buildmode button = select material
***********************************************************"}
	icon_state = "buildmode4"
	var/meteor_type = /obj/newmeteor
	var/transmute_material = null

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/target = get_turf(object)
		var/obj/newmeteor/M = new src.meteor_type(usr.loc,target)
		if(src.transmute_material)
			M.set_transmute(getMaterial(transmute_material))
			M.meteorhit_chance = 20
		M.pix_speed = 10

	click_mode_right(ctrl, alt, shift)
		if (ctrl)
			src.transmute_material = tgui_input_list(usr, "Pick material", "Meteor material", material_cache)
		else
			src.meteor_type = tgui_input_list(usr, "Pick meteor type", "Meteor type", concrete_typesof(/obj/newmeteor)) || src.meteor_type
