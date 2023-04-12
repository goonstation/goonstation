/datum/targetable/throw/wrestler
	name = "Throw (grab)"
	desc = "Spin a grabbed opponent around and throw them."
	icon_state = "Throw"
	preferred_holder_type = /datum/abilityHolder/wrestler
	cooldown = 20 SECONDS
	start_on_cooldown = TRUE

/datum/targetable/throw/wrestler/fake
	weak = TRUE
