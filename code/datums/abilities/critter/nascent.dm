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
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/skeleton_commander/S = new /mob/living/critter/skeleton_commander(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		qdel(N)

/datum/targetable/critter/nascent/become_voidhound
	name = "Become voidhound"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return 1
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/voidhound/S = new /mob/living/critter/voidhound(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		qdel(N)

/datum/targetable/critter/nascent/become_spiker
	name = "Become ranged"
	desc = "Become a commander"
	icon_state = "clown_spider_bite"
	cooldown = 0
	targeted = 0

	cast()
		if (..())
			return 1
		var/mob/wraith/W = null
		if(istype(holder.owner, /mob/living/critter/nascent))
			var/mob/living/critter/nascent/N = holder.owner
			if(N.master != null)
				W = N.master
		var/mob/living/critter/spiker/S = new /mob/living/critter/spiker(get_turf(holder.owner), W)
		var/mob/living/critter/nascent/N = holder.owner
		holder.owner.mind.transfer_to(S)
		qdel(N)

