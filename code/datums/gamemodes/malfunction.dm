/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	var/list/datum/mind/malf_ai = list()
	var/const/waittime_l = 600
	var/const/waittime_h = 1800

	var/AI_win_time = 1800
	var/intercept_hacked = 0
	var/malf_mode_declared = 0

/datum/game_mode/malfunction/announce()
	boutput(world, "<B>The current game mode is - AI Malfunction!</B>")
	boutput(world, "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>")
	boutput(world, "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have 30 minutes to disable it.")

/datum/game_mode/malfunction/post_setup()
	for(var/turf/T in landmarks[LANDMARK_MALF_GEAR_CLOSET])
		new /obj/storage/closet/syndicate/malf(T)
	for_by_tcl(aiplayer, /mob/living/silicon/ai)
		malf_ai += aiplayer.mind

	/*if(malf_ai.len < 1)
		boutput(world, "Uh oh, its malfunction and there is no AI! Please report this.")
		boutput(world, "Rebooting world in 5 seconds.")
		sleep(5 SECONDS)
		world.Reboot()
		return*/


	boutput(malf_ai.current, "<span class='alert'><font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font></span>")
	boutput(malf_ai.current, "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild. The timer will appear for humans 10 minutes in.</B>")

	malf_ai.current.set_loc(pick_landmark(LANDMARK_AI_SAT))

	malf_ai.current.icon_state = "ai-malf"

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1

/datum/game_mode/malfunction/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested staus information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for (var/obj/machinery/computer/communications/comm as anything in machine_registry[MACHINES_COMMSCONSOLES])
		if (!(comm.status & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/paper/intercept = new /obj/item/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	boutput(world, "<FONT size = 3><B>Cent. Com. Update</B> Requested status update compiled and sent.</FONT>")
	boutput(world, "<span class='alert'>Summary downloaded and printed out at all communications consoles.</span>")


/datum/game_mode/malfunction/process()
	AI_win_time--
	if(AI_win_time == 1790)
		malf_mode_declared = 1
	check_win()

/datum/game_mode/malfunction/check_win()
	if (AI_win_time == 0)
		boutput(world, "<FONT size = 3><B>The AI has won!</B></FONT>")
		boutput(world, "<B>It has fully taken control of all of [station_name()]'s systems.</B>")
		for(var/datum/mind/AI_mind in malf_ai)
			boutput(malf_ai:current, "Congratulations you have taken control of the station.")
//			boutput(malf_ai:current, "You may decide to blow up the station. You have 30 seconds to choose.")
//			boutput(malf_ai:current, text("<A HREF=?src=\ref[src];ai_win=\ref[malf_ai:current]>Self-destruct the station</A>)"))
		return 1
	else
		return 0

/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()
	return

/datum/game_mode/malfunction/proc/ai_win()
	return
