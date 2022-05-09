///////////////////////////////////
//	Nascent abilities, morph into other critters
///////////////////////////////////
/datum/targetable/critter/nascent/become_commander
	name = "Become commander"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return 1
		holder.owner.make_critter(/mob/living/critter/skeleton_commander)

/datum/targetable/critter/nascent/become_voidhound
	name = "Become voidhound"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return 1
		holder.owner.make_critter(/mob/living/critter/voidhound)

/datum/targetable/critter/nascent/become_spiker
	name = "Become ranged"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return 1
		holder.owner.make_critter(/mob/living/critter/spiker)

