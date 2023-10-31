//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Welcome To Morrigan ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Area Allocations ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
var/datum/allocated_region/morrigan_region = null
proc/load_morrigan()
	var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/morrigan)
	morrigan_region = prefab.load()
	// big stupid hack because conveyors only init if loaded earlier
	for (var/obj/machinery/conveyor/conveyor as anything in machine_registry[MACHINES_CONVEYORS])
		if (morrigan_region.turf_in_region(get_turf(conveyor)))
			conveyor.initialize()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Unbidden Macha Ship ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
var/datum/allocated_region/morrigan_ship = null // This is for admin events only I'd imagine - Rex
proc/load_morrigan_ship()
	var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/morrigan_ship)
	morrigan_ship = prefab.load()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Balor Teleporter ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
ADMIN_INTERACT_PROCS(/obj/machinery/networked/telepad/morrigan, proc/transmit)
///A modified telepad
/obj/machinery/networked/telepad/morrigan
	device_tag = "PNET_S_TELEPAD_PRISONER"

//yes this is a lot of parsing boilerplate, blame years of machinery/networked being awful
/obj/machinery/networked/telepad/morrigan/receive_signal(datum/signal/signal)
	if (!..())
		return //parent says the signal is dodgy, abort

	var/sigcommand = lowertext(signal.data["command"])
	if(!sigcommand || !signal.data["sender"])
		return
	var/target = signal.data["sender"]

	switch(sigcommand)
		if("term_message","term_file")
			if(target != src.host_id) //Huh, who is this?
				return

			var/list/data = params2list(signal.data["data"])
			if(!data)
				return

			session = data["session"]

			switch(lowertext(data["command"]))
				if ("transmit")
					if (ON_COOLDOWN(src, "transmit", 10 SECONDS))
						message_host("command=nack") //TODO: handle this maybe
						return
					src.transmit()
					message_host("command=ack")

/obj/machinery/networked/telepad/morrigan/proc/transmit()
	var/turf/target_turf = get_turf(landmarks[LANDMARK_MORRIGAN_START][1])
	var/turf/crate_turf = get_turf(landmarks[LANDMARK_MORRIGAN_CRATE][1])
	for (var/mob/living/M in get_turf(src))
		var/obj/storage/crate/crate = new(crate_turf)
		M.unequip_all(unequip_to = crate)

		do_teleport(M, target_turf, use_teleblocks = FALSE)

		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_new_if_possible(/obj/item/clothing/shoes/orange, SLOT_SHOES)
			H.equip_new_if_possible(/obj/item/clothing/under/misc/prisoner, SLOT_W_UNIFORM)

		var/obj/port_a_prisoner/prison = new /obj/port_a_prisoner(get_turf(M))
		prison.force_in(M)

	showswirl_out(src.loc)
	leaveresidual(src.loc)
	showswirl(target_turf)
	leaveresidual(target_turf)
	use_power(1500)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Balor Mainframe ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/machinery/networked/mainframe/balor
	setup_drive_type = /obj/item/disk/data/memcard/balor

/obj/item/disk/data/memcard/balor
	file_amount = 1024

	New()
		..()
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "sys"
		newfolder.metadata["permission"] = COMP_HIDDEN
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/mainframe_program/os/kernel(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/shell(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/login(src) )

		var/datum/computer/folder/subfolder = new /datum/computer/folder
		subfolder.name = "drvr" //Driver prototypes.
		newfolder.add_file( subfolder )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/user_terminal(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/telepad_prisoner(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/apc(src) )

		subfolder = new /datum/computer/folder
		subfolder.name = "srv"
		newfolder.add_file( subfolder )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/email(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/print(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/telecontrol(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/telecontrol_prisoner(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "bin" //Applications available to all users.
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cd(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/ls(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/rm(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cat(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mkdir(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/ln(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/chmod(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/chown(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/su/syndicate(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cp(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mv(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mount(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/hept_interface(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/guardbot_interface(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "mnt"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		newfolder = new /datum/computer/folder
		newfolder.name = "conf"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		var/datum/computer/file/record/testR = new
		testR.name = "motd"
		testR.fields += "Welcome to DWAINE System VI!"
		testR.fields += "Hafgan Robotics Distribution"
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Landmarks ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/landmark/morrigan_start
	name = LANDMARK_MORRIGAN_START

/obj/landmark/morrigan_crate
	name = LANDMARK_MORRIGAN_CRATE

/obj/landmark/morrigan_transport
	name = LANDMARK_MORRIGAN_TRANSPORT

/obj/landmark/morrigan_prisoner
	name = LANDMARK_MORRIGAN_PRISONER

/obj/landmark/morrigan_crate_puzzle
	name = LANDMARK_MORRIGAN_CRATE_PUZZLE

//fakescanner because actual secscanner makes it go weird

/obj/machinery/fakescanner/crate_puzzle
	name = "crate security scanner"
	desc = "Scanner for scanning the crates for contraband"
	icon = 'icons/obj/machines/scanner.dmi'
	icon_state = "scanner_on"
	anchored = ANCHORED_ALWAYS

	var/success_sound = 'sound/machines/chime.ogg'
	var/fail_sound = 'sound/machines/alarm_a.ogg'
	var/secret_sound = 'sound/misc/respawn.ogg'
	var/unlock_door_sound = 'sound/effects/cargodoor.ogg'

	var/cargo_points_earned = null //dunno if it should be a var seperate of object
	var/door_opened = FALSE
	var/crate_spawned = FALSE

	proc/scan_the_crate(var/obj/storage/crate)

		if (!istype(crate, /obj/storage/crate/morrigancargo))
			return

		var/obj/storage/crate/morrigancargo/morrigan_crate = crate

		if (!morrigan_crate.delivery_destination)
			playsound(src.loc, fail_sound, 30, 0)
			return
		if (morrigan_crate.delivery_destination == "Safe" && morrigan_crate.contra_contained == 0)
			cargo_points_earned++
			playsound(src.loc, success_sound, 30, 1)
			return
		else if (morrigan_crate.delivery_destination == "Suspicious" && morrigan_crate.contra_contained > 0)
			cargo_points_earned++
			playsound(src.loc, success_sound, 30, 1)
			return
		else
			playsound(src.loc, fail_sound, 30, 0)
			return

	proc/check_if_can_do_stuff()

		if (src.cargo_points_earned < 5)
			return

		else if(!door_opened && src.cargo_points_earned < 10)
			playsound(src.loc, unlock_door_sound, 110, 1)
			door_opened = TRUE
			for (var/obj/machinery/door/airlock/pyro/glass/security/door as anything in by_type[/obj/machinery/door/airlock])
				if (door.id == "cargo_security" && door.density)
					door.open()
			for (var/mob/M in range(10, src))
 			boutput(M, "Something clicks in the distance!")
			return

		else if (!src.crate_spawned && src.cargo_points_earned > 9)
			playsound(src.loc, secret_sound, 110, 1)
			new /obj/storage/crate/morriganaccess(get_turf(landmarks[LANDMARK_MORRIGAN_CRATE_PUZZLE][1]))
			crate_spawned = TRUE
			return

	Crossed(atom/movable/AM as obj)
		. = ..()
		if (!istype(AM, /obj/storage/crate))
			return
		scan_the_crate(AM)
		SPAWN(1 SECOND)
			check_if_can_do_stuff()

/obj/machinery/door/airlock/pyro/glass/security

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ID Cards ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/card/id/morrigan
	desc = "An ID card allowing you into places, but for the syndicate... not much else to say."
/obj/item/card/id/morrigan/adfm
	icon_state = "id_morg"
	access = list(access_maint_tunnels, access_morrigan_security)

/obj/item/card/id/morrigan/balor_it
	name = "Technical Operative Banks spare ID (do not use)"
	icon_state = "id_synexe"
	registered = "Operative Banks"
	assignment = "Technical Operative"
	access = list(access_maint_tunnels, access_syndicate_it)

/obj/item/card/id/morrigan/specialist
	name = "Sarah Lin (R&D Specialist)"
	icon_state = "id_spe"
	desc = "I wonder where this leads you.."
	access = list(access_maint_tunnels, access_morrigan_specialist)

/obj/item/card/id/morrigan/inspector
	name = "Old Inspector's Card"
	icon_state = "data_old"
	desc = "Looks like and old proto-type ID card!"
	access = list(access_maint_tunnels, access_morrigan_teleporter)

/obj/item/card/id/morrigan/engineer
	name = "Richard S. Batherl (Engineer)"
	icon_state = "id_eng"
	desc = "This should let you get into engineering..."
	access = list(access_maint_tunnels, access_morrigan_engineering)

/obj/item/card/id/morrigan/ce
	name = "Misplaced CE Card"
	icon_state = "id_comde"
	desc = "Name and picture are scratched off. It's in pretty poor shape."
	access = list(access_maint_tunnels, access_morrigan_CE, access_morrigan_engineering)

/obj/item/card/id/morrigan/medical
	name = "Harther Monoshoe (EMT)"
	icon_state = "id_res"
	desc = "A card for medbay!"
	access = list(access_maint_tunnels, access_morrigan_medical)

/obj/item/card/id/morrigan/mdir
	name = "Barara J. June (Medical Director)"
	icon_state = "id_com"
	desc = "An important ID card belonging to the medical director."
	access = list(access_maint_tunnels, access_morrigan_medical, access_morrigan_mdir, access_morrigan_bridge)

/obj/item/card/id/morrigan/science
	name = "Troy Wentworth (Scientist)"
	icon_state = "id_res"
	desc = "An ID card of a scientist."
	access = list(access_maint_tunnels, access_morrigan_science)

/obj/item/card/id/morrigan/rd
	name = "Partially melted Research Director ID"
	icon_state = "id_comac"
	desc = "This card looks badly damaged, does it still work?"
	access = list(access_maint_tunnels, access_morrigan_science, access_morrigan_RD)

/obj/item/card/id/morrigan/janitor
	name = "Yi Wong (Janitor)"
	icon_state = "id_civ"
	desc = "It's sparkling clean."
	access = list(access_maint_tunnels, access_morrigan_janitor)

/obj/item/card/id/morrigan/security
	name = "Harrier S. Jentlil (Patrol Officer)"
	icon_state = "id_sec"
	desc = "Wow, a still intact security ID! This could come in handy..."
	access = list(access_maint_tunnels, access_morrigan_security)

/obj/item/card/id/morrigan/hos
	name = "Alexander Nash (Elite Head of Security)"
	icon_state = "id_synexe"
	desc = "Jackpot!"
	access = list(access_maint_tunnels, access_morrigan_bridge, access_morrigan_security, access_morrigan_HOS)

/obj/item/card/id/morrigan/customs
	name = "William B. Ron"
	icon_state = "id_com"
	desc = "A Head ID but it seems to be lacking something..."
	access = list(access_maint_tunnels, access_morrigan_customs)

/obj/item/card/id/morrigan/captain
	name = "Captain's Spare ID"
	icon_state = "id_scap"
	desc = "The Captains spare ID! This should access most doors..."

	New()
		..()
		access = morrigan_access() - list(access_morrigan_meetingroom, access_morrigan_HOS)

/obj/item/card/id/morrigan/all_access
	name = "Number 3 (Hafgan Executive)"
	icon_state = "id_haf"
	desc = "Someone must've been in a rush and left this behind... it's heavily decorated and seems extremely important. Could this be your key out?"

	New()
		..()
		access = morrigan_access() - list(access_morrigan_HOS)

/proc/morrigan_access()
	return list(access_morrigan_bridge, access_morrigan_medical, access_morrigan_CE, access_morrigan_captain, access_morrigan_RD, access_morrigan_engineering,
	access_morrigan_factory, access_morrigan_HOS, access_morrigan_meetingroom, access_morrigan_customs, access_morrigan_exit, access_morrigan_science,
	access_morrigan_mdir, access_morrigan_security, access_morrigan_janitor, access_morrigan_specialist, access_maint_tunnels)


//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Areas ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/area/morrigan
	name = "Morrigan Area Parent"
	icon_state = "red"
	requires_power = FALSE

// Areas before the station proper

/area/morrigan/routing
	name = "Syndicate Routing Depot"
	icon_state = "depot"

/area/morrigan/routing/transport
	name = "Prisoner Transport"
	sound_loop = 'sound/ambience/morrigan/entranceamb.ogg'
	sound_loop_vol = 75

/area/morrigan/construction
	name = "Construction Area"
	icon_state = "construction"

/area/morrigan/holding
	name = "Holding Cell"
	icon_state = "brigcell"

/area/morrigan/teleporter
	name = "Cell Teleporter"
	icon_state = "teleporter"

/area/morrigan/warden
	name = "Warden's Office"
	icon_state = "security"

/area/morrigan/overseer
	name = "Overseer's Office"
	icon_state = "red"

/area/morrigan/derelict
	name = "Derelict Maintenance"
	icon_state = "green"
	ambient_light = "#131414"
	sound_loop = 'sound/ambience/morrigan/deriambience.ogg'
	sound_loop_vol = 75

/area/morrigan/derelict/hobo
	name = "Hobo Hovel"
	icon_state = "crewquarters"

/area/morrigan/derelict/cargo
	name = "Derelict cargo area"
	icon_state = "construction"

/area/morrigan/derelict/inspector
	name = "Inspector Office"
	icon_state = "red"

//elevator

/area/shuttle/morrigan_elevator
	name = "Elevator Shaft"
	icon_state = "blue"
	ambient_light = "#131414"
	sound_loop = 'sound/ambience/morrigan/deriambience.ogg'
/area/shuttle/morrigan_elevator/upper
	name = "Elevator Upper Section"
	icon_state = "shuttle"
	force_fullbright = 0

/area/shuttle/morrigan_elevator/lower
	name = "Elevator Lower Section"
	icon_state = "shuttle2"
	force_fullbright = 0


// Station areas

/area/morrigan/station
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/cairngorm

// Security areas

/area/morrigan/station/security
	sound_loop = 'sound/ambience/morrigan/secamb.ogg'
	sound_loop_vol = 75

/area/morrigan/station/security/brig
	name = "Morrigan Brig"
	icon_state = "brigcell"

/area/morrigan/station/security/main
	name = "Morrigan Security"
	icon_state = "security"

/area/morrigan/station/security/armory
	name = "Morrigan Armory"
	icon_state = "armory"

/area/morrigan/station/security/interrogation
	name = "Morrigan Interrogation"
	icon_state = "brig"

// Med/Sci areas

/area/morrigan/station/medical
	icon_state = "blue"
	sound_loop = 'sound/ambience/morrigan/medbayambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/medical/main
	name = "Morrigan Medical Centre"
	icon_state = "medbay"

/area/morrigan/station/medical/reception
	name = "Morrigan Medical Reception"

/area/morrigan/station/medical/emergency
	name = "Morrigan Emergency Response"

/area/morrigan/station/medical/morgue
	name = "Morrigan Morgue"

/area/morrigan/station/medical/robotics
	name = "Morrigan Robotics"
	sound_loop = 'sound/ambience/morrigan/repairamb.ogg'
	sound_loop_vol = 75

/area/morrigan/station/science
	name = "Morrigan Science Centre"
	icon_state = "science"
	sound_loop = 'sound/ambience/morrigan/sciamb.ogg'
	sound_loop_vol = 75

// Engineering areas

/area/morrigan/station/engineering

/area/morrigan/station/engineering/eng
	name = "Morrigan Engineering"
	icon_state = "engineering"
	sound_loop = 'sound/ambience/morrigan/ambientfactoryrobo.ogg'
	sound_loop_vol = 75

/area/morrigan/station/engineering/specialist
	name = "Morrigan R&D"
	sound_loop = 'sound/ambience/morrigan/calibrationambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/engineering/exports
	name = "Morrigan Exports"
	sound_loop = 'sound/ambience/morrigan/cargoambi.ogg'
	sound_loop_vol = 75

// Civilian areas

/area/morrigan/station/civilian

/area/morrigan/station/civilian/bar
	name = "Morrigan Bar"
	icon_state = "bar"
	sound_loop = 'sound/ambience/morrigan/kitchenamb.ogg'
	sound_loop_vol = 75

/area/morrigan/station/civilian/kitchen
	name = "Morrigan Kitchen"
	icon_state = "kitchen"
	sound_loop = 'sound/ambience/morrigan/kitchenamb.ogg'
	sound_loop_vol = 75
/area/morrigan/station/civilian/cafe
	name = "Morrigan Mess Hall"
	icon_state = "cafeteria"
	sound_loop = 'sound/ambience/morrigan/kitchenamb.ogg'
	sound_loop_vol = 75

/area/morrigan/station/civilian/crewquarters
	name = "Morrigan Crew Lounge"
	icon_state = "crewquarters"
	sound_loop = 'sound/ambience/morrigan/crewquateramb.ogg'
	sound_loop_vol = 75
/area/morrigan/station/civilian/janitor
	name = "Morrigan Janitor's Office"
	icon_state = "janitor"

// Command areas

/area/morrigan/station/command
	icon_state = "purple"

/area/morrigan/station/command/CE
	name = "Morrigan Chief Quarters"

/area/morrigan/station/command/RD
	name = "Morrigan Research Director's Office"

/area/morrigan/station/command/MD
	name = "Morrigan Medical Director's Office"
	sound_loop = 'sound/ambience/morrigan/officeambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/command/HOP
	name = "Morrigan Customs Office"
	sound_loop = 'sound/ambience/morrigan/officeambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/command/HOS
	name = "Morrigan Commanders Quarters"

/area/morrigan/station/command/captain
	name = "Morrigan Captains Quarters"
	sound_loop = 'sound/ambience/morrigan/officeambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/command/eva
	name = "Morrigan EVA Storage"

/area/morrigan/station/command/bridge
	name = "Morrigan Bridge"
	sound_loop = 'sound/ambience/morrigan/bridgeambi.ogg'
	sound_loop_vol = 75

/area/morrigan/station/command/meeting
	name = "Morrigan Conference Room"
	sound_loop = 'sound/ambience/morrigan/printer.ogg'
	sound_loop_vol = 75

// Misc areas

/area/morrigan/station/hallway
	name = "Morrigan Hall"
	icon_state = "yellow"
	sound_loop = 'sound/ambience/morrigan/hallwaysamb.ogg'
	sound_loop_vol = 75

/area/morrigan/station/exit
	name = "Morrigan Escape Wing"
	icon_state = "escape"

/area/morrigan/station/maintenance
	name = "Morrigan Maintenance"
	icon_state = "imaint"

/area/morrigan/station/disposals
	name = "Morrigan Disposals"
	icon_state = "disposal"

/area/morrigan/station/spy
	name = "NanoTrasen Listening Room"

/area/morrigan/station/invest
	name = "Investor's Area"

/area/morrigan/station/factory
	name = "Manufacturing Line"
	icon_state = "robotics"
	sound_loop = 'sound/ambience/morrigan/ambientfactory.ogg'
	sound_loop_vol = 75

/area/morrigan/station/passage
	name = "Manufacturing Passage"

/area/morrigan/station/space
	name = "Morrigan Space"
	icon_state = "red"
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/cairngorm

// Podbays

/area/morrigan/station/podbay
	icon_state = "hangar"

/area/morrigan/station/podbay/medical
	name = "Morrigan Medical Podbay"

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Lockers ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/storage/secure/closet/morrigan
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	icon_state = "scommand"
	icon_closed = "scommand"
	icon_opened = "secure_red-open"
	bolted = TRUE

/obj/storage/secure/closet/morrigan/hos
	name = "Head of Security's locker"
	reinforced = TRUE
	req_access = list(access_morrigan_HOS)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/ce
	name = "Chief Engineer's Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_CE ,access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/rd
	name = "Research Director's Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_RD, access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/mdir
	name = "Medical Director's Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_mdir, access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/captain
	name = "Captain's Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/hop
	name = "Head of Personnel's Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_bridge, access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/security
	name = "Security Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_security, access_morrigan_HOS, access_morrigan_captain, access_morrigan_exit)
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_red-open"
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/brig
	name = "Contraband Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_security, access_morrigan_HOS, access_morrigan_captain, access_morrigan_exit)
	icon_state = "safe_locker"
	icon_closed = "safe_locker"
	icon_opened = "safe_locker-open"
	icon_greenlight = "safe-greenlight"
	icon_redlight = "safe-redlight"
	open_sound = 'sound/misc/safe_open.ogg'
	close_sound = 'sound/misc/safe_close.ogg'
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/engineer
	name = "Engineering Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_engineering, access_morrigan_CE, access_morrigan_captain, access_morrigan_exit)
	icon_state = "eng"
	icon_closed = "eng"
	icon_opened = "secure_yellow-open"
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/sci
	name = "Scientist Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_science, access_morrigan_RD, access_morrigan_captain, access_morrigan_exit)
	icon_state = "science"
	icon_closed = "science"
	icon_opened = "secure_white-open"
	spawn_contents = list()

/obj/storage/secure/closet/morrigan/medical
	name = "Medical Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_medical, access_morrigan_mdir, access_morrigan_captain, access_morrigan_exit)
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "secure_white-open"
	spawn_contents = list()

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Locked Crates ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/storage/secure/crate/morrigan
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	icon_redlight = "securecrater"
	icon_greenlight = "securecrateg"
	icon_sparks = "securecratesparks"
	icon_welded = "welded-crate"
	density = 1
	always_display_locks = 1
	throwforce = 50
	can_flip_bust = 1

/obj/storage/secure/crate/morrigan/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon_state = "secgearcrate"
	density = 1
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"
	req_access = list(access_morrigan_security, access_morrigan_HOS, access_morrigan_captain, access_morrigan_exit)
	spawn_contents = list()

/obj/storage/crate/morriganaccess
	desc = "an unlocked crate..."
	name = "Back up you wanted"
	spawn_contents = list(/obj/item/implant/access/infinite/morrigan, /obj/item/paper/morrigan/backup, /obj/item/implanter)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Teleport Objects ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/morrigan_teleporter
	name = "short-range teleporter"
	desc = "A precise teleporter that only works across short distances."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "lrport"
	var/landmark // What landmark do we point to

	Crossed(atom/movable/AM)
		. = ..()

		if (istype(AM, /obj/port_a_prisoner) || istype(AM, /mob/living))
			var/target_turf =  get_turf(landmarks[landmark][1])
			do_teleport(AM, target_turf, use_teleblocks = FALSE)
			showswirl_out(src.loc)
			leaveresidual(src.loc)
			showswirl(target_turf)
			leaveresidual(target_turf)

/obj/morrigan_teleporter/transport
	landmark = LANDMARK_MORRIGAN_TRANSPORT

/obj/morrigan_teleporter/prisoner
	landmark = LANDMARK_MORRIGAN_PRISONER

/obj/fakeobjects/morrigan_teleporter
	name = "short-range teleporter"
	desc = "A precise teleporter that only works across short distances."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "lrport"

// Port a prisoner

/obj/port_a_prisoner
	name = "Port-A-Prisoner"
	desc = "A portable cage created with stolen technology"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "port_a_brig_synd"
	var/mob/occupant = null

/obj/port_a_prisoner/proc/force_in(var/mob/living/M)
	boutput(M, "<span class='alert'> You suddenly find yourself locked up...</span>")
	src.occupant = M
	M.set_loc(src)

/obj/port_a_prisoner/proc/eject_and_del()
	src.occupant?.set_loc(src.loc)
	src.occupant = null
	qdel(src)

/obj/machinery/floorflusher/industrial/morrigan
	name = "prisoner flusher"
	desc = "A one-way ticket to your new home!"

	flush()
		for (var/obj/port_a_prisoner/jail in src)
			jail.eject_and_del()
		..()

/obj/testobjformorrigan
	name = "GTFO teleporter"
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	Crossed(atom/movable/AM)
		..()

		if (istype(AM, /mob/living))
			var/target_turf = pick(get_area_turfs(/area/helldrone, TRUE))
			launch_with_missile(AM, target_turf, null, "arrival_missile_synd")


//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Self Destruction Button ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

//This supposed to replace the nuclear charge at the end of Morrigan.
/obj/machinery/morrigan_self_destruct
	name = "Self Destruct Button"
	anchored = ANCHORED_ALWAYS
	density = TRUE
	deconstruct_flags = DECON_NONE
	icon = 'icons/obj/monitors.dmi'
	icon_state = "self_destruct1"
	desc = "A big red button labeled to activate station's self destruct when pressed. It has an ID card reader. It is locked behind a bulletproof glass case."
	var/timing = FALSE
	var/time = 80
	var/locked = TRUE
	var/last_announcement_made = FALSE
	var/list/linked_doors = null

	proc/activate_nuke()
		if (src.timing)
			return
		src.timing = TRUE
		command_alert("Attention all personnel aboard Morrigan, this is an urgent self-destruction alert. Please remain calm and follow the evacuation protocols immediately. Detonation in T-[src.time] seconds", "Self Destruct Activated", alert_origin = ALERT_STATION)
		playsound_global(src.z, 'sound/ambience/morrigan/selfdestruct.ogg', 50)

	proc/detonate()
		playsound_global(src.z, 'sound/ambience/morrigan/boomnoise.ogg', 70)
		for (var/mob/living/carbon/human/H in mobs) //so people wouldn't just survive station's self destruct
			if (istype(get_area(H), /area/morrigan/station))
				SPAWN(1 SECONDS)
					H.emote("scream")
					H.firegib()
		qdel(src)

	proc/lockdown()
	//eventually i will find a better way to update lights
		for(var/obj/machinery/light/light in by_cat[TR_CAT_MORRIGAN_LIGHTS])
			if (!istype(light, /obj/machinery/light/emergency))
				light.seton(FALSE)
				LAGCHECK(LAG_LOW)
			else
				light.on = TRUE
				light.update() //you have to update it for it to work
				LAGCHECK(LAG_LOW)
		for (var/obj/machinery/door/door as anything in by_type[/obj/machinery/door/poddoor/buff/morrigan_lockdown])
			if (door.density)
				door.open()
			else
				door.close()

	//pressing the button
	attack_hand(var/mob/user)
		..()
		if (src.locked)
			boutput(user, "<span class='alert'>The button seems to be locked behind the glass case. Looks like you can unlock it using an ID card.</span>")
			return
		if (src.timing)
			boutput(user, "<span class='alert'>You press the button over and over again but it's no use! Shit!</span>")
			return
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user.unlock_medal("Cell Shock", TRUE)
		activate_nuke()
		lockdown()

	//attack by an item
	attackby(var/obj/item/I, var/mob/user)
		..()
		if (!src.locked)
			boutput(user, "<span class='notice'>The glass case has already been opened.</span>")
			return
		if (!istype(I, /obj/item/card/id/morrigan/all_access) && src.locked)
			boutput(user, "<span class='alert'>You try to hit the glass case with \the [I] but it doesn't seem to be effective!</span>")
			return
		else
			boutput(user, "<span class='notice'>You swipe the ID card opening the glass case.</span>") //now we can press the button
			src.icon_state = "self_destruct2"
			src.locked = FALSE
			return

	//timing process
	process()
		..()
		if(src.timing)
			src.time--
			if(src.time <= 0)
				src.detonate()
				return
			if (src.time <= 10)
				if (!last_announcement_made)
					command_alert("Self-destruction sequence initiated in [src.time] seconds. Countdown started. Evacuate immediately. Good luck.", "Morrigan Self Destruct", alert_origin = ALERT_STATION)
					last_announcement_made = TRUE
				boutput(world, "<span class='alert'><b>[src.time] seconds until nuclear charge detonation.</b></span>")
			else
				src.time -= 2
		return

//lockdown doors for morrigan (at least for now)

/obj/machinery/door/poddoor/buff/morrigan_lockdown
	name = "lockdown door"
	desc = "Door used for lockdowns."
	layer = OBJ_LAYER + 1
	autoclose = FALSE

	New()
		..()
		START_TRACKING
		open()

	disposing()
		STOP_TRACKING
		..()

/obj/fakeobjects/morrigan/broken_lockdown
	name = "lockdown door"
	desc = "Door used for lockdowns. This one seems to be malfunctioning."
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "pdoor0"
	layer = OBJ_LAYER + 1

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Collection Chute ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//side quest to unlock railgun - Rex
/obj/item/railgunpart
	name = "Railgun Part"
	icon = 'icons/obj/electronics.dmi'
	icon_state = "railpart"
	desc = "You're not too sure what to do with this."

/obj/item/collecting_chute
	name = "Collection chute"
	desc = "Semms like you're supposed to put stuff in it..."
	icon = 'icons/obj/disposal.dmi'
	icon_state = "matdrop"
	anchored = ANCHORED
	density = TRUE
	var/required_object = /obj/item/railgunpart
	var/complete = FALSE
	var/amount_required = 4

	attackby(obj/item/W, mob/user)
		if (src.complete)
			return ..()
		if (ON_COOLDOWN(src, "item_insert_cooldown", 3 SECONDS))
			boutput(user, "<span class='warning'>You have to wait before you put another item in!</span>")
			return ..()
		put_item(W, user)

	proc/put_item(var/obj/item/W, var/mob/user)
		if (istype(W, src.required_object))
			W.set_loc(src)
			user.u_equip(W)
			SPAWN(2 SECONDS)
				playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
		else
			W.set_loc(src)
			user.u_equip(W)
			SPAWN(2 SECONDS)
				W?.set_loc(get_turf(src))
				playsound(src, 'sound/machines/buzz-two.ogg', 40, TRUE)
			return
		if (length(src.contents) >= src.amount_required)
			playsound(src, 'sound/machines/chime.ogg', 40, TRUE)
			src.complete = TRUE
			for_by_tcl(D, /obj/machinery/door/poddoor/buff/railgun_door)
				D.open()
			for (var/item as anything in src.contents)
				qdel(item)
		// TODO ADD OFF STATE

/obj/machinery/activation_button/morrigan_cargo
	name = "Teleporter control"
	desc = "A switch used to teleport in a crate"
	var/turf/spawn_place = null
	var/list/crates = list(
		/obj/storage/crate/morrigancargo/engineer,
		/obj/storage/crate/morrigancargo/security,
		/obj/storage/crate/morrigancargo/medical
		)

	New()
		..()
		src.spawn_place = get_turf(landmarks[LANDMARK_MORRIGAN_CRATE_PUZZLE][1])

	activate()
		var/crate = pick(src.crates)
		new crate(src.spawn_place)
		showswirl(src.spawn_place)
		leaveresidual(src.spawn_place)

		sleep(10 SECONDS)

/obj/machinery/door/poddoor/buff/railgun_door
	name = "Railgun Storage"
	desc = "Door used to keep prying eyes away!."
	layer = OBJ_LAYER + 1
	autoclose = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

/obj/machinery/door/poddoor/blast/cargo
	name = "Cargo Door"
	desc = "A strong deterent against cargo!"
	autoclose = TRUE
	autoclose_delay =  1 SECONDS

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Sound Triggers ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/sound_trigger/morrigan
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0
	var/active = 0

/obj/sound_trigger/morrigan/steam_trigger

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(15 SECONDS) active = 0
					playsound(AM, pick('sound/ambience/morrigan/steamhiss.ogg'), 75, 0)

/obj/sound_trigger/morrigan/broken_phone

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/brokenphone.ogg'), 75, 0)

/obj/sound_trigger/morrigan/creak_metal

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/creakmetal.ogg'), 75, 0)

/obj/sound_trigger/morrigan/doorknock_trigger

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/knockamb.ogg'), 75, 0)

/obj/sound_trigger/morrigan/glass_break

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/glassbreak.ogg'), 75, 0)

/obj/sound_trigger/morrigan/metal_drop

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/metaldrop.ogg'), 75, 0)


/obj/sound_trigger/morrigan/glass_drop

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick('sound/ambience/morrigan/glassdrop.ogg'), 75, 0)

/obj/sound_trigger/morrigan/sparks

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(100))
					active = 1
					SPAWN(2 MINUTES) active = 0
					playsound(AM, pick(list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg','sound/effects/sparks5.ogg','sound/effects/sparks6.ogg'), 75, 0))


//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Lever Pipe Puzzle ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/lever/pipeswitch
	///The ID to match with the particular pipe
	var/id = null
	///The /obj/disposalpipe type to switch to, changes on switching
	var/switch_type = null

	on()
		src.do_switch()
	off()
		src.do_switch()

	proc/do_switch()
		if (!src.id || !src.switch_type)
			return

		for (var/obj/disposalpipe/pipe in by_cat[TR_CAT_SWITCHED_PIPES])
			if (pipe.id == src.id)
				var/pipe_type = pipe.type
				var/turf/T = get_turf(pipe)
				qdel(pipe)
				var/obj/disposalpipe/newpipe = new src.switch_type(T)
				newpipe.id = src.id
				OTHER_START_TRACKING_CAT(newpipe, TR_CAT_SWITCHED_PIPES)
				src.switch_type = pipe_type //so we switch back next time

/turf/simulated/wall/morrigan_cracked
	name = "wall"
	desc = "This wall seems damaged..."
	icon = 'icons/obj/adventurezones/Morrigan/turf.dmi'
	icon_state = "bustedwall"

	health = 30

	proc/take_damage(var/damage) // Let other walls support this later
		src.health -= damage
		if (src.health <= 0)
			new /obj/fakeobjects/morrigan/broken_wall(get_turf(src))
			src.ReplaceWith(/turf/unsimulated/floor/plating)

	attackby(obj/item/W, mob/user, params)
		user.lastattacked = src
		attack_particle(user, src)
		src.visible_message("<span class='alert'>[user ? user : "Someone"] hits [src] with [W].</span>", "<span class='alert'>You hit [src] with [W].</span>")
		src.take_damage(W.force / 2)

	dismantle_wall(devastated=0, keep_material = 1)
		return

	meteorhit()
		return

	ex_act(severity)
		return

	blob_act(var/power)
		return

/obj/fakeobjects/morrigan/broken_wall
	name = "collapsed wall"
	icon = 'icons/obj/adventurezones/Morrigan/turf.dmi'
	icon_state = "bustedwallc"
	anchored = ANCHORED_ALWAYS
	density = 0
	opacity = 0


/obj/item/storage/secure/ssafe/hossafe
	name = "Secure Safe"
	crackable = FALSE
	random_code = FALSE
	code = 50848
	code_len = 5
	configure_mode = FALSE

	spawn_contents = list(/obj/item/paper/morrigan/hospastpaper, /obj/item/paper/morrigan/hoshospital, /obj/item/paper/morrigan/hosoldteam, /obj/item/paper/morrigan/hospastpaper2, /obj/item/paper/morrigan/hosrecovered)

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Doors ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

/obj/machinery/door/airlock/pyro/syndicate_morrigan
	name = "Prisoner Transfer"
	icon_state = "synd_closed"
	icon_base = "synd"
	req_access = null

/obj/machinery/door/airlock/pyro/syndicate_cargo
	name = "Material Exports"
	icon_state = "min_closed"
	icon_base = "min"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/syndicate_morrigan
	name = "R&D Research"
	icon_state = "rnd_glass_closed"
	icon_base = "rnd_glass"
	req_access = null
