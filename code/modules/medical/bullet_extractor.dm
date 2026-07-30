/// This tool is mainly used by NanoTrasen Emergency Paramedics. It lets you remove shrapnel from someone whos standing up, at the cost of hurting. Its kind of a pseudo surgery that really hurts.

#define CAUSE_EXPECTED_PAIN(victim, damage)\
	random_brute_damage(victim, damage);\
	take_bleeding_damage(victim, null, damage);\
	victim.emote("scream");

/obj/item/bullet_extractor
	name = "Shrapnel Extractor"
	desc = "An advanced surgeon's tool with multiple robotic limbs capable of extracting shrapnel from a patient in any situation. \
	 Reserved only for desperate conditions due to the high risk of causing minor injuries. \
	 Users often complain the tool has a personality of its own"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "shrapnel_extractor"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "shrapnel_extractor"
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
	move_triggered = FALSE

	var/interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_ACT

	attack(mob/target, mob/user, def_zone, is_special, params)
		if(is_special || !ishuman(target))
			return ..()

		var/mob/living/carbon/human/patient = target

		if (length(patient.implant) == 0)
			boutput(user, SPAN_NOTICE("You wave around the [src], It has nothing to do, it is insulted."))
			return

		SETUP_GENERIC_ACTIONBAR(user, src, 1 SECONDS ,PROC_REF(attempt_extraction), list(patient, user), src.icon, src.icon_state, null, src.interrupt_flags)


	proc/attempt_extraction(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
		var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " accidentally pinches themselves", " had a messy disagreement with the [src]'s robotic arms", "'s medical incompetence is an insult to [src]'s advanced micro electronics")

		var/screw_up_prob = calc_screw_up_prob(patient, surgeon, 10)

		var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,5))
		var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(5,10))

		if (surgeon.bioHolder.HasEffect("clumsy") && prob(30))
			surgeon.visible_message(\
			SPAN_ALERT("<b>[surgeon]</b> Missuses the [src] so much it slaps [surgeon] on [his_or_her(surgeon)] face!"), \
			SPAN_ALERT("You fumble with the [src] and it becomes so insulted with your lack of skill that it slaps you on the face!"))

			surgeon.changeStatus("disorient", 2 SECOND)
			JOB_XP(surgeon, "Clown", 1)

			CAUSE_EXPECTED_PAIN(surgeon, damage_high)

			return

		if (surgeon.a_intent == INTENT_DISARM)
			boutput(surgeon, SPAN_NOTICE("You intentionally hurt [patient] with the [src], an insult to the craftmanship."))
			do_slipup(surgeon, patient, "chest", damage_high, fluff)

			return

		playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

		if(prob(screw_up_prob))
			do_slipup(surgeon, patient, "chest", damage_low, fluff)

			return

		for (var/obj/item/implant/projectile/I in patient.implant)
			surgeon.tri_message(patient, \
				SPAN_ALERT("<b>[surgeon]</b> reaches with the [src] into [patient == surgeon ? his_or_her(patient) : "[patient]'s"] wound and pull \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : patient] with the [src]!"),\
				SPAN_ALERT("You pluck out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [src]!"),\
				SPAN_ALERT("[patient == surgeon ? "You pluck" : "<b>[surgeon]</b> plucks"] out \an [I] from you with [src]!"))

			I.on_remove(patient)
			patient.implant.Remove(I)

			// The shrapnel gets pulled to the user
			I.set_loc(surgeon.loc)
			I.pixel_x = rand(-2, 5)
			I.pixel_y = rand(-6, 1)

			// This tool is sofisticated, but operating on a patiant whos awake and moving is risky
			CAUSE_EXPECTED_PAIN(patient, damage_low)

			return


#undef CAUSE_EXPECTED_PAIN
