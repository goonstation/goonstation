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
/obj/New()
	..()
	src.update_access_from_txt()
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
							else
								// string code
								// TODO: some sensible lookup, possibly using access_name_lookup (but they're VERY wordy)
					// add to the src.req_access list (assuming non-empty)
					if (access_group.len > 1)
						// add the whole access group
						// odd syntax is because += with a list on the right appends the items of the list, not the list itself, so we wrap in a list so it only unpacks once
						src.req_access += list(access_group)
					else if (access_group.len == 1)
						// add the single element
						src.req_access += access_group[1]
		else
			src.req_access = null

/**
 * @param {mob} M Mob of which to check the credentials
 * @return {bool} Whether mob has sufficient access
 */
/obj/proc/allowed(mob/M)
	// easy out for if no access is required
	if (src.check_access(null))
		return 1
	if (M && ismob(M))
		// check for admin access override
		if (src.admin_access_override)
			if (M.client?.holder?.level >= LEVEL_SA)
				return 1
		// check in-hand first
		if (src.check_access(M.equipped()))
			return 1
		// check if they are wearing a card that has access
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (src.check_access(H.wear_id))
				return 1
		// check if they are a silicon with access
		else if (issilicon(M) || isAIeye(M))
			var/mob/living/silicon/S
			if (isAIeye(M))
				var/mob/dead/aieye/E = M
				S = E.mainframe
			else
				S = M
			// check if their silicon-card has access
			if (src.check_access(S.botcard))
				return 1
		// check implant (last, so as to avoid using it unnecessarily)
		if (src.check_implanted_access(M))
			return 1
	return 0


/obj/proc/has_access_requirements()
	.= 1
	// no requirements
	if (!src.req_access)
		return 0
	// something's very wrong
	if (!istype(src.req_access, /list))
		return 0
	// no requirements (also clean up src.req_access)
	if (src.req_access.len == 0)
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
	if (src.req_access.len == 0)
		src.req_access = null
		return 1

	if (istype(I, /obj/item/device/pda2))
		var/obj/item/device/pda2/P = I
		if (P.ID_card)
			I = P.ID_card
	else if (istype(I, /obj/item/magtractor))
		var/obj/item/magtractor/mag = I
		if (istype(mag.holding, /obj/item/card/id))
			I = mag.holding
	var/obj/item/card/id/ID = I
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
	if (src.req_access.len == 0)
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

// I moved all the duplicate definitions from jobs.dm to this global lookup proc.
// Advantages: can be used by other stuff (bots etc), and there's less code to maintain (Convair880).
/proc/get_access(job)
	switch(job)
		///////////////////////////// Heads of staff
		if("Captain")
			return get_all_accesses()
		if("Head of Personnel")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_brig, access_forensics_lockers, access_armory,
						access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab,
						access_emergency_storage, access_change_ids, access_eva, access_heads, access_head_of_personnel, access_medical_lockers,
						access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_crematorium, access_kitchen, access_robotics, access_cargo, access_supply_console,
						access_research, access_hydro, access_mail, access_ai_upload)
		if("Head of Security")
#ifdef RP_MODE
			var/list/hos_access = get_all_accesses()
			hos_access += access_maxsec
			return hos_access
#else
			return list(access_security, access_carrypermit, access_contrabandpermit, access_maxsec, access_brig, access_securitylockers, access_forensics_lockers, access_armory,
						access_tox, access_tox_storage, access_chemistry, access_medical, access_morgue, access_medlab,
						access_emergency_storage, access_change_ids, access_eva, access_heads, access_medical_lockers,
						access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_crematorium, access_kitchen, access_robotics, access_cargo,
						access_research, access_dwaine_superuser, access_hydro, access_mail, access_ai_upload,
						access_engineering, access_teleporter, access_engineering_engine, access_engineering_power,
						access_mining)
#endif
		if("Research Director")
			return list(access_research, access_research_director, access_dwaine_superuser,
						access_tech_storage, access_maint_tunnels, access_heads, access_eva, access_tox,
						access_tox_storage, access_chemistry, access_teleporter, access_ai_upload)
		if("Medical Director", "Head Surgeon")
			return list(access_robotics, access_medical, access_morgue,
						access_maint_tunnels, access_tech_storage, access_medical_lockers,
						access_medlab, access_heads, access_eva, access_medical_director, access_ai_upload)
		if("Chief Engineer")
			return list(access_engineering, access_maint_tunnels, access_external_airlocks,
						access_tech_storage, access_engineering_storage, access_engineering_eva, access_engineering_atmos,
						access_engineering_power, access_engineering_engine, access_mining_shuttle,
						access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
						access_heads, access_ai_upload, access_construction, access_eva, access_cargo, access_supply_console, access_hangar)
		if("Head of Mining", "Mining Supervisor")
			return list(access_engineering, access_maint_tunnels, access_external_airlocks,
						access_engineering_eva, access_mining_shuttle, access_mining,
						access_mining_outpost, access_hangar, access_heads, access_ai_upload, access_construction, access_eva)

		///////////////////////////// Security
		if("Security Officer")
#ifdef RP_MODE // trying out giving them more access for RP
			return list(access_security, access_brig, access_forensics_lockers, access_armory,
				access_medical, access_medlab, access_morgue, access_securitylockers,
				access_tox, access_tox_storage, access_chemistry, access_carrypermit, access_contrabandpermit,
				access_emergency_storage, access_chapel_office, access_kitchen, access_medical_lockers,
				access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction, access_hydro, access_mail,
				access_engineering, access_maint_tunnels, access_external_airlocks,
				access_tech_storage, access_engineering_storage, access_engineering_eva,
				access_engineering_power, access_engineering_engine, access_mining_shuttle,
				access_engineering_control, access_engineering_mechanic, access_mining, access_mining_outpost,
				access_research, access_engineering_atmos, access_hangar)
#else
			return list(access_security, access_carrypermit, access_contrabandpermit, access_securitylockers, access_brig, access_maint_tunnels,
			access_medical, access_morgue, access_crematorium, access_research, access_cargo, access_engineering,
			access_chemistry, access_bar, access_kitchen, access_hydro)
#endif
		if("Vice Officer")
			return list(access_security, access_carrypermit, access_contrabandpermit, access_securitylockers, access_brig, access_maint_tunnels,access_hydro,access_bar,access_kitchen)
		if("Detective", "Forensic Technician")
			return list(access_brig, access_carrypermit, access_contrabandpermit, access_security, access_forensics_lockers, access_morgue, access_maint_tunnels, access_crematorium, access_medical, access_research)
		if("Lawyer")
			return list(access_maint_tunnels, access_security, access_brig)

		///////////////////////////// Medical
		if("Medical Doctor")
			return list(access_medical, access_medical_lockers, access_morgue, access_maint_tunnels)
		if("Geneticist")
			return list(access_medical, access_medical_lockers, access_morgue, access_medlab, access_maint_tunnels)
		if("Roboticist")
			return list(access_robotics, access_tech_storage, access_medical, access_medical_lockers, access_morgue, access_maint_tunnels)
		if("Pharmacist")
			return list(access_research,access_tech_storage, access_maint_tunnels, access_chemistry,
						access_medical_lockers, access_medical, access_morgue)
		if("Medical Assistant")
			return list(access_maint_tunnels, access_tech_storage, access_medical, access_morgue)
		if("Psychologist")
			return list(access_medical, access_maint_tunnels)

		///////////////////////////// Science
		if("Scientist")
			return list(access_tox, access_tox_storage, access_research, access_chemistry)
		if("Chemist")
			return list(access_research, access_chemistry)
		if("Toxins Researcher")
			return list(access_research, access_tox, access_tox_storage)
		if("Research Assistant")
			return list(access_maint_tunnels, access_tech_storage, access_research)

		//////////////////////////// Engineering
		if("Mechanic")
			return list(access_maint_tunnels, access_external_airlocks,
						access_tech_storage,access_engineering_mechanic,access_engineering_power)
		if("Atmospheric Technician")
			return list(access_maint_tunnels, access_external_airlocks, access_construction,
						access_eva, access_engineering, access_engineering_storage, access_engineering_eva, access_engineering_atmos)
		if("Engineer")
			return list(access_engineering,access_maint_tunnels,access_external_airlocks,
						access_engineering_storage,access_engineering_atmos,access_engineering_engine,access_engineering_power)
		if("Miner")
			return list(access_maint_tunnels, access_external_airlocks,
						access_engineering_eva, access_mining_shuttle, access_mining,
						access_mining_outpost, access_hangar)
		if("Quartermaster")
			return list(access_maint_tunnels, access_cargo, access_supply_console, access_hangar)
		if("Construction Worker")
			return list(access_engineering,access_maint_tunnels,access_external_airlocks,
						access_engineering_storage,access_engineering_atmos,access_engineering_engine,access_engineering_power)

		///////////////////////////// Civilian
		if("Chaplain")
			return list(access_morgue, access_chapel_office, access_crematorium)
		if("Janitor")
			return list(access_janitor, access_maint_tunnels, access_medical, access_morgue, access_crematorium)
		if("Botanist", "Apiculturist")
			return list(access_maint_tunnels, access_hydro)
		if("Chef", "Sous-Chef")
			return list(access_kitchen)
		if("Bartender")
			return list(access_bar)
		if("Waiter")
			return list(access_bar, access_kitchen)
		if("Clown", "Boxer", "Barber", "Mime")
			return list(access_maint_tunnels)
		if("Assistant", "Staff Assistant", "Technical Assistant", "Radio Show Host")
			return list(access_maint_tunnels, access_tech_storage)
		if("Mailman")
			return list(access_maint_tunnels, access_mail, access_heads, access_cargo, access_hangar)

		//////////////////////////// Other or gimmick
		if("VIP")
			return list(access_heads, access_contrabandpermit) // Their cane is contraband.
		if("Diplomat")
			return list(access_heads)
		if("Space Cowboy")
			return list(access_maint_tunnels, access_carrypermit)
		if("Club member")
			return list(access_special_club)
		if("Inspector", "Communications Officer")
			return list(access_security, access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab,
						access_emergency_storage, access_eva, access_heads, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
						access_kitchen, access_robotics, access_cargo, access_research, access_hydro)

		else
			return list()

/proc/get_all_accesses()  // not adding the special stuff to this
	return list(access_security, access_brig, access_forensics_lockers, access_armory,
	            access_medical, access_medlab, access_morgue, access_securitylockers,
	            access_tox, access_tox_storage, access_chemistry, access_carrypermit, access_contrabandpermit,
	            access_emergency_storage, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_head_of_personnel,
	            access_chapel_office, access_kitchen, access_medical_lockers,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_supply_console, access_construction, access_hydro, access_mail,
	            access_engineering, access_maint_tunnels, access_external_airlocks,
	            access_tech_storage, access_engineering_storage, access_engineering_eva,
	            access_engineering_power, access_engineering_engine, access_mining_shuttle,
	            access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
	            access_research, access_research_director, access_dwaine_superuser, access_engineering_atmos, access_hangar, access_medical_director, access_special_club)

/proc/syndicate_spec_ops_access() //syndie spec ops need to get out of the listening post.
	return list(access_security, access_brig, access_forensics_lockers, access_armory,
	            access_medical, access_medlab, access_morgue, access_securitylockers,
	            access_tox, access_tox_storage, access_chemistry, access_carrypermit,
	            access_emergency_storage, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_head_of_personnel,
	            access_chapel_office, access_kitchen, access_medical_lockers,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_supply_console, access_construction, access_hydro, access_mail,
	            access_engineering, access_maint_tunnels, access_external_airlocks,
	            access_tech_storage, access_engineering_storage, access_engineering_eva,
	            access_engineering_power, access_engineering_engine, access_mining_shuttle,
	            access_engineering_control, access_engineering_mechanic, access_engineering_chief, access_mining, access_mining_outpost,
	            access_research, access_research_director, access_dwaine_superuser, access_engineering_atmos, access_hangar, access_medical_director, access_special_club, access_syndicate_shuttle)

var/list/access_name_lookup //Generated at round start.

//Build the access_name_lookup table, to associate descriptions of accesses with their numerical value.
/proc/generate_access_name_lookup()
	if (access_name_lookup)
		return

	access_name_lookup = list()
	var/list/accesses = get_all_accesses()
	for (var/accessNum in accesses)
		access_name_lookup += "[get_access_desc(accessNum)]"

	access_name_lookup = sortList(access_name_lookup) //Make the list all nice and alphabetical.

	for (var/accessNum in accesses)
		access_name_lookup["[get_access_desc(accessNum)]"] = accessNum

/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
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
		if(access_external_airlocks)
			return "External Airlock"
		if(access_emergency_storage)
			return "Emergency Storage"
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
			return "Armory (Command Staff)"
		if(access_maxsec)
			return "Armory (Head of Security)"
		if(access_construction)
			return "Construction Site"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydro)
			return "Hydroponics"
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
		if(access_mining_shuttle)
			return "Mining Outpost Shuttle"
		if(access_engineering_control)
			return "Engine Control Room"
		if(access_engineering_chief)
			return "Chief Engineer's Office"
		if(access_mining)
			return "Mining Department"
		if(access_mining_outpost)
			return "Mining Outpost"
		if(access_hangar)
			return "Hangar"
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



