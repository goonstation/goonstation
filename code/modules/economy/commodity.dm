// Commodities
/datum/commodity
	var/comname = "commodity" // Name of the item on the market
	var/comtype = null // Type Path of the item on the market
	var/price = 0 // Current selling price for this commodity
	var/baseprice = 0 // Baseline selling price for this commodity
	var/onmarket = 0 // Whether this item is currently being accepted for sale on the shipping market
	var/indemand = 0 // Whether this item is currently being bought at a high price on the market
	var/upperfluc = null // Highest this item's price can raise in one shift
	var/lowerfluc = null // Lowest this item's price can drop in one shift (negative numbers only)
	var/desc = "item" //Description for item
	var/desc_buy = "There are several buyers interested in acquiring this item." //Description for player selling
	var/desc_buy_demand = "This item is in high demand." //Descripition for player selling when in high demand
	var/hidden = 0 //Sometimes traders won't say if they will buy something
	var/haggleattempts = 0
	var/amount = -1 // Used for QM traders - how much of a thing they have for sale, unlim if -1
	// if its in the shopping cart, this is how many you're buying instead
	///if true, subtypes of this item will be accepted by NPC traders
	var/subtype_valid = TRUE
	///are there any commodities linked to this one? used to balance pricing for related commodities e.g. sheets/ore/materials
	///The key/value pair is commodity_type / ratio of relationship B/A where A is the current commodity's value related to linked commodity B
	var/list/linked_commodities = null

	New(atom/source, var/amount_sell_or_buy = -1)
		. = ..()
		baseprice = price
		if(isnull(upperfluc))
			upperfluc = baseprice/2
		if(isnull(lowerfluc))
			lowerfluc = -baseprice/2
		if(amount_sell_or_buy > 0)
			src.amount = amount_sell_or_buy

/*
/datum/commodity/clothing
	comname = "Jumpsuits"
	comtype = /obj/item/clothing/under
	price = 30
	baseprice = 30
	upperfluc = 20
	lowerfluc = 10

/datum/commodity/shoes
	comname = "Shoes"
	comtype = /obj/item/clothing/shoes
	price = 20
	baseprice = 20
	upperfluc = 10
	lowerfluc = 10 */


/datum/commodity/robotics
	comname = "Robot Parts"
	comtype = /obj/item/parts/robot_parts
	desc_buy = "The Omega Mining Corporation is expanding its operations and is in need of some robot parts"
	desc_buy_demand = "Cyborgs have revolted in the Lambada Quadrant, they are in desprate need of some more robot parts"
	onmarket = 1
	price = PRICE_RECURRING*0.6

/datum/commodity/produce
	comname = "Fresh Produce"
	comtype = /obj/item/reagent_containers/food/snacks/plant
	onmarket = 1
	price = PRICE_RECURRING*0.6

/datum/commodity/meat
	comname = "Meat"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat
	onmarket = 1
	price = PRICE_RECURRING*0.6

/datum/commodity/fish
	comname = "Fish"
	comtype = /obj/item/reagent_containers/food/fish
	onmarket = 1
	price = PRICE_RECURRING*0.6

/datum/commodity/herbs
	comname = "Medical Herbs"
	comtype = /obj/item/plant/herb
	onmarket = 1
	price = PRICE_75

/datum/commodity/honey
	comname = "Space Honey"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/honey
	desc_buy = "Meagre nectar yields this year have made honey imports desirable to space-bee hives."
	onmarket = 1
	price = PRICE_RECURRING_COSTLY

/datum/commodity/sheet
	comname = "Material Sheets"
	comtype = /obj/item/sheet
	desc = "High-quality material sheets."
	onmarket = 1
	price = PRICE_RECURRING_CHEAP*0.08
	linked_commodities = list(
		/datum/commodity/mat_bar = 10,
	)

/datum/commodity/mat_bar
	comname = "Material Bar"
	comtype = /obj/item/material_piece
	desc = "A Material Bar of some type."
	desc_buy = "The Promethus Consortium is currently gathering resources for a research project and is willing to buy this item"
	desc_buy_demand = "The colony on Regus X has had their main power reactor break down and need this item for repairs"
	onmarket = 1
	price = PRICE_75
	linked_commodities = list(
		/datum/commodity/sheet = 0.1,
	)

/datum/commodity/ore
	comname = "Rock"
	comtype = /obj/item/raw_material
	desc = "An ore that has various practical uses in manufacturing and research."
	desc_buy = "The Promethus Consortium is currently gathering resources for a research project and is willing to buy this item"
	desc_buy_demand = "The colony on Regus X has had their main power reactor break down and need this item for repairs"
	onmarket = 0
	price = PRICE_RECURRING*0.75
	var/value = 1

	New()
		price *= value
		. = ..()

/datum/commodity/ore/mauxite
	comname = "Mauxite"
	comtype = /obj/item/raw_material/mauxite
	onmarket = 1
	value = 0.9

/datum/commodity/ore/pharosium
	comname = "Pharosium"
	comtype = /obj/item/raw_material/pharosium
	onmarket = 1
	value = 1.1

/datum/commodity/ore/char
	comname = "Char"
	comtype = /obj/item/raw_material/char
	onmarket = 1
	value = 0.5

/datum/commodity/ore/molitz
	comname = "Molitz"
	comtype = /obj/item/raw_material/molitz
	onmarket = 1
	value = 0.9

/datum/commodity/ore/gemstone
	comname = "Gemstone"
	comtype = /obj/item/raw_material/gemstone
	onmarket = 1
	value = 4

/datum/commodity/ore/cobryl
	comname = "Cobryl"
	comtype = /obj/item/raw_material/cobryl
	onmarket = 1
	value = 1

/datum/commodity/ore/uqill
	comname = "Uqill"
	comtype = /obj/item/raw_material/uqill
	onmarket = 1
	value = 5

/datum/commodity/ore/fibrilith // why is this worth a ton of money?? dropping the value to further upset QMs
	comname = "Fibrilith"
	comtype = /obj/item/raw_material/fibrilith
	onmarket = 1
	value = 0.5

/datum/commodity/ore/viscerite
	comname = "Viscerite"
	comtype = /obj/item/raw_material/martian
	onmarket = 1
	value = 1

/datum/commodity/ore/bohrum
	comname = "Bohrum"
	comtype = /obj/item/raw_material/bohrum
	onmarket = 1
	value = 1.2

/datum/commodity/ore/claretine
	comname = "Claretine"
	comtype = /obj/item/raw_material/claretine
	onmarket = 1
	value = 2

/datum/commodity/ore/koshmarite
	comname = "Koshmarite"
	comtype = /obj/item/raw_material/eldritch
	onmarket = 1
	value = 1

/datum/commodity/ore/cerenkite
	comname = "Cerenkite"
	comtype = /obj/item/raw_material/cerenkite
	onmarket = 1
	value = 2

/datum/commodity/ore/erebite
	comname = "Erebite"
	comtype = /obj/item/raw_material/erebite
	onmarket = 1
	value = 5

/datum/commodity/ore/plasmastone
	comname = "Plasmastone"
	comtype = /obj/item/raw_material/plasmastone
	onmarket = 1
	value = 5

/datum/commodity/ore/telecrystal
	comname = "Telecrystal"
	comtype = /obj/item/raw_material/telecrystal
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	onmarket = 1
	value = 7

/datum/commodity/ore/syreline
	comname = "Syreline"
	comtype = /obj/item/raw_material/syreline
	onmarket = 1
	value = 3

/datum/commodity/ore/gold
	comname = "Gold Nugget"
	comtype = /obj/item/raw_material/gold
	onmarket = 1
	value = 5

/datum/commodity/goldbar
	comname = "Stamped Gold Bullion"
	comtype = /obj/item/stamped_bullion
	onmarket = 1
	price = PRICE_EXORBITANT

/datum/commodity/laser_gun
	comname = "Laser Gun"
	comtype =  /obj/item/gun/energy/laser_gun
	onmarket = 0
	desc = "A laser gun. Pew pew."
	price = PRICE_LUXURY*0.8

/datum/commodity/pen
	comname = "Pen"
	comtype = /obj/item/pen
	desc = "A useful writing tool."
	onmarket = 0
	price = PRICE_15

/datum/commodity/guardbot_medicator
	comname = "Medicator Tool Module"
	comtype = /obj/item/device/guardbot_tool/medicator
	desc = "A 'Medicator' syringe launcher module for PR-6S Guardbuddies. These things are actually outlawed on Earth."
	onmarket = 0
	price = PRICE_60

/datum/commodity/guardbot_smoker
	comname = "Smoker Tool Module"
	comtype = /obj/item/device/guardbot_tool/smoker
	desc = "A riot-control gas module for PR-6S Guardbuddies."
	onmarket = 0
	price = PRICE_60

/datum/commodity/guardbot_flash
	comname = "Flash Tool Module"
	comtype = /obj/item/device/guardbot_tool/flash
	desc = "A flash module for PR-6S Guardbuddies."
	onmarket = 0
	price = PRICE_60

/datum/commodity/guardbot_taser
	comname = "Taser Tool Module"
	comtype = /obj/item/device/guardbot_tool/taser
	desc = "A taser module for PR-6S Guardbuddies."
	onmarket = 0
	price = PRICE_60

/datum/commodity/guardbot_kit
	comname = "Guardbot Construction Kit"
	comtype = /obj/item/storage/box/guardbot_kit
	desc = "A useful kit for building guardbuddies. All you need is a module!"
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/boogiebot
	comname = "Boogiebot"
	comtype = /mob/living/critter/small_animal/boogiebot
	desc = "The latest in boogie technology!"
	onmarket = 0
	price = PRICE_LUXURY*0.8

// cogwerks - NPC stuff

/datum/commodity/fuel // buy from trader NPC
	comname = "Fuel Tank"
	comtype = /obj/item/tank/plasma
	desc = "A small tank of plasma. Use with caution."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/royaljelly
	comname = "Royal Jelly"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	desc = "A sample of royal jelly, a nutritive compound for bee larvae."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/beeegg
	comname = "Bee Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	onmarket = 0
	desc = "A space bee egg.  Space bees hatch from these."
	price = PRICE_RECURRING*0.6

/datum/commodity/b33egg
	comname = "Irregular Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy
	desc = "This batch of space bee eggs exhibits a minor irregularity that kept it out of normal distribution channels."
	onmarket = 0
	price = PRICE_RECURRING*0.6

/datum/commodity/bee_kibble
	comname = "Bee Kibble"
	comtype = /obj/item/reagent_containers/food/snacks/beefood
	desc = "Essentially cereal for bees.  Tastes pretty good, provided that you are a bee."
	onmarket = 0
	price = PRICE_RECURRING*0.6

//////////////////////
//// pod sales ///////
//////////////////////

/datum/commodity/podparts
	onmarket = 0

/datum/commodity/podparts/engine
	comname = "HERMES Engine"
	comtype = /obj/item/shipcomponent/engine/hermes
	desc = "A heavy-duty engine for pod vehicles."
	price = PRICE_LUXURY*0.5

/datum/commodity/podparts/laser
	comname = "Mk.2 Scout Laser"
	comtype = /obj/item/shipcomponent/mainweapon/laser
	desc = "A standard military laser built around a pod-based weapons platform."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/podparts/asslaser
	comname = "Assault Laser Array"
	comtype = /obj/item/shipcomponent/mainweapon/laser_ass
	desc = "Usually only seen on cruiser-class ships. How the hell did this end up here?"
	price = PRICE_EXORBITANT*5

/datum/commodity/podparts/blackarmor
	comname = "Strange Armor Plating"
	comtype = /obj/item/podarmor/armor_black
	desc = "NT Special Ops vehicular armor plating, almost certainly stolen."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/podparts/redarmor
	comname = "Syndicate Pod Armor"
	comtype = /obj/item/podarmor/armor_red
	desc = "A kit of Syndicate pod armor plating."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/podparts/goldarmor
	comname = "Gold Pod Armor"
	comtype = /obj/item/podarmor/armor_gold
	desc = "A kit of gold-plated pod armor plating."
	price = PRICE_EXORBITANT

/datum/commodity/podparts/ballistic_22
	comname = "PEP-22 Ballistic System"
	comtype = /obj/item/shipcomponent/mainweapon/gun_22
	desc = "A pod-mounted kinetic weapon system."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/podparts/ballistic_9mm
	comname = "PEP-9 Ballistic System"
	comtype = /obj/item/shipcomponent/mainweapon/gun_9mm
	desc = "A pod-mounted kinetic weapon system."
	price = PRICE_EXORBITANT*0.75

/datum/commodity/podparts/ballistic
	comname = "SPE-12 Ballistic System"
	comtype = /obj/item/shipcomponent/mainweapon/gun
	desc = "A pod-mounted kinetic weapon system."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/podparts/artillery
	comname = "40mm Assault Platform"
	comtype = /obj/item/shipcomponent/mainweapon/artillery
	desc = "A pair of ballistic launchers, fires explosive 40mm shells."
	price = PRICE_EXORBITANT*5

/datum/commodity/contraband/artillery_ammo
	comname = "40mm HE Ammunition"
	comtype = /obj/item/ammo/bullets/autocannon
	desc = "High explosive grenades, for the resupplement of artillery assault platforms."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/podparts/cloak
	comname = "Medusa Stealth System 300"
	comtype = /obj/item/shipcomponent/secondary_system/cloak
	desc = "A cloaking device for stealth recon vehicles."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/podparts/skin_stripe_r
	comname = "Pod Paint Job Kit (Red Racing Stripes)"
	comtype = /obj/item/pod/paintjob/stripe_r
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = PRICE_LUXURY*0.8

/datum/commodity/podparts/skin_stripe_b
	comname = "Pod Paint Job Kit (Blue Racing Stripes)"
	comtype = /obj/item/pod/paintjob/stripe_b
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = PRICE_LUXURY*0.8

/datum/commodity/podparts/skin_flames
	comname = "Pod Paint Job Kit (Flames)"
	comtype = /obj/item/pod/paintjob/flames
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = PRICE_LUXURY_COSTLY*0.96

////////////////////////////
///// 420 all day //////////
////////////////////////////

/datum/commodity/drugs
	desc = "Illegal drugs."
	onmarket = 0

// these have two separate subtypes because herbs need separate spawnable types for reagents

// traders buy these from players

/datum/commodity/drugs/buy/poppies
	comname = "Poppies"
	comtype = /obj/item/plant/herb/poppy
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/buy/shrooms
	comname = "Psilocybin"
	comtype = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/buy/cannabis
	comname = "Cannabis"
	comtype = /obj/item/plant/herb/cannabis
	price = PRICE_75

/datum/commodity/drugs/buy/cannabis_mega
	comname = "Rainbow Cannabis"
	comtype = /obj/item/plant/herb/cannabis/mega
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/buy/cannabis_white
	comname = "White Cannabis"
	comtype = /obj/item/plant/herb/cannabis/white
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/buy/cannabis_omega
	comname = "Omega Cannabis"
	comtype = /obj/item/plant/herb/cannabis/omega
	price = PRICE_RECURRING_COSTLY

// traders sell these to players


/datum/commodity/drugs/sell/cannabis_omega
	comname = "Omega Cannabis"
	comtype = /obj/item/plant/herb/cannabis/omega/spawnable
	price = PRICE_RECURRING_COSTLY

datum/commodity/drugs/sell/poppies
	comname = "Poppies"
	comtype = /obj/item/plant/herb/poppy/spawnable
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/shrooms
	comname = "Psilocybin"
	comtype = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin/spawnable
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/cannabis
	comname = "Cannabis"
	comtype = /obj/item/plant/herb/cannabis/spawnable
	price = PRICE_75

/datum/commodity/drugs/sell/cannabis_mega
	comname = "Rainbow Cannabis"
	comtype = /obj/item/plant/herb/cannabis/mega/spawnable
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/cannabis_white
	comname = "White Cannabis"
	comtype = /obj/item/plant/herb/cannabis/white/spawnable
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/CBD
	comname = "CBD Pills"
	comtype = /obj/item/reagent_containers/pill/CBD
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/drugs/sell/methamphetamine
	comname = "Methamphetamine (5x pills)"
	comtype = /obj/item/storage/pill_bottle/methamphetamine
	desc = "Methamphetamine is a highly effective and dangerous stimulant drug."
	price = PRICE_LUXURY*0.4

/datum/commodity/drugs/sell/crank
	comname = "Crank (5x pills)"
	comtype = /obj/item/storage/pill_bottle/crank
	desc = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/drugs/sell/bathsalts
	comname = "Bath Salts (5x pills)"
	comtype = /obj/item/storage/pill_bottle/bathsalts
	desc = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	price = PRICE_LUXURY_COSTLY*0.96

/datum/commodity/drugs/sell/catdrugs
	comname = "Cat Drugs (5x pills)"
	comtype = /obj/item/storage/pill_bottle/catdrugs
	desc = "Uhh..."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/drugs/sell/morphine
	comname = "Morphine (1x syringe)"
	comtype = /obj/item/reagent_containers/syringe/morphine
	desc = "A strong but highly addictive opiate painkiller with sedative side effects."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/drugs/sell/krokodil
	comname = "Krokodil (1x syringe)"
	comtype = /obj/item/reagent_containers/syringe/krokodil
	desc = "A sketchy homemade opiate often used by disgruntled Cosmonauts."
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/lsd
	comname = "LSD (1x patch)"
	comtype = /obj/item/reagent_containers/patch/LSD
	desc = "A highly potent hallucinogenic substance. Far out, maaaan."
	price = PRICE_RECURRING*0.75

/datum/commodity/drugs/sell/lsd_bee
	comname = "LSBee (1x patch)"
	comtype = /obj/item/reagent_containers/patch/lsd_bee
	desc = "A highly potent hallucinogenic substance. It smells like honey."
	price = PRICE_RECURRING*0.75

/datum/commodity/pills/uranium
	comname = "Uranium (1x nugget)"
	comtype = /obj/item/reagent_containers/pill/uranium
	desc = "A nugget of weapons grade uranium. Label says it's roughly 'size 5'."
	price = PRICE_LUXURY*0.4

/datum/commodity/drugs/sell/cyberpunk
	comname = "Designer Drugs (5x pills)"
	comtype = /obj/item/storage/pill_bottle/cyberpunk
	desc = "Who knows what you might get."
	price = PRICE_LUXURY_CHEAP*0.6

/////////////////////////////////
//// valuable space junk ////////
/////////////////////////////////

/datum/commodity/relics
	desc = "Strange things from deep space."
	onmarket = 0

/datum/commodity/relics/skull
	comname = "Skull"
	comtype = /obj/item/skull
	price = PRICE_LUXURY_COSTLY

/datum/commodity/relics/relic
	comname = "Strange Relic"
	comtype = /obj/item/relic
	price = PRICE_EXORBITANT*5

/datum/commodity/relics/gnome
	comname = "Garden Gnome"
	comtype = /obj/item/gnomechompski
	price = PRICE_LUXURY_COSTLY

/datum/commodity/relics/crown
	comname = "Obsidian Crown"
	comtype = /obj/item/clothing/head/void_crown
	price = PRICE_EXORBITANT*5

/datum/commodity/relics/armor
	comname = "Ancient Armor"
	comtype = /obj/item/clothing/suit/armor/ancient
	price = PRICE_EXORBITANT*5

/datum/commodity/relics/marshelmet
	comname = "Antique Mars Helmet"
	comtype = /obj/item/clothing/head/helmet/mars
	price = PRICE_LUXURY_COSTLY

/datum/commodity/relics/marsuit
	comname = "Antique Mars Suit"
	comtype = /obj/item/clothing/suit/armor/mars
	price = PRICE_LUXURY_COSTLY

/datum/commodity/relics/bootlegfirework
	comname = "Bootleg Firework (1x rocket)"
	comtype = /obj/item/firework/bootleg
	desc = "Bootleg fireworks, found deep in the back of an old warehouse."
	price = PRICE_75

////////////////////////////////
///// syndicate trader /////////
////////////////////////////////

/datum/commodity/clothing_restock
	comname = "Syndicate Clothing Vendor Restock Cartridge"
	desc = "A restock cartridge for restocking syndicate clothing vending machines."
	comtype = /obj/item/vending/restock_cartridge/jobclothing/syndicate
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband
	comname = "Contraband"
	desc = "Stolen gear and syndicate products."
	onmarket = 0

/datum/commodity/contraband/captainid
	comname = "NT Captain Gold ID"
	comtype = /obj/item/card/id/gold/captains_spare
	desc = "NT gold-level registered captain ID."
	price = PRICE_LUXURY_COSTLY

	bee
		comname = "Captain Gold ID"
		desc_buy = "The kind of ID a queen would probably hang on the wall of the hive or something."

/datum/commodity/contraband/spareid
	comname = "NT Spare Gold ID"
	comtype = /obj/item/card/id/gold
	desc = "NT gold-level unregistered spare ID."
	price = PRICE_LUXURY_COSTLY

	bee
		comname = "Gold ID"
		desc_buy = "You know, gold, like honey! Grey ones are out of place in a hive."

/datum/commodity/contraband/secheadset
	comname = "Security Headset"
	comtype = /obj/item/device/radio/headset/security
	desc = "A radio headset used by NT security forces."
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband/hosberet
	comname = "Head of Security Beret"
	comtype = /obj/item/clothing/head/hos_hat
	desc = "The beloved beret of an NT HoS."
	price = PRICE_EXORBITANT

/datum/commodity/contraband/egun
	comname = "Energy Gun"
	comtype = /obj/item/gun/energy/egun
	desc = "A standard-issue NT energy gun."
	price = PRICE_LUXURY_COSTLY

//// purchase stuff

/datum/commodity/contraband/command_suit
	comname = "Armored Spacesuit"
	comtype = /obj/item/clothing/suit/space/industrial/syndicate
	desc = "An armored spacesuit issued to Syndicate squad leaders."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/contraband/command_helmet
	comname = "Armored Helmet"
	comtype = /obj/item/clothing/head/helmet/space/industrial/syndicate
	desc = "An armored helmet issued to Syndicate squad leaders."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/contraband/swatmask
	comname = "Scary Gasmask"
	comtype = /obj/item/clothing/mask/gas/swat
	desc = "Pretty much exactly what it sounds like."
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband/swatmask/NT
	comname = "Scary NanoTrasen Gasmask"
	comtype = /obj/item/clothing/mask/gas/swat/NT
	desc = "Pretty much exactly what it sounds like, but in blue."
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband/plutonium
	comname = "Plutonium Core"
	comtype = /obj/item/plutonium_core
	desc = "Stolen from a nuclear warhead."
	price = PRICE_RICHES_OF_HEAVEN_AND_EARTH

/datum/commodity/contraband/radiojammer
	comname = "Radio Jammer"
	comtype = /obj/item/radiojammer
	desc = "A device that can block radio transmissions around it."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/stealthstorage
	comname = "Stealth Storage"
	comtype = /obj/item/storage/box/syndibox
	desc = "Can take on the appearance of another item. Creates a small dimensional rift in space-time, allowing it to hold multiple items."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/chamsuit
	comname = "Chameleon Jumpsuit"
	comtype = /obj/item/clothing/under/chameleon
	desc = "A jumpsuit made of advanced fibres that can change colour to suit the needs of the wearer. Do not expose to electromagnetic interference."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/dnascram
	comname = "DNA Scrambler"
	comtype = /obj/item/dna_scrambler
	desc = "An injector that gives a new, random identity upon injection, storing the original for later."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/voicechanger
	comname = "Voice Changer"
	comtype = /obj/item/voice_changer
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/syndicate_headset
	comname = "Illegal Headset"
	comtype = /obj/item/device/radio/headset/syndicate
	desc = "This headset allows you to speak over a highly illegal Syndicate frequency."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/briefcase
	comname = "Briefcase Valve Assembly"
	comtype = /obj/item/device/transfer_valve/briefcase
	desc = "Bomb not included."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/disguiser
	comname = "Holographic Disguiser"
	comtype = /obj/item/device/disguiser
	desc = "Another one of those experimental Syndicate holographic projects, seems to be an older model."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/birdbomb
	comname = "12ga AEX ammo"
	comtype = /obj/item/ammo/bullets/aex
	desc = "12 gauge ammo marked 12ga AEX Large Wildlife Dispersal Cartridge. Huh."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/flare
	comname = "12ga Flare Shells"
	comtype = /obj/item/ammo/bullets/flare
	desc = "Military-grade 12 gauge flare shells. Guaranteed to brighten your day."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/eguncell_highcap
	comname = "High-Capacity Power Cell"
	comtype = /obj/item/ammo/power_cell/high_power
	desc = "Power cell with a capacity of 300 PU. Compatible with energy guns and stun batons."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/contraband/spy_sticker_kit
	comname = "Spy Sticker Kit"
	comtype = /obj/item/storage/box/spy_sticker_kit
	desc = "Kit contains innocuous stickers that can be used to broadcast audio and observe a video feed wirelessly."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/contraband/ai_kit_syndie
	comname = "Red AI Kit"
	comtype = /obj/item/ai_plating_kit/syndicate
	desc = "A dubiously colored AI core kit, which doesn't match standard designs. It's sold at a discount though, because it's just the casing pieces."
	price = PRICE_LUXURY*0.4

//NT stuff

/datum/commodity/contraband/ntso_uniform
	comname = "Surplus tactical uniform"
	comtype = /obj/item/clothing/under/misc/turds
	desc = "A rather smelly tactical uniform sold off from an NT warehouse."
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband/ntso_beret
	comname = "Surplus NT beret"
	comtype = /obj/item/clothing/head/NTberet
	desc = "Fancy. Possibly salvaged, possibly stolen, what's it to you?"
	price = PRICE_LUXURY*0.4

/datum/commodity/contraband/ntso_vest
	comname = "Surplus armored vest"
	comtype = /obj/item/clothing/suit/armor/NT_alt
	desc = "A surplus blue armored vest, well worn and definitely not drycleaned."
	price = PRICE_LUXURY*0.8

/////////////////////////////////
////// salvage trader ///////////
/////////////////////////////////

/datum/commodity/salvage
	comname = "Salvaged Junk"
	desc = "Bits of debris."
	onmarket = 0

/datum/commodity/salvage/scrap
	comname = "Scrap Metal"
	comtype = /obj/item/scrap
	price = PRICE_15
	desc_buy = "We are interested in recycling ground metal scrap."

/datum/commodity/salvage/robot_upgrades
	comname = "Cyborg Upgrade"
	desc = "A salvaged cyborg upgrade kit."
	onmarket = 0

/datum/commodity/salvage/robot_upgrades/efficiency
	comname = "Cyborg Upgrade (Efficiency)"
	comtype = /obj/item/roboupgrade/efficiency
	price = PRICE_LUXURY_COSTLY

/datum/commodity/salvage/robot_upgrades/expand
	comname = "Cyborg Upgrade (Expansion)"
	comtype = /obj/item/roboupgrade/expand
	price = PRICE_LUXURY_COSTLY

/datum/commodity/salvage/robot_upgrades/selfrepair
	comname = "Cyborg Upgrade (Self-Repair)"
	comtype = /obj/item/roboupgrade/repair
	price = PRICE_LUXURY_COSTLY

/datum/commodity/salvage/robot_upgrades/stunresist
	comname = "Cyborg Upgrade (Recovery)"
	comtype = /obj/item/roboupgrade/aware
	price = PRICE_LUXURY_COSTLY

/datum/commodity/junk
	comname = "Space Junk"
	desc = "Space junk and trinkets."
	onmarket = 0

/datum/commodity/junk/horsemask
	comname = "Horse Mask"
	comtype = /obj/item/clothing/mask/horse_mask
	price = PRICE_RECURRING*0.75

/datum/commodity/junk/batmask
	comname = "Bat Mask"
	comtype = /obj/item/clothing/mask/batman
	price = PRICE_RECURRING*0.75

/datum/commodity/junk/johnny
	comname = "Strange Suit"
	comtype = /obj/item/clothing/suit/johnny_coat
	price = PRICE_RECURRING_COSTLY

/datum/commodity/junk/buddy
	comname = "Robuddy Costume"
	comtype = /obj/item/clothing/suit/robuddy
	price = PRICE_RECURRING_COSTLY

/datum/commodity/junk/cowboy_boots
	comname = "Cowboy Boots"
	comtype = /obj/item/clothing/shoes/cowboy
	price = PRICE_75

/datum/commodity/junk/cowboy_hat
	comname = "Cowboy Hat"
	comtype = /obj/item/clothing/head/cowboy
	price = PRICE_75

/datum/commodity/junk/voltron
	comname = "Voltron"
	comtype = /obj/item/device/voltron
	price = PRICE_EXORBITANT*2.5

/datum/commodity/junk/cloner_upgrade
	comname = "Cloning Machine Upgrade Board"
	comtype = /obj/item/cloner_upgrade
	price = PRICE_LUXURY*0.8

/datum/commodity/junk/grinder_upgrade
	comname = "Enzymatic Reclaimer Upgrade Board"
	comtype = /obj/item/grinder_upgrade
	price = PRICE_LUXURY*0.8

/datum/commodity/junk/speedyclone
	comname = "SpeedyClone2000"
	comtype = /obj/item/cloneModule/speedyclone
	price = PRICE_LUXURY*0.8

/datum/commodity/junk/efficientclone
	comname = "Biomatter recycling unit"
	comtype = /obj/item/cloneModule/efficientclone
	price = PRICE_LUXURY*0.8

/datum/commodity/junk/circus_board
	comname = "Circus board"
	comtype = /obj/item/peripheral/card_scanner/clownifier
	desc = "A cheap imported ID scanner module. It looks sticky. Like, WAY sticker than a computer module should be."
	price = PRICE_RECURRING*0.75

/datum/commodity/junk/pie_launcher
	comname = "Pie Tool Module"
	comtype = /obj/item/device/guardbot_tool/pie_launcher
	desc = "A tool module compatible with guardbuddies. Are tool modules supposed to have cream on them?"
	price = PRICE_RECURRING_COSTLY
	baseprice = PRICE_RECURRING_COSTLY
	upperfluc = PRICE_RECURRING_CHEAP
	lowerfluc = -PRICE_RECURRING_CHEAP

/datum/commodity/junk/laughbox
	comname = "Box of Laughs"
	comtype = /obj/item/storage/box/box_o_laughs
	desc = "A box full of canned laughs. In case you cant get any of the real stuff."
	price = PRICE_PISS

/datum/commodity/junk/ai_kit_clown
	comname = "Circus AI Parts"
	comtype = /obj/item/ai_plating_kit/clown
	desc = "The parts required to plate an AI frame to make it fit for running a circus."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/junk/ai_kit_mime
	comname = "Mime AI Parts"
	comtype = /obj/item/ai_plating_kit/mime
	desc = "The parts required to plate an AI to thematically match with being trapped in a box."
	price = PRICE_LUXURY_CHEAP*0.6

/////////////////////////////////
///////food trader //////////////
/////////////////////////////////

/datum/commodity/produce/special
	desc = "Valuable produce."
	onmarket = 0

/datum/commodity/produce/special/gmelon
	comname = "George Melon"
	comtype = /obj/item/reagent_containers/food/snacks/plant/melon/george
	price = PRICE_75

/datum/commodity/produce/special/greengrape
	comname = "Green Grapes"
	comtype = /obj/item/reagent_containers/food/snacks/plant/grape/green
	price = PRICE_75

/datum/commodity/produce/special/chilly
	comname = "Chilly Pepper"
	comtype = /obj/item/reagent_containers/food/snacks/plant/chili/chilly
	price = PRICE_RECURRING_CHEAP

/datum/commodity/produce/special/ghostchili
	comname = "Ghost Chili Pepper"
	comtype = /obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili
	price = PRICE_RECURRING_COSTLY

/datum/commodity/produce/special/lashberry
	comname = "Lashberry"
	comtype = /obj/item/reagent_containers/food/snacks/plant/lashberry
	price = PRICE_RECURRING_COSTLY

/datum/commodity/produce/special/glowfruit
	comname = "Glowfruit"
	comtype = /obj/item/reagent_containers/food/snacks/plant/glowfruit
	price = PRICE_RECURRING_COSTLY

/datum/commodity/produce/special/purplegoop
	comname = "Purple Goop"
	comtype = /obj/item/reagent_containers/food/snacks/plant/purplegoop
	price = PRICE_RECURRING_COSTLY

/datum/commodity/produce/special/goldfishcracker
	comname = "Goldfish Cracker"
	comtype = /obj/item/reagent_containers/food/snacks/goldfish_cracker
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/diner/monster
	comname = "THE MONSTER"
	comtype = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	price = PRICE_LUXURY_CHEAP*0.6

// sell

/datum/commodity/diner
	desc = "Diner food of questionable quality."
	onmarket = 0

/datum/commodity/diner/mysteryburger
	comname = "Mystery Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/mysteryburger
	price = PRICE_15

/datum/commodity/diner/sloppyjoe
	comname = "Sloppy Joe"
	comtype = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe
	price = PRICE_15

/datum/commodity/diner/fishburger
	comname = "Fish-Fil-A"
	comtype = /obj/item/reagent_containers/food/snacks/burger/fishburger
	price = PRICE_15

/datum/commodity/diner/luauburger
	comname = "Luau Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/luauburger
	price = PRICE_15

/datum/commodity/diner/tikiburger
	comname = "Tiki Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	price = PRICE_15

/datum/commodity/diner/coconutburger
	comname = "Coconut Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	price = PRICE_15

/datum/commodity/diner/onigiri
	comname = "Onigiri"
	comtype = /obj/item/reagent_containers/food/snacks/rice_ball/onigiri
	price = PRICE_15

/datum/commodity/diner/nigiri_roll
	comname = "Nigiri Roll"
	comtype = /obj/item/reagent_containers/food/snacks/nigiri_roll
	price = PRICE_30

/datum/commodity/diner/sushi_roll
	comname = "Sushi Roll"
	comtype = /obj/item/reagent_containers/food/snacks/sushi_roll
	price = PRICE_30

/datum/commodity/diner/mashedpotatoes
	comname = "Mashed Potatoes"
	comtype = /obj/item/reagent_containers/food/snacks/mashedpotatoes
	price = PRICE_15

/datum/commodity/diner/waffles
	comname = "Waffles"
	comtype = /obj/item/reagent_containers/food/snacks/waffles
	price = PRICE_15

/datum/commodity/diner/pancake
	comname = "Pancake"
	comtype = /obj/item/reagent_containers/food/snacks/pancake
	price = PRICE_15

/datum/commodity/diner/meatloaf
	comname = "Meatloaf"
	comtype = /obj/item/reagent_containers/food/snacks/meatloaf
	price = PRICE_15

/datum/commodity/diner/fishfingers
	comname = "Fish Fingers"
	comtype = /obj/item/reagent_containers/food/snacks/fish_fingers
	price = PRICE_15

/datum/commodity/diner/slurrypie
	comname = "Slurry Pie"
	comtype = /obj/item/reagent_containers/food/snacks/pie/slurry
	price = PRICE_15

/datum/commodity/diner/creampie
	comname = "Cream Pie"
	comtype = /obj/item/reagent_containers/food/snacks/pie/cream
	price = PRICE_15

/datum/commodity/diner/daily_special
	comname = "Daily Special"
	comtype = null
	price = PRICE_15

	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/reagent_containers/food/snacks/corndog/banana
			if ("tuesday")
				comtype = /obj/item/reagent_containers/food/snacks/bakedpotato
			if ("wednesday")
				comtype = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey
			if ("thursday")
				comtype = /obj/item/reagent_containers/food/snacks/sandwich/meatball
			if ("friday")
				comtype = /obj/item/reagent_containers/food/snacks/burger/fishburger
			if ("saturday")
				comtype = /obj/item/reagent_containers/food/snacks/breakfast
			if ("sunday")
				comtype = /obj/item/reagent_containers/food/snacks/pie/pot



///// body parts

/datum/commodity/bodyparts
	desc = "It's best not to ask too many questions."
	onmarket = 0
	subtype_valid = FALSE

/datum/commodity/bodyparts/armL
	comname = "Human Arm - Left"
	comtype = /obj/item/parts/human_parts/arm/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/armR
	comname = "Human Arm - Right"
	comtype = /obj/item/parts/human_parts/arm/right
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/legL
	comname = "Human Leg - Left"
	comtype = /obj/item/parts/human_parts/leg/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/legR
	comname = "Human Leg - Right"
	comtype = /obj/item/parts/human_parts/leg/right
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/brain
	comname = "Brain"
	comtype = /obj/item/organ/brain
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/synthbrain
	comname = "Synthetic Brain"
	comtype = /obj/item/organ/brain/synth
	price = PRICE_RECURRING*0.75

/datum/commodity/bodyparts/aibrain
	comname = "AI Neural Net Processor"
	comtype = /obj/item/organ/brain/ai
	price = PRICE_LUXURY_COSTLY

/datum/commodity/bodyparts/butt
	comname = "Human Butt"
	comtype = /obj/item/clothing/head/butt
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/synthbutt
	comname = "Synthetic Butt"
	comtype = /obj/item/clothing/head/butt/synth
	price = PRICE_RECURRING*0.75

/datum/commodity/bodyparts/cyberbutt
	comname = "Robutt"
	comtype = /obj/item/clothing/head/butt/cyberbutt
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/heart
	comname = "Human Heart"
	comtype = /obj/item/organ/heart
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/synthheart
	comname = "Synthetic Heart"
	comtype = /obj/item/organ/heart/synth
	price = PRICE_RECURRING*0.75

/datum/commodity/bodyparts/cyberheart
	comname = "Cyberheart"
	comtype = /obj/item/organ/heart/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/l_eye
	comname = "Left Human Eye"
	comtype = /obj/item/organ/eye/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/r_eye
	comname = "Right Human Eye"
	comtype = /obj/item/organ/eye/right
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/syntheye
	comname = "Synthetic Eye"
	comtype = /obj/item/organ/eye/synth
	price = PRICE_RECURRING*0.75

/datum/commodity/bodyparts/cybereye
	comname = "Cybereye"
	comtype = /obj/item/organ/eye/cyber/configurable
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cybereye_sunglass
	comname = "Polarized Cybereye"
	comtype = /obj/item/organ/eye/cyber/sunglass
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_sechud
	comname = "Security HUD Cybereye"
	comtype = /obj/item/organ/eye/cyber/sechud
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_thermal
	comname = "Thermal Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/thermal
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_meson
	comname = "Mesonic Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/meson
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_spectro
	comname = "Spectroscopic Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/spectro
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_prodoc
	comname = "ProDoc Healthview Cybereye"
	comtype = /obj/item/organ/eye/cyber/prodoc
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_camera
	comname = "Camera Cybereye"
	comtype = /obj/item/organ/eye/cyber/camera
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_monitor
	comname = "Monitor Cybereye"
	comtype = /obj/item/organ/eye/cyber/monitor
	price = PRICE_LUXURY*0.4

/datum/commodity/bodyparts/cybereye_night
	comname = "Night Vision Cybereye"
	comtype = /obj/item/organ/eye/cyber/nightvision
	price = PRICE_LUXURY_COSTLY

/datum/commodity/bodyparts/cybereye_laser
	comname = "Laser Cybereye"
	comtype = /obj/item/organ/eye/cyber/laser
	price = PRICE_LUXURY_COSTLY

/datum/commodity/bodyparts/cybereye_ecto
	comname = "Ectosensor Cybereye"
	comtype = /obj/item/organ/eye/cyber/ecto
	price = PRICE_LUXURY_COSTLY

/datum/commodity/bodyparts/l_lung
	comname = "Left Human Lung"
	comtype = /obj/item/organ/lung/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/r_lung
	comname = "Right Human Lung"
	comtype = /obj/item/organ/lung/right
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/l_cyberlung
	comname = "Left Cyberlung"
	comtype = /obj/item/organ/lung/cyber/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/r_cyberlung
	comname = "Right Cyberlung"
	comtype = /obj/item/organ/lung/cyber/right
	price = PRICE_LUXURY_CHEAP*0.6

//////////////////////////////////////

/datum/commodity/bodyparts/l_kidney
	comname = "Left Human Kidney"
	comtype = /obj/item/organ/kidney/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/r_kidney
	comname = "Right Human Kidney"
	comtype = /obj/item/organ/kidney/right
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/l_cyberkidney
	comname = "Left Cyberkidney"
	comtype = /obj/item/organ/kidney/cyber/left
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/r_cyberkidney
	comname = "Right Cyberkidney"
	comtype = /obj/item/organ/kidney/cyber/right
	price = PRICE_LUXURY_CHEAP*0.6

////////////////////////////////////////

/datum/commodity/bodyparts/liver
	comname = "Human Liver"
	comtype = /obj/item/organ/liver
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cyberliver
	comname = "Cyberliver"
	comtype = /obj/item/organ/liver/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/spleen
	comname = "Human Spleen"
	comtype = /obj/item/organ/spleen
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cyberspleen
	comname = "Cyberspleen"
	comtype = /obj/item/organ/spleen/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/pancreas
	comname = "Human Pancreas"
	comtype = /obj/item/organ/pancreas
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cyberpancreas
	comname = "Cyberpancreas"
	comtype = /obj/item/organ/pancreas/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/appendix
	comname = "Human Appendix"
	comtype = /obj/item/organ/appendix
	price = PRICE_RECURRING*0.75

/datum/commodity/bodyparts/cyberappendix
	comname = "Cyberappendix"
	comtype = /obj/item/organ/appendix/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/stomach
	comname = "Human Stomach"
	comtype = /obj/item/organ/stomach
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cyberstomach
	comname = "Cyberstomach"
	comtype = /obj/item/organ/stomach/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/intestines
	comname = "Human Intestines"
	comtype = /obj/item/organ/intestines
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/bodyparts/cyberintestines
	comname = "Cyberintestines"
	comtype = /obj/item/organ/intestines/cyber
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/medical
	onmarket = 0
	desc = "Medical Supplies."

/datum/commodity/medical/injectorbelt
	comname = "Injector Belt"
	comtype = /obj/item/injector_belt
	desc = "A belt that injects the wearer with chemicals loaded from a container."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/medical/injectormask
	comname = "Vapo-Matic"
	comtype = /obj/item/clothing/mask/injector_mask
	desc = "A gas mask that doses the wearer with chemicals loaded from a container."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/medical/strange_reagent
	comname = "Strange Reagent"
	comtype = /obj/item/reagent_containers/glass/beaker/strange_reagent
	price = PRICE_LUXURY_COSTLY

/datum/commodity/medical/firstaidR
	comname = "First Aid Kit - Regular"
	comtype = /obj/item/storage/firstaid/regular
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidBr
	comname = "First Aid Kit - Brute"
	comtype = /obj/item/storage/firstaid/brute
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidB
	comname = "First Aid Kit - Fire"
	comtype = /obj/item/storage/firstaid/fire
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidT
	comname = "First Aid Kit - Toxin"
	comtype = /obj/item/storage/firstaid/toxin
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidO
	comname = "First Aid Kit - Suffocation"
	comtype = /obj/item/storage/firstaid/oxygen
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidN
	comname = "First Aid Kit - Neurological"
	comtype = /obj/item/storage/firstaid/brain
	price = PRICE_RECURRING*0.6

/datum/commodity/medical/firstaidC
	comname = "First Aid Kit - Critical"
	comtype = /obj/item/storage/firstaid/crit
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/medical/injectorPent
	comname = "Auto-Injector - Pentetic Acid"
	comtype = /obj/item/reagent_containers/emergency_injector/pentetic_acid
	price = PRICE_RECURRING_COSTLY

/datum/commodity/medical/injectorPerf
	comname = "Auto-Injector - Perfluorodecalin"
	comtype = /obj/item/reagent_containers/emergency_injector/perf
	price = PRICE_RECURRING_COSTLY

/datum/commodity/medical/ether
	comname = "Ether"
	comtype = /obj/item/reagent_containers/glass/bottle/ether
	desc = "A strong but highly addictive anesthetic and sedative."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/medical/toxin
	comname = "Toxin"
	comtype = /obj/item/reagent_containers/glass/bottle/toxin
	desc = "Various toxin compounds."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/medical/cyanide
	comname = "Cyanide"
	comtype = /obj/item/reagent_containers/pill/toxlite
	desc = "A rapidly acting and highly dangerous chemical."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/medical/omnizine
	comname = "Omnizine"
	comtype = /obj/item/reagent_containers/glass/bottle/omnizine
	desc = "An experimental and expensive herbal compound."
	price = PRICE_LUXURY_COSTLY

///// costume kits

/datum/commodity/costume
	onmarket = 0

/datum/commodity/costume/bee
	comname = "Bee Costume"
	comtype = /obj/item/storage/box/costume/bee
	desc = "A licensed costume that makes you look like a bumbly bee!"
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/monkey
	comname = "Monkey Costume"
	comtype = /obj/item/storage/box/costume/monkey
	desc = "A licensed costume that makes you look like a monkey!"
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/robuddy
	comname = "Guardbuddy Costume"
	comtype = /obj/item/storage/box/costume/robuddy
	desc = "A licensed costume that makes you look like a PR-6 Guardbuddy!"
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/waltwhite
	comname = "Meth Scientist Costume"
	comtype = /obj/item/storage/box/costume/crap/waltwhite
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/spiderman
	comname = "Red Alien Costume"
	comtype = /obj/item/storage/box/costume/crap/spiderman
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/wonka
	comname = "Victorian Confectionery Factory Owner Costume"
	comtype = /obj/item/storage/box/costume/crap/wonka
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/goku
	comname = "Anime Martial Artist Costume"
	comtype = /obj/item/storage/box/costume/crap/goku
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/light_borg //YJHGHTFH's light borg costume
	comname = "Light Cyborg Costume"
	comtype = /obj/item/storage/box/costume/light_borg
	desc = "Beep-bop synthesizer sold separately."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/utena //YJHGHTFH's utena costume & AffableGiraffe's anthy dress
	comname = "Revolutionary Costume Set"
	comtype = /obj/item/storage/box/costume/utena
	desc = "A set of fancy clothes that may or may not give you the power to revolutionize things. Magic sword not included."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/werewolf
	comname = "Werewolf Costume"
	comtype = /obj/item/storage/box/costume/werewolf
	desc = "A surprisingly decent quality werewolf costume, probably from some discount Halloween superstore."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/costume/vampire
	comname = "Vampire Costume"
	comtype = /obj/item/storage/box/costume/vampire
	desc = "A bunch of clothing that kinda resembles a vampire from some old piece of cinema."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/costume/abomination
	comname = "Abomination Costume"
	comtype = /obj/item/storage/box/costume/abomination
	desc = "Who's seen a shambling abomination in such close detail to recreate such a monstrosity?"
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/costume/roller_disco
	comname = "Roller Disco Costume"
	comtype = /obj/item/storage/box/costume/roller_disco
	desc = "You'll really impress your pals at the next Saturday night roller disco."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/hotdog
	comname = "Hotdog Costume"
	comtype = /obj/item/storage/box/costume/hotdog
	desc = "Hot-diggity-dog!"
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/scifi
	comname = "Sci-Fi Garb Set"
	comtype = /obj/item/storage/box/costume/scifi
	desc = "From a faraway time and place."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/purpwitch
	comname = "Purple Witch Costume Set"
	comtype = /obj/item/storage/box/costume/purpwitch
	desc = "It won't give you any real magic, but you always have the magic of Imagination."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/costume/mintwitch
	comname = "Mint Witch Costume Set"
	comtype = /obj/item/storage/box/costume/mintwitch
	desc = "It won't give you any real magic, but you always have the magic of Imagination."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/costume/mime
	comname = "Mime Clothes"
	comtype = /obj/item/storage/box/costume/mime
	desc = "No words can describe this. Only intricate gesticulation."
	price = PRICE_RECURRING*0.75

/datum/commodity/costume/mime/alt
	comname = "Alternate Mime Clothes."
	comtype = /obj/item/storage/box/costume/mime/alt
	desc = "This stuff will give you an edge in charades."

/datum/commodity/costume/jester
	comname = "Jester Costume Set."
	comtype = /obj/item/storage/box/costume/jester
	desc = "Travel back in time and become the medieval version of a clown. (Does not provide time travel)"
	price = PRICE_RECURRING_COSTLY

/datum/commodity/costume/rabbitsuit
	comname = "Rabbit Suit"
	comtype = /obj/item/storage/box/costume/rabbitsuit
	desc = "A not-at-all scary rabbit suit! Steam clean only."
	price = PRICE_RECURRING*0.75

/datum/commodity/costume/blorbosuit
	comname = "Mx. Blorbo suit"
	comtype = /obj/item/storage/box/costume/blorbosuit
	desc = "The delightful regalia of a terrible polkadot mascot."
	price = PRICE_RECURRING*0.75

/datum/commodity/costume/chompskysuit
	comname = "Gnome Chompsky costume"
	comtype = /obj/item/storage/box/costume/chompskysuit
	desc = "Roam as a Gnome with this giant-sized gnome costume."
	price = PRICE_RECURRING*0.75

/datum/commodity/backpack/breadpack
	comname = "Bag-uette"
	comtype = /obj/item/storage/backpack/breadpack
	desc = "A bread-themed backpack...? It kind of smells like bread too! Unfortunately inedible."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/backpack/bearpack
	comname = "Bearpack"
	comtype = /obj/item/storage/backpack/bearpack
	desc = "A teddy bear backpack; perfect for hugs AND carries your gear for you, how helpful!"
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/backpack/turtlebrown
	comname = "Brown Turtle Shell Backpack"
	comtype = /obj/item/storage/backpack/turtlebrown
	desc = "All the hip teenage mutants have one of these turtle shell backpacks."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/backpack/turtlegreen
	comname = "Green Turtle Shell Backpack"
	comtype = /obj/item/storage/backpack/turtlegreen
	desc = "All the hip teenage mutants have one of these turtle shell backpacks."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/balloons //no it ain't a costume kit but it's going in Geoff's wares so idgaf tOt fite me
	comname = "box of balloons"
	comtype = /obj/item/storage/box/balloonbox
	desc = "A box full of colorful balloons!  Neat!"
	onmarket = 0
	price = PRICE_30

/datum/commodity/crayons
	comname = "box of crayons"
	comtype = /obj/item/storage/box/crayon
	desc = "A box of colorful crayons! Lovely!"
	onmarket = 0
	price = PRICE_30

/datum/commodity/sticker
	onmarket = 0

/datum/commodity/sticker/googly_eyes
	comname = "box of googly eyes"
	comtype = /obj/item/item_box/googly_eyes
	desc = "A box of googly eyes! Sweet!"
	onmarket = 0
	price = PRICE_30

/datum/commodity/sticker/googly_eyes_angry
	comname = "box of angry googly eyes"
	comtype = /obj/item/item_box/googly_eyes/angry
	desc = "A box of angry googly eyes! Aaaaargh!"
	onmarket = 0
	price = PRICE_30

/datum/commodity/toygun
	comname = "Toy Gun"
	comtype = /obj/item/gun/kinetic/foamdartgun
	desc = "A toy gun that fires foam darts."
	onmarket = 0
	price = PRICE_75

/datum/commodity/toygunammo
	comname = "Foam Darts"
	comtype = /obj/item/ammo/bullets/foamdarts
	desc = "Six foam darts for toy guns."
	onmarket = 0
	price = PRICE_30

/datum/commodity/clownsabre
	comname = "C-Sabre"
	comtype = /obj/item/swords_sheaths/clown
	desc = "A high quality sabre."
	onmarket = 0
	price = PRICE_RECURRING*0.75

/datum/commodity/clown_nose
	comname = "Clown Nose"
	comtype = /obj/item/clothing/mask/clown_nose
	desc = "A clown nose, simple!"
	onmarket = 0
	price = PRICE_30

/*
/datum/commodity/screamshoes
	comname = "scream shoes"
	comtype = /obj/item/clothing/shoes/scream
	desc = "AAAAAAAAAAAAAAAAAAAA!"
	onmarket = 0
	price = 50
	baseprice = 100
	upperfluc = 150
	lowerfluc = -20

/datum/commodity/fartflops
	comname = "fart-flops"
	comtype = /obj/item/clothing/shoes/fart
	desc = "They fart when you walk."
	onmarket = 0
	price = 50
	baseprice = 100
	upperfluc = 150
	lowerfluc = -20
*/

/datum/commodity/largeartifact
	comname = "Large Artifact"
	comtype = null
	onmarket = 0
	price = PRICE_LUXURY*0.4

/datum/commodity/smallartifact
	comname = "Handheld Artifact"
	comtype = null
	onmarket = 0
	price = PRICE_LUXURY*0.4

// FLOCKTRADER COMMODITIES AND PRICES
/datum/commodity/flock
	desc = "Goods that the Flocktrader sells or wants."
	onmarket = 0

// WANTS TO BUY
/datum/commodity/flock/desired
	desc = "This material can be used by us to repair our ship and fabricate new drones."

/datum/commodity/flock/desired/videocard
	comname = "Advanced Videocard"
	comtype = /obj/item/peripheral/videocard
	desc_buy = "We're aware your computers can't handle this peripheral. We can find a use for it."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/flock/desired/feather
	comname = "Feather"
	comtype = /obj/item/feather
	desc_buy = "Low material value, but it reminds us of the Source. We find these comforting."
	price = PRICE_30

/datum/commodity/flock/desired/electronics
	comname = "Electronic Components"
	comtype = /obj/item/electronics
	desc_buy = "The aggressive drones of this space have useful innards."
	price = PRICE_50

/datum/commodity/flock/desired/brain
	comname = "Brain"
	comtype = /obj/item/organ/brain
	desc_buy = "We are experimenting with new cognitive microstructures. Specimens for research are appreciated."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/flock/desired/beeegg
	comname = "Bee Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	desc_buy = "These creatures have a fascinating genetic structure. Specimens for research are appreciated."
	price = PRICE_RECURRING*0.6

/datum/commodity/flock/desired/critteregg
	comname = "Creature Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter
	desc_buy = "We are interested in novel biological structures within this region of space. Specimens for research are appreciated."
	price = PRICE_RECURRING*0.6

/datum/commodity/flock/desired/egg
	comname = "Regular Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg
	desc_buy = "Eggs are delicious and a good source of nutrients for growing flockdrones."
	price = PRICE_15

/datum/commodity/flock/desired/material
	comname = "Material Piece"
	comtype = /obj/item/material_piece
	desc_buy = "We are not selective. Any processed material is acceptable."
	price = PRICE_30

/datum/commodity/flock/desired/rawmaterial
	comname = "Raw Material Piece"
	comtype = /obj/item/raw_material
	desc_buy = "We are not selective. Any raw material is acceptable."
	price = PRICE_30

// WILL SELL
/datum/commodity/flock/tech
	desc = "Our technology is unique and unattainable elsewhere."

/datum/commodity/flock/tech/table
	comname = "Flocktable"
	comtype = /obj/item/furniture_parts/table/flock
	desc = "A processing subsystem of obsolete design with a perfectly flat surface. Good for placing things."
	price = PRICE_RECURRING*0.75

/datum/commodity/flock/tech/chair
	comname = "Flockchair"
	comtype = /obj/item/furniture_parts/flock_chair
	desc = "Prior to our mass-energy conversion technology, we used these chambers to charge our drones. Now padded with feather-down cushions for comfort."
	price = PRICE_RECURRING*0.75

/datum/commodity/flock/tech/gnesis
	comname = "Gnesis"
	comtype = /obj/item/material_piece/gnesis
	desc = "Our mind and matter, filled with stoic and resolute intent."
	price = PRICE_LUXURY*0.4

/datum/commodity/flock/tech/gnesisglass
	comname = "Translucent Gnesis"
	comtype = /obj/item/material_piece/gnesisglass
	desc = "Our mind and matter, filled with open and honest intent."
	price = PRICE_LUXURY*0.4

/datum/commodity/flock/tech/flocknugget
	comname = "Flocknugget"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock
	desc = "Apparently this is a delicacy. We did not know your kind can stomach metallic crystal."
	price = PRICE_15

/datum/commodity/flock/tech/flockbrain
	comname = "Processing Core"
	comtype = /obj/item/organ/brain/flockdrone
	desc = "We are loathe to part with our processing cores, but we can be convinced with enough credits."
	price = PRICE_LUXURY*0.4

/datum/commodity/flock/tech/fluid
	comname = "Fluid Cache"
	comtype = /obj/item/reagent_containers/gnesis
	desc = "A sealed container with a fluid form of our matter, filled with indecision. We wish you the very best in figuring out how to extract the fluid."
	price = PRICE_LUXURY*0.6

/datum/commodity/flock/tech/flockburger
	comname = "Flockburger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/flockburger
	desc = "We have found a new use for completely irrecoverable processing cores. We cannot currently offer fries with that. We've changed the recipe after some complaints from our customers."
	price = PRICE_30

/datum/commodity/flock/tech/flockblocker
	comname = "Flockblocker Telejammer"
	comtype = /obj/item/device/flockblocker
	desc = "A handheld teleportation jammer powered by the universe's contempt for those who attempt to bend space to their whim."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/flock/tech/incapacitor
	comname = "Incapacitor"
	comtype = /obj/item/gun/energy/flock
	desc = "We have tried to replicate our pacification technology in a form your kind can use. There may be some issues."
	price = PRICE_EXORBITANT*2.5

/datum/commodity/flock/tech/ai_kit_flock
	comname = "Flock Plating Kit"
	comtype = /obj/item/ai_plating_kit/flock
	desc = "A decorative plating kit for a computational core. We cannot guarantee an absence of side effects."
	price = PRICE_LUXURY*0.4

/////////////////////////////////
///////skeleton trader //////////
/////////////////////////////////

/datum/commodity/hat
	onmarket = 0

/datum/commodity/hat/bandana
	comname = "Bandana"
	comtype = /obj/item/clothing/head/bandana/random_color
	desc = "A randomly colored bandana."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/hat/beret
	comname = "Beret"
	comtype = /obj/item/clothing/head/beret/random_color
	desc = "A randomly colored beret."
	price = PRICE_RECURRING_COSTLY

/datum/commodity/hat/spacehelmet
	comname = "Space Helmet"
	comtype = /obj/item/clothing/head/helmet/space/oldish
	desc = "An old space helmet."
	price = PRICE_LUXURY_CHEAP*0.6

	red
		comname = "Red Space Helmet"
		comtype = /obj/item/clothing/head/helmet/space/syndicate/old
		desc = "An old space helmet. It's red."

/datum/commodity/hat/pinkwizard
	comname = "Pink Wizard Hat"
	comtype = /obj/item/clothing/head/pinkwizard
	desc = "A pink wizard hat. Magic not included."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/hat/purplebutt
	comname = "Purple Butt Hat"
	comtype = /obj/item/clothing/head/purplebutt
	desc = "Exotic."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/hat/dailyspecial
	comname = "Daily Special"
	comtype = null
	desc = "Purchase assured, it's a bargain."
	price = PRICE_LUXURY_CHEAP*0.6

	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/head/dramachefhat
			if ("tuesday")
				comtype = /obj/item/clothing/head/psyche
			if ("wednesday")
				comtype = /obj/item/clothing/head/centhat/red
			if ("thursday")
				comtype = /obj/item/clothing/head/bigtex
			if ("friday")
				comtype = /obj/item/clothing/head/fedora
			if ("saturday")
				comtype = /obj/item/clothing/head/XComHair
			if ("sunday")
				comtype = /obj/item/clothing/head/helmet/greek

/datum/commodity/hat/laurels
	comname = "Laurels"
	comtype = /obj/item/clothing/head/laurels
	desc = "An ancient Greek affair."
	price = PRICE_LUXURY*0.4

/datum/commodity/tech/laptop
	comname = "Personal Laptop"
	comtype = /obj/item/luggable_computer/personal
	desc = "Top of the line!"
	price = PRICE_LUXURY*0.8


////////////////////////////////////////////////

/datum/commodity/clothing
	onmarket = 0

/datum/commodity/clothing/psyche
	comname = "Psychedelic jumpsuit"
	comtype = /obj/item/clothing/under/gimmick/psyche
	desc = "Some garish garb, stolen off a hippie's back."
	price = PRICE_LUXURY*0.8

/datum/commodity/clothing/chameleon
	comname = "Black jumpsuit"
	comtype = /obj/item/clothing/under/chameleon
	desc = "A plain black jumpsuit. Not very mysterious at all, no."
	price = PRICE_LUXURY_COSTLY

/datum/commodity/banana_grenade
	comname = "Banana grenade"
	comtype = /obj/item/old_grenade/spawner/banana
	desc = "Perfect for magic tricks and slips, and some clown's birthday present."
	price = PRICE_LUXURY_CHEAP*0.6

/datum/commodity/foam_dart_grenade
	comname = "Foam Dart Grenade"
	comtype = /obj/item/old_grenade/foam_dart
	desc = "Goes great with foam dart guns!"
	price = PRICE_RECURRING*0.75

/datum/commodity/cheese_grenade
	comname = "Cheese Sandwich grenade"
	comtype = /obj/item/old_grenade/spawner/cheese_sandwich
	desc = "Contains only one type of cheese, unfortunately."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/corndog_grenade
	comname = "Banana Corndog grenade"
	comtype = /obj/item/old_grenade/spawner/banana_corndog
	desc = "A very space efficient party pleaser. No ketchup or mustard included."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/gokart
	comname = "Go-Kart"
	comtype = /obj/racing_clowncar/kart
	desc = "They just don't make the same quality go-karts anymore. Get this relic while you can."
	onmarket = 0
	price = PRICE_LUXURY_COSTLY*0.96

/datum/commodity/car
	comname = "Fancy Car"
	comtype = /obj/machinery/vehicle/tank/car/rusty
	desc = "Might need some TLC, but a discount ride is a discount ride."
	onmarket = 0
	price = PRICE_LUXURY_COSTLY*0.96

/datum/commodity/menthol_cigarettes
	comname = "Menthol Cigarettes"
	comtype = /obj/item/clothing/mask/cigarette/menthol
	desc = "Gotta get some minty smokes."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY

/datum/commodity/propuffs
	comname = "Pro Puffs"
	comtype = /obj/item/clothing/mask/cigarette/propuffs
	desc = "These flavors are are gold."
	onmarket = 0
	price = PRICE_RECURRING_COSTLY


///////////////////greg///////////////////////////////
/datum/commodity/airzooka
	comname = "Donk Co. brand Airzooka"
	comtype = /obj/item/gun/kinetic/airzooka
	desc = "A high tech air deploying and transportation device produced by Donk Co!"
	onmarket = 0
	price = PRICE_LUXURY*0.8

/datum/commodity/airbag
	comname = "Airzooka Replacement Bag"
	comtype = /obj/item/ammo/bullets/airzooka
	desc = "A replacement bag for your Donk Co brand Airzooka!"
	onmarket = 0
	price = PRICE_LUXURY_CHEAP*0.48

/datum/commodity/dangerbag
	comname = "Airzooka Replacement Bag: Xtreme Edition"
	comtype = /obj/item/ammo/bullets/airzooka/bad
	desc = "A replacement bag for your Donk Co brand Airzooka, now with plasma lining!"
	onmarket = 0
	price = PRICE_LUXURY*0.8

/datum/commodity/owleggs
	comname = "Owl Eggs"
	desc = "We are currently accepting donations of Owl Eggs for the exhibits! isn't that hootastic?"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl
	onmarket = 0
	price = PRICE_RECURRING*0.75

/datum/commodity/hat/dailyspecial/greg
	comname = "Daily Special"
	comtype = null
	desc = "We are now authorized to begin importing fashion accessories for our customers!"
	onmarket = 0
	price = PRICE_LUXURY*0.4

/datum/commodity/crayons/greg
	comname = "box of crayons"
	comtype = /obj/item/storage/box/crayon
	desc = "Donkola brand color sticks! FDA approved to not cause sudden cell death since 2032!"
	onmarket = 0
	price = PRICE_75

/datum/commodity/drugs/poppies/greg
	comname = "Poppies"
	desc = "In respect of those lost during the colonization of the frontier, we are now offering poppies."
	comtype = /obj/item/plant/herb/poppy/spawnable
	onmarket = 0
	price = PRICE_RECURRING*0.75

/datum/commodity/owlpaint
	comtype = /obj/item/pod/paintjob/owl
	comname = "Limited Edition Owlery Brand Pod Painting Kit"
	desc = "Now you can represent your love for the Owls by painting your Space Pod in our signature colors!"
	onmarket = 0
	price = PRICE_LUXURY*0.8

/datum/commodity/HEtorpedo
	comname = "High Explosive Torpedo"
	comtype = /obj/torpedo_tray/hiexp_loaded
	desc = "A highly explosive torpedo, ready for your sick, destructive needs."
	onmarket = 0
	price = PRICE_EXORBITANT

/datum/commodity/sketchy_press_upgrade
	comname = "Sketchy press upgrade"
	desc = "This looks like a bootlegged printing press upgrade."
	comtype = /obj/item/press_upgrade/forbidden
	onmarket = 0
	price = PRICE_LUXURY*0.4

/datum/commodity/expensive_card
	comname = "Incredibly Expensive Card"
	desc = "Wow...people really pay a lot for these cards..."
	comtype = /obj/item/playing_card/expensive
	onmarket = 1
	price = PRICE_LUXURY_COSTLY
