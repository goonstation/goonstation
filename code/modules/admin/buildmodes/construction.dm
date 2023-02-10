/datum/buildmode/construction
	name = "Construction"
	desc = {"***********************************************************<br>
Left Mouse Button         = Construct / Upgrade<br>
Right Mouse Button        = Deconstruct / Delete / Downgrade<br>
Left Mouse Button + ctrl  = R-Window<br>
Left Mouse Button + alt   = Airlock<br>
Left Mouse Button + shift = Grille<br>
<br>
Use the button in the upper left corner to<br>
change the direction of created objects.<br>
***********************************************************"}
	icon_state = "buildmode1"

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!isturf(object))
			return
		if (!ctrl && !alt && !shift)
			if(istype(object,/turf/space))
				var/turf/T = object
				T.ReplaceWithFloor()
				return
			else if(istype(object,/turf/simulated/floor))
				var/turf/T = object
				T.ReplaceWithWall()
				return
			else if(istype(object,/turf/simulated/wall))
				var/turf/T = object
				T.ReplaceWithRWall()
				return
		else if (alt)
			new /obj/machinery/door/airlock(get_turf(object))
		else if (ctrl)
			var/obj/window/reinforced/R = new /obj/window/reinforced(get_turf(object))
			R.set_dir(holder.dir)
		else if (shift)
			new /obj/grille/steel(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if(istype(object,/turf/simulated/wall))
			var/turf/T = object
			T.ReplaceWithFloor()
			return
		else if(istype(object,/turf/simulated/floor))
			var/turf/T = object
			T.ReplaceWithSpaceForce()
			return
		else if(istype(object,/turf/simulated/wall/r_wall) || istype(object, /turf/simulated/wall/auto/reinforced))
			var/turf/T = object
			T.ReplaceWithWall()
			return
		else if(istype(object,/obj))
			qdel(object)
			return
