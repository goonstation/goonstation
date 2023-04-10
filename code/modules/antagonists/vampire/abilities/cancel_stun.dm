/datum/targetable/vampire/cancel_stuns
	name = "Cancel stuns"
	desc = "Recover from being stunned. You will take damage in proportion to the amount of stun you dispel."
	icon_state = "nostun"
	cooldown = 4 SECONDS
	not_when_in_an_object = FALSE
	incapacitation_restriction = ABILITY_CAN_USE_ALWAYS
	can_cast_while_cuffed = FALSE

	cast(mob/target)
		var/mob/living/user = holder.owner

		var/greatest_stun = max(3, user.getStatusDuration("stunned"), user.getStatusDuration("weakened"), \
								user.getStatusDuration("paralysis"), user.getStatusDuration("slowed")/4, user.getStatusDuration("disorient")/2)
		greatest_stun = round(greatest_stun / 20)

		user.TakeDamage("All", greatest_stun, 0)
		user.take_oxygen_deprivation(-5)
		user.losebreath = min(usr.losebreath - 3)
		boutput(user, "<span class='notice'>You cancel your stuns and take [greatest_stun] damage in return.</span>")

		src.remove_stuns()
		return FALSE

	proc/remove_stuns(var/message_type = 1)
		var/mob/living/user = holder.owner

		if (is_incapacitated(user) && user.stamina < 40)
			user.set_stamina(40)

		user.delStatus("stunned")
		user.delStatus("weakened")
		user.delStatus("paralysis")
		user.delStatus("slowed")
		user.delStatus("disorient")
		user.change_misstep_chance(-INFINITY)
		user.stuttering = 0
		user.delStatus("drowsy")

		violent_standup_twitch(user)
		user.visible_message("<span class='alert'><B>[user] contorts their body and judders upright!</B></span>")
		playsound(user.loc, 'sound/effects/bones_break.ogg', 60, 1)

		user.delStatus("resting")
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()

		user.force_laydown_standup()


		logTheThing(LOG_COMBAT, user, "uses cancel stuns at [log_loc(user)].")
