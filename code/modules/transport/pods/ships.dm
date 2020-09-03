//////////Escape pod
/obj/machinery/vehicle/pod
	name = "Escape Pod A7-"
	icon = 'icons/obj/ship.dmi'
	icon_state = "pod"
	capacity = 4
	health = 70
	maxhealth = 70
	anchored = 0
//////////Recon
/obj/machinery/vehicle/recon
	name = "Reconaissance Ship 7X-"
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
	health = 100
	maxhealth = 100

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
	health = 75
	maxhealth = 75
	weapon_class = 1
	speed = 0.8
	var/image/damaged = null
	var/busted = 0

	attackby(obj/item/W as obj, mob/living/user as mob)
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

/obj/machinery/vehicle/miniputt/armed
	New()
		..()
		//Phaser
		src.m_w_system = new /obj/item/shipcomponent/mainweapon
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

	New()
		..()
		//Phaser
		src.m_w_system = new /obj/item/shipcomponent/mainweapon
		src.m_w_system.ship = src
		src.com_system = new /obj/item/shipcomponent/communications/wizard(src)
		src.com_system.ship = src
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.m_w_system
		src.components += src.com_system
		src.components += src.lock

		myhud.update_systems()
		myhud.update_states()
		return

////////syndicate putt
/obj/machinery/vehicle/miniputt/syndiputt
	name = "SyndiPutt-"
	icon_state = "syndiputt"
	health = 125
	maxhealth = 125
	armor_score_multiplier = 0.7
	speed = 0.8

	New()
		..()
		src.com_system = new /obj/item/shipcomponent/communications/syndicate(src)
		src.com_system.ship = src
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.components += src.com_system
		src.components += src.lock
		myhud.update_systems()
		myhud.update_states()
		return

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
	health = 125
	maxhealth = 125
	armor_score_multiplier = 0.7
	speed = 0.9

////////soviet putt
/obj/machinery/vehicle/miniputt/soviputt
	name = "Strelka-"
	icon_state = "soviputt"
	desc = "A little solo vehicle for scouting and exploration work. Seems to be a Russian model."
	armor_score_multiplier = 1.0
	health = 150
	maxhealth = 150

	New()
		..()
		src.m_w_system = new /obj/item/shipcomponent/mainweapon/russian(src)
		src.m_w_system.ship = src
		src.com_system = new /obj/item/shipcomponent/communications/syndicate(src)
		src.com_system.ship = src
		src.components += src.m_w_system
		src.components += src.com_system
		myhud.update_systems()
		myhud.update_states()
		return

////////engine putt
/obj/machinery/vehicle/miniputt/indyputt
	name = "IndyPutt-"
	icon_state = "indyputt"
	armor_score_multiplier = 0.8
	health = 200
	maxhealth = 200
	speed = 1.4
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
	health = 200
	maxhealth = 200
	speed = 1
	desc = "A smaller version of the experimental Y-series of pods."

////////gold putt
/obj/machinery/vehicle/miniputt/gold
	name = "PyriPutt-"
	icon_state = "putt_gold"
	health = 200
	maxhealth = 200
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

/* miniputts can just use the standard pod armor idgaf
/obj/item/putt/armor_light
	name = "Light Pod Armor"
	desc = "Standard exterior plating for MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_custom
	name = "MiniPutt Armor"
	desc = "Plating for vehicle pods made from a custom compound."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_heavy
	name = "Heavy MiniPutt Armor"
	desc = "Reinforced exterior plating for MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_black
	name = "Strange MiniPutt Armor"
	desc = "The box is stamped with the Nanotrasen symbol and a lengthy list of classified warnings. Neat."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_red
	name = "Syndicate MiniPutt Armor"
	desc = "The box is stamped with the logos of various Syndicate affiliated corporations."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_industrial
	name = "Industrial MiniPutt Armor"
	desc = "A kit of bulky industrial armor plates for MiniPutt ships."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/putt/armor_gold
	name = "Gold MiniPutt Armor"
	desc = "It's really only gold-plated."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
*/
/obj/item/putt/frame_box
	name = "MiniPutt Frame Kit"
	desc = "You can hear an awful lot of junk rattling around in this box."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

	attack_self(mob/user as mob)
		boutput(user, "<span class='notice'>You dump out the box of parts onto the floor.</span>")
		var/obj/O = new /obj/structure/puttframe( get_turf(user) )
		logTheThing("station", user, null, "builds [O] in [get_area(user)] ([showCoords(user.x, user.y, user.z)])")
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		qdel(src)

/obj/structure/puttframe
	name = "MiniPutt Frame"
	desc = "A MiniPutt ship under construction."
	icon = 'icons/obj/ship.dmi'
	icon_state = "putt_parts"
	anchored = 1
	density = 1
	var/stage = 0
	var/armor_type = 1

/*-----------------------------*/
/* Deconstruction              */
/*-----------------------------*/

/obj/structure/puttframe/verb/deconstruct()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	boutput(usr, "Deconstructing frame...")

	var/timer = 5 * stage + 30
	while(timer > 0)
		if(do_after(usr, 10))
			timer -= 10
		else
			boutput(usr, "<span class='alert'>You were interrupted!</span>")
			return

	boutput(usr, "<span class='notice'>You deconstructed the MiniPutt frame.</span>")
	var/obj/O
	if (stage == 10)
		O = new /obj/item/putt/control( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage -= 2
	if (stage == 9)
		stage-- // no parts involved here, this construction step is welding the exterior
	if (stage == 8)
		if (armor_type == 1)
			O = new /obj/item/pod/armor_light( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 2)
			O = new /obj/item/pod/armor_heavy( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 3)
			O = new /obj/item/pod/armor_black( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 4)
			O = new /obj/item/pod/armor_red( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 5)
			O = new /obj/item/pod/armor_industrial( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 6)
			O = new /obj/item/pod/armor_gold( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 7)
			O = new /obj/item/pod/armor_custom( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
			O.setMaterial(src.material)
			src.removeMaterial()
		stage--
	if (stage == 7)
		O = new /obj/item/putt/engine( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 6)
		var/obj/item/sheet/steel/M = new ( get_turf(src) )
		M.amount = 3
		M.fingerprints = src.fingerprints
		M.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 5)
		O = new /obj/item/putt/boards( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 4)
		var/obj/item/cable_coil/cut/C = new ( get_turf(src) )
		C.amount = 2
		C.fingerprints = src.fingerprints
		C.fingerprintshidden = src.fingerprintshidden
		// all other steps were tool applications, no more parts to create

	O = new /obj/item/putt/frame_box( get_turf(src) )
	logTheThing("station", usr, null, "deconstructs [src] in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
	O.fingerprints = src.fingerprints
	O.fingerprintshidden = src.fingerprintshidden
	qdel(src)

/*-----------------------------*/
/* Construction                */
/*-----------------------------*/

/obj/structure/puttframe/attackby(obj/item/W as obj, mob/living/user as mob)
	switch(stage)
		if(0)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the frame...")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You wrench some of the frame parts together.")
				src.overlays += image('icons/obj/ship.dmi', "[pick("putt_frame1", "putt_frame2")]")
				stage = 1
			else
				boutput(user, "If only there was some way to secure all this junk together! You should get a wrench.")

		if(1)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the rest of the frame...")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You finish wrenching the frame parts together.")
				src.overlays -= image('icons/obj/ship.dmi', "putt_frame1")
				src.overlays -= image('icons/obj/ship.dmi', "putt_frame2")
				icon_state = "putt_frame"
				stage = 2
			else
				boutput(user, "You should probably finish putting these parts together. A wrench would do the trick!")

		if(2)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the joints of the frame...")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You weld the joints of the frame together.")
				stage = 3
			else
				boutput(user, "Even with the bolts secured, the joints of this frame still feel pretty wobbly. Welding it will make it nice and sturdy.")

		if(3)
			if(istype(W, /obj/item/cable_coil))
				if(W.amount < 2)
					boutput(user, "<span class='notice'>You need at least two lengths of cable.</span>")
					return
				boutput(user, "You begin to install the wiring...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				W.amount -= 2
				if(!W.amount)
					user.u_equip(W)
					qdel(W)
				boutput(user, "You add power cables to the MiniPutt frame.")
				src.overlays += image('icons/obj/ship.dmi', "putt_wires")
				stage = 4
			else
				boutput(user, "You're not gonna get very far without power cables. You should get at least two lengths of it.")

		if(4)
			if(istype(W, /obj/item/putt/boards))
				boutput(user, "You begin to install the circuit boards...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the internal circuitry parts.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "putt_circuits")
				stage = 5
			else
				boutput(user, "Maybe those wires should be connecting something together. Some kind of circuitry, perhaps.")

		if(5)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (S.material && S.material.material_flags & MATERIAL_METAL)
					if( S.amount < 3)
						boutput(usr, text("<span class='alert'>You need at least three metal sheets to make internal plating for this pod.</span>"))
						return
					boutput(user, "You begin to install the internal plating...")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					if (!do_after(user, 30))
						boutput(user, "<span class='alert'>You were interrupted!</span>")
						return
					S.amount -= 3
					if(S.amount < 1)
						user.u_equip(S)
						qdel(S)
					boutput(user, "You construct internal covers over the circuitry systems.")
					src.overlays += image('icons/obj/ship.dmi', "putt_covers")
					stage = 6
				else
					boutput(user, "<span class='alert'>These sheets aren't the right kind of material. You need metal!</span>")
			else
				boutput(user, "You shouldn't just leave all those circuits exposed! That's dangerous! You'll need three sheets of metal to cover it all up.")

		if(6)
			if(istype(W, /obj/item/putt/engine))
				boutput(user, "You begin to install the engine...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the engine.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "putt_engine")
				stage = 7
			else
				boutput(user, "Having an engine might be nice.")

		if(7)
			if(istype(W, /obj/item/pod/armor_light))
				boutput(user, "You begin to install the light armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the light armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin1")
				stage = 8
				armor_type = 1
			else if(istype(W, /obj/item/pod/armor_heavy))
				boutput(user, "You begin to install the heavy armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the heavy armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin2")
				stage = 8
				armor_type = 2
			else if(istype(W, /obj/item/pod/armor_black))
				boutput(user, "You begin to install the strange armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the strange armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin3")
				stage = 8
				armor_type = 3
			else if(istype(W, /obj/item/pod/armor_red))
				boutput(user, "You begin to install the syndicate armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the syndicate armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin2")
				stage = 8
				armor_type = 4
			else if(istype(W, /obj/item/pod/armor_industrial))
				boutput(user, "You begin to install the industrial armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the industrial armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin3")
				stage = 8
				armor_type = 5
			else if(istype(W, /obj/item/pod/armor_gold))
				boutput(user, "You begin to install the gold armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the gold armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi', "pod_skin4")
				stage = 8
				armor_type = 6
			else if(istype(W, /obj/item/pod/armor_custom) && W.material)
				boutput(user, "You begin to install the custom armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the custom armor plating.")
				src.overlays += image('icons/obj/ship.dmi', "pod_skin1")
				src.setMaterial(W.material)
				user.u_equip(W)
				qdel(W)
				stage = 8
				armor_type = 7
			else
				boutput(user, "You don't think you're going anywhere without a skin on this pod, do you? Get some armor!")

		if(8)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the exterior...")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You weld the seams of the outer skin to make it air-tight.")
				stage = 9
			else
				boutput(user, "The outer skin still feels pretty loose. Welding it together would make it nice and airtight.")

		if(9)
			if(istype(W, /obj/item/putt/control))
				boutput(user, "You begin to install the control system...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the control system for the pod.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/obj/ship.dmi',"putt_control")
				stage = 10
			else
				boutput(user, "It's not gonna get very far without a control system!")

		if(10)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (!S.material)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return
				if (!(S.material.material_flags & MATERIAL_CRYSTAL) || !S.reinforcement)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return

				if (S.amount < 3)
					boutput(usr, text("<span class='alert'>You need at least three reinforced glass sheets to make the cockpit window and outer indicator surfaces for this pod.</span>"))
					return
				boutput(user, "You begin to install the glass...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				W.amount -= 3
				if(!W:amount)
					user.u_equip(W)
					qdel(W)
				boutput(user, "With the cockpit and exterior indicators secured, the control system automatically starts up.")

				if(armor_type == 1)
					new /obj/machinery/vehicle/miniputt( src.loc )
					logTheThing("station", usr, null, "finishes building a MiniPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 2)
					new /obj/machinery/vehicle/miniputt/nanoputt( src.loc )
					logTheThing("station", usr, null, "finishes building a NanoPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 3)
					new /obj/machinery/vehicle/miniputt/black( src.loc )
					logTheThing("station", usr, null, "finishes building a XeniPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 4)
					new /obj/machinery/vehicle/miniputt/syndiputt( src.loc )
					logTheThing("station", usr, null, "finishes building a SyndiPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 5)
					new /obj/machinery/vehicle/miniputt/indyputt( src.loc )
					logTheThing("station", usr, null, "finishes building an IndyPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 6)
					new /obj/machinery/vehicle/miniputt/gold( src.loc )
					logTheThing("station", usr, null, "finishes building a PyriPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 7)
					var/obj/machinery/vehicle/miniputt/A = new /obj/machinery/vehicle/miniputt( src.loc )
					A.name = "MiniPutt"
					A.setMaterial(src.material)
					logTheThing("station", usr, null, "finishes building a custom armored MiniPutt in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)
			else
				boutput(user, "You weren't thinking of flying around without a reinforced cockpit, were you? Put some reinforced glass on it! Three sheets will do.")

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

	if (!t1 || !t2 || !t3 || !t1.CanPass(src, t1) || !t2.CanPass(src, t2) || !t3.CanPass(src, t3))
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
	health = 75
	maxhealth = 75
	bound_width = 64
	bound_height = 64
	view_offset_x = 16
	view_offset_y = 16
	//luminosity = 5 // will help with space exploration

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.maxhealth = max(75, src.material.getProperty("density") * 5)
			src.health = maxhealth
			src.speed = max(0.75,min(5, (100 - src.material.getProperty("electrical")) / 40))
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
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
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), SOUTHEAST), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
				var/turf/E = get_step(get_turf(src), EAST)
				P = shoot_projectile_DIR(get_step(E, EAST), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
			if (shoot_dir == SOUTHWEST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), WEST), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
				P = shoot_projectile_DIR(get_step(get_turf(src), SOUTH), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user

			if (shoot_dir == NORTHEAST)
				var/turf/NE = get_step(get_turf(src), NORTHEAST)

				var/obj/projectile/P = shoot_projectile_DIR(get_step(NE, NORTH), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
				P = shoot_projectile_DIR(get_step(NE, EAST), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user

			if (shoot_dir == NORTHWEST)
				var/turf/N = get_step(get_turf(src), NORTH)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(N, WEST), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
				P = shoot_projectile_DIR(get_step(N, NORTH), PROJ, shoot_dir, src)
				if (P)
					P.mob_shooter = user
		else
			if (shoot_dir == SOUTH || shoot_dir == WEST)
				var/obj/projectile/P = shoot_projectile_DIR(src, PROJ, shoot_dir)
				if (P)
					P.mob_shooter = user
					P.pixel_x = H * -5
					P.pixel_y = V * -5
			if (shoot_dir == SOUTH || shoot_dir == EAST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), EAST), PROJ, shoot_dir, src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * 5
					P.pixel_y = V * -5
			if (shoot_dir == NORTH || shoot_dir == WEST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), NORTH), PROJ, shoot_dir, src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * -5
					P.pixel_y = V * 5
			if (shoot_dir == NORTH || shoot_dir == EAST)
				var/obj/projectile/P = shoot_projectile_DIR(get_step(get_turf(src), NORTHEAST), PROJ, shoot_dir, src)
				if (P)
					P.shooter = src
					P.mob_shooter = user
					P.pixel_x = H * 5
					P.pixel_y = V * 5


/obj/machinery/vehicle/pod_smooth/light // standard civilian pods
	name = "Pod C-"
	desc = "A civilian-class vehicle pod, often used for exploration and trading."
	icon_state = "pod_civ"
	health = 100
	maxhealth = 100
	speed = 0

/obj/machinery/vehicle/pod_smooth/gold // blingee
	name = "Pod G-"
	desc = "A light, high-speed vehicle pod often used by underground pod racing clubs and people with more money than sense."
	icon_state = "pod_gold"
	armor_score_multiplier = 0.4
	health = 200
	maxhealth = 200
	speed = 0.2

/obj/machinery/vehicle/pod_smooth/heavy // pods made with reinforced armor
	name = "Pod T-"
	desc = "A military-issue vehicle pod."
	armor_score_multiplier = 1
	icon_state = "pod_mil"
	health = 250
	maxhealth = 250
	speed = 0.3

	/*prearmed // this doesn't seem to work yet, dangit
		New()
			..()
			src.sec_system = new /obj/item/shipcomponent/pod_weapon/laser( src )
			src.sec_system.ship = src
			src.components += src.sec_system
			return */

/obj/machinery/vehicle/pod_smooth/syndicate
	name = "Pod S-"
	desc = "A syndicate-issue assault pod."
	armor_score_multiplier = 1
	icon_state = "pod_synd"
	health = 250
	maxhealth = 250
	speed = 0.3

	/*prearmed
		New()
			..()
			src.sec_system = new /obj/item/shipcomponent/pod_weapon/gun( src )
			src.sec_system.ship = src
			src.components += src.sec_system
			return*/

	New()
		..()
		myhud.update_systems()
		myhud.update_states()
		return

	New()
		..()
		src.lock = new /obj/item/shipcomponent/secondary_system/lock(src)
		src.lock.ship = src
		src.com_system = new /obj/item/shipcomponent/communications/syndicate(src)
		src.com_system.ship = src
		src.components += src.lock
		src.components += src.com_system
		myhud.update_systems()
		myhud.update_states()

/obj/machinery/vehicle/pod_smooth/black
	name = "Pod X-"
	desc = "????"
	armor_score_multiplier = 1.5
	icon_state = "pod_black"
	health = 500
	maxhealth = 500

/obj/machinery/vehicle/pod_smooth/iridium
	name = "Pod Y-"
	desc = "It appears to be an experimental vehicle based on the Syndicate's IRIDIUM project."
	armor_score_multiplier = 1.25
	icon_state = "pod_pre"
	health = 400
	maxhealth = 400

/obj/machinery/vehicle/pod_smooth/industrial
	name = "Pod I-"
	desc = "A slow yet sturdy industrial pod, designed for hazardous work in asteroid belts. Can accomodate up to four passengers."
	armor_score_multiplier = 1.25
	icon_state = "pod_industrial"
	health = 400
	maxhealth = 400
	speed = 0.6
	capacity = 4

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
		//boutput(usr, "<span class='alert'>The access door is already in use!</span>")
		//return

	if(locked)
		boutput(usr, "<span class='alert'>[src] is locked!</span>")
		return

	if(panel_status)
		boutput(usr, "<span class='alert'>Close the maintenance panel first!</span>")
		return

	if(!isliving(usr))
		return

	if (usr.stat)
		return

	if (usr in src) // fuck's sake
		boutput(usr, "<span class='alert'>You're already inside [src]!</span>")
		return

	boarding = 1

	passengers = 0 // reset this shit

	for(var/mob/M in src) // nobody likes losing a pod to a dead pilot
		passengers++
		if(M.stat || !M.client)
			eject(M)
			boutput(usr, "<span class='alert'>You pull [M] out of [src].</span>")
		else if(!isliving(M))
			eject(M)
			boutput(usr, "<span class='alert'>You scrape [M] out of [src].</span>")


	for(var/obj/decal/cleanable/O in src)
		boutput(usr, "<span class='alert'>You [pick(</span>"scrape","scrub","clean")] [O] out of [src].")
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

	SPAWN_DBG(0.5 SECONDS)
		boarding = 0*/



/*/obj/machinery/vehicle/pod_smooth/handle_occupants_shipdeath()
	for(var/mob/M in src)
		boutput(M, "<span class='alert'><b>You are ejected from [src]!</b></span>")
		src.eject(M)
		var/atom/target = get_edge_target_turf(M,pick(alldirs))
		SPAWN_DBG(0)
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

/obj/item/pod/armor_light
	name = "Light Pod Armor"
	desc = "Standard exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_custom
	name = "Pod Armor"
	desc = "Plating for vehicle pods made from a custom compound."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_heavy
	name = "Heavy Pod Armor"
	desc = "Reinforced exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_black
	name = "Strange Pod Armor"
	desc = "The box is stamped with the Nanotrasen symbol and a lengthy list of classified warnings. Neat."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_red
	name = "Syndicate Pod Armor"
	desc = "The box is stamped with the logos of various Syndicate affiliated corporations."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_industrial
	name = "Industrial Pod Armor"
	desc = "A kit of bulky industrial armor plates for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

/obj/item/pod/armor_gold
	name = "Gold Pod Armor"
	desc = "It's really only gold-plated."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"

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
			if (istype(T, /turf/simulated))
				var/turf/simulated/S = T
				if (!S.allows_vehicles)
					canbuild = 0
					boutput(user, "<span class='alert'>You can't build a pod here! It'd get stuck.</span>")
					break
			for (A in T)
				if (A == user)
					continue
				if (A.density)
					canbuild = 0
					boutput(user, "<span class='alert'>You can't build a pod here! [A] is in the way.</span>")
					goto out // break isn't enough since this loop is nested
		out:

		if (canbuild)
			boutput(user, "<span class='notice'>You dump out the box of parts onto the floor.</span>")
			var/obj/O = new /obj/structure/podframe( get_turf(user) )
			logTheThing("station", user, null, "builds [O] in [get_area(user)] ([showCoords(user.x, user.y, user.z)])")
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
			qdel(src)

/obj/structure/podframe
	name = "Pod Frame"
	desc = "A vehicle pod under construction."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "pod_parts"
	bound_width = 64
	bound_height = 64
	anchored = 1
	density = 1
	var/stage = 0
	var/armor_type = 1

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

//-- POD DECONSTRUCTION
/obj/structure/podframe/verb/deconstruct()
	set src in oview(1)
	set category = "Local"

	if (usr.stat)
		return

	boutput(usr, "Deconstructing frame...")

	var/timer = 5 * stage + 30
	while(timer > 0)
		if(do_after(usr, 10))
			timer -= 10
		else
			boutput(usr, "<span class='alert'>You were interrupted!</span>")
			return

	boutput(usr, "<span class='notice'>You deconstructed the pod frame.</span>")
	var/obj/O
	if (stage == 10)
		O = new /obj/item/pod/control( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage -= 2
	if (stage == 9)
		stage-- // no parts involved here, this construction step is welding the exterior
	if (stage == 8)
		if (armor_type == 1)
			O = new /obj/item/pod/armor_light( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 2)
			O = new /obj/item/pod/armor_heavy( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 3)
			O = new /obj/item/pod/armor_black( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 4)
			O = new /obj/item/pod/armor_red( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 5)
			O = new /obj/item/pod/armor_industrial( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 6)
			O = new /obj/item/pod/armor_gold( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
		else if (armor_type == 7)
			O = new /obj/item/pod/armor_custom( get_turf(src) )
			O.fingerprints = src.fingerprints
			O.fingerprintshidden = src.fingerprintshidden
			O.setMaterial(src.material)
			src.removeMaterial()
		stage--
	if (stage == 7)
		O = new /obj/item/pod/engine( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 6)
		var/obj/item/sheet/steel/M = new ( get_turf(src) )
		M.amount = 5
		M.fingerprints = src.fingerprints
		M.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 5)
		O = new /obj/item/pod/boards( get_turf(src) )
		O.fingerprints = src.fingerprints
		O.fingerprintshidden = src.fingerprintshidden
		stage--
	if (stage == 4)
		var/obj/item/cable_coil/cut/C = new ( get_turf(src) )
		C.amount = 4
		C.fingerprints = src.fingerprints
		C.fingerprintshidden = src.fingerprintshidden
		// all other steps were tool applications, no more parts to create

	O = new /obj/item/pod/frame_box( get_turf(src) )
	logTheThing("station", usr, null, "deconstructs [src] in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
	O.fingerprints = src.fingerprints
	O.fingerprintshidden = src.fingerprintshidden
	qdel(src)

//-- POD CONSTRUCTION METHOD

/obj/structure/podframe/attackby(obj/item/W as obj, mob/living/user as mob)
	switch(stage)
		if (0)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the frame...")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You wrench some of the frame parts together.")
				src.overlays += image('icons/effects/64x64.dmi', "pod_frame1")
				stage = 1
			else
				boutput(user, "If only there was some way to secure all this junk together! You should get a wrench.")

		if (1)
			if (iswrenchingtool(W))
				boutput(user, "You begin to secure the rest of the frame...")
				playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You finish wrenching the frame parts together.")
				src.overlays -= image('icons/effects/64x64.dmi', "pod_frame1")
				icon_state = "pod_frame"
				stage = 2
			else
				boutput(user, "You should probably finish putting these parts together. A wrench would do the trick!")

		if(2)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the joints of the frame...")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You weld the joints of the frame together.")
				stage = 3
			else
				boutput(user, "Even with the bolts secured, the joints of this frame still feel pretty wobbly. Welding it will make it nice and sturdy.")

		if(3)
			if(istype(W, /obj/item/cable_coil))
				if(W.amount < 4)
					boutput(user, "<span class='notice'>You need at least four lengths of cable.</span>")
					return
				boutput(user, "You begin to install the wiring...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				W.amount -= 4
				if(!W.amount)
					user.u_equip(W)
					qdel(W)
				boutput(user, "You add power cables to the pod frame.")
				src.overlays += image('icons/effects/64x64.dmi', "pod_wires")
				stage = 4
			else
				boutput(user, "You're not gonna get very far without power cables. You should get at least four lengths of it.")

		if(4)
			if(istype(W, /obj/item/pod/boards))
				boutput(user, "You begin to install the circuit boards...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the internal circuitry parts.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_circuits")
				stage = 5
			else
				boutput(user, "Maybe those wires should be connecting something together. Some kind of circuitry, perhaps.")

		if(5)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (S.material && S.material.material_flags & MATERIAL_METAL)
					if( S.amount < 5)
						boutput(usr, text("<span class='alert'>You need at least five metal sheets to make internal plating for this pod.</span>"))
						return
					boutput(user, "You begin to install the internal plating...")
					playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
					if (!do_after(user, 30))
						boutput(user, "<span class='alert'>You were interrupted!</span>")
						return
					S.amount -= 5
					if(S.amount < 1)
						user.u_equip(S)
						qdel(S)
					boutput(user, "You construct internal covers over the circuitry systems.")
					src.overlays += image('icons/effects/64x64.dmi', "pod_covers")
					stage = 6
				else
					boutput(user, "<span class='alert'>These sheets aren't the right kind of material. You need metal!</span>")
			else
				boutput(user, "You shouldn't just leave all those circuits exposed! That's dangerous! You'll need five sheets of metal to cover it all up.")

		if(6)
			if(istype(W, /obj/item/pod/engine))
				boutput(user, "You begin to install the engine...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the engine.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_engine")
				stage = 7
			else
				boutput(user, "Having an engine might be nice.")

		if(7)
			if(istype(W, /obj/item/pod/armor_light))
				boutput(user, "You begin to install the light armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the light armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin1")
				stage = 8
				armor_type = 1
			else if(istype(W, /obj/item/pod/armor_heavy))
				boutput(user, "You begin to install the heavy armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the heavy armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin2")
				stage = 8
				armor_type = 2
			else if(istype(W, /obj/item/pod/armor_black))
				boutput(user, "You begin to install the strange armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the strange armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin3")
				stage = 8
				armor_type = 3
			else if(istype(W, /obj/item/pod/armor_red))
				boutput(user, "You begin to install the syndicate armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the syndicate armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin2")
				stage = 8
				armor_type = 4
			else if(istype(W, /obj/item/pod/armor_industrial))
				boutput(user, "You begin to install the industrial armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the industrial armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin3")
				stage = 8
				armor_type = 5
			else if(istype(W, /obj/item/pod/armor_gold))
				boutput(user, "You begin to install the gold armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the gold armor plating.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin4")
				stage = 8
				armor_type = 6
			else if(istype(W, /obj/item/pod/armor_custom) && W.material)
				boutput(user, "You begin to install the custom armor plating...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You loosely attach the custom armor plating.")
				src.overlays += image('icons/effects/64x64.dmi', "pod_skin1")
				src.setMaterial(W.material)
				user.u_equip(W)
				qdel(W)
				stage = 8
				armor_type = 7
			else
				boutput(user, "You don't think you're going anywhere without a skin on this pod, do you? Get some armor!")

		if(8)
			if (isweldingtool(W))
				if(!W:try_weld(user, 1))
					return
				boutput(user, "You begin to weld the exterior...")
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You weld the seams of the outer skin to make it air-tight.")
				stage = 9
			else
				boutput(user, "The outer skin still feels pretty loose. Welding it together would make it nice and airtight.")

		if(9)
			if(istype(W, /obj/item/pod/control))
				boutput(user, "You begin to install the control system...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				boutput(user, "You install the control system for the pod.")
				user.u_equip(W)
				qdel(W)
				src.overlays += image('icons/effects/64x64.dmi',"pod_control")
				stage = 10
			else
				boutput(user, "It's not gonna get very far without a control system!")

		if(10)
			if(istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (!S.material)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return
				if (!(S.material.material_flags & MATERIAL_CRYSTAL) || !S.reinforcement)
					boutput(user, "These sheets won't work. You'll need reinforced glass or crystal.")
					return

				if (S.amount < 5)
					boutput(usr, text("<span class='alert'>You need at least five reinforced glass sheets to make the cockpit window and outer indicator surfaces for this pod.</span>"))
					return
				boutput(user, "You begin to install the glass...")
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)
				if (!do_after(user, 30))
					boutput(user, "<span class='alert'>You were interrupted!</span>")
					return
				W.amount -= 5
				if(!W:amount)
					user.u_equip(W)
					qdel(W)
				boutput(user, "With the cockpit and exterior indicators secured, the control system automatically starts up.")

				if(armor_type == 1)
					new /obj/machinery/vehicle/pod_smooth/light( src.loc )
					logTheThing("station", usr, null, "finishes building a lightly armored pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 2)
					new /obj/machinery/vehicle/pod_smooth/heavy( src.loc )
					logTheThing("station", usr, null, "finishes building a heavily armored pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 3)
					new /obj/machinery/vehicle/pod_smooth/black( src.loc )
					logTheThing("station", usr, null, "finishes building an NT pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 4)
					new /obj/machinery/vehicle/pod_smooth/syndicate( src.loc )
					logTheThing("station", usr, null, "finishes building a syndicate pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 5)
					new /obj/machinery/vehicle/pod_smooth/industrial( src.loc )
					logTheThing("station", usr, null, "finishes building an industrial pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 6)
					new /obj/machinery/vehicle/pod_smooth/gold( src.loc )
					logTheThing("station", usr, null, "finishes building a gold pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)

				else if (armor_type == 7)
					var/obj/machinery/vehicle/pod_smooth/light/A = new /obj/machinery/vehicle/pod_smooth/light( src.loc )
					A.name = "Pod"
					A.setMaterial(src.material)
					logTheThing("station", usr, null, "finishes building a custom armored pod in [get_area(usr)] ([showCoords(usr.x, usr.y, usr.z)])")
					qdel(src)
			else
				boutput(user, "You weren't thinking of flying around without a reinforced cockpit, were you? Put some reinforced glass on it! Five sheets will do.")

///// Shitty escape pod that flies by itself for a bit then explodes.

/obj/machinery/vehicle/escape_pod
	name = "Escape Pod E-"
	desc = "A small one-person pod for escaping the station in emergencies.<br>It looks sort of rickety..."
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

	finish_board_pod(var/mob/boarder)
		..()
		if (!src.pilot) return //if they were stopped from entering by other parts of the board proc from ..()
		SPAWN_DBG(0)
			src.escape()

	proc/escape()
		if(!launched)
			launched = 1
			anchored = 0
			var/opened_door = 0
			var/turf_in_front = get_step(src,src.dir)
			for(var/obj/machinery/door/poddoor/D in turf_in_front)
				D.open()
				opened_door = 1
			if(opened_door) sleep(2 SECONDS) //make sure it's fully open
			playsound(src.loc, "sound/effects/bamf.ogg", 100, 0)
			sleep(0.5 SECONDS)
			playsound(src.loc, "sound/effects/flameswoosh.ogg", 100, 0)
			while(!failing)
				var/loc = src.loc
				step(src,src.dir)
				if(src.loc == loc) //we hit something
					explosion(src, src.loc, 1, 1, 2, 3)
					break
				steps_moved++
				if(prob((steps_moved-7) * 3) && !succeeding)
					fail()
				if (prob((steps_moved-7) * 4))
					succeed()
				sleep(0.4 SECONDS)

	proc/test()
		boutput(world,"shuttle loc is [emergency_shuttle.location]")

	proc/succeed()
		if (succeeding && prob(3))
			succeeding = 0
		if (emergency_shuttle.location == SHUTTLE_LOC_TRANSIT & !did_warp) //lol sorry hardcoded a define thing
			succeeding = 1
			did_warp = 1

			playsound(src.loc, "warp", 50, 1, 0.1, 0.7)

			var/obj/portal/P = unpool(/obj/portal)
			P.set_loc(get_turf(src))
			var/turf/T = pick_landmark(LANDMARK_ESCAPE_POD_SUCCESS)
			src.dir = landmarks[LANDMARK_ESCAPE_POD_SUCCESS][T]
			P.target = T
			src.set_loc(T)

			logTheThing("station", src, null, "creates an escape portal at [log_loc(src)].")


	proc/fail()
		failing = 1
		if(!fail_type) fail_type = rand(1,8)
		switch(fail_type)
			if(1) //dies
				shipdeath()
			if(2) //fuel tank explodes??
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>The fuel tank of your escape pod explodes!</span>")
				explosion(src, src.loc, 2, 3, 4, 6)
			if(3) //falls apart
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>Your escape pod is falling apart around you!</span>")
				while(src)
					step(src,src.dir)
					if(prob(50))
						make_cleanable(/obj/decal/cleanable/robot_debris/gib, src.loc)
					if(prob(20) && pilot)
						boutput(pilot, "<span class='alert'>You fall out of the rapidly disintegrating escape pod!</span>")
						src.leave_pod(pilot)
					if(prob(10)) shipdeath()
					sleep(0.4 SECONDS)
			if(4) //flies off course
				pilot << sound('sound/machines/engine_alert1.ogg')
				boutput(pilot, "<span class='alert'>Your escape pod is veering out of control!</span>")
				while(src)
					if(prob(10)) src.dir = turn(dir,pick(90,-90))
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					sleep(0.4 SECONDS)
			if(5)
				boutput(pilot, "<span class='alert'>Your escape pod sputters to a halt!</span>")
			if(6)
				boutput(pilot, "<span class='alert'>Your escape pod explosively decompresses, hurling you into space!</span>")
				pilot << sound('sound/effects/Explosion2.ogg')
				if(ishuman(pilot))
					var/mob/living/carbon/human/H = pilot
					for(var/effect in list("sever_left_leg","sever_right_leg","sever_left_arm","sever_right_arm"))
						if(prob(40))
							SPAWN_DBG(rand(0,5))
								H.bioHolder.AddEffect(effect)
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
				boutput(pilot, "<span class='alert'>Your escape pod begins to accelerate!</span>")
				var/speed = 5
				while(speed)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(speed > 1 && prob(10)) speed--
					if(speed == 1 && prob(5))
						boutput(pilot, "<span class='alert'>Your escape pod is moving so fast that it tears itself apart!</span>")
						shipdeath()
					else if(prob(10/speed))
						boutput(pilot, "<span class='alert'>Your escape pod is [pick("vibrating","shuddering","shaking")] [pick("alarmingly","worryingly","violently","terribly","scarily","weirdly","distressingly")]!</span>")
					sleep(speed)
			if(8)
				boutput(pilot, "<span class='alert'>Your escape pod starts to fly around in circles [pick("awkwardly","embarrassingly","sadly","pathetically","shamefully","ridiculously")]!</span>")
				pilot << sound('sound/machines/engine_alert1.ogg')
				var/spin_dir = pick(90,-90)
				while(src)
					src.dir = turn(dir,spin_dir)
					var/loc = src.loc
					step(src,src.dir)
					if(src.loc == loc) //we hit something
						explosion(src, src.loc, 1, 1, 2, 3)
						break
					if(prob(2)) //we don't want to do this forever so let's explode
						shipdeath()
					sleep(0.4 SECONDS)
