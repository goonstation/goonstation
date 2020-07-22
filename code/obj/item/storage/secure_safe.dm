// SECURE STORAGE

/obj/item/storage/secure
	name = "storage/secure"
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_open = "secure0"
	var/locked = 1
	var/code = ""
	var/l_setshort = 0
	var/l_hacking = 0
	var/configure_mode = 1
	var/emagged = 0
	var/open = 0
	var/hackable = 0
	w_class = 3.0
	burn_possible = 0
	var/random_code = 0 // sets things to already have a randomized code on spawning

/obj/item/storage/secure/New()
	..()
	if (src.random_code)
		src.code = random_hex(4)

/obj/item/storage/secure/get_desc()
	return "The service panel is [src.open ? "open" : "closed"]."

/obj/item/storage/secure/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if ((src.locked == 1) && (!src.emagged))
		emagged = 1
		src.overlays += image('icons/obj/items/storage.dmi', icon_sparking)
		sleep(0.6 SECONDS)
		src.overlays = null
		overlays += image('icons/obj/items/storage.dmi', icon_locking)
		locked = 0
		if (user)
			boutput(user, "You short out the lock on [src].")
		return 1
	return 0

/obj/item/storage/secure/demag(var/mob/user)
	if (!src.emagged)
		return 0
	emagged = 0
	sleep(0.6 SECONDS)
	src.overlays = null
	if (user)
		user.show_text("You repair the lock on [src].", "blue")
	return 1

/obj/item/storage/secure/attackby(obj/item/W as obj, mob/user as mob)
	if ((W.w_class > 3 || istype(W, /obj/item/storage/secure)))
		return
	//Waluigi hates this
	if (hackable)
		if (isscrewingtool(W) && (src.locked == 1))
			sleep(0.6 SECONDS)
			src.open =! src.open
			tooltip_rebuild = 1
			user.show_message("<span class='notice'>You [src.open ? "open" : "close"] the service panel.</span>")
			return

		if (ispulsingtool(W) && (src.open == 1) && (!src.locked) && (!src.l_hacking))
			user.show_message(text("<span class='alert'>Now attempting to reset internal memory, please hold.</span>"), 1)
			src.l_hacking = 1
			SPAWN_DBG(10 SECONDS)
				if (prob(40))
					src.l_setshort = 1
					configure_mode = 1
					user.show_message("<span class='alert'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>", 1)
					sleep(8 SECONDS)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message("<span class='alert'>Unable to reset internal memory.</span>", 1)
					src.l_hacking = 0
			return

	if (src.locked == 1)
		return

	return ..()

/obj/item/storage/secure/attack_hand(mob/user as mob)
	if (src.loc == user && src.locked == 1)
		boutput(usr, "<span class='alert'>[src] is locked and cannot be opened!</span>")
		return
	return ..()

/obj/item/storage/secure/MouseDrop(atom/over_object, src_location, over_location)
	if ((usr.is_in_hands(src) || over_object == usr) && src.locked == 1)
		boutput(usr, "<span class='alert'>[src] is locked and cannot be opened!</span>")
		return
	return ..()

/obj/item/storage/secure/attack_self(mob/user as mob)
	src.add_dialog(user)
	add_fingerprint(user)
	return show_lock_panel(user)

/obj/item/storage/secure/proc/show_lock_panel(mob/user as mob)
		var/dat = {"
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
		while (i++ < 4 && currentVal.length < 4)
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

/*
	var/dat = "<TT><B>[src.name]</B><BR><br><br>Lock Status: [src.locked ? "LOCKED" : "UNLOCKED"]"
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += "<p><br><b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"
	if (src.emagged)
		dat += "<p><br><font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>"
	if (src.l_setshort)
		dat += "<p><br><font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>"
	message = "[src.code]"
	if (!src.locked)
		message = "*****"
	dat += "<HR><br>>[message]<BR><br><table border='1'><tr><td><A href='?src=\ref[src];type=1'>1</A></td><td><A href='?src=\ref[src];type=2'>2</A></td><td><A href='?src=\ref[src];type=3'>3</A></td></tr><tr><td><A href='?src=\ref[src];type=4'>4</A></td><td><A href='?src=\ref[src];type=5'>5</A></td><td><A href='?src=\ref[src];type=6'>6</A></td></tr><tr><td><A href='?src=\ref[src];type=7'>7</A></td><td><A href='?src=\ref[src];type=8'>8</A></td><td><A href='?src=\ref[src];type=9'>9</A></td></tr><tr><td><A href='?src=\ref[src];type=R'>R</A></td><td><A href='?src=\ref[src];type=0'>0</A></td><td><A href='?src=\ref[src];type=E'>E</A></td></tr></table></tt>"
	user.Browse(dat, "window=caselock;size=300x280")
*/
/obj/item/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return

	if ("enter" in href_list)
		if (configure_mode)
			var/new_code = uppertext(ckey(href_list["enter"]))
			if (!new_code || length(new_code) != 4 || !is_hex(new_code))
				usr << output("ERR!&0", "caselock.browser:updateReadout")
			else
				code = new_code
				configure_mode = 0
				usr << output("SET!&0", "caselock.browser:updateReadout")

		else
			if (uppertext(href_list["enter"]) == src.code)
				usr << output("!OK!&0", "caselock.browser:updateReadout")


				if (locked)
					locked = 0
					overlays = list(image('icons/obj/items/storage.dmi', icon_open))
					src.visible_message("<span class='alert'>[src]'s lock mechanism clicks unlocked.</span>")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 65, 1)

				else
					locked = 1

					overlays = null
					src.visible_message("<span class='alert'>[src]'s lock mechanism clunks locked.</span>")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 65, 1)

			else if (href_list["enter"] == "")
				locked = 1

				overlays = null
				src.visible_message("<span class='alert'>[src]'s lock mechanism clunks locked.</span>")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 65, 1)

			else
				usr << output("ERR!&0", "caselock.browser:updateReadout")
				var/code_attempt = uppertext(ckey(href_list["enter"]))
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
				if (length(code_attempt) == 4)
					var/guessplace = 0
					var/codeplace = 0
					var/guessflags = 0
					var/codeflags = 0

					var/wrongplace = 0
					var/rightplace = 0
					while (++guessplace < 5)
						if ((((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, guessplace, guessplace + 1)))
							guessflags += 2 ** (guessplace-1)
							codeflags += 2 ** (guessplace-1)
							rightplace++

					guessplace = 0
					while (++guessplace < 5)
						codeplace = 0
						while(++codeplace < 5)
							if(guessplace != codeplace && (((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (((codeflags - codeflags % (2 ** (codeplace - 1))) / (2 ** (codeplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, codeplace , codeplace + 1)))
								guessflags += 2 ** (guessplace-1)
								codeflags += 2 ** (codeplace-1)
								wrongplace++
								codeplace = 5

					var/desctext = ""
					switch(rightplace)
						if (1)
							desctext += "a grumpy beep"
						if (2)
							desctext += "a pair of grumpy beeps"
						if (3)
							desctext += "a trio of grumpy beeps"

					if (desctext && (wrongplace) > 0)
						desctext += " and "

					switch(wrongplace)
						if (1)
							desctext += "a short boop"
						if (2)
							desctext += "two harsh boops"
						if (3)
							desctext += "a quick three boops"
						if (4)
							desctext += "a long, sad, warbly boop"

					if (desctext)
						src.visible_message("<span class='alert'>[src]'s lock panel emits [desctext].</span>")
						playsound(src.loc, "sound/machines/twobeep.ogg", 55, 1) // set this to play proper beeps later

	else if (href_list["lock"])
		if (!locked)
			locked = 1

			overlays = null
			boutput(usr, "<span class='alert'>The lock mechanism clunks locked.</span>")
			src.visible_message("<span class='alert'>[src]'s lock mechanism clunks locked.</span>")
			playsound(src.loc, "sound/items/Deconstruct.ogg", 65, 1)
/*
	else if (href_list["setcode"])
		if (src.locked && src.code)
			return

		src.configure_mode = 1
		src.locked = 0
		overlays = list(image('icons/obj/items/storage.dmi', icon_open))
		src.code = ""

		boutput(usr, "Code reset.  Please type new code and press enter.")
		show_lock_panel(usr)
*/

	/*
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.locked = 0
				src.overlays = null
				overlays += image('icons/obj/items/storage.dmi', icon_open)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += "[href_list["type"]]"
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
			return
	*/
	return

// SECURE BRIEFCASE

/obj/item/storage/secure/sbriefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	flags = FPRINT | TABLEPASS
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	mats = 8
	spawn_contents = list(/obj/item/paper,\
	/obj/item/pen)

/*
/obj/item/storage/secure/sbriefcase/attack(mob/M as mob, mob/user as mob)
	if (usr.bioHolder.HasEffect("clumsy") && prob(50))
		user.visible_message("<span class='alert'><b>[usr]</b> swings [src] too hard and nails \himself in the face.</span>")
		random_brute_damage(usr, 10)
		usr.paralysis += 2
		return

	var/t = user:zone_sel.selecting
	if (t == "head")
		if (M.stat < 2 && M.health < 50 && prob(90))
			// ******* Check
			var/mob/living/carbon/human/H = 0
			var/mob/living/silicon/S = 0
			if (ishuman(M))
				H = M
			else if (issilicon(M))
				S = M
			if (H && (istype(H.head, /obj/item/clothing/head/helmet/) && H.head.body_parts_covered & HEAD) && prob(80))
				boutput(M, "<span class='alert'>The helmet protects you from being hit hard in the head!</span>")
				return
			var/time = rand(2, 6)
			if (prob(75))
				if (M.paralysis < time && !M.is_hulk())
					M.paralysis = time
			else
				if (M.stunned < time && !M.is_hulk())
					M.stunned = time
			M.lying = 1
			if (H && isalive(H)) H.lastgasp()
			if (S && isalive(S)) S.lastgasp()
			if(!isdead(M))	setunconcious(M)
			M.set_clothing_icon_dirty()
			M.visible_message("<span class='alert'><B>[M] has been knocked unconscious!</B></span>")
		else
			boutput(M, "<span class='alert'>[user] tried to knock you unconcious!</span>")
			M.change_eye_blurry(3)

	return
*/

/obj/item/storage/secure/ssafe
	name = "secure safe"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "safe"
	icon_open = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags = FPRINT | TABLEPASS
	force = 8.0
	w_class = 4.0
	anchored = 1.0
	density = 0
	mats = 8
	desc = "A extremely tough secure safe."
	mechanics_type_override = /obj/item/storage/secure/ssafe

	attack_hand(mob/user as mob)
		return attack_self(user)

/obj/item/storage/secure/ssafe/loot
	configure_mode = 0
	random_code = 1

	make_my_stuff()
		..()
		var/loot = rand(1,9)
		switch (loot)
			if (1)
				new /obj/item/material_piece/gold(src)
				for (var/i=6, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (2)
				for (var/i=2, i>0, i--)
					new /obj/item/material_piece/gold(src)
				for (var/i=4, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (3)
				for (var/i=5, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (4)
				for (var/i=4, i>0, i--)
					new /obj/item/skull(src)
				for (var/i=2, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (5)
				for (var/i=2, i>0, i--)
					new /obj/item/skull(src)
				for (var/i=2, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (6)
				for (var/i=2, i>0, i--)
					new /obj/item/gun/energy/laser_gun(src)
				for (var/i=3, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
					S.setup(src)
			if (7)
				new /obj/item/gun/kinetic/riotgun(src)
				new /obj/item/ammo/bullets/abg(src)
				for (var/i=3, i>0, i--)
					var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
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
		var/iou_name = pick(uppercase_letters) + " " + pick(last_names)
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

/obj/item/storage/secure/ssafe/theorangeroom
	configure_mode = 0
	random_code = 1

	New()
		..()
		var/loot = rand(1,2)
		switch (loot)
			if (1)
				new /obj/item/storage/pill_bottle/cyberpunk(src)
				new /obj/item/storage/pill_bottle/ipecac(src)
				new /obj/item/gun/kinetic/pistol(src)
				new /obj/item/paper/orangeroomsafe(src)
			if (2)
				new /obj/item/storage/pill_bottle/bathsalts(src)
				new /obj/item/reagent_containers/pill/crank(src)
				new /obj/item/reagent_containers/patch/LSD(src)
				new /obj/item/paint_can/random(src)
				var/obj/item/spacecash/random/tourist/S = unpool(/obj/item/spacecash/random/tourist)
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
	configure_mode = 0
	random_code = 1

	New()
		..()
		var/loot = rand(1,4)
		switch (loot)
			if (1)
				new /obj/item/reagent_containers/food/drinks/moonshine(src)
				new /obj/item/skull(src)
			if (2)
				new /obj/item/material_piece/gold(src)
				var/obj/item/spacecash/random/tourist/S = unpool(/obj/item/spacecash/random/tourist)
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
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/device/key/lead,\
	/obj/item/paper/intelligence_report,\
	/obj/item/material_piece/gold = 2)

/obj/item/storage/secure/ssafe/icemoon
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/gun/kinetic/revolver,
	/obj/item/chilly_orb, // a thing to confuse people
	/obj/item/spacecash/thousand = 3)

/obj/item/storage/secure/ssafe/marsvault
	name = "secure vault"
	configure_mode = 0
	random_code = 1
	var/disabled = 1

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
				var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)
				S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)

			if (3)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new /obj/item/football(src)
				var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)
				S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)

			if (4)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new	/obj/item/instrument/saxophone(src)
				var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)
				S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)

			if (5)
				new /obj/item/material_piece/gold(src)
				new /obj/item/material_piece/gold(src)
				new /obj/item/skull(src)
				new /obj/item/skull(src)
				new /obj/item/skull(src)
				var/obj/item/spacecash/thousand/S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)
				S = unpool(/obj/item/spacecash/thousand)
				S.setup(src)

	disposing()
		. = ..()
		STOP_TRACKING

	show_lock_panel(mob/user as mob)
		var/dat = ""
		if(disabled)
			dat = "Access Denied"
		else
			dat = {"
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
					while (i++ < 4 && currentVal.length < 4)
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
