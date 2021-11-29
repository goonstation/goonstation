
ABSTRACT_TYPE(/datum/siphon_mineral)
/datum/siphon_mineral
	///Name of mineral, can be used for the player-viewable settings compendium
	var/name = "Youshouldn'tseemium"
	///Shows whether this outcome should be indexed in the player-viewable settings compendium
	var/indexed = 1
	///How many extraction tick_req are required to produce this resource
	var/tick_req = 3
	///Target resonance horizontal strength, positive or negative based on relative X position of resonator multiplied by its power.
	var/x_torque = 0
	///Target resonance vertical strength, positive or negative based on relative Y position of resonator multiplied by its power.
	var/y_torque = 0
	///Target resonance shear, always positive; when positive and negative resonance cancel each other out, shear is the differential
	var/shear = 0
	///Sensitivity window for target resonances; a higher window is more forgiving of imprecise settings
	var/sens_window = 0
	///Stuff to produce when parameters are successfully met
	var/product = /obj/item/raw_material/scrap_metal

	New()
		..()

//A note: Parameter requirements will be totally ignored if not explicitly set.

/datum/siphon_mineral/rock
	name = "Rock"
	tick_req = 1
	x_torque = 16
	y_torque = 0
	product = /obj/item/raw_material/rock

/datum/siphon_mineral/mauxite
	name = "Mauxite"
	x_torque = 48
	y_torque = -16
	shear = 8
	sens_window = 7
	product = /obj/item/raw_material/mauxite

/datum/siphon_mineral/molitz
	name = "Molitz"
	x_torque = -16
	y_torque = -48
	shear = 8
	sens_window = 7
	product = /obj/item/raw_material/molitz

/datum/siphon_mineral/pharosium
	name = "Pharosium"
	x_torque = 16
	y_torque = 0
	shear = 40
	sens_window = 7
	product = /obj/item/raw_material/pharosium

/datum/siphon_mineral/cobryl
	name = "Cobryl"
	x_torque = -96
	shear = 4
	sens_window = 9
	product = /obj/item/raw_material/cobryl

/datum/siphon_mineral/char
	name = "Char"
	tick_req = 2
	x_torque = -16
	y_torque = 0
	shear = 16
	sens_window = 1
	product = /obj/item/raw_material/char

	New()
		src.shear = rand(12,20) * -1
		..()

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

/datum/siphon_mineral/martian
	name = "Viscerite"
	tick_req = 4
	x_torque = 20
	y_torque = 16
	shear = 8
	sens_window = 3
	product = /obj/item/raw_material/martian

/datum/siphon_mineral/claretine
	name = "Claretine"
	tick_req = 5
	x_torque = 32
	y_torque = -4
	shear = 20
	sens_window = 4
	product = /obj/item/raw_material/claretine

/datum/siphon_mineral/bohrum
	name = "Bohrum"
	tick_req = 5
	x_torque = -16
	y_torque = -16
	shear = 30
	sens_window = 4
	product = /obj/item/raw_material/bohrum

/datum/siphon_mineral/syreline
	name = "Syreline"
	tick_req = 6
	x_torque = 88
	shear = 6
	sens_window = 1
	product = /obj/item/raw_material/syreline

/datum/siphon_mineral/erebite
	name = "Erebite"
	tick_req = 8
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
	tick_req = 7
	x_torque = -24
	y_torque = 8
	shear = 16
	sens_window = 3
	product = /obj/item/raw_material/cerenkite

	New()
		src.shear = rand(8,24)
		..()

/datum/siphon_mineral/koshmarite
	name = "Koshmarite"
	tick_req = 4
	shear = 58
	product = /obj/item/raw_material/eldritch

	New()
		src.shear = rand(57,60)
		..()

/datum/siphon_mineral/gemstone
	name = "Gemstone"
	tick_req = 6
	shear = 64
	product = /obj/item/raw_material/gemstone

/datum/siphon_mineral/uqill
	name = "uqill"
	tick_req = 9
	shear = 54
	sens_window = 2
	product = /obj/item/raw_material/uqill

/datum/siphon_mineral/telecrystal
	name = "Telecrystal"
	tick_req = 12
	shear = 63
	product = /obj/item/raw_material/telecrystal

	New()
		src.shear = rand(61,63)
		..()

//shear of 65 or higher should do Bad Things unless precisely set to this number
/datum/siphon_mineral/starstone
	name = "Starstone"
	tick_req = 35
	shear = 110
	product = /obj/item/raw_material/starstone

	New()
		src.shear = rand(106,115)
		..()
