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
			boutput(usr, SPAN_ALERT("No object path!"))
			return
		var/atom/movable/M = object
		if(istype(M) && objpath)
			if (M.storage)
				if (!M.storage.is_full())
					M.storage.add_contents(new objpath(M))
				else
					new objpath(get_turf(M))
			else
				new objpath(M)
			//I'm turning this off on the basis that you almost never want people to know you've done something with this mode
			// blink(get_turf(object))

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
