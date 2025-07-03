#define TAG_ORE 1
#define TAG_WRECKAGE 2
#define TAG_PLANET 4
#define TAG_ANOMALY 8
#define TAG_SPACE 16
#define TAG_NPC 32
#define TAG_TELEPORT_LOC 64
#define TAG_CRUISER_LOC 128
#define TAG_MAGNET_LOC 256

/datum/telescope_event
	var/name = ""			   //Name which is shown after discovery
	var/name_undiscovered = "" //Name which is shown when you haven't found this event yet.
	var/id = ""
	var/fixed_location = 0
	var/loc_x = 0
	var/loc_y = 0
	var/size = 15 			//The size of the spot you need to hit.
	var/tags = 0 //Bitfield of tags, see beginning of file. Used for searching.
	var/rarity = 100 //Rarity of location in percent. (100% is base)
	var/datum/dialogueMaster/telescopeDialogue = null //If this exists it will be called when the location is contacted.a
	var/disabled = 0 //Disabled events will stay in their respective lists but will not show up on the telescope. They are not considered when looking for new events to pop up.
	var/manual = 0 //Manual events will not be created on round start and must be instantiated and managed manually. See proc/addManualEvent(var/eventType = null, var/active=1)

	proc/onDiscover(var/obj/machinery/computer/telescope/T) //When "discovered"
		return

	proc/onContact(var/obj/machinery/computer/telescope/T) //When actually activated in the telescope
		return

/*
/datum/telescope_event/TEST
	name = "TEST"
	name_undiscovered = "TEST"
	id = "TEST"
	tags = TAG_WRECKAGE | TAG_NPC
	size = 200
	rarity = 1000000
	manual = 1

	onContact(var/obj/machinery/computer/telescope/T)
		..()
		swapMaster.placeSwapPrefab("assets/maps/prefabs/prefab_ksol.dmm")
		return
*/

/datum/telescope_event/sosvaliant
	name = "SS Valiant signal"
	name_undiscovered = "Distress signal V41-7"
	id = "vd"
	tags = TAG_WRECKAGE | TAG_NPC
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeValiant(src)

/datum/telescope_event/chainedpen
	name = "Weak transmission"
	name_undiscovered = "Weak signal"
	id = "pn"
	size = 10
	tags = TAG_ANOMALY
	rarity = 3

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopePen(src)

	onContact(var/obj/machinery/computer/telescope/T)
		..()
		playsound(T.loc, 'sound/voice/femvox.ogg', 100, 0)
		return

/datum/telescope_event/geminorum
	name = "Geminorum V"
	name_undiscovered = "Unknown beacon A23V"
	id = "gm"
	size = 15
	tags = TAG_PLANET | TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeGeminorum(src)

/datum/telescope_event/dojo
	name = "Hidden Workshop"
	name_undiscovered = "Energy emission signal"
	id = "ws"
	size = 25
	tags = TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeDojo(src)

#ifdef ENABLE_ARTEMIS
/datum/telescope_event/artemis
	name = "Artemis"
	name_undiscovered = "Encrypted NT signal"
	id = "at"
	size = 10
	manual = 1
	tags = TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeArtemis(src)
#endif

/datum/telescope_event/cow
	name = "Void Diner"
	name_undiscovered = "Unusual signal"
	id = "cw"
	size = 25
	tags = TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeCow(src)

/datum/telescope_event/watchfuleye
	name = "Watchful Eye Sensor"
	name_undiscovered = "Strong Signal"
	id = "we"
	size = 25
	tags = TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeEye(src)

//MINING STUFF BELOW
/datum/telescope_event/ore_miraclium
	name = "Miraclium asteroid"
	name_undiscovered = "Celestial body"
	id = "om"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 40
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Miraclium asteroid"
		D.start.nodeImage = "asteroidmiracle.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large miraclium asteroid."


/datum/telescope_event/ore_mauxite
	name = "Mauxite asteroid"
	name_undiscovered = "Celestial body"
	id = "oma"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 100
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Mauxite asteroid"
		D.start.nodeImage = "asteroidred.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large Mauxite asteroid."


/datum/telescope_event/ore_valuable
	name = "Valuable asteroid"
	name_undiscovered = "Celestial body"
	id = "ov"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 20
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Valuable asteroid"
		D.start.nodeImage = "asteroidgold.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large golden asteroid."

/datum/telescope_event/ore_molitz
	name = "Molitz asteroid"
	name_undiscovered = "Celestial body"
	id = "omo"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 80
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Molitz asteroid"
		D.start.nodeImage = "asteroidsmooth.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large molitz asteroid."


/datum/telescope_event/ore_bohrum
	name = "Bohrum asteroid"
	name_undiscovered = "Celestial body"
	id = "ob"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 100
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Bohrum asteroid"
		D.start.nodeImage = "asteroid.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large bohrum asteroid."

/datum/telescope_event/ore_char
	name = "Char asteroid"
	name_undiscovered = "Celestial body"
	id = "oc"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 100
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Char asteroid"
		D.start.nodeImage = "asteroiddark.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large char asteroid."

/datum/telescope_event/ore_erebite
	name = "Erebite asteroid"
	name_undiscovered = "Celestial body"
	id = "oe"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 50
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Erebite asteroid"
		D.start.nodeImage = "asteroidgoldred.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large Erebite asteroid."

/datum/telescope_event/ore_phar
	name = "Pharosium asteroid"
	name_undiscovered = "Celestial body"
	id = "oph"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 90
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Pharosium asteroid"
		D.start.nodeImage = "asteroidcopper.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a large Pharosium asteroid."

/datum/telescope_event/ore_star
	name = "Starstone asteroid"
	name_undiscovered = "Celestial body"
	id = "ost"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 14
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Starstone asteroid"
		D.start.nodeImage = "asteroidcrystal.png"
		D.start.linkText = "..."
		D.start.nodeText = "It's a Starstone asteroid; incredible!"

/datum/telescope_event/ore_nanite
	name = "Nanite asteroid"
	name_undiscovered = "Celestial body"
	id = "ona"
	tags = TAG_ORE | TAG_MAGNET_LOC
	rarity = 10
	size = 15

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeAsteroidDialogue(src)
		var/datum/dialogueMaster/telescopeAsteroidDialogue/D = telescopeDialogue
		D.linkedEvent = src
		D.encounterName = "Nanite asteroid"
		D.start.nodeImage = "asteroidnano.png"
		D.start.linkText = "..."
		D.start.nodeText = "This asteroid appears to be infested with nanites. This could be dangerous."
