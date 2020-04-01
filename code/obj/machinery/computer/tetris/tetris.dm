
//Save tetris highscores to the hub
/proc/save_tetris_highscores()
	if (!config)
		return null
	else if (!config.medal_hub || !config.medal_password)
		return null
	for(var/obj/machinery/computer/tetris/T in machine_registry[MACHINES_MISC]) // JFC this a world loop before this. aaaAAAAAAA
		if (T.highscore && T.highscorekey)
			SPAWN_DBG(0)
				var/list/response = world.GetScores(T.highscorekey, "Tetris", config.medal_hub, config.medal_password)
				var/currScore = -1
				if(response)
					var/list/rList = params2list(response)
					if(rList["Tetris"])
						currScore = text2num(rList["Tetris"])
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
			result = text2num(rList[field_name])
	return result
*/



/obj/machinery/computer/tetris
	name = "Robustris Pro Cabinet"
	icon = 'icons/obj/computer.dmi'
	icon_state = "tetris"

	desc = "Instructions: Left/Right Arrows: move, Up Arrow: turn, Down Arrow: faster, Space: auto place | HIGHSCORE: 0"
	machine_registry_idx = MACHINES_MISC
	var/highscore = 0
	var/highscoreholder
	var/highscorekey
	var/tetriscode

/obj/machinery/computer/tetris/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/screwdriver))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			if (src.status & BROKEN)
				boutput(user, "<span style=\"color:blue\">The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/tetris/M = new /obj/item/circuitboard/tetris( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span style=\"color:blue\">You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/tetris/M = new /obj/item/circuitboard/tetris( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
		src.add_fingerprint(user)
	return

/obj/machinery/computer/tetris/New()
	..()
	tetriscode = grabResource("html/tetris.html")


/obj/machinery/computer/tetris/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/tetris/attack_hand(mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat = replacetext(tetriscode, "{{HIGHSCORE}}", num2text(highscore))
	dat = replacetext(dat, "{{TOPICURL}}", "'?src=\ref[src];highscore='+this.ScoreCur;")

	user.Browse(dat, "window=tetris;size=375x500")
	onclose(user, "tetris")
	return

/obj/machinery/computer/tetris/Topic(href, href_list)
	if(..())
		return

	if (href_list["highscore"])
		if (text2num(href_list["highscore"]))
			if (text2num(href_list["highscore"]) > highscore)
				highscore = text2num(href_list["highscore"])
				highscorekey = usr.key
				highscoreholder = html_encode(input("Congratulations! You have achieved the highscore! Enter a name:", "Highscore!", usr.name) as text)

				desc = "Instructions: Left/Right Arrows: move, Up Arrow: turn, Down Arrow: faster, Space: auto place<br><br><b>Highscore: [highscore] by [highscoreholder]</b>"

	return

/obj/machinery/computer/tetris/power_change()

	if(status & BROKEN)
		icon_state = "tetrisb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = "tetris0"
				status |= NOPOWER
