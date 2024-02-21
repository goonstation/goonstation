TYPEINFO(/datum)
	var/admin_spawnable = TRUE

#ifdef IMAGE_DEL_DEBUG
var/global/list/deletedImageData = list()
var/global/list/deletedImageIconStates = list()

/image/Del()
	deletedImageData.len++;
	deletedImageData[deletedImageData.len] = "alpha: [src.alpha] blend_mode: [src.blend_mode] color: [src.color], file: [src.icon] icon: \icon[src.icon] icon_state: [src.icon_state] dir: [src.dir] loc: \ref[src.loc] layer: [src.layer] x: [src.x] y: [src.y] z: [src.z] type: [src.type] parent_type: [src.parent_type] tag: [src.tag]"
	deletedImageIconStates[src.icon_state]++

	..()
#endif

#ifdef DELETE_QUEUE_DEBUG
var/global/list/deletedObjects = list()

/datum/Del()
	if(!("[src.type]" in deletedObjects))
		deletedObjects["[src.type]"] = 0
	deletedObjects["[src.type]"]++
	..()
#endif

#ifdef SPACEMAN_DMM
/datum/New()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
#endif

/// called when a variable is admin-edited
/datum/proc/onVarChanged(variable, oldval, newval)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_VARIABLE_CHANGED, variable, oldval, newval)

/// called when a proc is admin-called
/datum/proc/onProcCalled(procname, list/arglist)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_PROC_CALLED, procname, arglist)

/// Used when you need to record a proc call to delete something (see spawn_rules.dm)
/datum/proc/safe_delete()
	qdel(src)
