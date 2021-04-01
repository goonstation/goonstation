/mob/living/silicon/robot/Login()
	..()
	update_clothing()
//TO-DO add power bar
	for(var/S in src.client.screen)
		del(S)
	src.flash = new /obj/screen( null )
	src.flash.icon_state = "blank"
	src.flash.name = "flash"
	src.flash.screen_loc = "1,1 to 15,15"
	src.flash.layer = 17
	src.blind = new /obj/screen( null )
	src.blind.icon_state = "black"
	src.blind.name = " "
	src.blind.screen_loc = "1,1 to 15,15"
	src.blind.layer = 0
	src.client.screen += list( src.blind, src.flash )
	if(!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghostize
	if(src.real_name == "Cyborg")
		src.real_name += " [pick(rand(1, 999))]"
		src.name = src.real_name
	if(!src.connected_ai)
		for(var/mob/living/silicon/ai/A in world)
			src.connected_ai = A
			A.connected_robots += src
			break
	return