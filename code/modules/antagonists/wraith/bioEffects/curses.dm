////////////////////
//Wraith curses
////////////////////

/datum/bioEffect/blood_curse
	name = "Blood curse"
	desc = "Curse of blood."
	id = "blood_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0

	OnAdd()
		if (ishuman(owner))
			owner.traitHolder?.addTrait("hemophilia")

	OnLife(mult)
		if (probmult(5))
			owner.emote("cough")
			var/turf/T = get_turf(owner)
			new /obj/decal/cleanable/blood/drip(T)
		if (probmult(3))
			owner.visible_message("<span class='alert'>[owner] vomits a lot of blood!</span>")
			playsound(owner.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			bleed(owner, rand(5,8), 5)


	OnRemove()
		if (ishuman(owner))
			owner.traitHolder?.removeTrait("hemophilia")
		. = ..()

/datum/bioEffect/blindness_curse
	name = "Blind curse"
	desc = "Curse of blindness."
	id = "blind_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0

	OnLife(mult)
		if (probmult(8) && ishuman(owner))
			owner.eye_damage += 10
			if (owner.eye_damage > 90)
				owner.emote("blink")
				boutput(owner, "<span class='alert'>A shadowy veil falls over your vision.</span>")
			else if (owner.eye_damage > 50)
				owner.emote("blink")
				boutput(owner, "<span class='alert'>You can't seem to be able to see things clearly anymore.</span>")
			else
				owner.emote("blink")
				boutput(owner, "<span class='notice'>You blink and notice that your vision is blurier than before.<span>")


/datum/bioEffect/weak_curse
	name = "Weakness curse"
	desc = "Curse of enfeeblement."
	id = "weak_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0

	OnAdd()
		if (ishuman(owner))
			owner.setStatus("weakcurse", duration = null)

	OnLife(mult)
		if (probmult(5))
			boutput(owner, "<span class='notice'>You suddenly feel very [pick("winded", "tired")].</span>")
			owner.changeStatus("slowed")
		if (probmult(3))
			boutput(owner, pick("<span class='notice'>Your muscles tense up.</span>", "<span class='notice'>You feel light-headed.</span>", "<span class='notice'>Your legs almost give in.</span>"))
			owner.emote("pale")
		if (probmult(3))
			boutput(owner, pick("<span class='notice'>Your conscience slips.</span>", "<span class='notice'>You feel awfully drowsy.</span>"))
			owner.changeStatus("drowsy", 10 SECONDS)

	OnRemove()
		if (ishuman(owner))
			owner.delStatus("weakcurse")
		. = ..()

/datum/bioEffect/rot_curse	//Also prevents eating entirely.
	name = "Rot curse"
	desc = "Curse of rot."
	id = "rot_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0

	OnAdd()
		if (ishuman(owner))
			owner.bioHolder.AddEffect("stinky")

	OnLife(mult)
		if (probmult(5))
			owner.visible_message("<span class='alert'>[owner] suddenly vomits on the floor!</span>")
			owner.vomit(rand(3,5))
		if (probmult(3))
			owner.emote(pick("cough", "sneeze"))


	OnRemove()
		if (ishuman(owner))
			owner.bioHolder.RemoveEffect("stinky")
		. = ..()
