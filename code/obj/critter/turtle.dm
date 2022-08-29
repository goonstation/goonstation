/obj/critter/turtle
	name = "turtle"
	desc = "A turtle. They are noble creatures of the land and sea."
	icon_state = "turtle"
	var/base_icon_state = "turtle"		//I added this in a poor attempt to add costumes for sylvester and decided not to go with it, but it could be useful for handling other turtle types later on so I'll leave it.
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
	var/wandering_count = 0		//Make them move less frequently when wandering... They're slow.
	var/rigged = FALSE
	var/rigger = null
	var/exploding = FALSE
	var/costume_name = null
	var/image/costume_alive = null
	var/image/costume_shell = null
	var/image/costume_dead = null

	New(loc)
		. = ..()
		START_TRACKING
		if (costume_name)
			costume_alive = image(src.icon, "[costume_name]")
			costume_shell = image(src.icon, "[costume_name]-shell")
			costume_dead = image(src.icon, "[costume_name]-dead")

	disposing()
		. = ..()
		STOP_TRACKING

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
		var/S = pick('sound/impact_sounds/Generic_Hit_2.ogg', 'sound/impact_sounds/Wood_Hit_Small_1.ogg')
		playsound(src.loc, S, 30, 1, -1)

	ChaseAttack(mob/M)
		..()
		playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 20, 1, -1)
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

	attackby(obj/item/I, mob/living/user)
		if(istype(I, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/S = I

			boutput(user, "You inject the solution into [src].")

			if(!rigged && S.reagents.has_reagent("plasma", 1))
				for (var/mob/living/M in mobs)
					if (M.mind && M.mind.assigned_role == "Head of Security")
						boutput(M, "<span class='alert'>You feel a foreboding feeling about the imminent fate of a certain turtle in [get_area(src)], better act quick.</span>")

				message_admins("[key_name(user)] rigged [src] to explode in [user.loc.loc], [log_loc(user)].")
				logTheThing(LOG_COMBAT, user, "rigged [src] to explode in [user.loc.loc] ([log_loc(user)])")
				rigged = TRUE
				rigger = user

				S.reagents.clear_reagents()

				var/area/A = get_area(src)
				if(A?.lightswitch && A?.power_light)
					src.explode()
		else
			. = ..()

	// explode the turtle

	proc/explode()
		SPAWN(0)
			src.rigged = FALSE
			src.rigger = null
			enter_shell()	//enter shell first to give a warning
			src.exploding = TRUE
			sleep(0.2 SECONDS)
			explosion(src, get_turf(src), 0, 1, 2, 2)
			sleep(4 SECONDS)
			src.exploding = FALSE
			var/message = "Check please!"
			var/chat_text = make_chat_maptext(src, message)
			for (var/mob/O in all_hearers(7, get_turf(src)))
				O.show_message("<span class='game say bold'><span class='name'>[src]</span></span> says, <span class='message'>\"[message]\"</span>", 2, assoc_maptext = chat_text)
			playsound(src.loc, 'sound/misc/rimshot.ogg', 50, 1)

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

		icon_state = "[base_icon_state]-shell"
		if (costume_name)
			src.UpdateOverlays(costume_shell, "costume")

		density = 0

		src.visible_message("<span class='alert'><b>[src]</b> retreats into [his_or_her()] shell!")
		return 1

	//sets shellcount to 0 and changes task to "thinking". changes icon state and protections.
	proc/exit_shell()

		shell_count = 0
		task = "thinking"

		brutevuln = 0.7
		firevuln = 1
		icon_state = base_icon_state
		if (costume_name)
			src.UpdateOverlays(costume_alive, "costume")

		density = 1

		src.visible_message("<span class='notice'><b>[src]</b> comes out of [his_or_her()] shell!")
		return 1

	//Just completely override this to change values of severity. Kinda ugly, but it's what I want!
	ex_act(severity)
		if(src.exploding)
			return
		if (src.shell_count)
			shell_count = 0
			on_wake()

		on_damaged()
		//high chance to suvive explosions
		if (prob(50))
			enter_shell()

		switch(severity)
			if(1)
				src.health -= shell_count ? 75 : 200
			if(2)
				src.health -= shell_count ? 25 : 75
			else
				src.health -= shell_count ? 0 : 25

		if (src.health <= 0)
			src.CritterDeath()

//Yes, I stole this from mobprocs cause that one only works on mobs and I didn't think it worthwhile to change it to work on objects too.
/obj/critter/turtle/proc/his_or_her()
	switch (src.gender)
		if ("male")
			return "his"
		if ("female")
			return "her"
		else
			return "their"

//This is kinda messy from me moving it out from the secret repo and then shoehorning in the commander hat wearing.
//I'd like to let turtles wear any hat, like bees. But I'm gonna keep it this cheesey way for now cause I just wanna get this done
//Sylvester
//The HoS's pet turtle. He can wear the beret!
/obj/critter/turtle/sylvester
	name = "Sylvester"
	desc = "This turtle looks both cute and indimidating. It's a tough line to walk, but he does it effortlessly."
	icon_state = "turtle"		//I kinda wanna make sylvester stand out a bit amongs other turtles, even without the hat.
	health = 100
	generic = 0
	is_pet = 2
	gender = MALE
	var/obj/item/wearing_beret = 0	//Don't really need this var, but I like it better than checking contents every time we wanna see if he's got the beret
	var/search_frequency = 30	//number of cycles between searches
	var/preferred_hat = /obj/item/clothing/head/hos_hat 	//if this is not null then the only hat type he will wear is this path.
	#ifdef HALLOWEEN
	costume_name = "sylv_costume_1"
	#endif

	New()
		..()
		UpdateIcon()
	ai_think()
		..()
		//find clown
		if (search_frequency <= 0)
			if (task != "chasing" || task != "attacking" || task != "sleeping")
				for (var/mob/M in mobs)
					if (M.job == "Clown" && GET_DIST(src, M) < 7)
						target = M
						attack = 1
						task = "chasing"
						src.visible_message("<span class='alert'><b>[src]</b> notices a Clown and starts charging at [src.target]!</span>")

						// walk_to(src, target,1,4)
						search_frequency = 30
						seek_target()
						return
		search_frequency--

	get_desc()
		..()
		if (src.wearing_beret)
			. += "<br>[src] is wearing an adorable beret!."
		else
			. += "<br>[src] looks cold without some sort of hat on."

		if (src.costume_name)
			. += "And he's wearing an adorable costume! Wow!"

	attackby(obj/item/W, mob/user)
		if (istype(W, preferred_hat))
			give_beret(W, user)
		else
			..()

	attack_hand(mob/user)
		if (!src.alive)
			take_beret(user)
			return
		..()

	//Calls parent, if it returns 0, don't do the effects here and just returun 0
	enter_shell()
		if (!..()) return 0

		brutevuln = 0.2
		firevuln = 0.5

		return

	exit_shell()
		..()
		if (wearing_beret)
			brutevuln = 0.5
			firevuln = 0.8
		else
			brutevuln = 0.7
			firevuln = 1

		UpdateIcon()

		return 1

	CritterDeath()
		..()
		if (src.wearing_beret)
			src.icon_state = "[base_icon_state]-dead-beret"
		else
			src.icon_state = "[base_icon_state]-dead"

		UpdateIcon()

	on_revive()
		..()
		if (src.wearing_beret)
			src.icon_state = "[base_icon_state]-beret"
		else
			src.icon_state = base_icon_state

		UpdateIcon()

	proc/give_beret(var/obj/hat, var/mob/user)
		if (shell_count || wearing_beret) return 0

		var/obj/item/clothing/head/hos_hat/beret = hat
		if (istype(beret))
			if (beret.folds == 0)
				beret.folds = 1
				beret.name = "HoS Beret"
				beret.icon_state = "hosberet"
				beret.item_state = "hosberet"
				boutput(user, "<span class='notice'>[src] folds the hat into a beret before putting it on! </span>")
			//beret gives bonus protection
			brutevuln = 0.5
			firevuln = 0.8

		else if (istype(hat, /obj/item/clothing/head/NTberet/commander))
			// var/obj/item/clothing/head/NTberet/commander/com_beret = hat

			//beret gives bonus protection
			brutevuln = 0.5
			firevuln = 0.8

		user.drop_item()
		beret.set_loc(src)
		wearing_beret = hat


		UpdateIcon()
		// if (src.alive)
		// 	src.icon_state = "turtle-beret"
		// else
		// 	src.icon_state = "turtle-dead-beret"
		return 1

	//The HoS can take the beret whenever Sylvester is out of his shell. ~~And anyone can take it if he's dead.~~ not anymore
	//This has some extraneous logic in it for non HoS mobs trying to take the beret since the only place this is called
	//is in attack_hand if src is dead. But still, wanted to be comprehensive.
	proc/take_beret(var/mob/M)
		if (shell_count || !wearing_beret) return 0

		var/obj/item/clothing/head/beret = wearing_beret
		if (beret)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.job == "Head of Security" && istype(beret, /obj/item/clothing/head/hos_hat))
					H.put_in_hand_or_drop(beret)
				else if (H.job == "NanoTrasen Commander" && istype(beret, /obj/item/clothing/head/NTberet/commander))
					H.put_in_hand_or_drop(beret)
				else
					if (alive)
						boutput(M, "<span class='alert'>You try to grab the beret, but [src] pulls into his shell before you can!</span>")
						playsound(src.loc, "rustle", 10, 1)
						src.enter_shell()
					return 0

			//Commented out for now, only the HoS can remove the beret, even when dead. Might change later, idk.
			// else if (!src.alive && ismob(M))
			// 	//if this proc fails, don't update icon state
			// 	if (!M.put_in_hand(beret))
			// 		return 0

			//SUCCESS

			wearing_beret = null
			//Remove beret bonus protection
			brutevuln = initial(brutevuln)
			firevuln = initial(firevuln)

			UpdateIcon()

			return 1
		return 0

	mouse_drop(atom/over_object as mob|obj)
		if (over_object == usr && ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if (in_interact_range(src, H))
				if (take_beret(H))
					return
		..()

	//I'm sorry sylvester... I'll fix this later when I have time, I promise. - Kyle
	update_icon()
		if (src.alive)
			if (src.wearing_beret)
				if (istype(wearing_beret, /obj/item/clothing/head/hos_hat))
					src.icon_state = "[base_icon_state]-beret"
				else if (istype(wearing_beret, /obj/item/clothing/head/NTberet/commander))
					src.icon_state = "[base_icon_state]-beret-com"

			else
				src.icon_state = base_icon_state
			if (costume_name)
				src.UpdateOverlays(costume_alive, "costume")

		else
			if (src.wearing_beret)
				if (istype(wearing_beret, /obj/item/clothing/head/hos_hat))
					src.icon_state = "[base_icon_state]-dead-beret"
				else if (istype(wearing_beret, /obj/item/clothing/head/NTberet/commander))
					src.icon_state = "[base_icon_state]-dead-beret-com"

			else
				src.icon_state = "[base_icon_state]-dead"
			if (costume_name)
				src.UpdateOverlays(costume_dead, "costume")

//Starts with the beret on!
/obj/critter/turtle/sylvester/HoS
	wearing_beret = 1
	icon_state = "turtle-beret"

	New()
		..()
		//Make the beret
		var/obj/item/clothing/head/hos_hat/beret = new/obj/item/clothing/head/hos_hat(src)
		//fold it
		beret.folds = 1
		beret.name = "HoS Beret"
		beret.icon_state = "hosberet"
		beret.item_state = "hosberet"
		set_loc(beret)

		wearing_beret = beret

/obj/critter/turtle/sylvester/Commander
	icon_state = "turtle-beret-com"

	preferred_hat = /obj/item/clothing/head/NTberet/commander 	//if this is not null then the only hat type he will wear is this path.

	New()
		..()
		var/obj/item/clothing/head/NTberet/commander/beret = new/obj/item/clothing/head/NTberet/commander(src)
		//fold it
		beret.name = "Sylvester's Beret"
		set_loc(beret)
		wearing_beret = beret

		START_TRACKING_CAT(TR_CAT_PW_PETS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PW_PETS)
		..()

