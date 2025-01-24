/obj/fakeobject
	text = ""
	plane = PLANE_NOSHADOW_BELOW
	var/list/random_icon_states = list()
	var/random_dir = 0
	pass_unstable = FALSE

	layer = OBJ_LAYER
	plane = PLANE_DEFAULT
	var/true_name = "fuck you erik"	//How else will players banish it or place curses on it?? honestly people

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.true_name][name_suffix(null, 1)]"

	New()
		true_name = name
		..()
		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name
		src.flags |= UNCRUSHABLE

	proc/setup(var/L)
		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name

	meteorhit(obj/M as obj)
		if (isrestrictedz(src.z))
			return
		else
			return ..()

	ex_act(severity)
		if (isrestrictedz(src.z))
			return
		else
			qdel(src)
			//return ..()

	track_blood()
		src.tracked_blood = null
		return

/obj/fakeobject/skeleton
	name = "skeleton"
	desc = "The remains of a human."
	opacity = 0
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "skeleton_l"
	plane = PLANE_DEFAULT

	decomposed_corpse
		name = "decomposed corpse"
		desc = "Eugh, the stench is horrible!"
		icon = 'icons/misc/hstation.dmi'
		icon_state = "body1"

	unanchored
		anchored = UNANCHORED

		summon
			New()
				flick("skeleton_summon", src)
				..()


	cap
		name = "remains of the captain"
		desc = "The remains of the captain of this station ..."
		opacity = 0
		density = 0
		anchored = ANCHORED
		icon = 'icons/obj/adventurezones/void.dmi'
		icon_state = "skeleton_l"

/obj/fakeobject/pole
	name = "Barber Pole"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "pole"
	anchored = ANCHORED
	density = 0
	desc = "Barber poles historically were signage used to convey that the barber would perform services such as blood letting and other medical procedures, with the red representing blood, and the white representing the bandaging. In America, long after the time when blood-letting was offered, a third colour was added to bring it in line with the colours of their national flag. This one is in space."
	layer = EFFECTS_LAYER_UNDER_2
	plane = PLANE_DEFAULT

/obj/fakeobject/oven
	name = "Oven"
	desc = "An old oven."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	anchored = ANCHORED
	density = 1
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT

/obj/fakeobject/sink
	name = "Sink"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	desc = "The sink doesn't appear to be connected to a waterline."
	anchored = ANCHORED
	density = 1
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT

/obj/fakeobject/console_lever
	name = "lever console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lever0"
	density = 1

/obj/fakeobject/console_randompc
	name = "computer console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "randompc"
	density = 1

/obj/fakeobject/console_radar
	name = "radar console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "radar"
	density = 1

/obj/fakeobject/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects transported by a Cargo Transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = ANCHORED

/obj/fakeobject/robot
	name = "Inactive Robot"
	desc = "The robot looks to be in good condition."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	anchored = UNANCHORED
	density = 1

/obj/fakeobject/robot/security
	name = "robot"
	desc = "A Security Robot, something seems a bit off."
	icon = 'icons/mob/critter/robotic/gunbot.dmi'
	icon_state = "gunbot"

	hugo
		name = "HUGO"

	henk
		name = "HENK"

/obj/fakeobject/apc_broken
	name = "broken APC"
	desc = "A smashed local power unit."
	icon = 'icons/obj/power.dmi'
	icon_state = "apc-b"
	anchored = ANCHORED

/obj/fakeobject/teleport_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = ANCHORED
	layer = FLOOR_EQUIP_LAYER1
	desc = "A pad used for scientific teleportation."

/obj/fakeobject/firealarm_broken
	name = "broken fire alarm"
	desc = "This fire alarm is burnt out, ironically."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "firex"
	anchored = ANCHORED

/obj/fakeobject/lighttube_broken
	name = "shattered light tube"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-broken"
	anchored = ANCHORED

/obj/fakeobject/lightbulb_broken
	name = "shattered light bulb"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-broken"
	anchored = ANCHORED

/obj/fakeobject/airmonitor_broken
	name = "broken air monitor"
	desc = "Something has broken this air monitor."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarmx"
	anchored = ANCHORED

/obj/fakeobject/shuttlethruster
	name = "propulsion unit"
	desc = "A small impulse drive that moves the shuttle."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "alt_propulsion"
	anchored = ANCHORED
	density = 1
	opacity = 0

/obj/fakeobject/shuttleweapon
	name = "weapons unit"
	desc = "A weapons system for shuttles and similar craft."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "shuttle_laser"
	anchored = ANCHORED
	density = 1
	opacity = 0

	base
		icon_state = "alt_heater"

/obj/fakeobject/pipe
	name = "rusted pipe"
	desc = "Good riddance."
	icon = 'icons/obj/atmospherics/pipes/pipe.dmi'
	icon_state = "intact"
	anchored = ANCHORED
	layer = DECAL_LAYER

	heat
		icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'

/obj/fakeobject/oldcanister
	name = "old gas canister"
	desc = "All the gas in it seems to be long gone."
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "old_oxy"
	anchored = UNANCHORED
	density = 1


	plasma
		name = "old plasma canister"
		icon_state = "old_plasma"
		desc = "This used to be the most feared piece of equipment on the station, don't you believe it?"

/obj/fakeobject/shuttleengine
	name = "engine unit"
	desc = "A generator unit that uses complex technology."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "heater"
	anchored = ANCHORED
	density = 1
	opacity = 0

/obj/fakeobject/falseladder
	name = "ladder"
	desc = "The ladder is blocked, you can't get down there."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ladder"
	anchored = ANCHORED
	density = 0

/obj/fakeobject/sealedsleeper
	name = "sleeper"
	desc = "This one appears to still be sealed. Who's in there?"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sealedsleeper"
	anchored = ANCHORED
	density = 1

// Laundry machines

/obj/fakeobject/Laundry
	name = "laundry machine"
	desc = "The door has been pried off..."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "laundry"
	anchored = ANCHORED
	density = 1
	var/image/cycle = null
	var/image/light = null

	New()
		..()
		src.UpdateOverlays(src.cycle, "door")

	drying
		desc = "Will those clothes ever be dry?"
		New()
			icon_state = "laundry-d1"
			ENSURE_IMAGE(src.cycle, src.icon, "laundry0")
			ENSURE_IMAGE(src.light, src.icon, "laundry-dlight")
			src.UpdateOverlays(src.light, "light")
			..()

	washing
		desc = "Around and around..."
		New()
			icon_state = "laundry-w1"
			ENSURE_IMAGE(src.cycle, src.icon, "laundry0")
			ENSURE_IMAGE(src.light, src.icon, "laundry-wlight")
			src.UpdateOverlays(src.light, "light")
			..()

	open
		desc = "Who left these clothes?"
		New()
			icon_state = "laundry-p"
			ENSURE_IMAGE(src.cycle, src.icon, "laundry1")
			..()

//sealab prefab fakeobjs

/obj/fakeobject/pcb
	name = "PCB constructor"
	desc = "A combination pick and place machine and wave soldering gizmo.  For making boards.  Buddy boards.   Well, it would if the interface wasn't broken."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab-general"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/palmtree
	name = "palm tree"
	desc = "This is a palm tree. Smells like plastic."
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm"
	anchored = ANCHORED
	density = 0

/obj/fakeobject/brokenportal
	name = "broken portal ring"
	desc = "This portal ring looks completely fried."
	icon = 'icons/obj/teleporter.dmi'
	icon_state = "tele_fuzz"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/lawrack
	name = "defunct AI Law Mount Rack"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behavior of connected AIs. This one looks non-functional."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	anchored = ANCHORED
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_DEFAULT

/obj/fakeobject/artifact_boh_pocket_dimension_artifact
	name = "fake artifact"
	desc = "Looking at this fills you with even more dread."
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "eldritch-1"
	anchored = ANCHORED

	New()
		src.name = pick("unnerving claw", "horrid carving", "foreboding relic")
		icon_state = "eldritch-[rand(1, 7)]"
		..()

/obj/fakeobject/crashed_arrivals
	name = "crashed human capsule missile"
	desc = "Some kind of deliver means to get humans from here to there."
	anchored = ANCHORED
	density = 0
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "arrival_missile_synd-crash"
	bound_width = 32
	bound_height = 64

// pathology

/obj/fakeobject/centrifuge
	name = "Centrifuge"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "centrifuge0"
	desc = "A large machine that can be used to separate a pathogen sample from a blood sample."
	anchored = ANCHORED
	density = 1

/obj/fakeobject/microscope
	name = "Microscope"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "microscope0"
	desc = "A device which provides a magnified view of a culture in a petri dish."

/obj/fakeobject/synthomatic
	name = "Synth-O-Matic"
	desc = "The leading technological assistant in synthesizing cures for certain pathogens."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "synth1"
	density = 1
	anchored = ANCHORED

/obj/fakeobject/autoclave
	name = "Autoclave"
	desc = "A bulky machine used for sanitizing pathogen growth equipment."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "autoclave"
	density = 1
	anchored = ANCHORED

/obj/fakeobject/incubator
	name = "Incubator"
	desc = "A machine that can automatically provide a petri dish with nutrients. It can also directly fill vials with a sample of the pathogen inside."
	icon = 'icons/obj/pathology.dmi'
	icon_state = "incubator"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/pathogen_manipulator
	name = "Pathogen Manipulator"
	icon = 'icons/obj/pathology.dmi'
	icon_state = "manipulator"
	desc = "A large, softly humming machine."
	density = 1
	anchored = ANCHORED

/obj/fakeobject/pathogen_computer
	name = "Pathology Research"
	icon = 'icons/obj/computer.dmi'
	icon_state = "pathologyb"
	desc = "A bulky machine used to control the pathogen manipulator. It looks super old and busted."

/obj/fakeobject/pathology_vendor
	name = "Path-o-Matic"
	desc = "Pathology equipment dispenser. It looks super old and busted."
	icon = 'icons/obj/vending.dmi'
	icon_state = "med-broken"

/obj/fakeobject/bigcabinets
	name = "equipment cabinet"
	desc = "Some sort of electronic equipment in a freestanding enclosure."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "bigcabinet1"
	bound_width = 32
	bound_height = 64
	anchored = 1
	density = 1

	gauges
		icon_state = "bigcabinet2"

	gaugeswithlamp
		icon_state = "bigcabinet3"

	monitors
		name = "AV Monitors"
		icon_state = "bigcabinet4"

	rackmount
		icon_state = "bigcabinet5"

	slider
		icon_state = "bigcabinet6"

	doorcontrol
		name = "access console"
		icon_state = "doorcontrol"

/obj/fakeobject/bigatmos
	name = "atmospherics equipment"
	desc = "Industrial-scale air-handling equipment."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "bigatmos1"
	bound_width = 32
	bound_height = 64
	anchored = 1
	density = 1

	bigatmos2
		icon_state = "bigatmos2"

	bigatmos3
		icon_state = "bigatmos3"

/obj/fakeobject/biggercabinets
	name = "big equipment cabinet"
	desc = "An even bigger enclosure for industrial equipment."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "displays"
	bound_width = 64
	bound_height = 64
	anchored = 1
	density = 1

	gauges
		icon_state = "gauges"

	lockdown
		icon_state = "lockdown"

	recorders
		name = "chart recorders"
		desc = "Paper chart recorders, with a little robotic pen inscribing sensor readings on each side."
		icon_state = "recorders"

/obj/fakeobject/tower
	name = "sensor mast"
	desc = "A tall pylon with various sensor and antenna mounts."
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "tower1"
	bound_width = 32
	bound_height = 32 // ignore the top part i guess
	anchored = 1
	density = 1

	tower2
		icon_state = "tower2"

	huge
		icon = 'icons/obj/large/96x160.dmi'
		icon_state = "tower"
		bound_width = 96
		bound_height = 64
