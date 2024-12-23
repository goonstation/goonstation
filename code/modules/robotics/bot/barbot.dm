// Barbuddy [my beloved] -- currently used in the Space Casino prefab

#define BARBUDDY_MOVE_SPEED 7
/obj/machinery/bot/barbuddy
	name = "BarBuddy"
	desc = "A little bartending robot!"
	icon = 'icons/obj/bots/robuddy/pr-6.dmi'
	icon_state = "body"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	bot_move_delay = BARBUDDY_MOVE_SPEED
	var/hasDrink = 0
	var/turf/home // Initialized early. Where the barbuddy should be serving. Barbuddy explodes if taken too far from here.
	var/list/homeTables = list() // Initialized early. All nearby tables that the barbuddy should be checking for drinks.
	var/list/targets = list() // Nearby tables that are in need of drinks.
	var/atom/moveTowards // The object that should be moved towards.
	var/worryLevel = 0 // Taking the barbuddy away from their bar makes them sad. Very sad. This stores how sad they are.
	var/emotion = "neutral" // The face the barbuddy should be making.

	var/possible_drinks = list("bilk","beer","cider","mead","wine","champagne","rum","vodka","bourbon", \
							"boorbon","beepskybeer","screwdriver","bloody_mary","bloody_scary",\
							"snakebite","diesel","suicider","port","gin","vermouth","bitters","whiskey_sour",\
							"daiquiri","martini","v_martini","murdini","manhattan","libre","ginfizz","gimlet",\
							"v_gimlet","w_russian","b_russian","irishcoffee","cosmo","beach","gtonic","vtonic","sonic",\
							"gpink","eraser","squeeze","hunchback","madmen","planter","maitai","harlow",\
							"gchronic","margarita","tequini","pfire","bull","longisland","pinacolada","longbeach",\
							"mimosa","french75","sangria","tomcollins","peachschnapps","moscowmule","tequilasunrise",\
							"paloma","mintjulep","mojito","cremedementhe","grasshopper","curacao","bluelagoon",\
							"bluehawaiian","negroni","necroni", "cola", "juice_lime", "juice_lemon", "juice_orange", \
							"juice_cran", "juice_cherry", "juice_pineapple", "juice_tomato", \
							"coconut_milk", "sugar", "water", "vanilla", "tea","mint")

	var/possible_poisons = list("acetaldehyde","wolfsbane","ants","weedkiller","cyanide","krokodil", "fluorine", "radium", \
							"neurotoxin","phlogiston","ghostchilijuice", "cholesterol", "mercury")

	var/possible_vessels = list(/obj/item/reagent_containers/food/drinks/drinkingglass, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/shot, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/oldf, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/round, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/wine, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail, \
							/obj/item/reagent_containers/food/drinks/drinkingglass/flute)

	var/possible_stuffs = list(/obj/item/cocktail_stuff/drink_umbrella, \
							/obj/item/cocktail_stuff/maraschino_cherry, \
							/obj/item/cocktail_stuff/cocktail_olive, \
							/obj/item/cocktail_stuff/celery)

	var/possible_wedges = list(/obj/item/reagent_containers/food/snacks/plant/orange/wedge, \
	                        /obj/item/reagent_containers/food/snacks/plant/lime/wedge, \
							/obj/item/reagent_containers/food/snacks/plant/lemon/wedge, \
							/obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge)

	New()
		..()
		src.setEmotion("happy")
		src.UpdateOverlays(image(src.icon, "lights-on"), "lights")
		// Start by getting a few initial things
		home = get_turf(src)
		if (!home)
			qdel(src)
			return

	proc/setEmotion(var/set_emotion)
		if(src.emotion == set_emotion)
			return
		src.emotion = set_emotion
		var/emotion_image = image(src.icon, "face-[src.emotion]")
		src.UpdateOverlays(emotion_image, "emotion_image")

	proc/get_empty_tables()
		if (!length(src.homeTables))
			for (var/obj/table/reinforced/bar/T in view(5, src.home))
				src.homeTables += T
			if (!length(src.homeTables))
				explode()
		for (var/obj/table/reinforced/bar/T in src.homeTables)
			var/glasses = 0
			for (var/obj/item/reagent_containers/food/drinks/drinkingglass in view(0, T))
				glasses++
			if (glasses < 3)
				src.targets += T

	process()
		// Nothing to do. Let's find something to do.
		if (!length(targets))
			get_empty_tables()
			if (!length(targets)) // No work to be done, let's go home.
				if (get_turf(src) == home) return
				src.navigate_to(home, BARBUDDY_MOVE_SPEED, max_dist = 60)
				if (!length(src.path))
					KillPathAndGiveUp(1)
				return
		// Let's decide what to do.
		if (!moveTowards)
			if (!hasDrink)
				// if there's a barbuddy dispenser nearby, let's do the cute little animation thing. if not, use magic to summon a drink
				for (var/obj/fakeobject/barbuddy_dispenser/D in view(5, src))
					moveTowards = D
				if (!moveTowards)
					hasDrink = 1
			else
				if (length(targets))
					moveTowards = targets[1]

		if (isnull(get_turf(moveTowards)))
			if (moveTowards in src.homeTables)
				src.homeTables -= moveTowards
			KillPathAndGiveUp(1)
			return

		if ((BOUNDS_DIST(src, src.moveTowards) == 0))
			bartend()
			src.worryLevel = 0
			src.setEmotion("happy")
			return

		if (!length(src.path))
			src.navigate_to(get_turf(moveTowards), BARBUDDY_MOVE_SPEED, max_dist = 60)
			if (!length(src.path))
				KillPathAndGiveUp(1)
				return

	KillPathAndGiveUp(var/give_up)
		. = ..()
		if(give_up)
			src.targets -= src.moveTowards
			moveTowards = null
			// Let's check if we've been stolen.
			if (!(src.home in view(7, src)))
				homesick()

	proc/bartend()
		if (istype(moveTowards, /obj/fakeobject/barbuddy_dispenser)) // If it's the dispenser, do a little animation.
			playsound(moveTowards.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.3)
			moveTowards.icon_state = "alc_dispenser[rand(1,5)]"
			hasDrink = 1
			moveTowards = null
		else if (istype(moveTowards, /obj/table/reinforced/bar)) // If it's a table, so let's generate a drink.
			var/pickedVessel = pick(possible_vessels)
			var/obj/item/reagent_containers/food/drinks/drinkingglass/W = new pickedVessel(moveTowards.loc)
			if (src.emagged)
				W.reagents.add_reagent(pick(possible_poisons), W.initial_volume)
			else
				W.reagents.add_reagent(pick(possible_drinks), W.initial_volume)
			W.pixel_x = rand(-8, 8)
			W.pixel_y = rand(0, 16)
			if (prob(25)) // Chance of stuff!
				var/pickedStuff = pick(possible_stuffs)
				var/obj/item/cocktail_stuff/U = new pickedStuff(null)
				W.in_glass = U
				W.UpdateIcon()
			if (prob(25)) // Chance of wedge!
				var/pickedWedge = pick(possible_wedges)
				var/obj/item/reagent_containers/food/snacks/plant/P = new pickedWedge(null)
				W.wedge = P
				W.UpdateIcon()
			hasDrink = 0
			targets -= moveTowards
			KillPathAndGiveUp(1)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (user)
			user.show_text("You show [src] your [E]. They smile so hard that they begin sparking!", "red")
		emagged = TRUE
		return TRUE

	demag(var/mob/user)
		emagged = 0

	proc/homesick()
		switch (src.worryLevel)
			if (1)
				src.speak("Where am I?")
			if (3)
				src.speak("Where's my bar?")
				src.setEmotion("sad")
			if (6)
				src.speak("I can't bartend out here...")
			if (9)
				src.setEmotion("screaming")
			if (10)
				src.visible_message(SPAN_ALERT("<B>[src] gets so homesick that they explode!</B>"))
				explode()
		src.worryLevel++

	explode()
		playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)
		elecflash(src, radius=1, power=3, exclude_center = 0)
		qdel(src)

/obj/fakeobject/barbuddy_dispenser
	name = "BarBuddy Drink Dispenser"
	desc = "A dispenser made specifically for BarBuddies to use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "alc_dispenser"
	anchored = ANCHORED
	density = 1
