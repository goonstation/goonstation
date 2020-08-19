#ifdef IMAGE_DEL_DEBUG
var/global/list/deletedImageData = new
var/global/list/deletedImageIconStates = new

/image/Del()
	deletedImageData.len++;
	deletedImageData[deletedImageData.len] = "alpha: [src.alpha] blend_mode: [src.blend_mode] color: [src.color], file: [src.icon] icon: \icon[src.icon] icon_state: [src.icon_state] dir: [src.dir] loc: \ref[src.loc] layer: [src.layer] x: [src.x] y: [src.y] z: [src.z] type: [src.type] parent_type: [src.parent_type] tag: [src.tag]"
	deletedImageIconStates[src.icon_state]++

	..()
#endif

#ifdef DELETE_QUEUE_DEBUG
var/global/list/deletedObjects = new

/datum/Del()
	if(!("[src.type]" in deletedObjects))
		deletedObjects["[src.type]"] = 0
	deletedObjects["[src.type]"]++
	..()
#endif

/// called when a variable is admin-edited
/datum/proc/onVarChanged(variable, oldval, newval)

// so we can check if something we have a ref to is pool() or not
/datum/var/pooled = 0

/datum/var/qdeltime = 0
