/datum/buildmode/transmute
	name = "Transmute"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Set material<br>
Right Mouse Button on mob/obj/turf = Remove material<br>
Right Mouse Button on buildmode    = Set material ID<br>
***********************************************************"}
	icon_state = "buildmode_transmute"
	var/mat_id = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!material_cache.len)
			boutput(usr, "<span class='alert'>Error detected in material cache, attempting rebuild. Please try again.</span>")
			buildMaterialCache()
			return
		var/mat = input(usr,"Select Material:","Material",null) in material_cache
		if(!mat)
			return
		mat_id = mat
		update_button_text(mat_id)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!mat_id)
			return
		object.setMaterial(getMaterial(mat_id))
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		object.removeMaterial()
		blink(get_turf(object))
