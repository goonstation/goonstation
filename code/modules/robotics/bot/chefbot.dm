#define CHEFBOT_MOVE_SPEED 8
/obj/machinery/bot/chefbot
	name = "Dramatic Chef"
	desc = "Who let this guy in the kitchen? Does he even know how to cook, or is he just there to criticize?"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "chefbot-idle"
	density = 0
	anchored = UNANCHORED
	on = TRUE
	health = 5
	var/raging = 0
	no_camera = 1
	/// Doesn't feel right to have this guy *constantly* flipping its lid like a methed up graytider
	dynamic_processing = 0

/obj/machinery/bot/chefbot/process()
	. = ..()
	if (raging || !src.on)
		return
	if(prob(src.emagged * 20))
		drama()
	if(!GET_COOLDOWN(src, "chefbot_yelling"))
		SPAWN (0 SECOND)
			if (src.emagged)
				ON_COOLDOWN(src, "chefbot_yelling", pick(10 SECONDS, 20 SECONDS))
			else
				ON_COOLDOWN(src, "chefbot_yelling", pick(40 SECONDS, 60 SECONDS))
			yell()
	if(!ON_COOLDOWN(src, "chefbot_wander", pick(2 SECONDS, 5 SECONDS)))
		src.navigate_to(get_step_rand(src))

/obj/machinery/bot/chefbot/proc/drama()
	playsound(src,'sound/effects/dramatic.ogg', vol = 100)

/obj/machinery/bot/chefbot/speak(var/message)
	if (message)
		message = uppertext(message)
	. = ..()

/obj/machinery/bot/chefbot/proc/why_is_it_bad()
	return pick("IS FUCKING [pick("RAW", "BLAND", "UNDERCOOKED", "OVERCOOKED", "INEDIBLE", "RANCID", "DISGUSTING")]", "LOOKS LIKE [pick("BABY VOMIT", "A MUSHY PIG'S ASS", "REGURGITATED DONKEY SHIT", "A PILE OF ROTTING FLIES", "REFINED CAT PISS")]")

#define FOOD_QUALITY_HORSESHIT 0
#define FOOD_QUALITY_SHIT 1
#define FOOD_QUALITY_GOOD_SHIT 2
/obj/machinery/bot/chefbot/proc/yell()
	if (!src.emagged || prob(50))
		var/obj/item/reagent_containers/food/snacks/food_to_judge
		var/mob/living/carbon/human/thechef
		var/mob/dork
		var/is_thechef_the_chef = 0
		var/how_shit = FOOD_QUALITY_HORSESHIT //ITS ALL DONKEY PISS UNTIL I SAY OTHERWISE
		for (var/obj/item/reagent_containers/food/snacks/probablyshitfood in view(7, src))
			if (GET_COOLDOWN(src, "judged_\ref[probablyshitfood]") && (prob(95))) //This food has already been judged. 5 % Chance to yell at people it got stale
				continue
			food_to_judge = probablyshitfood
			break
		if (!food_to_judge)
			if(prob(30))
				speak(pick_string("chefbot.txt", "get_to_work"))
			return
		if (food_to_judge.quality > 1 && food_to_judge.quality < 5 && !src.emagged)
			how_shit = FOOD_QUALITY_SHIT
		else if (food_to_judge.quality >= 5 && !src.emagged)
			how_shit = FOOD_QUALITY_GOOD_SHIT
		src.get_mad()
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
			point(food_to_judge)
			src.navigate_to(food_to_judge, CHEFBOT_MOVE_SPEED / (1+src.emagged), 1, 15) // Shit food can't hide!
			speak(pick_string("chefbot.txt", "found_food"))
			sleep(1 SECOND)
			drama()
			sleep(3 SECONDS)
			if (is_thechef_the_chef && thechef)
				point(thechef)
				speak(pick_string("chefbot.txt", "call_chef"))
			else
				if (GET_COOLDOWN(src, "judged_\ref[food_to_judge]")) //We already judged this food and it's STILL HERE, GET MAD
					speak(pick_string("chefbot.txt", "stale_food"))
					src.calm_down()
					return
				switch (how_shit)
					if (FOOD_QUALITY_HORSESHIT)
						speak(pick_string("chefbot.txt", "question_shit_food"))
					else
						speak(pick_string("chefbot.txt", "question_food"))
				ON_COOLDOWN(src, "judged_\ref[food_to_judge]", INFINITY) // We judged this food, remember it.
			sleep(3 SECONDS)
			if (food_to_judge)
				switch(how_shit)
					if (FOOD_QUALITY_HORSESHIT)
						if (dork && prob(10))
							speak("THIS [food_to_judge.name] LOOKS LIKE [dork]!")
						else
							speak("THIS [food_to_judge.name] [why_is_it_bad()]!")
					if (FOOD_QUALITY_SHIT)
						speak(pick_string("chefbot.txt", "insult_food"))
					if (FOOD_QUALITY_GOOD_SHIT)
						speak(pick_string("chefbot.txt", "compliment"))
			if (how_shit == FOOD_QUALITY_GOOD_SHIT)
				src.calm_down()
				return
			var/is_in_kitchen = 0
			if (thechef && is_thechef_the_chef)
				var/area/area = get_area(thechef)
				if (findtext(area.name, "Kitchen"))
					is_in_kitchen = 1
			sleep(3 SECONDS)
			if (is_in_kitchen)
				speak(pick_string("chefbot.txt", "blame_kitchen"))
			else if (how_shit == FOOD_QUALITY_HORSESHIT)
				speak(pick_string("chefbot.txt", "insult_cook"))
			src.calm_down()
			if (how_shit == FOOD_QUALITY_HORSESHIT)
				if (food_to_judge in range(1, src))
					food_to_judge.set_loc(src.loc)
					visible_message(SPAN_ALERT("<b>[src]</b> stomps on [food_to_judge] [pick("with glee", "with the wrath of a thousand overworked line-cooks", "with cold, uncaring efficiency")]."))
					animate_stomp(src)
					SPAWN(0.5 SECONDS)
						if (food_to_judge in range(1, src))
							qdel(food_to_judge)
			else
				speak(pick_string("chefbot.txt", "flip_shit"))
				if (food_to_judge in range(1, src))
					src.visible_message(SPAN_NOTICE("[src] flings [food_to_judge] away [pick("without even looking", "with rage", "with a disappointed sigh", "at impossible speeds")]."))
					ThrowRandom(food_to_judge, 4, 1)
		else
			// Nobody is in range anyway
			src.calm_down()
			return
	else if (src.emagged)
		src.get_mad()
		switch (rand(1,3))
			if (1)
				var/mob/living/carbon/human/somefucker = locate() in view(7, src)
				if (somefucker)
					speak(pick_string("chefbot.txt", "found_food"))
					drama()
					sleep(3 SECONDS)
					point(somefucker)
					speak(pick_string("chefbot.txt", "emag_insult"))
					sleep(3 SECONDS)
					if (somefucker)
						if (somefucker.getStatusDuration("burning") > 0)
							speak("YOU DON'T LEAVE YOUR FUCKING FOOD UNATTENDED ON THE FUCKING STOVE. LOOK AT THIS. IT'S ON FIRE! IT'S GOING TO BE FUCKING BURNT!")
						else if (somefucker.get_burn_damage() < 50)
							speak("THIS [pick("HUMAN", "PRIMATE", "STEAK", "BURGER", "PORK", "MEAT")] IS SO FUCKING RAW IT'S STILL [pick("BEATING ASSISTANTS TO DEATH", "FARTING ON DEAD BODIES", "TRYING TO FEED ME FLOOR PILLS")]!")
							src.navigate_to(somefucker, CHEFBOT_MOVE_SPEED / 2, 1, 15)
							sleep(4 SECOND)
							speak("TURN THE HEAT UP! I WANT TO HEAR IT SIZZLE!", "NO UNDERCOOKED MEAT IN MY KITCHEN!", "I HAVE TO DO THIS SHIT MYSELF! PATHETIC!", "DO I HAVE TO DO EVERYTHING HERE?")
							src.visible_message(SPAN_ALERT("[src] flares up in anger!"))
							fireflash(src, 1, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
						else
							speak("THIS [pick("HUMAN", "PRIMATE", "STEAK", "BURGER", "PORK", "MEAT")] IS FUCKING [pick("OVERCOOKED", "BURNT")]!")
				else
					var/mob/living/silicon/robot/someborg = locate() in view(7, src)
					if (someborg)
						speak(pick_string("chefbot.txt", "found_food"))
						drama()
						sleep(3 SECONDS)
						point(someborg)
						speak(pick_string("chefbot.txt", "emag_insult"))
						sleep(3 SECONDS)
						if (someborg)
							speak("THIS ROBURGER IS SO FUCKING RAW [pick("IT'S STILL VIOLATING ITS LAWS", "IT HASN'T EVEN STARTED TO GO ROGUE")]!")
			if (2)
				drama()
				sleep(3 SECONDS)
				speak(pick_string("chefbot.txt", "bad_joke"))
			if (3)
				var/obj/item/stuff_to_fling = null
				for (var/obj/item/stuff in range(4, src))
					if (istype(stuff, /obj/item/kitchen/utensil))
						stuff_to_fling = stuff
						break
					if (istype(stuff, /obj/item/plate))
						stuff_to_fling = stuff
						break
				if (stuff_to_fling)
					speak(pick_string("chefbot.txt", "criticize_cleanliness"))
					drama()
					sleep (3 SECONDS)
					if (stuff_to_fling)
						src.navigate_to(stuff_to_fling, CHEFBOT_MOVE_SPEED / 2, 1, 15)
						speak(pick_string("chefbot.txt", "adjust_cutlery"))
						sleep (3 SECONDS)
						if ((stuff_to_fling) && (stuff_to_fling in range(1, src)))
							ThrowRandom(stuff_to_fling, 4, 1)
							src.visible_message(SPAN_ALERT("[src] smacks at [stuff_to_fling], sending it flying."))
		src.calm_down()
#undef FOOD_QUALITY_HORSESHIT
#undef FOOD_QUALITY_SHIT
#undef FOOD_QUALITY_GOOD_SHIT

/obj/machinery/bot/chefbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, SPAN_ALERT("You short out the restraining bolt on [src]."))
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
		src.visible_message(SPAN_ALERT("[user] hits [src] with [W]!"))
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()
		..()

/obj/machinery/bot/chefbot/gib()
	return src.explode()

/obj/machinery/bot/chefbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message(SPAN_ALERT("<B>[src] blows apart!</B>"))
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
	var/turf/Tsec = get_turf(src)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	if (src.emagged)
		fireflash(src, 1, checkLos = FALSE, chemfire = CHEM_FIRE_RED)
	new /obj/item/clothing/head/dramachefhat(Tsec)
	qdel(src)
	return

/obj/machinery/bot/chefbot/proc/get_mad()
	src.raging = 1
	src.icon_state = "chefbot-mad"

/obj/machinery/bot/chefbot/proc/calm_down()
	src.raging = 0
	src.icon_state = "chefbot-idle"
