
/obj/item/bullet_extractor
	name = "Shrapnel Extractor"
	desc = "An advanced surgeon's tool, used to extract shrapnel from the body of a standing person, used in desperate situations due to patiant movment often causing additonal harm. Users often complain the tool has a personality of it's own."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "null_scalpel"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "null_scalpel"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SNIPPING
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_2.ogg'
	force = 5
	w_class = W_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	move_triggered = 1

	attack(mob/target, mob/user, def_zone, is_special, params)
		if(is_special || !ishuman(target) || !attempt_extraction(target, user) || user.a_intent != INTENT_HELP)
			return ..()


	proc/attempt_extraction(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
		var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " accidentally pinches themselves", " had a messy disagreement with the [src]'s robotic arms", "'s medical incompetence is an insult to [src]'s advanced micro electronics")

		var/screw_up_prob = calc_screw_up_prob(patient, surgeon, 1) // The tool is smarter then you, ok?

		var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,5))
		var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(5,10))

		if (surgeon.bioHolder.HasEffect("clumsy") && prob(30))
			surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumble so much with the [src] pricks [him_or_her(surgeon)] them!"), \
			SPAN_ALERT("You fumble and the [src], insulted, pricks you!"))
			surgeon.changeStatus("disorient", 2 SECOND)
			JOB_XP(surgeon, "Clown", 1)

			random_brute_damage(surgeon, damage_low)
			take_bleeding_damage(surgeon, null, damage_low)

			return FALSE

		if (surgeon.a_intent == INTENT_DISARM)
			boutput(surgeon, SPAN_NOTICE("You intentionally hurt [patient] with the [src], an insult to the craftmanship."))
			do_slipup(surgeon, patient, "chest", damage_high, fluff)

			return TRUE

		if (length(patient.implant) == 0)
			boutput(surgeon, SPAN_NOTICE("You wave around with the [src], It has nothing to do, it is insulted."))

			return TRUE

		playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

		for (var/obj/item/implant/projectile/I in patient.implant)
			surgeon.tri_message(patient, \
				SPAN_ALERT("<b>[surgeon]</b> reaches with the [src] into [patient == surgeon ? his_or_her(patient) : "[patient]'s"] wound and pull \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : patient] with the [src]!"),\
				SPAN_ALERT("You pluck out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [src]!"),\
				SPAN_ALERT("[patient == surgeon ? "You pluck" : "<b>[surgeon]</b> plucjs"] out \an [I] from you with [src]!"))

			I.on_remove(patient)
			patient.implant.Remove(I)
			I.set_loc(patient.loc)

			I.pixel_x = rand(-2, 5)
			I.pixel_y = rand(-6, 1)

			// This tool is sofisticated, but operating on a patiant whos awake and moving is risky
			if(calc_screw_up_prob(patient, surgeon, 40))
				random_brute_damage(patient, patient)
				take_bleeding_damage(patient, null, patient)

			return TRUE


