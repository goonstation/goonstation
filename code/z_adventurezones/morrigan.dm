var/datum/allocated_region/morrigan_region = null
proc/load_morrigan()
	var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/morrigan)
	morrigan_region = prefab.load()
	// big stupid hack because conveyors only init if loaded earlier
	for (var/obj/machinery/conveyor/conveyor as anything in machine_registry[MACHINES_CONVEYORS])
		if (morrigan_region.turf_in_region(get_turf(conveyor)))
			conveyor.initialize()

// Morrigan Azone Content

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

///A mainframe for the Balor entrance area, includes the custom teleport programs and a special syndie SU program
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

// Landmarks

/obj/landmark/morrigan_start
	name = LANDMARK_MORRIGAN_START

/obj/landmark/morrigan_crate
	name = LANDMARK_MORRIGAN_CRATE

/obj/landmark/morrigan_transport
	name = LANDMARK_MORRIGAN_TRANSPORT

/obj/landmark/morrigan_prisoner
	name = LANDMARK_MORRIGAN_PRISONER

// ID Cards
/obj/item/card/id/morrigan

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
	access = list(access_morrigan_specialist)

/obj/item/card/id/morrigan/inspector
	name = "Old Inspector's Card"
	icon_state = "data_old"
	desc = "Looks like and old proto-type ID card!"
	access = list(access_morrigan_teleporter)

/obj/item/card/id/morrigan/engineer
	name = "Richard S. Batherl (Engineer)"
	icon_state = "id_eng"
	desc = "This should let you get into engineering..."
	access = list(access_morrigan_engineering)

/obj/item/card/id/morrigan/ce
	name = "Misplaced CE Card"
	icon_state = "id_comde"
	desc = "Name and picture are scratched off. It's in pretty poor shape."
	access = list(access_morrigan_CE, access_morrigan_engineering)

/obj/item/card/id/morrigan/medical
	name = "Harther Monoshoe (EMT)"
	icon_state = "id_res"
	desc = "A card for medbay!"
	access = list(access_morrigan_medical)

/obj/item/card/id/morrigan/mdir
	name = "Barara J. June (Medical Director)"
	icon_state = "id_com"
	desc = "An important ID card belonging to the medical director."
	access = list(access_morrigan_medical, access_morrigan_mdir, access_morrigan_bridge)

/obj/item/card/id/morrigan/science
	name = "Troy Wentworth (Scientist)"
	icon_state = "id_res"
	desc = "An ID card of a scientist."
	access = list(access_morrigan_science)

/obj/item/card/id/morrigan/rd
	name = "Partially melted Research Director ID"
	icon_state = "id_comac"
	desc = "This card looks badly damaged, does it still work?"
	access = list(access_morrigan_science, access_morrigan_RD)

/obj/item/card/id/morrigan/janitor
	name = "Yi Wong (Janitor)"
	icon_state = "id_civ"
	desc = "It's sparkling clean."
	access = list(access_morrigan_janitor)

/obj/item/card/id/morrigan/security
	name = "Harrier S. Jentlil (Patrol Officer)"
	icon_state = "id_sec"
	desc = "Wow, a still intact security ID! This could come in handy..."
	access = list(access_morrigan_security)

/obj/item/card/id/morrigan/hos
	name = "Alexander Nash (Elite Head of Security)"
	icon_state = "id_synexe"
	desc = "Jackpot!"
	access = list(access_morrigan_bridge, access_morrigan_security, access_morrigan_HOS)

/obj/item/card/id/morrigan/customs
	name = "William B. Ron"
	icon_state = "id_com"
	desc = "A Head ID but it seems to be lacking something..."
	access = list(access_morrigan_customs, access_morrigan_bridge)

/obj/item/card/id/morrigan/captain
	name = "Captain's Spare ID"
	icon_state = "id_scap"
	desc = "The Captains spare ID! This should access most doors..."

	New()
		..()
		access = morrigan_access() - list(access_morrigan_exit, access_morrigan_HOS)

/obj/item/card/id/morrigan/all_access
	name = "Number 3 (Hafgan Executive)"
	icon_state = "id_haf"
	desc = "Someone must've been in a rush and left this behind... it's heavily decorated and seems extremely important. Could this be your key out?"

	New()
		..()
		access = morrigan_access()

/proc/morrigan_access()
	return list(access_morrigan_bridge, access_morrigan_medical, access_morrigan_CE, access_morrigan_captain, access_morrigan_RD, access_morrigan_engineering,
	access_morrigan_factory, access_morrigan_HOS, access_morrigan_meetingroom, access_morrigan_customs, access_morrigan_exit, access_morrigan_science,
	access_morrigan_mdir, access_morrigan_security, access_morrigan_janitor, access_morrigan_specialist)
//decals
/obj/decal/poster/wallsign/morrigan
	name = "ADF Morrigan"
	desc = "Poster of ADF Morrigan, looks very fancy!"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "morrigan"

/obj/decal/poster/wallsign/report
	name = "Vigilance Poster"
	desc = "Keen eyes keep the station safe! Report suspicious behavior to Security."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "report"

/obj/decal/poster/wallsign/betray
	name = "Not too late!"
	desc = "You have a place here, with us, the Syndicate."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "n_for_s"

/obj/decal/poster/wallsign/looselips
	name = "Loose Lips"
	desc = "Loose Lips Sink SpaceShips."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "looselips"

/obj/decal/poster/wallsign/you4s
	name = "Join Security"
	desc = "Help keep your station secure today."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "you_4_s"

/obj/decal/poster/wallsign/mod21
	name = "Mod. 21 Deneb"
	desc = "Our new staple ! With multiple functions!"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "mod21"

/obj/decal/poster/wallsign/syndicateposter
	name = "Syndicate Poster"
	desc = "A poster promoting the Syndicate."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "wall_poster_syndicate"

/obj/decal/poster/wallsign/syndicatebanner
	name = "Syndicate Banner"
	desc = "A banner promoting the Syndicate"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "syndicateposter"

/obj/decal/poster/wallsign/nomask
	name = "No Masks"
	desc = "No Masks in this area."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "nomask"

//fake objects
/obj/decal/fakeobjects/hafmech
	name = "Strange Machine"
	icon = 'icons/obj/adventurezones/morrigan/decoration.dmi'
	bound_width = 128
	bound_height = 128
	density = TRUE
/obj/decal/fakeobjects/hafmech
	name = "Big Machine"
	desc = "This does not come in smaller sizes..."
	icon_state = "mech"

/obj/decal/fakeobjects/missile
	name = "Escape Missile"
	icon = 'icons/obj/large/32x64.dmi'
	bound_width = 32
	bound_height = 64

/obj/decal/fakeobjects/missile/syndicate
	icon_state = "arrival_missile_synd"


/obj/decal/fakeobjects/pod
	name = "Pod"
	icon = 'icons/effects/64x64.dmi'
	bound_width = 64
	bound_height = 64

/obj/decal/fakeobjects/pod/syndicate/racepod
	name = "Syndicate Security Pod"
	desc = "A Syndicate-crafted light pod, seems locked."
	icon_state = "pod_raceRed"

/obj/decal/fakeobjects/pod/nanotrasen/racepod
	name = "Nanotrasen Light Pod"
	desc = "A Nanotrasen light Pod! It seems locked.. "
	icon_state = "pod_raceBlue"

/obj/decal/fakeobjects/pod/black
	name = "Black Pod"
	desc = "A black pod, seems locked."
	icon_state = "pod_black"

/obj/decal/fakeobjects/miniputt
	name = "Miniputt"
	icon = 'icons/obj/ship.dmi'

/obj/decal/fakeobjects/miniputt/syndicate/raceputt
	name = "Syndicate Security MiniPutt"
	desc = "A Syndicate-crafted light miniputt, seems locked."
	icon_state = "putt_raceRed_alt"

/obj/decal/fakeobjects/miniputt/nanotrasen/raceputt
	name = "Nanotrasen Light MiniPutt"
	desc = "A Nanotrasen light miniputt! It seems locked..."
	icon_state = "putt_raceBlue"

/obj/decal/fakeobjects/miniputt/black
	name = "Black Miniputt"
	desc = "A black miniputt, seems locked."
	icon_state = "putt_black"

/obj/decal/fakeobjects/weapon_racks
	name = "Weapon Rack"
	icon = 'icons/obj/weapon_rack.dmi'

/obj/decal/fakeobjects/weapon_racks/plasmagun1
	name = "Plasma Rifle Rack"
	icon_state = "plasmarifle_rack1"

/obj/decal/fakeobjects/gunbotrep
	name = "Unfinished drones"
	icon = 'icons/obj/adventurezones/morrigan/gunbot.dmi'

/obj/decal/fakeobjects/gunbotrep/gunrep1
	name = "Unfinised Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep1"

/obj/decal/fakeobjects/gunbotrep/gunrep2
	name = "Unfinished Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep2"
/obj/decal/fakeobjects/gunbotrep/gunrep3
	name = "Damaged Sentinel"
	desc = "Seems worse for wear."
	icon_state = "gunbot_rep3"

/obj/decal/fakeobjects/gunbotrep/gunrep4
	name = "Unfinished Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep4"

/obj/decal/fakeobjects/gunbotrep/clawbot
	name = "Unfinished CQC Unit"
	icon_state = "clawbot_rep"

/obj/decal/fakeobjects/gunbotrep/gunbotarm
	name = "Gun Arm"
	icon_state = "gunbot_arm"

/obj/decal/fakeobjects/gunbotrep/gunbotarm2
	name = "Gun Arm"
	icon_state = "gunbot_arm2"

/obj/decal/fakeobjects/gunbotrep/engineerbot
	name = "Unfinished 	MULTI Unit"
	icon_state = "engineerbot_rep"

/obj/decal/fakeobjects/gunbotrep/riotbot
	name = "Unfinished Riot Unit"
	icon_state = "riotbot"
/obj/decal/fakeobjects/gunbotrep/jacklift
	name = "Jack-lift"
	desc = "Used to lift up units that need repairs or require finishing."
	icon_state = "jacklift"

/obj/decal/fakeobjects/gunbotrep/clawbotinactive
	name = "Inactive CQC Unit"
	icon_state = "clawbotina"

/obj/decal/fakeobjects/gunbotrep/engineerbotinactive
	name = "Inactive MULTI Unit"
	icon_state = "engina"

/obj/decal/fakeobjects/gunbotrep/medibotinactive
	name = "Inactive Medical Unit"
	icon_state = "medibotina"
/obj/decal/fakeobjects/gunbotrep/riotbotina
	name = "Inactive Riot Unit"
	icon_state = "riotbotina"
/obj/decal/fakeobjects/tpractice
	name = "Target Practice Dummy"
	desc = "You can just IMAGINE why it's blue..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bopbagsyd"

/obj/decal/fakeobjects/factory
	name = "Machine"
	icon = 'icons/obj/adventurezones/morrigan/factory64x64.dmi'
	bound_width = 64
	bound_height = 64

/obj/decal/fakeobjects/factory/claw
	name = "Factory Arm"
	icon_state = "arm"

/obj/decal/fakeobjects/factory/drill
	name = "Factory Arm"
	icon_state = "drill"

/obj/decal/fakeobjects/factory/bolt
	name = "Factory Arm"
	icon_state = "bolter"

/obj/decal/fakeobjects/factory/weld
	name = "Factory Weld"
	icon_state = "welder"

/obj/decal/fakeobjects/midfactory
	name = "Machine"
	icon = 'icons/obj/large/32x48.dmi'
	bound_width = 32
	bound_height = 48

/obj/decal/fakeobjects/midfactory/enginething
	name = "Factory Machine"
	icon_state = "stomper0"

/obj/decal/fakeobjects/midfactory/enginething2
	name = "Factory Machine"
	icon_state = "bigatmos1_1"

/obj/decal/fakeobjects/midfactory/enginething3
	name = "Factory Machine"
	icon_state = "bigatmos2"

/obj/decal/fakeobjects/cabinet1
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab1"

/obj/decal/fakeobjects/cabinet2
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab2"

/obj/decal/fakeobjects/cabinet3
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab3"

/obj/decal/fakeobjects/ships
	name = "Drone Pods"
	icon = 'icons/obj/adventurezones/morrigan/ships.dmi'
/obj/decal/fakeobjects/ships/dronerep
	name = "Unfinished Drone"
	icon_state = "dronerep"

/obj/decal/fakeobjects/ships/dronerep2
	name = "Unfinished Drone"
	icon_state = "dronerep_2"

/obj/decal/fakeobjects/ships/dronesnip
	name = "Prototype Drone"
	icon_state = "dronesnip"

/obj/decal/fakeobjects/ships/dronerep3
	name = "Unfinished Drone"
	icon_state = "dronerep_3"

/obj/decal/fakeobjects/ships/dronerep4
	name = "Unfinished Drone"
	icon_state = "dronerep_4"

/obj/decal/fakeobjects/ships/dronebomb
	name = "Prototype Drone"
	icon_state = "dronebomb"

/obj/decoration/ntcratesmall/syndicrate
	name = "Metal Crate"
	icon_state = "syndiecrate"

/obj/decoration/ntcratesmall/opencrate
	name = "Open Crate"
	icon_state = "opencrate"
//NPCS for Morrigan
/mob/living/carbon/human/hobo
	New()
		..()
		src.equip_new_if_possible(pick(/obj/item/clothing/head/apprentice, /obj/item/clothing/head/beret/random_color, /obj/item/clothing/head/black, /obj/item/clothing/head/chav,
		/obj/item/clothing/head/fish_fear_me/emagged, /obj/item/clothing/head/flatcap, /obj/item/clothing/head/party/random, /obj/item/clothing/head/plunger,
		/obj/item/clothing/head/towel_hat, /obj/item/clothing/head/wizard/green, /obj/item/clothing/head/snake, /obj/item/clothing/head/raccoon,
		/obj/item/clothing/head/bandana/random_color), SLOT_HEAD)
		src.equip_new_if_possible(pick(/obj/item/clothing/under/gimmick/yay, /obj/item/clothing/under/misc/casualjeansgrey, /obj/item/clothing/under/misc/dirty_vest,
		/obj/item/clothing/under/misc/yoga/communist, /obj/item/clothing/under/patient_gown, /obj/item/clothing/under/shorts/random_color,
		/obj/item/clothing/under/misc/flannel), SLOT_W_UNIFORM)
		src.equip_new_if_possible(pick(/obj/item/clothing/suit/walpcardigan, /obj/item/clothing/suit/gimmick/hotdog, /obj/item/clothing/suit/loosejacket,
		/obj/item/clothing/suit/torncloak/random, /obj/item/clothing/suit/gimmick/guncoat/dirty, /obj/item/clothing/suit/bathrobe, /obj/item/clothing/suit/apron,
		/obj/item/clothing/suit/apron/botanist, /obj/item/clothing/suit/bedsheet/random), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/shoes/tourist), SLOT_SHOES)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(2) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, src)
		bioHolder.mobAppearance.gender = "male"
		bioHolder.age = rand(50, 90)
		bioHolder.mobAppearance.customization_first_color = pick("#292929", "#504e00" , "#1a1016")
		bioHolder.mobAppearance.customization_second_color = pick("#292929", "#504e00" , "#1a1016")
		var/beard = pick(/datum/customization_style/hair/gimmick/shitty_beard, /datum/customization_style/hair/gimmick.wiz, /datum/customization_style/beard/braided,
		/datum/customization_style/beard/abe, /datum/customization_style/beard/fullbeard, /datum/customization_style/beard/longbeard, /datum/customization_style/beard/trampstains)
		bioHolder.mobAppearance.customization_second = new beard

/mob/living/carbon/human/hobo/vladimir
	real_name = "Vladimir Dostoevsky"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "I neeeda zzrink...", "Fugh...", "Where me am...", "I pischd on duh floor...","Why duh bluee ann sen how...","AAAAAAAAAAAAAAAAH CHOOO!"))

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, src)

/mob/living/carbon/human/hobo/laraman
	real_name = "The Lara Man"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.stat)
			return

		src.setStatusMin("weakened", 10 SECONDS)
		if (prob(10))
			src.say(pick( "Don't look for Lara...", "Lara??", "Lara the oven!", "Please don't talk to Lara", "LAAAAARRRAAAAAAAA!!!" ,"L-Lara.","Do you know where Lara is?"))

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, src)


/mob/living/carbon/human/morrigansec
	New()
		..()
		src.equip_new_if_possible(pick(/obj/item/clothing/head/morrigan/sberet), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/mask/gas/swat), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/sec), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/armor/vest), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morriganntop
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/robofab), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/brown), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/card/id/morrigan/captain), SLOT_IN_BACKPACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_prisoner
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/misc/prisoner), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/brown), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/weldingtool), SLOT_IN_BACKPACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/orange), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)
/mob/living/carbon/human/morrigan_rnd
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/robofab), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/engineering), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_quality
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/quality), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/green), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_executive
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/morrigan/executive), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/morrigan/executive), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/mask/swat/haf), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)
		src.equip_new_if_possible((/obj/item/card/id/morrigan/all_access), SLOT_WEAR_ID)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/morrigan_doctor
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/under/rank/medical/april_fools), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/storage/backpack/blue), SLOT_BACK)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/critter/human/hobo
	name = "Hobo"
	desc = "They have a crazed look in their eyes"
	health_brute = 20
	health_burn = 20
	faction = FACTION_GENERIC
	ai_type = /datum/aiHolder/aggressive
	human_to_copy = /mob/living/carbon/human/hobo

/mob/living/critter/human/morrigan_quality
	name = "Quality Assurance Worker"
	desc = "You don't recognize them"
	health_brute = 20
	health_burn = 20
	faction = FACTION_SYNDICATE
	ai_type = /datum/aiHolder/aggressive
	human_to_copy = /mob/living/carbon/human/morrigan_quality

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("Who...who are you?!", "Get away from here!", "SECURITY, HELP!", "You aren't meant to be here!", "It's because of people like you!", "You caused this!"))

/mob/living/critter/human/morrigan_rnd
	name = "R&D Worker"
	desc = "You don't recognize them"
	health_brute = 20
	health_burn = 20
	faction = FACTION_SYNDICATE
	ai_type = /datum/aiHolder/aggressive
	human_to_copy = /mob/living/carbon/human/morrigan_rnd

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("Who...who are you?!", "Get away from here!", "SECURITY, HELP!", "You aren't meant to be here!", "It's because of people like you!", "You caused this!"))

/mob/living/critter/human/hobo/dagger
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "scrap dagger"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/dagger

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("FUCK FUCK FUCK!", "CR-CRANK BABY!", "MORMGHRMGINIAD!", "YOU WERE THERE!!", "Ohh...oohhh....", "BUTTER THEY HAD MY BUTTER!!!", "Shrughaldin...AAAAAH!", "SPIDER FACE!!"))


/mob/living/critter/human/hobo/club
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap club"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/club

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("WOOOOOSHHH WEEEEEEE!", "ORDER 3 SANDWICHES, 3 OF THEM!", "IS THAT YOU MOM ??!", "Urgh...piss...", "If you are injured, I advise applying pressure to the wound until the medics arrive.", "KAAAAAAAWAAAAAAAAAAAAA!", "Rat FOOD!!", "XDEOBLD....EOWA"))


/mob/living/critter/human/hobo/machete
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "scrap machete"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/scrapweapons/weapons/machete

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

	seek_target(range)
		. = ..()

		if (length(.) && prob(10))
			src.say(pick("WEEEEWOOOOOWEEEEWOOOOO.", "A B C D E ....", "LOOK AT ME, I AM THE CAPTAIN NOW.", "Fuckers got my cash...", "WANNA SCRAP YOU WIMP?", "TOENAILS, TOENAILS...", "Mmmmerghh...mmm....", "OWNED??"))


/mob/living/carbon/human/syndicatemorrigan
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/head/morrigan/swarden), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/mask/gas/swat), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/rank/head_of_security/fancy_alt), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/armor/vest), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/gloves/black), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/syndicatemorrigan/rowdy

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Got us a few visitors!", "Looking forward to lunch time...", "Ha, you're in our turf now.", "Unit 78 requesting orders.",
			"Hey! Who took my gum?"))

/mob/living/carbon/human/syndicatemorrigan/cautious

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Have you double checked them for contraband?", "We should place them in handcuffs.", "Hey, quit slacking off!", "Unit 25C confirming prisoners.",
			"Rumor has it, there's trouble stiring on Morrigan."))

/mob/living/carbon/human/syndicatemorrigan/eager

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Unit 90A reporting for duty!", "I got this!", "Logging them in now!", "Aw yeah, we got ourself another one !",
			"I'm up for promotion! Think I'll get it ?"))

/mob/living/carbon/human/syndicatemorrigan/veteran

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "Same old, same old.", "I'm due for a nap, get me a coffee.", "Any of you got a lighter?", "I'm not paid enough to care.",
			"Just create a new record."))
/mob/living/carbon/human/syndicatemorrigan/sleepy

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.stat)
			return

		src.setStatusMin("unconscious", 10 SECONDS)

		if (prob(2) && !src.stat)
			src.emote("snore")

/mob/living/carbon/human/syndicatemorriganeng
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/head/helmet/hardhat), SLOT_HEAD)
		src.equip_new_if_possible((/obj/item/clothing/glasses/meson), SLOT_GLASSES)
		src.equip_new_if_possible((/obj/item/clothing/under/misc/casualjeansyel), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/hi_vis), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/gloves/yellow), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/magnetic), SLOT_SHOES)


	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(0) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/mob/living/carbon/human/syndicatemorrigandoc
	New()
		..()
		src.equip_new_if_possible((/obj/item/clothing/glasses/nightvision/sechud), SLOT_GLASSES)
		src.equip_new_if_possible((/obj/item/clothing/mask/surgical), SLOT_WEAR_MASK)
		src.equip_new_if_possible((/obj/item/clothing/under/scrub), SLOT_W_UNIFORM)
		src.equip_new_if_possible((/obj/item/clothing/suit/space/syndicate/specialist/medic), SLOT_WEAR_SUIT)
		src.equip_if_possible((/obj/item/clothing/gloves/black), SLOT_GLOVES)
		src.equip_new_if_possible((/obj/item/clothing/shoes/swat), SLOT_SHOES)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(0) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, src)

/obj/mapping_helper/mob_spawn/corpse/human/hobo
	spawn_type = /mob/living/carbon/human/hobo

/obj/mapping_helper/mob_spawn/corpse/human/ntop
	spawn_type = /mob/living/carbon/human/morriganntop

/obj/mapping_helper/mob_spawn/corpse/human/morrigansec
	spawn_type = /mob/living/carbon/human/morrigansec

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_executive
	spawn_type = /mob/living/carbon/human/morrigan_executive

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_rnd
	spawn_type = /mob/living/carbon/human/morrigan_rnd

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_quality
	spawn_type = /mob/living/carbon/human/morrigan_quality

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_doctor
	spawn_type = /mob/living/carbon/human/morrigan_doctor

/obj/mapping_helper/mob_spawn/corpse/human/morrigan_prisoner
	spawn_type = /mob/living/carbon/human/morrigan_prisoner
// Areas

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

// Papers

/obj/item/paper/toiletnote
	name = "Messy piece of paper"
	icon_state = "paper_caution_bloody"
	info ={"
	He said he'd be here, that where was some way out, I spent all my lunch money on this... <br>
	Did he bail out on me ? Why did he mention a vending machine... <br>
	I have to get out of here before the wardens come back.
	"}

/obj/item/paper/complaint1
	name = "Old piece of paper"
	icon_state = "paper_burned"
	info ={"
	They're abandoning this place hunh, about damn time. The air here is foul.<br>
	Working here was a hazard anyways, last week we lost Carla to some strange looking fella.<br>
	Security wouldn't even bother coming up here. These shafts are a death sentence.<br>
	I miss the old Captain, he wouldn't stand for these deplorable conditions, the power goes out constantly!
	"}

/obj/item/paper/rolecall
	name = "Torn off piece of paper"
	icon_state = "paper_burned"
	info ={"
	<h2 style="text-align: center;"><span style="text-decoration: underline;"><strong>Manifest Role Call</strong></span></h2>
	<ul>
	<li>Carla Bentson - Present</li>
	<li>Hendrick L. Fold - ABS</li>
	<li>Bernadette Crimnoty - ABS</li>
	</ul>
	<p>(the rest seems to be torn off...)</p>
	"}

/obj/item/paper/Cecomplaint
	name = "Old letter"
	icon_state = "paper_burned"
	info ={"
	I'm tired of this! Half our employees are high on crank!<br>
	This has to stop, captain. We're constantly losing power and worse yet, we're losing engineers!<br>
	I don't know who's supplying them or how this stuff is getting in but I have a hunch Carla is behind it.<br>
	She hasn't even been showing up to work lately and nobodoy even knows where she is.<br>
	At this rate I'm starting to think she might be an NT sleeper agent or something.<br>
	Ever since she came back from the outpost expidition she's been acting strange...<br>
	Captain, please do something about this.
	"}

/obj/item/paper/notice_deri
	name = "Old email print-out"
	icon_state = "paper_burned"
	info ={"
	Attention All Employees,<br>
	It has come to our notice that performance on this station is uncharacteristically low. After much deliberation with our superiors,<br>
	we regret to inform you that we will be decommissioning sector 4a.<br>
	You will all be on paid leave while we investigate alarming testaments about certain crew members of this section of the station.<br>
	After the investigation is concluded will re-allocate competent and productive members to another section of the station.<br>
	Those deemed unfit will be sent back to training off station. Renovation will begin in the coming weeks.<br>
	<br>
	Your Head of Personnel,
	Inowatt M. Dewing

	"}

/obj/item/paper/inspectorlastwords
	name = "Deranged Scribblings"
	icon_state = "paper_caution"
	info ={"
	I've been inspecting CARGO FOR YEARS, 9 YEARS, PERFECT RECORD... something about the way the undesirable cargo and trash gets...<br>
	COMPACTED is just so... soo.....<br>
	...
	"}

/obj/item/paper/mindhackedcarla
	name = "What am I doing?"
	icon_state = "paper_caution"
	info ={"
	I don't know what's going on, ever since that journey I ... I just can't seem to gather my thoughts.<br>
	I barely remember anything, just a voice and someone with... blue hair... Lara ? Lieria ? Lenah...?<br>
	I don't know who they are but something tells me, something... I must... wires...I must... obey...<br>
	"}

/obj/item/paper/hobotalk
	name = "Badly worded note"
	icon_state = "paper"
	info ={"
	Ey dun evn kno y he insts abt goin out there we kno thms foks no good, ey git is adiktins thms crazies gon get him!
	"}

/obj/item/paper/laraman
	name = "LARA"
	icon_state = "paper_caution"
	info ={"
	Don't TELL LARA. LARA, LARA, PLEASE NOT LARA. LARA? LARAAAAAA, OH LARA<br>
	Not LARA! LARA ? LARA. L A R A. LARA! HANDS OFF LARA, WHERE'S LARA?<br>
	Have you seen LARA ? please LARA ! Laraaaaaaa??
	"}

/obj/item/paper/hobonote
	name = "Note"
	icon_state = "paper_caution"
	info ={"
	There's been less people passin' by. No good... us prisoner fellars gotta stick together! I still remember the old days, I sure miss that old station...
	mushroom was it ? We started off as 5 and we'd smuggle in a few others. But we've had to slow it down, been drawin' too much attention yer see.<br>
	that soda machine been keeping our brews fresh! You'd be right surprised what kinda liquor you can brew with them sodas.<br>
	Damn syndies keep restockin' it too! Every wheneversday yes sirree. We've also sealed off most the parts that was causing trouble with them<br>
	crazies over on the other side. Still hopin' we get a sign of Johnny sometime soon though. Went out to scout for some drugs days ago.
	"}

/obj/item/paper/hintjail
	name = "Paper"
	icon_state = "paper"
	info ={"
	A spot of relief.<br>
	The one that stands out<br>
	The sewers beneath.
	"}

/obj/item/paper/NTnote
	name = "Hidden note"
	icon_state = "paper"
	info ={"
	I think they're on to us S... I'd PDA text you but they might be watching those too. Decided to leave the note in our usual spot.<br>
	We might need to hitch a ride out of here, stuffs gettin' too heated. I was already brigged twice and managed convince them that our sabotage<br>
	was mere accidents of incompetence. I don't think they're gonna keep buying it. I've already been implanted with a tracker I think.<br>
	Unless you wanna end up crammed into their damn robot shells I'd suggest you keep a low profile. Burn this once you read it and meet me<br>
	by Medical Janitor's room, you know behind the bush in 2 hours. Bring a disguise too, and for god sakes WEAR A MASK. <br>
	-J
	"}

/obj/item/paper/secnote1
	name = "New Prisoner #79"
	icon_state = "paper"
	info ={"
	<p style="text-align: center;"><strong>Week 25</strong></p>
	<p style="text-align: center;"><strong>New prisoner</strong><strong></strong></p>
	<p style="text-align: center;"><span style="text-decoration: underline;">David L. Broad</span></p>
	<p>Age : 36</p>
	<p>Transfered from Lero IV</p>
	<p>Transfered to : ADF Morrigan</p>
	<p>Height : 175cm</p>
	<p>Species : Human</p>
	<p>RAE : ★✰✰✰✰</p>
	<p>Notes :</p>
	<p>Mobster from Amantes, low ranking. Cooperative. Known alcoholic. Married, 3 children. Connections to&nbsp;Los ladrones de helados and Hairy Mafia.</p>
	<p>Instructions from Lero IV:</p>
	<p>Incarcerate until cell available on Lero IV. No special treatment required. Confine in GenPop Brig.</p>
	"}

/obj/item/paper/secnote2
	name = "New Prisoner #85"
	icon_state = "paper"
	info ={"
	<p style="text-align: center;"><strong>Week 26</strong></p>
	<p style="text-align: center;"><strong>New prisoner</strong><strong></strong></p>
	<p style="text-align: center;"><span style="text-decoration: underline;">Helga S. Marts</span></p>
	<p>Age : 45</p>
	<p>Transfered from Lero IV</p>
	<p>Transfered to : ADF Morrigan</p>
	<p>Height : 165cm</p>
	<p>Species : Human</p>
	<p>RAE : ★★★✰✰</p>
	<p>Notes :</p>
	<p>Inconsistent Story. Unknown Origin. No Records. Shown to be resourceful and violent. Apply Caution.</p>
	<p>Instructions from Lero IV:</p>
	<p>Incarcerate in solitary. Contract from third party. To be returned to Lero IV once cell available.</p>
	"}
/obj/item/paper/secnote3
	name = "New Prisoner #88"
	icon_state = "paper"
	info ={"
	<p style="text-align: center;"><strong>Week 26</strong></p>
	<p style="text-align: center;"><strong>New prisoner</strong><strong></strong></p>
	<p style="text-align: center;"><span style="text-decoration: underline;">Matheos Abkins</span></p>
	<p>Age : 39</p>
	<p>ADF Morrigan Employee</p>
	<p>Height : 182cm</p>
	<p>Species : Human</p>
	<p>RAE : ★★★★★</p>
	<p>Notes :</p>
	<p>=REDACTED=</p>
	<p>Instructions from Head Of Security:</p>
	<p>Incarcerate in solitary until interrogation. Avoid all contact with other inmates.</p>
	"}

/obj/item/paper/morrigansciencecomplaint
	name = "Angry Note"
	icon_state = "paper"
	info ={"
	I SWEAR TO GOD, I don't care if she's the RD that SLOP needs to get her act together. If you're using MY workstation,<br>
	PUT THE DAMN TOOLS BACK. I'm sick and tired of having to beg to on an easter egg hunt for MY shit. If I catch them misplacing them one more time.<br>
	"}

/obj/item/paper/morriganclown
	name ="Nukies?"
	icon_state = "paper"
	info ={"
	Hi Cappy! Honk :)<br>
	Iz me Klown!! Authorize armory I think nukies engi. Need Aa, please give ?<br>
	-Klown
	"}

/obj/item/paper/MorriganHoS
	name = "Important Message From HQ"
	icon_state = "paper"
	info ={"
	Hello Alexander, <br>
	We're contacting you inform you that information might have been compromised. We've lost contact with Agent Ivy.<br>
	He isn't responding to any of our messages. Extraction is probably impossible. We're worried however. The messages<br>
	appear to be going through, just without answers. It's possible they might have been captured and their device intercepted.<br>
	For an agent recommended by you, they have so far proven to be unreliable.<br>
	A full scale investigation will be conducted on ADF Morrigan.<br>
	Your direct orders are to ensure no one leaves the station for any reason without our express authorization.<br>
	We're counting on you back at HQ here. Report to us if anything changes, and stay alert.
	-Syndicate High Command.
	"}

/obj/item/paper/MorriganHoS2
	name = "Important Message From HQ"
	icon_state = "paper"
	info ={"
	Hello Alexander, <br>
	Your reports have been received. Please handle all 3 suspected spies with caution.<br>
	As of now, we have restricted radio frequencies. Adjust your radio accordingly to frequences =Redacted=.<br>
	You are not to execute the spies until we gather as much information from them as possible.<br>
	A =Redacted= Executive, codenamed Number 3 will be overseeing operations in Morrigan.<br>
	Ensure they come to no harm what-so-ever. Your branch reputation is on the line here.<br>
	Your direct orders are to ensure the interrogation of the 3 spies. A formal report is to be issued to us as soon as possible.<br>
	You are not to us fail us,<br>
	-Syndicate High Command.
	"}

/obj/item/paper/morrigancaptain
	name = "Complaint to HQ"
	icon_state = "paper"
	info ={"
	HQ this is Captain Kalada S. Heuron,<br>
	I'm sending this message to talk about the recent situation going on here on Morrigan. We've been receiving an increasing influx of prisoners<br>
	ones from Lero VI. While I appreciate your trust in our ability, we simply cannot accomodate this many. When I was informed this about this.. <br>
	I expected it to be a temporary solution while reconstruction of sector 4a was in process. I understand that every station is sharing the burden, <br>
	but ours isn't nearly as big as the others. We don't have the manpower nor room for this many. We've had security personnel on overtime for 2 weeks,<br>
	We cannot continue like this. Please advise as soon as possible.
	--Transcript End. Audio Message Delivered.--
	"}

/obj/item/paper/morriganpda
	name = "Intercepted PDA Message"
	icon_state = "paper"
	info ={"
	I've never been on any of their stations but your stories make them seem awesome! Is true they use laser weapons and stuff ? That's so cool...<br>
	I hear you're returning on the 8th! Think you could possibly... get me one of their fancy tasers? I'll of course pay you for it obviously..<br>
	I know it's a big risk and all so how about 20k? Seems like a fair deal to me.
	--Transcript End. Message Delivered from PDA-Sorbert S. Haffings.--
	"}

/obj/item/paper/morriganalert
	name = "RECON DEFENSE PERIMETER ALERT"
	icon_state = "paper"
	info ={"
	<p style="text-align: center;">SECURITY ALERT</p>
	<p style="text-align: center;">WARNING SEVERAL UNIDENTIFIED VESSELS APPROACHING</p>
	<p style="text-align: center;">RESPONSE ADVISE</p>
	<p style="text-align: center;">ETA TO CONTACT: 13 MINUTES</p>
	<p style="text-align: center;">NUMBER OF VESSELS: 5</p>
	<p style="text-align: center;">A COPY OF THIS MESSAGE HAS BEEN SENT TO HQ</p>
	<p style="text-align: center;">ALERT STATUS AUTOMATICALLY SENT TO HEADS OF STAFF</p>
	<p style="text-align: center;"><br></p>
	"}

/obj/item/paper/morriganhos4
	name = "Left over note"
	icon_state = "paper"
	info ={"

	"}

/obj/item/paper/morriganfactory
	name = "intercepted PDA Message"
	icon_state = "paper_caution_bloody"
	info ={"
	Those damn Traseys... they found out our operation before we could complete Storm... Came in guns blazing like a bunch of savages. The factory <br>
	it... it's ruined. Operations are completely halted. Most machinery was destroyed. Their assault didn't go off as well least... <br>
	but the cost was great on our side. My pda is damaged and I'm stuck behind this door. Air is running out and I think I've<br>
	shrapnel in my stomach... I don't think I'm going to be able to be rescued. I've sent out several alert and I've oxygen for another 12 minutes...<br>
	I don't think this message is going to go through either but here's one final try. If anyone receives this I'm in the Factory Engine Maintenance area<br>
	Coordinates Attached with message. =Redacted= , =Redacted=
	Evan out.
	--Transcript End. Message redacted and blocked from PDA -CORRUPTED--
	"}

/obj/item/paper/Morriganstatus
	name = "AUTOMATIC UPDATE SYSTEM"
	icon_state = "paper"
	info ={"
	<p style="text-align: center;">MORRIGAN STATUS UPDATE</p>
	<p style="text-align: center;">HULL INTEGRITY 78%</p>
	<p style="text-align: center;">BIOSCAN INDICATE CREW AT 49% CAPACITY</p>
	<p style="text-align: center;">CYBORG CAPACITY: 84%</p>
	<p style="text-align: center;">CAPTAIN KALADA S. HEURON: MIA</p>
	<p style="text-align: center;">HoS ALEXANDER NASH : MIA</p>
	<p style="text-align: center;">CE BERTHOLD H. RANTHER : MIA</p>
	<p style="text-align: center;">RD MARISSA BELFRON : MIA</p>
	<p style="text-align: center;">HoP WILLIAM B. RON : MIA</p>
	<p style="text-align: center;">MDir FREDRICH C. PALIDOME : UNKNOWN</p>
	<p style="text-align: center;">STATION POWER : 30%&nbsp;</p>
	<p style="text-align: center;">SITUATION CRITICAL</p>
	<p style="text-align: center;">--Transcript End. Message Delivered to HQ.--</p>
	"}

/obj/item/paper/morriganling
	name = "Intercepted PDA Message"
	icon_state = "paper"
	info ={"
	Hey Jess, don't you think Albert is acting a little strange... I could've sworn he never had a pink finger... didn't we always call him<br>
	 'foursies' or something for it ? He's also been doing a lot of EVA work... he never liked leaving the station.<br>
	 He also doesn't seem to be snacking at all like he usually does. Something feels off. I can't exactly point out what.<br>
	 I don't know what to do or say. Surely I'm not the only one noticing this. We can talk more about this at lunch.<br>
	 See you soon,<br>
	 Hubert.
	 --Transcript End. Message Delivered from PDA-Hubert V. Bronbor--
	"}

/obj/item/paper/morriganhop
	name = "Reminder! New ID Cards!"
	icon_state = "paper"
	info ={"
	This is your reminder that we are changing the ID locks on certain doors after our little incident. This is a security measure and is mandatory. <br>
	Be sure to deposit your old ID by the end of the week for your new one. You will not be provided a new one if you don't give us back the old one. <br>
	Your old cards will not work anymore 48 hours from now. We will be working extra hours to help deal with the temporary situation.<br>
	-Head of Personnel
	--Transcript End. Message Delivered to all valid PDAs--
	"}

/obj/item/paper/morriganrd
	name = "You're Fired Nick"
	icon_state = "paper"
	info ={"
	You're fucking fired Nick. By the time you read this, I want you out of my department. That acid could've seriously injured me or you co-workers.<br>
	You've a clear disregard for safety here and I don't want you anywhere near us. Oh and the captain is aware of this too, so good luck getting a new job<br>
	I don't want to see your face ever again, keep the fucking ID and the mask. I already got a new one.<br>
	-Research Director.
	--Transcript End. Message Delivered to PDA-Nickolas Eol and HQ--
	"}

/obj/item/paper/MorriganNT
	name = "Midly Crumbled Note"
	icon_state = "paper"
	info ={"
	I've swipped the CE's card while they were busy maintaining the singularity. He left it in his console and by the time he came back.. <br>
	I was already gone with it. We always needed a Head of Staff id with us. Not the most powerful one... <br>
	but it should probably do. I'll be waiting for you in the northern maints. Come alone please, you're the only one I trust.<br>
	-A
	"}
/obj/item/paper/MorriganNT2
	name = "Intercepted PDA Message"
	icon_state = "paper"
	info ={"
	Hello CentComm,
	This is agent S, I've confirmed that there is indeed a way to self destruct this station. I don't know where yet, rumors say it in the bridge. <br>
	Sounds too risky to infil right now, they appear to be on high alert or something. We would appreciate some feedback, your last orders date from <br>
	a while ago. Is operation Blue still in action ? We're eagerly awaiting a response from you.<br>
	-May Nanotrasen never fall.
	--Transcript End. Message Delivered from PDA-%#24EW#2 to $%@#!-32.--
	"}

/obj/item/paper/MorriganNT3
	name = "Slightly Damaged Note"
	icon_state = "paper"
	info ={"
	I don't know man, this seems weird. How come we haven't heard anything from CC. It's been way too long... did they turn their backs on us?<br>
	I've swipped the Mdir's Id. We can unlock the pod and get the fuck out of here.<br>
	We risked our necks out there to uncover the factory operation and now we're not even getting replies ? Our directives haven't been updated since. <br>
	Something is wrong here. I wanna tell S but he never takes these things well. Guy's an NT freak. We're already on thin ice, I'm planning to bail out of this operation. <br>
	One of the Medbay Pods is going in for maintenance in a few hours, perfect time to swipe the lock module with our hacked one. You in ? <br>
	-J
	"}

/obj/item/paper/morrigancargo
	name = "Order #781"
	icon_state = "paper"
	info = {"
	<p style="text-align: center;"><strong>Order Recieved</strong></p>
	<ul>
	<li style="text-align: left;">4 Medical Units - 20 000 x 4</li>
	<li style="text-align: left;">1 Sentinel Unit - 15 000 x 1</li>
	<li style="text-align: left;">4 Engineer Units - 23 000 x 4</li>
	<li style="text-align: left;">10 Mod.21 Deneb Handguns - 9 000 x 10</li>
	<li>TOTAL : 277 000 Credits</li>
	</ul>
	<p>Recipient : Third Party HAFGAN H.I.</p>
	<p>Thank you for your purchase !</p>
	"}

/obj/item/paper/morrigancargo2
	name = "Order #385"
	icon_state = "paper"
	info = {"
	<p style="text-align: center;"><strong>Order Recieved</strong></p>
	<ul>
	<li style="text-align: left;">1 CQC Unit - 25 000 x 1</li>
	<li style="text-align: left;">2 Sentinel Units - 15 000 x 2</li>
	<li style="text-align: left;">5 Mod.77 Nosaxa - 15 000 x 4</li>
	<li style="text-align: left;">20 Mod.21 Deneb Handguns - 9 000 x 20</li>
	<li>TOTAL : 295 000 Credits</li>
	</ul>
	<p>Recipient : Third Party HAFGAN H.I.</p>
	<p>Thank you for your purchase !</p>
	"}


/obj/item/paper/morrigance
	name = "In case you're locked out"
	icon_state = "paper"
	info = {"
	What kind of IDIOT are you ? Are you trying to get all of us fired Matheos ? Why were you even IN there ? My fucking god, it's not even something I expected of you<br>
	You KNOW the bridge is restricted, let alone the Conference room. You're asking for trouble man, you know I'm relaxed but this is just fucked up.<br>
	Don't ever, EVER go anywhere near there again !<br>
	--Transcript End. Message Delivered to PDA-Matheos Nummer From PDA-Chief Engineer(Id WiP) and Security Department.--
	"}

/obj/item/paper/balor_IT
	name = "Note from IT"
	icon_state = "paper"
	info = {"Since some of you (Kingfisher) seem incapable of operating the damn teleporter without waking me up, here's an idiots guide:<br>
	Ensure the prisoner is restrained, this should be obvious but we've had multiple angry emails from Lero just this month about improperly restrained prisoners.<br>
	Run the control program, it's all preconfigured now so there should be no more incidents of prisoners ending up 2 lightyears the wrong way because <i>Kingfisher</i> can't do basic linear algebra.<br>
	You can find the program in /sys/srv, and you'll need to SU to access it. Why is it there? Look, this entire OS is held together with duct tape and patent infringment, don't even ask.<br>
	And above all DO NOT stand on the pad when it's active, unless you feel like reciting code phrases to Lero security for the next 6 hours.<br><br>
	- Technical Operative Banks
	"}

/obj/item/paper/sentinelunit
	name = "Sentinel Unit"
	icon_state = "paper"
	info = {"
	<h2 style="text-align: center;"><span style="text-decoration: underline;"><strong>Sentinel Unit</strong></span></h2>
	<p>The Sentinel Unit, also known as "Gunbot" comes from a long line of research and fine tuning to deliver you</p>
	<p>a one size fit all generic, yet still formidable ally. This unit comes with state of the art weaponary. Featuring over 80% accuracy and increased durability.</p>
	<p>The model 5, currently commercially available will relieve you of combat duties. Able to be confirgured for both lethal and non-lethal engagements, the Model 5 Sentinel Unit can patrol stations, roam colonies, or even be deployed along missions !</p>
	<p>It's features include but are not limited to :&nbsp;</p>
	<ul>
	<li>A sturdy reinforced body</li>
	</ul>
	<p>Able to endure much more damage than any of its previous models.</p>
	<ul>
	<li>.38 Semi-Automatic Gun Arm</li>
	</ul>
	<p>The lethal setting allows the Sentinel Unit to engage targets using easy-to-find and reliable .38 rounds commonly found across the frontier!</p>
	<ul>
	<li>AP Rubber Slug Gun Arm</li>
	</ul>
	<p>On the fly, the Gunbot is able to swap into a non-lethal setting with Anti Personnel rubber slugs guaranteed to subdue foes with minimal damage!</p>
	<ul>
	<li>Adaptable AI</li>
	</ul>
	<p>The Sentinel Unit comes pre-packed with state of the art AI able to identify friendly and non friendly individuals based off a multitude of customizable modules!</p>
	<p>And much much more ! Order yours today !</p>
	"}
/obj/item/paper/cqcunit
	name = "CQC Unit"
	icon_state = "paper"
	info = {"
	<h2 style="text-align: center;"><span style="text-decoration: underline;"><strong>CQC Unit</strong></span></h2>
	<p>The Close Quarters Combat Unit, also known as "Meleebot" comes from a long line of research and fine tuning to deliver you :</p>
	<p>A specialized, devastating, and effective robot companion. This unit comes with razor sharp uqil reinforced claws. Featuring over 15 different combat patterns, let the CQC Unit take the risk for you!</p>
	<p>The model 3, currently commercially availabe will remove all risks when handling tight or narrow urban engagements. This lethal meleebot will not let you down !</p>
	<p>It's features include but are not limited to :&nbsp;</p>
	<ul>
	<li>A sturdy reinforced body</li>
	</ul>
	<p>Able to endure much more damage than any of its previous models.</p>
	<ul>
	<li>2 Rotator Claw Arms</li>
	</ul>
	<p>Able to grab, jab, maul, and tear your assailants to shreds, the melee bot cuts deep and never dulls!</p>
	<ul>
	<li>GRABBER Tech Hookshot</li>
	</ul>
	<p>Your would be foes fleeing away at the sight of the fearsome CQC Unit ? Try the GRABBER tech Hookshot installed with all CQC units to bring your foes to you!</p>
	<p>And much much more ! Order yours today !</p>
	"}
/obj/item/paper/riotunit
	name = "Riot Unit"
	icon_state = "paper"
	info = {"
	<h2 style="text-align: center;"><span style="text-decoration: underline;"><strong>Riot Suppression Unit</strong></span></h2>
	<p>The Riot Suppression Unit, also known as "Riotbot" comes from a long line of research and fine tuning to deliver you :</p>
	<p>A specialized, Tough and durable machine to quel all your crowd control needs!</p>
	<p>Thoughts of revolutions on your station ? Uproar of the masses on your colony ? Not with the Riot Bot! They will think twice upon seeing the face of your menacing friend.</p>
	<p>The model 2.2, currently commercially availabe will assist when dealing with no-gooders who cause trouble. Numbers don't scare it, nothing does!</p>
	<p>It's features include but are not limited to :&nbsp;</p>
	<ul>
	<li>An extremely reinforced body</li>
	</ul>
	<p>Able to withstand the most of punishment between all our units.</p>
	<ul>
	<li>AP Staggerlock Shotgun arm</li>
	</ul>
	<p>A less-than-lethal shotgun arm which will slow any would be assailants down to a crawls pace so that you and your security force can lock'em up!</p>
	<ul>
	<li>A Formidable Robust Shield</li>
	</ul>
	<p>Able to outright deflect damage, this shield will keep the robot upstand and ready for action much longer than any police force!</p>
	<ul>
	<li>Tactical Shield Repulsion Technology</li>
	</ul>
	<p>Keep them at bay with the Riotbot's TSRT, a shift burst of highly compressed air to send them and anything they throw flying back!</p>
	<p>And much much more ! Order yours today !</p>
	"}

// Audio Tapes
/obj/item/audio_tape/morrigan_interrogation
	New()
		..()

		messages = list(
	"Come on, you know we aren't buying that.. even you can realize there's no way you weren't the source of the problem.",
	"You know I can't help you like this, think with me here... you just happened to be there when security arrived ?",
	"You're not going to make this any better on yourself. We know what happened, we have cameras, we are just giving you a chance to explain yourself.",
	"I know what you people do... there's just no point. Lock me up already.",
	"Of course there's a point. There's always a point. Maybe it was an accident. You aren't a bad person are you?",
	"...are you...Soren?",
	"That's not my na-",
	"Shh.. this is all off the record. But you can't expect me to not notice things off.",
	"This missing here, that disappears there... I'm not blind to this. We know what you're doing.",
	"You'd have been executed already, if it weren't for me. Call it a favor.",
	"*static*",
	"Looks like our time is done, think carefully about our conversation today, Matheos. "
	)

		speakers = list(
		"Filtered voice",
		"Filtered voice",
		"Filtered voice",
		"Male voice",
		"Filtered voice",
		"Filtered voice",
		"Male Voice",
		"Filtered Voice",
		"Filtered Voice",
		"Filtered Voice",
		"???",
		"Filtered Voice")

/obj/item/audio_tape/morrigan_interrogation2
	New()
		..()

		messages = list(

	"We're past that now. You know, I commend your skill even. If things were different.. you'd make for an excellent operative.",
	"I am just an engineer, nothing more.",
	"You are hunh ? We usually keep most records redacted for security reasons, but I've managed to get a hand on yours.",
	"...*sighs*",
	"Do you know why I've spent so much time with you Soren?",
	"Stop. Calling. Me. That.",
	"We have all the information we need already.",
	"You don't know what you're talking about-",
	"You're not the only one here. Ever since we've become a temporary prison service for that fucked up station, we've had dozens like you through here.",
	"While it's not our primary job, we have sensitive material here, of course we'd KNOW Soren. You and your 3 other little lambs won't dent our operation.",
	"Your little friend 'A' is already in custody. So quit the fucking act. We know what NanoTrasen is capable of.",
	"*undiscernable noises*",
	"*Deep Breath* Because I was part of them.",
	"...holy fuck Alderman?!"
	)

		speakers = list(
		"Filtered voice",
		"Matheos's voice",
		"Filtered voice",
		"Matheos's voice",
		"Filtered voice",
		"Matheos' voice",
		"Filtered Voice",
		"Matheos's Voice",
		"Filtered Voice",
		"Filtered Voice",
		"Filtered Voice",
		"???",
		"Male Voice",
		"Soren's Voice")

/obj/item/audio_tape/morrigan_interrogation3
	New()
		..()

		messages = list(

	"But how ? We ... we all thought..",
	"That doesn't matter. What you need to understand is that NanoTrasen betrayed us. They don't care about you Soren. You don't matter.",
	"Because the syndicate is somehow better Alderman ? Hunh ? You think terrorizing employees just going about their day is the right thing to do?",
	"What is the right thing to do then?",
	"Definitely not this! You're better than this.",
	"We do what we must in this grand game. I've found my place here. There was no attempt EVER to try to rescue us Soren. Not one.",
	"I tried coming back, it was just.. so hard there was just so much snow.. I thought..",
	"That wasn't your job. And neither is it mine to sit here and chat with you.",
	"...what are you getting at ?",
	"It's not too late Soren. Those pest friends of yours didn't have this luxury. I'm going above and beyond for an old friend.",
	"I... Alderman you know this just.",
	"*undiscernable noises*",
	"I don't want to see you die pointlessly. It's hell on both sides, they knew the risks... at least we could endure hell together again.",
	"Alderman...",
	"It's Alexander now. I can't do more for you. I'm calling them to take you back to your cell, you already know too much. Make the right choice."
	)

		speakers = list(
		"Soren's Voice",
		"Alderman's Voice",
		"Soren's Voice",
		"Alderman's Voice",
		"Soren's Voice",
		"Alderman's Voice",
		"Soren's Voice",
		"Alderman's Voice",
		"Soren's Voice",
		"Alderman's Voice",
		"???",
		"Filtered Voice",
		"Soren's Voice",
		"Filtered Voice"
		)
// Lockers with restricted access

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
	name = "Engineering Locker"
	reinforced = TRUE
	req_access = list(access_morrigan_medical, access_morrigan_mdir, access_morrigan_captain, access_morrigan_exit)
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "secure_white-open"
	spawn_contents = list()

// Secure Crates

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


//hobo dialogue man !!!!!

/obj/dialogueobj/hobo
	icon = 'icons/obj/trader.dmi'
	icon_state = "hoboman"
	density = TRUE
	anchored = ANCHORED_ALWAYS
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/hobo(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

/datum/dialogueMaster/hobo
	dialogueName = "Hobo"
	start = /datum/dialogueNode/hobo_start
	maxDistance = 1

//start of the dialogue
/datum/dialogueNode/hobo_start
	linkText = "..."
	links = list(/datum/dialogueNode/hobo_who,/datum/dialogueNode/hobo_question,/datum/dialogueNode/hobo_where)

	getNodeText(var/client/C)
		return pick("I haven't seen my wife in 30 years, only the drugs bring her back.", "Fuck off already.", "I need me drugs...")

/datum/dialogueNode/hobo_who
	linkText = "Who are you?"
	links = list()

	getNodeText(var/client/C)
		return "None of your fucking business is who I am yeah ? Just call me 'John'."

/datum/dialogueNode/hobo_question
	linkText = "How do I leave?"
	links = list(/datum/dialogueNode/hobo_thank)
	nodeText = "Bloody scammed yeah."

	getNodeText(var/client/C)
		return "If you can get past the addicts and the creepy shit out there, I hear there's some old id hidden in some bum middle of here. Us sane few barricaded ourselves in, if you go out there you're on your own."
/datum/dialogueNode/hobo_where
	linkText = "Where am I ?"
	links = list(/datum/dialogueNode/hobo_thank)
	nodeText = "Bloody scammed yeah."

	getNodeText(var/client/C)
		return "Where do you think ? Fuckin' paradise. You're on Lero you bumbling ape. Otherwise known as the slammer. Don't know what you've done, don't care either just keep away from me and my mates' shit."

/datum/dialogueNode/hobo_thank
	linkText = "Thank you."
	links = list()

	getNodeText(var/client/C)
		return pick("Whatever.", "Just bugger off already will you?", "Fuck off already.", "Cool, mate.")

// Critter area
/mob/living/critter/robotic/gunbot/morrigan

/mob/living/critter/robotic/gunbot/morrigan/gunbot
	name = "Syndicate Sentinel Unit"
	real_name = "Syndicate Sentinel Unit"
	desc = "One of Morrigan's classic models... best avoid it."
	health_brute = 20
	health_burn = 20
	is_npc = TRUE
	speak_lines = TRUE
	icon_state = "mars_nuke_bot"
	eye_light_icon = "mars_nuke_bot_eye"

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("POTENTIAL INTRUDER. MOVING TO ELIMINATE.","YOU DO NOT BELONG HERE.","ALERT - ALL SYNDICATE PERSONNEL ARE TO MOVE TO A SAFE ZONE.","WARNING: THREAT RECOGNIZED AS NANOTRASEN.","Help!! Please I don- RESETTING.","YOU CANNOT ESCAPE. SURRENDER. NOW.","NANOTRASEN WILL LEAVE YOU BEHIND.","THIS IS NOT EVEN MY FINAL FORM."))

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/meleebot
	name = "Syndicate CQC Unit"
	real_name = "Syndicate CQC Unit"
	desc = "A security robot specially designed for close quarters combat. Prone to overheating.."
	health_brute = 20
	health_burn = 10
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "clawbot"
	ai_type = /datum/aiHolder/aggressive
	eye_light_icon = "clawbot-eye"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/hookshot)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("GET. OVER. HERE.", "PREPARE TO BE TORN TO SHREDS.", "NANOTRASEN SCUM DETECTED.", "MOVING TO ENGAGE.", "THESE CLAWS DO NOT CARE ABOUT YOUR FEELINGS.", "SURRENDER OR BE DESTROYED.", "THIS ENDS BADLY FOR YOU.", "YOU DO NOT BELONG HERE."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left arm"
		HH.limb_name = "mauler claws"

		HH = hands[2]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right arm"
		HH.limb_name = "mauler claws"


	critter_ability_attack(mob/target)
		var/datum/targetable/critter/hookshot = src.abilityHolder.getAbility(/datum/targetable/critter/hookshot)
		if (!hookshot.disabled && hookshot.cooldowncheck())
			hookshot.handleCast(target)
			return TRUE

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/riotbot
	name = "Syndicate Suppression Unit"
	real_name = "Syndicate Suppression Unit"
	desc = "A sturdy version with a shield for increased survivability. Not nearly as lethal as the others though."
	health_brute = 30
	health_burn = 30
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "riotbot"
	ai_type = /datum/aiHolder/ranged
	eye_light_icon = "riotbot-eye"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/shieldproto)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("HALT SLIMEBUCKET!", "SUPPRESSION IN PROGRESS.", "NANOTRASEN INTRUDER DETECTED.", "APPROACHING.", "HASTA LA VISTA BABY.", "TURN YOURSELF IN. IT IS NOT TOO LATE.", "RUB YOUR STOMACH AND PAT YOUR HEAD-- ERROR", "YOU CANNOT STOP ME."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/morriganabg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.limb = new /datum/limb/gun/kinetic/morriganabg
		HH.name = "ABG Riot Suppression Appendage"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handabg"
		HH.limb_name = "ABG Riot Suppression Appendage"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE

	critter_ability_attack(mob/target)
		var/datum/targetable/werewolf/werewolf_defense = src.abilityHolder.getAbility(/datum/targetable/werewolf/werewolf_defense)
		if (!werewolf_defense.disabled && werewolf_defense.cooldowncheck())
			werewolf_defense.handleCast(target)
			return TRUE


	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/engineerbot
	name = "Syndicate MULTI Unit"
	real_name = "Syndicate MULTI Unit"
	desc = "An engnieering unit, you can somehow feel that it's angry at you."
	health_brute = 20
	health_burn = 10
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "engineerbot"
	ai_type = /datum/aiHolder/aggressive
	eye_light_icon = "engineerbot-eye"

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/nano_repair)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("SMASH.", "THIS IS NOT WHERE YOU ARE SUPPOSED TO BE.", "NANOTRASEN TRESPASSING.", "YOUR PUNY FISTS CANNOT HURT ME.", "I WILL DECODE YOU.", "WHERE IS YOUR FIRE EXTINGUISHER.", "I HAVE PRESSED BOLTS HARDER THAN YOU.", "SHOULD HAVE NEVER COME HERE."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/transposed/morrigan
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "welderhand"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

		HH = hands[2]
		HH.limb = new /datum/limb/transposed/morrigan
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "hand_martian"
		HH.name = "Soldering Iron"
		HH.limb_name = "soldering iron"

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

/mob/living/critter/robotic/gunbot/morrigan/medibot
	name = "Syndicate Medical Unit"
	real_name = "Syndicate Medical Unit"
	desc = "A medical unit, doesn't pose as much of a threat. Looks a little smaller than the other ones."
	health_brute = 20
	health_burn = 10
	icon = 'icons/obj/adventurezones/Morrigan/critter.dmi'
	icon_state = "medibot"
	ai_type = /datum/aiHolder/ranged
	eye_light_icon = "medibot-eye"


	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		abilityHolder.addAbility(/datum/targetable/critter/robofast)

	seek_target(range)
		. = ..()

		if (length(.) && prob(10) && src.speak_lines)
			src.say(pick("YOU ARE NOT ON RECORDS.", "WAIT YOUR TURN.", "NANOTRASEN PATIENT DETECTED. CONFLICT.", "WAIT, I DON'T WANT TO HELP.", "THIS IS CONFUSING.", "YOU ARE NOT COVERED BY OUR HEALTH PLAN.", "I KNEW IT, I SHOULD'VE BEEN A SENTINEL UNIT", "LEAVE. NOW."))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/syringe/morrigan
		HH.name = "Syringe Gun"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun"
		HH.limb_name = "Syringe Gun"

		HH = hands[2]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right arm"
		HH.limb_name = "mauler claws"

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 2

	setup_equipment_slots()
		return

// Teleporter objects

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

//Suit stuff

/obj/item/clothing/suit/space/syndiehos
	name = "Head of Security's coat"
	desc = "A slightly armored jacket favored by Syndicate security personnel!"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
	icon_state = "syndicommander_coat"
	item_state = "thermal"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 35)

/obj/item/clothing/under/suit/syndiehos
	name = "Head of Security's Decorated Suit"
	desc = "An imposing jumpsuit that radiates with... evil order?"
	icon = 'icons/obj/clothing/uniforms/item_js_rank.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
	icon_state = "hos_syndie"
	item_state = "kilt"

/obj/item/clothing/under/rank/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/underitem.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'

/obj/item/clothing/under/rank/morrigan/robofab
	name = "Robotics Engineer Jumpsuit"
	desc = "A uniform issued to those working on turning the raw parts into useable circuitry."
	icon_state = "robofab"
	item_state = "black"

/obj/item/clothing/under/rank/morrigan/quality
	name = "Quality Control Jumpsuit"
	desc = "Guaranteed or money back!"
	icon_state = "quality"
	item_state = "black"

/obj/item/clothing/under/rank/morrigan/sce
	name = "Chief Engineer's Uniform"
	desc = "A simple outfit for the CE."
	icon_state = "sce"
	item_state = "grey"

/obj/item/clothing/under/rank/morrigan/executive
	name = "Hafgan Executive's Suit"
	desc = "You wouldn't know it was Hafgan's if it weren't for the big H on the coat..."
	icon_state = "executive"
	item_state = "suitB"

/obj/item/clothing/under/rank/morrigan/sec
	name = "Security Jumpsuit"
	desc = "Needs no explaining.."
	icon_state = "sec"
	item_state = "darkred"

/obj/item/clothing/under/rank/morrigan/scap
	name = "Captain's Suit"
	desc = "Fancy!"
	icon_state = "scap"
	item_state = "red"

/obj/item/clothing/under/rank/morrigan/weaponsmith
	name = "Weapon Smith's Overalls"
	desc = "Includes a handy pouch to store tools in."
	icon_state = "weaponsmith"
	item_state = "brown"

/obj/item/clothing/under/rank/morrigan/shop
	name = "Head of Personnel's Suit?"
	desc = "What is this ??"
	icon_state = "shop"
	item_state = "grey"

/obj/item/clothing/under/rank/morrigan/scargo
	name = "Exports Jumpsuit"
	desc = "TOO BRIGHT"
	icon_state = "scargo"
	item_state = "yellow"

/obj/item/clothing/under/rank/morrigan/srd
	name = "Research Director's suit"
	desc = "They mostly research materials here"
	icon_state = "srd"
	item_state = "purple"

/obj/item/clothing/suit/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/overcoat.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'

/obj/item/clothing/suit/morrigan/executive
	name = "Executive's Coat"
	desc = "See ? A big damn H"
	icon_state = "executive"
	item_state = "wcoat"

/obj/item/clothing/suit/morrigan/captain
	name = "Captain's Coat"
	desc = "Keeps out the cold! The zipper is bust though."
	icon_state = "captain"
	item_state = "wizardred"

/obj/item/clothing/suit/morrigan/srd
	name = "Research Director's Coat"
	desc = "What an ugly palette..."
	icon_state = "srdlabcoat"
	item_state = "labcoat"

/obj/item/clothing/head/morrigan
	icon = 'icons/obj/adventurezones/morrigan/clothing/hats.dmi'
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'

/obj/item/clothing/head/morrigan/swarden
	name = "Warden's Cap"
	desc = "A cap worn by the Syndicate Corrections Officers."
	icon_state = "swarden"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/sberet
	name = "Gray Beret"
	desc = "Standard issue beret for security aboard Morrigan"
	icon_state = "sberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/hafberet
	name = "Captain's Beret"
	desc = "They really like their berets hunh..."
	icon_state = "hafberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/shos
	name = "Head of Security's Peak Cap"
	desc = "Sleek, evil and definitely not for you."
	uses_multiple_icon_states = 1
	icon_state = "shos"
	item_state = "tinfoil"
	var/folds = 0

/obj/item/clothing/head/morrigan/shos/attack_self(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.folds)
			src.folds = 1
			src.name = "Head Of Security's Beret"
			src.icon_state = "sberetdec"
			src.item_state = "tinfoil"
			boutput(user, "<span class='notice'>You fold the hat into a beret.</span>")
		else
			src.folds = 0
			src.name = "Head of Security's Peak Cap"
			src.icon_state = "shos"
			src.item_state = "tinfoil"
			boutput(user, "<span class='notice'>You unfold the beret back into a hat.</span>")
		return

/obj/item/clothing/head/morrigan/sberetdec
	name = "Head Of Security's Beret"
	desc = "More fucking berets..."
	icon_state = "sberetdec"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/rdberet
	name = "Research Director's Beret"
	desc = "A purple beret for the research director"
	icon_state = "rdberet"
	item_state = "tinfoil"

/obj/item/clothing/head/morrigan/rndhelmet
	name = "Protective Headgear"
	desc = "Complicated headgear you don't understand.."
	icon_state = "rndhelmet"
	item_state = "welding-fire"

//Self Destruct Button

//This supposed to replace the nuclear charge at the end of Morrigan.

//WIP
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

	disposing()
		STOP_TRACKING
		..()

/obj/machinery/door/poddoor/buff/morrigan_lockdown/open
	New()
		..()
		src.open()

/obj/fakeobjects/morrigan/broken_lockdown
	name = "lockdown door"
	desc = "Door used for lockdowns. This one seems to be malfunctioning."
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "pdoor0"
	layer = OBJ_LAYER + 1

//funny chute

/obj/item/collecting_chute

	name = "collecting chute"
	desc = "put stuff in it"
	icon = 'icons/obj/disposal.dmi'
	icon_state = "disposal"
	anchored = ANCHORED
	density = TRUE
	var/required_objects = list(/obj/item/fishing_rod, /obj/item/gun/energy/railgun_experimental) //temporary
	var/functioning = TRUE

	New()
		. = ..()

	proc/put_item(var/obj/item/W, var/mob/user)
		W.set_loc(src)
		user.u_equip(W)
		for (W in src)
			for (var/obj in required_objects)
				if (istype(W, obj))
					return
				else
					sleep(2 SECONDS)
					W.set_loc(src.loc)
					src.visible_message("<span class='alert'><b>The chute spits [W] out! Looks like it doesn't accept it..</b></span>")
					return

	proc/check_contents()
		var/items_collected = 0
		for (var/item in src)
			for (var/required_item in required_objects)
				if (istype(item, required_item))
					items_collected += 1
		if (length(required_objects) == items_collected)
			src.visible_message("<span class='alert'><b>\The [src] makes a beep!</b></span>")
			playsound(src, 'sound/effects/zzzt.ogg', 50, TRUE)
			src.functioning = FALSE
			return
		else
			return

	attackby(obj/item/W, mob/user)
		if(src.functioning)
			put_item(W, user)
			check_contents()
			return
		else
			boutput(user, "<span class='alert'><b>\The [src] doesn't seem to work!</b></span>")
			return

//gas mask please i beg

/obj/item/clothing/mask/gas/eyemask
	name = "Z-4KU mask"
	desc = "A nifty LED Mask that changes color in hand!"
	icon_state = "eyemask"
	item_state = "gas_mask"
	uses_multiple_icon_states = 1
	color_r = 1
	color_g = 0.8
	color_b = 0.8

	attack_self(mob/user)
		user.show_text("The LED changes color!")
		if (src.icon_state == "eyemask")
			src.icon_state = "eyemask_b"
		else if (src.icon_state == "eyemask_b")
			src.icon_state = "eyemask_g"
		else if (src.icon_state == "eyemask_g")
			src.icon_state = "eyemask_p"
		else if (src.icon_state == "eyemask_p")
			src.icon_state = "eyemask_y"
		else
			src.icon_state = "eyemask"
/obj/item/clothing/mask/swat/haf
	name = "Strange Mask"
	desc = "Not your usual colors..."
	icon_state = "swathaf"
	item_state = "swathaf"

	color_r = 0.8
	color_g = 0.8
	color_b = 0.8

//WEAPONS-------------------------------------------------------------------------------

//Railgun
TYPEINFO(/obj/item/gun/energy/railgun_experimental)
	mats = null
/obj/item/gun/energy/railgun_experimental
	name = "Mod.54 Electro Slinger"
	cell_type = /obj/item/ammo/power_cell/self_charging/railgun_experimental
	icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
	icon_state = "railgun"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	desc = "An experimental Morrigan weapon that draws a lot of power to fling projectiles are dangerous speeds, it seems to be in working condition."
	item_state = "railgun"
	force = 10
	shoot_delay = 1 SECONDS
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_elec"
	charge_icon_state = "railgun"
	w_class = W_CLASS_BULKY
	c_flags = ONBACK | ONBELT
	cantshootsound = 'sound/weapons/railgunwait.ogg'

	New()
		set_current_projectile(new/datum/projectile/bullet/optio/hitscanrail)
		projectiles = list(new/datum/projectile/bullet/optio/hitscanrail)
		..()

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_BELT)
			wear_image_icon = 'icons/mob/clothing/belt.dmi'
			wear_layer = MOB_BACK_SUIT_LAYER
		else if (slot == SLOT_BACK)
			wear_image_icon = 'icons/mob/clothing/back.dmi'
			wear_layer = MOB_BACK_LAYER
		..()

//pistol
TYPEINFO(/obj/item/gun/energy/hafpistol)
	mats = null
/obj/item/gun/energy/hafpistol
	name = "Mod.21 Deneb"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/hafpistol
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "laser"
	desc = "A popular self defense handgun favored by security and adventuring spacefarers alike! Features a lethal and less than lethal mode."
	item_state = "hafpistol"
	force = 5
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "laser"

	New()
		set_current_projectile(new/datum/projectile/laser/hafplethal)
		projectiles = list(current_projectile,new/datum/projectile/laser/hafpless)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/hafplethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "laser"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "hafpistol"
		else if (current_projectile.type == /datum/projectile/laser/hafpless)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "laserless"
			muzzle_flash = "muzzle_flash_bluezap"
			item_state = "hafpistoless"
		..()

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

TYPEINFO(/obj/item/gun/energy/peacebringer)
	mats = null
/obj/item/gun/energy/peacebringer
	name = "The Aberrant"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/peacebringer
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "peacebringer"
	desc = "A scary albeit it, silly, energy revolver custom made for the Morrigan head of security."
	item_state = "peacebringer"
	force = 10
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "peacebringer"

	New()
		set_current_projectile(new/datum/projectile/bullet/optio/peacebringer)
		projectiles = list(current_projectile,new/datum/projectile/bullet/optio/peacebringerlesslethal)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/bullet/optio/peacebringer)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "peacebringer"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "peacebringer"
		else if (current_projectile.type == /datum/projectile/bullet/optio/peacebringerlesslethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "peaceless"
			muzzle_flash = "muzzle_flash_waveg"
			item_state = "peacebringerless"
		..()

	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

TYPEINFO(/obj/item/gun/energy/smgmine)
	mats = null
/obj/item/gun/energy/smgmine
	name = "HMT Lycon"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
	icon_state = "minesmg"
	desc = "A tool issued to miners thoughout space, deemed extremely reliable for both punching through rock and punching through hostile fauna."
	item_state = "smgmine"
	force = 5
	can_swap_cell = TRUE
	rechargeable = TRUE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_laser"
	charge_icon_state = "minesmgfire"
	spread_angle = 4

	New()
		set_current_projectile(new/datum/projectile/laser/mining/smgmine)
		projectiles = list(current_projectile,new/datum/projectile/laser/smgminelethal)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/mining/smgmine)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "minesmgfire"
			muzzle_flash = "muzzle_flash_elec"
			item_state = "smgmining"
		else if (current_projectile.type == /datum/projectile/laser/smgminelethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gun.dmi'
			charge_icon_state = "minesmg"
			muzzle_flash = "muzzle_flash_wavep"
			item_state = "smgmine"
			spread_angle = 10
		..()
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()

//shotgun
TYPEINFO(/obj/item/gun/energy/lasershotgun)
	mats = null
/obj/item/gun/energy/lasershotgun
	name = "Mod. 77 Nosaxa"
	uses_multiple_icon_states = 0
	cell_type = /obj/item/ammo/power_cell/self_charging/lasershotgun
	icon = 'icons/obj/adventurezones/morrigan/weapons/gun48.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "lasershotgun"
	desc = "A burst shotgun with short range. Sold for heavy crowd control and shock tactics."
	item_state = "lasershotgun"
	c_flags = ONBACK | ONBELT
	force = 10
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	muzzle_flash = "muzzle_flash_red"
	charge_icon_state = "lasershotgun"
	var/racked_slide = FALSE
	var/shotcount = 0

	New()
		set_current_projectile(new/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun)
		projectiles = list(new/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun)
		..()

	canshoot(mob/user)
		return(..() && src.racked_slide)

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 1)
			src.racked_slide = FALSE

	shoot_point_blank(atom/target, mob/user, second_shot)
		if (!shoot_check(user))
			return
		..()
		if (src.shotcount++ >= 2)
			src.racked_slide = FALSE

	equipped(var/mob/user, var/slot)
		if (slot == SLOT_BELT)
			wear_image_icon = 'icons/mob/clothing/belt.dmi'
			wear_layer = MOB_BACK_SUIT_LAYER
		else if (slot == SLOT_BACK)
			wear_image_icon = 'icons/mob/clothing/back.dmi'
			wear_layer = MOB_BACK_LAYER
		..()

	proc/shoot_check(var/mob/user)
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
			boutput(user, "<span class ='notice'>You are out of energy!</span>")
			return FALSE

		if (!src.racked_slide)
			boutput(user, "<span class='notice'>You need to vent before you can fire!</span>")
			return FALSE

		if (GET_COOLDOWN(src, "rack delay"))
			boutput(user, "<span class ='notice'>Still cooling!</span>")
			return FALSE
		return TRUE

	attack_self(mob/user as mob)
		..()
		src.rack(user)

	proc/rack(var/mob/user)
		if (!src.racked_slide)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, amount) & CELL_INSUFFICIENT_CHARGE)
				boutput(user, "<span class ='notice'>You are out of energy!</span>")

			else
				src.racked_slide = TRUE
				src.shotcount = 0
				boutput(user, "<span class='notice'>You release some heat from the shotgun!</span>")
				playsound(src, 'sound/ambience/morrigan/steamrelease.ogg', 70, 1)
				ON_COOLDOWN(src, "rack delay", 1 SECONDS)
//rifle unused but there for completion reasons i'm sick please help - rex
TYPEINFO(/obj/item/gun/energy/laserifle)
	mats = null
/obj/item/gun/energy/laserifle
	name = "Mod. 201 Mimosa"
	uses_multiple_icon_states = 1
	cell_type = /obj/item/ammo/power_cell/self_charging/medium
	icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
	icon_state = "laserifle"
	desc = "The lastest product from Morrigan, a self charging rifle made for peace..or..war keeping with not stolen technology."
	item_state = "laserifle"
	force = 10
	two_handed = TRUE
	can_swap_cell = FALSE
	rechargeable = FALSE
	uses_charge_overlay = TRUE
	charge_icon_state = "laserifle"
	spread_angle = 3

	New()
		set_current_projectile(new/datum/projectile/laser/laseriflelethal)
		projectiles = list(current_projectile,new/datum/projectile/laser/laseriflelesslethal)
		..()

	update_icon()
		if (current_projectile.type == /datum/projectile/laser/laseriflelethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
			charge_icon_state = "laserifle"
			muzzle_flash = "muzzle_flash_laser"
			item_state = "laserifle"
		else if (current_projectile.type == new/datum/projectile/laser/laseriflelesslethal)
			icon = 'icons/obj/adventurezones/morrigan/weapons/gunlarge.dmi'
			charge_icon_state = "laserifleless"
			muzzle_flash = "muzzle_flash_waveg"
			item_state = "laserless"
		..()
	attack_self(var/mob/M)
		..()
		UpdateIcon()
		M.update_inhands()


// stun baton
/obj/item/baton/windup/morrigan
	name = "Mod.33 Izar"
	desc = "An experimental stun baton, designed to incapacitate targets consistently. It has safeties against users stunning themselves."
	icon = 'icons/obj/adventurezones/morrigan/weapons/weapon.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "synd_baton"
	item_state = "synd_baton-off"
	icon_on = "synd_baton-A"
	icon_off = "synd_baton"
	item_on = "synd_baton-A"
	item_off = "synd_baton-D"
	force = 15
	throwforce = 7
	contraband = 4
	can_swap_cell = FALSE

	attack_self(var/mob/user)
		if (src.flipped)
			user.show_text("The internal safeties kick in stopping you from turning on the baton!", "red")
			return
		..()

	the_stun(var/mob/target)
		target.changeStatus("weakened", 5 SECONDS)
		src.delStatus("defib_charged")
		src.is_active = FALSE
		src.UpdateIcon()
		target.update_inhands()

	intent_switch_trigger(var/mob/user)
		if (src.is_active)
			src.is_active = FALSE
			src.UpdateIcon()
			user?.update_inhands()
			user?.show_text("The internal safeties kick in turning off the baton!", "red")
		..()

//projectiles
/datum/projectile/bullet/optio/hitscanrail
	name = "hardlight beam"
	sname = "electro magnetic shot"
	damage = 61
	cost = 900
	max_range = PROJ_INFINITE_RANGE
	shot_sound = 'sound/weapons/railgunfire.ogg'
	dissipation_rate = 0
	projectile_speed = 2400
	armor_ignored = 0.33
	window_pass = FALSE


	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,0,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			O.color = list(-0.8, 0, 0, 0, -0.8, 0, 0, 0, -0.8, 1.5, 1.5, 1.5)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/laser/hafpless
	name = "Mod. 21 less lethal"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "hafpistol_less"
	shot_sound = 'sound/weapons/hafpless.ogg'
	cost = 35
	damage = 10

	sname = "less-lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	brightness = 1
	color_red = 1
	color_green = 1
	color_blue = 0

	disruption = 2

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 0, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 2 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/laser/hafplethal
	name = "Mod. 21 lethal"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "signifer2_burn"
	shot_sound = 'sound/weapons/hafplethal.ogg'
	cost = 35
	damage = 22

	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	color_red = 0.1
	color_green = 0.1
	color_blue = 0.8

/datum/projectile/bullet/optio/peacebringer
	name = "Peacekeeper"
	icon = 'icons/obj/projectiles.dmi'
	shot_sound = 'sound/weapons/peacebringer.ogg'
	cost = 7
	damage = 30
	sname = "lethal"
	damage_type = D_ENERGY
	hit_type = DAMAGE_BURN
	hit_ground_chance = 30
	impact_image_state = "burn1"
	color_red = 0.8
	color_green = 0.1
	color_blue = 0.2
	projectile_speed = 1500
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	armor_ignored = 0.2
	window_pass = FALSE


	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrailRed",1,0,"HalfStartTrailRed","HalfEndTrailRed",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/bullet/optio/peacebringerlesslethal
	name = "Peacekeeper"
	icon = 'icons/obj/projectiles.dmi'
	shot_sound = 'sound/weapons/peacebringerlesslethal.ogg'
	cost = 7
	damage = 5

	sname = "less-lethal"
	damage_type = D_ENERGY
	hit_type = DAMAGE_BURN
	hit_ground_chance = 30
	impact_image_state = "burn1"
	color_red = 0.1
	color_green = 0.8
	color_blue = 0.2
	projectile_speed = 1000
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	armor_ignored = 0
	window_pass = FALSE
	color_red = 0.1
	color_green = 1
	color_blue = 0.3

	disruption = 2

	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrailGreen",1,0,"HalfStartTrailGreen","HalfEndTrailGreen",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 35, weakened = 0 SECONDS, stunned = 0 SECONDS, disorient = 7 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/laser/mining/smgmine
	name = "AC Shot"
	icon_state = "crescentmine"
	damage = 5
	cost = 20
	dissipation_delay = 3
	dissipation_rate = 8
	sname = "mining laser"
	shot_sound = 'sound/weapons/smgmine.ogg'
	damage_type = D_BURNING
	brightness = 0.8
	window_pass = 0
	color_red = 0.9
	color_green = 0.6
	color_blue = 0

	on_launch(obj/projectile/O)
		. = ..()
		O.AddComponent(/datum/component/proj_mining, 0.2, 2)

/datum/projectile/special/spreader/tasershotgunspread/morriganshotgun
	name = "laser"
	sname = "shotgun spread"
	cost = 50
	damage = 20
	damage_type = D_ENERGY
	pellets_to_fire = 3
	spread_projectile_type = /datum/projectile/laser/lasershotgun
	split_type = 0
	shot_sound = 'sound/weapons/shotgunlaser.ogg'

/datum/projectile/laser/lasershotgun
	name = "Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "redbolt"
	shot_sound = 'sound/weapons/shotgunlaser.ogg'
	cost = 50
	damage = 15
	shot_number = 1
	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(!ismob(hit))
			shot_volume = 0
			shoot_reflected_bounce(proj, hit, 2, PROJ_NO_HEADON_BOUNCE)
			shot_volume = 100
		if(proj.reflectcount >= 2)
			elecflash(get_turf(hit),radius=0, power=1, exclude_center = 0)

/datum/projectile/laser/laseriflelethal
	name = "Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "redbolt"
	shot_sound = 'sound/weapons/laserifle.ogg'
	cost = 45
	damage = 19
	shot_number = 2
	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30

/datum/projectile/laser/laseriflelesslethal
	name = "Less-Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "laserifleless"
	shot_sound = 'sound/weapons/laser_a.ogg'
	cost = 35
	pierces = -1
	damage = 7
	shot_number = 1
	sname = "less-lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 35, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 5 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/shieldpush
	name = "AP Repulsion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	shot_sound = 'sound/weapons/pushrobo.ogg'
	damage = 10

	on_hit(atom/hit, angle, var/obj/projectile/O)
		var/dir = get_dir(O.shooter, hit)
		var/pow = O.power
		if (isliving(hit))
			O.die()
			var/mob/living/mob = hit
			mob.do_disorient(stamina_damage = 20, weakened = 0, stunned = 0, disorient = pow, remove_stamina_below_zero = 0)
			var/throw_type = mob.can_lie ? THROW_GUNIMPACT : THROW_NORMAL
			mob.throw_at(get_edge_target_turf(hit, dir),(pow-7)/2,1, throw_type = throw_type)
			mob.emote("twitch_v")

/datum/projectile/laser/smgminelethal
	name = "Lethal Mode"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "signifer2_burn"
	shot_sound = 'sound/weapons/hafplethal.ogg'
	cost = 35
	damage = 6
	shot_number = 3

	sname = "lethal"
	damage_type = D_ENERGY
	hit_ground_chance = 30
	color_red = 0.1
	color_green = 0.1
	color_blue = 0.8

/datum/projectile/bullet/abg/morrigan
	name = "rubber slug"
	shot_sound = 'sound/weapons/shotgunshot.ogg'
	damage = 10
	stun = 0
	dissipation_rate = 3
	dissipation_delay = 4
	implanted = null
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	impact_image_state = "bhole"
	casing = /obj/item/casing/shotgun/blue

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(proj.power >= 16)
				var/throw_range = (proj.power > 20) ? 2 : 1

				var/turf/target = get_edge_target_turf(M, dirflag)
				M.throw_at(target, throw_range, 1, throw_type = THROW_GUNIMPACT)
				M.update_canmove()
			hit.changeStatus("staggered", clamp(proj.power/8, 5, 1) SECONDS)

		if(isliving(hit))
			var/mob/living/L = hit
			L.do_disorient(stamina_damage = 0, weakened = 0 SECOND, stunned = 0 SECOND, disorient = 7 SECONDS, remove_stamina_below_zero = 0)

/datum/projectile/syringefilled/morrigan
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	dissipation_rate = 1
	dissipation_delay = 7
	damage = 10
	hit_ground_chance = 10
	shot_sound = 'sound/effects/syringeproj.ogg'
	venom_id = list("formaldehyde", "atropine")
	inject_amount = 3.5

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if (ismob(hit))
			if (hit.reagents)
				for (var/reagent_id as anything in venom_id)
					hit.reagents.add_reagent(reagent_id, inject_amount)

/datum/projectile/special/robohook
	name = "hook"
	dissipation_rate = 1
	dissipation_delay = 7
	icon_state = ""
	damage = 1
	hit_ground_chance = 0
	shot_sound = 'sound/impact_sounds/robograb.ogg'
	var/list/previous_line = list()

	on_hit(atom/hit, angle, var/obj/projectile/P)
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		if (ismob(hit))
			var/mob/M = hit
			if(hit == P.special_data["owner"]) return 1
			var/turf/destination = get_turf(P.special_data["owner"])
			if (destination)

				M.throw_at(destination, 10, 1)

				playsound(M, 'sound/impact_sounds/stabreel.ogg', 50, 0)
				M.TakeDamageAccountArmor("All", rand(3,4), 0, 0, DAMAGE_CUT)
				M.force_laydown_standup()
				M.changeStatus("paralysis", 5 SECONDS)
				M.visible_message("<span class='alert'>[M] gets grabbed by a hook and dragged!</span>")

		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_gungrab",1,1,"start_gungrab","end_gungrab",OBJ_LAYER,1)
		SPAWN(1 DECI SECOND)
			for (var/obj/O in previous_line)
				qdel(O)
		qdel(P)


	on_launch(var/obj/projectile/P)
		..()
		if (!("owner" in P.special_data))
			P.die()
			return

	on_end(var/obj/projectile/P)	//Clean up behind us
		SPAWN(1 DECI SECOND)
			for (var/obj/O in previous_line)
				qdel(O)
		..()

	tick(var/obj/projectile/P)	//Trail the projectile
		..()
		if (previous_line != null)
			for (var/obj/O in previous_line)
				qdel(O)
		previous_line = DrawLine(P.special_data["owner"], P, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"mid_tentacle",1,1,"start_tentacle","end_tentacle",OBJ_LAYER,1)


//belts

/obj/item/storage/belt/gun/peacebringer
	name = "HoS belt"
	desc = "A stylish leather belt for holstering an expensive over the top laser revolver."
	icon = 'icons/obj/adventurezones/morrigan/belt.dmi'
	icon_state = "hosbelt"
	item_state = "hosbelt"
	slots = 7
	check_wclass = 1
	gun_type = /obj/item/gun/energy/peacebringer
	can_hold = list(/obj/item/gun/energy/peacebringer)
	can_hold_exact = list(/obj/item/gun/energy/peacebringer)
	spawn_contents = list(/obj/item/gun/energy/peacebringer)

//limbs

/datum/limb/gun/kinetic/morriganabg
	proj = new/datum/projectile/bullet/abg/morrigan
	shots = 6
	current_shots = 6
	cooldown = 3 SECONDS
	reload_time = 10 SECONDS
	muzzle_flash = "muzzle_flash"

/datum/limb/gun/kinetic/syringe/morrigan
	proj = new/datum/projectile/syringefilled/morrigan
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 10 SECONDS

/datum/limb/transposed/morrigan
	help(mob/target, var/mob/living/user)
		..()
		harm(target, user, 0)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 15, 15, 0, can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = "grab"
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/generic_hit_2.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

//sound triggers

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
//Ability
/datum/targetable/critter/hookshot
	name = "GRABBER tech"
	desc = "Keep your friends close, and enemies closer."
	icon_state = "robograb"
	cooldown = 15 SECONDS
	targeted = TRUE

	cast(atom/target)
		if (..())
			return TRUE

		var/obj/projectile/proj = initialize_projectile_pixel_spread(holder.owner, new/datum/projectile/special/robohook, get_turf(target))
		while (!proj || proj.disposed)
			proj = initialize_projectile_pixel_spread(holder.owner, new/datum/projectile/special/robohook, get_turf(target))

		proj.special_data["owner"] = holder.owner
		proj.targets = list(target)

		proj.launch()

/datum/targetable/critter/shieldproto
	name = "AP Shield"
	desc = "Knock assailants back then destroy incoming projectiles"
	icon_state = "robopush"
	cooldown = 10 SECONDS
	targeted = TRUE
	target_anything = TRUE

	var/datum/projectile/shieldpush/projectile = new

	cast(atom/target)
		var/obj/projectile/P = initialize_projectile_pixel_spread(holder.owner, projectile, target )
		logTheThing(LOG_COMBAT, usr, "used their [src.name] ability at [log_loc(usr)]")
		if (P)
			P.mob_shooter = holder.owner
			P.launch()

/datum/targetable/critter/nano_repair
	name = "nano-bot repair"
	desc = "Send out nano-bots to repair robotics in a 5 tile radius."
	icon_state = "roboheal"
	cooldown = 20 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		for (var/mob/living/critter/robotic/robot in range(5, holder.owner))
			robot.HealDamage("all", 10, 10, 0)
		playsound(holder.owner, 'sound/items/welder.ogg', 80, 0)
		return FALSE

/datum/targetable/critter/robofast
	name = "ER Speed Mode"
	desc = "Overcharge your cell to speed yourself up."
	icon_state = "robospeed"
	cooldown = 45 SECONDS
	targeted = FALSE

	cast(atom/target)
		if (..())
			return TRUE
		holder.owner.delStatus("stunned")
		holder.owner.delStatus("weakened")
		holder.owner.delStatus("paralysis")
		holder.owner.delStatus("slowed")
		holder.owner.delStatus("disorient")
		holder.owner.change_misstep_chance(-INFINITY)
		playsound(holder.owner, 'sound/machines/shielddown.ogg', 80, 1)
		holder.owner.setStatusMin("robospeed", 10 SECONDS)
		return FALSE



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
