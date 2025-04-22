// haine wuz heer
// I got rid of all the various message bullshit in here
// it's more organized and makes the code easier to read imo

/* Understanding Op Stages
Step 1 - dont
Step 2 - uhg, fine

Most organs are in the chest and most organs use patient.organHolder.chest.op_stage (ranges from 0.0 to 2.0) to determine the current state of the chest
To operate on organs you need to open the chest. To do that you use tools in a specific order to increment chest op_stage.
The basic combo is Scalpel -> Scissors to operate on most chest organs (chest op_stage 1 and 2).
And finally suture resets the op_stage to zero (representing closing the cuts you've made), though for reasons you might need to do it more than once.
So op_stage is a number that tells you how cut up the meatbag is.

Step 3 - the exceptions

Removing a head is done with patient.organHolder.head.op _stage and represents cuts to the neck. 3.0 is just before removing a head.

Brain and skull use patient.organHolder.head.scalp_op_stage , ranging from 0.0 to 5.0 and is used to track an incisions in the top of the head/scalp.
3.0 is right before brain removal, 4 is a missing brain, 5 is before skull removal. Skull must be there to add a brain, adding a brain resets the stage to 3

Eyes use the op_stage on each eyeball (patient.organHolder.left_eye.op_stage for example)

Finally Sutures on the head heal these back to op_stage 0.0 in a speicifc order: neck, scalp, right eye, left eye, (closes bleeding)

limbs are their own thing not included here.
*/

// chest item whitelist, because some things are more important than being reasonable
var/global/list/chestitem_whitelist = list(/obj/item/gnomechompski, /obj/item/gnomechompski/elf, /obj/item/gnomechompski/mummified)

// ~make procs 4 everything~

/proc/headSurgeryCheck(var/mob/living/carbon/human/patient as mob)
	if (!patient) // did we not get passed a patient?
		return FALSE
	if (!ishuman(patient)) // is the patient not a human?
		return FALSE

	if (patient.head && patient.head.c_flags & COVERSEYES) // does the patient have a head, and on their head they have something covering their eyes?
		return FALSE
	else if (patient.wear_mask && patient.wear_mask.c_flags & COVERSEYES) // does the patient have a mask, and their mask covers their eyes?
		return FALSE
/*	else if (patient.glasses && patient.glasses.c_flags & COVERSEYES) // does the patient have glasses, and their glasses, uh, cover their eyes?
		return FALSE
*/
	else // if all else fails?
		return TRUE // head surgery is okay

/proc/create_blood_sploosh(var/turf/T)
	var/obj/itemspecialeffect/impact/blood/blood_effect = new /obj/itemspecialeffect/impact/blood
	if (blood_effect)
		blood_effect.setup(get_turf(T))

/obj/item/proc/surgeryConfusion(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob, var/damage as num)
	if (!patient || !surgeon)
		return
	if (!ishuman(patient))
		return
	if (!damage)
		damage = rand(25,75)

	var/target_area = zone_sel2name[surgeon.zone_sel.selecting]

	if (prob(33)) // if they REALLY fuck up
		var/fluff = pick("", "confident ", "quick ", "agile ", "flamboyant ", "nimble ")
		surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> makes a [fluff]cut into [patient]'s [target_area] with [src]!"),\
			SPAN_ALERT("You make a [fluff]cut into [patient]'s [target_area] with [src]!"),\
			SPAN_ALERT("<b>[surgeon]</b> makes a [fluff]cut into your [target_area] with [src]!"))

		patient.TakeDamage(surgeon.zone_sel.selecting, damage, 0)
		take_bleeding_damage(patient, surgeon, damage, surgery_bleed = TRUE)
		create_blood_sploosh(patient)
		display_slipup_image(surgeon, patient.loc)

		patient.visible_message(SPAN_ALERT("<b>Blood gushes from the incision!</b> That can't have been the correct thing to do!"))
		return

	else
		var/fluff = pick("", "gently ", "carefully ", "lightly ", "trepidly ")
		var/fluff2 = pick("prod", "poke", "jab", "dig")
		var/fluff3 = pick("", " [he_or_she(surgeon)] looks [pick("confused", "unsure", "uncertain")][pick("", " about what [he_or_she(surgeon)]'s doing")].")
		surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> [fluff][fluff2]s at [patient]'s [target_area] with [src].[fluff3]"),\
			SPAN_ALERT("You [fluff][fluff2] at [patient]'s [target_area] with [src]."),\
			SPAN_ALERT("<b>[surgeon]</b> [fluff][fluff2]s at your [target_area] with [src].[fluff3]"))
		return

/proc/calc_screw_up_prob(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob, var/screw_up_prob = 25)
	if (!patient) // did we not get passed a patient?
		return FALSE // uhhh
	if (!ishuman(patient)) // is the patient not a human?
		return FALSE // welp vOv

	if (surgeon.bioHolder.HasEffect("clumsy")) // is the surgeon clumsy?
		screw_up_prob += 35
	if (patient == surgeon) // is the patient doing self-surgery?
		screw_up_prob += 15
	if (patient.jitteriness) // is the patient all twitchy?
		screw_up_prob += 15
	if (surgeon.reagents)
		var/drunken_surgeon = surgeon.reagents.get_reagent_amount("ethanol") // has the surgeon had a drink (or two (or three (or four (etc))))?
		if (drunken_surgeon > 0 && drunken_surgeon < 5) // it steadies the hand a bit
			screw_up_prob -= 10
		else if (drunken_surgeon >= 5) // but too much and that might be bad
			screw_up_prob += 10
			if(surgeon.traitHolder.hasTrait("training_partysurgeon") && drunken_surgeon >= 100)
				screw_up_prob = 0 //ayyyyy

	if (patient.stat) // is the patient dead?
		screw_up_prob -= 30
	if (patient.getStatusDuration("unconscious")) // unable to move?
		screw_up_prob -= 15
	if (patient.sleeping) // asleep?
		screw_up_prob -= 10
	if (patient.getStatusDuration("stunned")) // stunned?
		screw_up_prob -= 5
	if (patient.hasStatus("drowsy")) // sleepy?
		screw_up_prob -= 5

	if (patient.reagents) // check for anesthetics/analgetics
		if (patient.reagents.get_reagent_amount("morphine") >= 10)
			screw_up_prob -= 10
		if (patient.reagents.get_reagent_amount("haloperidol") >= 10)
			screw_up_prob -= 10
		if (patient.reagents.get_reagent_amount("ethanol") >= 5)
			screw_up_prob -= 5
		if (patient.reagents.get_reagent_amount("salicylic_acid") >= 5)
			screw_up_prob -= 5
		if (patient.reagents.get_reagent_amount("antihistamine") >= 5)
			screw_up_prob -= 5

	if (surgeon.traitHolder.hasTrait("training_medical"))
		screw_up_prob = clamp(screw_up_prob, 0, 100) // if they're a doctor they can have no chance to mess up
	else
		screw_up_prob = clamp(screw_up_prob, 5, 100) // otherwise there'll always be a slight chance

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) has screw_up_prob set to [screw_up_prob]</b>")

	return screw_up_prob

/proc/calc_surgery_damage(var/mob/surgeon as mob, var/screw_up_prob = 25, var/damage = 10, var/adj1 = 0.5, adj2 = 200)
	damage = damage * (adj1 + (screw_up_prob / adj2))

	if (surgeon?.traitHolder.hasTrait("training_medical")) // doctor better trained and do less hurt
		damage = max(0, round(damage))
	else
		damage = max(2, round(damage))

	return damage


/obj/item/proc/remove_bandage(mob/living/carbon/human/H, mob/user)
	. = TRUE

	if (!ishuman(H))
		return FALSE

	if (user?.a_intent != INTENT_HELP)
		return FALSE

	if (!islist(H.bandaged) || !length(H.bandaged))
		return FALSE

	var/removing = pick(H.bandaged)
	if (!removing) // ?????
		return FALSE

	user.tri_message(H, SPAN_NOTICE("<b>[user]</b> begins removing [H == user ? "[his_or_her(H)]" : "[H]'s"] bandage."),\
		SPAN_NOTICE("You begin removing [H == user ? "your" : "[H]'s"] bandage."),\
		SPAN_NOTICE("[H == user ? "You begin" : "<b>[user]</b> begins"] removing your bandage."))

	if (!ON_COOLDOWN(src, "bandage_removal_sound", 0.5 SECONDS))
		playsound(src, 'sound/items/Scissor.ogg', 100, TRUE)

	SETUP_GENERIC_ACTIONBAR(user, H, 5 SECONDS, /mob/living/carbon/human/proc/on_bandage_removal, list(user, removing), src.icon, src.icon_state, null,
		list(INTERRUPT_MOVE, INTERRUPT_ATTACKED, INTERRUPT_STUNNED, INTERRUPT_ACTION))


/*
/* ============================= */
/* ---------- SCALPEL ---------- */
/* ============================= */

/obj/item/proc/scalpel_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!ishuman(patient))
		return FALSE

	if (!patient.organHolder)
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!"), \
		SPAN_ALERT("You fumble and stab yourself in the eye with [src]!"))
		surgeon.bioHolder.AddEffect("blind")
		surgeon.changeStatus("knockdown", 4 SECONDS)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, null, damage)
		return TRUE

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return FALSE

	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15) * surgCheck/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(15,25) * surgCheck/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SCALPEL - INTENTIONAL SLIPUP ---------- */

	if (surgeon.a_intent == INTENT_DISARM)
		boutput(surgeon, SPAN_NOTICE("You mess up [patient]'s surgery on purpose."))
		do_slipup(surgeon, patient, "chest", damage_high, fluff)
		return TRUE

/* ---------- SCALPEL - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (!headSurgeryCheck(patient))
			surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return TRUE

		if (!patient.organHolder.head)
			boutput(surgeon, SPAN_ALERT("[patient] doesn't have a head!"))
			return FALSE

		if (surgeon.a_intent == INTENT_HARM)
			if (patient.organHolder.head.op_stage == 0.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts the skin of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck open with [src]!"),\
					SPAN_ALERT("You cut the skin of [surgeon == patient ? "your" : "[patient]'s"] neck open with [src]!"), \
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] the skin of your neck open with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.op_stage = 1
				return TRUE

			else if (patient.organHolder.head.op_stage == 2)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_high, fluff2)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> slices the tissue around [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] spine with [src]!"),\
					SPAN_ALERT("You slice the tissue around [surgeon == patient ? "your" : "[patient]'s"] spine with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You slice" : "<b>[surgeon]</b> slices"] the tissue around your spine with [src]!"))

				patient.TakeDamage("head", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.op_stage = 3
				return TRUE

		else if (patient.organHolder.right_eye && patient.organHolder.right_eye.op_stage == 1.0 && surgeon.find_in_hand(src, "right"))
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

			if (prob(screw_up_prob))
				do_slipup(surgeon, patient, "head", damage_low, fluff)
				return TRUE

			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts away the flesh holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye in with [src]!"),\
				SPAN_ALERT("You cut away the flesh holding [surgeon == patient ? "your" : "[patient]'s"] right eye in with [src]!"), \
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the flesh holding your right eye in with [src]!"))

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
			patient.organHolder.right_eye.op_stage = 2
			return TRUE

		else if (patient.organHolder.left_eye && patient.organHolder.left_eye.op_stage == 1.0 && surgeon.find_in_hand(src, "left"))
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

			if (prob(screw_up_prob))
				do_slipup(surgeon, patient, "head", damage_low, fluff)
				return TRUE

			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts away the flesh holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] left eye in with [src]!"),\
				SPAN_ALERT("You cut away the flesh holding [surgeon == patient ? "your" : "[patient]'s"] left eye in with [src]!"), \
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the flesh holding your left eye in with [src]!"))

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
			patient.organHolder.left_eye.op_stage = 2
			return TRUE

		else if (patient.organHolder.head.scalp_op_stage <= 4.0)
			if (patient.organHolder.head.scalp_op_stage == 0.0)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head open with [src]!"),\
					SPAN_ALERT("You cut [surgeon == patient ? "your" : "[patient]'s"] head open with [src]!"), \
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your head open with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.scalp_op_stage = 1
				return TRUE

			else if (patient.organHolder.head.scalp_op_stage == 2)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_high, fluff2)
					return TRUE

				if (patient.organHolder.brain)
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> removes the connections to [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain with [src]!"),\
						SPAN_ALERT("You remove [surgeon == patient ? "your" : "[patient]'s"] connections to [surgeon == patient ? "your" : "[his_or_her(patient)]"] brain with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] the connections to your brain with [src]!"))
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> opens the area around [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain cavity with [src]!"),\
						SPAN_ALERT("You open the area around [surgeon == patient ? "your" : "[patient]'s"] brain cavity with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You open" : "<b>[surgeon]</b> opens"] the area around your brain cavity with [src]!"))

				patient.TakeDamage("head", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.scalp_op_stage = 3
				return TRUE
			else if (patient.organHolder.head.scalp_op_stage == 4.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				if (patient.organHolder.skull)
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull away from the skin with [src]!"),\
						SPAN_ALERT("You cut [surgeon == patient ? "your" : "[patient]'s"] skull away from the skin with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your skull away from the skin with [src]!"))
				else
					// If the skull is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> opens [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull cavity with [src]!"),\
						SPAN_ALERT("You open [surgeon == patient ? "your" : "[patient]'s"] skull cavity with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You open" : "<b>[surgeon]</b> opens"] your skull cavity with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.scalp_op_stage = 5
				return TRUE

			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE
		else
			return FALSE


/* ---------- SCALPEL - BUTT ---------- */
	if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == INTENT_GRAB)
		switch (patient.organHolder.back_op_stage)
			if (BACK_SURGERY_CLOSED)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "chest", damage_low, fluff)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] lower back open with [src]!"),\
					SPAN_ALERT("You cut [surgeon == patient ? "your" : "[patient]'s"] lower back open with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your lower back open with [src]!"))

				patient.TakeDamage("chest", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.back_op_stage = BACK_SURGERY_STEP_ONE
				return TRUE

			if (BACK_SURGERY_STEP_TWO)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "chest", damage_high, fluff2)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] intestines with [src]!"),\
					SPAN_ALERT("You sever [surgeon == patient ? "your" : "[patient]'s"] intestines with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your intestines with [src]!"))

				patient.TakeDamage("chest", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.back_op_stage = BACK_SURGERY_OPENED
				return TRUE

			if (BACK_SURGERY_OPENED)
				if (!patient.organHolder.build_back_surgery_buttons())
					boutput(surgeon, "[patient] has no butt or tail!")
					return TRUE
				surgeon.showContextActions(patient.organHolder.back_contexts, patient, patient.organHolder.contextLayout)
				return TRUE
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE

/* ---------- SCALPEL - IMPLANT ---------- */
	else if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == INTENT_HELP)
		if (length(patient.implant) > 0)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src]!"),\
				SPAN_ALERT("You cut into [surgeon == patient ? "your" : "[patient]'s"] chest with [src]!"),\
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] into your chest with [src]!"))

			for (var/obj/item/implant/projectile/I in patient.implant)
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts out \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!"),\
					SPAN_ALERT("You cut out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out \an [I] from you with [src]!"))

				I.on_remove(patient)
				patient.implant.Remove(I)
				I.set_loc(patient.loc)
				// offset approximately around chest area, based on cutting over operating table
				I.pixel_x = rand(-2, 5)
				I.pixel_y = rand(-6, 1)
				return TRUE

		if (patient.organHolder.chest)
			switch (patient.organHolder.chest.op_stage)
				if (0)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
					if (prob(screw_up_prob))
						do_slipup(surgeon, patient, "chest", damage_low, fluff)
						return TRUE

					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> makes a cut on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src]!"),\
						SPAN_ALERT("You make a cut on [surgeon == patient ? "your" : "[patient]'s"] chest with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You make a cut" : "<b>[surgeon]</b> makes a cut"] on chest with [src]!"))
					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
					patient.organHolder.chest.op_stage ++
					patient.chest_cavity_clamped = FALSE	//Start bleeding all over the place until we are clamped or sutured
					patient.visible_message(SPAN_ALERT("[patient] begins bleeding profusely from [his_or_her(patient)] open chest wound. Clamping the bleeders may alleviate this issue."))
					return TRUE
				if (1)
					src.surgeryConfusion(patient, surgeon, damage_high)
					return TRUE
				if (2)
					if (!patient.organHolder.build_region_buttons())
						boutput(surgeon, "[patient] has no more organs!")
						return TRUE
					surgeon.showContextActions(patient.organHolder.contexts, patient, patient.organHolder.contextLayout)
					return TRUE

				if (3 to INFINITY)
					boutput(surgeon, SPAN_ALERT("[patient]'s op_stage is above intended parameters. Dial 1-800 CODER."))
					return TRUE
		else
			return FALSE

/* ---------- SCALPEL - LIMBS ---------- */

	else if (surgeon.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg"))
		var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (istype(surgery_limb))
			if (surgery_limb.surgery(src))
				return TRUE
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE
	else
		return FALSE

/* ========================= */
/* ---------- SAW ---------- */
/* ========================= */

/obj/item/proc/saw_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	if (!ishuman(patient))
		return FALSE

	if (!patient.organHolder)
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> mishandles [src] and cuts [him_or_her(surgeon)]self!"),\
		SPAN_ALERT("You mishandle [src] and cut yourself!"))
		surgeon.changeStatus("knockdown", 1 SECOND)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(10, 20)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, damage)
		return TRUE

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return FALSE


	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(10,20) * surgCheck /*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(20,30) * surgCheck /*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SAW - INTENTIONAL SLIPUP ---------- */

	if (surgeon.a_intent == INTENT_DISARM)
		do_slipup(surgeon, patient, "chest", damage_high, fluff2)
		boutput(surgeon, SPAN_NOTICE("You mess up [patient]'s surgery on purpose."))
		return TRUE

/* ---------- SAW - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (!headSurgeryCheck(patient))
			surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return TRUE

		if (!patient.organHolder.head)
			boutput(surgeon, SPAN_ALERT("[patient] doesn't have a head!"))
			return FALSE

		if (surgeon.a_intent == INTENT_HARM)
			if (patient.organHolder.head.op_stage == 1.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "chest", damage_low, fluff)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> severs most of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck with [src]!"),\
					SPAN_ALERT("You sever most of [surgeon == patient ? "your" : "[patient]'s"] neck with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] most of your neck with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.op_stage = 2
				return TRUE

			else if (patient.organHolder.head.op_stage == 3.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "chest", damage_low, fluff)
					return TRUE

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws through the last of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head's connections to [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] body with [src]!"),\
					SPAN_ALERT("You saw through the last of [surgeon == patient ? "your" : "[patient]'s"] head's connections to [surgeon == patient ? "your" : "[his_or_her(patient)]"] body with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through the last of your head's connection to your body with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				if (patient.organHolder.brain)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s head and brain with [src].")
					patient.death()
				patient.organHolder.drop_organ("head")
				return TRUE

			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE

		else
			if (patient.organHolder.head.scalp_op_stage == 1.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				var/missing_fluff = ""
				if (!patient.organHolder.skull)
					// If the skull is gone, but the suture site was closed and we're re-opening
					missing_fluff = pick("region", "area")

				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull [missing_fluff] with [src]!"),\
					SPAN_ALERT("You saw open [surgeon == patient ? "your" : "[patient]'s"] skull [missing_fluff] with [src]!"),\
					SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your skull [missing_fluff] with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.organHolder.head.scalp_op_stage = 2
				return TRUE

			else if (patient.organHolder.head.scalp_op_stage == 3.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				if (patient.organHolder.brain)
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain's connection to the spine with [src]!"),\
						SPAN_ALERT("You sever [surgeon == patient ? "your" : "[patient]'s"] brain's connection to the spine with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your brain's connection to the spine with [src]!"))

					patient.organHolder.drop_organ("brain")
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain cavity with [src]!"),\
						SPAN_ALERT("You cut open [surgeon == patient ? "your" : "[patient]'s"] brain cavity with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You cut open" : "<b>[surgeon]</b> cuts open "] your brain cavity with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s brain with [src].")
				patient.death()
				patient.organHolder.head.scalp_op_stage = 4
				return TRUE

			else if (patient.organHolder.head.scalp_op_stage == 5.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

				if (prob(screw_up_prob))
					do_slipup(surgeon, patient, "head", damage_low, fluff)
					return TRUE

				if (patient.organHolder.skull)
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull out with [src]!"),\
						SPAN_ALERT("You saw [surgeon == patient ? "your" : "[patient]'s"] skull out with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] your skull out with [src]!"))

					patient.visible_message(SPAN_ALERT("<b>[patient]</b>'s head collapses into a useless pile of skin with no skull to keep it in its proper shape!"),\
					SPAN_ALERT("Your head collapses into a useless pile of skin with no skull to keep it in its proper shape!"))
					patient.organHolder.drop_organ("skull")
				else
					// If the skull is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws the top of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head open with [src]!"),\
						SPAN_ALERT("You saw the top of [surgeon == patient ? "your" : "[patient]'s"] head open with [src]!"),\
						SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] the top of your head open with [src]!"))

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
				patient.real_name = "Unknown"
				patient.unlock_medal("Red Hood", 1)
				patient.set_clothing_icon_dirty()
				return TRUE
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE

/* ---------- SAW - ribcage ---------- */

	else if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == INTENT_HELP)
		if (patient.organHolder.chest)
			switch (patient.organHolder.chest.op_stage)
				if (0 to 1)
					src.surgeryConfusion(patient, surgeon, damage_high)
					return TRUE
				if (2)
					if (!patient.organHolder.build_region_buttons())
						boutput(surgeon, "[patient] has no more organs!")
						return TRUE
					surgeon.showContextActions(patient.organHolder.contexts, patient, patient.organHolder.contextLayout)
					return TRUE
				if (3 to INFINITY)
					boutput(surgeon, SPAN_ALERT("[patient]'s op_stage is above intended parameters. Dial 1-800 CODER."))
					return TRUE
		else
			return FALSE

/* ---------- SAW - LIMBS ---------- */

	else if (surgeon.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg"))
		var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (istype(surgery_limb))
			if (surgery_limb.surgery(src))
				return TRUE
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return TRUE
	else
		return FALSE

/* ============================ */
/* ---------- SUTURE ---------- */
/* ============================ */

/obj/item/proc/suture_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	if (!ishuman(patient))
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pricks [his_or_her(surgeon)] finger with [src]!"),\
		SPAN_ALERT("You prick your finger with [src]"))

		//surgeon.bioHolder.AddEffect("blind") // oh my god I'm the biggest idiot ever I forgot to get rid of this part
		// I'm not deleting it I'm just commenting it out so my shame will be eternal and perhaps future generations of coders can learn from my mistake
		// - Haine
		surgeon.changeStatus("knockdown", 4 SECONDS)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(1, 10)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, damage)
		return TRUE

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return FALSE

/* ---------- SUTURE - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (patient.organHolder && patient.organHolder.head && patient.organHolder.head.op_stage > 0.0)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your neck closed with [src]."))

			patient.organHolder.head.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else if (patient.organHolder && patient.organHolder.head && patient.organHolder.head.scalp_op_stage > 0.0)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head closed with [src]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] head closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your head closed with [src]."))

			patient.organHolder.head.scalp_op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else if (patient.organHolder && patient.organHolder.right_eye && patient.organHolder.right_eye.op_stage > 0.0)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye socket closed with [src]."),\
				SPAN_NOTICE("You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] right eye socket closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your right eye socket closed with [src]."))

			patient.organHolder.right_eye.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))

		else if (patient.organHolder && patient.organHolder.left_eye && patient.organHolder.left_eye.op_stage > 0.0)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] left eye socket closed with [src]."),\
				SPAN_NOTICE("You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] left eye socket closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your left eye socket closed with [src]."))

			patient.organHolder.left_eye.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))

		else if (patient.bleeding)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src]."),\
				"You sew [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].",\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your wounds closed with [src]."))

			random_brute_damage(patient, 2 * surgCheck * surgCheck)
			repair_bleeding_damage(patient, 100, 10)
			return TRUE

		else
			return FALSE

/* ---------- SUTURE - CHEST ---------- */

	else if (surgeon.zone_sel.selecting == "chest")

		if (patient.organHolder?.chest?.op_stage > 1 && patient.chest_item != null && patient.chest_item_sewn == 0 && surgeon.a_intent == "grab")
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the [patient.chest_item] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity with [src]."),\
				SPAN_NOTICE("You sew the [patient.chest_item] securely into [surgeon == patient ? "your" : "[patient]'s"] chest cavity with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the [patient.chest_item] into your chest cavity with [src]."))

			patient.chest_item_sewn = 1
			patient.TakeDamage("chest", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else if (patient.organHolder.chest && patient.organHolder.chest.op_stage > 0.0)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest closed with [src]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] chest closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your chest closed with [src]."))

			patient.organHolder.chest.op_stage = 0
			patient.organHolder.close_surgery_regions()
			patient.TakeDamage("chest", 2, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else if (patient.organHolder.back_op_stage > BACK_SURGERY_CLOSED && surgeon.a_intent == "grab")
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your butt closed with [src]."))

			patient.organHolder.back_op_stage = BACK_SURGERY_CLOSED
			patient.TakeDamage("chest", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else if (patient.bleeding)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src]."),\
				"You sew [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].",\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your wounds closed with [src]."))

			random_brute_damage(patient, 2 * surgCheck * surgCheck)
			repair_bleeding_damage(patient, 100, 10)
			return TRUE

		else
			return FALSE
	else

		if (surgeon.zone_sel.selecting in patient.limbs.vars) //ugly copy paste from stapler
			var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
			if (istype(surgery_limb) && surgery_limb.remove_stage)
				surgery_limb.surgery(src)
			return

		return FALSE

/* ============================= */
/* ---------- CAUTERY ---------- */
/* ============================= */

// right now this is just for cauterizing butt wounds in case someone wants to, uhh, do that, I guess
// okay I gotta make this proc work differently than the others because holy shit all those return 1/return 0s are driving me batty

/obj/item/proc/cautery_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob, var/damage as num, var/lit = 1)
	if (!ishuman(patient))
		return FALSE

	if (patient.is_heat_resistant())
		patient.visible_message(SPAN_ALERT("<b>Nothing happens!</b>"))
		return FALSE

	if (!surgeon)
		surgeon = patient

	if (!damage)
		damage = rand(5, 15)

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> burns [him_or_her(surgeon)]self with [src]!"),\
		SPAN_ALERT("You burn yourself with [src]"))

		JOB_XP(surgeon, "Clown", 1)
		surgeon.changeStatus("knockdown", 4 SECONDS)
		random_burn_damage(surgeon, damage)
		return TRUE

	src.add_fingerprint(surgeon)

	var/quick_surgery = 0

	if (surgeryCheck(patient, surgeon))
		quick_surgery = 1

/* ---------- CAUTERY - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head" && patient.organHolder && patient.organHolder.head && patient.organHolder.head.op_stage > 0.0)

		if (!lit)
			surgeon.tri_message(patient, "<b>[surgeon]</b> tries to use [src] on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"You try to use [src] on [surgeon == patient ? "your" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"[patient == surgeon ? "You try" : "<b>[surgeon]</b> tries"] to use [src] on your incision, but [src] isn't lit! Sheesh.")
			return FALSE

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [src]."))

			patient.organHolder.head.op_stage = 0
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your neck closed with [src]."))

			if (do_mob(patient, surgeon, max(100 - (damage * 2)), 0))
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src]."),\
					SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src]."),\
					SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [src]."))

				patient.organHolder.head.op_stage = 0
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return TRUE

			else
				surgeon.show_text("<b>You were interrupted!</b>", "red")
				return TRUE

/* ---------- CAUTERY - BUTT ---------- */

	else if (surgeon.zone_sel.selecting == "chest" && patient.organHolder.back_op_stage > BACK_SURGERY_CLOSED)

		if (!lit)
			surgeon.tri_message(patient, "<b>[surgeon]</b> tries to use [src] on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"You try to use [src] on [surgeon == patient ? "your" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"[patient == surgeon ? "You try" : "<b>[surgeon]</b> tries"] to use [src] on your incision, but [src] isn't lit! Sheesh.")
			return FALSE

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your butt closed with [src]."))

			patient.organHolder.back_op_stage = BACK_SURGERY_CLOSED
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return TRUE

		else
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your butt closed with [src]."))

			if (do_mob(patient, surgeon, max(100 - (damage * 2)), 0))
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src]."),\
					SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src]."),\
					SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your butt closed with [src]."))

				patient.organHolder.back_op_stage = BACK_SURGERY_CLOSED
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return TRUE

			else
				surgeon.show_text("<b>You were interrupted!</b>", "red")
				return TRUE

/* ---------- CAUTERY - BLEEDING ---------- */

	else if (patient.bleeding)

		if (!lit)
			surgeon.tri_message(patient, "<b>[surgeon]</b> tries to use [src] on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds, but [src] isn't lit! Sheesh.",\
				"You try to use [src] on [surgeon == patient ? "your" : "[patient]'s"] wounds, but [src] isn't lit! Sheesh.",\
				"[patient == surgeon ? "You try" : "<b>[surgeon]</b> tries"] to use [src] on your wounds, but [src] isn't lit! Sheesh.")
			return TRUE

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src]."),\
				SPAN_NOTICE("You cauterize [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You cauterizes" : "<b>[surgeon]</b> cauterizes"] your wounds closed with [src]."))

			repair_bleeding_damage(patient, 100, 10)
			return TRUE

		else
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> begins cauterizing [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src]."),\
				SPAN_NOTICE("You begin cauterizing [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing your wounds closed with [src]."))

			var/dur = max(patient.bleeding * 2 - damage * 0.2, 0) SECONDS
			if (dur == 0)
				repair_bleeding_damage(patient, 100, 10)
			else
				SETUP_GENERIC_ACTIONBAR(patient, src, dur, /obj/item/proc/cauterize_wound, list(surgeon, patient), src.icon, src.icon_state, null,
					INTERRUPT_ACT | INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_ATTACKED | INTERRUPT_STUNNED)
			return TRUE

	else
		return FALSE

/obj/item/proc/cauterize_wound(mob/surgeon, mob/living/carbon/human/patient)
	surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src]."),
		SPAN_NOTICE("You cauterize [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src]."),
		SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] your wounds closed with [src]."))

	repair_bleeding_damage(patient, 100, 10)

/* =========================== */
/* ---------- SPOON ---------- */
/* =========================== */

/obj/item/proc/spoon_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!ishuman(patient))
		return FALSE

	if (!patient.organHolder)
		return FALSE
	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return FALSE

	// fluff2 is for things that do more damage: nicking the optic nerve is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " jabs [src] in too far")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " jabs [src] in too far", " nicks the optic nerve")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15) * surgCheck/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(15,25) * surgCheck/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SPOON - EYES ---------- */



		else if (target_eye.op_stage == 2)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)

			if (prob(screw_up_prob))
				do_slipup(surgeon, patient, "head", damage_high, fluff2)
				return TRUE

			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> removes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] eye with [src]!"),\
				SPAN_ALERT("You remove [surgeon == patient ? "your" : "[patient]'s"] [target_side] eye with [src]!"),\
				SPAN_ALERT("[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] your [target_side] eye with [src]!"))

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = TRUE)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [target_side] eye with [src].")

			if (target_eye == patient.organHolder.right_eye)
				patient.organHolder.drop_organ("right_eye")
			else if (target_eye == patient.organHolder.left_eye)
				patient.organHolder.drop_organ("left_eye")
			return TRUE

		else
			src.surgeryConfusion(patient, surgeon, damage_high)
			return TRUE

////////////////////////////////////////////////////////////////////

/* ============================= */
/* ------------ SNIP ----------- */
/* ============================= */

/obj/item/proc/snip_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!surgeryCheck(patient, surgeon))
		return FALSE

	if (!patient.organHolder)
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!"), \
		SPAN_ALERT("You fumble and stab yourself in the eye with [src]!"))
		surgeon.bioHolder.AddEffect("blind")
		patient.changeStatus("knockdown", 0.4 SECONDS)

		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, null, damage)
		return TRUE

	src.add_fingerprint(surgeon)


	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	//Snipping is a lot safer than other types of surgery. Is it because snips are the One True Surgery Tool? Maybe, maybe not. Who can say.
	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,5)/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15)/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SNIP - INTENTIONAL SLIPUP ---------- */

	if (surgeon.a_intent == INTENT_DISARM)
		do_slipup(surgeon, patient, "chest", damage_high, fluff2)
		boutput(surgeon, SPAN_NOTICE("You mess up [patient]'s surgery on purpose."))
		return TRUE


////////////////////////////////////////////////////////////////////

/* ================================ */
/* ------------ CROWBAR ----------- */
/* ================================ */

/obj/item/proc/pry_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!isskeleton(patient) || !patient.organHolder || surgeon.a_intent == INTENT_HARM)
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> fumbles and clubs [him_or_her(surgeon)]self upside the head with [src]!"), \
		SPAN_ALERT("You fumble and club yourself in the head with [src]!"))
		patient.changeStatus("knockdown", 0.4 SECONDS)

		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		return FALSE

	src.add_fingerprint(surgeon)

	// fluff2 is for things that do more damage: smacking an artery is included in the choices
	//var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches")
	//var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " smacks an artery")

	//var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	//Crowbarring is a lot safer than other types of surgery. Is it because the crowbar is a pretty lousy weaspon? Yes, it is
	//var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,2)/*, src.adj1, src.adj2*/)
	//var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(3,4)/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon])</b>")

	if (surgeon.zone_sel.selecting == "chest")
		playsound(patient, 'sound/items/Crowbar.ogg', 50, TRUE)	// Dont really need much surgery to remove a bone from a skeleton
		surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> jams one end of the [src] just below [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] sacrum and pries [his_or_her(patient)] tail off!"),\
			SPAN_ALERT("You jam one end of the [src] just below [surgeon == patient ? "your" : "[patient]'s"] sacrum and pries [his_or_her(patient)] tail off!"),\
			SPAN_ALERT("[patient == surgeon ? "You jam" : "<b>[surgeon]</b> jams"] one end of the [src] just below your sacrum and [patient == surgeon ? "pry" : "pries"] your tail off!"))
		if (patient.organHolder.tail)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s skeleton tail with [src].")
		patient.organHolder.drop_organ("tail")
		return TRUE

	else if (surgeon.zone_sel.selecting == "head" && patient.organHolder.head)
		var/obj/item/organ/head/H = patient.organHolder.head
		if (H.op_stage != 1)
			return FALSE
		H.op_stage = 2
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pries [H] loose with [src]."))
		playsound(patient, 'sound/items/Crowbar.ogg', 50, TRUE)
		return TRUE

	else if (surgeon.zone_sel.selecting in patient.limbs.vars)
		var/obj/item/parts/limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (!isskeletonlimb(limb) || limb.remove_stage != 1)
			return FALSE
		limb.remove_stage = 2
		surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pries [limb] loose with [src]."))
		playsound(patient, 'sound/items/Crowbar.ogg', 50, TRUE)
		return TRUE

*/
///You messed up. Cause damage and spawn some indicators.
/proc/do_slipup(var/mob/surgeon, var/mob/patient, var/damage_target, var/damage_value, var/fluff_text)
	surgeon.visible_message(SPAN_ALERT("<b>[surgeon][fluff_text]!</b>"))
	patient.TakeDamage(damage_target, damage_value, 0)
	take_bleeding_damage(patient, surgeon, damage_value, surgery_bleed = TRUE)
	create_blood_sploosh(patient)
	display_slipup_image(surgeon, patient.loc)

///Spawns an image above a patient when you slip up. Only the surgeon sees it.
/proc/display_slipup_image(var/mob/surgeon, var/loc)
	if (!surgeon || !loc)
		return
	if (surgeon.bioHolder.HasEffect("clumsy"))
		var/slipup_icon_state = "slipup_clown1"
		if (prob(1))
			//You lose your medical license
			slipup_icon_state = "slipup_clown3"
		else if (prob(10))
			slipup_icon_state = "slipup_clown2"
		new/obj/decal/slipup/clumsy(loc, slipup_icon_state, surgeon)
	else
		new/obj/decal/slipup(loc, "slipup", surgeon)

/datum/action/bar/icon/remove_organ
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	resumable = FALSE
	var/mob/surgeon = null
	var/mob/living/carbon/human/target = null
	///The path of the organ we want to remove
	var/organ_path = null
	///The name of the organ we want to remove (for display purposes)
	var/organ_name = null
	var/surgeon_duration = 2 SECONDS
	///Are we ripping out the organ without any tools?
	var/rip_out_organ = FALSE //I don't care that i lack tools, i'm gonna rip out this heart with my bare hands!
	///How long does it take to rip out an organ?
	var/rip_out_duration = 10 SECONDS
	var/datum/surgery/surgery = null
	New(mob, patient, organ, name, surgery, hand_surgery = FALSE, new_icon = null, new_icon_state = null)
		src.surgeon = mob
		src.target = patient
		src.organ_path = organ
		src.organ_name = name
		src.surgery = surgery
		if (!src.surgery.surgery_conditions_met(src.surgeon))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (hand_surgery)
			src.rip_out_organ = hand_surgery
			src.duration = src.rip_out_duration
		if (new_icon && new_icon_state)
			src.icon = new_icon
			src.icon_state = new_icon_state
		if (src.surgeon.traitHolder.hasTrait("training_medical") && !rip_out_organ)
			src.duration = src.surgeon_duration
		..()

	onStart()
		..()
		if(BOUNDS_DIST(src.surgeon, src.target) > 0 || src.surgeon == null || src.target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.rip_out_organ)
			src.surgeon.visible_message(SPAN_ALERT("[src.surgeon] begins ripping out [src.target]'s [src.organ_name] with [his_or_her(src.surgeon)] bare hands!"))
			ON_COOLDOWN(src.surgeon, "rip_out_damage", 4 SECOND)
		else
			src.surgeon.visible_message(SPAN_NOTICE("[src.surgeon] begins cutting out [src.target]'s [src.organ_name]."))

	onUpdate()
		..()
		if(BOUNDS_DIST(surgeon, target) > 0 || surgeon == null || target == null || !surgery.surgery_conditions_met(src.surgeon))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!ON_COOLDOWN(src.surgeon, "rip_out_damage", 4 SECONDS))
			random_brute_damage(src.target, rand(10, 20))
			take_bleeding_damage(src.target, src.surgeon, rand(5, 15))

	onInterrupt()
		..()
		var/damage = calc_surgery_damage(src.surgeon, damage = rand(5,10))
		var/slipup_message = " messes up mid-surgery"
		if (src.rip_out_organ)
			slipup_message = " loses [his_or_her(src.surgeon)] grips on the [src.organ_name]"
		do_slipup(src.surgeon, src.target, "chest", damage, slipup_message)

	onEnd()
		..()
		if(BOUNDS_DIST(src.surgeon, src.target) > 0 || src.target == null || src.surgeon == null || !src.target.organHolder?.organ_list[src.organ_path])
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.rip_out_organ)
			var/obj/item/organ/the_organ = src.target.organHolder.drop_organ(src.organ_path)
			the_organ.take_damage(rand(20, 35), 0, 0)
			src.surgeon.put_in_hand_or_drop(the_organ)
			src.surgeon.visible_message(SPAN_NOTICE("[src.surgeon] rips out [src.target]'s [src.organ_name]."))
			playsound(src.target, 'sound/impact_sounds/Slimy_Hit_3.ogg', 50, 1, -1)
			if (isalive(src.target) && prob(30))
				src.target.emote("scream")
			src.target.TakeDamage("chest", rand(25, 45), 0)

			take_bleeding_damage(src.target, src.surgeon, rand(15, 20))
		else
			var/screw_up_prob = calc_screw_up_prob(src.target, src.surgeon)
			if (prob(screw_up_prob))
				var/damage = calc_surgery_damage(src.surgeon, screw_up_prob, rand(5,10))
				do_slipup(src.surgeon, src.target, "chest", damage, pick(" messes up", " slips up", " makes a mess", " stabs directly into [src.target]'s organs"))
				return
			src.surgeon.tri_message(src.target, SPAN_NOTICE("<b>[src.surgeon]</b> takes out [src.surgeon == src.target ? "[his_or_her(src.target)]" : "[src.target]'s"] [src.organ_name]."),\
				SPAN_NOTICE("You take out [src.surgeon == src.target ? "your" : "[src.target]'s"] [src.organ_name]."),\
				SPAN_ALERT("[src.target == src.surgeon ? "You take" : "<b>[src.surgeon]</b> takes"] out your [src.organ_name]!"))
			logTheThing(LOG_COMBAT, src.surgeon, "removed [constructTarget(src.target,"combat")]'s [src.organ_path].")
			src.target.organHolder.drop_organ(src.organ_path)
			playsound(src.target, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
			src.target.TakeDamage("chest", rand(5, 15), 0)

/datum/action/bar/icon/clamp_bleeders
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	resumable = FALSE
	var/mob/surgeon = null
	var/mob/living/carbon/human/target = null
	var/surgeon_duration = 1.5 SECONDS
	var/datum/surgery/surgery = null

	New(mob, patient, surgery)
		src.surgeon = mob
		src.target = patient
		src.surgery = surgery
		if (!src.surgery.surgery_conditions_met(src.surgeon))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.surgeon.traitHolder.hasTrait("training_medical"))
			src.duration = src.surgeon_duration
		..()

	onStart()
		..()
		if(BOUNDS_DIST(src.surgeon, src.target) > 0 || src.surgeon == null || src.target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		else
			src.surgeon.visible_message(SPAN_NOTICE("[src.surgeon] begins clamping the bleeders on [src.target]'s chest wound."))

	onUpdate()
		..()
		if(BOUNDS_DIST(surgeon, target) > 0 || surgeon == null || target == null || !surgery.surgery_conditions_met(src.surgeon))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		var/damage = calc_surgery_damage(src.surgeon, damage = rand(5,10))
		do_slipup(src.surgeon, src.target, "chest", damage, " clamps a little too hard")

	onEnd()
		..()
		if(BOUNDS_DIST(src.surgeon, src.target) > 0 || src.target == null || src.surgeon == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.surgeon.tri_message(src.target, SPAN_NOTICE("<b>[src.surgeon]</b> clamps the bleeders on [src.surgeon == src.target ? "[his_or_her(src.target)]" : "[src.target]'s"] chest wound."),\
			SPAN_NOTICE("You clamp the bleeders on [src.surgeon == src.target ? "your" : "[src.target]'s"] chest wound."),\
			SPAN_ALERT("[src.target == src.surgeon ? "You clamp" : "<b>[src.surgeon]</b> clamps"] the bleeders on your chest wound!"))
		var/chest_stage = src.target.surgeryHolder.get_surgery_progress("torso_surgery")
		if (chest_stage > 0)
			src.target.chest_cavity_clamped = TRUE
		if (src.target.bleeding)
			repair_bleeding_damage(src.target, 50, rand(2,5))
