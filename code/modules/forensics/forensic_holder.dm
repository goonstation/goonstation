
// A forensic_holder stores all forensic evidence associated with whatever it is attached to
// The holder contains forensic groups, which are responsible for managing a specific type of evidence that may exist
datum/forensic_holder
	var/list/datum/forensic_group/group_list = new/list()
	var/list/datum/forensic_group/admin_list = new/list() // A seperate evidence list for admins

	disposing()
		if(src.group_list)
			for(var/group in src.group_list)
				qdel(group)
			src.group_list.len = 0
			src.group_list = null
		if(src.admin_list)
			for(var/group in src.admin_list)
				qdel(group)
			src.admin_list.len = 0
			src.admin_list = null
		..()

	/// Add forensic data to the holder, such as an indiviual fingerprint or DNA sample
	proc/add_evidence(var/datum/forensic_data/data, var/category = FORENSIC_GROUP_NOTE, var/admin_only = FALSE)
		if(!HAS_FLAG(data.flags, FORENSIC_FAKE))
			var/datum/forensic_group/h_group = get_group(category, TRUE)
			if(!h_group)
				h_group = forensic_group_create(category)
				src.admin_list += h_group
			h_group.apply_evidence(data.get_copy())
		if(!admin_only)
			var/datum/forensic_group/group = get_group(category, FALSE)
			if(!group)
				group = forensic_group_create(category)
				src.group_list += group
			group.apply_evidence(data)

	/// Obtain a specific type of forensic group if it exists
	proc/get_group(var/category = FORENSIC_GROUP_NOTE, var/admin = FALSE)
		var/list/datum/forensic_group/E_list
		if(admin)
			E_list = src.admin_list
		else
			E_list = src.group_list
		for(var/datum/forensic_group/G in E_list)
			if(G.category == category)
				return G
		return null
