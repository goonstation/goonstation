/datum/trader/sobb
	// Mostly-friendly neighborhood blob.
	// Interested in medical stuff and food. Honest and laid-back, but tends to not be very clear about what it has/wants.
	name = "Sobb"
	picture = "Sobb/sobb_green.png"
	crate_tag = "Sobb"
	hiketolerance = 40
	base_patience = list(20,35)
	chance_leave = 20
	chance_arrive = 10
	chance_restock = 25

	base_goods_buy = alist(
		TRADER_RARITY_COMMON = list(
			/datum/commodity/trader/sobb/honey
		),
		TRADER_RARITY_UNCOMMON = list(
			/datum/commodity/trader/sobb/digestion,
			/datum/commodity/trader/sobb/bot
		),
		TRADER_RARITY_RARE = list()
	)

	base_goods_sell = alist(
		TRADER_RARITY_COMMON = list(
			/datum/commodity/trader/sobb/chunk
		),
		TRADER_RARITY_UNCOMMON = list(
			/datum/commodity/trader/sobb/remains
		),
		TRADER_RARITY_RARE = list()
	)

	dialogue_greet = list("Grootings multicellular being. Would you like to trude?",
	"Hello many-cells. Reudy to trude?",
	"Do your cells want to buy somethung?")
	dialogue_leave = list("Moybe next time.",
	"Foolish multicellular thing.",
	"One cell is better than mony cells.")
	dialogue_purchase = list("Hopefully many-cells can use ut.",
	"Huppy to holp!",
	"Pleasure doing busuness with all of your cells.")
	dialogue_haggle_accept = list("This is acooptable.",
	"Faur enough. Is ut a deul?",
	"*bubbly noises*.",
	"...okuy.",
	"Do deul now?")
	dialogue_haggle_reject = list("That os too much.",
	"That os out of my pruce runge.",
	"Too much for me.",
	"NO. NO. NO.",
	"I'd loke to do deul now.")
	dialogue_wrong_haggle_accept = list("If that's what you wunt.")
	dialogue_wrong_haggle_reject = list("Allow me to clurify the prusing.")
	dialogue_cant_afford_that = list("Not enough credots to moke tronsoctuon.",
	"Ploase ruturn with more credots.",
	"Account needs more stuff for trude.")
	dialogue_out_of_stock = list("Sorry, I need to fond more of that.",
	"That os out-of-stock for now.")

	New()
		. = ..()
		var/datum/material/organic/blob/sobb/sobb_material = getMaterial("blob_sobb")
		var/color_sobb = sobb_material.color_rgb
		var/list/color_hsl = rgb2hsl(GetRedPart(color_sobb), GetGreenPart(color_sobb), GetBluePart(color_sobb))
		var/hue = color_hsl[1] / 360
		var/saturation = color_hsl[2] // 0 to 100
		var/luminosity = color_hsl[3] // 0 to 100
		if(saturation < 20)
			if(luminosity < 33)
				src.picture = "Sobb/sobb_black.png"
			else if(luminosity > 66)
				src.picture = "Sobb/sobb_white.png"
			else
				src.picture = "Sobb/sobb_gray.png"
		else
			if(hue < 0.05)
				src.picture = "Sobb/sobb_red.png"
			else if(hue < 0.14)
				src.picture = "Sobb/sobb_orange.png"
			else if(hue < 0.25)
				src.picture = "Sobb/sobb_yellow.png"
			else if(hue < 0.37)
				src.picture = "Sobb/sobb_green.png"
			else if(hue < 0.55)
				src.picture = "Sobb/sobb_cyan.png"
			else if(hue < 0.68)
				src.picture = "Sobb/sobb_blue.png"
			else if(hue < 0.87)
				src.picture = "Sobb/sobb_purple.png"
			else
				src.picture = "Sobb/sobb_red.png"

// Sobb is selling these things

/datum/commodity/trader/sobb/chunk
	comname = "Chunk of Sobb"
	comtype = /obj/item/material_piece/wad/blob/sobb
	amount = 25
	price_boundary = list(PAY::TRADESMAN, PAY::TRADESMAN * 3)
	possible_names = list("Sellung some excess me. Organelles not oncludod.",
	"Cytoplasm avaoloble for purchose. Strong and savory.",
	"Need to lose weight. Contact if you aru lookung to buy it.")

/datum/commodity/trader/sobb/remains
	comname = "Undugested Remauns"
	comtype = /obj/sobb_remains_spawner
	amount = 25
	price_boundary = list(PAY::UNTRAINED * 2, PAY::UNTRAINED * 3)
	possible_names = list("Loftover junk from dunner.",
	"Lookung to get rud of stuff that dudn't dissolve well.")

/obj/sobb_remains_spawner
	var/list/spawns_random = list(
		/obj/item/material_piece/bone = 350,
		/obj/item/skull = 70,
		/obj/item/raw_material/chitin = 50,
		/obj/item/mining_tool/powered/drill = 10,
		/obj/item/mining_tool/powered/shovel = 10,
		/obj/item/mining_tool/powered/hammer = 10,
		/obj/item/cargotele = 10,
		/obj/item/device/analyzer/healthanalyzer = 10,
		/obj/item/device/analyzer/genetic = 10,
		/obj/item/device/analyzer/atmospheric = 10,
		/obj/item/device/light/flashlight = 10,
		/obj/item/device/gps = 10,
		/obj/item/crowbar = 10,
		/obj/item/wrench = 10,
		/obj/item/wirecutters = 10,
		/obj/item/screwdriver = 10,
		/obj/item/implant/health = 3,
		/obj/item/implant/tracking = 3,

		/obj/item/parts/robot_parts/arm/left/standard = 10,
		/obj/item/parts/robot_parts/arm/left/light = 10,
		/obj/item/parts/robot_parts/arm/right/standard = 10,
		/obj/item/parts/robot_parts/arm/right/light = 10,
		/obj/item/parts/robot_parts/leg/left/standard = 10,
		/obj/item/parts/robot_parts/leg/left/light = 10,
		/obj/item/parts/robot_parts/leg/right/standard = 10,
		/obj/item/parts/robot_parts/leg/right/light = 10,
		/obj/item/organ/appendix/cyber = 10,
		/obj/item/organ/heart/cyber = 10,
		/obj/item/organ/intestines/cyber = 10,
		/obj/item/organ/kidney/cyber/left = 10,
		/obj/item/organ/kidney/cyber/right = 10,
		/obj/item/organ/liver/cyber = 10,
		/obj/item/organ/lung/cyber/left = 10,
		/obj/item/organ/lung/cyber/right = 10,
		/obj/item/organ/pancreas/cyber = 10,
		/obj/item/organ/spleen/cyber = 10,
		/obj/item/organ/stomach/cyber = 10,
		/obj/item/organ/eye/glass = 5,
		/obj/item/organ/eye/cyber = 5,
		/obj/item/organ/eye/cyber/sechud = 2,
		/obj/item/organ/eye/cyber/nightvision = 2,
		/obj/item/organ/eye/cyber/meson = 2,
		/obj/item/organ/eye/cyber/thermal = 2,
		/obj/item/organ/eye/cyber/laser = 1,
		/obj/item/organ/eye/cyber/ecto = 1,
	)
	New()
		. = ..()
		var/pick_type = weighted_pick(spawns_random)
		var/atom/thing = new pick_type(src.loc)
		thing.pixel_x = rand(-8, 8)
		thing.pixel_y = rand(-8, 8)
		qdel(src)

// Sobb wants these things

/datum/commodity/trader/sobb/honey
	comname = "Honoy"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/honey
	price_boundary = list(PAY::UNTRAINED, PAY::UNTRAINED * 2)
	possible_names = list("Bee food. Stucks to thungs, but somehow does not stuck to Sobb.",
	"Buyung dulicious bee blob. Good for cytoplasm.")

/datum/commodity/trader/sobb/digestion
	comname = "Dugestive Organ"
	comtype = null
	possible_alt_types = list(
		/obj/item/organ/stomach,
		/obj/item/organ/intestines
	)
	alt_type_chance = 100
	price_boundary = list(PAY::TRADESMAN, PAY::TRADESMAN * 2)
	possible_names = list("The organelle humons use for dugesting food.")

/datum/commodity/trader/sobb/bot
	comname = "Bot-thingie"
	comtype = null
	possible_alt_types = list(
		/obj/machinery/bot/cleanbot,
		/obj/machinery/bot/firebot,
		/obj/machinery/bot/medbot
	)
	alt_type_chance = 100
	price_boundary = list(PAY::TRADESMAN, PAY::DOCTORATE * 2)
	possible_names = list("Need that bot-thung that does stuff for you. Know whuch one?",
	"Lookung for that bot-thung, the one that I sow before.")
