
// The forensic holder stores all the forensic evidence associated with whatever it is attached to
// The holder contains forensic groups, which are responsible for managing a specific type of evidence that may exist
datum/forensic_holder
	var/list/datum/forensic_group/group_list = new/list()
	var/list/datum/forensic_group/admin_list = new/list() // Evidence list for admins
	var/accuracy_mult = 1.0 // Multiplier for this item's timestamp accuracy. Lower the better.

	var/ignore_flags = 0 // Do not add evidence with these flags
	var/ignore_flags_removal = 0 // These ways of removing evidence have no power here

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

	proc/get_group(var/category = FORENSIC_GROUP_NOTE, var/admin = FALSE)
		// Should I change this to a dictionary lookup?
		var/list/datum/forensic_group/E_list
		if(admin)
			E_list = src.admin_list
		else
			E_list = src.group_list
		for(var/datum/forensic_group/G in E_list)
			if(G.category == category)
				return G
		return null

	proc/cut_group(var/category)
		for(var/i in 1 to src.group_list)
			if(src.group_list[i].category == category)
				src.group_list.Cut(i, i+1)
				return

	proc/add_evidence(var/datum/forensic_data/data, var/category = FORENSIC_GROUP_NOTE, var/admin_only = FALSE)
		data.category = category
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

	proc/remove_evidence(var/removal_flags) // Remove evidence marked with a flag. Should work with multiple flags as well.
		removal_flags = removal_flags & (~src.ignore_flags_removal)
		if(removal_flags == 0 || length(group_list) == 0)
			return
		// Iterate backwards since groups can be removed
		for(var/i= length(src.group_list); i>= 1; i--)
			src.group_list[i].remove_evidence(src, removal_flags)
		return
	proc/remove_group(var/category, var/removal_flags = FORENSIC_REMOVAL_ALL)
		for(var/datum/forensic_group/G in src.group_list)
			if(G.category == category)
				G.remove_evidence(src, removal_flags)
				return

	proc/copy_evidence(var/datum/forensic_holder/target, var/copy_flags = ~0) // Copy evidence from this holder to another
		for(var/datum/forensic_group/G in src.group_list)
			G.copy_group(target)
