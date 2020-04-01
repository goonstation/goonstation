/obj/machinery/bot/chefbot
	name = "Dramatic Chef"
	desc = "(icon, name, concept, and any kind of consistency or sense is currently pending)"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "chefbot-idle"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	on = 1 // ACTION
	health = 5
	var/raging = 0
	var/list/calledout = list()
	no_camera = 1

/obj/machinery/bot/chefbot/proc/do_step()
	var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
	if(isturf(moveto) && !moveto.density) step_towards(src, moveto)

/obj/machinery/bot/chefbot/process()
	if (raging)
		return
	if(prob(60) && src.on == 1)
		SPAWN_DBG(0)
			do_step()
			if(prob(src.emagged * 20))
				drama()
			if(prob(30 + src.emagged * 30))
				yell()

/obj/machinery/bot/chefbot/proc/point(var/target)
	visible_message("<b>[src]</b> points at [target].")
	if (istype(target, /atom))
		var/D = new /obj/decal/point(get_turf(target))
		SPAWN_DBG(2.5 SECONDS)
			qdel(D)

/obj/machinery/bot/chefbot/proc/drama()
	for (var/mob/M in hearers(7, src))
		M << sound('sound/effects/dramatic.ogg', volume = 100) // F U C K temporary measure

/obj/machinery/bot/chefbot/speak(var/message)
	if (message)
		message = uppertext(message)
		..(message)

/obj/machinery/bot/chefbot/proc/why_is_it_bad()
	return pick("IS FUCKING [pick("RAW", "BLAND", "UNDERCOOKED", "OVERCOOKED", "INEDIBLE", "RANCID", "DISGUSTING")]", "LOOKS LIKE [pick("BABY VOMIT", "A MUSHY PIG'S ASS", "REGURGITATED DONKEY SHIT", "A PILE OF ROTTING FLIES", "REFINED CAT PISS")]")

/obj/machinery/bot/chefbot/proc/yell()
	if (!src.emagged || prob(50))
		var/obj/item/reagent_containers/food/snacks/shitfood
		var/mob/living/carbon/human/thechef
		var/mob/dork
		var/is_thechef_the_chef = 0
		for (var/obj/item/reagent_containers/food/snacks/probablyshitfood in view(7, src))
			if (probablyshitfood in calledout)
				continue
			if (probablyshitfood.quality < 2)
				shitfood = probablyshitfood
				break
		if (shitfood)
			raging = 1
			icon_state = "chefbot-mad"
			for (var/mob/living/carbon/human/M in view(7, src))
				if (M.mind)
					if (M.mind.assigned_role == "Chef")
						thechef = M
						is_thechef_the_chef = 1
						break
				if (M.wear_id)
					if (findtext(M.wear_id:assignment, "chef") || findtext(M.wear_id:assignment, "cook"))
						thechef = M
						is_thechef_the_chef = 1
						break
				if (!thechef)
					thechef = M
				if (!dork)
					if (M.client)
						if (M.client.IsByondMember())
							dork = M
			if (thechef)
				point(shitfood)
				walk_to(src, shitfood, 1, 5)
				if (prob(50))
					speak(pick("ALRIGHT, EVERYBODY STOP!" , "THAT'S ENOUGH!"))
				sleep(10)
				drama()
				sleep(20)
				if (is_thechef_the_chef && prob(50) && thechef)
					point(thechef)
					speak(pick("COME HERE YOU!", "COME HERE, LET ME TELL YOU SOMETHING!", "STOP WHAT YOU'RE DOING AND COME HERE RIGHT NOW!"))
				else
					speak("WHO COOKED THIS SHIT?")
				sleep(20)
				if (shitfood) // fix for cannot read null.name (the food sometimes no longer exists after a sleep (because people eat it I assume)) - haine
					if (dork && prob(10))
						speak("THIS [shitfood.name] LOOKS LIKE [dork]!")
					speak("THIS [shitfood.name] [why_is_it_bad()]!")
				var/is_in_kitchen = 0
				if (thechef && is_thechef_the_chef)
					var/area/area = get_area(thechef)
					if (findtext(area.name, "Kitchen"))
						is_in_kitchen = 1
				sleep(20)
				if (is_in_kitchen && prob(40))
					speak(pick("SWITCH IT OFF!", "SHUT IT DOWN!", "FUCK OFF OUT OF HERE!", "OUT. GET OUT! GET OUT OF THIS KITCHEN! GET OUT!"))
				else
					speak(pick("THAT WAS PATHETIC. THAT WAS ABSOLUTELY PATHETIC!", "COME ON!", "YOU CALL YOURSELF CHEFS?", "YOU'RE AS MUCH OF A CHEF AS I AM A NICE PERSON."))
				icon_state = "chefbot-idle"
				raging = 0
				calledout += shitfood
				if (shitfood in range(1, src))
					visible_message("<b>[src]</b> stomps [shitfood], instantly destroying it.")
					qdel(shitfood)
			else
				// Nobody is in range anyway
				icon_state = "chefbot-idle"
				raging = 0
				return
	else if (src.emagged && prob(70))
		raging = 1
		icon_state = "chefbot-mad"
		switch (rand(1,4))
			if (1)
				var/mob/living/carbon/human/somefucker = locate() in view(7, src)
				if (somefucker)
					speak(pick("WHAT IS THIS?", "OH MY GOD."))
					drama()
					sleep(20)
					point(somefucker)
					speak("WHO COOKED THIS?")
					sleep(20)
					if (somefucker)
						if (somefucker.getStatusDuration("burning") > 0)
							speak("YOU DON'T LEAVE YOUR FUCKING FOOD UNATTENDED ON THE FUCKING STOVE. LOOK AT THIS. IT'S ON FIRE! IT'S GOING TO BE FUCKING BURNT!")
						else if (somefucker.get_burn_damage() < 50)
							speak("THIS [pick("HUMAN", "BURGER", "STEAK", "PORK")] IS SO FUCKING RAW IT'S STILL [pick("BEATING ASSISTANTS TO DEATH", "FARTING ON DEAD BODIES", "TRYING TO FEED ME FLOOR PILLS")]!")
						else
							speak("THIS [pick("HUMAN", "PRIMATE", "STEAK", "BURGER")] IS FUCKING [pick("OVERCOOKED", "BURNT")]!")
			if (2 to 3)
				drama()
				sleep(20)
				var/msg = pick("WHY DID THE CHICKEN CROSS THE ROAD? BECAUSE YOU DIDN'T FUCKING COOK IT.", "THIS PORK IS SO RAW IT'S STILL SINGING HAKUNA MATATA!", "THIS STEAK IS SO RAW OLD MCDONALD IS STILL TRYING TO MILK IT!", "THIS FISH IS SO RAW IT'S STILL TRYING TO FIND NEMO!")
				speak(msg)
			if (4)
				var/mob/living/silicon/robot/someborg = locate() in view(7, src)
				if (someborg)
					speak(pick("WHAT IS THIS?", "OH MY GOD."))
					drama()
					sleep(20)
					point(someborg)
					speak("WHO COOKED THIS?")
					sleep(20)
					if (someborg)
						speak("THIS ROBURGER IS SO FUCKING RAW [pick("IT'S STILL VIOLATING ITS LAWS", "IT HASN'T EVEN STARTED TO GO ROGUE")]!")
		raging = 0
		icon_state = "chefbot-idle"

/obj/machinery/bot/chefbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span style=\"color:red\">You short out the restraining bolt on [src].</span>")
		src.emagged = 1
		return 1
	return 0

/obj/machinery/bot/chefbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s restraining bolt.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/chefbot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/card/emag))
		emag_act(user, W)
	else
		src.visible_message("<span style=\"color:red\">[user] hits [src] with [W]!</span>")
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.5
			if("brute")
				src.health -= W.force * 0.5
			else
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/chefbot/gib()
	return src.explode()

/obj/machinery/bot/chefbot/explode()
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("<span style=\"color:red\"><B>[src] blows apart!</B></span>", 1)
	var/turf/Tsec = get_turf(src)
	var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
	s.set_up(3, 1, src)
	s.start()
	new /obj/item/clothing/head/dramachefhat(Tsec)
	qdel(src)
	return
