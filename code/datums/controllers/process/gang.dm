/datum/controller/process/gang_tag_vision
	setup()
		name = "Gang_Tags"
		schedule_interval = GANG_TAG_SCAN_RATE DECI SECONDS

	copyStateFrom(datum/controller/process/target)
		return

	doWork()
		for(var/obj/decal/gangtag/I in by_cat[TR_CAT_GANGTAGS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.find_players()



/datum/controller/process/gang_tag_score
	setup()
		name = "Gang_Tags_Score"
		schedule_interval = GANG_TAG_SCORE_INTERVAL SECONDS

	copyStateFrom(datum/controller/process/target)
		return

	doWork()
		for(var/obj/decal/gangtag/I in by_cat[TR_CAT_GANGTAGS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.score_players()
