/datum/targetable/vampiric_thrall/speak
	name = "Speak"
	desc = "Telepathically speak to your master and your fellow ghouls."
	icon_state = "thrallspeak"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	not_when_in_an_object = FALSE
	when_stunned = 1
	not_when_handcuffed = 0
	unlock_message = ""
	interrupt_action_bars = FALSE
	do_logs = FALSE

	incapacitation_check()
		.= 1

	cast(mob/target)
		if (!holder)
			return 1

		. = ..()
		var/message = html_encode(tgui_input_text(usr, "Choose something to say:", "Enter Message."))
		if (!message)
			return

		src.holder.owner.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER, message_params = list("output_module_channel" = SAY_CHANNEL_THRALL))
		return FALSE
