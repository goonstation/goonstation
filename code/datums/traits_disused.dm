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

// People use this to identify changelings and people wearing disguises and I can't be bothered
// to rewrite a whole bunch of stuff for what is essentially something very specific and minor.
/obj/trait/observant
	name = "Observant (-1)"
	cleanName = "Observant"
	desc = "Examining people will show you their traits."
	id = "observant"
	points = -1
	isPositive = 1
	unselectable = 1

/obj/trait/roboears
	name = "Robotic ears (-4) \[Body\]"
	cleanName = "Robotic ears"
	desc = "You can hear, understand and speak robotic languages."
	id = "roboears"
	category = "body"
	points = -4
	isPositive = 1
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
	isPositive = 0
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
	isPositive = 1
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
	isPositive = 1
	unselectable = 1

/obj/trait/reversal
	name = "Damage Reversal"
	cleanName = "Damage Reversal"
	desc = "You are now healed by things that would otherwise cause brute, burn, toxin, or brain damage. On the flipside, you are harmed by medicines."
	id = "reversal" //We can't have oxydamage in there, otherwise they'd immediately start suffocating.
	points = -1
	isPositive = 1
	unselectable = 1

/obj/trait/badgenes
	name = "Bad Genes (+2) \[Genetics\]"
	cleanName = "Bad Genes"
	desc = "You spawn with 2 random, permanent, bad mutations."
	id = "badgenes"
	points = 2
	isPositive = 0
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

			SPAWN_DBG(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return

/obj/trait/goodgenes
	name = "Good Genes (-3) \[Genetics\]"
	cleanName = "Good Genes"
	desc = "You spawn with 2 random good mutations."
	id = "goodgenes"
	points = -3
	isPositive = 0
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

			SPAWN_DBG(4 SECONDS) owner.add_memory(str) //FUCK THIS SPAWN FUCK FUUUCK
		return


//RANDOM SNIPPETS AND RUBBISH BELOW

/*
/obj/trait/testTrait1//
	name = "Lizard (-1) \[Race\]"
	desc = "You spawn as a lizard person thing. Yep.\nThere you go. Finally you can live out your dream."
	id = "lizard"
	points = -1
	isPositive = 1
	category = "race"

	onAdd(var/mob/owner)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_mutantrace(/datum/mutantrace/lizard)
		return

/obj/trait/testTrait2
	name = "Cough (+1) \[Race\]"
	desc = "You suffer from a chronic cough."
	id = "cough"
	points = 1
	isPositive = 0
	category = "race"

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("cough")
		return

/obj/trait/testTrait3
	name = "Swedish (-1)"
	desc = "You are from sweden. Meat balls and so on."
	id = "swedish"//
	points = -1
	isPositive = 1

	onAdd(var/mob/owner)
		owner.bioHolder?.AddEffect("accent_swedish")
		return
*/

			/*
			var/mob/living/carbon/human/target = null
			for(var/mob/living/carbon/human/M in range(1, owner))
				if(M == owner || !ishuman(M)) continue
				target = M
				break
			if(target)
				if(!actions.hasAction(owner, "otheritem") && !owner.equipped())
					var/trgSlot = null
					if(target.get_slot(target.slot_l_hand)) trgSlot = target.slot_l_hand
					else if(target.get_slot(target.slot_r_hand)) trgSlot = target.slot_r_hand
					else if(target.get_slot(target.slot_wear_id)) trgSlot = target.slot_wear_id
					else if(target.get_slot(target.slot_l_store)) trgSlot = target.slot_l_store
					else if(target.get_slot(target.slot_r_store)) trgSlot = target.slot_r_store
					else if(target.get_slot(target.slot_head)) trgSlot = target.slot_head
					else if(target.get_slot(target.slot_back)) trgSlot = target.slot_back
					else if(target.get_slot(target.slot_w_uniform)) trgSlot = target.slot_w_uniform
					if(trgSlot)
						actions.start(new/datum/action/bar/icon/otherItem( owner, target, null, trgSlot ) , owner)
			*/
