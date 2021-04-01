/mob/living/silicon/robot/Life()

	if (src.stat)
		src.camera.status = 0.0
		if(src.stat == 2)
			return
	else

		src.updatehealth()

		if (src.health <= -100.0)
			death()
			return
		else if (src.health < 0)
			src.oxyloss++
	src.updateicon()

	//stage = 0
	if (src.client)

		var/blind = 0

		if (src.cell)

			if(src.cell.charge <= 0)
				blind = 1
				stat = 1
			else if (src.cell.charge <= 100)
				src.module_state_1 = null
				src.module_state_2 = null
				src.module_state_3 = null
				src.cell.use(1)
			else
				if(src.module_state_1)
					cell.use(5)
				if(src.module_state_2)
					cell.use(5)
				if(src.module_state_3)
					cell.use(5)
				cell.use(1)
				blind = 0
				stat = 0
		else
			blind = 1
			stat = 1

		if (!blind)

			if (src.blind.layer!=0)
				src.blind.layer = 0
			src.see_in_dark = 8
			src.see_invisible = 2

		else
			src.blind.screen_loc = "1,1 to 15,15"
			if (src.blind.layer!=18)
				src.blind.layer = 18
			src.see_in_dark = 0
			src.see_invisible = 0