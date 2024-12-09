/mob/living/carbon/human
	name = "human"
	voice_name = "human"
	icon = 'icons/mob/mob.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "m-none"
#else
	icon_state = "blank"
#endif
	throw_range = 4
	p_class = 1.5 // 1.5 while standing, 2.5 while resting)

	event_handler_flags = USE_FLUID_ENTER  | IS_FARTABLE
	mob_flags = IGNORE_SHIFT_CLICK_MODIFIER

	var/dump_contents_chance = 20

	var/image/health_mon = null
	var/list/prodoc_icons = null
	var/image/arrestIcon = null

	var/pin = null
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/under/w_uniform = null
	var/obj/item/clothing/shoes/shoes = null
	var/obj/item/belt = null
	var/obj/item/clothing/gloves/gloves = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/clothing/head/head = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null

	var/clothing_dirty = 0

	var/image/body_standing = null
	var/image/tail_standing = null
	var/image/tail_standing_oversuit = null
	var/image/detail_standing_oversuit = null
	var/image/fire_standing = null
	var/image/hands_standing = null

	var/image/body_damage_standing = null
	var/image/head_damage_standing = null
	var/image/l_arm_damage_standing = null
	var/image/r_arm_damage_standing = null
	var/image/l_leg_damage_standing = null
	var/image/r_leg_damage_standing = null

	var/image/image_eyes_L = null
	var/image/image_eyes_R = null
	var/image/image_cust_one = null
	var/image/image_cust_two = null
	var/image/image_cust_three = null
	var/image/image_special_one = null
	var/image/image_special_two = null
	var/image/image_special_three = null

	///Has our chest cavity been clamped by hemostats?
	var/chest_cavity_clamped = FALSE
	var/obj/item/chest_item = null	// Item stored in chest cavity
	var/chest_item_sewn = FALSE		// Item is sewn in or is loose

	var/cust_icon = 'icons/mob/human_hair.dmi'	// icon for hair, in case we want something else
	var/special_one_icon = 'icons/mob/human_hair.dmi'
	var/special_one_state = "none"
	var/special_two_icon = 'icons/mob/human_hair.dmi'
	var/special_two_state = "none"
	var/special_three_icon = 'icons/mob/human_hair.dmi'
	var/special_three_state = "none"

	var/ignore_organs = 0 // set to 1 to basically skip the handle_organs() proc
	var/robotic_organs = 0
	var/last_eyes_blinded = 0 // used in handle_blindness_overlays() to determine if a change is needed!

	var/obj/on_chair = null
	var/simple_examine = FALSE

	var/in_throw_mode = 0

	var/yeet_chance = 0.1 //yeet

	var/decomp_stage = DECOMP_STAGE_NO_ROT
	var/time_until_decomposition = 0
	var/uses_damage_overlays = 1 //If set to 0, the mob won't receive any damage overlays.

	var/datum/mutantrace/mutantrace = null
	/// used by werewolf TF to store and restore what you were before TFing into a werewolf
	var/datum/mutantrace/coreMR = null // There are two wolves inside you. One's a wolf, the other's probably some kind of lizard. Also one's actually you, and they trade places Hannah Montana style

	var/emagged = 0 //What the hell is wrong with me?
	var/spiders = 0 // SPIDERS
	var/makeup = null // for when you wanna look pretty
	var/makeup_color = null

	var/gunshot_residue = 0 // Fire a kinetic firearm and get forensic evidence all over you (Convair880).

	var/datum/hud/human/hud
	var/mini_health_hud = 0

	//The spooky UNKILLABLE MAN
	var/unkillable = 0

	var/mob/living/carbon/target = null
	var/ai_aggressive = 0
	var/ai_default_intent = INTENT_DISARM
	var/ai_calm_down = 0 // do we chill out after a while?
	var/ai_picking_pocket = 0
	var/ai_offhand_pickup_chance = 50
	var/bruteloss = 0
	var/burnloss = 0

	max_health = 100

	var/datum/weakref/trinket = null //Used for spy_theft mode - this is an item that is eligible to have a bounty on it

	//dismemberment stuff
	var/datum/human_limbs/limbs = null

	var/static/image/human_image = image('icons/mob/human.dmi')
	var/static/image/human_head_image = image('icons/mob/human_head.dmi')
	var/static/image/human_detail_image = image('icons/mob/human.dmi', layer = MOB_OVERSUIT_LAYER2)
	var/static/image/human_tail_image = image('icons/mob/human.dmi')
	var/static/image/human_untoned_image = image('icons/mob/human.dmi')
	var/static/image/human_decomp_image = image('icons/mob/human_decomp.dmi')
	var/static/image/human_untoned_decomp_image = image('icons/mob/human.dmi')
	var/static/image/undies_image = image('icons/mob/human_underwear.dmi') //, layer = MOB_UNDERWEAR_LAYER)
	var/static/image/bandage_image = image('icons/obj/surgery.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/heart_image = image('icons/mob/human.dmi')
	var/static/image/heart_emagged_image = image('icons/mob/human.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/spider_image = image('icons/mob/human.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/makeup_image = image('icons/mob/human.dmi') // yeah this is just getting stupider

	var/list/juggling = list()
	var/can_juggle = 0
	///A dummy object that juggled objects go in the vis_contents of, so they can be scaled visually without affecting their actual scale
	var/obj/dummy/juggle_dummy = null

	// preloaded sounds moved up to /mob/living

	var/list/sound_list_scream = null
	var/list/sound_list_laugh = null
	var/list/sound_list_flap = null

	var/datum/simsHolder/sims = null

	/// forces the mob to wear underpants, even if their flags tell them not to
	var/underpants_override = 0
	/// forces the mob to display human hair, even if their flags tell them not to
	var/hair_override = 0 // only really works if they have hair. Barbering might help
	/// forces the mob to display their special hair, even if their flags tell them not to
	var/special_hair_override = 0 // only really works if they have any special hair
	var/trample_cooldown = 4 SECONDS

	random_emotes = list("drool", "blink", "yawn", "burp", "twitch", "twitch_v",\
	"cough", "sneeze", "shiver", "shudder", "shake", "hiccup", "sigh", "flinch", "blink_r",\
	"pale", "blush", "scratch", "stretch", /*"fart", */"smile")

	var/icon/flat_icon = null

	can_bleed = 1
	blood_id = "blood"
	blood_volume = 500
	dna_to_absorb = 10

	void_mindswappable = TRUE

	var/datum/humanInventory/inventory = null

	var/default_mutantrace = /datum/mutantrace/human

/mob/living/carbon/human/New(loc, datum/appearanceHolder/AH_passthru, datum/preferences/init_preferences, ignore_randomizer=FALSE, role_for_traits)
	. = ..()

	image_eyes_L = image('icons/mob/human_hair.dmi', layer = MOB_FACE_LAYER)
	image_eyes_R = image('icons/mob/human_hair.dmi', layer = MOB_FACE_LAYER)
	image_cust_one = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)
	image_cust_two = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)
	image_cust_three = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)

	src.create_reagents(330)

	hud = new(src)
	src.attach_hud(hud)
	src.zone_sel = new(src)
	src.attach_hud(zone_sel)
	src.update_equipment_screen_loc()

	if (src.stamina_bar)
		hud.add_object(src.stamina_bar, initial(src.stamina_bar.layer), "EAST-1, NORTH")


	if (global_sims_mode) // IF YOU ARE HERE TO DISABLE SIMS MODE, DO NOT TOUCH THIS. LOOK IN GLOBAL.DM
#ifdef RP_MODE
		sims = new /datum/simsHolder/rp(src)
#else
		sims = new /datum/simsHolder/human(src)
#endif

	health_mon = image('icons/effects/healthgoggles.dmi',src,"100",EFFECTS_LAYER_UNDER_4)
	health_mon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_image(health_mon)

	prodoc_icons = list()
	// 0.01 layering increases to guarantee layering over the health monitor icon
	prodoc_icons["health"] = image('icons/effects/healthgoggles.dmi',src,null,EFFECTS_LAYER_UNDER_4 + 0.01)
	prodoc_icons["cloner"] = image('icons/effects/healthgoggles.dmi',src,null,EFFECTS_LAYER_UNDER_4 + 0.01)
	prodoc_icons["other"] = image('icons/effects/healthgoggles.dmi',src,null,EFFECTS_LAYER_UNDER_4 + 0.01)
	prodoc_icons["robotic_organs"] = image('icons/effects/healthgoggles.dmi',src,null,EFFECTS_LAYER_UNDER_4 + 0.01)
	for (var/implant in prodoc_icons)
		var/image/image = prodoc_icons[implant]
		image.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_image(image)

	arrestIcon = image('icons/effects/sechud.dmi',src,null,EFFECTS_LAYER_UNDER_4)
	arrestIcon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_image(arrestIcon)

	src.organHolder = new(src)

	if (!bioHolder)
		bioHolder = new/datum/bioHolder(src)
		src.initializeBioholder()
	if (!abilityHolder)
		abilityHolder = new /datum/abilityHolder/composite(src)

	if (src.disposed || src.qdeled || !src.bioHolder)
		return

	src.limbs = new /datum/human_limbs(src)

	src.update_body()
	src.update_face()
	src.UpdateDamageIcon()
	START_TRACKING

	// for pope
	if (microbombs_4_everyone)
		if (isnum(microbombs_4_everyone))
			var/obj/item/implant/revenge/microbomb/MB = new (src)
			MB.power = microbombs_4_everyone

	src.text = "<font color=#[random_hex(3)]>@"
	src.set_mutantrace(src.default_mutantrace)
	src.update_colorful_parts()

	init_preferences?.apply_post_new_stuff(src, role_for_traits)

	inventory = new(src)

	AddComponent(/datum/component/contraband, 0, 0)

/datum/human_limbs
	var/mob/living/carbon/human/holder = null

	var/obj/item/parts/l_arm = null
	var/obj/item/parts/r_arm = null
	var/obj/item/parts/l_leg = null
	var/obj/item/parts/r_leg = null

	New(mob/new_holder, var/ling) // to prevent lings from spawning a shitload of limbs in unspeakable locations
		..()
		holder = new_holder
		if (holder && !ling)
			create(holder.AH_we_spawned_with)

	disposing()
		if (l_arm)
			l_arm.holder = null
			l_arm?.bones?.donor = null
		if (r_arm)
			r_arm.holder = null
			r_arm?.bones?.donor = null
		if (l_leg)
			l_leg.holder = null
			l_leg?.bones?.donor = null
		if (r_leg)
			r_leg.holder = null
			r_leg?.bones?.donor = null
		holder = null
		..()

	proc/create(var/datum/appearanceHolder/AHolLimb)
		if (!l_arm) l_arm = new /obj/item/parts/human_parts/arm/left(holder, AHolLimb)
		if (!r_arm) r_arm = new /obj/item/parts/human_parts/arm/right(holder, AHolLimb)
		if (!l_leg) l_leg = new /obj/item/parts/human_parts/leg/left(holder, AHolLimb)
		if (!r_leg) r_leg = new /obj/item/parts/human_parts/leg/right(holder, AHolLimb)

	proc/mend(var/howmany = 4)
		if (!holder)
			return

		var/force_redraw = FALSE

		if (!l_arm && howmany > 0)
			if (holder?.mutantrace?.l_limb_arm_type_mutantrace)
				l_arm = new holder.mutantrace.l_limb_arm_type_mutantrace(holder)
			else
				l_arm = new /obj/item/parts/human_parts/arm/left(holder)
			l_arm.holder = holder
			boutput(holder, SPAN_NOTICE("Your left arm regrows!"))
			l_arm:original_holder = holder
			l_arm:set_skin_tone()
			holder.hud.update_hands()
			howmany--
			force_redraw = TRUE

		if (!r_arm && howmany > 0)
			if (holder?.mutantrace?.r_limb_arm_type_mutantrace)
				r_arm = new holder.mutantrace.r_limb_arm_type_mutantrace(holder)
			else
				r_arm = new /obj/item/parts/human_parts/arm/right(holder)
			r_arm.holder = holder
			boutput(holder, SPAN_NOTICE("Your right arm regrows!"))
			r_arm:original_holder = holder
			r_arm:set_skin_tone()
			holder.hud.update_hands()
			howmany--
			force_redraw = TRUE

		if (!l_leg && howmany > 0)
			if (holder?.mutantrace?.l_limb_leg_type_mutantrace)
				l_leg = new holder.mutantrace.l_limb_leg_type_mutantrace(holder)
			else
				l_leg = new /obj/item/parts/human_parts/leg/left(holder)
			l_leg.holder = holder
			boutput(holder, SPAN_NOTICE("Your left leg regrows!"))
			l_leg:original_holder = holder
			l_leg:set_skin_tone()
			howmany--
			force_redraw = TRUE

		if (!r_leg && howmany > 0)
			if (holder?.mutantrace?.r_limb_leg_type_mutantrace)
				r_leg = new holder.mutantrace.r_limb_leg_type_mutantrace(holder)
			else
				r_leg = new /obj/item/parts/human_parts/leg/right(holder)
			r_leg.holder = holder
			boutput(holder, SPAN_NOTICE("Your right leg regrows!"))
			r_leg:original_holder = holder
			r_leg:set_skin_tone()
			howmany--
			force_redraw = TRUE

		if(force_redraw)
			src.holder.update_body()

		if (holder.client) holder.next_move = world.time + 7 //Fix for not being able to move after you got new limbs.

	proc/reset_stone() // reset skintone to whatever the holder's s_tone is
		if (l_arm && istype(l_arm, /obj/item/parts/human_parts))
			l_arm:set_skin_tone()
		if (r_arm && istype(r_arm, /obj/item/parts/human_parts))
			r_arm:set_skin_tone()
		if (l_leg && istype(l_leg, /obj/item/parts/human_parts))
			l_leg:set_skin_tone()
		if (r_leg && istype(r_leg, /obj/item/parts/human_parts))
			r_leg:set_skin_tone()

	proc/sever(var/target = "all", var/mob/user)
		if (!target)
			return 0
		if (istext(target))
			var/list/limbs_to_sever = list()
			switch (target)
				if ("all")
					limbs_to_sever += list(src.l_arm, src.r_arm, src.l_leg, src.r_leg)
				if ("both_arms")
					limbs_to_sever += list(src.l_arm, src.r_arm)
				if ("both_legs")
					limbs_to_sever += list(src.l_leg, src.r_leg)
				if ("l_arm")
					limbs_to_sever += list(src.l_arm)
				if ("r_arm")
					limbs_to_sever += list(src.r_arm)
				if ("l_leg")
					limbs_to_sever += list(src.l_leg)
				if ("r_leg")
					limbs_to_sever += list(src.r_leg)
			if (length(limbs_to_sever))
				for (var/obj/item/parts/P in limbs_to_sever)
					P.sever(user)
				return 1
		else if (istype(target, /obj/item/parts))
			var/obj/item/parts/P = target
			P.sever(user)
			return 1

	// quick hacky thing to have similar functionality to get_organ
	// maybe one day one of us will make this better - cirr
	proc/get_limb(var/limb)
		RETURN_TYPE(/obj/item/parts)
		if(!limb)
			return
		switch(limb)
			if("l_arm")
				. = l_arm
			if("r_arm")
				. = r_arm
			if("l_leg")
				. = l_leg
			if("r_leg")
				. = r_leg

	proc/replace_with(var/target, var/new_type, var/mob/user, var/show_message = 1, var/no_drop = FALSE)
		if (!target || !new_type || !src.holder)
			return 0
		if (istext(target) && ispath(new_type))
			if (target == "both_arms" || target == "l_arm")
				if (ispath(new_type, /obj/item/parts/human_parts/arm) || ispath(new_type, /obj/item/parts/robot_parts/arm) || ispath(new_type, /obj/item/parts/artifact_parts/arm))
					var/l_held_item
					if (src.l_arm)
						if (no_drop && src.holder.l_hand)
							l_held_item = src.holder.l_hand
						src.l_arm.delete()
					src.l_arm = new new_type(src.holder)
					if (l_held_item)
						src.holder.equip_if_possible(l_held_item, SLOT_L_HAND)
				else // need to make an item arm
					if (src.l_arm)
						src.l_arm.delete()
					src.l_arm = new /obj/item/parts/human_parts/arm/left/item(src.holder, new new_type(src.holder))
				src.holder.hud.update_hands()
				if (show_message)
					src.holder.show_message(SPAN_NOTICE("<b>Your left arm [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.l_arm]!</b>"))
				if (user)
					logTheThing(LOG_ADMIN, user, "replaced [constructTarget(src.holder,"admin")]'s left arm with [new_type]")
				. ++

			if (target == "both_arms" || target == "r_arm")
				if (ispath(new_type, /obj/item/parts/human_parts/arm) || ispath(new_type, /obj/item/parts/robot_parts/arm) || ispath(new_type, /obj/item/parts/artifact_parts/arm))
					var/r_held_item
					if (src.r_arm)
						if (no_drop && src.holder.r_hand)
							r_held_item = src.holder.r_hand
						src.r_arm.delete()
					src.r_arm = new new_type(src.holder)
					if (r_held_item)
						src.holder.equip_if_possible(r_held_item, SLOT_R_HAND)
				else // need to make an item arm
					if (src.r_arm)
						src.r_arm.delete()
					src.r_arm = new /obj/item/parts/human_parts/arm/right/item(src.holder, new new_type(src.holder))
				src.holder.hud.update_hands()
				if (show_message)
					src.holder.show_message(SPAN_NOTICE("<b>Your right arm [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.r_arm]!</b>"))
				if (user)
					logTheThing(LOG_ADMIN, user, "replaced [constructTarget(src.holder,"admin")]'s right arm with [new_type]")
				. ++

			if (target == "both_legs" || target == "l_leg")
				if (ispath(new_type, /obj/item/parts/human_parts/leg) || ispath(new_type, /obj/item/parts/robot_parts/leg) || ispath(new_type, /obj/item/parts/artifact_parts/leg))
					qdel(src.l_leg)
					src.l_leg = new new_type(src.holder)
					if (show_message)
						src.holder.show_message(SPAN_NOTICE("<b>Your left leg [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.l_leg]!</b>"))
					if (user)
						logTheThing(LOG_ADMIN, user, "replaced [constructTarget(src.holder,"admin")]'s left leg with [new_type]")
					. ++

			if (target == "both_legs" || target == "r_leg")
				if (ispath(new_type, /obj/item/parts/human_parts/leg) || ispath(new_type, /obj/item/parts/robot_parts/leg) || ispath(new_type, /obj/item/parts/artifact_parts/leg))
					qdel(src.r_leg)
					src.r_leg = new new_type(src.holder)
					if (show_message)
						src.holder.show_message(SPAN_NOTICE("<b>Your right leg [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.r_leg]!</b>"))
					if (user)
						logTheThing(LOG_ADMIN, user, "replaced [constructTarget(src.holder,"admin")]'s right leg with [new_type]")
					. ++
			if (.)
				src.holder.set_body_icon_dirty()
			return
		return 0

	proc/randomize(var/target, var/mob/user, var/show_message = 1)
		if (!src.holder || !target)
			return 0
		if (istext(target))
			var/randlimb = null
			if (target == "all" || target == "both_arms" || target == "l_arm")
				randlimb = pick(all_valid_random_left_arms)
				. += src.replace_with("l_arm", randlimb, user, show_message)
			if (target == "all" || target == "both_arms" || target == "r_arm")
				randlimb = pick(all_valid_random_right_arms)
				. += src.replace_with("r_arm", randlimb, user, show_message)
			if (target == "all" || target == "both_legs" || target == "r_leg")
				randlimb = pick(all_valid_random_right_legs)
				. += src.replace_with("r_leg", randlimb, user, show_message)
			if (target == "all" || target == "both_legs" || target == "l_leg")
				randlimb = pick(all_valid_random_left_legs)
				. += src.replace_with("l_leg", randlimb, user, show_message)
		return .

	proc/rename_limbs(user_name)
		for(var/atom/limb in list(l_arm, r_arm, l_leg, r_leg))
			var/list/limb_name_parts = splittext(limb.name, "'s")
			if(length(limb_name_parts) == 2)
				limb.name = "[user_name]'s [limb_name_parts[2]]"

/mob/living/carbon/human/proc/is_vampire()
	return get_ability_holder(/datum/abilityHolder/vampire)

/mob/living/carbon/human/proc/is_vampiric_thrall()
	return get_ability_holder(/datum/abilityHolder/vampiric_thrall)

/mob/living/carbon/human/is_open_container()
	return !(src.organHolder?.head)

/mob/living/carbon/human/disposing()
	for(var/obj/item/I in src)
		if(I.equipped_in_slot != SLOT_W_UNIFORM)
			src.u_equip(I)
	if(src.w_uniform) // last because pockets etc.
		src.u_equip(src.w_uniform)

	if (hud)
		if(src.stamina_bar)
			hud.remove_object(stamina_bar)

		if (hud.master == src)
			hud.master = null
		hud.inventory_bg = null
		hud.inventory_items = null
		qdel(hud)

	STOP_TRACKING

	for(var/obj/item/implant/imp in src.implant)
		imp.dispose()
	src.implant = null

	if(health_mon)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_image(health_mon)
		health_mon.dispose()
		health_mon = null
	if(prodoc_icons)
		for (var/implant in prodoc_icons)
			var/image/I = prodoc_icons[implant]
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_image(I)
			I.dispose()
		prodoc_icons = null
	if(arrestIcon)
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_image(arrestIcon)
		arrestIcon.dispose()
		arrestIcon = null

	src.chest_item = null

	QDEL_NULL(src.mutantrace)

	target = null

	QDEL_NULL(src.limbs)
	QDEL_NULL(src.organHolder)
	QDEL_NULL(src.cloner_defects)
	QDEL_NULL(src.inventory)

	src.juggle_dummy = null

	..()

	//blah, this might not be effective for ref clearing but ghost observers inside me NEED this list to be populated in base mob/disposing
	//if (islist(hud.objects))//possibly causing bug where gibbed persons UI persistss on ghosts
	//	hud.objects.len = 0

// death

/mob/living/carbon/human/disposing()
	for (var/obj/item/parts/HP in src)
		if (istype(HP,/obj/item/parts/human_parts))
			if (HP.bones && HP.bones.donor == src)
				HP.dispose()

			var/obj/item/parts/human_parts/humanpart = HP
			humanpart.original_holder = null

		HP.holder = null

	//limbs may be detacherd?
	if (src.limbs)
		if (src.limbs.l_arm && istype(src.limbs.l_arm, /obj/item/parts/human_parts))
			src.limbs.l_arm:original_holder = null
		if (src.limbs.r_arm && istype(src.limbs.r_arm, /obj/item/parts/human_parts))
			src.limbs.r_arm:original_holder = null
		if (src.limbs.l_leg && istype(src.limbs.l_leg, /obj/item/parts/human_parts))
			src.limbs.l_leg:original_holder = null
		if (src.limbs.r_leg && istype(src.limbs.r_leg, /obj/item/parts/human_parts))
			src.limbs.r_leg:original_holder = null


	for (var/obj/item/organ/O in src)
		O.donor = null
	for (var/obj/item/implant/I in src)
		I.implanted = null
		I.owner = null
		I.former_implantee = null
	..()

/mob/living/carbon/human/death(gibbed)
	if (ticker?.mode)
		ticker.mode?.on_human_death(src)
	if(src.mind && src.mind.damned) // Ha you arent getting out of hell that easy.
		src.hell_respawn()
		return
	if (isdead(src))
		return

	if (health_mon)
		health_mon.icon_state = "-1"

	src.need_update_item_abilities = 1
	setdead(src)
	src.dizziness = 0
	src.jitteriness = 0

	for (var/obj/item/implant/H in src.implant)
		H.on_death()

	src.drop_juggle()

#ifdef DATALOGGER
	game_stats.Increment("deaths")
#endif

	if (src.mind?.key)
		var/datum/player/P = find_player(src.mind.key)
		P.last_death_time = world.timeofday


	//The unkillable man just respawns nearby! Oh no!
	if (src.unkillable || src.spell_soulguard)
		if (src.unkillable && src.mind.get_player()?.dnr) //Unless they have dnr set in which case rip for good
			logTheThing(LOG_COMBAT, src, "was about to be respawned (Unkillable) but had DNR set.")
			if (!gibbed)
				src.gib()
			boutput(src, SPAN_ALERT("The shield hisses and buzzes grumpily! It's almost as if you have some sort of option set that prevents you from coming back to life. Fancy that."))
			var/obj/item/unkill_shield/U = new /obj/item/unkill_shield
			U.set_loc(src.loc)
		else
			logTheThing(LOG_COMBAT, src, "respawns ([src.spell_soulguard ? "Soul Guard" : "Unkillable"])")
			src.unkillable_respawn()

	if(src.traitHolder && src.traitHolder.hasTrait("soggy"))
		src.unequip_all()
		src.gib()
		return

	//Zombies just rise again (after a delay)! Oh my!
	var/mutrace_result = src.mutantrace.onDeath(gibbed)
	if(mutrace_result == MUTRACE_ONDEATH_REVIVED)
		return

	if (src.bioHolder && src.bioHolder.HasEffect("revenant"))
		var/datum/bioEffect/hidden/revenant/R = src.bioHolder.GetEffect("revenant")
		R.RevenantDeath()
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			CHANGELING BUSINESS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	var/datum/abilityHolder/changeling/C = get_ability_holder(/datum/abilityHolder/changeling)
	if (C)
		if (gibbed || C.points < 10)
			if (C.points < 10)
				boutput(src, "You try to release a headspider but don't have enough DNA points (requires 10)!")
			for (var/mob/living/critter/changeling/spider in C.hivemind)
				boutput(spider, SPAN_ALERT("Your telepathic link to your master has been destroyed!"))
				spider.hivemind_owner = 0
			for (var/mob/dead/target_observer/hivemind_observer/obs in C.hivemind)
				boutput(obs, SPAN_ALERT("Your telepathic link to your master has been destroyed!"))
				obs.mind?.remove_antagonist(ROLE_CHANGELING_HIVEMIND_MEMBER)
			if (length(C.hivemind) > 0)
				boutput(src, "Contact with the hivemind has been lost.")
			C.hivemind = list()
			if(C.master != C.temp_controller)
				C.return_control_to_master()

		else
		//Changelings' heads pop off and crawl away - but only if they're not gibbed and have some spare DNA points. Oy vey!
			var/datum/mind/mind = src.mind //let's not rely on the mind still being here after a SPAWN(0)
			SPAWN(0)
				emote("deathgasp")
				src.visible_message(SPAN_ALERT("<B>[src]</B> head starts to shift around!"))
				src.show_text("<b>We begin to grow a headspider...</b>", "blue")
				var/mob/living/critter/changeling/headspider/HS = new /mob/living/critter/changeling/headspider(src) //we spawn the headspider inside this dude immediately.
				HS.RegisterSignal(src, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove)) //if this dude gets grindered or cremated or whatever, we go with it
				mind?.transfer_to(HS) //ok we're a headspider now
				C.points = max(0, C.points - 10) // This stuff isn't free, you know.
				HS.changeling = C
				// alright everything to do with headspiders is a blasted hellscape but here's what goes on here
				// we don't want to actually give the headspider access to the changeling abilityholder, because that would let it use all the abilities
				// which leads to bugs and is generally bad. So we remove the HUD from corpsey over here, tell the abilityholder (C) that the headspider owns it,
				// but we do NOT tell the headspider it has access to the abilities.
				src.detach_hud(C.hud)
				C.owner = HS
				C.reassign_hivemind_target_mob()
				sleep(20 SECONDS)
				if(HS.disposed || !HS.mind || HS.mind.disposed || isdead(HS)) // we went somewhere else, or suicided, or something idk
					return
				HS.UnregisterSignal(src, COMSIG_PARENT_PRE_DISPOSING) // We no longer want to disappear if the body gets del'd
				boutput(HS, "<b class = 'hint'>We released a headspider, using up some of our DNA reserves.</b>")
				HS.set_loc(get_turf(src)) //be free!!!
				src.visible_message(SPAN_ALERT("<B>[src]</B>'s head detaches, sprouts legs and wanders off looking for food!"))
				//make a headspider, have it crawl to find a host, give the host the disease, hand control to the player again afterwards
				remove_ability_holder(/datum/abilityHolder/changeling/)

				if(src.client)
					src.ghostize()
					boutput(src, "Something went wrong, and we couldn't transfer you into a handspider! Please adminhelp this.")

				logTheThing(LOG_COMBAT, src, "became a headspider at [log_loc(src)].")

				if(src.wear_mask)
					var/obj/item/dropped_mask = src.wear_mask
					src.u_equip(dropped_mask)
					dropped_mask.set_loc(src.loc)
				if(src.glasses)
					var/obj/item/dropped_glasses = src.glasses
					src.u_equip(dropped_glasses)
					dropped_glasses.set_loc(src.loc)
				if(src.head)
					var/obj/item/dropped_headwear = src.head
					src.u_equip(dropped_headwear)
					dropped_headwear.set_loc(src.loc)
				if(src.ears)
					var/obj/item/dropped_earwear = src.ears
					src.u_equip(dropped_earwear)
					dropped_earwear.set_loc(src.loc)
				var/obj/item/organ/head/organ_head = src.organHolder.drop_organ("head")
				qdel(organ_head)
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			NORMAL BUSINESS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	if (!HAS_ATOM_PROPERTY(src, PROP_MOB_SUPPRESS_DEATH_SOUND))
		emote("deathgasp") //let the world KNOW WE ARE DEAD

	if (!inafterlife(src) && !istestdummy(src) && !isvirtual(src) && !src.hasStatus("in_afterlife") && current_state >= GAME_STATE_PLAYING) // prevent corpse spawners from reducing cheer; TODO: better fix
		modify_christmas_cheer(-7)


	if(src.traitHolder?.hasTrait("martyrdom") && (istype(src.equipped(), /obj/item/old_grenade) || istype(src.equipped(), /obj/item/chem_grenade)))
		src.equipped():AttackSelf(src)

	src.canmove = 0
	src.lying = 1
	src.last_sleep = 0
	src.ClearSpecificOverlays("sleep_bubble")
	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.set_clothing_icon_dirty()
	src.hand = h

	if (istype(src.wear_suit, /obj/item/clothing/suit/armor/suicide_bomb))
		var/obj/item/clothing/suit/armor/suicide_bomb/A = src.wear_suit
		INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/item/clothing/suit/armor/suicide_bomb, trigger), src)

	src.time_until_decomposition = rand(4 MINUTES, 10 MINUTES)
	add_lifeprocess(/datum/lifeprocess/decomposition)

	if (src.mind) // I think this is kinda important (Convair880).
		if (src.mind.ckey && !inafterlife(src))
			var/turf/where = get_turf(src)
			var/where_text = "Unknown (?, ?, ?)"
			if (where)
				where_text = "<b>[where.loc]</b> [showCoords(where.x, where.y, where.z, ghostjump=TRUE)]"

			message_ghosts("<b>[src.name]</b> has died in ([where_text]).")
#ifdef DATALOGGER
			game_stats.AddDeath(src.name, src.ckey, src.loc, log_health(src))
#endif
		src.mind.register_death()

	logTheThing(LOG_COMBAT, src, "dies [log_health(src)] at [log_loc(src)].")
	//src.icon_state = "dead"

	if (!src.suiciding)
		if (emergency_shuttle?.location == SHUTTLE_LOC_STATION)
			src.unlock_medal("HUMANOID MUST NOT ESCAPE", 1)

		if (src.hasStatus("handcuffed"))
			src.unlock_medal("Fell down the stairs", 1)

		if (src.mind?.get_antagonist(ROLE_REVOLUTIONARY))
			src.unlock_medal("Expendable", 1)

		if (src.getStatusDuration("burning") > 400)
			src.unlock_medal("Black and Blue", 1)
		JOB_XP(src, "Clown", 10)

		if (src.hasStatus("drunk"))
			if(locate(/obj/item/device/light/glowstick) in src.contents)
				src.unlock_medal("Party Hard", 1)
			for(var/turf/T in view(2, src.loc))
				if(locate(/obj/neon_lining) in T.contents)
					src.unlock_medal("Party Hard", 1)

	ticker?.mode?.check_win()

#ifdef RESTART_WHEN_ALL_DEAD
	var/cancel
	for (var/client/C)
		if (!C.mob) continue
		if (!C.mob.stat)
			cancel = 1
			break

	if (!cancel && !abandon_allowed)
		SPAWN(5 SECONDS)
			cancel = 0
			for (var/client/C)
				if (!C.mob) continue
				if (!C.mob.stat)
					cancel = 1
					break

			if (!cancel && !abandon_allowed)
				boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")

				SPAWN(30 SECONDS)
					logTheThing(LOG_DIARY, null, "Rebooting because of no live players", "game")
					Reboot_server()
#endif
	. = ..(gibbed)

	if(mutrace_result == MUTRACE_ONDEATH_DEFER_DELETE)
		qdel(src)

//Unkillable respawn proc, also used by soulguard now
// Also for removing antagonist status. New mob required to get rid of old-style, mob-specific antagonist verbs (Convair880).
/mob/living/carbon/human/proc/unkillable_respawn(var/antag_removal = 0)
	if (!antag_removal && src.bioHolder && src.bioHolder.HasEffect("revenant"))
		return

	var/turf/reappear_turf = get_turf(src)
	if (!antag_removal && !isrestrictedz(reappear_turf.z))
		for (var/turf/simulated/floor/S in orange(7))
			if (S == reappear_turf) continue
			if (prob(50)) //Try to appear on a turf other than the one we die on.
				reappear_turf = S
				break

	if (!antag_removal && src.spell_soulguard)
		boutput(src, SPAN_NOTICE("Your Soulguard enchantment activates and saves you..."))
		//soulguard ring puts you in the same spot
		if(src.spell_soulguard == SOULGUARD_RING)	//istype(src.gloves, /obj/item/clothing/gloves/ring/wizard/teleport)
			reappear_turf = get_turf(src)
		else
			reappear_turf = pick_landmark(LANDMARK_WIZARD)

	////////////////Set up the new body./////////////////

	var/mob/living/carbon/human/newbody = new()
	newbody.set_loc(reappear_turf)

	newbody.real_name = src.real_name
	newbody.faction = src.faction

	// These necessities (organs/limbs/inventory) are bad enough. I don't care about specific damage values etc.
	// Antag status removal doesn't happen very often (Convair880).
	if (antag_removal)
		transfer_mob_inventory(src, newbody, 1, 1, 1) // There's a spawn(20) in that proc.
		if (isdead(src))
			setdead(newbody)

	if (!antag_removal) // We don't want changeling etc ability holders (Convair880).
		newbody.abilityHolder = src.abilityHolder
		if (newbody.abilityHolder)
			newbody.abilityHolder.transferOwnership(newbody)
	src.abilityHolder = null

	if (!antag_removal && src.unkillable) // Doesn't work properly for half the antagonist types anyway (Convair880).
		newbody.unkillable = 1
		newbody.setStatus("maxhealth-", 30 SECONDS, -25)
		newbody.setStatus("unconscious", 10 SECONDS)
		newbody.bioHolder.AddEffect("hell_fire", do_stability = 0, magical = 1)

	if (src.bioHolder)
		newbody.bioHolder.CopyOther(src.bioHolder)
		if (!antag_removal && src.spell_soulguard)
			newbody.bioHolder.RemoveAllEffects()

	if(src.traitHolder)
		newbody.traitHolder = src.traitHolder
		newbody.traitHolder.owner = newbody
		if (src.spell_soulguard)
			newbody.equip_sensory_items()

	// Prone to causing runtimes, don't enable.
/*	if (src.mutantrace && !src.spell_soulguard)
		newbody.mutantrace = new src.mutantrace.type(newbody)*/

	if (src.mind) //Mind transfer also handles key transfer.
		if (antag_removal)
			// Ugly but necessary until I can figure out a better to do this or every antagonist has been moved to ability holders.
			// Transfering it directly to the new mob DOESN'T dispose of certain antagonist-specific verbs (Convair880).
			var/mob/dead/observer/O_temp = new/mob/dead/observer(src)
			src.mind.transfer_to(O_temp)
			O_temp.mind.transfer_to(newbody)
			qdel(O_temp)
		else
			src.mind.transfer_to(newbody)
	else //Oh welp, still need to move that key!
		newbody.key = src.key

	////////////Now play the degibbing animation and move them to the turf.////////////////

	if (!antag_removal)
		var/atom/movable/overlay/animation = new(reappear_turf)
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		animation.icon_state = "ungibbed"
		src.unkillable = 0 //Don't want this lying around to repeatedly die or whatever.
		if (src.spell_soulguard)
			newbody.RegisterSignal(newbody, COMSIG_MOB_PICKUP, /mob/proc/emp_touchy)
			newbody.RegisterSignal(newbody, COMSIG_LIVING_LIFE_TICK, /mob/proc/emp_slots)
		src.spell_soulguard = SOULGUARD_INACTIVE // clear this as well
		src = null //Detach this, what if we get deleted before the animation ends??
		SPAWN(0.7 SECONDS) //Length of animation.
			newbody.set_loc(animation.loc)
			qdel(animation)
	else
		src.unkillable = 0
		src.spell_soulguard = SOULGUARD_INACTIVE
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
		SPAWN(2.2 SECONDS) // Has to at least match the organ/limb replacement stuff (Convair880).
			if (src) qdel(src)

	return


/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		stat(null, " ")

		/*
		//For some reason, this code was causing severe lag. Feel free to uncomment it if you want to figure out why - Emily

		if (src.internal)
			if (!src.internal.air_contents)
				qdel(src.internal)
			else
				stat("Internal Atmosphere Info:", src.internal.name)
				stat("Tank Pressure:", MIXTURE_PRESSURE(src.internal.air_contents))
				stat("Distribution Pressure:", src.internal.distribute_pressure)
		*/
/mob/living/carbon/human/set_a_intent(intent)
	. = ..()
	src.hud?.update_intent()

/mob/living/carbon/human/hotkey(name)
	switch (name)
		if ("help")
			src.set_a_intent(INTENT_HELP)
		if ("disarm")
			src.set_a_intent(INTENT_DISARM)
		if ("grab")
			src.set_a_intent(INTENT_GRAB)
		if ("harm")
			src.set_a_intent(INTENT_HARM)
		if ("drop")
			src.drop_item(null, TRUE)
		if ("swaphand")
			src.swap_hand()
		if ("attackself")
			var/obj/item/W = src.equipped()
			if (W)
				src.click(W, list())
		if ("equip")
			src.hud.relay_click("invtoggle", src, list()) // this is incredibly dumb, it's also just as dumb as what was here previously
		if ("togglethrow")
			src.toggle_throw_mode()
		if ("walk")
			if (src.m_intent == "run")
				src.m_intent = "walk"
			else
				src.m_intent = "run"
			boutput(src, "You are now [src.m_intent == "walk" ? "walking" : "running"].")
			hud.update_mintent()
		if ("rest")
			if(ON_COOLDOWN(src, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
			if(src.ai_active && !src.hasStatus("resting"))
				src.show_text("You feel too restless to do that!", "red")
			else
				src.hasStatus("resting") ? src.delStatus("resting") : src.setStatus("resting", INFINITE_STATUS)
				src.force_laydown_standup()
			hud.update_resting()
		if ("head")
			src.zone_sel.select_zone("head")
		if ("chest")
			src.zone_sel.select_zone("chest")
		if ("l_arm")
			src.zone_sel.select_zone("l_arm")
		if ("r_arm")
			src.zone_sel.select_zone("r_arm")
		if ("l_leg")
			src.zone_sel.select_zone("l_leg")
		if ("r_leg")
			src.zone_sel.select_zone("r_leg")
		else
			return ..()

/mob/living/carbon/human/build_keybind_styles(client/C)
	..()
	C.apply_keybind("human")

	if (!C.preferences.use_wasd)
		C.apply_keybind("human_arrow")

	if (C.preferences.use_azerty)
		C.apply_keybind("human_azerty")
	if (C.tg_controls)
		C.apply_keybind("human_tg")
		if (C.preferences.use_azerty)
			C.apply_keybind("human_tg_azerty")

/mob/living/carbon/human/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/human/proc/throw_mode_off()
	src.in_throw_mode = 0
	src.update_cursor()
	hud?.update_throwing()

/mob/living/carbon/human/proc/throw_mode_on()
	src.in_throw_mode = 1
	src.update_cursor()
	hud?.update_throwing()

/mob/living/carbon/human/throw_item(atom/target, list/params)
	..()
	var/turf/thrown_from = get_turf(src)
	src.throw_mode_off()
	if (HAS_ATOM_PROPERTY(src, PROP_MOB_CANTTHROW))
		return
	if (src.stat)
		return

	var/obj/item/I = src.equipped()

	if (!I || !isitem(I) || I.cant_drop)
		return

	var/obj/item/grab/grab = null
	if (istype(I, /obj/item/grab))
		grab = I
	else if (I.chokehold)
		grab = I.chokehold
	if (grab)
		I = grab.handle_throw(src, target)
		if (!I)
			return

	I.set_loc(src.loc)

	u_equip(I)

	if (GET_DIST(src, target) > 0)
		src.set_dir(get_dir(src, target))

	//actually throw it!
	if (I)
		attack_twitch(src)
		I.layer = initial(I.layer)
		var/yeet = 0 // what the fuck am I doing
		var/yeet_change_mod = yeet_chance
		var/throw_dir = get_dir(src, target)
		if(src.mind)
			if(src.mind.karma >= 50) //karma karma karma karma karma khamelion
				yeet_change_mod *= 1
			if(src.mind.karma < 0) //you come and go, you come and go.
				yeet_change_mod *= 0
			if(src.mind.karma < 50 && src.mind.karma >= 0)
				yeet_change_mod *= 0.1

		if(prob(yeet_change_mod))
			src.visible_message(SPAN_ALERT("[src] yeets [I]."))
			src.say("YEET")
			yeet = 1 // I hate this
		else
			src.visible_message(SPAN_ALERT("[src] throws [I]."))
		if (iscarbon(I))
			var/mob/living/carbon/C = I
			logTheThing(LOG_COMBAT, src, "throws [constructTarget(C,"combat")] [dir2text(throw_dir)] at [log_loc(src)].")
		else
			// Added log_reagents() call for drinking glasses. Also the location (Convair880).
			logTheThing(LOG_COMBAT, src, "throws [I] [I.is_open_container() ? "[log_reagents(I)]" : ""] [dir2text(throw_dir)] at [log_loc(src)].")
		if (istype(src.loc, /turf/space) || src.no_gravity) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src) // Float opposite direction from throw
			step(src, inertia_dir)
		if ((istype(I.loc, /turf/space) || I.no_gravity)  && ismob(I))
			var/mob/M = I
			M.inertia_dir = throw_dir

		playsound(src.loc, 'sound/effects/throw.ogg', 40, 1, 0.1)

		adjust_throw(I.throw_at(target, I.throw_range, I.throw_speed, params, thrown_from, src))
		if(yeet)
			new/obj/effect/supplyexplosion(I.loc)

			playsound(I.loc, 'sound/effects/ExplosionFirey.ogg', 100, 1)

			for(var/mob/M in view(7, I.loc))
				shake_camera(M, 20, 8)

		SEND_SIGNAL(src, COMSIG_MOB_TRIGGER_THREAT)

		src.next_click = world.time + src.combat_click_delay

/mob/living/carbon/human/click(atom/target, list/params)
	if (src.client)
		if (src.client.experimental_intents)
			if (src.client.check_key(KEY_THROW))
				if (params["right"])
					if (src.equipped())
						src.throw_item(target, params)
					else
						params["left"] = 1 //hacky :)
						src.set_a_intent(INTENT_DISARM)
						.=..()
						src.set_a_intent(INTENT_DISARM)
				else
					src.set_a_intent(INTENT_HARM)
					.=..()
					src.set_a_intent(INTENT_DISARM)
				return
			if (src.client.check_key(KEY_PULL))
				if (params["left"] && ismob(target))
					params["ctrl"] = 0 //hacky wows :)
					var/prev = src.a_intent
					src.set_a_intent(INTENT_GRAB)
					.=..()
					src.set_a_intent(prev)
					return
				else
					src.set_a_intent(INTENT_HARM)
					.=..()
					src.set_a_intent(INTENT_DISARM)
				return
		else
			if (src.client.check_key(KEY_THROW) && src.equipped() && src.a_intent == "help" && isliving(target) && BOUNDS_DIST(src, target) <= 0)
				var/obj/item/thing = src.equipped() || src.l_hand || src.r_hand
				if (thing)
					usr = src
					var/mob/living/living_target = target
					living_target.give_item()
					return
			else if (src.client.check_key(KEY_THROW) && !src.equipped() && BOUNDS_DIST(src, target) <= 0)
				if (src.auto_pickup_item(target))
					return
			else if (src.client.check_key(KEY_THROW) || src.in_throw_mode)
				SEND_SIGNAL(src, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
				src.throw_item(target, params)
				return

	return ..()

/mob/living/carbon/human/update_cursor()
	if (src.client)
		if (src.client.experimental_intents)
			if (src.client.check_key(KEY_THROW))
				if (src.equipped())
					src.set_cursor('icons/cursors/combat.dmi')
				else
					src.set_cursor('icons/cursors/combat_barehand.dmi')
				src.client.show_popup_menus = 0
				src.set_a_intent(INTENT_DISARM)
				return
			else if (src.client.check_key(KEY_PULL))
				src.set_cursor('icons/cursors/combat_grab.dmi')
				src.client.show_popup_menus = 0
				src.set_a_intent(INTENT_GRAB)
				return
			else if (src.client.show_popup_menus == 0)
				src.client.show_popup_menus = 1
				src.set_a_intent(INTENT_HELP)
		else
			if (src.client.check_key(KEY_THROW) || src.in_throw_mode)
				src.set_cursor('icons/cursors/throw.dmi')
				return

	return ..()

/mob/living/carbon/human/meteorhit(O as obj)
	if (isdead(src)) src.gib()
	src.visible_message(SPAN_ALERT("[src] has been hit by [O]!"))
	if (src.nodamage) return
	if (src.health > 0)
		var/dam_zone = pick("chest", "head")
		var/reduction = 0
		if (src.spellshield)
			reduction = 30
			boutput(src, SPAN_ALERT("<b>Your Spell Shield absorbs some damage!</b>"))

		src.TakeDamage(dam_zone, (istype(O, /obj/newmeteor/small) ? max(15-reduction,0) : max(25-reduction,0)), max(20-reduction,0), 0, DAMAGE_CRUSH)
		src.UpdateDamageIcon()
	else if (prob(20))
		src.gib()

	return

/mob/living/carbon/human/deliver_move_trigger(ev)
	for (var/obj/O in contents)
		if (O.move_triggered)
			O.move_trigger(src, ev)
	reagents?.move_trigger(src, ev)
	for (var/datum/statusEffect/S as anything in statusEffects)
		if (S?.move_triggered)
			S.move_trigger(src, ev)


/mob/living/carbon/human/proc/face_visible()
	. = TRUE
	if (istype(src.wear_mask) && !src.wear_mask.see_face)
		return FALSE
	else if (istype(src.head) && !src.head.see_face)
		return FALSE
	else if (istype(src.wear_suit) && !src.wear_suit.see_face)
		return FALSE
	else if (istype(src.back, /obj/item/clothing))
		var/obj/item/clothing/hider = src.back
		if (!hider.see_face)
			return FALSE
	for (var/obj/item/hand in list(src.l_hand, src.r_hand))
		if (istype(hand, /obj/item/paper/newspaper))
			if (hand.two_handed)
				return FALSE



/mob/living/carbon/human/UpdateName()
	var/id_name = get_id_card(src.wear_id)?:registered
	if (!face_visible())
		if (id_name)
			src.name = "[src.name_prefix(null, 1)][id_name][src.name_suffix(null, 1)]"
			src.update_name_tag(id_name)
		else
			src.unlock_medal("Suspicious Character", 1)
			src.name = "[src.name_prefix(null, 1)]Unknown[src.name_suffix(null, 1)]"
			src.update_name_tag("")
	else
		if (id_name != src.real_name)
			if (src.decomp_stage > DECOMP_STAGE_DECAYED || src.disfigured)
				src.name = "[src.name_prefix(null, 1)]Unknown[id_name ? " (as [id_name])" : ""][src.name_suffix(null, 1)]"
				src.update_name_tag(id_name)
			else
				src.name = "[src.name_prefix(null, 1)][src.real_name][id_name ? " (as [id_name])" : ""][src.name_suffix(null, 1)]"
				src.update_name_tag(src.real_name)
		else
			if (src.decomp_stage > DECOMP_STAGE_DECAYED || src.disfigured)
				src.name = "[src.name_prefix(null, 1)]Unknown[src.wear_id ? " (as [id_name])" : ""][src.name_suffix(null, 1)]"
				src.update_name_tag(id_name)
			else
				src.name = "[src.name_prefix(null, 1)][src.real_name][src.name_suffix(null, 1)]"
				src.update_name_tag(src.real_name)

	src.update_arrest_icon()


/mob/living/carbon/human/admin_visible_name()
	return src.real_name

/mob/living/carbon/human/find_in_equipment(var/eqtype)
	if (istype(w_uniform, eqtype))
		return w_uniform
	if (istype(wear_id, eqtype))
		return wear_id
	if (istype(gloves, eqtype))
		return gloves
	if (istype(shoes, eqtype))
		return shoes
	if (istype(wear_suit, eqtype))
		return wear_suit
	if (istype(back, eqtype))
		return back
	if (istype(glasses, eqtype))
		return glasses
	if (istype(ears, eqtype))
		return ears
	if (istype(wear_mask, eqtype))
		return wear_mask
	if (istype(head, eqtype))
		return head
	if (istype(belt, eqtype))
		return belt
	if (istype(l_store, eqtype))
		return l_store
	if (istype(r_store, eqtype))
		return r_store
	return null

/mob/living/carbon/human/get_slot_from_item(var/obj/item/I)
	//wanted the following to be a switch case but those expect constant expressions

	if (src.w_uniform == I)
		return SLOT_W_UNIFORM
	if (src.wear_id == I)
		return SLOT_WEAR_ID
	if (src.gloves == I)
		return SLOT_GLOVES
	if (src.shoes == I)
		return SLOT_SHOES
	if (src.wear_suit == I)
		return SLOT_WEAR_SUIT
	if (src.back == I)
		return SLOT_BACK
	if (src.glasses == I)
		return SLOT_GLASSES
	if (src.ears == I)
		return ears
	if (src.wear_mask == I)
		return SLOT_WEAR_MASK
	if (src.head == I)
		return SLOT_HEAD
	if (src.belt == I)
		return SLOT_BELT
	if (src.l_store == I)
		return SLOT_L_STORE
	if (src.r_store == I)
		return SLOT_R_STORE
	if(src.l_hand == I)
		return SLOT_L_HAND
	if(src.r_hand == I)
		return SLOT_R_HAND
	return null

/mob/living/carbon/human/is_in_hands(var/obj/O)
	if (l_hand == O || r_hand == O)
		return 1
	return 0

/mob/living/carbon/human/restrained()
	if (src.hasStatus("handcuffed"))
		return 1
	if (src.hasStatus("incorporeal"))
		return 1
	if (src.wear_suit && src.wear_suit.restrain_wearer)
		return 1
	if (src.limbs && (src.hand ? !src.limbs.l_arm : !src.limbs.r_arm))
		return 1

	/*if (src.limbs && (src.hand ? !src.limbs.l_arm:can_hold_items : !src.limbs.r_arm:can_hold_items)) // this was fucking stupid and broke item limbs, I mean really, how do you restrain someone whos arm is a goddamn CHAINSAW
		return 1*/

/mob/living/carbon/human/set_pulling(atom/movable/A)
	. = ..()
	hud.update_pulling()

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/mouse_drop(mob/M as mob)
	..()
	if (M != usr) return
	if (usr == src) return
	if (BOUNDS_DIST(usr, src) > 0) return
	if (!M.can_strip(src)) return
	if (LinkBlocked(usr.loc,src.loc)) return
	if (isAI(usr) || isAI(src)) return
	if (isghostcritter(usr) && !isdead(src)) return
	if(!isliving(usr)) return
	src.show_inv(usr)

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/Crossed(atom/movable/AM)
	..()
	var/obj/machinery/bot/mulebot/MB = AM
	if (istype(MB))
		MB.RunOver(src)

/* ----------------------------------------------------------------------------------------------------------------- */

/mob/living/carbon/human/Login()
	..()

	update_clothing()

	if (ai_active)
		ai_set_active(0)
	if (src.organHolder && src.organHolder.brain && src.mind)
		src.organHolder.brain.setOwner(src.mind)

/mob/living/carbon/human/Logout()
	..()
	if (!ai_active && is_npc)
		ai_set_active(1)

/mob/living/carbon/human/get_heard_name(just_name_itself=FALSE)
	var/alt_name = ""
	if (src.name != src.real_name)
		if (src.wear_id && src.wear_id:registered && src.wear_id:registered != src.real_name)
			alt_name = " (as [src.wear_id:registered])"
		else if (!src.wear_id)
			alt_name = " (as Unknown)"

	if (src.is_npc)
		. = "<span class='name'>"
	else
		. = "<span class='name' data-ctx='\ref[src.mind]'>"
	if (src.wear_mask?.vchange)//(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		if (src.wear_id && length(src.wear_id:registered))
			if (just_name_itself)
				return src.wear_id:registered
			. += "[src.wear_id:registered]</span>"
		else
			if (just_name_itself)
				return "Unknown"
			. += "Unknown</span>"
	else if (src.vdisfigured)
		if (just_name_itself)
			return "Unknown"
		. += "Unknown</span>"
	else
		if (just_name_itself)
			return src.real_name
		. += "[src.real_name]</span>[alt_name]"

/mob/living/carbon/human/say(var/message, var/ignore_stamina_winded = FALSE, var/unique_maptext_style, var/maptext_animation_colors)
	var/original_language = src.say_language
	if (mutantrace?.override_language)
		say_language = mutantrace.override_language

	if (istype(src.wear_mask, /obj/item/clothing/mask/monkey_translator))
		var/obj/item/clothing/mask/monkey_translator/mask = src.wear_mask
		say_language = mask.new_language

	message = copytext(message, 1, MAX_MESSAGE_LEN)

	if (src.fakedead)
		var/the_verb = pick("wails","moans","laments")
		boutput(src, SPAN_DEADSAY("[SPAN_PREFIX("DEAD:")] [src.get_heard_name()] [the_verb], [SPAN_MESSAGE("\"[message]\"")]"))
		src.say_language = original_language
		return

	if (dd_hasprefix(message, "*") || isdead(src))
		..(message)
		src.say_language = original_language
		return

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message(SPAN_ALERT("[src] makes some [pick("eldritch", "eerie", "otherworldly", "netherly", "spooky", "demonic", "haunting")] noises!"))
		src.say_language = original_language
		return

	if (src.bioHolder.HasEffect("food_bad_breath"))
		for (var/mob/living/L in oview(2,src))
			if (prob(20))
				boutput(L, SPAN_ALERT("Good lord, [src]'s breath smells bad!"))
				L.vomit()


	if (src.stamina < STAMINA_WINDED_SPEAK_MIN && !ignore_stamina_winded)
		//src.emote(pick("gasp", "choke", "cough"))
		//boutput(src, SPAN_ALERT("You are too exhausted to speak."))
		whisper(message, forced=TRUE)
		src.say_language = original_language
		return

	if (src.robot_talk_understand && !src.stat)
		if (length(message) >= 2)
			if (copytext(lowertext(message), 1, 3) == ":s")
				message = copytext(message, 3)
				src.robot_talk(message)
				src.say_language = original_language
				return

	message = process_accents(src,message)

	..(message, unique_maptext_style = unique_maptext_style, maptext_animation_colors = maptext_animation_colors)

	src.say_language = original_language

/*/mob/living/carbon/human/say_understands(var/other)
	if (src.mutantrace)
		return src.mutantrace.say_understands(other)
	if (isAI(other))
		return 1
	if (isrobot(other))
		return 1
	if (ishivebot(other))
		return 1
	if (ismainframe(other))
		return 1
	if (ishuman(other) && (!other:mutantrace || !other:mutantrace.exclusive_language))
		return 1*/

/mob/living/carbon/human/say_quote(var/text)
	if (src.mutantrace.voice_message)
		src.voice_name = src.mutantrace.voice_name
		src.voice_message = src.mutantrace.voice_message
	var/sayverb = src.mutantrace.say_verb()
	var/special = 0
	if (src.stamina < STAMINA_WINDED_SPEAK_MIN)
		special = "gasp_whisper"
	if (src.oxyloss > 10 && !HAS_ATOM_PROPERTY(src, PROP_MOB_REBREATHING))
		special = "gasp_whisper"

	return ..(text, special, sayverb)

//Lallander was here
/mob/living/carbon/human/whisper(message as text, forced=FALSE)
	if (src.bioHolder.HasEffect("revenant"))
		return src.say(message)
	var/message_mode = null
	var/secure_headset_mode = null
	if (src.get_brain_damage() >= 60 && prob(50))
		message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		message_mode = "headset"
		message = copytext(message, 2)

	if (src.stamina < STAMINA_WINDED_SPEAK_MIN || src.oxyloss > 10)
		message = lowertext(message)

	else if ((length(message) >= 2) && (copytext(message,1,2) == ":"))
		switch (lowertext( copytext(message,2,4) ))
			if ("rh")
				message_mode = "right hand"
				message = copytext(message, 4)

			if ("lh")
				message_mode = "left hand"
				message = copytext(message, 4)

			if ("in")
				message_mode = "intercom"
				message = copytext(message, 4)

			else
				if (ishuman(src))
					message_mode = "secure headset"
					secure_headset_mode = lowertext(copytext(message,2,3))
				message = copytext(message, 3)

	message = strip_html(trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if (!message)
		return

	logTheThing(LOG_DIARY, src, "(WHISPER): [message]", "whisper")
	logTheThing(LOG_WHISPER, src, "SAY: [message] (WHISPER) [log_loc(src)]")

	if (src.client && !src.client.holder && url_regex?.Find(message))
		boutput(src, SPAN_NOTICE("<b>Web/BYOND links are not allowed in ingame chat.</b>"))
		boutput(src, SPAN_ALERT("&emsp;<b>\"[message]</b>\""))
		return

	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	if (isdead(src))
		return src.say_dead(message)

	if (src.stat)
		return

	var/alt_name = ""
	if (ishuman(src) && src.name != src.real_name)
		if (src:wear_id && src:wear_id:registered && src:wear_id:registered != src.real_name)
			alt_name = " (as [src:wear_id:registered])"
		else if (!src:wear_id)
			alt_name = " (as Unknown)"

	// Mute disability
	if (src.bioHolder.HasEffect("mute"))
		boutput(src, SPAN_ALERT("You seem to be unable to speak."))
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		boutput(src, SPAN_ALERT("Your muzzle prevents you from speaking."))
		return

	var/italics = 1
	var/message_range = 1
	var/forced_language = null
	forced_language = get_special_language(secure_headset_mode)

	message = process_accents(src,message)

	if (src.stuttering)
		message = stutter(message)

	var/list/messages = process_language(message, forced_language)
	var/lang_id = get_language_id(forced_language)

	switch (message_mode)
		//MBC : now that you can whisper while dying or suffocating, let's not allow you to whisper into a radio.
		/*
		if ("headset", "secure headset", "right hand", "left hand")
			talk_into_equipment(message_mode, messages, secure_headset_mode, lang_id)
			message_range = 0
			italics = 1
		*/
		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, messages, null, src.real_name, lang_id)

			message_range = 0
			italics = 1

	var/list/eavesdropping = hearers(2, src)
	eavesdropping -= src
	var/list/watching  = viewers(5, src)
	watching -= src
	watching -= eavesdropping

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	var/rendered = null

	if (message_range)
		var/heardname = src.real_name
		src.send_hear_talks(message_range, messages, heardname, lang_id)

		var/list/listening = all_hearers(message_range, src)
		eavesdropping -= listening

		for (var/mob/M in listening)
			if (M.say_understands(src))
				heard_a += M
			else
				heard_b += M

	for (var/mob/M in watching)
		if (M.say_understands(src))
			rendered = SPAN_SAY("[SPAN_NAME("[src.name]")] whispers something.")
		else
			rendered = SPAN_SAY("[SPAN_NAME("[src.voice_name]")] whispers something.")
		M.show_message(rendered, 2)

	var/list/olocs = list()
	var/thickness = 0
	if (!isturf(loc))
		olocs = obj_loc_chain(src)
		for (var/atom/movable/AM in olocs)
			thickness += AM.soundproofing
	var/list/processed = list()

	if (length(heard_a))
		processed = saylist(messages[1], heard_a, olocs, thickness, italics, processed)

	if (length(heard_b))
		processed = saylist(messages[2], heard_b, olocs, thickness, italics, processed, 1)

	message = messages[1]
	if(src.client)
		phrase_log.log_phrase(forced ? "say" : "whisper", message)
	last_words = message
	for (var/mob/M in eavesdropping)
		if (M.say_understands(src, lang_id))
			var/message_c = stars(message)

			if (!ishuman(src))
				rendered = SPAN_SAY("[SPAN_NAME("[src.name]")] whispers, [SPAN_MESSAGE("\"[message_c]\"")]")
			else
				if (src.wear_mask && src.wear_mask.vchange)//(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
					if (src.wear_id && src.wear_id:registered)
						rendered = SPAN_SAY("[SPAN_NAME("[src.wear_id:registered]")] whispers, [SPAN_MESSAGE("\"[message_c]\"")]")
					else
						rendered = SPAN_SAY("[SPAN_NAME("Unknown")] whispers, [SPAN_MESSAGE("\"[message_c]\"")]")
				else
					rendered = SPAN_SAY("[SPAN_NAME("[src.real_name]")][alt_name] whispers, [SPAN_MESSAGE("\"[message_c]\"")]")

		else
			rendered = SPAN_SAY("[SPAN_NAME("[src.voice_name]")] whispers something.")

		M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"

	if (!ishuman(src))
		rendered = SPAN_SAY("[SPAN_NAME("[src.name]")] whispers, [SPAN_MESSAGE("[message]")]")
	else
		if (src.wear_mask && src.wear_mask.vchange)//(istype(src:wear_mask, /obj/item/clothing/mask/gas/voice))
			if (src.wear_id && length(src.wear_id:registered))
				rendered = SPAN_SAY("[SPAN_NAME("[src.wear_id:registered]")] whispers, [SPAN_MESSAGE("[message]")]")
			else
				rendered = SPAN_SAY("[SPAN_NAME("Unknown")] whispers, [SPAN_MESSAGE("[message]")]")
		else
			rendered = SPAN_SAY("[SPAN_NAME("[src.real_name]")][alt_name] whispers, [SPAN_MESSAGE("[message]")]")

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue
		if (isdead(M) && !(M in heard_a) && !istype(M, /mob/dead/target_observer) && !(M?.client?.preferences?.local_deadchat))
			M.show_message(rendered, 2)

	speech_bubble.icon_state = "speech"
	show_speech_bubble(speech_bubble)

/mob/living/carbon/human/u_equip(obj/item/W)
	if (!W)
		return

	hud?.remove_item(W) // eh

	if (isitem(W))
		if (W.two_handed) //This runtime is caused by grabbing a human.
			hud.set_visible(hud.lhand, 1)
			hud.set_visible(hud.rhand, 1)
			hud.set_visible(hud.twohandl, 0)
			hud.set_visible(hud.twohandr, 0)

	if (W == src.wear_suit)
		src.update_hair_layer()
		src.wear_suit = null
		W.unequipped(src)
		src.update_clothing()
	else if (W == src.w_uniform)
		W.unequipped(src)
		W = src.r_store
		if (W)
			u_equip(W)
			if (W)
				W.set_loc(src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.l_store
		if (W)
			u_equip(W)
			if (W)
				W.set_loc(src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.wear_id
		if (W)
			u_equip(W)
			if (W)
				W.set_loc(src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.belt
		if (W)
			u_equip(W)
			if (W)
				W.set_loc(src.loc)
				W.dropped(src)
				W.layer = initial(W.layer)
		src.w_uniform = null
		src.update_clothing()
	else if (W == src.gloves)
		W.unequipped(src)
		src.gloves = null
		src.update_clothing()
	else if (W == src.glasses)
		W.unequipped(src)
		src.glasses = null
		src.update_clothing()
	else if (W == src.head)
		W.unequipped(src)
		src.head = null
		src.update_hair_layer()
		src.update_clothing()
	else if (W == src.ears)
		W.unequipped(src)
		src.ears = null
		src.update_clothing()
	else if (W == src.shoes)
		W.unequipped(src)
		src.shoes = null
		src.update_clothing()
		var/turf/T = get_turf(src)
		if(T?.active_liquid)
			T.active_liquid.Crossed(src)
	else if (W == src.belt)
		W.unequipped(src)
		src.belt = null
		src.update_clothing()
	else if (W == src.wear_mask)
		W.unequipped(src)
		if (internal)
			if (src.internals)
				src.internals.icon_state = "internal0"
			for (var/obj/ability_button/tank_valve_toggle/T in internal.ability_buttons)
				T.icon_state = "airoff"
			internal = null
		src.wear_mask = null
		src.update_clothing()
	else if (W == src.wear_id)
		W.unequipped(src)
		src.wear_id = null
		src.update_clothing()
	else if (W == src.r_store)
		src.r_store = null
	else if (W == src.l_store)
		src.l_store = null
	else if (W == src.back)
		W.unequipped(src)
		src.back = null
		src.update_clothing()
	else if (W == src.handcuffs)
		src.handcuffs = null
		src.delStatus("handcuffed")
		src.update_clothing()

	if (W && W == src.r_hand)
		W.dropped(src)
		src.r_hand = null
		src.update_inhands()
	if (W && W == src.l_hand)
		W.dropped(src)
		src.l_hand = null
		src.update_inhands()


/mob/living/carbon/human/updateTwoHanded(var/obj/item/I, var/twoHanded = 1)
	if(!(I in src) || (src.l_hand != I && src.r_hand != I)) return FALSE
	if (!(src.has_hand(1) && src.has_hand(0))) return FALSE //gotta have two hands to two-hand
	I.two_handed = twoHanded

	if(I.two_handed)
		if(src.l_hand == I)
			if((src.r_hand != null) && (src.r_hand != I))
				I.two_handed = 0
				return FALSE
		else if(src.r_hand == I)
			if((src.l_hand != null) && (src.l_hand != I))
				I.two_handed = 0
				return FALSE
		hud.set_visible(hud.lhand, 0)
		hud.set_visible(hud.rhand, 0)
		hud.set_visible(hud.twohandl, 1)
		hud.set_visible(hud.twohandr, 1)
		hud.remove_item(I)
		hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["twohand"])

		src.l_hand = I
		src.r_hand = I
	else //Object is 1-hand, remove ui elements, set item to proper location.
		hud.set_visible(hud.lhand, 1)
		hud.set_visible(hud.rhand, 1)
		hud.set_visible(hud.twohandl, 0)
		hud.set_visible(hud.twohandr, 0)
		hud.remove_item(I)
		hud.add_object(I, HUD_LAYER+2, (src.hand ? hud.layouts[hud.layout_style]["lhand"] : hud.layouts[hud.layout_style]["rhand"]))
		switch(src.hand)
			if(1)//Left
				src.l_hand = I
				src.r_hand = null
			if(0)//Right
				src.l_hand = null
				src.r_hand = I
	src.update_inhands()
	return TRUE

/mob/living/carbon/human/has_any_hands()
	return src.has_hand(1) || src.has_hand(0)

/mob/living/carbon/human/proc/has_hand(var/hand = 1)
	switch(hand)
		if (1)//Left
			if (src.limbs && src.limbs.l_arm && !istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item))
				return TRUE
			if (istype(src.l_hand, /obj/item/magtractor))
				return TRUE
		if (0)//Right
			if (src.limbs && src.limbs.r_arm && !istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item))
				return TRUE
			if (istype(src.r_hand, /obj/item/magtractor))
				return TRUE
	return FALSE

/mob/living/carbon/human/can_hold_two_handed()
	. = ..()
	if (src.r_hand || src.l_hand)
		return FALSE
	if (src.limbs && (!src.limbs.r_arm || istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
		return FALSE
	if (src.limbs && (!src.limbs.l_arm || istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)))
		return FALSE
	return TRUE

/mob/living/carbon/human/put_in_hand(obj/item/I, hand)
	if (!istype(I))
		return 0
	if (src.equipped() && istype(src.equipped(), /obj/item/magtractor))
		var/obj/item/magtractor/M = src.equipped()
		if (M.pickupItem(I, src))
			actions.start(new/datum/action/magPickerHold(M), src)
			return 1
		return 0
	if (I.two_handed) //MARKER1
		if (!src.can_hold_two_handed())
			return FALSE
		src.l_hand = I
		src.r_hand = I
		I.pickup(src)
		if(QDELETED(I))
			return 0
		I.add_fingerprint(src)
		I.set_loc(src)
		src.update_inhands()
		if (hud)
			hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["twohand"])
			hud.set_visible(hud.lhand, 0)
			hud.set_visible(hud.rhand, 0)
			hud.set_visible(hud.twohandl, 1)
			hud.set_visible(hud.twohandr, 1)

		return 1
	else
		if (isnull(hand))
			if (src.put_in_hand(I, src.hand))
				return 1
			if (src.put_in_hand(I, !src.hand))
				return 1
			return 0
		else
			if (hand)
				if (!src.l_hand)
					if (I == src.r_hand && I.cant_self_remove)
						return 0
					if (src.limbs && (!src.limbs.l_arm || istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)))
						return 0
					src.l_hand = I
					I.pickup(src)
					if(QDELETED(I))
						return 0
					I.add_fingerprint(src)
					I.set_loc(src)
					src.update_inhands()
					hud?.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["lhand"])
					return 1
				else
					return 0
			else
				if (!src.r_hand)
					if (I == src.l_hand && I.cant_self_remove)
						return 0
					if (src.limbs && (!src.limbs.r_arm || istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
						return 0
					src.r_hand = I
					I.pickup(src)
					I.add_fingerprint(src)
					I.set_loc(src)
					src.update_inhands()
					hud?.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["rhand"])
					return 1
				else
					return 0

/mob/living/carbon/human/proc/get_slot(slot)
	switch(slot)
		if (SLOT_BACK)
			return src.back
		if (SLOT_WEAR_MASK)
			return src.wear_mask
		if (SLOT_L_HAND)
			return src.l_hand
		if (SLOT_R_HAND)
			return src.r_hand
		if (SLOT_BELT)
			return src.belt
		if (SLOT_WEAR_ID)
			return src.wear_id
		if (SLOT_EARS)
			return src.ears
		if (SLOT_GLASSES)
			return src.glasses
		if (SLOT_GLOVES)
			return src.gloves
		if (SLOT_HEAD)
			return src.head
		if (SLOT_SHOES)
			return src.shoes
		if (SLOT_WEAR_SUIT)
			return src.wear_suit
		if (SLOT_W_UNIFORM)
			return src.w_uniform
		if (SLOT_L_STORE)
			return src.l_store
		if (SLOT_R_STORE)
			return src.r_store

/mob/living/carbon/human/proc/force_equip(obj/item/I, slot, role_equipped = FALSE)
	//warning: icky code
	var/equipped = 0
	switch(slot)
		if (SLOT_BACK)
			if (!src.back)
				src.back = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["back"])
				I.equipped(src, SLOT_BACK)
				equipped = 1
				clothing_dirty |= C_BACK
		if (SLOT_WEAR_MASK)
			if (!src.wear_mask && src.organHolder && src.organHolder.head)
				src.wear_mask = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["mask"])
				I.equipped(src, SLOT_WEAR_MASK)
				equipped = 1
				clothing_dirty |= C_MASK
		if (SLOT_L_HAND)
			equipped = src.put_in_hand(I, 1)
			clothing_dirty |= C_LHAND
		if (SLOT_R_HAND)
			equipped = src.put_in_hand(I, 0)
			clothing_dirty |= C_RHAND
		if (SLOT_BELT)
			if (!src.belt)
				src.belt = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["belt"])
				I.equipped(src, SLOT_BELT)
				equipped = 1
				clothing_dirty |= C_BELT
		if (SLOT_WEAR_ID)
			if (!src.wear_id)
				src.wear_id = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["id"])
				I.equipped(src, SLOT_WEAR_ID)
				equipped = 1
				clothing_dirty |= C_ID
			else if (istype(src.wear_id,/obj/item/clothing/lanyard)) // Lanyards
				if (src.wear_id.storage.check_can_hold(I))
					src.wear_id.storage.add_contents(I)
		if (SLOT_EARS)
			if (!src.ears && src.organHolder && src.organHolder.head)
				src.ears = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["ears"])
				I.equipped(src, SLOT_EARS)
				equipped = 1
				clothing_dirty |= C_EARS
		if (SLOT_GLASSES)
			if (!src.glasses && src.organHolder && src.organHolder.head)
				src.glasses = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["glasses"])
				I.equipped(src, SLOT_GLASSES)
				equipped = 1
				clothing_dirty |= C_GLASSES
		if (SLOT_GLOVES)
			if (!src.gloves)
				src.gloves = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["gloves"])
				I.equipped(src, SLOT_GLOVES)
				equipped = 1
				clothing_dirty |= C_GLOVES
		if (SLOT_HEAD)
			if (!src.head && src.organHolder && src.organHolder.head)
				src.head = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["head"])
				I.equipped(src, SLOT_HEAD)
				equipped = 1
				src.update_hair_layer()
				clothing_dirty |= C_HEAD
		if (SLOT_SHOES)
			if (!src.shoes)
				src.shoes = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["shoes"])
				I.equipped(src, SLOT_SHOES)
				equipped = 1
				clothing_dirty |= C_SHOES
		if (SLOT_WEAR_SUIT)
			if (!src.wear_suit)
				src.wear_suit = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["suit"])
				I.equipped(src, SLOT_WEAR_SUIT)
				equipped = 1
				src.update_hair_layer()
				clothing_dirty |= C_SUIT
		if (SLOT_W_UNIFORM)
			if (!src.w_uniform)
				src.w_uniform = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["under"])
				I.equipped(src, SLOT_W_UNIFORM)
				equipped = 1
				clothing_dirty |= C_UNIFORM
		if (SLOT_L_STORE)
			if (!src.l_store)
				src.l_store = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["storage1"])
				if (I.storage && !I.storage.opens_if_worn) // from item/proc/equipped()
					I.storage.hide_hud(src)
				equipped = 1
		if (SLOT_R_STORE)
			if (!src.r_store)
				src.r_store = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["storage2"])
				if (I.storage && !I.storage.opens_if_worn)
					I.storage.hide_hud(src)
				equipped = 1
		if (SLOT_IN_BACKPACK)
			if (src.back?.storage)
				if (role_equipped)
					src.back.storage.add_contents(I, src, FALSE)
					equipped = TRUE
				else
					src.back.storage.add_contents_safe(I, src, FALSE)
					equipped = (I in src.back.storage.get_contents())
		if (SLOT_IN_BELT)
			if (src.belt?.storage)
				if (role_equipped)
					src.belt.storage.add_contents(I, src, FALSE)
					equipped = TRUE
				else
					src.belt.storage.add_contents_safe(I, src, FALSE)
					equipped = (I in src.belt.storage.get_contents())
				equipped = 1

	if (equipped)
		if (slot != SLOT_IN_BACKPACK && slot != SLOT_IN_BELT)
			I.set_loc(src)
		if (islist(I.ability_buttons) && length(I.ability_buttons))
			I.set_mob(src)
			if (slot != SLOT_IN_BACKPACK && slot != SLOT_IN_BELT)
				I.show_buttons()
		src.update_clothing()
	return equipped


/mob/living/carbon/human/proc/update_equipment_screen_loc()
	hud.inventory_items.len = 0
	if (src.back)
		hud.add_other_object(src.back,hud.layouts[hud.layout_style]["back"])
	if (src.wear_mask)
		hud.add_other_object(src.wear_mask,hud.layouts[hud.layout_style]["mask"])
	if (src.l_hand)
		hud.add_other_object(src.l_hand,hud.layouts[hud.layout_style]["lhand"])
	if (src.r_hand)
		hud.add_other_object(src.r_hand,hud.layouts[hud.layout_style]["rhand"])
	if (src.belt)
		hud.add_other_object(src.belt,hud.layouts[hud.layout_style]["belt"])
	if (src.wear_id)
		hud.add_other_object(src.wear_id,hud.layouts[hud.layout_style]["id"])
	if (src.ears)
		hud.add_other_object(src.ears,hud.layouts[hud.layout_style]["ears"])
	if (src.glasses)
		hud.add_other_object(src.glasses,hud.layouts[hud.layout_style]["glasses"])
	if (src.gloves)
		hud.add_other_object(src.gloves,hud.layouts[hud.layout_style]["gloves"])
	if (src.head)
		hud.add_other_object(src.head,hud.layouts[hud.layout_style]["head"])
	if (src.shoes)
		hud.add_other_object(src.shoes,hud.layouts[hud.layout_style]["shoes"])
	if (src.wear_suit)
		hud.add_other_object(src.wear_suit,hud.layouts[hud.layout_style]["suit"])
	if (src.w_uniform)
		hud.add_other_object(src.w_uniform,hud.layouts[hud.layout_style]["under"])
	if (src.l_store)
		hud.add_other_object(src.l_store,hud.layouts[hud.layout_style]["storage1"])
	if (src.r_store)
		hud.add_other_object(src.r_store,hud.layouts[hud.layout_style]["storage2"])

/mob/living/carbon/human/proc/can_equip(obj/item/I, slot)
	switch (slot)
		if (SLOT_L_STORE, SLOT_R_STORE)
			if (I.w_class <= W_CLASS_POCKET_SIZED && src.w_uniform)
				return TRUE
		if (SLOT_L_HAND)
			if (src.limbs.l_arm)
				if (!istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm) && !istype(src.limbs.l_arm, /obj/item/parts/robot_parts/arm) && !istype(src.limbs.l_arm, /obj/item/parts/artifact_parts/arm))
					return FALSE
				if (istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item))
					return FALSE
				if (I.two_handed)
					if (src.limbs.r_arm)
						if(src.r_hand)
							return FALSE
					else
						return FALSE
				return TRUE
		if (SLOT_R_HAND)
			if (src.limbs.r_arm)
				if (!istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm) && !istype(src.limbs.r_arm, /obj/item/parts/robot_parts/arm) && !istype(src.limbs.r_arm, /obj/item/parts/artifact_parts/arm))
					return FALSE
				if (istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item))
					return FALSE
				if (I.two_handed)
					if (src.limbs.l_arm)
						if(src.l_hand)
							return FALSE
					else
						return FALSE
				return TRUE
		if (SLOT_BELT)
			if ((I.c_flags & ONBELT) && src.w_uniform)
				return TRUE
		if (SLOT_WEAR_ID)
			if (istype(I, /obj/item/card/id) && src.w_uniform)
				return TRUE
			if (istype(I, /obj/item/device/pda2) && src.w_uniform) // removed the check for the ID card in here because tbh it was silly that you could only equip it to the ID slot when it had a card  :I
				return TRUE
			if (istype(I, /obj/item/clothing/lanyard) && src.w_uniform)
				return TRUE
		if (SLOT_BACK)
			if (I.c_flags & ONBACK)
				return TRUE
		if (SLOT_WEAR_MASK) // It's not pretty, but the mutantrace check will do for the time being (Convair880).
			if (!src.organHolder.head)
				return FALSE
			if (istype(I, /obj/item/clothing/mask))
				var/obj/item/clothing/M = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !M.compatible_species.Find(src.mutantrace.name)))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return FALSE
				else
					return TRUE
		if (SLOT_EARS)
			if (!src.organHolder.head)
				return FALSE
			if (istype(I, /obj/item/clothing/ears) || istype(I,/obj/item/device/radio/headset))
				return TRUE
		if (SLOT_GLASSES)
			if (!src.organHolder.head)
				return FALSE
			if (istype(I, /obj/item/clothing/glasses))
				return TRUE
		if (SLOT_GLOVES)
			if ((!src.limbs.l_arm) && (!src.limbs.r_arm))
				return FALSE
			if (istype(I, /obj/item/clothing/gloves))
				return TRUE
		if (SLOT_HEAD)
			if (!src.organHolder.head)
				return FALSE
			if (istype(I, /obj/item/clothing/head))
				var/obj/item/clothing/H = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !(src.mutantrace.name in H.compatible_species)))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return FALSE
				else if (src.wear_suit?.hooded)
					return FALSE
				else
					return TRUE
		if (SLOT_SHOES)
			if ((!src.limbs.l_leg) && (!src.limbs.r_leg))
				return FALSE
			if (istype(I, /obj/item/clothing/shoes))
				var/obj/item/clothing/SH = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !(src.mutantrace.name in SH.compatible_species)))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return FALSE
				else
					return TRUE
		if (SLOT_WEAR_SUIT)
			if (istype(I, /obj/item/clothing/suit))
				var/obj/item/clothing/SU = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !(src.mutantrace.name in SU.compatible_species)))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return FALSE
				else
					return TRUE
		if (SLOT_W_UNIFORM)
			if (istype(I, /obj/item/clothing/under))
				var/obj/item/clothing/U = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !(src.mutantrace.name in U.compatible_species)))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return FALSE
				else
					return TRUE
		if (SLOT_IN_BACKPACK) // this slot is stupid
			if (src.back?.storage?.check_can_hold(I) == STORAGE_CAN_HOLD)
				return TRUE
		if (SLOT_IN_BELT) // this slot is also stupid
			if (src.belt?.storage?.check_can_hold(I) == STORAGE_CAN_HOLD)
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/equip_new_if_possible(path, slot)
	var/obj/item/I = new path(src)
	src.equip_if_possible(I, slot)
	if(slot != SLOT_IN_BACKPACK && slot != SLOT_IN_BELT && src.get_slot(slot) != I)
		qdel(I)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/equip_if_possible(obj/item/I, slot, role_equipped = TRUE)
	if (can_equip(I, slot))
		return force_equip(I, slot, role_equipped)
	else
		return 0

/// swap I into the given slot, puts item in that slot (if it exists) into hand or on ground
/mob/living/carbon/human/proc/autoequip_slot(obj/item/I, slot)
	if(!src.can_equip(I, slot) || istype(I.loc, /obj/item/parts))
		return FALSE
	var/obj/item/current = src.get_slot(slot)
	if(current && current.cant_self_remove)
		return FALSE
	src.u_equip(I)
	if(current)
		current.unequipped(src)
		src.hud?.remove_item(current)
		src.vars[slot] = null
		if(!src.put_in_hand(current))
			src.drop_from_slot(current, get_turf(current))
	src.force_equip(I, slot)
	return TRUE
///Tries to put an item in an available backpack, pocket, or hand slot, default specified to delete the item if unsuccessful
/mob/living/carbon/human/proc/stow_in_available(obj/item/I, delete_item = TRUE)
	if (src.autoequip_slot(I, SLOT_IN_BACKPACK))
		return
	if (src.autoequip_slot(I, SLOT_IN_BELT))
		return
	if (src.autoequip_slot(I, SLOT_L_STORE))
		return
	if (src.autoequip_slot(I, SLOT_R_STORE))
		return
	if (src.autoequip_slot(I, SLOT_L_HAND))
		return
	if (src.autoequip_slot(I, SLOT_R_HAND))
		return
	if (delete_item)
		qdel(I)
	else
		I.set_loc(get_turf(src))

/mob/living/carbon/human/swap_hand(var/specify=-1)
	if(src.hand == specify)
		return
	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B)
		qdel(B)
	var/obj/item/old = src.equipped()
	if (specify >= 0)
		src.hand = specify
	else
		src.hand = !src.hand
	hud.update_hands()
	if(old != src.equipped())
		if(old)
			SEND_SIGNAL(old, COMSIG_ITEM_SWAP_AWAY, src)
		if(src.equipped())
			SEND_SIGNAL(src.equipped(), COMSIG_ITEM_SWAP_TO, src)
	if(src.equipped() && (src.equipped().item_function_flags & USE_INTENT_SWITCH_TRIGGER) && !src.equipped().two_handed)
		src.equipped().intent_switch_trigger(src)

/mob/living/carbon/human/emp_act()
	boutput(src, SPAN_ALERT("<B>Your equipment malfunctions.</B>"))

	var/list/L = src.get_all_items_on_mob()
	if (length(L))
		for (var/obj/O in L)
			O.emp_act()
	boutput(src, SPAN_ALERT("<B>BZZZT</B>"))

/mob/living/carbon/human/verb/consume(mob/M as mob in oview(0))
	set hidden = 1
	var/mob/living/carbon/human/H = M
	if (!istype(H))
		return

	if (!H.stat)
		boutput(usr, "You can't eat [H] while [hes_or_shes(H)] conscious!")
		return

	if (H.bioHolder.HasEffect("consumed"))
		boutput(usr, "There's nothing left to consume!")
		return

	if(src.emote_check(1, 50, 0))	//spam prevention
		usr.visible_message(SPAN_ALERT("[usr] starts [pick("taking bites out of","chomping","chewing","biting","eating","gnawing")] [H]. [pick("What a [pick("psychopath","freak","weirdo","lunatic","creep","rude dude","nutter","jerk","nerd")]!","Holy shit!","What the [pick("hell","fuck","christ","shit","heck")]?","Oh [pick("no","dear","god")]!")]"))

		var/loc = usr.loc

		SPAWN(5 SECONDS)
			if (usr.loc != loc || H.loc != loc)
				boutput(usr, SPAN_ALERT("Your consumption of [H] was interrupted!"))
				return

			usr.visible_message(SPAN_ALERT("[usr] finishes [pick("taking bites out of","chomping","chewing","biting","eating","gnawing")] [H]. That was [pick("gross","horrific","disturbing","weird","horrible","funny","strange","odd","creepy","bloody","gory","shameful","awkward","unusual")]!"))

			if (prob(10) && !H.mutantrace)
				usr.reagents.add_reagent("prions", 10)
				SPAWN(rand(20,50)) boutput(usr, SPAN_ALERT("You don't feel so good."))

			H.TakeDamageAccountArmor("chest", rand(30,50), 0, 0, DAMAGE_STAB)
			if (!isdead(H) && prob(50))
				H.emote("scream")
			H.bioHolder.AddEffect("consumed")
			take_bleeding_damage(H, null, rand(15,30), DAMAGE_STAB)
	else
		src.show_text("You're not done eating the last piece yet.", "red")

/mob/living/carbon/human/verb/numbers()
	set name = "7848(2)9(1)"
	set hidden = 1

	boutput(src, SPAN_ALERT("You have no idea what to do with that."))
	boutput(src, SPAN_ALERT("This statement is universally true because if you did you probably wouldn't be desperate enough to see this message."))

/mob/living/carbon/human/full_heal()
	blinded = 0
	bleeding = 0
	blood_volume = 500
	decomp_stage = DECOMP_STAGE_NO_ROT

	if (!src.limbs)
		src.limbs = new /datum/human_limbs(src)
	else
		src.limbs.mend()
	//Unbreak organs. There really should be no way to do this so there's no proc, but I'm explicitly making to work for this. - kyle
	for (var/organ_slot in src.organHolder.organ_list)
		var/obj/item/organ/O = src.organHolder.organ_list[organ_slot]
		if(istype(O))
			O.unbreakme()
	if (!src.organHolder)
		src.organHolder = new(src)
	src.organHolder.heal_organs(INFINITY, INFINITY, INFINITY, list("liver", "left_kidney", "right_kidney", "stomach", "intestines","spleen", "left_lung", "right_lung","appendix", "pancreas", "heart", "brain", "left_eye", "right_eye", "tail"))

	src.organHolder.create_organs()
	if (src.organHolder.chest)
		src.organHolder.chest.op_stage = 0
	if (src.organHolder.heart)
		src.organHolder.heart.op_stage = 0
	if (src.organHolder.brain)
		src.organHolder.brain.op_stage = 0

	if (src.get_stamina() != (STAMINA_MAX + src.get_stam_mod_max()))
		src.set_stamina(STAMINA_MAX + src.get_stam_mod_max())

	..()

	if (src.bioHolder)
		bioHolder.RemoveAllEffects(EFFECT_TYPE_DISABILITY)

	if (src.sims)
		for (var/name in sims.motives)
			sims.affectMotive(name, 100)

	if (implant)
		for (var/obj/item/implant/I in implant)
			if (istype(I, /obj/item/implant/projectile))
				boutput(src, "[I] falls out of you!")
				I.on_remove(src)
				implant.Remove(I)
				I.set_loc(get_turf(src))
				continue

	update_face()
	return

/mob/living/carbon/human/get_equipped_ore_scoop()
	if (istype(src.l_hand,/obj/item/ore_scoop))
		return src.l_hand
	else if (istype(src.r_hand,/obj/item/ore_scoop))
		return src.r_hand
	else
		return null

/mob/living/carbon/human/emag_act(mob/user, obj/item/card/emag/E)

	if (prob(1)) //Magnet healing!
		src.HealDamage("All", 3, 3)
		src.show_text("The electromagnetic field seems to make your joints feel less stiff! Maybe...", "blue")
		if (user) user.show_text("You pass \the [E] over [src]'s body, thinking positive thoughts. They look a little better. <BR><B>You have the gift!</B>", "blue")
		return 1
	else
		if (user && user != src && E)
			user.show_text("You poke [src] with \the [E].", "red")
			src.show_text("<B>[user]</B> pokes you with \an [E]. [prob(25)?"What a weirdo.":null]", "red")
		else if (user)
			if (!emagged)
				emagged = 1
				user.show_text("You poke yourself with \the [E]! [pick_string("descriptors.txt","emag_self")]", "red")
			else
				user.show_text("You poke yourself with \the [E]! It does nothing. What did you expect?","red")
	return 0

//MBC : oh god there's like 6 different code paths for the 'rip apart handcuffs' ability
//																						pls standardize later
/mob/living/carbon/human/resist()
	if (..()) // For resisting burning and grabs see living.dm
		return TRUE
	// Added this here (Convair880).
	if (!isalive(src)) //can't resist when dead or unconscious
		return

	if (!src.restrained() && (src.shoes && src.shoes.chained))
		var/obj/item/clothing/shoes/SH = src.shoes
		if (ischangeling(src))
			src.u_equip(SH)
			SH.set_loc(get_turf(src))
			src.update_clothing()
			src.show_text("We briefly shrink our legs to remove the shackles.", "blue")
		else if (src.is_hulk() || ishunter(src) || iswerewolf(src))
			src.visible_message(SPAN_ALERT("[src] rips apart the shackles with pure brute strength!</b>"), SPAN_NOTICE("You rip apart the shackles."))
			var/obj/item/clothing/shoes/NEW = new SH.type
			// Fallback if type is chained by default. Don't think we can check without spawning a pair first.
			if (NEW.chained)
				qdel(NEW)
				NEW = new /obj/item/clothing/shoes/brown
			src.u_equip(SH)
			src.equip_if_possible(NEW, SLOT_SHOES)
			src.update_clothing()
			qdel(SH)
		else if (src.limbs && src.limbs.l_leg.breaks_cuffs && src.limbs.r_leg.breaks_cuffs)
			src.visible_message(SPAN_ALERT("[src] rips apart the shackles with [src.limbs.l_leg.kind_of_limb & LIMB_ROBOT ? "machine-like" : "unnatural"] strength!</b>"), SPAN_NOTICE("You rip apart the shackles."))
			var/obj/item/clothing/shoes/NEW2 = new SH.type
			if (NEW2.chained)
				qdel(NEW2)
				NEW2 = new /obj/item/clothing/shoes/brown
			src.u_equip(SH)
			src.equip_if_possible(NEW2, SLOT_SHOES)
			src.update_clothing()
			qdel(SH)
		else
			src.last_resist = world.time + 100
			var/time = 450
			src.show_text("You attempt to remove your shackles. (This will take around [round(time / 10)] seconds and you need to stand still.)", "red")
			actions.start(new/datum/action/bar/private/icon/shackles_removal(time), src)

	if (src.hasStatus("handcuffed"))
		if (ishuman(src))
			if (ischangeling(src))
				boutput(src, SPAN_NOTICE("We briefly shrink our hands to remove the handcuffs."))
				src.handcuffs.drop_handcuffs(src)
				return
			if (ishunter(src))
				for (var/mob/O in AIviewers(src))
					O.show_message(SPAN_ALERT("<B>[src] rips apart the handcuffs with pure brute strength!</B>"), 1)
				boutput(src, SPAN_NOTICE("You rip apart your handcuffs."))

				src.handcuffs.material_trigger_when_attacked(src, src, 1)
				src.handcuffs.destroy_handcuffs(src)
				return
			if (iswerewolf(src))
				if (src.handcuffs.werewolf_cant_rip())
					boutput(src, SPAN_ALERT("<b>[src.handcuffs] burn you! They'll take a longer time to remove...</b>"))
					// no return, proceed as normal
				else
					src.visible_message(SPAN_ALERT("<B>[src] rips apart the handcuffs with pure brute strength!</b>"))
					boutput(src, SPAN_NOTICE("You rip apart your handcuffs."))
					src.handcuffs.material_trigger_when_attacked(src, src, 1)
					src.handcuffs.destroy_handcuffs(src)
					return
		if (src.is_hulk())
			for (var/mob/O in AIviewers(src))
				O.show_message(SPAN_ALERT("<B>[src] rips apart the handcuffs with pure brute strength!</B>"), 1)
			boutput(src, SPAN_NOTICE("You rip apart your handcuffs."))

			src.handcuffs.material_trigger_when_attacked(src, src, 1)
			src.handcuffs.destroy_handcuffs(src)
		else if ( src.limbs && src.limbs.l_arm?.breaks_cuffs && src.limbs.r_arm?.breaks_cuffs)
			for (var/mob/O in AIviewers(src))
				O.show_message(SPAN_ALERT("<B>[src] rips apart the handcuffs with [src.limbs.l_arm.kind_of_limb & LIMB_ROBOT ? "machine-like" : "unnatural"] strength!</B>"), 1)
			boutput(src, SPAN_NOTICE("You rip apart your handcuffs."))

			src.handcuffs.material_trigger_when_attacked(src, src, 1)
			src.handcuffs.destroy_handcuffs(src)
		else
			src.last_resist = world.time + 100
			var/calcTime
			if (src.handcuffs.material)
				calcTime = clamp((src.handcuffs.material.getProperty("hard") + src.handcuffs.material.getProperty("density"))*5 SECONDS, 20 SECONDS, 50 SECONDS)
			else
				calcTime = istype(src.handcuffs, /obj/item/handcuffs/guardbot) ? rand(15 SECONDS, 18 SECONDS) : rand(40 SECONDS, 50 SECONDS)
			if (!src.canmove)
				calcTime *= 1.5
			boutput(src, SPAN_ALERT("You attempt to remove your handcuffs. (This will take around [round(calcTime / 10)] seconds and you need to stand still)"))
			src.handcuffs.material_trigger_when_attacked(src, src, 1)
			actions.start(new/datum/action/bar/private/icon/handcuffRemoval(calcTime), src)
	return 0

/mob/living/carbon/human/proc/spidergib()
	if (isobserver(src))
		gibs(src.loc)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif

	src.death(TRUE)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if (ishuman(src))
		animation = new(src.loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("spidergib", animation)
		src.visible_message(SPAN_ALERT("<font size=4><B>A swarm of spiders erupts from [src]'s mouth and devours them! OH GOD!</B></font>"), SPAN_ALERT("<font size=4><B>A swarm of spiders erupts from your mouth! OH GOD!</B></font>"), SPAN_ALERT("You hear a vile chittering sound."))
		playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 100, 1)
		SPAWN(1 SECOND)
			make_cleanable(/obj/decal/cleanable/vomit/spiders,src.loc)
			for (var/i in 1 to 4)
				new /mob/living/critter/spider/baby(src.loc)

	if (src.mind || src.client)
		ghostize()

	if (animation)
		animation.delaydispose()

	SPAWN(1.5 SECONDS)
		qdel(src)

/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE)
	. = ..()
	if (src.belt) . += src.belt
	if (src.glasses) . += src.glasses
	if (src.gloves) . += src.gloves
	if (src.head) . += src.head
	if (src.shoes) . += src.shoes
	if (src.wear_id) . += src.wear_id
	if (src.wear_suit) . += src.wear_suit
	if (src.w_uniform) . += src.w_uniform
	if(include_pockets)
		if (src.l_store) . += src.l_store
		if (src.r_store) . += src.r_store


/mob/living/carbon/human/protected_from_space()
	var/space_suit = 0
	if (wear_suit && (wear_suit.c_flags & SPACEWEAR))
		space_suit++
	if (w_uniform && (w_uniform.c_flags & SPACEWEAR))
		space_suit++
	if (head && (head.c_flags & SPACEWEAR))
		space_suit++
	else if (wear_mask && (wear_mask.c_flags & SPACEWEAR))
		space_suit++

	if (space_suit >= 2)
		return 1
	else
		return 0

/mob/living/carbon/human/list_ejectables()
	var/list/ret = list()
	var/list/processed = list()
	if (limbs)
		if (limbs.l_arm && prob(75) && limbs.l_arm.loc == src)
			ret += limbs.l_arm
			processed += limbs.l_arm
		if (limbs.r_arm && prob(75) && limbs.r_arm.loc == src)
			ret += limbs.r_arm
			processed += limbs.r_arm
		if (limbs.l_leg && prob(75) && limbs.l_leg.loc == src)
			ret += limbs.l_leg
			processed += limbs.l_leg
		if (limbs.r_leg && prob(75) && limbs.r_leg.loc == src)
			ret += limbs.r_leg
			processed += limbs.r_leg
	if (src.organHolder)
		if (organHolder.chest)
			processed += organHolder.chest
		if (organHolder.heart)
			processed += organHolder.heart
			if (prob(50) && organHolder.heart.loc == src)
				ret += organHolder.heart
		if (organHolder.skull)
			processed += organHolder.skull
		if (organHolder.brain)
			processed += organHolder.brain
		if (organHolder.head)
			processed += organHolder.head
		if (prob(40))
			if (prob(15) && organHolder.head && organHolder.head.loc == src)
				ret += organHolder.drop_organ("head", src)
			else
				if (organHolder.skull && organHolder.skull.loc == src)
					ret += organHolder.skull
				if (prob(15) && organHolder.brain && organHolder.brain.loc == src)
					ret += organHolder.brain
		if (organHolder.left_eye)
			processed += organHolder.left_eye
			if (prob(25) && organHolder.left_eye.loc == src)
				ret += organHolder.left_eye
		if (organHolder.right_eye)
			processed += organHolder.right_eye
			if (prob(25) && organHolder.right_eye.loc == src)
				ret += organHolder.right_eye
		if (organHolder.left_lung)
			processed += organHolder.left_lung
			if (prob(25) && organHolder.left_lung.loc == src)
				ret += organHolder.left_lung
		if (organHolder.right_lung)
			processed += organHolder.right_lung
			if (prob(25) && organHolder.right_lung.loc == src)
				ret += organHolder.right_lung
		if (organHolder.right_kidney)
			processed += organHolder.right_kidney
			if (prob(25) && organHolder.right_kidney.loc == src)
				ret += organHolder.right_kidney
		if (organHolder.left_kidney)
			processed += organHolder.left_kidney
			if (prob(25) && organHolder.left_kidney.loc == src)
				ret += organHolder.left_kidney
		if (organHolder.liver)
			processed += organHolder.liver
			if (prob(25) && organHolder.liver.loc == src)
				ret += organHolder.liver
		if (organHolder.pancreas)
			processed += organHolder.pancreas
			if (prob(25) && organHolder.pancreas.loc == src)
				ret += organHolder.pancreas
		if (organHolder.spleen)
			processed += organHolder.spleen
			if (prob(25) && organHolder.spleen.loc == src)
				ret += organHolder.spleen
		if (organHolder.appendix)
			processed += organHolder.appendix
			if (prob(25) && organHolder.appendix.loc == src)
				ret += organHolder.appendix
		if (organHolder.stomach)
			processed += organHolder.stomach
			if (prob(25) && organHolder.stomach.loc == src)
				ret += organHolder.stomach
		if (organHolder.intestines)
			processed += organHolder.intestines
			if (prob(25) && organHolder.intestines.loc == src)
				ret += organHolder.intestines
		if (organHolder.tail)
			processed += organHolder.tail
			if (prob(75) && organHolder.tail.loc == src)
				ret += organHolder.tail
		if (prob(50) && !isskeleton(src)) // Skeletons don't have hair, so don't create and drop a wig for them on death
			var/obj/item/clothing/head/wig/W = create_wig(keep_hair = TRUE)
			if (W)
				processed += W
				ret += W
		if (organHolder.butt)
			processed += organHolder.butt
			if (prob(50) && organHolder.butt.loc == src)
				ret += organHolder.butt

	for (var/atom/movable/A in contents)
		if (A in processed)
			continue
		if (istype(A, /atom/movable/screen)) // maybe people will stop gibbing out their stamina bars now  :|
			continue
		if (prob(dump_contents_chance) || istype(A, /obj/item/reagent_containers/food/snacks/shell)) //For dudes who got fried and eaten so they eject -ZeWaka
			ret += A
	return ret

/mob/living/carbon/human/proc/is_bald()
	var/datum/appearanceHolder/AH = src.bioHolder.mobAppearance
	return istype(AH.customizations["hair_bottom"], /datum/customization_style/none) \
	&& istype(AH.customizations["hair_middle"], /datum/customization_style/none) \
	&& istype(AH.customizations["hair_top"], /datum/customization_style/none)

/mob/living/carbon/human/proc/create_wig(var/keep_hair = FALSE)
	if (!src.bioHolder || !src.bioHolder.mobAppearance)
		return null
	var/obj/item/clothing/head/wig/W = new(src)
	W.name = "[real_name]'s hair"
	W.real_name = "[real_name]'s hair" // The clothing parent setting real_name is probably good for other stuff so I'll just do this
	W.icon = 'icons/mob/human_hair.dmi'
	W.icon_state = "bald" // Let's give the actual hair a chance to shine

	var/hair_list = list()
	hair_list[src.bioHolder.mobAppearance.customizations["hair_bottom"].style.id] = src.bioHolder.mobAppearance.customizations["hair_bottom"].color
	hair_list[src.bioHolder.mobAppearance.customizations["hair_middle"].style.id] = src.bioHolder.mobAppearance.customizations["hair_middle"].color
	hair_list[src.bioHolder.mobAppearance.customizations["hair_top"].style.id] = src.bioHolder.mobAppearance.customizations["hair_top"].color

	W.setup_wig(hair_list)

	if (!keep_hair)
		src.bioHolder.mobAppearance.customizations["hair_bottom"].style = new /datum/customization_style/none
		src.bioHolder.mobAppearance.customizations["hair_middle"].style = new /datum/customization_style/none
		src.bioHolder.mobAppearance.customizations["hair_top"].style = new /datum/customization_style/none
		src.update_colorful_parts()
	return W


/mob/living/carbon/human/set_eye()
	..()
	src.update_sight()

/mob/living/carbon/human/heard_say(var/mob/other, var/message)
	if (!sims)
		return
	if (other != src)
		sims.affectMotive("social", 5)

/mob/living/carbon/human/proc/lose_limb(var/limb)
	if (!src.limbs)
		return
	if(!(limb in list("l_arm","r_arm","l_leg","r_leg"))) return

	//not exactly elegant, but fuck it, src.vars[limb].remove() didn't want to work :effort:
	if(limb == "l_arm" && src.limbs.l_arm) src.limbs.l_arm.remove()
	else if(limb == "r_arm" && src.limbs.r_arm) src.limbs.r_arm.remove()
	else if(limb == "l_leg" && src.limbs.l_leg) src.limbs.l_leg.remove()
	else if(limb == "r_leg" && src.limbs.r_leg) src.limbs.r_leg.remove()

/mob/living/carbon/human/proc/sever_limb(var/limb)
	if (!src.limbs)
		return
	if(!(limb in list("l_arm","r_arm","l_leg","r_leg"))) return

	//not exactly elegant, but fuck it, src.vars[limb].sever() didn't want to work :effort:
	if(limb == "l_arm" && src.limbs.l_arm) src.limbs.l_arm.sever()
	else if(limb == "r_arm" && src.limbs.r_arm) src.limbs.r_arm.sever()
	else if(limb == "l_leg" && src.limbs.l_leg) src.limbs.l_leg.sever()
	else if(limb == "r_leg" && src.limbs.r_leg) src.limbs.r_leg.sever()

/mob/living/carbon/human/proc/has_limb(var/limb)
	if (!src.limbs)
		return
	if(!(limb in list("l_arm","r_arm","l_leg","r_leg"))) return

	if(limb == "l_arm" && src.limbs.l_arm) return 1
	else if(limb == "r_arm" && src.limbs.r_arm) return 1
	else if(limb == "l_leg" && src.limbs.l_leg) return 1
	else if(limb == "r_leg" && src.limbs.r_leg) return 1

/mob/living/carbon/human/hand_attack(atom/target, params, location, control)
	if (src.lying && src.buckled != target) //lol we need to allow unbuckling here i guess...
		return

	if (mutantrace?.override_attack)
		if(mutantrace.custom_attack(target))
			return
	var/obj/item/parts/arm = null
	if (limbs) //Wire: fix for null.r_arm and null.l_arm
		arm = hand ? limbs.l_arm : limbs.r_arm // I'm so sorry I couldent kill all this shitcode at once
	if (arm)
		arm.limb_data.attack_hand(target, src, can_reach(src, target), params, location, control)

/mob/living/carbon/human/hand_range_attack(atom/target, params, location, control, origParams)
	//This looks bad but it really isn't anymore. <3

	var/list/valid_slots = list(
		SLOT_BACK,
		SLOT_WEAR_MASK,
		SLOT_BELT,
		SLOT_WEAR_ID,
		SLOT_EARS,
		SLOT_GLASSES,
		SLOT_GLOVES,
		SLOT_HEAD,
		SLOT_SHOES,
		SLOT_WEAR_SUIT,
		SLOT_W_UNIFORM,
		SLOT_L_STORE,
		SLOT_R_STORE,
		SLOT_L_HAND,
		SLOT_R_HAND
	)

	for(var/slot in valid_slots)
		var/obj/item/slot_item = src.get_slot(slot)
		if (slot_item?.flags & HAS_EQUIP_CLICK &&\
		 	src.in_real_view_range(get_turf(target)) &&\
		 	slot_item.equipment_click(src, target, params, location, control, origParams, slot))
			return

	if (src.lying)
		if (src.limbs.r_leg || src.limbs.l_leg) //legless people should still be able to interact
			return 0
	.=..()

/mob/living/carbon/human/attack_hand(mob/M)
	if(ishuman(M) && M == src && M.a_intent == "harm")
		var/mob/living/carbon/human/H = M
		if(HAS_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM))
			boutput(H, "You can't bring yourself to attack yourself!")
			return
	..()
	if (!surgeryCheck(src, M))
		src.activate_chest_item_on_attack(M)

/mob/living/carbon/human/attackby(obj/item/W, mob/M)
	if (isghostcritter(M) && src.health < 80) //there's another one of these in attack_hand(). Same file. see, the quality of my code doens't matter as long as i leave a very helpful comment!!!
		boutput(M, "Your spectral conscience refuses to damage this human any further.")
		return
	if(ishuman(M) && M == src && (W.force > 0))
		var/mob/living/carbon/human/H = M
		if(HAS_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM))
			boutput(H, "You can't bring yourself to attack yourself!")
			return
	..()
	if (!surgeryCheck(src, M))
		src.activate_chest_item_on_attack(M)

/mob/living/carbon/human/understands_language(var/langname)
	if (mutantrace)
		if ((langname == "" || langname == "english") && !mutantrace.override_language)
			. = 1
		else if (mutantrace.override_language == langname)
			. = 1
		else if (langname in mutantrace.understood_languages)
			. = 1
		else if (istype(src.wear_mask, /obj/item/clothing/mask/monkey_translator))
			var/obj/item/clothing/mask/monkey_translator/translator = src.wear_mask
			if (langname == translator.new_language)
				. = 1
		else
			. = 0
	else
		. = ..()
	if ((langname == "silicon" || langname == "binary") && ((locate(/obj/item/implant/robotalk) in implant) || src.traitHolder.hasTrait("roboears")))
		return 1
	return .

/mob/living/carbon/human/bump(atom/movable/AM as mob|obj)
	if (wearing_football_gear())
		src.tackle(AM)
	..()

/mob/living/carbon/human/get_special_language(var/secure_mode)
	if (secure_mode == "s" && ((locate(/obj/item/implant/robotalk) in implant) || src.traitHolder.hasTrait("roboears")))
		return "silicon"
	return null

/mob/living/carbon/human/HealBleeding(var/amt)
	bleeding = max(bleeding - amt, 0)

/mob/living/carbon/human/proc/juggling()
	if (islist(src.juggling) && length(src.juggling))
		return 1
	return 0

/mob/living/carbon/human/proc/drop_juggle()
	set waitfor = FALSE // remove if you want to see 3,500 SHOULD_NOT_SLEEP errors because anything that ever causes a person to die can't sleep anymore

	if (!src.juggling())
		return
	src.visible_message(SPAN_ALERT("<b>[src]</b> drops everything [he_or_she(src)] [were_or_was(src)] juggling!"))
	for (var/atom/movable/A in src.juggling)
		src.remove_juggle(A)
		if(istype(A, /obj/item/device/light)) //i hate this
			var/obj/item/device/light/L = A
			L.light?.attach(L)
		if (istype(A, /obj/item/gun) && prob(80)) //prob(80)
			var/obj/item/gun/gun = A
			gun.shoot(get_turf(pick(view(10, src))), get_turf(src), src, 16, 16)
		else if (prob(40)) //bombs might land funny
			if (istype(A, /obj/item/chem_grenade) || istype(A, /obj/item/old_grenade) || istype(A, /obj/item/pipebomb/bomb))
				var/obj/item/explosive = A
				explosive.AttackSelf(src)
			else if (istype(A, /obj/item/device/transfer_valve))
				var/obj/item/device/transfer_valve/ttv = A
				ttv.toggle_valve()
				logTheThing(LOG_BOMBING, src, "accidentally [ttv.valve_open ? "opened" : "closed"] the valve on a TTV tank transfer valve by failing to juggle at [log_loc(src)].")
				message_admins("[key_name(usr)] accidentally [ttv.valve_open ? "opened" : "closed"] the valve on a TTV tank transfer valve by failing to juggle at [log_loc(src)].")
		A.set_loc(get_turf(src)) //I give up trying to make this work with src.loc
		if (prob(25))
			A.throw_at(get_step(src, pick(alldirs)), 1, 1)
	src.drop_from_slot(src.r_hand)
	src.drop_from_slot(src.l_hand)
	src.update_body()
	logTheThing(LOG_STATION, src, "drops the items they were juggling")

/mob/living/carbon/human/proc/remove_juggle(atom/movable/thing)
	UnregisterSignal(thing, COMSIG_MOVABLE_SET_LOC)
	thing.layer = initial(thing.layer)
	src.juggle_dummy.vis_contents -= thing
	animate_spin(thing, parallel = FALSE, looping = 0)
	thing.pixel_x = initial(thing.pixel_x)
	thing.pixel_y = initial(thing.pixel_y)
	thing.layer = initial(thing.layer)
	src.juggling -= thing

/mob/living/carbon/human/proc/add_juggle(atom/movable/thing)
	if (!thing || src.stat)
		return
	if (istype(thing, /obj/item/grab))
		return
	src.u_equip(thing)
	if (thing.loc != src)
		thing.set_loc(src)
	if (src.juggling())
		var/items = ""
		var/count = 0
		for (var/atom/movable/juggled in src.juggling)
			count ++
			if (length(src.juggling) > 1 && count == src.juggling.len)
				items += " and [juggled]"
				continue
			items += ", [juggled]"
		items = copytext(items, 3)
		src.visible_message("<b>[src]</b> adds [thing] to the [items] [he_or_she(src)] [were_or_was(src)] already juggling!")
	else
		src.visible_message("<b>[src]</b> starts juggling [thing]!")
	src.juggling += thing
	if(isnull(src.juggle_dummy))
		src.juggle_dummy = new(null)
		src.juggle_dummy.name = null
		src.juggle_dummy.mouse_opacity = FALSE
		src.juggle_dummy.Scale(2/3, 2/3)
		src.juggle_dummy.layer = src.layer + 0.1
		src.juggle_dummy.appearance_flags |= RESET_COLOR | RESET_ALPHA
		src.vis_contents += src.juggle_dummy
	src.juggle_dummy.vis_contents += thing
	thing.layer = src.layer + 0.1
	animate_juggle(thing)
	RegisterSignal(thing, COMSIG_MOVABLE_SET_LOC, PROC_REF(remove_juggle)) //there are so many ways juggled things can be stolen I'm just doing this
	JOB_XP(src, "Clown", 1)
	if (isitem(thing))
		var/obj/item/i = thing
		i.on_spin_emote(src)
	src.update_body()
	logTheThing(LOG_STATION, src, "starts juggling [thing].")

/mob/living/carbon/human/relaymove(mob/user, direction, delay, running)
	if ((user in src.juggling) && !ON_COOLDOWN(user, "resist_juggle", 1 SECOND))
		boutput(user, SPAN_ALERT("You attempt to wriggle free from the unending juggling."))
		playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
		if (prob(15))
			src.remove_juggle(user)
			user.set_loc(src.loc)

/mob/living/carbon/human/return_air(direct = FALSE)
	if (!direct)
		return src.loc?.return_air()

/mob/living/carbon/human/does_it_metabolize()
	return 1

/mob/living/carbon/human/canRideMailchutes()
	if (ismonkey(src)) // Why not, I guess?
		return 1
	else if (src.w_uniform && istype(src.w_uniform, /obj/item/clothing/under/misc/mail/syndicate))
		return 1
	else
		return 0

/mob/living/carbon/human/set_mutantrace(var/datum/mutantrace/mutantrace_type)

	if(!mutantrace_type)
		mutantrace_type = src.default_mutantrace
	if(src.mutantrace)
		qdel(src.mutantrace) // so that disposing() runs and removes mutant traits
		. = 1

	if(istype(mutantrace_type, /datum/mutantrace)) // So it'll still work if passed an initialized datum
		mutantrace_type = mutantrace_type.type

	if(ispath(mutantrace_type, /datum/mutantrace) )	//Set a new mutantrace only if passed one
		src.mutantrace = new mutantrace_type(src)
		src.mutantrace.MutateMutant(src, "set")
		src.mutantrace.on_attach(src) // Mutant race initalization, to avoid issues with abstract representation in New()
		. = 1

	if(.)
		src.set_face_icon_dirty()
		src.set_body_icon_dirty()
	else // updates are called by the mutantrace datum. lets not call it a million times
		src.update_body()
		src.update_clothing()

/mob/living/carbon/human/verb/change_hud_style()
	set name = "Change HUD Style"
	set desc = "Selects what style HUD you would like to use."
	set category = "Commands"

	if (!src.hud) // uh?
		return src.show_text("<b>Somehow you have no HUD! Please alert a coder!</b>", "red")

	var/selection = tgui_input_list(usr, "What style HUD style would you like?", "Selection", hud_style_selection)
	if (!selection)
		return

	src.force_hud_style(selection)

/mob/living/carbon/human/proc/force_hud_style(var/selection)
	if (!selection)
		return

	if (src.client && src.client.preferences) // there's bits and bobs that are created/destroyed that check prefs to see how they should look
		src.client.preferences.hud_style = selection

	var/icon/new_style = hud_style_selection[selection]

	src.hud.change_hud_style(new_style)

	if (src.zone_sel)
		src.zone_sel.change_hud_style(new_style)

	var/obj/item/R = src.find_type_in_hand(/obj/item/grab, "right") // same with grabs
	if (R)
		R.icon = new_style

	var/obj/item/L = src.find_type_in_hand(/obj/item/grab, "left") // same for the other hand
	if (L)
		L.icon = new_style

	if (src.sims) // saaaaame with sims motives
		src.sims.updateHudIcons(new_style)
	return
// --- Chest Item Procs --- //

/mob/living/carbon/human/proc/activate_chest_item_on_attack(mob/living/carbon/human/M) // Let's only have humans do this, ok?
	// If attacker is targeting the chest and a chest item exists, activate it.
	if (M && M.zone_sel && M.zone_sel.selecting == "chest" && src.chest_item != null && (src.chest_item in src.contents))
		logTheThing(LOG_COMBAT, M, "activates [src.chest_item] embedded in [src]'s chest cavity at [log_loc(src)]")
		SPAWN(0) //might sleep/input/etc, and we don't want to hold anything up
			src.chest_item.AttackSelf(src)
	return

/mob/living/carbon/human/proc/chest_item_dump_reagents_on_flip()
	if(!(src.chest_item && (src.chest_item in src.contents)))
		return
	// Determine if the container is like a beaker/glass or is an artifact. We're looking for something that's got an
	// open top to it. With stuff like pills/patches it would consume the reagents but not the item itself!
	var/liquidReagentContainer = istype(src.chest_item, /obj/item/reagent_containers/food/drinks) || istype(src.chest_item, /obj/item/reagent_containers/glass/)
	if (liquidReagentContainer && src.chest_item.reagents.total_volume > 0)			// If container type is OK and has reagents...
		var/maxVolumeAdd = src.reagents.maximum_volume - src.reagents.total_volume	// Get max available volume in human
		if (maxVolumeAdd > 0)	// If we can add reagents to human, print message and dump shit into human
			boutput(src, SPAN_ALERT("<b>[src.chest_item] spills its contents inside your chest!"))
			logTheThing(LOG_CHEMISTRY, src, "transfers chemicals from [src.chest_item] [log_reagents(src.chest_item)] to [src] at [log_loc(src)]")
			src.chest_item.reagents.trans_to(src, maxVolumeAdd)
	return

/mob/living/carbon/human/proc/chest_item_attack_self_on_fart()
	if(!(src.chest_item && (src.chest_item in src.contents)))
		return
	src.show_text("You grunt and squeeze <B>[src.chest_item]</B> in your chest.")
	if (src.chest_item_sewn == 0 || istype(src.chest_item, /obj/item/cloaking_device))	// If item isn't sewn in, poop it onto the ground. No fartcloaks allowed
		// Item object is pooped out
		if (istype(src.chest_item, /obj/item/))
			// Determine ass and bleed damage based on item size
			var/poopingDamage = 0
			if (src.chest_item.w_class == W_CLASS_TINY )
				poopingDamage = 5
				src.show_text("<B>[src.chest_item]</B> plops out of your rear and onto the floor.")
			else if (src.chest_item.w_class == W_CLASS_SMALL )
				poopingDamage = 10
				src.show_text("You poop out <B>[src.chest_item]</B>! Your butt aches a bit.")
			else if (src.chest_item.w_class == W_CLASS_NORMAL )
				poopingDamage = 20
				src.show_text(SPAN_ALERT("<B>[src.chest_item]</B> was shat out, that's got to hurt!"))
				src.changeStatus("stunned", 2 SECONDS)
				take_bleeding_damage(src, src, 5)
			else if (src.chest_item.w_class == W_CLASS_BULKY || src.chest_item.w_class == W_CLASS_HUGE)
				poopingDamage = 50
				src.show_text(SPAN_ALERT("<B>[src.chest_item] explodes out of your ass, jesus christ!</B>"))
				src.changeStatus("stunned", 5 SECONDS)
				take_bleeding_damage(src, src, 20)

			// Deal out ass damage
			src.TakeDamage("chest", poopingDamage, 0, 0, src.chest_item.hit_type)

			// If the object cuts things, cut the butt off
			var/cutOffButt = 0
			if (src.chest_item.hit_type == DAMAGE_CUT || src.chest_item.hit_type == DAMAGE_STAB)
				cutOffButt = 1
			if (istype(src.chest_item, /obj/item/sword/))
				var/obj/item/sword/c_saber = src.chest_item
				if(c_saber.active)
					cutOffButt = 1
			if (cutOffButt)
				src.TakeDamage("chest", 15, 0, 0, src.chest_item.hit_type)
				take_bleeding_damage(src, src, 15)
				src.show_text(SPAN_ALERT("<B>[src.chest_item] cuts your butt off on the way out!</B>"))
				src.organHolder.drop_organ("butt")
		// Other object is pooped out
		else
			// If it's not an "item", deal medium damage
			src.show_text(SPAN_ALERT("<B>[src.chest_item]</B> was shat out, that's got to hurt!"))
			src.changeStatus("stunned", 1 SECOND)
			src.TakeDamage("chest", 20, 0, 0, DAMAGE_BLUNT)
			take_bleeding_damage(src, src, 5)
		// added log - cirr
		logTheThing(LOG_COMBAT, src, "takes damage from farting out [src.chest_item] embedded in [src]'s chest cavity at [log_loc(src)]")
		// Make copy of item on ground
		var/obj/item/outChestItem = src.chest_item
		outChestItem.set_loc(get_turf(src))
		outChestItem.AttackSelf(src)
		src.chest_item = null
		return
	src.chest_item.AttackSelf(src)

///Clear chest item if it escapes/gets disposed
/mob/living/carbon/human/Exited(atom/movable/thing)
	..()
	if (thing == chest_item)
		chest_item = null
		chest_item_sewn = 0

/mob/living/carbon/human/attackby(obj/item/W, mob/M)
	if (src.parry_or_dodge(M))
		return
	..()

/mob/living/carbon/human/get_hand_pixel_x()
	if (src.dir & NORTH || src.dir & SOUTH)
		.= 8 * (src.hand ? 1 : -1) * (src.dir & SOUTH ? 1 : -1)
	else
		.= 4 * (src.hand ? 1 : -1) * (src.dir & WEST ? 1 : -1)

/mob/living/carbon/human/get_hand_pixel_y()
	.= -5 + src.mutantrace.hand_offset

/mob/living/carbon/human/verb/show_inventory()
	set name = "Show Inventory"
	set src in view(1)
	set category = "Local"

	if (usr == src)
		src.hud.relay_click("invtoggle", src, list()) // ha i copy the dumb thing
		return
	if (!src.can_strip(src)) return
	if (LinkBlocked(src.loc,usr.loc)) return
	if (isAI(usr) || isAI(src)) return
	if (isghostcritter(usr) && !isdead(src)) return
	if (isintangible(usr)) return
	src.show_inv(usr)

/mob/living/carbon/human/get_random_equipped_thing_name() //FOR FLAVOR USE ONLY
	var/list/worn = list()
	if (wear_suit)
		worn += wear_suit.name
	else if (w_uniform)
		worn += w_uniform.name

	if (shoes)
		worn += shoes.name
	if (belt)
		worn += belt.name
	if (gloves)
		worn += gloves.name
	if (glasses)
		worn += glasses.name

	if (head)
		worn += head.name

	else if (mutantrace?.self_click_fluff)
		worn += mutantrace.self_click_fluff
	else
		worn += "hair"

	.= pick(worn)


#define can_step_sfx(H)  (H.footstep >= 4 || (H.m_intent != "run" && H.footstep >= 3))

/mob/living/carbon/human/OnMove(source = null)
	var/turf/NewLoc = get_turf(src)
	var/steps = 1
	if (move_dir & (move_dir-1))
		steps *= DIAG_MOVE_DELAY_MULT

	//STEP SOUND HANDLING
	if (!src.lying && isturf(NewLoc) && NewLoc.turf_flags & MOB_STEP)
		if (NewLoc.active_liquid)
			if (NewLoc.active_liquid.step_sound)
				if (src.m_intent == "run")
					if (src.footstep >= 4)
						src.footstep = 0
					else
						src.footstep += steps
					if (src.footstep == 0)
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 50, 1, extrarange = footstep_extrarange)
				else
					if (src.footstep >= 2)
						src.footstep = 0
					else
						src.footstep += steps
					if (src.footstep == 0)
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 20, 1, extrarange = footstep_extrarange)
		else if (src.shoes && src.shoes.step_sound && src.shoes.step_lots)
			if (src.m_intent == "run")
				if (src.footstep >= 2)
					src.footstep = 0
				else
					src.footstep += steps
				if (src.footstep == 0)
					playsound(NewLoc, src.shoes.step_sound, 50, 1, extrarange = footstep_extrarange)
			else
				playsound(NewLoc, src.shoes.step_sound, 20, 1, extrarange = footstep_extrarange)

		else
			src.footstep += steps
			if (can_step_sfx(src))
				src.footstep = 0
				if (NewLoc.step_material || !src.shoes || (src.shoes && src.shoes.step_sound))
					var/priority = 0

					if (!NewLoc.step_material)
						priority = -1
					else if (src.shoes && !src.shoes.step_sound)
						priority = 1

					if (!priority) //now we must resolve bc the floor and the shoe both wanna make noise
						if (!src.shoes) //barefoot
							priority = (STEP_PRIORITY_MAX > NewLoc.step_priority) ? -1 : 1
						else //shoed
							priority = (src.shoes.step_priority > NewLoc.step_priority) ? -1 : 1

					if (priority)
						if (priority > 0)
							priority = "[NewLoc.step_material]"
						else if (priority < 0)
							priority = src.shoes ? src.shoes.step_sound : (src.mutantrace && src.mutantrace.step_override ? src.mutantrace.step_override : "step_barefoot")

						playsound(NewLoc, priority, src.m_intent == "run" ? 65 : 40, 1, extrarange = 3)

	//STEP SOUND HANDLING OVER

	if (prob(5)) // Handling tied or cut shoelaces courtesy of /obj/item/gun/energy/pickpocket
		if (src.shoes && src.m_intent == "run" && src.shoes.laces != LACES_NORMAL)
			if (src.shoes.laces == LACES_TIED) // Laces tied
				boutput(src, "You stumble and fall headlong to the ground. Your shoelaces are a huge knot! [SPAN_ALERT("FUCK!")]")
				src.changeStatus("knockdown", 3 SECONDS)
			else if (src.shoes.laces == LACES_CUT) // Laces cut
				var/obj/item/clothing/shoes/S = src.shoes
				src.u_equip(S)
				S.set_loc(src.loc)
				S.dropped(src)
				S.layer = initial(S.layer)
				if (prob(20)) boutput(src, "You run right the fuck out of your shoes. [SPAN_ALERT("Shit!")]")

	..()
#undef can_step_sfx


/mob/living/carbon/human/set_loc(var/newloc as turf|mob|obj in world)
	if (abilityHolder)
		abilityHolder.set_loc_callback(newloc)
	..()

/mob/living/carbon/human/get_id(not_worn = FALSE)
	. = ..()
	if(. || not_worn)
		return
	var/obj/item/card/id/id_card = get_id_card(src.wear_id)
	if (istype(id_card))
		return id_card

/mob/living/carbon/human/is_hulk()
	if (src.bioHolder && src.bioHolder.HasEffect("hulk"))
		return 1
	else if (istype(src.gloves, /obj/item/clothing/gloves/ring/titanium))
		return 1
	return 0

/mob/living/carbon/human/is_heat_resistant()
	. = ..()
	if (ischangeling(src)) // comic book weakness
		return FALSE

/mob/living/carbon/human/empty_hands()
	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.hand = h
	if (src.juggling())
		src.drop_juggle()

/mob/living/carbon/human/special_movedelay_mod(delay,space_movement,aquatic_movement)
	.= delay
	var/missing_legs = 0
	var/missing_arms = 0
	if (src.limbs)
		if (!src.limbs.l_leg) missing_legs++
		if (!src.limbs.r_leg) missing_legs++
		if (!src.limbs.l_arm) missing_arms++
		if (!src.limbs.r_arm) missing_arms++
	if (src.lying || GET_COOLDOWN(src, "unlying_speed_cheesy"))
		missing_legs = 2
	else if (src.shoes && src.shoes.chained)
		missing_legs = 2

	if (missing_legs == 2 && !(locate(/datum/movement_modifier/slither) in src.movement_modifiers))
		. += 14 - ((2-missing_arms) * 2) // each missing leg adds 7 of movement delay. Each functional arm reduces this by 2.
	else
		. += 7*missing_legs

	var/turf/T = get_turf(src)

	if (T)
		if (T.turf_flags & CAN_BE_SPACE_SAMPLE)
			. -= space_movement

		if (!(src.mutantrace && src.mutantrace.aquatic) && !src.hasStatus("aquabreath"))
			if (aquatic_movement > 0)
				if (T.active_liquid || T.turf_flags & FLUID_MOVE)
					. -= aquatic_movement
			else
				if (T.active_liquid)
					. += T.active_liquid.movement_speed_mod
				else if (istype(T,/turf/space/fluid))
					. += 3

/mob/living/carbon/human/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()

	if(isobj(AM) && src.juggling())
		if (prob(40))
			src.visible_message(SPAN_ALERT("<b>[src]<b> gets hit in the face by [AM]!"))
			src.TakeDamageAccountArmor("head", AM.throwforce, 0)
		else
			if (prob(src.juggling.len * 5)) // might drop stuff while already juggling things
				src.drop_juggle()
			else
				SPAWN(0) //wait for the throw to have fully ended (yes I know this is bad, feel free to fix it if you can figure out how to make throws end early)
					src.add_juggle(AM)
		return

	if(((src.in_throw_mode && src.a_intent == "help") || src.client?.check_key(KEY_THROW)) && !src.equipped())
		if((src.hand && (!src.limbs.l_arm)) || (!src.hand && (!src.limbs.r_arm)) || src.hasStatus("handcuffed") || (prob(60) && src.bioHolder.HasEffect("clumsy")) || ismob(AM) || (thr?.get_throw_travelled() <= 1 && AM.last_throw_x == AM.x && AM.last_throw_y == AM.y))
			src.visible_message(SPAN_ALERT("[src] has been hit by [AM]."))
			logTheThing(LOG_COMBAT, src, "is struck by [AM] [AM.is_open_container() ? "[log_reagents(AM)]" : ""] at [log_loc(src)] (likely thrown by [thr?.user ? thr.user : "a non-mob"]).")
			random_brute_damage(src, AM.throwforce,1)
			if(thr?.user)
				src.was_harmed(thr.user, AM)

			#ifdef DATALOGGER
			game_stats.Increment("violence")
			#endif

			if(AM.throwforce >= 40)
				src.throw_at(get_edge_target_turf(src,get_dir(AM, src)), 10, 1)
				src.changeStatus("stunned", 3 SECONDS)

		else
			AM.Attackhand(src)	// nice catch, hayes. don't ever fuckin do it again
			src.visible_message(SPAN_ALERT("[src] catches the [AM.name]!"))
			logTheThing(LOG_COMBAT, src, "catches [AM] [AM.is_open_container() ? "[log_reagents(AM)]" : ""] at [log_loc(src)] (likely thrown by [thr?.user ? constructName(thr.user) : "a non-mob"]).")
			src.throw_mode_off()
			#ifdef DATALOGGER
			game_stats.Increment("catches")
			#endif

	else  //normmal thingy hit me
		if (AM.throwing & THROW_CHAIRFLIP)
			src.visible_message(SPAN_ALERT("[AM] slams into [src] midair!"))
		else
			src.visible_message(SPAN_ALERT("[src] has been hit by [AM]."))
			random_brute_damage(src, AM.throwforce,1)
			logTheThing(LOG_COMBAT, src, "is struck by [AM] [AM.is_open_container() ? "[log_reagents(AM)]" : ""] at [log_loc(src)] (likely thrown by [thr?.user ? constructName(thr.user) : "a non-mob"]).")
			if(thr?.user)
				src.was_harmed(thr.user, AM)

		#ifdef DATALOGGER
		game_stats.Increment("violence")
		#endif

		if(AM.throwforce >= 40)
			src.throw_at(get_edge_target_turf(src, get_dir(AM, src)), 10, 1)
			src.changeStatus("stunned", 3 SECONDS)

/// Goes through all the things that can be recolored and updates their colors
/mob/living/carbon/human/proc/update_colorful_parts()
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if(!H?.limbs)
			return
		if (istype(H.limbs.l_arm, /obj/item/parts/human_parts ))
			var/obj/item/parts/human_parts/LA = H.limbs.l_arm
			LA.colorize_limb_icon()
			LA.set_skin_tone()
		if (istype(H.limbs.r_arm, /obj/item/parts/human_parts ))
			var/obj/item/parts/human_parts/RA = H.limbs.r_arm
			RA.colorize_limb_icon()
			RA.set_skin_tone()
		if (istype(H.limbs.l_leg, /obj/item/parts/human_parts ))
			var/obj/item/parts/human_parts/LL = H.limbs.l_leg
			LL.colorize_limb_icon()
			LL.set_skin_tone()
		if (istype(H.limbs.r_leg, /obj/item/parts/human_parts ))
			var/obj/item/parts/human_parts/RL = H.limbs.r_leg
			RL.colorize_limb_icon()
			RL.set_skin_tone()
		if (H.organHolder?.head)
			H.organHolder.head.UpdateIcon()
		if (H.organHolder?.tail)
			var/obj/item/organ/tail/T = H.organHolder.tail
			T.colorize_tail(H.bioHolder.mobAppearance)
		H.organHolder?.left_eye?.update_color(H.bioHolder?.mobAppearance, "L")
		H.organHolder?.right_eye?.update_color(H.bioHolder?.mobAppearance, "R")
		H?.bioHolder?.mobAppearance.UpdateMob()

/mob/living/carbon/human/get_pronouns()
	RETURN_TYPE(/datum/pronouns)
	if(isabomination(src))
		return get_singleton(/datum/pronouns/abomination)
	if(src.wear_id)
		// not using get_id() because we don't want held IDs
		var/obj/item/card/id/id = get_id_card(src.wear_id)
		. = id?.pronouns
	if(isnull(.))
		return ..()

/mob/living/carbon/human/hear_talk(mob/M, text, real_name, lang_id) //Allows stuff in your hands/pockets/belt to pickup voice from other people
	var/mob/self = src
	if(M != self)	//So we dont hear ourselves twice
		src.l_store?.hear_talk(M, text, real_name, lang_id)
		src.r_store?.hear_talk(M, text, real_name, lang_id)
		src.belt?.hear_talk(M, text, real_name, lang_id)
		src.r_hand?.hear_talk(M, text, real_name, lang_id)
		src.l_hand?.hear_talk(M, text, real_name, lang_id)
	. = ..()

///Returns the number of clown items someone is wearing
/mob/living/carbon/human/proc/clown_tally()
	. = 0
	if(istype(src.w_uniform, /obj/item/clothing/under/misc/clown))
		. += 1
	if(istype(src.shoes, /obj/item/clothing/shoes/clown_shoes))
		. += 1
	if(istype(src.wear_mask, /obj/item/clothing/mask/clown_hat))
		. += 1

/mob/living/carbon/human/get_chem_depletion_multiplier()
	. = ..()
	if (src.traitHolder.hasTrait("slowmetabolism"))
		. /= 2
	if (src.organHolder && !ischangeling(src))
		if (!src.organHolder.liver || src.organHolder.liver.broken)	//if no liver or liver is dead, deplete slower
			. /= 2
		if (src.organHolder.get_working_kidney_amt() == 0)	//same with kidneys
			. /= 2

/mob/living/carbon/human/get_blood_absorption_rate()
	. = ..()
	var/blood_metabolism_multiplier = 1
	//We adjust the amount of blood we absorb depending on how much the body needs it. Hypotensive causes a higher rate, Hypertensive causes a decreased rate
	switch(src.blood_volume)
		if(551 to INFINITY)
			blood_metabolism_multiplier = 0.8
		if(476 to 550)
			blood_metabolism_multiplier = 1
		if(426 to 475)
			blood_metabolism_multiplier = 1.25
		if(301 to 425)
			blood_metabolism_multiplier = 1.5
		if(201 to 300)
			blood_metabolism_multiplier = 2
		else
			blood_metabolism_multiplier = 3
	//Now we multiply the absorption rate with the metabolism multiplier
	. *= blood_metabolism_multiplier

/mob/living/carbon/human/was_built_from_frame(mob/user, newly_built)
	. = ..()
	ai_init()

/mob/living/carbon/human/proc/on_realname_change()
	src.limbs?.rename_limbs(src.real_name)
	src.organHolder?.rename_organs(src.real_name)
	src.UpdateName()

/mob/living/carbon/human/onVarChanged(variable, oldval, newval)
	. = ..()
	if(variable == "real_name")
		src.on_realname_change()

/mob/living/carbon/human/choose_name(retries, what_you_are, default_name, force_instead)
	. = ..()
	src.on_realname_change()

/mob/living/carbon/human/proc/head_explosion()
	var/list/nearby_turfs = list()
	for(var/turf/T in view(5, src))
		nearby_turfs += T
		var/obj/brain = src.organHolder.drop_organ("brain")
		var/obj/l_eye = src.organHolder.drop_organ("left_eye")
		var/obj/r_eye = src.organHolder.drop_organ("right_eye")
		var/obj/head = src.organHolder.drop_organ("head")
		brain?.throw_at(pick(nearby_turfs), pick(1,2), 10)
		l_eye?.throw_at(pick(nearby_turfs), pick(1,2), 10)
		r_eye?.throw_at(pick(nearby_turfs), pick(1,2), 10)
		qdel(head)
	take_bleeding_damage(src, null, 500, DAMAGE_STAB)
	src.visible_message(SPAN_ALERT("<B>BOOM!</B> [src]'s head explodes."),\
	SPAN_ALERT("<B>BOOM!</B>"),\
	SPAN_ALERT("You hear someone's head explode."))

/mob/living/carbon/human/proc/on_bandage_removal(mob/user, bandaged_part)
	user.tri_message(src, SPAN_NOTICE("<b>[user]</b> removes [src == user ? "[his_or_her(src)]" : "[src]'s"] bandage."),\
		SPAN_NOTICE("You remove [src == user ? "your" : "[src]'s"] bandage."),\
		SPAN_NOTICE("[src == user ? "You remove" : "<b>[user]</b> removes"] your bandage."))
	src.bandaged -= bandaged_part
	src.update_body()

/mob/living/carbon/human/proc/drag_onto_op_table(obj/machinery/optable/table)
	src.setStatus("resting", INFINITE_STATUS)
	src.force_laydown_standup()
	src.hud.update_resting()
	src.set_loc(get_turf(table))
	table.victim = src

/mob/living/carbon/human/proc/update_health_monitor_icon()
	if (!src.health_mon)
		return
	if (src.bioHolder.HasEffect("dead_scan") || isdead(src))
		src.health_mon.icon_state = "-1"
		return
	// Handle possible division by zero
	var/health_prc = (src.health / (src.max_health != 0 ? src.max_health : 1)) * 100
	switch (health_prc)
		if (98 to INFINITY)
			src.health_mon.icon_state = "100"
		if (80 to 98)
			src.health_mon.icon_state = "80"
		if (60 to 80)
			src.health_mon.icon_state = "75"
		if (40 to 60)
			src.health_mon.icon_state = "50"
		if (20 to 40)
			src.health_mon.icon_state = "25"
		if (0 to 20)
			src.health_mon.icon_state = "10"
		if (-INFINITY to 0)
			src.health_mon.icon_state = "0"

/mob/living/carbon/human/proc/update_arrest_icon()
	if (!src.arrestIcon)
		return

	var/arrestState = ""
	var/visibleName = src.face_visible() ? src.real_name : src.name
	var/datum/db_record/record = data_core.security.find_record("name", visibleName)
	if(record)
		var/criminal = record["criminal"]
		if(criminal == ARREST_STATE_ARREST || criminal == ARREST_STATE_DETAIN || criminal == ARREST_STATE_SUSPECT || criminal == ARREST_STATE_PAROLE || criminal == ARREST_STATE_INCARCERATED || criminal == ARREST_STATE_RELEASED || \
				criminal == ARREST_STATE_CLOWN)
			arrestState = criminal
	else if(src.traitHolder.hasTrait("stowaway") && src.traitHolder.hasTrait("jailbird"))
		arrestState = ARREST_STATE_ARREST
	if (arrestState != ARREST_STATE_ARREST) // Contraband overrides non-arrest statuses, now check for contraband
		if (locate(/obj/item/implant/counterrev) in src.implant)
			var/mob/M = ckey_to_mob_maybe_disconnected(src.last_ckey)
			if (M?.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
				arrestState = ARREST_STATE_REVHEAD
			else if (M?.mind?.get_antagonist(ROLE_REVOLUTIONARY))
				arrestState = ARREST_STATE_LOYAL_IN_PROGRESS
			else
				arrestState = ARREST_STATE_LOYAL
		else
			var/obj/item/card/id/myID = 0
			//mbc : its faster to check if the item in either hand has a registered owner than doing istype on equipped()
			//this does mean that if an ID has no registered owner + carry permit enabled it will blink off as contraband. however i dont care!
			if (src.l_hand?.registered_owner())
				myID = src.l_hand
			else if (src.r_hand?.registered_owner())
				myID = src.r_hand
			if (!myID)
				myID = src.wear_id
			var/has_contraband_permit = 0
			var/has_carry_permit = 0
			if (myID)
				has_contraband_permit = (access_contrabandpermit in myID.access)
				has_carry_permit = (access_carrypermit in myID.access)
			if ((!has_contraband_permit && GET_ATOM_PROPERTY(src,PROP_MOVABLE_VISIBLE_CONTRABAND) > 0) || (!has_carry_permit && GET_ATOM_PROPERTY(src,PROP_MOVABLE_VISIBLE_GUNS) > 0))
				arrestState = ARREST_STATE_CONTRABAND
	src.arrestIcon.icon_state = arrestState

/mob/living/carbon/human/get_genetic_traits()
	return list(5,5,1)

mob/living/carbon/human/has_genetics()
	return TRUE

/mob/living/carbon/human/get_fingertip_color()
	var/hand_color = null
	if (istype(src.gloves))
		var/obj/item/clothing/gloves/gloves = src.gloves
		hand_color = gloves.get_fingertip_color()
		if (!isnull(hand_color))
			return hand_color

	var/obj/item/parts/limb = null
	if(src.hand)
		limb = src.limbs.l_arm
	else
		limb = src.limbs.r_arm
	if (istype(limb))
		hand_color = limb.get_fingertip_color()
		if (!isnull(hand_color))
			return hand_color

	. = ..()
