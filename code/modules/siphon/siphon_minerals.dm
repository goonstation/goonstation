
ABSTRACT_TYPE(/datum/siphon_mineral)
/datum/siphon_mineral
	///Name of mineral, can be used for the player-viewable settings compendium
	var/name = "Youshouldn'tseemium"
	///Whether this outcome should be indexed in the player-viewable settings compendium
	var/indexed = TRUE
	///How many extraction ticks (process iterations times resonator intensity) are required to produce this resource
	var/tick_req = 10
	///Target resonance horizontal strength, positive or negative based on relative X position of resonator multiplied by its power.
	var/x_torque = null
	///Target resonance vertical strength, positive or negative based on relative Y position of resonator multiplied by its power.
	var/y_torque = null
	///Target resonance shear, always positive; when positive and negative resonance cancel each other out, shear is the differential
	var/shear = null
	///Sensitivity window for target resonances; a higher window is more forgiving of imprecise settings
	var/sens_window = 0
	///Stuff to produce when parameters are successfully met
	var/product = /obj/item/raw_material/scrap_metal
	///Setup guide, formatted as a list of strings describing individual resonator positions and intensities
	var/list/setup_guide = null


//A note: Parameter requirements will be totally ignored if not explicitly set.

/datum/siphon_mineral/miraclium
	name = "Direct Extraction"
	tick_req = 16
	x_torque = 0
	y_torque = 0
	shear = 0
	product = /obj/item/raw_material/miracle
	setup_guide = list(
		"Type-AX Resonator, Position C4, 3 Intensity<br>",
		"Type-AX Resonator, Position G4, 3 Intensity<br>",
		"Type-SM Resonator, Position E3, 3 Intensity<br>"
	)

/datum/siphon_mineral/rock
	name = "Rock"
	tick_req = 8
	x_torque = 16
	y_torque = 0
	shear = 0
	sens_window = 2
	product = /obj/item/raw_material/rock
	setup_guide = list(
		"Type-AX Resonator, Position F4, 2 Intensity<br>"
	)

/datum/siphon_mineral/char
	name = "Char"
	tick_req = 8
	x_torque = -16
	y_torque = -4
	shear = 16
	sens_window = 5
	product = /obj/item/raw_material/char
	setup_guide = list(
		"Type-AX Resonator, Position B7, 2 Intensity<br>",
		"Type-AX Resonator, Position G2, 1 Intensity<br>",
		"Type-AX Resonator, Position D4, 2 Intensity<br>"
	)

/datum/siphon_mineral/mauxite
	name = "Mauxite"
	x_torque = 48
	y_torque = -16
	shear = 8
	sens_window = 7
	product = /obj/item/raw_material/mauxite
	setup_guide = list(
		"Type-AX Resonator, Position F4, 4 Intensity<br>",
		"Type-AX Resonator, Position G4, 2 Intensity<br>",
		"Type-AX Resonator, Position E3, 3 Intensity<br>",
		"Type-AX Resonator, Position F6, 1 Intensity<br>"
	)

/datum/siphon_mineral/molitz
	name = "Molitz"
	x_torque = -16
	y_torque = -48
	shear = 8
	sens_window = 7
	product = /obj/item/raw_material/molitz
	setup_guide = list(
		"Type-AX Resonator, Position E3, 4 Intensity<br>",
		"Type-AX Resonator, Position E2, 4 Intensity<br>",
		"Type-AX Resonator, Position D7, 2 Intensity<br>"
	)

/datum/siphon_mineral/pharosium
	name = "Pharosium"
	x_torque = 16
	y_torque = 0
	shear = 40
	sens_window = 7
	product = /obj/item/raw_material/pharosium
	setup_guide = list(
		"Type-AX Resonator, Position F6, 1 Intensity<br>",
		"Type-AX Resonator, Position G5, 2 Intensity<br>",
		"Type-AX Resonator, Position E3, 3 Intensity<br>"
	)

/datum/siphon_mineral/martian
	name = "Viscerite"
	x_torque = 20
	y_torque = 16
	shear = 8
	sens_window = 3
	product = /obj/item/raw_material/martian
	setup_guide = list(
		"Type-AX Resonator, Position E7, 3 Intensity<br>",
		"Type-AX Resonator, Position E2, 1 Intensity<br>",
		"Type-AX Resonator, Position G6, 3 Intensity<br>",
		"Type-AX Resonator, Position F4, 1 Intensity<br>"
	)

/datum/siphon_mineral/claretine
	name = "Claretine"
	tick_req = 15
	x_torque = 32
	y_torque = -4
	shear = 20
	sens_window = 4
	product = /obj/item/raw_material/claretine
	setup_guide = list(
		"Type-AX Resonator, Position C2, 1 Intensity<br>",
		"Type-AX Resonator, Position E2, 1 Intensity<br>",
		"Type-AX Resonator, Position F4, 4 Intensity<br>",
		"Type-AX Resonator, Position G6, 1 Intensity<br>"
	)

/datum/siphon_mineral/bohrum
	name = "Bohrum"
	tick_req = 15
	x_torque = -16
	y_torque = -16
	shear = 24
	sens_window = 4
	product = /obj/item/raw_material/bohrum
	setup_guide = list(
		"Type-AX Resonator, Position C2, 2 Intensity<br>",
		"Type-AX Resonator, Position D3, 2 Intensity<br>",
		"Type-AX Resonator, Position G6, 1 Intensity<br>",
		"Type-AX Resonator, Position H7, 1 Intensity<br>"
	)

/datum/siphon_mineral/fibrilith
	name = "Fibrilith"
	x_torque = 0
	y_torque = 0
	shear = 12
	sens_window = 1
	product = /obj/item/raw_material/fibrilith

	New()
		src.shear = rand(8,16)
		..()

/datum/siphon_mineral/cobryl
	name = "Cobryl"
	x_torque = -96
	shear = 4
	sens_window = 9
	product = /obj/item/raw_material/cobryl

/datum/siphon_mineral/syreline
	name = "Syreline"
	tick_req = 20
	x_torque = 88
	shear = 6
	sens_window = 1
	product = /obj/item/raw_material/syreline

/datum/siphon_mineral/erebite
	name = "Erebite"
	tick_req = 50
	x_torque = 6
	y_torque = -22
	shear = 33
	sens_window = 2
	product = /obj/item/raw_material/erebite

	New()
		src.shear = rand(30,40)
		..()

/datum/siphon_mineral/cerenkite
	name = "Cerenkite"
	tick_req = 30
	x_torque = -24
	y_torque = 8
	shear = 16
	sens_window = 3
	product = /obj/item/raw_material/cerenkite

	New()
		src.shear = rand(8,24)
		..()

/datum/siphon_mineral/plasmastone
	name = "Plasmastone"
	tick_req = 50
	x_torque = -16
	y_torque = 13
	shear = 4
	sens_window = 1
	product = /obj/item/raw_material/plasmastone

	New()
		src.shear = rand(4,10)
		..()

/datum/siphon_mineral/koshmarite
	name = "Koshmarite"
	tick_req = 18
	shear = 58
	product = /obj/item/raw_material/eldritch

	New()
		src.shear = rand(57,60)
		..()

/datum/siphon_mineral/gemstone
	name = "Gemstone"
	tick_req = 35
	x_torque = 0
	y_torque = 0
	shear = 64
	product = /obj/item/raw_material/gemstone

/datum/siphon_mineral/uqill
	name = "Uqill"
	tick_req = 40
	shear = 54
	sens_window = 2
	product = /obj/item/raw_material/uqill
//telecrystal and gnesis have unusual formative conditions difficult to induce manually
//should probably have highly specific parameters, maybe obtained through secrets?
//idea in particular: the required shear is in the 76-89 range and chooses a different value every 60 or 90 sec
//and the recipe is learned through a device that shows you when this value changes, so you need a rapidly adjustable resonator setup
/*
/datum/siphon_mineral/telecrystal
	name = "Telecrystal"
	tick_req = 200
	shear = 63
	product = /obj/item/raw_material/telecrystal

	New()
		src.tick_req = rand(200,230)
		src.shear = rand(61,63)
		..()
*/
//shear of 65 or higher should probably do Bad Things unless precisely set.
/datum/siphon_mineral/gold
	name = "Gold"
	tick_req = 50
	y_torque = 0
	shear = 100
	sens_window = 0
	product = /obj/item/raw_material/gold

	New()
		src.shear = rand(45,50) * 2 // 90 to 100, in only even increments
		..()

/datum/siphon_mineral/starstone
	name = "Starstone"
	tick_req = 1616
	shear = 161
	product = /obj/item/raw_material/starstone

	New()
		src.tick_req = rand(100,130) * 5
		src.shear = rand(130,230)
		..()

/datum/siphon_mineral/blob
	name = "Biomatter (NOT RECOMMENDED)"
	tick_req = 62
	shear = 127
	sens_window = 0
	product = /obj/item/material_piece/wad/blob

	New()
		src.tick_req = rand(8,11) * 10
		src.shear = (rand(56,61) * 2) + 1 // 113 to 127, in only odd increments
		..()

/datum/siphon_mineral/pizza
	indexed = FALSE
	name = "Pizza"
	tick_req = 21
	shear = 69
	sens_window = 0
	product = /obj/item/reagent_containers/food/snacks/pizza

/datum/siphon_mineral/weed
	indexed = FALSE
	name = "Cannabis Synthesis"
	tick_req = 303
	shear = 420
	sens_window = 0
	product = /obj/item/plant/herb/cannabis/mega/spawnable

/datum/siphon_mineral/forbidden //the end comes
	indexed = FALSE
	name = "DATA EXPUNGED"
	tick_req = 666
	shear = 666 //this is a very hard value to reach
	sens_window = 0
	product = /obj/item/plutonium_core
