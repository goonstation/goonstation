
//Save tetris highscores to the hub
/proc/save_tetris_highscores()
	if (!config)
		return null
	else if (!config.medal_hub || !config.medal_password)
		return null
	for(var/datum/game/tetris/T in by_type[/datum/game/tetris]) // JFC this a world loop before this. aaaAAAAAAA
		if (T.highscore && T.highscorekey)
			SPAWN(0)
				var/list/response = world.GetScores(T.highscorekey, "Tetris", config.medal_hub, config.medal_password)
				var/currScore = -1
				if(response)
					var/list/rList = params2list(response)
					if(rList["Tetris"])
						currScore = text2num_safe(rList["Tetris"])
				if(T.highscore > currScore)
					DEBUG_MESSAGE("Setting Tetris scores: Key: [T.highscorekey] Score: [T.highscore]")
					var/returnval = world.SetScores(T.highscorekey, "Tetris=[T.highscore]", config.medal_hub, config.medal_password)
					DEBUG_MESSAGE("Return Value for [T.highscorekey]: [returnval]")

/*
	var/list/response = world.GetScores(key, field_name, config.medal_hub, config.medal_password)
	if(isnull(response)) return null
	if(response)
		var/list/rList = params2list(response)
		if(rList[field_name])
			result = text2num_safe(rList[field_name])
	return result
*/

TYPEINFO(/obj/machinery/computer/tetris)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/machinery/computer/tetris
	name = "Robustris Pro cabinet"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tetris"
	desc = "Instructions:<ul style='margin: 0;'><li>Left/Right Arrows: Move</li><li>Up Arrow/Space: Hard Drop</li><li>Down Arrow/S: Soft Drop</li><li>W/E/R: Rotate CW</li><li>Q/Z: Rotate CCW</li></ul>"
	machine_registry_idx = MACHINES_MISC
	circuit_type = /obj/item/circuitboard/tetris
	speech_verb_say = "beeps"
	var/datum/game/tetris/tetris

/obj/machinery/computer/tetris/New()
	..()
	src.tetris = new /datum/game/tetris(src)

/obj/machinery/computer/tetris/attack_hand(mob/user)
	if(..())
		return
	src.add_dialog(user)
	src.tetris.new_game(user)
	return

/obj/machinery/computer/tetris/power_change()
	if(status & BROKEN)
		icon_state = "tetrisb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				src.icon_state = "tetris0"
				status |= NOPOWER

/obj/machinery/computer/tetris/get_desc()
	if (src.tetris && src.tetris.highscore)
		return "<b>High Score: [src.tetris.highscore] by [src.tetris.highscoreholder]</b>"


ABSTRACT_TYPE(/datum/game)
/datum/game

	proc/new_game(mob/user as mob)

	proc/end_game()

/datum/game/tetris
	var/obj/owner
	var/code
	var/highscore = 0
	var/highscoreholder
	var/highscorekey

	New(var/owner)
		..()
		START_TRACKING
		src.owner = owner
		src.code = grabResource("html/tetris.html")

	disposing()
		..()
		STOP_TRACKING

	Topic(href, href_list)
		if (owner.Topic(href, href_list))
			return
		if (href_list["highscore"])
			var/score = text2num_safe(href_list["highscore"])
			if (score)
				var/msg
				if (score >= 30000)
					msg = "Game over. [usr] scored [score] points!"
					usr.unlock_medal("Block Stacker", 1)

				else if (score > 500)
					// arbitrary threshold of effort
					// (slightly more than "mash hard drop for 11 pieces")
					msg = "Game over. [usr] scored [score] points."

				if (score > highscore)
					msg = "New high score by [usr] -- [score] points!!"
					highscore = score
					highscorekey = usr.key
					highscoreholder = html_encode(input("Congratulations! You have achieved the highscore! Enter a name:", "Highscore!", usr.name) as text)
					src.end_game()


				if (src.owner && msg)
					src.owner.say(msg)
					if (score >= highscore || score >= 30000)
						// >= here becuase it was updated earlier
						particleMaster.SpawnSystem(new /datum/particleSystem/confetti(src.owner.loc))
						SPAWN(1 SECOND)
							playsound(src.owner, 'sound/voice/yayyy.ogg', 50, 1)
		return

	new_game(mob/user as mob)
		var/dat = replacetext(code, "{{HIGHSCORE}}", num2text(highscore))
		dat = replacetext(dat, "{{TOPICURL}}", "'byond://?src=\ref[src];highscore='+this.ScoreCur;")

		user.Browse(dat, "window=tetris;size=375x546")
		onclose(user, "tetris")
		return
