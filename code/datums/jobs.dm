/datum/job
	var/name = null
	var/list/alias_names = null
	var/initial_name = null
	var/linkcolor = "#0FF"
	var/wages = 0
	var/limit = -1
	var/add_to_manifest = 1
	var/no_late_join = 0
	var/no_jobban_from_this_job = 0
	var/allow_traitors = 1
	///can you roll this job if you rolled antag with a non-traitor-allowed favourite job (e.g.: prevent sec mains from forcing only captain antag rounds)
	var/allow_antag_fallthrough = TRUE
	var/allow_spy_theft = 1
	var/can_join_gangs = TRUE
	var/cant_spawn_as_rev = 0 // For the revoltion game mode. See jobprocs.dm for notes etc (Convair880).
	var/cant_spawn_as_con = 0 // Prevents this job spawning as a conspirator in the conspiracy gamemode.
	var/requires_whitelist = 0
	var/mentor_only = 0
	var/requires_supervisor_job = null // Enter job name, this job will only be present if the entered job has joined already
	var/needs_college = 0
	var/assigned = 0
	var/high_priority_job = 0
	var/low_priority_job = 0
	var/cant_allocate_unwanted = 0
	var/receives_miranda = 0
	var/receives_implant = null //Will be a path.
	var/receives_disk = 0
	var/receives_security_disk = 0
	var/receives_badge = 0
	var/announce_on_join = 0 // that's the head of staff announcement thing
	var/radio_announcement = 1 // that's the latejoin announcement thing
	var/list/alt_names = list()
	var/slot_card = /obj/item/card/id
	var/spawn_id = 1 // will override slot_card if 1
	/// Oufit datum used by this job handles clothing. See 'modules/outfits'.
	var/datum/outfit/outfit = null
	var/list/access = list(access_fuck_all) // Please define in global get_access() proc (access.dm), so it can also be used by bots etc.
	var/mob/living/mob_type = /mob/living/carbon/human
	var/datum/mutantrace/starting_mutantrace = null
	var/change_name_on_spawn = 0
	var/special_spawn_location = null
	var/bio_effects = null
	var/objective = null
	var/rounds_needed_to_play = 0 //0 by default, set to the amount of rounds they should have in order to play this
	var/map_can_autooverride = 1 // if set to 0 map can't change limit on this job automatically (it can still set it manually)

	/// The faction to be assigned to the mob on setup uses flags from factions.dm
	var/faction = 0

	New()
		..()
		initial_name = name

	proc/special_setup(var/mob/M, no_special_spawn)
		if (!M)
			return
		if (receives_miranda)
			M.verbs += /mob/proc/recite_miranda
			M.verbs += /mob/proc/add_miranda
			if (!isnull(M.mind))
				M.mind.miranda = DEFAULT_MIRANDA
		M.faction |= src.faction

		SPAWN(0)
			if (receives_implant && ispath(receives_implant))
				var/mob/living/carbon/human/H = M
				var/obj/item/implant/I = new receives_implant(M)
				if (src.receives_disk && ishuman(M))
					if (H.back?.storage)
						var/obj/item/disk/data/floppy/D = locate(/obj/item/disk/data/floppy) in H.back.storage.get_contents()
						if (D)
							var/datum/computer/file/clone/R = locate(/datum/computer/file/clone/) in D.root.contents
							if (R)
								R.fields["imp"] = "\ref[I]"

			var/give_access_implant = ismobcritter(M)
			if(!spawn_id && (length(access) > 0 || length(access) == 1 && access[1] != access_fuck_all))
				give_access_implant = 1
			if (give_access_implant)
				var/obj/item/implant/access/I = new /obj/item/implant/access(M)
				I.access.access = src.access.Copy()
				I.uses = -1

			if (src.special_spawn_location && !no_special_spawn)
				var/location = special_spawn_location
				if (!istype(special_spawn_location, /turf))
					location = pick_landmark(special_spawn_location)
				if (!isnull(location))
					M.set_loc(location)

			if (ishuman(M) && src.bio_effects)
				var/list/picklist = params2list(src.bio_effects)
				if (length(picklist))
					for(var/pick in picklist)
						M.bioHolder.AddEffect(pick)

			if (ishuman(M) && src.starting_mutantrace)
				var/mob/living/carbon/human/H = M
				H.set_mutantrace(src.starting_mutantrace)

			if (src.objective)
				var/datum/objective/newObjective = new /datum/objective/crew(src.objective, M.mind)
				boutput(M, "<B>Your OPTIONAL Crew Objectives are as follows:</b>")
				boutput(M, "<B>Objective #1</B>: [newObjective.explanation_text]")

			if (M.client && src.change_name_on_spawn && !jobban_isbanned(M, "Custom Names"))
				//if (ishuman(M)) //yyeah this doesn't work with critters fix later
				var/default = M.real_name + " the " + src.name
				var/orig_real = M.real_name
				M.choose_name(3, src.name, default)
				if(M.real_name != default && M.real_name != orig_real)
					phrase_log.log_phrase("name-[ckey(src.name)]", M.real_name, no_duplicates=TRUE)

// Command Jobs

ABSTRACT_TYPE(/datum/job/command)
/datum/job/command
	linkcolor = "#00CC00"
	slot_card = /obj/item/card/id/command
	map_can_autooverride = FALSE
	can_join_gangs = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	announce_on_join = TRUE

	special_setup(mob/M, no_special_spawn)
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = "head", loc = M)
		get_image_group(CLIENT_IMAGE_GROUP_HEADS_OF_STAFF).add_image(image)

/datum/job/command/captain
	name = "Captain"
	limit = 1
	wages = PAY_EXECUTIVE
	high_priority_job = TRUE
	receives_miranda = TRUE
#ifdef RP_MODE
	allow_traitors = FALSE
#endif
	allow_antag_fallthrough = FALSE
	slot_card = /obj/item/card/id/gold
	outfit = /datum/outfit/command/captain
	rounds_needed_to_play = 30

	New()
		..()
		src.access = get_all_accesses()

/datum/job/command/captain/derelict
	//name = "NT-SO Commander"
	name = null
	limit = 0
	outfit = /datum/outfit/command/captain/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/head_of_personnel
	name = "Head of Personnel"
	limit = 1
	wages = PAY_IMPORTANT
	allow_antag_fallthrough = FALSE
	announce_on_join = TRUE
	outfit = /datum/outfit/command/head_of_personnel

	New()
		..()
		src.access = get_access("Head of Personnel")

/datum/job/command/head_of_security
	name = "Head of Security"
	limit = 1
	wages = PAY_IMPORTANT
	requires_whitelist = TRUE
	receives_miranda = TRUE
	allow_traitors = FALSE
	cant_spawn_as_con = TRUE
	receives_disk = TRUE
	receives_security_disk = TRUE
	receives_badge = TRUE
	receives_implant = /obj/item/implant/health/security/anti_mindhack
	outfit = /datum/outfit/command/head_of_security

	New()
		..()
		src.access = get_access("Head of Security")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")
		M.traitHolder.addTrait("training_security")

/datum/job/command/head_of_security/derelict
	name = null//"NT-SO Special Operative"
	limit = 0
	outfit = /datum/outfit/command/head_of_security/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/chief_engineer
	name = "Chief Engineer"
	limit = 1
	wages = PAY_IMPORTANT
	outfit = /datum/outfit/command/chief_engineer

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")

	New()
		..()
		src.access = get_access("Chief Engineer")

/datum/job/command/chief_engineer/derelict
	name = null//"Salvage Chief"
	limit = 0
	outfit = /datum/outfit/command/chief_engineer/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/command/research_director
	name = "Research Director"
	limit = 1
	wages = PAY_IMPORTANT
	outfit = /datum/outfit/command/research_director

	New()
		..()
		src.access = get_access("Research Director")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		for_by_tcl(heisenbee, /obj/critter/domestic_bee/heisenbee)
			if (!heisenbee.beeMom)
				heisenbee.beeMom = M
				heisenbee.beeMomCkey = M.ckey

/datum/job/command/medical_director
	name = "Medical Director"
	limit = 1
	wages = PAY_IMPORTANT
	outfit = /datum/outfit/command/medical_director

	New()
		..()
		src.access = get_access("Medical Director")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

#ifdef MAP_OVERRIDE_MANTA
/datum/job/command/comm_officer
	name = "Communications Officer"
	limit = 1
	wages = PAY_IMPORTANT
	outfit = /datum/outfit/command/comm_officer

	New()
		..()
		src.access = get_access("Communications Officer")
#endif

// Security Jobs

ABSTRACT_TYPE(/datum/job/security)
/datum/job/security
	linkcolor = "#FF0000"
	slot_card = /obj/item/card/id/security
	receives_miranda = TRUE

/datum/job/security/security_officer
	name = "Security Officer"
#ifdef MAP_OVERRIDE_MANTA
	limit = 4
#else
	limit = 5
#endif
	wages = PAY_TRADESMAN
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_con = TRUE
	cant_spawn_as_rev = TRUE
	receives_disk = TRUE
	receives_security_disk = TRUE
	receives_badge = TRUE
	receives_implant = /obj/item/implant/health/security/anti_mindhack
	rounds_needed_to_play = 30 //higher barrier of entry than before but now with a trainee job to get into the rythym of things to compensate
	outfit = /datum/outfit/security/security_officer

	New()
		..()
		src.access = get_access("Security Officer")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")

/datum/job/security/security_officer/assistant
	name = "Security Assistant"
	limit = 3
	cant_spawn_as_con = TRUE
	wages = PAY_UNTRAINED
	receives_implant = /obj/item/implant/health/security
	rounds_needed_to_play = 5
	outfit = /datum/outfit/security/security_assistant

	New()
		..()
		src.access = get_access("Security Assistant")

/datum/job/security/security_officer/derelict
	//name = "NT-SO Officer"
	name = null
	limit = 0
	outfit = /datum/outfit/security/security_officer/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

/datum/job/security/detective
	name = "Detective"
	limit = 1
	wages = PAY_TRADESMAN
	//allow_traitors = 0
	receives_badge = TRUE
	cant_spawn_as_rev = TRUE
	allow_antag_fallthrough = FALSE
	map_can_autooverride = FALSE
	rounds_needed_to_play = 15 // Half of sec, please stop shooting people with lethals
	outfit = /datum/outfit/security/detective

	New()
		..()
		src.access = get_access("Detective")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")

// Research Jobs

ABSTRACT_TYPE(/datum/job/research)
/datum/job/research
	linkcolor = "#9900FF"
	slot_card = /obj/item/card/id/research

/datum/job/research/geneticist
	name = "Geneticist"
	limit = 2
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/research/geneticist

	New()
		..()
		src.access = get_access("Geneticist")

#ifdef CREATE_PATHOGENS
/datum/job/research/pathologist
#else
/datum/job/pathologist // pls no autogenerate list
#endif
	name = "Pathologist"
#ifdef CREATE_PATHOGENS
	limit = 1
#else
	limit = 0
#endif
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/pathologist

	New()
		..()
		src.access = get_access("Pathologist")

/datum/job/research/roboticist
	name = "Roboticist"
	limit = 3
	wages = 200
	outfit = /datum/outfit/research/roboticist

	New()
		..()
		src.access = get_access("Roboticist")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/research/scientist
	name = "Scientist"
	limit = 5
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/research/scientist

	New()
		..()
		src.access = get_access("Scientist")

/datum/job/research/medical_doctor
	name = "Medical Doctor"
	limit = 5
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/research/medical_doctor

	New()
		..()
		src.access = get_access("Medical Doctor")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/research/medical_doctor/derelict
	//name = "Salvage Medic"
	name = null
	limit = 0
	outfit = /datum/outfit/research/medical_doctor/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

// Engineering Jobs

ABSTRACT_TYPE(/datum/job/engineering)
/datum/job/engineering
	linkcolor = "#FF9900"
	slot_card = /obj/item/card/id/engineering

/datum/job/engineering/quartermaster
	name = "Quartermaster"
	limit = 3
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/engineering/quartermaster

	New()
		..()
		src.access = get_access("Quartermaster")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_quartermaster")

/datum/job/engineering/miner
	name = "Miner"
#ifdef UNDERWATER_MAP
	limit = 6
#else
	limit = 5
#endif
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/engineering/miner

	New()
		..()
		src.access = get_access("Miner")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("training_miner")

/datum/job/engineering/engineer
	name = "Engineer"
	limit = 8
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/engineering/engineer

	New()
		..()
		src.access = get_access("Engineer")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")

/datum/job/engineering/engineer/derelict
	name = null//"Salvage Engineer"
	limit = 0
	outfit = /datum/outfit/engineering/engineer/derelict

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.show_text("<b>Something has gone terribly wrong here! Search for survivors and escape together.</b>", "blue")

// Civilian Jobs

ABSTRACT_TYPE(/datum/job/civilian)
/datum/job/civilian
	linkcolor = "#0099FF"
	slot_card = /obj/item/card/id/civilian

/datum/job/civilian/chef
	name = "Chef"
	limit = 1
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/civilian/chef

	New()
		..()
		src.access = get_access("Chef")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_chef")

/datum/job/civilian/bartender
	name = "Bartender"
	alias_names = list("Barman")
	limit = 1
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/civilian/bartender

	New()
		..()
		src.access = get_access("Bartender")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_drinker")

/datum/job/civilian/botanist
	name = "Botanist"
#ifdef MAP_OVERRIDE_DONUT3
	limit = 7
#else
	limit = 5
#endif
	wages = PAY_TRADESMAN
	faction = FACTION_BOTANY
	outfit = /datum/outfit/civilian/botanist

	New()
		..()
		src.access = get_access("Botanist")

/datum/job/civilian/rancher
	name = "Rancher"
	limit = 1
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/civilian/rancher

	New()
		..()
		src.access = get_access("Rancher")

/datum/job/civilian/janitor
	name = "Janitor"
	limit = 3
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/civilian/rancher

	New()
		..()
		src.access = get_access("Janitor")

/datum/job/civilian/chaplain
	name = "Chaplain"
	limit = 1
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/civilian/chaplain

	New()
		..()
		src.access = get_access("Chaplain")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_chaplain")
		OTHER_START_TRACKING_CAT(M, TR_CAT_CHAPLAINS)
		if (prob(15))
			M.see_invisible = INVIS_GHOST

/datum/job/civilian/staff_assistant
	name = "Staff Assistant"
	wages = PAY_UNTRAINED
	no_jobban_from_this_job = TRUE
	low_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	map_can_autooverride = FALSE
	outfit = /datum/outfit/civilian/staff_assistant

	New()
		..()
		src.access = get_access("Staff Assistant")

/datum/job/civilian/clown
	name = "Clown"
	linkcolor = "#FF99FF"
	limit = 1
	wages = PAY_DUMBCLOWN
	change_name_on_spawn = TRUE
	faction = FACTION_CLOWN
	outfit = /datum/outfit/civilian/clown

	New()
		..()
		src.access = get_access("Clown")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_clown")

// AI and Cyborgs

/datum/job/civilian/AI
	name = "AI"
	linkcolor = "#999999"
	limit = 1
	no_late_join = TRUE
	high_priority_job = TRUE
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	slot_card = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.AIize()

/datum/job/civilian/cyborg
	name = "Cyborg"
	linkcolor = "#999999"
	limit = 8
	no_late_join = TRUE
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	slot_card = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		return M.Robotize_MK2()

// Special Cases

/datum/job/special/station_builder
	// Used for Construction game mode, where you build the station
	name = "Station Builder"
	limit = 0
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/station_builder

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_engineer")

	New()
		..()
		src.access = get_access("Construction Worker")

/datum/job/special/hairdresser
	name = "Hairdresser"
	wages = PAY_UNTRAINED
	limit = 0
	outfit = /datum/outfit/barber

	New()
		..()
		src.access = get_access("Barber")

/datum/job/special/mime
	name = "Mime"
	limit = 1
	wages = PAY_DUMBCLOWN * 2 // lol okay whatever
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/mime

	New()
		..()
		src.access = get_access("Mime")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_mime")

/datum/job/special/attorney
	name = "Attorney"
	linkcolor = "#FF0000"
	wages = PAY_DOCTORATE
	limit = 0
	receives_badge = TRUE
	outfit = /datum/outfit/attorney

	New()
		..()
		src.access = get_access("Lawyer")

/datum/job/special/attorney/judge
	name = "Judge"
	limit = 0
	New()
		..()
		src.access = get_all_accesses()

/datum/job/special/vice_officer
	name = "Vice Officer"
	linkcolor = "#FF0000"
	limit = 0
	wages = PAY_TRADESMAN
	allow_traitors = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_con = TRUE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	outfit = /datum/outfit/vice_officer

	New()
		..()
		src.access = get_access("Vice Officer")

/datum/job/special/forensic_technician
	name = "Forensic Technician"
	linkcolor = "#FF0000"
	limit = 0
	wages = PAY_TRADESMAN
	cant_spawn_as_rev = TRUE
	outfit = /datum/outfit/forensic_technician

	New()
		..()
		src.access = get_access("Forensic Technician")

/datum/job/special/toxins_researcher
	name = "Toxins Researcher"
	linkcolor = "#9900FF"
	limit = 0
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/toxins_researcher

	New()
		..()
		src.access = get_access("Toxins Researcher")

/datum/job/special/chemist
	name = "Chemist"
	linkcolor = "#9900FF"
	limit = 0
	wages = PAY_DOCTORATE
	outfit = /datum/outfit/chemist

	New()
		..()
		src.access = get_access("Chemist")

/datum/job/special/research_assistant
	name = "Research Assistant"
	linkcolor = "#9900FF"
	limit = 2
	wages = PAY_UNTRAINED
	low_priority_job = TRUE
	outfit = /datum/outfit/research_assistant

	New()
		..()
		src.access = get_access("Research Assistant")


/datum/job/special/medical_assistant
	name = "Medical Assistant"
	linkcolor = "#9900FF"
	limit = 2
	wages = PAY_UNTRAINED
	low_priority_job = TRUE
	outfit = /datum/outfit/medical_assistant

	New()
		..()
		src.access = get_access("Medical Assistant")

/datum/job/special/atmospheric_technician
	name = "Atmospherish Technician"
	linkcolor = "#FF9900"
	limit = 0
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/atmospheric_technician

	New()
		..()
		src.access = get_access("Atmospheric Technician")

/datum/job/special/tech_assistant
	name = "Technical Assistant"
	linkcolor = "#FF9900"
	limit = 2
	wages = PAY_UNTRAINED
	low_priority_job = TRUE
	outfit = /datum/outfit/tech_assistant

	New()
		..()
		src.access = get_access("Technical Assistant")

/datum/job/special/space_cowboy
	name = "Space Cowboy"
	linkcolor = "#FF99FF"
	limit = 0
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/space_cowboy

	New()
		..()
		src.access = get_access("Space Cowboy")

// randomizd gimmick jobs

/datum/job/special/random
	name = "Hollywood Actor"
	limit = 0
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/actor

	New()
		..()
		if (prob(40))
			limit = 1
		if (src.alt_names.len)
			name = pick(src.alt_names)

/datum/job/special/random/medical_specialist
	name = "Medical Specialist"
	linkcolor = "#9900FF"
	alt_names = list("Neurological Specialist", "Ophthalmic Specialist", "Thoracic Specialist", "Orthopaedic Specialist", "Maxillofacial Specialist",
	  "Vascular Specialist", "Anaesthesiologist", "Acupuncturist", "Medical Director's Assistant")
	wages = PAY_IMPORTANT
	slot_card = /obj/item/card/id/research
	outfit = /datum/outfit/medical_specialist

	New()
		..()
		src.access = get_access("Medical Specialist")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")
		M.traitHolder.addTrait("training_partysurgeon")

/datum/job/special/random/vip
	name = "VIP"
	linkcolor = "#FF0000"
	alt_names = list("Senator", "President", "CEO", "Board Member", "Mayor", "Vice-President", "Governor")
	wages = PAY_EXECUTIVE
	outfit = /datum/outfit/vip

	New()
		..()
		src.access = get_access("VIP")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/secure/sbriefcase/B = M.find_type_in_hand(/obj/item/storage/secure/sbriefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

/datum/job/special/random/inspector
	name = "Inspector"
	wages = PAY_IMPORTANT
	receives_miranda = TRUE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	outfit = /datum/outfit/inspector

	New()
		..()
		src.access = get_access("Inspector")

	proc/inspector_miranda()
		return "You have been found to be in breach of Nanotrasen corporate regulation [rand(1,100)][pick(uppercase_letters)]. You are allowed a grace period of 5 minutes to correct this infringement before you may be subjected to disciplinary action including but not limited to: strongly worded tickets, reduction in pay, and being buried in paperwork for the next [rand(10,20)] standard shifts."

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/instrument/whistle(B))
			var/obj/item/clipboard/with_pen/inspector/clipboard = new /obj/item/clipboard/with_pen/inspector(B)
			B.storage.add_contents(clipboard)
			clipboard.set_owner(M)
		M.mind?.set_miranda(PROC_REF(inspector_miranda))

/datum/job/special/random/director
	name = "Regional Director"
	receives_miranda = TRUE
	cant_spawn_as_rev = TRUE
	wages = PAY_EXECUTIVE
	outfit = /datum/outfit/director

	New()
		..()
		src.access = get_all_accesses()

/datum/job/special/random/diplomat
	name = "Diplomat"
	wages = PAY_DUMBCLOWN
	cant_spawn_as_rev = TRUE
	change_name_on_spawn = TRUE
	alt_names = list("Diplomat", "Ambassador")
	outfit = /datum/outfit/diplomat

	New()
		..()
		src.access = get_access("Diplomat")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)
		M.set_mutantrace(morph)

/datum/job/special/random/testsubject
	name = "Test Subject"
	wages = PAY_DUMBCLOWN
	change_name_on_spawn = TRUE
	starting_mutantrace = /datum/mutantrace/monkey
	outfit = /datum/outfit/testsubject

/datum/job/special/random/union
	name = "Union Rep"
	wages = PAY_TRADESMAN
	alt_names = list("Assistants Union Rep", "Cyborgs Union Rep", "Union Rep", "Security Union Rep", "Doctors Union Rep", "Engineers Union Rep", "Miners Union Rep")
	outfit = /datum/outfit/union

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

/datum/job/special/random/salesman
	name = "Salesman"
	wages = PAY_TRADESMAN
	change_name_on_spawn = TRUE
	alt_names = list("Salesman", "Merchant")
	outfit = /datum/outfit/salesman

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian)
			M.set_mutantrace(morph)

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			for (var/i = 1 to 2)
				B.storage.add_contents(new /obj/item/stamped_bullion(B))

/datum/job/special/random/coach
	name = "Coach"
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/coach

/datum/job/special/random/journalist
	name = "Journalist"
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/journalist

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		var/obj/item/storage/briefcase/B = M.find_type_in_hand(/obj/item/storage/briefcase)
		if (B && istype(B))
			B.storage.add_contents(new /obj/item/device/camera_viewer{network = "Zeta"}(B))
			B.storage.add_contents(new /obj/item/clothing/head/helmet/camera(B))
			B.storage.add_contents(new /obj/item/device/audio_log(B))
			B.storage.add_contents(new /obj/item/clipboard/with_pen(B))

/datum/job/special/random/beekeeper
	name = "Apiculturist"
	wages = PAY_TRADESMAN
	faction = FACTION_BOTANY
	alt_names = list("Apiculturist", "Apiarist")
	outfit = /datum/outfit/beekeeper

	New()
		..()
		src.access = get_access("Apiculturist")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if (prob(15))
			var/obj/critter/domestic_bee/bee = new(get_turf(M))
			bee.beeMom = M
			bee.beeMomCkey = M.ckey
			bee.name = pick_string("bee_names.txt", "beename")
			bee.name = replacetext(bee.name, "larva", "bee")

		M.bioHolder.AddEffect("bee", magical=1) //They're one with the bees!

/datum/job/special/random/angler
	name = "Angler"
	wages = PAY_TRADESMAN
	outfit = /datum/outfit/angler

	New()
		..()
		src.access = get_access("Rancher")

/datum/job/special/random/souschef
	name = "Sous-Chef"
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/souschef

	New()
		..()
		src.access = get_access("Sous-Chef")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_chef")

/datum/job/special/random/waiter
	name = "Waiter"
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/waiter

	New()
		..()
		src.access = get_access("Waiter")

/datum/job/special/random/pharmacist
	name = "Pharmacist"
	wages = PAY_DOCTORATE
	slot_card = /obj/item/card/id/research
	outfit = /datum/outfit/pharmacist

	New()
		..()
		src.access = get_access("Pharmacist")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_medical")

/datum/job/special/random/radioshowhost
	name = "Radio Show Host"
	wages = PAY_TRADESMAN
#ifdef MAP_OVERRIDE_MANTA
	limit = 0
	special_spawn_location = null
#elif defined(MAP_OVERRIDE_OSHAN)
	limit = 1
	special_spawn_location = null
#elif defined(MAP_OVERRIDE_NADIR)
	limit = 1
	special_spawn_location = null
#else
	limit = 1
	special_spawn_location = LANDMARK_RADIO_SHOW_HOST
#endif
	change_name_on_spawn = TRUE
	slot_card = /obj/item/card/id/civilian
	outfit = /datum/outfit/radioshowhost

	New()
		..()
		src.access = get_access("Radio Show Host")

/datum/job/special/random/psychiatrist
	name = "Psychiatrist"
	wages = PAY_DOCTORATE
	alt_names = list("Psychiatrist", "Psychologist", "Psychotherapist", "Therapist", "Counselor", "Life Coach") // All with slightly different connotations
	slot_card = /obj/item/card/id/research
	outfit = /datum/outfit/psychiatrist

	New()
		..()
		src.access = get_access("Psychiatrist")

/datum/job/special/random/artist
	name = "Artist"
	wages = PAY_UNTRAINED
	outfit = /datum/outfit/artist

#ifdef HALLOWEEN
/*
 * Halloween jobs
 */
ABSTRACT_TYPE(/datum/job/special/halloween)
/datum/job/special/halloween
	linkcolor = "#FF7300"

/datum/job/special/halloween/blue_clown
	name = "Blue Clown"
	limit = 1
	wages = PAY_DUMBCLOWN
	change_name_on_spawn = TRUE
	faction = FACTION_CLOWN
	slot_card = /obj/item/card/id/clown
	outfit = /datum/outfit/blue_clown

	New()
		..()
		src.access = get_access("Clown")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("regenerator", magical=1)

/datum/job/special/halloween/candy_salesman
	name = "Candy Salesman"
	wages = PAY_UNTRAINED
	limit = 1

	outfit = /datum/outfit/candy_salesman

	New()
		..()
		src.access = get_access("Salesman")

/datum/job/special/halloween/pumpkin_head
	name = "Pumpkin Head"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE

	outfit = /datum/outfit/pumpkin_head

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("quiet_voice", magical=1)

/datum/job/special/halloween/wanna_bee
	name = "WannaBEE"
	wages = PAY_UNTRAINED
	limit = 1

	outfit = /datum/outfit/wanna_bee

	New()
		..()
		src.access = get_access("Botanist")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("drunk_bee", magical=1)

/datum/job/special/halloween/dracula
	name = "Discount Dracula"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRU
	outfit = /datum/outfit/dracula

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("cloak_of_darkness", magical=1)

/datum/job/special/halloween/werewolf
	name = "Discount Werewolf"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/werewolf

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("jumpy", magical=1)

/datum/job/special/halloween/mummy
	name = "Discount Mummy"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/mummy

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("aura", magical=1)
		M.bioHolder.AddEffect("midas", magical=1)

/datum/job/special/halloween/hotdog
	name = "Hot Dog"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/hotdog

	New()
		..()
		src.access = get_access("Staff Assistant")

/datum/job/special/halloween/godzilla
	name = "Discount Godzilla"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/godzilla

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("lizard", magical=1)
		M.bioHolder.AddEffect("loud_voice", magical=1)

/datum/job/special/halloween/macho
	name = "Discount Macho Man"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/discount_macho

	New()
		..()
		src.access = get_access("Staff Assistant")


	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("accent_chav", magical=1)

/datum/job/special/halloween/ghost
	name = "Ghost"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/ghost

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("chameleon", magical=1)

/datum/job/special/halloween/ghost_buster
	name = "Ghost Buster"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	change_name_on_spawn = TRUE
	alt_names = list("Paranormal Activities Investigator", "Spooks Specialist")

	outfit = /datum/outfit/ghost_buster

	New()
		..()
		src.access = get_access("Staff Assistant")

/datum/job/special/halloween/angel
	name = "Angel"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE

	outfit = /datum/outfit/angel

	New()
		..()
		src.access = get_access("Chaplain")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("shiny", magical=1)
		M.bioHolder.AddEffect("healing_touch", magical=1)

/datum/job/special/halloween/vendor
	name = "Costume Vendor"
	wages = PAY_TRADESMAN
	limit = 1
	change_name_on_spawn = 1
	outfit = /datum/outfit/vendor

/datum/job/special/halloween/devil
	name = "Devil"
	wages = PAY_UNTRAINED
	limit = 0
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/devil

	New()
		..()
		src.access = get_access("Chaplain")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("hell_fire", magical=1)

/datum/job/special/halloween/superhero
	name = "Discount Vigilante Superhero"
	wages = PAY_UNTRAINED
	limit = 1
	change_name_on_spawn = TRUE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	receives_miranda = TRUE
	outfit = /datum/outfit/superhero

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		if(prob(60))
			var/aggressive = pick("eyebeams","cryokinesis")
			var/defensive = pick("fire_resist","cold_resist","rad_resist","breathless") // no thermal resist, gotta have some sort of comic book weakness
			var/datum/bioEffect/power/be = M.bioHolder.AddEffect(aggressive, do_stability=0)
			if(aggressive == "eyebeams")
				var/datum/bioEffect/power/eyebeams/eb = be
				eb.stun_mode = 1
				eb.altered = 1
			else
				be.power = 1
				be.altered = 1
			be = M.bioHolder.AddEffect(defensive, do_stability=0)
		else
			var/datum/bioEffect/power/shoot_limb/sl = M.bioHolder.AddEffect("shoot_limb", do_stability=0)
			sl.safety = 1
			sl.altered = 1
			sl.cooldown = 300
			sl.stun_mode = 1
			var/datum/bioEffect/regenerator/r = M.bioHolder.AddEffect("regenerator", do_stability=0)
			r.regrow_prob = 10
		var/datum/bioEffect/power/be = M.bioHolder.AddEffect("adrenaline", do_stability=0)
		be.safety = 1
		be.altered = 1
		M?.mind?.miranda = "Evildoer! You have been apprehended by a hero of space justice!"

/datum/job/special/halloween/pickle
	name = "Pickle"
	wages = PAY_DUMBCLOWN
	limit = 1
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/pickle

	New()
		..()
		src.access = get_access("Staff Assistant")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/obj/item/trinket = M.trinket.deref()
		trinket.setMaterial(getMaterial("pickle"))
		for (var/i in 1 to 3)
			var/type = pick(trinket_safelist)
			var/obj/item/pickle = new type(M.loc)
			pickle.setMaterial(getMaterial("pickle"))
			M.equip_if_possible(pickle, SLOT_IN_BACKPACK)
		M.bioHolder.AddEffect("pickle", magical=1)

ABSTRACT_TYPE(/datum/job/special/halloween/critter)
/datum/job/special/halloween/critter
	wages = PAY_DUMBCLOWN
	mentor_only = TRUE
	allow_traitors = FALSE
	slot_card = null

/datum/job/special/halloween/critter/plush
	name = "Plush Toy"
	mentor_only = FALSE
	limit = 2

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.critterize(/mob/living/critter/small_animal/plush/cryptid)

/datum/job/special/halloween/critter/remy
	name = "Remy"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/mouse/remy)
		C.flags = null

/datum/job/special/halloween/critter/bumblespider
	name = "Bumblespider"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/spider/nice)
		C.flags = null

/datum/job/special/halloween/critter/crow
	name = "Crow"
	limit = 1

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/mob/living/critter/C = M.critterize(/mob/living/critter/small_animal/bird/crow)
		C.flags = null

// end halloween jobs
#endif

/*
/datum/job/special/turkey
	name = "Turkey"
	linkcolor = "#FF7300"
	wages = PAY_DUMBCLOWN
	requires_whitelist = 1
	limit = 1
	allow_traitors = 0
	slot_ears = list()
	slot_card = null
	slot_back = list()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/type = pick(/mob/living/critter/small_animal/bird/turkey/gobbler, /mob/living/critter/small_animal/bird/turkey/hen)
		M.critterize(type)
*/

/datum/job/special/syndicate_operative
	name = "Syndicate Operative"
	wages = 0
	limit = 0
	linkcolor = "#880000"
	slot_card = null
	spawn_id = FALSE
	radio_announcement = FALSE
	special_spawn_location = LANDMARK_SYNDICATE
	add_to_manifest = FALSE
	faction = FACTION_SYNDICATE
	var/leader = FALSE
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M?.mind)
			return

		if (src.leader)
			M.mind.add_antagonist(ROLE_NUKEOP_COMMANDER, do_objectives = FALSE, source = ANTAGONIST_SOURCE_ADMIN)
		else
			M.mind.add_antagonist(ROLE_NUKEOP, do_objectives = FALSE, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/syndicate_operative/leader
	name = "Syndicate Operative Commander"
	special_spawn_location = LANDMARK_SYNDICATE_BOSS
	leader = TRUE

/datum/job/special/syndicate_weak
	linkcolor = "#880000"
	name = "Junior Syndicate Operative"
	limit = 0
	wages = 0
	radio_announcement = FALSE
	add_to_manifest = FALSE
	faction = FACTION_SYNDICATE
	slot_card = null		///obj/item/card/id
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		M.mind?.add_generic_antagonist(ROLE_SYNDICATE_AGENT, "Junior Syndicate Operative", source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/syndicate_weak/no_ammo
	name = "Poorly Equipped Junior Syndicate Operative"
	faction = FACTION_SYNDICATE

// hidden jobs for nt-so vs syndicate spec-ops

/datum/job/special/syndicate_specialist
	linkcolor = "#880000"
	name = "Syndicate Special Operative"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	radio_announcement = FALSE
	add_to_manifest = FALSE
	special_spawn_location = LANDMARK_SYNDICATE
	faction = FACTION_SYNDICATE
	receives_implant = /obj/item/implant/revenge/microbomb
	slot_card = /obj/item/card/id
	outfit = /datum/outfit/syndicate_specialist

	New()
		..()
		src.access = syndicate_spec_ops_access()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_generic_antagonist(ROLE_SYNDICATE_AGENT, "Syndicate Special Operative", source = ANTAGONIST_SOURCE_ADMIN)
		M.show_text("<b>The assault has begun! Head over to the station and kill any and all Nanotrasen personnel you encounter!</b>", "red")

/datum/job/special/pirate
	linkcolor = "#880000"
	name = "Space Pirate"
	limit = 0
	wages = 0
	add_to_manifest = FALSE
	radio_announcement = FALSE
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	slot_card = /obj/item/card/id
	outfit = null
	var/rank = ROLE_PIRATE

	New()
		..()
		src.access = list(access_maint_tunnels, access_pirate )

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		for (var/datum/antagonist/antag in M.mind.antagonists)
			if (antag.id == ROLE_PIRATE || antag.id == ROLE_PIRATE_FIRST_MATE || antag.id == ROLE_PIRATE_CAPTAIN)
				antag.give_equipment()
				return
		M.mind.add_antagonist(rank, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/pirate/first_mate
	name = "Space Pirate First Mate"
	rank = ROLE_PIRATE_FIRST_MATE

/datum/job/special/pirate/captain
	name = "Space Pirate Captain"
	rank = ROLE_PIRATE_CAPTAIN

/datum/job/special/juicer_specialist
	linkcolor = "#cc8899"
	name = "Juicer Security"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	add_to_manifest = FALSE
	outfit = /datum/outfit/juicer_specialist

/datum/job/special/ntso_specialist
	linkcolor = "#3348ff"
	name = "Nanotrasen Special Operative"
	limit = 0
	wages = PAY_IMPORTANT
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	faction = FACTION_NANOTRASEN
	receives_implant = /obj/item/implant/health
	outfit = /datum/outfit/ntso_specialist

	New()
		..()
		src.access = get_all_accesses()

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")
		// M.show_text("<b>Hostile assault force incoming! Defend the crew from the attacking Syndicate Special Operatives!</b>", "blue")

/datum/job/special/nt_engineer
	linkcolor = "#3348ff"
	name = "Nanotrasen Emergency Repair Technician"
	limit = 0
	wages = PAY_IMPORTANT
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	faction = FACTION_NANOTRASEN
	outfit = /datum/outfit/nt_engineer

	New()
		..()
		src.access = get_all_accesses()

	special_setup(var/mob/living/carbon/human/M)
		..()
		M?.traitHolder.addTrait("training_engineer")
		SPAWN(1)
			var/obj/item/rcd/rcd = locate() in M.belt.storage.stored_items
			rcd.matter = 100
			rcd.max_matter = 100
			rcd.tooltip_rebuild = TRUE
			rcd.UpdateIcon()

/datum/job/special/nt_medical
	linkcolor = "#3348ff"
	name = "Nanotrasen Emergency Medic"
	limit = 0
	wages = PAY_IMPORTANT
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	cant_spawn_as_rev = TRUE
	faction = FACTION_NANOTRASEN
	outfit = /datum/outfit/nt_medical

	New()
		..()
		src.access = get_all_accesses()

	special_setup(var/mob/living/carbon/human/M)
		..()
		M?.traitHolder.addTrait("training_medical")

// Use this one for late respawns to deal with existing antags. they are weaker cause they dont get a laser rifle or frags
/datum/job/special/nt_security
	linkcolor = "#3348ff"
	name = "Nanotrasen Security Consultant"
	limit = 1 // backup during HELL WEEK. players will probably like it
	wages = PAY_TRADESMAN
	requires_whitelist = TRUE
	requires_supervisor_job = "Head of Security"
	allow_traitors = FALSE
	allow_spy_theft = FALSE
	can_join_gangs = FALSE
	cant_spawn_as_rev = TRUE
	receives_badge = TRUE
	receives_miranda = TRUE
	faction = FACTION_NANOTRASEN
	receives_implant = /obj/item/implant/health/security/anti_mindhack
	outfit = /datum/outfit/nt_security

	New()
		..()
		src.access = get_access("Security Officer") + list(access_heads)

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.traitHolder.addTrait("training_security")

/datum/job/special/headminer
	name = "Head of Mining"
	limit = 0
	wages = PAY_IMPORTANT
	linkcolor = "#00CC00"
	cant_spawn_as_rev = TRUE
	slot_card = /obj/item/card/id/command

	outfit = /datum/outfit/headminer

	New()
		..()
		src.access = get_access("Head of Mining")

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.bioHolder.AddEffect("training_miner")

/datum/job/special/machoman
	name = "Macho Man"
	linkcolor = "#9E0E4D"
	limit = 0
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_MACHO_MAN, source = ANTAGONIST_SOURCE_ADMIN)

/datum/job/special/meatcube
	name = "Meatcube"
	linkcolor = "#FF0000"
	limit = 0
	allow_traitors = FALSE
	add_to_manifest = FALSE
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.cubeize(INFINITY)

/datum/job/special/ghostdrone
	name = "Drone"
	linkcolor = "#999999"
	limit = 0
	wages = 0
	allow_traitors = FALSE
	slot_card = null
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		droneize(M, 0)

/datum/job/daily //Special daily jobs

/datum/job/daily/sunday
	name = "Boxer"
	wages = PAY_UNTRAINED
	limit = 4
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/boxer

	New()
		..()
		src.access = get_access("Boxer")

/datum/job/daily/monday
	name = "Dungeoneer"
	limit = 1
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/dungeoneer

	New()
		..()
		src.access = get_access("Dungeoneer")

/datum/job/daily/tuesday
	name = "Barber"
	wages = PAY_UNTRAINED
	limit = 1
	outfit = /datum/outfit/barber

	New()
		..()
		src.access = get_access("Barber")

/datum/job/daily/wednesday
	name = "Mailman"
	wages = PAY_TRADESMAN
	limit = 2
	alt_names = list("Head of Deliverying", "Head of Mailmanning")
	outfit = /datum/outfit/mailman

	New()
		..()
		src.access = get_access("Mailman")

/datum/job/daily/thursday
	name = "Lawyer"
	linkcolor = "#FF0000"
	wages = PAY_DOCTORATE
	limit = 4
	receives_badge = 1
	outfit = /datum/outfit/attorney

	New()
		..()
		src.access = get_access("Lawyer")

/datum/job/daily/friday
	name = "Tourist"
	linkcolor = "#FF99FF"
	limit = 100
	wages = 0
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/tourist

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		if(prob(33))
			var/morph = pick(/datum/mutantrace/lizard,/datum/mutantrace/skeleton,/datum/mutantrace/ithillid,/datum/mutantrace/martian,/datum/mutantrace/amphibian,/datum/mutantrace/blob,/datum/mutantrace/cow)
			M.set_mutantrace(morph)
		var/obj/item/clothing/lanyard/L = new /obj/item/clothing/lanyard(M.loc)
		M.equip_if_possible(L, SLOT_WEAR_ID, FALSE)
		var/obj/item/card/id = locate() in M
		if (id)
			L.storage.add_contents(id, M, FALSE)

/datum/job/daily/saturday
	name = "Musician"
	limit = 3
	wages = PAY_UNTRAINED
	change_name_on_spawn = TRUE
	outfit = /datum/outfit/musician

/datum/job/battler
	name = "Battler"
	limit = -1

/datum/job/slasher
	name = "The Slasher"
	linkcolor = "#02020d"
	limit = 0
	slot_card = null
	outfit = null

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		M.mind?.add_antagonist(ROLE_SLASHER, source = ANTAGONIST_SOURCE_ADMIN)

ABSTRACT_TYPE(/datum/job/special/pod_wars)
/datum/job/special/pod_wars
	name = "Pod_Wars"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = -1
#else
	limit = 0
#endif
	allow_traitors = FALSE
	cant_spawn_as_rev = TRUE
	var/team = 0 //1 = NT, 2 = SY
	var/overlay_icon

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return

		if (!M.abilityHolder)
			M.abilityHolder = new /datum/abilityHolder/pod_pilot(src)
			M.abilityHolder.owner = src
		else if (istype(M.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/AH = M.abilityHolder
			AH.addHolder(/datum/abilityHolder/pod_pilot)

		//stuff for headsets
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			mode.setup_team_overlay(M.mind, overlay_icon)
			if (team == 1)
				M.mind.special_role = mode.team_NT?.name
				setup_headset(M.ears, mode.team_NT?.comms_frequency)
			else if (team == 2)
				M.mind.special_role = mode.team_SY?.name
				setup_headset(M.ears, mode.team_SY?.comms_frequency)

	proc/setup_headset(var/obj/item/device/radio/headset/headset, var/freq)
		if (istype(headset))
			headset.set_secure_frequency("g",freq)
			headset.secure_classes["g"] = RADIOCL_SYNDICATE
			headset.cant_self_remove = FALSE
			headset.cant_other_remove = FALSE

/datum/job/special/pod_wars/nanotrasen
	name = "NanoTrasen Pod Pilot"
	linkcolor = "#3348ff"
	no_jobban_from_this_job = TRUE
	low_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	access = list(access_heads, access_medical, access_medical_lockers)
	team = 1
	overlay_icon = "nanotrasen"
	faction = FACTION_NANOTRASEN
	receives_implant = /obj/item/implant/pod_wars/nanotrasen
	outfit = /datum/outfit/pod_wars/nanotrasen

/datum/job/special/pod_wars/nanotrasen/commander
	name = "NanoTrasen Commander"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = 1
#else
	limit = 0
#endif
	no_jobban_from_this_job = FALSE
	high_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	overlay_icon = "nanocomm"
	access = list(access_heads, access_captain, access_medical, access_medical_lockers, access_engineering_power)
	slot_card = /obj/item/card/id/pod_wars/nanotrasen/commander
	outfit = /datum/outfit/pod_wars/nanotrasen/commander

/datum/job/special/pod_wars/syndicate
	name = "Syndicate Pod Pilot"
	linkcolor = "#FF0000"
	no_jobban_from_this_job = TRUE
	low_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	access = list(access_syndicate_shuttle, access_medical, access_medical_lockers)
	team = 2
	overlay_icon = "syndicate"
	add_to_manifest = FALSE
	faction = FACTION_SYNDICATE
	receives_implant = /obj/item/implant/pod_wars/syndicate
	outfit = /datum/outfit/pod_wars/syndicate

/datum/job/special/pod_wars/syndicate/commander
	name = "Syndicate Commander"
#ifdef MAP_OVERRIDE_POD_WARS
	limit = 1
#else
	limit = 0
#endif
	no_jobban_from_this_job = FALSE
	high_priority_job = TRUE
	cant_allocate_unwanted = TRUE
	overlay_icon = "syndcomm"
	access = list(access_syndicate_shuttle, access_syndicate_commander, access_medical, access_medical_lockers, access_engineering_power)
	outfit = /datum/outfit/pod_wars/syndicate/commander

/datum/job/football
	name = "Football Player"
	limit = -1

/*---------------------------------------------------------------*/

/// job for being overwritten by job creator
/datum/job/created
	name = "Special Job"
	outfit = /datum/outfit/created

