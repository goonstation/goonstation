//Access levels moved to _accessLevels.dm
/*
 * List of access groups; if any access group has its access criteria met, access is granted (i.e. logical or).
 * Each access group must have all of its access requirements met (i.e. logical and).
 * The access groups may be flattened to a single access number (e.g. list(1) being equivalent to list(list(1)), and list(1, 2) being equivalent to list(list(1), list(2)).
 */
/obj/var/list/req_access = null
/*
 * Text version of req_access, converted on instantiation (useful for applying vars to specific instances in a map)
 * Syntax is "x|y;z", where "|" delimit access groups, and ";" delimit access within each group.
 * To set to no access requirements, set this to an empty string.
 * To not affect requirements, this should be null.
 */
/obj/var/req_access_txt = null
/*
 * Override all access requirements if user is an administrator
 */
/obj/var/admin_access_override = FALSE

/*
 * Overrides the object's req_access var based on what's in req_access_txt (if set).
 */
/obj/proc/update_access_from_txt()
	// null req_access_txt means no change
	if (!isnull(src.req_access_txt))
		// empty string (or "0") req_access_txt means set to no access required
		if (src.req_access_txt && src.req_access_txt != "0")
			// reset src.req_access to build it up
			src.req_access = list()
			var/list/access_group_txts = splittext(src.req_access_txt, "|")
			// loop through the access groups, adding them to src.req_access as they are resolved
			for (var/access_group_txt in access_group_txts)
				// sanity check for an empty access group (e.g. src.req_access_txt is "1|"), giving an empty string as the last access group
				if (access_group_txt)
					var/list/access_group = list()
					var/list/access_group_strings = splittext(access_group_txt, ";")
					// loop through the access group, adding them to the list for this group
					for (var/access_string in access_group_strings)
						// sanity check for an empty access string (e.g. src.req_access_txt is "1;", giving an empty string as the last access string
						if (access_string)
							// parse the access string
							var/access_code = text2num(access_string)
							if (!isnull(access_code))
								// numerical code
								access_group += access_code
							// else
								// string code
								// TODO: some sensible lookup, possibly using access_name_lookup (but they're VERY wordy)
					// add to the src.req_access list (assuming non-empty)
					if (length(access_group) > 1)
						// add the whole access group
						// odd syntax is because += with a list on the right appends the items of the list, not the list itself, so we wrap in a list so it only unpacks once
						src.req_access += list(access_group)
					else if (length(access_group) == 1)
						// add the single element
						src.req_access += access_group[1]
		else
			src.req_access = null

/**
 * Determines if a mob is allowed to use an object (or pass through
 *
 * @param {mob} M Mob of which to check the credentials
 *
 * @return {int} Whether mob has sufficient access (0=no, 1=implicit, 2=explicit)
 */
/obj/proc/allowed(mob/M)
	. = 0
	if(M?.client?.holder?.ghost_interaction)
		return 2
	// easy out for if no access is required
	if (src.check_access(null))
		return 1
	if (M && ismob(M))
		// check for admin access override
		if (src.admin_access_override)
			if (M.client?.holder?.level >= LEVEL_SA)
				return 2
		// check in-hand first
		if (src.check_access(M.equipped()))
			return 2
		// check if they are wearing a card that has access
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (src.check_access(H.wear_id))
				return 2
		// check if they are a silicon with access
		else if (issilicon(M) || isAIeye(M))
			var/mob/living/silicon/S
			if (isAIeye(M))
				var/mob/living/intangible/aieye/E = M
				S = E.mainframe
			else
				S = M
			// check if their silicon-card has access
			if (src.check_access(S.botcard))
				return 2
		// check implant (last, so as to avoid using it unnecessarily)
		if (src.check_implanted_access(M))
			return 2


/obj/proc/has_access_requirements()
	.= 1
	// no requirements
	if (!src.req_access)
		return 0
	// something's very wrong
	if (!istype(src.req_access, /list))
		return 0
	// no requirements (also clean up src.req_access)
	if (!length(src.req_access))
		src.req_access = null
		return 0

/*
 * @param {/obj/item} I Item of which to check the credentials
 * @return {bool} Whether item has sufficient access
 */
/obj/proc/check_access(obj/item/I)
	// no requirements
	if (!src.req_access)
		return 1
	// something's very wrong
	if (!istype(src.req_access, /list))
		return 1
	// no requirements (also clean up src.req_access)
	if (length(src.req_access) == 0)
		src.req_access = null
		return 1

	var/obj/item/card/id/ID = get_id_card(I)
	// not ID
	if (!istype(ID))
		return 0
	// no access
	if (!ID.access)
		return 0

	for (var/req_access_group in src.req_access)
		var/has_access = 1
		// access group is a list
		if (islist(req_access_group))
			var/list/req_access_group_list = req_access_group
			for (var/req in req_access_group_list)
				// if missing access within this access group, move on to the next
				if (!(req in ID.access))
					has_access = 0
					break
		// access group is a single number
		else if (!(req_access_group in ID.access))
			has_access = 0
		// meets all access requirements for the access group
		if (has_access)
			return 1
	return 0

//put in access num, check if i have that
/obj/proc/has_access(var/acc)
	// no requirements
	if (!src.req_access)
		return 1
	// something's very wrong
	if (!istype(src.req_access, /list))
		return 1
	// no requirements (also clean up src.req_access)
	if (length(src.req_access) == 0)
		src.req_access = null
		return 1

	for (var/req_access_group in src.req_access)
		// access group is a list
		if (islist(req_access_group))
			var/list/req_access_group_list = req_access_group
			if (acc in req_access_group_list)
				return 1
		// access group is a single number
		else if (req_access_group == acc)
			return 1

	return 0

/**
 * @param {mob} M Mob of which to check the implanted credentials
 *
 * @return {bool} Whether mob has sufficient access via its implant
 */
/obj/proc/check_implanted_access(mob/M)
	var/has_access = 0
	for (var/obj/item/implant/access/I in M)
		if (I.owner != M)
			continue
		if (check_access(I.access))
			has_access = I.used()
	return has_access


/// Global lookup proc for access levels based on a job string (e.g. "Captain")
/proc/get_access(job)
	switch(job)
		// --------------------------- Heads of staff
		if("Captain")
			return get_all_accesses()
		if("Head of Personnel")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_brig, access_forensics_lockers, access_ticket,
						access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab,
						access_change_ids, access_eva, access_heads, access_head_of_personnel, access_medical_lockers,
						access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_kitchen, access_robotics, access_cargo, access_supply_console,
						access_research, access_hydro, access_ranch, access_mail, access_ai_upload, access_pathology, access_researchfoyer,
						access_telesci, access_teleporter, access_money)
		if("Head of Security")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_maxsec, access_brig, access_securitylockers,
						access_forensics_lockers, access_armory, access_ticket, access_tox, access_tox_storage, access_chemistry, access_medical,
						access_morgue, access_change_ids, access_eva, access_heads, access_medical_lockers, access_medlab,
						access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_crematorium, access_kitchen, access_robotics, access_cargo, access_money,
						access_research, access_dwaine_superuser, access_hydro, access_ranch, access_mail, access_ai_upload,
						access_engineering, access_teleporter, access_engineering_engine, access_engineering_control,
						access_mining, access_pathology, access_researchfoyer, access_chapel_office, access_telesci,
						access_engineering_eva, access_engineering_storage, access_engineering_mechanic)
		if("Research Director")
			return list(access_research, access_research_director, access_dwaine_superuser,
						access_tech_storage, access_maint_tunnels, access_heads, access_eva, access_tox,
						access_tox_storage, access_chemistry, access_teleporter, access_ai_upload, access_researchfoyer, access_telesci,
						access_artlab, access_robotdepot,
						)
		if("Medical Director")
			return list(access_robotics, access_medical, access_morgue,
						access_maint_tunnels, access_tech_storage, access_medical_lockers,
						access_medlab, access_heads, access_eva, access_medical_director, access_ai_upload, access_teleporter
						)
		if("Chief Engineer")
			return list(access_engineering, access_maint_tunnels,
						access_tech_storage, access_engineering_storage, access_engineering_eva, access_engineering_atmos,
						access_engineering_power, access_engineering_engine,
						access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
						access_heads, access_ai_upload, access_eva, access_cargo, access_supply_console, access_teleporter)
		if("Head of Mining", "Mining Supervisor")
			return list(access_engineering, access_maint_tunnels,
						access_engineering_eva, access_mining,
						access_mining_outpost, access_heads, access_ai_upload, access_eva)

		// --------------------------- Security
		if("Nanotrasen Security Consultant")
			return get_access("Security Officer") + list(access_heads, access_eva)
		if("Security Officer")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_securitylockers, access_brig,  access_ticket,
			access_maint_tunnels, access_medical, access_morgue, access_research, access_cargo, access_engineering, access_engineering_control,
			access_chemistry, access_bar, access_kitchen, access_hydro, access_pathology, access_researchfoyer, access_mining
			)
		if("Vice Officer")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_brig, access_ticket, access_maint_tunnels,
			access_hydro, access_bar, access_kitchen, access_ranch)
		if("Security Assistant")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_brig, access_ticket, access_maint_tunnels)
		if("Detective", "Forensic Technician")
			return list(access_brig, access_carrypermit, access_contrabandpermit, access_security, access_forensics_lockers, access_ticket,
			access_morgue, access_maint_tunnels, access_crematorium, access_medical, access_research)
		if("Lawyer")
			return list(access_morgue, access_maint_tunnels)

		// --------------------------- Medical
		if("Medical Doctor", "Medical Trainee")
			return list(access_medical, access_medical_lockers, access_morgue, access_maint_tunnels)
		if("Geneticist")
			return list(access_medical, access_medical_lockers, access_morgue, access_medlab, access_maint_tunnels)
		if("Pathologist")
			return list(access_medical, access_medical_lockers, access_morgue, access_pathology, access_maint_tunnels)
		if("Roboticist")
			return list(access_robotics, access_tech_storage, access_medical, access_medical_lockers, access_morgue, access_maint_tunnels)
		if("Pharmacist")
			return list(access_research,access_tech_storage, access_maint_tunnels, access_chemistry,
						access_medical_lockers, access_medical, access_morgue, access_researchfoyer)
		if("Psychiatrist")
			return list(access_medical, access_maint_tunnels)
		if("Medical Specialist")
			return list(access_robotics, access_medical, access_morgue,
						access_maint_tunnels, access_tech_storage, access_medical_lockers,
						access_medlab) //Mdir minus head stuff

		// --------------------------- Science
		if("Scientist", "Research Trainee")
			return list(access_tox, access_tox_storage, access_research, access_chemistry, access_researchfoyer, access_artlab, access_telesci, access_robotdepot)
		if("Chemist")
			return list(access_research, access_chemistry, access_researchfoyer)
		if("Toxins Researcher")
			return list(access_research, access_tox, access_tox_storage, access_researchfoyer)

		// --------------------------- Engineering
		if("Atmospheric Technician")
			return list(access_maint_tunnels, access_engineering_control,
						access_eva, access_engineering, access_engineering_storage, access_engineering_eva, access_engineering_atmos)
		if("Engineer", "Technical Trainee")
			return list(access_engineering, access_maint_tunnels, access_engineering_control,
						access_engineering_storage, access_engineering_atmos, access_engineering_engine, access_engineering_power,
						access_tech_storage, access_engineering_mechanic)
		if("Miner")
			return list(access_maint_tunnels,
						access_engineering_eva, access_mining,
						access_mining_outpost)
		if("Quartermaster")
			return list(access_maint_tunnels, access_cargo, access_supply_console)
		if("Construction Worker")
			return list(access_engineering, access_maint_tunnels, access_engineering_control,
						access_engineering_storage,access_engineering_atmos,access_engineering_engine,access_engineering_power)

		// --------------------------- Civilian
		if("Chaplain")
			return list(access_morgue, access_chapel_office, access_crematorium)
		if("Janitor")
			return list(access_janitor, access_maint_tunnels, access_medical, access_morgue, access_crematorium)
		if("Botanist", "Apiculturist")
			return list(access_maint_tunnels, access_hydro)
		if("Rancher")
			return list(access_maint_tunnels, access_hydro, access_ranch)
		if("Chef", "Sous-Chef")
			return list(access_kitchen)
		if("Bartender")
			return list(access_bar)
		if("Waiter")
			return list(access_bar, access_kitchen)
		if("Clown", "Boxer", "Barber", "Mime", "Dungeoneer")
			return list(access_maint_tunnels)
		if("Assistant", "Staff Assistant", "Radio Show Host")
			return list(access_maint_tunnels, access_tech_storage)
		if("Mail Courier")
			return list(access_mail, access_heads, access_cargo, access_medical, access_researchfoyer, access_research, access_tech_storage)

		// --------------------------- Other or gimmick
		if("VIP")
			return list(access_heads, access_contrabandpermit) // Their cane is contraband.
		if("Diplomat")
			return list(access_heads)
		if("Space Cowboy")
			return list(access_maint_tunnels, access_carrypermit)
		if("Club member")
			return list(access_special_club)
		if("Inspector", "Communications Officer")
			return list(access_security, access_ticket, access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab,
						access_eva, access_heads, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_kitchen, access_robotics, access_cargo, access_research, access_hydro, access_ranch, access_pathology,
						access_researchfoyer, access_artlab, access_telesci, access_robotdepot)
		if("Hall Monitor")
			return list(access_ticket)
		if("Admin")
			return access_all_actually
		else
			return list()

/proc/get_all_accesses()  // not adding the special stuff to this
#if defined(I_MEAN_ALL_ACCESS)
	return access_all_actually
#else
	return list(access_security, access_brig, access_forensics_lockers, access_ticket,
				access_medical, access_medlab, access_morgue, access_securitylockers,
				access_tox, access_tox_storage, access_chemistry, access_carrypermit, access_contrabandpermit,
				access_change_ids, access_ai_upload,
				access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_head_of_personnel,
				access_chapel_office, access_kitchen, access_medical_lockers, access_pathology,
				access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_supply_console, access_hydro, access_ranch, access_mail,
				access_engineering, access_maint_tunnels,
				access_tech_storage, access_engineering_storage, access_engineering_eva,
				access_engineering_power, access_engineering_engine,
				access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
				access_research, access_research_director, access_dwaine_superuser, access_engineering_atmos, access_medical_director, access_special_club,
				access_researchfoyer, access_telesci, access_artlab, access_robotdepot, access_money)
#endif

/proc/syndicate_spec_ops_access() //syndie spec ops need to get out of the listening post.
	return list(access_security, access_brig, access_forensics_lockers,
				access_medical, access_medlab, access_morgue, access_securitylockers,
				access_tox, access_tox_storage, access_chemistry, access_carrypermit,
				access_change_ids, access_ai_upload,
				access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_head_of_personnel,
				access_chapel_office, access_kitchen, access_medical_lockers, access_pathology,
				access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_supply_console, access_hydro, access_ranch, access_mail,
				access_engineering, access_maint_tunnels,
				access_tech_storage, access_engineering_storage, access_engineering_eva,
				access_engineering_power, access_engineering_engine,
				access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
				access_research, access_research_director, access_dwaine_superuser, access_engineering_atmos, access_medical_director, access_special_club, access_syndicate_shuttle,
				access_researchfoyer, access_artlab, access_telesci, access_robotdepot)

// Generated at round start.
var/list/access_name_lookup = null
var/list/access_all_actually = null


/// Build the access_name_lookup table, to associate descriptions of accesses with their numerical value.
/proc/generate_access_name_lookup()
	if (!access_all_actually)
		access_all_actually  = new /list(100)
		for(var/i in 1 to 100)
			access_all_actually[i] = i

	if (access_name_lookup)
		return

	access_name_lookup = list()
	var/list/accesses = get_all_accesses()
	for (var/accessNum in accesses)
		access_name_lookup += "[get_access_desc(accessNum)]"

	sortList(access_name_lookup, /proc/cmp_text_asc)

	for (var/accessNum in accesses)
		access_name_lookup["[get_access_desc(accessNum)]"] = accessNum

/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_brig)
			return "Brig"
		if(access_security)
			return "Security"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_securitylockers)
			return "Security Equipment"
		if(access_medical)
			return "Medical"
		if(access_medical_lockers)
			return "Medical Equipment"
		if(access_medlab)
			return "Med-Sci/Genetics"
		if(access_pathology)
			return "Pathology"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "Toxins Research"
		if(access_tox_storage)
			return "Toxins Storage"
		if(access_chemistry)
			return "Chemical Lab"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Janitorial Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_supply_console)
			return "Quartermaster Supply Console"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Head's Quarters/Bridge"
		if(access_captain)
			return "Captain's Quarters"
		if(access_all_personal_lockers)
			return "Personal Locker Master Key"
		if(access_chapel_office)
			return "Chaplain's Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_maxsec)
			return "Head of Security's Office"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydro)
			return "Hydroponics"
		if(access_ranch)
			return "Ranch"
		if(access_mail)
			return "Mailroom"
		if(access_research)
			return "Research Sector"
		if(access_research_director)
			return "Research Director's Office"
		if(access_engineering)
			return "Engineering"
		if(access_engineering_storage)
			return "Engineering Storage"
		if(access_engineering_eva)
			return "Engineering EVA"
		if(access_engineering_power)
			return "Electrical Equipment (APCs)"
		if(access_engineering_engine)
			return "Engine Room"
		if(access_engineering_mechanic)
			return "Mechanical Lab"
		if(access_engineering_atmos)
			return "Engineering Gas Storage/Atmospherics"
		if(access_engineering_control)
			return "Engine Control Room"
		if(access_engineering_chief)
			return "Chief Engineer's Office"
		if(access_mining)
			return "Mining Department"
		if(access_mining_outpost)
			return "Mining Outpost"
		if(access_carrypermit)
			return "Firearms Carry Permit"
		if(access_contrabandpermit)
			return "Handling of Contraband Permit"
		if(access_medical_director)
			return "Medical Director's Office"
		if(access_robotics)
			return "Robotics"
		if(access_head_of_personnel)
			return "Head of Personnel's Office"
		if(access_dwaine_superuser)
			return "DWAINE Superuser"
		if(access_researchfoyer)
			return "Research Foyer"
		if(access_artlab)
			return "Artifact Lab"
		if(access_telesci)
			return "Telescience"
		if(access_robotdepot)
			return "Robot Depot"
		if (access_money)
			return "Budget Control"
		if (access_ticket)
			return "Ticketing"


proc/colorAirlock(access)
	switch(access)
		if(1,2,3,4,37,38)
			return "sec"
		if(5,6,9,10,24,27,29)
			return "med"
		if(7,8,24,33)
			return "sci"
		if(12,23,31)
			return "maint"
		if(11,18 to 20,49,53,55)
			return "com"
		if(40 to 48,50,51)
			return "eng"
		else
			return null



// gets you a list of airlock types for the current map, minus the bad ones
// probably. idk. fuck it
var/list/airlock_types = null
proc/get_airlock_types()
	if (airlock_types)
		return airlock_types

	airlock_types = list()
	var/hide_path = ""
	var/list/types = null
	switch (map_settings.airlock_style)
		if ("pyro")
			types = typesof(/obj/machinery/door/airlock/pyro)
			hide_path = "/obj/machinery/door/airlock/pyro"
		if ("gannets")
			types = typesof(/obj/machinery/door/airlock/gannets)
			hide_path = "/obj/machinery/door/airlock/gannets"
		else
			// gross
			types = typesof(/obj/machinery/door/airlock)
			types -= typesof(/obj/machinery/door/airlock/pyro)
			types -= typesof(/obj/machinery/door/airlock/gannets)
			hide_path = "/obj/machinery/door/airlock"

	for (var/door_type in types)
		if (initial(door_type:hardened) || initial(door_type:cant_emag))
			// Skip doors that we shouldn't be able to build
			continue
		var/display_name = replacetext("[door_type]", hide_path, "")
		if (!display_name)
			// Fake having a name for the blank ones
			display_name = "/basic"
		airlock_types[display_name] = door_type

	return airlock_types


//retrieves a map-appropriate airlock path
//access: a numerical access value
//variant: text string for the type you want (Glass, Standard, Alternate)
//technically you can skip both
// technically neat but fuck making this work currently
// i do not feel like unfuckling a three-dimensional switch statement -- zamujasa

//hello zamujasa it is kubius i am here to at least slightly unfuckle

proc/fetchAirlock(access,variant)
	if (map_settings)
		var/chroma = colorAirlock(access)
		switch(variant)
			if("Glass")
				if(chroma == "com")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass/command"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/command/alt"
						else return "/obj/machinery/door/airlock/glass/command"
				else if(chroma == "eng")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass/engineering"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/engineering/alt"
						else return "/obj/machinery/door/airlock/glass/engineering"
				else if(chroma == "sec")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/security/alt"
						else return "/obj/machinery/door/airlock/glass"
				else if(chroma == "med")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/medical"
						else return "/obj/machinery/door/airlock/glass/medical"
				else if(chroma == "sci")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/chemistry"
						else return "/obj/machinery/door/airlock/glass"
				else if(chroma == "maint")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass/maintenance"
						else return "/obj/machinery/door/airlock/glass"
				else
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/glass"
						if("gannets") return "/obj/machinery/door/airlock/gannets/glass"
						else return "/obj/machinery/door/airlock/glass"
			if("Alternate")
				if(chroma == "com")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/command/alt"
						if("gannets") return "/obj/machinery/door/airlock/gannets/command/alt"
						else return "/obj/machinery/door/airlock/command"
				else if(chroma == "eng")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/engineering/alt"
						if("gannets") return "/obj/machinery/door/airlock/gannets/engineering/alt"
						else return "/obj/machinery/door/airlock/engineering"
				else if(chroma == "sec")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/security/alt"
						if("gannets") return "/obj/machinery/door/airlock/gannets/security/alt"
						else return "/obj/machinery/door/airlock/security"
				else if(chroma == "med")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/medical/alt"
						if("gannets") return "/obj/machinery/door/airlock/gannets/medical"
						else return "/obj/machinery/door/airlock/medical"
				else if(chroma == "sci")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/medical/alt"
						if("gannets") return "/obj/machinery/door/airlock/gannets/toxins"
						else return "/obj/machinery/door/airlock/medical"
				else if(chroma == "maint")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/classic"
						if("gannets") return "/obj/machinery/door/airlock/gannets/maintenance"
						else return "/obj/machinery/door/airlock/classic"
				else
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro"
						if("gannets") return "/obj/machinery/door/airlock/gannets"
						else return "/obj/machinery/door/airlock"
			else
				if(chroma == "com")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/command"
						if("gannets") return "/obj/machinery/door/airlock/gannets/command"
						else return "/obj/machinery/door/airlock/command"
				else if(chroma == "eng")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/engineering"
						if("gannets") return "/obj/machinery/door/airlock/gannets/engineering"
						else return "/obj/machinery/door/airlock/engineering"
				else if(chroma == "sec")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/security"
						if("gannets") return "/obj/machinery/door/airlock/gannets/security"
						else return "/obj/machinery/door/airlock/security"
				else if(chroma == "med")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/medical"
						if("gannets") return "/obj/machinery/door/airlock/gannets/medical"
						else return "/obj/machinery/door/airlock/medical"
				else if(chroma == "sci")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/medical"
						if("gannets") return "/obj/machinery/door/airlock/gannets/chemistry"
						else return "/obj/machinery/door/airlock/medical"
				else if(chroma == "maint")
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro/maintenance"
						if("gannets") return "/obj/machinery/door/airlock/gannets/maintenance"
						else return "/obj/machinery/door/airlock/maintenance"
				else
					switch(map_settings.airlock_style)
						if("pyro") return "/obj/machinery/door/airlock/pyro"
						if("gannets") return "/obj/machinery/door/airlock/gannets"
						else return "/obj/machinery/door/airlock"
	else
		return "/obj/machinery/door/airlock"

/obj/proc/set_access_list(var/list/L)
	src.req_access = L.Copy()
	src.req_access_txt = null



