#define COMBO_HELP "help"
#define COMBO_DISARM "disarm"
#define COMBO_GRAB "grab"
#define COMBO_HARM "harm"

/obj/item/organ/augmentation
	name = "surgical augmentation parent"
	organ_name = "augmentation"
	//organ_holder_name = "augmentation_nerve"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 0.0
	icon_state = "augmentation"
	robotic = 1
	desc = "A thin, metal oval with some wires sticking out. It seems like it'd do well attached to the nervous system."

/obj/item/organ/augmentation/head //second abstract parent incase other augmentation types get added
	name = "surgical augmentation parent"
	organ_name = "augmentation_nerve"
	organ_holder_name = "augmentation_nerve"
	organ_holder_location = "head"
	organ_holder_required_op_stage = 4.0
	icon_state = "augmentation"

/obj/item/organ/augmentation/head/pain_reducer //reduces pain by slowing down nerve functions, but makes you completely unaware of your current health
	name = "pain reducer"
	organ_name = "pain reducer"
	icon_state = "augmentation_pain"
	desc = "An augmentation that slows down central nerve function, reducing the effect of pain on the body."

	proc/suffer_pain_punch(source, mob/attacker)
		src.suffer_pain(source, null, attacker)

	proc/suffer_pain(source, item, mob/attacker)
		var/obj/item/I = item
		var/suffer_chance = 0
		if(!GET_COOLDOWN(src.donor, "pain_aug_hurt") && src.broken)
			if(!isnull(item))
				suffer_chance = round((I.force / 4) * 5)
				if(prob(suffer_chance))
					boutput(src.donor, __red("You are paralyzed from the pain!"))
					src.donor.changeStatus("stunned", 5 SECONDS)
					src.donor.emote("scream")
					ON_COOLDOWN(src.donor, "pain_aug_hurt", 10 SECONDS)
			else
				if(prob(7.5))
					boutput(src.donor, __red("You are paralyzed from the pain!"))
					src.donor.changeStatus("stunned", 5 SECONDS)
					src.donor.emote("scream")
					ON_COOLDOWN(src.donor, "pain_aug_hurt", 10 SECONDS)

	proc/suffer_pain_bullet(var/obj/projectile/P, var/atom/hit)
		var/suffer_chance = 0
		if(!GET_COOLDOWN(src.donor, "pain_aug_hurt") && src.broken)
			suffer_chance = round((P.power / 4) * 5)
			if(prob(suffer_chance))
				boutput(src.donor, __red("You are paralyzed from the pain!"))
				src.donor.changeStatus("stunned", 5 SECONDS)
				src.donor.emote("scream")
				ON_COOLDOWN(src.donor, "pain_aug_hurt", 10 SECONDS)

	on_transplant(var/mob/M as mob)
		..()
		APPLY_MOVEMENT_MODIFIER(src.donor, /datum/movement_modifier/pain_reducer, "pain_reducer")
		RegisterSignal(src.donor, COMSIG_ATTACKBY, .proc/suffer_pain)
		RegisterSignal(src.donor, COMSIG_ATTACKHAND, .proc/suffer_pain_punch)
		RegisterSignal(src.donor, COMSIG_PROJ_COLLIDE, .proc/suffer_pain_bullet)

	on_removal()
		..()
		if(src.donor.movement_modifiers.Find(/datum/movement_modifier/pain_reducer))
			REMOVE_MOVEMENT_MODIFIER(src.donor, /datum/movement_modifier/pain_reducer, "pain_reducer")
		if(src.donor.movement_modifiers.Find(/datum/movement_modifier/pain_reducer_broken))
			REMOVE_MOVEMENT_MODIFIER(src.donor, /datum/movement_modifier/pain_reducer_broken, "pain_reducer_broken")
		UnregisterSignal(src.donor, COMSIG_ATTACKBY)
		UnregisterSignal(src.donor, COMSIG_ATTACKHAND)
		UnregisterSignal(src.donor, COMSIG_PROJ_COLLIDE)

	on_life(var/mult = 1)
		var/mob/living/carbon/human/M = src.donor
		if(!..())
			return 0
		if(src.broken && M.get_brain_damage() <= 70)
			M.take_brain_damage(1 * mult)
		return 1

	on_broken(var/mult = 1)
		if (!..())
			return
		if(src.donor.movement_modifiers.Find(/datum/movement_modifier/pain_reducer))
			REMOVE_MOVEMENT_MODIFIER(src.donor, /datum/movement_modifier/pain_reducer, "pain_reducer")
		if(!src.donor.movement_modifiers.Find(/datum/movement_modifier/pain_reducer_broken))
			APPLY_MOVEMENT_MODIFIER(src.donor, /datum/movement_modifier/pain_reducer_broken, "pain_reducer_broken")

/obj/item/organ/augmentation/head/stamina_enhancer //less max health and stamina regen, at the benefit of a massive max stamina increase
	name = "stamina enhancer"
	organ_name = "stamina enhancer"
	icon_state = "augmentation_stam"
	desc = "An augmentation that modifies muscle, organ, and brain functions to prioritize energy storage over energy generation."

	on_transplant(var/mob/M as mob)
		..()
		M.add_stam_mod_max("stamina_storage", 200)
		M.max_health -= 20
		APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "stamina_storage", -6)

	on_removal()
		..()
		if(!src.broken)
			src.donor.remove_stam_mod_max("stamina_storage")
			src.donor.max_health += 20
			REMOVE_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "stamina_storage")
		else
			REMOVE_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "stamina_storage")
			src.donor.max_health += 20

	emp_act()
		..()
		if(src.broken)
			src.donor.reagents.add_reagent("bathsalts", 10)
			src.donor.reagents.add_reagent("methamphetamine", 10)
			src.donor.blood_volume -= 50

	on_broken(var/mult = 1)
		if (!..())
			return
		src.donor.remove_stam_mod_max("stamina_storage")
		src.donor.reagents.add_reagent("bathsalts", 3) //it thinks you're going into the negative on stamina, so it synthesizes stam-boosters forever using your blood
		src.donor.reagents.add_reagent("methamphetamine", 3)
		src.donor.blood_volume -= 15

/obj/item/organ/augmentation/head/wireless_interact //you can interact with mechanical things at range at the cost of flash vulnerability
	name = "wireless interactor"
	organ_name = "wireless interactor"
	icon_state = "augmentation_wire"
	desc = "An augmentation that allows for ranged interaction with various electronic devices."
	var/flashed = FALSE

	proc/ranged_click(atom/target, params, location, control)
		var/mob/M = src.donor
		var/inrange = in_interact_range(target, M)
		var/obj/item/equipped = M.equipped()
		if(!istype(params, /obj) || istype(params, /obj/item) || src.flashed == TRUE)
			return
		if (M.client.check_any_key(KEY_EXAMINE | KEY_POINT) || (equipped && (inrange || (equipped.flags & EXTRADELAY))) || ishelpermouse(target)) // slightly hacky, oh well, tries to check whether we want to click normally or use attack_ai
			return
		else
			if (get_dist(M, target) > 0)
				set_dir(get_dir(M, target))

			target.attack_ai(M, params, location, control)

	proc/flash_check(atom/A, obj/item/I, mob/user)
		if(istype(I, /obj/item/device/flash))
			src.flashed = TRUE
			src.take_damage(5, 5, 0) //owie
			src.donor.remove_stamina(25)
			SPAWN_DBG(15 SECONDS)
				src.flashed = FALSE
		if(src.broken)
			src.donor.remove_stamina(15)

	on_transplant(var/mob/M as mob)
		..()
		if(!broken)
			RegisterSignal(src.donor, COMSIG_CLICK, .proc/ranged_click)
			RegisterSignal(src.donor, COMSIG_ATTACKBY, .proc/flash_check)

	on_removal()
		..()
		if(!broken)
			UnregisterSignal(src.donor, COMSIG_CLICK)
		UnregisterSignal(src.donor, COMSIG_ATTACKBY)

	on_broken(var/mult = 1)
		if (!..())
			return
		src.donor.reagents.add_reagent("nanites", 0.5 * mult) //you want borg powers? Well, come and get 'em!
		UnregisterSignal(src.donor, COMSIG_CLICK)

/obj/item/organ/augmentation/head/surgery_assistant //better surgery odds and you get told the steps at the cost of being unable to self-surgery, good for newbies and surgeons
	name = "surgery assistant"
	organ_name = "surgery assistant"
	icon_state = "augmentation_surgery"
	desc = "An augmentation that, unlike medical books, teaches you how to do surgery, and makes you better at it too!"
	organ_abilities = list(/datum/targetable/organAbility/surgery_assistant)
	var/chosen_surgery
	var/surgery_step

	proc/surgery_act(var/mob/U, var/mob/living/carbon/human/M, var/obj/item/I)
		switch(chosen_surgery)
			if("Implant/Parasite/Shrapnel Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0

			if("Limb Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && !U.zone_sel.selecting == "chest" && !U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's limb on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && !U.zone_sel.selecting == "chest" && !U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's limb on help intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && !U.zone_sel.selecting == "chest" && !U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's limb on help intent."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && !U.zone_sel.selecting == "chest" && !U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(U.zone_sel.selecting == "chest" || U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting one of their limbs!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!")) // odds are, this won't occur because of how I did the signals, but keeping it to be safe
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!")) // no idea what the fuck they're doing wrong

			if("Butt Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HARM && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's chest on harm intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HARM && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's chest on harm intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HARM && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's chest on harm intent."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HARM && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting one of their limbs!"))
				else if(!U.a_intent == INTENT_HARM)
					boutput(U, __blue("<b>Warning!</b> You're not on harm intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Eye Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SPOONING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's head on help intent, with the hand in relation to the side you wish to remove."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's head on help intent, with the hand in relation to the side you wish to remove."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HELP && istool(I, TOOL_SPOONING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting one of their limbs!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Brain Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's head on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's head on help intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's head on help intent. Note: If you wish to put in a brain, put it in instead of or following this step."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their head!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Head Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HARM && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's head on harm intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HARM && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's gead on harm intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HARM && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's head on harm intent."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HARM && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting one of their head!"))
				else if(!U.a_intent == INTENT_HARM)
					boutput(U, __blue("<b>Warning!</b> You're not on harm intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Skull Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's head on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's head on help intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's head on help intent. Note: This will remove the brain."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 5
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 5:</b> Use a surgical saw on the patient's head on help intent."))
				else if(surgery_step == 5 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 6
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 6:</b> Use a surgical saw on the patient's head on help intent."))
				else if(surgery_step == 6 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their head!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Heart")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a surgical saw on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 4
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 4:</b> Use a surgical saw on the patient's chest on help intent. Note: If you wish to put in a heart, put it in instead of or following this step."))
				else if(surgery_step == 4 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Lung")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's chest on help intent, with the hand in relation to the side you wish to remove. Note: If you wish to put in a lung, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Kidney")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's chest on help intent, with the hand in relation to the side you wish to remove. Note: If you wish to put in a kidney, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Appendix")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use surgical scissors on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's chest on help intent. Note: If you wish to put in an appendix, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Liver")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use surgical scissors on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's chest on help intent. Note: If you wish to put in a liver, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Stomach")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's chest on help intent. Note: If you wish to put in a stomach, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Intestines")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's chest on help intent. Note: If you wish to put in intestines, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Pancreas")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use surgical scissors on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use surgical scissors on the patient's chest on help intent.  Note: If you wish to put in a pancreas, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Spleen")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_SNIPPING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a scalpel on the patient's chest on help intent. Note: If you wish to put in a spleen, put it in instead of or following this step."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Tail Removal")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use surgical scissors on the patient's chest on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 3
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 3:</b> Use a surgical saw on the patient's chest on help intent."))
				else if(surgery_step == 3 && U.a_intent == INTENT_HELP && istype(I, TOOL_SAWING) && U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Surgery completed, good job!</b>"))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "chest")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their chest!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

			if("Augumentation")
				if(surgery_step == 1 && U.a_intent == INTENT_HELP && istool(I, TOOL_SAWING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("Step Completed."))
					src.surgery_step = 2
					sleep(15 DECI SECONDS)
					boutput(U, __blue("<b>Step 2:</b> Use a scalpel on the patient's head on help intent."))
				else if(surgery_step == 2 && U.a_intent == INTENT_HELP && istool(I, TOOL_CUTTING) && U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Surgery completed, good job!</b> Note: If you wish to remove an augmentation, use surgical scissors at this step."))
					src.chosen_surgery = null
					src.surgery_step = 0
				else if(!U.zone_sel.selecting == "head")
					boutput(U, __blue("<b>Warning!</b> You're not targeting their head!"))
				else if(!U.a_intent == INTENT_HELP)
					boutput(U, __blue("<b>Warning!</b> You're not on help intent!"))
				else
					boutput(U, __blue("<b>Warning!</b> Double check you're doing everything right!"))

	on_transplant(var/mob/M as mob)
		..()
		RegisterSignal(src.donor, COMSIG_SURGERY_TOOL, .proc/surgery_act)

	on_removal()
		..()
		UnregisterSignal(src.donor, COMSIG_SURGERY_TOOL)
		chosen_surgery = null
		surgery_step = 0

/obj/item/organ/augmentation/head/neural_jack //traitor roboticists can get matrix powers
	name = "neural jack"
	organ_name = "neural jack"
	icon_state = "augmentation_neural"
	desc = "A highly illegal augmentation for the brain, which imparts a boost in reflex speed, and knowledge of some martial moves."
	organ_abilities = list(/datum/targetable/organAbility/combohelp, /datum/targetable/organAbility/combomode)
	var/parrychance = 20
	var/comboattacks = FALSE
	var/list/lastattacks = list()
	var/combotarget = null
	var/attacktime = null

	proc/parry_attack(mob/user, mob/living/target)
		var/mob/M = src.donor
		if (M && M.check_block() && !src.broken)
			if((isnull(usr.l_hand) || isnull(usr.r_hand))) // both hands are empty
				if(prob(parrychance + 10))
					M.set_dir(get_dir(M, target))
					M.visible_message("<span class='alert'><B>[M] parries [target]'s attack, knocking them to the ground!</B></span>")
					logTheThing("combat", M, target, "[M] parries [constructTarget(target,"combat")]'s unarmed attack at [log_loc(M)].")
					target.changeStatus("weakened", 4 SECONDS)
					target.force_laydown_standup()
					playsound(M.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)
					src.parrychance = 20
				else
					src.parrychance += 7.5
			else if((!isnull(usr.l_hand) || !isnull(usr.r_hand))) // has something in their hand
				if(prob(parrychance))
					M.set_dir(get_dir(M, target))
					M.visible_message("<span class='alert'><B>[M] parries [target]'s blow, forcing them to drop their weapon and knocking them to the ground!</B></span>")
					logTheThing("combat", M, target, "[M] parries [constructTarget(target,"combat")]'s armed attack at [log_loc(M)].")
					target.changeStatus("weakened", 3 SECONDS)
					target.force_laydown_standup()
					playsound(M.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)
					src.parrychance = 20
				else
					src.parrychance += 7.5

	proc/combohelp(mob/user, mob/target) //help's not used *currently* but keeping it for the sake of consistency
		if(comboattacks)
			if(combotarget != target)
				combotarget = null
				lastattacks.Cut()
			if(isnull(combotarget))
				combotarget = target
			attacktime = world.time
			lastattacks += COMBO_HELP
			comboattack(user, target)

	proc/combodisarm(mob/user, mob/target)
		if(comboattacks)
			if(combotarget != target)
				combotarget = null
				lastattacks.Cut()
			if(isnull(combotarget))
				combotarget = target
			attacktime = world.time
			lastattacks += COMBO_DISARM
			comboattack(user, target)

	proc/combograb(mob/user, mob/target)
		if(comboattacks)
			if(combotarget != target)
				combotarget = null
				lastattacks.Cut()
			if(isnull(combotarget))
				combotarget = target
			attacktime = world.time
			lastattacks += COMBO_GRAB
			comboattack(user, target)

	proc/comboharm(mob/user, mob/target)
		if(comboattacks)
			if(combotarget != target)
				combotarget = null
				lastattacks.Cut()
			if(isnull(combotarget))
				combotarget = target
			attacktime = world.time
			lastattacks += COMBO_HARM
			comboattack(user, target)

	proc/comboattack(mob/user, mob/target)
		var/amount_remove
		if(length(lastattacks) > 4)
			amount_remove = -4 + 1 + length(lastattacks) //the 1's just there because .Cut() is weird
			lastattacks.Cut(1, amount_remove)
		else if(length(lastattacks) <= 1)
			return

		if(length(lastattacks) >= 2 && lastattacks[1] == COMBO_GRAB && lastattacks[2] == COMBO_HARM) // vanilla powerfling punch attack
			combotarget = null
			lastattacks.Cut()
			user.visible_message("<span class='alert'>[user] punches [target] heavily, sending [target] flying!<B></B></span>") //this entire attack is lame and will probably get changed
			var/turf/T = get_edge_target_turf(user, get_dir(user, get_step_away(target, user)))
			if (T && isturf(T) && get_dist(target, user) <= 1)
				target.throw_at(T, 3, 2)
				random_brute_damage(target, 10, 1)
				target.changeStatus("weakened", 2 SECONDS)
				target.changeStatus("stunned", 2 SECONDS)
				target.force_laydown_standup()
				logTheThing("combat", user, target, "uses a heavy punch on [constructTarget(target,"combat")] at [log_loc(user)].")

		else if(length(lastattacks) >= 3 && lastattacks[1] == COMBO_GRAB && lastattacks[2] == COMBO_DISARM && lastattacks[3] == COMBO_HARM) // leg sweep
			combotarget = null
			lastattacks.Cut()
			user.visible_message("<span class='alert'>[user] sweeps [target]'s legs out from under them!<B></B></span>")
			playsound(user, 'sound/effects/swoosh.ogg', 50, 0)
			target.changeStatus("paralysis", 7 SECONDS)
			target.force_laydown_standup()
			SPAWN_DBG(7 SECONDS)
				target.changeStatus("staggered", 4 SECONDS)
			logTheThing("combat", user, target, "uses a legsweep on [constructTarget(target,"combat")] at [log_loc(user)].")

		else if(length(lastattacks) >= 4 && lastattacks[1] == COMBO_HARM && lastattacks[2] == COMBO_HARM && lastattacks[3] == COMBO_DISARM && lastattacks[4] == COMBO_DISARM) // turbo kick
			combotarget = null
			lastattacks.Cut()
			var/mob/living/carbon/human/H = usr
			var/damage = 10
			if (H.bioHolder.HasEffect("neural_jack"))
				damage += 2
			if (H.shoes)
				damage += H.shoes.kick_bonus
			else if (H.limbs.r_leg)
				damage += H.limbs.r_leg.limb_hit_bonus
			else if (H.limbs.l_leg)
				damage += H.limbs.l_leg.limb_hit_bonus
			target.changeStatus("paralysis", 2 SECONDS)
			var/I = 4
			while(I != 0)
				var/turf/T = get_turf(user)
				if((T && isturf(T) && target && isturf(target.loc)) && get_dist(user, target) <= 1)
					random_brute_damage(target, damage, 1)
					target.force_laydown_standup()
					target.change_misstep_chance(25)
					playsound(user.loc, "swing_hit", 50, 1)

					SPAWN_DBG(0)
						for (var/i2 = 0, i2 < 4, i2++)
							user.set_dir(turn(user.dir, 90))

						user.set_loc(target.loc)
						sleep(4)
						if (user && (T && isturf(T) && get_dist(user, T) <= 1))
							user.set_loc(T)
					sleep(3 DECI SECONDS)
					playsound(user.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
				else if((T && isturf(T) && target && isturf(target.loc)) && get_dist(user, target) > 1)
					boutput(user, __red("You aren't close enough!!"))
					break
				else
					boutput(user, __red("You can't attack the target here!"))
				I--
				user.visible_message("<span class='alert'><b>[user] repeatedly turbokicks [target]!</b></span>")
			target.changeStatus("paralysis", 2 SECONDS)
			logTheThing("combat", user, target, "uses a turbokick on [constructTarget(target,"combat")] at [log_loc(user)].")

		else if(length(lastattacks) >= 4 && lastattacks[1] == COMBO_GRAB && lastattacks[2] == COMBO_GRAB && lastattacks[3] == COMBO_DISARM && lastattacks[4] == COMBO_HARM) // fling pin
			combotarget = null
			lastattacks.Cut()
			user.visible_message("<span class='alert'>[user] jumps on [target], pinning them!<B></B></span>")
			var/turf/T = get_edge_target_turf(user, get_dir(user, get_step_away(target, user)))
			if (T && isturf(T) && get_dist(target, user) <= 1)
				target.throw_at(T, 2, 2)
				user.throw_at(T, 2, 2)
				random_brute_damage(target, 10, 1)
				target.changeStatus("weakened", 2 SECONDS)
				target.changeStatus("stunned", 2 SECONDS)
				user.a_intent = INTENT_GRAB
				user.drop_item()
				target.attack_hand(user)
				target.force_laydown_standup()
				if (istype(user.equipped(), /obj/item/grab))
					var/obj/item/grab/G = user.equipped()
					target.attack_hand(user)
					G.upgrade_to_pin(get_turf(user))
				logTheThing("combat", user, target, "uses a flingpin on [constructTarget(target,"combat")] at [log_loc(user)].")
		else
			return
		combotarget = null
		lastattacks.Cut()

	on_transplant(var/mob/M as mob)
		..()
		RegisterSignal(src.donor, COMSIG_MOB_ATTACKED_PRE, .proc/parry_attack)
		RegisterSignal(src.donor, COMSIG_MOB_HELP, .proc/combohelp)
		RegisterSignal(src.donor, COMSIG_MOB_DISARM, .proc/combodisarm)
		RegisterSignal(src.donor, COMSIG_MOB_GRAB, .proc/combograb)
		RegisterSignal(src.donor, COMSIG_MOB_ATTACK, .proc/comboharm)
		if(!broken)
			M.bioHolder.AddEffect("neural_jack")
			M.add_stam_mod_max("neural_jack", 50)
			APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "neural_jack", 5) // might be overkill but as it stands you get rolled by getting your stamina drained through melee attacks
		else
			src.organ_abilities = null

	on_life()
		if(!..())
			return 0
		if(src.parrychance >= 22.5)
			src.parrychance -= 2.5
		else if(src.parrychance > 20 && src.parrychance < 22.5)
			src.parrychance = src.parrychance - (src.parrychance - 20)
		if(world.time - attacktime >= 10 SECONDS)
			combotarget = null
			lastattacks.Cut()
		if(src.broken) //turns out this thing runs on uranium fuel cells, interesting, huh?
			src.donor.reagents.add_reagent("lithium", 2)
			src.donor.reagents.add_reagent("fuel", 2)
			src.donor.reagents.add_reagent("uranium", 2)
			src.organ_abilities = null

	emp_act()
		src.take_damage(5, 5, 0) //extra reinforced
		if(src.broken)
			src.donor.reagents.add_reagent("lithium", 10)
			src.donor.reagents.add_reagent("fuel", 10)
			src.donor.reagents.add_reagent("uranium", 10)
			src.donor.remove_stam_mod_max("neural_jack")
			REMOVE_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "neural_jack")


	on_removal()
		..()
		src.donor.bioHolder.RemoveEffect("neural_jack")
		UnregisterSignal(src.donor, COMSIG_MOB_ATTACKED_PRE)
		UnregisterSignal(src.donor, COMSIG_MOB_HELP)
		UnregisterSignal(src.donor, COMSIG_MOB_DISARM)
		UnregisterSignal(src.donor, COMSIG_MOB_GRAB)
		UnregisterSignal(src.donor, COMSIG_MOB_ATTACK)
		src.donor.remove_stam_mod_max("neural_jack")
		REMOVE_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, "neural_jack")


#undef COMBO_HELP
#undef COMBO_DISARM
#undef COMBO_GRAB
#undef COMBO_HARM
