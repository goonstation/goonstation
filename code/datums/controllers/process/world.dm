// handles various global init and the position of the sun.
datum/controller/process/world
	var/shuttle

	setup()
		name = "World"
		schedule_interval = 23

		if(genResearch) genResearch.setup()

		setup_radiocodes()

		emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()
		src.shuttle = emergency_shuttle

		generate_access_name_lookup()

	doWork()
		sun.calc_position()

		if(genResearch) genResearch.progress()

		for (var/byondkey in muted_keys)
			var/value = muted_keys[byondkey]
			if (value > 1)
				muted_keys[byondkey] = value - 1
			else if (value == 1 || value == 0)
				muted_keys -= byondkey

/proc/setup_radiocodes()
	var/list/codewords = list("Alpha","Beta","Gamma","Zeta","Omega", "Bravo", "Epsilon", "Jeff", "Delta")
	var/tempword = null

	tempword = pick(codewords)
	netpass_heads = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_security = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_medical = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_banking = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_cargo = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_syndicate = "[rand(111,999)]DET[tempword]=[rand(1111,9999)]"
	codewords -= tempword

	//boutput(world, "debug:<br>head: [netpass_heads] <br> med: [netpass_medical] <br> sec: [netpass_security]<br> atm: [netpass_banking]<br> cargo: [netpass_cargo]")
