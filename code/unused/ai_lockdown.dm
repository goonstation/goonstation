/*

This shit isn't good for anything and lags like fuck. Commented it out for now.

/mob/living/silicon/ai/proc/lockdown()
	set category = "AI Commands"
	set name = "Lockdown"

	if(isdead(usr))
		boutput(usr, "You cannot initiate lockdown because you are dead!")
		return

	boutput(world, "<span class='alert'>Lockdown initiated by [usr.name]!</span>")

	for(var/obj/machinery/firealarm/FA as() in machine_registry[MACHINES_FIREALARMS]) //activate firealarms
		SPAWN_DBG( 0 )
			if(FA.lockdownbyai == 0)
				FA.lockdownbyai = 1
				FA.alarm()
	for(var/obj/machinery/door/airlock/AL) //close airlocks
		SPAWN_DBG( 0 )
			if(AL.canAIControl() && AL.icon_state == "door0" && AL.lockdownbyai == 0)
				AL.close()
				AL.lockdownbyai = 1

	var/obj/machinery/computer/communications/C = locate() in world
	if(C)
		C.post_status("alert", "lockdown")

/*	src.verbs -= /mob/living/silicon/ai/proc/lockdown
	src.verbs += /mob/living/silicon/ai/proc/disablelockdown
	boutput(usr, "<span class='alert'>Disable lockdown command enabled!</span>")
	winshow(usr,"rpane",1)
*/

/mob/living/silicon/ai/proc/disablelockdown()
	set category = "AI Commands"
	set name = "Disable Lockdown"

	if(isdead(usr))
		boutput(usr, "You cannot disable lockdown because you are dead!")
		return

	boutput(world, "<span class='alert'>Lockdown cancelled by [usr.name]!</span>")

	for(var/obj/machinery/firealarm/FA s anything in machine_registry[MACHINES_FIREALARMS]) //deactivate firealarms
		SPAWN_DBG( 0 )
			if(FA.lockdownbyai == 1)
				FA.lockdownbyai = 0
				FA.reset()
	for(var/obj/machinery/door/airlock/AL) //open airlocks
		SPAWN_DBG ( 0 )
			if(AL.canAIControl() && AL.lockdownbyai == 1)
				AL.open()
				AL.lockdownbyai = 0

	src.verbs -= /mob/living/silicon/ai/proc/disablelockdown
	src.verbs += /mob/living/silicon/ai/proc/lockdown
	boutput(usr, "<span class='alert'>Disable lockdown command removed until lockdown initiated again!</span>")
	winshow(usr,"rpane",1)
*/
