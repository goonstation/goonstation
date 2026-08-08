/obj/mapping_helper/access
	name = "access spawn"
	desc = "Sets access of machines on the same turf as it to its access, then destroys itself."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "access_spawn"
	/// List of types this helper affects, anything else is ignored.
	var/affected_types = list(/obj/machinery)
	/// Completely override any existing accesses on the target or just add to it?
	var/override_access = FALSE

	setup()
		for (var/obj/O in src.loc)
			if(!istypes(O, src.affected_types))
				continue
			if (!O.req_access || src.override_access)
				O.req_access = src.req_access
			else
				O.req_access += src.req_access
			//todo : autoname doors	here too. var editing is illegal!

//////////// Security ////
/obj/mapping_helper/access/security
	name = "security access spawn"
	req_access = list(access_security)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/brig
	name = "brig access spawn"
	req_access = list(access_brig)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/sec_lockers
	name = "security weapons access spawn"
	req_access = list(access_securitylockers)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/carry_permit
	name = "carry permit access spawn"
	req_access = list(access_carrypermit)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/forensics
	name = "forensics access spawn"
	req_access = list(access_forensics_lockers)
	color = CI::COL::SECURITY

//////////// Medical ////
/obj/mapping_helper/access/medical
	name = "medical access spawn"
	req_access = list(access_medical)
	color = CI::COL::MEDICAL

/obj/mapping_helper/access/medlocker
	name = "medical locker access spawn"
	req_access = list(access_medical_lockers)
	color = CI::COL::MEDICAL

/obj/mapping_helper/access/morgue
	name = "morgue access spawn"
	req_access = list(access_morgue)
	color = CI::COL::MORGUE

/obj/mapping_helper/access/medlab
	name = "medlab access spawn"
	req_access = list(access_medlab)
	color = CI::COL::MEDICAL

/obj/mapping_helper/access/robotics
	name = "robotics access spawn"
	req_access = list(access_robotics)
	color = CI::COL::MEDICAL

/obj/mapping_helper/access/pharmacy
	name = "pharmacy access spawn"
	req_access = list(access_pharmacy)
	color = CI::COL::MEDICAL

//////////// Engineering ////
/obj/mapping_helper/access/cargo
	name = "cargo access spawn"
	req_access = list(access_cargo)
	color = CI::COL::CARGO

/obj/mapping_helper/access/engineering
	name = "engineering access spawn"
	req_access = list(access_engineering)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_storage
	name = "engineering storage access spawn"
	req_access = list(access_engineering_storage)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_power
	name = "engineering power access spawn"
	req_access = list(access_engineering_power)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_engine
	name = "engineering engine access spawn"
	req_access = list(access_engineering_engine)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_mechanic
	name = "engineering mechanics access spawn"
	req_access = list(access_engineering_mechanic)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_atmos
	name = "engineering atmos access spawn"
	req_access = list(access_engineering_atmos)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/engineering_control
	name = "engineering control access spawn"
	req_access = list(access_engineering_control)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/mining
	name = "mining EVA access spawn"
	req_access = list(access_mining)
	color = CI::COL::CARGO

/obj/mapping_helper/access/mining_outpost
	name = "mining_outpost access spawn"
	req_access = list(access_mining_outpost)
	color = CI::COL::CARGO

//////////// Research ////
/obj/mapping_helper/access/tox
	name = "toxins access spawn"
	req_access = list(access_tox)
	color = CI::COL::TOXINS

/obj/mapping_helper/access/tox_storage
	name = "toxins storage access spawn"
	req_access = list(access_tox_storage)
	color = CI::COL::TOXINS

/obj/mapping_helper/access/research
	name = "research access spawn"
	req_access = list(access_research)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/chemistry
	name = "chem access spawn"
	req_access = list(access_chemistry)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/research_foyer
	name = "research foyer access spawn"
	req_access = list(access_researchfoyer)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/artlab
	name = "artlab access spawn"
	req_access = list(access_artlab)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/telesci
	name = "telesci access spawn"
	req_access = list(access_telesci)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/robotdepot
	name = "robot depot access spawn"
	req_access = list(access_robotdepot)
	color = CI::COL::RESEARCH

//////////// Civilian ////
/obj/mapping_helper/access/maint
	name = "maint access spawn"
	req_access = list(access_maint_tunnels)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/chapel_office
	name = "chapel office access spawn"
	req_access = list(access_chapel_office)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/tech_storage
	name = "tech storage access spawn"
	req_access = list(access_tech_storage)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/bar
	name = "bar access spawn"
	req_access = list(access_bar)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/janitor
	name = "janitor access spawn"
	req_access = list(access_janitor)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/crematorium
	name = "crematorium access spawn"
	req_access = list(access_crematorium)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/kitchen
	name = "kitchen access spawn"
	req_access = list(access_kitchen)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/hydro
	name = "hydro access spawn"
	req_access = list(access_hydro)
	color = CI::COL::MAINTENANCE

/obj/mapping_helper/access/rancher
	name = "ranch access spawn"
	req_access = list(access_ranch)
	color = CI::COL::MAINTENANCE

//////////// Command/Heads ////
/obj/mapping_helper/access/ai_upload
	name = "ai upload access spawn"
	req_access = list(access_ai_upload)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/teleporter
	name = "teleporter access spawn"
	req_access = list(access_teleporter)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/eva
	name = "eva access spawn"
	req_access = list(access_eva)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/heads
	name = "heads access spawn"
	req_access = list(access_heads)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/captain
	name = "captain access spawn"
	req_access = list(access_captain)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/head_of_personnel
	name = "HOP access spawn"
	req_access = list(access_head_of_personnel)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/computer_core
	name = "computer core access spawn"
	req_access = list(access_sysadmin)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/research_director
	name = "RD access spawn"
	req_access = list(access_research_director)
	color = CI::COL::RESEARCH

/obj/mapping_helper/access/medical_director
	name = "MD access spawn"
	req_access = list(access_medical_director)
	color = CI::COL::MEDICAL

/obj/mapping_helper/access/hos
	name = "HOS access spawn"
	req_access = list(access_maxsec)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/armory
	name = "Armory access spawn"
	req_access = list(access_armory)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/engineering_chief
	name = "CE access spawn"
	req_access = list(access_engineering_chief)
	color = CI::COL::ENGINEERING

//////////// Other ////
/obj/mapping_helper/access/centcom
	name = "centcom access spawn"
	req_access = list(access_centcom)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/syndie_shuttle
	name = "syndie_shuttle access spawn"
	req_access = list(access_syndicate_shuttle)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/pirate_ship
	name = "pirate ship access spawn"
	req_access = list(access_pirate)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/admin_override //special admin override access spawner
	name = "admin override access spawn"
	color = CI::COL::SPECIAL
	affected_types = list(/obj)
	admin_access_override = ADMIN_ACCESS_OVERRIDE_BYPASS

	setup()
		for (var/obj/O in src.loc)
			if(!istypes(O, src.affected_types))
				continue
			O.admin_access_override = src.admin_access_override

/obj/mapping_helper/access/admin_override/admin_only //Deny access to any non-admins
	name = "admin only access spawn"
	color = CI::COL::MORGUE
	admin_access_override = ADMIN_ACCESS_OVERRIDE_ONLY

/obj/mapping_helper/access/public
	name = "public access spawn"
	color = CI::COL::SPECIAL
	affected_types = list(/obj)

	setup()
		for (var/obj/O in src.loc)
			if(!istypes(O, src.affected_types))
				continue
			O.req_access = null

//////////////////////owlzone access///////
/obj/mapping_helper/access/owlmaint
	name = "owlery maint access spawn"
	req_access = list(access_owlerymaint)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/owlcommand
	name = "owlery command access spawn"
	req_access = list(access_owlerycommand)
	color = CI::COL::COMMAND

/obj/mapping_helper/access/owlsecurity
	name = "owlery sec access spawn"
	req_access = list(access_owlerysec)
	color = CI::COL::SECURITY

/obj/mapping_helper/access/polariscargo
	name = "polaris cargo access spawn"
	req_access = list(access_polariscargo)
	color = CI::COL::CARGO

/obj/mapping_helper/access/polarisimportant
	name = "polaris important access spawn"
	req_access = list(access_polarisimportant)
	color = CI::COL::CARGO

/obj/mapping_helper/access/impossible
	name = "impossible access spawn"
	req_access = list(access_impossible)
	color = CI::COL::MORGUE

/obj/mapping_helper/access/lunar_breakdoor
	name = "lunar breakdoor access spawn"
	req_access = list(access_lunar_breakdoor)
	color = CI::COL::ENGINEERING

/obj/mapping_helper/access/ainley_buddy
	name = "ainley buddy access spawn"
	req_access = list(access_ainley_buddy)
	color = CI::COL::COMMAND
