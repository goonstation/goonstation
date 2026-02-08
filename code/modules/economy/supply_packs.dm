
/proc/build_supply_pack_cache()
	qm_supply_cache.Cut()
	for(var/S in concrete_typesof(/datum/supply_packs))
		qm_supply_cache += new S()

/datum/supply_order
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/comment = null
	var/used_personal_funds = FALSE
	var/address = null
	var/console_location = null

	proc/create(var/mob/orderer)
		var/obj/storage/S = object.create(orderer)

		var/show_purchaser = !isnull(src.orderedby) && src.used_personal_funds
		S.name = "[S.name][show_purchaser ? " (Purchased by [src.orderedby])" : ""][src.comment ? " ([src.comment])" : "" ]"

		if(src.comment)
			S.delivery_destination = src.comment

		object.exhaustion += 1
		if(object.exhaustion > 10)
			object.cost = round(object.cost*(1+object.exhaustion/50))

		return S

//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
ABSTRACT_TYPE(/datum/supply_packs)
/datum/supply_packs
	var/name = null
	var/desc = null
	var/list/contains = list()
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/category = "Miscellaneous"
	var/access = null
	var/hidden = 0	//So as it turns out this is used in construction mode hardyhar
	var/syndicate = 0 //If this is one the crate will only show up when the console is emagged
	var/id = 0 //What jobs can order it
	var/whos_id = null //linked ID
	var/basecost // the original cost
	///This value will be used to increase the price of the supply pack if it's bought too many times.
	var/exhaustion = 0

	New()
		. = ..()
		basecost = cost

	proc/create(var/mob/creator)
		var/obj/storage/S
		if (!ispath(containertype) && length(contains) > 1)
			containertype = text2path(containertype)
			if (!ispath(containertype))
				containertype = /obj/storage/crate // this did not need to be a string

		if (ispath(containertype))
#ifdef HALLOWEEN
			if (halloween_mode && prob(10))
				S = new /obj/storage/crate/haunted
			else
				S = new containertype
#else
			S = new containertype
#endif
			if (S)
				if (containername)
					S.name = containername

				if (access && istype(S))
					S.req_access = list()
					S.req_access += text2num(access)

		if (contains.len)
			for (var/B in contains)
				var/thepath = B
				if (!ispath(thepath))
					thepath = text2path(B)
					if (!ispath(thepath))
						continue

				var/amt = 1
				if (isnum(contains[B]))
					amt = abs(contains[B])

				for (amt, amt>0, amt--)
					var/atom/thething = new thepath(S)
					if (amount && isitem(thething))
						var/obj/item/I = thething
						I.amount = amount
		return S

/datum/supply_packs/emptycrate
	name = "Empty Crate"
	desc = "x1 Empty Crate."
	contains = list()
	cost = PAY_UNTRAINED/10
	containertype = /obj/storage/crate
	containername = "crate"

/datum/supply_packs/specialops
	name = "Special Ops Supplies"
	desc = "x1 Holographic Disguiser, x1 Signal Jammer, x1 Agent Card, x1 EMP Grenade Kit, x1 Tactical Grenades Kit."
	contains = list(/obj/item/card/id/syndicate,
					/obj/item/storage/box/emp_kit,
					/obj/item/storage/box/tactical_kit,
					/obj/item/device/disguiser,
					/obj/item/radiojammer)
	cost = PAY_EMBEZZLED*2
	containertype = /obj/storage/crate
	containername = "Special Ops Crate"
	syndicate = 1

/datum/supply_packs/paint
	name = "Artistic Supplies Crate"
	desc = "x5 Random Paints, x1 Artistic Toolbox. Get arty!"
	contains = list(/obj/item/paint_can/totally_random = 5, /obj/item/storage/toolbox/artistic)
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate/packing
	containername = "Artistic Crate"

/datum/supply_packs/neon_lining
	name = "Neon Lining Crate"
	desc = "x20 Neon Linings. x1 Installation Instructions. For intellectuals that value the aesthetic of the past."
	contains = list(/obj/item/neon_lining/shipped, /obj/item/paper/neonlining)
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate
	containername = "Neon Lining Crate"

/datum/supply_packs/metal200
	name = "200 Metal Sheets"
	desc = "x200 Metal Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/steel)
	amount = 200
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate
	containername = "Metal Sheets Crate - 200 pack"

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	desc = "x50 Metal Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/steel)
	amount = 50
	cost = PAY_TRADESMAN
	containertype = /obj/storage/crate
	containername = "Metal Sheets Crate - 50 pack"

/datum/supply_packs/glass200
	name = "200 Glass Sheets"
	desc = "x200 Glass Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/glass)
	amount = 200
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate
	containername = "Glass Sheets Crate - 200 pack"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	desc = "x50 Glass Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/glass)
	amount = 50
	cost = PAY_TRADESMAN
	containertype = /obj/storage/crate
	containername = "Glass Sheets Crate - 50 pack"

/datum/supply_packs/wood10
	name = "10 Wooden Sheets"
	desc = "x10 Wooden Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/wood)
	amount = 10
	cost = PAY_TRADESMAN
	containertype = /obj/storage/crate/wooden
	containername = "Wooden Sheets Crate - 10 pack"

/datum/supply_packs/wood50
	name = "50 Wooden Sheets"
	desc = "x50 Wooden Sheets."
	category = "Basic Materials"
	contains = list(/obj/item/sheet/wood)
	amount = 50
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate/wooden
	containername = "Wooden Sheets Crate - 50 pack"

/datum/supply_packs/dryfoods
	name = "Catering: Dry Goods Crate"
	desc = "x25 Assorted Cooking Ingredients."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/ingredient/flour = 6,
					/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/sugar = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 2)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Dry Goods Crate"

/datum/supply_packs/meateggdairy
	name = "Catering: Meat, Eggs and Dairy Crate"
	desc = "x25+ Assorted Cooking Ingredients."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/hotdog = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/cheese = 4,
					/obj/item/reagent_containers/food/drinks/milk = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/salmon,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet/white,
					/obj/item/item_box/anchovy,
					/obj/item/kitchen/egg_box = 3,
					/obj/item/storage/box/bacon_kit = 2)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Meat, Eggs and Dairy Crate"

/datum/supply_packs/produce
	name = "Catering: Fresh Produce Crate"
	desc = "x20 Assorted Cooking Ingredients."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/plant/apple = 2,
					/obj/item/reagent_containers/food/snacks/plant/banana = 2,
					/obj/item/reagent_containers/food/snacks/plant/carrot = 2,
					/obj/item/reagent_containers/food/snacks/plant/corn = 2,
					/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
					/obj/item/reagent_containers/food/snacks/plant/lettuce = 2,
					/obj/item/reagent_containers/food/snacks/plant/tomato = 3,
					/obj/item/reagent_containers/food/snacks/plant/potato = 2,
					/obj/item/reagent_containers/food/snacks/plant/onion,
					/obj/item/reagent_containers/food/snacks/plant/lime,
					/obj/item/reagent_containers/food/snacks/plant/lemon,
					/obj/item/reagent_containers/food/snacks/plant/orange)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Fresh Produce Crate"

/datum/supply_packs/condiment
	name = "Catering: Condiment Crate"
	desc = "x25 Assorted Cooking Ingredients."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/condiment/chocchips = 3,
					/obj/item/reagent_containers/food/snacks/condiment/cream = 2,
					/obj/item/reagent_containers/food/snacks/condiment/custard,
					/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 3,
					/obj/item/reagent_containers/food/snacks/condiment/ketchup = 4,
					/obj/item/reagent_containers/food/snacks/condiment/mayo = 4,
					/obj/item/reagent_containers/food/snacks/condiment/syrup = 2,
					/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 2,
					/obj/item/reagent_containers/food/snacks/ingredient/honey = 2,
					/obj/item/reagent_containers/food/snacks/ingredient/vanilla_extract = 2)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Condiment Crate"

/datum/supply_packs/electrical
	name = "Electrical Supplies Crate (red) - 2 pack"
	desc = "x2 Cabling Boxes - red. (14 cable coils total)"
	contains = list(/obj/item/storage/box/cablesbox = 2)
	containername = "Electrical Supplies Crate - 2 pack"
	category = "Basic Materials"
	cost = PAY_DOCTORATE*4
	containertype = /obj/storage/crate

/datum/supply_packs/engineering
	name = "Engineering Crate"
	desc = "x2 Mechanical Toolboxes, x2 Welding Masks, x2 Insulated Coats."
	category = "Engineering Department"
	contains = list(/obj/item/storage/toolbox/mechanical/orange_tools = 2,
					/obj/item/clothing/head/helmet/welding = 2,
					/obj/item/clothing/suit/wintercoat/engineering = 2)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate
	containername = "Engineering Crate"

/datum/supply_packs/electool
	name = "Electrical Maintenance Crate"
	desc = "x2 Electrical Toolboxes, x2 Multi-Tools, x2 Insulated Gloves."
	category = "Engineering Department"
	contains = list(/obj/item/storage/toolbox/electrical/orange_tools = 2,
					/obj/item/device/multitool/orange = 2,
					/obj/item/clothing/gloves/yellow = 2)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate
	containername = "Electrical Maintenance Crate"

/datum/supply_packs/powercell
	name = "Power Cell Crate"
	desc = "x3 Power Cells."
	category = "Engineering Department"
	contains = list(/obj/item/cell/charged = 3)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate
	containername = "Power Cell Crate"

/datum/supply_packs/firefighting
	name = "Firefighting Supplies Crate"
	desc = "x3 Extinguishers, x3 Firefighting Grenades, x2 Firesuits, x2 Firefighter Helmets."
	category = "Engineering Department"
	contains = list(/obj/item/extinguisher = 3,
	/obj/item/chem_grenade/firefighting = 3,
	/obj/item/clothing/suit/hazard/fire = 2,
	/obj/item/clothing/head/helmet/firefighter = 2)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Firefighting Supplies Crate"

/datum/supply_packs/engineering_grenades
	name = "Station Pressurization Crate"
	desc = "x4 Red Oxygen Grenades, x4 Metal Foam Grenades."
	category = "Engineering Department"
	contains = list(/obj/item/old_grenade/oxygen = 4, /obj/item/chem_grenade/metalfoam = 4)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Station Pressurization Crate"

/datum/supply_packs/disposal_pipe_cart
	name = "Disposal Pipe Dispenser Cart"
	desc = "x1 Mobile Pipe Dispenser. Has a pesky staff assistant stolen your cart?"
	category = "Engineering Department"
	contains = list(/obj/machinery/disposal_pipedispenser/mobile)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Replacement Disposal Cart Crate"

/datum/supply_packs/gas_filtration
	name = "Gas Filtration Machinery"
	desc = "x1 Portable Air Pump, x1 Portable Air Scrubber."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/scrubber, /obj/machinery/portable_atmospherics/pump)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Filtration Machinery Crate"

/datum/supply_packs/generator
	name = "Experimental Local Generator"
	desc = "x1 Experimental Local Generator."
	category = "Engineering Department"
	contains = list(/obj/machinery/power/lgenerator)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Experimental Local Generator Crate"

/datum/supply_packs/combustion_generator
	name = "Portable Combustion Generator"
	desc = "x1 Portable Generator, x1 Empty Fuel Tank."
	category = "Engineering Department"
	contains = list(/obj/machinery/power/combustion_generator,
					/obj/item/reagent_containers/food/drinks/fueltank/empty)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate/wooden
	containername = "Portable Combustion Generator"

/datum/supply_packs/medicalfirstaid
	name = "Medical: First Aid Crate"
	desc = "x10 Assorted First Aid Kits"
	category = "Medical Department"
	contains = list(/obj/item/storage/firstaid/regular = 2,
					/obj/item/storage/firstaid/brute = 2,
					/obj/item/storage/firstaid/fire = 2,
					/obj/item/storage/firstaid/toxin = 2,
					/obj/item/storage/firstaid/oxygen,
					/obj/item/storage/firstaid/brain)
	cost = PAY_DOCTORATE*3
	containertype = /obj/storage/crate/medical
	containername = "Medical: First Aid Crate"

/datum/supply_packs/medicalchems
	name = "Medical: Medical Reservoir Crate"
	desc = "x4 Assorted Reservoir Tanks, x2 Sedative Bottles, x2 Hyposprays, x1 Auto-mender, x2 Brute Auto-mender Refill Cartridges, x2 Burn Auto-mender Refill Cartridges, x1 Syringe Kit."
	category = "Medical Department"
	contains = list(/obj/item/reagent_containers/glass/beaker/large/antitox,
					/obj/item/reagent_containers/glass/beaker/large/epinephrine,
					/obj/item/reagent_containers/food/drinks/reserve/brute,
					/obj/item/reagent_containers/food/drinks/reserve/burn,
					/obj/item/reagent_containers/glass/bottle/morphine = 2,
					/obj/item/reagent_containers/mender,
					/obj/item/reagent_containers/mender_refill_cartridge/brute = 2,
					/obj/item/reagent_containers/mender_refill_cartridge/burn = 2,
					/obj/item/reagent_containers/hypospray = 2,
					/obj/item/storage/box/syringes)
	cost = PAY_DOCTORATE*3
	containertype = /obj/storage/crate/medical
	containername = "Medical Crate"

/datum/supply_packs/complex/glass_recycler
	name = "Glass Recycler"
	desc = "x1 Glass Recycler, x1 Soldering Iron."
	category = "Civilian Department"
	contains = list(/obj/item/electronics/soldering)
	frames = list(/obj/machinery/glass_recycler)
	cost = PAY_TRADESMAN*2
	containertype =/obj/storage/crate
	containername = "Recycling Initiative Crate"

/datum/supply_packs/janitor
	name = "Janitorial Supplies"
	desc = "x3 Buckets, x3 Mop, x3 Wet Floor Signs, x3 Cleaning Grenades, x1 Mop Bucket, x1 Rubber Gloves"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/glass/bucket = 3,
					/obj/item/mop = 3,
					/obj/item/caution = 3,
					/obj/item/chem_grenade/cleaner = 3,
					/obj/mopbucket,
					/obj/item/clothing/gloves/long)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Janitorial Supplies"

/datum/supply_packs/janitor_sprayer
	name = "WA-V3 Janitorial Sprayer"
	desc = "x1 Wide Area V3 Cleaning Device, x1 WA-V3 Back Tank."
	category = "Civilian Department"
	containertype = /obj/storage/crate
	containername = "WA-V3 Crate"
	cost = PAY_TRADESMAN * 15 //pricy
	contains = list(
		/obj/item/gun/sprayer,
		/obj/item/reagent_containers/glass/backtank
	)

/datum/supply_packs/hydronutrient
	name = "Hydroponics: Nutrient Crate"
	desc = "x1 Saltpetre Jug, x1 Ammonia Jug, x1 Potash Jug, x1 Mutadone Jug, x1 Unstable Mutagen Jug."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/glass/jug/saltpetrebulk,
					/obj/item/reagent_containers/glass/jug/ammoniabulk,
					/obj/item/reagent_containers/glass/jug/potashbulk,
					/obj/item/reagent_containers/glass/jug/mutadonebulk,
					/obj/item/reagent_containers/glass/jug/mutagenicbulk)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Hydroponics: Nutrient Crate"

/datum/supply_packs/mining
	name = "Mining Equipment"
	desc = "x1 Powered Pickaxe, x1 Power Hammer, x1 Optical Meson Scanner, x1 Geological Scanner, x2 Mining Satchels, x3 Mining Explosives."
	category = "Engineering Department"
	contains = list(/obj/item/mining_tool/powered/pickaxe,
					/obj/item/mining_tool/powered/hammer,
					/obj/item/clothing/glasses/toggleable/meson,
					/obj/item/oreprospector,
					/obj/item/satchel/mining = 2,
					/obj/item/breaching_charge/mining = 3)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/secure/crate/plasma
	containername = "Mining Equipment Crate"
	access = null

/datum/supply_packs/monkey4
	name = "Lab Monkey Crate - 4 pack"
	desc = "x4 Monkeys, x1 Monkey Translator."
	category = "Research Department"
	contains = list(/mob/living/carbon/human/npc/monkey = 4,
						/obj/item/clothing/mask/monkey_translator)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/secure/crate/medical/monkey
	containername = "Lab Monkey Crate"
	hidden = 1

/datum/supply_packs/monkey_restock
	name = "ValuChimp Restock cartridge"
	desc = "x1 Valuchimp Restock Cartridge. Every chef's dream! Or a nightmare. Depends."
	category = "Civilian Department"
	contains = list(/obj/item/vending/restock_cartridge/monkey)
	cost = PAY_DOCTORATE*3
	containertype = /obj/storage/crate
	containername = "ValuChimp restock crate"
	hidden = 1

/datum/supply_packs/bee
	name = "Honey Production Kit"
	desc = "x5 Bee Eggs. For use with existing hydroponics bay."
	category = "Civilian Department"
	contains = list(/obj/item/bee_egg_carton = 5)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/bee
	containername = "Honey Production Kit"
	create(var/sp, var/mob/creator)
		var/obj/storage/secure/crate/bee/beez=..()
		for(var/obj/item/bee_egg_carton/carton in beez)
			carton.ourEgg.blog = "ordered by [key_name(creator)]|"
		return beez

/datum/supply_packs/sheep
	name = "Wool Production Kit"
	desc = "x1 Sheep egg, x1 Knitting kit. For use with existing Ranch."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/sheep, /obj/item/storage/box/knitting)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Wool Production Kit"


/datum/supply_packs/ranch_egg_cartons
	name = "Empty Egg Cartons"
	desc = "x5 Egg cartons. For use with existing Ranch."
	category = "Civilian Department"
	contains = list(/obj/item/kitchen/egg_box/empty = 5)
	cost = PAY_TRADESMAN*1
	containertype = /obj/storage/crate
	containername = "Empty Egg Cartons"

/datum/supply_packs/fishing
	name = "Angling Starter Kit"
	desc = "x1 Aquatic Research Upload Terminal, x1 Fishing Supplies Vendor, x1 Aquatic Research Pool, x1 Wrench, x1 Basic Fishing Rod. A full complement of fishing tools for the amateur angler."
	category = "Civilian Department"
	contains = list(/obj/item/fishing_rod/basic,
					/obj/item/wrench,
					/obj/submachine/fishing_upload_terminal/portable,
					/obj/submachine/weapon_vendor/fishing/portable,
					/obj/fishing_pool/portable)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Angling Starter Kit"

/datum/supply_packs/chemical
	name = "Chemistry Resupply Crate"
	desc = "x6 Reagent Bottles, x1 Beaker Box, x1 Mechanical Dropper, x1 Spectroscopic Goggles, x1 Reagent Scanner."
	category = "Research Department"
	contains = list(/obj/item/storage/box/beakerbox,
					/obj/item/reagent_containers/glass/bottle/oil,
					/obj/item/reagent_containers/glass/bottle/phenol,
					/obj/item/reagent_containers/glass/bottle/acid,
					/obj/item/reagent_containers/glass/bottle/acetone,
					/obj/item/reagent_containers/glass/bottle/diethylamine,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/dropper/mechanical,
					/obj/item/clothing/glasses/spectro,
					/obj/item/device/reagentscanner)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/secure/crate/plasma
	containername = "Chemistry Resupply Crate"


// Added security resupply crate (Convair880).
/datum/supply_packs/security_resupply
	name = "Weapons Crate - Security Assistant Equipment (Cardlocked \[Security Equipment])"
	desc = "x1 Security Assistant Requisition Token, x1 Armoured Vest, x1 Helmet, x1 Handcuff Kit."
	category = "Security Department"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/head/helmet/hardhat/security,
					/obj/item/requisition_token/security/assistant,
					/obj/item/storage/box/handcuff_kit)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/security_upgrade
	name = "Weapons Crate - Experimental Security Equipment (Cardlocked \[Security Equipment])"
	desc = "x1 Clock 180, x1 Elite Security Helmet, x1 Lethal Grenade Kit, x1 Experimental Grenade Kit, x1 Stasis Rifle."
	category = "Security Department"
	contains = list(/obj/item/gun/kinetic/clock_188/boomerang,
					/obj/item/storage/box/QM_grenadekit_security,
					/obj/item/storage/box/QM_grenadekit_experimentalweapons,
					/obj/item/clothing/head/helmet/hardhat/security/improved,
					/obj/item/gun/energy/stasis)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Experimental Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/security_brig_resupply
	name = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
	desc = "x1 Port-a-Brig and Remote."
	category = "Security Department"
	contains = list(/obj/machinery/port_a_brig,
					/obj/item/remote/porter/port_a_brig)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate/weapon
	containername = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons2
	name = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
	desc = "x2 Phaser Guns."
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_gun = 2)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate/weapon/sec_weapons
	containername = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons3
	name = "Weapons Crate - Micro Phasers (Cardlocked \[Security Equipment])"
	desc = "x4 Micro Phaser Guns."
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_small = 4)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate/weapon/sec_weapons
	containername = "Weapons Crate - Micro Phasers (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons4
	name = "Weapons Crate - Macro Phaser (Cardlocked \[Armory Equipment])"
	desc = "x1 Macro Phaser Gun."
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_huge = 1)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/secure/crate/weapon/armory
	containername = "Weapons Crate - Macro Phaser (Cardlocked \[Armory Equipment])"
	access = access_armory

/datum/supply_packs/weapons5
	name = "Weapons Crate - Phaser SMGs (Cardlocked \[Security Equipment])"
	desc = "x2 Phaser SMGs."
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_smg = 2)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate/weapon/sec_weapons
	containername = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/evacuation
	name = "Emergency Equipment"
	desc = "x4 Floor Bots, x4 Oxygen Tanks, x4 Gas Mask, x4 Emergency Space Suit Sets."
	contains = list(/obj/machinery/bot/floorbot = 4,
	/obj/item/clothing/mask/gas = 4,
	/obj/item/tank/mini/oxygen = 4,
	/obj/item/tank/air = 2,
	/obj/item/clothing/head/emerg = 4,
	/obj/item/clothing/suit/space/emerg = 4)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/internals
	containername = "Emergency Equipment"

/datum/supply_packs/alcohol
	name = "Alcohol Resupply Crate"
	desc = "x1 Beer, x1 Wine, x1 Mead, x1 Cider, x1 Rum, x1 Vodka, x1 Tequila, x1 Bo Jack Daniel's, x1 Curaçao, x1 Beer Box. In case of stationwide alcohol deficiency."
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/beer,
					/obj/item/reagent_containers/food/drinks/bottle/beer,
					/obj/item/reagent_containers/food/drinks/bottle/wine,
					/obj/item/reagent_containers/food/drinks/bottle/mead,
					/obj/item/reagent_containers/food/drinks/bottle/cider,
					/obj/item/reagent_containers/food/drinks/bottle/rum,
					/obj/item/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/reagent_containers/food/drinks/bottle/tequila,
					/obj/item/reagent_containers/food/drinks/bottle/bojackson,
					/obj/item/reagent_containers/food/drinks/curacao)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Alcohol Crate"

/datum/supply_packs/cocktailparty
	name = "Cocktail Party Supplies"
	desc = "x1 Cocktail Shaker, x2 Cocktail Umbrella Boxes, x2 Cocktail Doodads Boxes, x1 Fruit Wedges Box, x1 Salt Shaker. All you need to be the next up and coming amateur mixologist."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/drinks/cocktailshaker,
					/obj/item/storage/box/cocktail_umbrellas = 2,
					/obj/item/storage/box/cocktail_doodads = 2,
					/obj/item/storage/box/fruit_wedges = 1,
					/obj/item/shaker/salt = 1)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Cocktail Party Supplies"

/datum/supply_packs/robot
	name = "Robotics Crate"
	desc = "x1 Floorbot, x1 Cleanbot, x1 Medibot, x1 Firebot."
	category = "Medical Department"
	contains = list(/obj/machinery/bot/floorbot,
					/obj/machinery/bot/cleanbot,
					/obj/machinery/bot/medbot,
					/obj/machinery/bot/firebot)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Robotics Crate"

/datum/supply_packs/mulebot
	name = "Replacement Mulebot"
	desc = "x1 Mulebot."
	category = "Engineering Department"
	contains = list("/obj/machinery/bot/mulebot")
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Replacement Mulebot Crate"

/datum/supply_packs/dressup
	name = "Novelty Clothing Crate"
	desc = "x5+ Assorted Novelty Clothing."
	contains = list(/obj/random_item_spawner/dressup)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate/packing
	containername = "Novelty Clothing Crate"

#ifdef HALLOWEEN
/datum/supply_packs/halloween
	name = "Spooky Crate"
	desc = "WHAT COULD IT BE? SPOOKY GHOSTS?? TERRIFYING SKELETONS??? DARE YOU FIND OUT?!"
	contains = list(/obj/item/storage/goodybag = 6)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Spooky Crate"
#endif

#ifdef XMAS
/datum/supply_packs/xmas
	name = "Holiday Supplies"
	desc = "Winter joys from the workshop of Santa Claus himself! (Amusing Trivia: Santa Claus does not in fact exist.)"
	contains = list(/obj/item/clothing/head/helmet/space/santahat = 3,
					/obj/item/wrapping_paper/xmas = 2,
					/obj/item/scissors,
					/obj/item/reagent_containers/food/drinks/eggnog = 2,
					/obj/item/a_gift/festive = 2)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/xmas
	containername = "Holiday Supplies"
#endif

/datum/supply_packs/party
	name = "Party Supplies"
	desc = "x7 Assorted Party Hats, x2 Wrapping Paper Tubes, x1 Scissors, x1 Sticker Box, x2 Balloon Boxes, x6 Alcohol Boxes, x6 Beer Boxes, x1 Chocolate Gateau. Perfect for celebrating any special occasion!"
	contains = list(/obj/item/clothing/head/party/birthday = 1,
					/obj/item/clothing/head/party/birthday/blue = 1,
					/obj/item/clothing/head/party/random = 5,
					/obj/item/wrapping_paper = 2,
					/obj/item/scissors,
					/obj/item/item_box/assorted/stickers,
					/obj/item/storage/box/balloonbox = 2,
					/obj/item/reagent_containers/food/drinks/duo = 6,
					/obj/item/reagent_containers/food/drinks/bottle/beer = 6,
					/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau = 1)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Party Supplies"

/datum/supply_packs/wedding
	name = "Wedding Supplies"
	desc = "x2 Wedding Dresses, x2 Veils, x2 Fancy Vests, x2 Tuxedo Jackets, x2 Gold Rings, x1 Fancy Champagne. Your very own DIY wedding! Chaplain not included."
	contains = list(/obj/item/clothing/under/gimmick/wedding_dress = 2,
					/obj/item/clothing/head/veil = 2,
					/obj/item/clothing/under/misc/fancy_vest = 2,
					/obj/item/clothing/suit/tuxedo_jacket = 2,
					/obj/item/clothing/gloves/ring = 2,
					/obj/item/reagent_containers/food/drinks/bottle/champagne/cristal_champagne = 1)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/crate
	containername = "Wedding Supplies"

/datum/supply_packs/glowsticks
	name = "Emergency Glowsticks Crate - 4 pack"
	desc = "x4 Glowsticks Boxes (28 glowsticks total)."
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/glowstickbox = 4)
	cost = PAY_UNTRAINED*2
	containertype = /obj/storage/crate
	containername = "Emergency Glowsticks Crate - 4 pack"

/datum/supply_packs/glowsticksassorted
	name = "Assorted Glowsticks Crate - 4 pack"
	desc = "x4 Assorted Glowstick Boxes. Everything you need for your very own DIY rave!"
	contains = list(/obj/item/storage/box/glowstickbox/assorted = 4)
	cost = PAY_UNTRAINED*4
	containertype = /obj/storage/crate
	containername = "Assorted Glowsticks Crate - 4 pack"

/datum/supply_packs/portable_fueltank
	name = "Portable Welding Fuel Tank"
	desc = "x1 Transportable Welding Fuel Tank. For when you're on the move."
	category = "Basic Materials"
	contains = list(/obj/item/reagent_containers/food/drinks/fueltank)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Portable Welding Tank Crate"

/datum/supply_packs/fueltank
	name = "Welding Fuel Tank"
	desc = "x1 Welding Fuel Tank."
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/fueltank)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Welding Fuel Tank crate"

/datum/supply_packs/foamtank
	name = "Firefighting Foam tank"
	desc = "x1 Firefighting Foam Tank."
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/foamtank)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Firefighting Foamtank crate"

/datum/supply_packs/watertank
	name = "High Capacity Watertank"
	desc = "x1 High Capacity Watertank."
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/watertank/big)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "High Capacity Watertank crate"

/datum/supply_packs/compostbin
	name = "Compost Bin"
	desc = "x1 Compost Bin."
	category = "Civilian Department"
	contains = list(/obj/reagent_dispensers/compostbin)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Compost Bin crate"

/datum/supply_packs/office
	name = "Office Supply Crate"
	desc = "x4 Paper Bins, x2 Clipboards, x1 Sticky Note Box, x5 Writing Implement Sets, x1 Stapler, x1 Scissors, x2 Canvases."
	contains = list(/obj/item/paper_bin = 4,
		/obj/item/clipboard = 2,
		/obj/item/item_box/postit,
		/obj/item/storage/box/pen,
		/obj/item/storage/box/marker/basic,
		/obj/item/storage/box/marker,
		/obj/item/storage/box/crayon/basic,
		/obj/item/storage/box/crayon,
		/obj/item/staple_gun/red,
		/obj/item/scissors,
		/obj/item/canvas = 2,
		/obj/item/stamp = 2)
	cost = PAY_UNTRAINED*2
	containername = "Office Supply Crate"

// vvv Adding some suggestions from the QM Order Thread (Gannets) vvv

/datum/supply_packs/birds
	name = "Avian Import Kit"
	desc = "x5 Birds. Hand-reared, to help brighten your workplace."
	category = "Civilian Department"
	contains = list(/obj/critter/parrot/random = 5)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/pryable/animal
	containername = "Avian Import Kit"

/datum/supply_packs/animal
	name = "Animal Import Kit"
	desc = "x4+ Assorted Animals."
	category = "Civilian Department"
	contains = list (/obj/random_item_spawner/critter)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/pryable/animal
	containername = "Animal Import Kit"

/datum/supply_packs/pet_carrier
	name = "Pet Carrier"
	desc = "x1 Pet Carrier. Warranty voided if used to transport pet rocks or \
			tortoises."
	category = "Civilian Department"
	contains = list(/obj/item/pet_carrier)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate/packing
	containername = "Pet Carrier"

/datum/supply_packs/takeout_chinese
	name = "Golden Gannet Delivery"
	desc = "x2 Takeout Cartons, x2 Fortune Cookies, x2 Chopsticks Sets. A Space Chinese meal for two, delivered galaxy-wide."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/takeout = 2,
					/obj/item/reagent_containers/food/snacks/fortune_cookie = 2,
					/obj/item/kitchen/chopsticks_package = 2)
	cost = PAY_UNTRAINED
	containertype = /obj/storage/crate/packing
	containername = "Golden Gannet Delivery"

/datum/supply_packs/takeout_pizza
	name = "Soft Soft Pizzeria Delivery"
	desc = "x2 Soft Serve Pizzas, x2 Fries, x1 Cola. Straight from the oven to your airlock."
	category = "Civilian Department"
	contains = list(/obj/random_item_spawner/pizza = 1,
					/obj/item/reagent_containers/food/snacks/fries = 2,
					/obj/random_item_spawner/cola = 1)
	cost = PAY_UNTRAINED
	containertype = /obj/storage/crate/wooden
	containername = "Soft Soft Pizza Delivery"

/datum/supply_packs/mimicry
	name = "Mimicry Equipment"
	desc = "x1 Mime Costume, x1 Baguette, x1 Cigarette Pack, x1 Lighter. Entertainers burn bright, only to fade away in silence."
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/costume/mime/alt,
		/obj/item/baguette,
		/obj/item/cigpacket,
		/obj/item/device/light/zippo)
	cost = PAY_UNTRAINED
	containertype = /obj/storage/crate/packing
	containername = "Mimicry Equipment"

/datum/supply_packs/clown
	name = "Comedy Equipment"
	desc = "x1 Clown Costume, x1 Bike Horn, x1 Banana Peel, x1 Cream Pie, x1 Balloon Box. Entertainers burn bright but die young, outfit a new one with this crate!"
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/costume/clown/recycled,
		/obj/item/instrument/bikehorn,
		/obj/item/bananapeel,
		/obj/item/reagent_containers/food/snacks/pie/cream,
		/obj/item/storage/box/balloonbox)
	cost = PAY_UNTRAINED
	containertype = /obj/storage/crate/packing
	containername = "Comedy Equipment"

/datum/supply_packs/ID_gear
	name = "Identity Kit"
	desc = "x1 PDA Box, x1 ID box. For HOP use only. Certainly not for identity fraud."
	contains = list(/obj/item/storage/box/PDAbox,
					/obj/item/storage/box/id_kit)
	cost = PAY_IMPORTANT
	containertype = /obj/storage/secure/crate
	containername = "Identity Kit"
	access = access_heads

/datum/supply_packs/prosphetics
	name = "Prosthetic Augmentation Kit"
	desc = "x6+ Cybernetic Augmentations. Replace your feeble flesh with these mechanical substitutes."
	category = "Medical Department"
	contains = list(/obj/random_item_spawner/prosthetics)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate
	containername = "Prosthetic Augmentation Kit"

/datum/supply_packs/restricted_medicine
	name = "Restricted Medicine Shipment (Cardlocked \[Medical Director])"
	desc = "x1 Omnizine bottle, x1 Perfluorodecalin bottle, x1 Haloperidol bottle, x1 Diethyl Ether bottle."
	category = "Medical Department"
	contains = list(/obj/item/reagent_containers/glass/bottle/omnizine,
					/obj/item/reagent_containers/glass/bottle/pfd = 2,
					/obj/item/reagent_containers/glass/bottle/pentetic,
					/obj/item/reagent_containers/glass/bottle/haloperidol,
					/obj/item/reagent_containers/glass/bottle/ether)
	cost = PAY_DOCTORATE*5
	containertype = /obj/storage/secure/crate
	containername = "Restricted Medicine Shipment (Cardlocked \[Medical Director])"
	access = access_medical_director

/datum/supply_packs/cyborg
	name = "Cyborg Component Crate"
	desc = "x1 Robot Frame, x1 Standard Cyborg Part Set, x1 Cable Coil. Build your very own walking science nightmare! (Brain not included.)"
	category = "Medical Department"
	contains = list(/obj/item/parts/robot_parts/robot_frame,
					/obj/item/parts/robot_parts/head/sturdy,
					/obj/item/parts/robot_parts/chest/standard,
					/obj/item/parts/robot_parts/arm/left/sturdy,
					/obj/item/parts/robot_parts/arm/right/sturdy,
					/obj/item/parts/robot_parts/leg/left/standard,
					/obj/item/parts/robot_parts/leg/right/standard,
					/obj/item/cable_coil)
	cost = PAY_DOCTORATE*5
	containertype = /obj/storage/crate/wooden
	containername = "Junior Medical Science Set: For Ages 7+"

/datum/supply_packs/rcd
	name = "Rapid-construction-device Replacement"
	desc = "x1 Empty Rapid Construction Device."
	category = "Basic Materials"
	contains = list(/obj/item/rcd)
	cost = PAY_DONTBUYIT
	containertype = /obj/storage/crate/wooden
	containername = "RCD Replacement"

/datum/supply_packs/places_pipes
	name = "Handheld-pipe-dispenser replacement"
	desc = "x1 Handheld Pipe Dispenser."
	category = "Basic Materials"
	contains = list(/obj/item/places_pipes)
	cost = PAY_EMBEZZLED*2
	containertype = /obj/storage/crate/wooden
	containername = "HPD Replacement"

/datum/supply_packs/buddy
	name = "Thinktronic Build Your Own Buddy Kit"
	desc = "x1 Guardbuddy Frame, x1 Guardbuddy Mainboard, x1 Sturdy Cyborg Arm, x1 Power Cell, x1 Random Guardbuddy Module. Assemble your very own working Robuddy, one part per week."
	contains = list(/obj/item/guardbot_frame,
					/obj/item/guardbot_core,
					/obj/item/cell,
					/obj/item/parts/robot_parts/arm/right/sturdy,
					/obj/random_item_spawner/buddytool)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate/wooden
	containername = "Robuddy Kit"

/datum/supply_packs/meteor
	name = "Meteor Shield System"
	desc = "x4 Meteor Shield Generators."
	contains = list(/obj/machinery/shieldgenerator/meteorshield = 4)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Meteor Shield System"

/datum/supply_packs/reclaimer
	name = "Reclaimed Reclaimer"
	desc = "x1 Portable Reclaimer. Jeez, be more careful with it next time!"
	category = "Basic Materials"
	contains = list(/obj/machinery/portable_reclaimer)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/packing
	containername = "Reclaimed Reclaimer"

/datum/supply_packs/morgue
	name = "Morgue Supplies"
	desc = "x10 Body Bags, x1 Embalming Fluid Bottle, x1 Syringe, x1 Bible. The morgue can only fit so many clowns."
	category = "Medical Department"
	contains = list(/obj/item/body_bag = 10,
					/obj/item/reagent_containers/glass/bottle/formaldehyde,
					/obj/item/reagent_containers/syringe,
					/obj/item/bible)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/closet/coffin
	containername = "Morgue Supplies"

/datum/supply_packs/computer
	name = "Home Networking Kit"
	desc = "x3 Cable Coils, 50x Glass Sheets, x1 Motherboard, x5+ Assorted Peripherals, x2+ Assorted Circuit boards. Build your own state of the art computer system! (Contents may vary.)"
	contains = list(/obj/item/sheet/glass/fullstack,
					/obj/item/sheet/steel/fullstack,
					/obj/item/cable_coil = 3,
					/obj/item/motherboard,
					/obj/random_item_spawner/peripherals,
					/obj/random_item_spawner/circuitboards)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate/wooden
	containername = "Home Networking Kit"

/datum/supply_packs/candle
	name = "Candle Crate"
	desc = "x3 Candles, x6 Small Candles, x1 Matchbook. Perfect for setting the mood."
	contains = list(/obj/item/device/light/candle = 3,
					/obj/item/device/light/candle/small = 6,
					/obj/item/matchbook)
	cost = PAY_UNTRAINED*2
	containertype = /obj/storage/crate/packing
	containername = "Candle Crate"

/datum/supply_packs/microbrew
	name = "Home Distillery Kit"
	desc = "x1 Still, x2 Glass Pitchers, x6 Glass Bottles. Turn Cargo into a microbrewery."
	contains = list(/obj/reagent_dispensers/still,
					/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher = 2,
					/obj/item/reagent_containers/food/drinks/bottle/soda = 6)
	cost = PAY_TRADESMAN*3
	containertype = /obj/storage/crate/wooden
	containername = "Home Distillery Kit"

/datum/supply_packs/bloodbags
	name = "Blood Bank"
	desc = "x2 Blood Packs, x2 Saline-glucose Solution Drips."
	category = "Medical Department"
	contains = list (/obj/item/reagent_containers/iv_drip/blood = 2,
					/obj/item/reagent_containers/iv_drip/saline = 2)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate/medical
	containername = "Blood Bank"

/datum/supply_packs/singularity_generator
	name = "Singularity Generator Crate (Cardlocked \[Chief Engineer])"
	desc = "x1 Extremely Unstable Gravitational Singularity. Stored in a hi-tech jam jar, fired directly at your current location."
	category = "Engineering Department"
	contains = list(/obj/machinery/the_singularitygen)
	cost = PAY_EMBEZZLED
	containertype = /obj/storage/secure/crate
	containername = "Singularity Generator Crate (Cardlocked \[Chief Engineer])"
	access = access_engineering_chief

/datum/supply_packs/emitter
	name = "Emitter Crate (Cardlocked \[Engineering])"
	desc = "x1 Emitter. For energizing field generators. You'll need a few of these."
	category = "Engineering Department"
	contains = list(/obj/machinery/emitter)
	cost = PAY_EMBEZZLED
	containertype = /obj/storage/secure/crate
	containername = "Emitter Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/rad_collector
	name = "Radiation Collector Crate (Cardlocked \[Engineering])"
	desc = "x4 Radiation Collector Array Frames, x1 Collector Controller Frame, x1 Soldering Iron. To harvest radiation from a singularity."
	category = "Engineering Department"
	contains = list(/obj/item/electronics/frame/collector_array = 4,
					/obj/item/electronics/frame/collector_control,
					/obj/item/electronics/soldering)
	cost = PAY_EMBEZZLED
	containertype = /obj/storage/secure/crate
	containername = "Radiation Array Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/radiation_emergency
	name = "Radiation Emergency Supplies"
	desc = "x4 Radiation Suits, x2 Potassium Iodide Pill Bottles, x4 Potassium Iodide Auto-injectors, x2 Geiger Counters. Equipment for dealing with a radiation emergency. No, the crate itself is not irradiated."
	category = "Basic Materials"
	contains = list(/obj/item/clothing/suit/hazard/rad = 4,
					/obj/item/clothing/head/rad_hood = 4,
					/obj/item/storage/pill_bottle/antirad = 2,
					/obj/item/reagent_containers/emergency_injector/anti_rad = 4,
					/obj/item/device/geiger = 2)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Radiation Emergency Supplies"

/datum/supply_packs/eva
	name = "EVA Equipment Crate"
	desc = "x1 Space Suit, x1 Emergency Gas Mask, x1 Jetpack, x1 Magboots. For enabling mobility in major hull damage scenarios."
	category = "Basic Materials"
	contains = list(/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/mask/gas/emergency,
					/obj/item/tank/jetpack,
					/obj/item/clothing/shoes/magnetic)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate/wooden
	containername = "EVA Equipment Crate"

/datum/supply_packs/XL_air_canister
	name = "Extra Large Air Mix Canister"
	desc = "x1 XL Air Mix Canister. Filled with a mix of nitrogen, oxygen and minimal amounts of carbon dioxide. Used for emergency re-pressurisation efforts."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/canister/air/large)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Spare XL Air Mix Canister Crate"

/datum/supply_packs/oxygen_canister
	name = "Spare Oxygen Canister"
	desc = "x1 Oxygen canister. For resupplying Engineering's fuel or refilling oxygen tanks."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Spare Oxygen Canister Crate"

/datum/supply_packs/abcu
	name = "ABCU Unit Crate (Cardlocked \[Engineering])"
	desc = "x1 ABCU Unit. For large construction projects."
	category = "Engineering Department"
	contains = list(/obj/machinery/abcu, /obj/item/blueprint_marker)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/secure/crate
	containername = "ABCU Unit Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/efif1
	name = "EFIF-1 Construction System (Cardlocked \[Engineering])"
	desc = "x1 Pod-mounted Mass Construction Tool. Suitable for large-scale repairs and offsite building projects."
	category = "Engineering Department"
	contains = list(/obj/item/shipcomponent/mainweapon/constructor/stocked,
					/obj/item/paper/efif_disclaimer)
	cost = PAY_DOCTORATE*15
	containertype = /obj/storage/secure/crate
	containername = "EFIF-1 Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/janitor_supplies
	name = "Janitorial Supplies Refill"
	desc = "x4 Cleaner Grenades, x2 Cleaner Bottles, x2 Spray Bottles, x1 Trash Bags Box, x1 Hazardous Waste Bags Box."
	category = "Civilian Department"
	contains = list(/obj/item/chem_grenade/cleaner = 4,
					/obj/item/spraybottle/cleaner = 2,
					/obj/item/reagent_containers/glass/bottle/cleaner = 2,
					/obj/item/storage/box/trash_bags,
					/obj/item/storage/box/biohazard_bags)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/packing
	containername = "Janitorial Supplies Refill"

/datum/supply_packs/toolbelts
	name = "Utility Belt Crate"
	desc = "x2 Utility Belts, x2 Mechanical Toolboxes. To appease the staff assistant masses."
	category = "Basic Materials"
	contains = list(/obj/item/storage/belt/utility = 2,
					/obj/item/storage/toolbox/mechanical = 2)
	cost = PAY_TRADESMAN*4
	containertype = /obj/storage/crate/packing
	containername = "Utility Belt Crate"

/datum/supply_packs/counterrevimplant
	name = "Counter-Revolutionary Kit"
	desc = "x2 Implanter, x4 Counter-Revolutionary Implants. To suppress rebellion against Nanotrasen."
	category = "Security Department"
	contains = list(/obj/item/implantcase/counterrev = 4,
					/obj/item/implanter = 2)
	cost = PAY_IMPORTANT*4
	containertype = /obj/storage/crate
	containername = "Counter-Revolutionary Kit"
	access = access_security

/datum/supply_packs/furniture
	name = "Furnishings Crate"
	desc = "x8 Assorted Flat-Packed Furniture. Designed in Space Sweden."
	contains = list(/obj/random_item_spawner/furniture_parts)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/wooden
	containername = "Furnishings Crate"

/datum/supply_packs/furniture_eventtablered
	name = "Red Event Table Crate"
	desc = "x5 Flat-Packed Tables. Each with a fancy red tablecloth."
	contains = list(/obj/item/furniture_parts/table/clothred = 5)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/crate/wooden
	containername = "Red Event Table Crate"

/datum/supply_packs/furniture_neon
	name = "Neon Furnishings Crate"
	desc = "x4 Flat-Packed Tables, x4 Flat-Packed Stools. Each in eye-searing neon."
	contains = list(/obj/item/furniture_parts/table/neon = 4,
					/obj/item/furniture_parts/stool/neon = 4)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/crate/wooden
	containername = "Neon Furnishings Crate"

/datum/supply_packs/furniture_scrap
	name = "Scrap Furnishings Crate"
	desc = "x8 Scrap Parts. I guess you could make furniture out of it?"
	contains = list(/obj/item/furniture_parts/table/scrap = 4,
					/obj/item/furniture_parts/dining_chair/scrap = 4)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Scrap Furnishings Crate"

/datum/supply_packs/furniture_sleek
	name = "Sleek Furnishings Crate"
	desc = "x2 Flat-Packed Chairs, x4 Flat-Packed Tables, x2 Flat-Packed Stools. All in a glossy black."
	contains = list(/obj/item/furniture_parts/table/sleek = 4,
					/obj/item/furniture_parts/stool/sleek = 2,
					/obj/item/furniture_parts/sleekchair =2)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/crate/wooden
	containername = "Sleek Furnishings Crate"

/datum/supply_packs/furniture_regal
	name = "Regal Furnishings Crate"
	desc = "x4 Flat-Packed Chairs, x4 Flat-Packed Tables, x2 Flat-Packed Lamps. All regal. "
	contains = list(/obj/item/furniture_parts/dining_chair/regal = 4,
					/obj/item/furniture_parts/table/regal = 4,
					/obj/item/furniture_parts/decor/regallamp = 2)
	cost = PAY_EMBEZZLED*2
	containertype = /obj/storage/crate/wooden
	containername = "Regal Furnishings Crate"

/datum/supply_packs/furniture_throne
	name = "Golden Throne"
	desc = "x1 Flat-Packed Throne. It can't be real gold for that price..."
	contains = list(/obj/item/furniture_parts/throne_gold)
	cost = PAY_EMBEZZLED*5
	containertype = /obj/storage/crate/wooden
	containername = "Throne Crate"

/datum/supply_packs/hat
	name = "Haberdasher's Crate"
	desc = "x5+ Assorted Hats. A veritable smörgåsbord of head ornaments."
	contains = list(/obj/random_item_spawner/hat)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Haberdasher's Crate"

/datum/supply_packs/random_wigs
	name = "Spare wigs crate"
	desc = "x7 Assorted Wigs."
	category = "Civilian Department"
	contains = list(/obj/item/clothing/head/wig/spawnable/random = 7)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Wig Crate"

/datum/supply_packs/headbands
	name = "Bargain Bows and Bands Box"
	desc = "x8 Headbands. For all occasions."
	cost = PAY_IMPORTANT*2
	contains = list(/obj/item/clothing/head/headband/giraffe = 1,
					/obj/item/clothing/head/headband/antlers = 1,
					/obj/item/clothing/head/headband/nyan/tiger = 1,
					/obj/item/clothing/head/headband/nyan/leopard = 1,
					/obj/item/clothing/head/headband/nyan/snowleopard = 1,
					/obj/item/clothing/head/headband/bee = 2,
					/obj/item/clothing/head/headband/nyan/random = 1)
	containertype = /obj/storage/crate/packing
	containername = "Bows and Bands Box"

/datum/supply_packs/mask
	name = "Masquerade Crate"
	desc = "x5+ Assorted Novelty Masks. For hosting a masked ball in the bar."
	contains = list(/obj/random_item_spawner/mask)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Masquerade Crate"

/datum/supply_packs/shoe
	name = "Shoe Crate"
	desc = "x5+ Assorted Novelty Shoes. Has an unruly staff assistant stolen all your shoes?"
	contains = list(/obj/random_item_spawner/shoe)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Shoe Crate"

/datum/supply_packs/ballroom
	name = "Ballroom Supplies"
	desc = "x4 Social Dancing Shoes, x5+ Assorted Formalwear. Host your very own HR approved ball."
	contains = list(/obj/random_item_spawner/formalclothes,
					/obj/item/clothing/shoes/dress_shoes/dance = 4)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate
	containername = "Ballroom Supplies"

/datum/supply_packs/kendo
	name = "Kendo Crate"
	desc = "x2 Sets of Kendo Equipment."
	contains = list(/obj/item/clothing/head/helmet/men = 2,
					/obj/item/clothing/suit/armor/douandtare = 2,
					/obj/item/clothing/gloves/kote = 2,
					/obj/item/shinai_bag,
					/obj/item/storage/box/kendo_box/hakama)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/wooden
	containername = "Kendo Crate"

/datum/supply_packs/obon
	name = "Obon Festival Crate"
	desc = {"x10 Assorted Yukatas, x10 Sandals, x2 Fireworks Boxes, x5 Fireworks. For the observance of Obon; a syncretic summer festival fusing indigenous Japanese spiritual beliefs
			with the Buddhist tradition of reverence for the dead."}
	contains = list(/obj/item/clothing/under/gimmick/yukata/plain/gray,
					/obj/item/clothing/under/gimmick/yukata/plain/black,
					/obj/item/clothing/under/gimmick/yukata/plain/cream,
					/obj/item/clothing/under/gimmick/yukata/plain/navy,
					/obj/item/clothing/under/gimmick/yukata/plain/teal,
					/obj/item/clothing/under/gimmick/yukata/floral/blue,
					/obj/item/clothing/under/gimmick/yukata/floral/orange,
					/obj/item/clothing/under/gimmick/yukata/floral/yellow,
					/obj/item/clothing/under/gimmick/yukata/floral/red,
					/obj/item/clothing/under/gimmick/yukata/floral/black,
					/obj/item/clothing/shoes/sandal = 10,
					/obj/fireworksbox = 2,
					/obj/item/firework = 5)
	cost = PAY_EXECUTIVE*2
	containertype = /obj/storage/crate/wooden
	containername = "Obon Festival Crate"

/datum/supply_packs/sponge
	name = "Sponge Capsule Crate"
	desc = "x1 Sponge Capsule Set. For all your watery animal needs!"
	contains = list(/obj/item/spongecaps = 1)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Sponge Capsule Crate"

/datum/supply_packs/candy
	name = "Candy Crate"
	desc = "x5 Assorted Candy Packs. Proudly bringing sugar comas to your space stations since 2k53."
	contains = list(/obj/item/item_box/heartcandy,
					/obj/item/storage/goodybag,
					/obj/item/item_box/swedish_bag,
					/obj/item/kitchen/peach_rings,
					/obj/item/kitchen/gummy_worms_bag)
	cost = PAY_UNTRAINED*2
	containertype = /obj/storage/crate
	containername = "Candy Crate"

/datum/supply_packs/light
	name = "Lighting Crate"
	desc = "x6 Glowsticks, x3 Flares, x2 Flashlights. Afraid of the dark?"
	contains = list(/obj/item/device/light/glowstick = 6,
					/obj/item/roadflare = 3,
					/obj/item/device/light/flashlight = 2)
	cost = PAY_UNTRAINED*2
	containertype = /obj/storage/crate/packing
	containername = "Lighting Crate"

// Kyle2143's vending restock packs

/datum/supply_packs/necessities_vending_restock
	name = "Necessities Vending Machine Restocking Pack"
	desc = "x1 Coffee Restock Cartridge, x1 Snack Restock Cartridge, x1 Cigarette Restock Cartridge, x1 Cola Restock Cartridge, x1 Alcohol Restock Cartridge, x1 Capsule Restock Cartridge, x1 Standard Restock Cartridge, x1 Kitchen Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/coffee,
					/obj/item/vending/restock_cartridge/snack,
					/obj/item/vending/restock_cartridge/cigarette,
					/obj/item/vending/restock_cartridge/alcohol,
					/obj/item/vending/restock_cartridge/cola,
					/obj/item/vending/restock_cartridge/kitchen,
					/obj/item/vending/restock_cartridge/standard,
					/obj/item/vending/restock_cartridge/capsule)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Necessities Vending Machine Restocking Pack"

/datum/supply_packs/catering_vending_restock
	name = "Catering and Hydroponics Vending Machine Restocking Pack"
	desc = "x1 Hydroponics Restock Cartridge, x1 Kitchen Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/hydroponics,
					/obj/item/vending/restock_cartridge/kitchen)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Catering and Hydroponics Vending Machine Restocking Pack"

/datum/supply_packs/medical_vending_restock
	name = "Medical Vending Machine Restock Pack"
	desc = "x1 Medical Restock Cartridge, x1 Public Medical Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/medical,
					/obj/item/vending/restock_cartridge/medical_public,)
	cost = PAY_DOCTORATE*2
	containertype = /obj/storage/crate
	containername = "Medical Vending Machine Restocking Pack"

/datum/supply_packs/security_vending_restock
	name = "Security Vending Machine Restocking Pack"
	desc = "x1 Security Restock Cartridge, x1 Security Ammo Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/security,
					/obj/item/vending/restock_cartridge/security_ammo)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate
	containername = "Security Vending Machine Restocking Pack"

/datum/supply_packs/electronics_vending_restock
	name = "Electronics Vending Machine Restocking Pack"
	desc = "x1 Mechanics Restock Cartridge, x1 PDA Restock Cartridge, x1 Computer3 Restock Cartridge, x1 Floppy Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/mechanics,
					/obj/item/vending/restock_cartridge/computer3,
					/obj/item/vending/restock_cartridge/floppy,
					/obj/item/vending/restock_cartridge/pda)
	cost = PAY_DOCTORATE*4
	containertype = /obj/storage/crate
	containername = "Electronics Vending Machine Restocking Pack"

/datum/supply_packs/clothing_vending_restock
	name = "Clothing Vending Machine Restock Pack"
	desc = "x1 Catering Clothing Restock Cartridge, x1 Engineering Clothing Restock Cartridge, x1 Medical Clothing Restock Cartridge, x1 Research Clothing Restock Cartridge, x1 Security Clothing Restock Cartridge."
	contains = list(/obj/item/vending/restock_cartridge/jobclothing/security,
					/obj/item/vending/restock_cartridge/jobclothing/medical,
					/obj/item/vending/restock_cartridge/jobclothing/engineering,
					/obj/item/vending/restock_cartridge/jobclothing/catering,
					/obj/item/vending/restock_cartridge/jobclothing/research,)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Clothing Vending Machine Restocking Pack"

/*
	Umm, apparently the packs below never get added? What's up with that. Construction mode :S -ZeWaka
*/

/datum/supply_packs/banking_kit
	name = "Banking Kit"
	desc = "x1 ATM Circuitboard, x1 BankBoss Disk."
	contains = list(/obj/item/circuitboard/atm, /obj/item/disk/data/floppy/read_only/bank_progs)
	hidden = 1
	cost = PAY_IMPORTANT*5
	containertype = /obj/storage/crate
	containername = "Banking Kit"

/datum/supply_packs/homing_kit
	name = "Homing Kit"
	desc = "x3 Tracking Beacons."
	cost = PAY_IMPORTANT*2
	hidden = 1
	contains = list(/obj/item/device/radio/beacon = 3)
	containertype = /obj/storage/crate
	containername = "Homing Kit"


/datum/supply_packs/id_computer
	name = "ID Computer Circuitboard"
	desc = "x1 ID Computer Circuitboard."
	hidden = 1
	contains = list(/obj/item/circuitboard/card)
	cost = PAY_IMPORTANT*5

/datum/supply_packs/administrative_id
	name = "Administrative ID card"
	desc = "x1 Captain level ID."
	contains = list(/obj/item/card/id/gold/captains_spare)
	cost = PAY_EXECUTIVE*2
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/plasmastone
	name = "Plasmastone"
	desc = "x1 Plasmastone."
	contains = list(/obj/item/raw_material/plasmastone)
	cost = PAY_IMPORTANT
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/baton
	name = "Stun Baton"
	desc = "x1 Stun Baton."
	contains = list(/obj/item/baton)
	cost = PAY_IMPORTANT
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/telecrystal
	name = "Telecrystal"
	desc = "x1 Telecrystal."
	contains = list(/obj/item/raw_material/telecrystal)
	cost = PAY_IMPORTANT
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/telecrystal_bulk
	name = "Telecrystal Resupply Pack"
	desc = "x10 Telecrystals."
	contains = list(/obj/item/raw_material/telecrystal = 10)
	cost = PAY_IMPORTANT*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Telecrystal Resupply Pack"

/datum/supply_packs/antisingularity
	name = "Anti-Singularity Pack"
	desc = "x1 Singularity Buster Rocket Launcher, x5 Singularity Buster Rockets, x1 Singularity Buster Instructions. Everything that the crew needs to take down a rogue singularity."
	category = "Engineering Department"
	contains = list(/obj/item/paper/antisingularity,/obj/item/ammo/bullets/antisingularity = 5,/obj/item/gun/kinetic/antisingularity)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate/classcrate/qm
	containername = "Anti-Singularity Supply Pack"

/datum/supply_packs/conworksupplies
	name = "Construction Equipment"
	desc = "x1 Floor and Wall Designer, x1 Lamp Manufacturer, x1 Room Designator, x1 Construction Worker's Overalls. The mothballed tools of our former Construction Workers, in a crate, for you!"
	category = "Engineering Department"
	contains = list(/obj/item/lamp_manufacturer/organic,/obj/item/room_planner, /obj/item/room_marker, /obj/item/clothing/under/rank/orangeoveralls)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/secure/crate
	containername = "Construction Equipment"

/datum/supply_packs/lawrack
	name = "AI Law Rack ManuDrive Crate (Cardlocked \[Heads])"
	desc = "x1 Single-use Law Rack ManuDrive. For creating a replacement Law Rack for your Automated Intelligence unit. Note: Bring your own law modules."
	category = "Engineering Department"
	contains = list(/obj/item/disk/data/floppy/manudrive/law_rack/singleuse)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate
	containername = "AI Law Rack ManuDrive Crate (Cardlocked \[Heads])"
	access = access_heads

/datum/supply_packs/stationgravitytether
	name = "Station Gravity Tether ManuDrive Crate"
	desc = "A single-use ManuDrive for creating a replacement Gravity Tether for your ship or station. Note: Multiple gravity tethers are unsupported."
	category = "Engineering Department"
	contains = list(/obj/item/disk/data/floppy/manudrive/gravity_tether/singleuse)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/secure/crate
	containername = "Station Gravity Tether ManuDrive Crate (Cardlocked \[Heads])"
	access = access_heads

/datum/supply_packs/pressure_crystals_qt5
	name = "Pressure Crystal Resupply"
	desc = "x5 Pressure Crystals. Used in high-energy research."
	category = "Research Department"
	contains = list(/obj/item/pressure_crystal = 5)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "Pressure Crystal Crate"

/datum/supply_packs/comms_dish
	name = "Communications Dish (Cardlocked \[Engineering])"
	desc = "x1 Single-Use Communications Disk Manudrive, x1 COMMaster Disk. For creating a new Communications Dish. Note: Console not included."
	category = "Engineering Department"
	contains = list(/obj/item/disk/data/floppy/manudrive/comms_dish/singleuse, /obj/item/disk/data/floppy/read_only/communications)
	cost = PAY_IMPORTANT
	containertype = /obj/storage/secure/crate
	containertype = /obj/storage/secure/crate
	containername = "Communications Dish Crate (Cardlocked \[Engineering])"
	access = access_engineering

/* ================================================= */
/* -------------------- Complex -------------------- */
/* ================================================= */
ABSTRACT_TYPE(/datum/supply_packs/complex)
/datum/supply_packs/complex
	hidden = 0
	var/list/blueprints = list()
	var/list/frames = list()

	create(var/spawnpoint,var/mob/creator)
		var/atom/movable/A = ..()
		if (!A)
			// TODO: spawn a new crate instead of just returning?
			return

		for (var/path in blueprints)
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					continue

			var/amt = 1
			if (isnum(blueprints[path]))
				amt = abs(blueprints[path])

			for (amt, amt>0, amt--)
				new /obj/item/paper/manufacturer_blueprint(A, path)

		for (var/path in frames)
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					continue

			var/amt = 1
			if (isnum(frames[path]))
				amt = abs(frames[path])

			var/atom/template = path
			var/template_name = initial(template.name)
			if (!template_name)
				continue

			for (amt, amt>0, amt--)
				var/obj/item/electronics/frame/F = new /obj/item/electronics/frame(A)
				F.name = "[template_name] frame"
				F.store_type = path
				F.viewstat = 2
				F.secured = 2
				F.icon_state = "dbox"

		return A

/datum/supply_packs/complex/electronics_kit
	name = "Mechanics Reconstruction Kit (Cardlocked \[Chief Engineer])"
	desc = "x1 Ruckingenur Frame, x1 Manufacturer Frame, x1 Reclaimer Frame, x1 Device Analyzer, x1 Soldering Iron."
	category = "Engineering Department"
	contains = list(/obj/item/electronics/scanner,
					/obj/item/electronics/soldering,
					/obj/item/deconstructor)
	frames = list(/obj/machinery/rkit,
					/obj/machinery/manufacturer/mechanic,
					/obj/machinery/portable_reclaimer)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/secure/crate/eng
	access = access_engineering_chief
	containername = "Mechanics Reconstruction Kit (Cardlocked \[Chief Engineer])"

/datum/supply_packs/complex/barbershop_kit
	name = "Barbershop Kit"
	desc = "x1 Barber Chair, x2 Dye Bottles, x1 Razor Blade, x1 Scissors, x1 Barber's Uniform, x1 Latex Gloves, x1 Soldering Iron."
	category = "Civilian Department"
	contains = list(/obj/item/electronics/soldering,
					/obj/item/furniture_parts/barber_chair,
					/obj/item/dye_bottle,
					/obj/item/dye_bottle,
					/obj/item/razor_blade,
					/obj/item/scissors,
					/obj/item/clothing/under/misc/barber,
					/obj/item/clothing/gloves/latex)
	frames = list(/obj/machinery/hair_dye_dispenser)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Barbershop Kit"

#ifndef UNDERWATER_MAP
/datum/supply_packs/complex/mini_magnet_kit
	name = "Small Magnet Kit"
	desc = "x1 Magnetizer, x1 Low Performance Magnet Kit, x1 Magnet Chassis Frame, x1 Instructions Manual."
	category = "Engineering Department"
	contains = list(/obj/item/magnetizer,
					/obj/item/magnet_parts/construction/small,
					/obj/item/paper/magnetconstruction)
	frames = list(/obj/machinery/magnet_chassis,
					/obj/machinery/computer/magnet)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Small Magnet Kit"

/datum/supply_packs/complex/magnet_kit
	name = "Magnet Kit"
	desc = "x1 Magnetizer, x1 High Performance Magnet Kit, x1 Magnet Chassis Frame, x1 Instructions Manual."
	category = "Engineering Department"
	contains = list(/obj/item/magnetizer,
					/obj/item/magnet_parts/construction,
					/obj/item/paper/magnetconstruction)
	frames = list(/obj/machinery/magnet_chassis,
					/obj/machinery/computer/magnet)
	cost = PAY_TRADESMAN*15
	containertype = /obj/storage/crate
	containername = "Magnet Kit"
#endif

/datum/supply_packs/complex/mining_rockbox
	name = "Rockbox™ Storage Container (Cardlocked \[Chief Engineer])"
	desc = "x1 Rockbox™ Ore Cloud Storage Container."
	category = "Engineering Department"
	frames = list(/obj/machinery/ore_cloud_storage_container)
	cost = PAY_EMBEZZLED
	containertype = /obj/storage/secure/crate/plasma
	containername = "Rockbox™ Storage Container (Cardlocked \[Chief Engineer])"
	access = access_engineering_chief

/datum/supply_packs/complex/manufacturer_kit
	name = "Manufacturer Kit"
	desc = "x1 General Manufacturer Frame, x1 Mining Manufacturer Frame, x1 Science Manufacturer Frame, x1 Gas Extractor Frame, x1 Clothing Manufacturer Frame, x1 Reclaimer Frame."
	category = "Engineering Department"
	frames = list(/obj/machinery/manufacturer/general,
					/obj/machinery/manufacturer/mining,
					/obj/machinery/manufacturer/science,
					/obj/machinery/manufacturer/gas,
					/obj/machinery/manufacturer/uniform,
					/obj/machinery/portable_reclaimer)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Manufacturer Kit"

/datum/supply_packs/complex/cargo_kit
	name = "Cargo Bay Kit"
	desc = "x1 Cargo Teleporter, x1 Commerce Computer Frame, x1 Incoming Supply Pad Frame, x1 Outgoing Supply Pad Frame, x1 Cargo Teleporter Pad Frame, x1 Recharger Frame. Contains a higher tier of cargo computer, allowed access to the full NT catalog."
	category = "Engineering Department"
	hidden = 1
	contains = list(/obj/item/paper/cargo_instructions,
					/obj/item/cargotele)
	frames = list(/obj/machinery/computer/special_supply/commerce,
					/obj/supply_pad/incoming,
					/obj/supply_pad/outgoing,
					/obj/submachine/cargopad,
					/obj/machinery/recharger)
	cost = PAY_TRADESMAN*20
	containertype = /obj/storage/crate
	containername = "Cargo Bay Kit"

/datum/supply_packs/complex/pod_kit
	name = "Pod Production Kit"
	desc = "x1 Ship Component Fabricator Frame, x1 Reclaimer Frame."
	frames = list(/obj/machinery/manufacturer/hangar,
					/obj/machinery/portable_reclaimer)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Pod Production Kit"

/datum/supply_packs/complex/turret_kit
	name = "Defense Turret Kit"
	desc = "x3 Turret Frames, x2 Turret Control Console Frames, x2 Security Camera Frames."
	frames = list(/obj/machinery/turret/construction = 3,
					/obj/machinery/turretid/computer,
					/obj/machinery/camera = 2)
	cost = PAY_IMPORTANT*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Defense Turret Kit"

/datum/supply_packs/complex/ai_kit
	name = "Artificial Intelligence Kit"
	desc = "x1 Asimov 5 AI Frame, x2 Turret, x1 Turret Control Console Frame, x2 Security Camera Frame."
	frames = list(/obj/ai_frame,
					/obj/machinery/turret/construction = 2,
					/obj/machinery/turretid/computer,
					/obj/machinery/camera = 2)
	cost = PAY_IMPORTANT*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "AI Kit"

/datum/supply_packs/complex/status_display
	name = "Disassembled Status Displays"
	desc = "x4 Status Display Panel Frames."
	category = "Engineering Department"
	frames = list(/obj/machinery/status_display,
		/obj/machinery/status_display,
		/obj/machinery/status_display,
		/obj/machinery/status_display)
	cost = PAY_IMPORTANT*5
	containertype = /obj/storage/crate
	containername = "Status Display Kit"

/datum/supply_packs/complex/eppd_kit
	name = "Emergency Pressurization Kit"
	desc = "x1 Extreme-Pressure Pressurization Device Frame."
	category = "Engineering Department"
	frames = list(/obj/machinery/portable_atmospherics/pressurizer)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate
	containername = "Prototype EPPD Kit"

/datum/supply_packs/complex/basic_power_kit
	name = "Basic Power Kit"
	desc = "x1 SMES Cell Frame, x2 Furnace Frame."
	category = "Engineering Department"
	frames = list(/obj/smes_spawner,
					/obj/machinery/power/furnace = 2)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Power Kit"

/datum/supply_packs/complex/basic_power_kit/crew
	name = "Emergency Power Equipment"
	desc = "x2 Circular Power Treadmill Frames."
	category = "Engineering Department"
	frames = list(/obj/machinery/power/power_wheel/hamster = 2)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Crew Power Generation Kit"

/datum/supply_packs/complex/mainframe_kit
	name = "Computer Core Kit"
	category = "Research Department"
	desc = "x1 Memory Board, x1 Mainframe Recovery Kit, x1 TermOS B Disk, x1 Computer Mainframe Frame, x1 Databank Frame, x1 Network Radio Frame, x3 Data Terminal Frames, x1 CompTech Frame."
	contains = list(/obj/item/disk/data/memcard,
					/obj/item/storage/box/zeta_boot_kit,
					/obj/item/disk/data/floppy/read_only/terminal_os)
	frames = list(/obj/machinery/networked/mainframe,
					/obj/machinery/networked/storage,
					/obj/machinery/networked/radio,
					/obj/machinery/power/data_terminal = 3,
					/obj/machinery/vending/computer3)
	cost = PAY_IMPORTANT*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Computer Core Kit"

/datum/supply_packs/complex/artlab_kit
	name = "Artifact Research Kit"
	desc = "x5 Data Terminal Frames, x1 Pitcher Frame, x1 Impact Pad Frame, x1 Heater Pad Frame, x1 Electric Box Frame, x1 X-Ray Machine Frame."
	category = "Research Department"
	frames = list(/obj/machinery/networked/test_apparatus/pitching_machine,
					/obj/machinery/networked/test_apparatus/impact_pad,
					/obj/machinery/networked/test_apparatus/electrobox,
					/obj/machinery/networked/test_apparatus/heater,
					/obj/machinery/networked/test_apparatus/xraymachine,
					/obj/machinery/power/data_terminal = 5)
	cost = PAY_DOCTORATE*10
	containertype = /obj/storage/crate
	containername = "Artifact Research Kit"

/datum/supply_packs/complex/toilet_kit
	name = "Bathroom Kit"
	desc = "x4 Toilet Frames, x1 Sink Frame, x1 Shower Head Frame, x1 Bathtub Frame."
	category = "Civilian Department"
	frames = list(/obj/item/storage/toilet = 4,
					/obj/machinery/shower,
					/obj/machinery/bathtub,
					/obj/submachine/chef_sink/chem_sink)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Bathroom Kit"

/datum/supply_packs/complex/sonic_shower
	name = "Sonic Showerheads"
	desc = "Two fancy cleaning heads capable of vibrating dirt and grime off of you without the need for water."
	category = "Basic Materials"
	frames = list(/obj/machinery/sonic_shower = 2)
	cost = PAY_TRADESMAN*5
	containertype = /obj/storage/crate/packing
	containername = "Sonic Showerheads"

/datum/supply_packs/complex/kitchen_kit
	name = "Kitchen Kit"
	desc = "x1 Fridge, x1 Oven Frame, x1 Mixer Frame, x1 Sink Frame, x1 Deep Fryer Frame, x1 Food Processor Frame, x1 FoodTech Frame, x1 Meat Spike Frame, x1 Gibber Frame."
	category = "Civilian Department"
	contains = list(/obj/storage/secure/closet/fridge)
	frames = list(/obj/submachine/chef_oven,
					/obj/machinery/mixer,
					/obj/submachine/chef_sink,
					/obj/machinery/deep_fryer,
					/obj/submachine/foodprocessor,
					/obj/machinery/vending/kitchen,
					/obj/kitchenspike,
					/obj/machinery/gibber)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Kitchen Kit"

/datum/supply_packs/complex/bartender_kit
	name = "Bar Kit"
	desc = "x2 Glassware boxes, x1 Alcohol Dispenser Frame, x1 Soda Fountain Frame, x1 Ice Cream Machine Frame, x1 Kitchenware Recycler Frame, x1 Microwave Frame."
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/glassbox = 2)
	frames = list(/obj/machinery/microwave,
					/obj/machinery/chem_dispenser/alcohol,
					/obj/machinery/chem_dispenser/soda,
					/obj/submachine/ice_cream_dispenser,
					/obj/machinery/glass_recycler)
	cost = PAY_TRADESMAN*10
	containertype = /obj/storage/crate
	containername = "Bar Kit"

/datum/supply_packs/complex/arcade
	name = "Arcade Machine"
	desc = "x1 Arcade Machine Frame."
	category = "Civilian Department"
	frames = list(/obj/machinery/computer/arcade)
	cost = PAY_UNTRAINED*10
	containertype = /obj/storage/crate
	containername = "Arcade Machine"

/datum/supply_packs/complex/telescience_kit
	name = "Telescience Kit"
	desc = "x1 Science Teleporter Console Frame, x2 Data Terminal Frames, x1 Telepad Frames."
	category = "Research Department"
	frames = list(/obj/machinery/networked/teleconsole,
					/obj/machinery/networked/telepad,
					/obj/machinery/power/data_terminal = 2)
	cost = PAY_IMPORTANT*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Telescience"

/datum/supply_packs/complex/security_camera
	name = "Security Camera kit"
	desc = "x5 Security Camera Frames."
	category = "Security Department"
	frames = list(/obj/machinery/camera = 5)
	cost = PAY_DOCTORATE*10
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Security Camera"

/datum/supply_packs/complex/medical_kit
	name = "Medbay kit"
	desc = "x1 Defibrillator, x2 Hyposprays, x1 Medical Belt, x1 NanoMed Frame, x1 Medical Records Computer Frame."
	category = "Medical Department"
	contains = list(/obj/item/robodefibrillator,
					/obj/item/storage/belt/medical,
					/obj/item/reagent_containers/hypospray = 2)
	frames = list(/obj/machinery/optable,
					/obj/machinery/vending/medical)
	cost = PAY_DOCTORATE*10
	containertype = /obj/storage/crate
	containername = "Medbay kit"

/datum/supply_packs/complex/operating_kit
	name = "Operating Room kit"
	desc = "x1 Staple Gun, x1 Defibrillator, x2 Scalpel, x2 Circular Saw, x1 Hemostat, x2 Suture, x1 Enucleation Spoon, x1 Medical Fabricator Frame, x1 Operating Table Frame."
	category = "Medical Department"
	contains = list(/obj/item/staple_gun,
					/obj/item/robodefibrillator,
					/obj/item/scalpel = 2,
					/obj/item/circular_saw = 2,
					/obj/item/hemostat,
					/obj/item/scissors/surgical_scissors,
					/obj/item/suture,
					/obj/item/surgical_spoon)
	frames = list(/obj/machinery/manufacturer/medical,
					/obj/machinery/optable,
					/obj/machinery/vending/medical)
	cost = PAY_DOCTORATE*10
	containertype = /obj/storage/crate
	containername = "Operating Room kit"

/datum/supply_packs/complex/field_generator
	name = "Field Generator Crate (Cardlocked \[Engineering])"
	desc = "x4 Field Generator Frames. The four goal-posts needed to contain a singularity."
	category = "Engineering Department"
	frames = list(/obj/machinery/field_generator = 4)
	cost = PAY_EMBEZZLED
	containertype = /obj/storage/secure/crate
	containername = "Field Generator Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/complex/winter
	name = "Cold Weather Gear"
	desc = "x5 Winter Coats, x2 Chicken Soup, x2 Coffee, x2 Space Heaters. Warm winter gear to ward off the winter chills."
	contains = list(/obj/item/clothing/suit/wintercoat = 5,
					/obj/item/reagent_containers/food/drinks/chickensoup = 2,
					/obj/item/reagent_containers/food/drinks/coffee = 2)
	frames = list(/obj/machinery/space_heater = 2)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate/wooden
	containername = "Cold Weather Gear"

/datum/supply_packs/complex/hydrostarter
	name = "Hydroponics: Starter Crate"
	desc = "x2 Watering Cans, x4 Compost Bags, x2 Weedkiller bottles, x2 Plant Analyzers, x4 Plant Tray Frames."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/glass/wateringcan = 2,
					/obj/item/reagent_containers/glass/compostbag = 4,
					/obj/item/reagent_containers/glass/bottle/weedkiller = 2,
					/obj/item/plantanalyzer = 2)
	frames = list(/obj/machinery/plantpot = 4)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Hydroponics: Starter Crate"

/datum/supply_packs/complex/robotics_kit
	name = "Robotics kit"
	desc = "x1 Staple Gun, x1 Scalpel, x1 Circular Saw, x1 Robotics Fabricator Frame, x1 Operating Table Frame, x1 Module Rewriter Frame, x1 Recharge Station Frame."
	category = "Medical Department"
	contains = list(/obj/item/staple_gun,
					/obj/item/scalpel,
					/obj/item/circular_saw,
					/obj/item/circuitboard/robot_module_rewriter)
	frames = list(/obj/machinery/manufacturer/robotics,
					/obj/machinery/optable,
					/obj/machinery/recharge_station)
	cost = PAY_DOCTORATE*10
	containertype = /obj/storage/crate
	containername = "Robotics kit"

/datum/supply_packs/complex/genetics_kit
	name = "Genetics kit"
	desc = "x1 DNA Modifier Circuitboard, x1 DNA Scanner Circuitboard."
	category = "Medical Department"
	contains = list(/obj/item/circuitboard/genetics)
	frames = list(/obj/machinery/genetics_scanner)
	cost = PAY_DOCTORATE*10
	containertype = /obj/storage/crate
	containername = "Genetics kit"

/datum/supply_packs/complex/cloner_kit
	name = "Cloning kit"
	desc = "x1 Cloning Console Circuitboard, x1 Cloning Scanner Frame, x1 Cloning Pod Frame, x1 Enzymatic Reclaimer Frame, x1 Clone Rack Frame."
	category = "Medical Department"
	contains = list(/obj/item/circuitboard/cloning)
	frames = list(/obj/machinery/clone_scanner,
					/obj/machinery/clonepod,
					/obj/machinery/clonegrinder,
					/obj/machinery/disk_rack/clone)
	cost = PAY_DOCTORATE*20
	containertype = /obj/storage/crate
	containername = "Cloning kit"

/datum/supply_packs/bureaucrat
	name = "Bureaucracy Supply Crate"
	desc = "x2 Paper bins, x2 Folders, x2 Pencils, x2 Pens, x2 Stamps, x1 Fancy Pen."
	contains = list(/obj/item/paper_bin,
					/obj/item/paper_bin,
					/obj/item/folder,
					/obj/item/folder,
					/obj/item/pen/pencil,
					/obj/item/pen/pencil,
					/obj/item/pen,
					/obj/item/pen,
					/obj/item/stamp,
					/obj/item/stamp,
					/obj/item/pen/fancy)
	cost = PAY_TRADESMAN*2
	containertype = /obj/storage/crate
	containername = "Bureaucracy Supply Crate"


/datum/supply_packs/ink_refill
	name = "Printing Press Refill Supplies"
	desc = "x1 Ink Cartridge, x2 Paper Bins."
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/ink,
					/obj/item/paper_bin,
					/obj/item/paper_bin)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Refill Crate"

/datum/supply_packs/ink_upgrade
	name = "Printing Press Colour Module"
	desc = "x1 Ink Color Upgrade."
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/colors)
	cost = PAY_IMPORTANT*3
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Colour Crate"

/datum/supply_packs/custom_books
	name = "Printing Press Custom Cover Module"
	desc = "x1 Custom Cover Upgrade."
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/books)
	cost = PAY_IMPORTANT*2
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Cover Crate"

/datum/supply_packs/printing_press
	name = "Printing Press"
	desc = "x1 Printing Press Frame."
	category = "Civilian Department"
	contains = list(/obj/item/electronics/frame/press_frame,
					/obj/item/paper/press_warning)
	cost = PAY_IMPORTANT*5
	containertype = /obj/storage/crate/wooden
	containername = "Printing Press Crate"

/datum/supply_packs/percussion_band_kit
	name = "Percussion Band Kit"
	desc = "x1 Tambourine, x1 Cowbell, x1 Triangle."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Percussion Band Kit"
	contains = list(/obj/item/instrument/tambourine,/obj/item/instrument/triangle,/obj/item/instrument/cowbell)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/banjo
	name = "Banjo Kit"
	desc = "x1 Banjo."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Banjo Kit"
	contains = list(/obj/item/instrument/banjo)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/news
	name = "Old Newspaper Set"
	desc = "x8 Old Newspapers. Please take them off our hands."
	cost = PAY_TRADESMAN
	containername = "Newspaper Crate"
	contains = list(/obj/item/paper/newspaper/rolled = 8)
	containertype = /obj/storage/crate/packing

/datum/supply_packs/electricguitar
	name = "Electric Guitar Kit"
	desc = "x1 Electric Guitar."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Electric Guitar Kit"
	contains = list(/obj/item/instrument/electricguitar)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/guitar
	name = "Acoustic Guitar Kit"
	desc = "x1 Acoustic Guitar."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Acoustic Guitar Kit"
	contains = list(/obj/item/instrument/guitar)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/bass
	name = "Bass Guitar Kit"
	desc = "x1 Bass Guitar."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Bass Guitar Kit"
	contains = list(/obj/item/instrument/bass)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/keytar
	name = "Keytar Kit"
	desc = "x1 Keytar."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*2
	containername = "Keytar Kit"
	contains = list(/obj/item/instrument/keytar)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/complex/player_piano
	name = "Player Piano Kit"
	desc = "x1 Player Piano Kit."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*3
	containername = "Player Piano Kit"
	frames = list(/obj/player_piano)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/complex/piano
	name = "Piano Kit"
	desc = "x1 Piano Kit."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*3
	containername = "Piano Kit"
	frames = list(/obj/item/instrument/large/piano)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/complex/piano_grand
	name = "Grand Piano Kit"
	desc = "x1 Grand Piano Kit."
	category = "Civilian Department"
	cost = PAY_TRADESMAN*3
	containername = "Grand Piano Kit"
	frames = list(/obj/item/instrument/large/piano/grand)
	containertype = /obj/storage/crate/wooden

//Western
/datum/supply_packs/west_coats
	name = "Dusty Old Coats"
	desc = "x4 Coats. In various colors."
	category = "Civilian Department"
	contains = list(/obj/item/clothing/suit/gimmick/guncoat,
			/obj/item/clothing/suit/gimmick/guncoat/black,
			/obj/item/clothing/suit/gimmick/guncoat/tan,
			/obj/item/clothing/suit/gimmick/guncoat/dirty)
	cost = PAY_TRADESMAN*5
	containername = "Dusty Old Clothing Crate"
	containertype = /obj/storage/crate/wooden
