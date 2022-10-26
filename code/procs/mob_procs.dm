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


/mob/proc/slip(walking_matters = 0, running = 0, ignore_actual_delay = 0, throw_type=THROW_SLIP, list/params=null)
	. = null
	SHOULD_CALL_PARENT(1)

	if (!src.can_slip())
		return

	var/slip_delay = BASE_SPEED_SUSTAINED //we need to fall under this movedelay value in order to slip :O

	if (walking_matters)
		slip_delay = BASE_SPEED_SUSTAINED + WALK_DELAY_ADD
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
	if (consciousness_check && (src.hasStatus("paralysis") || src.sleeping || src.stat || src.hibernating))
		return 0

	if (istype(src.glasses, /obj/item/clothing/glasses/))
		var/obj/item/clothing/glasses/G = src.glasses
		if (G.allow_blind_sight)
			return 1
		if (G.block_vision)
			return 0

	if ((src.bioHolder && src.bioHolder.HasEffect("blind")) || src.blinded || src.get_eye_damage(1) || (src.organHolder && !src.organHolder.left_eye && !src.organHolder.right_eye && !isskeleton(src)))
		return 0

	return 1

/mob/living/critter/sight_check(var/consciousness_check = 0)
	if (consciousness_check && (src.getStatusDuration("paralysis") || src.sleeping || src.stat))
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

/mob/proc/apply_flash(var/animation_duration, var/weak, var/stnu, var/misstep, var/eyes_blurry, var/eyes_damage, var/eye_tempblind, var/burn, var/uncloak_prob, var/stamina_damage,var/disorient_time)
	return

// We've had like 10+ code snippets for a variation of the same thing, now it's just one mob proc (Convair880).
/mob/living/apply_flash(var/animation_duration = 30, var/weak = 8, var/stun = 0, var/misstep = 0, var/eyes_blurry = 0, var/eyes_damage = 0, var/eye_tempblind = 0, var/burn = 0, var/uncloak_prob = 50, var/stamina_damage = 130,var/disorient_time = 60)
	if (isintangible(src) || islivingobject(src))
		return
	if (animation_duration <= 0)
		return

	if (check_target_immunity(src))
		return 0
	// Target checks.
	var/mod_animation = 0 // Note: these aren't multipliers.
	var/mod_weak = 0
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
			mod_weak = -INFINITY
			mod_stun = -INFINITY
			hulk = 1
		if ((H.glasses && istype(H.glasses, /obj/item/clothing/glasses/thermal)) || H.eye_istype(/obj/item/organ/eye/cyber/thermal))
			H.show_text("<b>Your thermals intensify the bright flash of light, hurting your eyes quite a bit.</b>", "red")
			mod_animation = 20
			if (hulk == 0)
				mod_weak = rand(1, 2)
			mod_eyeblurry = rand(6, 8)
			mod_eyedamage = rand(2, 3)
		else if (istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
			H.show_text("<b>Your night vision goggles intensify the bright flash of light.</b>", "red")
			H.show_text("<b style=\"font-size: 200%\">IT BURNS</b>", "red")
			mod_animation = 30
			if (hulk == 0)
				mod_weak = rand(3, 4)
			mod_eyeblurry = rand(8, 10)
			mod_eyedamage = rand(3, 5)
		else
			mod_eyeblurry = rand(4, 6)

	// No negative values.
	animation_duration = max(0, animation_duration + mod_animation)
	weak = max(0, weak + mod_weak)
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
		src.do_disorient(stamina_damage, weakened = weak*20, stunned = stun*20, disorient = disorient_time, remove_stamina_below_zero = 0, target_type = DISORIENT_EYE)
#else
		changeStatus("weakened", weak*2 SECONDS)
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

/mob/proc/hearing_check(var/consciousness_check = 0)
	return 1

/mob/living/carbon/human/hearing_check(var/consciousness_check = 0)
	if (consciousness_check && (src.stat || src.getStatusDuration("paralysis") || src.sleeping))
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

/mob/living/silicon/hearing_check(var/consciousness_check = 0)
	if (consciousness_check && (src.getStatusDuration("paralysis") || src.sleeping || src.stat))
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
#define DO_NOTHING (!weak && !stun && !misstep && !slow && !drop_item && !ears_damage && !ear_tempdeaf)
/mob/living/apply_sonic_stun(var/weak = 0, var/stun = 8, var/misstep = 0, var/slow = 0, var/drop_item = 0, var/ears_damage = 0, var/ear_tempdeaf = 0, var/stamina_damage = 130)
	if (isintangible(src) || islivingobject(src))
		return
	if (DO_NOTHING)
		return

	// Target checks.
	var/mod_weak = 0 // Note: these aren't multipliers.
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
			mod_weak = -INFINITY
			mod_stun = -INFINITY

	// No negative values.
	weak = max(0, weak + mod_weak)
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
	boutput(src, "<span class='alert'><b>You hear an extremely loud noise!</b></span>")


#ifdef USE_STAMINA_DISORIENT
	src.do_disorient(stamina_damage, weakened = weak*20, stunned = stun*20, disorient = 60, remove_stamina_below_zero = 0, target_type = DISORIENT_EAR)
#else

	changeStatus("weakened", stun*10)

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

		if (weak == 0 && stun == 0 && prob(clamp(drop_item, 0, 100)))
			src.show_message("<span class='alert'><B>You drop what you were holding to clutch at your ears!</B></span>")
			src.drop_item()

	return
#undef DO_NOTHING

/mob/proc/is_mentally_dominated_by(var/mob/dominator)
	if (!dominator || !src.mind)
		return 0

	if (src.mind.master)
		var/mob/mymaster = ckey_to_mob(src.mind.master)
		if (mymaster && (mymaster == dominator))
			return 1

	return 0

/mob/proc/violate_hippocratic_oath()
	if(!src.mind)
		return 0

	src.mind.violated_hippocratic_oath = 1
	return 1

/proc/man_or_woman(var/mob/subject)
	return subject.get_pronouns().preferredGender

/proc/his_or_her(var/mob/subject)
	return subject.get_pronouns().possessive

/proc/him_or_her(var/mob/subject)
	return subject.get_pronouns().objective

/proc/he_or_she(var/mob/subject)
	return subject.get_pronouns().subjective

/proc/hes_or_shes(var/mob/subject)
	var/datum/pronouns/pronouns = subject.get_pronouns()
	return pronouns.subjective + (pronouns.pluralize ? "'re" : "'s")

/proc/himself_or_herself(var/mob/subject)
	return subject.get_pronouns().reflexive

/mob/proc/get_explosion_resistance()
	return min(GET_ATOM_PROPERTY(src, PROP_MOB_EXPLOPROT), 100) / 100

/mob/proc/spread_blood_clothes(mob/whose)
	return

/mob/living/carbon/human/spread_blood_clothes(mob/whose)
	if (!whose || !ismob(whose))
		return

	if (src.wear_mask)
		src.wear_mask.add_blood(whose)
	if (src.head)
		src.head.add_blood(whose)
	if (src.glasses && prob(33))
		src.glasses.add_blood(whose)
	if (prob(15))
		if (src.wear_suit)
			src.wear_suit.add_blood(whose)
		else if (src.w_uniform)
			src.w_uniform.add_blood(whose)

	src.update_clothing()
	src.update_body()
	return

/mob/proc/spread_blood_hands(mob/whose)
	return

/mob/living/carbon/human/spread_blood_hands(mob/whose)
	if (!whose || !ismob(whose))
		return

	if (src.gloves)
		src.gloves.add_blood(whose)
	else
		src.add_blood(whose)
	if (src.equipped())
		var/obj/item/I = src.equipped()
		if (istype(I))
			I.add_blood(whose)
	if (prob(15))
		if (src.wear_suit)
			src.wear_suit.add_blood(whose)
		else if (src.w_uniform)
			src.w_uniform.add_blood(whose)

	src.update_clothing()
	src.update_body()
	return

/mob/proc/is_bleeding()
	return 0

/mob/living/carbon/human/is_bleeding()
	return bleeding

/mob/proc/equipped_limb()
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
			newbody.equip_if_possible(CI, slot_w_uniform) // Has to be at the top of the list, naturally.
			if (CI2) newbody.equip_if_possible(CI2, slot_belt)
			if (CI3) newbody.equip_if_possible(CI3, slot_wear_id)
			if (CI4) newbody.equip_if_possible(CI4, slot_l_store)
			if (CI5) newbody.equip_if_possible(CI5, slot_r_store)

		if (old.wear_suit)
			var/obj/item/CI6 = old.wear_suit
			old.u_equip(CI6)
			newbody.equip_if_possible(CI6, slot_wear_suit)
		if (old.head)
			var/obj/item/CI7 = old.head
			old.u_equip(CI7)
			newbody.equip_if_possible(CI7, slot_head)
		if (old.wear_mask)
			var/obj/item/CI8 = old.wear_mask
			old.u_equip(CI8)
			newbody.equip_if_possible(CI8, slot_wear_mask)
		if (old.ears)
			var/obj/item/CI9 = old.ears
			old.u_equip(CI9)
			newbody.equip_if_possible(CI9, slot_ears)
		if (old.glasses)
			var/obj/item/CI10 = old.glasses
			old.u_equip(CI10)
			newbody.equip_if_possible(CI10, slot_glasses)
		if (old.gloves)
			var/obj/item/CI11 = old.gloves
			old.u_equip(CI11)
			newbody.equip_if_possible(CI11, slot_gloves)
		if (old.shoes)
			var/obj/item/CI12 = old.shoes
			old.u_equip(CI12)
			newbody.equip_if_possible(CI12, slot_shoes)
		if (old.back)
			var/obj/item/CI13 = old.back
			old.u_equip(CI13)
			newbody.equip_if_possible(CI13, slot_back)
		if (old.l_hand)
			var/obj/item/CI14 = old.l_hand
			old.u_equip(CI14)
			newbody.equip_if_possible(CI14, slot_l_hand)
		if (old.r_hand)
			var/obj/item/CI15 = old.r_hand
			old.u_equip(CI15)
			newbody.equip_if_possible(CI15, slot_r_hand)

	SPAWN(2 SECONDS) // Necessary.
		if (newbody)
			newbody.set_face_icon_dirty()
			newbody.set_body_icon_dirty()
			newbody.update_clothing()

	return

// Used to refresh the antagonist overlays certain mobs can see, such as admins, revs or Syndie robots (Convair880).
/mob/proc/antagonist_overlay_refresh(var/bypass_cooldown = 0, var/remove = 0)
	if (!bypass_cooldown && (src.last_overlay_refresh && world.time < src.last_overlay_refresh + 1200))
		return
	if (!(ticker?.mode && current_state >= GAME_STATE_PLAYING))
		return
	if (!ismob(src) || !src.client || !src.mind)
		return

	if (remove)
		goto delete_overlays

	// Setup.
	var/list/can_see = list()
	var/see_traitors = 0
	var/see_nukeops = 0
	var/see_wizards = 0
	var/see_revs = 0
	var/see_heads = 0
	var/see_xmas = 0
	var/see_zombies = 0
	var/see_salvager = 0
	var/see_special = 0 // Just a pass-through. Game mode-specific stuff is handled further down in the proc.
	var/see_everything = 0
	var/datum/gang/gang_to_see = null
	var/PWT_to_see = null
	var/datum/abilityHolder/vampire/V = null
	var/datum/abilityHolder/vampiric_thrall/VT = null

	if (isadminghost(src) || src.client?.adventure_view || current_state >= GAME_STATE_FINISHED)
		see_everything = 1
	else
		if (istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/R = ticker.mode
			var/list/datum/mind/HR = R.head_revolutionaries
			var/list/datum/mind/RR = R.revolutionaries
			if (src.mind in (HR + RR))
				see_revs = 1
			if (src.mind in HR)
				see_heads = 1
		else if (istype(ticker.mode, /datum/game_mode/spy))
			var/datum/game_mode/spy/S = ticker.mode
			var/list/L = S.leaders
			var/list/M = S.spies
			if (src.mind in (L + M))
				see_special = 1
		else if (istype(ticker.mode, /datum/game_mode/gang))
			if(src.mind.gang != null)
				gang_to_see = src.mind.gang
		//mostly took this from gang. I'm sure it can be better though, sorry. -Kyle
		else if (istype(ticker.mode, /datum/game_mode/pod_wars))
			// var/datum/game_mode/pod_wars/PW = ticker.mode
			PWT_to_see = get_pod_wars_team_num(src)
		else if (issilicon(src)) // We need to look for borged antagonists too.
			var/mob/living/silicon/S = src
			if (src.mind.special_role == ROLE_SYNDICATE_ROBOT || (S.syndicate && !S.dependent)) // No AI shells.
				see_traitors = 1
				see_nukeops = 1
				see_revs = 1
		if (istraitor(src) && traitorsseeeachother)
			see_traitors = TRUE
		else if (isnukeop(src) || isnukeopgunbot(src))
			see_nukeops = 1
		else if (iswizard(src))
			see_wizards = 1
		else if (isvampire(src))
			V = src.get_ability_holder(/datum/abilityHolder/vampire)
		else if (isvampiricthrall(src))
			VT = src.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		else if (iszombie(src))
			see_zombies = 1
		else if (src.mind && src.mind.special_role == ROLE_GRINCH)
			see_xmas = 1
		else if (src.mind && src.mind.special_role == ROLE_SALVAGER)
			see_salvager = 1

	// Clear existing overlays.
	delete_overlays:
	for (var/image/I in src.client.images)
		if (!I) continue
		if (I.icon == 'icons/mob/antag_overlays.dmi')
			//DEBUG_MESSAGE("Deleted overlay ([I.icon_state]) from [src].")
			qdel(I)
			src.client.images -= I
			src.client.screen -= I

	if (remove)
		return

	if (!see_traitors && !see_nukeops && !see_wizards && !see_revs && !see_heads && !see_xmas && !see_zombies && !see_salvager && !see_special && !see_everything && gang_to_see == null && PWT_to_see == null && !V && !VT)
		src.last_overlay_refresh = world.time
		return

	// Default antagonists that can appear in every game mode.
	var/list/datum/mind/regular = ticker.mode.traitors
	var/list/datum/mind/misc = ticker.mode.Agimmicks

	var/robot_override = 0 // Syndicate/emagged robot overlay overrides traitor etc for borged antagonists.

	for (var/datum/mind/M in (regular + misc))
		robot_override = 0 // Gotta reset this.

		if (!M.current) // no body?
			continue
		if (!see_everything && isobserver(M.current))
			continue

		if (issilicon(M.current)) // We need to look for borged antagonists too.
			var/mob/living/silicon/S = M.current
			if (M.special_role == ROLE_SYNDICATE_ROBOT || (S.syndicate && !S.dependent)) // No AI shells.
				if (see_everything || see_traitors)
					if (!see_everything && isdead(S)) continue
					var/I = image(antag_syndieborg, loc = M.current)
					can_see.Add(I)
					robot_override = 1
			if (M.special_role == ROLE_EMAGGED_ROBOT || (S.emagged && !S.dependent))
				if (see_everything)
					var/I = image(antag_emagged, loc = M.current)
					can_see.Add(I)
					robot_override = 1

		if (robot_override != 1)
			switch (M.special_role)
				if (ROLE_TRAITOR, ROLE_HARDMODE_TRAITOR, ROLE_SLEEPER_AGENT)
					if (see_everything || see_traitors)
						var/I = image(antag_traitor, loc = M.current)
						can_see.Add(I)
				if (ROLE_CHANGELING)
					if (see_everything)
						var/I = image(antag_changeling, loc = M.current)
						can_see.Add(I)
				if (ROLE_WIZARD)
					if (see_everything || see_wizards)
						var/I = image(antag_wizard, loc = M.current)
						can_see.Add(I)
				if (ROLE_VAMPIRE)
					var/datum/abilityHolder/vampire/MV = M.current.get_ability_holder(/datum/abilityHolder/vampire)
					if (see_everything || (src in MV?.thralls)) // you're their thrall
						var/I = image(antag_vampire, loc = M.current)
						can_see.Add(I)
				if (ROLE_HUNTER)
					if (see_everything)
						var/I = image(antag_hunter, loc = M.current)
						can_see.Add(I)
				if (ROLE_WEREWOLF)
					if (see_everything)
						var/I = image(antag_werewolf, loc = M.current)
						can_see.Add(I)
				if (ROLE_VAMPTHRALL)
					var/datum/abilityHolder/vampiric_thrall/VT2 = M.current.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
					if (see_everything || (M.current in V?.thralls) || (VT?.master == VT2?.master)) // they're your thrall or they have the same vamp master
						var/I = image(antag_vampthrall, loc = M.current)
						can_see.Add(I)
				if (ROLE_WRAITH)
					if (see_everything)
						var/I = image(antag_wraith, loc = M.current)
						can_see.Add(I)
				if (ROLE_BLOB)
					if (see_everything)
						var/I = image(antag_blob, loc = M.current)
						can_see.Add(I)
				if (ROLE_OMNITRAITOR)
					if (see_everything)
						var/I = image(antag_omnitraitor, loc = M.current)
						can_see.Add(I)
				if (ROLE_WRESTLER)
					if (see_everything)
						var/I = image(antag_wrestler, loc = M.current)
						can_see.Add(I)
				if (ROLE_GRINCH)
					if (see_everything || see_xmas)
						var/I = image(antag_grinch, loc = M.current)
						can_see.Add(I)
				if (ROLE_SPY_THIEF)
					if (see_everything)
						var/I = image(antag_spy_theft, loc = M.current)
						can_see.Add(I)
				if (ROLE_ARCFIEND)
					if (see_everything)
						var/I = image(antag_arcfiend, loc = M.current)
						can_see.Add(I)
				if (ROLE_ZOMBIE)
					if (see_everything || see_zombies)
						var/I = image(antag_generic, loc = M.current)
						can_see.Add(I)
				if (ROLE_SALVAGER)
					if (see_everything || see_salvager)
						var/I = image(antag_salvager, loc = M.current)
						can_see.Add(I)
				else
					if (see_everything)
						var/I = image(antag_generic, loc = M.current) // Default to this.
						can_see.Add(I)

	// Antagonists who generally only appear in certain game modes.
	if (istype(ticker.mode, /datum/game_mode/revolution))
		var/datum/game_mode/revolution/R = ticker.mode
		var/list/datum/mind/HR = R.head_revolutionaries
		var/list/datum/mind/RR = R.revolutionaries
		var/list/datum/mind/heads = R.get_all_heads()

		if (see_revs || see_everything)
			for (var/datum/mind/M in HR)
				if (M.current)
					if (!see_everything && isobserver(M.current)) continue
					var/I = image(antag_revhead, loc = M.current, icon_state = null, layer = (EFFECTS_LAYER_UNDER_4 + 0.1)) //secHuds are on EFFECTS_LAYER_UNDER_4
					can_see.Add(I)
			for (var/datum/mind/M in RR)
				if (M.current)
					if (!see_everything && isobserver(M.current)) continue
					var/I = image(antag_rev, loc = M.current, icon_state = null, layer = (EFFECTS_LAYER_UNDER_4 + 0.1))
					can_see.Add(I)

		if (see_heads || see_everything)
			for (var/datum/mind/M in heads)
				if (M.current)
					var/I = image(antag_head, loc = M.current, icon_state = null, layer = (EFFECTS_LAYER_UNDER_4 + 0.1))
					can_see.Add(I)

	else if (istype(ticker.mode, /datum/game_mode/nuclear))
		var/datum/game_mode/nuclear/N = ticker.mode
		var/list/datum/mind/syndicates = N.syndicates
		if (see_nukeops || see_everything)
			for (var/datum/mind/M in syndicates)
				if (M.current)
					if (!see_everything && isobserver(M.current)) continue
					var/I = image(antag_syndicate, loc = M.current)
					can_see.Add(I)

	else if (istype(ticker.mode, /datum/game_mode/spy))
		var/datum/game_mode/spy/S = ticker.mode
		var/list/spies = S.spies
		if (see_everything)
			for (var/datum/mind/M in S.leaders)
				if (M.current)
					var/I = image(antag_spyleader, loc = M.current)
					can_see.Add(I)
			for (var/datum/mind/M in spies)
				if (M.current)
					var/I = image(antag_spyminion, loc = M.current)
					can_see.Add(I)

		else if (src.mind in spies)
			var/datum/mind/leader_mind = spies[src.mind]
			if (istype(leader_mind) && leader_mind.current && !isobserver(leader_mind.current))
				var/I = image(antag_spyleader, loc = leader_mind.current)
				can_see.Add(I)

	else if (istype(ticker.mode, /datum/game_mode/gang))
		var/datum/game_mode/gang/mode = ticker.mode

		for (var/datum/gang/G in mode.gangs)
			if (G != gang_to_see && !see_everything) continue

			if(G.leader && G.leader.current)
				if (!see_everything && isobserver(G.leader.current)) continue
				var/I = image(antag_gang_leader, loc = G.leader.current)
				can_see.Add(I)

			for(var/datum/mind/M in G.members)
				if(M.current)
					if (!see_everything && isobserver(M.current)) continue
					var/II = image(antag_gang, loc = M.current)
					can_see.Add(II)
	else if (istype(ticker.mode, /datum/game_mode/pod_wars))
		var/datum/game_mode/pod_wars/mode = ticker.mode
		if (PWT_to_see || see_everything)
			for (var/datum/mind/M in (mode.team_NT.members + mode.team_SY.members))
				if (M.current)
					var/cur_team
					cur_team = get_pod_wars_team_num(M.current)
					if (!see_everything && isobserver(M.current)) continue
					if (PWT_to_see == cur_team)//NANOTRASEN
						if (cur_team == 1)
							var/image/I = image(pod_wars_NT, loc = M.current)
							I.pixel_y = 4
							can_see.Add(I)
						if (cur_team == 2)
					// else if (PWT_to_see == cur_team)//SYNDICATE
							var/image/I = image(pod_wars_SY, loc = M.current)
							I.pixel_y = 4
							can_see.Add(I)

			//show commanders to everyone, can't hide.
			//Alright, I'll confess. this draws the commander over the other one. idk how this shit works and it works anyway, I'm not in the mood to learn for real. -Kyle
			if(mode.team_NT.commander && mode.team_NT.commander.current)
				// if (PWT_to_see == mode.team_NT || see_everything)
				var/image/I = image(pod_wars_NT_CMDR, loc = mode.team_NT.commander.current)
				I.pixel_y = 4
				can_see.Add(I)

			if(mode.team_SY.commander && mode.team_SY.commander.current)
				// if (PWT_to_see == mode.team_SY || see_everything)
				var/image/I = image(pod_wars_SY_CMDR, loc = mode.team_SY.commander.current)
				I.pixel_y = 4
				can_see.Add(I)


	if (can_see.len > 0)
		//logTheThing(LOG_DEBUG, src, "<b>Convair880 antag overlay:</b> [can_see.len] added with parameters all ([see_everything]), T ([see_traitors]), S ([see_nukeops]), W ([see_wizards]), R ([see_revs]), SP ([see_special])")
		//DEBUG_MESSAGE("Overlay parameters for [src]: all ([see_everything]), T ([see_traitors]), S ([see_nukeops]), W ([see_wizards]), R ([see_revs]), SP ([see_special])")
		//DEBUG_MESSAGE("Added [can_see.len] overlays to [src].")
		src.client.images.Add(can_see)

	src.last_overlay_refresh = world.time
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
				src.visible_message("<span class='alert'>[src] smashes through the window.</span>", "<span class='notice'>You smash through the window.</span>")
			W.health = 0
			W.smash()
			return TRUE

		if (S == "grille" && istype(target, /obj/grille))
			var/obj/grille/G = target
			if (!G.shock(src, 70))
				if (show_message)
					G.visible_message("<span class='alert'><b>[src]</b> violently slashes [G]!</span>")
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
				src.visible_message("<span class='alert'><B>[src] savagely slashes [B]!</span>", "<span class='notice'>You savagely slash at \the [B]</span>")
			B.take_damage(rand(10,20),1,DAMAGE_CUT)
			playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
			return TRUE
	return FALSE

/mob/proc/saylist(var/message, var/list/heard, var/list/olocs, var/thickness, var/italics, var/list/processed, var/use_voice_name = 0, var/image/chat_maptext/assoc_maptext = null)
	var/message_a

	message_a = src.say_quote(message)

	if (italics)
		message_a = "<i>[message_a]</i>"

	var/my_name = "<span class='name' data-ctx='\ref[src.mind]'>[src.voice_name]</span>"
	if (!use_voice_name)
		my_name = src.get_heard_name()
	var/rendered = "<span class='game say'>[my_name] <span class='message'>[message_a]</span></span>"

	var/rendered_outside = null
	if (olocs.len)
		var/atom/movable/OL = olocs[olocs.len]
		if (thickness < 0)
			rendered_outside = rendered
		else if (thickness == 0)
			rendered_outside = "<span class='game say'>[my_name] (on [bicon(OL)] [OL]) <span class='message'>[message_a]</span></span>"
		else if (thickness < 10)
			rendered_outside = "<span class='game say'>[my_name] (inside [bicon(OL)] [OL]) <span class='message'>[message_a]</span></span>"
		else if (thickness < 20)
			rendered_outside = "<span class='game say'>muffled <span class='name' data-ctx='\ref[src.mind]'>[src.voice_name]</span> (inside [bicon(OL)] [OL]) <span class='message'>[message_a]</span></span>"

	for (var/mob/M in heard)
		if (M in processed)
			continue
		processed += M
		var/thisR = rendered

		if (olocs.len && !(M.loc in olocs))
			if (rendered_outside)
				thisR = rendered_outside
			else
				continue
		else
			if (isghostdrone(M) && !isghostdrone(src) && !istype(M, /mob/living/silicon/ghostdrone/deluxe))
				thisR = "<span class='game say'><span class='name' data-ctx='\ref[src.mind]'>[src.voice_name]</span> <span class='message'>[message_a]</span></span>"

		if (M.client && (istype(M, /mob/dead/observer)||M.client.holder) && src.mind)
			thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[thisR]</span>"
		M.heard_say(src, message)
		M.show_message(thisR, 2, assoc_maptext = assoc_maptext)

	return processed


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
		G.invisibility = new_invis
		REMOVE_ATOM_PROPERTY(G, PROP_MOB_INVISIBILITY, G)
		APPLY_ATOM_PROPERTY(G, PROP_MOB_INVISIBILITY, G, new_invis)
		if (new_invis != prev_invis && (new_invis == 0 || prev_invis == 0))
			boutput(G, "<span class='notice'>You are [new_invis == 0 ? "now" : "no longer"] visible to the living!</span>")


