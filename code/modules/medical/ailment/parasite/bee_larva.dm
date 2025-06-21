//IBM note: haha this is the dumbest thing I have ever coded
/datum/ailment/parasite/bee_larva
	name = "Unidentified Foreign Body"
	max_stages = 5
	stage_advance_prob = 8
	affected_species = list("Human", "Monkey")

/datum/ailment/parasite/bee_larva/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if (2, 3)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels sore."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Mucous runs down the back of your throat."))
		if(4)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("Your stomach hurts."))
				if(prob(20))
					affected_mob.take_toxin_damage(1)
		if(5)
			boutput(affected_mob, SPAN_ALERT("You feel something tearing its way out of your stomach..."))
			if (affected_mob.get_toxin_damage() < 30)
				affected_mob.take_toxin_damage(10 * mult)

			if(probmult(40))
				var/obj/critter/domestic_bee_larva/larva = new /obj/critter/domestic_bee_larva (get_turf(affected_mob))
				larva.name = "li'l [affected_mob:real_name]"
				if (affected_mob.bioHolder && affected_mob.bioHolder.mobAppearance)
					larva.color = "[affected_mob.bioHolder.mobAppearance.customizations["hair_bottom"].color]"
					if (!affected_mob.bioHolder.mobAppearance.customizations["hair_bottom"].color)
						larva.color = "#FFFFFF"

				larva.beeMom = affected_mob
				larva.beeMomCkey = affected_mob.ckey

				if (ishuman(affected_mob))
					var/mob/living/carbon/human/human = affected_mob
					if (human.head && !istype(human.head, /obj/item/clothing/head/void_crown))
						var/obj/item/clothing/head/cloned_hat = new human.head.type
						cloned_hat.set_loc(larva)
						larva.stored_hat = cloned_hat

					if (human.mind?.assigned_role == "Mime")
						larva.color = "#ebedeb"
						if (human.bioHolder.HasEffect(/datum/bioEffect/noir))
							larva.custom_bee_type = /obj/critter/domestic_bee/mimebee/noirbee
						else
							larva.custom_bee_type = /obj/critter/domestic_bee/mimebee
					else if (human.mind?.assigned_role == "Clown")
						larva.color = "#ff0033"
						larva.custom_bee_type = /obj/critter/domestic_bee/clownbee
					else if (iscluwne(human))
						larva.custom_bee_type = /obj/critter/domestic_bee/cluwnebee
						larva.color = "#35bf4f"

				playsound(affected_mob.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] horks up a bee larva!  Grody!</b>"), SPAN_ALERT("<b>You cough up...a bee larva. Uhhhhh</b>"))

				affected_mob.cure_disease(D)
