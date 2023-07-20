#define CHEFBOT_MOVE_SPEED 8
/obj/machinery/bot/chefbot
	name = "Dramatic Chef"
	desc = "(icon, name, concept, and any kind of consistency or sense is currently pending)"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "chefbot-idle"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	on = 1 // ACTION
	health = 5
	var/raging = 0
	var/list/calledout = list()
	no_camera = 1
	/// Doesn't feel right to have this guy *constantly* flipping its lid like a methed up graytider
	dynamic_processing = 0

/obj/machinery/bot/chefbot/process()
	. = ..()
	if (raging)
		return
	if(prob(60) && src.on == 1)
		src.navigate_to(get_step_rand(src))

		SPAWN(0)
			if(prob(src.emagged * 20))
				drama()
			if(prob(30 + src.emagged * 30))
				yell()

/obj/machinery/bot/chefbot/proc/drama()
	playsound(src,'sound/effects/dramatic.ogg', vol = 100) // F U C K temporary measure

/obj/machinery/bot/chefbot/speak(var/message)
	if (message)
		message = uppertext(message)
	. = ..()

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
			for_by_tcl(M, /mob/living/carbon/human)
				if(!IN_RANGE(M, src, 7))
					continue
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
				src.navigate_to(shitfood, CHEFBOT_MOVE_SPEED / (1+src.emagged), 1, 15) // Shit food can't hide!
				if (prob(50))
					speak(pick("ALRIGHT, EVERYBODY STOP!" , "THAT'S ENOUGH!"))
				sleep(1 SECOND)
				drama()
				sleep(2 SECONDS)
				if (is_thechef_the_chef && prob(50) && thechef)
					point(thechef)
					speak(pick("COME HERE YOU!", "COME HERE, LET ME TELL YOU SOMETHING!", "STOP WHAT YOU'RE DOING AND COME HERE RIGHT NOW!"))
				else
					speak("WHO COOKED THIS SHIT?")
				sleep(2 SECONDS)
				if (shitfood) // fix for cannot read null.name (the food sometimes no longer exists after a sleep (because people eat it I assume)) - haine
					if (dork && prob(10))
						speak("THIS [shitfood.name] LOOKS LIKE [dork]!")
					speak("THIS [shitfood.name] [why_is_it_bad()]!")
				var/is_in_kitchen = 0
				if (thechef && is_thechef_the_chef)
					var/area/area = get_area(thechef)
					if (findtext(area.name, "Kitchen"))
						is_in_kitchen = 1
				sleep(2 SECONDS)
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
					sleep(2 SECONDS)
					point(somefucker)
					speak("WHO COOKED THIS?")
					sleep(2 SECONDS)
					if (somefucker)
						if (somefucker.getStatusDuration("burning") > 0)
							speak("YOU DON'T LEAVE YOUR FUCKING FOOD UNATTENDED ON THE FUCKING STOVE. LOOK AT THIS. IT'S ON FIRE! IT'S GOING TO BE FUCKING BURNT!")
						else if (somefucker.get_burn_damage() < 50)
							speak("THIS [pick("HUMAN", "BURGER", "STEAK", "PORK")] IS SO FUCKING RAW IT'S STILL [pick("BEATING ASSISTANTS TO DEATH", "FARTING ON DEAD BODIES", "TRYING TO FEED ME FLOOR PILLS")]!")
						else
							speak("THIS [pick("HUMAN", "PRIMATE", "STEAK", "BURGER")] IS FUCKING [pick("OVERCOOKED", "BURNT")]!")
			if (2 to 3)
				drama()
				sleep(2 SECONDS)
				var/msg = pick("WHY DID THE CHICKEN CROSS THE ROAD? BECAUSE YOU DIDN'T FUCKING COOK IT.", "THIS PORK IS SO RAW IT'S STILL SINGING HAKUNA MATATA!", "THIS STEAK IS SO RAW OLD MCDONALD IS STILL TRYING TO MILK IT!", "THIS FISH IS SO RAW IT'S STILL TRYING TO FIND NEMO!")
				speak(msg)
			if (4)
				var/mob/living/silicon/robot/someborg = locate() in view(7, src)
				if (someborg)
					speak(pick("WHAT IS THIS?", "OH MY GOD."))
					drama()
					sleep(2 SECONDS)
					point(someborg)
					speak("WHO COOKED THIS?")
					sleep(2 SECONDS)
					if (someborg)
						speak("THIS ROBURGER IS SO FUCKING RAW [pick("IT'S STILL VIOLATING ITS LAWS", "IT HASN'T EVEN STARTED TO GO ROGUE")]!")
		raging = 0
		icon_state = "chefbot-idle"

/obj/machinery/bot/chefbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='alert'>You short out the restraining bolt on [src].</span>")
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

/obj/machinery/bot/chefbot/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/card/emag))
		emag_act(user, W)
	else
		src.visible_message("<span class='alert'>[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/chefbot/gib()
	return src.explode()

/obj/machinery/bot/chefbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
	var/turf/Tsec = get_turf(src)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	new /obj/item/clothing/head/dramachefhat(Tsec)
	qdel(src)
	return
