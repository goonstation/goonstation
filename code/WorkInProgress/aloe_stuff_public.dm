/obj/item/clothing/suit/bio_suit/paramedic/armored/prenerf
	desc = "<i style='color:pink'>My beloved...</i>"

	setupProperties()
		..()
		setProperty("rangedprot", 1.5)

/mob/living/critter/small_animal/bee/aloe_bee
	desc = "It's looking right through you."
	icon_state = "aloebee-wings"
	icon_body = "aloebee"
	icon_state_dead = "aloebee-dead"
	sleeping_icon_state = "aloebee-sleep"
	add_abilities = list(/datum/targetable/critter/bite/bee,
		/datum/targetable/critter/bee_sting/random)

/datum/targetable/critter/bee_sting/random

	cast(atom/target)
		if (..())
			return TRUE
		src.venom2 = pick(all_functional_reagent_ids)
		src.amt2 = rand(1, 10)

