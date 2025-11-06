
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
	proc/add_evidence(var/datum/forensic_data/data, var/category = FORENSIC_GROUP_NOTES, var/admin_only = FALSE)
		if(HAS_FLAG(data.flags, FORENSIC_USED))
			CRASH("Another forensic_holder is already using this forensic_data! Please use a copy instead.")

		ADD_FLAG(data.flags, FORENSIC_USED)
		if(!HAS_FLAG(data.flags, FORENSIC_FAKE))
			var/datum/forensic_group/admin_group = get_group(category, TRUE)
			if(!admin_group)
				admin_group = forensic_group_create(category)
				src.admin_list += admin_group
			admin_group.apply_evidence(data.get_copy())
		if(!admin_only)
			var/datum/forensic_group/holder_group = get_group(category, FALSE)
			if(!holder_group)
				holder_group = forensic_group_create(category)
				src.group_list += holder_group
			holder_group.apply_evidence(data)

	proc/remove_evidence(var/removal_flags)
		for(var/datum/forensic_group/group in src.group_list)
			var/is_empty = group.remove_evidence(removal_flags)
			if(is_empty)
				src.remove_group(group)

	/// Obtain a specific type of forensic group if it exists
	proc/get_group(var/category = FORENSIC_GROUP_NOTES, var/check_admin = FALSE)
		var/list/datum/forensic_group/target_groups
		if(check_admin)
			target_groups = src.admin_list
		else
			target_groups = src.group_list
		for(var/datum/forensic_group/group in target_groups)
			if(group.category == category)
				return group
		return null

	proc/remove_group(var/datum/forensic_group/group)
		src.group_list -= group

	proc/copy_to(var/datum/forensic_holder/other, var/is_admin = FALSE)
		var/list/datum/forensic_group/scan_groups = src.group_list
		if(is_admin)
			scan_groups = src.admin_list
		for(var/datum/forensic_group/group in scan_groups)
			group.copy_to(other)

	proc/report_text(var/datum/forensic_scan/scan, var/datum/forensic_report/report, var/is_admin = FALSE)
		var/list/datum/forensic_group/scan_groups = src.group_list
		if(is_admin)
			scan_groups = src.admin_list
		for(var/datum/forensic_group/group in scan_groups)
			group.report_text(scan, report)
