/datum/antagonist/infinicrimer
	id = ROLE_CONFIRMED_CRIMINAL
	display_name = "ultimate criminal"
	antagonist_icon = "traitor"
	assigned_by = ANTAGONIST_SOURCE_ADMIN
	has_info_popup = FALSE
	mutually_exclusive = FALSE

	handle_cryo()
		SPAWN(0)
			var/obj/cryotron/cryo = owner.current.loc
			cryo.add_person_to_queue(owner.current, null)
			cryo.stored_mobs[owner.current] = null
			cryo.stored_mobs_volunteered[owner.current] = null
			cryo.stored_mobs -= owner.current
			cryo.stored_mobs_volunteered -= owner.current
			cryo.stored_crew_names -= owner.current.real_name
			var/datum/db_record/crew_record = data_core.general.find_record("id", owner.current.datacore_id)
			if (!isnull(crew_record))
				crew_record["p_stat"] = "Active"
			var/datum/job/job = find_job_in_controller_by_string(owner.current.job, soft=TRUE)
			if (job && !job.unique)
				job.assigned = min(job.limit, job.assigned + 1)
			boutput(owner.current, SPAN_ALERT("CRIME TIME NEVER STOPS"))
	handle_perma_cryo()
		owner.remove_antagonist(ROLE_CONFIRMED_CRIMINAL, ANTAGONIST_REMOVAL_SOURCE_DEATH)
