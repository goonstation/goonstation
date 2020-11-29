//Add this screen object to a hud or screen with a supplied owner and target and set up some loop to call proc/process()
obj/screen/compass_display
	name = "compass"
	icon = 'icons/mob/mob.dmi'
	icon_state = "compass_border"
	screen_loc = "NORTH-2,EAST"
	var/obj/needle = null
	var/atom/target
	var/atom/owner
	var/degree = 0
	
	New(var/owner, var/target)
		..()
		needle = new (src)
		needle.icon = 'icons/mob/mob.dmi'
		needle.icon_state = "compass_needle"
		
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


// /mob
// 	verb/test_compass()
// 		var/obj/screen/compass/P = new/obj/screen/compass(src,owner=src,target=new/obj/warp_portal(src.loc))
// 		src.client.screen += P
