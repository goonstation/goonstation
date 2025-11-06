// if you're looking for something like find_in_active_hand(), you'll want /mob/proc/equipped()
/mob/proc/find_in_hand(var/obj/item/I, var/this_hand) // for when you need to find a SPECIFIC THING and not just a type
	if (!I) // did we not get passed a thing to look for?
		return // fuck you
	if (!src.r_hand && !src.l_hand) // is there nothing in either hand?
		return

	if (this_hand) // were we asked to find a thing in a specific hand?
		if (this_hand == "right")
			if (src.r_hand && src.r_hand == I) // is there something in the right hand and is it the thing?
				return src.r_hand // say where we found it
			else
				return
		else if (this_hand == "left")
			if (src.l_hand && src.l_hand == I) // is there something in the left hand and is it the thing?
				return src.l_hand // say where we found it
			else
				return
		else
			return

	if (src.r_hand && src.r_hand == I) // is there something in the right hand and is it the thing?
		return src.r_hand // say where we found it
	else if (src.l_hand && src.l_hand == I) // is there something in the left hand and is it the thing?
		return src.l_hand // say where we found it
	else
		return // vOv

/mob/proc/find_type_in_hand(var/obj/item/I, var/this_hand) // for finding a thing of a type but not a specific instance
	if (!I)
		return
	if (!src.r_hand && !src.l_hand)
		return

	if (this_hand)
		if (this_hand == "right")
			if (src.r_hand && istype(src.r_hand, I))
				return src.r_hand
			else
				return
		else if (this_hand == "left")
			if (src.l_hand && istype(src.l_hand, I))
				return src.l_hand
			else
				return
		else
			return

	if (src.r_hand && istype(src.r_hand, I))
		return src.r_hand
	else if (src.l_hand && istype(src.l_hand, I))
		return src.l_hand
	else
		return // vOv

/**
	* Given a tool flag, returns the src mob's tool in hand that matches the flag, or null
	*
	* * tool_flag {int} - See defines/item.dm for valid TOOL_X values
	* * hand {string} - If set, checks only in specific hand, else checks all hands
	*
	* * return {[obj/item] | 0} - Tool that matched flag (and was in specific hand, if specified)
	*/
/mob/proc/find_tool_in_hand(var/tool_flag, var/hand)
	if (hand)
		// check specific hand
		if (hand == "right")
			var/obj/item/I = src.r_hand
			if (I && (I.tool_flags & tool_flag))
				return src.r_hand
		else if (hand == "left")
			var/obj/item/I = src.l_hand
			if (I && (I.tool_flags & tool_flag))
				return src.l_hand
	else
		// check both hands
		var/obj/item/R = src.r_hand
		if (R && (R.tool_flags & tool_flag))
			return src.r_hand
		var/obj/item/L = src.l_hand
		if (L && (L.tool_flags & tool_flag))
			return src.l_hand
	return null

/mob/proc/put_in_hand_or_drop(var/obj/item/I)
	if (!I)
		return 0
	if (!src.put_in_hand(I))
		I.set_loc(get_turf(src))
		return 1
	return 1

/mob/proc/put_in_hand_or_eject(var/obj/item/I)
	if (!I)
		return 0
	if (!src.put_in_hand(I))
		#ifdef UPSCALED_MAP
		I.set_loc(get_turf(src))
		#else
		I.set_loc(get_turf(I))
		#endif
		return 1
	return 1


/mob/proc/can_slip()
	return 1

/mob/living/carbon/human/can_slip()
	if (src.lying)
		return 0
	if (!src.shoes)
		return 1
	if (src.shoes && (src.shoes.c_flags & NOSLIP))
		return 0
	return 1

/mob/proc/running_check(walking_matters = 0, running = 0, ignore_actual_delay = 0)

	var/check_delay = BASE_SPEED_SUSTAINED //we need to fall under this movedelay value in order for the check to suceed

	if (walking_matters)
		check_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
	var/movement_delay_real = max(src.movement_delay(get_step(src,src.move_dir), running),world.tick_lag)
	var/movedelay = clamp(world.time - src.next_move, movement_delay_real, world.time - src.last_pulled_time)
	if (ignore_actual_delay)
		movedelay = movement_delay_real
	return (movedelay < check_delay)

/mob/living/carbon/human/running_check(walking_matters = 0, running = 0, ignore_actual_delay = 0)
	. = ..(walking_matters, (src.client?.check_key(KEY_RUN) && src.get_stamina() > STAMINA_SPRINT), ignore_actual_delay)

/mob/proc/slip(walking_matters = 0, running = 0, ignore_actual_delay = 0, throw_type=THROW_SLIP, list/params=null)
	SHOULD_CALL_PARENT(1)
	. = null

	if (!src.can_slip())
		return

	var/slip_delay = base_slip_delay //we need to fall under this movedelay value in order to slip :O

	if (walking_matters)
		slip_delay += WALK_DELAY_ADD
	var/movement_delay_real = max(src.movement_delay(get_step(src,src.move_dir), running),world.tick_lag)
	var/movedelay = clamp(world.time - src.next_move, movement_delay_real, world.time - src.last_pulled_time)
	if (ignore_actual_delay)
		movedelay = movement_delay_real

	if (movedelay < slip_delay)
		var/intensity = (-0.33)+(6.033763-(-0.33))/(1+(movement_delay_real/(0.4))-1.975308)  //y=d+(6.033763-d)/(1+(x/c)-1.975308)
		if (traitHolder && traitHolder.hasTrait("super_slips"))
			intensity = max(intensity, 12) //the 12 is copied from the range of lube slips because that's what I'm trying to emulate
		var/throw_range = min(round(intensity),50)
		if (intensity < 1 && intensity > 0 && throw_range <= 0)
			throw_range = max(throw_range,1)
		else
			throw_range = max(throw_range,0)

		if (intensity <= 2.4)
			playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		else
			playsound(src.loc, 'sound/misc/slip_big.ogg', 50, 1, -3)
		src.remove_pulling()
		var/turf/T = get_ranged_target_turf(src, src.move_dir, throw_range)
		var/throw_speed = 2
		if(throw_type == THROW_PEEL_SLIP)
			params += list("peel_stun"=clamp(1.1 SECONDS * intensity, 1 SECOND, 5 SECONDS))
			throw_speed = 0.5
			var/list/datum/thrown_thing/existing_throws = global.throwing_controller.throws_of_atom(src)
			if(length(existing_throws))
				for(var/datum/thrown_thing/thr as anything in existing_throws)
					if(thr.throw_type & THROW_PEEL_SLIP)
						thr.target_x = null
						thr.target_y = null
						thr.range = max(thr.range, thr.dist_travelled + throw_range)
						return 1
		else
			params += list("stun"=clamp(1.1 SECONDS * intensity, 1 SECOND, 5 SECONDS))
		game_stats.Increment("slips")
		. = src.throw_at(T, intensity, throw_speed, params, src.loc, throw_type = throw_type)

/mob/living/carbon/human/slip(walking_matters = 0, running = 0, ignore_actual_delay = 0, throw_type=THROW_SLIP, list/params=null)
	. = ..(walking_matters, (src.client?.check_key(KEY_RUN) && src.get_stamina() > STAMINA_SPRINT), ignore_actual_delay, throw_type, params)


/mob/living/carbon/human/proc/skeletonize()
	if (!istype(src))
		return
	src.set_mutantrace(/datum/mutantrace/skeleton)
	src.decomp_stage = DECOMP_STAGE_SKELETONIZED
	if (src.organHolder && src.organHolder.brain)
		qdel(src.organHolder.brain)
	src.set_clothing_icon_dirty()

/mob/proc/show_text(var/message, var/color = "#000000", var/hearing_check = 0, var/sight_check = 0, var/allow_corruption = 0, var/group = 0)
	if (!src.client || !istext(message) || !message)
		// if they're not logged in, save some cycles by not bothering
		return

	if (sight_check && !src.sight_check(1))
		return
	if (hearing_check && !src.hearing_check(1))
		return

	var/class = ""
	switch (color)
		if ("red") class = "alert"
		if ("blue") class = "notice"
		if ("green") class = "success"

	boutput(src, "<span class='[class]'>[message]</span>", group)

/mob/proc/sight_check(var/consciousness_check = 0)
	return 1

/mob/living/carbon/human/sight_check(var/consciousness_check = 0)
	//Order of checks:
	//1) Are you unconscious?
	//2a) Are you capable of seeing through eye coverings? 2b) Are any items covering your eyes?
	//3) Do any of your items allow you to see?
	//4) Are you blind?

	if (consciousness_check && (src.hasStatus("unconscious") || src.sleeping || src.stat || src.hibernating))
		return 0

	if(!(HAS_ATOM_PROPERTY(src, PROP_MOB_XRAYVISION) || HAS_ATOM_PROPERTY(src, PROP_MOB_XRAYVISION_WEAK)))
		for (var/thing in src.get_equipped_items())
			if (!thing) continue
			var/obj/item/I = thing
			if (I.block_vision)
				return 0

	if (istype(src.glasses, /obj/item/clothing/glasses/))
		var/obj/item/clothing/glasses/G = src.glasses
		if (G.allow_blind_sight)
			return 1

	if (isskeleton(src))
		var/datum/mutantrace/skeleton/skele = src.mutantrace
		if (skele.head_tracker?.glasses?.allow_blind_sight)
			return 1

	if ((src.bioHolder && src.bioHolder.HasEffect("blind")) || src.blinded || src.get_eye_damage(1) || (src.organHolder && !src.organHolder.left_eye && !src.organHolder.right_eye && !isskeleton(src)))
		return 0

	return 1

/mob/living/critter/sight_check(var/consciousness_check = 0)
	if (consciousness_check && (src.getStatusDuration("unconscious") || src.sleeping || src.stat))
		return 0
	return 1

/mob/proc/eyes_protected_from_light()
	return 0

/mob/living/carbon/human/eyes_protected_from_light()
	if (!src.sight_check(1)) // Blindness etc (Convair880).
		return 1
	if (src.get_disorient_protection_eye() >= 100)
		return 1
	if (src.eye_istype(/obj/item/organ/eye/cyber/thermal))
		return 0
	return 0

/mob/proc/apply_flash(var/animation_duration, var/knockdown, var/stnu, var/misstep, var/eyes_blurry, var/eyes_damage, var/eye_tempblind, var/burn, var/uncloak_prob, var/stamina_damage,var/disorient_time)
	return

// We've had like 10+ code snippets for a variation of the same thing, now it's just one mob proc (Convair880).
/mob/living/apply_flash(var/animation_duration = 30, var/knockdown = 8, var/stun = 0, var/misstep = 0, var/eyes_blurry = 0, var/eyes_damage = 0, var/eye_tempblind = 0, var/burn = 0, var/uncloak_prob = 50, var/stamina_damage = 130,var/disorient_time = 60)
	if (isintangible(src) || islivingobject(src))
		return
	if (animation_duration <= 0)
		return

	if (check_target_immunity(src))
		return 0
	// Target checks.
	var/mod_animation = 0 // Note: these aren't multipliers.
	var/mod_knockdown = 0
	var/mod_stun = 0
	var/mod_misstep = 0
	var/mod_eyeblurry = 0
	var/mod_eyedamage = 0
	var/mod_eyetempblind = 0
	var/mod_burning = 0
	var/mod_uncloak = 0

	var/safety = 0
	if (src.eyes_protected_from_light())
		safety = 1

	if (safety == 0 && ishuman(src))
		var/mob/living/carbon/human/H = src
		var/hulk = 0
		if (H.is_hulk())
			mod_knockdown = -INFINITY
			mod_stun = -INFINITY
			hulk = 1
		var/helmet_thermal = FALSE
		if (istype(H.head, /obj/item/clothing/head/helmet/space/industrial))
			var/obj/item/clothing/head/helmet/space/industrial/helmet = H.head
			helmet_thermal = helmet.visor_enabled && helmet.visor_enabled
		if (helmet_thermal || istype(H.glasses, /obj/item/clothing/glasses/thermal) || H.eye_istype(/obj/item/organ/eye/cyber/thermal))
			H.show_text("<b>Your thermals intensify the bright flash of light, hurting your eyes quite a bit.</b>", "red")
			mod_animation = 20
			if (hulk == 0)
				mod_knockdown = rand(1, 2)
			mod_eyeblurry = rand(6, 8)
			mod_eyedamage = rand(2, 3)
		else if (istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
			H.show_text("<b>Your night vision goggles intensify the bright flash of light.</b>", "red")
			H.show_text("<b style=\"font-size: 200%\">IT BURNS</b>", "red")
			mod_animation = 30
			if (hulk == 0)
				mod_knockdown = rand(3, 4)
			mod_eyeblurry = rand(8, 10)
			mod_eyedamage = rand(3, 5)
		else
			mod_eyeblurry = rand(4, 6)

	// No negative values.
	animation_duration = max(0, animation_duration + mod_animation)
	knockdown = max(0, knockdown + mod_knockdown)
	stun = max(0, stun + mod_stun)
	misstep = max(0, misstep + mod_misstep)
	eyes_blurry = max(0, eyes_blurry + mod_eyeblurry)
	eyes_damage = max(0, eyes_damage + mod_eyedamage)
	eye_tempblind = max(0, eye_tempblind + mod_eyetempblind)
	burn = max(0, burn + mod_burning)
	uncloak_prob = max(0, uncloak_prob + mod_uncloak)

	if (animation_duration <= 0)
		return

	//DEBUG_MESSAGE("Apply_flash() called for [src] at [log_loc(src)]. Safe: [safety == 1 ? "Y" : "N"], AD: [animation_duration], W: [weak], S: [stun], MS: [misstep], EB [eyes_blurry], ED: [eyes_damage], EB: [eye_tempblind], B: [burn], UP: [uncloak_prob]")

	// Stun target mob.
	if (safety == 0)
		//src.flash(animation_duration)
#ifdef USE_STAMINA_DISORIENT
		src.do_disorient(stamina_damage, knockdown = knockdown*20, stunned = stun*20, disorient = disorient_time, remove_stamina_below_zero = 0, target_type = DISORIENT_EYE)
#else
		changeStatus("knockdown", knockdown*2 SECONDS)
		changeStatus("stunned", stun*2 SECONDS)
#endif

		if (!issilicon(src))
			if (eyes_damage > 0)
				var/eye_dam = src.get_eye_damage()
				if ((eye_dam > 15 && prob(eye_dam + 50)))
					src.take_eye_damage(eyes_damage * 1.5)
				else
					src.take_eye_damage(eyes_damage)

			if (src.misstep_chance < misstep)
				src.change_misstep_chance(misstep)
			if (src.get_eye_blurry() < eyes_blurry)
				src.change_eye_blurry(eyes_blurry)
			if (eye_tempblind > 0)
				src.take_eye_damage(eye_tempblind, 1)

	// Certain effects apply regardless of eye protection.
	if (burn > 0)
		src.update_burning(burn)
		src.TakeDamage("head", 0, 5)

	if (prob(clamp(uncloak_prob, 0, 100)))
		SEND_SIGNAL(src, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
		SEND_SIGNAL(src, COMSIG_MOB_DISGUISER_DEACTIVATE)

	if (safety)
		return 0
	return 1

/mob/proc/hearing_check(var/consciousness_check = 0, for_audio = FALSE)
	return 1

/mob/living/carbon/human/hearing_check(var/consciousness_check = 0, for_audio = FALSE)
	if (consciousness_check && (src.stat || src.getStatusDuration("unconscious") || src.sleeping))
		// you may be physically capable of hearing it, but you're sure as hell not mentally able when you're out cold
		.= 0
	else
		.= 1
		//dont do disorient_ear check here cause its slower. just use the flags HEARING_BLOCKED pls
		if (src.ears)
			if (src.ears.block_hearing_when_worn >= HEARING_BLOCKED)
				return 0
			else if (src.ears.block_hearing_when_worn <= HEARING_ANTIDEAF)
				return 1

		if (src.ear_disability || src.get_ear_damage(1))
			.= 0

/mob/living/silicon/hearing_check(var/consciousness_check = 0, for_audio = FALSE)
	if (consciousness_check && (src.getStatusDuration("unconscious") || src.sleeping || src.stat))
		return 0

	if (src.ear_disability)
		return 0

	return 1

// Bit redundant at the moment, but we might get ear transplants at some point, who knows? Just put 'em here (Convair880).
/mob/proc/ears_protected_from_sound()
	return 0

/mob/living/carbon/human/ears_protected_from_sound()
	if (!src.hearing_check(1))
		return 1
	return 0

/mob/proc/apply_sonic_stun()
	return

// Similar concept to apply_flash(). One proc in place of a bunch of individually implemented code snippets (Convair880).
#define DO_NOTHING (!knockdown && !stun && !misstep && !slow && !drop_item && !ears_damage && !ear_tempdeaf)
/mob/living/apply_sonic_stun(var/knockdown = 0, var/stun = 8, var/misstep = 0, var/slow = 0, var/drop_item = 0, var/ears_damage = 0, var/ear_tempdeaf = 0, var/stamina_damage = 130)
	if (isintangible(src) || islivingobject(src))
		return
	if (DO_NOTHING)
		return

	// Target checks.
	var/mod_knockdown = 0 // Note: these aren't multipliers.
	var/mod_stun = 0
	var/mod_misstep = 0
	var/mod_slow = 0
	var/mod_drop = 0
	var/mod_eardamage = 0
	var/mod_eartempdeaf = 0

	if (src.ears_protected_from_sound())
		return

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if (H.is_hulk())
			mod_knockdown = -INFINITY
			mod_stun = -INFINITY

	// No negative values.
	knockdown = max(0, knockdown + mod_knockdown)
	stun = max(0, stun + mod_stun)
	misstep = max(0, misstep + mod_misstep)
	slow = max(0, slow + mod_slow)
	drop_item = max(0, drop_item + mod_drop)
	ears_damage = max(0, ears_damage + mod_eardamage)
	ear_tempdeaf = max(0, ear_tempdeaf + mod_eartempdeaf)

	if (DO_NOTHING)
		return

	//DEBUG_MESSAGE("Apply_sonic_stun() called for [src] at [log_loc(src)]. W: [weak], S: [stun], MS: [misstep], SL: [slow], DI: [drop_item], ED: [ears_damage], EF: [ear_tempdeaf]")

	// Stun target mob.
	boutput(src, SPAN_ALERT("<b>You hear an extremely loud noise!</b>"))


#ifdef USE_STAMINA_DISORIENT
	src.do_disorient(stamina_damage, knockdown = knockdown*20, stunned = stun*20, disorient = 60, remove_stamina_below_zero = 0, target_type = DISORIENT_EAR)
#else

	changeStatus("knockdown", stun*10)

	changeStatus("stunned", stun*10)
#endif


	if (!issilicon(src))
		if (ears_damage > 0)
			src.take_ear_damage(ears_damage)
		if (src.misstep_chance < misstep)
			src.change_misstep_chance(misstep)
			src.getStatusDuration(slow*10)
		if (ear_tempdeaf > 0)
			src.take_ear_damage(ear_tempdeaf, 1)

		if (knockdown == 0 && stun == 0 && prob(clamp(drop_item, 0, 100)))
			src.show_message(SPAN_ALERT("<B>You drop what you were holding to clutch at your ears!</B>"))
			src.drop_item()

	return
#undef DO_NOTHING

/mob/proc/violate_hippocratic_oath()
	if(!src.mind)
		return 0

	src.mind.violated_hippocratic_oath = 1
	return 1

/// 'this man' vs 'this person'
/proc/man_or_woman(var/mob/subject)
	return subject.get_pronouns().preferredGender

/// 'their cookie' vs 'her cookie'
/proc/his_or_her(var/mob/subject)
	return subject.get_pronouns().possessive

/proc/him_or_her(var/mob/subject)
	return subject.get_pronouns().objective

/proc/he_or_she(var/mob/subject)
	return subject.get_pronouns().subjective

/// "they're outside" vs "he's outside"
/proc/hes_or_shes(var/mob/subject)
	var/datum/pronouns/pronouns = subject.get_pronouns()
	return pronouns.subjective + (pronouns.pluralize ? "'re" : "'s")

/// 'they are' vs 'he is'
/proc/is_or_are(var/mob/subject)
	return subject.get_pronouns().pluralize ? "are" : "is"

/// 'they have' vs 'he has'
/proc/has_or_have(var/mob/subject)
	return subject.get_pronouns().pluralize ? "have" : "has"

/// "they've had" vs "he's had"
/proc/ve_or_s(var/mob/subject)
	return subject.get_pronouns().pluralize ? "'ve" : "'s"

/proc/himself_or_herself(var/mob/subject)
	return subject.get_pronouns().reflexive

/// "he doesn't" vs "they don't"
///
/// should arguably just be 'does_or_doesnt' but i figure this is by far the dominant use of that so I'm rolling them together
/proc/he_or_she_dont_or_doesnt(mob/subject)
	return "[he_or_she(subject)] do[blank_or_es(subject)]n't"

/// 'they run' vs 'he runs'
/proc/blank_or_s(mob/subject)
	return subject.get_pronouns().pluralize ? "" : "s"

/// 'they smash' vs 'he smashes'
/proc/blank_or_es(mob/subject)
	return subject.get_pronouns().pluralize ? "" : "es"

/// 'they were' vs 'he was'
/proc/were_or_was(var/mob/subject)
	return subject.get_pronouns().pluralize ? "were" : "was"

/mob/proc/get_explosion_resistance()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_EXPLOPROT), 100) / 100

/mob/proc/spread_blood_clothes(mob/whose)
	return

/mob/living/carbon/human/spread_blood_clothes(mob/whose)
	if (!whose || !ismob(whose))
		return

	if (src.wear_mask)
		src.wear_mask.add_blood(whose)
		src.update_bloody_mask()
	if (src.head)
		src.head.add_blood(whose)
		src.update_bloody_head()
	if (src.glasses && prob(33))
		src.glasses.add_blood(whose)
	if (prob(15))
		if (src.wear_suit)
			src.wear_suit.add_blood(whose)
			src.update_bloody_suit()
		else if (src.w_uniform)
			src.w_uniform.add_blood(whose)
			src.update_bloody_uniform()

/mob/proc/spread_blood_hands(mob/whose)
	return

/mob/living/carbon/human/spread_blood_hands(mob/whose)
	if (!whose || !ismob(whose))
		return

	if (src.gloves)
		src.gloves.add_blood(whose)
		src.update_bloody_gloves()
	else
		src.add_blood(whose)
		src.update_bloody_hands()
	if (src.equipped())
		var/obj/item/I = src.equipped()
		if (istype(I))
			I.add_blood(whose)
	if (prob(15))
		if (src.wear_suit)
			src.wear_suit.add_blood(whose)
			src.update_bloody_suit()
		else if (src.w_uniform)
			src.w_uniform.add_blood(whose)
			src.update_bloody_uniform()

/mob/proc/is_bleeding()
	return 0

/mob/living/carbon/human/is_bleeding()
	return bleeding

/mob/proc/equipped_limb()
	RETURN_TYPE(/datum/limb)
	return null

/mob/living/critter/equipped_limb()
	var/datum/handHolder/HH = get_active_hand()
	if (HH)
		return HH.limb
	return null

/mob/living/carbon/human/equipped_limb()
	if (!hand && limbs?.r_arm)
		return limbs.r_arm.limb_data
	else if (hand && limbs?.l_arm)
		return limbs.l_arm.limb_data
	return null


// This proc copies one mob's inventory to another. Why the separate entry? I don't wanna have to
// rip it out of unkillable_respawn() later for unforseeable reasons (Convair880).
/mob/living/carbon/human/proc/transfer_mob_inventory(var/mob/living/carbon/human/old, var/mob/living/carbon/human/newbody, var/copy_organs = 0, var/copy_limbs = 0, var/transfer_inventory = 1)
	if (!old || !newbody || !ishuman(old) || !ishuman(newbody))
		return

	SPAWN(2 SECONDS) // OrganHolders etc need time to initialize. Transferring inventory doesn't.
		if (copy_organs && old && newbody && old.organHolder && newbody.organHolder)
			if (old.organHolder.skull && (old.organHolder.skull.type != newbody.organHolder.skull.type))
				var/obj/item/organ/NO = new old.organHolder.skull.type(newbody)
				NO.donor = newbody
				var/DEL = newbody.organHolder.drop_organ("skull")
				qdel(DEL)
				newbody.organHolder.receive_organ(NO, "skull")
			// Prone to failure, don't enable.
			/*if (old.organHolder.brain && (old.organHolder.brain.type != newbody.organHolder.brain.type))
				var/obj/item/organ/NO2 = new old.organHolder.brain.type(newbody)
				NO2.donor = newbody
				var/DEL2 = newbody.organHolder.drop_organ("Brain")
				qdel(DEL2)
				newbody.organHolder.receive_organ(NO2, "Brain")*/
			if (old.organHolder.left_eye && (old.organHolder.left_eye.type != newbody.organHolder.left_eye.type))
				var/obj/item/organ/NO3 = new old.organHolder.left_eye.type(newbody)
				NO3.donor = newbody
				var/DEL3 = newbody.organHolder.drop_organ("left_eye")
				qdel(DEL3)
				newbody.organHolder.receive_organ(NO3, "left_eye")
			if (old.organHolder.right_eye && (old.organHolder.right_eye.type != newbody.organHolder.right_eye.type))
				var/obj/item/organ/NO4 = new old.organHolder.right_eye.type(newbody)
				NO4.donor = newbody
				var/DEL4 = newbody.organHolder.drop_organ("right_eye")
				qdel(DEL4)
				newbody.organHolder.receive_organ(NO4, "right_eye")
			if (old.organHolder.left_lung && (old.organHolder.left_lung.type != newbody.organHolder.left_lung.type))
				var/obj/item/organ/NO5 = new old.organHolder.left_lung.type(newbody)
				NO5.donor = newbody
				var/DEL5 = newbody.organHolder.drop_organ("left_lung")
				qdel(DEL5)
				newbody.organHolder.receive_organ(NO5, "left_lung")
			if (old.organHolder.right_lung && (old.organHolder.right_lung.type != newbody.organHolder.right_lung.type))
				var/obj/item/organ/NO6 = new old.organHolder.right_lung.type(newbody)
				NO6.donor = newbody
				var/DEL6 = newbody.organHolder.drop_organ("right_lung")
				qdel(DEL6)
				newbody.organHolder.receive_organ(NO6, "right_lung")
			if (old.organHolder.heart && (old.organHolder.heart.type != newbody.organHolder.heart.type))
				var/obj/item/organ/NO7 = new old.organHolder.heart.type
				NO7.donor = newbody
				var/DEL7 = newbody.organHolder.drop_organ("heart")
				qdel(DEL7)
				newbody.organHolder.receive_organ(NO7, "heart")
			if (old.organHolder.butt && (old.organHolder.butt.type != newbody.organHolder.butt.type))
				var/obj/item/organ/NO8 = new old.organHolder.butt.type(newbody)
				NO8.donor = newbody
				var/DEL8 = newbody.organHolder.drop_organ("butt")
				qdel(DEL8)
				newbody.organHolder.receive_organ(NO8, "butt")

		// Some mutantraces get powerful limbs and we generally don't want the player to keep them.
		if (copy_limbs && old && !old.mutantrace && newbody && old.limbs && newbody.limbs)
			if (old.limbs.l_arm && (old.limbs.l_arm.type != newbody.limbs.l_arm.type))
				if (istype(old.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item))
					var/obj/item/parts/human_parts/arm/left/item/NL_item = new old.limbs.l_arm.type(newbody)
					if (old.limbs.l_arm.remove_object)
						var/obj/item/new_LAI = new old.limbs.l_arm.remove_object.type(NL_item)
						NL_item.set_item(new_LAI)
					NL_item.holder = newbody
					qdel(newbody.limbs.l_arm)
					newbody.limbs.l_arm = NL_item
				else
					var/obj/item/parts/NL = new old.limbs.l_arm.type(newbody)
					NL.holder = newbody
					qdel(newbody.limbs.l_arm)
					newbody.limbs.l_arm = NL
			if (old.limbs.r_arm && (old.limbs.r_arm.type != newbody.limbs.r_arm.type))
				if (istype(old.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item))
					var/obj/item/parts/human_parts/arm/right/item/NL2_item = new old.limbs.r_arm.type(newbody)
					if (old.limbs.r_arm.remove_object)
						var/obj/item/new_RAI = new old.limbs.r_arm.remove_object.type(NL2_item)
						NL2_item.set_item(new_RAI)
					NL2_item.holder = newbody
					qdel(newbody.limbs.r_arm)
					newbody.limbs.r_arm = NL2_item
				else
					var/obj/item/parts/NL2 = new old.limbs.r_arm.type(newbody)
					NL2.holder = newbody
					qdel(newbody.limbs.r_arm)
					newbody.limbs.r_arm = NL2
			if (old.limbs.l_leg && (old.limbs.l_leg.type != newbody.limbs.l_leg.type))
				var/obj/item/parts/NL3 = new old.limbs.l_leg.type(newbody)
				NL3.holder = newbody
				qdel(newbody.limbs.l_leg)
				newbody.limbs.l_leg = NL3
			if (old.limbs.r_leg && (old.limbs.r_leg.type != newbody.limbs.r_leg.type))
				var/obj/item/parts/NL4 = new old.limbs.r_leg.type(newbody)
				NL4.holder = newbody
				qdel(newbody.limbs.r_leg)
				newbody.limbs.r_leg = NL4

	if (transfer_inventory && old && newbody)
		if (old.w_uniform)
			var/obj/item/CI = old.w_uniform
			var/obj/item/CI2 = old.belt
			var/obj/item/CI3 = old.wear_id
			var/obj/item/CI4 = old.l_store
			var/obj/item/CI5 = old.r_store

			if (old.belt)
				old.u_equip(CI2)
			if (old.wear_id)
				old.u_equip(CI3)
			if (old.l_store)
				old.u_equip(CI4)
			if (old.r_store)
				old.u_equip(CI5)

			old.u_equip(CI)
			newbody.equip_if_possible(CI, SLOT_W_UNIFORM) // Has to be at the top of the list, naturally.
			if (CI2) newbody.equip_if_possible(CI2, SLOT_BELT)
			if (CI3) newbody.equip_if_possible(CI3, SLOT_WEAR_ID)
			if (CI4) newbody.equip_if_possible(CI4, SLOT_L_STORE)
			if (CI5) newbody.equip_if_possible(CI5, SLOT_R_STORE)

		if (old.wear_suit)
			var/obj/item/CI6 = old.wear_suit
			old.u_equip(CI6)
			newbody.equip_if_possible(CI6, SLOT_WEAR_SUIT)
		if (old.head)
			var/obj/item/CI7 = old.head
			old.u_equip(CI7)
			newbody.equip_if_possible(CI7, SLOT_HEAD)
		if (old.wear_mask)
			var/obj/item/CI8 = old.wear_mask
			old.u_equip(CI8)
			newbody.equip_if_possible(CI8, SLOT_WEAR_MASK)
		if (old.ears)
			var/obj/item/CI9 = old.ears
			old.u_equip(CI9)
			newbody.equip_if_possible(CI9, SLOT_EARS)
		if (old.glasses)
			var/obj/item/CI10 = old.glasses
			old.u_equip(CI10)
			newbody.equip_if_possible(CI10, SLOT_GLASSES)
		if (old.gloves)
			var/obj/item/CI11 = old.gloves
			old.u_equip(CI11)
			newbody.equip_if_possible(CI11, SLOT_GLOVES)
		if (old.shoes)
			var/obj/item/CI12 = old.shoes
			old.u_equip(CI12)
			newbody.equip_if_possible(CI12, SLOT_SHOES)
		if (old.back)
			var/obj/item/CI13 = old.back
			old.u_equip(CI13)
			newbody.equip_if_possible(CI13, SLOT_BACK)
		if (old.l_hand)
			var/obj/item/CI14 = old.l_hand
			old.u_equip(CI14)
			newbody.equip_if_possible(CI14, SLOT_L_HAND)
		if (old.r_hand)
			var/obj/item/CI15 = old.r_hand
			old.u_equip(CI15)
			newbody.equip_if_possible(CI15, SLOT_R_HAND)

	SPAWN(2 SECONDS) // Necessary.
		if (newbody)
			newbody.set_face_icon_dirty()
			newbody.set_body_icon_dirty()
			newbody.update_clothing()

	return

// Avoids some C&P since multiple procs make use of this ability (Convair880).
/mob/proc/smash_through(var/obj/target, var/list/can_smash, var/show_message = 1)
	if (!src || !ismob(src) || !target || !isobj(target))
		return FALSE

	if (!islist(can_smash) || !length(can_smash))
		return FALSE

	for (var/S in can_smash)
		if (S == "window" && istype(target, /obj/window))
			var/obj/window/W = target
			if (show_message)
				src.visible_message(SPAN_ALERT("[src] smashes through the window."), SPAN_NOTICE("You smash through the window."))
			W.health = 0
			W.smash()
			return TRUE

		if (S == "grille" && istype(target, /obj/mesh/grille))
			var/obj/mesh/grille/G = target
			if (!G.shock(src, 70))
				if (show_message)
					G.visible_message(SPAN_ALERT("<b>[src]</b> violently slashes [G]!"))
				playsound(G.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)
				G.damage_slashing(15)
				return TRUE

		if (S == "door" && istype(target, /obj/machinery/door))
			var/obj/machinery/door/door = target
			SPAWN(0)
				door.tear_apart(src)
			return TRUE

		if (S == "table" && istype(target, /obj/table))
			var/obj/table/table = target
			playsound(table.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			table.deconstruct()
			return TRUE

		if (S == "blob" && istype(target, /obj/blob))
			var/obj/blob/B = target
			if(show_message)
				src.visible_message(SPAN_ALERT("<B>[src] savagely slashes [B]!"), SPAN_NOTICE("You savagely slash at \the [B]"))
			B.take_damage(rand(10,20),1,DAMAGE_CUT)
			playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
			return TRUE
	return FALSE

/mob/proc/clothing_protects_from_chems()
	.=0

/mob/living/carbon/human/clothing_protects_from_chems()
	if (src.get_chem_protection() == 100)
		return 1
	else
		return 0


/// Changes ghost invisibility for the round.
// Default value set in global.dm: INVIS_GHOST
/proc/change_ghost_invisibility(var/new_invis)
	var/prev_invis = ghost_invisibility
	ghost_invisibility = new_invis
	for (var/mob/dead/observer/G in mobs)
		if (G.invisibility == INVIS_ALWAYS)
			// logged out ghosts stay invisible
			continue
		G.invisibility = new_invis
		REMOVE_ATOM_PROPERTY(G, PROP_MOB_INVISIBILITY, G)
		APPLY_ATOM_PROPERTY(G, PROP_MOB_INVISIBILITY, G, new_invis)
		if (new_invis != prev_invis && (new_invis == 0 || prev_invis == 0))
			boutput(G, SPAN_NOTICE("You are [new_invis == 0 ? "now" : "no longer"] visible to the living!"))


