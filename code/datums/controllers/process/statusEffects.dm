
/// handles status effects
/datum/controller/process/statusEffects
	var/lastUpdate = null
	var/lastProcessLength = 1

	setup()
		name = "StatusEffects"
		schedule_interval = 0.3 SECONDS //Adjust as needed; Wouldnt go over 10.
		lastUpdate = world.timeofday

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/statusEffects/old_statusEffects = target
		src.lastUpdate = old_statusEffects.lastUpdate
		src.lastProcessLength = old_statusEffects.lastProcessLength

	doWork()
		lastProcessLength = world.timeofday
		var/actual = (world.timeofday - lastUpdate)
		if(actual < 0) //Wrapped
			actual += 864000 //Add one day worth of ticks to this. I think this should work?

		var/list/notifyUiUpdate = list() //List of objects that need to update their status ui.

		for (var/datum/statusEffect/S as anything in globalStatusInstances)
			if(S == null) continue
			if (S.duration < 0)
				stack_trace("statusEffect [S] with owner [identify_object(S.owner)] updating with negative duration [S.duration]. actual = [actual]")
				globalStatusInstances -= S
			if(S.owner)
				S.onUpdate(actual)
				if(!isnull(S.duration))
					S.duration -= actual
					if(S.duration <= 0)
						if(S.owner)
							S.owner.delStatus(S)
					else
						if(!(S.owner in notifyUiUpdate))
							notifyUiUpdate.Add(S.owner)
				else
					//if it's a permanent one, you can still update the icon
					if(!(S.owner in notifyUiUpdate))
						notifyUiUpdate.Add(S.owner)
			else
				logTheThing(LOG_DEBUG, null, "Deleting orphaned status effect - type:[S.type], duration:[S.duration], OwnerInfo(was):[S.archivedOwnerInfo]")
				try
					S.onRemove()
				catch()
					logTheThing(LOG_DEBUG, null, "Orphaned onRemove failed - type:[S.type]")
				globalStatusInstances -= S

		for(var/atom/A in notifyUiUpdate)
			SPAWN(0) if(A?.statusEffects) A.updateStatusUi()

		lastUpdate = world.timeofday
		lastProcessLength =  (world.timeofday - lastProcessLength)

	tickDetail()
		var/stats = "<b>Processing [globalStatusInstances.len] items every [schedule_interval] ticks</b><br>"
		stats += "<b>Last processing duration was [lastProcessLength / 10] sec.</b><br>"
		if(lastProcessLength > schedule_interval)
			stats += "<b>WARNING: PROCESS RUNNING OVERTIME</b><br>"
		boutput(usr, "<br>[stats]")
