
ABSTRACT_TYPE(/datum/siphon_mineral)
///A datum providing description and requirements for a particular thing the harmonic siphon can extract.
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

	//A note: Parameter requirements will be totally ignored if not explicitly set.

	///Stuff to produce when parameters are successfully met
	var/product = /obj/item/raw_material/scrap_metal
	///Setup guide, formatted as a list of strings describing individual resonator positions and intensities
	var/list/setup_guide = null
	///When a harmonic cycle is provided, the siphon and associated hardware will automatically handle its integration and cycling.
	var/datum/harmonic_cycle/hm_cycle = null

ABSTRACT_TYPE(/datum/harmonic_cycle)
///Certain harmonic siphon extraction targets have requirements that change over time; this datum specifies the precise manner in which they change.
/datum/harmonic_cycle
	///The minimum time in each cycle before "reharmonization", the randomization of specified parameters.
	var/time_to_shift = 5 MINUTES
	///Additional persistence time that can be added on randomly with each cycle.
	var/extra_time_variability = null
	///Each time a shift occurs, the newly-randomized delay until the next shift is stored here.
	var/current_shift_length = null
	///What time the cycle last shifted (for tracking how long it is until the next shift).
	var/tmp/last_shifted = null

	var/x_torque_min = null
	var/x_torque_max = null
	var/y_torque_min = null
	var/y_torque_max = null
	var/shear_min = null
	var/shear_max = null

//Individual entries

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

//variable materials

/datum/siphon_mineral/telecrystal
	name = "Telecrystal"
	tick_req = 75
	y_torque = -10
	shear = 800
	sens_window = 1
	product = /obj/item/raw_material/telecrystal
	hm_cycle = new /datum/harmonic_cycle/telecrystal

/datum/harmonic_cycle/telecrystal
	time_to_shift = 4 MINUTES
	extra_time_variability = 70 SECONDS
	shear_min = 70
	shear_max = 98

/datum/siphon_mineral/veranium
	name = "Veranium"
	tick_req = 110
	x_torque = 0
	y_torque = -13
	shear = 0
	sens_window = 2
	product = /obj/item/raw_material/veranium
	hm_cycle = new /datum/harmonic_cycle/veranium

/datum/harmonic_cycle/veranium
	time_to_shift = 6 MINUTES
	extra_time_variability = 50 SECONDS
	x_torque_min = -61
	x_torque_max = 61
	y_torque_min = -19
	y_torque_max = -13

/datum/siphon_mineral/yuranite
	name = "Yuranite"
	tick_req = 120
	x_torque = 0
	y_torque = -111
	shear = 130
	sens_window = 5
	product = /obj/item/raw_material/yuranite
	hm_cycle = new /datum/harmonic_cycle/yuranite

/datum/harmonic_cycle/yuranite
	time_to_shift = 1 MINUTES
	extra_time_variability = 12 SECONDS
	y_torque_min = -70
	y_torque_max = -110

//high shear special zone

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
	x_torque = 0
	shear = 161
	product = /obj/item/raw_material/starstone

	New()
		src.tick_req = rand(150,220) * 8
		src.shear = rand(260,360)
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
	product = /obj/item/reagent_containers/food/snacks/pizza/standard/pepperoni

/datum/siphon_mineral/weed
	indexed = FALSE
	name = "Cannabis Synthesis"
	tick_req = 303
	shear = 420
	sens_window = 0
	product = /obj/item/plant/herb/cannabis/spawnable

/datum/siphon_mineral/forbidden
	indexed = FALSE
	name = "DATA EXPUNGED"
	tick_req = 666
	shear = 666
	sens_window = 0
	product = /obj/item/reagent_containers/food/snacks/ectoplasm
