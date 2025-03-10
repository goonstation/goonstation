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

/datum/vomit_behavior/blood
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("[M] vomits a lot of blood!"))
		bleed(M, rand(5,8))
		return /obj/decal/cleanable/blood/splatter

/datum/vomit_behavior/flock
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("[M] vomits up a viscous teal liquid!"), SPAN_ALERT("You vomit up a viscous teal liquid!"))
		return /obj/decal/cleanable/flockdrone_debris/fluid

/datum/vomit_behavior/green_goo
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("[M] vomits up some green goo."))
		return /obj/decal/cleanable/greenpuke

/datum/vomit_behavior/owl
	vomit(mob/M)
		new /mob/living/critter/small_animal/bird/owl(get_turf(M))
		M.visible_message(SPAN_ALERT("<b>[M] [pick("horks", "vomits", "spews")] up an Owl!</b>"))

//this is a little bit dumb and should probably be separate behaviours but I want to maintain existing functionality exactly
/datum/vomit_behavior/hyper
	vomit(mob/M)
		var/datum/reagent/harmful/hyper_vomitium/vomitium = M.reagents.get_reagent("hyper_vomitium")
		if (vomitium.cycles > 10 && prob(35) && !ON_COOLDOWN(M, "hyper_vomitium_blood_vomit", 9 SECONDS)) //when after the 10th cycle, you have a chance of vomiting blood and suffering high toxin damage
			M.visible_message(SPAN_ALERT("[M] vomits a concerning amount of blood all over themselves!"))
			var/blood_loss = rand(10,20)
			bleed(M, blood_loss, blood_loss)
			M.take_toxin_damage(6)
			M.change_misstep_chance(10)
			M.stuttering += rand(3,6)
			. = /obj/decal/cleanable/blood/splatter
		else
			M.stuttering += rand(0,2)
			M.change_misstep_chance(6)
			M.take_toxin_damage(3)
		if(vomitium.cycles > 20 && isliving(M) && !ON_COOLDOWN(M, "hyper_vomitium_organ_loss", 6 SECONDS))
			var/mob/living/victim = M
			var/datum/organHolder/vomitable_organHolder = victim.organHolder
			var/picked_organ = src.grab_available_organ(vomitable_organHolder, vomitium.cycles)
			if(picked_organ)
				var/obj/item/organ/organ_to_loose = vomitable_organHolder.get_organ(picked_organ)
				vomitable_organHolder.drop_organ(picked_organ, get_turf(victim))
				M.visible_message(SPAN_ALERT("[M] also vomits out [his_or_her(M)] [organ_to_loose.name]! [pick("WHAT THE FUCK!", "HOLY HECK!", "FRIGGING HELL!")]"))
				var/organ_blood_loss = rand(15,25)
				bleed(M, organ_blood_loss, organ_blood_loss)
				M.change_misstep_chance(5)
				M.setStatusMin("stunned", 2 SECOND)

	proc/grab_available_organ(var/datum/organHolder/vomitable_organHolder, var/cycles_elapsed)
		var/cycles_for_vital_organs = 40 //! the amount of cycles that need to have passed until the target looses a vital organ
		if(!vomitable_organHolder)
			return
		//we a start to build a list with the organs we're able to throw out of our victim
		var/list/available_organs = list()
		available_organs += non_vital_organ_strings
		if(cycles_elapsed > cycles_for_vital_organs)
			//after 40 cycles (8u) this chem has a very high chance to kill by straight out vomiting out the brain or heart
			available_organs += list("brain", "heart")
		//now, we go through each organ and kick out every already missing organ from the list
		for (var/organ in available_organs)
			if(!vomitable_organHolder.get_organ(organ))
				available_organs -= organ
		//after we are finished, we look if organs are left (to account for changelings emptying all out of themselves) and then return out the ejectable organ
		if(length(available_organs))
			return pick(available_organs)
