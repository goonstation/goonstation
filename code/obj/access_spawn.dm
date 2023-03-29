/obj/access_spawn
	name = "access spawn"
	desc = "Sets access of machines on the same turf as it to its access, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"

	/*
	 * loop through valid objects in the same location and, if they have no access set, set it to this one
	 */

	New()
		..()
		if (current_state > GAME_STATE_WORLD_INIT)
			SPAWN(5 DECI SECONDS)
				src.setup()
				qdel(src)

	initialize()
		..()
		src.setup()
		qdel(src)

	proc/setup()
		for (var/obj/machinery/M in src.loc)
			if (!M.req_access)
				M.req_access = src.req_access
			else
				M.req_access += src.req_access
			//todo : autoname doors	here too. var editing is illegal!

#define SPECIAL "#ffa135"
#define MEDICAL "#3daff7"
#define SECURITY "#f73d3d"
#define MORGUE_BLACK "#002135"
#define TOXINS "#a3f73d"
#define RESEARCH "#b23df7"
#define ENGINEERING "#f7af3d"
#define CARGO "#f7e43d"
#define MAINTENANCE "#e5ff32"
#define COMMAND "#00783c"

/obj/access_spawn/admin_override //special admin override access spawner
	name = "admin override access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.admin_access_override = TRUE

/obj/access_spawn/public
	name = "public access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.req_access = null

/obj/access_spawn/security
	name = "security access spawn"
	req_access = list(access_security)
	color = SECURITY

/obj/access_spawn/forensics
	name = "forensics access spawn"
	req_access = list(access_forensics_lockers)
	color = SECURITY

/obj/access_spawn/brig
	name = "brig access spawn"
	req_access = list(access_brig)
	color = SECURITY

/obj/access_spawn/medical
	name = "medical access spawn"
	req_access = list(access_medical)
	color = MEDICAL

/obj/access_spawn/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)
	color = MORGUE_BLACK

/obj/access_spawn/tox
	name = "tox access spawn"
	req_access = list(access_tox)
	color = TOXINS

/obj/access_spawn/tox_storage
	name = "tox access spawn"
	req_access = list(access_tox_storage)
	color = TOXINS

/obj/access_spawn/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)
	color = MEDICAL

/obj/access_spawn/pathology
	name = "pathology spawn"
	#ifdef CREATE_PATHOGENS
	req_access = list(access_pathology)
	#elif defined(SCIENCE_PATHO_MAP)
	req_access = list(access_research)
	#else
	req_access = list(access_medical)
	#endif
	#ifdef SCIENCE_PATHO_MAP
	color = RESEARCH
	#else
	color = MEDICAL
	#endif

/obj/access_spawn/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)
	color = RESEARCH

/obj/access_spawn/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)
	color = MAINTENANCE

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/access_spawn/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/access_spawn/centcom
	name = "centcom access spawn"
	req_access = list(access_centcom)
	color = COMMAND

/obj/access_spawn/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)
	color = COMMAND

/obj/access_spawn/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)
	color = COMMAND

/obj/access_spawn/eva
	name = "eva access spawn"
	req_access = list(access_eva)
	color = COMMAND

/obj/access_spawn/heads
	name = "heads access spawn"
	req_access = list(access_heads)
	color = COMMAND

/obj/access_spawn/captain
	name = "captain access spawn"
	req_access = list(access_captain)
	color = COMMAND

/obj/access_spawn/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)
	color = MEDICAL

/obj/access_spawn/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)
	color = COMMAND

/obj/access_spawn/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)
	color = MAINTENANCE

/obj/access_spawn/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)
	color = MAINTENANCE

/obj/access_spawn/research
	name = "research access spawn"
	req_access = list(access_research)
	color = RESEARCH

/obj/access_spawn/bar
	name = "bar access spawn"
	req_access = list(access_bar)
	color = MAINTENANCE

/obj/access_spawn/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)
	color = MAINTENANCE

/obj/access_spawn/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)
	color = MAINTENANCE

/obj/access_spawn/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)
	color = MAINTENANCE

/obj/access_spawn/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)
	color = MEDICAL

/obj/access_spawn/hangar
	name = "hangar access spawn"
	req_access = list(access_hangar)
	color = CARGO

/obj/access_spawn/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)
	color = CARGO

/obj/access_spawn/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)
	color = RESEARCH

/obj/access_spawn/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)
	color = MAINTENANCE

/obj/access_spawn/rancher
	name = "ranch access spawn"
	req_access = list(access_ranch)
	color = MAINTENANCE

/obj/access_spawn/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)
	color = SECURITY

/obj/access_spawn/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)
	color = SECURITY

/obj/access_spawn/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)
	color = SECURITY

/obj/access_spawn/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)
	color = ENGINEERING

/obj/access_spawn/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)
	color = ENGINEERING

/obj/access_spawn/engineering_eva
	name = "engineering EVA access spawn"
	req_access = list(access_engineering_eva)
	color = ENGINEERING

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/access_spawn/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)
	color = ENGINEERING

/obj/access_spawn/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/access_spawn/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)
	color = ENGINEERING

/obj/access_spawn/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)
	color = ENGINEERING

/obj/access_spawn/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)
	color = ENGINEERING

/obj/access_spawn/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)
	color = ENGINEERING

/obj/access_spawn/mining_shuttle
	name = "mining_shuttle access spawn"
	req_access = list(access_mining_shuttle)
	color = CARGO

/obj/access_spawn/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)
	color = CARGO

/obj/access_spawn/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)
	color = CARGO

/obj/access_spawn/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)
	color = SECURITY

/obj/access_spawn/pirate_ship
	name = "pirate ship access spawn"
	req_access = list(access_pirate)
	color = SECURITY

/obj/access_spawn/research_foyer
	name = "research foyer access spawn"
	req_access = list(access_researchfoyer)
	color = RESEARCH

/obj/access_spawn/artlab
	name = "artlab access spawn"
	req_access = list(access_artlab)
	color = RESEARCH

/obj/access_spawn/telesci
	name = "telesci access spawn"
	req_access = list(access_telesci)
	color = RESEARCH

/obj/access_spawn/robotdepot
	name = "robot depot access spawn"
	req_access = list(access_robotdepot)
	color = RESEARCH

//////////////////////owlzone access///////
/obj/access_spawn/owlmaint
	name = "owlery maint access spawn"
	req_access = list(access_owlerymaint)
	color = ENGINEERING

/obj/access_spawn/owlcommand
	name = "owlery command access spawn"
	req_access = list(access_owlerysec)
	color = COMMAND

/obj/access_spawn/owlsecurity
	name = "owlery sec access spawn"
	req_access = list(access_owlerycommand)
	color = SECURITY

/obj/access_spawn/polariscargo
	name = "polaris cargo access spawn"
	req_access = list(access_polariscargo)
	color = CARGO

/obj/access_spawn/polarisimportant
	name = "polaris important access spawn"
	req_access = list(access_polarisimportant)
	color = CARGO

#undef MEDICAL
#undef SECURITY
#undef MORGUE_BLACK
#undef TOXINS
#undef RESEARCH
#undef ENGINEERING
#undef CARGO
#undef MAINTENANCE
#undef COMMAND
