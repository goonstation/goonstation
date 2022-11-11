//Add this screen object to a hud or screen with a supplied owner and target and set up some loop to call proc/process()
//Example for if you were adding this from inside an abilityHolder
//compass = new/atom/movable/screen/compass_display(src,owner=owner,target=get_turf(owner))
//hud.add_object(compass)
//Then call compass.process() from datum/abilityHolder/proc/onLife

atom/movable/screen/compass_display
	name = "compass"
	icon = 'icons/mob/mob.dmi'
	icon_state = "compass_border"
	screen_loc = "NORTH-2,EAST"
	var/obj/needle = null
	var/atom/owner
	var/atom/target
	var/degree = 0


	New(turf/loc, var/owner, var/target)
		..()
		src.owner = owner
		src.target = target
		needle = new (src)
		needle.icon = 'icons/mob/mob.dmi'
		needle.icon_state = "compass_needle_dot"
		needle.layer = src.layer + 1
		needle.vis_flags = VIS_INHERIT_PLANE
		src.vis_contents += needle

	proc/process()
		if (!owner || !target) return

		degree = get_angle(owner,target)
		if (degree == 0 && get_turf(owner) == get_turf(target))
			needle.icon_state = "compass_needle_dot"
		else
			needle.icon_state = "compass_needle"
		var/matrix/M = matrix()
		M = M.Turn(degree)

		animate(needle, transform = M, time = 10, loop = 0)

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")

			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = "HuD Compass",
				"content" = "It points towards [target].",
				"theme" = null
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

// /mob
// 	verb/test_compass()
// 		var/atom/movable/screen/compass/P = new/atom/movable/screen/compass(src,owner=src,target=new/obj/warp_portal(src.loc))
// 		src.client.screen += P
