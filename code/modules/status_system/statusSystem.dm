/*
-- atom.changeStatus(statusId, duration, optional)
If atom has status with [statusId], change by [duration]. (The change is relative to the current value, think +=)
If atom does not have status, add it with given [duration].
In both cases [optional] will be passed into either .onAdd or .onChange on the status effect. Useful for custom behaviour.
Returns: The changed/added status effect or null on errors.

-- atom.setStatus(statusId, duration, optional)
If atom has status with [statusId], set it to [duration]. (The change is absolute, think =)
If atom does not have status, add it with given [duration].
In both cases [optional] will be passed into either .onAdd or .onChange on the status effect. Useful for custom behaviour.
Returns: The changed/added status effect or null on errors.

-- atom.getStatusDuration(statusId)
Returns duration of status with given [statusId], or null if not found.

-- atom.hasStatus(statusId, optionalArgs = null)
Returns first status with given [statusId] or null if not found.
[optionalArgs] can be passed in for additional checks that are handled in the effects .onCheck proc. Useful if you want to check some custom conditions on status effects

-- atom.delStatus(var/status)
Deletes the given status from the atom.
[status] can either be a reference to a status effect or a status effect ID.

Additional notes:
Non-unique status effects (effects that can be applied several times to the same atom) can not be changed by normal means after they are added. Keep a reference if you need to change them.
Status effect procs have comments in their base definition below. Check there if you want to know more about what they do.
Status effects with a duration of INFINITE_STATUS (null) last indefinitely. (Shows as a duration of * in the UI) ((Keep in mind that null is distinct from 0))
*/

var/list/globalStatusPrototypes = list()
var/list/globalStatusInstances = list()

//Simple global list of groupname : amount, that tells the system how many effects of a group we can have active at most. See exclusiveGroup. Buffs above the max will not be applied.
var/list/statusGroupLimits = list("Food"=4)

/proc/testStatus()
	var/inp = input(usr,"Which status?","Test status","airrit") as text
	SPAWN_DBG(0)
		for(var/datum/statusEffect/status in usr.statusEffects)
			usr.delStatus(status)
		usr.changeStatus(inp, 15 MINUTES)
	return

/obj/screen/statusEffect
	name = "Status effect"
	desc = ""
	icon = 'icons/ui/statussystem.dmi'
	icon_state = "statusbg"
	layer = HUD_LAYER+1
	plane = PLANE_HUD

	var/datum/statusEffect/ownerStatus = null
	var/image/overImg = null

	New()
		overImg = image('icons/ui/statussystem.dmi')

		src.maptext_y = -12
		maptext_width = 16
		maptext_height = 16
		//filters += filter(type="outline", size=1, color="#000000")
		filters += filter(type="outline", size=0.7,color=rgb(0,0,0))
		filters += filter(type="drop_shadow", size=1.5, color=rgb(0,0,0))
		..()

	proc/init(var/mob/living/C, var/datum/statusEffect/S)
		if(!S) throw "STATUS EFFECT UI INITIALIZED WITHOUT INSTANCE"
		ownerStatus = S
		src.name = S.name
		overImg.icon_state = S.icon_state

	pooled()
		src.name = "null"
		ownerStatus = 0
		..()

	clicked(list/params)
		if (ownerStatus)
			ownerStatus.clicked(params)

	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && ownerStatus)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = ownerStatus.name,
				"content" = ownerStatus.getTooltip() + "<br>[ownerStatus.duration != null ? "[round(ownerStatus.duration/10)] sec.":""]",
				"theme" = "stamina"
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

	proc/update_value()
		if(!ownerStatus)
			return

		src.overlays.Cut()
		overImg.icon_state = ownerStatus.icon_state
		src.overlays += overImg

		if (ownerStatus.duration <= 50 && !isnull(ownerStatus.duration))
			src.alpha = 175
		else
			src.alpha = 255

		var/str = "??"

		if(isnull(ownerStatus.duration)) //Null means infinite.
			str = "*"
		else
			if(ownerStatus.duration >= 1 HOURS) //Hours
				if(ownerStatus.duration > 10 HOURS) //10 hours fuck this
					str = "+H"
				else
					str = "[round(ownerStatus.duration / (1 HOURS))]H"
			else if(ownerStatus.duration >= 1 MINUTES) //1+ min
				if(ownerStatus.duration >= 10 MINUTES) //10+ min fuck that
					str = "+M"
				else
					str = "[round(ownerStatus.duration / (1 MINUTES))]M"
			else
				if(ownerStatus.duration < 10 SECONDS)
					str = "0[round(ownerStatus.duration / (1 SECOND))]"
				else
					str = "[round(ownerStatus.duration / (1 SECOND))]"

		maptext = "<text align=center><FONT FACE=Arial COLOR=white SIZE=1>[str]</FONT></text>"
		return


/atom
	var/list/statusEffects = null //List of status effects.
	var/list/statusLimits //only instantiated if we actually need it

	proc/updateStatusUi() //Stub. Override for objects that need to update their ui with status information.
		return

	proc/changeStatus(statusId, duration, optional)
		var/datum/statusEffect/globalInstance = null
		for(var/datum/statusEffect/status in globalStatusPrototypes)
			if(status.id == statusId)
				globalInstance = status
				break

		if(!globalInstance)
			throw EXCEPTION("Unknown status type passed: [statusId]")
			return null

		if(!globalInstance.preCheck(src)) return null

		if(hasStatus(statusId))
			var/datum/statusEffect/S = hasStatus(statusId)
			setStatus(statusId, (isnull(S.maxDuration) ? (S.duration + duration):(min(S.duration + duration, S.maxDuration))), optional)
			return S
		else
			if(duration > 0)
				return setStatus(statusId, (isnull(globalInstance.maxDuration) ? (duration):(min(duration, globalInstance.maxDuration))), optional)

		return null

	proc/setStatus(statusId, duration, optional)
		if(statusEffects == null) statusEffects = list()

		var/datum/statusEffect/globalInstance = null
		for(var/datum/statusEffect/status in globalStatusPrototypes)
			if(status.id == statusId)
				globalInstance = status
				break

		if(globalInstance != null)
			if(!globalInstance.preCheck(src)) return null

			var/groupFull = 0
			var/groupCount = 0
			var/list/groupLimits = (length(src.statusLimits) ? src.statusLimits | statusGroupLimits : statusGroupLimits)
			if(globalInstance.exclusiveGroup != "" && groupLimits.Find(globalInstance.exclusiveGroup))
				for(var/datum/statusEffect/status in statusEffects)
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
							if (!duration) //if we ended up reducing it to 0, just clear it without ever applying
								localInstance.owner = null
								return null
						localInstance.duration = (isnull(localInstance.maxDuration) ? (duration):(min(duration, localInstance.maxDuration)))
						localInstance.archivedOwnerInfo = "OwnerName:[src.name] - OwnerType:[src.type] - ContLen:[src.contents.len] - StatusLen:[src.statusEffects.len]"
						localInstance.onAdd(optional)
						if(!statusEffects.Find(localInstance)) statusEffects.Add(localInstance)
						if(!globalStatusInstances.Find(localInstance)) globalStatusInstances.Add(localInstance)
						src.updateStatusUi()
						return localInstance
					else return null
			else
				//Not unique, no changing it. Only adding supported.
				//Add it
				if((duration > 0 || isnull(duration)) && !groupFull)
					var/datum/statusEffect/localInstance = new globalInstance.type()
					localInstance.owner = src
					if (duration)
						duration = localInstance.duration + localInstance.modify_change(duration - localInstance.duration)
						if (!duration) //if we ended up reducing it to 0, just clear it without ever applying
							localInstance.owner = null
							return null

					localInstance.duration = (isnull(localInstance.maxDuration) ? (duration):(min(duration, localInstance.maxDuration)))
					localInstance.archivedOwnerInfo = "OwnerName:[src.name] - OwnerType:[src.type] - ContLen:[src.contents.len] - StatusLen:[src.statusEffects.len]"
					localInstance.onAdd(optional)
					if(!statusEffects.Find(localInstance)) statusEffects.Add(localInstance)
					if(!globalStatusInstances.Find(localInstance)) globalStatusInstances.Add(localInstance)
					src.updateStatusUi()
					return localInstance
				else return null
		else
			throw EXCEPTION("Unknown status type passed: [statusId]")
			return null

	proc/getStatusDuration(statusId)
		.= null
		if(statusEffects)
			var/datum/statusEffect/status = 0
			for(var/S in statusEffects) //dont typecheck as we loop through StatusEffects - Assume everything inside must be a statuseffect
				status = S
				if(status.id == statusId)
					.= status.duration
					break

	proc/hasStatus(statusId, optionalArgs = null)
		if(statusEffects)
			if (!islist(statusId))
				var/datum/statusEffect/status
				for(var/S in statusEffects) //dont typecheck as we loop through StatusEffects - Assume everything inside must be a statuseffect
					status = S
					if(status.id == statusId && ((optionalArgs && status.onCheck(optionalArgs)) || (!optionalArgs)))
						return status
			else
				var/list/idlist = statusId
				var/datum/statusEffect/status
				for(var/S in statusEffects)
					status = S
					if((status.id in idlist) && ((optionalArgs && status.onCheck(optionalArgs)) || (!optionalArgs)))
						return status

	proc/getStatusList(optionalArgs = null)
		. = list()
		if (statusEffects)
			var/datum/statusEffect/status
			for(var/S in statusEffects)
				status = S
				if((optionalArgs && status.onCheck(optionalArgs)) || (!optionalArgs))
					.[status.id] = status

	proc/delStatus(var/status)
		if(statusEffects == null)
			return null

		if(istext(status)) //ID was passed in.
			for(var/datum/statusEffect/statcurr in statusEffects)
				if(statcurr.id == status)
					if(globalStatusInstances.Find(statcurr)) globalStatusInstances.Remove(statcurr)
					statusEffects.Remove(statcurr)
					statcurr.onRemove()
		else if(istype(status, /datum/statusEffect)) //Instance was passed in.
			if(statusEffects.Find(status))
				if(globalStatusInstances.Find(status)) globalStatusInstances.Remove(status)
				statusEffects.Remove(status)
				var/datum/statusEffect/S = status
				S.onRemove()

		src.updateStatusUi()

		return null

/datum/statusEffect
	var/id = ""
	var/name = ""
	var/icon_state = ""
	var/desc = ""		//Tooltip desc
	var/duration = 0 //In deciseconds (tenths of a second, same as ticks just sane). A duration of NULL is infinite. (This is distinct from 0)
	var/atom/owner = null //Owner of the status effect
	var/archivedOwnerInfo = ""
	var/unique = 1 //If true, this status effect can only have one instance on any given object.
	var/visible = 1 //Is this visible in the status effect bar?
	var/exclusiveGroup = "" //optional name of a group of buffs. players can only have a certain number of buffs of a given group - any new applications fail. useful for food buffs etc.
	var/maxDuration = null //If non-null, duration of the effect will be clamped to be max. this amount.
	var/move_triggered = 0 //has an on-move effect
	var/datum/movement_modifier/movement_modifier // Has a movement-modifying effect


	proc/preCheck(var/atom/A) //Used to run a custom check before adding status to an object. For when you want something to be flat out immune or something. ret = 1 allow, 0 = do not allow
		return 1

	proc/modify_change(var/change)
		.= change

	proc/onAdd(var/optional=null) //Called when the status is added to an object. owner is already set at this point. Has the optional arg from setStatus passed in.
		if (movement_modifier && ismob(owner))
			var/mob/mob_owner = owner
			APPLY_MOVEMENT_MODIFIER(mob_owner, movement_modifier, src.type)
		return

	proc/onRemove() //Called when the status is removed from the object. owner is still set at this point.
		if (movement_modifier && ismob(owner))
			var/mob/mob_owner = owner
			REMOVE_MOVEMENT_MODIFIER(mob_owner, movement_modifier, src.type)
		return

	proc/onUpdate(var/timedPassed) //Called every tick by the status controller. Argument is the actual time since the last update call.
		return

	proc/onChange(var/optional=null) //Called when the status is changed using setStatus. Called after duration is updated etc. Has the optional arg from setStatus passed in.
		return

	proc/onCheck(var/optional=null) //Called by hasStatus. Used to handle additional checks with the optional arg in that proc.
		return 1

	proc/getTooltip() //Used to generate tooltip. Can be changed to have dynamic tooltips.
		return desc

	proc/getExamine() //Information that should show up when an object has this effect and is examined.
		return null

	proc/clicked(list/params)
		.= 0

	proc/move_trigger(var/mob/user, var/ev)
		.=0

	disposing()
		if (owner)
			owner.statusEffects -= src
		src.owner = null
		..()

	defibbed
		id = "defibbed"
		name = "Defibrillated"
		desc = "You've been zapped in a way your heart seems to like."
		icon_state = "heart+"
		unique = 1
		maxDuration = 12 SECONDS // Just slightly longer than a defib's charge cycle

		getTooltip()
			return "You've been zapped in a way your heart seems to like!<br>You feel more resistant to cardiac arrest, and more likely for subsequent defibrillating shocks to restart your heart if it stops!"

	maxhealth
		id = "maxhealth"
		name = ""
		desc = ""
		icon_state = ""
		unique = 1
		var/change = 1 //Effective change to maxHealth

		onAdd(var/optional=null) //Optional is change.
			if(ismob(owner) && optional != 0)
				var/mob/M = owner
				change = optional
				M.max_health += change
				health_update_queue |= M
			return

		onRemove()
			if(ismob(owner))
				var/mob/M = owner
				M.max_health -= change
				health_update_queue |= M
			return

		onUpdate(var/timedPassed)
			icon_state = "[change > 0 ? "heart+":"heart-"]"
			name = "Max. health [change > 0 ? "increased":"reduced"]"
			return

		//causes max health to stack up to thousands on repeat calls
		//THEN DONT REPEATEDLY CALL IT. Don't just comment shit out. The value can't be changed without this. I've changed it to make the change value absolute.
		onChange(var/optional=null)
			if(ismob(owner) && optional != 0)
				var/mob/M = owner
				M.max_health -= change
				change = optional
				M.max_health += change
				health_update_queue |= M
			return

		getTooltip()
			return "Your max. health has been [change > 0 ? "increased":"reduced"] by [abs(change)]."

		//Technically the base class can handle either but we need to separate these.
		increased
			id = "maxhealth+"
			onUpdate(var/timedPassed)
				if(change < 0) //Someone fucked this up; remove effect.
					duration = 1
				return ..(timedPassed)

		decreased
			id = "maxhealth-"
			onUpdate(var/timedPassed)
				if(change > 0) //Someone fucked this up; remove effect.
					duration = 1
				return ..(timedPassed)

	simplehot //Simple heal over time.
		var/tickCount = 0
		var/tickSpacing = 1 SECOND //Time between ticks.
		var/heal_brute = 0
		var/heal_tox = 0
		var/heal_burn = 0
		icon_state = "+"

		onUpdate(var/timedPassed)
			tickCount += timedPassed
			var/times = (tickCount / tickSpacing)
			if(times >= 1 && ismob(owner))
				tickCount -= (round(times) * tickSpacing)
				for(var/i = 0, i < times, i++)
					var/mob/M = owner
					M.HealDamage("All", heal_brute, heal_burn, heal_tox)
			return

	simpledot //Simple damage over time.
		var/tickCount = 0
		var/tickSpacing = 1 SECOND //Time between ticks.
		var/damage_brute = 0
		var/damage_tox = 0
		var/damage_burn = 0
		var/damage_type = DAMAGE_STAB
		icon_state = "-"

		onUpdate(var/timedPassed)
			tickCount += timedPassed
			var/times = (tickCount / tickSpacing)
			if(times >= 1 && ismob(owner))
				tickCount -= (round(times) * tickSpacing)
				for(var/i = 0, i < times, i++)
					var/mob/M = owner
					M.TakeDamage("All", damage_brute, damage_burn, damage_tox, damage_type)
			return

	simpledot/radiation
		id = "radiation"
		name = "Irradiated"
		desc = ""
		icon_state = "radiation1"
		unique = 1

		tickSpacing = 3 SECONDS

		damage_tox = 1
		damage_type = DAMAGE_BURN

		var/howMuch = ""
		var/stage = 0
		var/counter = 0
		var/stageTime = 10 SECONDS

		getTooltip()
			return "You are [howMuch]irradiated.<br>Taking [damage_tox] toxin damage every [tickSpacing/10] sec.<br>Damage reduced by radiation resistance on gear."

		preCheck(var/atom/A)
			if(issilicon(A) || isobserver(A) || isintangible(A)) return 0
			return 1

		onAdd(var/optional=null)
			if(!isnull(optional) && optional >= stage)
				stage = optional
			else
				stage = 5
			icon_state = "radiation[stage]"
			return

		onChange(var/optional=null)
			if(!isnull(optional) && optional >= stage)
				stage = optional
			else
				stage = 5
			icon_state = "radiation[stage]"
			return

		onUpdate(var/timedPassed)
			counter += timedPassed
			if(counter >= stageTime)
				counter -= stageTime
				stage = max(stage-1, 1)

			var/prot = 1
			if(istype(owner, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner
				prot = (1 - (H.get_rad_protection() / 100))

			switch(stage)
				if(1)
					damage_tox = (1 * prot)
					howMuch = ""

				if(2)
					damage_tox = (2 * prot)
					howMuch = "significantly "
					var/chance = (2 * prot)
					if(prob(chance) && ismob(owner))
						var/mob/M = owner
						if (M.bioHolder && !M.bioHolder.HasEffect("revenant"))
							M.changeStatus("weakened", 3 SECONDS)
							boutput(M, "<span class='alert'>You feel weak.</span>")
							M.emote("collapse")
				if(3)
					damage_tox = (3 * prot)
					howMuch = "very much "
					if (ismob(owner))
						var/mob/M = owner
						var/mutChance = (1 * prot)

						if (M.traitHolder && M.traitHolder.hasTrait("stablegenes"))
							mutChance = 0
						if (mutChance < 1) mutChance = 0

						if (prob(mutChance) && (M.bioHolder && !M.bioHolder.HasEffect("revenant")))
							boutput(M, "<span class='alert'>You mutate!</span>")
							M:bioHolder:RandomEffect("either")
				if(4)
					damage_tox = (4 * prot)
					howMuch = "extremely "
					if (ismob(owner))
						var/mob/M = owner
						var/mutChance = (2 * prot)

						if (M.traitHolder && M.traitHolder.hasTrait("stablegenes"))
							mutChance = (1 * prot)
						if (mutChance < 1) mutChance = 0

						if (prob(mutChance) && (M.bioHolder && !M.bioHolder.HasEffect("revenant")))
							boutput(M, "<span class='alert'>You mutate!</span>")
							M:bioHolder:RandomEffect("either")
				if(5)
					damage_tox = (4.5 * prot)
					howMuch = "horribly "
					if (ismob(owner))
						var/mob/M = owner
						var/mutChance = (3 * prot)

						if (M.traitHolder && M.traitHolder.hasTrait("stablegenes"))
							mutChance = (2 * prot)
						if (mutChance < 1) mutChance = 0

						if (prob(mutChance) && (M.bioHolder && !M.bioHolder.HasEffect("revenant")))
							boutput(M, "<span class='alert'>You mutate!</span>")
							M:bioHolder:RandomEffect("either")

			icon_state = "radiation[stage]"

			return ..(timedPassed)

	simpledot/n_radiation
		id = "neutron_radiation"
		name = "Neutron Irradiated"
		desc = ""
		icon_state = "radiation1"
		unique = 1

		tickSpacing = 1.5 SECONDS

		damage_tox = 2
		damage_brute = 2
		damage_type = DAMAGE_STAB | DAMAGE_BURN

		var/howMuch = ""
		var/stage = 0
		var/counter = 0
		var/stageTime = 10 SECONDS

		getTooltip()
			return "You are [howMuch]irradiated by neutrons.<br>Taking [damage_tox] toxin damage every [tickSpacing/10] sec and [damage_brute] brute damage every [tickSpacing/10] sec."

		preCheck(var/atom/A)
			if(isobserver(A) || isintangible(A)) return 0
			return 1

		onAdd(var/optional=null)
			if(!isnull(optional) && optional >= stage)
				stage = optional
			else
				stage = 5
			icon_state = "radiation[stage]"
			return

		onChange(var/optional=null)
			if(!isnull(optional) && optional >= stage)
				stage = optional
			else
				stage = 5
			icon_state = "radiation[stage]"
			return

		onUpdate(var/timedPassed)
			counter += timedPassed
			if(counter >= stageTime)
				counter -= stageTime
				stage = max(stage-1, 1)

			var/prot = 1
			if(istype(owner, /mob/living/carbon/human))
				prot = (1 - (0 / 100))

			switch(stage)
				if(1)
					damage_tox = (1 * prot)
					damage_brute = (1 * prot)
					howMuch = ""

				if(2)
					damage_tox = (2 * prot)
					damage_brute = (2 * prot)
					howMuch = "significantly "

				if(3)
					damage_tox = (3 * prot)
					damage_brute = (3 * prot)
					howMuch = "very much "

				if(4)
					damage_tox = (4 * prot)
					damage_brute = (4 * prot)
					howMuch = "extremely "

				if(5)
					damage_tox = (5 * prot)
					damage_brute = (5 * prot)
					howMuch = "horribly "

			icon_state = "radiation[stage]"

			return ..(timedPassed)

	simpledot/burning
		id = "burning"
		name = "Burning"
		desc = ""
		icon_state = "fire1"
		unique = 1
		maxDuration = 100 SECONDS

		damage_burn = 1
		damage_type = DAMAGE_BURN

		var/howMuch = ""
		var/stage = -1
		var/counter = 1

		var/mob/living/carbon/human/H
		var/image/onfire = null

		getTooltip()
			return "You are [howMuch]on fire.<br>Taking [damage_burn] burn damage every [tickSpacing/10] sec.<br>Damage reduced by heat resistance on gear. Click this statuseffect to resist."

		clicked(list/params)
			if (H)
				H.resist()

		preCheck(var/atom/A)
			if(issilicon(A)) return 0
			return 1

		onAdd(var/optional = BURNING_LV1)
			if(!isnull(optional) && optional >= stage)
				counter = optional

			switchStage(getStage())

			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				L.update_burning_icon(0, src) // pass in src because technically our owner does not have us as a status effect yet (this happens immediately after onAdd())

				if (ishuman(owner))
					H = owner
			else
				onfire = image('icons/effects/effects.dmi', null, EFFECTS_LAYER_1)
				onfire.icon_state = "onfire[getStage()]"
				onfire.filters += filter(type="alpha", icon=icon(owner.icon, owner.icon_state))
				owner.UpdateOverlays(onfire, "onfire")

			return

		onChange(var/optional = BURNING_LV1)
			if(!isnull(optional) && optional >= stage)
				counter = optional
				switchStage(getStage())
			return

		onRemove()
			if(!owner) return //owner got in our del queue
			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				L.update_burning_icon(1)
			else
				owner.UpdateOverlays(null, "onfire")
			return

		proc/getStage()
			if(counter < BURNING_LV2)
				return 1
			else if (counter >= BURNING_LV2 && counter < BURNING_LV3)
				return 2
			else if (counter >= BURNING_LV3)
				return 3
			return 1

		proc/switchStage(var/toStage)
			if(stage != toStage)
				stage = toStage
				switch(stage)
					if(1) icon_state = "fire1"
					if(2) icon_state = "fire2"
					if(3) icon_state = "fire3"
				if(istype(owner, /mob/living))
					var/mob/living/L = owner
					L.update_burning_icon()
				else
					onfire.icon_state = "onfire[getStage()]"
					owner.UpdateOverlays(onfire, "onfire")
			return

		move_trigger(var/mob/user, var/ev)
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (ev == "run" || ev == "walk")
					H.resist()
					.=1
			.=0

		onUpdate(var/timedPassed)

			counter += timedPassed
			switchStage(getStage())

			var/prot = 1
			if(istype(owner, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner
				prot = (1 - (H.get_heat_protection() / 100))

			if(ismob(owner) && owner:is_heat_resistant())
				prot = 0

			switch(stage)
				if(1)
					damage_burn = 0.9 * prot
					howMuch = ""
				if(2)
					damage_burn = 2 * prot
					howMuch = "very much "
				if(3)
					damage_burn = 3.5 * prot
					howMuch = "extremely "

			return ..(timedPassed)

	stuns
		modify_change(var/change)
			. = change

			if (owner && ismob(owner) && change > 0)
				var/mob/M = owner
				var/percent_protection = M.get_stun_resist_mod()
				percent_protection = 1 - (percent_protection/100) //scale from 0 to 1
				. *= percent_protection

		onRemove()
			..()
			if(!owner) return
			if (!owner.hasStatus(list("stunned", "weakened", "paralysis", "pinned")))
				if (isliving(owner))
					var/mob/living/L = owner
					L.force_laydown_standup()

		stunned
			id = "stunned"
			name = "Stunned"
			desc = "You are stunned.<br>Unable to take any actions."
			icon_state = "stunned"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(var/optional=null)
				. = ..()
				if (ismob(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

		weakened
			id = "weakened"
			name = "Knocked-down"
			desc = "You are knocked-down.<br>Unable to take any actions, prone."
			icon_state = "weakened"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(var/optional=null)
				. = ..()
				if (ismob(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

			pinned
				id = "pinned"
				name = "Pinned"
				desc = "You are pinned. Click this status effect to resist.<br>Unable to take any actions, prone."
				icon_state = "pin"
				unique = 1
				maxDuration = null
				move_triggered = 1

				move_trigger(var/mob/user, var/ev)
					.=0
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						H.resist()
						.=1


				clicked(list/params)
					if (ishuman(owner))
						var/mob/living/carbon/human/H = owner
						H.resist()

				onUpdate()
					if (ismob(owner))
						var/mob/M = owner
						var/found = 0
						if (M.grabbed_by)
							for (var/obj/item/grab/G in M.grabbed_by)
								if (G.state == GRAB_PIN)
									found = 1
						if (!found)
							owner.delStatus("pinned")

						.=..()



		paralysis
			id = "paralysis"
			name = "Unconscious"
			desc = "You are unconscious.<br>Unable to take any actions, blinded."
			icon_state = "paralysis"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(var/optional=null)
				. = ..()
				if (ismob(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

		dormant
			id = "dormant"
			name = "Dormant"
			desc = "You are dormant.<br>Unable to take any actions, until you power yourself."
			icon_state = "paralysis"
			unique = 1
			duration = INFINITE_STATUS

	staggered
		id = "staggered"
		name = "Staggered"
		desc = "You have been staggered by a melee attack.<br>Slowed slightly, unable to sprint."
		icon_state = "staggered"
		unique = 1
		maxDuration = 5 SECONDS
		movement_modifier = /datum/movement_modifier/staggered_or_blocking

		onAdd(var/optional=null)
			.=..()
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.sustained_moves = 0

	blocking
		id = "blocking"
		name = "Blocking"
		desc = "You are currently blocking. Use Resist to stop blocking.<br>Slowed slightly, unable to sprint. This overrides the 'staggered' effect and does not stack."
		icon_state = "blocking"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		movement_modifier = /datum/movement_modifier/staggered_or_blocking

		clicked(list/params)
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.resist()

	slowed
		id = "slowed"
		name = "Slowed"
		desc = "You are slowed.<br>Movement speed is reduced."
		icon_state = "slowed"
		unique = 1
		var/howMuch = 10
		movement_modifier = new /datum/movement_modifier/status_slowed

		onAdd(var/optional=null)
			if(optional)
				howMuch = optional
				movement_modifier.additive_slowdown = optional
			return ..(optional)

		onChange(var/optional=null)
			if(optional)
				howMuch = optional
				movement_modifier.additive_slowdown = optional
			return ..(optional)

	disorient
		id = "disorient"
		name = "Disoriented"
		desc = "You are disoriented.<br>Movement speed is reduced. You may stumble or drop items."
		icon_state = "disorient"
		unique = 1
		maxDuration = 15 SECONDS
		var/counter = 0
		var/sound = "sound/effects/electric_shock_short.ogg"
		var/count = 7
		movement_modifier = /datum/movement_modifier/disoriented

		onUpdate(var/timedPassed)
			counter += timedPassed
			if (counter >= count && owner && !owner.hasStatus(list("weakened", "paralysis")) )
				counter -= count
				playsound(get_turf(owner), sound, 17, 1, 0.4, 1.6)
				violent_twitch(owner)
			.=..(timedPassed)

	drunk
		id = "drunk"
		name = "Drunk"
		desc = "You are drunk."
		icon_state = "drunk"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/how_drunk = 0

		onAdd(var/optional=null)
			changeState()
			return ..(optional)

		onUpdate(var/timedPassed)
			changeState()
			return ..(timedPassed)

		proc/changeState()
			if(owner?.reagents)
				var/amt = owner.reagents.get_reagent_amount("ethanol")
				if (amt >= 110)
					how_drunk = 3
				else if (amt > 50)
					how_drunk = 2
				else if (amt <= 50)
					how_drunk = 1
				else if (amt <= 0)
					how_drunk = 0
					return
				icon_state = "drunk[how_drunk]"

		getTooltip()
			return "You are [how_drunk == 2 ? "very": ""][how_drunk == 3 ? ", very" : ""] drunk."

	blinded
		id = "blinded"
		name = "Blinded"
		desc = "You are blinded.<br>Visibility drastically reduced."
		icon_state = "blinded"
		unique = 1

	hastened
		id = "hastened"
		name = "Hastened"
		desc = "You are hastened.<br>Movement speed is increased."
		icon_state = "hastened"
		unique = 1
		movement_modifier = /datum/movement_modifier/hastened

	cloaked
		id = "cloaked"
		name = "Cloaked"
		desc = "You are cloaked.<br>You are less visible."
		icon_state = "cloaked"
		unique = 1
		var/wait = 0

		onAdd(var/optional=null)
			animate(owner, alpha=30,flags=ANIMATION_PARALLEL, time=30)
			return

		onRemove()
			animate(owner,alpha=255,flags=ANIMATION_PARALLEL, time=30)
			return

		onUpdate(var/timedPassed)
			wait += timedPassed
			if(owner.alpha > 33 && wait > 40)
				animate(owner, alpha=30,flags=ANIMATION_PARALLEL, time=30)
				wait = 0
			return

	fitness_staminaregen
		id = "fitness_stam_regen"
		name = "Pumped"
		desc = ""
		icon_state = "muscle"
		exclusiveGroup = "Food"
		maxDuration = 500 SECONDS
		unique = 1
		var/change = 2

		getTooltip()
			return "Your stamina regen is increased by [change]."

		onAdd(var/optional=null)
			if(hascall(owner, "add_stam_mod_regen"))
				owner:add_stam_mod_regen("fitness_regen", change)
			return

		onRemove()
			if(hascall(owner, "remove_stam_mod_regen"))
				owner:remove_stam_mod_regen("fitness_regen")
			return

	fitness_staminamax
		id = "fitness_stam_max"
		name = "Buff"
		desc = ""
		icon_state = "muscle"
		exclusiveGroup = "Food"
		maxDuration = 500 SECONDS
		unique = 1
		var/change = 10

		getTooltip()
			return "Your stamina max is increased by [change]."

		onAdd(var/optional=null)
			if(hascall(owner, "add_stam_mod_max"))
				owner:add_stam_mod_max("fitness_max", change)
			return

		onRemove()
			if(hascall(owner, "remove_stam_mod_max"))
				owner:remove_stam_mod_max("fitness_max")
			return

	handcuffed
		id = "handcuffed"
		name = "Handcuffed"
		desc = "You are handcuffed.<br>You cannot use your hands. Click this status effect to resist."
		icon_state = "handcuffed"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/carbon/human/H

		onAdd(var/optional=null)
			if (ishuman(owner))
				H = owner
			else
				if (ismob(owner))
					var/mob/M = owner
					if (M.handcuffs) M.handcuffs.drop_handcuffs(M) //Some kind of invalid mob??
				owner.delStatus("handcuffed")

		clicked(list/params)
			H.resist()

	buckled
		id = "buckled"
		name = "Buckled"
		desc = "You are buckled.<br>You cannot walk. Click this status effect to unbuckle."
		icon_state = "buckled"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/carbon/human/H
		var/sleepcount = 5 SECONDS

		onAdd(var/optional=null)
			if (ishuman(owner))
				H = owner
				sleepcount = 5 SECONDS
			else
				owner.delStatus("buckled")

		clicked(list/params)
			if(H.buckled)
				H.buckled.attack_hand(H)

		onUpdate(var/timedPassed)
			if (H && !H.buckled)
				owner.delStatus("buckled")
			else
				if (sleepcount > 0)
					sleepcount -= timedPassed
					if (sleepcount <= 0)
						if (H.hasStatus("resting") && istype(H.buckled,/obj/stool/bed))
							var/obj/stool/bed/B = H.buckled
							B.sleep_in(H)
						else
							sleepcount = 3 SECONDS

			.=..()

	resting
		id = "resting"
		name = "Resting"
		desc = "You are resting.<br>You are laying down. Click this status effect to stand up."
		icon_state = "resting"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/L

		onAdd(var/optional=null)
			if (isliving(owner))
				L = owner
				if (L.getStatusDuration("burning"))
					if (!actions.hasAction(L, "fire_roll"))
						L.last_resist = world.time + 25
						actions.start(new/datum/action/fire_roll(), L)
					else
						return
			else
				owner.delStatus("resting")

		clicked(list/params)
			L.delStatus("resting")
			L.force_laydown_standup()
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				H.hud.update_resting()

	ganger
		id = "ganger"
		name = "Gang Member"
		desc = "You are a gang member wearing your uniform. You get health and stamina bonuses."
		icon_state = "ganger"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/const/max_health = 30
		var/const/max_stam = 60
		var/const/regen_stam = 5
		var/const/max_dist = 50
		var/mob/living/carbon/human/H
		var/datum/gang/gang
		var/on_turf = 0

		onAdd(var/optional=null)
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("ganger")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("ganger_max", max_stam)
			H.add_stam_mod_regen("ganger_regen", regen_stam)
			if (ismob(owner))
				var/mob/M = owner
				if (M.mind)
					gang = M.mind.gang

		onRemove()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("ganger_max")
			H.remove_stam_mod_regen("ganger_regen")
			gang = null

		onUpdate(var/timedPassed)
			var/area/cur_area = get_area(H)
			if (cur_area?.gang_owners == gang && prob(50))
				on_turf = 1

				//get distance divided by max distance and invert it. Result will be between 0 and 1
				var/buff_mult = round(1-(min(get_dist(owner,gang.locker), max_dist) / max_dist), 0.1)
				if (buff_mult <=0)
					buff_mult = 0.1

				var/mob/living/carbon/human/H
				if(ishuman(owner))
					H = owner
					H.HealDamage("All", 10*buff_mult, 0, 0)
					if (H.bleeding && prob(100*buff_mult))
						repair_bleeding_damage(H, 5, 1)

					var/list/statusList = H.getStatusList()

					if(statusList["paralysis"])
						H.changeStatus("paralysis", -3*buff_mult)
					if(statusList["stunned"])
						H.changeStatus("stunned", -3*buff_mult)
					if(statusList["weakened"])
						H.changeStatus("weakened", -3*buff_mult)
			else
				on_turf = 0

			return

		getTooltip()
			return "Your max health, max stamina, and stamina regen have been increased because of the pride you feel while wearing your uniform. [on_turf?"You are on home turf and receiving healing and stun reduction buffs when nearer your locker.":""]"

	janktank
		id = "janktank"
		name = "janktank"
		desc = "You're \"high\" on some sorta stimulant"
		icon_state = "janktank"
		duration = 9 MINUTES
		maxDuration = 18 MINUTES
		unique = 1
		movement_modifier = /datum/movement_modifier/janktank
		var/change = 1 //Effective change to maxHealth

		onAdd(var/optional=null) //Optional is change.
			if(ismob(owner))
				//var/mob/M = owner
				owner.delStatus("janktank_withdrawl")
				var/mob/M = owner
				M.add_stun_resist_mod("janktank", 40)
			else
				owner.delStatus("janktank")
			return

		onRemove()
			if(ismob(owner))
				//var/mob/M = owner
				owner.changeStatus("janktank_withdrawl", 10 MINUTES)
				var/mob/M = owner
				M.remove_stun_resist_mod("janktank")
			return

		onUpdate(var/timedPassed)
			var/mob/living/carbon/human/H
			if(ishuman(owner))
				H = owner
				H.take_oxygen_deprivation(-1)
				H.HealDamage("All", 2, 0, 0)
				if (prob(60))
					H.HealDamage("All", 1, 1, 1)
					if (H.bleeding)
						repair_bleeding_damage(H, 10, 1)
				if (prob(10))
					H.make_jittery(2)

				if (H.misstep_chance)
					H.change_misstep_chance(-5)
			return

	gang_drug_withdrawl
		id = "janktank_withdrawl"
		name = "janktank withdrawl"
		desc = "You're going through withrawl of Janktank"
		icon_state = "janktank-w"
		duration = 9 MINUTES
		maxDuration = 18 MINUTES
		unique = 1
		var/change = 1 //Effective change to maxHealth

		onAdd(var/optional=null) //Optional is change.
			if(ismob(owner) && optional != 0)
				//var/mob/M = owner
				change = optional
			return

		onUpdate(var/timedPassed)
			var/mob/living/carbon/human/M
			if(ishuman(owner))
				M = owner
			if (prob(15))
				M.TakeDamage("All", 0, 0, 1)
			if (prob(10))
				owner.changeStatus("stunned", 2 SECONDS)
			if (prob(20))
				violent_twitch(owner)
				M.make_jittery(rand(6,9))
			return

	mutiny
		id = "mutiny"
		name = "Mutiny"
		desc = "You can sense the aura of revolutionary activity! Your bossy attitude grants you health and stamina bonuses."
		icon_state = "mutiny"
		unique = 1
		maxDuration = 1 MINUTES
		var/const/max_health = 60
		var/const/max_stam = 30
		var/const/regen_stam = 5
		var/mob/living/carbon/human/H

		onAdd(var/optional=null)
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("mutiny")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("mutiny_max", max_stam)
			H.add_stam_mod_regen("mutiny_regen", regen_stam)

		onRemove()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("mutiny_max")
			H.remove_stam_mod_regen("mutiny_regen")

		getTooltip()
			return "Your max health, max stamina, and stamina regen have been increased because of your bossy attitude."


	revspirit
		id = "revspirit"
		name = "Revolutionary Spirit"
		desc = "Your saw your revolution leaders holding some great signs. The cameraderie motivating you to fight harder!"
		icon_state = "revspirit"
		unique = 1
		maxDuration = 20 SECONDS
		var/const/max_health = 20
		var/const/max_stam = 15
		var/const/regen_stam = 3
		var/mob/living/carbon/human/H

		onAdd(var/optional=null)
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("revspirit")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("revspirit_max", max_stam)
			H.add_stam_mod_regen("revspirit_regen", regen_stam)

		onRemove()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("revspirit_max")
			H.remove_stam_mod_regen("revspirit_regen")

		getTooltip()
			return "Your max stamina and stamina regen have been increased slightly."



/datum/statusEffect/bloodcurse
	id = "bloodcurse"
	name = "Cursed"
	desc = "You have been cursed."
	icon_state = "bleeding"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null
	var/mob/living/carbon/human/H
	var/units = 5

	getTooltip()
		return "You are losing blood at rate of [units] per second ."

	preCheck(var/atom/A)
		if(issilicon(A)) return 0
		return 1

	onAdd(var/optional=null)
		if (ishuman(owner))
			H = owner
		else
			owner.delStatus("bloodcurse")

	onUpdate()
		if (H.blood_volume > 400 && H.blood_volume > 0)
			H.blood_volume -= units
		if (prob(5))
			var/damage = rand(1,5)
			var/bleed = rand(3,5)
			H.visible_message("<span class='alert'>[H] [damage > 3 ? "vomits" : "coughs up"] blood!</span>", "<span class='alert'>You [damage > 3 ? "vomit" : "cough up"] blood!</span>")
			playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			H.TakeDamage(zone="All", brute=damage)
			bleed(H, damage, bleed)


/datum/statusEffect/mentor_mouse
	id = "mentor_mouse"
	name = "Mentor Mouse"
	desc = "A mentor is helping you in the form of a mouse in your pocket. Click here to let them go."
	icon_state = "mentor_mouse"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null

	clicked(list/params)
		for(var/mob/dead/target_observer/mentor_mouse_observer/M in src.owner)
			boutput(src.owner, "You let the mentor mouse go.")
			M.boot()

	onUpdate()
		if (src.owner && !(locate(/mob/dead/target_observer/mentor_mouse_observer) in src.owner))
			owner.delStatus("mentor_mouse")
		. = ..()

/datum/statusEffect/mentor_mouse/admin
	id = "admin_mouse"
	name = "Admin Mouse"
	desc = "An admin is helping you in the form of a mouse in your pocket. Click here to let them go."
	icon_state = "admin_mouse"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null

	clicked(list/params)
		for(var/mob/dead/target_observer/mentor_mouse_observer/M in src.owner)
			boutput(src.owner, "You let the admin mouse go.")
			M.boot()

	onUpdate()
		if (src.owner && !(locate(/mob/dead/target_observer/mentor_mouse_observer) in src.owner))
			owner.delStatus("admin_mouse")
		. = ..()
