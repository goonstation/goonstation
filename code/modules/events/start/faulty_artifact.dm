/datum/random_event/start/faulty_artifact
	name = "Artifact Warping"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()
		var/turf/T = pick_landmark(LANDMARK_BLOBSTART) // Quite samey to midround one
		if(!T)
			return
		Artifact_Spawn(T)
		var/damage_amt = rand(50, 75)
		T.ArtifactDevelopFault(100)
		T.ArtifactTakeDamage(damage_amt)
