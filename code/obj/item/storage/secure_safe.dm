// SECURE STORAGE

ABSTRACT_TYPE(/obj/item/storage/secure)
/obj/item/storage/secure
	name = "storage/secure"
	var/atom/movable/screen/storage/boxes = null
	var/atom/movable/screen/close/closer = null
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_open = "secure0"
	var/locked = TRUE
	var/code = ""
	var/code_len = 4
	var/l_setshort = FALSE
	var/l_hacking = FALSE
	var/configure_mode = TRUE
	var/emagged = FALSE
	var/open = FALSE
	var/hackable = FALSE
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
		locked = FALSE
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
	if (user)
		user.show_text("You repair the lock on [src].", "blue")
	return TRUE

/obj/item/storage/secure/attackby(obj/item/W, mob/user, obj/item/storage/T)
	if ((W.w_class > W_CLASS_NORMAL || istype(W, /obj/item/storage/secure)))
		return
	//Waluigi hates this
	if (src.hackable)
		if (isscrewingtool(W) && (src.locked))
			sleep(0.6 SECONDS)
			src.open = !src.open
			tooltip_rebuild = 1
			user.show_message("<span class='notice'>You [src.open ? "open" : "close"] the service panel.</span>")
			return

		if (ispulsingtool(W) && (src.open) && (!src.locked) && (!src.l_hacking))
			user.show_message(text("<span class='alert'>Now attempting to reset internal memory, please hold.</span>"), 1)
			src.l_hacking = TRUE
			SPAWN(10 SECONDS)
				if (prob(40))
					src.l_setshort = TRUE
					src.configure_mode = TRUE
					user.show_message("<span class='alert'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>", 1)
					sleep(8 SECONDS)
					src.l_setshort = FALSE
					src.l_hacking = FALSE
				else
					user.show_message("<span class='alert'>Unable to reset internal memory.</span>", 1)
					src.l_hacking = FALSE
			return

	if (src.locked)
		return

	return ..()

/obj/item/storage/secure/attack_hand(mob/user)
	if (src.loc == user && src.locked)
		boutput(user, "<span class='alert'>[src] is locked and cannot be opened!</span>")
		return
	return ..()

/obj/item/storage/secure/mouse_drop(atom/over_object, src_location, over_location)
	if ((usr.is_in_hands(src) || over_object == usr) && src.locked)
		boutput(usr, "<span class='alert'>[src] is locked and cannot be opened!</span>")
		return
	return ..()

/obj/item/storage/secure/attack_self(mob/user as mob)
	src.add_dialog(user)
	add_fingerprint(user)
	return ui_interact(user)

/obj/item/storage/secure/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user,src, "SecureSafe")
		ui.open()

/obj/item/storage/secure/ui_static_data(mob/user)
	. = list(
		"safeName" = src.name
	)

/obj/item/storage/secure/ui_data(mob/user)
	. = list()

/obj/item/storage/secure/ui_act(action, params)
	. = ..()
	if (.)
		return
	. = TRUE

/obj/item/storage/secure/proc/show_lock_panel(mob/user as mob)
		var/dat = disabled ? "Access Denied" : {"
<!DOCTYPE html>
<head>
<title>[src.name]</title>
<style type="text/css">
	table.keypad, td.key
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		border:2px solid #1F1F1F;
		padding:10px;
		font-size:24px;
		font-weight:bold;
	}
	a
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		font-size:24px;
		font-weight:bold;
		border:2px solid #1F1F1F;
		text-decoration:none;
		display:block;
	}
</style>

</head>



<body bgcolor=#2F2F2F>
	<table border = 2 bgcolor=#7F3030 width = 150px>
		<tr><td><font face='system' size = 6 color=#FF0000 [src.emagged ? ">ERR" : "id = \"readout\">&nbsp;"]</font></td></tr>
	</table>
	<br>
	<table class = "keypad">
		<tr><td><a href='javascript:keypadIn(7);'>7</a></td><td><a href='javascript:keypadIn(8);'>8</a></td><td><a href='javascript:keypadIn(9);'>9</a></td></td><td><a href='javascript:keypadIn("A");'>A</a></td></tr>
		<tr><td><a href='javascript:keypadIn(4);'>4</a></td><td><a href='javascript:keypadIn(5);'>5</a></td><td><a href='javascript:keypadIn(6)'>6</a></td></td><td><a href='javascript:keypadIn("B");'>B</a></td></tr>
		<tr><td><a href='javascript:keypadIn(1);'>1</a></td><td><a href='javascript:keypadIn(2);'>2</a></td><td><a href='javascript:keypadIn(3)'>3</a></td></td><td><a href='javascript:keypadIn("C");'>C</a></td></tr>
		<tr><td><a href='javascript:keypadIn(0);'>0</a></td><td><a href='javascript:keypadIn("F");'>F</a></td><td><a href='javascript:keypadIn("E");'>E</a></td></td><td><a href='javascript:keypadIn("D");'>D</a></td></tr>

		<tr><td colspan=2 width = 100px><a id = "enterkey" href='?src=\ref[src];enter=0;'>ENTER</a></td><td colspan = 2 width = 100px><a href='javascript:keypadIn("reset");'>RESET</a></td></tr>
	</table>

<script language="JavaScript">
	var currentVal = "";

	function updateReadout(t, additive)
	{
		if ((additive != 1 && additive != "1") || currentVal == "")
		{
			document.getElementById("readout").innerHTML = "&nbsp;";
			currentVal = "";
		}
		var i = 0
		while (i++ < [src.code_len] && currentVal.length < [src.code_len])
		{
			if (t.length)
			{
				document.getElementById("readout").innerHTML += t.substr(0,1) + "&nbsp;";
				currentVal += t.substr(0,1);
				t = t.substr(1);
			}
		}

		document.getElementById("enterkey").setAttribute("href","?src=\ref[src];enter=" + currentVal + ";");
	}

	function keypadIn(num)
	{
		switch (num)
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				updateReadout(num.toString(), 1);
				break;

			case "A":
			case "B":
			case "C":
			case "D":
			case "E":
			case "F":
				updateReadout(num, 1);
				break;

			case "reset":
				updateReadout("", 0);
				break;
		}
	}

</script>

</body>"}
		user << browse(dat, "window=caselock;size=270x300;can_resize=0;can_minimize=0")


/obj/item/storage/secure/proc/set_code(var/code)
	// The code is not the correct format: null, wrong length, isn't in hex.
	if (!code || length(code) != src.code_len || !is_hex(code))
		usr << output("ERR!&0", "caselock.browser:updateReadout")
	// The code is in valid format, lets set it.
	else
		src.code = code
		src.configure_mode = FALSE
		usr << output("SET!&0", "caselock.browser:updateReadout")

/obj/item/storage/secure/proc/gen_hint(var/code_attempt)
	/*
	Mastermind game in which the solution is "code" and the guess is "code_attempt"
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
		if ((((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, guessplace, guessplace + 1)))
			guessflags += 2 ** (guessplace-1)
			codeflags += 2 ** (guessplace-1)
			rightplace++

	guessplace = 0
	while (++guessplace < search_len)
		codeplace = 0
		while(++codeplace < search_len)
			if(guessplace != codeplace && (((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (((codeflags - codeflags % (2 ** (codeplace - 1))) / (2 ** (codeplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, codeplace , codeplace + 1)))
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

/obj/item/storage/secure/proc/attempt_code(var/code_attempt)
	// Player has the correct code, toggle it open / closed.
	if (code_attempt == src.code)
		usr << output("!OK!&0", "caselock.browser:updateReadout")
		src.locked = !src.locked
		src.overlays = src.locked ? null : list(image('icons/obj/items/storage.dmi', icon_open))
		src.visible_message("<span class='alert'>[src]'s lock mechanism clicks [src.locked ? "locked" : "unlocked"].</span>")
		playsound(src.loc, "sound/items/Deconstruct.ogg", 65, 1)
	else
		usr << output("ERR!&0", "caselock.browser:updateReadout")

		if (length(code_attempt) == src.code_len)
			var/desctext = src.gen_hint(code_attempt)
			if (desctext)
				src.visible_message("<span class='alert'>[src]'s lock panel emits [desctext].</span>")
				playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1) // set this to play proper beeps later



/obj/item/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (BOUNDS_DIST(src, usr) > 0))
		return

	if ("enter" in href_list)
		var/input_code = uppertext(ckey(href_list["enter"]));
		// The safe hasn't been setup yet, try setting it up
		if (src.configure_mode)
			src.set_code(input_code)
			return
		// We're dealing with a configured safe, try to open / close it using the set code
		src.attempt_code(input_code)
	return

// SECURE BRIEFCASE

/obj/item/storage/secure/sbriefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	flags = FPRINT | TABLEPASS
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_BULKY
	mats = 8
	spawn_contents = list(/obj/item/paper,\
	/obj/item/pen)

/obj/item/storage/secure/ssafe
	name = "secure safe"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "safe"
	icon_open = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags = FPRINT | TABLEPASS
	force = 8.0
	w_class = W_CLASS_BULKY
	anchored = 1.0
	density = 0
	mats = 8
	desc = "A extremely tough secure safe."
	mechanics_type_override = /obj/item/storage/secure/ssafe

	attack_hand(mob/user)
		return attack_self(user)

/obj/item/storage/secure/ssafe/loot
	configure_mode = FALSE
	random_code = TRUE

	make_my_stuff()
		..()
		var/loot = rand(1,9)
		switch (loot)
			if (1)
				new /obj/item/material_piece/gold(src)
				for (var/i=6, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (2)
				for (var/i=2, i>0, i--)
					new /obj/item/material_piece/gold(src)
				for (var/i=4, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (3)
				for (var/i=5, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (4)
				for (var/i=4, i>0, i--)
					new /obj/item/skull(src)
				for (var/i=2, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (5)
				for (var/i=2, i>0, i--)
					new /obj/item/skull(src)
				for (var/i=2, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (6)
				for (var/i=2, i>0, i--)
					new /obj/item/gun/energy/laser_gun(src)
				for (var/i=3, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (7)
				new /obj/item/gun/kinetic/riotgun(src)
				new /obj/item/ammo/bullets/abg(src)
				for (var/i=3, i>0, i--)
					var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
					S.setup(src)
			if (8)
				for (var/i=7, i>0, i--)
					new /obj/item/raw_material/telecrystal(src)
			if (9)
				var/list/treasures = list(/obj/item/material_piece/gold,\
				/obj/item/raw_material/telecrystal,\
				/obj/item/skull,\
				/obj/item/football,\
				/obj/item/parts/human_parts/arm/left,\
				/obj/item/parts/human_parts/arm/right,\
				/obj/item/parts/human_parts/leg/left,\
				/obj/item/parts/human_parts/leg/right,\
				/obj/item/spacecash/random,\
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
				/obj/item/gun/kinetic/riotgun = /obj/item/ammo/bullets/abg,\
				/obj/item/gun/energy/taser_gun,\
				/obj/item/gun/energy/phaser_gun,\
				/obj/item/gun/energy/laser_gun,\
				/obj/item/device/key/random,\
				/obj/item/paper/IOU)

				for (var/i=rand(1,7), i>0, i--)
					var/treasure = pick(treasures)
					if (ispath(treasure))
						if (ispath(treasures[treasure])) // for things that should spawn with specific other things, ie guns & ammo
							if (i <= 5) // if there's enough room for two things
								new treasure(src)
								var/treasure_extra = treasures[treasure]
								new treasure_extra(src)
								i-- // one less thing since we spawned two
							else // if there's not enough room
								i++ // try again
						else // if there's no matching thing to spawn
							new treasure(src)
					else // if what we selected wasn't a valid path
						i++ // try again

/obj/item/paper/IOU
	name = "paper- 'IOU'"
	New()
		..()
		var/iou_name = pick(uppercase_letters) + " " + pick_string_autokey("names/last.txt")
		if (prob(1))
			iou_name = pick("L Alliman", "J Antonsson") // we're stealin all ur stuff >:D
		var/iou_thing = pick("gold bar", "telecrystal", "skull", "football", "human arm", "human arm", "human leg", "human leg", "[pick("pile", "wad")] of cash",\
		"piece of scrap", "bottle of questionable drugs", "vial of some mysterious chemical", "bag of some mysterious chemical", "bee egg", "parrot egg", "owl egg",\
		"gem", "miracle matter", "uqill nugget", "RCD", "riot shotgun", "taser", "phaser", "laser", "weird old key", "IOU note")
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
				new /obj/item/storage/firstaid/brain(src)
				new /obj/item/storage/firstaid/toxin(src)
				new /obj/item/storage/firstaid/old(src)
				new /obj/item/parts/robot_parts/head/standard(src)
			if (2)
				new /obj/item/injector_belt(src)
				new /obj/item/reagent_containers/glass/bottle/morphine(src)
				new /obj/item/reagent_containers/syringe(src)

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
				new /obj/item/storage/pill_bottle/cyberpunk(src)
				new /obj/item/storage/pill_bottle/ipecac(src)
				new /obj/item/gun/kinetic/clock_188/boomerang(src)
				new /obj/item/paper/orangeroomsafe(src)
			if (2)
				new /obj/item/storage/pill_bottle/bathsalts(src)
				new /obj/item/reagent_containers/pill/crank(src)
				new /obj/item/reagent_containers/patch/LSD(src)
				new /obj/item/paint_can/random(src)
				var/obj/item/spacecash/random/tourist/S = new /obj/item/spacecash/random/tourist
				S.setup(src)

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
				new /obj/item/reagent_containers/food/drinks/moonshine(src)
				new /obj/item/skull(src)
			if (2)
				new /obj/item/material_piece/gold(src)
				var/obj/item/spacecash/random/tourist/S = new /obj/item/spacecash/random/tourist
				S.setup(src)
			if (3)
				new /obj/item/gun/kinetic/riotgun(src)
				new /obj/item/ammo/bullets/abg(src)
			if (4)
				new /obj/item/paper/freeze(src)

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
	/obj/item/material_piece/gold = 2)

/obj/item/storage/secure/ssafe/icemoon
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/gun/kinetic/revolver,
	/obj/item/chilly_orb, // a thing to confuse people
	/obj/item/spacecash/thousand = 3)

/obj/item/storage/secure/ssafe/candy_shop
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/robot_foodsynthesizer,\
	/obj/item/spacecash/thousand,\
	/obj/item/gun/kinetic/derringer/empty)

/obj/item/storage/secure/ssafe/shooting_range //prefab safe
	configure_mode = FALSE
	random_code = TRUE
	spawn_contents = list(/obj/item/spacecash/thousand,\
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
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new /obj/item/scrap(src)
			if (2)
				new /obj/item/material_piece/gold(src)
				new /obj/item/skull(src)
				new /obj/item/parts/human_parts/arm/left(src)
				new /obj/item/parts/human_parts/leg/right(src)
				var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
				S.setup(src)
				S = new /obj/item/spacecash/thousand
				S.setup(src)

			if (3)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new /obj/item/football(src)
				var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
				S.setup(src)
				S = new /obj/item/spacecash/thousand
				S.setup(src)

			if (4)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new	/obj/item/instrument/saxophone(src)
				var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
				S.setup(src)
				S = new /obj/item/spacecash/thousand
				S.setup(src)

			if (5)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new /obj/item/skull(src)
				new /obj/item/skull(src)
				new /obj/item/skull(src)
				var/obj/item/spacecash/thousand/S = new /obj/item/spacecash/thousand
				S.setup(src)
				S = new /obj/item/spacecash/thousand
				S.setup(src)

	disposing()
		. = ..()
		STOP_TRACKING
