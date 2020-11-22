/obj/critter/turtle
	name = "turtle"
	desc = "A turtle. They are noble creatures of the land and sea."
	icon_state = "turtle"
	density = 1
	health = 100
	aggressive = 0
	defensive = 1
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	brutevuln = 0.7
	firevuln = 1
	atk_delay = 5 SECONDS
	atk_brute_amt = 3
	crit_brute_amt = 6
	atk_text = "headbutts"
	chase_text = "charges into"
	crit_text = "rams really hard into"
	var/shell_count = 0		//Count down to 0. Measured in process cycles. If they are in their shell when this is 0, exit.

	ai_think()
		if (shell_count > 0)
			shell_count--
			return 0
		else if (task == "in_shell")
			src.attack = 0
			src.target = null
			exit_shell()


		..()

	//Might want this, idk. or should just get a sleeping state for him
	on_sleep()
		..()
		// enter_shell()

	on_wake()
		..()
		//only call if they're in the shell.
		if (shell_count)
			exit_shell()

	CritterAttack(mob/M)
		..()
		var/S = pick("sound/impact_sounds/Generic_Hit_2.ogg", "sound/impact_sounds/Wood_Hit_Small_1.ogg")
		playsound(src.loc, S, 30, 1, -1)

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, "sound/impact_sounds/Wood_Hit_1.ogg", 20, 1, -1)
		M.changeStatus("stunned", 3 SECONDS)

	on_grump()
		..()
		if (shell_count)
			//Won't always come out when attacked
			if (prob(30))
				exit_shell()
				src.task = "chasing"
			else
				src.task = "in_shell"
		else
			if (prob(20))
				enter_shell()

	bullet_act(var/obj/projectile/P)
		switch(P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				if (prob(70))
					enter_shell()
		..()

	blob_act(var/power)
		src.health -= power*brutevuln
		on_damaged()
		if (src.health <= 0)
			src.CritterDeath()
		return

	on_damaged(mob/user)
		if (prob(20))
			enter_shell()
		..()
	CritterDeath()
		..()
		shell_count = 0

	//sets the turtle to sleep inside their shell. Will exit their shell if hit again
	proc/enter_shell()
		if (shell_count) return 0
		shell_count = 10
		task = "in_shell"
		attack = 0
		target = null
		walk_to(src,0)

		brutevuln = 0.2
		firevuln = 0.5
		icon_state = "turtle-shell"
		density = 0

		src.visible_message("<span class='alert'><b>[src]</b> retreats into their shell!")
		return 1

	//sets shellcount to 0 and changes task to "thinking". changes icon state and protections.
	proc/exit_shell()

		shell_count = 0
		task = "thinking"

		brutevuln = 0.7
		firevuln = 1
		icon_state = "turtle"
		density = 1

		src.visible_message("<span class='notice'><b>[src]</b> comes out of their shell!")
		return 1

	//Just completely override this to change values of severity. Kinda ugly, but it's what I want!
	ex_act(severity)

		if (src.shell_count)
			shell_count = 0
			on_wake()

		on_damaged()
		//high chance to suvive explosions
		if (prob(50))
			enter_shell()

		switch(severity)
			if(1.0)
				src.health -= shell_count ? 75 : 200
			if(2.0)
				src.health -= shell_count ? 25 : 75
			else
				src.health -= shell_count ? 0 : 25

		if (src.health <= 0)
			src.CritterDeath()


//The HoS's pet turtle. He can wear the beret!
/obj/critter/turtle/sylvester
	name = "Sylvester"
	desc = "This turtle looks both cute and indimidating. It's a tough line to walk, but he does it effortlessly."
	icon_state = "turtle"		//I kinda wanna make sylvester stand out a bit amongs other turtles, even without the hat.
	health = 100
	generic = 0
	is_pet = 2
//Starts with the beret on!
/obj/critter/turtle/sylvester/HoS

