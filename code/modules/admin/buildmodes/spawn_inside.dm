/datum/buildmode/spawn_inside
	name = "Object Spawn (place inside)"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set object type<br>
Left Mouse Button on mob/obj           = Place object inside object or turf<br>
Right Mouse Button                     = Delete an object from contents<br>
Right Mouse Button + Shift             = Set object type to selected mob/obj type<br>
***********************************************************"}
	icon_state = "buildmode_putin"
	var/objpath = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!objpath)
			objpath = /obj/critter/domestic_bee/heisenbee
		objpath = get_one_match(input("Type path", "Type path", "[objpath]"), /atom/movable)
		update_button_text(objpath)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!objpath)
			boutput(usr, "<span class='alert'>No object path!</span>")
			return
		var/atom/movable/M = object
		if(istype(M) && objpath)
			new objpath(object)
			blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			if (ismob(object) || isobj(object))
				objpath = object.type
				update_button_text(objpath)
		else
			var/atom/movable/M = object
			if (istype(M))
				if (!M.contents.len)
					return
				var/which = input("Delete what from [M]'s contents?", "Deleting contents", null) as null|anything in M.contents
				if (which)
					qdel(which)
