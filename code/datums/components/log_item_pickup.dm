/datum/component/log_item_pickup
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/authorized_job = null
	var/message_admins_too = FALSE

TYPEINFO(/datum/component/log_item_pickup)
	initialization_args = list(
		ARG_INFO("authorized_job", DATA_INPUT_TEXT, "Job to ignore?", null),
		ARG_INFO("message_admins_too", DATA_INPUT_BOOL, "Message admins too?", FALSE)
	)

/datum/component/log_item_pickup/Initialize(authorized_job=null, message_admins_too=FALSE)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.authorized_job = authorized_job
	src.message_admins_too = message_admins_too
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/logging)

/datum/component/log_item_pickup/proc/logging(atom/movable/thing, mob/user)
	var/obj/item/I = src.parent
	if(authorized_job)
		if(user.job != authorized_job)
			logTheThing(LOG_STATION, user, "is the first non-[authorized_job] to pick up [I] at [log_loc(I)]")
			if(message_admins_too)
				message_admins("[key_name(user)] is the first non-[authorized_job] to pick up \the [I] at [log_loc(I)]")
			src.RemoveComponent()
	else
		logTheThing(LOG_STATION, user, "is the first to pick up [I] at [log_loc(I)]")
		if(message_admins_too)
			message_admins("[key_name(user)] is the first to pick up \the [I] at [log_loc(I)]")
		src.RemoveComponent()


/datum/component/log_item_pickup/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKHAND)
	. = ..()
