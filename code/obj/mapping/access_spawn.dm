/obj/effects/map_helper/access
	name = "access spawn"
	desc = "Sets access of machines on the same turf as it to its access, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"

	setup()
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

//////////// Security ////
/obj/effects/map_helper/access/security
	name = "security access spawn"
	req_access = list(access_security)
	color = SECURITY

/obj/effects/map_helper/access/brig
	name = "brig access spawn"
	req_access = list(access_brig)
	color = SECURITY

/obj/effects/map_helper/access/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)
	color = SECURITY

/obj/effects/map_helper/access/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)
	color = SECURITY

/obj/effects/map_helper/access/forensics
	name = "forensics access spawn"
	req_access = list(access_forensics_lockers)
	color = SECURITY

//////////// Medical ////
/obj/effects/map_helper/access/pathology // top of the list because of the whole "science or med" thing w/e
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

/obj/effects/map_helper/access/medical
	name = "medical access spawn"
	req_access = list(access_medical)
	color = MEDICAL

/obj/effects/map_helper/access/medlocker
	name = "medical locker access spawn"
	req_access = list(access_medical_lockers)
	color = MEDICAL

/obj/effects/map_helper/access/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)
	color = MORGUE_BLACK

/obj/effects/map_helper/access/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)
	color = MEDICAL

/obj/effects/map_helper/access/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)
	color = MEDICAL

//////////// Engineering ////
/obj/effects/map_helper/access/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)
	color = CARGO

/obj/effects/map_helper/access/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_eva
	name = "engineering EVA access spawn"
	req_access = list(access_engineering_eva)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)
	color = ENGINEERING

/obj/effects/map_helper/access/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)
	color = ENGINEERING

/obj/effects/map_helper/access/mining_shuttle
	name = "mining_shuttle access spawn"
	req_access = list(access_mining_shuttle)
	color = CARGO

/obj/effects/map_helper/access/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)
	color = CARGO

/obj/effects/map_helper/access/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)
	color = CARGO

//////////// Research ////
/obj/effects/map_helper/access/tox
	name = "tox access spawn"
	req_access = list(access_tox)
	color = TOXINS

/obj/effects/map_helper/access/tox_storage
	name = "tox access spawn"
	req_access = list(access_tox_storage)
	color = TOXINS

/obj/effects/map_helper/access/research
	name = "research access spawn"
	req_access = list(access_research)
	color = RESEARCH

/obj/effects/map_helper/access/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)
	color = RESEARCH

/obj/effects/map_helper/access/research_foyer
	name = "research foyer access spawn"
	req_access = list(access_researchfoyer)
	color = RESEARCH

/obj/effects/map_helper/access/artlab
	name = "artlab access spawn"
	req_access = list(access_artlab)
	color = RESEARCH

/obj/effects/map_helper/access/telesci
	name = "telesci access spawn"
	req_access = list(access_telesci)
	color = RESEARCH

/obj/effects/map_helper/access/robotdepot
	name = "robot depot access spawn"
	req_access = list(access_robotdepot)
	color = RESEARCH

//////////// Civilian ////
/obj/effects/map_helper/access/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)
	color = MAINTENANCE

/obj/effects/map_helper/access/emergency_storage
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/effects/map_helper/access/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)
	color = MAINTENANCE

/obj/effects/map_helper/access/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)
	color = MAINTENANCE

/obj/effects/map_helper/access/bar
	name = "bar access spawn"
	req_access = list(access_bar)
	color = MAINTENANCE

/obj/effects/map_helper/access/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)
	color = MAINTENANCE

/obj/effects/map_helper/access/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)
	color = MAINTENANCE

/obj/effects/map_helper/access/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)
	color = MAINTENANCE

/obj/effects/map_helper/access/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)
	color = MAINTENANCE

/obj/effects/map_helper/access/rancher
	name = "ranch access spawn"
	req_access = list(access_ranch)
	color = MAINTENANCE

//////////// Command/Heads ////
/obj/effects/map_helper/access/emergency_storage // technically unused, sorta, mostly, kinda
	name = "emergency storage access spawn"
	req_access = list(access_emergency_storage)
	color = MAINTENANCE

/obj/effects/map_helper/access/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)
	color = COMMAND

/obj/effects/map_helper/access/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)
	color = COMMAND

/obj/effects/map_helper/access/eva
	name = "eva access spawn"
	req_access = list(access_eva)
	color = COMMAND

/obj/effects/map_helper/access/heads
	name = "heads access spawn"
	req_access = list(access_heads)
	color = COMMAND

/obj/effects/map_helper/access/captain
	name = "captain access spawn"
	req_access = list(access_captain)
	color = COMMAND

/obj/effects/map_helper/access/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)
	color = COMMAND

/obj/effects/map_helper/access/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)
	color = RESEARCH

/obj/effects/map_helper/access/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)
	color = MEDICAL

/obj/effects/map_helper/access/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)
	color = SECURITY

/obj/effects/map_helper/access/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)
	color = ENGINEERING

//////////// Other ////
/obj/effects/map_helper/access/centcom
	name = "centcom access spawn"
	req_access = list(access_centcom)
	color = COMMAND

/obj/effects/map_helper/access/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)
	color = SECURITY

/obj/effects/map_helper/access/pirate_ship
	name = "pirate ship access spawn"
	req_access = list(access_pirate)
	color = SECURITY

/obj/effects/map_helper/access/admin_override //special admin override access spawner
	name = "admin override access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.admin_access_override = TRUE

/obj/effects/map_helper/access/public
	name = "public access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.req_access = null

//////////// unsorted/unused ////
/obj/effects/map_helper/access/hangar
	name = "hangar access spawn"
	req_access = list(access_hangar)
	color = CARGO

//////////////////////owlzone access///////
/obj/effects/map_helper/access/owlmaint
	name = "owlery maint access spawn"
	req_access = list(access_owlerymaint)
	color = ENGINEERING

/obj/effects/map_helper/access/owlcommand
	name = "owlery command access spawn"
	req_access = list(access_owlerysec)
	color = COMMAND

/obj/effects/map_helper/access/owlsecurity
	name = "owlery sec access spawn"
	req_access = list(access_owlerycommand)
	color = SECURITY

/obj/effects/map_helper/access/polariscargo
	name = "polaris cargo access spawn"
	req_access = list(access_polariscargo)
	color = CARGO

/obj/effects/map_helper/access/polarisimportant
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
