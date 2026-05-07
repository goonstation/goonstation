/datum/lifeprocess/camera_awareness
	/// Camera coverage emitters we are currently using to see
	var/list/current_emitters = list()
	process(datum/gas_mixture/environment)
		//no client, no looking
		if (!src.owner.client)
			for (var/datum/component/camera_coverage_emitter/emitter as anything in src.current_emitters)
				emitter.unregister_user(src.owner)
			src.current_emitters = list()
			return

		var/list/new_emitters = list()
		for (var/turf/T in view(src.owner.client.view, src.owner))
			for (var/datum/component/camera_coverage_emitter/emitter as anything in T.camera_coverage_emitters)
				new_emitters |= emitter
		for (var/datum/component/camera_coverage_emitter/emitter as anything in src.current_emitters)
			//not in the new batch, we're not using this camera anymore
			if (!(emitter in new_emitters))
				emitter.unregister_user(src.owner)
				src.current_emitters -= emitter
		for (var/datum/component/camera_coverage_emitter/emitter as anything in new_emitters)
			//new one!
			if (!(emitter in src.current_emitters))
				emitter.register_user(src.owner)
				src.current_emitters += emitter
