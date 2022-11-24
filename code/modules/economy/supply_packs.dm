
/proc/build_supply_pack_cache()
	qm_supply_cache.Cut()
	for(var/S in concrete_typesof(/datum/supply_packs))
		qm_supply_cache += new S()

/datum/supply_order
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/comment = null
	var/whos_id = null
	var/console_location = null

	proc/create(var/mob/orderer)
		var/obj/storage/S = object.create(orderer)

		if(!isnull(whos_id))
			S.name = "[S.name], Ordered by [whos_id:registered], [comment ? "([comment])":"" ]"
		else
			S.name = "[S.name] [comment ? "([comment])":"" ]"

		if(comment)
			S.delivery_destination = comment

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

	proc/create(var/mob/creator)
		var/obj/storage/S
		if (!ispath(containertype) && contains.len > 1)
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
	desc = "Nothing (crate only)"
	contains = list()
	cost = 10
	containertype = /obj/storage/crate
	containername = "crate"

/datum/supply_packs/specialops
	name = "Special Ops Supplies"
	desc = "x1 Sleepy Pen, x1 Holographic Disguiser, x1 Signal Jammer, x1 Agent Card, x1 EMP Grenade Kit, x1 Tactical Grenades Kit"
	contains = list(/obj/item/card/id/syndicate,
					/obj/item/storage/box/emp_kit,
					/obj/item/storage/box/tactical_kit,
					/obj/item/pen/sleepypen,
					/obj/item/device/disguiser,
					/obj/item/radiojammer)
	cost = 80000
	containertype = /obj/storage/crate
	containername = "Special Ops Crate"
	syndicate = 1

/datum/supply_packs/paint
	name = "Paint Cans"
	desc = "A selection of random paints."
	contains = list(/obj/item/paint_can/random = 4)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Paint Crate"

/datum/supply_packs/neon_lining
	name = "Neon Lining Crate"
	desc = "For intellectuals that value the aesthetic of the past."
	contains = list(/obj/item/neon_lining/shipped, /obj/item/paper/neonlining)
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Neon Lining Crate"

/datum/supply_packs/metal200
	name = "200 Metal Sheets"
	desc = "x200 Metal Sheets"
	category = "Basic Materials"
	contains = list(/obj/item/sheet/steel)
	amount = 200
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Metal Sheets Crate - 200 pack"

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	desc = "x50 Metal Sheets"
	category = "Basic Materials"
	contains = list(/obj/item/sheet/steel)
	amount = 50
	cost = 500
	containertype = /obj/storage/crate
	containername = "Metal Sheets Crate - 50 pack"

/datum/supply_packs/glass200
	name = "200 Glass Sheets"
	desc = "x200 Glass Sheets"
	category = "Basic Materials"
	contains = list(/obj/item/sheet/glass)
	amount = 200
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Glass Sheets Crate - 200 pack"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	desc = "x50 Glass Sheets"
	category = "Basic Materials"
	contains = list(/obj/item/sheet/glass)
	amount = 50
	cost = 500
	containertype = /obj/storage/crate
	containername = "Glass Sheets Crate - 50 pack"

/datum/supply_packs/dryfoods
	name = "Catering: Dry Goods Crate"
	desc = "x25 Assorted Cooking Ingredients"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/ingredient/flour = 6,
					/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/spaghetti = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/sugar = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 2)
	cost = 750
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Dry Goods Crate"

/datum/supply_packs/meateggdairy
	name = "Catering: Meat, Eggs and Dairy Crate"
	desc = "x25 Assorted Cooking Ingredients"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/hotdog = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/cheese = 4,
					/obj/item/reagent_containers/food/drinks/milk = 4,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/salmon,
					/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white,
					/obj/item/kitchen/food_box/egg_box = 3,
					/obj/item/storage/box/bacon_kit = 2)
	cost = 1500
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Meat, Eggs and Dairy Crate"

/datum/supply_packs/produce
	name = "Catering: Fresh Produce Crate"
	desc = "x20 Assorted Cooking Ingredients"
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
	cost = 1500
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Fresh Produce Crate"

/datum/supply_packs/condiment
	name = "Catering: Condiment Crate"
	desc = "x25 Assorted Cooking Ingredients"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/condiment/chocchips = 3,
					/obj/item/reagent_containers/food/snacks/condiment/cream = 2,
					/obj/item/reagent_containers/food/snacks/condiment/custard,
					/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 3,
					/obj/item/reagent_containers/food/snacks/condiment/ketchup = 4,
					/obj/item/reagent_containers/food/snacks/condiment/mayo = 4,
					/obj/item/reagent_containers/food/snacks/condiment/syrup = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 3,
					/obj/item/reagent_containers/food/snacks/ingredient/honey = 2)
	cost = 750
	containertype = /obj/storage/crate/freezer
	containername = "Catering: Condiment Crate"

/datum/supply_packs/electrical
	name = "Electrical Supplies Crate (red) - 2 pack"
	desc = "x2 Cabling Box (14 cable coils total)"
	contains = list(/obj/item/storage/box/cablesbox = 2)
	containername = "Electrical Supplies Crate - 2 pack"
	category = "Basic Materials"
	cost = 2000
	containertype = /obj/storage/crate

/datum/supply_packs/engineering
	name = "Engineering Crate"
	desc = "x2 Mechanical Toolbox, x2 Welding Mask, x2 Insulated Coat"
	category = "Engineering Department"
	contains = list(/obj/item/storage/toolbox/mechanical = 2,
					/obj/item/clothing/head/helmet/welding = 2,
					/obj/item/clothing/suit/wintercoat/engineering = 2)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Engineering Crate"

/datum/supply_packs/electool
	name = "Electrical Maintenance Crate"
	desc = "x2 Electrical Toolbox, x2 Multi-Tool, x2 Insulated Gloves"
	category = "Engineering Department"
	contains = list(/obj/item/storage/toolbox/electrical = 2,
					/obj/item/device/multitool = 2,
					/obj/item/clothing/gloves/yellow = 2)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "Electrical Maintenance Crate"

/datum/supply_packs/powercell
	name = "Power Cell Crate"
	desc = "x3 Power Cell"
	category = "Engineering Department"
	contains = list(/obj/item/cell/charged = 3)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "Power Cell Crate"

/datum/supply_packs/firefighting
	name = "Firefighting Supplies Crate"
	desc = "x3 Extinguisher, x3 Firefighting Grenade, x2 Firesuit, x2 Firefighter Helmets"
	category = "Engineering Department"
	contains = list(/obj/item/extinguisher = 3,
	/obj/item/chem_grenade/firefighting = 3,
	/obj/item/clothing/suit/fire = 2,
	/obj/item/clothing/head/helmet/firefighter = 2)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Firefighting Supplies Crate"

/datum/supply_packs/engineering_grenades
	name = "Station Pressurization Crate"
	desc = "4x Red Oxygen Grenades, x4 Metal Foam Grenades"
	category = "Engineering Department"
	contains = list(/obj/item/old_grenade/oxygen = 4, /obj/item/chem_grenade/metalfoam = 4)
	cost = 1200
	containertype = /obj/storage/crate
	containername = "Station Pressurization Crate"

/datum/supply_packs/disposal_pipe_cart
	name = "Disposal Pipe Dispenser Cart"
	desc = "Has a pesky staff assistant stolen your cart?"
	category = "Engineering Department"
	contains = list(/obj/machinery/disposal_pipedispenser/mobile)
	cost = 4000
	containertype = /obj/storage/crate
	containername = "Replacement Disposal Cart Crate"

/datum/supply_packs/gas_filtration
	name = "Gas Filtration Machinery"
	desc = "A two-piece set consisting of a Portable Air Pump and a Portable Air Scrubber."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/scrubber, /obj/machinery/portable_atmospherics/pump)
	cost = 5000
	containertype = /obj/storage/crate
	containername = "Filtration Machinery Crate"

/datum/supply_packs/generator
	name = "Experimental Local Generator"
	desc = "x1 Experimental Local Generator"
	category = "Engineering Department"
	contains = list(/obj/machinery/power/lgenerator)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "Experimental Local Generator Crate"

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
	cost = 1000
	containertype = /obj/storage/crate/medical
	containername = "Medical: First Aid Crate"

/datum/supply_packs/medicalchems
	name = "Medical: Medical Reservoir Crate"
	desc = "x4 Assorted reservoir tanks, x2 Sedative bottles, x2 Hyposprays, x1 Auto-mender, x2 Brute Auto-mender Refill Cartridges, x2 Burn Auto-mender Refill Cartridges, x1 Syringe Kit"
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
	cost = 2300
	containertype = /obj/storage/crate/medical
	containername = "Medical Crate"

/datum/supply_packs/complex/glass_recycler
	name = "Glass Recycler"
	desc = "x1 Kitchenware Recycler, a tabletop machine allowing you to recycle reclaimed glass into many different types of glassware"
	category = "Civilian Department"
	contains = list(/obj/item/electronics/soldering)
	frames = list(/obj/machinery/glass_recycler)
	cost = 3000
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
	cost = 500
	containertype = /obj/storage/crate
	containername = "Janitorial Supplies"

/datum/supply_packs/hydronutrient
	name = "Hydroponics: Nutrient Crate"
	desc = "Five bulk jugs of the most essential plant nutrients"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/glass/jug/saltpetrebulk,
					/obj/item/reagent_containers/glass/jug/ammoniabulk,
					/obj/item/reagent_containers/glass/jug/potashbulk,
					/obj/item/reagent_containers/glass/jug/mutadonebulk,
					/obj/item/reagent_containers/glass/jug/mutagenicbulk)
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Hydroponics: Nutrient Crate"

/datum/supply_packs/mining
	name = "Mining Equipment"
	desc = "x1 Powered Pickaxe, x1 Power Hammer, x1 Optical Meson Scanner, x1 Geological Scanner, x2 Mining Satchel, x3 Mining Explosives"
	category = "Engineering Department"
	contains = list(/obj/item/mining_tool/power_pick,
					/obj/item/mining_tool/powerhammer,
					/obj/item/clothing/glasses/meson,
					/obj/item/oreprospector,
					/obj/item/satchel/mining = 2,
					/obj/item/breaching_charge/mining = 3)
	cost = 500
	containertype = /obj/storage/secure/crate/plasma
	containername = "Mining Equipment Crate"
	access = null

/datum/supply_packs/monkey4
	name = "Lab Monkey Crate - 4 pack"
	desc = "x4 Monkey, x1 Monkey Translator"
	category = "Research Department"
	contains = list(/mob/living/carbon/human/npc/monkey = 4,
						/obj/item/clothing/mask/monkey_translator)
	cost = 2500
	containertype = /obj/storage/secure/crate/medical/monkey
	containername = "Lab Monkey Crate"
	hidden = 1

/datum/supply_packs/monkey_restock
	name = "ValuChimp Restock cartridge"
	desc = "Every chef's dream! Or a nightmare. Depends."
	category = "Civilian Department"
	contains = list(/obj/item/vending/restock_cartridge/monkey)
	cost = 7500
	containertype = /obj/storage/crate
	containername = "ValuChimp restock crate"
	hidden = 1

/datum/supply_packs/bee
	name = "Honey Production Kit"
	desc = "For use with existing hydroponics bay."
	category = "Civilian Department"
	contains = list(/obj/item/bee_egg_carton = 5)
	cost = 450
	containertype = /obj/storage/crate/bee
	containername = "Honey Production Kit"
	create(var/sp, var/mob/creator)
		var/obj/storage/secure/crate/bee/beez=..()
		for(var/obj/item/bee_egg_carton/carton in beez)
			carton.ourEgg.blog = "ordered by [key_name(creator)]|"
		return beez

/datum/supply_packs/chemical
	name = "Chemistry Resupply Crate"
	desc = "x6 Reagent Bottles, x1 Beaker Box, x1 Mechanical Dropper, x1 Spectroscopic Goggles, x1 Reagent Scanner"
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
	cost = 500
	containertype = /obj/storage/secure/crate/plasma
	containername = "Chemistry Resupply Crate"


// Added security resupply crate (Convair880).
/datum/supply_packs/security_resupply
	name = "Weapons Crate - Security Assistant Equipment (Cardlocked \[Security Equipment])"
	desc = "x1 Security Assistant Requisition Token, 1x Armoured Vest, 1x Helmet, x1 Handcuff Kit"
	category = "Security Department"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/head/helmet/hardhat/security,
					/obj/item/requisition_token/security/assistant,
					/obj/item/storage/box/handcuff_kit)
	cost = 6900 //nice
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/security_upgrade
	name = "Weapons Crate - Experimental Security Equipment (Cardlocked \[Security Equipment])"
	desc = "1x Clock 180, x1 Elite Security Helmet, x1 Lethal Grenade Kit, 1x Experimental Grenade Kit"
	category = "Security Department"
	contains = list(/obj/item/gun/kinetic/clock_188/boomerang,
					/obj/item/storage/box/QM_grenadekit_security,
					/obj/item/storage/box/QM_grenadekit_experimentalweapons,
					/obj/item/clothing/head/helmet/hardhat/security/improved)
	cost = 12000
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Experimental Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/security_brig_resupply
	name = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
	desc = "x1 Port-a-Brig and Remote"
	category = "Security Department"
	contains = list(/obj/machinery/port_a_brig,
					/obj/item/remote/porter/port_a_brig)
	cost = 1000
	containertype = /obj/storage/secure/crate/weapon
	containername = "Security Containment Crate - Security Equipment (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons2
	name = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
	desc = "x2 Phaser Gun"
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_gun = 2)
	cost = 5000
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Phasers (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons3
	name = "Weapons Crate - Micro Phasers (Cardlocked \[Security Equipment])"
	desc = "x4 Micro Phaser Gun"
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_small = 4)
	cost = 5000
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Micro Phasers (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/weapons4
	name = "Weapons Crate - Macro Phaser (Cardlocked \[Armory Equipment])"
	desc = "x1 Macro Phaser Gun"
	category = "Security Department"
	contains = list(/obj/item/gun/energy/phaser_huge = 1)
	cost = 10000
	containertype = /obj/storage/secure/crate/weapon
	containername = "Weapons Crate - Macro Phaser (Cardlocked \[Armory Equipment])"
	access = access_armory

/datum/supply_packs/evacuation
	name = "Emergency Equipment"
	desc = "x4 Floor Bot, x4 Gas Tanks, x4 Gas Mask, x4 Emergency Space Suit Set"
	contains = list(/obj/machinery/bot/floorbot = 4,
	/obj/item/clothing/mask/gas = 4,
	/obj/item/tank/mini_oxygen = 4,
	/obj/item/tank/air = 2,
	/obj/item/clothing/head/emerg = 4,
	/obj/item/clothing/suit/space/emerg = 4)
	cost = 1500
	containertype = /obj/storage/crate/internals
	containername = "Emergency Equipment"

/datum/supply_packs/alcohol
	name = "Alcohol Resupply Crate"
	desc = "A collection of nine assorted liquors in case of stationwide alcohol deficiency"
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
	cost = 400
	containertype = /obj/storage/crate
	containername = "Alcohol Crate"

/datum/supply_packs/cocktailparty
	name = "Cocktail Party Supplies"
	desc = "All the equipment you need to be the next up and coming amateur mixologist."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/drinks/cocktailshaker,
					/obj/item/storage/box/cocktail_umbrellas = 2,
					/obj/item/storage/box/cocktail_doodads = 2,
					/obj/item/storage/box/fruit_wedges = 1,
					/obj/item/shaker/salt = 1)
	cost = 100
	containertype = /obj/storage/crate
	containername = "Cocktail Party Supplies"

/datum/supply_packs/robot
	name = "Robotics Crate"
	desc = "x1 Securitron, x1 Floorbot, x1 Cleanbot, x1 Medibot, x1 Firebot"
	category = "Medical Department"
	contains = list(/obj/machinery/bot/secbot,
					/obj/machinery/bot/floorbot,
					/obj/machinery/bot/cleanbot,
					/obj/machinery/bot/medbot,
					/obj/machinery/bot/firebot)
	cost = 7500
	containertype = /obj/storage/crate
	containername = "Robotics Crate"

/datum/supply_packs/mulebot
	name = "Replacement Mulebot"
	desc = "x1 Mulebot"
	category = "Engineering Department"
	contains = list("/obj/machinery/bot/mulebot")
	cost = 750
	containertype = /obj/storage/crate
	containername = "Replacement Mulebot Crate"

/datum/supply_packs/dressup
	name = "Novelty Clothing Crate"
	desc = "Assorted Novelty Clothing"
	contains = list(/obj/random_item_spawner/dressup)
	cost = 15000
	containertype = /obj/storage/crate/packing
	containername = "Novelty Clothing Crate"

#ifdef HALLOWEEN
/datum/supply_packs/halloween
	name = "Spooky Crate"
	desc = "WHAT COULD IT BE? SPOOKY GHOSTS?? TERRIFYING SKELETONS??? DARE YOU FIND OUT?!"
	contains = list(/obj/item/storage/goodybag = 6)
	cost = 250
	containertype = /obj/storage/crate
	containername = "Spooky Crate"
#endif

#ifdef XMAS
/datum/supply_packs/xmas
	name = "Holiday Supplies"
	desc = "Winter joys from the workshop of Santa Claus himself! (Amusing Trivia: Santa Claus does not infact exist.)"
	contains = list(/obj/item/clothing/head/helmet/space/santahat = 3,
					/obj/item/wrapping_paper/xmas = 2,
					/obj/item/scissors,
					/obj/item/reagent_containers/food/drinks/eggnog = 2,
					/obj/item/a_gift/festive = 2)
	cost = 500
	containertype = /obj/storage/crate/xmas
	containername = "Holiday Supplies"
#endif

/datum/supply_packs/party
	name = "Party Supplies"
	desc = "Perfect for celebrating any special occasion!"
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
	cost = 750
	containertype = /obj/storage/crate
	containername = "Party Supplies"

/datum/supply_packs/glowsticks
	name = "Emergency Glowsticks Crate - 4 pack"
	desc = "x4 Glowsticks Box (28 glowsticks total)"
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/glowstickbox = 4)
	cost = 500
	containertype = /obj/storage/crate
	containername = "Emergency Glowsticks Crate - 4 pack"

/datum/supply_packs/glowsticksassorted
	name = "Assorted Glowsticks Crate - 4 pack"
	desc = "Everything you need for your very own DIY rave!"
	contains = list(/obj/item/storage/box/glowstickbox/assorted = 4)
	cost = 600
	containertype = /obj/storage/crate
	containername = "Assorted Glowsticks Crate - 4 pack"

/datum/supply_packs/portable_fueltank
	name = "Portable Welding Fuel Tank"
	desc = "A single transportable fuel tank, for when you're on the move."
	category = "Basic Materials"
	contains = list(/obj/item/reagent_containers/food/drinks/fueltank)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Portable Welding Tank Crate"

/datum/supply_packs/fueltank
	name = "Welding Fuel Tank"
	desc = "1x Welding Fuel Tank"
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/fueltank)
	cost = 4000
	containertype = /obj/storage/crate
	containername = "Welding Fuel Tank crate"

/datum/supply_packs/foamtank
	name = "Firefighting Foam tank"
	desc = "1x Firefighting Foam Tank"
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/foamtank)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Firefighting Foamtank crate"

/datum/supply_packs/watertank
	name = "High Capacity Watertank"
	desc = "1x High Capacity Watertank"
	category = "Basic Materials"
	contains = list(/obj/reagent_dispensers/watertank/big)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "High Capacity Watertank crate"

/datum/supply_packs/compostbin
	name = "Compost Bin"
	desc = "1x Compost Bin"
	category = "Civilian Department"
	contains = list(/obj/reagent_dispensers/compostbin)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Compost Bin crate"

/datum/supply_packs/office
	name = "Office Supply Crate"
	desc = "x4 Paper Bins, x2 Clipboards, x1 Sticky Note Box, x5 Writing Implement Sets, x1 Stapler, x1 Scissors, x2 Canvas"
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
	cost = 250
	containername = "Office Supply Crate"

// vvv Adding some suggestions from the QM Order Thread (Gannets) vvv

/datum/supply_packs/birds
	name = "Avian Import Kit"
	desc = "x5 hand-reared birds to help brighten your workplace."
	category = "Civilian Department"
	contains = list(/obj/critter/parrot/random = 5)
	cost = 2000
	containertype = /obj/storage/crate/packing
	containername = "Avian Import Kit"

/datum/supply_packs/animal
	name = "Animal Import Kit"
	desc = "A random pile of animals."
	category = "Civilian Department"
	contains = list (/obj/random_item_spawner/critter)
	cost = 2000
	containertype = /obj/storage/crate/packing
	containername = "Animal Import Kit"

/datum/supply_packs/takeout_chinese
	name = "Golden Gannet Delivery"
	desc = "A Space Chinese meal for two, delivered galaxy-wide."
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/food/snacks/takeout = 2,
					/obj/item/reagent_containers/food/snacks/fortune_cookie = 2,
					/obj/item/kitchen/chopsticks_package = 2)
	cost = 200
	containertype = /obj/storage/crate/packing
	containername = "Golden Gannet Delivery"

/datum/supply_packs/takeout_pizza
	name = "Soft Soft Pizzeria Delivery"
	desc = "Two soft serve pizzas, straight from the oven to your airlock."
	category = "Civilian Department"
	contains = list(/obj/random_item_spawner/pizza = 1,
					/obj/item/reagent_containers/food/snacks/fries = 2,
					/obj/random_item_spawner/cola = 1)
	cost = 200
	containertype = /obj/storage/crate/wooden
	containername = "Soft Soft Pizza Delivery"

/datum/supply_packs/mimicry
	name = "Mimicry Equipment"
	desc = "Entertainers burn bright, only to fade away in silence."
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/costume/mime/alt,
		/obj/item/baguette,
		/obj/item/cigpacket,
		/obj/item/device/light/zippo)
	cost = 500
	containertype = /obj/storage/crate/packing
	containername = "Mimicry Equipment"

/datum/supply_packs/clown
	name = "Comedy Equipment"
	desc = "Entertainers burn bright but die young, outfit a new one with this crate!"
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/costume/clown/recycled,
		/obj/item/instrument/bikehorn,
		/obj/item/bananapeel,
		/obj/item/reagent_containers/food/snacks/pie/cream,
		/obj/item/storage/box/balloonbox)
	cost = 500
	containertype = /obj/storage/crate/packing
	containername = "Comedy Equipment"

/datum/supply_packs/ID_gear
	name = "Identity Kit"
	desc = "For HOP use only. Certainly not for identity fraud."
	contains = list(/obj/item/storage/box/PDAbox,
					/obj/item/storage/box/id_kit)
	cost = 1500
	containertype = /obj/storage/secure/crate
	containername = "Identity Kit"
	access = access_heads

/datum/supply_packs/prosphetics
	name = "Prosthetic Augmentation Kit"
	desc = "Replace your feeble flesh with these mechanical substitutes."
	category = "Medical Department"
	contains = list(/obj/random_item_spawner/prosthetics)
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Prosthetic Augmentation Kit"

/datum/supply_packs/restricted_medicine
	name = "Restricted Medicine Shipment"
	desc = "A shipment of specialised medicines. Card-locked to medical access."
	category = "Medical Department"
	contains = list(/obj/item/reagent_containers/glass/bottle/omnizine,
					/obj/item/reagent_containers/glass/bottle/pfd = 2,
					/obj/item/reagent_containers/glass/bottle/pentetic,
					/obj/item/reagent_containers/glass/bottle/haloperidol,
					/obj/item/reagent_containers/glass/bottle/ether)
	cost = 6000
	containertype = /obj/storage/secure/crate
	containername = "Restricted Medicine Shipment (Cardlocked \[Medical])"
	access = access_medical_director

/datum/supply_packs/cyborg
	name = "Cyborg Component Crate"
	desc = "Build your very own walking science nightmare! (Brain not included.)"
	category = "Medical Department"
	contains = list(/obj/item/parts/robot_parts/robot_frame,
					/obj/item/parts/robot_parts/head/sturdy,
					/obj/item/parts/robot_parts/chest/standard,
					/obj/item/parts/robot_parts/arm/left/sturdy,
					/obj/item/parts/robot_parts/arm/right/sturdy,
					/obj/item/parts/robot_parts/leg/left/standard,
					/obj/item/parts/robot_parts/leg/right/standard,
					/obj/item/cable_coil)
	cost = 4500
	containertype = /obj/storage/crate/wooden
	containername = "Junior Medical Science Set: For Ages 7+"

/datum/supply_packs/rcd
	name = "Rapid-construction-device Replacement"
	desc = "Contains one empty rapid-construction-device."
	category = "Basic Materials"
	contains = list(/obj/item/rcd)
	cost = 60000
	containertype = /obj/storage/crate/wooden
	containername = "RCD Replacement"

/datum/supply_packs/buddy
	name = "Thinktronic Build Your Own Buddy Kit"
	desc = "Assemble your very own working Robuddy, one part per week."
	contains = list(/obj/item/guardbot_frame,
					/obj/item/guardbot_core,
					/obj/item/cell,
					/obj/item/parts/robot_parts/arm/right/sturdy,
					/obj/random_item_spawner/buddytool)
	cost = 7500
	containertype = /obj/storage/crate/wooden
	containername = "Robuddy Kit"

/datum/supply_packs/meteor
	name = "Meteor Shield System"
	desc = "It'll do in a pinch but your ship should really have it's own shields."
	contains = list(/obj/machinery/shieldgenerator/meteorshield = 4)
	cost = 2500
	containertype = /obj/storage/crate/wooden
	containername = "Meteor Shield System"

/datum/supply_packs/reclaimer
	name = "Reclaimed Reclaimer"
	desc = "Jeez, be more careful with it next time!"
	category = "Basic Materials"
	contains = list(/obj/machinery/portable_reclaimer)
	cost = 1000
	containertype = /obj/storage/crate/packing
	containername = "Reclaimed Reclaimer"

/datum/supply_packs/morgue
	name = "Morgue Supplies"
	desc = "The morgue can only fit so many clowns."
	category = "Medical Department"
	contains = list(/obj/item/body_bag = 10,
					/obj/item/reagent_containers/glass/bottle/formaldehyde,
					/obj/item/reagent_containers/syringe,
					/obj/item/storage/bible)
	cost = 10000
	containertype = /obj/storage/closet/coffin
	containername = "Morgue Supplies"

/datum/supply_packs/computer
	name = "Home Networking Kit"
	desc = "Build your own state of the art computer system! (Contents may vary.)"
	contains = list(/obj/item/sheet/glass/fullstack,
					/obj/item/sheet/steel/fullstack,
					/obj/item/cable_coil = 3,
					/obj/item/motherboard,
					/obj/random_item_spawner/peripherals,
					/obj/random_item_spawner/circuitboards)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "Home Networking Kit"

/datum/supply_packs/candle
	name = "Candle Crate"
	desc = "Perfect for setting the mood."
	contains = list(/obj/item/device/light/candle = 3,
					/obj/item/device/light/candle/small = 6,
					/obj/item/matchbook)
	cost = 500
	containertype = /obj/storage/crate/packing
	containername = "Candle Crate"

/datum/supply_packs/microbrew
	name = "Home Distillery Kit"
	desc = "Turn Cargo into a microbrewery."
	contains = list(/obj/reagent_dispensers/still,
					/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher = 2,
					/obj/item/reagent_containers/food/drinks/bottle/soda = 6)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "Home Distillery Kit"

/datum/supply_packs/bloodbags
	name = "Blood Bank"
	desc = "An emergency supply of blood."
	category = "Medical Department"
	contains = list (/obj/item/reagent_containers/iv_drip/blood = 4)
	cost = 3000
	containertype = /obj/storage/crate/medical
	containername = "Blood Bank"

/datum/supply_packs/singularity_generator
	name = "Singularity Generator Crate"
	desc = "An extremely unstable gravitational singularity, stored in a hi-tech jam jar, fired directly at your current location."
	category = "Engineering Department"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 100000
	containertype = /obj/storage/secure/crate
	containername = "Singularity Generator Crate (Cardlocked \[Chief Engineer])"
	access = access_engineering_chief

/datum/supply_packs/emitter
	name = "Emitter Crate"
	desc = "Contains one emitter, for energizing field generators. You'll need a few of these."
	category = "Engineering Department"
	contains = list(/obj/machinery/emitter)
	cost = 15000
	containertype = /obj/storage/secure/crate
	containername = "Emitter Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/rad_collector
	name = "Radiation Collector Crate"
	desc = "Four collector arrays and one controller, to harvest radiation from the singularity."
	category = "Engineering Department"
	contains = list(/obj/item/electronics/frame/collector_array = 4,
					/obj/item/electronics/frame/collector_control,
					/obj/item/electronics/soldering)
	cost = 5000
	containertype = /obj/storage/secure/crate
	containername = "Radiation Array Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/radiation_emergency
	name = "Radioactive Emergency Supplies"
	desc = "Equipment for dealing with a radioactive emergency. No, the crate itself is not radioactive."
	category = "Basic Materials"
	contains = list(/obj/item/clothing/suit/rad = 4,
					/obj/item/clothing/head/rad_hood = 4,
					/obj/item/storage/pill_bottle/antirad = 2,
					/obj/item/reagent_containers/emergency_injector/anti_rad = 4,
					/obj/item/device/geiger = 2)
	cost = 2000
	containertype = /obj/storage/crate/wooden
	containername = "Radiation Emergency Supplies"

/datum/supply_packs/eva
	name = "EVA Equipment Crate"
	desc = "Gear for enabling mobility in major hull damage scenarios."
	category = "Basic Materials"
	contains = list(/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/mask/gas/emergency,
					/obj/item/tank/jetpack,
					/obj/item/clothing/shoes/magnetic)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "EVA Equipment Crate"

/datum/supply_packs/XL_air_canister
	name = "Extra Large Air Mix Canister"
	desc = "Spare canister filled with a mix of nitrogen, oxygen and minimal amounts of carbon dioxide. Used for emergency re-pressurisation efforts."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/canister/air/large)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "Spare XL Air Mix Canister Crate"

/datum/supply_packs/oxygen_canister
	name = "Spare Oxygen Canister"
	desc = "Spare oxygen canister, for resupplying Engineering's fuel or refilling oxygen tanks."
	category = "Engineering Department"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = 10000
	containertype = /obj/storage/crate/wooden
	containername = "Spare Oxygen Canister Crate"

/datum/supply_packs/abcu
	name = "ABCU Unit Crate"
	desc = "An additional ABCU Unit, for large construction projects."
	category = "Engineering Department"
	contains = list(/obj/machinery/abcu, /obj/item/blueprint_marker)
	cost = 5000
	containertype = /obj/storage/secure/crate
	containername = "ABCU Unit Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/janitor_supplies
	name = "Janitorial Supplies Refill"
	desc = "Supplies to restock your hard-working Janitor."
	category = "Civilian Department"
	contains = list(/obj/item/chem_grenade/cleaner = 4,
					/obj/item/spraybottle/cleaner = 2,
					/obj/item/reagent_containers/glass/bottle/cleaner = 2,
					/obj/item/storage/box/trash_bags,
					/obj/item/storage/box/biohazard_bags)
	cost = 500
	containertype = /obj/storage/crate/packing
	containername = "Janitorial Supplies Refill"

/datum/supply_packs/toolbelts
	name = "Utility Belt Crate"
	desc = "Belts and tools to fill them to appease the staff assistant masses."
	category = "Basic Materials"
	contains = list(/obj/item/storage/belt/utility = 2,
					/obj/item/storage/toolbox/mechanical = 2)
	cost = 750
	containertype = /obj/storage/crate/packing
	containername = "Utility Belt Crate"

/datum/supply_packs/antibio
	name = "Anti-Biological Hazard Supplies"
	desc = " A couple of tools for combatting rogue biological lifeforms."
	category = "Security Department"
	contains = list(/obj/item/gun/flamethrower/assembled/loaded,
					/obj/item/storage/box/flaregun)
	cost = 7000
	containertype = /obj/storage/secure/crate
	containername = "Anti-Biological Hazard Supplies (Cardlocked \[Security Equipment])"
	access = access_securitylockers

/datum/supply_packs/counterrevimplant
	name = "Counter-Revolutionary Kit"
	desc = "Implanters and counter-revolutionary implants to supress rebellion against Nanotrasen."
	category = "Security Department"
	contains = list(/obj/item/implantcase/counterrev = 4,
					/obj/item/implanter = 2)
	cost = 6000
	containertype = /obj/storage/crate
	containername = "Counter-Revolutionary Kit"
	access = access_security

/datum/supply_packs/furniture
	name = "Furnishings Crate"
	desc = "An assortment of flat-packed furniture, designed in Space Sweden."
	contains = list(/obj/random_item_spawner/furniture_parts)
	cost = 1500
	containertype = /obj/storage/crate/wooden
	containername = "Furnishings Crate"

/datum/supply_packs/furniture_eventtablered
	name = "Red Event Table Crate"
	desc = "A flat-packed set of tables, each with a fancy red tablecloth."
	contains = list(/obj/item/furniture_parts/table/clothred = 5)
	cost = 25000
	containertype = /obj/storage/crate/wooden
	containername = "Red Event Table Crate"

/datum/supply_packs/furniture_neon
	name = "Neon Furnishings Crate"
	desc = "A flat-packed set of tables and stools, each in eye-searing neon."
	contains = list(/obj/item/furniture_parts/table/neon = 4,
					/obj/item/furniture_parts/stool/neon = 4)
	cost = 20000
	containertype = /obj/storage/crate/wooden
	containername = "Neon Furnishings Crate"

/datum/supply_packs/furniture_scrap
	name = "Scrap Furnishings Crate"
	desc = "A flat-packed set of...trash and scrap parts. I guess you could make furniture out of it?"
	contains = list(/obj/item/furniture_parts/table/scrap = 4,
					/obj/item/furniture_parts/wood_chair/scrap = 4)
	cost = 20000
	containertype = /obj/storage/crate/wooden
	containername = "Scrap Furnishings Crate"

/datum/supply_packs/furniture_regal
	name = "Regal Furnishings Crate"
	desc = "A set of very fancy flat-packed, regal furniture."
	contains = list(/obj/item/furniture_parts/wood_chair/regal = 4,
					/obj/item/furniture_parts/table/regal = 4,
					/obj/item/furniture_parts/decor/regallamp = 2)
	cost = 80000
	containertype = /obj/storage/crate/wooden
	containername = "Regal Furnishings Crate"

/datum/supply_packs/furniture_throne
	name = "Golden Throne"
	desc = "A flat-packed throne. It can't be real gold for that price..."
	contains = list(/obj/item/furniture_parts/throne_gold)
	cost = 150000
	containertype = /obj/storage/crate/wooden
	containername = "Throne Crate"

/datum/supply_packs/hat
	name = "Haberdasher's Crate"
	desc = "A veritable smörgåsbord of head ornaments."
	contains = list(/obj/random_item_spawner/hat)
	cost = 5000
	containertype = /obj/storage/crate/packing
	containername = "Haberdasher's Crate"

/datum/supply_packs/headbands
	name = "Bargain Bows and Bands Box"
	desc = "Headbands for all occasions."
	cost = 2000
	contains = list(/obj/item/clothing/head/headband/giraffe = 1,
					/obj/item/clothing/head/headband/antlers = 1,
					/obj/item/clothing/head/headband/nyan/tiger = 1,
					/obj/item/clothing/head/headband/nyan/leopard = 1,
					/obj/item/clothing/head/headband/nyan/snowleopard = 1,
					/obj/item/clothing/head/headband/bee = 2,
					/obj/item/clothing/head/headband/nyan/random = 1)

/datum/supply_packs/mask
	name = "Masquerade Crate"
	desc = "For hosting a masked ball in the bar."
	contains = list(/obj/random_item_spawner/mask)
	cost = 5000
	containertype = /obj/storage/crate/packing
	containername = "Masquerade Crate"

/datum/supply_packs/shoe
	name = "Shoe Crate"
	desc = "Has an unruly staff assistant stolen all your shoes?"
	contains = list(/obj/random_item_spawner/shoe)
	cost = 2000
	containertype = /obj/storage/crate/packing
	containername = "Shoe Crate"

/datum/supply_packs/kendo
	name = "Kendo Crate"
	desc = "A crate containing two full sets of kendo equipment."
	contains = list(/obj/item/clothing/head/helmet/men = 2,
					/obj/item/clothing/suit/armor/douandtare = 2,
					/obj/item/clothing/gloves/kote = 2,
					/obj/item/shinai_bag,
					/obj/item/storage/box/kendo_box/hakama)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "Kendo Crate"

/datum/supply_packs/sponge
	name = "Sponge Capsule Crate"
	desc = "For all your watery animal needs!"
	contains = list(/obj/item/spongecaps = 1)
	cost = 5000
	containertype = /obj/storage/crate/packing
	containername = "Sponge Capsule Crate"

/datum/supply_packs/candy
	name = "Candy Crate"
	desc = "Proudly bringing sugar comas to your space stations since 2k53."
	contains = list(/obj/item/item_box/heartcandy,
					/obj/item/storage/goodybag,
					/obj/item/item_box/swedish_bag,
					/obj/item/kitchen/peach_rings,
					/obj/item/kitchen/gummy_worms_bag)
	cost = 500
	containertype = /obj/storage/crate
	containername = "Candy Crate"

/datum/supply_packs/light
	name = "Lighting Crate"
	desc = "Afraid of the dark? Lighten up your life with a couple of torches and a pile of glowsticks."
	contains = list(/obj/item/device/light/glowstick = 8,
					/obj/item/device/light/flashlight = 2)
	cost = 500
	containertype = /obj/storage/crate/packing
	containername = "Lighting Crate"

// Kyle2143's vending restock packs

/datum/supply_packs/necessities_vending_restock
	name = "Necessities Vending Machine Restocking Pack"
	desc = "Various Vending Machine Restock Cartridges for necessities"
	contains = list(/obj/item/vending/restock_cartridge/coffee,
					/obj/item/vending/restock_cartridge/snack,
					/obj/item/vending/restock_cartridge/cigarette,
					/obj/item/vending/restock_cartridge/alcohol,
					/obj/item/vending/restock_cartridge/cola,
					/obj/item/vending/restock_cartridge/kitchen,
					/obj/item/vending/restock_cartridge/standard,
					/obj/item/vending/restock_cartridge/capsule)
	cost = 3000
	containertype = /obj/storage/crate
	containername = "Necessities Vending Machine Restocking Pack"

/datum/supply_packs/catering_vending_restock
	name = "Catering Vending Machine Restocking Pack"
	desc = "Various Vending Machine Restock Cartridges for catering"
	contains = list(/obj/item/vending/restock_cartridge/hydroponics,
					/obj/item/vending/restock_cartridge/kitchen)
	cost = 1000
	containertype = /obj/storage/crate
	containername = "Catering Vending Machine Restocking Pack"

/datum/supply_packs/medical_vending_restock
	name = "Medical Vending Machine Restock Pack"
	desc = "Various Vending Machine Restock Cartridges for medical"
	contains = list(/obj/item/vending/restock_cartridge/medical,
					/obj/item/vending/restock_cartridge/medical_public,)
	cost = 2000
	containertype = /obj/storage/crate
	containername = "Medical Vending Machine Restocking Pack"

/datum/supply_packs/security_vending_restock
	name = "Security Vending Machine Restocking Pack"
	desc = "Various Vending Machine Restock Cartridges for security"
	contains = list(/obj/item/vending/restock_cartridge/security,
					/obj/item/vending/restock_cartridge/security_ammo)
	cost = 5000
	containertype = /obj/storage/crate
	containername = "Security Vending Machine Restocking Pack"

/datum/supply_packs/electronics_vending_restock
	name = "Electronics Vending Machine Restocking Pack"
	desc = "Various Vending Machine Restock Cartridges for electronics"
	contains = list(/obj/item/vending/restock_cartridge/mechanics,
					/obj/item/vending/restock_cartridge/computer3,
					/obj/item/vending/restock_cartridge/floppy,
					/obj/item/vending/restock_cartridge/pda)
	cost = 4000
	containertype = /obj/storage/crate
	containername = "Electronics Vending Machine Restocking Pack"

/*
	Umm, apparently the packs below never get added? What's up with that. Construction mode :S -ZeWaka
*/

/datum/supply_packs/banking_kit
	name = "Banking Kit"
	desc = "Circuit Boards: 1x Bank Records, 1x ATM"
	contains = list(/obj/item/circuitboard/atm,
					/obj/item/circuitboard/bank_data)
	hidden = 1
	cost = 10000
	containertype = /obj/storage/crate
	containername = "Banking Kit"

/datum/supply_packs/homing_kit
	name = "Homing Kit"
	desc = "3x Tracking Beacon"
	cost = 1000
	hidden = 1
	contains = list(/obj/item/device/radio/beacon = 3)
	containertype = /obj/storage/crate
	containername = "Homing Kit"


/datum/supply_packs/id_computer
	name = "ID Computer Circuitboard"
	desc = "1x ID Computer Circuitboard"
	hidden = 1
	contains = list(/obj/item/circuitboard/card)
	cost = 10000

/datum/supply_packs/administrative_id
	name = "Administrative ID card"
	desc = "1x Captain level ID"
	contains = list(/obj/item/card/id/captains_spare)
	cost = 2500
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/plasmastone
	name = "Plasmastone"
	desc = "1x Plasmastone"
	contains = list(/obj/item/raw_material/plasmastone)
	cost = 7000
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/baton
	name = "Stun Baton"
	desc = "1x Stun Baton"
	contains = list(/obj/item/baton)
	cost = 3000
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/telecrystal
	name = "Telecrystal"
	desc = "1x Telecrystal"
	contains = list(/obj/item/raw_material/telecrystal)
	cost = 7000
	hidden = 1
	containertype = null
	containername = null

/datum/supply_packs/telecrystal_bulk
	name = "Telecrystal Resupply Pack"
	desc = "10x Telecrystal"
	contains = list(/obj/item/raw_material/telecrystal = 10)
	cost = 63000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Telecrystal Resupply Pack"

/datum/supply_packs/antisingularity
	name = "Anti-Singularity Pack"
	desc = "Everything that the crew needs to take down a rogue singularity."
	category = "Engineering Department"
	contains = list(/obj/item/paper/antisingularity,/obj/item/ammo/bullets/antisingularity = 5,/obj/item/gun/kinetic/antisingularity)
	cost = 10000
	containertype = /obj/storage/crate/classcrate/qm
	containername = "Anti-Singularity Supply Pack"

/datum/supply_packs/conworksupplies
	name = "Construction Equipment"
	desc = "The mothballed tools of our former Construction Workers, in a crate, for you!"
	category = "Engineering Department"
	contains = list(/obj/item/lamp_manufacturer/organic,/obj/item/room_planner,/obj/item/clothing/under/rank/orangeoveralls)
	cost = 7000
	containertype = /obj/storage/secure/crate
	containername = "Construction Equipment"

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
	name = "Mechanics Reconstruction Kit"
	desc = "1x Ruckingenur frame, 1x Manufacturer frame, 1x reclaimer frame, 1x device analyzer, 1x soldering iron"
	category = "Engineering Department"
	contains = list(/obj/item/electronics/scanner,
					/obj/item/electronics/soldering,
					/obj/item/deconstructor)
	frames = list(/obj/machinery/rkit,
					/obj/machinery/manufacturer/mechanic,
					/obj/machinery/portable_reclaimer)
	cost = 35000
	containertype = /obj/storage/crate
	containername = "Mechanics Reconstruction Kit"

#ifndef UNDERWATER_MAP
/datum/supply_packs/complex/mini_magnet_kit
	name = "Small Magnet Kit"
	desc = "1x Magnetizer, 1x Low Performance Magnet Kit, 1x Magnet Chassis Frame, 1x Instructions Manual"
	category = "Engineering Department"
	contains = list(/obj/item/magnetizer,
					/obj/item/magnet_parts/construction/small,
					/obj/item/paper/magnetconstruction)
	frames = list(/obj/machinery/magnet_chassis,
					/obj/machinery/computer/magnet)
	cost = 10000
	containertype = /obj/storage/crate
	containername = "Small Magnet Kit"

/datum/supply_packs/complex/magnet_kit
	name = "Magnet Kit"
	desc = "1x Magnetizer, 1x High Performance Magnet Kit, 1x Magnet Chassis Frame, 1x Instructions Manual"
	category = "Engineering Department"
	contains = list(/obj/item/magnetizer,
					/obj/item/magnet_parts/construction,
					/obj/item/paper/magnetconstruction)
	frames = list(/obj/machinery/magnet_chassis,
					/obj/machinery/computer/magnet)
	cost = 75000
	containertype = /obj/storage/crate
	containername = "Magnet Kit"
#endif

/datum/supply_packs/complex/manufacturer_kit
	name = "Manufacturer Kit"
	desc = "Frames: 1x General Manufacturer, 1x Mining Manufacturer, 1x Science Manufacturer, 1x Gas Extractor, 1x Clothing Manufacturer, 1x Reclaimer"
	category = "Engineering Department"
	frames = list(/obj/machinery/manufacturer/general,
					/obj/machinery/manufacturer/mining,
					/obj/machinery/manufacturer/science,
					/obj/machinery/manufacturer/gas,
					/obj/machinery/manufacturer/uniform,
					/obj/machinery/portable_reclaimer)
	cost = 8000
	containertype = /obj/storage/crate
	containername = "Manufacturer Kit"

/datum/supply_packs/complex/cargo_kit
	name = "Cargo Bay Kit"
	desc = "Contains a higher tier of cargo computer, allowed access to the full NT catalog.<br>1x Cargo Teleporter, Frames: 1x Commerce Computer, 1x Incoming supply pad, 1x Outgoing supply pad, 1x Cargo Teleporter pad, 1x Recharger"
	category = "Engineering Department"
	hidden = 1
	contains = list(/obj/item/paper/cargo_instructions,
					/obj/item/cargotele)
	frames = list(/obj/machinery/computer/special_supply/commerce,
					/obj/supply_pad/incoming,
					/obj/supply_pad/outgoing,
					/obj/submachine/cargopad,
					/obj/machinery/recharger)
	cost = 45000
	containertype = /obj/storage/crate
	containername = "Cargo Bay Kit"


/datum/supply_packs/complex/pod_kit
	name = "Pod Production Kit"
	desc = "Frames: 1x Ship Component Fabricator, 1x Reclaimer"
	frames = list(/obj/machinery/manufacturer/hangar,
					/obj/machinery/portable_reclaimer)
	cost = 5000
	containertype = /obj/storage/crate
	containername = "Pod Production Kit"

/datum/supply_packs/complex/turret_kit
	name = "Defense Turret Kit"
	desc = "Frames: 3x Turret, 1x Turret Control Console, 2x Security Camera"
	frames = list(/obj/machinery/turret/construction = 3,
					/obj/machinery/turretid/computer,
					/obj/machinery/camera = 2)
	cost = 40000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Defense Turret Kit"

/datum/supply_packs/complex/ai_kit
	name = "Artificial Intelligence Kit"
	desc = "Frames: 1x Asimov 5 AI, 2x Turret, 1x Turret Control Console, 2x Security Camera"
	frames = list(/obj/ai_frame,
					/obj/machinery/turret/construction = 2,
					/obj/machinery/turretid/computer,
					/obj/machinery/camera = 2)
	cost = 100000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "AI Kit"

/datum/supply_packs/complex/status_display
	name = "Disassembled Status Displays"
	desc = "Contains four disassembled status display panels as they have not yet been installed on all NanoTrasen space objects."
	category = "Engineering Department"
	frames = list(/obj/machinery/status_display,
		/obj/machinery/status_display,
		/obj/machinery/status_display,
		/obj/machinery/status_display)
	cost = 6000
	containertype = /obj/storage/crate
	containername = "Status Display Kit"

/datum/supply_packs/complex/eppd_kit
	name = "Emergency Pressurzation Kit"
	desc = "Frames: 1x Extreme-Pressure Pressurization Device"
	category = "Engineering Department"
	frames = list(/obj/machinery/portable_atmospherics/pressurizer)
	cost = 5000
	containertype = /obj/storage/crate
	containername = "Prototype EPPD Kit"

/datum/supply_packs/complex/basic_power_kit
	name = "Basic Power Kit"
	desc = "Frames: 1x SMES cell, 2x Furnace"
	category = "Engineering Department"
	frames = list(/obj/smes_spawner,
					/obj/machinery/power/furnace = 2)
	cost = 20000
	containertype = /obj/storage/crate
	containername = "Power Kit"

/datum/supply_packs/complex/mainframe_kit
	name = "Computer Core Kit"
	category = "Research Department"
	desc = "1x Memory Board, 1x Mainframe Recovery Kit, 1x TermOS B disk, Frames: 1x Computer Mainframe, 1x Databank, 1x Network Radio, 3x Data Terminal, 1x CompTech"
	contains = list(/obj/item/disk/data/memcard,
					/obj/item/storage/box/zeta_boot_kit,
					/obj/item/disk/data/floppy/read_only/terminal_os)
	frames = list(/obj/machinery/networked/mainframe,
					/obj/machinery/networked/storage,
					/obj/machinery/networked/radio,
					/obj/machinery/power/data_terminal = 3,
					/obj/machinery/vending/computer3)
	cost = 150000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Computer Core Kit"

/datum/supply_packs/complex/artlab_kit
	name = "Artifact Research Kit"
	desc = "Frames: 5x Data Terminal, 1x Pitcher, 1x Impact pad, 1x Heater pad, 1x Electric box, 1x X-Ray machine"
	category = "Research Department"
	frames = list(/obj/machinery/networked/test_apparatus/pitching_machine,
					/obj/machinery/networked/test_apparatus/impact_pad,
					/obj/machinery/networked/test_apparatus/electrobox,
					/obj/machinery/networked/test_apparatus/heater,
					/obj/machinery/networked/test_apparatus/xraymachine,
					/obj/machinery/power/data_terminal = 5)
	cost = 80000
	containertype = /obj/storage/crate
	containername = "Artifact Research Kit"

/datum/supply_packs/complex/toilet_kit
	name = "Bathroom Kit"
	desc = "Frames: 4x Toilet, 1x Sink, 1x Shower Head, 1x Bathtub"
	category = "Civilian Department"
	frames = list(/obj/item/storage/toilet = 4,
					/obj/machinery/shower,
					/obj/machinery/bathtub,
					/obj/submachine/chef_sink/chem_sink)
	cost = 15000
	containertype = /obj/storage/crate
	containername = "Bathroom Kit"

/datum/supply_packs/complex/kitchen_kit
	name = "Kitchen Kit"
	desc = "1x Fridge, Frames: 1x Oven, 1x Mixer, 1x Sink, 1x Deep Fryer, 1x Food Processor, 1x ValuChimp, 1x FoodTech, 1x Meat Spike, 1x Gibber"
	category = "Civilian Department"
	contains = list(/obj/storage/secure/closet/fridge)
	frames = list(/obj/submachine/chef_oven,
					/obj/submachine/mixer,
					/obj/submachine/chef_sink,
					/obj/machinery/deep_fryer,
					/obj/submachine/foodprocessor,
					/obj/machinery/vending/monkey,
					/obj/machinery/vending/kitchen,
					/obj/kitchenspike,
					/obj/machinery/gibber)
	cost = 50000
	containertype = /obj/storage/crate
	containername = "Kitchen Kit"

/datum/supply_packs/complex/bartender_kit
	name = "Bar Kit"
	desc = "2x Glassware box, Frames: 1x Alcohol Dispenser, 1x Soda Fountain, 1x Ice Cream Machine, 1x Kitchenware Recycler, 1x Microwave"
	category = "Civilian Department"
	contains = list(/obj/item/storage/box/glassbox = 2)
	frames = list(/obj/machinery/microwave,
					/obj/machinery/chem_dispenser/alcohol,
					/obj/machinery/chem_dispenser/soda,
					/obj/submachine/ice_cream_dispenser,
					/obj/machinery/glass_recycler)
	cost = 25000
	containertype = /obj/storage/crate
	containername = "Bar Kit"

/datum/supply_packs/complex/arcade
	name = "Arcade Machine"
	desc = "Frames: 1x Arcade Machine"
	category = "Civilian Department"
	frames = list(/obj/machinery/computer/arcade)
	cost = 2500
	containertype = /obj/storage/crate
	containername = "Arcade Machine"

/datum/supply_packs/complex/telescience_kit
	name = "Telescience Kit"
	desc = "Frames: 1x Science Teleporter Console, 2x Data Terminal, 1x Telepad"
	category = "Research Department"
	frames = list(/obj/machinery/networked/teleconsole,
					/obj/machinery/networked/telepad,
					/obj/machinery/power/data_terminal = 2)
	cost = 40000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Telescience"

/datum/supply_packs/complex/security_camera
	name = "Security Camera kit"
	desc = "Frames: 5x Security Camera"
	category = "Security Department"
	frames = list(/obj/machinery/camera = 5)
	cost = 1000
	hidden = 1
	containertype = /obj/storage/crate
	containername = "Security Camera"

/datum/supply_packs/complex/medical_kit
	name = "Medbay kit"
	desc = "1x Defibrillator, 2x Hypospray, 1x Medical Belt, Frames: 1x NanoMed, 1x Medical Records computer"
	category = "Medical Department"
	contains = list(/obj/item/robodefibrillator,
					/obj/item/storage/belt/medical,
					/obj/item/reagent_containers/hypospray = 2)
	frames = list(/obj/machinery/optable,
					/obj/machinery/vending/medical)
	cost = 10000
	containertype = /obj/storage/crate
	containername = "Medbay kit"

/datum/supply_packs/complex/operating_kit
	name = "Operating Room kit"
	desc = "1x Staple Gun, 1x Defibrillator, 2x Scalpel, 2x Circular Saw, 1x Hemostat, 2x Suture, 1x Enucleation Spoon, Frames: 1x Medical Fabricator, 1x Operating Table"
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
	cost = 15000
	containertype = /obj/storage/crate
	containername = "Operating Room kit"

/datum/supply_packs/complex/field_generator
	name = "Field Generator Crate"
	desc = "The four goal-posts needed to contain a singularity. Comes as frames to solder."
	category = "Engineering Department"
	frames = list(/obj/machinery/field_generator = 4)
	cost = 40000
	containertype = /obj/storage/secure/crate
	containername = "Field Generator Crate (Cardlocked \[Engineering])"
	access = access_engineering

/datum/supply_packs/complex/winter
	name = "Cold Weather Gear"
	desc = "Warm winter gear to ward off the winter chills."
	contains = list(/obj/item/clothing/suit/wintercoat = 5,
					/obj/item/clothing/mask/wscarf = 5,
					/obj/item/reagent_containers/food/drinks/chickensoup = 2,
					/obj/item/reagent_containers/food/drinks/coffee = 2)
	frames = list(/obj/machinery/space_heater = 2)
	cost = 3000

/datum/supply_packs/complex/hydrostarter
	name = "Hydroponics: Starter Crate"
	desc = "x2 Watering Cans, x4 Compost Bags, x2 Weedkiller bottles, x2 Plant Analyzers, x4 Plant Tray frames"
	category = "Civilian Department"
	contains = list(/obj/item/reagent_containers/glass/wateringcan = 2,
					/obj/item/reagent_containers/glass/compostbag = 4,
					/obj/item/reagent_containers/glass/bottle/weedkiller = 2,
					/obj/item/plantanalyzer = 2)
	frames = list(/obj/machinery/plantpot = 4)
	cost = 500
	containertype = /obj/storage/crate
	containername = "Hydroponics: Starter Crate"

/datum/supply_packs/complex/robotics_kit
	name = "Robotics kit"
	desc = "1x Staple Gun, 1x Scalpel, 1x Circular Saw, Frames: 1x Robotics Fabricator, 1x Operating Table, 1x Module Rewriter, 1x Recharge station"
	category = "Medical Department"
	contains = list(/obj/item/staple_gun,
					/obj/item/scalpel,
					/obj/item/circular_saw,
					/obj/item/circuitboard/robot_module_rewriter)
	frames = list(/obj/machinery/manufacturer/robotics,
					/obj/machinery/optable,
					/obj/machinery/recharge_station)
	cost = 20000
	containertype = /obj/storage/crate
	containername = "Robotics kit"

/datum/supply_packs/complex/genetics_kit
	name = "Genetics kit"
	desc = "Circuitboards: 1x DNA Modifier, 1x DNA Scanner"
	category = "Medical Department"
	contains = list(/obj/item/circuitboard/genetics)
	frames = list(/obj/machinery/genetics_scanner)
	cost = 30000
	containertype = /obj/storage/crate
	containername = "Genetics kit"

/datum/supply_packs/complex/cloner_kit
	name = "Cloning kit"
	desc = "Circuitboards: 1x Cloning Console, Frames: 1x Cloning Scanner, 1x Cloning Pod, 1x Enzymatic Reclaimer"
	category = "Medical Department"
	contains = list(/obj/item/circuitboard/cloning)
	frames = list(/obj/machinery/clone_scanner,
					/obj/machinery/clonepod,
					/obj/machinery/clonegrinder)
	cost = 50000
	containertype = /obj/storage/crate
	containername = "Cloning kit"

/datum/supply_packs/bureaucrat
	name = "Bureaucracy Supply Crate"
	desc = "x2 Paper bins, x2 Folders, x2 Pencils, x2 Pens, x2 Stamps, x1 Fancy Pen"
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
	cost = 1500
	containertype = /obj/storage/crate
	containername = "Bureaucracy Supply Crate"


/datum/supply_packs/ink_refill
	name = "Printing Press Refill Supplies"
	desc = "x1 Ink Cartridge, x2 Paper Bin"
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/ink,
					/obj/item/paper_bin,
					/obj/item/paper_bin)
	cost = 2500 //theres a monopoly on space ink!
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Refill Crate"

/datum/supply_packs/ink_upgrade
	name = "Printing Press Colour Module"
	desc = "x1 Ink Color Upgrade"
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/colors)
	cost = 2000 //colour ink is expensive yo
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Colour Crate"

/datum/supply_packs/custom_books
	name = "Printing Press Custom Cover Module"
	desc = "x1 Custom Cover Upgrade"
	category = "Civilian Department"
	contains = list(/obj/item/press_upgrade/books)
	cost = 2000
	containertype = /obj/storage/crate/packing
	containername = "Printing Press Cover Crate"

/datum/supply_packs/printing_press
	name = "Printing Press"
	desc = "x1 Printing Press Frame"
	category = "Civilian Department"
	contains = list(/obj/item/electronics/frame/press_frame,
					/obj/item/paper/press_warning)
	cost = 5000
	containertype = /obj/storage/crate/wooden
	containername = "Printing Press Crate"

/datum/supply_packs/percussion_band_kit
	name = "Percussion Band Kit"
	desc = "1x Tambourine, 1x Cowbell, 1x Triangle"
	category = "Civilian Department"
	cost = 2000
	containername = "Percussion Band Kit"
	contains = list(/obj/item/instrument/tambourine,/obj/item/instrument/triangle,/obj/item/instrument/cowbell)
	containertype = /obj/storage/crate/wooden

/datum/supply_packs/banjo
	name = "Banjo Kit"
	desc = "1x Banjo"
	category = "Civilian Department"
	cost = 2000
	containername = "Banjo Kit"
	contains = list(/obj/item/instrument/banjo)
	containertype = /obj/storage/crate/wooden

//Western

/datum/supply_packs/west_coats
	name = "Dusty Old Coats"
	desc = "4x coats in various colors."
	category = "Civilian Department"
	contains = list(/obj/item/clothing/suit/gimmick/guncoat,
			/obj/item/clothing/suit/gimmick/guncoat/black,
			/obj/item/clothing/suit/gimmick/guncoat/tan,
			/obj/item/clothing/suit/gimmick/guncoat/dirty)
	cost = 2000
	containername = "Dusty Old Clothing Crate"
	containertype = /obj/storage/crate/wooden
