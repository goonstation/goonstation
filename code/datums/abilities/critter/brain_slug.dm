/datum/targetable/critter/brain_slug/slither
	name = "Slither away"
	desc = "Expel some mucus from your body to trip threats."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 30 SECONDS
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"
	//Todo add a sound
	cast()
		if (..())
			return TRUE
		holder.owner.AddComponent(/datum/component/floor_slime, "superlube", 75, 75)
		var/datum/component/C = holder.owner.GetComponent(/datum/component/floor_slime)
		spawn(7 SECONDS)
			C?.RemoveComponent(/datum/component/floor_slime)


	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/brain_slug/infest_host
	name = "Infest a host"
	desc = "Take control of an animal host or of a dead body."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "ratbite"
	cooldown = 20 SECOND
	targeted = 1
	start_on_cooldown = 1
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"
//Todo add small_animals mobs + critters. Make sure they can all die.
//Turn obj critters into mob critters, not gonna be pretty.
//Turn corpses back into a living thing and add counter + abilities. Kill the revived corpse when the counter ends.
//Abilities should cost the same points that keep the body alive.
//
//maybe ban boogiebots and morty?
//Ban mentormouse and adminmouse.
//Ability to spread? Think it over. Prolly not.
	cast(atom/target)
		if (..())
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return TRUE
		var/mob/MT = target
		var/mob/living/critter/wraith/plaguerat/P = holder.owner
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>",\
		"<span class='combat'><b>You bite [MT]!</b></span>")
		P.venom_bite(MT)
		return 0

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
