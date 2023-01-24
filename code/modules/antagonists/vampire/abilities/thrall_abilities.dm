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
	restricted_area_check = 0
	unlock_message = ""

	incapacitation_check()
		.= 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampiric_thrall/H = holder

		if (!M)
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return

		if (!H.master)
			boutput(M, "<span class='alert'>Your link to your master has been severed!</span>")
			return 1

		.= H.msg_to_master(message)

		return 0
