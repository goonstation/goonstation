/datum/component/flock_protection
	var/flockdrones_can_hit
	var/report_hand_attack
	var/report_obj_attack

/datum/component/flock_protection/Initialize(flockdrones_can_hit, report_hand_attack, report_obj_attack)
	src.flockdrones_can_hit = flockdrones_can_hit
	src.report_hand_attack = report_hand_attack
	src.report_obj_attack = report_obj_attack

/datum/component/flock_protection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/handle_attackhand)
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/handle_attackby)

/datum/component/flock_protection/proc/handle_attackhand(source, mob/user as mob)
	if (user.a_intent != INTENT_HARM)
		return

	if (istype(user, /mob/living/critter/flock/drone) && !flockdrones_can_hit)
		boutput(user, "<span class='alert'>The grip tool refuses to harm this, jamming briefly.</span>")
		return TRUE

	if (!istype(user, /mob/living/critter/flock/drone) && report_hand_attack)
		src.attempt_report_attack(source, user)

/datum/component/flock_protection/proc/handle_attackby(source, obj/item/W as obj, mob/user as mob)
	if (istype(user, /mob/living/critter/flock/drone) && !flockdrones_can_hit)
		boutput(user, "<span class='alert'>The grip tool refuses to allow damage to this, jamming briefly.</span>")
		return TRUE

	if (!istype(user, /mob/living/critter/flock/drone) && report_obj_attack)
		src.attempt_report_attack(source, user)

/datum/component/flock_protection/proc/attempt_report_attack(source, mob/attacker)
	var/list/nearby_flockdrones = list()
	for (var/mob/living/critter/flock/drone/flockdrone in view(7, source))
		if (!isdead(flockdrone) && flockdrone.is_npc && flockdrone.flock)
			nearby_flockdrones.Add(flockdrone)

	if (length(nearby_flockdrones))
		var/mob/living/critter/flock/drone/flockdrone = pick(nearby_flockdrones)

		if (!flockdrone.flock.isEnemy(attacker))
			flock_speak(flockdrone, "Damage sighted on [source], [pick_string("flockmind.txt", "flockdrone_enemy")] [attacker]", flockdrone.flock)
			flockdrone.flock.updateEnemy(attacker)
