/datum/controller/process/artifacts
	setup()
		name = "Artifacts"
		schedule_interval = 1 SECOND

	doWork()
		for (var/obj/artifact/art as anything in by_cat[TR_CAT_PROCESSED_ARTIFACTS])
			if (!QDELETED(art))
				art.process()
