/datum/component/wearertargeting/geiger
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	signals = list(COMSIG_MOB_GEIGER_TICK)
	var/list/cooldowns = list()
	proctype = .proc/geigerclick

/datum/component/wearertargeting/geiger/proc/geigerclick(var/mob/owner, var/stage)
	if(owner && !ON_COOLDOWN(src, "playsound", 1 SECOND))
		owner.playsound_local(get_turf(owner), "sound/items/geiger/geiger-[stage]-[stage >= 4 ? rand(1, 3) : rand(1, 2)].ogg", 10)


/datum/component/holdertargeting/geiger
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	signals = list(COMSIG_MOB_GEIGER_TICK)
	proctype = .proc/geigerclick
	var/list/cooldowns = list()

	on_dropped(datum/source, mob/user)
		var/obj/item/I = parent
		if(I.loc != user)
			. = ..()

/datum/component/holdertargeting/geiger/proc/geigerclick(var/mob/owner, var/stage)
	if(owner)
		var/obj/item/I = parent
		if(!ON_COOLDOWN(src, "playsound", 1 SECOND))
			owner.playsound_local(get_turf(owner), "sound/items/geiger/geiger-[stage]-[stage >= 4 ? rand(1, 3) : rand(1, 2)].ogg", 20, flags = SOUND_IGNORE_SPACE)
		SEND_SIGNAL(I, COMSIG_MOB_GEIGER_TICK, stage)
