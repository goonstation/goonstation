var/channelReserved = 256
var/channelMax = 512
var/sound/mutecache
/atom/var
	list/attachedSounds = null
/var/list/allAttachedSounds = list()
/sound
	var/atom/attached
	var/list/listeners = list()
	var/maxdist = 0


	proc/attach( var/atom/towhat )
		attached = towhat
		channel = channelReserved++
		if(channelReserved>channelMax)
			channelReserved=256
		if(!attached.attachedSounds)
			attached.attachedSounds = list()
		attached.attachedSounds.Add( src )
		allAttachedSounds.Add( src )

		recalculate()

	proc/stop()
		if(channel)
			if(!mutecache)
				mutecache = sound(null)
			mutecache.channel = channel
			world << src
			if(attached)
				attached.attachedSounds.Remove( src )
				allAttachedSounds.Remove( src )
				attached = null
				listeners = list()

	proc/recalcClient(var/client/c)
		if(!mutecache)
			mutecache = sound(null)
		mutecache.channel = channel
		status |= SOUND_UPDATE
		var/turf/CT = get_turf(c.mob)
		var/turf/AT = get_turf(attached)
		var/dist = GET_DIST(CT, AT)
		if( !listeners.Find(c) )
			//world << "Their dist: [dist] vs [maxdist]"
			if( dist < maxdist )
				status &= ~SOUND_UPDATE
				pan = clamp((AT.x - CT.x)/maxdist*100,-100,100)
				volume = 100-(dist/maxdist*100)
				c << src
				status |= SOUND_UPDATE
				listeners.Add(c)

		else if( dist > maxdist )
			listeners.Remove(c)
			c << mutecache
		else
			pan = (AT.x - CT.x)/maxdist*100
			volume = 100-(dist/maxdist*100)
			c << src
	proc/recalculate()
		for(var/client/c)
			//world << "Recalculating for [c]"
			recalcClient(c)
/*/client/Move()
	.=..()
	for (var/sound/S as anything in allAttachedSounds)
		world << "[S]"
		if(S.listeners.Find( src ))
			S.recalcClient(src)*/
/atom/movable/proc/update_sounds()
	.=..()
	if(length(attachedSounds))
		for (var/sound/S as anything in attachedSounds)
			S.recalculate()
			//world << "Recalc due to move!"

/mob/proc/OnMove()
	if(client)
		for(var/sound/s in allAttachedSounds)
			s.recalcClient(client)
/mob/Move()
	.=..()
	OnMove()

/atom/movable/set_loc()
	.=..()
	update_sounds()

/atom/movable/Move()
	.=..()
	update_sounds()
	for(var/mob/m in get_all_mobs_in(src))
		if(m.client)
			for(var/sound/s in allAttachedSounds)
				s.recalcClient(m.client)
/atom/proc/sound2(var/snd, var/vol, var/looping)
	var/sound/s = sound(snd, repeat=1)
	s.maxdist = vol
	s.attach(src)

/proc/STOPITSTOPTHESOUNDSNOWOHDEARGODPLEASE()
	if(!mutecache)
		mutecache = sound(null)
	for(var/i=1,i <= 1024,i++)
		mutecache.channel = i
		world << mutecache
