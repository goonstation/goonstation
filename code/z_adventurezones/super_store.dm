// discount gaming store prefab

// areas
/area/super_store
	name = "Debris-19 X-treme Gaming Superstore"
	icon_state = "blue"
	sound_environment = 11
	sound_group = "super_store"
	sound_loop = 'sound/ambience/music/arcade_ambience.ogg'
	sound_loop_vol = 40

/area/super_store/hangar
	name = "Debris-19 Parking"
	icon_state = "red"
	sound_group = "super_store_backroom"
	sound_loop = 'sound/ambience/music/arcade_ambience_quiet.ogg'

/area/super_store/backrooms
	name = "Debris-19 Employee Area"
	icon_state = "purple"
	sound_group = "super_store_backroom"
	sound_loop = 'sound/ambience/music/arcade_ambience_quiet.ogg'

// posters

/obj/decal/poster/wallsign/duck
	name = "poster"
	desc = "It's an advertisement for the latest model of Amusing Duck toy."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "duck"

/obj/decal/poster/wallsign/toy_gun
	name = "poster"
	desc = "It's an advertisement for the latest model of Super! Gun Friend."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "toy_gun"

// Lore stuff
/obj/item/device/audio_log/radioship/large/super_store
		name = "voice mail recorder"
		continuous = 0
		audiolog_messages = list("*harsh beep*",
								"You have three new messages. Begin message one.",
								"Hey Sal, this is Big Manny. I'm uhhh.",
								"Look man. I know I said I'd get back to you this week.",
								"Next week. I promise. I got a big shipment coming in.",
								"*harsh beep*",
								"End of message one. Begin message two.",
								"SALLYYYYY BOY. Looks like I missed you. It's your ole Cousin Briggs.",
								"When you gonna stop playing with those toys and start hangin with ya boys. ",
								"Look man. I'm just kidding. I get it, I was way into that shit.",
								"But you gotta get out more man. Come on. Call me back, love ya bud.",
								"*harsh beep*",
								"End of message two. Begin message three.",
								"THIS IS AUTOMATED CALL FROM SUPER! FRIEND.",
								"ANNOUNCING NEW INNOVATIVE ENJOYMENT BASED PRODUCT FOR HUMAN.",
								"NEW INTERACTIVE ENRICHED KINETIC TOY",
								"UNPRECEDENTED RATE OF FIRE AND FUN 100%.",
								"ENQUIRE NOW WITH REPRESENTATIVE.",
								"*harsh beep*")

		audiolog_speakers = list("Electronic Tone",
								"Electronic Voice",
								"Snivelling Male Voice",
								"Snivelling Male Voice",
								"Snivelling Male Voice",
								"Electronic Tone",
								"Electronic Voice",
								"Loud Male Voice",
								"Loud Male Voice",
								"Loud Male Voice",
								"Loud Male Voice",
								"Electronic Tone",
								"Electronic Voice",
								"????",
								"????",
								"????",
								"????",
								"????",
								"Electronic Tone")


/obj/item/paper/image/businesscard/super_store
	name = "business card - Debris-19 X-treme Gaming Superstore"
	icon_state = "businesscard"
	desc = "A business card for Debris-19 X-treme Gaming Superstore."
	path = "images/arts/business_superstore.png"
	sizex = 630
	sizey = 360



/obj/item/paper/image/duck_magazine
	name = "Super! Friend 2053 Catalogue"
	desc= "The latest and greatest enjoyment products."
	icon_state = "duck_magazine"
	path = "images/arts/business_superfriend.png"
	sizex = 1055
	sizey = 746

/obj/item/paper/super_store1
	name = "scribbled note"
	info = "Hey Sal.<br> \
			Those salvs came by asking about the old Cyalume replica swords again. They wanted to collect a bulk order of the 2050 model in red color. \
			I told them we don't stock those anymore after those customs officials came and confiscated that batch, but they kept just putting more \
			and more money on the counter saying 'maybe this will change your tune'. I told them it's out of my hands and they got really angry. \
			Said they're gonna pay you a visit and give you a 'piece of their time'. I said I don't think that's the right phrase and then the big \
			bald one knocked over the shelf with all the Robustris Memorabilia. Sorry Sal. <br><br> \
			-Jenkins."

/obj/item/paper/super_store2
	name = "email printout"
	info = {"
	=== Spacemail ===<br>
	From: bob_henderson@lunaport_surplus.org<br>
	To: info@debris19-gaming.com<br>
	Subject: Mod.00 Inquiry<br><br>

	Good Afternoon Sal,<br><br>

	We've received your inquiry regarding a first edition Super! Friend Mod.00 Kit model replica laser gun.<br>
	I'm happy to say I have some good news. We've located a seller who is in possession of a mint condition example.<br>
	The example is without original box or papers, but it has been inspected for authenticity. The seller is a big Super! Friend enthusiast.<br>
	He wants a guarantee the gun is not going to be sold on after you purchase it. I understand you own a Gaming store?<br>
	If this would be a problem let me know and I can see what I can do. Otherwise, I'm happy to facilitate a deal.<br><br>

	- Bob Henderson, LunaPort Surplus.<br><br>

	=== Spacemail ===<br>
	From: info@debris19-gaming.com<br>
	To: bob_henderson@lunaport_surplus.org<br>
	Subject: Re: Mod.00 Inquiry<br><br>

	Hi Bob,<br><br>

	That won't be a problem. I do own a gaming store, but I'm a big Super! Friend fan myself.<br>
	This would be for personal use, to display in the store as a centrepiece. That kind of thing, big display cabinet.<br>
	If the buyer lives on Luna then I think I know who you're talking about. We've done business before and it didn't end well.<br>
	I'll send over one of my people to Luna, just don't mention me. But I can guarantee it won't be sold on.<br><br>

	Price won't be an issue.<br><br>
	- Sal <br>
	"}

/obj/item/paper/super_store3
	name = "memo to staff"
	info = {"<center><h2>NOTICE TO STAFF</h2></center>
	I've got some big news. Sarah went out to Luna and secured us a one of a kind deal on a first edition Mod.00. <br>
	This thing is gonna look fucking great. I've got a custom display case coming in and we're gonna put it in the middle of the store.<br>
	I'm gonna be out when it arrives. Cousin is draggin me out on vacation to some shithole space diner. <br><br>
	When it gets here: Put it in the display case in the backroom, and lock the door. Do NOT fuck about with it. Do NOT move the case yet. <br>
	I swear to god Jenkins if you fucking even THINK of trying to put it together I will DESTROY YOU. <br><br>

	-Sal."}

/obj/item/paper/super_store4
	name = "to-do list"
	info = {"<center><h2>Sal's To-do list</h2></center><br>
	-Scam that asshole on Luna for his original Mod. 00 <br>
	-Deal with those salvage punks who keep tryna hustle the staff (hire mercs? dunno) <br>
	-Call Cousin Briggs <br>
	-Find replacement for Jenkins <br>
	-Fire Jenkins <br>
	-Get investment back from Big Manny (Don't forget it's 4000 CREDITS not 400.) <br>
	-Call that dumbass contractor who didn't install a way to get out the duck enclosure. <br>
	-Break into NT employee market. Free duck samples?"}


// Sals computer
/obj/machinery/computer3/luggable/personal/sals_laptop
	setup_drive_type = /obj/item/disk/data/fixed_disk/hd64/super_store

/obj/item/luggable_computer/personal/sals_laptop
	name = "sal's laptop"
	desc = "Looks like an aging gaming model."
	luggable_type = /obj/machinery/computer3/luggable/personal/sals_laptop

/obj/item/disk/data/fixed_disk/hd64/super_store
	New()
		..()
		var/datum/computer/folder/newfolder = new /datum/computer/folder
		newfolder.name = "logs"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/record/c3help(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/terminal_program/writewizard(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "mail"
		src.root.add_file(newfolder)
		newfolder.add_file(new /datum/computer/file/record/super_store/important_offer(src))
		newfolder.add_file(new /datum/computer/file/record/super_store/customs_notice(src))
		newfolder.add_file(new /datum/computer/file/record/super_store/pay_up(src))

// Sals computer files
/datum/computer/file/record/super_store
	important_offer
		name = "important_offer"
		New()
			..()
			src.fields = list("FROM: king_wyatt@spacemail.com",\
			"SUBJECT: important offer", \
			"Hey Sal, I've come across something big.", \
			"Got one of these red VR headsets.", \
			"You know the ones. I need to shift it fast.", \
			"I'll do you for 2k. Or we do consignment?", \
			"Let me know asap. need to get rid of it.", \
			"-wyatt." \
			)

	customs_notice
		name = "customs_notice"
		New()
			..()
			src.fields = list("FROM: customs@frontier_authority.org",\
			"SUBJECT: notice of inspection", \
			"FOR IMMEDIATE ATTENTION", \
			"Your business is subject to enforcement action.", \
			"Customs officials will arrive for inspection.", \
			"Please ensure all documentation is prepared.", \
			"As a reminder, all goods that have passed through", \
			"Amantes are now subject to additional checks.", \
			"We look forward to continued cooperation.", \
			"-Customs Dept. Frontier Authority"
			)

	pay_up
		name = "pay_up"
		New()
			..()
			src.fields = list("FROM: silva@magpie.net",\
			"SUBJECT: pay up sal", \
			"Sal you fuck. quit running so scared.", \
			"convenient youre never in store when", \
			"my contractors come round to visit you.", \
			"youre a slippery bastard sal. just cos", \
			"we were on mars together dont mean that", \
			"u can fuckin rip me off. i want compensated.", \
			"either pay up or hand over those sabers.", \
			"those syndies already paid for 30 units.", \
			"you fucked it sal. if they ask im blaming", \
			"you. they wont be kind like me. fuck you.",
			"-silva"
			)

/obj/item/gun/energy/antique/first_edition
	name = "Super! Friend First Edition Mod. 00 Kit Laser"
	desc = "It's a FIRST EDITION kit model of the Mod.00 'Lunaport Legend' laser gun from Super! Protector Friend. With realistic sound fx and exciting LED display!"
	icon_state = "caplaser_rare"
	rarity = ITEM_RARITY_EPIC

/obj/machinery/bot/secbot/super_store
	name = "Mr Duckman"
	desc = "The Guardian of the Gaming store"

	initialize()
		..()
		for_by_tcl(case, /obj/displaycase)
			if (istype(case, /obj/displaycase/alarmed/super_store))
				RegisterSignal(case, COMSIG_DISPLAYCASE_ALARM, PROC_REF(on_alarm))

	proc/on_alarm(obj/displaycase/case)
		src.emag_act(null, null)
		src.emag_act(null, null)
		src.say("ROBBERY IN PROGRESS. LOCKDOWN IN EFFECT")
		src.summon_bot(get_turf(case))


/mob/living/carbon/human/super_store_employee
	is_npc = TRUE
	gender = MALE
	real_name = "Jenkins \"Buckshot\" Wriggley"

	// both used for dialogue stuff
	var/concerned = FALSE // you smashed the display case
	var/fired = FALSE // you took off his mandatory hotdog suit


	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/white, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/jersey/red, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, SLOT_GLASSES)
		if(prob(1))
			src.equip_new_if_possible(/obj/item/clothing/suit/gimmick/pickle, SLOT_WEAR_SUIT) // rare pickle
		else
			src.equip_new_if_possible(/obj/item/clothing/suit/gimmick/hotdog, SLOT_WEAR_SUIT)

		SPAWN(1 SECOND) // in case he loads before the alarmed case does. I love prefabs.
			for_by_tcl(case, /obj/displaycase)
				if (istype(case, /obj/displaycase/alarmed/super_store))
					RegisterSignal(case, COMSIG_DISPLAYCASE_ALARM, PROC_REF(crash_out))

	initializeBioholder()
		. = ..()
		bioHolder.age = 27
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "boxers"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		var/area/area = get_area(src)
		if(can_act(src, FALSE) && area?.active)
			if(!ON_COOLDOWN(src, "employee_talk", 20 SECONDS))
				talk_shit(area)

			if(!src.fired && !istype(src.wear_suit, /obj/item/clothing/suit/gimmick/hotdog) && !istype(src.wear_suit, /obj/item/clothing/suit/gimmick/pickle))
				src.fired = TRUE
				src.concerned = TRUE
				src.say("You think I was fucking joking? I'm totally fired now, asshole")

	proc/talk_shit(area/A)
		if(!src.concerned)
			if(istype(A, /area/super_store/backrooms))
				src.say(pick(
					"Oh yea. Just fucking walk into the employee area. Sure.", \
					"I don't care. Go wherever. Take a shit in the staff toilet.", \
					"Don't smash the display case in the backroom or I'm fucked.", \
					"You tryna kick back and smoke somethin?", \
					"You some kinda salvager or some shit?", \
					"Just don't steal the Mod. 00. Or it's my ass on the line." \
				))
			else
				src.say(pick(
					"Welcome to Debris-19 Gaming Super store.", \
					"Feel free to browse. Take a look around.", \
					"You can shoplift, I don't really care.", \
					"Man... how did I get here.", \
					"I love those ducks. They're so amusing.", \
					"I know what it looks like. But I've got big things coming soon.", \
					"If I don't wear this suit I'll be fired instantly. It's got a tracker.", \
					"I don't really remember when I started working here, or how.", \
					"You ever met my bro Bill?", \
					"You seen those salvagers round here?. Assholes blew my high.", \
					"Don't ask for the recalled cyalume swords. Bunch of suits came round and took em.", \
					"You from that big ass station? Man... Must be nice.", \
					"Sal don't let me play robustris on shift anymore. Fucking asshole." \
				))
		else
			src.say(pick(
				"Man. You've fucked us all. You're a real jerk.", \
				"THIS IS A PRIVATE DOMICILE! GET THE HELL OUT!", \
				"Mr Duckman is gonna fuck us up. Thanks, asshole.", \
				"How am I gonna explain this shit to Sal.", \
				"I'm so fired. All because of YOU.", \
				"I should beat your ass.", \
				"I got friends, bro. Friends that will gib your ass." \
			))

	proc/crash_out()
		if(src.concerned || !can_act(src))
			return
		src.say(pick(
			"BRO. WHAT THE FUCK DID YOU JUST DO!", \
			"Oh fuck. OH FUCK.", \
			"WE'RE SO FUCKED.", \
			"SAL IS GONNA KILL ME! FUCK!" \
		))
		src.concerned = TRUE

