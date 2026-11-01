/// Record slipping on a banana peel
/datum/eventRecord/BananaSlip
	eventType = "banana_slip"
	body = /datum/eventRecordBody/TracksPlayer/BananaSlip

	send(player_id, mob_name, mob_job, x, y, z, map_id, intensity)

	buildAndSend(mob/living/carbon/human/slipper, intensity)
		var/datum/player/player = slipper.client?.player
		var/turf/T = get_turf(slipper)
		if (player?.id && T)
			src.send(list(player.id, slipper.real_name, slipper.job, T.x, T.y, T.z, map_setting, intensity))
