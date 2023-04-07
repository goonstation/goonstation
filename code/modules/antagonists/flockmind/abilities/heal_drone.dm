/datum/targetable/flockmindAbility/healDrone
	name = "Concentrated Repair Burst"
	desc = "Accelerate the repair processes of all flock units in an area (maximum 4 drones)."
	icon_state = "heal_drone"
	cooldown = 30 SECONDS
	var/max_targets = 4 //maximum number of drones healed

/datum/targetable/flockmindAbility/healDrone/cast(atom/target)
	if(..())
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_HEAL, target))
		return TRUE
	var/mob/living/intangible/flock/flockowner = holder.owner
	var/healed = 0
	for (var/mob/living/critter/flock/flockcritter in range(3, target))
		var/health_ratio = flockcritter.get_health_percentage()
		if (isdead(flockcritter) || health_ratio >= 1 || flockcritter.flock != flockowner.flock)
			continue
		flockcritter.HealDamage("All", 30, 30) //half of a flockdrone's health
		var/particles/healing/flock/particles = new
		particles.spawning = 1 - health_ratio //more heal = more particles
		flockcritter.UpdateParticles(particles, "flockmind_heal")
		SPAWN(1.5 SECONDS)
			particles.spawning = 0
			sleep(1.5 SECONDS)
			flockcritter.ClearSpecificParticles("flockmind_heal")
		if (istype(flockcritter, /mob/living/critter/flock/drone))
			healed++
		if (healed >= src.max_targets)
			break

	playsound(holder.get_controlling_mob(), 'sound/misc/flockmind/flockmind_cast.ogg', 80, 1)
	boutput(holder.get_controlling_mob(), "<span class='notice'>You focus the flock's efforts on repairing nearby units.</span>")
	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "casts repair burst at [log_loc(src.holder.owner)].")
