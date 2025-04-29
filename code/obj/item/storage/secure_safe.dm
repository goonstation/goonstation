#define KEYPAD_ERR "ERROR"
#define KEYPAD_SET "SET"
#define KEYPAD_OK "OK"

ABSTRACT_TYPE(/obj/item/storage/secure)
/obj/item/storage/secure
	name = "storage/secure"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_open = "secure0"
	var/locked = TRUE
	var/code = ""
	var/guess = ""
	/// Associative list of ckeys to the number of incorrect guesses they have made
	var/number_of_guesses = list()
	// What msg show on the keypad, non-null overrides guess in the UI
	var/pad_msg = null
	var/code_len = 4
	var/l_setshort = FALSE
	var/l_hacking = FALSE
	var/configure_mode = TRUE
	var/emagged = FALSE
	var/open = FALSE
	var/hackable = FALSE
	/// Can we do the mastermind game to try to crack this safe?
	var/crackable = TRUE
	var/disabled = FALSE
	w_class = W_CLASS_NORMAL
	burn_possible = FALSE
	var/random_code = FALSE // sets things to already have a randomized code on spawning

/obj/item/storage/secure/New()
	..()
	if (src.random_code)
		src.code = random_hex(src.code_len)

/obj/item/storage/secure/get_desc()
	return "The service panel is [src.open ? "open" : "closed"]."

/obj/item/storage/secure/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if ((src.locked) && (!src.emagged))
		src.emagged = TRUE
		src.overlays += image('icons/obj/items/storage.dmi', icon_sparking)
		sleep(0.6 SECONDS)
		src.overlays = null
		src.overlays += image('icons/obj/items/storage.dmi', icon_locking)
		src.pad_msg = KEYPAD_ERR
		src.locked = FALSE
		if (user)
			boutput(user, "You short out the lock on [src].")
		return TRUE
	return FALSE

/obj/item/storage/secure/demag(var/mob/user)
	if (!src.emagged)
		return FALSE
	src.emagged = FALSE
	sleep(0.6 SECONDS)
	src.overlays = null
	src.pad_msg = null
	if (user)
		boutput(user, "You repair the lock on [src].")
	return TRUE

/obj/item/storage/secure/attackby(obj/item/W, mob/user)
	if (!(src.storage.check_can_hold(W) == STORAGE_CAN_HOLD) || istype(W, /obj/item/storage/secure))
		return
	//Waluigi hates this
	if (src.hackable)
		if (isscrewingtool(W) && (src.locked))
			sleep(0.6 SECONDS)
			src.open = !src.open
			tooltip_rebuild = TRUE
			boutput(user, SPAN_NOTICE("You [src.open ? "open" : "close"] the service panel."))
			return

		if (ispulsingtool(W) && (src.open) && (!src.locked) && (!src.l_hacking))
			boutput(user, SPAN_ALERT("Now attempting to reset internal memory, please hold."))
			src.l_hacking = TRUE
			SPAWN(10 SECONDS)
				if (prob(40))
					src.l_setshort = TRUE
					src.configure_mode = TRUE
					boutput(user, SPAN_ALERT("Internal memory reset.  Please give it a few seconds to reinitialize."))
					sleep(8 SECONDS)
					src.l_setshort = FALSE
					src.l_hacking = FALSE
				else
					boutput(user, SPAN_ALERT("Unable to reset internal memory."))
					src.l_hacking = FALSE
			return

	if (src.locked)
		return

	return ..()

/obj/item/storage/secure/attack_hand(mob/user)
	if (src.loc == user && src.locked)
		boutput(user, SPAN_ALERT("[src] is locked and cannot be opened!"))
		return
	return ..()

/obj/item/storage/secure/mouse_drop(atom/over_object, src_location, over_location)
	if ((usr.is_in_hands(src) || over_object == usr) && src.locked)
		boutput(usr, SPAN_ALERT("[src] is locked and cannot be opened!"))
		return
	return ..()

/obj/item/storage/secure/attack_self(mob/user as mob)
	src.add_dialog(user)
	add_fingerprint(user)
	return ui_interact(user)

/obj/item/storage/secure/attack_ai(mob/user)
	src.add_dialog(user)
	return ui_interact(user)

/obj/item/storage/secure/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SecureSafe")
		ui.open()

/obj/item/storage/secure/ui_static_data(mob/user)
	. = list(
		"codeLen" = src.code_len,
		"safeName" = src.name,
	)

/obj/item/storage/secure/ui_data(mob/user)
	. = list(
		"attempt" = src.guess,
		"disabled" = src.disabled,
		"emagged" = src.emagged,
		"padMsg" = src.pad_msg,
	)

/obj/item/storage/secure/ui_act(action, params)
	. = ..()
	if (.)
		return

	if (!ON_COOLDOWN(src, "playsound", 0.2 SECONDS))
		playsound(src.loc, 'sound/machines/keypress.ogg', 55, 1)

	if (src.disabled || src.emagged)
		return

	switch(action)
		if("input")
			src.add_input(params["input"])
		if("enter")
			if (src.configure_mode)
				src.set_code()
			else
				// We're dealing with a configured safe, try to open / close it using the set code
				src.submit_guess(usr)
		if("reset")
			src.clear_input()
	. = TRUE


/obj/item/storage/secure/proc/add_input(var/key)
	var/key_len = length(key)
	var/guess_len = length(src.guess)
	// User is trying to type in code higher than the length, just dump the new input and bail out early
	if (guess_len + key_len > src.code_len)
		return

	// Otherwise add the input to the code attempt
	src.pad_msg = null
	src.guess += key

/obj/item/storage/secure/proc/set_code()
	// The code is not the correct format: null, wrong length, isn't in hex.
	if (length(src.guess) != src.code_len || !is_hex(src.guess))
		src.pad_msg = KEYPAD_ERR
	// The code is in valid format, lets set it.
	else
		src.pad_msg = KEYPAD_SET
		src.code = src.guess
		src.configure_mode = FALSE
	src.guess = ""

/obj/item/storage/secure/proc/gen_hint(var/guess)
	/*
	Mastermind game in which the solution is "code" and the guess is "guess"
	First go through the guess and find any with the exact same position as in the solution
	Increment rightplace when such occurs.
	Then go through the guess and, with each letter, go through all the letters of the solution code
	Increment wrongplace when such occurs.
	In both cases, add a power of two corresponding to the locations of the relevant letters
	This forms a set of flags which is checked whenever same-letters are found
	Once all of the guess has been iterated through for both rightplace and wrongplace, construct
	a beep/boop message dependant on what was gotten right.
	*/
	var/guessplace = 0
	var/codeplace = 0
	var/guessflags = 0
	var/codeflags = 0
	var/search_len = src.code_len + 1;

	var/wrongplace = 0
	var/rightplace = 0

	while (++guessplace < search_len)
		if ((((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (copytext(guess, guessplace , guessplace + 1) == copytext(code, guessplace, guessplace + 1)))
			guessflags += 2 ** (guessplace-1)
			codeflags += 2 ** (guessplace-1)
			rightplace++

	guessplace = 0
	while (++guessplace < search_len)
		codeplace = 0
		while(++codeplace < search_len)
			if(guessplace != codeplace && (((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (((codeflags - codeflags % (2 ** (codeplace - 1))) / (2 ** (codeplace - 1))) % 2 == 0) && (copytext(guess, guessplace , guessplace + 1) == copytext(code, codeplace , codeplace + 1)))
				guessflags += 2 ** (guessplace-1)
				codeflags += 2 ** (codeplace-1)
				wrongplace++
				codeplace = search_len

	var/desctext = ""
	if (rightplace > 0)
		desctext += rightplace == 1 ? "a single grumpy beep" : "[rightplace] grumpy beeps"

	if (desctext && (wrongplace) > 0)
		desctext += " and "

	if (wrongplace == src.code_len)
		desctext += "a long, sad, warbly boop"
	else if (wrongplace > 0)
		desctext += wrongplace == 1 ? "a single short boop" : "[wrongplace] quick boops"

	return desctext

/obj/item/storage/secure/proc/submit_guess(mob/user)
	// Player has the correct code, toggle it open / closed.
	if (guess == src.code)
		src.pad_msg = KEYPAD_OK
		src.guess = ""
		src.locked = !src.locked
		src.overlays = src.locked ? null : list(image('icons/obj/items/storage.dmi', icon_open))
		boutput(user, SPAN_ALERT("[src]'s lock mechanism clicks [src.locked ? "locked" : "unlocked"]."))
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 65, 1)
		if (!src.locked)
			logTheThing(LOG_STATION, src, "at [log_loc(src)] has been unlocked by [key_name(user)] after [src.number_of_guesses[user.key] || "0"] incorrect guesses. Contents: [src.contents.Join(", ")]")
		src.number_of_guesses = list()
	else
		src.number_of_guesses[user.key]++
		if (length(guess) == src.code_len && src.crackable)
			var/desctext = src.gen_hint(guess)
			if (desctext)
				boutput(user, SPAN_ALERT("[src]'s lock panel emits [desctext]."))
				playsound(src.loc, 'sound/machines/twobeep.ogg', 55, 1)

		src.pad_msg = KEYPAD_ERR
		src.guess= ""

/obj/item/storage/secure/proc/clear_input()
	src.pad_msg = null
	src.guess = ""

// SECURE BRIEFCASE

TYPEINFO(/obj/item/storage/secure/sbriefcase)
	mats = 8

/obj/item/storage/secure/sbriefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	spawn_contents = list(/obj/item/paper,\
	/obj/item/pen)
	check_wclass = TRUE
	can_hold = list(/obj/item/stamped_bullion)

TYPEINFO(/obj/item/storage/secure/ssafe)
	mats = 8

/obj/item/storage/secure/ssafe
	name = "secure safe"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "safe"
	icon_open = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8
	w_class = W_CLASS_BULKY
	anchored = ANCHORED
	density = 0
	desc = "A extremely tough secure safe."
	mechanics_type_override = /obj/item/storage/secure/ssafe

	attack_hand(mob/user)
		return src.AttackSelf(user)

/obj/item/storage/secure/ssafe/loot
	configure_mode = FALSE
	random_code = TRUE

	make_my_stuff()
		..()
		var/loot = rand(1,11)
		switch (loot)
			if (1)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				for (var/i=6, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (2)
				for (var/i=2, i>0, i--)
					src.storage.add_contents(new /obj/item/stamped_bullion(src))
				for (var/i=4, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (3)
				for (var/i=5, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (4)
				for (var/i=4, i>0, i--)
					src.storage.add_contents(new /obj/item/skull(src))
				for (var/i=2, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (5)
				for (var/i=2, i>0, i--)
					src.storage.add_contents(new /obj/item/skull(src))
				for (var/i=2, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (6)
				for (var/i=2, i>0, i--)
					src.storage.add_contents(new /obj/item/gun/energy/laser_gun(src))
				for (var/i=3, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (7)
				src.storage.add_contents(new /obj/item/gun/kinetic/single_action/mts_255(src))
				src.storage.add_contents(new /obj/item/ammo/bullets/a12/bird/five(src))
				for (var/i=3, i>0, i--)
					var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
					S.setup(src, try_add_to_storage = TRUE)
			if (8)
				for (var/i=7, i>0, i--)
					src.storage.add_contents(new /obj/item/raw_material/telecrystal(src))
			if (9)
				var/list/treasures = list(/obj/item/stamped_bullion,\
				/obj/item/raw_material/telecrystal,\
				/obj/item/skull,\
				/obj/item/football,\
				/obj/item/parts/human_parts/arm/left,\
				/obj/item/parts/human_parts/arm/right,\
				/obj/item/parts/human_parts/leg/left,\
				/obj/item/parts/human_parts/leg/right,\
				/obj/item/currency/spacecash,\
				/obj/item/scrap,\
				/obj/item/storage/pill_bottle/cyberpunk,\
				/obj/item/reagent_containers/vending/vial/random,\
				/obj/item/reagent_containers/vending/bag/random,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/bee,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/parrot,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl,\
				/obj/item/raw_material/gemstone,\
				/obj/item/raw_material/miracle,\
				/obj/item/raw_material/uqill,\
				/obj/item/rcd = /obj/item/rcd_ammo/big,\
				/obj/item/gun/kinetic/single_action/mts_255 = /obj/item/ammo/bullets/a12/bird/five,\
				/obj/item/gun/energy/taser_gun,\
				/obj/item/gun/energy/phaser_gun,\
				/obj/item/gun/energy/egun_jr,\
				/obj/item/gun/energy/laser_gun,\
				/obj/item/device/key/random,\
				/obj/item/storage/firstaid/old,\
				/obj/item/storage/firstaid/crit,\
				/obj/item/paper/IOU)

				for (var/i=rand(1,src.storage.slots), i>0, i--)
					var/treasure = pick(treasures)
					if (ispath(treasure))
						if (ispath(treasures[treasure])) // for things that should spawn with specific other things, ie guns & ammo
							if (i <= 5) // if there's enough room for two things
								src.storage.add_contents(new treasure(src))
								var/treasure_extra = treasures[treasure]
								src.storage.add_contents(new treasure_extra(src))
								i-- // one less thing since we spawned two
							else // if there's not enough room
								i++ // try again
						else // if there's no matching thing to spawn
							src.storage.add_contents(new treasure(src))
					else // if what we selected wasn't a valid path
						i++ // try again

			if (10) // weaker power eggs
				var/list/eggs_weak = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/purple,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/mime,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/plant,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/candy,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/knight,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/ghost)

				for (var/i=rand(1,src.storage.slots), i>0, i--)
					var/egg = pick(eggs_weak)
					if (ispath(egg))
						src.storage.add_contents(new egg(src))
					else // if what we selected wasn't a valid path
						i++ // try again
				for (var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/E in src.contents)
					E.infertile = TRUE

			if (11) // strong power eggs
				var/list/eggs_strong = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/robot,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/cockatrice,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/dream,\
				/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/popsicle)
				#ifdef SECRETS_ENABLED
					eggs_strong += list(/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/dragon,\
					/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/coral,\
					/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/phoenix,\
					/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/zappy)
				#endif
				for (var/i=rand(1,1), i>0, i--) // think we need this for loop for error handling still
					var/egg = pick(eggs_strong)
					var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/C = new(egg)
					if (istype(C))
						C.infertile = TRUE
						src.storage.add_contents(C)

/obj/item/paper/IOU
	name = "paper- 'IOU'"
	New()
		..()
		var/iou_name = pick(uppercase_letters) + " " + pick_string_autokey("names/last.txt")
		if (prob(1))
			iou_name = pick("L Alliman", "J Antonsson") // we're stealin all ur stuff >:D
		var/iou_thing = pick("gold bar", "telecrystal", "skull", "football", "human arm", "human arm", "human leg", "human leg", "[pick("pile", "wad")] of cash",\
		"piece of scrap", "bottle of questionable drugs", "vial of some mysterious chemical", "bag of some mysterious chemical", "bee egg", "parrot egg", "owl egg",\
		"gem", "miracle matter", "uqill nugget", "RCD", "shotgun", "taser", "phaser", "laser", "weird old key", "IOU note")
		src.desc = "Looks like \"[iou_name]\" got here first. Hope you didn't want that [iou_thing] too bad, cause unless you find whoever that is, you're probably never gunna see that thing."
		src.info = {"I owe you one (1):
		<u>[iou_thing]</u>
		- <i>[iou_name]</i>"}
		return

/obj/item/storage/secure/ssafe/vonrickenstorage
	configure_mode = FALSE
	random_code = TRUE

	New()
		..()
		var/loot = rand(1,2)
		switch (loot)
			if (1)
				src.storage.add_contents(new /obj/item/storage/firstaid/brain(src))
				src.storage.add_contents(new /obj/item/storage/firstaid/toxin(src))
				src.storage.add_contents(new /obj/item/storage/firstaid/old(src))
				src.storage.add_contents(new /obj/item/parts/robot_parts/head/standard(src))
			if (2)
				src.storage.add_contents(new /obj/item/injector_belt(src))
				src.storage.add_contents(new /obj/item/reagent_containers/glass/bottle/morphine(src))
				src.storage.add_contents(new /obj/item/reagent_containers/syringe(src))

/obj/item/storage/secure/ssafe/vonricken
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/clothing/shoes/cyborg, /obj/item/clothing/suit/cyborg_suit, /obj/item/clothing/gloves/cyborg, /obj/item/paper/thevonricken)


/obj/item/paper/thevonricken
	name = "This is hell! Oh god!"

	New()
		..()
		src.icon_state = "paper_singed"
		src.desc = "It looks like someone had jotted stuff down on it in frantic haste!"
		src.info = {"<center><h1>My doom? Yes.</h1></center>
		<hr>
		Wow...then I thought boarding a space-cruise would be fun...but now? I heard these over-the-top-armed-beasts-of-robots tread into the room next door.
		<br>
		I doubt Marvin is anymore.
		<br>
		I doubt I will be either.
		<br>
		Never leave the room. Never. Never...yes...someone will come...rescue me,...
		<br>
		<b>Why did I not pack a spare radio? Fuck!</b>
		<br>
		<br>
		Whoever reads this...destroy this facility! It is not what it seems to be!
		<hr>
		<b>Space-Cruise? My butt!</b>"}

/obj/item/storage/secure/ssafe/theorangeroom
	configure_mode = FALSE
	random_code = TRUE

	New()
		..()
		var/loot = rand(1,2)
		switch (loot)
			if (1)
				src.storage.add_contents(new /obj/item/storage/pill_bottle/cyberpunk(src))
				src.storage.add_contents(new /obj/item/storage/pill_bottle/ipecac(src))
				src.storage.add_contents(new /obj/item/gun/kinetic/clock_188/boomerang(src))
				src.storage.add_contents(new /obj/item/paper/orangeroomsafe(src))
			if (2)
				src.storage.add_contents(new /obj/item/storage/pill_bottle/bathsalts(src))
				src.storage.add_contents(new /obj/item/reagent_containers/pill/crank(src))
				src.storage.add_contents(new /obj/item/reagent_containers/patch/LSD(src))
				src.storage.add_contents(new /obj/item/paint_can/random(src))
				var/obj/item/currency/spacecash/tourist/S = new /obj/item/currency/spacecash/tourist
				S.setup(src, try_add_to_storage = TRUE)

/obj/item/paper/orangeroomsafe
	name = "Bon voyage!"

	New()
		..()
		src.icon_state = "thermal_paper"
		src.desc = "This piece of paper has been scribbled on with focused elegance."
		src.info = {"<center><h2>Goodbye boredom!</h2></center>
		<hr>
		Today is my first day abboard this vessel and oh wow! I would have never guessed that I'd be the lucky bastard to get to sleep the first shift.
		<br>
		<br>
		Joffrey is working the engine and making sure that we don't blow up and that curious computer in the cockpit brings us to where we gotta go.
		<br>
		Certainly checking out if the nearest NanoTrasen station is doing well is not a hard job at all.
		<br>
		For most of the day we simply twiddle our thumbs and kick back.
		<br>
		<br>
		<i>I think I'll take a good nights sleep and relax with my personal goodies. :)</i>"}

/obj/item/storage/secure/ssafe/theblindpig
	configure_mode = FALSE
	random_code = TRUE

	New()
		..()
		var/loot = rand(1,4)
		switch (loot)
			if (1)
				src.storage.add_contents(new /obj/item/reagent_containers/food/drinks/moonshine(src))
				src.storage.add_contents(new /obj/item/skull(src))
			if (2)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				var/obj/item/currency/spacecash/tourist/S = new /obj/item/currency/spacecash/tourist
				S.setup(src, try_add_to_storage = TRUE)
			if (3)
				src.storage.add_contents(new /obj/item/gun/kinetic/single_action/mts_255(src))
				src.storage.add_contents(new /obj/item/ammo/bullets/a12/bird/five(src))
			if (4)
				src.storage.add_contents(new /obj/item/paper/freeze(src))

/obj/item/paper/freeze
	name = "paper-'Recipe for Freeze'"

	New()
		..()
		src.desc = "This piece of paper looks pretty worn and has a bunch of stains on it."
		src.info = {"<li>Gin</li><br>
		<li>Menthol</li><br>
		<br><i>The rest of the text is obscured by several stains.</i>
		"}

/obj/item/storage/secure/ssafe/martian
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/device/key/lead,\
	/obj/item/paper/intelligence_report,\
	/obj/item/stamped_bullion = 2)

/obj/item/storage/secure/ssafe/icemoon
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/gun/kinetic/revolver,
	/obj/item/chilly_orb, // a thing to confuse people
	/obj/item/currency/spacecash/thousand = 3)

/obj/item/storage/secure/ssafe/candy_shop
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/robot_foodsynthesizer,\
	/obj/item/currency/spacecash/thousand,\
	/obj/item/gun/kinetic/derringer/empty)

/obj/item/storage/secure/ssafe/shooting_range //prefab safe
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/currency/spacecash/thousand,\
	/obj/item/gun/energy/raygun,\
	/obj/item/paper/shooting_range_note2)

/obj/item/storage/secure/ssafe/marsvault
	name = "secure vault"
	configure_mode = FALSE
	random_code = TRUE
	disabled = TRUE

	New()
		..()
		START_TRACKING

		var/loot = rand(1,5)
		switch (loot)
			if (1)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/scrap(src))
			if (2)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/skull(src))
				src.storage.add_contents(new /obj/item/parts/human_parts/arm/left(src))
				src.storage.add_contents(new /obj/item/parts/human_parts/leg/right(src))
				var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)
				S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)

			if (3)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/football(src))
				var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)
				S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)

			if (4)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/instrument/saxophone(src))
				var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)
				S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)

			if (5)
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/stamped_bullion(src))
				src.storage.add_contents(new /obj/item/skull(src))
				src.storage.add_contents(new /obj/item/skull(src))
				src.storage.add_contents(new /obj/item/skull(src))
				var/obj/item/currency/spacecash/thousand/S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)
				S = new /obj/item/currency/spacecash/thousand
				S.setup(src, try_add_to_storage = TRUE)

	disposing()
		. = ..()
		STOP_TRACKING

/obj/item/storage/secure/ssafe/larrys
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/paper/IOU, /obj/item/device/key/generic/larrys, /obj/item/currency/buttcoin, /obj/item/currency/buttcoin)

#undef KEYPAD_ERR
#undef KEYPAD_SET
#undef KEYPAD_OK
