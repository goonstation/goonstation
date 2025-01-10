
var/datum/magpie_manager/magpie_man = new
/datum/magpie_manager
	var/obj/npc/trader/salvager/magpie

	proc/setup()
		src.magpie = locate("M4GP13")


/obj/npc/trader/salvager
	name = "M4GP13 Salvage and Barter System"
	icon = 'icons/obj/trader.dmi'
	icon_state = "crate_dispenser"
	picture = "generic.png"
	angrynope = "Unable to process request."
	whotext = "I am the salvage reclamation and supply commissary.  In short I will provide goods in exchange for reclaimed materials and equipment."
	barter = TRUE
	currency = "Salvage Points"
	var/distribute_earnings = FALSE

	New()
		..()

		src.chat_text = new(null, src)

		for(var/sell_type in concrete_typesof(/datum/commodity/magpie/sell))
			src.goods_sell += new sell_type(src)

		for(var/buy_type in (concrete_typesof(/datum/commodity/magpie/buy) - concrete_typesof(/datum/commodity/magpie/buy/random_buy)))
			src.goods_buy += new buy_type(src)

		greeting= {"[src.name]'s light flash, and he states, \"Greetings, welcome to my shop. Please select from my available equipment.\""}

		sell_dialogue = "[src.name] states, \"There are several individuals in my database that are looking to procure goods."

		buy_dialogue = "[src.name] states,\"Please select what you would like to buy\"."

		successful_sale_dialogue = list("[src.name] states, \"Thank you for the business organic.\"",
			"[src.name], \"I am adding you to the Good Customer Database.\"")

		failed_sale_dialogue = list("[src.name] states, \"<ERROR> Item not in purchase database.\"",
			"[src.name] states, \"I'm sorry I currently have no interest in that item, perhaps you should try another trader.\"",
			"[src.name] starts making a loud and irritating noise. [src.name] states, \"Fatal Exception Error: Cannot locate item\"",
			"[src.name] states, \"Invalid Input\"")

		successful_purchase_dialogue = list("[src.name] states, \"Thank you for your business\".",
			"[src.name] states, \"Looking forward to future transactions\".")

		failed_purchase_dialogue = list("[src.name] states, \"I am sorry, but you currenty do not have enough funds to purchase this.\"",
			"[src.name] states, \"Funds not found.\"")

		pickupdialogue = "[src.name] states, \"Thank you for your business. Please come again\"."

		pickupdialoguefailure = "[src.name] states, \"I'm sorry, but you don't have anything to pick up\"."

	var/list/speakverbs = list("beeps", "boops")
	var/static/mutable_appearance/bot_speech_bubble = mutable_appearance('icons/mob/mob.dmi', "speech")
	var/bot_speech_color

	proc/speak(var/message, var/sing, var/just_float, var/just_chat)
		if (!message)
			return
		var/image/chat_maptext/chatbot_text = null
		if (src.chat_text && !just_chat)
			UpdateOverlays(bot_speech_bubble, "bot_speech_bubble")
			SPAWN(1.5 SECONDS)
				UpdateOverlays(null, "bot_speech_bubble")
			if(!src.bot_speech_color)
				var/num = hex2num(copytext(md5("[src.name][TIME]"), 1, 7))
				src.bot_speech_color = hsv2rgb(num % 360, (num / 360) % 10 + 18, num / 360 / 10 % 15 + 85)
			var/maptext_color
			if (sing)
				maptext_color ="#D8BFD8"
			else
				maptext_color = src.bot_speech_color
			chatbot_text = make_chat_maptext(src, message, "color: [maptext_color];")
			if(chatbot_text && src.chat_text && length(src.chat_text.lines))
				chatbot_text.measure(src)
				//hack until measure is unfucked
				chatbot_text.measured_height = 20
				for(var/image/chat_maptext/I in src.chat_text.lines)
					if(I != chatbot_text)
						I.bump_up(chatbot_text.measured_height)

		src.audible_message(SPAN_SAY("[SPAN_NAME("[src]")] [pick(src.speakverbs)], \"[message]\""), just_maptext = just_float, assoc_maptext = chatbot_text)
		playsound(src, 'sound/misc/talk/bottalk_1.ogg', 40, TRUE)

	sold_item(datum/commodity/C, obj/S, amount, mob/user as mob)
		. = ..()
		if(istype(C, /datum/commodity/magpie/buy))
			var/datum/commodity/magpie/buy/salvager_commodity = C
			. = round(salvager_commodity.price_check(S) * amount)

		if(istype(C, /datum/commodity/magpie/buy/random_buy))
			var/datum/commodity/magpie/buy/random_buy/RB = C
			RB.reroll_commodity()

		var/datum/antagonist/salvager/SA = user?.mind?.get_antagonist(ROLE_SALVAGER)
		if(SA)
			SA.salvager_points += .

		if(src.distribute_earnings && round(. * src.distribute_earnings / length(src.barter_customers)))
			var/portion = round(. * src.distribute_earnings / length(src.barter_customers))
			for(var/customer in barter_customers)
				src.barter_customers[customer] += portion
			. -= length(src.barter_customers) * portion

	attackby(obj/item/I, mob/user)
		var/scan_time = 1.8 SECONDS
		if(ON_COOLDOWN(src, "scanning", scan_time * 1.5))
			return

		. = appraise_text(I)

		animate_scanning(user, . ? "#FFFF00" : "#ff4400", scan_time)
		sleep(scan_time)
		src.speak(.)

	proc/appraise(obj/item/I)
		if(I.deconstruct_flags || isitem(I))
			var/datum/commodity/magpie/buy/salvager_commodity = most_applicable_trade(src.goods_buy, I)
			var/datum/commodity/magpie/sell/selling_commodity = most_applicable_trade(src.goods_sell, I)
			if(salvager_commodity)
				. = salvager_commodity.price_check(I)
				if(istype(I))
					. *= I.amount

				// Ensure that all items sell for less than what they can be purchased for
				// except for power sink because we want to buy AND sell it
				if(selling_commodity && !istype(salvager_commodity, /datum/commodity/magpie/buy/power_sink))
					var/buy_cost = selling_commodity.price
					if(istype(I))
						buy_cost *= I.amount
					if(. > buy_cost)
						. = min(., buy_cost * 0.8)


	proc/appraise_text(obj/item/I)
		. = appraise(I)
		if(.)
			if(prob(90))
				. = "Current market value is [.]."
			else
				if(prob(20))
					. = "[.] is the best I can do."
				else
					. = "[.]."
			if(src.distribute_earnings)
				if(prob(50))
					. += " [src.distribute_earnings*100]% of that will be distributed amongst the crew."
				else
					. += " [src.distribute_earnings*100]% will be shared."
		else
			if(prob(95))
				. = "Current market value is 0."
			else
				. = "No record of a buyer for [I]."

	barter_lookup(mob/M)
		. = M?.bioHolder?.Uid
		if(!.)
			. = ..()


/////////////////
// M4GP13 Trader
/////////////////

ABSTRACT_TYPE(/datum/commodity/magpie/buy)
/datum/commodity/magpie/buy

	proc/price_check(obj/item)
		. = src.price

		if(GET_COOLDOWN(item, "SALVAGER PART"))
			. = 5

	materials
		comname = "Processed Material Bar"
		comtype = /obj/item/material_piece
		desc_buy = "This forms the backbone of the salvage economy. We need it today and others will need it tomorrow."
		price = 10

		price_check(obj/O)
			. = ..()
			if(O?.material)
				if(O.material.getID() in list("slag", "glass"))
					. *= 0.4
				else if(O.material.getID() in list("char"))
					. *= 0.2

				if(O.material.getProperty("reflective") >= 7)
					. *= 1.3
				if(O.material.getProperty("radioactive") >= 5)
					. *= 1.3

				if(O.material.getProperty("density") >= 5)
					. *= 1.2
				if(O.material.getProperty("hard") >= 5)
					. *= 1.2
				if(O.material.getProperty("electrical") >= 5)
					. *= 1.2

	sheet
		comname = "Material Sheets"
		comtype = /obj/item/sheet
		desc_buy = "Metal to glass these are common building blocks of many salvaged goods."
		price = 1

	machine_frame
		comname = "Disassembled Frame"
		comtype = /obj/item/electronics/frame
		desc_buy = "Machinery and electronics are highly valued and will fetch a decent price.  Price subject to source and quality of product."
		price = 100

		price_check(obj/O)
			. = ..()
#ifdef SECRETS_ENABLED
			var/obj/item/electronics/frame/F = O

			var/path
			if(istype(F))
				if(F.deconstructed_thing)
					path = F.deconstructed_thing.type
				else
					path = F.store_type
			else
				path = O.type

			for(var/type in value_list)
				if(ispath(path, type))
					. += value_list[type]
					break
#endif

			. = source_adjustment(O, .)

		proc/source_adjustment(obj/O, value)
			. = value

			if(length(O.req_access))
				. += 75

			if( O.icon_state != "dbox_big")
				. /= 10
			else
				if(!GET_COOLDOWN(O,"OEM PART"))
					. *= 0.5
				if(!GET_COOLDOWN(O,"STATION"))
					. *= 0.8

	machine_frame/machine
		hidden = TRUE
		comtype = /obj/machinery

		source_adjustment(obj/O, value)
			. = value

			if(length(O.req_access))
				. += 75

			if(!GET_COOLDOWN(O,"OEM PART"))
				. *= 0.5
			if(!istype(get_area(O),/area/station))
				. *= 0.8

	machine_frame/machine/submachine
		hidden = TRUE
		comtype = /obj/submachine

	power_sink
		hidden = TRUE
		comtype = /obj/item/device/powersink/salvager

		price_check(obj/O)
			. = 0
			var/obj/item/device/powersink/salvager/sink = O
			if(istype(O))
				. =	round(( sink.power_drained / sink.max_power ) * 20000)

	robotics
		comname = "Robot Parts"
		comtype = /obj/item/parts/robot_parts
		desc_buy = "There are always a number of groups in need of some robot parts."
		price = 25

	telecrystal
		comname = "Telecrystal"
		comtype = /obj/item/raw_material/telecrystal
		desc = "Rare space-warping are highly valued and needed for continued salvaging operations."
		price = 200

	gemstone
		comname = "Gemstone"
		comtype = /obj/item/raw_material/gemstone
		desc = "A cornerstone of both jewelry and often specalty electronics.  There are always a buyer."
		price = 150


ABSTRACT_TYPE(/datum/commodity/magpie/buy/random_buy)
/datum/commodity/magpie/buy/random_buy
	var/list/targets = list()

	proc/reroll_commodity()
		if(length(targets))
			comtype = pick(targets)
			var/obj/object_type = comtype
			comname = initial(object_type.name)
			var/value = targets[comtype]
			price = value
			baseprice = value
			upperfluc = value * 0.10
			lowerfluc = value * -0.05
			targets -= comtype
		else
			comtype = null
			hidden = TRUE

	New()
		..()
		reroll_commodity()

ABSTRACT_TYPE(/datum/commodity/magpie/sell)
/datum/commodity/magpie/sell

	teleporter
		comname = "Handheld teleporter to Magpie"
		desc = "Recovered and repurposed teleportation technology.  It works most of the time."
		comtype = /obj/item/salvager_hand_tele
		price = 400

	helmet
		comname = "Combat Helm"
		desc = "Heavily modified combination of industrial and military combat headgear."
		comtype = /obj/item/clothing/head/helmet/space/industrial/salvager
		price = 250

	armor
		comname = "Combat armor"
		desc = "Heavily modified combination of industrial and military combat gear."
		comtype = /obj/item/clothing/suit/space/industrial/salvager
		price = 500

	arcwelder
		comname = "Arc Welder"
		desc = "A self-recharging handheld arc welder.  Weld some metal or arc some people."
		comtype = /obj/item/weldingtool/arcwelder
		price = 500

	caxe
		comname = "Crash axe"
		desc = "A light utility axe that can be serviced as a vicious weapon."
		comtype = /obj/item/crashaxe
		price = 400

	sledgehammer
		comname = "Sledgehammer"
		desc = "A classic means of manual demolition."
		comtype = /obj/item/breaching_hammer/salvager
		price = 500
		amount = 4

#ifdef SECRETS_ENABLED
	improved_zipgun
		comname = "Customized Zip gun"
		desc = "An improvised firearm made from other firearms.  Modified for field repair."
		comtype = /obj/item/gun/kinetic/zipgun/salvager
		price = 350
#endif

	shotgun
		comname = "Pump action shotgun"
		desc = "A salvaged and rebuilt pump action shotgun."
		comtype = /obj/item/gun/kinetic/pumpweapon/riotgun/salvager
		price = 1200
		amount = 6

	quadbarrel
		comname = "Four Letter Word"
		desc = "Built around a shotgun that couldn't be reclaimed, this weapon trades stability for versatility."
		comtype = /obj/item/gun/kinetic/sawnoff/quadbarrel
		price = 1200
		amount = 4

	flare_ammo
		comname = "12ga Flare Shells"
		comtype = /obj/item/ammo/bullets/flare
		desc = "Military-grade 12 gauge flare shells."
		price = 250

	makeshift_laser
		comname = "Makeshift Laser Rifle"
		desc = "A makeshift laser rifle outfitted with a tube and cell."
		comtype = /obj/item/gun/energy/makeshift/basic_salvager
		price = 650
		amount = 4

	rifle
		comname = "Survival Rifle"
		desc = "Semi-automatic rifle with easily convertible caliber. Starts in .22 caliber."
		comtype = /obj/item/gun/kinetic/survival_rifle
		price = 1000

	bullets_22
		comname = ".22 magazine"
		desc = "A small .22 magazine for kinetic firearms."
		comtype = /obj/item/ammo/bullets/bullet_22
		price = 200
		amount = 4

	bullets_22_hp
		comname = ".22 Hollow Point magazine"
		desc = "A small .22 HP magazine for kinetic firearms. Less penetration and more pain."
		comtype = /obj/item/ammo/bullets/bullet_22HP
		price = 500
		amount = 10

	rifle_9mm
		comname = "Rifle 9mm conversion"
		desc = "Survival rifle conversion kit to 9mm."
		comtype = /obj/item/survival_rifle_barrel/barrel_9mm
		price = 500
		amount = 10

	bullets_9mm
		comname = "9mm magazine"
		desc = "A handgun magazine with 9x19mm rounds."
		comtype = /obj/item/ammo/bullets/bullet_9mm
		price = 399
		amount = 10

#ifndef RP_MODE
	rifle_556
		comname = "Rifle 5.56x45 conversion"
		desc = "Survival rifle conversion kit to 5.56x45mm NATO."
		comtype = /obj/item/survival_rifle_barrel/barrel_556
		price = 969
#endif

	assault_mag
		comname = "Rifle magazine"
		desc = "A magazine of 5.56 rounds, an intermediate rifle cartridge."
		comtype =  /obj/item/ammo/bullets/assault_rifle
		price = 699
		amount = 10

	assault_mag_ap
		comname = "Armor Piercing Rifle magazine"
		desc = "A magazine of 5.56 AP rounds, an intermediate rifle cartridge."
		comtype =  /obj/item/ammo/bullets/assault_rifle/armor_piercing
		price = 850
		amount = 8

	pepper_nades
		comname = "Crowd Dispersal Grenades"
		desc = "A box of crowd dispersal grenades"
		comtype = /obj/item/storage/box/crowdgrenades
		price = 400
		amount = 4

	flash_n_smoke
		comname = "Grenade Pouch"
		desc = "Flashbang and smoke grenades."
		comtype = /obj/item/storage/grenade_pouch/salvager_distract
		price = 350
		amount = 6

#ifndef UNDERWATER_MAP
	pod_kinetic
		comname = "Ballistic System"
		comtype = /obj/item/shipcomponent/mainweapon/gun
		desc = "A pod-mounted kinetic weapon system."
		price = 3000
		amount = 3

	pod_40mm
		comname = "40mm Assault Platform"
		comtype = /obj/item/shipcomponent/mainweapon/artillery/lower_ammo
		desc = "A pair of pod-mounted ballistic launchers, fires explosive 40mm shells. Holds 6 shells."
		price = 5000
		amount = 3

	artillery_ammo
		comname = "40mm HE Ammunition"
		comtype = /obj/item/ammo/bullets/autocannon
		desc = "High explosive grenades, for the resupplement of artillery assault platforms."
		price = 1500
		amount = 2
#endif

	barbed_wire
		comname = "Barbed Wire"
		comtype = /obj/item/deployer/barricade/barbed/wire
		desc = "A coiled up length of barbed wire that can be used to make some kind of barricade."
		price = 400

#ifdef SECRETS_ENABLED
	shield
		comname = "Makeshift Riot Shield"
		desc = "A giant sheet of steel with a strap.  Not quite the acme of defense but it should do."
		comtype = /obj/item/salvager_shield
		price = 700

	shield_belt
		comname = "Shield Belt"
		comtype = /obj/item/storage/belt/powered/salvager
		desc = "Belt generates an energy field around the user.  Provides some enviromental protection as well."
		price = 1200
		amount = 4
#endif

	radiojammer
		comname = "Radio Jammer"
		comtype = /obj/item/radiojammer
		desc = "A device that can block radio transmissions around it.  Recovered from a syndicate vessel."
		price = 2000

#ifdef SECRETS_ENABLED
	door_hacker
		comname = "Door Hacker Assistant"
		comtype = /obj/item/door_hacker
		desc = "A device that when connected to a door panel will determine the function of each wire."
		price = 100
#endif

	power_sink
		comname = "Power Sink and Storage"
		comtype = /obj/item/device/powersink/salvager
		desc = "A device that can be used to drain power and sell it back to the M4GP13."
		price = 1000
		amount = 6

	crank
		comname = "Crank (5x pills)"
		comtype = /obj/item/storage/pill_bottle/crank
		desc = "A cheap and dirty stimulant drug."
		price = 50

	meth
		comname = "Meth (5x pills)"
		comtype = /obj/item/storage/pill_bottle/methamphetamine
		desc = "A highly effective and dangerous stimulant drug."
		price = 350

	salvager
		comname = "Salvage Reclaimer"
		desc = "Replacement salvage reclaimer.  Sometimes you lose things and sometimes people take things..."
		comtype = /obj/item/salvager
		price = 100

	decon
		comname = "Deconstructor"
		desc = "Replacement deconstructor.  Sometimes you lose things and sometimes people yeet them into space..."
		comtype = /obj/item/deconstructor
		price = 10

	omnitool
		comname = "Omnitool"
		desc = "Replacement omnitool.  No one wants to carry around each tool individually."
		comtype = /obj/item/tool/omnitool
		price = 100
		amount = 6

	comm_upgrade
		comname = "Radio channel upgrade"
		desc = "Key to retrofit an existing headset to support Salvager frequencies."
		comtype = /obj/item/device/radio_upgrade/salvager
		price = 10

	salvager_goggles
		comname = "Salvager Goggles"
		desc = "Salvager Appraisal Visualizer. Provides a rough estimate of the value of things nearby."
		comtype = /obj/item/clothing/glasses/salvager
		price = 50

	telecrystal
		comname = "Telecrystal"
		comtype = /obj/item/raw_material/telecrystal
		desc = "Rare space-warping are highly valued and needed for continued salvaging operations."
		price = 225

ABSTRACT_TYPE(/datum/commodity/magpie/special/sell/arms)
/datum/commodity/magpie/special/sell/arms
	pistol
		comname = "9mm pistol"
		desc = "A rare semi-automatic 9mm pistol that was collected from an military vessel."
		comtype = /obj/item/gun/kinetic/pistol
		price = 1650
		amount = 4

	pulse_rifle
		comname = "Pulse Rifle"
		desc = "A sleek energy rifle. Often kept under lock and key at nanotrasen facilities."
		comtype = /obj/item/gun/energy/pulse_rifle
		price = 1800
		amount = 6

	breaching_charge
		comname = "Thermite Breaching Charge"
		desc = "A self-contained thermite breaching charge, useful for destroying walls."
		comtype = /obj/item/breaching_charge/thermite
		price = 500
		amount = 4

#ifdef RP_MODE
	rifle_556
		comname = "Rifle 5.56x45 conversion"
		desc = "Survival rifle conversion kit to 5.56x45mm NATO."
		comtype = /obj/item/survival_rifle_barrel/barrel_556
		price = 969
#endif

ABSTRACT_TYPE(/datum/commodity/magpie/special/sell/pirate)
/datum/commodity/magpie/special/sell/pirate
	rifle
		comname = "Replica Flintlock Rifle"
		desc = "Flintlock rifle and 15 rounds of ammunition provided in a specialised satchel."
		comtype = /obj/item/storage/backpack/satchel/flintlock_rifle_satchel
		price = 550
		amount = 5

	pistol
		comname = "Replica flintlock pistols"
		desc = "A set of two flintlock pistols and 15 rounds of ammunition."
		comtype = /obj/item/storage/backpack/satchel/flintlock_pistol_satchel
		price = 750
		amount = 4

	sabre
		comname = "Replica Pirate's Sabre"
		desc = "A sharp sabre for the most feared of all space pirates. Being you of course."
		comtype = /obj/item/swords_sheaths/pirate
		price = 650
		amount = 3


ABSTRACT_TYPE(/datum/commodity/magpie/special/buy/pirate)
/datum/commodity/magpie/special/buy/pirate

	proc/price_check(obj/item)
		. = src.price
	bullion
		comname = "Stamped Gold Bullion"
		comtype = /obj/item/stamped_bullion
		price = 1000

