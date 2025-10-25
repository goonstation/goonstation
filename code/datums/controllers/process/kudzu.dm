#define CONVERT_PER_CORPSE_MINIMUM 40
#define CONVERT_PER_CORPSE_MAXIMUM 60
#define CONVERT_REQUIRED 100

/// Controlls the kudzu process
/datum/controller/process/kudzu
	var/list/kudzu = list()

	var/tmp/list/detailed_count
	var/count = 0
	var/conversion_progress = 0

	setup()
		name = "Kudzu"
		schedule_interval = 3 SECONDS

		detailed_count = new

	doWork()
		for (var/obj/spacevine/K in kudzu)
			if (K.run_life)
				K.Life()
				scheck()

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/kudzu/old_kudzu = target
		src.detailed_count = old_kudzu.detailed_count
		src.count = old_kudzu.count
		src.kudzu = old_kudzu.kudzu

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>Kudzu Stats:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				stats += "[thing] processed [count] times. Total kudzu: [kudzu.len]<br>"
			boutput(usr, "<br>[stats]")

	proc/process_corpse(var/mob/living/carbon/human/H)
		if(!H || !istype(H) || !isdead(H))
			return
		if(isnpc(H) || isnpcmonkey(H)) //NPCs provide no points
			H.decomp_stage = DECOMP_STAGE_SKELETONIZED
			H.set_body_icon_dirty()
			return
		src.conversion_progress += rand(CONVERT_PER_CORPSE_MINIMUM, CONVERT_PER_CORPSE_MAXIMUM)
		if(src.conversion_progress < CONVERT_REQUIRED)
			H.decomp_stage = DECOMP_STAGE_SKELETONIZED
			H.set_body_icon_dirty()
			return
		//Enough corpses have been consumed to make a kudzuperson
		src.conversion_progress -= CONVERT_REQUIRED
		H.full_heal()
		if (!H.ckey && H.last_client && !H.last_client.mob.mind.get_player()?.dnr)
			if (!istype(H.last_client.mob,/mob/living) || inafterlifebar(H.last_client.mob))
				H.ckey = H.last_client.ckey
		if (istype(H.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/Comp = H.abilityHolder
			Comp.removeHolder(/datum/abilityHolder/kudzu)
		else if (H.abilityHolder)
			H.abilityHolder.dispose()
			H.abilityHolder = null
		H.mind?.add_antagonist(ROLE_KUDZUPERSON, source = ANTAGONIST_SOURCE_CONVERTED, respect_mutual_exclusives = FALSE)

/mob/living/carbon/human/proc/infect_kudzu()
	var/obj/icecube/kudzu/cube = new /obj/icecube/kudzu(get_turf(src), src)
	src.set_loc(cube)
	cube.visible_message(SPAN_ALERT("<B>[src] is covered by the vines!"))

#undef CONVERT_PER_CORPSE_MINIMUM
#undef CONVERT_PER_CORPSE_MAXIMUM
#undef CONVERT_REQUIRED
