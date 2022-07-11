//UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW////UNSELECTABLE BELOW//


/*
/obj/trait/lizard
	name = "Lizard (-1) \[Race\]"
	desc = "You spawn as a lizard. Remember; you have no rights as a human if you choose this trait!"
	cleanName = "Lizard"
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

/obj/trait/color_shift
	name = "Color Shift (0)"
	cleanName = "Color Shift"
	desc = "You are more depressing on the outside but more colorful on the inside."
	id = "color_shift"
	unselectable = TRUE
	points = 0

	onAdd(var/mob/owner) //Not enforcing any of them with onLife because Hemochromia is a multi-mutation thing while Achromia would darken the skin color every tick until it's pitch black.
		if(owner.bioHolder)
			owner.bioHolder.AddEffect("achromia", 0, 0, 0, 1)
			owner.bioHolder.AddEffect("hemochromia_unknown", 0, 0, 0, 1)

// Phobias - Undetermined Border

/obj/trait/phobia
	name = "Phobias suck"
	cleanName = "Phobias suck"
	desc = "Wow, phobias are no fun! Report this to a coder please."
	unselectable = TRUE

/obj/trait/phobia/space
	name = "Spacephobia (+1) \[Phobia\]"
	cleanName = "Spacephobia"
	desc = "Being in space scares you. A lot. While in space you might panic or faint."
	id = "spacephobia"
	points = 1

	onLife(var/mob/owner)
		if(!owner.stat && can_act(owner) && istype(owner.loc, /turf/space))
			if(prob(2))
				owner.emote("faint")
				owner.changeStatus("paralysis", 8 SECONDS)
			else if (prob(8))
				owner.emote("scream")
				owner.changeStatus("stunned", 2 SECONDS)


// People use this to identify changelings and people wearing disguises and I can't be bothered
// to rewrite a whole bunch of stuff for what is essentially something very specific and minor.
/obj/trait/observant
	name = "Observant (-1)"
	cleanName = "Observant"
	desc = "Examining people will show you their traits."
	id = "observant"
	points = -1
	unselectable = 1

/obj/trait/roboears
	name = "Robotic ears (-4) \[Body\]"
	cleanName = "Robotic ears"
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

/obj/trait/deathwish
	name = "Death wish (+8) \[Stats\]"
	cleanName = "Death wish"
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
		return

	onLife(var/mob/owner) //Just to be safe.
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.max_health = 50
		return

/obj/trait/glasscannon
	name = "Glass cannon (-2) \[Stats\]"
	cleanName = "Glass cannon"
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

/obj/trait/soggy
	name = "Overly soggy (-1)"
	cleanName = "Overly soggy"
	desc = "When you die you explode into gibs and drop everything you were carrying."
	id = "soggy"
	points = -1
	unselectable = 1

/obj/trait/reversal
	name = "Damage Reversal"
	cleanName = "Damage Reversal"
	desc = "You are now healed by things that would otherwise cause brute, burn, toxin, or brain damage. On the flipside, you are harmed by medicines."
	id = "reversal" //We can't have oxydamage in there, otherwise they'd immediately start suffocating.
	points = -1
	unselectable = 1

/obj/trait/badgenes
	name = "Bad Genes (+2) \[Genetics\]"
	cleanName = "Bad Genes"
	desc = "You spawn with 2 random, permanent, bad mutations."
	id = "badgenes"
	points = 2
	category = "genetics"
	unselectable = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			var/str = "I have the following bad mutations: "

			var/curr_id = owner.bioHolder.RandomEffect("bad", 1)
			var/datum/bioEffect/curr = owner.bioHolder.effects[curr_id]
			curr.curable_by_mutadone = 0
			curr.can_reclaim = 0
			curr.can_scramble = 0
			str += " [curr.name],"
			curr_id = owner.bioHolder.RandomEffect("bad", 1)
			curr = owner.bioHolder.effects[curr_id]
			curr.curable_by_mutadone = 0
			curr.can_reclaim = 0
			curr.can_scramble = 0
			str += " [curr.name]"

			SPAWN(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return

/obj/trait/goodgenes
	name = "Good Genes (-3) \[Genetics\]"
	cleanName = "Good Genes"
	desc = "You spawn with 2 random good mutations."
	id = "goodgenes"
	points = -3
	category = "genetics"
	unselectable = 1

	onAdd(var/mob/owner)
		if(owner.bioHolder)
			var/str = "I have the following good mutations: "

			var/curr_id = owner.bioHolder.RandomEffect("good", 1)
			var/datum/bioEffect/curr = owner.bioHolder.effects[curr_id]
			str += " [curr.name],"
			curr_id = owner.bioHolder.RandomEffect("good", 1)
			curr = owner.bioHolder.effects[curr_id]
			str += " [curr.name]"

			SPAWN(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return
