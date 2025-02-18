//////////Escape pod
/obj/machinery/vehicle/pod
	name = "Escape Pod A7-"
	icon = 'icons/obj/ship.dmi'
	icon_state = "pod"
	capacity = 4
	health = 140
	maxhealth = 140
	anchored = UNANCHORED
//////////Recon
/obj/machinery/vehicle/recon
	name = "Reconnaissance Ship 7X-"
	icon = 'icons/obj/ship.dmi'
	icon_state = "recon"
	capacity = 1
	health= 200
	maxhealth = 200
	weapon_class = 1

/obj/machinery/vehicle/recon/New()
	..()
	/////////Weapon Setup
	src.m_w_system = new /obj/item/shipcomponent/mainweapon( src )
	src.m_w_system.ship = src
	src.components += src.m_w_system
	src.m_w_system.activate()
	////////Secondary System
	src.sec_system = new /obj/item/shipcomponent/secondary_system/cloak( src )
	src.sec_system.ship = src
	src.components += src.sec_system
	myhud.update_systems()
	myhud.update_states()
	return
//////////Cargo
/obj/machinery/vehicle/cargo
	name = "Cargo Ship Q5-"
	icon = 'icons/obj/ship.dmi'
	icon_state = "cargo"
	capacity = 2
	health = 200
	maxhealth = 200

/obj/machinery/vehicle/cargo/New()
	..()
	src.sec_system = new /obj/item/shipcomponent/secondary_system/cargo( src )
	src.sec_system.ship = src
	src.components += src.sec_system
	myhud.update_systems()
	myhud.update_states()
	return

///////////UFO
/obj/machinery/vehicle/UFO
	name = "Flying Saucer"
	desc = "I Want to Believe."
	icon_state = "saucer"
	capacity = 1
	health = 400
	maxhealth = 400
	weapon_class = 1
	var/image/damaged = null
	var/antispam = 0

	New()
		..()
		name = "Flying Saucer"
		src.sec_system = new /obj/item/shipcomponent/secondary_system/UFO( src )
		src.sec_system.ship = src
		src.components += src.sec_system
		src.m_w_system = new /obj/item/shipcomponent/mainweapon/UFO( src )
		src.m_w_system.ship = src
		src.components += src.m_w_system
		src.m_w_system.activate()
		myhud.update_systems()
		myhud.update_states()
		return

	checkhealth()
		..()
		if(health/maxhealth <= 0.25)
			damaged = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "saucer_damage", "layer" = MOB_LAYER)
			overlays += damaged
		else
			overlays -=damaged


////// miniputt shuttles
/obj/machinery/vehicle/miniputt
	name = "MiniPutt-"
	desc = "A little solo vehicle for scouting and exploration work."
	icon_state = "miniputt"
	capacity = 1
	var/armor_score_multiplier = 0.5
	health = 125
	maxhealth = 125
	weapon_class = 1
	speed = 0.9
	var/image/damaged = null
	var/busted = 0

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/pod/paintjob))
			src.paint_pod(W, user)
		else return ..(W, user)

	New()
		..()
		//Cargo hold
		src.sec_system = new /obj/item/shipcomponent/secondary_system/cargo/small( src )
		src.sec_system.ship = src
		src.components += src.sec_system

		myhud.update_systems()
		myhud.update_states()
		return

/*	checkhealth()
		..()
		if(health/maxhealth <= 0.25 && !busted)
			damaged = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "miniputt_fire", "layer" = MOB_LAYER)
			overlays += damaged
			busted++
		else
			overlays -=damaged
			busted = 0
		return */

////////armed civ putt

/obj/machinery/vehicle/miniputt/pilot
	New()
		. = ..()
		src.com_system.deactivate()
		qdel(src.engine)
		qdel(src.com_system)
		src.components -= src.engine
		src.components -= src.com_system
		src.engine = null
		src.Install(new /obj/item/shipcomponent/engine/zero(src))
		src.Install(new /obj/item/shipcomponent/mainweapon/bad_mining(src))
		src.engine.activate()
		src.com_system = null
		myhud.update_systems()
		myhud.update_states()
		return

/obj/machinery/vehicle/miniputt/armed
	New()
		..()
		//Phaser
		src.m_w_system = new /obj/item/shipcomponent/mainweapon(src)
		src.m_w_system.ship = src
		src.components += src.m_w_system

		myhud.update_systems()
		myhud.update_states()
		return

////// wizard putt
/obj/machinery/vehicle/miniputt/wizard
	name = "MagicPutt-"
	desc = "The standard solo vehicle of the Space Wizard Federation."
	icon_state = "putt_wizard" //slick
	health = 200
	maxhealth = 200
	init_comms_type = /obj/item/shipcomponent/communications/wizard

	New()
		..()
		//Phaser
		src.m_w_system = new /obj/item/shipcomponent/mainweapon(src)
		src.m_w_system.ship = src
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.m_w_system
		src.components += src.lock

		myhud.update_systems()
		myhud.update_states()
		return

////////syndicate putt
/obj/machinery/vehicle/miniputt/syndiputt
	name = "SyndiPutt-"
	icon_state = "syndiputt"
	health = 250
	maxhealth = 250
	armor_score_multiplier = 0.7
	speed = 0.8
	acid_damage_multiplier = 0
	faction = list(FACTION_SYNDICATE)
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

//syndiput spawner
/obj/syndi_putt_spawner
	name = "syndiputt spawner"
	icon = 'icons/obj/ship.dmi'
	icon_state = "syndi_mini_spawn"
	New()
		..()
#ifdef UNDERWATER_MAP
		new/obj/machinery/vehicle/tank/minisub/syndisub(src.loc)
#else
		new/obj/machinery/vehicle/miniputt/syndiputt(src.loc)
#endif
		qdel(src)

////////nano putt
/obj/machinery/vehicle/miniputt/nanoputt
	name = "NanoPutt-"
	icon_state = "nanoputt"
	health = 250
	maxhealth = 250
	armor_score_multiplier = 0.7
	speed = 0.8

	security
		init_comms_type = /obj/item/shipcomponent/communications/security

////////soviet putt
/obj/machinery/vehicle/miniputt/soviputt
	name = "Strelka-"
	icon_state = "soviputt"
	desc = "A little solo vehicle for scouting and exploration work. Seems to be a Russian model."
	armor_score_multiplier = 1
	health = 225
	maxhealth = 225
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

	New()
		..()
		src.m_w_system = new /obj/item/shipcomponent/mainweapon/russian(src)
		src.m_w_system.ship = src
		src.components += src.m_w_system
		myhud.update_systems()
		myhud.update_states()
		return

////////engine putt
/obj/machinery/vehicle/miniputt/indyputt
	name = "IndyPutt-"
	icon_state = "indyputt"
	armor_score_multiplier = 0.8
	health = 275
	maxhealth = 275
	speed = 1.3
	desc = "A smaller version of the I-class industrial pod, the IndyPutt is useful for emergency repair work and small-scale mining operations."

	armed
		New()
			..()
			src.m_w_system = new /obj/item/shipcomponent/mainweapon/foamer(src)
			src.m_w_system.ship = src
			src.components += src.m_w_system
			myhud.update_systems()
			myhud.update_states()
			return

////////iridium putt
/obj/machinery/vehicle/miniputt/iridium
	name = "IridiPutt-"
	icon_state = "putt_pre"
	armor_score_multiplier = 1.7
	health = 400
	maxhealth = 400
	speed = 1
	desc = "A smaller version of the experimental Y-series of pods."

////////gold putt
/obj/machinery/vehicle/miniputt/gold
	name = "PyriPutt-"
	icon_state = "putt_gold"
	armor_score_multiplier = 0.6
	speed = 0.2
	desc = "A light, high-speed MiniPutt with a gold-plated armor installed. Who the hell has this kind of money and this little sense?"

////////strange putt
/obj/machinery/vehicle/miniputt/black
	name = "XeniPutt-"
	icon_state = "putt_black"
	armor_score_multiplier = 1.25
	health = 300
	maxhealth = 300
	desc = "????"

//pod wars ones//
/obj/machinery/vehicle/miniputt/nt_light
	name = "Pod NTL-"
	desc = "A nanotrasen-issue light pod."
	armor_score_multiplier = 1
	icon_state = "putt_raceBlue"
	health = 150
	maxhealth = 150
	speed = 0.8
	init_comms_type = /obj/item/shipcomponent/communications/security

/obj/machinery/vehicle/miniputt/nt_robust
	name = "Pod NTR-"
	desc = "A nanotrasen-issue robust pod."
	armor_score_multiplier = 1.5
	icon_state = "putt_nt_robust"
	health = 350
	maxhealth = 350
	speed = 0.6
	init_comms_type = /obj/item/shipcomponent/communications/security

/obj/machinery/vehicle/miniputt/sy_light
	name = "Pod SYL-"
	desc = "A syndicate-crafted light pod."
	armor_score_multiplier = 1
	icon_state = "putt_raceRed_alt"
	health = 150
	maxhealth = 150
	speed = 0.8
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

/obj/machinery/vehicle/miniputt/sy_robust
	name = "Pod SYR-"
	desc = "A syndicate-crafted robust pod."
	armor_score_multiplier = 1.5
	icon_state = "putt_sy_robust"
	health = 350
	maxhealth = 350
	speed = 0.6
	init_comms_type = /obj/item/shipcomponent/communications/syndicate
//pod wars end//

/*-----------------------------*/
/* MiniPutt construction stuff */
/*-----------------------------*/

/obj/item/putt/boards
	name = "MiniPutt Circuitry Kit"
	desc = "A kit containing various circuit boards for use in MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/control
	name = "MiniPutt Control System Kit"
	desc = "A kit containing control interfaces and display screens for MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/engine
	name = "MiniPutt Engine Manifold"
	desc = "A standard engine housing for MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/*-----------------------------*/
/* Minisub construction stuff */
/*-----------------------------*/

/obj/item/sub/boards
	name = "Minisub Circuitry Kit"
	desc = "A kit containing various circuit boards for use in a minisub."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/sub/control
	name = "Minisub Control System Kit"
	desc = "A kit containing control interfaces and display screens for a minisub."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/sub/engine
	name = "Minisub Engine Manifold"
	desc = "A standard engine housing for a minisub."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

ABSTRACT_TYPE(/obj/structure/vehicleframe)

/obj/structure/vehicleframe
	var/stage = 0
	var/obj/item/podarmor/armor_type = null
	var/engine_type = null
	var/control_type = null
	var/boards_type = null
	var/box_type = null
	var/metal_amt = null
	var/glass_amt = null
	var/cable_amt = null
	var/vehicle_name = null
	var/vehicle_type = null
	anchored = ANCHORED
	density = 1

/obj/item/putt/frame_box
	name = "MiniPutt Frame Kit"
	desc = "You can hear an awful lot of junk rattling around in this box."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

	attack_self(mob/user as mob)
		boutput(user, SPAN_NOTICE("You dump out the box of parts onto the floor."))
		var/obj/O = new /obj/structure/vehicleframe/puttframe( get_turf(user) )
		logTheThing(LOG_STATION, user, "builds [O] in [get_area(user)] ([log_loc(user)])")
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		qdel(src)

/obj/item/sub/frame_box
	name = "Minisub Frame Kit"
	desc = "You can hear an awful lot of junk rattling around in this box."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

	attack_self(mob/user as mob)
		boutput(user, SPAN_NOTICE("You dump out the box of parts onto the floor."))
		var/obj/O = new /obj/structure/vehicleframe/subframe( get_turf(user) )
		logTheThing(LOG_STATION, user, "builds [O] in [get_area(user)] ([log_loc(user)])")
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		qdel(src)

/obj/structure/vehicleframe/puttframe
	name = "MiniPutt Frame"
	desc = "A MiniPutt ship under construction."
	icon = 'icons/obj/ship.dmi'
	icon_state = "parts"
	engine_type = /obj/item/putt/engine
	control_type = /obj/item/putt/control
	boards_type = /obj/item/putt/boards
	box_type = /obj/item/putt/frame_box
	metal_amt = 3
	glass_amt = 3
	cable_amt = 2
	vehicle_name = "MiniPutt"

/obj/structure/vehicleframe/subframe
	name = "Minisub Frame"
	desc = "A minisub under construction."
	icon = 'icons/obj/machines/8dirvehicles.dmi'
	icon_state = "parts"
	engine_type = /obj/item/sub/engine
	control_type = /obj/item/sub/control
	boards_type = /obj/item/sub/boards
	box_type = /obj/item/sub/frame_box
	metal_amt = 3
	glass_amt = 3
	cable_amt = 2
	vehicle_name = "Minisub"

/obj/structure/vehicleframe/podframe
	name = "Pod Frame"
	desc = "A vehicle pod under construction."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "parts"
	bound_width = 64
	bound_height = 64
	engine_type = /obj/item/pod/engine
	control_type = /obj/item/pod/control
	boards_type = /obj/item/pod/boards
	box_type = /obj/item/pod/frame_box
	metal_amt = 5
	glass_amt = 5
	cable_amt = 4
	vehicle_name = "Pod"

/*-----------------------------*/
/* Deconstruction              */
/*-----------------------------*/

/obj/structure/vehicleframe/verb/deconstruct()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	boutput(usr, "Deconstructing frame...")

	var/timer = 5 * stage + 30
	while(timer > 0)
		if(do_after(usr, 1 SECONDS))
			timer -= 10
		else
			boutput(usr, SPAN_ALERT("You were interrupted!"))
			return

	boutput(usr, SPAN_NOTICE("You deconstructed the [src]."))
	var/obj/O
	if (stage == 10)
		O = new src.control_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		stage -= 2
	if (stage == 9)
		stage-- // no parts involved here, this construction step is welding the exterior
	if (stage == 8)
		O = new src.armor_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		if (istype(O,/obj/item/podarmor/armor_custom))
			O.setMaterial(src.material)
			src.removeMaterial()
		stage--
	if (stage == 7)
		O = new src.engine_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		stage--
	if (stage == 6)
		var/obj/item/sheet/steel/M = new ( get_turf(src) )
		M.amount = src.metal_amt
		M.fingerprints = src.fingerprints
		M.fingerprints_full = src.fingerprints_full
		stage--
	if (stage == 5)
		O = new src.boards_type( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprints_full = src.fingerprints_full
		stage--
	if (stage == 4)
		var/obj/item/cable_coil/cut/C = new ( get_turf(src) )
		C.amount = src.cable_amt
		C.fingerprints = src.fingerprints
		C.fingerprints_full = src.fingerprints_full
		// all other steps were tool applications, no more parts to create

	O = new src.box_type( get_turf(src) )
	logTheThing(LOG_STATION, usr, "deconstructs [src] in [get_area(usr)] ([log_loc(usr)])")
	O.fingerprints = src.fingerprints
	O.fingerprints_full = src.fingerprints_full
	qdel(src)

/*-----------------------------*/
/* Construction                */
/*-----------------------------*/

/obj/structure/vehicleframe/attackby(obj/item/W, mob/living/user)
	switch(stage)
		if(0)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the frame...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You wrench some of the frame parts together.")
				src.overlays += image(src.icon, "[pick("frame1", "frame2")]")
				stage = 1
			else
				boutput(user, "If only there was some way to secure all this junk together! You should get a wrench.")

		if(1)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the rest of the frame...")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You finish wrenching the frame parts together.")
				src.overlays -= image(src.icon, "frame1")
				src.overlays -= image(src.icon, "frame2")
				icon_state = "frame"
				stage = 2
			else
				boutput(user, "You should probably finish putting these parts together. A wrench would do the trick!")

		if(2)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the joints of the frame...")
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You weld the joints of the frame together.")
				stage = 3
			else
				boutput(user, "Even with the bolts secured, the joints of this frame still feel pretty wobbly. Welding it will make it nice and sturdy.")

		if(3)
			var/obj/item/cable_coil/C = W
			if(istype(C))
				if(C.amount < src.cable_amt)
					boutput(user, SPAN_NOTICE("You need at least [src.cable_amt] lengths of cable."))
					return
				boutput(user, "You begin to install the wiring...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS) || !C.use(src.cable_amt))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You add power cables to the MiniPutt frame.")
				src.overlays += image(src.icon, "wires")
				stage = 4
			else
				boutput(user, "You're not gonna get very far without power cables. You should get at least [src.cable_amt] lengths of it.")

		if(4)
			if(istype(W, src.boards_type))
				boutput(user, "You begin to install the circuit boards...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You install the internal circuitry parts.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image(src.icon, "circuits")
				stage = 5
			else
				boutput(user, "Maybe those wires should be connecting something together. Some kind of circuitry, perhaps.")

		if(5)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (S.material && S.material.getMaterialFlags() & MATERIAL_METAL)
					if( S.amount < src.metal_amt)
						boutput(user, SPAN_ALERT("You need at least [src.metal_amt] metal sheets to make the internal plating."))
						return
					boutput(user, "You begin to install the internal plating...")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if (!do_after(user, 3 SECONDS) || !S.change_stack_amount(-src.metal_amt))
						boutput(user, SPAN_ALERT("You were interrupted!"))
						return
					boutput(user, "You construct internal covers over the circuitry systems.")
					src.overlays += image(src.icon, "covers")
					stage = 6
				else
					boutput(user, SPAN_ALERT("These sheets aren't the right kind of material. You need metal!"))
			else
				boutput(user, "You shouldn't just leave all those circuits exposed! That's dangerous! You'll need [src.metal_amt] sheets of metal to cover it all up.")

		if(6)
			if(istype(W, src.engine_type))
				boutput(user, "You begin to install the engine...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You install the engine.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image(src.icon, "thrust")
				stage = 7
			else
				boutput(user, "Having an engine might be nice.")

		if(7)
			if(istype(W, /obj/item/podarmor))
				var/obj/item/podarmor/armor = W
				if(!armor.vehicle_types["[src.type]"])
					boutput(user, "That type of armor is not compatible with this frame.")
					return
				boutput(user, "You begin to install the [W]...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You loosely attach the light armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image(src.icon, armor.overlay_state)
				stage = 8
				armor_type = armor.type
				src.vehicle_type = armor.vehicle_types["[src.type]"]
				if(istype(W, /obj/item/podarmor/armor_custom))
					src.setMaterial(W.material)
			else
				boutput(user, "You don't think you're going anywhere without a skin, do you? Get some armor!")

		if(8)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the exterior...")
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You weld the seams of the outer skin to make it air-tight.")
				stage = 9
			else
				boutput(user, "The outer skin still feels pretty loose. Welding it together would make it nice and airtight.")

		if(9)
			if(istype(W, src.control_type))
				boutput(user, "You begin to install the control system...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "You install the control system.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image(src.icon,"control")
				stage = 10
			else
				boutput(user, "It's not gonna get very far without a control system!")

		if(10)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (!S.material)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return
				if (!(S.material.getMaterialFlags() & MATERIAL_CRYSTAL) || !S.reinforcement)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return

				if (S.amount < src.glass_amt)
					boutput(user, SPAN_ALERT("You need at least [src.glass_amt] reinforced glass sheets to make the cockpit window and outer indicator surfaces."))
					return
				boutput(user, "You begin to install the glass...")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				if (!do_after(user, 3 SECONDS) || !S.change_stack_amount(-src.glass_amt))
					boutput(user, SPAN_ALERT("You were interrupted!"))
					return
				boutput(user, "With the cockpit and exterior indicators secured, the control system automatically starts up.")

				var/obj/machinery/vehicle/V = new vehicle_type( src.loc )
				if (src.armor_type == /obj/item/podarmor/armor_custom)
					V.name = src.vehicle_name
					V.setMaterial(src.material)
				logTheThing(LOG_STATION, user, "finishes building a [V] in [get_area(user)] ([log_loc(user)])")
				qdel(src)

			else
				boutput(user, "You weren't thinking of heading out without a reinforced cockpit, were you? Put some reinforced glass on it! Just [src.glass_amt] sheets will do.")

/*-----------------------------*/
/*                             */
/*-----------------------------*/

///////////cogpod test
/obj/machinery/vehicle/pod_civ
	name = "Standard Pod Q5-"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "pod_civ"
	capacity = 2
	weapon_class = 1
	health = 75
	maxhealth = 75

/obj/machinery/vehicle/pod_civ/New()
	..()
	src.sec_system = new /obj/item/shipcomponent/secondary_system/cargo( src )
	src.sec_system.ship = src
	src.components += src.sec_system
	qdel(src.lights)
	src.lights = new /obj/item/shipcomponent/pod_lights/pod_2x2
	src.lights.ship = src
	src.components += src.lights
	src.pixel_x = -16
	src.pixel_y = -16
	myhud.update_systems()
	myhud.update_states()
	return

/obj/machinery/vehicle/pod_civ/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	// check oversize bounds
	var/turf/new_loc = get_turf(NewLoc)
	if (flying == WEST && new_loc.x == 1)
		return ..(NewLoc, Dir, step_x, step_y)
	if (flying == SOUTH && new_loc.y == 1)
		return ..(NewLoc, Dir, step_x, step_y)

	var/turf/t1 = get_step(NewLoc, Dir)
	var/turf/t2
	var/turf/t3
	switch(Dir)
		if(NORTH, SOUTH)
			t2 = get_step(t1, EAST)
			t3 = get_step(t1, WEST)
		if(EAST, WEST)
			t2 = get_step(t1, NORTH)
			t3 = get_step(t1, SOUTH)

	if (!t1 || !t2 || !t3 || !t1.Cross(src) || !t2.Cross(src) || !t3.Cross(src))
		if (t1) Bump(t1)
		if (t2) Bump(t2)
		if (t3) Bump(t3)
		return 0

	// set return value to default
	.=..(NewLoc,Dir,step_x,step_y)


///////////Also a Test
//README! - Since we use 32x32 tiles normally and since we can't have a view of "half" tiles in byond (think view = 7.5)
//Using a view centered on a 64x64 Ship will always result in one more row of tiles being visible to the right / top than to the left / bottom
//since the "center" of the ship is always between 4 tiles - and we can't center the map on "half-tiles".
//Alternatively you can just leave the view centered on the bottom left tile of the ship which is not centered but might look better since
//you have an equal amount of tiles in every direction. But this would also mean that the center of the ship isnt the center of the screen but
//rather the lower left corner of it. If you prefer this remove all the client.pixel_x / client.pixel_y stuff below.
//Nevermind that above ; it's already commented out.

/obj/machinery/vehicle/pod_smooth
	name = "Pod C-"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "pod_civ"
	uses_weapon_overlays = 1
	var/armor_score_multiplier = 0.2
	capacity = 2
	weapon_class = 1
	health = 250
	maxhealth = 250
	bound_width = 64
	bound_height = 64
	view_offset_x = 16
	view_offset_y = 16
	speedmod = 0.9
	//luminosity = 5 // will help with space exploration
	var/maxboom = 0

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.maxhealth = max(75, src.material.getProperty("density") * 40)
			src.health = maxhealth
			src.speed = 1 - (src.material.getProperty("electrical") - 5) / 15
		return

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/pod/paintjob))
			src.paint_pod(W, user)
		else return ..(W, user)

	New()
		..()
		src.sec_system = new /obj/item/shipcomponent/secondary_system/cargo( src )
		src.sec_system.ship = src
		src.components += src.sec_system
		qdel(src.lights)
		src.lights = new /obj/item/shipcomponent/pod_lights/pod_2x2
		src.lights.ship = src
		src.components += src.lights
		myhud.update_systems()
		myhud.update_states()
		return

	AmmoPerShot()
		return 2

	ShootProjectiles(var/mob/user, var/datum/projectile/PROJ, var/shoot_dir)
		var/H = (shoot_dir & 3) ? 1 : 0
		var/V = (shoot_dir & 12) ? 1 : 0

		//fucK ME
		if (shoot_dir & (shoot_dir-1))
			if (shoot_dir == SOUTHEAST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), SOUTHEAST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
				var/turf/E = get_step(get_turf(src), EAST)
				P = shoot_projectile_DIR(get_step(E, EAST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
			if (shoot_dir == SOUTHWEST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), WEST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
				P = shoot_projectile_DIR(get_step(get_turf(src), SOUTH), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user

			if (shoot_dir == NORTHEAST)
				var/turf/NE = get_step(get_turf(src), NORTHEAST)

				var/obj/projectile/P = shoot_projectile_DIR(get_step(NE, NORTH), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
				P = shoot_projectile_DIR(get_step(NE, EAST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user

			if (shoot_dir == NORTHWEST)
				var/turf/N = get_step(get_turf(src), NORTH)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(N, WEST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.mob_shooter = user
					P.shooter = src
				P = shoot_projectile_DIR(get_step(N, NORTH), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
		else
			if (shoot_dir == SOUTH || shoot_dir == WEST)
				var/obj/projectile/P = shoot_projectile_DIR(src, PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * -5
					P.pixel_y = V * -5
			if (shoot_dir == SOUTH || shoot_dir == EAST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), EAST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * 5
					P.pixel_y = V * -5
			if (shoot_dir == NORTH || shoot_dir == WEST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), NORTH), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * -5
					P.pixel_y = V * 5
			if (shoot_dir == NORTH || shoot_dir == EAST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), NORTHEAST), PROJ, shoot_dir, remote_sound_source = src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * 5
					P.pixel_y = V * 5
	ex_act(severity)
		if(!maxboom)
			SPAWN(0.1 SECONDS)
				..()
				maxboom = 0
		maxboom = max(severity, maxboom)



/obj/machinery/vehicle/pod_smooth/light // standard civilian pods
	name = "Pod C-"
	desc = "A civilian-class vehicle pod, often used for exploration and trading."
	icon_state = "pod_civ"
	health = 250
	maxhealth = 250

/obj/machinery/vehicle/pod_smooth/gold // blingee
	name = "Pod G-"
	desc = "A light, high-speed vehicle pod often used by underground pod racing clubs and people with more money than sense."
	icon_state = "pod_gold"
	armor_score_multiplier = 0.4
	speed = 0.3

/obj/machinery/vehicle/pod_smooth/heavy // pods made with reinforced armor
	name = "Pod T-"
	desc = "A military-issue vehicle pod."
	armor_score_multiplier = 1
	icon_state = "pod_mil"
	health = 500
	maxhealth = 500
	speed = 0.9

	security
		init_comms_type = /obj/item/shipcomponent/communications/security

/obj/machinery/vehicle/pod_smooth/syndicate
	name = "Pod S-"
	desc = "A syndicate-issue assault pod."
	armor_score_multiplier = 1
	icon_state = "pod_synd"
	health = 500
	maxhealth = 500
	speed = 0.9
	acid_damage_multiplier = 0
	faction = list(FACTION_SYNDICATE)
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

	/*prearmed
		New()
			..()
			src.sec_system = new /obj/item/shipcomponent/pod_weapon/gun( src )
			src.sec_system.ship = src
			src.components += src.sec_system
			return*/

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
		myhud.update_systems()
		myhud.update_states()
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()
/obj/machinery/vehicle/pod_smooth/black
	name = "Pod X-"
	desc = "????"
	armor_score_multiplier = 1.5
	icon_state = "pod_black"
	health = 700
	maxhealth = 700

/obj/machinery/vehicle/pod_smooth/iridium
	name = "Pod Y-"
	desc = "It appears to be an experimental vehicle based on the Syndicate's IRIDIUM project."
	armor_score_multiplier = 1.25
	icon_state = "pod_pre"
	health = 800
	maxhealth = 800
	speed = 1.2

/obj/machinery/vehicle/pod_smooth/industrial
	name = "Pod I-"
	desc = "A slow yet sturdy industrial pod, designed for hazardous work in asteroid belts. Can accommodate up to four passengers."
	armor_score_multiplier = 1.25
	icon_state = "pod_industrial"
	health = 550
	maxhealth = 550
	speed = 1.5
	capacity = 4

/obj/machinery/vehicle/pod_smooth/industrial/nadir
	//special name, pre-equipped with drilling hardware
	New()
		..()
		name += "[pick(" (The Orca)"," (Sea Pig)"," (The Iso-Pod)")]"
		src.m_w_system = new /obj/item/shipcomponent/mainweapon/rockdrills(src)
		src.m_w_system.ship = src
		src.components += src.m_w_system
		myhud.update_systems()
		myhud.update_states()
		src.overlays += image('icons/effects/64x64.dmi', "[src.m_w_system.appearanceString]")
		return

//pod wars ones//
/obj/machinery/vehicle/pod_smooth/nt_light
	name = "Pod NTL-"
	desc = "A nanotrasen-issue light pod."
	armor_score_multiplier = 1
	icon_state = "pod_raceBlue"
	health = 250
	maxhealth = 250
	speed = 0.9
	init_comms_type = /obj/item/shipcomponent/communications

/obj/machinery/vehicle/pod_smooth/nt_robust
	name = "Pod NTR-"
	desc = "A nanotrasen-issue robust pod."
	armor_score_multiplier = 1.5
	icon_state = "pod_nt_robust"
	health = 500
	maxhealth = 500
	speed = 0.8
	init_comms_type = /obj/item/shipcomponent/communications

/obj/machinery/vehicle/pod_smooth/sy_light
	name = "Pod SYL-"
	desc = "A syndicate-crafted light pod."
	armor_score_multiplier = 1
	icon_state = "pod_raceRed"
	health = 250
	maxhealth = 250
	speed = 0.9
	init_comms_type = /obj/item/shipcomponent/communications/syndicate

/obj/machinery/vehicle/pod_smooth/sy_robust
	name = "Pod SYR-"
	desc = "A syndicate-crafted robust pod."
	armor_score_multiplier = 1.5
	icon_state = "pod_sy_robust"
	health = 500
	maxhealth = 500
	speed = 0.8
	init_comms_type = /obj/item/shipcomponent/communications/syndicate
//pod wars end//

/obj/machinery/vehicle/pod_smooth/setup_ion_trail()
	//////Ion Trail Setup
	src.ion_trail = new /datum/effects/system/ion_trail_follow()
	src.ion_trail.set_up(src, 16)

/*
/obj/machinery/vehicle/pod_smooth/exit_ship()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	if (usr.loc != src)
		return
	src.passengers--
	usr.set_loc(src.loc)
	usr.remove_shipcrewmember_powers(src.weapon_class)
	if (usr.client)
		usr.client.perspective = MOB_PERSPECTIVE
		//usr.client.pixel_x = 0
		//usr.client.pixel_y = 0
	if(src.pilot == usr)
		src.pilot = null
	if(passengers)
		find_pilot()
	else
		src.ion_trail.stop()
*/
// why are we duplicating this??
/*
/obj/machinery/vehicle/pod_smooth/board()
	set src in oview(1)
	set category = "Local"

	//if(boarding) // stop multiple inputs from ruining shit
		//boutput(usr, SPAN_ALERT("The access door is already in use!"))
		//return

	if(locked)
		boutput(usr, SPAN_ALERT("[src] is locked!"))
		return

	if(panel_status)
		boutput(usr, SPAN_ALERT("Close the maintenance panel first!"))
		return

	if(!isliving(usr))
		return

	if (usr.stat)
		return

	if (usr in src) // fuck's sake
		boutput(usr, SPAN_ALERT("You're already inside [src]!"))
		return

	boarding = 1

	passengers = 0 // reset this shit

	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		passengers++
		if(M.stat || !M.client)
			eject(M)
			boutput(usr, SPAN_ALERT("You pull [M] out of [src]."))
		else if(!isliving(M))
			eject(M)
			boutput(usr, SPAN_ALERT("You scrape [M] out of [src]."))


	for(var/obj/decal/cleanable/O in src)
		boutput(usr, SPAN_ALERT("You [pick(")scrape","scrub","clean")] [O] out of [src].")
		sleep(0.1 SECONDS)
		var/floor = get_turf(src)
		O.set_loc(floor)

	if (src.capacity <= src.passengers )
		boutput(usr, "There is no more room!")
		return
	if (usr.client)
		myhud.add_client(usr.client)
	usr.make_shipcrewmember(src.weapon_class)
	for(var/obj/item/shipcomponent/S in src.components)
		S.mob_activate(usr)
	sleep(0.5 SECONDS) //Make sure the verb gets added

	src.passengers++
	var/mob/M = usr

	M.set_loc(src, 16, 16)
	if(!src.pilot)
		src.pilot = M
		src.ion_trail.start()

	SPAWN(0.5 SECONDS)
		boarding = 0*/



/*/obj/machinery/vehicle/pod_smooth/handle_occupants_shipdeath()
	for(var/mob/M in src)
		boutput(M, SPAN_ALERT("<b>You are ejected from [src]!</b>"))
		src.eject(M)
		var/atom/target = get_edge_target_turf(M,pick(alldirs))
		SPAWN(0)
		M.throw_at(target, 10, 2)*/

//Returns the correct tile to spawn projectiles on for either side of the ship, given the current direction.
/obj/machinery/vehicle/pod_smooth/proc/getGunSlotTile(var/leftGun = 1)
	switch(dir)
		if(NORTH)
			if(leftGun) return get_step(src.loc, NORTH)
			else return get_step(get_step(src.loc, NORTH), EAST)
		if(EAST)
			if(leftGun) return get_step(get_step(src.loc, NORTH), EAST)
			else return get_step(src.loc, EAST)
		if(SOUTH)
			if(leftGun) return get_step(src.loc, EAST)
			else return src.loc
		if(WEST)
			if(leftGun) return src.loc
			else return get_step(src.loc, NORTH)


// ----------- Pod Construction Junk ------ //

/obj/item/pod/boards
	name = "Pod Circuitry Kit"
	desc = "A kit containing various circuit boards for use in  vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/control
	name = "Control System Kit"
	desc = "A kit containing control interfaces and display screens for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/engine
	name = "Engine Manifold"
	desc = "A standard engine housing for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

ABSTRACT_TYPE(/obj/item/podarmor)
/obj/item/podarmor
	var/overlay_state
	var/list/vehicle_types
	/// multiplicative ship speed modifier from weight of this pod armor
	var/speedmod = 1

/obj/item/podarmor/armor_light
	name = "Light Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin1"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/light,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/civilian,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/light,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/civilian)

/obj/item/podarmor/armor_custom
	name = "Pod Armor"
	desc = "Plating for vehicle pods made from a custom compound."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin1"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/light,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/civilian,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/light,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/civilian)

/obj/item/podarmor/armor_heavy
	name = "Heavy Pod Armor"
	desc = "Reinforced exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin2"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nanoputt,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/heavy,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/heavy,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nanoputt,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/heavy,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/heavy)

/obj/item/podarmor/nt_light
	name = "Light NT Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "pod_skinB"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nt_light,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/nt_light,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nt_light,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/nt_light)

/obj/item/podarmor/nt_robust
	name = "Robust NT Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "pod_skinBF"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nt_robust,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/nt_robust,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/nt_robust,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/nt_robust)

/obj/item/podarmor/sy_light
	name = "Light Syndicate Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "pod_skinR"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/sy_light,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/sy_light,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/sy_light,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/sy_light)

/obj/item/podarmor/sy_robust
	name = "Robust Syndicate Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "pod_skinRF"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/sy_robust,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/sy_robust,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/sy_robust,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/sy_robust)


/obj/item/podarmor/armor_black
	name = "Strange Pod Armor"
	desc = "The box is stamped with the Nanotrasen symbol and a lengthy list of classified warnings. Neat."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin3"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/black,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/black,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/black,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/black,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/black,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/black)

/obj/item/podarmor/armor_red
	name = "Syndicate Pod Armor"
	desc = "The box is stamped with the logos of various Syndicate affiliated corporations."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin2"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/syndiputt,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/syndicate,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/syndisub,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/syndiputt,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/syndicate,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/syndisub)

/obj/item/podarmor/armor_industrial
	name = "Industrial Pod Armor"
	desc = "A kit of bulky industrial armor plates for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin3"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/indyputt,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/industrial,
		"/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/industrial,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/indyputt,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/industrial,
		"/obj/structure/preassembeled_vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/industrial)

/obj/item/podarmor/armor_gold
	name = "Gold Pod Armor"
	desc = "It's really only gold-plated."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	overlay_state = "skin4"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/gold,
		"/obj/structure/vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/gold,
		"/obj/structure/preassembeled_vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/gold,
		"/obj/structure/preassembeled_vehicleframe/podframe" = /obj/machinery/vehicle/pod_smooth/gold)

/obj/item/pod/frame_box
	name = "Pod Frame Kit"
	desc = "You can hear an awful lot of junk rattling around in this box."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

	attack_self(mob/user as mob)
		// lets assume everything is ok so we can stop checking at the first sign of trouble
		var/canbuild = 1

		// buffers whee
		var/list/checkturfs = block(get_turf(user),locate(user.x+1,user.y+1,user.z))
		var/turf/T
		var/atom/A

		// check the 2x2 square that the finished pod will occupy
		for(T in checkturfs)
			if (istype(T, /turf/space))
				continue
			if (!T.allows_vehicles || T.density)
				canbuild = 0
				boutput(user, SPAN_ALERT("You can't build a pod here! It'd get stuck."))
				break
			for (A in T)
				if (A == user)
					continue
				if (A.density)
					canbuild = 0
					boutput(user, SPAN_ALERT("You can't build a pod here! [A] is in the way."))
					goto out // break isn't enough since this loop is nested
		out:

		if (canbuild)
			boutput(user, SPAN_NOTICE("You dump out the box of parts onto the floor."))
			var/obj/O = new /obj/structure/vehicleframe/podframe( get_turf(user) )
			logTheThing(LOG_STATION, user, "builds [O] in [get_area(user)] ([log_loc(user)])")
			O.fingerprints = src.fingerprints
			O.fingerprints_full = src.fingerprints_full
			qdel(src)

/obj/item/pod/paintjob
	name = "Pod Paint Job Kit"
	desc = "A kit containing everything you need to bling out your pod."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	var/pod_skin = "pod_skin1"

/obj/item/pod/paintjob/tronthing
	name = "Pod Paint Job Kit (HighTech)"
	pod_skin = "pod_skinAc"

/obj/item/pod/paintjob/flames
	name = "Pod Paint Job Kit (Flames)"
	pod_skin = "pod_skinW"

/obj/item/pod/paintjob/flames_p
	name = "Pod Paint Job Kit (Purple Flames)"
	pod_skin = "pod_skinPF"

/obj/item/pod/paintjob/flames_b
	name = "Pod Paint Job Kit (Blue Flames)"
	pod_skin = "pod_skinBF"

/obj/item/pod/paintjob/stripe_r
	name = "Pod Paint Job Kit (Red Racing Stripes)"
	pod_skin = "pod_skinR"

/obj/item/pod/paintjob/stripe_b
	name = "Pod Paint Job Kit (Blue Racing Stripes)"
	pod_skin = "pod_skinB"

/obj/item/pod/paintjob/stripe_g
	name = "Pod Paint Job Kit (Green Racing Stripes)"
	pod_skin = "pod_skinG"

/obj/item/pod/paintjob/rainbow
	name = "Pod Paint Job Kit (Rainbow)"
	pod_skin = "pod_skinFAB"

/obj/item/pod/paintjob/owl
	name = "Pod Paint Job Kit (Owl)"
	pod_skin = "pod_skinOWL"

///// Shitty escape pod that flies by itself for a bit then explodes.
/obj/machinery/vehicle/escape_pod
	name = "Escape Pod E-"
	desc = "A small one-person pod that scans for the emergency shuttle's engine signature and warps to it mid-transit. These are notorious for lacking any safety checks. <br>It looks sort of rickety..."
	icon_state = "escape"
	capacity = 1
	health = 60
	maxhealth = 60
	weapon_class = 1
	speed = 5
	var/fail_type = 0
	var/launched = 0
	var/steps_moved = 0
	var/failing = 0
	var/succeeding = 0
	var/did_warp = 0

	New()
		. = ..()
		src.components -= src.engine
		qdel(src.engine)
		src.engine = new /obj/item/shipcomponent/engine/escape(src)
		src.components += src.engine
		src.engine.ship = src
		src.engine.activate()

	finish_board_pod(var/mob/boarder)
		..()
		if (!src.pilot)
			return //if they were stopped from entering by other parts of the board proc from ..()
		SPAWN(0)
			src.escape()

	#define SHUTTLE_PERCENT_FROM_STATION emergency_shuttle.timeleft() / SHUTTLETRANSITTIME // both in seconds
	proc/escape()
		if(!launched)
			launched = 1
			anchored = UNANCHORED
			var/opened_door = 0
			var/turf_in_front = get_step(src,src.dir)
			for(var/obj/machinery/door/poddoor/D in turf_in_front)
				D.open()
				opened_door = 1
			if(opened_door) sleep(2 SECONDS) //make sure it's fully open
			playsound(src.loc, 'sound/effects/bamf.ogg', 100, 0)
			sleep(0.5 SECONDS)
			playsound(src.loc, 'sound/effects/flameswoosh.ogg', 100, 0)
			while(!failing)
				var/loc = src.loc
				step(src,src.dir)
				if(src.loc == loc) //we hit something
					explosion(src, src.loc, 1, 1, 2, 3)
					break
				steps_moved++
				if(prob((steps_moved-7) * 4 * (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT ? (1 - SHUTTLE_PERCENT_FROM_STATION) : 1)) && !succeeding) // failure becomes more likely as the shuttle gets farther
					fail()
				if (prob((steps_moved-7) * 6 * SHUTTLE_PERCENT_FROM_STATION))
					succeed()
				sleep(0.4 SECONDS)
	#undef SHUTTLE_PERCENT_FROM_STATION

	proc/succeed()
		if (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT & !did_warp) //lol sorry hardcoded a define thing
			succeeding = 1
			did_warp = 1

			playsound(src.loc, "warp", 50, 1, 0.1, 0.7)

			var/obj/portal/P = new /obj/portal
			P.set_loc(get_turf(src))
			var/turf/T = pick_landmark(LANDMARK_ESCAPE_POD_SUCCESS)
			src.set_dir(map_settings ? map_settings.escape_dir : SOUTH)
			P.set_target(T)
			src.set_loc(T)
			logTheThing(LOG_STATION, src, "creates an escape portal at [log_loc(src)].")


	proc/fail()
		failing = 1
		if(!fail_type) fail_type = rand(1,8)
		switch(fail_type)
			if(1) //dies
				shipdeath()
			if(2) //fuel tank explodes??
				pilot.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("The fuel tank of your escape pod explodes!"))
				explosion(src, src.loc, 2, 3, 4, 6)
			if(3) //falls apart
				pilot.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("Your escape pod is falling apart around you!"))
				while(src)
					step(src,src.dir)
					if(prob(50))
						make_cleanable(/obj/decal/cleanable/robot_debris/gib, src.loc)
					if(prob(20) && pilot)
						boutput(pilot, SPAN_ALERT("You fall out of the rapidly disintegrating escape pod!"))
						src.leave_pod(pilot)
					if(prob(10)) shipdeath()
					sleep(0.4 SECONDS)
			if(4) //flies off course
				pilot.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				boutput(pilot, SPAN_ALERT("Your escape pod is veering out of control!"))
				while(src)
					if(prob(10)) src.set_dir(turn(dir,pick(90,-90)))
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					sleep(0.4 SECONDS)
			if(5)
				boutput(pilot, SPAN_ALERT("Your escape pod sputters to a halt!"))
			if(6)
				boutput(pilot, SPAN_ALERT("Your escape pod explosively decompresses, hurling you into space!"))
				pilot.playsound_local_not_inworld('sound/effects/Explosion2.ogg', vol=100)
				if(ishuman(pilot))
					var/mob/living/carbon/human/H = pilot
					if(prob(40))
						var/limb = pick(list("l_arm","r_arm","l_leg","r_leg"))
						SPAWN(rand(0,5))
							H.sever_limb(limb)
				src.leave_pod(pilot)
				src.icon_state = "escape_nowindow"
				while(src)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					else if(prob(2)) shipdeath()
					sleep(0.4 SECONDS)

			if(7)
				boutput(pilot, SPAN_ALERT("Your escape pod begins to accelerate!"))
				var/speed = 5
				while(speed)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(speed > 1 && prob(10)) speed--
					if(speed == 1 && prob(5))
						boutput(pilot, SPAN_ALERT("Your escape pod is moving so fast that it tears itself apart!"))
						shipdeath()
					else if(prob(10/speed))
						boutput(pilot, SPAN_ALERT("Your escape pod is [pick("vibrating","shuddering","shaking")] [pick("alarmingly","worryingly","violently","terribly","scarily","weirdly","distressingly")]!"))
					sleep(speed)
			if(8)
				boutput(pilot, SPAN_ALERT("Your escape pod starts to fly around in circles [pick("awkwardly","embarrassingly","sadly","pathetically","shamefully","ridiculously")]!"))
				pilot?.playsound_local_not_inworld('sound/machines/engine_alert1.ogg', vol=100)
				var/spin_dir = pick(90,-90)
				while(src)
					src.set_dir(turn(dir,spin_dir))
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(prob(2)) //we don't want to do this forever so let's explode
						shipdeath()
					sleep(0.4 SECONDS)
