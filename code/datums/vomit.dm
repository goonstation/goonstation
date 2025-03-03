ABSTRACT_TYPE(/datum/vomit_behavior)
/datum/vomit_behavior
	/// Return a cleanable type path from here to use it as the vomit, return FALSE to defer to default vomit
	proc/vomit(mob/M)
		return FALSE

/datum/vomit_behavior/spider
	vomit(mob/M)
		random_brute_damage(M, rand(4))
		M.visible_message(SPAN_ALERT("<b>[M]</b> [pick("barfs", "hurls", "pukes", "vomits")] up some [pick("spiders", "weird black stuff", "strange black goop", "wriggling black goo")]![pick("", " Gross!", " Ew!", " Nasty!")]"),\
		SPAN_ALERT("<b>OH [pick("SHIT", "FUCK", "GOD")] YOU JUST [pick("BARFED", "HURLED", "PUKED", "VOMITED")] SPIDERS[pick("!", " FUCK THAT'S GROSS!", " SHIT THAT'S NASTY!", " OH GOD EW!")][pick("", "!", "!!", "!!!", "!!!!")]</b>"))
		if (!(locate(/obj/decal/cleanable/vomit/spiders) in get_turf(M)))
			if (prob(5))
				new /mob/living/critter/spider/baby(M)
			else
				new /mob/living/critter/spider/baby/nice(M)
		return /obj/decal/cleanable/vomit/spiders

/datum/vomit_behavior/ricin
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("[M] vomits a lot of blood!"))
		return /obj/decal/cleanable/blood/splatter

/datum/vomit_behavior/flock
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("[M] vomits up a viscous teal liquid!"), SPAN_ALERT("You vomit up a viscous teal liquid!"))
		return /obj/decal/cleanable/flockdrone_debris/fluid
