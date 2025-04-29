//UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW//


/*
/datum/trait/lizard
	desc = "You spawn as a lizard. Remember; you have no rights as a human if you choose this trait!"
	name = "Lizard"
	id = "lizard"
	points = -1
	isPositive = 1
	category = "race"

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_mutantrace(/datum/mutantrace/lizard)
		return
*/

/datum/trait/color_shift
	name = "Color Shift"
	desc = "You are more depressing on the outside but more colorful on the inside."
	id = "color_shift"
	unselectable = TRUE
	points = 0

	onAdd(var/mob/owner) //Not enforcing any of them with onLife because Hemochromia is a multi-mutation thing while Achromia would darken the skin color every tick until it's pitch black.
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("achromia", 0, 0, 0, 1)
			owner.bioHolder.AddEffect("hemochromia_unknown", 0, 0, 0, 1)

// Phobias - Undetermined Border

/datum/trait/phobia
	name = "Phobias suck"
	desc = "Wow, phobias are no fun! Report this to a coder please."
	unselectable = TRUE

/datum/trait/phobia/space
	name = "Spacephobia"
	desc = "Being in space scares you. A lot. While in space you might panic or faint."
	id = "spacephobia"
	points = 1

	onLife(var/mob/owner)
		if(!owner.stat && can_act(owner) && istype(owner.loc, /turf/space))
			if(prob(2))
				owner.emote("faint")
				owner.changeStatus("unconscious", 8 SECONDS)
			else if (prob(8))
				owner.emote("scream")
				owner.changeStatus("stunned", 2 SECONDS)


// People use this to identify changelings and people wearing disguises and I can't be bothered
// to rewrite a whole bunch of stuff for what is essentially something very specific and minor.
/datum/trait/observant
	name = "Observant"
	desc = "Examining people will show you their traits."
	id = "observant"
	points = -1
	unselectable = 1

/datum/trait/roboears
	name = "Robotic ears"
	desc = "You can hear, understand and speak robotic languages."
	id = "roboears"
	category = "body"
	points = -4
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.robot_talk_understand = 1
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.robot_talk_understand = 1
		return
/*
	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.organHolder != null)
				H.organHolder.receive_organ(var/obj/item/I, var/type, var/op_stage = 0.0)
		return
*/

/datum/trait/deathwish
	name = "Death wish"
	desc = "You take double damage from most things and have half your normal health."
	id = "deathwish"
	category = "stats"
	points = 8
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 50
			H.health = 50
			health_update_queue |= H
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 50
		return

	onRemove(mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = initial(H.max_health)
			health_update_queue |= H
		. = ..()

/datum/trait/glasscannon
	name = "Glass cannon"
	desc = "You have 1 stamina max. Attacks no longer cost you stamina and\nyou deal double the normal damage with most melee weapons."
	id = "glasscannon"
	category = "stats"
	points = -2
	unselectable = 1

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.add_stam_mod_max("trait", -(STAMINA_MAX - 1))
		return

/datum/trait/soggy
	name = "Overly soggy"
	desc = "When you die you explode into gibs and drop everything you were carrying."
	id = "soggy"
	points = -1
	unselectable = 1

/datum/trait/reversal
	name = "Damage Reversal"
	desc = "You are now healed by things that would otherwise cause brute, burn, toxin, or brain damage. On the flipside, you are harmed by medicines."
	id = "reversal" //We can't have oxydamage in there, otherwise they'd immediately start suffocating.
	points = -1
	unselectable = 1
