// haine wuz heer
// I got rid of all the various message bullshit in here
// it's more organized and makes the code easier to read imo


/* Understanding Op Stages
Step 1 - dont
Step 2 - uhg, fine

Most organs are in the chest and most organs use patient.organHolder.chest.op_stage (ranges from 0.0 to 9.0) to determine the current state of the chest
The combo of chest op_stage and tool tells it what the next action is. Think of it like a flowchart or tree where op_stage is a node.

Example -
Scissors on a fresh chest, chest op_stage advances to 1.0. Next use scissors and chest op_stage advances to 3.0.
From 3.0 you can remove the appendix or liver, with scissors and scalpel, but removing an organ does not change the op_stage.
This is so when inserting organs we can check that the op_stage is at the same point needed to remove the organ. I.E. the same cuts have been made to the torso.
And finally suture resets the op_stage to zero (representing closing the cuts you've made), though for reasons you might need to do it more than once.
So op_stage is a number that tells you what holes are in the meatbag and where.

Step 3 - the exceptions

The butt has it's own variable to count op_stage, patient.butt_op_stage (not on organHolder), which goes from 0 to 5
butt_op_stage 3 is just before a butt is removed. 4 is a missing butt, and 5 is a cauterized gap where the butt was. When a butt is put back on, it goes back to 3

Removing a head is done with patient.organHolder.head.op_stage and represents cuts to the neck. 3.0 is just before removing a head.

Brain and skull use patient.organHolder.head.scalp_op_stage , ranging from 0.0 to 5.0 and is used to track an incisions in the top of the head/scalp.
3.0 is right before brain removal, 4 is a missing brain, 5 is before skull removal. Skull must be there to add a brain, adding a brain resets the stage to 3

Eyes use the op_stage on each eyeball (patient.organHolder.left_eye.op_stage for example)

Finally Sutures on the head heal these back to op_stage 0.0 in a speicifc order: neck, scalp, right eye, left eye, (closes bleeding)

limbs are their own thing not included here.
*/

// chest item whitelist, because some things are more important than being reasonable
var/global/list/chestitem_whitelist = list(/obj/item/gnomechompski, /obj/item/gnomechompski/elf, /obj/item/gnomechompski/mummified)

// ~make procs 4 everything~
/proc/surgeryCheck(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	if (!patient) // did we not get passed a patient?
		return 0 // surgery is not okay
	if (!ishuman(patient)) // is the patient not a human?
		return 0 // surgery is not okay

	if (locate(/obj/machinery/optable, patient.loc)) // is the patient on an optable and lying?
		if(patient.lying)
			return 1 // surgery is okay
		else if (patient == surgeon)
			return 3.5 // surgery is okay but hurts more

	else if ((locate(/obj/stool/bed, patient.loc) || locate(/obj/table, patient.loc)) && (patient.getStatusDuration("paralysis") || patient.stat)) // is the patient on a table and paralyzed or dead?
		return 1 // surgery is okay
	else if (patient.reagents && (patient.reagents.get_reagent_amount("ethanol") > 40 || patient.reagents.get_reagent_amount("morphine") > 5) && (patient == surgeon || (locate(/obj/stool/bed, patient.loc) && patient.lying))) // is the patient really drunk and also the surgeon?
		return 1 // surgery is okay

	else // if all else fails?
		return 0 // surgery is not okay

/proc/headSurgeryCheck(var/mob/living/carbon/human/patient as mob)
	if (!patient) // did we not get passed a patient?
		return 0 // head surgery is not okay
	if (!ishuman(patient)) // is the patient not a human?
		return 0 // head surgery is not okay

	if (patient.head && patient.head.c_flags & COVERSEYES) // does the patient have a head, and on their head they have something covering their eyes?
		return 0 // head surgery is not okay
	else if (patient.wear_mask && patient.wear_mask.c_flags & COVERSEYES) // does the patient have a mask, and their mask covers their eyes?
		return 0 // head surgery is not okay
/*	else if (patient.glasses && patient.glasses.c_flags & COVERSEYES) // does the patient have glasses, and their glasses, uh, cover their eyes?
		return 0 // head surgery is not okay
*/
	else // if all else fails?
		return 1 // head surgery is okay

#define CREATE_BLOOD_SPLOOSH(T) var/obj/itemspecialeffect/impact/E = new /obj/itemspecialeffect/impact/blood;\
			if (E){E.setup(get_turf(T));}

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
		surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> makes a [fluff]cut into [patient]'s [target_area] with [src]!</span>",\
			"<span class='alert'>You make a [fluff]cut into [patient]'s [target_area] with [src]!</span>",\
			"<span class='alert'><b>[surgeon]</b> makes a [fluff]cut into your [target_area] with [src]!</span>")

		patient.TakeDamage(surgeon.zone_sel.selecting, damage, 0)
		take_bleeding_damage(patient, surgeon, damage)
		CREATE_BLOOD_SPLOOSH(patient)

		patient.visible_message("<span class='alert'><b>Blood gushes from the incision!</b> That can't have been the correct thing to do!</span>")
		return

	else
		var/fluff = pick("", "gently ", "carefully ", "lightly ", "trepidly ")
		var/fluff2 = pick("prod", "poke", "jab", "dig")
		var/fluff3 = pick("", " [he_or_she(surgeon)] looks [pick("confused", "unsure", "uncertain")][pick("", " about what [he_or_she(surgeon)]'s doing")].")
		surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> [fluff][fluff2]s at [patient]'s [target_area] with [src].[fluff3]</span>",\
			"<span class='alert'>You [fluff][fluff2] at [patient]'s [target_area] with [src].</span>",\
			"<span class='alert'><b>[surgeon]</b> [fluff][fluff2]s at your [target_area] with [src].[fluff3]</span>")
		return

/proc/calc_screw_up_prob(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob, var/screw_up_prob = 25)
	if (!patient) // did we not get passed a patient?
		return 0 // uhhh
	if (!ishuman(patient)) // is the patient not a human?
		return 0 // welp vOv

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
	if (patient.getStatusDuration("paralysis")) // unable to move?
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

/proc/insertChestItem(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	// Check if surgeon is targeting chest while there's a hole in patient's chest
	if (surgeon.zone_sel.selecting == "chest" && patient.chest_cavity_open == 1)
		// Check if patient has item in chest already
		if (patient.chest_item == null)
			// If no item in chest, get surgeon's equipped item
			var/obj/item/chest_item = surgeon.equipped()

			if(chest_item.w_class > W_CLASS_NORMAL && !(chest_item.type in chestitem_whitelist))
				surgeon.show_text("<span class='alert'>[chest_item] is too big to fit into [patient]'s chest cavity.</span>")
				return 1

			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> shoves [chest_item] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest.</span>",\
				"<span class='notice'>You shove [chest_item] into [surgeon == patient ? "your" : "[patient]'s"] chest.</span>",\
				"<span class='notice'>[patient == surgeon ? "You shove" : "<b>[surgeon]</b> shoves"] [chest_item] into your chest.</span>")

			// Move equipped item to patient's chest
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
			chest_item.set_loc(patient)
			patient.chest_item = chest_item

			// Remove item from surgeon
			surgeon.u_equip(chest_item)

		else if (patient.chest_item != null)
			// State that there's already something in the patient's chest.
			surgeon.show_text("<span class='alert'>[patient.chest_item] is already inside [patient]'s chest cavity.</span>")
		return 1
	else
		return 0


/obj/item/proc/remove_bandage(var/mob/living/carbon/human/H as mob, var/mob/user as mob)
	if (!H)
		return 0

	if (!ishuman(H))
		return 0

	if (user && user.a_intent != INTENT_HELP)
		return 0

	if (!islist(H.bandaged) || !length(H.bandaged))
		return 0

	var/removing = pick(H.bandaged)
	if (!removing) // ?????
		return 0

	user.tri_message(H, "<span class='notice'><b>[user]</b> begins removing [H == user ? "[his_or_her(H)]" : "[H]'s"] bandage.</span>",\
		"<span class='notice'>You begin removing [H == user ? "your" : "[H]'s"] bandage.</span>",\
		"<span class='notice'>[H == user ? "You begin" : "<b>[user]</b> begins"] removing your bandage.</span>")

	if (!do_mob(user, H, 50))
		user.show_text("You were interrupted!", "red")
		return 1

	user.tri_message(H, "<span class='notice'><b>[user]</b> removes [H == user ? "[his_or_her(H)]" : "[H]'s"] bandage.</span>",\
		"<span class='notice'>You remove [H == user ? "your" : "[H]'s"] bandage.</span>",\
		"<span class='notice'>[H == user ? "You remove" : "<b>[user]</b> removes"] your bandage.</span>")

	H.bandaged -= removing
	H.update_body()
	return 1

/mob/proc/get_surgery_status(var/zone)
	return 0

/mob/living/carbon/human/get_surgery_status(var/zone)
	if (!src.organHolder)
		DEBUG_MESSAGE("get_surgery_status failed due to [src] having no organHolder")
		return 0

	var/datum/organHolder/oH = src.organHolder
	var/return_thing = 0

	if (!zone || zone == "head")
		if (oH.brain)
			return_thing += oH.brain.op_stage
		else
			return_thing ++

		if (oH.skull)
			return_thing += oH.skull.op_stage
		else
			return_thing ++

		if (oH.head)
			return_thing += oH.head.op_stage
		else
			return_thing ++

	if (!zone || zone == "chest")
		//I'd like to see the heart thing use the chest for surgery. I think it makes more sense than having each organ have a surgery stage...
		// if (oH.chest)
		// 	return_thing += oH.chest.op_stage
		if (oH.chest)
			return_thing += oH.chest.op_stage
		else if (src.butt_op_stage < 5)
			return_thing += src.butt_op_stage

	if (zone in list("l_arm","r_arm","l_leg","r_leg"))
		var/obj/item/parts/surgery_limb = src.limbs.vars[zone]
		if (istype(surgery_limb))
			return_thing += surgery_limb.remove_stage
		else if (!surgery_limb)
			return_thing ++

	if(!zone)
		for(var/actual_zone in list("l_arm","r_arm","l_leg","r_leg"))
			var/obj/item/parts/surgery_limb = src.limbs.vars[actual_zone]
			if (istype(surgery_limb))
				return_thing += surgery_limb.remove_stage
			else if (!surgery_limb)
				return_thing ++

	//DEBUG_MESSAGE("get_surgery_status for [src] returning [return_thing]")
	return return_thing

/* ============================= */
/* ---------- SCALPEL ---------- */
/* ============================= */

/obj/item/proc/scalpel_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!ishuman(patient))
		return 0

	if (!patient.organHolder)
		return 0

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!</span>", \
		"<span class='alert'>You fumble and stab yourself in the eye with [src]!</span>")
		surgeon.bioHolder.AddEffect("blind")
		surgeon.changeStatus("weakened", 4 SECONDS)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, null, damage)
		return 1

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return 0

	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15) * surgCheck/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(15,25) * surgCheck/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SCALPEL - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (!headSurgeryCheck(patient))
			surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return 1

		if (!patient.organHolder.head)
			boutput(surgeon, "<span class='alert'>[patient] doesn't have a head!</span>")
			return 0

		if (surgeon.a_intent == INTENT_HARM)
			if (patient.organHolder.head.op_stage == 0.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts the skin of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck open with [src]!</span>",\
					"<span class='alert'>You cut the skin of [surgeon == patient ? "your" : "[patient]'s"] neck open with [src]!</span>", \
					"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] the skin of your neck open with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.op_stage = 1
				return 1

			else if (patient.organHolder.head.op_stage == 2)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
					patient.TakeDamage("head", damage_high, 0)
					take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> slices the tissue around [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] spine with [src]!</span>",\
					"<span class='alert'>You slice the tissue around [surgeon == patient ? "your" : "[patient]'s"] spine with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You slice" : "<b>[surgeon]</b> slices"] the tissue around your spine with [src]!</span>")

				patient.TakeDamage("head", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.op_stage = 3
				return 1

		else if (patient.organHolder.right_eye && patient.organHolder.right_eye.op_stage == 1.0 && surgeon.find_in_hand(src, "right"))
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts away the flesh holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye in with [src]!</span>",\
				"<span class='alert'>You cut away the flesh holding [surgeon == patient ? "your" : "[patient]'s"] right eye in with [src]!</span>", \
				"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the flesh holding your right eye in with [src]!</span>")

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			patient.organHolder.right_eye.op_stage = 2
			return 1

		else if (patient.organHolder.left_eye && patient.organHolder.left_eye.op_stage == 1.0 && surgeon.find_in_hand(src, "left"))
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts away the flesh holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] left eye in with [src]!</span>",\
				"<span class='alert'>You cut away the flesh holding [surgeon == patient ? "your" : "[patient]'s"] left eye in with [src]!</span>", \
				"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the flesh holding your left eye in with [src]!</span>")

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			patient.organHolder.left_eye.op_stage = 2
			return 1

		else if (patient.organHolder.head.scalp_op_stage <= 4.0)
			if (patient.organHolder.head.scalp_op_stage == 0.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				var/removing_eye = (patient.organHolder.left_eye && patient.organHolder.left_eye.op_stage == 1.0) || (patient.organHolder.right_eye && patient.organHolder.right_eye.op_stage == 1.0)

				if (removing_eye && (surgeon.find_in_hand(src, "left") || surgeon.find_in_hand(src, "right")))
					surgeon.show_text("Wait, which eye was I operating on?")
				else if (removing_eye && surgeon.find_in_hand(src, "middle"))
					surgeon.show_text("Hey, there's no middle eye!")

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head open with [src]!</span>",\
					"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] head open with [src]!</span>", \
					"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your head open with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.scalp_op_stage = 1
				return 1

			else if (patient.organHolder.head.scalp_op_stage == 2)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
					patient.TakeDamage("head", damage_high, 0)
					take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				if (patient.organHolder.brain)
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> removes the connections to [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain with [src]!</span>",\
						"<span class='alert'>You remove [surgeon == patient ? "your" : "[patient]'s"] connections to [surgeon == patient ? "your" : "[his_or_her(patient)]"] brain with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] the connections to your brain with [src]!</span>")
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> opens the area around [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain cavity with [src]!</span>",\
						"<span class='alert'>You open the area around [surgeon == patient ? "your" : "[patient]'s"] brain cavity with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You open" : "<b>[surgeon]</b> opens"] the area around your brain cavity with [src]!</span>")

				patient.TakeDamage("head", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.scalp_op_stage = 3
				return 1
			else if (patient.organHolder.head.scalp_op_stage == 4.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				if (patient.organHolder.skull)
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull away from the skin with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] skull away from the skin with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your skull away from the skin with [src]!</span>")
				else
					// If the skull is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> opens [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull cavity with [src]!</span>",\
						"<span class='alert'>You open [surgeon == patient ? "your" : "[patient]'s"] skull cavity with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You open" : "<b>[surgeon]</b> opens"] your skull cavity with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.scalp_op_stage = 5
				return 1

			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1
		else
			return 0

/* ---------- SCALPEL - BUTT ---------- */
	if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == INTENT_HARM)
		if (patient.butt_op_stage == 0.0)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
				patient.TakeDamage("chest", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt open with [src]!</span>",\
				"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] butt open with [src]!</span>",\
				"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your butt open with [src]!</span>")

			patient.TakeDamage("chest", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			patient.butt_op_stage = 1
			return 1

		else if (patient.butt_op_stage == 2)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
				patient.TakeDamage("chest", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] intestines with [src]!</span>",\
				"<span class='alert'>You sever [surgeon == patient ? "your" : "[patient]'s"] intestines with [src]!</span>",\
				"<span class='alert'>[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your intestines with [src]!</span>")

			patient.TakeDamage("chest", damage_high, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			patient.butt_op_stage = 3
			return 1

		else
			src.surgeryConfusion(patient, surgeon, damage_high)
			return 1

/* ---------- SCALPEL - CAVITY ---------- */
	// Surgeon targeting chest with grab intent
	else if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == "grab")
		// Chest cavity is not open
		if(patient.chest_cavity_open == 0)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> carefully cuts down [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src] and opens it.</span>",\
				"<span class='notice'>You carefully cut down [surgeon == patient ? "your" : "[patient]'s"] chest with [src] and open it up.</span>",\
				"<span class='notice'>[patient == surgeon ? "You carefully cut" : "<b>[surgeon]</b> carefully cuts"] down your chest with [src] and [patient == surgeon ? "open" : "opens"] it.</span>")

			patient.TakeDamage("chest", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)

			// Open chest cavity for item insertion
			patient.chest_cavity_open = 1
			// If a chest item exists and is unsecured, it flops out onto the table
			if(patient.chest_item != null && patient.chest_item_sewn == 0)
				var/location = get_turf(patient)
				var/obj/item/outChestItem = patient.chest_item
				outChestItem.set_loc(location)
				patient.visible_message("<span class='alert'>\The [outChestItem] flops out onto the table.</span>")
				patient.chest_item = null
				patient.chest_item_sewn = 0 //There's no longer an item to be sewn!
			return 1
		// Chest cavity is open and an item exists
		else if(patient.chest_cavity_open == 1 && patient.chest_item != null)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cuts [patient.chest_item] out of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src].</span>",\
				"<span class='notice'>You cut [patient.chest_item] out of [surgeon == patient ? "your" : "[patient]'s"] chest with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] [patient.chest_item] out of your chest with [src].</span>")

			patient.TakeDamage("chest", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)

			// Cut item out of chest and move it outside of patient's body
			var/location = get_turf(patient)
			var/obj/item/outChestItem = patient.chest_item
			outChestItem.set_loc(location)
			patient.chest_item = null
			patient.chest_item_sewn = 0
			return 1

/* ---------- SCALPEL - IMPLANT ---------- */
	// else if (surgeon.zone_sel.selecting == "chest" && (surgeon.a_intent == "help" || surgeon.a_intent == "disarm"))
	else if (surgeon.zone_sel.selecting == "chest")
		if (patient.ailments.len > 0)
			var/attempted_parasite_removal = 0
			for (var/datum/ailment_data/an_ailment in patient.ailments)
				if (an_ailment.cure == "Surgery")
					attempted_parasite_removal = 1
					var/success = an_ailment.surgery(surgeon, patient)
					if (success)
						patient.cure_disease(an_ailment) // surgeon.cure_disease(an_ailment) no, doctor, DO NOT HEAL THYSELF, HEAL THY PATIENT
					else
						break

			if (attempted_parasite_removal == 1)
				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts out a parasite from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!</span>",\
					"<span class='alert'>You cut out a parasite from [surgeon == patient ? "yourself" : "[patient]"] with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out a parasite from you with [src]!</span>")
				return 1

		if (patient.implant.len > 0)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src]!</span>",\
				"<span class='alert'>You cut into [surgeon == patient ? "your" : "[patient]'s"] chest with [src]!</span>",\
				"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] into your chest with [src]!</span>")

			for (var/obj/item/implant/projectile/I in patient.implant)
				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts out \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!</span>",\
					"<span class='alert'>You cut out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out \an [I] from you with [src]!</span>")

				I.on_remove(patient)
				patient.implant.Remove(I)
				I.set_loc(patient.loc)
				// offset approximately around chest area, based on cutting over operating table
				I.pixel_x = rand(-2, 5)
				I.pixel_y = rand(-6, 1)
				return 1

			for (var/obj/item/implant/I in patient.implant)

				// This is kinda important (Convair880).
				if (istype(I, /obj/item/implant/mindhack))
					if (patient.mind?.special_role == ROLE_MINDHACK)
						if(surgeon == patient) continue
						remove_mindhack_status(patient, "mindhack", "surgery")
					else if (patient.mind && patient.mind.master)
						if(surgeon == patient) continue
						remove_mindhack_status(patient, "otherhack", "surgery")

				if (!istype(I, /obj/item/implant/artifact))
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts out an implant from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!</span>",\
						"<span class='alert'>You cut out an implant from [surgeon == patient ? "yourself" : "[patient]"] with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out an implant from you with [src]!</span>")

					var/obj/item/implantcase/newcase = new /obj/item/implantcase(patient.loc, usedimplant = I)
					newcase.pixel_x = rand(-2, 5)
					newcase.pixel_y = rand(-6, 1)
					I.on_remove(patient)
					patient.implant.Remove(I)
					var/image/wadblood = image('icons/obj/surgery.dmi', icon_state = "implantpaper-blood")
					wadblood.color = patient.blood_color
					newcase.UpdateOverlays(wadblood, "blood")
					newcase.blood_DNA = patient.bioHolder.Uid
					newcase.blood_type = patient.bioHolder.bloodType
				else
					var/obj/item/implant/artifact/imp = I
					if (imp.cant_take_out)
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> tries to cut out something from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!</span>",\
							"<span class='alert'>Whatever you try to cut out from [surgeon == patient ? "yourself" : "[patient]"] won't come out!</span>",\
							"<span class='alert'>[patient == surgeon ? "You try to cut" : "<b>[surgeon]</b> tries to cut"] out something from you with [src]!</span>")
					else
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts out something alien from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [src]!</span>",\
							"<span class='alert'>You cut out something alien from [surgeon == patient ? "yourself" : "[patient]"] with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out something alien from you with [src]!</span>")
						imp.pixel_x = rand(-2, 5)
						imp.pixel_y = rand(-6, 1)
						imp.set_loc(get_turf(patient))
						imp.on_remove(patient)
						patient.implant.Remove(imp)
				return 1

		/* chest op_stage description
			cut = scalpel
			saw = circular saw
			snip = surgical scissors/garden snips
			op_stage = (actions you can take) -> where it will send you
			0.0 = snip -> 1.0 || cut -> 5
			1.0 = snip -> 3.0 || cut -> 4.0 || (G)saw -> 2
			2 = cut is remove lungs R/L
			3.0 = snip is remove appendix || cut is remove liver
			4.0 = snip is remove stomach || cut is remove intestines

			5.0 = snip -> 6.0 || cut -> 7.0 || saw -> 8
			6.0 = snip is remove pancreas || cut is remove spleen
			7.0 = snip is remove kidneys
			8.0 = cut -> 9
			9.0 = saw is remove heart

			remove lungs = 		snip -> saw -> snip -> Right/Left hands for removing R/L lungs
			remove appendix = 	snip -> snip -> snip
			remove liver = 		snip -> snip -> cut
			remove stomach = 	snip -> cut -> snip
			remove intestines = snip -> cut -> cut
			remove pancreas = 	cut -> snip -> snip
			remove spleen = 	cut -> snip -> cut
			remove kidneys = 	cut -> cut -> snip -> Right/Left hands for removing R/L kidneys
			remove heart = 0.0 cut -> 5.0 saw -> 8.0 cut -> 9.0 saw
			remove tail = 0.0 saw -> 10.0 cut -> 11.0 saw
				except skeletons with bone tails, just disarm-poke em with some scissors
			*note, for lungs/kidneys R/L hand use only matters for last cut
		*/

		if (patient.organHolder.chest)
			switch (patient.organHolder.chest.op_stage)
				if (0)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> makes a cut on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src]!</span>",\
						"<span class='alert'>You make a cut on [surgeon == patient ? "your" : "[patient]'s"] chest with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You make a cut" : "<b>[surgeon]</b> makes a cut"] on chest with [src]!</span>")
					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 5
					return 1

				//second cut, path for stomach/Intestines
				if (1)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] lower abdomen open with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] lower abdomen open with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your lower abdomen open with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 4
					return 1

				//remove liver with this cut
				if (3)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (!patient.organHolder.liver)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] liver out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] liver out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your liver out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s liver with [src].")
					patient.organHolder.drop_organ("liver")

					return 1

				//remove intestines with this cut
				if (4)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (!patient.organHolder.intestines)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] intestines out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] intestines out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your intestines out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s intestines with [src].")
					patient.organHolder.drop_organ("intestines")

					return 1

				//path for kidneys/spleen/pancreas
				if (5)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> makes a cut in preparation to access  [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] kidneys with [src]!</span>",\
						"<span class='alert'>You make a cut in preparation to access  [surgeon == patient ? "your" : "[patient]'s"] kidneys with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You make" : "<b>[surgeon]</b> makes"] a cut in preparation to access your kidneys with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 7

					return 1

				// kyle-note fix this, it should be able to make a sound and damage if there's no spleen here
				//remove spleen with this cut
				if (6)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (!patient.organHolder.spleen)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					if (patient.organHolder.spleen)
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] spleen out with [src]!</span>",\
							"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] spleen out with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your spleen out with [src]!</span>")

						patient.TakeDamage("chest", damage_high, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s spleen with [src].")
						patient.organHolder.drop_organ("spleen")

						return 1

				//heart path
				if (8)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
						patient.TakeDamage("chest", damage_high, 0)
						take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] aorta and vena cava with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] aorta and vena cava with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your aorta and vena cava with [src]!</span>")


					patient.TakeDamage("chest", damage_high, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 9
					return 1

				//tail path
				if(10.0)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					if (!patient.organHolder.tail)	// Doesnt have tail at all, likely removed earlier
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts away the connective tissue between [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skin and [his_or_her(patient)] sacrum with [src]!</span>",\
							"<span class='alert'>You cut away the connective tissue between [surgeon == patient ? "your" : "[patient]'s"] skin and [surgeon == patient ? "your" : "[his_or_her(patient)]"] sacrum with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the connective tissue between your skin and your sacrum with [src]!</span>")
					else	// Has tail hopefully
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> severs the tendons and ligaments connecting [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] tail to [his_or_her(patient)] spine with [src]!</span>",\
							"<span class='alert'>You sever the tendons and ligaments connecting [surgeon == patient ? "your" : "[patient]'s"] tail to [surgeon == patient ? "your" : "[his_or_her(patient)]"] spine with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] the tendons and ligaments connecting your tail to your spine with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 11
					return 1

				else
					src.surgeryConfusion(patient, surgeon, damage_high)
					return 1

			src.surgeryConfusion(patient, surgeon, damage_low)
			return 1
		else
			return 0

/* ---------- SCALPEL - LIMBS ---------- */

	else if (surgeon.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg"))
		var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (istype(surgery_limb))
			if (surgery_limb.surgery(src))
				return 1
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1
	else
		return 0

/* ========================= */
/* ---------- SAW ---------- */
/* ========================= */

/obj/item/proc/saw_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	if (!ishuman(patient))
		return 0

	if (!patient.organHolder)
		return 0

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> mishandles [src] and cuts [him_or_her(surgeon)]self!</span>",\
		"<span class='alert'>You mishandle [src] and cut yourself!</span>")
		surgeon.changeStatus("weakened", 1 SECOND)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(10, 20)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, damage)
		return 1

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return 0


	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(10,20) * surgCheck /*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(20,30) * surgCheck /*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SAW - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (!headSurgeryCheck(patient))
			surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return 1

		if (!patient.organHolder.head)
			boutput(surgeon, "<span class='alert'>[patient] doesn't have a head!</span>")
			return 0

		if (surgeon.a_intent == INTENT_HARM)
			if (patient.organHolder.head.op_stage == 1.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> severs most of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck with [src]!</span>",\
					"<span class='alert'>You sever most of [surgeon == patient ? "your" : "[patient]'s"] neck with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] most of your neck with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.op_stage = 2
				return 1

			else if (patient.organHolder.head.op_stage == 3.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws through the last of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head's connections to [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] body with [src]!</span>",\
					"<span class='alert'>You saw through the last of [surgeon == patient ? "your" : "[patient]'s"] head's connections to [surgeon == patient ? "your" : "[his_or_her(patient)]"] body with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through the last of your head's connection to your body with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				if (patient.organHolder.brain)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s head and brain with [src].")
					patient.death()
				patient.organHolder.drop_organ("head")
				return 1

			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1

		else
			if (patient.organHolder.head.scalp_op_stage == 1.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				var/missing_fluff = ""
				if (!patient.organHolder.skull)
					// If the skull is gone, but the suture site was closed and we're re-opening
					missing_fluff = pick("region", "area")

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull [missing_fluff] with [src]!</span>",\
					"<span class='alert'>You saw open [surgeon == patient ? "your" : "[patient]'s"] skull [missing_fluff] with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your skull [missing_fluff] with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.organHolder.head.scalp_op_stage = 2
				return 1

			else if (patient.organHolder.head.scalp_op_stage == 3.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				if (patient.organHolder.brain)
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain's connection to the spine with [src]!</span>",\
						"<span class='alert'>You sever [surgeon == patient ? "your" : "[patient]'s"] brain's connection to the spine with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your brain's connection to the spine with [src]!</span>")

					patient.organHolder.drop_organ("brain")
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] brain cavity with [src]!</span>",\
						"<span class='alert'>You cut open [surgeon == patient ? "your" : "[patient]'s"] brain cavity with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut open" : "<b>[surgeon]</b> cuts open "] your brain cavity with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s brain with [src].")
				patient.death()
				patient.organHolder.head.scalp_op_stage = 4
				return 1

			else if (patient.organHolder.head.scalp_op_stage == 5.0)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("head", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				if (patient.organHolder.skull)
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull out with [src]!</span>",\
						"<span class='alert'>You saw [surgeon == patient ? "your" : "[patient]'s"] skull out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] your skull out with [src]!</span>")

					patient.visible_message("<span class='alert'><b>[patient]</b>'s head collapses into a useless pile of skin with no skull to keep it in its proper shape!</span>",\
					"<span class='alert'>Your head collapses into a useless pile of skin with no skull to keep it in its proper shape!</span>")
					patient.organHolder.drop_organ("skull")
				else
					// If the skull is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws the top of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head open with [src]!</span>",\
						"<span class='alert'>You saw the top of [surgeon == patient ? "your" : "[patient]'s"] head open with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] the top of your head open with [src]!</span>")

				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.real_name = "Unknown"
				patient.unlock_medal("Red Hood", 1)
				patient.set_clothing_icon_dirty()
				return 1
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1

/* ---------- SAW - BUTT ---------- */

	else if (surgeon.zone_sel.selecting == "chest" && surgeon.a_intent == INTENT_HARM)
		switch (patient.butt_op_stage)
			if (1)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt with [src]!</span>",\
					"<span class='alert'>You saw open [surgeon == patient ? "your" : "[patient]'s"] butt with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your butt with [src]!</span>")

				patient.TakeDamage("chest", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.butt_op_stage = 2
				return 1

			if (3)
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

				if (prob(screw_up_prob))
					surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					CREATE_BLOOD_SPLOOSH(patient)
					return 1

				surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt's connection to the stomach with [src]!</span>",\
					"<span class='alert'>You sever [surgeon == patient ? "your" : "[patient]'s"] butt's connection to the stomach with [src]!</span>",\
					"<span class='alert'>[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your butt's connection to the stomach with [src]!</span>")

				patient.TakeDamage("chest", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				patient.butt_op_stage = 4
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s butt with [src].")
				patient.organHolder.drop_organ("butt")
				return 1

			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1

/* ---------- SAW - lungs/heart ---------- */

	else if (surgeon.zone_sel.selecting == "chest")
		if (patient.organHolder.chest)
			switch (patient.organHolder.chest.op_stage)
				if(0)	// Tail!
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)
					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					if(!patient.organHolder.tail)
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws through the skin across the top of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt with [src]!</span>",\
							"<span class='alert'>You snip the skin across the top of [surgeon == patient ? "your" : "[patient]'s"] butt with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You snip" : "<b>[surgeon]</b> saws through"] the skin across the top of your butt with [src]!</span>")
					else
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws through the skin along the base of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] tail with [src]!</span>",\
							"<span class='alert'>You snip the skin along the base of [surgeon == patient ? "your" : "[patient]'s"] tail with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You snip" : "<b>[surgeon]</b> saws through"] the skin along the base of your tail with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 10
					return 1

				if(11.0)	// Last of tail!
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					if(!patient.organHolder.tail)
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws through away the last few connections holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] tailbone in place with [src]!</span>",\
							"<span class='alert'>You snip away the last few connections holding [surgeon == patient ? "your" : "[patient]'s"] tailbone in place with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You snip" : "<b>[surgeon]</b> saws through"] away the last few connections holding your tailbone in place with [src]!</span>")
					else
						surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws through away the last few remaining strings of flesh attaching [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] tail to [his_or_her(patient)] lower body with [src]!</span>",\
							"<span class='alert'>You snip away the last few remaining strings of flesh attaching [surgeon == patient ? "your" : "[patient]'s"] tail to [surgeon == patient ? "your" : "[his_or_her(patient)]"] lower body with [src]!</span>",\
							"<span class='alert'>[patient == surgeon ? "You snip" : "<b>[surgeon]</b> saws through"] away the last few remaining strings of flesh attaching your tail to your butt with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					if (patient.organHolder.tail)
						logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s tail with [src].")
					patient.organHolder.drop_organ("tail")
					return 1

				if (1)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>You saw open [surgeon == patient ? "your" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your ribcage with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 2

					return 1

				if (5)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>You saw open [surgeon == patient ? "your" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your ribcage with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 8
					return 1

				if (9)
					playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

					if (!patient.organHolder.get_organ("heart"))
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1
					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
						patient.TakeDamage("chest", damage_high, 0)
						take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1
					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts out [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] heart with [src]!</span>",\
						"<span class='alert'>You cut out [surgeon == patient ? "your" : "[patient]'s"] heart with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out your heart with [src]!</span>")

					patient.TakeDamage("chest", damage_high, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s heart with [src].")
					//patient.contract_disease(/datum/ailment/disease/noheart,null,null,1)

					patient.organHolder.drop_organ("heart")
					return 1
				else
					src.surgeryConfusion(patient, surgeon, damage_high)
					return 1

		else
			return 0

/* ---------- SAW - LIMBS ---------- */

	else if (surgeon.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg"))
		var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (istype(surgery_limb))
			if (surgery_limb.surgery(src))
				return 1
			else
				src.surgeryConfusion(patient, surgeon, damage_high)
				return 1
	else
		return 0

/* ============================ */
/* ---------- SUTURE ---------- */
/* ============================ */

/obj/item/proc/suture_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob)
	if (!ishuman(patient))
		return 0

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> pricks [his_or_her(surgeon)] finger with [src]!</span>",\
		"<span class='alert'>You prick your finger with [src]</span>")

		//surgeon.bioHolder.AddEffect("blind") // oh my god I'm the biggest idiot ever I forgot to get rid of this part
		// I'm not deleting it I'm just commenting it out so my shame will be eternal and perhaps future generations of coders can learn from my mistake
		// - Haine
		surgeon.changeStatus("weakened", 4 SECONDS)
		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(1, 10)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, damage, surgery_bleed = 1)
		return 1

	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return 0

/* ---------- SUTURE - HEAD ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (patient.organHolder && patient.organHolder.head && patient.organHolder.head.op_stage > 0.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your neck closed with [src].</span>")

			patient.organHolder.head.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else if (patient.organHolder && patient.organHolder.head && patient.organHolder.head.scalp_op_stage > 0.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head closed with [src].</span>",\
				"<span class='notice'>You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] head closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your head closed with [src].</span>")

			patient.organHolder.head.scalp_op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else if (patient.organHolder && patient.organHolder.right_eye && patient.organHolder.right_eye.op_stage > 0.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye socket closed with [src].</span>",\
				"<span class='notice'>You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] right eye socket closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your right eye socket closed with [src].</span>")

			patient.organHolder.right_eye.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))

		else if (patient.organHolder && patient.organHolder.left_eye && patient.organHolder.left_eye.op_stage > 0.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] left eye socket closed with [src].</span>",\
				"<span class='notice'>You sew the incision in [surgeon == patient ? "your" : "[patient]'s"] left eye socket closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision in your left eye socket closed with [src].</span>")

			patient.organHolder.left_eye.op_stage = 0
			patient.TakeDamage("head", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))

		else if (patient.bleeding)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src].</span>",\
				"You sew [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your wounds closed with [src].</span>")

			random_brute_damage(patient, 2 * surgCheck * surgCheck)
			repair_bleeding_damage(patient, 100, 10)
			return 1

		else
			return 0

/* ---------- SUTURE - CHEST ---------- */

	else if (surgeon.zone_sel.selecting == "chest")
		if (patient.organHolder.chest && patient.organHolder.chest.op_stage > 0.0 && patient.organHolder.chest.op_stage < 10.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest closed with [src].</span>",\
				"<span class='notice'>You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] chest closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your chest closed with [src].</span>")

			patient.organHolder.chest.op_stage = 0
			patient.TakeDamage("chest", 2, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else if (patient.organHolder.chest && patient.organHolder.chest.op_stage >= 10.0)
			if (patient.organHolder.tail && istype(patient.organHolder.tail, /obj/item/organ/tail)) // If tail, then sew it on
				surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] tail into place with [src].</span>",\
					"<span class='notice'>You sew [surgeon == patient ? "your" : "[patient]'s"] tail into place with [src].</span>",\
					"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your tail into place with [src].</span>")
			else
				surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision just above [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src].</span>",\
					"<span class='notice'>You sew the incision just above [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src].</span>",\
					"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision just above your butt closed with [src].</span>")

			patient.organHolder.chest.op_stage = 0
			patient.TakeDamage("chest", 2, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		// Sew chest cavity closed
		else if (patient.chest_cavity_open == 1 && surgeon.a_intent == "grab")
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> pulls the sides of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity closed and sew them together with [src].</span>",\
				"<span class='notice'>You pull the sides of [surgeon == patient ? "your" : "[patient]'s"] chest cavity closed and sew them together with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You pull" : "<b>[surgeon]</b> pulls"] your chest cavity closed and [patient == surgeon ? "sew" : "sews"] them together with [src].</span>")

			patient.chest_cavity_open = 0
			patient.TakeDamage("chest", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		// Sew chest item securely into chest cavity
		else if (patient.chest_cavity_open == 1 && patient.chest_item != null && patient.chest_item_sewn == 0 && surgeon.a_intent != "grab")
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the [patient.chest_item] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity with [src].</span>",\
				"<span class='notice'>You sew the [patient.chest_item] securely into [surgeon == patient ? "your" : "[patient]'s"] chest cavity with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the [patient.chest_item] into your chest cavity with [src].</span>")

			patient.chest_item_sewn = 1
			patient.TakeDamage("chest", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else if (patient.butt_op_stage > 0.0 && patient.butt_op_stage < 4.0)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your butt closed with [src].</span>")

			patient.butt_op_stage = 0
			patient.TakeDamage("chest", 2 * surgCheck * surgCheck, 0)
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else if (patient.bleeding)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> sews [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src].</span>",\
				"You sew [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].",\
				"<span class='notice'>[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your wounds closed with [src].</span>")

			random_brute_damage(patient, 2 * surgCheck * surgCheck)
			repair_bleeding_damage(patient, 100, 10)
			return 1

		else
			return 0
	else

		if (surgeon.zone_sel.selecting in patient.limbs.vars) //ugly copy paste from stapler
			var/obj/item/parts/surgery_limb = patient.limbs.vars[surgeon.zone_sel.selecting]
			if (istype(surgery_limb) && surgery_limb.remove_stage)
				surgery_limb.surgery(src)
			return

		return 0

/* ============================= */
/* ---------- CAUTERY ---------- */
/* ============================= */

// right now this is just for cauterizing butt wounds in case someone wants to, uhh, do that, I guess
// okay I gotta make this proc work differently than the others because holy shit all those return 1/return 0s are driving me batty

/obj/item/proc/cautery_surgery(var/mob/living/carbon/human/patient as mob, var/mob/surgeon as mob, var/damage as num, var/lit = 1)
	if (!ishuman(patient))
		return 0

	if (patient.is_heat_resistant())
		patient.visible_message("<span class='alert'><b>Nothing happens!</b></span>")
		return 0

	if (!surgeon)
		surgeon = patient

	if (!damage)
		damage = rand(5, 15)

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(33))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> burns [him_or_her(surgeon)]self with [src]!</span>",\
		"<span class='alert'>You burn yourself with [src]</span>")

		JOB_XP(surgeon, "Clown", 1)
		surgeon.changeStatus("weakened", 4 SECONDS)
		random_burn_damage(surgeon, damage)
		return 1

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
			return 0

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [src].</span>")

			patient.organHolder.head.op_stage = 0
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your neck closed with [src].</span>")

			if (do_mob(patient, surgeon, max(100 - (damage * 2)), 0))
				surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [src].</span>",\
					"<span class='notice'>You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [src].</span>",\
					"<span class='notice'>[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [src].</span>")

				patient.organHolder.head.op_stage = 0
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return 1

			else
				surgeon.show_text("<b>You were interrupted!</b>", "red")
				return 1

/* ---------- CAUTERY - BUTT ---------- */

	else if (surgeon.zone_sel.selecting == "chest" && patient.butt_op_stage == 4.0)

		if (!lit)
			surgeon.tri_message(patient, "<b>[surgeon]</b> tries to use [src] on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"You try to use [src] on [surgeon == patient ? "your" : "[patient]'s"] incision, but [src] isn't lit! Sheesh.",\
				"[patient == surgeon ? "You try" : "<b>[surgeon]</b> tries"] to use [src] on your incision, but [src] isn't lit! Sheesh.")
			return 0

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your butt closed with [src].</span>")

			patient.butt_op_stage = 5
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))
			return 1

		else
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your butt closed with [src].</span>")

			if (do_mob(patient, surgeon, max(100 - (damage * 2)), 0))
				surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] butt closed with [src].</span>",\
					"<span class='notice'>You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] butt closed with [src].</span>",\
					"<span class='notice'>[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your butt closed with [src].</span>")

				patient.butt_op_stage = 5
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return 1

			else
				surgeon.show_text("<b>You were interrupted!</b>", "red")
				return 1

/* ---------- CAUTERY - BLEEDING ---------- */

	else if (patient.bleeding)

		if (!lit)
			surgeon.tri_message(patient, "<b>[surgeon]</b> tries to use [src] on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds, but [src] isn't lit! Sheesh.",\
				"You try to use [src] on [surgeon == patient ? "your" : "[patient]'s"] wounds, but [src] isn't lit! Sheesh.",\
				"[patient == surgeon ? "You try" : "<b>[surgeon]</b> tries"] to use [src] on your wounds, but [src] isn't lit! Sheesh.")
			return 1

		random_burn_damage(patient, damage)

		if (quick_surgery)
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src].</span>",\
				"<span class='notice'>You cauterize [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You cauterizes" : "<b>[surgeon]</b> cauterizes"] your wounds closed with [src].</span>")

			repair_bleeding_damage(patient, 100, 10)
			return 1

		else
			surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> begins cauterizing [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src].</span>",\
				"<span class='notice'>You begin cauterizing [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].</span>",\
				"<span class='notice'>[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing your wounds closed with [src].</span>")

			if (do_mob(patient, surgeon, max((patient.bleeding * 20) - (damage * 2), 0)))
				surgeon.tri_message(patient, "<span class='notice'><b>[surgeon]</b> cauterizes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds closed with [src].</span>",\
					"<span class='notice'>You cauterize [surgeon == patient ? "your" : "[patient]'s"] wounds closed with [src].</span>",\
					"<span class='notice'>[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] your wounds closed with [src].</span>")

				repair_bleeding_damage(patient, 100, 10)
				return 1

			else
				surgeon.show_text("<b>You were interrupted!</b>", "red")
				return 1

	else
		return 0

/* =========================== */
/* ---------- SPOON ---------- */
/* =========================== */

/obj/item/proc/spoon_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!ishuman(patient))
		return 0

	if (!patient.organHolder)
		return 0
/* gunna think on this part
	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!</span>", \
		"<span class='alert'>You fumble and stab yourself in the eye with [src]!</span>")
		surgeon.bioHolder.AddEffect("blind")
		surgeon.weakened += 4
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, null, damage)
		return 1
*/
	src.add_fingerprint(surgeon)

	var/surgCheck = surgeryCheck(patient, surgeon)
	if (!surgCheck)
		return 0

	// fluff2 is for things that do more damage: nicking the optic nerve is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " jabs [src] in too far")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " jabs [src] in too far", " nicks the optic nerve")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15) * surgCheck/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(15,25) * surgCheck/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SPOON - EYES ---------- */

	if (surgeon.zone_sel.selecting == "head")
		if (!headSurgeryCheck(patient))
			surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return 1

		if (!patient.organHolder.head)
			boutput(surgeon, "<span class='alert'>[patient] doesn't have a head!</span>")
			return 0

		var/obj/item/organ/eye/target_eye = null
		var/target_side = null

		if (surgeon.find_in_hand(src, "right") && patient.organHolder.right_eye)
			target_eye = patient.organHolder.right_eye
			target_side = "right"
		else if (surgeon.find_in_hand(src, "left") && patient.organHolder.left_eye)
			target_eye = patient.organHolder.left_eye
			target_side = "left"
		else if (surgeon.find_in_hand(src, "middle"))
			surgeon.show_text("Hey, there's no middle eye!")
			return 0
		else
			return 0

		if (target_eye.op_stage == 0.0)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
				patient.TakeDamage("head", damage_low, 0)
				take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> inserts [src] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] eye socket!</span>",\
				"<span class='alert'>You insert [src] into [surgeon == patient ? "your" : "[patient]'s"] [target_side] eye socket!</span>", \
				"<span class='alert'>[patient == surgeon ? "You insert" : "<b>[surgeon]</b> inserts"] [src] into your [target_side] eye socket!</span>")

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			target_eye.op_stage = 1
			return 1

		else if (target_eye.op_stage == 2)
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, 1)

			if (prob(screw_up_prob))
				surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
				patient.TakeDamage("head", damage_high, 0)
				take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
				CREATE_BLOOD_SPLOOSH(patient)
				return 1

			surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> removes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] eye with [src]!</span>",\
				"<span class='alert'>You remove [surgeon == patient ? "your" : "[patient]'s"] [target_side] eye with [src]!</span>",\
				"<span class='alert'>[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] your [target_side] eye with [src]!</span>")

			patient.TakeDamage("head", damage_low, 0)
			take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [target_side] eye with [src].")

			if (target_eye == patient.organHolder.right_eye)
				patient.organHolder.drop_organ("right_eye")
			else if (target_eye == patient.organHolder.left_eye)
				patient.organHolder.drop_organ("left_eye")
			return 1

		else
			src.surgeryConfusion(patient, surgeon, damage_high)
			return 1

////////////////////////////////////////////////////////////////////

/* ============================= */
/* ------------ SNIP ----------- */
/* ============================= */

/obj/item/proc/snip_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!surgeryCheck(patient, surgeon))
		return 0

	if (!patient.organHolder)
		return 0

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> fumbles and stabs [him_or_her(surgeon)]self in the eye with [src]!</span>", \
		"<span class='alert'>You fumble and stab yourself in the eye with [src]!</span>")
		surgeon.bioHolder.AddEffect("blind")
		patient.changeStatus("weakened", 0.4 SECONDS)

		JOB_XP(surgeon, "Clown", 1)
		var/damage = rand(5, 15)
		random_brute_damage(surgeon, damage)
		take_bleeding_damage(surgeon, null, damage)
		return 1

	src.add_fingerprint(surgeon)


	// fluff2 is for things that do more damage: nicking an artery is included in the choices
	var/fluff = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut")
	var/fluff2 = pick(" messes up", "'s hand slips", " fumbles with [src]", " nearly drops [src]", "'s hand twitches", " makes a really messy cut", " nicks an artery")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon)

	//Snipping is a lot safer than other types of surgery. Is it because snips are the One True Surgery Tool? Maybe, maybe not. Who can say.
	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,5)/*, src.adj1, src.adj2*/)
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(5,15)/*, src.adj1, src.adj2*/)

	DEBUG_MESSAGE("<b>[patient]'s surgery (performed by [surgeon]) damage_low is [damage_low], damage_high is [damage_high]</b>")

/* ---------- SNIP - chest ---------- */
	if (surgeon.zone_sel.selecting == "chest")
		if (patient.organHolder.chest)
			switch (patient.organHolder.chest.op_stage)
				if (0)
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> makes a cut on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [src]!</span>",\
						"<span class='alert'>You make a cut on [surgeon == patient ? "your" : "[patient]'s"] chest with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You make a cut" : "<b>[surgeon]</b> makes a cut"] on chest with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 1
					return 1

				//second cut, path for appendix/liver
				if (1)
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right abdomen open with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] right abdomen open with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your right abdomen open with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 3
					return 1

				//remove lungs
				if (2)
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					var/obj/item/organ/lung/target_organ = null
					var/target_side = null

					if (surgeon.find_in_hand(src, "left") && patient.organHolder.left_lung)
						target_organ = patient.organHolder.left_lung
						target_side = "left"
					else if (surgeon.find_in_hand(src, "right") && patient.organHolder.right_lung)
						target_organ = patient.organHolder.right_lung
						target_side = "right"
					else
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
						patient.TakeDamage("chest", damage_high, 0)
						take_bleeding_damage(patient, surgeon, damage_high, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] lung out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] [target_side] lung out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your [target_side] lung out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [target_side] lung with [src].")

					if (target_organ == patient.organHolder.left_lung)
						patient.organHolder.drop_organ("left_lung")
					else if (target_organ == patient.organHolder.right_lung)
						patient.organHolder.drop_organ("right_lung")

					return 1

				//remove appendix or liver
				if (3)
					//remove appendix with this cut
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (!patient.organHolder.appendix)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] appendix out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] appendix out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your appendix out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s appendix with [src].")
					patient.organHolder.drop_organ("appendix")
					return 1

				//path for stomach and intestines
				if (4)
					//remove stomach with this cut
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (!patient.organHolder.stomach)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] stomach out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] stomach out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your stomach out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s stomach with [src].")
					patient.organHolder.drop_organ("stomach")

					return 1

				//paths for pancreas and kidneys
				if (5)
					//path for pancreas
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> makes a cut just below [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>You make a cut just below [surgeon == patient ? "your" : "[patient]'s"] ribcage with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You make" : "<b>[surgeon]</b> makes"] a cut just below your ribcage with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					patient.organHolder.chest.op_stage = 6

					return 1

				//remove pancreas
				if (6)
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					if (!patient.organHolder.pancreas)
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1


					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] pancreas out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] pancreas out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your pancreas out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s pancreas with [src].")
					patient.organHolder.drop_organ("pancreas")

					return 1

				//remove kidneys
				if (7)
					playsound(patient, 'sound/items/Scissor.ogg', 50, 1)

					var/obj/item/organ/kidney/target_organ = null
					var/target_side = null

					if (surgeon.find_in_hand(src, "left") && patient.organHolder.left_kidney)
						target_organ = patient.organHolder.left_kidney
						target_side = "left"
					else if (surgeon.find_in_hand(src, "right") && patient.organHolder.right_kidney)
						target_organ = patient.organHolder.right_kidney
						target_side = "right"
					else
						src.surgeryConfusion(patient, surgeon, damage_low)
						return 1

					if (prob(screw_up_prob))
						surgeon.visible_message("<span class='alert'><b>[surgeon][fluff2]!</b></span>")
						patient.TakeDamage("chest", damage_low, 0)
						take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
						CREATE_BLOOD_SPLOOSH(patient)
						return 1

					surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] kidney out with [src]!</span>",\
						"<span class='alert'>You cut [surgeon == patient ? "your" : "[patient]'s"] [target_side] kidney out with [src]!</span>",\
						"<span class='alert'>[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your [target_side] kidney out with [src]!</span>")

					patient.TakeDamage("chest", damage_low, 0)
					take_bleeding_damage(patient, surgeon, damage_low, surgery_bleed = 1)
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [target_side] kidney with [src].")

					if (target_organ == patient.organHolder.left_kidney)
						patient.organHolder.drop_organ("left_kidney")
					else if (target_organ == patient.organHolder.right_kidney)
						patient.organHolder.drop_organ("right_kidney")

					return 1
				else
					src.surgeryConfusion(patient, surgeon, damage_high)
					return 1

		else
			return 0

////////////////////////////////////////////////////////////////////

/* ================================ */
/* ------------ CROWBAR ----------- */
/* ================================ */

/obj/item/proc/pry_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!isskeleton(patient) || !patient.organHolder || surgeon.a_intent == INTENT_HARM)
		return FALSE

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(50))
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> fumbles and clubs [him_or_her(surgeon)]self upside the head with [src]!</span>", \
		"<span class='alert'>You fumble and club yourself in the head with [src]!</span>")
		patient.changeStatus("weakened", 0.4 SECONDS)

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
		playsound(patient, 'sound/items/Crowbar.ogg', 50, 1)	// Dont really need much surgery to remove a bone from a skeleton
		surgeon.tri_message(patient, "<span class='alert'><b>[surgeon]</b> jams one end of the [src] just below [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] sacrum and pries [his_or_her(patient)] tail off!</span>",\
			"<span class='alert'>You jam one end of the [src] just below [surgeon == patient ? "your" : "[patient]'s"] sacrum and pries [his_or_her(patient)] tail off!</span>",\
			"<span class='alert'>[patient == surgeon ? "You jam" : "<b>[surgeon]</b> jams"] one end of the [src] just below your sacrum and [patient == surgeon ? "pry" : "pries"] your tail off!</span>")
		if (patient.organHolder.tail)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s skeleton tail with [src].")
		patient.organHolder.drop_organ("tail")
		return TRUE

	else if (surgeon.zone_sel.selecting == "head" && patient.organHolder.head)
		var/obj/item/organ/head/H = patient.organHolder.head
		if (H.op_stage != 1)
			return FALSE
		H.op_stage = 2
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> pries [H] loose with [src].</span>")
		playsound(patient, 'sound/items/Crowbar.ogg', 50, 1)
		return TRUE

	else if (surgeon.zone_sel.selecting in patient.limbs.vars)
		var/obj/item/parts/limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (!isskeletonlimb(limb) || limb.remove_stage != 1)
			return FALSE
		limb.remove_stage = 2
		surgeon.visible_message("<span class='alert'><b>[surgeon]</b> pries [limb] loose with [src].</span>")
		playsound(patient, 'sound/items/Crowbar.ogg', 50, 1)
		return TRUE

////////////////////////////////////////////////////////////////////

/* ================================ */
/* ------------- WRENCH ------------ */
/* ================================ */

/obj/item/wrench/proc/wrench_surgery(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	if (!patient.organHolder || surgeon.a_intent == INTENT_HARM || !isskeleton(patient))
		return FALSE

	src.add_fingerprint(surgeon)

	if (surgeon.zone_sel.selecting == "head" && patient.organHolder.head)
		var/obj/item/organ/head/H = patient.organHolder.head
		if (H.op_stage == 0)
			H.op_stage = 1
			surgeon.visible_message("<span class='alert'><b>[surgeon]</b> loosens [H] with [src].</span>")
			playsound(patient, 'sound/items/Screwdriver.ogg', 50, 1)
			return TRUE
		else if (H.op_stage == 2)
			patient.organHolder.drop_organ("head", get_turf(patient))
			surgeon.visible_message("<span class='alert'><b>[surgeon]</b> twists [H] off with [src].</span>")
			playsound(patient, 'sound/items/Ratchet.ogg', 50, 1)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s head with [src].")
			return TRUE

	else if (surgeon.zone_sel.selecting in patient.limbs.vars)
		var/obj/item/parts/limb = patient.limbs.vars[surgeon.zone_sel.selecting]
		if (!istype(limb) || !isskeletonlimb(limb))
			return FALSE
		if (limb.remove_stage == 0)
			limb.remove_stage = 1
			surgeon.visible_message("<span class='alert'><b>[surgeon]</b> loosens [limb] with [src].</span>")
			playsound(patient, 'sound/items/Screwdriver.ogg', 50, 1)
			return TRUE
		else if (limb.remove_stage == 2)
			limb.remove(FALSE)
			surgeon.visible_message("<span class='alert'><b>[surgeon]</b> twists [limb] off with [src].</span>")
			playsound(patient, 'sound/items/Ratchet.ogg', 50, 1)
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [limb] with [src].")
			return TRUE

#undef CREATE_BLOOD_SPLOOSH
