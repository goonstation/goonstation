/datum/targetable/vampire/cancel_stuns
	name = "Cancel stuns"
	desc = "Recover from being stunned. You will take damage in proportion to the amount of stun you dispel."
	icon_state = "nostun"
	targeted = 0
	do_logs = FALSE
	target_nodamage_check = 0
	max_range = 0
	cooldown = 40
	pointCost = 0
	not_when_in_an_object = FALSE
	when_stunned = 2
	not_when_handcuffed = 0
	interrupt_action_bars = FALSE

	proc/remove_stuns(var/message_type = 1)
		if (!holder)
			return

		var/mob/living/M = holder.owner

		if (!M)
			return

		if (is_incapacitated(M) && M.stamina < 40)
			M.set_stamina(40)

		M.remove_stuns()
		M.delStatus("slowed")
		M.delStatus("disorient")
		M.change_misstep_chance(-INFINITY)
		M.stuttering = 0
		M.delStatus("drowsy")

		if (message_type == 3)
			violent_standup_twitch(M)
			M.visible_message(SPAN_ALERT("<B>[M] contorts [his_or_her(M)] body and judders upright!</B>"))
			playsound(M.loc, 'sound/effects/bones_break.ogg', 60, 1)
		else if (message_type == 2)
			boutput(M, SPAN_NOTICE("You feel your flesh knitting itself back together."))
		else
			boutput(M, SPAN_NOTICE("You feel refreshed and ready to get back into the fight."))

		M.delStatus("resting")
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hud.update_resting()

		M.force_laydown_standup()


		logTheThing(LOG_COMBAT, M, "uses cancel stuns at [log_loc(M)].")
		return

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		. = ..()
		var/greatest_stun = max(3, M.getStatusDuration("stunned"),M.getStatusDuration("knockdown"),M.getStatusDuration("unconscious"),M.getStatusDuration("slowed")/4,M.getStatusDuration("disorient")/2)
		greatest_stun = round(greatest_stun / 20)

		M.TakeDamage("All", greatest_stun, 0)
		M.take_oxygen_deprivation(-5)
		M.losebreath = min(usr.losebreath - 3)
		boutput(M, SPAN_NOTICE("You cancel your stuns and take [greatest_stun] damage in return."))

		src.remove_stuns(3)
		return 0

/datum/targetable/vampire/cancel_stuns/mk2
	name = "Cancel stuns Mk2"
	desc = "Recover from being stunned. Restores a minor amount of health."
	cooldown = 600
	pointCost = 0
	when_stunned = 2
	unlock_message = "Your cancel stuns power now heals you in addition to its original effect."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		. = ..()
		if (M.get_burn_damage() > 0 || M.get_toxin_damage() > 0 || M.get_brute_damage() > 0 || M.get_oxygen_deprivation() > 0 || M.losebreath > 0)
			M.HealDamage("All", 40, 40)
			M.take_toxin_damage(-40)
			M.take_oxygen_deprivation(-40)
			M.losebreath = min(usr.losebreath - 40)

		src.remove_stuns(2)
		return 0
