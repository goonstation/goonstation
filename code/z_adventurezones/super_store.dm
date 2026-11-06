// discount gaming store prefab

// areas
/area/super_store
	name = "Debris-19 X-treme Gaming Superstore"
	icon_state = "blue"
	sound_environment = 11

/area/super_store/hangar
	name = "Debris-19 Parking"
	icon_state = "red"

/area/super_store/backrooms
	name = "Debris-19 Employee Area"
	icon_state = "purple"

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
