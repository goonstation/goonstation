TYPEINFO(/mob/living/intangible/brainmob)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN, SPEECH_OUTPUT_EQUIPPED)

/mob/living/intangible/brainmob
	//Sort of like a holder mob for brain-triggered assemblies
	name = "brain thing"
	real_name = "brain thing"
	icon = 'icons/obj/items/organs/brain.dmi'
	icon_state = "cool_brain"
	canmove = 0
	nodamage = 1

	var/obj/item/device/brainjar/container = null

	speech_verb_say = "warbles"
	speech_verb_ask = "wonks"
	speech_verb_exclaim = "screeches"

	ghostize()
		var/mob/dead/observer/O = ..()
		if(O)
			O.icon = 'icons/obj/items/organs/brain.dmi'
			O.icon_state = "cool_brain"
			O.alpha = 155

		return O
