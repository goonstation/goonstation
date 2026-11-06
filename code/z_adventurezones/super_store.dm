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
	sizex = 1758
	sizey = 1243

/obj/item/paper/super_store1
	name = "scribbled note"
	info = "Hey Sal.<br> \
			Some guys came by asking about the Cyalume replica swords again. They wanted to place a bulk order of the 2050 model in red color. \
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

