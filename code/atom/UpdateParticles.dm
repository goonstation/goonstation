/atom/var/list/particle_refs = null

/atom/proc/UpdateParticles(particles/P, key, effect_appearance_flags, force=0, plane=null)
	if(!key)
		CRASH("UpdateParticles called without a key.")
	LAZYLISTINIT(particle_refs)
	var/obj/effects/holder
	holder = particle_refs[key]
	if(!holder && P)
		holder = new /obj/effects
	else if(!holder)
		return

	if(!force && (holder.particles == P)) //If it's the same particle as the other then do not update
		return
	if(!isnull(plane))
		holder.plane = plane
	holder.particles = P
	holder.vis_locs |= src
	particle_refs[key] = holder
	holder.appearance_flags |= effect_appearance_flags

/atom/proc/ClearSpecificParticles(key)
	if(!key)
		CRASH("ClearSpecificParticles called without a key.")
	if (!particle_refs)
		return
	var/obj/effects/holder = particle_refs[key]
	holder?.vis_locs = null
	qdel(holder)
	particle_refs -= key

/atom/proc/ClearAllParticles()
	if (!particle_refs)
		return
	for (var/index as anything in particle_refs)
		var/obj/O = particle_refs[index]
		if (!O) continue
		O.vis_locs = null
		O.particles = null
		qdel(O)

/atom/proc/GetParticles(key)
	RETURN_TYPE(/particles)
	if(!key)
		CRASH("GetParticles called without a key.")
	if (!particle_refs)
		return
	var/obj/O = particle_refs[key]
	return O?.particles
