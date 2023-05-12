/datum/targetable/flockmindAbility/radioStun
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone within 3m of your target. Will not work on broken or non-existent headsets."
	icon_state = "radio_stun"
	cooldown = 20 SECONDS
	targeted = TRUE

/datum/targetable/flockmindAbility/radioStun/cast(atom/target)
	if(..())
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_RADIO_STUN))
		return TRUE
	var/list/targets = list()
	for(var/mob/living/M in range(3, get_turf(target)))
		if(M.ear_disability)
			continue
		var/obj/item/device/radio/R = M.ears // wont work on flock as they have no slot for this
		if(istype(R) && R.listening) // working and toggled on
			targets += M
	if(length(targets))
		playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
		boutput(holder.get_controlling_mob(), "<span class='notice'>You transmit the worst static you can weave into the headsets around you.</span>")
		logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts radio stun burst at [log_loc(src.holder.owner)].")
		for(var/mob/living/M in targets)
			playsound(M, "sound/effects/radio_sweep[rand(1,5)].ogg", 70, 1)
			boutput(M, "<span class='alert'>Horrifying static bursts into your headset, disorienting you severely!</span>")
			M.apply_sonic_stun(3, 6, 30, 0, 0, rand(1, 3), rand(1, 3))
	else
		boutput(holder.get_controlling_mob(), "<span class='alert'>No targets in range with active radio headsets.</span>")
		return TRUE
