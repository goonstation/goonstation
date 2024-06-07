// -----------------------------------
// Way to end your life as a dead skeleton head
// -----------------------------------

/datum/targetable/critter/abandon_ship
	name = "Abandon ship!"
	desc = "Pick up your little organs and run! This kills the skeleton."
	icon = 'icons/mob/ghost_observer_abilities.dmi'
	icon_state = "skeleton_suicide"
	cooldown = 0
	targeted = 0
	needs_turf = 0

	cast()
		..()
		var/mob/living/skele = holder.owner
		var/obj/item/skull = skele.loc
		ThrowRandom(skull, 1)
		skele.set_loc(get_turf(skele))
		skull.contents -= skele
		SPAWN(10)
			skele.emote("scream")
		SPAWN(40)
			skele.gib()
