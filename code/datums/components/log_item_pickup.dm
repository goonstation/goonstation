/datum/component/log_item_pickup
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/first_time_only = TRUE
	var/authorized_job = null
	var/message_admins_too = FALSE
	var/mob/last_mob = null

TYPEINFO(/datum/component/log_item_pickup)
	initialization_args = list(
		ARG_INFO("first_time_only", DATA_INPUT_BOOL, "First pickup only?", TRUE),
		ARG_INFO("authorized_job", DATA_INPUT_TEXT, "Job to ignore?", null),
		ARG_INFO("message_admins_too", DATA_INPUT_BOOL, "Message admins too? May spam if not first pickup only!", FALSE)
	)

/datum/component/log_item_pickup/Initialize(first_time_only=TRUE, authorized_job=null, message_admins_too=FALSE)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.first_time_only = first_time_only
	src.authorized_job = authorized_job
	src.message_admins_too = message_admins_too
	RegisterSignal(parent, COMSIG_ATTACKHAND, PROC_REF(logging))

/datum/component/log_item_pickup/proc/logging(atom/movable/thing, mob/user)
	var/obj/item/I = src.parent
	if (last_mob == user)
		return
	last_mob = user
	if(authorized_job)
		if(user.job != authorized_job)
			logTheThing(LOG_STATION, user, "[first_time_only ? "is the first non-[authorized_job] to pick up " : " is non-[authorized_job] and picked up "] [log_object(I)] at [log_loc(I)]")
			if(message_admins_too)
				message_admins("[key_name(user)] [first_time_only ? " is the first non-[authorized_job] to pick up " : " is non-[authorized_job] and picked up "] \the [log_object(I)] at [log_loc(I)]")
			if (first_time_only)
				src.RemoveComponent()
	else
		logTheThing(LOG_STATION, user, "[first_time_only ? "is the first to pick up " : " picked up "] [log_object(I)] at [log_loc(I)]")
		if(message_admins_too)
			message_admins("[key_name(user)] [first_time_only ? " is the first to pick up " : " picked up "] \the [log_object(I)] at [log_loc(I)]")
		if (first_time_only)
			src.RemoveComponent()


/datum/component/log_item_pickup/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKHAND)
	. = ..()
