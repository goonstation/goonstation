/// Preserve the channel's spatial and playback settings in SOUND_UPDATE packets.
/proc/sound_update_packet(sound/original, volume)
	if (!original?.channel)
		return null
	var/sound/update = sound(null, wait = FALSE, channel = original.channel)
	update.status = SOUND_UPDATE
	update.repeat = original.repeat
	update.frequency = original.frequency
	update.pitch = original.pitch
	update.pan = original.pan
	update.x = original.x
	update.y = original.y
	update.z = original.z
	update.falloff = original.falloff
	update.environment = original.environment
	update.echo = original.echo
	update.volume = volume
	return update
