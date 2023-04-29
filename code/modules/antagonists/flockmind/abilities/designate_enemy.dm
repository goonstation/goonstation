/datum/targetable/flockmindAbility/designateEnemy
	name = "Designate Enemy"
	desc = "Mark or unmark someone as an enemy."
	icon_state = "designate_enemy"
	cooldown = 0

/datum/targetable/flockmindAbility/designateEnemy/cast(atom/target)
	if(..())
		return TRUE

	var/M = target
	var/mob/living/intangible/flock/F = holder.owner

	if (!(isliving(M) || iscritter(M) || isvehicle(M)) || isflockmob(M) || isintangible(M))
		boutput(F, "<span class='alert'>That isn't a valid target.</span>")
		return TRUE

	var/datum/flock/flock = F.flock

	if (!flock)
		return TRUE

	if (!src.tutorial_check(FLOCK_ACTION_MARK_ENEMY, M))
		return TRUE

	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "designates [constructTarget(M)] as [flock.isEnemy(M) ? "not " : ""]an enemy at [log_loc(src.holder.owner)].")

	if (flock.isIgnored(M))
		flock.removeIgnore(M)
	else if (flock.isEnemy(M))
		flock.removeEnemy(M)
		return

	flock.updateEnemy(M)

/datum/targetable/flockmindAbility/designateIgnore
	name = "Designate Ignore"
	desc = "Designate someone to be ignored by your Flock."
	icon_state = "designate_ignore"
	cooldown = 0.1 SECONDS

/datum/targetable/flockmindAbility/designateIgnore/cast(atom/target)
	if(..())
		return TRUE

	var/mob/living/intangible/flock/F = holder.owner

	if (!isflockvalidenemy(target))
		boutput(F, "<span class='alert'>That isn't a valid target.</span>")
		return TRUE

	if (!F.flock)
		return TRUE

	logTheThing(LOG_COMBAT, holder.get_controlling_mob(), "designates [constructTarget(target)] to [F.flock.isIgnored(target) ? "not " : ""] be ignored by their flock at [log_loc(src.holder.owner)].")

	if (F.flock.isIgnored(target))
		F.flock.removeIgnore(target)
		return
	if (F.flock.isEnemy(target))
		F.flock.removeEnemy(target)

	F.flock.addIgnore(target)
