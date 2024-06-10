///////////////////////
// FLOCKMIND ABILITIES
///////////////////////

/datum/abilityHolder/flockmind
	tabName = "Flockmind"
	usesPoints = TRUE
	points = 0 //total compute - used compute
	var/totalCompute = 0
	var/totalTiles = 0
	regenRate = 0
	topBarRendered = TRUE
	rendered = TRUE
	notEnoughPointsMessage = SPAN_ALERT("Insufficient available compute resources.")
	var/datum/targetable/flockmindAbility/droneControl/drone_controller = null

	New()
		..()
		drone_controller = addAbility(/datum/targetable/flockmindAbility/droneControl)

/datum/abilityHolder/flockmind/proc/updateCompute(usedCompute, totalCompute, forceTextUpdate = FALSE)
	var/mob/living/intangible/flock/F = owner
	if(!F?.flock)
		return //someone made a flockmind or flocktrace without a flock, or gave this ability holder to something else.
	src.points = totalCompute - usedCompute
	src.totalCompute = totalCompute
	if (forceTextUpdate)
		src.updateText()

/datum/abilityHolder/flockmind/proc/updateTiles(totalTiles, forceTextUpdate = FALSE)
	var/mob/living/intangible/flock/F = owner
	if(!F?.flock)
		return //someone made a flockmind or flocktrace without a flock, or gave this ability holder to something else.
	src.totalTiles = totalTiles
	if (forceTextUpdate)
		src.updateText()

/datum/abilityHolder/flockmind/onAbilityStat()
	..()
	.= list()
	.["Compute:"] = "[round(src.points)]/[round(src.totalCompute)]"
	.["Tiles:"] = "[src.totalTiles]"
	var/mob/living/intangible/flock/F = owner
	if (!istype(F) || !F.flock)
		return
	.["Traces:"] = "[length(F.flock.traces)]/[F.flock.max_trace_count]"

/atom/movable/screen/ability/topBar/flockmind
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

/////////////////////////////////////////

/datum/targetable/flockmindAbility
	icon = 'icons/mob/flock_ui.dmi'
	icon_state = "template"
	cooldown = 40
	last_cast = 0
	targeted = TRUE
	target_anything = TRUE
	preferred_holder_type = /datum/abilityHolder/flockmind
	theme = "flock"

/datum/targetable/flockmindAbility/New()
	var/atom/movable/screen/ability/topBar/flockmind/B = new /atom/movable/screen/ability/topBar/flockmind(null)
	B.icon = src.icon
	B.icon_state = src.icon_state
	B.owner = src
	B.name = src.name
	B.desc = src.desc
	src.object = B

/datum/targetable/flockmindAbility/cast(atom/target)
	if (..() || !holder || !holder.owner)
		return TRUE
	return FALSE

/datum/targetable/flockmindAbility/doCooldown()
	if (!holder)
		return
	last_cast = world.time + cooldown
	holder.updateButtons()
	SPAWN(cooldown + 5)
		holder?.updateButtons()

/datum/targetable/flockmindAbility/proc/tutorial_check(id, atom/context, silent = FALSE)
	var/mob/living/intangible/flock/flockmind/flock_owner = src.holder.owner
	if (istype(flock_owner))
		if (flock_owner.tutorial)
			if (silent)
				return flock_owner.tutorial.PerformSilentAction(id, context)
			else
				return flock_owner.tutorial.PerformAction(id, context)
	else if (istype(flock_owner, /mob/living/intangible/flock/trace)) //we are a flocktrace
		if (flock_owner.flock.flockmind.tutorial) //flocktraces can only watch
			return FALSE
	return TRUE
