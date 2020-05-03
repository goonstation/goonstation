/datum/buildmode/poddoors
	name = "Pod Doors"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Next ID<br>
Left Mouse Button                      = Place door with current ID<br>
Right Mouse Button                     = Place door control with current ID<br>
Ctrl + RMB                             = Remove pod door or door control<br>
***********************************************************"}
	icon_state = "buildmode8"
	var/counter = 0
	var/id

	New()
		..()
		id = "[holder.owner.ckey]0"

	click_mode_right(var/ctrl, var/alt, var/shift)
		counter++
		id = "[usr.client.ckey][counter]"
		boutput(usr, "<span class='notice'>ID now: [id]</span>")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/obj/machinery/door/poddoor/newdoor = new/obj/machinery/door/poddoor(get_turf(object))
		newdoor.id = id
		blink(get_turf(object))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (ctrl)
			if (istype(object, /obj/machinery/door/poddoor) || istype(object, /obj/machinery/door_control))
				blink(get_turf(object))
				qdel(object)
		else
			var/obj/machinery/door_control/newcontrol = new/obj/machinery/door_control(get_turf(object))
			newcontrol.id = id
			blink(get_turf(object))
