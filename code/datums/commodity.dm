// Commodities
/datum/commodity/
	var/comname = "commodity" // Name of the item on the market
	var/comtype = null // Type Path of the item on the market
	var/price = 0 // Current selling price for this commodity
	var/baseprice = 0 // Baseline selling price for this commodity
	var/onmarket = 0 // Whether this item is currently being accepted for sale on the shipping market
	var/indemand = 0 // Whether this item is currently being bought at a high price on the market
	var/upperfluc = 0 // Highest this item's price can raise in one shift
	var/lowerfluc = 0 // Lowest this item's price can drop in one shift (negative numbers only)
	var/desc = "item" //Description for item
	var/desc_buy = "There are several buyers interested in acquiring this item." //Description for player selling
	var/desc_buy_demand = "This item is in high demand." //Descripition for player selling when in high demand
	var/hidden = 0 //Sometimes traders won't say if they will buy something
	var/haggleattempts = 0
	var/amount = -1 // Used for QM traders - how much of a thing they have for sale, unlim if -1
	///if true, subtypes of this item will be accepted by NPC traders
	var/subtype_valid = TRUE
	// if its in the shopping cart, this is how many you're buying instead

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

/datum/commodity/electronics
	comname = "Electronic Parts"
	comtype = /obj/item/electronics
	price = 25
	baseprice = 25
	upperfluc = 15
	lowerfluc = -15
	onmarket = 1

/datum/commodity/robotics
	comname = "Robot Parts"
	comtype = /obj/item/parts/robot_parts
	desc_buy = "The Omega Mining Corporation is expanding its operations and is in need of some robot parts"
	desc_buy_demand = "Cyborgs have revolted in the Lambada Quadrant, they are in desprate need of some more robot parts"
	onmarket = 1
	price = 65
	baseprice = 65
	upperfluc = 30
	lowerfluc = -30

/datum/commodity/produce
	comname = "Fresh Produce"
	comtype = /obj/item/reagent_containers/food/snacks/plant
	onmarket = 1
	price = 50
	baseprice = 50
	upperfluc = 25
	lowerfluc = -25

/datum/commodity/meat
	comname = "Meat"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat
	onmarket = 1
	price = 50
	baseprice = 50
	upperfluc = 25
	lowerfluc = -25

/datum/commodity/herbs
	comname = "Medical Herbs"
	comtype = /obj/item/plant/herb
	onmarket = 1
	price = 75
	baseprice = 75
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/honey
	comname = "Space Honey"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/honey
	desc_buy = "Meagre nectar yields this year have made honey imports desirable to space-bee hives."
	onmarket = 1
	price = 200
	baseprice = 200
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/sheet
	comname = "Material Sheets"
	comtype = /obj/item/sheet
	desc = "High-quality material sheets."
	onmarket = 1
	price = 7 // no more scamming
	baseprice = 7
	upperfluc = 3
	lowerfluc = -3
/// pathology

/datum/commodity/mat_bar
	comname = "Material Bar"
	comtype = /obj/item/material_piece
	desc = "A Material Bar of some type."
	desc_buy = "The Promethus Consortium is currently gathering resources for a research project and is willing to buy this item"
	desc_buy_demand = "The colony on Regus X has had their main power reactor break down and need this item for repairs"
	onmarket = 1
	price = 70
	baseprice = 70
	upperfluc = 30
	lowerfluc = -30

/datum/commodity/ore // because QMs keep scamming the system, I am lowering the base price of ore way down - cogwerks
	comname = "Rock"
	comtype = /obj/item/raw_material
	desc = "An ore that has various practical uses in manufacturing and research."
	desc_buy = "The Promethus Consortium is currently gathering resources for a research project and is willing to buy this item"
	desc_buy_demand = "The colony on Regus X has had their main power reactor break down and need this item for repairs"
	onmarket = 0
	price = 70 // because it's no longer possible to scam this system in this way, i am raising the base price of ore way up - urs
	baseprice = 70
	upperfluc = 30
	lowerfluc = -30

/datum/commodity/ore/mauxite
	comname = "Mauxite"
	comtype = /obj/item/raw_material/mauxite
	onmarket = 1
/datum/commodity/mat_bar/mauxite
	comname = "Mauxite Bar"
	comtype = /obj/item/material_piece/mauxite
	onmarket = 0

/datum/commodity/ore/pharosium
	comname = "Pharosium"
	comtype = /obj/item/raw_material/pharosium
	onmarket = 1
/datum/commodity/mat_bar/pharosium
	comname = "Pharosium Bar"
	comtype = /obj/item/material_piece/pharosium
	onmarket = 0

/datum/commodity/ore/char
	comname = "Char"
	comtype = /obj/item/raw_material/char
	onmarket = 1
	price = 35
	baseprice = 35
	upperfluc = 50
	lowerfluc = -25
/datum/commodity/mat_bar/char
	comname = "Char Bar"
	comtype = /obj/item/material_piece/char
	onmarket = 0
	price = 35
	baseprice = 35
	upperfluc = 50
	lowerfluc = -25

/datum/commodity/ore/molitz
	comname = "Molitz"
	comtype = /obj/item/raw_material/molitz
	onmarket = 1
/datum/commodity/mat_bar/molitz
	comname = "Molitz Bar"
	comtype = /obj/item/material_piece/molitz
	onmarket = 0

/datum/commodity/ore/cobryl
	comname = "Cobryl"
	comtype = /obj/item/raw_material/cobryl
	onmarket = 1
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100
/datum/commodity/mat_bar/cobryl
	comname = "Cobryl Bar"
	comtype = /obj/item/material_piece/cobryl
	onmarket = 0
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/ore/uqill
	comname = "Uqill"
	comtype = /obj/item/raw_material/uqill
	onmarket = 1
	price = 750
	baseprice = 750
	upperfluc = 1000
	lowerfluc = -500
/datum/commodity/mat_bar/uqill
	comname = "Uqill Bar"
	comtype = /obj/item/material_piece/uqill
	onmarket = 0
	price = 750
	baseprice = 750
	upperfluc = 1000
	lowerfluc = -500

/datum/commodity/ore/telecrystal
	comname = "Telecrystal"
	comtype = /obj/item/raw_material/telecrystal
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	onmarket = 1
	price = 1000
	baseprice = 1000
	upperfluc = 1000
	lowerfluc = -500
/datum/commodity/mat_bar/telecrystal
	comname = "Telecrystal Block"
	comtype = /obj/item/material_piece/telecrystal
	onmarket = 0
	price = 1000
	baseprice = 1000
	upperfluc = 1000
	lowerfluc = -500

/datum/commodity/ore/fibrilith // why is this worth a ton of money?? dropping the value to further upset QMs
	comname = "Fibrilith"
	comtype = /obj/item/raw_material/fibrilith
	onmarket = 1
/datum/commodity/mat_bar/fibrilith
	comname = "Fibrilith Block"
	comtype = /obj/item/material_piece/fibrilith
	onmarket = 0

/datum/commodity/ore/koshmarite
	comname = "Koshmarite"
	comtype = /obj/item/raw_material/eldritch
	onmarket = 1
	price = 100
	baseprice = 100
	upperfluc = 100
	lowerfluc = -50
/datum/commodity/mat_bar/koshmarite
	comname = "Koshmarite Block"
	comtype = /obj/item/material_piece/koshmarite
	onmarket = 0
	price = 100
	baseprice = 100
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/ore/viscerite
	comname = "Viscerite"
	comtype = /obj/item/raw_material/martian
	onmarket = 1
	price = 100
	baseprice = 100
	upperfluc = 100
	lowerfluc = -50
/datum/commodity/mat_bar/viscerite
	comname = "Viscerite Block"
	comtype = /obj/item/material_piece/viscerite
	onmarket = 0
	price = 100
	baseprice = 100
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/ore/bohrum
	comname = "Bohrum"
	comtype = /obj/item/raw_material/bohrum
	onmarket = 1
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100
/datum/commodity/mat_bar/bohrum
	comname = "Bohrum Bar"
	comtype = /obj/item/material_piece/bohrum
	onmarket = 0
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/ore/claretine
	comname = "Claretine"
	comtype = /obj/item/raw_material/claretine
	onmarket = 1
	price = 350
	baseprice = 350
	upperfluc = 200
	lowerfluc = -200
/datum/commodity/mat_bar/claretine
	comname = "Claretine Bar"
	comtype = /obj/item/material_piece/claretine
	onmarket = 0
	price = 350
	baseprice = 350
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/ore/erebite
	comname = "Erebite"
	comtype = /obj/item/raw_material/erebite
	onmarket = 1
	price = 650
	baseprice = 650
	upperfluc = 200
	lowerfluc = -200
/datum/commodity/mat_bar/erebite
	comname = "Erebite Bar"
	comtype = /obj/item/material_piece/erebite
	onmarket = 0
	price = 650
	baseprice = 650
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/ore/cerenkite
	comname = "Cerenkite"
	comtype = /obj/item/raw_material/cerenkite
	onmarket = 1
	price = 480
	baseprice = 480
	upperfluc = 200
	lowerfluc = -200
/datum/commodity/mat_bar/cerenkite
	comname = "Cerenkite Bar"
	comtype = /obj/item/material_piece/cerenkite
	onmarket = 0
	price = 650
	baseprice = 650
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/ore/plasmastone
	comname = "Plasmastone"
	comtype = /obj/item/raw_material/plasmastone
	onmarket = 1
	price = 550
	baseprice = 550
	upperfluc = 200
	lowerfluc = -200
/datum/commodity/mat_bar/plasmastone
	comname = "Plasmastone Bar"
	comtype = /obj/item/material_piece/plasmastone
	onmarket = 0
	price = 550
	baseprice = 550
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/ore/syreline
	comname = "Syreline"
	comtype = /obj/item/raw_material/syreline
	onmarket = 1
	price = 800
	baseprice = 800
	upperfluc = 1000
	lowerfluc = -300
/datum/commodity/mat_bar/syreline
	comname = "Syreline Bar"
	comtype = /obj/item/material_piece/syreline
	onmarket = 0
	price = 800
	baseprice = 800
	upperfluc = 1000
	lowerfluc = -300

/datum/commodity/ore/gold
	comname = "Gold Nugget"
	comtype = /obj/item/raw_material/gold
	onmarket = 1
	price = 3500
	baseprice = 3500
	upperfluc = 5000
	lowerfluc = -2500
	onmarket = 1

/datum/commodity/goldbar
	comname = "Gold Bullion"
	comtype = /obj/item/material_piece/gold
	onmarket = 1
	price = 35000
	baseprice = 35000
	upperfluc = 50000
	lowerfluc = -25000

/datum/commodity/laser_gun
	comname = "Laser Gun"
	comtype =  /obj/item/gun/energy/laser_gun
	onmarket = 0
	desc = "A laser gun. Pew pew."
	price = 2000
	baseprice = 2000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/pen
	comname = "Pen"
	comtype = /obj/item/pen
	desc = "A useful writing tool."
	onmarket = 0
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/guardbot_medicator
	comname = "Medicator Tool Module"
	comtype = /obj/item/device/guardbot_tool/medicator
	desc = "A 'Medicator' syringe launcher module for PR-6S Guardbuddies. These things are actually outlawed on Earth."
	onmarket = 0
	price = 75
	baseprice = 75
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/guardbot_smoker
	comname = "Smoker Tool Module"
	comtype = /obj/item/device/guardbot_tool/smoker
	desc = "A riot-control gas module for PR-6S Guardbuddies."
	onmarket = 0
	price = 250
	baseprice = 250
	upperfluc = 40
	lowerfluc = -40

/datum/commodity/guardbot_flash
	comname = "Flash Tool Module"
	comtype = /obj/item/device/guardbot_tool/flash
	desc = "A flash module for PR-6S Guardbuddies."
	onmarket = 0
	price = 75
	baseprice = 75
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/guardbot_taser
	comname = "Taser Tool Module"
	comtype = /obj/item/device/guardbot_tool/taser
	desc = "A taser module for PR-6S Guardbuddies."
	onmarket = 0
	price = 175
	baseprice = 75
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/guardbot_kit
	comname = "Guardbot Construction Kit"
	comtype = /obj/item/storage/box/guardbot_kit
	desc = "A useful kit for building guardbuddies. All you need is a module!"
	onmarket = 0
	price = 100
	baseprice = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/boogiebot
	comname = "Boogiebot"
	comtype = /obj/critter/boogiebot
	desc = "The latest in boogie technology!"
	onmarket = 0
	price = 5000
	baseprice = 5000
	upperfluc = 500
	lowerfluc = -500

// cogwerks - NPC stuff

/datum/commodity/fuel // buy from trader NPC
	comname = "Fuel Tank"
	comtype = /obj/item/tank/plasma
	desc = "A small tank of plasma. Use with caution."
	onmarket = 0
	price = 250
	baseprice = 250
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/royaljelly
	comname = "Royal Jelly"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	desc = "A sample of royal jelly, a nutritive compound for bee larvae."
	onmarket = 0
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100
	onmarket = 0

/datum/commodity/beeegg
	comname = "Bee Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	onmarket = 0
	desc = "A space bee egg.  Space bees hatch from these."
	price = 75
	baseprice = 75
	upperfluc = 10
	lowerfluc = -10
	onmarket = 0

/datum/commodity/b33egg
	comname = "Irregular Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy
	desc = "This batch of space bee eggs exhibits a minor irregularity that kept it out of normal distribution channels."
	onmarket = 0
	price = 75
	baseprice = 75
	upperfluc = 10
	lowerfluc = -10
	onmarket = 0

/datum/commodity/bee_kibble
	comname = "Bee Kibble"
	comtype = /obj/item/reagent_containers/food/snacks/beefood
	desc = "Essentially cereal for bees.  Tastes pretty good, provided that you are a bee."
	onmarket = 0
	price = 50
	baseprice = 50
	upperfluc = 10
	lowerfluc = -10
	onmarket = 0

//////////////////////
//// pod sales ///////
//////////////////////

/datum/commodity/podparts
	onmarket = 0

/datum/commodity/podparts/engine
	comname = "HERMES Engine"
	comtype = /obj/item/shipcomponent/engine/hermes
	desc = "A heavy-duty engine for pod vehicles."
	price = 5500
	baseprice = 5500
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/podparts/laser
	comname = "Mk.2 Scout Laser"
	comtype = /obj/item/shipcomponent/mainweapon/laser
	desc = "A standard military laser built around a pod-based weapons platform."
	price = 25000
	baseprice = 25000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/podparts/asslaser
	comname = "Assault Laser Array"
	comtype = /obj/item/shipcomponent/mainweapon/laser_ass
	desc = "Usually only seen on cruiser-class ships. How the hell did this end up here?"
	price = 120000
	baseprice = 120000
	upperfluc = 25000
	lowerfluc = -25000

/datum/commodity/podparts/blackarmor
	comname = "Strange Armor Plating"
	comtype = /obj/item/podarmor/armor_black
	desc = "NT Special Ops vehicular armor plating, almost certainly stolen."
	price = 50000
	baseprice = 50000
	upperfluc = 15000
	lowerfluc = -15000

/datum/commodity/podparts/redarmor
	comname = "Syndicate Pod Armor"
	comtype = /obj/item/podarmor/armor_red
	desc = "A kit of Syndicate pod armor plating."
	price = 25000
	baseprice = 25000
	upperfluc = 8000
	lowerfluc = -8000

/datum/commodity/podparts/goldarmor
	comname = "Gold Pod Armor"
	comtype = /obj/item/podarmor/armor_gold
	desc = "A kit of gold-plated pod armor plating."
	price = 32500
	baseprice = 32500
	upperfluc = 8000
	lowerfluc = -8000

/datum/commodity/podparts/ballistic
	comname = "Ballistic System"
	comtype = /obj/item/shipcomponent/mainweapon/gun
	desc = "A pod-mounted kinetic weapon system."
	price = 45000
	baseprice = 45000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/podparts/artillery
	comname = "40mm Assault Platform"
	comtype = /obj/item/shipcomponent/mainweapon/artillery
	desc = "A pair of ballistic launchers, fires explosive 40mm shells."
	price = 250000
	baseprice = 250000
	upperfluc = 25000
	lowerfluc = -25000

/datum/commodity/contraband/artillery_ammo
	comname = "40mm HE Ammunition"
	comtype = /obj/item/ammo/bullets/autocannon
	desc = "High explosive grenades, for the resupplement of artillery assault platforms."
	price = 100000
	baseprice = 100000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/podparts/cloak
	comname = "Medusa Stealth System 300"
	comtype = /obj/item/shipcomponent/secondary_system/cloak
	desc = "A cloaking device for stealth recon vehicles."
	price = 500000
	baseprice = 500000
	upperfluc = 25000
	lowerfluc = -25000

/datum/commodity/podparts/skin_stripe_r
	comname = "Pod Paint Job Kit (Red Racing Stripes)"
	comtype = /obj/item/pod/paintjob/stripe_r
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = 5000
	baseprice = 5000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/podparts/skin_stripe_b
	comname = "Pod Paint Job Kit (Blue Racing Stripes)"
	comtype = /obj/item/pod/paintjob/stripe_b
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = 5000
	baseprice = 5000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/podparts/skin_flames
	comname = "Pod Paint Job Kit (Flames)"
	comtype = /obj/item/pod/paintjob/flames
	desc = "A pod paint job kit that makes it look all spiffy!"
	price = 9000
	baseprice = 9000
	upperfluc = 5000
	lowerfluc = -5000

////////////////////////////
///// 420 all day //////////
////////////////////////////

/datum/commodity/drugs
	desc = "Illegal drugs."
	onmarket = 0

/// these are things that you can sell to the traders

/datum/commodity/drugs/poppies
	comname = "Poppies"
	comtype = /obj/item/plant/herb/poppy
	price = 350
	baseprice = 350
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/drugs/shrooms
	comname = "Psilocybin"
	comtype = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	price = 500
	baseprice = 500
	upperfluc = 300
	lowerfluc = -300

/datum/commodity/drugs/cannabis
	comname = "Cannabis"
	comtype = /obj/item/plant/herb/cannabis
	price = 150
	baseprice = 150
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/drugs/cannabis_mega
	comname = "Rainbow Cannabis"
	comtype = /obj/item/plant/herb/cannabis/mega
	price = 700
	baseprice = 700
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/drugs/cannabis_white
	comname = "White Cannabis"
	comtype = /obj/item/plant/herb/cannabis/white
	price = 450
	baseprice = 450
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/drugs/cannabis_omega
	comname = "Omega Cannabis"
	comtype = /obj/item/plant/herb/cannabis/omega
	price = 2500
	baseprice = 2500
	upperfluc = 2000
	lowerfluc = -1000

///// things you can buy from the traders

/datum/commodity/drugs/methamphetamine
	comname = "Methamphetamine (5x pills)"
	comtype = /obj/item/storage/pill_bottle/methamphetamine
	desc = "Methamphetamine is a highly effective and dangerous stimulant drug."
	price = 1250
	baseprice = 1250
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/drugs/crank
	comname = "Crank (5x pills)"
	comtype = /obj/item/storage/pill_bottle/crank
	desc = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
	price = 400
	baseprice = 400
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/drugs/bathsalts
	comname = "Bath Salts (5x pills)"
	comtype = /obj/item/storage/pill_bottle/bathsalts
	desc = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	price = 6500
	baseprice = 6500
	upperfluc = 2500
	lowerfluc = -1500

/datum/commodity/drugs/catdrugs
	comname = "Cat Drugs (5x pills)"
	comtype = /obj/item/storage/pill_bottle/catdrugs
	desc = "Uhh..."
	price = 5000
	baseprice = 5000
	upperfluc = 2500
	lowerfluc = -1500

/datum/commodity/drugs/morphine
	comname = "Morphine (1x syringe)"
	comtype = /obj/item/reagent_containers/syringe/morphine
	desc = "A strong but highly addictive opiate painkiller with sedative side effects."
	price = 350
	baseprice = 350
	upperfluc = 250
	lowerfluc = -250

/datum/commodity/drugs/krokodil
	comname = "Krokodil (1x syringe)"
	comtype = /obj/item/reagent_containers/syringe/krokodil
	desc = "A sketchy homemade opiate often used by disgruntled Cosmonauts."
	price = 100
	baseprice = 100
	upperfluc = 150
	lowerfluc = -150

/datum/commodity/drugs/jenkem
	comname = "Jenkem (1x syringe)"
	comtype = /obj/item/reagent_containers/syringe/jenkem
	desc = "A low quality sewage drug used by no one in the right state of mind."
	price = 300
	baseprice = 300
	upperfluc = 150
	lowerfluc = -50

/datum/commodity/drugs/lsd
	comname = "LSD (1x patch)"
	comtype = /obj/item/reagent_containers/patch/LSD
	desc = "A highly potent hallucinogenic substance. Far out, maaaan."
	price = 250
	baseprice = 250
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/drug/lsd_bee
	comname = "LSBee (1x patch)"
	comtype = /obj/item/reagent_containers/patch/lsd_bee
	desc = "A highly potent hallucinogenic substance. It smells like honey."
	price = 220
	baseprice = 220
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/pills/uranium
	comname = "Uranium (1x nugget)"
	comtype = /obj/item/reagent_containers/pill/uranium
	desc = "A nugget of weapons grade uranium. Label says it's roughly 'size 5'."
	price = 1000
	baseprice = 1000
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/drugs/cyberpunk
	comname = "Designer Drugs (5x pills)"
	comtype = /obj/item/storage/pill_bottle/cyberpunk
	desc = "Who knows what you might get."
	price = 500
	baseprice = 500
	upperfluc = 500
	lowerfluc = -250

/////////////////////////////////
//// valuable space junk ////////
/////////////////////////////////

/datum/commodity/relics
	desc = "Strange things from deep space."
	onmarket = 0

/datum/commodity/relics/skull
	comname = "Skull"
	comtype = /obj/item/skull
	price = 5000
	baseprice = 5000
	upperfluc = 2500
	lowerfluc = -1000

/datum/commodity/relics/relic
	comname = "Strange Relic"
	comtype = /obj/item/relic
	price = 49500
	baseprice = 49500
	upperfluc = 12500
	lowerfluc = -12500

/datum/commodity/relics/gnome
	comname = "Garden Gnome"
	comtype = /obj/item/gnomechompski
	price = 6000
	baseprice = 6000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/relics/crown
	comname = "Obsidian Crown"
	comtype = /obj/item/clothing/head/void_crown
	price = 52250
	baseprice = 52250
	upperfluc = 20000
	lowerfluc = -20000

/datum/commodity/relics/armor
	comname = "Ancient Armor"
	comtype = /obj/item/clothing/suit/armor/ancient
	price = 86500
	baseprice = 86500
	upperfluc = 20000
	lowerfluc = -20000

/datum/commodity/relics/marshelmet
	comname = "Antique Mars Helmet"
	comtype = /obj/item/clothing/head/helmet/mars
	price = 3500
	baseprice = 3500
	upperfluc = 3000
	lowerfluc = -1500

/datum/commodity/relics/marsuit
	comname = "Antique Mars Suit"
	comtype = /obj/item/clothing/suit/armor/mars
	price = 7000
	baseprice = 7000
	upperfluc = 5000
	lowerfluc = -3000

/datum/commodity/relics/bootlegfirework
	comname = "Bootleg Firework (1x rocket)"
	comtype = /obj/item/firework/bootleg
	desc = "Bootleg fireworks, found deep in the back of an old warehouse."
	price = 60
	baseprice = 60
	upperfluc = 10
	lowerfluc = -10

////////////////////////////////
///// syndicate trader /////////
////////////////////////////////

/datum/commodity/contraband
	comname = "Contraband"
	desc = "Stolen gear and syndicate products."
	onmarket = 0

/datum/commodity/contraband/captainid
	comname = "NT Captain Gold ID"
	comtype = /obj/item/card/id/captains_spare
	desc = "NT gold-level registered captain ID."
	price = 7500
	baseprice = 7500
	upperfluc = 5000
	lowerfluc = -2000

	bee
		comname = "Captain Gold ID"
		desc_buy = "The kind of ID a queen would probably hang on the wall of the hive or something."

/datum/commodity/contraband/spareid
	comname = "NT Spare Gold ID"
	comtype = /obj/item/card/id/gold
	desc = "NT gold-level unregistered spare ID."
	price = 7500
	baseprice = 7500
	upperfluc = 5000
	lowerfluc = -2000

	bee
		comname = "Gold ID"
		desc_buy = "You know, gold, like honey! Grey ones are out of place in a hive."

/datum/commodity/contraband/secheadset
	comname = "Security Headset"
	comtype = /obj/item/device/radio/headset/security
	desc = "A radio headset used by NT security forces."
	price = 2000
	baseprice = 2000
	upperfluc = 2000
	lowerfluc = -1000

/datum/commodity/contraband/hosberet
	comname = "Head of Security Beret"
	comtype = /obj/item/clothing/head/hos_hat
	desc = "The beloved beret of an NT HoS."
	price = 10000
	baseprice = 10000
	upperfluc = 5000
	lowerfluc = -3000

/datum/commodity/contraband/egun
	comname = "Energy Gun"
	comtype = /obj/item/gun/energy/egun
	desc = "A standard-issue NT energy gun."
	price = 7000
	baseprice = 7000
	upperfluc = 4000
	lowerfluc = -1000

//// purchase stuff

/datum/commodity/contraband/command_suit
	comname = "Armored Spacesuit"
	comtype = /obj/item/clothing/suit/space/industrial/syndicate
	desc = "An armored spacesuit issued to Syndicate squad leaders."
	price = 20000
	baseprice = 20000
	upperfluc = 5000
	lowerfluc = -5000

/datum/commodity/contraband/command_helmet
	comname = "Armored Helmet"
	comtype = /obj/item/clothing/head/helmet/space/industrial/syndicate/
	desc = "An armored helmet issued to Syndicate squad leaders."
	price = 15000
	baseprice = 15000
	upperfluc = 5000
	lowerfluc = -2000

/datum/commodity/contraband/swatmask
	comname = "Scary Gasmask"
	comtype = /obj/item/clothing/mask/gas/swat
	desc = "Pretty much exactly what it sounds like."
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/contraband/plutonium
	comname = "Plutonium Core"
	comtype = /obj/item/plutonium_core
	desc = "Stolen from a nuclear warhead."
	price = 999999
	baseprice = 999999
	upperfluc = 0
	lowerfluc = 0

/datum/commodity/contraband/radiojammer
	comname = "Radio Jammer"
	comtype = /obj/item/radiojammer
	desc = "A device that can block radio transmissions around it."
	price = 6000
	baseprice = 6000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/contraband/stealthstorage
	comname = "Stealth Storage"
	comtype = /obj/item/storage/box/syndibox
	desc = "Can take on the appearance of another item. Creates a small dimensional rift in space-time, allowing it to hold multiple items."
	price = 400
	baseprice = 400
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/contraband/chamsuit
	comname = "Chameleon Jumpsuit"
	comtype = /obj/item/clothing/under/chameleon
	desc = "A jumpsuit made of advanced fibres that can change colour to suit the needs of the wearer. Do not expose to electromagnetic interference."
	price = 5000
	baseprice = 5000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/contraband/dnascram
	comname = "DNA Scrambler"
	comtype = /obj/item/genetics_injector/dna_scrambler
	desc = "An injector that gives a new, random identity upon injection."
	price = 15000
	baseprice = 15000
	upperfluc = 3000
	lowerfluc = -3000

/datum/commodity/contraband/voicechanger
	comname = "Voice Changer"
	comtype = /obj/item/voice_changer
	desc = "This voice-modulation device will dynamically disguise your voice to that of whoever is listed on your identification card, via incredibly complex algorithms. Discretely fits inside most masks, and can be removed with wirecutters."
	price = 4000
	baseprice = 4000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/contraband/briefcase
	comname = "Briefcase Valve Assembly"
	comtype = /obj/item/device/transfer_valve/briefcase
	desc = "Bomb not included."
	price = 2500
	baseprice = 2500
	upperfluc = 1500
	lowerfluc = -1500

/datum/commodity/contraband/disguiser
	comname = "Holographic Disguiser"
	comtype = /obj/item/device/disguiser
	desc = "Another one of those experimental Syndicate holographic projects, seems to be an older model."
	price = 15000
	baseprice = 15000
	upperfluc = 5000
	lowerfluc = -5000

/datum/commodity/contraband/birdbomb
	comname = "12ga AEX ammo"
	comtype = /obj/item/ammo/bullets/aex
	desc = "12 gauge ammo marked 12ga AEX Large Wildlife Dispersal Cartridge. Huh."
	price = 40000
	baseprice = 40000
	upperfluc = 10000
	lowerfluc = -5000

/datum/commodity/contraband/flare
	comname = "12ga Flare Shells"
	comtype = /obj/item/ammo/bullets/flare
	desc = "Military-grade 12 gauge flare shells. Guaranteed to brighten your day."
	price = 15000
	baseprice = 15000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/contraband/eguncell_highcap
	comname = "High-Capacity Power Cell"
	comtype = /obj/item/ammo/power_cell/high_power
	desc = "Power cell with a capacity of 300 PU. Compatible with energy guns and stun batons."
	price = 10000
	baseprice = 10000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/contraband/spy_sticker_kit
	comname = "Spy Sticker Kit"
	comtype = /obj/item/storage/box/spy_sticker_kit
	desc = "Kit contains innocuous stickers that can be used to broadcast audio and observe a video feed wirelessly."
	price = 1000
	baseprice = 1000
	upperfluc = 200
	lowerfluc = -200

//NT stuff

/datum/commodity/contraband/ntso_uniform
	comname = "Surplus tactical uniform"
	comtype = /obj/item/clothing/under/misc/turds
	desc = "A rather smelly tactical uniform sold off from an NT warehouse."
	price = 1500
	baseprice = 1500
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/contraband/ntso_beret
	comname = "Surplus NT beret"
	comtype = /obj/item/clothing/head/NTberet
	desc = "Fancy. Possibly salvaged, possibly stolen, what's it to you?"
	price = 2500
	baseprice = 2500
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/contraband/ntso_vest
	comname = "Surplus armored vest"
	comtype = /obj/item/clothing/suit/armor/NT_alt
	desc = "A surplus blue armored vest, well worn and definitely not drycleaned."
	price = 3500
	baseprice = 3500
	upperfluc = 500
	lowerfluc = -500

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
	price = 10
	baseprice = 10
	upperfluc = 15
	lowerfluc = -5

/datum/commodity/salvage/machinedebris
	comname = "Twisted Shrapnel"
	comtype = /obj/decal/cleanable/machine_debris
	price = 120
	baseprice = 120
	upperfluc = 120
	lowerfluc = -50

/datum/commodity/salvage/robotdebris
	comname = "Robot Debris"
	comtype = /obj/decal/cleanable/robot_debris
	price = 200
	baseprice = 200
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/salvage/robot_upgrades
	comname = "Cyborg Upgrade"
	desc = "A salvaged cyborg upgrade kit."
	onmarket = 0

/datum/commodity/salvage/robot_upgrades/efficiency
	comname = "Cyborg Upgrade (Efficiency)"
	comtype = /obj/item/roboupgrade/efficiency
	price = 5000
	baseprice = 5000
	upperfluc = 150
	lowerfluc = -150

/datum/commodity/salvage/robot_upgrades/expand
	comname = "Cyborg Upgrade (Expansion)"
	comtype = /obj/item/roboupgrade/expand
	price = 6300
	baseprice = 6300
	upperfluc = 150
	lowerfluc = -150

/datum/commodity/salvage/robot_upgrades/selfrepair
	comname = "Cyborg Upgrade (Self-Repair)"
	comtype = /obj/item/roboupgrade/repair
	price = 10000
	baseprice = 10000
	upperfluc = 250
	lowerfluc = -150

/datum/commodity/salvage/robot_upgrades/stunresist
	comname = "Cyborg Upgrade (Recovery)"
	comtype = /obj/item/roboupgrade/aware
	price = 9500
	baseprice = 9500
	upperfluc = 250
	lowerfluc = -150

/datum/commodity/junk
	comname = "Space Junk"
	desc = "Space junk and trinkets."
	onmarket = 0

/datum/commodity/junk/horsemask
	comname = "Horse Mask"
	comtype = /obj/item/clothing/mask/horse_mask
	price = 100
	baseprice = 100
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/junk/batmask
	comname = "Bat Mask"
	comtype = /obj/item/clothing/mask/batman
	price = 350
	baseprice = 350
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/junk/johnny
	comname = "Strange Suit"
	comtype = /obj/item/clothing/suit/johnny_coat
	price = 1500
	baseprice = 1500
	upperfluc = 300
	lowerfluc = -300

/datum/commodity/junk/buddy
	comname = "Robuddy Costume"
	comtype = /obj/item/clothing/suit/robuddy
	price = 600
	baseprice = 600
	upperfluc = 300
	lowerfluc = -300

/datum/commodity/junk/cowboy_boots
	comname = "Cowboy Boots"
	comtype = /obj/item/clothing/shoes/cowboy
	price = 80
	baseprice = 80
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/junk/cowboy_hat
	comname = "Cowboy Hat"
	comtype = /obj/item/clothing/head/cowboy
	price = 60
	baseprice = 60
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/junk/voltron
	comname = "Voltron"
	comtype = /obj/item/device/voltron
	price = 185000
	baseprice = 185000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/junk/cloner_upgrade
	comname = "Cloning Machine Upgrade Board"
	comtype = /obj/item/cloner_upgrade
	price = 2500
	baseprice = 2500
	upperfluc = 750
	lowerfluc = -500

/datum/commodity/junk/grinder_upgrade
	comname = "Enzymatic Reclaimer Upgrade Board"
	comtype = /obj/item/grinder_upgrade
	price = 2500
	baseprice = 2500
	upperfluc = 750
	lowerfluc = -500

/datum/commodity/junk/speedyclone
	comname = "SpeedyClone2000"
	comtype = /obj/item/cloneModule/speedyclone
	price = 5000
	baseprice = 5000
	upperfluc = 750
	lowerfluc = -500

/datum/commodity/junk/efficientclone
	comname = "Biomatter recycling unit"
	comtype = /obj/item/cloneModule/efficientclone
	price = 5000
	baseprice = 5000
	upperfluc = 750
	lowerfluc = -500

/datum/commodity/junk/circus_board
	comname = "Circus board"
	comtype = /obj/item/peripheral/card_scanner/clownifier
	desc = "A cheap imported ID scanner module. It looks sticky. Like, WAY sticker than a computer module should be."
	price = 150
	baseprice = 150
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/junk/pie_launcher
	comname = "Pie Tool Module"
	comtype = /obj/item/device/guardbot_tool/pie_launcher
	desc = "A tool module compatible with guardbuddies. Are tool modules supposed to have cream on them?"
	price = PAY_DOCTORATE/2
	baseprice = PAY_DOCTORATE/2
	upperfluc = PAY_DOCTORATE/6
	lowerfluc = -PAY_DOCTORATE/6

/datum/commodity/junk/laughbox
	comname = "Box of Laughs"
	comtype = /obj/item/storage/box/box_o_laughs
	desc = "A box full of canned laughs. In case you cant get any of the real stuff."
	price = 15
	baseprice = 15
	upperfluc = 3
	lowerfluc = -3

/////////////////////////////////
///////food trader //////////////
/////////////////////////////////

/datum/commodity/produce/special
	desc = "Valuable produce."
	onmarket = 0

/datum/commodity/produce/special/gmelon
	comname = "George Melon"
	comtype = /obj/item/reagent_containers/food/snacks/plant/melon/george
	price = 170
	baseprice = 170
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/produce/special/greengrape
	comname = "Green Grapes"
	comtype = /obj/item/reagent_containers/food/snacks/plant/grape/green
	price = 85
	baseprice = 85
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/produce/special/chilly
	comname = "Chilly Pepper"
	comtype = /obj/item/reagent_containers/food/snacks/plant/chili/chilly
	price = 100
	baseprice = 100
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/produce/special/ghostchili
	comname = "Ghost Chili Pepper"
	comtype = /obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili
	price = 200
	baseprice = 200
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/produce/special/lashberry
	comname = "Lashberry"
	comtype = /obj/item/reagent_containers/food/snacks/plant/lashberry
	price = 400
	baseprice = 400
	upperfluc = 300
	lowerfluc = -150

/datum/commodity/produce/special/glowfruit
	comname = "Glowfruit"
	comtype = /obj/item/reagent_containers/food/snacks/plant/glowfruit
	price = 350
	baseprice = 350
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/produce/special/purplegoop
	comname = "Purple Goop"
	comtype = /obj/item/reagent_containers/food/snacks/plant/purplegoop
	price = 215
	baseprice = 215
	upperfluc = 150
	lowerfluc = -75

/datum/commodity/produce/special/goldfishcracker
	comname = "Goldfish Cracker"
	comtype = /obj/item/reagent_containers/food/snacks/goldfish_cracker
	price = 500
	baseprice = 500
	upperfluc = 400
	lowerfluc = -200

// sell

/datum/commodity/diner
	desc = "Diner food of questionable quality."
	onmarket = 0

/datum/commodity/diner/mysteryburger
	comname = "Mystery Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/mysteryburger
	price = 7
	baseprice = 7
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/monster
	comname = "THE MONSTER"
	comtype = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	price = 100
	baseprice = 100
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/diner/sloppyjoe
	comname = "Sloppy Joe"
	comtype = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/fishburger
	comname = "Fish-Fil-A"
	comtype = /obj/item/reagent_containers/food/snacks/burger/fishburger
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/luauburger
	comname = "Luau Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/luauburger
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/tikiburger
	comname = "Tiki Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/coconutburger
	comname = "Coconut Burger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/onigiri
	comname = "Onigiri"
	comtype = /obj/item/reagent_containers/food/snacks/rice_ball/onigiri
	price = 6
	baseprice = 6
	upperfluc = 5
	lowerfluc = -3

/datum/commodity/diner/nigiri_roll
	comname = "Nigiri Roll"
	comtype = /obj/item/reagent_containers/food/snacks/nigiri_roll
	price = 20
	baseprice = 20
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/sushi_roll
	comname = "Sushi Roll"
	comtype = /obj/item/reagent_containers/food/snacks/sushi_roll
	price = 60
	baseprice = 60
	upperfluc = 10
	lowerfluc = -10

/datum/commodity/diner/mashedpotatoes
	comname = "Mashed Potatoes"
	comtype = /obj/item/reagent_containers/food/snacks/mashedpotatoes
	price = 6
	baseprice = 6
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/waffles
	comname = "Waffles"
	comtype = /obj/item/reagent_containers/food/snacks/waffles
	price = 12
	baseprice = 12
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/pancake
	comname = "Pancake"
	comtype = /obj/item/reagent_containers/food/snacks/pancake
	price = 10
	baseprice = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/meatloaf
	comname = "Meatloaf"
	comtype = /obj/item/reagent_containers/food/snacks/meatloaf
	price = 15
	baseprice = 15
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/fishfingers
	comname = "Fish Fingers"
	comtype = /obj/item/reagent_containers/food/snacks/fish_fingers
	price = 15
	baseprice = 15
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/slurrypie
	comname = "Slurry Pie"
	comtype = /obj/item/reagent_containers/food/snacks/pie/slurry
	price = 12
	baseprice = 12
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/creampie
	comname = "Cream Pie"
	comtype = /obj/item/reagent_containers/food/snacks/pie/cream
	price = 20
	baseprice = 20
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/diner/daily_special
	comname = "Daily Special"
	comtype = null
	price = 15
	baseprice = 15
	upperfluc = 5
	lowerfluc = -5

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
	price = 500
	baseprice = 500
	upperfluc = 300
	lowerfluc = -100

/datum/commodity/bodyparts/armR
	comname = "Human Arm - Right"
	comtype = /obj/item/parts/human_parts/arm/right
	price = 500
	baseprice = 500
	upperfluc = 300
	lowerfluc = -100

/datum/commodity/bodyparts/legL
	comname = "Human Leg - Left"
	comtype = /obj/item/parts/human_parts/leg/left
	price = 500
	baseprice = 500
	upperfluc = 300
	lowerfluc = -100

/datum/commodity/bodyparts/legR
	comname = "Human Leg - Right"
	comtype = /obj/item/parts/human_parts/leg/right
	price = 500
	baseprice = 500
	upperfluc = 300
	lowerfluc = -100

/datum/commodity/bodyparts/brain
	comname = "Brain"
	comtype = /obj/item/organ/brain
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -200

/datum/commodity/bodyparts/synthbrain
	comname = "Synthetic Brain"
	comtype = /obj/item/organ/brain/synth
	price = 100
	baseprice = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/bodyparts/aibrain
	comname = "AI Neural Net Processor"
	comtype = /obj/item/organ/brain/ai
	price = 30000
	baseprice = 30000
	upperfluc = 25000
	lowerfluc = -10000

/datum/commodity/bodyparts/butt
	comname = "Human Butt"
	comtype = /obj/item/clothing/head/butt
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -200

/datum/commodity/bodyparts/synthbutt
	comname = "Synthetic Butt"
	comtype = /obj/item/clothing/head/butt/synth
	price = 100
	baseprice = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/bodyparts/cyberbutt
	comname = "Robutt"
	comtype = /obj/item/clothing/head/butt/cyberbutt
	price = 4000
	baseprice = 4000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/bodyparts/heart
	comname = "Human Heart"
	comtype = /obj/item/organ/heart
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -200

/datum/commodity/bodyparts/synthheart
	comname = "Synthetic Heart"
	comtype = /obj/item/organ/heart/synth
	price = 100
	baseprice = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/bodyparts/cyberheart
	comname = "Cyberheart"
	comtype = /obj/item/organ/heart/cyber
	price = 4000
	baseprice = 4000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/bodyparts/l_eye
	comname = "Left Human Eye"
	comtype = /obj/item/organ/eye/left
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/bodyparts/r_eye
	comname = "Right Human Eye"
	comtype = /obj/item/organ/eye/right
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/bodyparts/syntheye
	comname = "Synthetic Eye"
	comtype = /obj/item/organ/eye/synth
	price = 50
	baseprice = 50
	upperfluc = 30
	lowerfluc = -10

/datum/commodity/bodyparts/cybereye
	comname = "Cybereye"
	comtype = /obj/item/organ/eye/cyber
	price = 1500
	baseprice = 1500
	upperfluc = 750
	lowerfluc = -750

/datum/commodity/bodyparts/cybereye_sunglass
	comname = "Polarized Cybereye"
	comtype = /obj/item/organ/eye/cyber/sunglass
	price = 2000
	baseprice = 2000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_sechud
	comname = "Security HUD Cybereye"
	comtype = /obj/item/organ/eye/cyber/sechud
	price = 2100
	baseprice = 2100
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_thermal
	comname = "Thermal Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/thermal
	price = 2200
	baseprice = 2200
	upperfluc = 1100
	lowerfluc = -1100

/datum/commodity/bodyparts/cybereye_meson
	comname = "Mesonic Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/meson
	price = 2000
	baseprice = 2000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_spectro
	comname = "Spectroscopic Imager Cybereye"
	comtype = /obj/item/organ/eye/cyber/spectro
	price = 2000
	baseprice = 2000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_prodoc
	comname = "ProDoc Healthview Cybereye"
	comtype = /obj/item/organ/eye/cyber/prodoc
	price = 2100
	baseprice = 2100
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_camera
	comname = "Camera Cybereye"
	comtype = /obj/item/organ/eye/cyber/camera
	price = 2000
	baseprice = 2000
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/cybereye_night
	comname = "Night Vision Cybereye"
	comtype = /obj/item/organ/eye/cyber/nightvision
	price = 8000
	baseprice = 8000
	upperfluc = 4000
	lowerfluc = -4000

/datum/commodity/bodyparts/cybereye_laser
	comname = "Laser Cybereye"
	comtype = /obj/item/organ/eye/cyber/laser
	price = 10000
	baseprice = 10000
	upperfluc = 5000
	lowerfluc = -5000

/datum/commodity/bodyparts/cybereye_ecto
	comname = "Ectosensor Cybereye"
	comtype = /obj/item/organ/eye/cyber/ecto
	price = 26000
	baseprice = 26000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/bodyparts/l_lung
	comname = "Left Human Lung"
	comtype = /obj/item/organ/lung/left
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/bodyparts/r_lung
	comname = "Right Human Lung"
	comtype = /obj/item/organ/lung/right
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/bodyparts/l_cyberlung
	comname = "Left Cyberlung"
	comtype = /obj/item/organ/lung/cyber/left
	price = 1300
	baseprice = 1300
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/bodyparts/r_cyberlung
	comname = "Right Cyberlung"
	comtype = /obj/item/organ/lung/cyber/right
	price = 1300
	baseprice = 1300
	upperfluc = 500
	lowerfluc = -500

//////////////////////////////////////

/datum/commodity/bodyparts/l_kidney
	comname = "Left Human Kidney"
	comtype = /obj/item/organ/kidney/left
	price = 440
	baseprice = 440
	upperfluc = 180
	lowerfluc = -180

/datum/commodity/bodyparts/r_kidney
	comname = "Right Human Kidney"
	comtype = /obj/item/organ/kidney/right
	price = 440
	baseprice = 440
	upperfluc = 180
	lowerfluc = -180

/datum/commodity/bodyparts/l_cyberkidney
	comname = "Left Cyberkidney"
	comtype = /obj/item/organ/kidney/cyber/left
	price = 1200
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/bodyparts/r_cyberkidney
	comname = "Right Cyberkidney"
	comtype = /obj/item/organ/kidney/cyber/right
	price = 1200
	baseprice = 1200
	upperfluc = 500
	lowerfluc = -500

////////////////////////////////////////

/datum/commodity/bodyparts/liver
	comname = "Human Liver"
	comtype = /obj/item/organ/liver
	price = 700
	baseprice = 700
	upperfluc = 300
	lowerfluc = -300

/datum/commodity/bodyparts/cyberliver
	comname = "Cyberliver"
	comtype = /obj/item/organ/liver/cyber
	price = 2500
	baseprice = 2500
	upperfluc = 1500
	lowerfluc = -1500

/datum/commodity/bodyparts/spleen
	comname = "Human Spleen"
	comtype = /obj/item/organ/spleen
	price = 440
	baseprice = 440
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/bodyparts/cyberspleen
	comname = "Cyberspleen"
	comtype = /obj/item/organ/spleen/cyber
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/bodyparts/pancreas
	comname = "Human Pancreas"
	comtype = /obj/item/organ/pancreas
	price = 220
	baseprice = 220
	upperfluc = 20
	lowerfluc = -20

/datum/commodity/bodyparts/cyberpancreas
	comname = "Cyberpancreas"
	comtype = /obj/item/organ/pancreas/cyber
	price = 800
	baseprice = 800
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/bodyparts/appendix
	comname = "Human Appendix"
	comtype = /obj/item/organ/appendix
	price = 20
	baseprice = 20
	upperfluc = 20
	lowerfluc = -19

/datum/commodity/bodyparts/cyberappendix
	comname = "Cyberappendix"
	comtype = /obj/item/organ/appendix/cyber
	price = 4500
	baseprice = 4500
	upperfluc = 1000
	lowerfluc = -1000

/datum/commodity/bodyparts/stomach
	comname = "Human Stomach"
	comtype = /obj/item/organ/stomach
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/bodyparts/cyberstomach
	comname = "Cyberstomach"
	comtype = /obj/item/organ/stomach/cyber
	price = 2200
	baseprice = 2200
	upperfluc = 2000
	lowerfluc = -1000

/datum/commodity/bodyparts/intestines
	comname = "Human Intestines"
	comtype = /obj/item/organ/intestines
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/bodyparts/cyberintestines
	comname = "Cyberintestines"
	comtype = /obj/item/organ/intestines/cyber
	price = 1800
	baseprice = 1800
	upperfluc = 2000
	lowerfluc = -1000

/datum/commodity/medical
	onmarket = 0
	desc = "Medical Supplies."

/datum/commodity/medical/injectorbelt
	comname = "Injector Belt"
	comtype = /obj/item/injector_belt
	desc = "A belt that injects the wearer with chemicals loaded from a container."
	price = 15500
	baseprice = 15500
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/medical/injectormask
	comname = "Vapo-Matic"
	comtype = /obj/item/clothing/mask/gas/injector_mask
	desc = "A gas mask that doses the wearer with chemicals loaded from a container."
	price = 19000
	baseprice = 19000
	upperfluc = 4500
	lowerfluc = -2500

/datum/commodity/medical/strange_reagent
	comname = "Strange Reagent"
	comtype = /obj/item/reagent_containers/glass/beaker/strange_reagent
	price = 25000
	baseprice = 25000
	upperfluc = 10000
	lowerfluc = -10000

/datum/commodity/medical/firstaidR
	comname = "First Aid Kit - Regular"
	comtype = /obj/item/storage/firstaid/regular
	price = 500
	baseprice = 500
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidBr
	comname = "First Aid Kit - Brute"
	comtype = /obj/item/storage/firstaid/brute
	price = 600
	baseprice = 600
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidB
	comname = "First Aid Kit - Fire"
	comtype = /obj/item/storage/firstaid/fire
	price = 600
	baseprice = 600
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidT
	comname = "First Aid Kit - Toxin"
	comtype = /obj/item/storage/firstaid/toxin
	price = 600
	baseprice = 600
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidO
	comname = "First Aid Kit - Suffocation"
	comtype = /obj/item/storage/firstaid/oxygen
	price = 800
	baseprice = 800
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidN
	comname = "First Aid Kit - Neurological"
	comtype = /obj/item/storage/firstaid/brain
	price = 1200
	baseprice = 1200
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/medical/firstaidC
	comname = "First Aid Kit - Critical"
	comtype = /obj/item/storage/firstaid/crit
	price = 10000
	baseprice = 10000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/medical/injectorPent
	comname = "Auto-Injector - Pentetic Acid"
	comtype = /obj/item/reagent_containers/emergency_injector/pentetic_acid
	price = 2000
	baseprice = 2000
	upperfluc = 500
	lowerfluc = -700

/datum/commodity/medical/injectorPerf
	comname = "Auto-Injector - Perfluorodecalin"
	comtype = /obj/item/reagent_containers/emergency_injector/perf
	price = 800
	baseprice = 800
	upperfluc = 500
	lowerfluc = -700

/datum/commodity/medical/ether
	comname = "Ether"
	comtype = /obj/item/reagent_containers/glass/bottle/ether
	desc = "A strong but highly addictive anesthetic and sedative."
	price = 2000
	baseprice = 2000
	upperfluc = 1500
	lowerfluc = -500

/datum/commodity/medical/toxin
	comname = "Toxin"
	comtype = /obj/item/reagent_containers/glass/bottle/toxin
	desc = "Various toxin compounds."
	price = 8000
	baseprice = 8000
	upperfluc = 3000
	lowerfluc = -1000

/datum/commodity/medical/cyanide
	comname = "Cyanide"
	comtype = /obj/item/reagent_containers/glass/bottle/cyanide
	desc = "A rapidly acting and highly dangerous chemical."
	price = 9000
	baseprice = 9000
	upperfluc = 4000
	lowerfluc = -1000

/datum/commodity/medical/omnizine
	comname = "Omnizine"
	comtype = /obj/item/reagent_containers/glass/bottle/omnizine
	desc = "An experimental and expensive herbal compound."
	price = 12000
	baseprice = 12000
	upperfluc = 6000
	lowerfluc = -2000

///// costume kits

/datum/commodity/costume
	onmarket = 0

/datum/commodity/costume/bee
	comname = "Bee Costume"
	comtype = /obj/item/storage/box/costume/bee
	desc = "A licensed costume that makes you look like a bumbly bee!"
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/monkey
	comname = "Monkey Costume"
	comtype = /obj/item/storage/box/costume/monkey
	desc = "A licensed costume that makes you look like a monkey!"
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/robuddy
	comname = "Guardbuddy Costume"
	comtype = /obj/item/storage/box/costume/robuddy
	desc = "A licensed costume that makes you look like a PR-6 Guardbuddy!"
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/waltwhite
	comname = "Meth Scientist Costume"
	comtype = /obj/item/storage/box/costume/crap/waltwhite
	price = 100
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/spiderman
	comname = "Red Alien Costume"
	comtype = /obj/item/storage/box/costume/crap/spiderman
	price = 100
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/wonka
	comname = "Victorian Confectionery Factory Owner Costume"
	comtype = /obj/item/storage/box/costume/crap/wonka
	price = 100
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/light_borg //YJHGHTFH's light borg costume
	comname = "Light Cyborg Costume"
	comtype = /obj/item/storage/box/costume/light_borg
	desc = "Beep-bop synthesizer sold separately."
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/utena //YJHGHTFH's utena costume & AffableGiraffe's anthy dress
	comname = "Revolutionary Costume Set"
	comtype = /obj/item/storage/box/costume/utena
	desc = "A set of fancy clothes that may or may not give you the power to revolutionize things. Magic sword not included."
	price = 200
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/werewolf
	comname = "Werewolf Costume"
	comtype = /obj/item/storage/box/costume/werewolf
	desc = "A surprisingly decent quality werewolf costume, probably from some discount Halloween superstore."
	price = 600
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/abomination
	comname = "Abomination Costume"
	comtype = /obj/item/storage/box/costume/abomination
	desc = "Who's seen a shambling abomination in such close detail to recreate such a monstrosity?"
	price = 600
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/roller_disco
	comname = "Roller Disco Costume"
	comtype = /obj/item/storage/box/costume/roller_disco
	desc = "You'll really impress your pals at the next Saturday night roller disco."
	price = 200
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/hotdog
	comname = "Hotdog Costume"
	comtype = /obj/item/storage/box/costume/hotdog
	desc = "Hot-diggity-dog!"
	price = 300
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/scifi
	comname = "Sci-Fi Garb Set"
	comtype = /obj/item/storage/box/costume/scifi
	desc = "From a faraway time and place."
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/purpwitch
	comname = "Purple Witch Costume Set"
	comtype = /obj/item/storage/box/costume/purpwitch
	desc = "It won't give you any real magic, but you always have the magic of Imagination."
	price = 300
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/mintwitch
	comname = "Mint Witch Costume Set"
	comtype = /obj/item/storage/box/costume/mintwitch
	desc = "It won't give you any real magic, but you always have the magic of Imagination."
	price = 300
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/mime
	comname = "Mime Clothes"
	comtype = /obj/item/storage/box/costume/mime
	desc = "No words can describe this. Only intricate gesticulation."
	price = 100 //exactly what the clown spawns with in their account, three mimes on mondays.
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/costume/mime/alt
	comname = "Alternate Mime Clothes."
	comtype = /obj/item/storage/box/costume/mime/alt
	desc = "This stuff will give you an edge in charades."

/datum/commodity/backpack/breadpack
	comname = "Bag-uette"
	comtype = /obj/item/storage/backpack/breadpack
	desc = "A bread-themed backpack...? It kind of smells like bread too! Unfortunately inedible."
	price = 600
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/backpack/bearpack
	comname = "Bearpack"
	comtype = /obj/item/storage/backpack/bearpack
	desc = "A teddy bear backpack; perfect for hugs AND carries your gear for you, how helpful!"
	price = 500
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/backpack/turtlebrown
	comname = "Brown Turtle Shell Backpack"
	comtype = /obj/item/storage/backpack/turtlebrown
	desc = "All the hip teenage mutants have one of these turtle shell backpacks."
	price = 650
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/backpack/turtlegreen
	comname = "Green Turtle Shell Backpack"
	comtype = /obj/item/storage/backpack/turtlegreen
	desc = "All the hip teenage mutants have one of these turtle shell backpacks."
	price = 650
	baseprice = 100
	upperfluc = 150
	lowerfluc = -100

/datum/commodity/balloons //no it ain't a costume kit but it's going in Geoff's wares so idgaf tOt fite me
	comname = "box of balloons"
	comtype = /obj/item/storage/box/balloonbox
	desc = "A box full of colorful balloons!  Neat!"
	onmarket = 0
	price = 50
	baseprice = 50
	upperfluc = 100
	lowerfluc = -50

/datum/commodity/crayons
	comname = "box of crayons"
	comtype = /obj/item/storage/box/crayon
	desc = "A box of colorful crayons! Lovely!"
	onmarket = 0
	price = 50
	baseprice = 50
	upperfluc = 100
	lowerfluc = -20

/datum/commodity/sticker/
	onmarket = 0

/datum/commodity/sticker/googly_eyes
	comname = "box of googly eyes"
	comtype = /obj/item/item_box/googly_eyes
	desc = "A box of googly eyes! Sweet!"
	onmarket = 0
	price = 50
	baseprice = 50
	upperfluc = 100
	lowerfluc = -20

/datum/commodity/sticker/googly_eyes_angry
	comname = "box of angry googly eyes"
	comtype = /obj/item/item_box/googly_eyes/angry
	desc = "A box of angry googly eyes! Aaaaargh!"
	onmarket = 0
	price = 50
	baseprice = 50
	upperfluc = 100
	lowerfluc = -20

/datum/commodity/toygun
	comname = "Toy Gun"
	comtype = /obj/item/gun/kinetic/foamdartgun
	desc = "A toy gun that fires foam darts."
	onmarket = 0
	price = 500
	baseprice = 500
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/toygunammo
	comname = "Foam Darts"
	comtype = /obj/item/ammo/bullets/foamdarts
	desc = "Six foam darts for toy guns."
	onmarket = 0
	price = 200
	baseprice = 200
	upperfluc = 20
	lowerfluc = -20

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

/// pathology
/datum/commodity/synthmodule
	comname = "Synth-O-Matic module"
	comtype = /obj/item/synthmodule
	desc = "A synth-o-matic module."
	onmarket = 0
	price = 5000
	baseprice = 5000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/synthmodule/vaccine
	comname = "Synth-O-Matic vaccine module"
	comtype = /obj/item/synthmodule/vaccine

/datum/commodity/synthmodule/upgrader
	comname = "Synth-O-Matic efficiency module"
	comtype = /obj/item/synthmodule/upgrader

/datum/commodity/synthmodule/assistant
	comname = "Synth-O-Matic assistant module"
	comtype = /obj/item/synthmodule/assistant

/datum/commodity/synthmodule/synthesizer
	comname = "Synth-O-Matic synthesizer module"
	comtype = /obj/item/synthmodule/synthesizer

/datum/commodity/synthmodule/virii
	comname = "Synth-O-Matic virus module"
	comtype = /obj/item/synthmodule/virii

/datum/commodity/synthmodule/bacteria
	comname = "Synth-O-Matic bacterium module"
	comtype = /obj/item/synthmodule/bacteria

/datum/commodity/synthmodule/fungi
	comname = "Synth-O-Matic fungus module"
	comtype = /obj/item/synthmodule/fungi

/datum/commodity/synthmodule/parasite
	comname = "Synth-O-Matic parasite module"
	comtype = /obj/item/synthmodule/parasite

/datum/commodity/synthmodule/gmcell
	comname = "Synth-O-Matic great mutatis cell module"
	comtype = /obj/item/synthmodule/gmcell

/datum/commodity/synthmodule/radiation
	comname = "Synth-O-Matic irradiation module"
	comtype = /obj/item/synthmodule/radiation

/datum/commodity/pathogensample
	comname = "Pathogen sample"
	comtype = /obj/item/reagent_containers/glass/vial/prepared
	desc = "A sample of pathogen. Probably stolen from a lab somewhere. Handle with care."
	onmarket = 0
	price = 700
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/largeartifact
	comname = "Large Artifact"
	comtype = null
	onmarket = 0
	price = 2000
	baseprice = 2000
	upperfluc = 1500
	lowerfluc = -1500

/datum/commodity/smallartifact
	comname = "Handheld Artifact"
	comtype = null
	onmarket = 0
	price = 400
	baseprice = 400
	upperfluc = 400
	lowerfluc = -200

// FLOCKTRADER COMMODITIES AND PRICES
/datum/commodity/flock/
	desc = "Goods that the Flocktrader sells or wants."
	onmarket = 0

// WANTS TO BUY
/datum/commodity/flock/desired
	desc = "This material can be used by us to repair our ship and fabricate new drones."

/datum/commodity/flock/desired/videocard
	comname = "Advanced Videocard"
	comtype = /obj/item/peripheral/videocard
	desc_buy = "We're aware your computers can't handle this peripheral. We can find a use for it."
	price = 400
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/flock/desired/feather
	comname = "Feather"
	comtype = /obj/item/feather
	desc_buy = "Low material value, but it reminds us of the Source. We find these comforting."
	price = 20
	upperfluc = 10
	lowerfluc = -10

/datum/commodity/flock/desired/electronics
	comname = "Electronic Components"
	comtype = /obj/item/electronics
	desc_buy = "The aggressive drones of this space have useful innards."
	price = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/flock/desired/brain
	comname = "Brain"
	comtype = /obj/item/organ/brain
	desc_buy = "We are experimenting with new cognitive microstructures. Specimens for research are appreciated."
	price = 1000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/flock/desired/beeegg
	comname = "Bee Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	desc_buy = "These creatures have a fascinating genetic structure. Specimens for research are appreciated."
	price = 50
	upperfluc = 25
	lowerfluc = -25

/datum/commodity/flock/desired/critteregg
	comname = "Creature Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter
	desc_buy = "We are interested in novel biological structures within this region of space. Specimens for research are appreciated."
	price = 100
	upperfluc = 50
	lowerfluc = -50

/datum/commodity/flock/desired/egg
	comname = "Regular Egg"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg
	desc_buy = "Eggs are delicious and a good source of nutrients for growing flockdrones."
	price = 10
	upperfluc = 5
	lowerfluc = -5

/datum/commodity/flock/desired/material
	comname = "Material Piece"
	comtype = /obj/item/material_piece
	desc_buy = "We are not selective. Any processed material is acceptable."
	price = 50
	upperfluc = 40
	lowerfluc = -40

/datum/commodity/flock/desired/rawmaterial
	comname = "Raw Material Piece"
	comtype = /obj/item/raw_material
	desc_buy = "We are not selective. Any raw material is acceptable."
	price = 40
	upperfluc = 30
	lowerfluc = -30

// WILL SELL
/datum/commodity/flock/tech
	desc = "Our technology is unique and unattainable elsewhere."

/datum/commodity/flock/tech/table
	comname = "Flocktable"
	comtype = /obj/item/furniture_parts/table/flock
	desc = "A processing subsystem of obsolete design with a perfectly flat surface. Good for placing things."
	price = 200
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/flock/tech/chair
	comname = "Flockchair"
	comtype = /obj/item/furniture_parts/flock_chair
	desc = "Prior to our mass-energy conversion technology, we used these chambers to charge our drones. Now padded with feather-down cushions for comfort."
	price = 350
	upperfluc = 175
	lowerfluc =  -175

/datum/commodity/flock/tech/gnesis
	comname = "Gnesis"
	comtype = /obj/item/material_piece/gnesis
	desc = "Our mind and matter, filled with stoic and resolute intent."
	price = 2000
	upperfluc = 1500
	lowerfluc = -1500

/datum/commodity/flock/tech/gnesisglass
	comname = "Translucent Gnesis"
	comtype = /obj/item/material_piece/gnesisglass
	desc = "Our mind and matter, filled with open and honest intent."
	price = 3000
	upperfluc = 2500
	lowerfluc = -2500

/datum/commodity/flock/tech/flocknugget
	comname = "Flocknugget"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock
	desc = "Apparently this is a delicacy. We did not know your kind can stomach metallic crystal."
	price = 30
	upperfluc = 15
	lowerfluc = -15

/datum/commodity/flock/tech/flockbrain
	comname = "Processing Core"
	comtype = /obj/item/organ/brain/flockdrone
	desc = "We are loathe to part with our processing cores, but we can be convinced with enough credits."
	price = 5000
	upperfluc = 4500
	lowerfluc = -4500

/datum/commodity/flock/tech/fluid
	comname = "Fluid Cache"
	comtype = /obj/item/reagent_containers/gnesis
	desc = "A sealed container with a fluid form of our matter, filled with indecision. We wish you the very best in figuring out how to extract the fluid."
	price = 4000
	upperfluc = 2000
	lowerfluc = -2000

/datum/commodity/flock/tech/flockburger
	comname = "Flockburger"
	comtype = /obj/item/reagent_containers/food/snacks/burger/flockburger
	desc = "We have found a new use for completely irrecoverable processing cores. We cannot currently offer fries with that. We've changed the recipe after some complaints from our customers."
	price = 60
	upperfluc = 30
	lowerfluc = -30

/datum/commodity/flock/tech/flockblocker
	comname = "Flockblocker Telejammer"
	comtype = /obj/item/device/flockblocker
	desc = "A handheld teleportation jammer powered by the universe's contempt for those who attempt to bend space to their whim."
	price = 300000
	upperfluc = 15000
	lowerfluc = -15000

/datum/commodity/flock/tech/incapacitor
	comname = "Incapacitor"
	comtype = /obj/item/gun/energy/flock
	desc = "We have tried to replicate our pacification technology in a form your kind can use. There may be some issues."
	price = 30000
	upperfluc = 12500
	lowerfluc = -12500

/////////////////////////////////
///////skeleton trader //////////
/////////////////////////////////

/datum/commodity/hat
	onmarket = 0

/datum/commodity/hat/bandana
	comname = "Bandana"
	comtype = /obj/item/clothing/head/bandana/random_color
	desc = "A randomly colored bandana."
	price = 300
	baseprice = 300
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/hat/beret
	comname = "Beret"
	comtype = /obj/item/clothing/head/beret/random_color
	desc = "A randomly colored beret."
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/hat/spacehelmet
	comname = "Space Helmet"
	comtype = /obj/item/clothing/head/helmet/space/oldish
	desc = "An old space helmet."
	price = 700
	baseprice = 600
	upperfluc = 100
	lowerfluc = -100

	red
		comname = "Red Space Helmet"
		comtype = /obj/item/clothing/head/helmet/space/syndicate/old
		desc = "An old space helmet. It's red."

/datum/commodity/hat/pinkwizard
	comname = "Pink Wizard Hat"
	comtype = /obj/item/clothing/head/pinkwizard
	desc = "A pink wizard hat. Magic not included."
	price = 800
	baseprice = 700
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/hat/purplebutt
	comname = "Purple Butt Hat"
	comtype = /obj/item/clothing/head/purplebutt
	desc = "Exotic."
	price = 800
	baseprice = 700
	upperfluc = 100
	lowerfluc = -200

/datum/commodity/hat/dailyspecial
	comname = "Daily Special"
	comtype = null
	desc = "Purchase assured, it's a bargain."
	price = 900
	baseprice = 800
	upperfluc = 200
	lowerfluc = -100

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
	price = 1000
	baseprice = 1000
	upperfluc = 500
	lowerfluc = -100

/datum/commodity/tech/laptop
	comname = "Personal Laptop"
	comtype = /obj/item/luggable_computer/personal
	desc = "Top of the line!"
	price = 5000
	baseprice = 5000
	upperfluc = 1000
	lowerfluc = -2000


////////////////////////////////////////////////

/datum/commodity/clothing
	onmarket = 0

/datum/commodity/clothing/psyche
	comname = "Psychedelic jumpsuit"
	comtype = /obj/item/clothing/under/gimmick/psyche
	desc = "Some garish garb, stolen off a hippie's back."
	price = 3000
	baseprice = 3000
	upperfluc = 500
	lowerfluc = -1000

/datum/commodity/clothing/chameleon
	comname = "Black jumpsuit"
	comtype = /obj/item/clothing/under/chameleon
	desc = "A plain black jumpsuit. Not very myserious at all, no."
	price = 6000
	baseprice = 6000
	upperfluc = 2500
	lowerfluc = -1000

/datum/commodity/banana_grenade
	comname = "Banana grenade"
	comtype = /obj/item/old_grenade/spawner/banana
	desc = "Perfect for magic tricks and slips, and some clown's birthday present."
	price = 2000
	baseprice = 2000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/cheese_grenade
	comname = "Cheese Sandwich grenade"
	comtype = /obj/item/old_grenade/spawner/cheese_sandwich
	desc = "Contains only one type of cheese, unfortunately."
	onmarket = 0
	price = 2500
	baseprice = 2500
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/corndog_grenade
	comname = "Banana Corndog grenade"
	comtype = /obj/item/old_grenade/spawner/banana_corndog
	desc = "A very space efficient party pleaser. No ketchup or mustard included."
	onmarket = 0
	price = 3000
	baseprice = 3000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/gokart
	comname = "Go-Kart"
	comtype = /obj/racing_clowncar/kart
	desc = "They just don't make the same quality go-karts anymore. Get this relic while you can."
	onmarket = 0
	price = 30000
	baseprice = 30000
	upperfluc = 10000
	lowerfluc = -1000

/datum/commodity/car
	comname = "Fancy Car"
	comtype = /obj/machinery/vehicle/tank/car/rusty
	desc = "Might need some TLC, but a discount ride is a discount ride."
	onmarket = 0
	price = 55000
	upperfluc = 10000
	lowerfluc = -5000

/datum/commodity/menthol_cigarettes
	comname = "Menthol Cigarettes"
	comtype = /obj/item/clothing/mask/cigarette/menthol
	desc = "Gotta get some minty smokes."
	onmarket = 0
	price = 500
	baseprice = 500
	upperfluc = 200
	lowerfluc = -200

/datum/commodity/propuffs
	comname = "Pro Puffs"
	comtype = /obj/item/clothing/mask/cigarette/propuffs
	desc = "These flavors are are gold."
	onmarket = 0
	price = 600
	baseprice = 600
	upperfluc = 200
	lowerfluc = -200

///////////////////greg///////////////////////////////
/datum/commodity/airzooka
	comname = "Donk Co. brand Airzooka"
	comtype = /obj/item/gun/kinetic/airzooka
	desc = "A high tech air deploying and transportation device produced by Donk Co!"
	onmarket = 0
	price = 5000
	baseprice = 5000
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/airbag
	comname = "Airzooka Replacement Bag"
	comtype = /obj/item/ammo/bullets/airzooka
	desc = "A replacement bag for your Donk Co brand Airzooka!"
	onmarket = 0
	price = 500
	baseprice = 500
	upperfluc = 100
	lowerfluc = -100

/datum/commodity/dangerbag
	comname = "Airzooka Replacement Bag: Xtreme Edition"
	comtype = /obj/item/ammo/bullets/airzooka/bad
	desc = "A replacement bag for your Donk Co brand Airzooka, now with plasma lining!"
	onmarket = 0
	price = 3000
	baseprice = 500
	upperfluc = 500
	lowerfluc = -500

/datum/commodity/owleggs
	comname = "Owl Eggs"
	desc = "We are currently accepting donations of Owl Eggs for the exhibits! isn't that hootastic?"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl
	onmarket = 0
	price = 150
	baseprice = 50
	upperfluc = 25
	lowerfluc = -25

/datum/commodity/hat/dailyspecial/greg
	comname = "Daily Special"
	comtype = null
	desc = "We are now authorized to begin importing fashion accessories for our customers!"
	onmarket = 0
	price = 1000
	baseprice = 800
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/crayons/greg
	comname = "box of crayons"
	comtype = /obj/item/storage/box/crayon
	desc = "Donkola brand color sticks! FDA approved to not cause sudden cell death since 2032!"
	onmarket = 0
	price = 250
	baseprice = 50
	upperfluc = 100
	lowerfluc = -20

/datum/commodity/drugs/poppies/greg
	comname = "Poppies"
	desc = "In respect of those lost during the colonization of the frontier, we are now offering poppies."
	comtype = /obj/item/plant/herb/poppy
	onmarket = 0
	price = 350
	baseprice = 350
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/owlpaint
	comtype = /obj/item/pod/paintjob/owl
	comname = "Limited Edition Owlery Brand Pod Painting Kit"
	desc = "Now you can represent your love for the Owls by painting your Space Pod in our signature colors!"
	onmarket = 0
	price = 10050
	baseprice = 550
	upperfluc = 200
	lowerfluc = -100

/datum/commodity/HEtorpedo
	comname = "High Explosive Torpedo"
	comtype = /obj/torpedo_tray/hiexp_loaded
	desc = "A highly explosive torpedo, ready for your sick, destructive needs."
	onmarket = 0
	price = 10000
	baseprice = 10000
	upperfluc = 5000
	lowerfluc = -5000

/datum/commodity/sketchy_press_upgrade
	comname = "Sketchy press upgrade"
	desc = "This looks like a bootlegged printing press upgrade."
	comtype = /obj/item/press_upgrade/forbidden
	onmarket = 0
	price = 2000
	baseprice = 2000
	upperfluc = 1700
	lowerfluc = -1700

/datum/commodity/expensive_card
	comname = "Incredibly Expensive Card"
	desc = "Wow...people really pay a lot for these cards..."
	comtype = /obj/item/playing_card/expensive
	onmarket = 1
	price = 21000
	upperfluc = 20000
	lowerfluc = -28500

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//         ______   _        _______  _______  _                _______  _______  _______  _        _______ _________         //
//        (  ___ \ ( \      (  ___  )(  ____ \| \    /\        (       )(  ___  )(  ____ )| \    /\(  ____ \\__   __/         //
//        | (   ) )| (      | (   ) || (    \/|  \  / /        | () () || (   ) || (    )||  \  / /| (    \/   ) (            //
//        | (__/ / | |      | (___) || |      |  (_/ /         | || || || (___) || (____)||  (_/ / | (__       | |            //
//        |  __ (  | |      |  ___  || |      |   _ (          | |(_)| ||  ___  ||     __)|   _ (  |  __)      | |            //
//        | (  \ \ | |      | (   ) || |      |  ( \ \         | |   | || (   ) || (\ (   |  ( \ \ | (         | |            //
//        | )___) )| (____/\| )   ( || (____/\|  /  \ \        | )   ( || )   ( || ) \ \__|  /  \ \| (____/\   | |            //
//        |/ \___/ (_______/|/     \|(_______/|_/    \/        |/     \||/     \||/   \__/|_/    \/(_______/   )_(            //
//                                                                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//time2text(time,format="MM/DD/YYYY HH:MM:SS",fine)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                //
//    ▄▄▄▄███▄▄▄▄      ▄████████ ▀████    ▐████▀       ▄█          ▄████████  ▄█     █▄     ▄▄▄▄███▄▄▄▄      ▄████████ ███▄▄▄▄    //
//  ▄██▀▀▀███▀▀▀██▄   ███    ███   ███▌   ████▀       ███         ███    ███ ███     ███  ▄██▀▀▀███▀▀▀██▄   ███    ███ ███▀▀▀██▄  //
//  ███   ███   ███   ███    ███    ███  ▐███         ███         ███    ███ ███     ███  ███   ███   ███   ███    ███ ███   ███  //
//  ███   ███   ███   ███    ███    ▀███▄███▀         ███         ███    ███ ███     ███  ███   ███   ███   ███    ███ ███   ███  //
//  ███   ███   ███ ▀███████████    ████▀██▄          ███       ▀███████████ ███     ███  ███   ███   ███ ▀███████████ ███   ███  //
//  ███   ███   ███   ███    ███   ▐███  ▀███         ███         ███    ███ ███     ███  ███   ███   ███   ███    ███ ███   ███  //
//  ███   ███   ███   ███    ███  ▄███     ███▄       ███▌    ▄   ███    ███ ███ ▄█▄ ███  ███   ███   ███   ███    ███ ███   ███  //
//   ▀█   ███   █▀    ███    █▀  ████       ███▄      █████▄▄██   ███    █▀   ▀███▀███▀    ▀█   ███   █▀    ███    █▀   ▀█   █▀   //
//                                                   ▀                                                                            //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
///███████ ███████ ██      ██      ██ ███    ██  ██████     //
///██      ██      ██      ██      ██ ████   ██ ██       ██ //
///███████ █████   ██      ██      ██ ██ ██  ██ ██   ███    //
///     ██ ██      ██      ██      ██ ██  ██ ██ ██    ██ ██ //
///███████ ███████ ███████ ███████ ██ ██   ████  ██████     //
//////////////////////////////////////////////////////////////

/datum/commodity/blackmarket/surplus/baton
	comname = "Imported Stun Baton"
	comtype = /obj/item/baton
	//custom power cell with 0 power - baton is only usable for harmbatoning. get a cell from security or make one with matsci if you want to use it normally
	cell_type = /obj/item/ammo/power_cell/dummy
	desc_sell = "Excess stun batons. Quality may vary, batteries not included."
	price = 30000
	upperfluc = 10000
	lowerfluc = -10000

// NOTE: A full set of armour ordered at the same time shouldn't match, but they should look cool together.
/datum/commodity/blackmarket/surplus/helmet
	comname = "Armor Helmet"
	comtype = null
	desc_sell = "Got a lot of these in good condition. One size fits all."
	price = 7000
	upperfluc = 1000
	lowerfluc = -1000
	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/head/helmet/camera/security
			if ("tuesday")
				comtype = /obj/item/clothing/head/helmet/hardhat/security/improved
			if ("wednesday")
				comtype = /obj/item/clothing/head/helmet/riot
			if ("thursday")
				comtype = /obj/item/clothing/head/helmet/space/ntso
			if ("friday")
				comtype = /obj/item/clothing/head/helmet/hardhat/security/improved
			if ("saturday")
				comtype = /obj/item/clothing/head/helmet/turd
			if ("sunday")
				comtype = /obj/item/clothing/head/helmet/hardhat/security

/datum/commodity/blackmarket/surplus/suit
	//overpriced to avoid dumb money exploits
	comname = "Security-Grade Jumpsuit"
	comtype = null
	desc_sell = "Yeah, I can get you some genuine security jumpsuits. Original holo-monograms included, of course."
	price = 4000
	upperfluc = 2000
	lowerfluc = -2000
	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/under/rank/security
			if ("tuesday")
				comtype = /obj/item/clothing/under/chameleon
				price = 14000
				upperfluc = 4000
				lowerfluc = -4000
			if ("wednesday")
				comtype = /obj/item/clothing/under/rank/security
			if ("thursday")
				comtype = /obj/item/clothing/under/misc/NT
			if ("friday")
				comtype = /obj/item/clothing/under/rank/security
			if ("saturday")
				comtype = /obj/item/clothing/under/rank/security
			if ("sunday")
				comtype = /obj/item/clothing/under/shirt_pants_b/redtie

/datum/commodity/blackmarket/surplus/vest
	comname = "Armor Vest"
	comtype = /obj/item/clothing/suit/armor/vest
	desc_sell = "Life savers. Want my advice? Buy a couple extra."
	price = 8000
	upperfluc = 2000
	lowerfluc = -2000
		New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/suit/armor/vest
			if ("tuesday")
				comtype = /obj/item/clothing/suit/armor/turd
			if ("wednesday")
				comtype = /obj/item/clothing/suit/fire/armored
			if ("thursday")
				comtype = /obj/item/clothing/suit/armor/EOD
			if ("friday")
				comtype = /obj/item/clothing/suit/armor/vest
			if ("saturday")
				comtype = /obj/item/clothing/suit/armor/tdome/red
			if ("sunday")
				comtype = /obj/item/clothing/suit/armor/NT_alt
				/datum/commodity/blackmarket/surplus/baton
				
/datum/commodity/blackmarket/surplus/gloves
	comname = "Tactical Gloves"
	comtype = /obj/item/clothing/gloves/swat
	price = 8400
	upperfluc = 1400
	lowerfluc = -1400
				
/datum/commodity/blackmarket/surplus/boots
	comname = "Tactical Boots"
	comtype = /obj/item/clothing/suit/armor/vest
	desc_sell = "I re-sole all the boots. Guaranteed 100% blood free."
	price = 8000
	upperfluc = 2000
	lowerfluc = -2000
		New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/shoes/bootsblk
			if ("tuesday")
				comtype = /obj/item/clothing/shoes/detective
			if ("wednesday")
				comtype = /obj/item/clothing/shoes/swat
			if ("thursday")
				comtype = /obj/item/clothing/shoes/bootsblk
			if ("friday")
				comtype = /obj/item/clothing/shoes/swat/noslip
			if ("saturday")
				comtype = /obj/item/clothing/shoes/swat
			if ("sunday")
				comtype = /obj/item/clothing/shoes/swat
				
	
/datum/commodity/blackmarket/surplus/gasmask
	comname = "Tactical Gas Mask"
	comtype = null
	name = "Tactical Gas Mask"
	desc_sell = "Tested and guaranteed 100% smokebomb-proof, every one of em."
	price = 2100
	upperfluc = 500
	lowerfluc = -500
	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/mask/gas/swat
			if ("tuesday")
				comtype = /obj/item/clothing/mask/gas
			if ("wednesday")
				comtype = /obj/item/clothing/mask/gas/swat
			if ("thursday")
				comtype = /obj/item/clothing/head/helmet/space/ntso
			if ("friday")
				comtype = /obj/item/clothing/mask/gas
			if ("saturday")
				comtype = /obj/item/clothing/mask/gas/swat
			if ("sunday")
				comtype = /obj/item/clothing/mask/gas/NTSO
	
/datum/commodity/blackmarket/surplus/backpack
	comname = "Security Satchel"
	comtype = /obj/item/storage/backpack/satchel/syndie
	name = "Deluxe Security Satchel"
	desc = "A stylish red, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a security officer's shoulder. It is monogrammed N.K. and has a certificate of authenticity stitched into the lining."
	desc_sell = "Got a few designer bags in. They're fully functional, and damn tough."
	price = 3800
	upperfluc = 190
	lowerfluc = -200

/datum/commodity/blackmarket/surplus/sechud
	comname = "Sechud Glasses"
	comtype = /obj/item/clothing/glasses/sunglasses/sechud
	color_r = 0.95
	desc_sell = "SecureTech Computerised Heads Up Display Sunglasses. Reveal wanted criminals with just a glance. They connect to your station's security network automatically. A must have in any modern space station."
	price = 12000
	upperfluc = 3000
	lowerfluc = -3000
	
/datum/commodity/blackmarket/surplus/breachinghammer
	//some people want this to be cheaper, those people are fools. this is an amazing item and if anything it's too cheap here
	comname = "Airlock Breaching Hammer"
	comtype = /obj/item/breaching_hammer
	desc_sell = "Got some premium breaching hammers in stock. Solid frame, hand-crafted, guaranteed to knock an airlock down in a matter of minutes if not seconds. This is prime stuff, spacer."
	price = 340000
	upperfluc = 50000
	lowerfluc = -50000
	
/datum/commodity/blackmarket/surplus/handcuffs
	//some people want this to be cheaper, those people are fools. this is an amazing item and if anything it's too cheap here
	comname = "Handcuffs"
	comtype = /obj/item/handcuffs
	price = 1800
	upperfluc = 300
	lowerfluc = -300
	/obj/item/handcuffs
	
/datum/commodity/blackmarket/surplus/riot_grenade
	//if you want good grenades you'll have to get those at qm
	comname = "Capsaicin Grenade"
	comtype = 
	price = 12000
	upperfluc = 3000
	lowerfluc = -3000
	
/////////////////////////////////////////////////////////
///██████  ██    ██ ██    ██ ██ ███    ██  ██████     ///
///██   ██ ██    ██  ██  ██  ██ ████   ██ ██       ██ ///
///██████  ██    ██   ████   ██ ██ ██  ██ ██   ███    ///
///██   ██ ██    ██    ██    ██ ██  ██ ██ ██    ██ ██ ///
///██████   ██████     ██    ██ ██   ████  ██████     ///
/////////////////////////////////////////////////////////

/datum/commodity/blackmarket/surplus/ak47
	comname = "AK-744 Rifle"
	comtype = /obj/item/gun/kinetic/ak47
	desc =  = "I need any functional models you have."
	price = 2000000
	upperfluc = 100000
	lowerfluc = -100000
/datum/commodity/blackmarket/surplus/revolver
	comname = "Predator Revolver"
	comtype = /obj/item/gun/kinetic/revolver
	desc =  = "We have an open bounty on these. Only the real deal counts."
	price = 260000
	upperfluc = 40000
	lowerfluc = -40000
/datum/commodity/blackmarket/surplus/lasergun
	comname = "Laser Gun"
	comtype = /obj/item/gun/energy/laser_gun
	desc =  = "Need some of those older NT laser guns. The obsolete ones with the round bodies. The parts are invaluable."
	price = 12000
	upperfluc = 3000
	lowerfluc = -3000
/datum/commodity/blackmarket/surplus/phaser
	comname = "Phaser"
	comtype = /obj/item/gun/energy/phaser_gun
	desc = "Moon prison in a neighbouring sector needs as many of these as I can get."
	price = 9000
	upperfluc = 2000
	lowerfluc = -1800
/datum/commodity/blackmarket/surplus/lawbringercell
	//I think it's funnier to encourage people to steal & sell the battery rather than the gun itself
	comname = "Power Cell - Lawbringer Charger"
	comtype = /obj/item/ammo/power_cell/self_charging/lawbringer
	desc = "The new generation lawbringers are prone to bricking their power cells in storage. I'll pay a lot for replacements."
	price = 250000
	upperfluc = 10000
	lowerfluc = -10000
/datum/commodity/blackmarket/surplus/powercell
	comname = "Small Power Cell"
	comtype = 
	desc = "We can always use more power cells."
	price = 1200
	upperfluc = 800
	lowerfluc = -600
/datum/commodity/blackmarket/surplus/customcell
	comname = "Power Cell - Custom"
	comtype = /obj/item/ammo/power_cell/self_charging/custom
	desc = "Any working power cells you make, I'll buy. Strictly at bulk rates."
	price = 1600
	upperfluc = 600
	lowerfluc = -600
/datum/commodity/blackmarket/surplus/powercell
	comname = "Erebite Power Cell"
	comtype = 
	desc = "We can always use more power cells."
	price = 1400
	upperfluc = 500
	lowerfluc = -500
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                          //
// ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄          ▄▄▄▄         ▄▄▄▄     //
//▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌       ▄█░░░░▌      ▄█░░░░▌    //
//▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀█░█▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀       ▐░░▌▐░░▌     ▐░░▌▐░░▌    //
//▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌      ▐░▌    ▐░▌          ▐░▌               ▐░▌            ▀▀ ▐░░▌      ▀▀ ▐░░▌    //
//▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌      ▐░▌    ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌               ▐░▌               ▐░░▌         ▐░░▌    //
//▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░▌       ▐░▌    ▐░░░░░░░░░░░▌▐░▌               ▐░▌               ▐░░▌         ▐░░▌    //
// ▀▀▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌      ▐░▌    ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌               ▐░▌               ▐░░▌         ▐░░▌    //
//          ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌      ▐░▌    ▐░▌          ▐░▌               ▐░▌               ▐░░▌         ▐░░▌    //
// ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄█░▌    ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌           ▄▄▄▄█░░█▄▄▄  ▄▄▄▄█░░█▄▄▄ //
//▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ ▐░░░░░░░▌    ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌//
// ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀      ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ //
//                                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
///███████ ███████ ██      ██      ██ ███    ██  ██████     //
///██      ██      ██      ██      ██ ████   ██ ██       ██ //
///███████ █████   ██      ██      ██ ██ ██  ██ ██   ███    //
///     ██ ██      ██      ██      ██ ██  ██ ██ ██    ██ ██ //
///███████ ███████ ███████ ███████ ██ ██   ████  ██████     //
///////////////////////////////////////////////////////////////

/datum/commodity/blackmarket/blob/chitin
	comname = "CHITIN"
	comtype = /obj/item/raw_material/chitin
	price = 2000
	upperfluc = 800
	lowerfluc = -800

/datum/commodity/blackmarket/blob/head
	comname = "CRANIUM"
	comtype = /obj/item/organ/head
	price = 6000
	made_from = "blob"
	name = "Weird Head"
	icon_state = "blob"
	desc = "A severed head. It looks weird and disgusting. More disgusting than other severed heads."
	upperfluc = 3000
	lowerfluc = -3000

/////////////////////////////////////////////////////////
///██████  ██    ██ ██    ██ ██ ███    ██  ██████     ///
///██   ██ ██    ██  ██  ██  ██ ████   ██ ██       ██ ///
///██████  ██    ██   ████   ██ ██ ██  ██ ██   ███    ///
///██   ██ ██    ██    ██    ██ ██  ██ ██ ██    ██ ██ ///
///██████   ██████     ██    ██ ██   ████  ██████     ///
/////////////////////////////////////////////////////////

/datum/commodity/blackmarket/blob/heisenbee
	comname = "Heisenbee"
	comtype = /obj/critter/domestic_bee/heisenbee
	desc_sell = "WANT. THE BEE. DEAD. OR ALIVE."
	price = 680600
	upperfluc = 120000
	lowerfluc = -120000

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                              //
//        ██████  ██░ ██  ▄▄▄      ▓█████▄ ▓██   ██▓    ▄▄▄██▀▀▀ ▄▄▄       ███▄    █ ▓█████     //
//      ▒██    ▒ ▓██░ ██▒▒████▄    ▒██▀ ██▌ ▒██  ██▒      ▒██   ▒████▄     ██ ▀█   █ ▓█   ▀     //
//      ░ ▓██▄   ▒██▀▀██░▒██  ▀█▄  ░██   █▌  ▒██ ██░      ░██   ▒██  ▀█▄  ▓██  ▀█ ██▒▒███       //
//       ▒   ██▒░▓█ ░██ ░██▄▄▄▄██ ░▓█▄   ▌  ░ ▐██▓░   ▓██▄██▓  ░██▄▄▄▄██ ▓██▒  ▐▌██▒▒▓█  ▄      //
//     ▒██████▒▒░▓█▒░██▓ ▓█   ▓██▒░▒████▓   ░ ██▒▓░    ▓███▒    ▓█   ▓██▒▒██░   ▓██░░▒████▒     //
//      ▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒ ▒▒   ▓▒█░ ▒▒▓  ▒    ██▒▒▒     ▒▓▒▒░    ▒▒   ▓▒█░░ ▒░   ▒ ▒ ░░ ▒░ ░    //
//      ░ ░▒  ░ ░ ▒ ░▒░ ░  ▒   ▒▒ ░ ░ ▒  ▒  ▓██ ░▒░     ▒ ░▒░     ▒   ▒▒ ░░ ░░   ░ ▒░ ░ ░  ░    //
//      ░  ░  ░   ░  ░░ ░  ░   ▒    ░ ░  ░  ▒ ▒ ░░      ░ ░ ░     ░   ▒      ░   ░ ░    ░       //
//            ░   ░  ░  ░      ░  ░   ░     ░ ░         ░   ░         ░  ░         ░    ░  ░    //
//                                  ░       ░ ░                                                 //
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
///███████ ███████ ██      ██      ██ ███    ██  ██████     //
///██      ██      ██      ██      ██ ████   ██ ██       ██ //
///███████ █████   ██      ██      ██ ██ ██  ██ ██   ███    //
///     ██ ██      ██      ██      ██ ██  ██ ██ ██    ██ ██ //
///███████ ███████ ███████ ███████ ██ ██   ████  ██████     ///
///////////////////////////////////////////////////////////////

/datum/commodity/blackmarket/shady/cursedmask
	comname = "Boobytrapped Clown Mask"
	desc_sell = "This one's been modified a little. Have fun!"
	comtype = /obj/item/clothing/mask/gas/syndie_clown
	price = 45000
	upperfluc = 15000
	lowerfluc = -15000
	
/datum/commodity/blackmarket/shady/omnitool
	comname = "Omnitool"
	desc_sell = "A lifesaver, really."
	comtype = obj/item/tool/omnitool/syndicate
	price = 35000
	upperfluc = 6000
	lowerfluc = -6000
	
/datum/commodity/blackmarket/shady/zippo
	comname = "High-power Zippo Lighter"
	desc_sell = "A lifesaver, really."
	comtype = obj/item/device/light/zippo/syndicate
	price = 32000
	upperfluc = 6000
	lowerfluc = -6000
	
/datum/commodity/blackmarket/shady/turboflash
	comname = "TurboFlash"
	desc_sell = "Standard flash with an aftermarket improvement."
	comtype = /obj/item/device/flash/turbo
	price = 1500
	upperfluc = 350
	lowerfluc = -350
	
/datum/commodity/blackmarket/shady/multitool
	comname = "Multitool"
	desc_sell = "Useful!"
	comtype = /obj/item/device/multitool
	price = 500
	upperfluc = 200
	lowerfluc = -200
	
/datum/commodity/blackmarket/shady/brick
	comname = "Ceramic Bricks"
	comtype = /obj/item/brick
	price = 60
	upperfluc = 20
	lowerfluc = -20
	
/datum/commodity/blackmarket/shady/balaclava
	comname = "Balaclava"
	comtype = /obj/item/clothing/mask/balaclava
	price = 120
	upperfluc = 100
	lowerfluc = -100
	
/datum/commodity/blackmarket/shady/welder
	comname = "High Capacity Welder"
	desc_sell = "Don't leave your pod without one."
	comtype = /obj/item/weldingtool/high_cap
	price = 120
	upperfluc = 100
	lowerfluc = -100
	
/////////////////////////////////////////////////////////
///██████  ██    ██ ██    ██ ██ ███    ██  ██████     ///
///██   ██ ██    ██  ██  ██  ██ ████   ██ ██       ██ ///
///██████  ██    ██   ████   ██ ██ ██  ██ ██   ███    ///
///██   ██ ██    ██    ██    ██ ██  ██ ██ ██    ██ ██ ///
///██████   ██████     ██    ██ ██   ████  ██████     ///
/////////////////////////////////////////////////////////

/datum/commodity/blackmarket/shady/pipebomb
	comname = "Pipe Bomb"
	comtype = obj/item/pipebomb/bomb
	price = 4500
	baseprice = 4500
	upperfluc = 700
	lowerfluc = -700
/datum/commodity/blackmarket/shady/flamethrower
	comname = "Flamethrower"
	comtype = /obj/item/gun/flamethrower/assembled
	price = 7500
	baseprice = 7500
	upperfluc = 1000
	lowerfluc = -1000
/datum/commodity/blackmarket/shady/wirecutters
	comname = "Yellow Wirecutters"
	comtype = /obj/item/wirecutters/yellow
	desc_sell = "Only the ones with the yellow handles!"
	price = 700
	baseprice = 700
	upperfluc = 500
	lowerfluc = -500
/datum/commodity/blackmarket/shady/crowbar
	comname = "Red Crowbar"
	comtype = /obj/item/crowbar/red
	desc_sell = "They've gotta be red."
	price = 1000
	baseprice = 1000
	upperfluc = 100
	lowerfluc = -100
/datum/commodity/blackmarket/shady/barrier
	comname = "Riot Barrier"
	comtype = /obj/item/barrier
	price = 12800
	baseprice = 2800
	upperfluc = 00
	lowerfluc = -1000
/datum/commodity/blackmarket/shady/security_badge
	comname = "Security Badge"
	comtype = /obj/item/clothing/suit/security_badge
	desc_sell = "These things fetch a high price on the black market."
	price = 9800
	baseprice = 9800
	upperfluc = 1200
	lowerfluc = -1200


//////////////////////////////////////////////////////////////////////////////////////////
//	███╗   ███╗ █████╗ ██████╗     ██╗      █████╗ ██████╗ ██████╗ ██╗   ██╗	//
//	████╗ ████║██╔══██╗██╔══██╗    ██║     ██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝	//
//	██╔████╔██║███████║██║  ██║    ██║     ███████║██████╔╝██████╔╝ ╚████╔╝ 	//
//	██║╚██╔╝██║██╔══██║██║  ██║    ██║     ██╔══██║██╔══██╗██╔══██╗  ╚██╔╝  	//
//	██║ ╚═╝ ██║██║  ██║██████╔╝    ███████╗██║  ██║██║  ██║██║  ██║   ██║   	//
//	╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝           //
//////////////////////////////////////////////////////////////////////////////////////////
// space garbage and telesci oddities

//////////////////////////////////////////////////////////////
///███████ ███████ ██      ██      ██ ███    ██  ██████     //
///██      ██      ██      ██      ██ ████   ██ ██       ██ //
///███████ █████   ██      ██      ██ ██ ██  ██ ██   ███    //
///     ██ ██      ██      ██      ██ ██  ██ ██ ██    ██ ██ //
///███████ ███████ ███████ ███████ ██ ██   ████  ██████     //
//////////////////////////////////////////////////////////////

/datum/commodity/blackmarket/wrestler/monkeyphoto
	comname = "Official Ugly Monkey Photograph"
	comtype = /obj/item/photo
	name = "Ugly Monkey Photograph"
	desc = "A poorly drawn picture of a monkey. Apparently its name is "
	var/list/monkeynamesa = list("Zu", "Old Za", "Ava", "Li", "Captain K", "Bana", "Krink", "Mu",
	"Hel", "King A", "Mann", "Piz", "El L", "Fi", "Dana", "Avi",)
	var/list/monkeynamesb = list("nal", "mbu", "lici", "kkil", "ro", "na", "risp", "ag",
	"ink", "oya", "onk", "abi", "angho", "sen", "kota", "illi",)
	var/list/monkeynamesc = list("n", " Kong", "li", "lu", "bury the Third", "g", "kle", "stein",
	"ger", "bob", "kee", " Smith", "oik", "mn", "a", "na",)
		New()
			..()
			desc = desc + pick(monkeynamesa) + pick(monkeynamesb) + pick(monkeynamesc) + ", and it is Ugly Monkey number " + rand(1, 5000) + ". Great."
	icon_state = "photo-monkey"
	desc_sell = "Highly collectible picture of a monkey! Each one comes with a number and a name!"
	price = 5000000
	upperfluc = 1000000
	lowerfluc = -1000000
	
/datum/commodity/blackmarket/wrestler/zippo
	comname = "Promotional Discunt Dan Zippo Lighter"
	comtype = /obj/item/device/light/zippo/dan
	desc_sell = "These things are hella rare! The value skyrocketted when they were banned from trade because of the explosion problem!"
	price = 1980
	upperfluc = 600
	lowerfluc = -600

/datum/commodity/blackmarket/wrestler/pinpointer
	comname = "Artifact Pinpointer"
	comtype = /obj/item/pinpointer/category/artifacts/safe
	desc_sell = "This machine POINTS OUT ancient alien artifacts near you! EXCELLENT for space explorers!"
	price = 1520
	upperfluc = 520
	lowerfluc = -520

/datum/commodity/blackmarket/wrestler/mop
	comname = "Box of Beer"
	comtype = /obj/item/mop/old
	desc_sell = "Old style mops! Some SWEAR BY EM!"
	price = 780
	upperfluc = 300
	lowerfluc = -300

/datum/commodity/blackmarket/wrestler/cigarbox
	comname = "Golden Cigar Box"
	comtype = /obj/item/cigarbox/gold
	desc_sell = "These are the good kind, pal! THE TOP OF THE LINE!"
	price = 5000000
	upperfluc = 1000000
	lowerfluc = -1000000

/datum/commodity/blackmarket/wrestler/juicer
	comname = "Box of Juicer Schweet's Rowdy Rillos"
	comtype = /obj/item/cigpacket/cigarillo/juicer
	desc_sell = "Get some JUICY SWEETS! Or WHATEVER it says on these!"
	price = 140
	upperfluc = 60
	lowerfluc = -60

/datum/commodity/blackmarket/wrestler/rubberduck
	comname = "Cursed Rubber Duck"
	comtype = /obj/item/rubberduck
	desc_sell = "DAMN do these ducks have bad vibes!"
	price = 530
	upperfluc = 80
	lowerfluc = -80
/datum/commodity/blackmarket/wrestler/beerbox
	comname = "Box of Beer"
	comtype = /obj/item/storage/box/beer
	desc_sell = "Get some BEER!"
	price = 980
	upperfluc = 600
	lowerfluc = -600
	
/datum/commodity/blackmarket/wrestler/videocard
	comname = "Advanced Videocard"
	comtype = /obj/item/peripheral/videocard
	desc_sell = "JUICE UP your computer's MUSCLES with one of these bad boys. Guaranteed to get you MORE FRAMES of HYPER ROBUST ACTION!"
	price = 8000
	upperfluc = 3000
	lowerfluc = -3000
	
/datum/commodity/blackmarket/wrestler/laptop
	comname = "Personal Laptop"
	comtype = /obj/item/luggable_computer/personal
	desc = "Hey how about a FOLDABLE PERSONAL PLANNER!"
	price = 5000
	baseprice = 5000
	upperfluc = 1000
	lowerfluc = -2000
	
/datum/commodity/blackmarket/wrestler/monkeywrench
	comname = "Monkey Wrench"
	comtype = /obj/item/wrench/monkey
	desc = "An awful and tragic abomination created by space-wizards. Allegedly the result of experimenting on injecting innocent animals with liquid puns. However, they are PRETTY USEFUL!"
	price = 1200
	baseprice = 1200
	upperfluc = 200
	lowerfluc = -200
	
/datum/commodity/blackmarket/wrestler/shirts
	comname = "Commemorative T-Shirt"
	comtype = null
	desc = "Got a bunch of these in from an old storage locker, I don't even know what's inside the boxes! I open a fresh crate one every day!"
	price = 90
	baseprice = 90
	upperfluc = 80
	lowerfluc = -80
	New()
		..()
		switch (lowertext( time2text(world.realtime, "Day") ))
			if ("monday")
				comtype = /obj/item/clothing/suit/lunar_tshirt
			if ("tuesday")
				comtype = /obj/item/clothing/under/jersey
				name = "Commemerative Basketball Jersey"
				desc = "A replica of a jersey worn by Red Hot Benson the during the '56 Space Olympics."
				icon_state = "dan_jersey"
				item_state = "dan_jersey"
			if ("wednesday")
				comtype = /obj/item/clothing/under/misc/bandshirt
				name = "Acer Riggs T-Shirt"
				desc = "Merch swag from an Acer Riggs concert on Europa."
			if ("thursday")
				comtype = /obj/item/clothing/suit/apron/tricolor
				name = "Promotional Apron"
				desc = "A gaudy apron. It seems to be advertising a restaurant called 'Dang Ol Belle's Crusty Cuts'."
			if ("friday")
				comtype = /obj/item/clothing/suit/lshirt
				name = "long sleeved logo shirt"
				icon_state = "dan_red"
				item_state = "dan_red"
				desc = "A comfy looking long sleeved shirt with 'I may be mad but I'm not off my rocker!!!' written on the front. Is this some kind of joke?"
			if ("saturday")
				comtype = /obj/item/clothing/suit/labcoat/dan
			if ("sunday")
				//todo: something to do with the sun
				comtype = /obj/item/clothing/suit/lshirt
				name = "long sleeved logo shirt"
				icon_state = "dan_blue"
				item_state = "dan_blue"
				desc = "A comfy looking long sleeved shirt with the Discount Dan's logo stitched on the front. Delicious-looking tortilla chips are stitched on the back."

/datum/commodity/blackmarket/wrestler/cowboyboots
	comname = "Genuine Space-Texan Cowboy Boots"
	comtype = /obj/item/clothing/shoes/westboot
	desc = "These bad boys will command RESPECT among any peers you may or may not have!"
	price = 150
	baseprice = 150
	upperfluc = 120
	lowerfluc = -120
	
/datum/commodity/blackmarket/wrestler/capsule
	comname = "Figurine Capsule"
	comtype = /obj/item/item_box/figure_capsule/gaming_capsule
	desc = "Got a bunch of these little plastic capsules with some kind of action figure inside. Apparently some kinda collectible."
	price = 90
	baseprice = 90
	upperfluc = 40
	lowerfluc = -40

/////////////////////////////////////////////////////////
///██████  ██    ██ ██    ██ ██ ███    ██  ██████     ///
///██   ██ ██    ██  ██  ██  ██ ████   ██ ██       ██ ///
///██████  ██    ██   ████   ██ ██ ██  ██ ██   ███    ///
///██   ██ ██    ██    ██    ██ ██  ██ ██ ██    ██ ██ ///
///██████   ██████     ██    ██ ██   ████  ██████     ///
/////////////////////////////////////////////////////////

/datum/commodity/blackmarket/wrestler/tsunami
	comname = "Tsunami Spray Bottle"
	comtype = /obj/item/spraybottle/cleaner/tsunami
	desc_sell = "The ring can get SWEATY! Sometimes there's BLOOD!"
	price = 7200
	baseprice = 7200
	upperfluc = 400
	lowerfluc = -400
/datum/commodity/blackmarket/wrestler/pen
	comname = "Fancy Pens"
	comtype = /obj/item/pen/fancy
	desc_sell = "I go through A LOT of these in my shows!"
	price = 350
	baseprice = 350
	upperfluc = 50
	lowerfluc = -50
/datum/commodity/blackmarket/wrestler/chompskey
	comname = "Chomp Key"
	comtype = /obj/item/device/key/chompskey
	desc_sell = "I need one of these URGENTLY!"
	price = 20000
	baseprice = 20000
	upperfluc = 2000
	lowerfluc = -2000
/datum/commodity/blackmarket/wrestler/hairballkey
	//katmandu
	comname = "Hairball Key"
	comtype = /obj/item/device/key/hairball
	desc_sell = "DON'T even ASK!"
	price = 60100
	baseprice = 60100
	upperfluc = 25000
	lowerfluc = -25000
/datum/commodity/blackmarket/wrestler/brick
	//stockpiling bricks from jane and selling them to larry makes a profit. it's brick economics
	comname = "Ceramic Bricks"
	comtype = /obj/item/brick
	desc_sell = "I go through A LOT of these in my shows!"
	price = 100
	baseprice = 40
	upperfluc = 40
	lowerfluc = -40
/datum/commodity/blackmarket/wrestler/ghostgun
	comname = "Ectoplasmic Destabilizer"
	comtype = /obj/item/gun/energy/ghost
	desc_sell = "Ghosts are real and THEY'RE COMING FOR MY ASS! I need some ASS KICKING GHOST MULCHING LASER GUNS!"
	price = 10200
	baseprice = 10200
	upperfluc = 10000
	lowerfluc = -10000
/datum/commodity/blackmarket/wrestler/goldfishcracker
	//farmable from a strange seeds plant - work out how profitible this is compared to other plants (especially rock plant).
	comname = "Goldfish Cracker"
	comtype = /obj/item/reagent_containers/food/snacks/goldfish_cracker
	desc_sell = "These things are LIFESAVERS when it comes to building muscle! I NEED AS MANY AS YOU CAN GET!"
	price = 1200
	baseprice = 1200
	upperfluc = 500
	lowerfluc = -500
/datum/commodity/blackmarket/wrestler/teapot
	//not really worth it but it's an excuse to take these out of the hidden workshop
	comname = "Handmade Tetsubin"
	comtype = /obj/item/reagent_containers/food/drinks/teapot
	desc_sell = "I'm an avid collector of fancy teapots, and I'd like to get my hand on any interesting ones you find."
	price = 4000
	upperfluc = 3000
	lowerfluc = -3000
/datum/commodity/blackmarket/wrestler/nassa
	//would like to have the price higher but alas it's avaliable in a QM crate and valued at about 7.5k there
	comname = "NASSA space suit"
	comtype = /obj/item/clothing/under/gimmick/blackstronaut
	desc_sell = "I'd LOVE to get my hands on a couple sets of that prototype jumpsuit. WRESTLING IN THE COLD VACCUM OF SPACE! I'll pay a BUNCH for any you find in good condition!"
	price = 6200
	upperfluc = 800
	lowerfluc = -800
/datum/commodity/blackmarket/wrestler/uplink_telecrystal
	//this is the bad guy tokens, and it's a lowball offer. this is primarily for using telescrystals to bribe crew members (who have no legitimate use for TCs)
	comname = "Pure Telecrystal Token"
	comtype = /obj/item/uplink_telecrystal
	desc_sell = "These things are practically CURRENCY on some planets! I can get you a GREAT DEAL on them!"
	price = 30000
	upperfluc = 1
	lowerfluc = -1
/datum/commodity/blackmarket/wrestler/sacred_sandal
	comname = "Sacred Sandals"
	comtype = /obj/item/clothing/shoes/hermes
	desc_sell = "These things have GOT TO BE ORIGINALS! Not the knock off "Magic Sandals" the space wizards manufacture in sweatshops!"
	price = 500000
	upperfluc = 100000
	lowerfluc = -100000
/datum/commodity/blackmarket/wrestler/magic_sandal
	//these things are everywhere
	comname = "Magic Sandals"
	comtype = /obj/item/clothing/shoes/sandal
	desc_sell = "That said, those knock offs are DAMN WELL MADE! I'll buy those for a fair price!"
	price = 6800
	upperfluc = 1200
	lowerfluc = -1200
/datum/commodity/blackmarket/wrestler/glitch_gun
	//not sure if this is legitimately obtainable?
	comname = "Glitch Gun"
	comtype = /obj/item/gun/energy/glitch_gun
	desc_sell = "You hear about the fabled Glitch Gun? It's said to be able to shoot bullets though code itself. If you find it, SELL IT TO ME!"
	price = 1620000
	upperfluc = 1200
	lowerfluc = -1200
/datum/commodity/blackmarket/wrestler/capsuit
	comname = "Captain's Space Suit"
	comtype = /obj/item/clothing/suit/space/captain
	desc_sell = "The old style green space suits NT used to issue to their captains are hella valuable, but unfortunately also hella rare. Hey, you're a Traser, aren't ya? Could you get your captain's space suit to me?"
	price = 605000
	upperfluc = 50000
	lowerfluc = -50000
/datum/commodity/blackmarket/wrestler/dagger
	//this is both the traitor's dagger and the biodome dagger
	comname = "Sacrificial Dagger"
	comtype = /obj/item/dagger
	desc_sell = "Old knives are great investments! The more occult the better!"
	price = 210400
	upperfluc = 30000
	lowerfluc = -30000
/datum/commodity/blackmarket/wrestler/shoecrafts
	//space sweatshop 13
	comname = "Custom Shoes"
	comtype = /obj/item/clothing/shoes/crafted
	desc_sell = "And any shoes YOU HAND CRAFT, I WILL BUY!"
	price = 800
	upperfluc = 600
	lowerfluc = -600
/datum/commodity/blackmarket/wrestler/katana_nukeop
	//this assumes only 1 exists, only on nuke mode, and only on the nuke op commander. remove if that ever changes
	comname = "Syndicate Commander's Sabre"
	comtype = /obj/item/katana/nukeop
	desc_sell = "These swords are the HOLY GRAIL for salvage crews!"
	price = 50000000
	upperfluc = 0
	lowerfluc = -1
