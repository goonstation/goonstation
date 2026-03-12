/datum/ailment/disability/clumsy
	name = "Dyspraxia"
	max_stages = 1
	cure_flags = CURE_UNKNOWN
	affected_species = list("Human")
	cluwne
		cure_flags = CURE_CUSTOM
		cure_desc = "Decursing" // Bible

/datum/ailment/disability/clumsy/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	var/mob/living/M = D.affected_mob
	if (probmult(6))
		boutput(M, SPAN_ALERT("Your hands twitch."))
		var/h = M.hand
		M.hand = 0
		M.drop_item()
		M.hand = 1
		M.drop_item()
		M.hand = h
	if (probmult(3))
		M.visible_message(SPAN_ALERT("<B>[M.name]</B> stumbles and falls!"))
		M.changeStatus("stunned", 1 SECOND)
		M.changeStatus("knockdown", 1 SECOND)
		if (ishuman(M) && prob(25))
			var/mob/living/carbon/human/H = M
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				boutput(H, SPAN_ALERT("You bash your head on the ground."))
				H.TakeDamageAccountArmor("head", 5, 0, 0, DAMAGE_BLUNT)
				H.take_brain_damage(2)
				H.changeStatus("unconscious", 10 SECONDS)
				H.make_jittery(1000)
			else
				boutput(H, SPAN_ALERT("You bash your head on the ground - good thing you were wearing a helmet!"))
	if (probmult(1))
		boutput(M, SPAN_ALERT("You forget to breathe."))
		M.take_oxygen_deprivation(33)
