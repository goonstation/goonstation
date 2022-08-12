/datum/ailment/disability/clumsy
	name = "Dyspraxia"
	max_stages = 1
	cure = "Unknown"
	affected_species = list("Human")
	cluwne
		cure = "Decursing"
		reagentcure = list("water_holy")

/datum/ailment/disability/clumsy/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	var/mob/living/M = D.affected_mob
	if (probmult(6))
		boutput(M, "<span class='alert'>Your hands twitch.</span>")
		var/h = M.hand
		M.hand = 0
		M.drop_item()
		M.hand = 1
		M.drop_item()
		M.hand = h
	if (probmult(3))
		M.visible_message("<span class='alert'><B>[M.name]</B> stumbles and falls!</span>")
		M.changeStatus("stunned", 1 SECOND)
		M.changeStatus("weakened", 1 SECOND)
		if (ishuman(M) && prob(25))
			var/mob/living/carbon/human/H = M
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				boutput(H, "<span class='alert'>You bash your head on the ground.</span>")
				H.TakeDamageAccountArmor("head", 5, 0, 0, DAMAGE_BLUNT)
				H.take_brain_damage(2)
				H.changeStatus("paralysis", 10 SECONDS)
				H.make_jittery(1000)
			else
				boutput(H, "<span class='alert'>You bash your head on the ground - good thing you were wearing a helmet!</span>")
	if (probmult(1))
		boutput(M, "<span class='alert'>You forget to breathe.</span>")
		M.take_oxygen_deprivation(33)
