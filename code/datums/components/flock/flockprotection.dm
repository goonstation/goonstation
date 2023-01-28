
/// Mark a specific flock as interested in this
/datum/component/flock_interest
	/// The flock who is intently interested in this thing.
	var/datum/flock/flock

/datum/component/flock_interest/Initialize(datum/flock/flock)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.flock = flock

/datum/component/flock_interest/RegisterWithParent()
	RegisterSignal(parent, COMSIG_FLOCK_ATTACK, .proc/handle_flock_attack)

/// If flockdrone is in our flock, deny the attack, otherwise scream and cry
/datum/component/flock_interest/proc/handle_flock_attack(atom/source, atom/attacker, intentional, projectile_attack)
	if(!istype(attacker))
		return

	var/mob/living/critter/flock/F = attacker
	if (istype(F) && F.flock == src.flock)
		if(intentional)
			boutput(F, "<span class='alert'>The grip tool refuses to harm this, jamming briefly.</span>")
		return intentional

	if (istype(source, /mob/living/critter/flock/drone))
		return

	var/mob/living/critter/flock/drone/snitch
	for (var/mob/living/critter/flock/drone/FD in viewers(attacker))
		if (FD != attacker && !isdead(FD) && FD.is_npc && !FD.dormant && FD.flock == src.flock)
			snitch = FD
			break

	if(!snitch)
		return

	var/report_name = source
	if (istype(source, /mob/living/critter/flock/bit))
		var/mob/M = source
		report_name = M.real_name
	else if (istype(source, /obj/flock_structure))
		var/obj/flock_structure/structure = source
		report_name = "the " + structure.flock_id
	else if (hasvar(source, "flock_id"))
		report_name = "the " + source.vars["flock_id"]

	if (snitch.flock.isIgnored(attacker))
		flock_speak(snitch, "Damage sighted on [report_name], [pick_string("flockmind.txt", "flockdrone_betrayal")] [attacker]", snitch.flock)
	else if (!snitch.flock.isEnemy(attacker))
		flock_speak(snitch, "Damage sighted on [report_name], [pick_string("flockmind.txt", "flockdrone_enemy")] [attacker]", snitch.flock)
	snitch.flock.updateEnemy(attacker)

	if (projectile_attack)
		snitch.flock.check_for_bullets_hit_achievement(projectile_attack)

/// Raise COMSIG_FLOCK_ATTACK on common sources of damage (projectiles, items, fists, etc.)
/datum/component/flock_protection
	/// Do we get mad if someone punches it?
	var/report_unarmed
	/// Do we get mad if someone hits it with something?
	var/report_attack
	/// Do we get mad if someone throws something at it?
	var/report_thrown
	/// Do we get mad if someone shoots it?
	var/report_proj

/datum/component/flock_protection/Initialize(report_unarmed=TRUE, report_attack=TRUE, report_thrown=TRUE, report_proj=TRUE)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.report_unarmed = report_unarmed
	src.report_attack = report_attack
	src.report_thrown = report_thrown
	src.report_proj = report_proj

/datum/component/flock_protection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/handle_attackhand)
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/handle_attackby)
	RegisterSignal(parent, COMSIG_ATOM_HITBY_THROWN, .proc/handle_hitby_thrown)
	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, .proc/handle_hitby_proj)

/// Protect against punches/kicks/etc.
/datum/component/flock_protection/proc/handle_attackhand(atom/source, mob/user)
	return user.a_intent == INTENT_HARM && src.report_unarmed && SEND_SIGNAL(source, COMSIG_FLOCK_ATTACK, user, TRUE, null)

/// Protect against being hit by something.
/datum/component/flock_protection/proc/handle_attackby(atom/source, obj/item/W, mob/user)
	return W && src.report_attack && SEND_SIGNAL(source, COMSIG_FLOCK_ATTACK, user, TRUE, null)

/// Protect against someone chucking stuff at the parent.
/datum/component/flock_protection/proc/handle_hitby_thrown(atom/source, atom/thrown_thing, datum/thrown_thing/thr)
	var/mob/attacker = thr.user
	return istype(attacker) && src.report_thrown && SEND_SIGNAL(source, COMSIG_FLOCK_ATTACK, attacker, FALSE, null)

/// Protect against someone shooting the parent.
/datum/component/flock_protection/proc/handle_hitby_proj(atom/source, obj/projectile/P)
	var/attacker = P.shooter
	if (!(ismob(attacker) || iscritter(attacker) || isvehicle(attacker)))
		attacker = P.mob_shooter //shooter is updated on reflection, so we fall back to mob_shooter if it turns out to be a wall or something
	return attacker && src.report_proj && SEND_SIGNAL(source, COMSIG_FLOCK_ATTACK, attacker, FALSE, P)
