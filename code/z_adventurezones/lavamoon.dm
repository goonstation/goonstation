//CONTENTS
//Turfs
//Areas
//Logs
//Decor stuff
//Items
//Clothing
//Lavamoon blowout-esque irradiate event
//THE BOSS
//Puzzle elements

//Turfs
/turf/unsimulated/iomoon/floor
	name = "silicate crust"
	icon = 'icons/turf/floors.dmi'
	icon_state = "iocrust"
	opacity = 0
	density = 0
	carbon_dioxide = 20
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

/turf/unsimulated/iomoon/floor/arena
	name = "silicate crust"
	icon = 'icons/turf/floors.dmi'
	icon_state = "iocrust"
	opacity = 0
	density = 0
	carbon_dioxide = 0
	oxygen = 100
	temperature = T20C

/turf/unsimulated/iomoon/crustwall
	name = "silicate crust"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "iowall1"
	opacity = 1
	density = 1
	carbon_dioxide = 20
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

/turf/unsimulated/iomoon/plating
	name = "charred plating"
	desc = "Any protection this plating once had against the extreme heat appears to have given way."
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	opacity = 0
	density = 0

	carbon_dioxide = 20
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

	New()
		..()
		if (prob(33))
			src.AddOverlays(image(src.icon, "panelscorched"), "burn")

/turf/unsimulated/iomoon/ancient_floor
	name = "Ancient Metal Floor"
	desc = "The floor here is cold and dark.  Far colder than it has any right to be down here."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ancientfloor"

	opacity = 0
	density = 0

	temperature = 10+T0C

/turf/unsimulated/iomoon/ancient_wall
	name = "strange wall"
	desc = "It is dark, glassy and foreboding."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ancientwall"

	opacity = 1
	density = 1

	temperature = 10+T0C

var/list/iomoon_exterior_sounds = list('sound/ambience/nature/Lavamoon_DeepBubble1.ogg','sound/ambience/nature/Lavamoon_RocksBreaking1.ogg','sound/ambience/nature/Lavamoon_RocksBreaking2.ogg','sound/ambience/nature/Lavamoon_DeepBubble2.ogg')
var/list/iomoon_powerplant_sounds = list('sound/ambience/nature/Lavamoon_RocksBreaking1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg','sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg','sound/ambience/station/Machinery_PowerStation1.ogg','sound/ambience/station/Machinery_PowerStation2.ogg',"rustle",)
var/list/iomoon_basement_sounds = list('sound/ambience/industrial/LavaPowerPlant_SteamHiss1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg','sound/machines/engine_grump4.ogg','sound/machines/hiss.ogg','sound/vox/smoke.ogg','sound/effects/pump.ogg')
var/list/iomoon_ancient_sounds = list('sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg','sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg','sound/ambience/industrial/AncientPowerPlant_Drone2.ogg')
var/sound/iomoon_alarm_sound = null

/turf/unsimulated/floor/logo_xg
	name = "XIANG|GIESEL"
	desc = "A floor sign with the logo for XIANG|GIESEL Advanced Power Systems, GmbH."
	icon = 'icons/turf/adventure.dmi'
	icon_state = "logo_xg1"

//Areas
/area/iomoon
	name = "Lava Moon Surface"
	icon_state = "red"
	filler_turf = "/turf/unsimulated/floor/lava"
	requires_power = 0
	force_fullbright = 0
	ambient_light = rgb(0.45 * 255, 0.2 * 255, 0.1 * 255)
	sound_group = "iomoon"
	sound_loop = 'sound/ambience/nature/Lavamoon_FireCrackling.ogg'
	sound_loop_vol = 60
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/io_moon
	var/list/sfx_to_pick_from = null

	/// Value to set irradiated to during the mini-blowout.
	var/radiation_level = 0.5
	var/use_alarm = FALSE

/area/iomoon/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	sfx_to_pick_from = iomoon_exterior_sounds

	if (use_alarm && !iomoon_alarm_sound)
		iomoon_alarm_sound = new/sound('sound/machines/lavamoon_alarm1.ogg', FALSE, FALSE, VOLUME_CHANNEL_AMBIENT, 60)
		iomoon_alarm_sound.priority = 255
		iomoon_alarm_sound.status = SOUND_UPDATE | SOUND_STREAM

/area/iomoon/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/iomoon/area_process()
	if(prob(20))
		src.sound_fx_2 = pick(sfx_to_pick_from)

		var/list/client/client_list = list()
		for(var/mob/living/carbon/human/H in src)
			if(H.client)
				client_list += H.client
				H.client.playAmbience(src, AMBIENCE_FX_2, 50)

		if (use_alarm && iomoon_blowout_state == 1 && length(client_list))
			playsound_global(client_list, iomoon_alarm_sound, 50, channel = VOLUME_CHANNEL_AMBIENT)

/area/iomoon/base
	name = "Power Plant"
	icon_state = "yellow"
	filler_turf = "/turf/unsimulated/iomoon/floor"
	requires_power = 1
	force_fullbright = 0
	ambient_light = rgb(0.3 * 255, 0.3 * 255, 0.3 * 255)
	sound_loop = 'sound/ambience/industrial/LavaPowerPlant_Rumbling1.ogg'
	use_alarm = 1
	occlude_foreground_parallax_layers = TRUE
	New()
		. = ..()
		sfx_to_pick_from = iomoon_powerplant_sounds


/area/iomoon/base/underground
	name = "Power Plant Tunnels"
	sound_loop = 'sound/ambience/industrial/LavaPowerPlant_Rumbling2.ogg'
	area_parallax_render_source_group = null

	New()
		. = ..()
		sfx_to_pick_from = iomoon_basement_sounds

/area/iomoon/caves
	name = "Magma Cavern"
	filler_turf = "/turf/unsimulated/floor/lava"
	requires_power = 1
	force_fullbright = 0
	luminosity = 0
	area_parallax_render_source_group = null
	radiation_level = 0.75

	New()
		. = ..()
		sfx_to_pick_from = iomoon_exterior_sounds

/area/iomoon/robot_ruins
	name = "Strange Ruins"
	icon_state = "purple"
	filler_turf = "/turf/unsimulated/iomoon/ancient_floor"
	requires_power = 1
	force_fullbright = 0
	luminosity = 0
	teleport_blocked = AREA_TELEPORT_BLOCKED
	area_parallax_render_source_group = null
	radiation_level = 0.8
	sound_loop = 'sound/ambience/industrial/AncientPowerPlant_Drone1.ogg'

	New()
		. = ..()
		sfx_to_pick_from = iomoon_ancient_sounds

/area/iomoon/robot_ruins/boss_chamber
	name = "Central Chamber"
	icon_state = "blue"
	radiation_level = 1
	sound_loop = 'sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg'


//Logs
/obj/item/audio_tape/iomoon_00
	New()
		..()
		messages = list("...s is Janet Habicht, Operations Manager.",
"Something is very wrong with the plant, stay awa-",
"*static*",
"*static*",
"it's in the caverns, the-",
"*static*")
		speakers = list("Female Voice","Female Voice","Female Voice","Female Voice","Female Voice","Female Voice")

/obj/item/audio_tape/iomoon_01
	New()
		..()
		speakers = list("Female Voice",
		"Female Voice",
		"Female Voice",
		"Female Voice",
		"Female Voice",
		"Female Voice",
		"Female Voice",
		"Female Voice")
		messages = list("*heavy breathing*",
"-hair's falling out...blood's coming up when I cough",
"I can't have long.",
"*heavy breathing, coughing*",
"If you are listening to this, get out. there is nothing but death here.",
"*coughing, labored breathing*",
"*labored breathing*",
"I'm sorry, Amy, I'm so so sorry.  Be good.")

/obj/item/device/audio_log/iomoon_01

	New()
		..()
		src.tape = new /obj/item/audio_tape/iomoon_01(src)

/obj/machinery/computer3/luggable/personal/iomoon
	name = "Research Laptop"
	desc = "A portable computer used for away team-style research."
	setup_drive_type = /obj/item/disk/data/fixed_disk/iomoon

/obj/item/disk/data/fixed_disk/iomoon

	New()
		..()
		//First off, create the directory for logging stuff
		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "logs"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/c3help(src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))
		//new
		newfolder = new /datum/computer/folder
		newfolder.name = "doc"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/iomoon_corrupt(src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_04(src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_06(src))
		newfolder.add_file( new /datum/computer/file/record/iomoon_corrupt/iomoon_08(src) )

/obj/item/luggable_computer/personal/iomoon
	name = "Research Laptop"
	desc = "A portable computer used for away team-style research."
	luggable_type = /obj/machinery/computer3/luggable/personal/iomoon

/datum/computer/file/record/iomoon_04
	name = "log04"
	fields = list("|--------------| Log 04 |--------------|",
	"We have now managed to breach the outer ",
	"shell of the obsidian structure. And the",
	"wonders we have found inside! Beyond the",
	"outer surface is a series of chambers.",
	"A base camp is now under construction in",
	"a room near our entry point. In the",
	"coming days, I hope to determine the age",
	"of the structure, map it out, and maybe",
	"begin to discern its purpose.",
	"|--------------------------------------|")

/datum/computer/file/record/iomoon_06
	name = "log06"
	fields = list("|--------------| Log 06 |--------------|",
	"I am as of yet unsure as to the nature",
	"of the floating constructs, but it is",
	"probable that they are some manner of",
	"repair mechanism. After a minor incident",
	"I must stress that physical contact with",
	"the constructs is completely inadvisable.",
	"A shame, really. Whatever mechanism they",
	"use for their flight-the efficiency alone",
	"could revolutionize XG power storage.",
	"",
	"Ambient radiation levels in the chambers",
	"have continued to rise, slowly. They are",
	"fully within the tolerances of our suits,",
	"however.",
	"|--------------------------------------|")

/datum/computer/file/record/iomoon_07
	name = "log07"
	fields = list("|--------------| Log 07 |--------------|",
	"Further ingress into the chambers has",
	"exposed a large magma containment vessel.",
	"This, coupled with the large number of",
	"energetic power conduits, indicates that",
	"this is a power production facility much",
	"like our own, but vastly more advanced!",
	"If only#&!@()(#)",
	"ffj&@____ +_122 )_*#=",
	"|--------------------------------------|")

/datum/computer/file/record/iomoon_corrupt
	name = "log03"
	fields = list("|--------------| ERR 00 |--------------|",
"39293-ff0eKJFIie fjf f f  a a 201-_98*",
"1 ( 1-2 ** _* **_ | /  / _____ffe",
"|--------------------------------------|")

	iomoon_08
		name = "log08"

/obj/machinery/computer3/generic/personal/iomoon
	setup_starting_program = /datum/computer/file/terminal_program/email/iomoon

/datum/computer/file/terminal_program/email/iomoon
	defaultDomain = "XG5"

//Mainframe
/obj/machinery/networked/mainframe/iomoon
	setup_drive_type = /obj/item/disk/data/memcard/iomoon


/obj/item/disk/data/memcard/iomoon
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
		//subfolder.add_file ( new FILEPATH GOES HERE )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/databank(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/printer(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/radio(src) )
		subfolder.add_file( new /datum/computer/file/mainframe_program/driver/mountable/service_terminal(src) )

		subfolder = new /datum/computer/folder
		subfolder.name = "srv"
		newfolder.add_file( subfolder )
		var/datum/computer/file/mainframe_program/srv/email/emailsrv = new /datum/computer/file/mainframe_program/srv/email(src)
		emailsrv.defaultDomain = "XG5"
		subfolder.add_file( emailsrv )
		subfolder.add_file( new /datum/computer/file/mainframe_program/srv/print(src) )

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
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/su(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/cp(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mv(src) )
		newfolder.add_file( new /datum/computer/file/mainframe_program/utility/mount(src) )
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
		testR.fields += "This System Licensed to XIANG|GIESEL Advanced Power Systems"
		newfolder.add_file( testR )

		newfolder.add_file( new /datum/computer/file/record/dwaine_help(src) )

		newfolder = new /datum/computer/folder
		newfolder.name = "etc"
		newfolder.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER
		src.root.add_file( newfolder )

		subfolder = new /datum/computer/folder
		subfolder.name = "mail"
		newfolder.add_file( subfolder )

		var/datum/computer/file/record/groupRec = new /datum/computer/file/record( )
		groupRec.name = "groups"
		subfolder.add_file( groupRec )

		subfolder.add_file( new /datum/computer/file/record/iomoon_mail/rad_advisory(src) )
		subfolder.add_file( new /datum/computer/file/record/iomoon_mail/flights(src) )
		subfolder.add_file( new /datum/computer/file/record/iomoon_mail/cleanliness(src) )
		subfolder.add_file( new /datum/computer/file/record/iomoon_mail/magma_chamber(src) )

		return

/datum/computer/file/record/iomoon_mail
	New()
		..()
		src.name = "[copytext("\ref[src]", 4, 12)]GENERIC"

	flights
		New()
			..()
			fields = list("PUBLIC_XG",
			"*ALL",
			"SHIFT_COORDINATOR@CORPORATE.XG",
			"GENERIC@XG5",
			"HIGH",
			"End-shift flight delays",
			"Hello Staff,",
			"In spite of our extensive efforts and much communication with the",
			"shuttle lines, we have been unable to secure transit to bring in",
			"the next shift. We are all deeply sorry for this, and assure you",
			"that you will all be compensated appropriately for the extra",
			"duty time.",
			"Current expectations are no more than a month delay, which",
			"is well within plant operation and supply tolerances.",
			"",
			"Again, we apologize for the wait.  Please bear with us.",
			"Johann Eisenhauer",
			"XIANG|GIESEL Advanced Power Systems")

	rad_advisory
		New()
			..()
			fields = list("PUBLIC_XG",
			"*ALL",
			"LOCALHOST",
			"GENERIC@XG5",
			"HIGH",
			"AUTOMATED ALERT",
			"This is an automated alert message sent as part of the XIANG|GIESEL",
			"AUTOMATED HAZARD WARNING SYSTEM. This message has been sent due to",
			"the detection of a critical safety hazard by plant sensors.",
			"",
			"!! CRITICAL RADIATION HAZARD DETECTED !!",
			"All personnel are to evacuate to the landing pad safety area at",
			"once and wait for further instructions.",
			"THIS IS NOT A DRILL")

	cleanliness
		New()
			..()
			fields = list("PUBLIC_XG",
			"*ALL",
			"JHABICHT@XG5",
			"GENERIC@XG5",
			"NORMAL",
			"Plant Cleanliness",
			"Hey folks,",
			"I had really hoped it wouldn't have come to this, but this looks",
			"to be the only way: clean up after yourselves, or the SHAME BOARD",
			"will be trotted back out.",
			"*Keep your work area free of wrappers and other trash.",
			"*Keep the restroom in good condition, there is only one in this",
			" module.  THIS MEANS YOU, GARY.",
			"*The break room doesn't clean itself!  Trash goes in the trash bins!")

	magma_chamber
		New()
			..()
			fields = list("PUBLIC_XG",
			"*ALL",
			"JHABICHT@XG5",
			"GENERIC@XG5",
			"HIGH",
			"Magma Chamber Safety",
			"Believe me, I know that our recent discovery down there is",
			"fascinating, but that's no reason to ignore existing regulations",
			"and safety procedures in place for the magma chamber area.")

//Items

/obj/item/radio_tape/adventure/xg
	name = "XIANG|GIESEL Onboarding Tape 1"
	desc = "A magnetic tape of recorded audio trainings. Some oaf left it outside of the storage case!"
	audio = 'sound/radio_station/xg_onboarding1.ogg'

/obj/item/radio_tape/adventure/xg2
	name = "XIANG|GIESEL Onboarding Tape 2"
	desc = "A magnetic tape of recorded audio trainings. Some oaf left it outside of the storage case!"
	audio = 'sound/radio_station/xg_onboarding2.ogg'

/obj/item/radio_tape/adventure/xg3
	name = "XIANG|GIESEL Onboarding Tape 3"
	desc = "A magnetic tape of recorded audio trainings. Some oaf left it outside of the storage case!"
	audio = 'sound/radio_station/xg_onboarding3.ogg'

/obj/item/radio_tape/adventure/xg4
	name = "XIANG|GIESEL Onboarding Tape 4"
	desc = "A magnetic tape of recorded audio trainings. Some oaf left it outside of the storage case!"
	audio = 'sound/radio_station/xg_onboarding4.ogg'



/obj/storage/crate/classcrate/xg
	name = "shielded crate"
	desc = "A hefty case for flux-sensitive materials."

/obj/spawner/ancient_robot_artifact
	name = "robot artifact spawn"
	icon = 'icons/misc/mark.dmi'
	icon_state = "x3"

	New()
		..()
		SPAWN(1 SECOND)
			var/spawntype = pick(/obj/item/artifact/activator_key, /obj/item/gun/energy/artifact, /obj/item/ammo/power_cell/self_charging/artifact, /obj/item/artifact/forcewall_wand)
			new spawntype(src.loc, "ancient")

			qdel(src)


/*
 *	UNKILLABLE shield. It makes dudes unkillable, it is not unkillable itself.
 */

/obj/item/unkill_shield
	name = "Shield of Souls"
	desc = "It appears to be a metal shield with blue LEDs glued to it."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "magic"

	attack_hand(mob/user)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			boutput(user, "<i><b><font face = Tempus Sans ITC>EI NATH</font></b></i>")
			logTheThing(LOG_COMBAT, H, "Becomes unkillable via Shield of Souls (unkill_shield))")

			//EI NATH!!
			elecflash(user,radius = 2, power = 6)

			H.unkillable = 1
			H.setStatus("maxhealth-", null, -90)
			H.gib(1)
			qdel(src)
		else
			. = ..()

//Clothing & Associated Equipment
/obj/item/clothing/suit/hazard/rad/iomoon
	name = "FB-8 Environment Suit"
	desc = "A rather old-looking suit designed to guard against extreme heat and radiation."
	icon_state = "rad_io"
	item_state = "rad_io"
	protective_temperature = 7500

	setupProperties()
		..()
		setProperty("coldprot", 30)
		setProperty("heatprot", 95)

/obj/item/clothing/head/rad_hood/iomoon
	name = "FB-8 Environment Hood"
	desc = "The paired hood to the FB-8 environment suit. Not in the least stylish."
	icon_state = "radhood"
	item_state = "radhood"

/obj/storage/closet/iomoon
	name = "\improper Thermal Hazard Equipment"
	desc = "A locker intended to carry protective clothing."
	icon_state = "syndicate"
	icon_opened = "syndicate-open"
	icon_closed = "syndicate"
	spawn_contents = list(/obj/item/clothing/suit/hazard/rad/iomoon,\
	/obj/item/clothing/head/rad_hood/iomoon)

/obj/machinery/light/small/iomoon
	name = "emergency light"
	light_type = /obj/item/light/bulb/emergency

//Irradiate event.
var/global/iomoon_blowout_state = 0 //0: Hasn't occurred, 1: Moon is irradiated & Boss is alive, 3: Boss killed, radiation over, -1: Something broke, so much for that.
/proc/event_iomoon_blowout()
	if (iomoon_blowout_state)
		return

	var/obj/iomoon_boss/core/theBoss = locate("IOMOON_BOSS")
	if (istype(theBoss))
		theBoss.base.icon_state = "powercore_base_start"
		theBoss.top.icon_state = "powercore_core_start"
		SPAWN(3.1 SECONDS)
			theBoss.base.icon_state = "powercore_base_active"
			theBoss.top.icon_state = "powercore_core_active"
		SPAWN(1.9 SECONDS)
			playsound(theBoss.loc, 'sound/machines/lavamoon_rotors_starting.ogg', 50, 0)
			theBoss.last_noise_time = ticker.round_elapsed_ticks
			theBoss.last_noise_length = 80
	sleep(1.9 SECONDS)
	iomoon_blowout_state = 1

	message_admins("EVENT: IOMOON mini-blowout event triggered.")
	var/list/iomoon_areas = get_areas(/area/iomoon)
	if (!iomoon_areas.len)
		iomoon_blowout_state = -1
		logTheThing(LOG_DEBUG, null, "IOMOON: Unable to locate areas for event_iomoon_blowout.")
		return

	for (var/area/iomoon/adjustedArea in iomoon_areas)
		adjustedArea.irradiated = adjustedArea.radiation_level

		for(var/mob/N in adjustedArea)
			N.flash(1 SECONDS)

			SPAWN(0)
				shake_camera(N, 210, 16)
	//todo: Alarms.  Not the dumb siren, I mean like the power plant's computer systems freaking the fuck out because oh jesus radiation

	var/obj/machinery/networked/mainframe/mainframe = locate("IOMOON_MAINFRAME")
	if (istype(mainframe) && mainframe.hd)
		for (var/datum/computer/folder/folder1 in mainframe.hd.root.contents)
			if (ckey(folder1.name) == "etc")
				for (var/datum/computer/folder/folder2 in folder1.contents)
					if (ckey(folder2.name) == "mail")
						folder2.add_file( new /datum/computer/file/record/iomoon_mail/rad_advisory )
						break

				break

	if (istype(theBoss))
		theBoss.activate()

	return

/proc/end_iomoon_blowout()
	if (iomoon_blowout_state != 1)
		return

	iomoon_blowout_state = -1
	message_admins("EVENT: IOMOON mini-blowout event ending.")
	var/list/iomoon_areas = get_areas(/area/iomoon)
	if (!iomoon_areas.len)
		iomoon_blowout_state = -1
		logTheThing(LOG_DEBUG, null, "IOMOON: Unable to locate areas for end_iomoon_blowout. Welp!")
		return

	for (var/area/iomoon/adjustedArea in iomoon_areas)
		adjustedArea.irradiated = 0

	var/obj/iomoon_puzzle/ancient_robot_door/prizedoor = locate("IOMOON_PRIZEDOOR")
	if (istype(prizedoor))
		prizedoor.open()

	return

//THE BOSS
#define PREZAP_WAIT 15
#define REZAP_WAIT 10
#define PANIC_HEALTH_LEVEL 30
#define STATE_DEFAULT 0
#define IOCORE_INACTIVE 0
#define IOCORE_ACTIVE 1
#define IOCORE_DEAD 2
#define STATE_MARKER_OUT 1
#define STATE_RECHARGING 2

/obj/iomoon_boss
	anchored = ANCHORED
	density = 1

	ex_act(severity)
		return 0

	activation_button
		name = "foreboding panel"
		desc = "Pressing this would probably be a bad idea."
		icon = 'icons/misc/worlds.dmi'
		icon_state = "boss_button0"
		layer = OBJ_LAYER
		var/b_pressed = FALSE

		attack_hand(mob/user)
			if (user.stat || user.getStatusDuration("knockdown") || BOUNDS_DIST(user, src) > 0 || !user.can_use_hands())
				return

			user.visible_message(SPAN_ALERT("[user] presses [src]."), SPAN_ALERT("You press [src]."))
			if (b_pressed)
				boutput(user, "Nothing happens.")
				return

			b_pressed = TRUE
			FLICK("boss_button_activate", src)
			src.icon_state = "boss_button1"

			playsound(src.loc, 'sound/machines/lavamoon_alarm1.ogg', 70,0)
			sleep(4 SECONDS)
			event_iomoon_blowout()

	bot_spawner
		name = "weird assembly"
		desc = "It looks like a tesla coil mated with a crab."
		icon = 'icons/misc/worlds.dmi'
		icon_state = "bot_spawner"
		var/functional = TRUE
		var/makingbot = FALSE
		var/health = 20
		var/max_bots = 5

		attackby(obj/item/I, mob/user as mob)
			if (!I.force || health <= 0)
				return

			user.lastattacked = get_weakref(src)
			user.visible_message(SPAN_ALERT("<b>[user] bonks [src] with [I]!</b>"),SPAN_ALERT("<b>You hit [src] with [I]!</b>"))
			if (iomoon_blowout_state == 0)
				playsound(src.loc, 'sound/machines/lavamoon_alarm1.ogg', 70,0)
				event_iomoon_blowout()
				return

			if (I.hit_type == DAMAGE_BURN)
				src.health -= I.force * 0.25
			else
				src.health -= I.force * 0.5


			if (src.health <= 0 && src.functional)
				src.icon_state = "bot_spawner_dead"
				src.functional = FALSE
				src.visible_message(SPAN_ALERT("[src] shuts down. Forever."))
				return



		proc/spawn_bot()
			if (makingbot || !functional || (max_bots  < 1))
				return -1

			makingbot = TRUE
			src.icon_state = "bot_spawner_start"
			SPAWN(0.7 SECONDS)
				src.icon_state = "bot_spawner_active"
			src.visible_message(SPAN_ALERT("[src] begins to whirr ominously!"))
			SPAWN(2 SECONDS)
				if (health <= 0)
					src.icon_state = "bot_spawner_dead"
					return
				if(prob(50)) //cheese reduction
					src.visible_message(SPAN_ALERT("[src] produces a terrifying vibration!"))
					for(var/atom/A in orange(3, src))
						if(!(ismob(A) || iscritter(A))) //only target inanimate objects mostly
							A.ex_act(1)
				sleep(1 SECOND)
				if (health <= 0)
					src.icon_state = "bot_spawner_dead"
					return
				src.icon_state = "bot_spawner_finish"
				sleep (0.4 SECONDS)
				if (prob(80))
					new /mob/living/critter/robotic/repairbot (src.loc)
				else
					new /mob/living/critter/robotic/repairbot/security (src.loc)
				max_bots--

				src.visible_message(SPAN_ALERT("[src] plunks out a robot! Oh dear!"))
				makingbot = FALSE

			return

	core
		name = "mechanism core"
		desc = "An enormous artifact of some sort. You feel uncomfortable just being near it."
		icon = 'icons/effects/96x96.dmi'
		icon_state = "powercore_core"
		layer = 10 // TODO LAYER
		plane = PLANE_NOSHADOW_ABOVE

		var/status = IOCORE_INACTIVE
		var/health = 100
		var/obj/iomoon_boss/top/top = null
		var/obj/iomoon_boss/base/base = null
		var/obj/iomoon_boss/zap_marker/zapMarker = null
		var/last_state_time = 0
		var/last_noise_time = 0
		var/last_noise_length = 0

		var/list/spawners = list()

		var/state = STATE_DEFAULT
/*
		//DEBUG
		default_click()
			SPAWN(0)
				activate()
				sleep(20 SECONDS)
				//world << zap_somebody(usr)
				//sleep(5 SECONDS)
				death()
*/
		New()
			..()
			if (!tag)
				tag = "IOMOON_BOSS"

			SPAWN(1 SECOND)
				//target_marker = image('icons/misc/worlds.dmi', "boss_marker")
				//target_marker.layer = FLY_LAYER

				base = new /obj/iomoon_boss/base (locate(src.x - 2, src.y - 2, src.z))
				base.core = src

				top = new /obj/iomoon_boss/top (base.loc)

				zapMarker = new /obj/iomoon_boss/zap_marker (src)

				for (var/obj/iomoon_boss/bot_spawner/spawner in range(src, 10))
					spawners += spawner

		attackby(obj/item/I, mob/user as mob)
			if (!I.force || src.status != IOCORE_ACTIVE)
				return

			user.lastattacked = get_weakref(src)
			if (I.hit_type == DAMAGE_BURN)
				src.health -= I.force * 0.25
			else
				src.health -= I.force * 0.5

			user.visible_message(SPAN_ALERT("<b>[user] bonks [src] with [I]!</b>"),SPAN_ALERT("<b>You hit [src] with [I]!</b>"))
			if (src.health <= 0)
				death()
				return

			else if (src.health <= PANIC_HEALTH_LEVEL)
				if (spawners)
					for (var/obj/iomoon_boss/bot_spawner/aSpawner in spawners)
						aSpawner.spawn_bot()
				if (base || iomoon_blowout_state == 1)
					base.icon_state = "powercore_base_fast"

			if (!ON_COOLDOWN(top, "hit_effect", 0.7 SECONDS))
				top.icon_state = "powercore_core_hit"
				playsound(src.loc, 'sound/machines/lavamoon_core_hit.ogg', 50, 0)
				SPAWN(0.6 SECONDS)
					if (src.status == IOCORE_ACTIVE && src.health <= PANIC_HEALTH_LEVEL)
						top.icon_state = "powercore_core_fast"
					else if (src.status == IOCORE_ACTIVE)
						top.icon_state = "powercore_core_active"
					else if (src.status == IOCORE_DEAD)
						top.icon_state = "powercore_core_dead"


		attack_hand(var/mob/user)
			if (src.status != IOCORE_ACTIVE)
				return

			user.lastattacked = get_weakref(src)
			if (user.a_intent == "harm")
				src.health -= rand(1,2) * 0.5
				user.visible_message(SPAN_ALERT("<b>[user]</b> punches [src]!"), SPAN_ALERT("You punch [src]![prob(25) ? " It's about as effective as you would expect!" : null]"))
				playsound(src.loc, "punch", 50, 1)

			else
				src.visible_message(SPAN_ALERT("<b>[user]</b> pets [src]!  For some reason!"))

		bullet_act(var/obj/projectile/P)

			if (src.status != IOCORE_ACTIVE)
				return

			if(P.proj_data.damage_type == D_KINETIC || P.proj_data.damage_type == D_PIERCING)
				src.health -= round(((P.power/8)*P.proj_data.ks_ratio), 1.0)

			if (src.health <= 0)
				death()

			else if (src.health <= PANIC_HEALTH_LEVEL)
				if (spawners)
					for (var/obj/iomoon_boss/bot_spawner/aSpawner in spawners)
						aSpawner.spawn_bot()
				if (base)
					base.icon_state = "powercore_base_fast"
					top.icon_state = "powercore_core_fast"

			return

		disposing()
			base = null
			top = null
			zapMarker = null
			if (spawners)
				spawners.len = 0

			..()

		proc
			activate()
				if (src.status != IOCORE_INACTIVE)
					return

				src.status = IOCORE_ACTIVE


				START_TRACKING_CAT(TR_CAT_CRITTERS)

			process()
				SHOULD_NOT_SLEEP(TRUE)
				if (last_noise_time + last_noise_length < ticker.round_elapsed_ticks)
					if (health <= 10)
						playsound(src.loc, 'sound/machines/lavamoon_rotors_fast.ogg', 50, 0)
						last_noise_length = 90
					else
						playsound(src.loc, 'sound/machines/lavamoon_rotors_slow.ogg', 50, 0)
						last_noise_length = 70

					last_noise_time = ticker.round_elapsed_ticks


				switch (state)
					if (STATE_DEFAULT)
						plunk_down_marker()
						if (length(spawners))
							var/obj/iomoon_boss/bot_spawner/aSpawner = pick(spawners)
							aSpawner.spawn_bot()

					if (STATE_MARKER_OUT)
						if (ticker.round_elapsed_ticks >= (last_state_time + PREZAP_WAIT))
							zap_somebody()

					if (STATE_RECHARGING)
						if (ticker.round_elapsed_ticks >= (last_state_time + REZAP_WAIT))
							state = STATE_DEFAULT

			plunk_down_marker()
				if (!src.zapMarker)
					src.zapMarker = new /obj/iomoon_boss/zap_marker(src)

				var/turf/newLoc
				switch (rand(1, 10))
					if (1)
						newLoc = locate(src.x, src.y + 4, src.z)

					if (2)
						newLoc = locate(src.x + 3, src.y + 3, src.z)

					if (3)
						newLoc = locate(src.x + 4, src.y, src.z)

					if (4)
						newLoc = locate(src.x + 3, src.y - 3, src.z)

					if (5)
						newLoc = locate(src.x, src.y - 4, src.z)

					if (6)
						newLoc = locate(src.x - 3, src.y - 4, src.z)

					if (7)
						newLoc = locate(src.x - 4, src.y, src.z)

					if (8)
						newLoc = locate(src.x - 3, src.y + 3, src.z)

					if (9 to 10)
						newLoc = locate (src.x + rand(-1, 1), src.y + rand(-1, 1), src.z)

				if (newLoc)
					zapMarker.set_loc(newLoc)
					last_state_time = ticker.round_elapsed_ticks
					state = STATE_MARKER_OUT

				return 0

			death()
				if (src.status == IOCORE_DEAD)
					return

				if (istype(get_area(src), /area/iomoon/robot_ruins/boss_chamber))
					for (var/mob/living/L in range(6, src))
						if (!isintangible(L))
							L.unlock_medal("What's Buried Stays Buried", TRUE)

				STOP_TRACKING_CAT(TR_CAT_CRITTERS)

				src.status = IOCORE_DEAD
				if (src.zapMarker)
					src.zapMarker.dispose()
					src.zapMarker = null

				end_iomoon_blowout()
				SPAWN(0)
					var/datum/effects/system/spark_spread/E = new /datum/effects/system/spark_spread
					E.set_up(8,0, src.loc)
					E.start()
					if (base)
						base.icon_state = "powercore_base_stop"
						top.icon_state = "powercore_core_stop"
						playsound(src.loc, 'sound/machines/lavamoon_rotors_stopping.ogg', 50, 1)
					sleep (2 SECONDS)

					var/obj/overlay/O = new/obj/overlay( src.loc )
					O.anchored = ANCHORED
					O.name = "Explosion"
					O.layer = NOLIGHT_EFFECTS_LAYER_BASE
					O.pixel_x = -92
					O.pixel_y = -96
					O.icon = 'icons/effects/214x246.dmi'
					O.icon_state = "explosion"
					playsound(src.loc, "explosion", 75, 1)
					base.icon_state = "powercore_base_dead"
					top.icon_state = "powercore_core_dead"
					sleep(2.5 SECONDS)
					//qdel(rotors)
					src.invisibility = INVIS_ALWAYS_ISH

					var/obj/decal/exitMarker = locate("IOMOON_BOSSDEATH_EXIT")
					if (istype(exitMarker))
						var/obj/laser_sink/perm_portal/portalOut = new
						portalOut.target = get_turf(exitMarker)
						portalOut.icon = 'icons/misc/worlds.dmi'
						portalOut.icon_state = "jitterportal"
						portalOut.layer = 8 // TODO layer
						portalOut.set_loc(src.loc)

					sleep(1 SECOND)
					if (O)
						O.dispose()
					qdel(src)

			zap_somebody()
				if (!zapMarker || zapMarker.loc == src)
					return -1

				playsound(src, 'sound/effects/elec_bigzap.ogg', 40, TRUE)

				var/list/lineObjs
				lineObjs = drawLineObj(src, zapMarker, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

				for (var/mob/living/poorSoul in range(zapMarker, 2))
					lineObjs += drawLineObj(zapMarker, poorSoul, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

					poorSoul.shock(src, 1250000, "chest", 0.15, 1)
					if (isdead(poorSoul) && prob(25))
						poorSoul.gib()

				SPAWN(0.6 SECONDS)
					for (var/obj/O in lineObjs)
						qdel(O)

				state = STATE_RECHARGING
				last_state_time = ticker.round_elapsed_ticks
				zapMarker.set_loc(src)

				return 0

	base
		name = "huge contraption"
		desc = "An enormous artifact of some sort. You feel uncomfortable just being near it. Probably because it is a giant piece of dangerous machinery."
		anchored = ANCHORED
		density = 0
		icon = 'icons/effects/160x160.dmi'
		icon_state = "powercore_base"
		bound_height = 160
		bound_width = 160
		layer = 3.2 // TODO layer
		plane = PLANE_NOSHADOW_BELOW
		var/obj/iomoon_boss/core/core = null

	top
		name = "mechanism core"
		desc = "An enormous artifact of some sort. You feel uncomfortable just being near it. Probably because it is a giant piece of dangerous machinery."
		anchored = ANCHORED
		density = 0
		icon = 'icons/effects/160x160.dmi'
		icon_state = "powercore_core"
		bound_height = 160
		bound_width = 160
		layer = 7 // TODO layer
		plane = PLANE_NOSHADOW_ABOVE
		var/obj/iomoon_boss/core/core = null

	zap_marker
		name = "danger zone"
		desc = "Some sort of light phenomena indicating that this area is hazardous.  Do NOT take a highway to it."
		density = 0
		layer = 5 // TODO layer
		icon = 'icons/effects/64x64.dmi'
		icon_state = "boss_marker"
		pixel_x = -16
		pixel_y = -16

#undef PREZAP_WAIT
#undef REZAP_WAIT
#undef PANIC_HEALTH_LEVEL
#undef IOCORE_INACTIVE
#undef IOCORE_ACTIVE
#undef IOCORE_DEAD
#undef STATE_DEFAULT
#undef STATE_MARKER_OUT
#undef STATE_RECHARGING


/obj/fakeobject/tallsmes
	name = "large power storage unit"
	desc = "An ultra-high-capacity superconducting magnetic energy storage (SMES) unit."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "tallsmes0"
	anchored = ANCHORED
	density = 1

	New()
		..()
		var/image/I = image(src.icon, icon_state="tallsmes1")
		I.pixel_y = 32
		I.layer = FLY_LAYER
		src.overlays += I

//Puzzle elements

/obj/iomoon_puzzle
	var/id = null
	proc
		activate()

		deactivate()

	ex_act(severity)
		return


//ancient robot door
/obj/iomoon_puzzle/ancient_robot_door
	name = "sealed door"
	desc = "Not only is it one hell of a foreboding door, it's also sealed fast.  It doesn't have any apparent means of opening."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ancientwall2"
	density = 1
	anchored = ANCHORED
	opacity = 1
	var/active = 0
	var/opened = 0
	var/changing_state = 0
	var/default_state = 0 //0: closed, 1: open

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.default_state = src.opened
			active = 0

	proc
		open()
			if (opened || changing_state == 1)
				return

			opened = 1
			changing_state = 1
			active = (opened != default_state)

			FLICK("ancientdoor_open",src)
			src.icon_state = "ancientdoor_opened"
			set_density(0)
			set_opacity(0)
			desc = "One hell of a foreboding door. It's not entirely clear how it opened, as the seams did not exist prior..."
			src.name = "unsealed door"
			SPAWN(1.3 SECONDS)
				changing_state = 0
			return


		close()
			if (!opened || changing_state == -1)
				return

			opened = 0
			changing_state = -1
			active = (opened != default_state)

			set_density(1)
			set_opacity(1)
			FLICK("ancientdoor_close",src)
			src.icon_state = "ancientwall2"
			desc = initial(src.desc)
			src.name = initial(src.name)
			SPAWN(1.3 SECONDS)
				changing_state = 0
			return

		toggle()
			if (opened)
				return close()
			else
				return open()

	activate()
		if (active)
			return

		if (opened)
			return close()

		return open()

	deactivate()
		if (!active)
			return

		if (opened)
			return close()

		return open()

/obj/iomoon_puzzle/ancient_robot_door/energy
	name = "energy field"
	desc = "A field of energy!  Some sort of energy.  Probably a really weird one."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "energywall"
	opacity = 0
	var/obj/iomoon_puzzle/ancient_robot_door/energy/next = null
	dir = EAST
	var/length = 1
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.8,1,0)
		light.set_brightness(0.4)


		if (length > 1)
			var/obj/iomoon_puzzle/ancient_robot_door/energy/current = src
			while (length-- > 1)
				current.next = new src.type ( get_step(current, src.dir) )
				current.next.set_dir(current.dir)
				current.next.opened = src.opened
				current = current.next

		SPAWN(1 SECOND)
			if (src.opened)
				src.invisibility = INVIS_ALWAYS_ISH
				src.set_density(0)
				light.enable()
			else
				light.disable()

	disposing()
		if (next)
			next.dispose()
			next = null

		..()

	open()
		if (opened || changing_state == 1)
			return

		opened = 1
		changing_state = 1
		active = (opened != default_state)

		playsound(src.loc, 'sound/effects/mag_iceburstimpact.ogg', 25, 1)

		set_density(0)
		invisibility = INVIS_ALWAYS_ISH
		light.disable()
		SPAWN(1.3 SECONDS)
			changing_state = 0

		if (next && next != src)
			next.open()

		return

	close()
		if (!opened || changing_state == -1)
			return

		opened = 0
		changing_state = -1
		active = (opened != default_state)

		playsound(src.loc, 'sound/effects/mag_iceburstimpact.ogg', 25, 1)

		for(var/mob/living/L in get_turf(src))
			logTheThing(LOG_COMBAT, L, "was gibbed by [src] ([src.type]) at [log_loc(L)].")
			L.gib()

		set_density(1)
		invisibility = INVIS_NONE

		light.enable()
		if (next && next != src)
			next.close()

		SPAWN(1.3 SECONDS)
			changing_state = 0

/obj/iomoon_puzzle/floor_pad
	name = "curious platform"
	desc = "A slightly elevated floor panel.  It matches the \"creepy ancient shit\" aesthetic pretty well."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ancient_floorpanel0"
	anchored = ANCHORED
	density = 0
	var/pads_required = 1 //Number of total active pads required to open a door, not including this one.  If 0, all pads must be INACTIVE instead.
	var/pads_active = 0
	var/active = 0
	var/changing_state = 0
	var/atom/activator = null

	New()
		..()
		if (findtext(id, ";"))
			id = params2list(id)

		SPAWN(1 SECOND)
			for (var/atom/potential_activator in src.loc)
				if (potential_activator.density)
					Crossed(potential_activator)
					break

	Crossed(var/atom/crosser as mob|obj)
		..()
		if (!activator || !(activator in src.loc))
			//if (crosser.density && !isshell(crosser))
			if (!isitem(crosser) && !isshell(crosser))
				activator = crosser
				if (!active)
					activate()

		 return

	Uncrossed(var/atom/crosser as mob|obj)
		..()
		if (crosser == activator)
			activator = null
			if (active)
				deactivate()

		return

	activate(var/target_only)
		if (!target_only)
			if (active || changing_state == 1)
				return 1

			active = 1
			playsound(src.loc, 'sound/effects/stoneshift.ogg', 25, 1)
			FLICK("ancient_floorpanel_activate",src)
			src.icon_state = "ancient_floorpanel1"

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/target_element = locate(sub_id)
					if (istype(target_element, /obj/iomoon_puzzle/floor_pad))
						var/obj/iomoon_puzzle/floor_pad/target_pad = target_element
						if (pads_required == 0)
							target_pad.remote_deactivate()
						else if ((pads_active + active) >= pads_required)
							target_pad.remote_activate()

					else if (istype(target_element, /obj/iomoon_puzzle/ancient_robot_door))
						var/obj/iomoon_puzzle/ancient_robot_door/target_door = target_element
						if (pads_required == 0)
							target_door.deactivate()
						else if ((pads_active + active) >= pads_required)
							target_door.activate()

				return 0

			var/obj/iomoon_puzzle/target_element = locate(id)
			if (istype(target_element, /obj/iomoon_puzzle/floor_pad))
				var/obj/iomoon_puzzle/floor_pad/target_pad = target_element
				if (pads_required == 0)
					target_pad.remote_deactivate()
				else if ((pads_active + active) >= pads_required)
					target_pad.remote_activate()

			else if (istype(target_element, /obj/iomoon_puzzle/ancient_robot_door))
				var/obj/iomoon_puzzle/ancient_robot_door/target_door = target_element
				if (pads_required == 0)
					target_door.deactivate()
				else if ((pads_active + active) >= pads_required)
					target_door.activate()

		return 0

	deactivate(var/target_only)
		if (!target_only)
			if (!active)
				return 1

			active = 0

			playsound(src.loc, 'sound/effects/stoneshift.ogg', 25, 1)
			FLICK("ancient_floorpanel_deactivate",src)
			src.icon_state = "ancient_floorpanel0"

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/target_element = locate(sub_id)
					if (istype(target_element, /obj/iomoon_puzzle/floor_pad))
						var/obj/iomoon_puzzle/floor_pad/target_pad = target_element
						if (pads_required == 0 && (pads_active + active) == 0)
							target_pad.remote_activate()
						else if ((pads_active + active) < pads_required)
							target_pad.remote_deactivate()

					else if (istype(target_element, /obj/iomoon_puzzle/ancient_robot_door))
						var/obj/iomoon_puzzle/ancient_robot_door/target_door = target_element
						if (pads_required == 0 && (pads_active + active) == 0)
							target_door.activate()
						else if ((pads_active + active) < pads_required)
							target_door.deactivate()

				return 0

			var/obj/iomoon_puzzle/target_element = locate(id)
			if (istype(target_element, /obj/iomoon_puzzle/floor_pad))
				var/obj/iomoon_puzzle/floor_pad/target_pad = target_element
				if (pads_required == 0 && (pads_active + active) == 0)
					target_pad.remote_activate()
				else if ((pads_active + active) < pads_required)
					target_pad.remote_deactivate()

			else if (istype(target_element, /obj/iomoon_puzzle/ancient_robot_door))
				var/obj/iomoon_puzzle/ancient_robot_door/target_door = target_element
				if (pads_required == 0 && (pads_active + active) == 0)
					target_door.activate()
				else if ((pads_active + active) < pads_required)
					target_door.deactivate()

		return 0

	proc
		remote_activate()
			pads_active++
			if (pads_required == 0)
				return deactivate(1)
			else if ((pads_active + active) >= pads_required)
				return activate(1)

			return 1

		remote_deactivate()
			pads_active = max(0, pads_active-1)
			if (pads_required == 0 && (pads_active + active) == 0)
				return activate(1)
			else if ((pads_active + active) < pads_required)
				return deactivate(1)

			return 1

/obj/item/iomoon_key
	name = "antediluvian key"
	desc = "This is obviously an ancient unlocking gizmo of some sort.  Clearly."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "robotkey-blue"
	w_class = W_CLASS_SMALL
	var/keytype = 0 //0: blue, 1: red

	red
		name = "chthonic key"
		icon_state = "robotkey-red"
		keytype = 1

/obj/iomoon_puzzle/lock
	name = "daedalean doo-dad"
	desc = "This is clearly some sort of lock in need of a key.  Obviously."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "lock-blue"
	anchored = ANCHORED
	density = 1
	var/locktype = 0 //0: blue, 1: red
	var/active = 0
	var/activations = 0
	var/activations_needed = 1

	red
		name = "abstruse gizmo"
		locktype = 1
		icon_state = "lock-red"

	New()
		..()

		if (findtext(id, ";"))
			id = params2list(id)

	attackby(obj/item/iomoon_key/I, mob/user as mob)
		if (istype(I))
			if (icon_state == initial(icon_state) && I.keytype == src.locktype)
				src.icon_state += "-active"
				user.visible_message(SPAN_ALERT("[user] plugs [I] into [src]!"), "You pop [I] into [src].")
				playsound(src.loc, 'sound/effects/syringeproj.ogg', 50, 1)
				user.drop_item()
				I.dispose()
				src.activate()
			else
				boutput(user, SPAN_ALERT("It won't fit!"))

		else
			..()

	activate()
		if (active)
			return 1

		if (++activations >= activations_needed)
			src.active = 1

			if (id)
				if (istype(id, /list))
					for (var/sub_id in id)
						var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(sub_id)
						if (istype(target_door))
							target_door.activate()

						else if (istype(target_door, /obj/iomoon_puzzle/lock))
							var/obj/iomoon_puzzle/button/target_lock = target_door
							target_lock.activate()
				else
					var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(id)
					if (istype(target_door))
						target_door.activate()

					else if (istype(target_door, /obj/iomoon_puzzle/lock))
						var/obj/iomoon_puzzle/button/target_lock = target_door
						target_lock.activate()

/obj/iomoon_puzzle/button
	name = "primordial panel"
	desc = "Some manner of strange panel, built of a strange and foreboding metal."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ancient_button0"
	anchored = ANCHORED
	density = 1
	var/timer = 0 //Seconds to toggle back off after activation.  Zero to just act as a toggle.
	var/active = 0
	var/latching = 0 //Remain on indefinitely.
	var/open_mode = 0 //0 for closed->open, 1 for open->closed

	New()
		..()

		if (findtext(id, ";"))
			id = params2list(id)

	attack_hand(mob/user)
		if (user.stat || user.getStatusDuration("knockdown") || BOUNDS_DIST(user, src) > 0 || !user.can_use_hands() || !ishuman(user))
			return

		user.visible_message(SPAN_ALERT("[user] presses [src]."), SPAN_ALERT("You press [src]."))
		return toggle()

	proc/toggle()
		if (timer)
			if (active)
				return 1

			return src.activate()

		if (active)
			return src.deactivate()
		else
			return src.activate()

	activate()
		if (active)
			return 1

		playsound(src.loc, 'sound/effects/syringeproj.ogg', 50, 1)
		FLICK("ancient_button_activate",src)
		src.icon_state = "ancient_button[++active]"

		if (timer)
			if (timer > 3)
				src.icon_state = "ancient_button_timer_slow"
				SPAWN((timer - 3) * 10)
					src.icon_state = "ancient_button_timer_fast"
					sleep(3 SECONDS)
					src.deactivate()

			else
				src.icon_state = "ancient_button_timer_fast"
				SPAWN(timer * 10)
					src.deactivate()

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(sub_id)
					if (istype(target_door))
						if (src.open_mode)
							target_door.deactivate()
						else
							target_door.activate()
			else
				var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(id)
				if (istype(target_door))
					if (src.open_mode)
						target_door.deactivate()
					else
						target_door.activate()

		return 0

	deactivate()
		if (!active || latching)
			return 1

		playsound(src.loc, 'sound/effects/syringeproj.ogg', 50, 1)
		FLICK("ancient_button_deactivate", src)
		src.icon_state = "ancient_button[--active]"

		if (id)
			if (istype(id, /list))
				for (var/sub_id in id)
					var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(sub_id)
					if (istype(target_door))
						if (src.open_mode)
							target_door.activate()
						else
							target_door.deactivate()
			else
				var/obj/iomoon_puzzle/ancient_robot_door/target_door = locate(id)
				if (istype(target_door))
					if (src.open_mode)
						target_door.activate()
					else
						target_door.deactivate()

		return 0


/obj/rack/iomoon
	name = "odd pedestal"
	desc = "Some sort of ancient..platform.  For holding things.  Or maybe it's an oven or something, who knows!"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "pedestal"

	attackby()
		return
