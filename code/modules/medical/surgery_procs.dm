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
