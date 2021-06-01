/*
    Lythine's space casino prefab
	Contents:
	 Item slot machine
	 Barbuddy
	 Misc props
*/

// Item slot machine

/obj/submachine/slot_machine/item
	name = "Item Slot Machine"
	desc = "A slot machine that produces items rather than money. Somehow."
	icon_state = "slotsitem-off"
	//mats = 50
	var/uses = 0

	var/list/junktier = list( // junk tier, 68% chance
		"/obj/item/a_gift/easter",
		"/obj/item/raw_material/rock",
		"/obj/item/balloon_animal",
		"/obj/item/cigpacket",
		"/obj/item/clothing/shoes/moon",
		"/obj/item/fish/carp",
		"/obj/item/instrument/bagpipe",
		"/obj/item/clothing/under/gimmick/yay",
		"/obj/item/scrap",
		"/obj/item/paper_bin",
		"/obj/item/item_box/stickers",
		"/obj/item/storage/box/costume/hotdog",
		"/obj/critter/cockroach",
		"/obj/item/device/light/flashlight",
		"/obj/item/kitchen/utensil/knife",
		"/obj/item/staple_gun",
		"/obj/item/old_grenade/banana/cheese_sandwich",
		"/obj/item/old_grenade/banana/banana_corndog",
		"/obj/item/rubberduck"
	)

	var/list/usefultier = list( // half decent tier, 30% chance
		"/obj/item/clothing/gloves/yellow",
		"/obj/item/bat",
		"/obj/item/reagent_containers/food/snacks/donkpocket/warm",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses/sunglasses",
		"/obj/vehicle/skateboard",
		"/obj/item/storage/firstaid/regular",
		"/obj/item/clothing/shoes/sandal",
		"/obj/item/cigpacket/random",
		"/obj/item/clothing/mask/gas",
		"/obj/critter/domestic_bee",
		"/obj/item/storage/firstaid/crit"
	)

	var/list/raretier = list( // rare tier, 2% chance
		"/obj/item/hand_tele",
		"/obj/item/clothing/suit/armor/vest",
		"/obj/item/gimmickbomb/hotdog",
		"/obj/item/card/id/captains_spare",
		"/obj/item/storage/banana_grenade_pouch",
		"/obj/critter/wendigo", // have fun!
		"/obj/item/artifact/teleport_wand",
		"/obj/item/card/id/dabbing_license"
	)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch(action)
			if ("insert_card")
				if (src.scan)
					return TRUE
				var/obj/O = usr.equipped()
				if (istype(O, /obj/item/card/id))
					boutput(usr, "<span class='notice'>You insert your ID card.</span>")
					usr.drop_item()
					O.set_loc(src)
					src.scan = O
					. = TRUE
			if ("play")
				if (src.working || !src.scan)
					return TRUE
				if (src.scan.money < 20)
					src.visible_message("<span class='subtle'><b>[src]</b> says, 'Insufficient money to play!'</span>")
					return TRUE
				src.scan.money -= 20
				src.plays++
				src.working = 1
				src.icon_state = "slotsitem-on"

				playsound(get_turf(src), "sound/machines/ding.ogg", 50, 1)
				. = TRUE
				ui_interact(usr, ui)
				SPAWN_DBG(2.5 SECONDS) // why was this at ten seconds, christ
					money_roll()
					src.working = 0
					src.icon_state = "slotsitem-off"

			if("eject")
				if(!src.scan)
					return TRUE // jerks doing that "hide in a chute to glitch auto-update windows out" exploit caused a wall of runtime errors
				usr.put_in_hand_or_eject(src.scan)
				src.scan = null
				src.working = FALSE
				src.icon_state = "slotsitem-off" // just in case, some fucker broke it earlier
				src.visible_message("<span class='subtle'><b>[src]</b> says, 'Thank you for playing!'</span>")
				. = TRUE

		src.add_fingerprint(usr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "machineUsed")

	money_roll()
		var/roll = rand(1,500)
		var/exclamation = ""
		var/win_sound = "sound/machines/ping.ogg"
		var/obj/item/P = null

		if (prob(src.uses))
			src.emag_act(null, null) // bye bye!
			return

		if (roll <= 10) // rare tier, 2% chance
			P = text2path(pick(raretier))
			win_sound = "sound/misc/airraid_loop_short.ogg"
			exclamation = "JACKPOT! "
			src.uses += 20
		else if (roll > 10 && roll <= 160) // half decent tier, 30% chance
			P = text2path(pick(usefultier))
			exclamation = "Big Winner! "
		else // junk tier, 68% chance
			P = text2path(pick(junktier))
			exclamation = "Winner! "

		if (P == null)
			P = /obj/item/raw_material/rock
		var/obj/item/prize = new P
		prize.loc = src.loc
		prize.layer += 0.1
		src.visible_message("<span class='subtle'><b>[src]</b> says, '[exclamation][src.scan.registered] has won \an [prize.name]!'</span>")
		playsound(get_turf(src), "[win_sound]", 55, 1)
		src.working = 0
		src.icon_state = "slotsitem-off"
		src.uses++

	emag_act(var/mob/user, var/obj/item/card/emag/E) // Freak out and die
		src.icon_state = "slotsitem-malf"
		playsound(get_turf(src), "sound/misc/klaxon.ogg", 55, 1)
		src.visible_message("<span class='subtle'><b>[src]</b> says, 'WINNER! WINNER! JACKPOT! WINNER! JACKPOT! BIG WINNER! BIG WINNER!'</span>")
		playsound(src.loc, "sound/impact_sounds/Metal_Clang_1.ogg", 60, 1, pitch = 1.2)
		animate_shake(src,7,5,2)
		sleep(3.5 SECONDS)

		src.visible_message("<span class='subtle'><b>[src]</b> says, 'BIG WINNER! BIG WINNER!'</span>")
		playsound(src.loc, "sound/impact_sounds/Metal_Clang_2.ogg", 60, 1, pitch = 0.8)
		animate_shake(src,5,7,2)
		sleep(1.5 SECONDS)

		new/obj/decal/implo(src.loc)
		playsound(src, 'sound/effects/suck.ogg', 60, 1)
		if (src.scan)
			src.scan.set_loc(src.loc)
		qdel(src)

// Barbuddy [my beloved]

/obj/machinery/bot/barbuddy
	name = "BarBuddy"
	desc = "A little bartending robot!"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy1"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	bot_move_delay = FLOORBOT_MOVE_SPEED
	var/hasDrink = 0
	var/atom/home // Initialized early. Where the barbuddy should be serving. Barbuddy explodes if taken too far from here.
	var/list/homeTables = list() // Initialized early. All nearby tables that the barbuddy should be checking for drinks.
	var/list/targets = list() // Nearby tables that are in need of drinks.
	var/target
	var/atom/moveTowards // The object that should be moved towards.

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
							"neurotoxin","phlogiston","freeze","dbreath","ghostchilijuice", "cholesterol", "mercury")

	var/possible_vessels = list("/obj/item/reagent_containers/food/drinks/drinkingglass", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/shot", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/oldf", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/round", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/wine", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail", \
							"/obj/item/reagent_containers/food/drinks/drinkingglass/flute")

	var/possible_stuffs = list("/obj/item/cocktail_stuff/drink_umbrella", \
							"/obj/item/cocktail_stuff/maraschino_cherry", \
							"/obj/item/cocktail_stuff/cocktail_olive", \
							"/obj/item/cocktail_stuff/celery")

	var/possible_wedges = list("/obj/item/reagent_containers/food/snacks/plant/orange/wedge", \
	                        "/obj/item/reagent_containers/food/snacks/plant/lime/wedge", \
							"/obj/item/reagent_containers/food/snacks/plant/lemon/wedge", \
							"/obj/item/reagent_containers/food/snacks/plant/grapefruit/wedge")

	New()
		..()
		// Start by getting a few initial things
		if (!src.home || !isturf(src.home))
			src.home = get_turf(src)
		if (src.homeTables.len == 0)
			for (var/obj/table/reinforced/bar/T in view(5, src.home))
				src.homeTables |= T

	proc/get_empty_tables()
		if (src.homeTables.len == 0)
			for (var/obj/table/reinforced/bar/T in view(5, src.home))
				src.homeTables |= T
			if (src.homeTables.len == 0)
				explode()
		for (var/obj/table/reinforced/bar/T in src.homeTables)
			if (!istype(T))
				src.homeTables -= T
			var/glasses = 0
			for (var/obj/item/reagent_containers/food/drinks/drinkingglass in view(0, get_turf(T)))
				glasses++
			if (glasses < 3)
				src.targets |= T

	process()
		// Nothing to do. Let's find something to do.
		if (targets.len == 0)
			get_empty_tables()
			if (targets.len == 0) // No work to be done, let's go home.
				if (!isturf(home))
					explode()
					return
				if (get_turf(src) == get_turf(home)) return
				src.navigate_to(get_turf(home), FLOORBOT_MOVE_SPEED, max_dist = 10)
				if (!src.path || !length(src.path))
					KillPathAndGiveUp(1)
					return
				return
		// Something to do. Let's decide what to do first.
		if (!target)
			target = targets[1]
		// Now we need to find out if we're going to move towards a prop dispenser or the table.
		if (!moveTowards)
			if (!hasDrink)
				// if there's a barbuddy dispenser nearby, let's do the cute little animation thing. if not, use magic to summon a drink
				for (var/obj/decal/fakeobjects/barbuddy_dispenser/D in view(5, src))
					moveTowards = D
				if (!moveTowards)
					hasDrink = 1
			else
				moveTowards = targets[1]

		if (IN_RANGE(get_turf(src), get_turf(src.moveTowards), 1))
			bartend()
			return

		if (isnull(get_turf(moveTowards)))
			if (moveTowards in src.homeTables)
				src.homeTables -= moveTowards
			KillPathAndGiveUp(1)
			return

		if (!src.path || !length(src.path))
			src.navigate_to(get_turf(moveTowards), FLOORBOT_MOVE_SPEED, max_dist = 10)
			if (!src.path || !length(src.path))
				KillPathAndGiveUp(1)
				return

	KillPathAndGiveUp(var/give_up)
		. = ..()
		if(give_up)
			src.targets -= src.target
			src.target = null
			moveTowards = null
			// Let's check if we've been stolen.
			if (!(src.home in view(5, src)))
				explode()

	proc/bartend()
		if (istype(moveTowards, /obj/decal/fakeobjects/barbuddy_dispenser)) // If it's the dispenser, do a little animation.
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
				W.update_icon()
			if (prob(25)) // Chance of wedge!
				var/pickedWedge = pick(possible_wedges)
				var/obj/item/reagent_containers/food/snacks/plant/P = new pickedWedge(null)
				W.wedge = P
				W.update_icon()
			hasDrink = 0
			KillPathAndGiveUp(1)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (user)
			user.show_text("You show [src] your [E]. They smile so hard that they begin sparking!", "red")
		emagged = 1

	demag(var/mob/user)
		emagged = 0

	explode()
		src.visible_message("<span class='alert'><B>[src] gets confused and explodes!</B></span>", 1)
		playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
		elecflash(src, radius=1, power=3, exclude_center = 0)
		qdel(src)
		return

// Misc props

/obj/decal/fakeobjects/barbuddy_dispenser
	name = "BarBuddy Drink Dispenser"
	desc = "A dispenser made specifically for BarBuddies to use."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "alc_dispenser"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/genetics_scrambler
	name = "modified GeneTek Scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/chefbot
	name = "inactive chefbot"
	desc = "It seems to still be sparking..."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "chefbot0"
	anchored = 1

/obj/decal/fakeobjects/brokengamblebot
	name = "inactive gambling robot"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy0"

/obj/item/paper/space_casino_note
	name = "note"
	info = {"I don't care if it's "not safe" or "we don't know how it works", we're about to go out of business!<br>
			I tested it and all I got were some clothes and food, it's safe enough to be making us money.<br>
			I'm putting the machine out for all to play. That's final. I don't see your genetics THING making us anything other than a lawsuit anyway.<br><br>

			P.S. Tell me if you see any suspicious pods outside, I'm starting to get paranoid.
			"}
