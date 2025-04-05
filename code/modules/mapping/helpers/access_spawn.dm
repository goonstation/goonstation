/obj/mapping_helper/access
	name = "access spawn"
	desc = "Adds its own access to any of the following objects on it's tile: /machinery, /storage/secure. Then destroys itself"
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"

	setup()
		for (var/obj/machinery/machine in src.loc) //Airlocks, Turret controls, Computers, etc.
			src.setup_access(machine)
		for (var/obj/storage/secure/storage in src.loc) //Lockers, crates, etc.
			src.setup_access(storage)

	proc/setup_access(var/obj/O)
		if (!O.req_access)
			O.req_access = src.req_access
		else
			O.req_access += src.req_access

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
/obj/mapping_helper/access/security
	name = "security access spawn"
	req_access = list(access_security)
	color = SECURITY

/obj/mapping_helper/access/brig
	name = "brig access spawn"
	req_access = list(access_brig)
	color = SECURITY

/obj/mapping_helper/access/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)
	color = SECURITY

/obj/mapping_helper/access/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)
	color = SECURITY

/obj/mapping_helper/access/forensics
	name = "forensics access spawn"
	req_access = list(access_forensics_lockers)
	color = SECURITY

//////////// Medical ////
/obj/mapping_helper/access/medical
	name = "medical access spawn"
	req_access = list(access_medical)
	color = MEDICAL

/obj/mapping_helper/access/medlocker
	name = "medical locker access spawn"
	req_access = list(access_medical_lockers)
	color = MEDICAL

/obj/mapping_helper/access/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)
	color = MORGUE_BLACK

/obj/mapping_helper/access/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)
	color = MEDICAL

/obj/mapping_helper/access/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)
	color = MEDICAL

/obj/mapping_helper/access/pathology
	name = "pathology spawn"
	req_access = list(access_medical)
	color = MEDICAL

//////////// Engineering ////
/obj/mapping_helper/access/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)
	color = CARGO

/obj/mapping_helper/access/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_eva
	name = "engineering EVA access spawn"
	req_access = list(access_engineering_eva)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)
	color = ENGINEERING

/obj/mapping_helper/access/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)
	color = ENGINEERING

/obj/mapping_helper/access/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)
	color = CARGO

/obj/mapping_helper/access/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)
	color = CARGO

//////////// Research ////
/obj/mapping_helper/access/tox
	name = "toxins access spawn"
	req_access = list(access_tox)
	color = TOXINS

/obj/mapping_helper/access/tox_storage
	name = "toxins storage access spawn"
	req_access = list(access_tox_storage)
	color = TOXINS

/obj/mapping_helper/access/research
	name = "research access spawn"
	req_access = list(access_research)
	color = RESEARCH

/obj/mapping_helper/access/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)
	color = RESEARCH

/obj/mapping_helper/access/research_foyer
	name = "research foyer access spawn"
	req_access = list(access_researchfoyer)
	color = RESEARCH

/obj/mapping_helper/access/artlab
	name = "artlab access spawn"
	req_access = list(access_artlab)
	color = RESEARCH

/obj/mapping_helper/access/telesci
	name = "telesci access spawn"
	req_access = list(access_telesci)
	color = RESEARCH

/obj/mapping_helper/access/robotdepot
	name = "robot depot access spawn"
	req_access = list(access_robotdepot)
	color = RESEARCH

//////////// Civilian ////
/obj/mapping_helper/access/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)
	color = MAINTENANCE

/obj/mapping_helper/access/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)
	color = MAINTENANCE

/obj/mapping_helper/access/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)
	color = MAINTENANCE

/obj/mapping_helper/access/bar
	name = "bar access spawn"
	req_access = list(access_bar)
	color = MAINTENANCE

/obj/mapping_helper/access/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)
	color = MAINTENANCE

/obj/mapping_helper/access/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)
	color = MAINTENANCE

/obj/mapping_helper/access/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)
	color = MAINTENANCE

/obj/mapping_helper/access/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)
	color = MAINTENANCE

/obj/mapping_helper/access/rancher
	name = "ranch access spawn"
	req_access = list(access_ranch)
	color = MAINTENANCE

//////////// Command/Heads ////
/obj/mapping_helper/access/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)
	color = COMMAND

/obj/mapping_helper/access/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)
	color = COMMAND

/obj/mapping_helper/access/eva
	name = "eva access spawn"
	req_access = list(access_eva)
	color = COMMAND

/obj/mapping_helper/access/heads
	name = "heads access spawn"
	req_access = list(access_heads)
	color = COMMAND

/obj/mapping_helper/access/captain
	name = "captain access spawn"
	req_access = list(access_captain)
	color = COMMAND

/obj/mapping_helper/access/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)
	color = COMMAND

/obj/mapping_helper/access/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)
	color = RESEARCH

/obj/mapping_helper/access/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)
	color = MEDICAL

/obj/mapping_helper/access/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)
	color = SECURITY

/obj/mapping_helper/access/armory
	name = "Armory access spawn"
	req_access = list(access_armory)
	color = SECURITY

/obj/mapping_helper/access/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)
	color = ENGINEERING

//////////// Other ////
/obj/mapping_helper/access/centcom
	name = "centcom access spawn"
	req_access = list(access_centcom)
	color = COMMAND

/obj/mapping_helper/access/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)
	color = SECURITY

/obj/mapping_helper/access/syndie_commander
	name = "syndie commander access spawn"
	req_access = list(access_syndicate_commander)
	color = SECURITY

/obj/mapping_helper/access/pirate_ship
	name = "pirate ship access spawn"
	req_access = list(access_pirate)
	color = SECURITY

/obj/mapping_helper/access/admin_override //special admin override access spawner
	name = "admin override access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.admin_access_override = TRUE

/obj/mapping_helper/access/public
	name = "public access spawn"
	color = SPECIAL

	setup()
		for (var/obj/O in src.loc)
			O.req_access = null

//////////////////////owlzone access///////
/obj/mapping_helper/access/owlmaint
	name = "owlery maint access spawn"
	req_access = list(access_owlerymaint)
	color = ENGINEERING

/obj/mapping_helper/access/owlcommand
	name = "owlery command access spawn"
	req_access = list(access_owlerysec)
	color = COMMAND

/obj/mapping_helper/access/owlsecurity
	name = "owlery sec access spawn"
	req_access = list(access_owlerycommand)
	color = SECURITY

/obj/mapping_helper/access/polariscargo
	name = "polaris cargo access spawn"
	req_access = list(access_polariscargo)
	color = CARGO

/obj/mapping_helper/access/polarisimportant
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
