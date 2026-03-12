
var/list/datum/statusEffect/globalStatusPrototypes = list()
var/list/datum/statusEffect/globalStatusInstances = list()

/// Simple global list of groupname : amount, that tells the system how many effects of a group we can have active at most.
/// See exclusiveGroup. Buffs above the max will not be applied.
var/global/list/statusGroupLimits = list("Food"=4)

/proc/testStatus()
	var/inp = input(usr,"Which status?","Test status","airrit") as text
	SPAWN(0)
		for(var/datum/statusEffect/status as anything in usr.statusEffects)
			usr.delStatus(status)
		usr.changeStatus(inp, 15 MINUTES)


/atom/movable/screen/statusEffect
	name = "Status effect"
	desc = ""
	icon = 'icons/ui/statussystem.dmi'
	icon_state = "statusbg"
	layer = HUD_LAYER+1
	plane = PLANE_HUD

	var/datum/statusEffect/ownerStatus = null
	var/image/overImg = null
	var/mob/living/owner_mob = null

	New()
		overImg = image('icons/ui/statussystem.dmi')

		src.maptext_y = -12
		maptext_width = 16
		maptext_height = 16
		add_filter("outline", 1, outline_filter(size=0.7,color=rgb(0,0,0)))
		add_filter("drop shadow", 2, drop_shadow_filter(size=1.5, color=rgb(0,0,0)))
		..()

	proc/init(mob/living/C, datum/statusEffect/S)
		if(!S) throw "STATUS EFFECT UI INITIALIZED WITHOUT INSTANCE"
		ownerStatus = S
		src.name = S.name
		overImg.icon_state = S.icon_state
		LAZYLISTADD(S.hud_elements, src)
#ifdef SHOW_ME_STATUSES
		src.owner_mob = C
		src.owner_mob.vis_contents |= src
		src.pixel_x = (length(src.owner_mob.statusEffects) - 1) * 16
		src.appearance_flags |= RESET_TRANSFORM
#endif

	disposing()
#ifdef SHOW_ME_STATUSES
		src.owner_mob.vis_contents -= src
		for (var/atom/movable/screen/statusEffect/effect_obj in src.owner_mob?.vis_contents)
			if (effect_obj.pixel_x > src.pixel_x)
				effect_obj.pixel_x -= 16
		src.owner_mob = null
#endif
		LAZYLISTREMOVE(src.ownerStatus.hud_elements, src)
		src.ownerStatus = null
		. = ..()

	clicked(list/params)
		if (ownerStatus)
			ownerStatus.clicked(params)

	MouseEntered(location, control, params)
		if (usr.client.tooltips && ownerStatus)
			usr.client.tooltips.show(
				TOOLTIP_HOVER, src,
				mouse = params,
				title = ownerStatus.name,
				content = ownerStatus.getTooltip() + "<br>[ownerStatus.duration != null ? "[round(ownerStatus.duration/10)] sec.":""]",
				theme = "stamina"
			)

	MouseExited()
		usr.client.tooltips?.hide(TOOLTIP_HOVER)

	proc/update_value()
		if(!ownerStatus)
			return

		src.overlays.Cut()
		overImg.icon_state = ownerStatus.icon_state
		src.overlays += overImg

		if (ownerStatus.duration <= (5 SECONDS) && !isnull(ownerStatus.duration))
			src.alpha = 175
		else
			src.alpha = 255

		var/str = "??"

		if(isnull(ownerStatus.duration)) //Null means infinite.
			str = "*"
		else
			if(ownerStatus.duration >= (1 HOURS)) //Hours
				if(ownerStatus.duration > (10 HOURS)) //10 hours fuck this
					str = "+H"
				else
					str = "[round(ownerStatus.duration / (1 HOURS))]H"
			else if(ownerStatus.duration >= (1 MINUTES)) //1+ min
				if(ownerStatus.duration >= (10 MINUTES)) //10+ min fuck that
					str = "+M"
				else
					str = "[round(ownerStatus.duration / (1 MINUTES))]M"
			else
				if(ownerStatus.duration < (10 SECONDS))
					str = "0[round(ownerStatus.duration / (1 SECOND))]"
				else
					str = "[round(ownerStatus.duration / (1 SECOND))]"

		maptext = "<text align=center><FONT FACE=Arial COLOR=white SIZE=1>[str]</FONT></text>"

/* BASE PROCS */

/// List of status effects
/atom/var/list/datum/statusEffect/statusEffects = null
/atom/var/list/statusLimits //only instantiated if we actually need it

/// Stub. Override for objects that need to update their ui with status effect information.
/atom/proc/updateStatusUi()

/**
	* If atom has status with {statusId}, change by {duration}.
	*
	* (The change is relative to the current value, think +=)
	* If atom does not have status, add it with given {duration}.
	* In both cases {optional} will be passed into either .onAdd or .onChange on the status effect. Useful for custom behaviour.
	*
	* * Returns: The changed/added status effect or null on errors.
	*/
/atom/proc/changeStatus(statusId, duration, optional)
	. = null
	var/datum/statusEffect/globalInstance = null
	for(var/datum/statusEffect/status as anything in globalStatusPrototypes)
		if(status.id == statusId)
			globalInstance = status
			break

	if(!globalInstance)
		throw EXCEPTION("Unknown status type passed: [statusId]")
		return

	if(!globalInstance.preCheck(src))
		return

	if(hasStatus(statusId))
		var/datum/statusEffect/S = hasStatus(statusId)
		setStatus(statusId, (isnull(S.maxDuration) ? (S.duration + duration):(min(S.duration + duration, S.maxDuration))), optional)
		return S
	else
		if(isnull(duration) || duration > 0)
			return setStatus(statusId, (isnull(globalInstance.maxDuration) ? (duration):(min(duration, globalInstance.maxDuration))), optional)

/**
	* If atom has status with {statusId}, set it to {duration}.
	*
	* (The change is absolute, think =)
	*
	* If atom does not have status, add it with given {duration}.
	*
	* In both cases {optional} will be passed into either .onAdd or .onChange on the status effect. Useful for custom behaviour.
	*
	* * Returns: The changed/added status effect or null on errors.
	*/
/atom/proc/setStatus(statusId, duration, optional)
	if(statusEffects == null) statusEffects = list()

	var/datum/statusEffect/globalInstance = null
	for(var/datum/statusEffect/status as anything in globalStatusPrototypes)
		if(status.id == statusId)
			globalInstance = status
			break

	if(!isnull(globalInstance))
		if(!globalInstance.preCheck(src))
			return null

		var/groupFull = 0
		var/groupCount = 0
		var/list/groupLimits = (length(src.statusLimits) ? src.statusLimits | statusGroupLimits : statusGroupLimits)
		if(globalInstance.exclusiveGroup != "" && groupLimits.Find(globalInstance.exclusiveGroup))
			for(var/datum/statusEffect/status as anything in statusEffects)
				if(status.exclusiveGroup == globalInstance.exclusiveGroup && status.id != statusId)
					groupCount++
			if(groupCount >= groupLimits[globalInstance.exclusiveGroup])
				groupFull = 1

		if(globalInstance.unique) //unique, easy.
			if(hasStatus(statusId))
				//Update it
				if(duration > 0 || isnull(duration))
					var/datum/statusEffect/localInstance = hasStatus(statusId)
					if (duration)
						duration = localInstance.duration + localInstance.modify_change(duration - localInstance.duration)
					localInstance.duration = (isnull(localInstance.maxDuration) ? (duration):(min(duration, localInstance.maxDuration)))
					localInstance.onChange(optional)
					src.updateStatusUi()
					return localInstance
				else
					delStatus(statusId)
			else
				if((duration > 0 || isnull(duration)) && !groupFull)
					//Add it
					var/datum/statusEffect/localInstance = new globalInstance.type()
					localInstance.owner = src
					if (duration)
						duration = localInstance.duration + localInstance.modify_change(duration - localInstance.duration)
						if (duration <= 0) //if we ended up reducing it to or past 0, just clear it without ever applying
							localInstance.owner = null
							return null
					localInstance.duration = (isnull(localInstance.maxDuration) ? (duration):(min(duration, localInstance.maxDuration)))
					localInstance.archivedOwnerInfo = "OwnerName:[src.name] - OwnerType:[src.type] - ContLen:[src.contents.len] - StatusLen:[src.statusEffects.len]"
					localInstance.onAdd(optional)
					statusEffects |= localInstance
					globalStatusInstances |= localInstance
					src.updateStatusUi()
					return localInstance
				else
					return null
		else
			//Not unique, no changing it. Only adding supported.
			//Add it
			if((duration > 0 || isnull(duration)) && !groupFull)
				var/datum/statusEffect/localInstance = new globalInstance.type()
				localInstance.owner = src

				if (duration)
					duration = localInstance.duration + localInstance.modify_change(duration - localInstance.duration)
					if (duration <= 0) //if we ended up reducing it to 0, just clear it without ever applying
						localInstance.owner = null
						return null

				localInstance.duration = (isnull(localInstance.maxDuration) ? (duration):(min(duration, localInstance.maxDuration)))
				localInstance.archivedOwnerInfo = "OwnerName:[src.name] - OwnerType:[src.type] - ContLen:[src.contents.len] - StatusLen:[src.statusEffects.len]"
				localInstance.onAdd(optional)
				statusEffects |= localInstance
				globalStatusInstances |= localInstance
				src.updateStatusUi()
				return localInstance
			else
				return null
	else
		throw EXCEPTION("Unknown status type passed: [statusId]")
		return null

// Sets the status duration of the passed statusId to the larger of the existing status of that ID and the passed {maxDuration}
/atom/proc/setStatusMin(statusId, minDuration, optional) //this is probably inefficient
	src.setStatus(statusId, max(src.getStatusDuration(statusId), minDuration), optional)

/**
	* Returns duration of status with given {statusId}, or null if not found.
	*/
/atom/proc/getStatusDuration(statusId)
	.= null
	if(statusEffects)
		for(var/datum/statusEffect/status as anything in statusEffects) //dont typecheck as we loop through StatusEffects - Assume everything inside must be a statuseffect
			if(status.id == statusId)
				. = status.duration
				break

/**
 	* Returns prototype of status effect from the globalStatusPrototypes list with given {statusId}, or null if not found
	*/
/atom/proc/getStatusPrototype(statusId)
	for(var/datum/statusEffect/status as anything in globalStatusPrototypes)
		var/datum/statusEffect/statuseffect = status
		if(statuseffect.id == statusId)
			return statuseffect
/**
	* Returns first status with given {statusId} or null if not found.
	*
	* {optionalArgs} can be passed in for additional checks that are handled in the effects .onCheck proc.
	* Useful if you want to check some custom conditions on status effects.
	*/
/atom/proc/hasStatus(statusId, optionalArgs = null)
	if(statusEffects)
		if (!islist(statusId))
			for(var/datum/statusEffect/status as anything in statusEffects) //dont typecheck as we loop through StatusEffects - Assume everything inside must be a statuseffect
				if(status.id == statusId && ((optionalArgs && status.onCheck(optionalArgs)) || (!optionalArgs)))
					return status
		else
			var/list/idlist = statusId
			for(var/datum/statusEffect/status as anything in statusEffects)
				if((status.id in idlist) && ((optionalArgs && status.onCheck(optionalArgs)) || (!optionalArgs)))
					return status

/**
	* Returns a list of all the datum/statusEffect on source atom.
	*
	* {statusId} optional status ID to match, otherwise matches any status type
	* {optionalArgs} can be passed in for additional checks that are handled in the effects .onCheck proc.
	* Useful if you want to check some custom conditions on status effects.
	*/
/atom/proc/getStatusList(statusId = null, optionalArgs = null)
	. = list()
	if (statusEffects)
		for(var/datum/statusEffect/status as anything in statusEffects)
			if( (!optionalArgs || status.onCheck(optionalArgs)) && (!statusId || (statusId == status.id)) )
				.[status.id] = status

/**
	* Deletes the given status from the atom.
	*
	* {status} can either be a reference to a status effect or a status effect ID.
	*/
/atom/proc/delStatus(status)
	. = null
	if(statusEffects == null)
		return

	if(istext(status)) //ID was passed in.
		for(var/datum/statusEffect/statcurr as anything in statusEffects)
			if(statcurr.id == status)
				globalStatusInstances -= statcurr
				statusEffects -= statcurr
				statcurr.onRemove()
	else if(istype(status, /datum/statusEffect)) //Instance was passed in.
		var/datum/statusEffect/S = status
		if(S in statusEffects)
			globalStatusInstances -= S
			statusEffects -= S
			S.onRemove()

	src.updateStatusUi()
