/datum/component/wearertargeting/geiger
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	signals = list(COMSIG_MOB_GEIGER_TICK)
	proctype = .proc/geigerclick

/datum/component/wearertargeting/geiger/proc/geigerclick(var/mob/owner, var/stage)
	if(owner && prob(stage*20))
		var/obj/item/I = parent
		boutput(owner, "<span class='alert'>The geiger counter on your [I.name] ticks...</span>")
		owner.playsound_local(get_turf(owner), "sound/machines/click.ogg", stage * 10)
	return 1


/datum/component/holdertargeting/geiger
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	signals = list(COMSIG_MOB_GEIGER_TICK)
	proctype = .proc/geigerclick

	on_dropped(datum/source, mob/user)
		var/obj/item/I = parent
		if(I.loc != user)
			. = ..()

/datum/component/holdertargeting/geiger/proc/geigerclick(var/mob/owner, var/stage)
	if(owner && prob(stage*20))
		var/obj/item/I = parent
		boutput(owner, "<span class='alert'>Your [I.name] ticks...</span>")
		owner.playsound_local(get_turf(owner), "sound/machines/click.ogg", stage * 10)
	return 1
