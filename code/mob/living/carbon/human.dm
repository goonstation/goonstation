// human

/mob/living/carbon/human
	name = "human"
	voice_name = "human"
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"
	static_type_override = /mob/living/carbon/human
	throw_range = 4
	p_class = 1.5 // 1.5 while standing, 2.5 while resting (see update_icon.dm for the place where this change happens)

	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER | USE_CANPASS | IS_FARTABLE
	mob_flags = IGNORE_SHIFT_CLICK_MODIFIER

	var/dump_contents_chance = 20

	var/image/health_mon = null
	var/image/health_implant = null
	var/image/arrestIcon = null

	var/pin = null
	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/under/w_uniform = null
//	var/obj/item/device/radio/w_radio = null
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
	var/image/fire_standing = null
	//var/image/face_standing = null
	var/image/hands_standing = null
	var/list/inhands_standing = list()

	var/image/body_damage_standing = null
	var/image/head_damage_standing = null
	var/image/l_arm_damage_standing = null
	var/image/r_arm_damage_standing = null
	var/image/l_leg_damage_standing = null
	var/image/r_leg_damage_standing = null

	var/image/image_eyes = null
	var/image/image_cust_one = null
	var/image/image_cust_two = null
	var/image/image_cust_three = null

	var/last_b_state = 1.0

	var/chest_cavity_open = 0
	var/obj/item/chest_item = null	// Item stored in chest cavity
	var/chest_item_sewn = 0			// Item is sewn in or is loose

	var/cust_one_state = "short"
	var/cust_two_state = "None"
	var/cust_three_state = "none"

	var/ignore_organs = 0 // set to 1 to basically skip the handle_organs() proc
	var/last_eyes_blinded = 0 // used in handle_blindness_overlays() to determine if a change is needed!

	var/obj/on_chair = 0
	var/simple_examine = 0

	var/last_cluwne_noise = 0 // used in /proc/process_accents() to keep cluwnes from making constant fucking noise

	var/in_throw_mode = 0

	var/yeet_chance = 0.1 //yeet

	var/decomp_stage = 0 // 1 = bloat, 2 = decay, 3 = advanced decay, 4 = skeletonized
	var/next_decomp_time = 0
	var/uses_damage_overlays = 1 //If set to 0, the mob won't receive any damage overlays.

	var/datum/mutantrace/mutantrace = null

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

	max_health = 100

	var/obj/item/trinket = null //Used for spy_theft mode - this is an item that is eligible to have a bounty on it

	//dismemberment stuff
	var/datum/human_limbs/limbs = null

	var/static/image/human_image = image('icons/mob/human.dmi')
	var/static/image/human_head_image = image('icons/mob/human_head.dmi')
	var/static/image/human_untoned_image = image('icons/mob/human.dmi')
	var/static/image/human_decomp_image = image('icons/mob/human_decomp.dmi')
	var/static/image/human_untoned_decomp_image = image('icons/mob/human.dmi')
	var/static/image/undies_image = image('icons/mob/human_underwear.dmi') //, layer = MOB_UNDERWEAR_LAYER)
	var/static/image/bandage_image = image('icons/obj/surgery.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/blood_image = image('icons/effects/blood.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/handcuff_img = image('icons/mob/mob.dmi')
	var/static/image/shield_image = image('icons/mob/mob.dmi', "icon_state" = "shield")
	var/static/image/heart_image = image('icons/mob/human.dmi')
	var/static/image/heart_emagged_image = image('icons/mob/human.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/spider_image = image('icons/mob/human.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/static/image/makeup_image = image('icons/mob/human.dmi') // yeah this is just getting stupider
	var/static/image/juggle_image = image('icons/mob/human.dmi', "layer" = EFFECTS_LAYER_UNDER_1-1)
	var/list/juggling = list()
	var/can_juggle = 0

	// preloaded sounds moved up to /mob/living

	var/list/sound_list_scream = null
	var/list/sound_list_laugh = null
	var/list/sound_list_flap = null

	var/list/pathogens = list()
	var/list/immunities = list()

	var/datum/simsHolder/sims = null

	random_emotes = list("drool", "blink", "yawn", "burp", "twitch", "twitch_v",\
	"cough", "sneeze", "shiver", "shudder", "shake", "hiccup", "sigh", "flinch", "blink_r", "nosepick")

	var/last_show_inv = 0 //used to speedup update_clothing check. its hacky, im sorry
	var/list/showing_inv

	var/icon/flat_icon = null

	can_bleed = 1
	blood_id = "blood"
	blood_volume = 500

/mob/living/carbon/human/New()
	default_static_icon = human_static_base_idiocy_bullshit_crap // FUCK
	. = ..()

	image_eyes = image('icons/mob/human_hair.dmi', layer = MOB_FACE_LAYER)
	image_cust_one = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)
	image_cust_two = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)
	image_cust_three = image('icons/mob/human_hair.dmi', layer = MOB_HAIR_LAYER2)

	var/datum/reagents/R = new/datum/reagents(330)
	reagents = R
	R.my_atom = src

	hud = new(src)
	src.attach_hud(hud)
	src.zone_sel = new(src)
	src.attach_hud(zone_sel)

	if (src.stamina_bar)
		hud.add_object(src.stamina_bar, initial(src.stamina_bar.layer), "EAST-1, NORTH")


	if (global_sims_mode) // IF YOU ARE HERE TO DISABLE SIMS MODE, DO NOT TOUCH THIS. LOOK IN GLOBAL.DM
#ifdef RP_MODE
		sims = new /datum/simsHolder/rp(src)
#else
		sims = new /datum/simsHolder/human(src)
#endif

	health_mon = image('icons/effects/healthgoggles.dmi',src,"100",10)
	health_mon_icons.Add(health_mon)

	health_implant = image('icons/effects/healthgoggles.dmi',src,"100",10)
	health_mon_icons.Add(health_implant)

	arrestIcon = image('icons/effects/sechud.dmi',src,null,10)
	arrestIconsAll.Add(arrestIcon)

	src.organHolder = new(src)

	if (!bioHolder)
		bioHolder = new/datum/bioHolder(src)
	if (!abilityHolder)
		abilityHolder = new /datum/abilityHolder/composite(src)

	if (src.disposed || src.qdeled || !src.bioHolder)
		return

	src.limbs = new /datum/human_limbs(src)

	if (src.organHolder)
		src.organs["chest"] = src.organHolder.chest
		src.organs["head"] = src.organHolder.head
	if (src.limbs)
		src.organs["l_arm"] = src.limbs.l_arm
		src.organs["r_arm"] = src.limbs.r_arm
		src.organs["l_leg"] = src.limbs.l_leg
		src.organs["r_leg"] = src.limbs.r_leg

	src.update_body()
	src.update_face()
	src.UpdateDamageIcon()

	// for pope
	if (microbombs_4_everyone)
		if (isnum(microbombs_4_everyone))
			var/obj/item/implant/microbomb/MB = new (src)
			MB.explosionPower = microbombs_4_everyone
			MB.implanted = 1
			src.implant.Add(MB)
			MB.implanted(src)

/datum/human_limbs
	var/mob/living/carbon/human/holder = null

	var/obj/item/parts/l_arm = null
	var/obj/item/parts/r_arm = null
	var/obj/item/parts/l_leg = null
	var/obj/item/parts/r_leg = null

	var/l_arm_bleed = 0
	var/r_arm_bleed = 0
	var/l_leg_bleed = 0
	var/r_leg_bleed = 0

	New(mob/new_holder)
		..()
		holder = new_holder
		if (holder) create()

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

	proc/create()
		if (!l_arm) l_arm = new /obj/item/parts/human_parts/arm/left(holder)
		if (!r_arm) r_arm = new /obj/item/parts/human_parts/arm/right(holder)
		if (!l_leg) l_leg = new /obj/item/parts/human_parts/leg/left(holder)
		if (!r_leg) r_leg = new /obj/item/parts/human_parts/leg/right(holder)
		SPAWN_DBG(5 SECONDS)
			if (holder && (!l_arm || !r_arm || !l_leg || !r_leg))
				logTheThing("debug", holder, null, "<B>SpyGuy/Limbs:</B> [src] is missing limbs after creation for some reason - recreating.")
				create()
				if (holder)
					// fix for "Cannot execute null.update body()".when mob is deleted too quickly after creation
					holder.update_body()
					if (holder.client)
						holder.next_move = world.time + 7
						//Fix for not being able to move after you got new limbs.

	proc/mend(var/howmany = 4)
		if (!holder)
			return

		if (!l_arm && howmany > 0)
			l_arm = new /obj/item/parts/human_parts/arm/left(holder)
			l_arm.holder = holder
			boutput(holder, "<span class='notice'>Your left arm regrows!</span>")
			l_arm:original_holder = holder
			l_arm:set_skin_tone()
			holder.hud.update_hands()
			howmany--

		if (!r_arm && howmany > 0)
			r_arm = new /obj/item/parts/human_parts/arm/right(holder)
			r_arm.holder = holder
			boutput(holder, "<span class='notice'>Your right arm regrows!</span>")
			r_arm:original_holder = holder
			r_arm:set_skin_tone()
			holder.hud.update_hands()
			howmany--

		if (!l_leg && howmany > 0)
			l_leg = new /obj/item/parts/human_parts/leg/left(holder)
			l_leg.holder = holder
			boutput(holder, "<span class='notice'>Your left leg regrows!</span>")
			l_leg:original_holder = holder
			l_leg:set_skin_tone()
			howmany--

		if (!r_leg && howmany > 0)
			r_leg = new /obj/item/parts/human_parts/leg/right(holder)
			r_leg.holder = holder
			boutput(holder, "<span class='notice'>Your right leg regrows!</span>")
			r_leg:original_holder = holder
			r_leg:set_skin_tone()
			howmany--

		if (holder.client) holder.next_move = world.time + 7 //Fix for not being able to move after you got new limbs.

	proc/reliquarymend(var/howmany = 4)
		if (!holder)
			return

		if (!l_arm && howmany > 0)
			l_arm = new /obj/item/parts/robot_parts/arm/left/reliquary(holder)
			l_arm.holder = holder
			boutput(holder, "<span class='notice'>Your left arm rebuilds itself!</span>")
			holder.hud.update_hands()
			howmany--

		if (!r_arm && howmany > 0)
			r_arm = new /obj/item/parts/robot_parts/arm/right/reliquary(holder)
			r_arm.holder = holder
			boutput(holder, "<span class='notice'>Your right arm rebuilds itself!</span>")
			holder.hud.update_hands()
			howmany--

		if (!l_leg && howmany > 0)
			l_leg = new /obj/item/parts/robot_parts/leg/left/reliquary(holder)
			l_leg.holder = holder
			boutput(holder, "<span class='notice'>Your left leg rebuilds itself!</span>")
			howmany--

		if (!r_leg && howmany > 0)
			r_leg = new /obj/item/parts/robot_parts/leg/right/reliquary(holder)
			r_leg.holder = holder
			boutput(holder, "<span class='notice'>Your right rebuilds itself!</span>")
			howmany--

		if (holder.client) holder.next_move = world.time + 7 //Fix for not being able to move after you got new limbs.
		holder.update_body()

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
			if (limbs_to_sever.len)
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
		if(!limb) return
		switch(limb)
			if("l_arm")
				. = l_arm
			if("r_arm")
				. = r_arm
			if("l_leg")
				. = l_leg
			if("r_leg")
				. = r_leg

	proc/replace_with(var/target, var/new_type, var/mob/user, var/show_message = 1)
		if (!target || !new_type || !src.holder)
			return 0
		if (istext(target) && ispath(new_type))
			if (target == "both_arms" || target == "l_arm")
				if (ispath(new_type, /obj/item/parts/human_parts/arm) || ispath(new_type, /obj/item/parts/robot_parts/arm))
					if (src.l_arm)
						src.l_arm.delete()
					src.l_arm = new new_type(src.holder)
				else // need to make an item arm
					if (src.l_arm)
						src.l_arm.delete()
					src.l_arm = new /obj/item/parts/human_parts/arm/left/item(src.holder, new new_type(src.holder))
				src.holder.organs["l_arm"] = src.l_arm
				if (show_message)
					src.holder.show_message("<span class='notice'><b>Your left arm [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.l_arm]!</b></span>")
				if (user)
					logTheThing("admin", user, src.holder, "replaced %target%'s left arm with [new_type]")
				. ++

			if (target == "both_arms" || target == "r_arm")
				if (ispath(new_type, /obj/item/parts/human_parts/arm) || ispath(new_type, /obj/item/parts/robot_parts/arm))
					if (src.r_arm)
						src.r_arm.delete()
					src.r_arm = new new_type(src.holder)
				else // need to make an item arm
					if (src.r_arm)
						src.r_arm.delete()
					src.r_arm = new /obj/item/parts/human_parts/arm/right/item(src.holder, new new_type(src.holder))
				src.holder.organs["r_arm"] = src.r_arm
				if (show_message)
					src.holder.show_message("<span class='notice'><b>Your right arm [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.r_arm]!</b></span>")
				if (user)
					logTheThing("admin", user, src.holder, "replaced %target%'s right arm with [new_type]")
				. ++

			if (target == "both_legs" || target == "l_leg")
				if (ispath(new_type, /obj/item/parts/human_parts/leg) || ispath(new_type, /obj/item/parts/robot_parts/leg))
					qdel(src.l_leg)
					src.l_leg = new new_type(src.holder)
					src.holder.organs["l_leg"] = src.l_leg
					if (show_message)
						src.holder.show_message("<span class='notice'><b>Your left leg [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.l_leg]!</b></span>")
					if (user)
						logTheThing("admin", user, src.holder, "replaced %target%'s left leg with [new_type]")
					. ++

			if (target == "both_legs" || target == "r_leg")
				if (ispath(new_type, /obj/item/parts/human_parts/leg) || ispath(new_type, /obj/item/parts/robot_parts/leg))
					qdel(src.r_leg)
					src.r_leg = new new_type(src.holder)
					src.holder.organs["r_leg"] = src.r_leg
					if (show_message)
						src.holder.show_message("<span class='notice'><b>Your right leg [pick("magically ", "weirdly ", "suddenly ", "grodily ", "")]becomes [src.r_leg]!</b></span>")
					if (user)
						logTheThing("admin", user, src.holder, "replaced %target%'s right leg with [new_type]")
					. ++
			if (.)
				src.holder.set_body_icon_dirty()
			return
		return 0

/mob/living/carbon/human/proc/is_vampire()
	return get_ability_holder(/datum/abilityHolder/vampire)

/mob/living/carbon/human/proc/is_vampiric_zombie()
	return get_ability_holder(/datum/abilityHolder/vampiric_zombie)

/mob/living/carbon/human/disposing()
	for(var/obj/item/I in src)
		if(I.equipped_in_slot != slot_w_uniform)
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


	for(var/obj/item/implant/imp in src.implant)
		imp.dispose()
	src.implant = null

	for(var/client/C)
		C.images -= list(health_mon, health_implant, arrestIcon)
	if(health_mon)
		health_mon.dispose()
		health_mon_icons -= health_mon
	if(health_implant)
		health_implant.dispose()
		health_mon_icons -= health_implant
	if(arrestIcon)
		arrestIcon.dispose()
		arrestIconsAll -= arrestIcon

	src.chest_item = null

	src.organs.len = 0
	src.organs = null

	if (mutantrace)
		mutantrace.dispose()
		mutantrace = null
	target = null
	if (limbs)
		limbs.dispose()
		limbs = null
	if (organHolder)
		organHolder.dispose()
		organHolder = null

	showing_inv = null
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

	for (var/uid in src.pathogens)
		var/datum/pathogen/P = src.pathogens[uid]
		P.ondeath()

#ifdef DATALOGGER
	game_stats.Increment("deaths")
#endif

	//The unkillable man just respawns nearby! Oh no!
	if (src.unkillable || src.spell_soulguard)
		if (src.unkillable && src.mind.dnr) //Unless they have dnr set in which case rip for good
			logTheThing("combat", src, null, "was about to be respawned (Unkillable) but had DNR set.")
			if (!gibbed)
				src.gib()
			boutput(src, "<span class='alert'>The shield hisses and buzzes grumpily! It's almost as if you have some sort of option set that prevents you from coming back to life. Fancy that.</span>")
			var/obj/item/unkill_shield/U = new /obj/item/unkill_shield
			U.set_loc(src.loc)
		else
			logTheThing("combat", src, null, "respawns ([src.spell_soulguard ? "Soul Guard" : "Unkillable"])")
			src.unkillable_respawn()

	if(src.traitHolder && src.traitHolder.hasTrait("soggy"))
		src.unequip_all()
		src.gib()
		return

	//Zombies just rise again (after a delay)! Oh my!
	if (src.mutantrace && src.mutantrace.onDeath())
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
				boutput(spider, __red("Your telepathic link to your master has been destroyed!"))
				spider.hivemind_owner = 0
			for (var/mob/dead/target_observer/hivemind_observer/obs in C.hivemind)
				boutput(obs, __red("Your telepathic link to your master has been destroyed!"))
				obs.boot()
			if (C.hivemind.len > 0)
				boutput(src, "Contact with the hivemind has been lost.")
			C.hivemind = list()

		else
		//Changelings' heads pop off and crawl away - but only if they're not gibbed and have some spare DNA points. Oy vey!
			SPAWN_DBG(0)
				var/datum/mind/M = src.mind
				emote("deathgasp")
				src.visible_message("<span class='alert'><B>[src]</B> begins to grow another head!</span>")
				src.show_text("<b>We begin to grow a headspider...</b>", "blue")
				sleep(20 SECONDS)
				if(!M || M.disposed)
					return
				if (M && M.current)
					M.current.show_text("<b>We released a headspider, using up some of our DNA reserves.</b>", "blue")
				src.visible_message("<span class='alert'><B>[src]</B> grows a head, which sprouts legs and wanders off, looking for food!</span>")
				//make a headspider, have it crawl to find a host, give the host the disease, hand control to the player again afterwards
				var/mob/living/critter/changeling/headspider/HS = new /mob/living/critter/changeling/headspider(get_turf(src))
				C.points = max(0, C.points - 10) // This stuff isn't free, you know.
				M.transfer_to(HS)
				HS.owner = M //In case we ghosted ourselves then the body won't hold the mind. Bad times.
				HS.changeling = C
				remove_ability_holder(/datum/abilityHolder/changeling/)

				if(src.client)
					src.ghostize()
					boutput(src, "Something went wrong, and we couldnt transfer you into a handspider! Please adminhelp this.")

				logTheThing("combat", src, null, "became a headspider at [log_loc(src)].")


				HS.changeling.transferOwnership(HS)
				HS.changeling.owner = HS
				HS.changeling.reassign_hivemind_target_mob()

				//HS.process() //A little kickstart to get you out into the big world (and some chump), li'l guy! O7

				return
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			NORMAL BUSINESS
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	emote("deathgasp") //let the world KNOW WE ARE DEAD

	if (!src.mutantrace || inafterlife(src)) // wow fucking racist
		modify_christmas_cheer(-7)

	src.canmove = 0
	src.lying = 1
	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.set_clothing_icon_dirty()
	src.hand = h

	if (istype(src.wear_suit, /obj/item/clothing/suit/armor/suicide_bomb))
		var/obj/item/clothing/suit/armor/suicide_bomb/A = src.wear_suit
		A.trigger(src)

	src.next_decomp_time = world.time + rand(480,900)*10

	if (src.mind) // I think this is kinda important (Convair880).
		src.mind.register_death()
		if (src.mind.special_role == "mindslave")
			remove_mindslave_status(src, "mslave", "death")
		else if (src.mind.special_role == "vampthrall")
			remove_mindslave_status(src, "vthrall", "death")
		else if (src.mind.master)
			remove_mindslave_status(src, "otherslave", "death")

	logTheThing("combat", src, null, "dies [log_health(src)] at [log_loc(src)].")
	//src.icon_state = "dead"

	if (!src.suiciding)
		if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
			src.unlock_medal("HUMANOID MUST NOT ESCAPE", 1)

		if (src.hasStatus("handcuffed"))
			src.unlock_medal("Fell down the stairs", 1)

		if (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/R = ticker.mode
			if (src.mind && (src.mind in R.revolutionaries)) // maybe add a check to see if they've been de-revved?
				src.unlock_medal("Expendable", 1)

		if (src.getStatusDuration("burning") > 400)
			src.unlock_medal("Black and Blue", 1)
		JOB_XP(src, "Clown", 10)

	ticker.mode.check_win()

#ifdef RESTART_WHEN_ALL_DEAD
	var/cancel
	for (var/client/C)
		if (!C.mob) continue
		if (!C.mob.stat)
			cancel = 1
			break

	if (!cancel && !abandon_allowed)
		SPAWN_DBG (50)
			cancel = 0
			for (var/client/C)
				if (!C.mob) continue
				if (!C.mob.stat)
					cancel = 1
					break

			if (!cancel && !abandon_allowed)
				boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")

				SPAWN_DBG (300)
					logTheThing("diary", null, null, "Rebooting because of no live players", "game")
					Reboot_server()
#endif
	return ..(gibbed)

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
		boutput(src, "<span class='notice'>Your Soulguard enchantment activates and saves you...</span>")
		reappear_turf = pick(wizardstart)

	////////////////Set up the new body./////////////////

	var/mob/living/carbon/human/newbody = new()
	newbody.set_loc(reappear_turf)

	newbody.real_name = src.real_name

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

	if (src.bioHolder)
		newbody.bioHolder.CopyOther(src.bioHolder)
		if (!antag_removal && src.spell_soulguard)
			newbody.bioHolder.RemoveAllEffects()

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
		src.spell_soulguard = 0 // clear this as well
		src = null //Detach this, what if we get deleted before the animation ends??
		SPAWN_DBG(0.7 SECONDS) //Length of animation.
			newbody.set_loc(animation.loc)
			qdel(animation)
	else
		src.unkillable = 0
		src.spell_soulguard = 0
		src.invisibility = 20
		SPAWN_DBG(2.2 SECONDS) // Has to at least match the organ/limb replacement stuff (Convair880).
			if (src) qdel(src)

	return


/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if (src.client)
			stat("Time Until Payday:", wagesystem.get_banking_timeleft())

		stat(null, " ")
		if (src.mind && src.mind.stealth_objective)
			if (src.mind.objectives && istype(src.mind.objectives, /list))
				for (var/datum/objective/O in src.mind.objectives)
					if (istype(O, /datum/objective/specialist/stealth))
						stat("Stealth Points:", "[O:score] / [O:min_score]")

		if (src.internal)
			if (!src.internal.air_contents)
				qdel(src.internal)
			else
				stat("Internal Atmosphere Info:", src.internal.name)
				stat("Tank Pressure:", MIXTURE_PRESSURE(src.internal.air_contents))
				stat("Distribution Pressure:", src.internal.distribute_pressure)

/mob/living/carbon/human/hotkey(name)
	switch (name)
		if ("help")
			src.a_intent = INTENT_HELP
			hud.update_intent()
		if ("disarm")
			src.a_intent = INTENT_DISARM
			hud.update_intent()
		if ("grab")
			src.a_intent = INTENT_GRAB
			hud.update_intent()
		if ("harm")
			src.a_intent = INTENT_HARM
			hud.update_intent()
		if ("drop")
			src.drop_item()
		if ("swaphand")
			src.swap_hand()
		if ("attackself")
			var/obj/item/W = src.equipped()
			if (W)
				src.click(W, list())
		if ("equip")
			src.hud.clicked("invtoggle", list()) // this is incredibly dumb, it's also just as dumb as what was here previously
		if ("togglethrow")
			src.toggle_throw_mode()
		if ("walk")
			if (src.m_intent == "run")
				src.m_intent = "walk"
			else
				src.m_intent = "run"
			out(src, "You are now [src.m_intent == "walk" ? "walking" : "running"].")
			hud.update_mintent()
		if ("rest")
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
	hud.update_throwing()

/mob/living/carbon/human/proc/throw_mode_on()
	src.in_throw_mode = 1
	src.update_cursor()
	hud.update_throwing()

/mob/living/carbon/human/proc/throw_item(atom/target, list/params)
	var/turf/thrown_from = get_turf(src)
	src.throw_mode_off()
	if (usr.stat)
		return
#if ASS_JAM //no throwing while in timestop
	if (paused)
		return
#endif

	//MBC : removing this because it felt bad and it wasn't *too* exploitable. still does click delay on the end of a throw anyway.
	//if (usr.next_click > world.time)
	//	return

	var/obj/item/I = src.equipped()

	if (!I || !isitem(I) || I.cant_drop) return

	if (istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		I = G.handle_throw(src, target)
		if (!I) return

	u_equip(I)

	I.set_loc(src.loc)

	if (get_dist(src, target) > 0)
		src.dir = get_dir(src, target)

	//actually throw it!
	if (I)
		attack_twitch(src)
		I.layer = initial(I.layer)
		var/yeet = 0 // what the fuck am I doing

		if(src.mind.karma >= 50) //karma karma karma karma karma khamelion
			yeet_chance = 1
		if(src.mind.karma < 0) //you come and go, you come and go.
			yeet_chance = 0
		if(src.mind.karma < 50 && src.mind.karma >= 0)
			yeet_chance = 0.1

		if(prob(yeet_chance))
			src.visible_message("<span class='alert'>[src] yeets [I].</span>")
			src.say("YEET")
			yeet = 1 // I hate this
		else
			src.visible_message("<span class='alert'>[src] throws [I].</span>")
		if (iscarbon(I))
			var/mob/living/carbon/C = I
			logTheThing("combat", src, C, "throws %target% at [log_loc(src)].")
			if ( ishuman(C) && !C.getStatusDuration("weakened"))
				C.changeStatus("weakened", 1 SECOND)
		else
			// Added log_reagents() call for drinking glasses. Also the location (Convair880).
			logTheThing("combat", src, null, "throws [I] [I.is_open_container() ? "[log_reagents(I)]" : ""] at [log_loc(src)].")
		if (istype(src.loc, /turf/space) || src.no_gravity) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
		if ((istype(I.loc, /turf/space) || I.no_gravity)  && ismob(I))
			var/mob/M = I
			M.inertia_dir = get_dir(src,target)

		playsound(src.loc, 'sound/effects/throw.ogg', 40, 1, 0.1)

		SPAWN_DBG(I.throw_at(target, I.throw_range, I.throw_speed, params, thrown_from))
			if(yeet)
				new/obj/effect/supplyexplosion(I.loc)
#if ASS_JAM
				explosion_new(I,get_turf(I),20,1)
#else
				playsound(I.loc, 'sound/effects/ExplosionFirey.ogg', 100, 1)
#endif
				for(var/mob/M in view(7, I.loc))
					shake_camera(M, 20, 1)

		if (mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in grabbed_by)
				G.shoot()

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
						src.a_intent = INTENT_DISARM
						.=..()
						src.a_intent = INTENT_DISARM
				/*else if (params["middle"])
					params["middle"] = 0
					params["left"] = 1 //hacky again :)
					var/prev = src.a_intent
					src.a_intent = INTENT_GRAB
					.=..()
					src.a_intent = prev
					return*/
				else
					src.a_intent = INTENT_HARM
					.=..()
					src.a_intent = INTENT_DISARM
				return
			if (src.client.check_key(KEY_PULL))
				if (params["left"] && ismob(target))
					params["ctrl"] = 0 //hacky wows :)
					var/prev = src.a_intent
					src.a_intent = INTENT_GRAB
					.=..()
					src.a_intent = prev
					return
				else
					src.a_intent = INTENT_HARM
					.=..()
					src.a_intent = INTENT_DISARM
				return
		else
			if (src.client.check_key(KEY_THROW) || src.in_throw_mode)
				for (var/obj/item/cloaking_device/I in src)
					if (I.active)
						I.deactivate(src)
						src.visible_message("<span class='notice'><b>[src]'s cloak is disrupted!</b></span>")
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
				src.a_intent = INTENT_DISARM
				src.hud.update_intent()
				return
			else if (src.client.check_key(KEY_PULL))
				src.set_cursor('icons/cursors/combat_grab.dmi')
				src.client.show_popup_menus = 0
				src.a_intent = INTENT_GRAB
				src.hud.update_intent()
				return
			else if (src.client.show_popup_menus == 0)
				src.client.show_popup_menus = 1
				src.a_intent = INTENT_HELP
				src.hud.update_intent()
		else
			if (src.client.check_key(KEY_THROW) || src.in_throw_mode)
				src.set_cursor('icons/cursors/throw.dmi')
				return

	return ..()

/mob/living/carbon/human/meteorhit(O as obj)
	if (isdead(src)) src.gib()
	src.visible_message("<span class='alert'>[src] has been hit by [O]!</span>")
	if (src.nodamage) return
	if (src.health > 0)
		var/dam_zone = pick("chest", "head")
		if (istype(src.organs[dam_zone], /obj/item/organ))
			var/obj/item/organ/temp = src.organs[dam_zone]

			var/reduction = 0
			if (src.energy_shield) reduction = src.energy_shield.protect()
			if (src.spellshield)
				reduction = 30
				boutput(src, "<span class='alert'><b>Your Spell Shield absorbs some damage!</b></span>")

			temp.take_damage((istype(O, /obj/newmeteor/small) ? max(15-reduction,0) : max(25-reduction,0)), max(20-reduction,0))
			src.UpdateDamageIcon()
	else if (prob(20))
		src.gib()

	return

/mob/living/carbon/human/deliver_move_trigger(ev)
	for (var/obj/O in contents)
		if (O.move_triggered)
			O.move_trigger(src, ev)
	for (var/atom in statusEffects)
		var/datum/statusEffect/S = atom
		if (S && S.move_triggered)
			S.move_trigger(src, ev)


/mob/living/carbon/human/UpdateName()
	var/see_face = 1
	if (istype(src.wear_mask) && !src.wear_mask.see_face)
		see_face = 0
	else if (istype(src.head) && !src.head.see_face)
		see_face = 0
	else if (istype(src.wear_suit) && !src.wear_suit.see_face)
		see_face = 0
	if (!see_face)
		if (istype(src.wear_id) && src.wear_id:registered)
			src.name = "[src.name_prefix(null, 1)][src.wear_id:registered][src.name_suffix(null, 1)]"
		else
			src.unlock_medal("Suspicious Character", 1)
			src.name = "[src.name_prefix(null, 1)]Unknown[src.name_suffix(null, 1)]"
	else
		if (istype(src.wear_id) && src.wear_id:registered != src.real_name)
			if (src.decomp_stage > 2)
				src.name = "[src.name_prefix(null, 1)]Unknown (as [src.wear_id:registered])[src.name_suffix(null, 1)]"
			else
				src.name = "[src.name_prefix(null, 1)][src.real_name] (as [src.wear_id:registered])[src.name_suffix(null, 1)]"
		else
			if (src.decomp_stage > 2)
				src.name = "[src.name_prefix(null, 1)]Unknown[src.wear_id ? " (as [src.wear_id:registered])" : ""][src.name_suffix(null, 1)]"
			else
				src.name = "[src.name_prefix(null, 1)][src.real_name][src.name_suffix(null, 1)]"

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
	if (!(I in src.contents))
		return null

	//wanted the following to be a switch case but those expect constant expressions

	if (src.w_uniform == I)
		return slot_w_uniform
	if (src.wear_id == I)
		return slot_wear_id
	if (src.gloves == I)
		return slot_gloves
	if (src.shoes == I)
		return slot_shoes
	if (src.wear_suit == I)
		return slot_wear_suit
	if (src.back == I)
		return slot_back
	if (src.glasses == I)
		return slot_glasses
	if (src.ears == I)
		return ears
	if (src.wear_mask == I)
		return slot_wear_mask
	if (src.head == I)
		return slot_head
	if (src.belt == I)
		return slot_belt
	if (src.l_store == I)
		return slot_l_store
	if (src.r_store == I)
		return slot_r_store
	if(src.l_hand == I)
		return slot_l_hand
	if(src.r_hand == I)
		return slot_r_hand
	return null

/mob/living/carbon/human/is_in_hands(var/obj/O)
	if (l_hand == O || r_hand == O)
		return 1
	return 0

/mob/living/carbon/human/restrained()
	if (src.hasStatus("handcuffed"))
		return 1
	if (src.wear_suit && src.wear_suit.restrain_wearer)
		return 1
	if (src.limbs && (src.hand ? !src.limbs.l_arm : !src.limbs.r_arm))
		return 1
#if ASS_JAM //no fucking with inventory in timestop
	if (paused)
		return 1
#endif
	/*if (src.limbs && (src.hand ? !src.limbs.l_arm:can_hold_items : !src.limbs.r_arm:can_hold_items)) // this was fucking stupid and broke item limbs, I mean really, how do you restrain someone whos arm is a goddamn CHAINSAW
		return 1*/

/mob/living/carbon/human/set_pulling(atom/movable/A)
	. = ..()
	hud.update_pulling()

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.add_dialog(user)
	var/dat = {"
	<B><HR><FONT size=3>[src.name]</FONT></B>
	<BR><HR>
	<B>Head:</B> <A href='?src=\ref[src];varname=head;slot=[src.slot_head];item=head'>[(src.head ? src.head : "Nothing")]</A>
	<BR><B>Mask:</B> <A href='?src=\ref[src];varname=wear_mask;slot=[src.slot_wear_mask];item=mask'>[(src.wear_mask ? src.wear_mask : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];varname=glasses;slot=[src.slot_glasses];item=eyes'>[(src.glasses ? src.glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];varname=ears;slot=[src.slot_ears];item=ears'>[(src.ears ? src.ears : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];varname=l_hand;slot=[src.slot_l_hand];item=l_hand'>[(src.l_hand ? src.l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];varname=r_hand;slot=[src.slot_r_hand];item=r_hand'>[(src.r_hand ? src.r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];varname=gloves;slot=[src.slot_gloves];item=gloves'>[(src.gloves ? src.gloves : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];varname=shoes;slot=[src.slot_shoes];item=shoes'>[(src.shoes ? src.shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];varname=belt;slot=[src.slot_belt];item=belt'>[(src.belt ? src.belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];varname=w_uniform;slot=[src.slot_w_uniform];item=uniform'>[(src.w_uniform ? src.w_uniform : "Nothing")]</A>
	<BR><B>Outer Suit:</B> <A href='?src=\ref[src];varname=wear_suit;slot=[src.slot_wear_suit];item=suit'>[(src.wear_suit ? src.wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];varname=back;slot=[src.slot_back];item=back'>[(src.back ? src.back : "Nothing")]</A> [((istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal;slot=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];varname=wear_id;slot=[src.slot_wear_id];item=id'>[(src.wear_id ? src.wear_id : "Nothing")]</A>
	<BR><B>Left Pocket:</B> <A href='?src=\ref[src];varname=l_store;slot=[src.slot_l_store];item=pockets'>[(src.l_store ? "Something" : "Nothing")]</A>
	<BR><B>Right Pocket:</B> <A href='?src=\ref[src];varname=r_store;slot=[src.slot_r_store];item=pockets'>[(src.r_store ? "Something" : "Nothing")]</A>
	<BR>[(src.hasStatus("handcuffed") ? text("<A href='?src=\ref[src];slot=handcuff;item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff;slot=handcuff'>Not Handcuffed</A>"))]
	<BR>[(src.internal ? text("<A href='?src=\ref[src];slot=internal;item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?action=mach_close&window=mob[src.name]'>Close</A>
	<BR>"}
	user.Browse(dat, text("window=mob[src.name];size=340x480"))
	onclose(user, "mob[src.name]")
	src.last_show_inv = world.time
	return
	//	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>

/mob/living/carbon/human/MouseDrop(mob/M as mob)
	..()
	if (M != usr) return
	if (usr == src) return
	if (get_dist(usr,src) > 1) return
	if (!M.can_strip(src)) return
	if (LinkBlocked(usr.loc,src.loc)) return
	if (isAI(usr) || isAI(src)) return
	if (isghostcritter(usr) && !isdead(src)) return
	src.show_inv(usr)

/mob/living/carbon/human/verb/fuck()
	set hidden = 1
	alert("Go play HellMOO if you wanna do that.")

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if (istype(MB))
		MB.RunOver(src)

/mob/living/carbon/human/Topic(href, href_list)
	if (istype(usr.loc,/obj/dummy/spell_invis/) || isghostdrone(usr))
		return
	var/canmove_or_pinning = usr.canmove
	for (var/obj/item/grab/G in usr.equipped_list(check_for_magtractor = 0))
		if (G.state == GRAB_PIN)
			canmove_or_pinning = 1

	if (!usr.stat && canmove_or_pinning && !usr.restrained() && in_range(src, usr) && ticker && usr.can_strip(src))
		if (href_list["slot"] == "handcuff")
			actions.start(new/datum/action/bar/icon/handcuffRemovalOther(src), usr)
		else if (href_list["slot"] == "internal")
			actions.start(new/datum/action/bar/icon/internalsOther(src), usr)
		else if (href_list["item"])
			actions.start(new/datum/action/bar/icon/otherItem(usr, src, usr.equipped(), text2num(href_list["slot"]), 0, href_list["item"] == "pockets") , usr)

/* ----------------------------------------------------------------------------------------------------------------- */

/mob/living/carbon/human/Login()
	..()

	update_clothing()

	if (ai_active)
		ai_set_active(0)
	if (src.organHolder && src.organHolder.brain && src.mind)
		src.organHolder.brain.setOwner(src.mind)

	/*
	if (src.ckey == "wonkmin") //If you mention this i will shank you.
		SPAWN_DBG(15 SECONDS)
			src.make_critter(/mob/living/critter/small_animal/bird/owl/large/hooter)
	*/
	return

/mob/living/carbon/human/Logout()
	..()
	if (!ai_active && is_npc)
		ai_set_active(1)
	return

/mob/living/carbon/human/get_heard_name()
	var/alt_name = ""
	if (src.name != src.real_name)
		if (src.wear_id && src.wear_id:registered && src.wear_id:registered != src.real_name)
			alt_name = " (as [src.wear_id:registered])"
		else if (!src.wear_id)
			alt_name = " (as Unknown)"

	var/rendered
	if (src.is_npc)
		rendered = "<span class='name'>"
	else
		rendered = "<span class='name' data-ctx='\ref[src.mind]'>"
	if (src.wear_mask && src.wear_mask.vchange)//(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		if (src.wear_id)
			rendered += "[src.wear_id:registered]</span>"
		else
			rendered += "Unknown</span>"
	else
		rendered += "[src.real_name]</span>[alt_name]"

	return rendered

/mob/living/carbon/human/say(var/message, var/ignore_stamina_winded = 0)
	var/original_language = src.say_language
	if (mutantrace && mutantrace.override_language)
		say_language = mutantrace.override_language

	message = copytext(message, 1, MAX_MESSAGE_LEN)

	if (src.fakedead)
		var/the_verb = pick("wails","moans","laments")
		boutput(src, "<span class='game deadsay'><span class='prefix'>DEAD:</span> [src.get_heard_name()] [the_verb], <span class='message'>\"[message]\"</span></span>")
		src.say_language = original_language
		return

	if (dd_hasprefix(message, "*") || isdead(src))
		..(message)
		src.say_language = original_language
		return

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message("<span class='alert'>[src] makes some [pick("eldritch", "eerie", "otherworldly", "netherly", "spooky", "demonic", "haunting")] noises!</span>")
		src.say_language = original_language
		return

	if (src.bioHolder.HasEffect("food_bad_breath"))
		for (var/mob/living/L in view(2,src))
			if (L == src) continue //You were able to vomit from your own breath. Maybe a good idea?
			if (prob(20))
				boutput(L, "<span class='alert'>Good lord, [src]'s breath smells bad!</span>")
				L.vomit()


	if (src.stamina < STAMINA_WINDED_SPEAK_MIN && !ignore_stamina_winded)
		//src.emote(pick("gasp", "choke", "cough"))
		//boutput(src, "<span class='alert'>You are too exhausted to speak.</span>")
		whisper(message)
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

	for (var/uid in src.pathogens)
		var/datum/pathogen/P = src.pathogens[uid]
		message = P.onsay(message)

	..(message)

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
	if (src.mutantrace)
		if (src.mutantrace.voice_message)
			src.voice_name = src.mutantrace.voice_name
			src.voice_message = src.mutantrace.voice_message
		if (text == "" || !text)
			return src.mutantrace.say_verb()
		return "[src.mutantrace.say_verb()], \"[text]\""
	else
		src.voice_name = initial(src.voice_name)
		src.voice_message = initial(src.voice_message)

	var/special = 0
	if (src.stamina < STAMINA_WINDED_SPEAK_MIN)
		special = "gasp_whisper"
	if (src.oxyloss > 10)
		special = "gasp_whisper"

	return ..(text,special)

//Lallander was here
/mob/living/carbon/human/whisper(message as text)
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

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	logTheThing("diary", src, null, "(WHISPER): [message]", "whisper")
	logTheThing("whisper", src, null, "SAY: [message] (Whispered)")

	if (src.client && !src.client.holder && url_regex && url_regex.Find(message))
		boutput(src, "<span class='notice'><b>Web/BYOND links are not allowed in ingame chat.</b></span>")
		boutput(src, "<span class='alert'>&emsp;<b>\"[message]</b>\"</span>")
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
		boutput(src, "<span class='alert'>You seem to be unable to speak.</span>")
		return

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		boutput(src, "<span class='alert'>Your muzzle prevents you from speaking.</span>")
		return

	var/italics = 1
	var/message_range = 1
	var/forced_language = null
	forced_language = get_special_language(secure_headset_mode)

	message = process_accents(src,message)
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
			rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers something.</span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"
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
	for (var/mob/M in eavesdropping)
		if (M.say_understands(src, lang_id))
			var/message_c = stars(message)

			if (!ishuman(src))
				rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
			else
				if (src.wear_mask && src.wear_mask.vchange)//(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
					if (src.wear_id)
						rendered = "<span class='game say'><span class='name'>[src.wear_id:registered]</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
					else
						rendered = "<span class='game say'><span class='name'>Unknown</span> whispers, <span class='message'>\"[message_c]\"</span></span>"
				else
					rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] whispers, <span class='message'>\"[message_c]\"</span></span>"

		else
			rendered = "<span class='game say'><span class='name'>[src.voice_name]</span> whispers something.</span>"

		M.show_message(rendered, 2)

	if (italics)
		message = "<i>[message]</i>"

	if (!ishuman(src))
		rendered = "<span class='game say'><span class='name'>[src.name]</span> whispers, <span class='message'>[message]</span></span>"
	else
		if (src.wear_mask && src.wear_mask.vchange)//(istype(src:wear_mask, /obj/item/clothing/mask/gas/voice))
			if (src.wear_id)
				rendered = "<span class='game say'><span class='name'>[src.wear_id:registered]</span> whispers, <span class='message'>[message]</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>Unknown</span> whispers, <span class='message'>[message]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[src.real_name]</span>[alt_name] whispers, <span class='message'>[message]</span></span>"

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1 && !(M in heard_a) && !istype(M, /mob/dead/target_observer))
			M.show_message(rendered, 2)

	//mbc FUCK why doesn't this have any parent to call
	speech_bubble.icon_state = "speech"
	UpdateOverlays(speech_bubble, "speech_bubble")
	SPAWN_DBG(1.5 SECONDS)
		UpdateOverlays(null, "speech_bubble")

/mob/living/carbon/human/var/const
	slot_back = 1
	slot_wear_mask = 2
	slot_l_hand = 4
	slot_r_hand = 5
	slot_belt = 6
	slot_wear_id = 7
	slot_ears = 8
	slot_glasses = 9
	slot_gloves = 10
	slot_head = 11
	slot_shoes = 12
	slot_wear_suit = 13
	slot_w_uniform = 14
	slot_l_store = 15
	slot_r_store = 16
//	slot_w_radio = 17
	slot_in_backpack = 18
	slot_in_belt = 19

/mob/living/carbon/human/u_equip(obj/item/W)
	if (!W)
		return

	hud.remove_item(W) // eh

	if (isitem(W))
		if (W.two_handed) //This runtime is caused by grabbing a human.
			hud.set_visible(hud.lhand, 1)
			hud.set_visible(hud.rhand, 1)
			hud.set_visible(hud.twohandl, 0)
			hud.set_visible(hud.twohandr, 0)

	if (W == src.wear_suit)
		src.wear_suit = null
		W.unequipped(src)
		src.update_clothing()
		src.update_hair_layer()
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
		src.update_clothing()
		src.update_hair_layer()
	else if (W == src.ears)
		W.unequipped(src)
		src.ears = null
		src.update_clothing()
	else if (W == src.shoes)
		W.unequipped(src)
		src.shoes = null
		src.update_clothing()
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
		src.update_clothing()

	if (W && W == src.r_hand)
		src.r_hand = null
		W.dropped(src)
		src.update_inhands()
	if (W && W == src.l_hand)
		src.l_hand = null
		W.dropped(src)
		src.update_inhands()

/mob/living/carbon/human/update_equipped_modifiers() // A bruteforce approach, for things like the garrote that like to change their modifier while equipped
	var/datum/movement_modifier/equipment/equipment_proxy = locate() in src.movement_modifiers
	if (!equipment_proxy)
		equipment_proxy = new
		APPLY_MOVEMENT_MODIFIER(src, equipment_proxy, /obj/item)

	// reset the modifiers to defaults
	equipment_proxy.additive_slowdown = 0
	equipment_proxy.aquatic_movement = 0
	equipment_proxy.space_movement = 0

	for (var/obj/item/I in src.get_equipped_items())
		equipment_proxy.additive_slowdown += I.getProperty("movespeed")
		var/fluidmove = I.getProperty("negate_fluid_speed_penalty")
		if (fluidmove)
			equipment_proxy.additive_slowdown += fluidmove // compatibility hack for old code treating space & fluid movement capability as a slowdown
			equipment_proxy.aquatic_movement += fluidmove
		var/spacemove = I.getProperty("space_movespeed")
		if (spacemove)
			equipment_proxy.additive_slowdown += spacemove // compatibility hack for old code treating space & fluid movement capability as a slowdown
			equipment_proxy.space_movement += spacemove


/mob/living/carbon/human/updateTwoHanded(var/obj/item/I, var/twoHanded = 1)
	if(!(I in src) || (src.l_hand != I && src.r_hand != I)) return 0
	I.two_handed = twoHanded

	if(I.two_handed)
		if(src.l_hand == I)
			if(src.r_hand != null)
				I.two_handed = 0
				return 0
		else if(src.r_hand == I)
			if(src.l_hand != null)
				I.two_handed = 0
				return 0
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
	return 1

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
		if (src.r_hand || src.l_hand)
			return 0
		if (src.limbs && (!src.limbs.r_arm || istype(src.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
			return 0
		if (src.limbs && (!src.limbs.l_arm || istype(src.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)))
			return 0
		src.l_hand = I
		src.r_hand = I
		I.pickup(src)
		I.add_fingerprint(src)
		I.set_loc(src)
		src.update_inhands()
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
					I.add_fingerprint(src)
					I.set_loc(src)
					src.update_inhands()
					hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["lhand"])
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
					hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["rhand"])
					return 1
				else
					return 0

/mob/living/carbon/human/proc/get_slot(slot)
	switch(slot)
		if (slot_back)
			return src.back
		if (slot_wear_mask)
			return src.wear_mask
		if (slot_l_hand)
			return src.l_hand
		if (slot_r_hand)
			return src.r_hand
		if (slot_belt)
			return src.belt
		if (slot_wear_id)
			return src.wear_id
		if (slot_ears)
			return src.ears
		if (slot_glasses)
			return src.glasses
		if (slot_gloves)
			return src.gloves
		if (slot_head)
			return src.head
		if (slot_shoes)
			return src.shoes
		if (slot_wear_suit)
			return src.wear_suit
		if (slot_w_uniform)
			return src.w_uniform
		if (slot_l_store)
			return src.l_store
		if (slot_r_store)
			return src.r_store

/mob/living/carbon/human/proc/force_equip(obj/item/I, slot)
	//warning: icky code
	var/equipped = 0
	switch(slot)
		if (slot_back)
			if (!src.back)
				src.back = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["back"])
				I.equipped(src, slot_back)
				equipped = 1
				clothing_dirty |= C_BACK
		if (slot_wear_mask)
			if (!src.wear_mask && src.organHolder && src.organHolder.head)
				src.wear_mask = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["mask"])
				I.equipped(src, slot_wear_mask)
				equipped = 1
				clothing_dirty |= C_MASK
		if (slot_l_hand)
			equipped = src.put_in_hand(I, 1)
			clothing_dirty |= C_LHAND
		if (slot_r_hand)
			equipped = src.put_in_hand(I, 0)
			clothing_dirty |= C_RHAND
		if (slot_belt)
			if (!src.belt)
				src.belt = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["belt"])
				I.equipped(src, slot_belt)
				equipped = 1
				clothing_dirty |= C_BELT
		if (slot_wear_id)
			if (!src.wear_id)
				src.wear_id = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["id"])
				I.equipped(src, slot_wear_id)
				equipped = 1
				clothing_dirty |= C_ID
		if (slot_ears)
			if (!src.ears && src.organHolder && src.organHolder.head)
				src.ears = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["ears"])
				I.equipped(src, slot_ears)
				equipped = 1
				clothing_dirty |= C_EARS
		if (slot_glasses)
			if (!src.glasses && src.organHolder && src.organHolder.head)
				src.glasses = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["glasses"])
				I.equipped(src, slot_glasses)
				equipped = 1
				clothing_dirty |= C_GLASSES
		if (slot_gloves)
			if (!src.gloves)
				src.gloves = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["gloves"])
				I.equipped(src, slot_gloves)
				equipped = 1
				clothing_dirty |= C_GLOVES
		if (slot_head)
			if (!src.head && src.organHolder && src.organHolder.head)
				src.head = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["head"])
				I.equipped(src, slot_head)
				equipped = 1
				src.update_hair_layer()
				clothing_dirty |= C_HEAD
		if (slot_shoes)
			if (!src.shoes)
				src.shoes = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["shoes"])
				I.equipped(src, slot_shoes)
				equipped = 1
				clothing_dirty |= C_SHOES
		if (slot_wear_suit)
			if (!src.wear_suit)
				src.wear_suit = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["suit"])
				I.equipped(src, slot_wear_suit)
				equipped = 1
				src.update_hair_layer()
				clothing_dirty |= C_SUIT
		if (slot_w_uniform)
			if (!src.w_uniform)
				src.w_uniform = I
				hud.add_other_object(I, hud.layouts[hud.layout_style]["under"])
				I.equipped(src, slot_w_uniform)
				equipped = 1
				clothing_dirty |= C_UNIFORM
		if (slot_l_store)
			if (!src.l_store)
				src.l_store = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["storage1"])
				equipped = 1
		if (slot_r_store)
			if (!src.r_store)
				src.r_store = I
				hud.add_object(I, HUD_LAYER+2, hud.layouts[hud.layout_style]["storage2"])
				equipped = 1
		if (slot_in_backpack)
			if (src.back && istype(src.back, /obj/item/storage))
				I.set_loc(src.back)
				equipped = 1
		if (slot_in_belt)
			if (src.belt && istype(src.belt, /obj/item/storage))
				I.set_loc(src.belt)
				equipped = 1

	if (equipped)
		if (slot != slot_in_backpack && slot != slot_in_belt)
			I.set_loc(src)
		if (islist(I.ability_buttons) && I.ability_buttons.len)
			I.set_mob(src)
			if (slot != slot_in_backpack && slot != slot_in_belt)
				I.show_buttons()
		src.update_clothing()


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
		if (slot_l_store, slot_r_store)
			if (I.w_class <= 2 && src.w_uniform)
				return 1
		if (slot_l_hand, slot_r_hand)
			return 1
		if (slot_belt)
			if ((I.flags & ONBELT) && src.w_uniform)
				return 1
		if (slot_wear_id)
			if (istype(I, /obj/item/card/id) && src.w_uniform)
				return 1
			if (istype(I, /obj/item/device/pda2) && src.w_uniform) // removed the check for the ID card in here because tbh it was silly that you could only equip it to the ID slot when it had a card  :I
				return 1
		if (slot_back)
			if (I.flags & ONBACK)
				return 1
		if (slot_wear_mask) // It's not pretty, but the mutantrace check will do for the time being (Convair880).
			if (istype(I, /obj/item/clothing/mask))
				var/obj/item/clothing/M = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !M.compatible_species.Find(src.mutantrace.name)) || (!ismonkey(src) && M.monkey_clothes))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return 0
				else
					return 1
		if (slot_ears)
			if (istype(I, /obj/item/clothing/ears) || istype(I,/obj/item/device/radio/headset))
				return 1
		if (slot_glasses)
			if (istype(I, /obj/item/clothing/glasses))
				return 1
		if (slot_gloves)
			if (istype(I, /obj/item/clothing/gloves))
				return 1
		if (slot_head)
			if (istype(I, /obj/item/clothing/head))
				var/obj/item/clothing/H = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !H.compatible_species.Find(src.mutantrace.name)) || (!ismonkey(src) && H.monkey_clothes))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return 0
				else
					return 1
		if (slot_shoes)
			if (istype(I, /obj/item/clothing/shoes))
				var/obj/item/clothing/SH = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !SH.compatible_species.Find(src.mutantrace.name)) || (!ismonkey(src) && SH.monkey_clothes))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return 0
				else
					return 1
		if (slot_wear_suit)
			if (istype(I, /obj/item/clothing/suit))
				var/obj/item/clothing/SU = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !SU.compatible_species.Find(src.mutantrace.name)) || (!ismonkey(src) && SU.monkey_clothes))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return 0
				else
					return 1
		if (slot_w_uniform)
			if (istype(I, /obj/item/clothing/under))
				var/obj/item/clothing/U = I
				if ((src.mutantrace && !src.mutantrace.uses_human_clothes && !U.compatible_species.Find(src.mutantrace.name)) || (!ismonkey(src) && U.monkey_clothes))
					//DEBUG_MESSAGE("[src] can't wear [I].")
					return 0
				else
					return 1
		if (slot_in_backpack) // this slot is stupid
			if (src.back && istype(src.back, /obj/item/storage))
				var/obj/item/storage/S = src.back
				if (S.contents.len < 7 && I.w_class <= 3)
					return 1
		if (slot_in_belt) // this slot is also stupid
			if (src.belt && istype(src.belt, /obj/item/storage))
				var/obj/item/storage/S = src.belt
				if (S.contents.len < 7 && I.w_class <= 3)
					return 1
	return 0

/mob/living/carbon/human/proc/equip_new_if_possible(path, slot)
	var/obj/item/I = new path(src)
	src.equip_if_possible(I, slot)
	if(slot != slot_in_backpack && slot != slot_in_belt && src.get_slot(slot) != I)
		qdel(I)
		return 0
	return 1

/mob/living/carbon/human/proc/equip_if_possible(obj/item/I, slot)
	if (can_equip(I, slot))
		force_equip(I, slot)
		return 1
	else
		return 0

/mob/living/carbon/human/swap_hand(var/specify=-1)
	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B && hand != specify)
		qdel(B)
	if (specify >= 0)
		src.hand = specify
	else
		src.hand = !src.hand
	hud.update_hands()

/mob/living/carbon/human/emp_act()
	boutput(src, "<span class='alert'><B>Your equipment malfunctions.</B></span>")

	var/list/L = src.get_all_items_on_mob()
	if (L && L.len)
		for (var/obj/O in L)
			O.emp_act()
	boutput(src, "<span class='alert'><B>BZZZT</B></span>")

/mob/living/carbon/human/verb/consume(mob/M as mob in oview(0))
	set hidden = 1
	var/mob/living/carbon/human/H = M
	if (!istype(H))
		return

	if (!H.stat)
		boutput(usr, "You can't eat [H] while they are conscious!")
		return

	if (H.bioHolder.HasEffect("consumed"))
		boutput(usr, "There's nothing left to consume!")
		return

	if(src.emote_check(1, 50, 0))	//spam prevention
		usr.visible_message("<span class='alert'>[usr] starts [pick("taking bites out of","chomping","chewing","biting","eating","gnawing")] [H]. [pick("What a [pick("psychopath","freak","weirdo","lunatic","creep","rude dude","nutter","jerk","nerd")]!","Holy shit!","What the [pick("hell","fuck","christ","shit","heck")]?","Oh [pick("no","dear","god")]!")]</span>")

		var/loc = usr.loc

		SPAWN_DBG(5 SECONDS)
			if (usr.loc != loc || H.loc != loc)
				boutput(usr, "<span class='alert'>Your consumption of [H] was interrupted!</span>")
				return

			usr.visible_message("<span class='alert'>[usr] finishes [pick("taking bites out of","chomping","chewing","biting","eating","gnawing")] [H]. That was [pick("gross","horrific","disturbing","weird","horrible","funny","strange","odd","creepy","bloody","gory","shameful","awkward","unusual")]!</span>")

			if (prob(10) && !H.mutantrace)
				usr.reagents.add_reagent("prions", 10)
				SPAWN_DBG(rand(20,50)) boutput(usr, "<span class='alert'>You don't feel so good.</span>")

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

	boutput(src, "<span class='alert'>You have no idea what to do with that.</span>")
	boutput(src, "<span class='alert'>This statement is universally true because if you did you probably wouldn't be desperate enough to see this message.</span>")

/mob/living/carbon/human/full_heal()
	blinded = 0
	bleeding = 0
	blood_volume = 500

	if (!src.limbs)
		src.limbs = new /datum/human_limbs(src)
	else
		src.limbs.mend()
	//Unbreak organs. There really should be no way to do this so there's no proc, but I'm explicitly making to work for this. - kyle
	for (var/organ_slot in src.organHolder.organ_list)
		var/obj/item/organ/O = src.organHolder.organ_list[organ_slot]
		if(istype(O))
			O.broken = 0
	if (!src.organHolder)
		src.organHolder = new(src)
	src.organHolder.heal_organs(INFINITY, INFINITY, INFINITY, list("liver", "left_kidney", "right_kidney", "stomach", "intestines","spleen", "left_lung", "right_lung","appendix", "pancreas", "heart", "brain", "left_eye", "right_eye"))

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
		bioHolder.RemoveAllEffects(effectTypeDisability)

	if (src.sims)
		for (var/name in sims.motives)
			sims.affectMotive(name, 100)

	if (implant)
		for (var/obj/item/implant/I in implant)
			if (istype(I, /obj/item/implant/projectile))
				boutput(src, "[I] falls out of you!")
				I.on_remove(src)
				implant.Remove(I)
				//del(I)
				I.set_loc(get_turf(src))
				continue

	update_body()
	update_face()
	return

/mob/living/carbon/human/get_equipped_ore_scoop()
	if (istype(src.l_hand,/obj/item/ore_scoop))
		return src.l_hand
	else if (istype(src.r_hand,/obj/item/ore_scoop))
		return src.r_hand
	else
		return null

/mob/living/carbon/human/infected(var/datum/pathogen/P)
	if (isdead(src))
		return
	if (ischangeling(src) || isvampire(src)) // Vampires were missing here. They're immune to old-style diseases too (Convair880).
		return 0
	if (P.pathogen_uid in src.immunities)
		return 0
	if (!(P.pathogen_uid in src.pathogens))
		var/datum/pathogen/Q = unpool(/datum/pathogen)
		Q.setup(0, P, 1)
		pathogen_controller.mob_infected(Q, src)
		src.pathogens += Q.pathogen_uid
		src.pathogens[Q.pathogen_uid] = Q
		Q.infected = src
		logTheThing("pathology", src, null, "is infected by [Q].")
		return 1
	else
		var/datum/pathogen/C = src.pathogens[P.pathogen_uid]
		if (C.generation < P.generation)
			var/datum/pathogen/Q = unpool(/datum/pathogen)
			Q.setup(0, P, 1)
			logTheThing("pathology", src, null, "'s pathogen mutation [C] is replaced by mutation [Q] due to a higher generation number.")
			pathogen_controller.mob_infected(Q, src)
			Q.stage = min(C.stage, Q.stages)
			pool(C)
			src.pathogens[Q.pathogen_uid] = Q
			Q.infected = src
			return 1
	return 0

/mob/living/carbon/human/cured(var/datum/pathogen/P)
	if (P.pathogen_uid in src.pathogens)
		pathogen_controller.mob_cured(src.pathogens[P.pathogen_uid], src)
		var/datum/pathogen/Q = src.pathogens[P.pathogen_uid]
		var/pname = Q.name
		src.pathogens -= P.pathogen_uid
		var/datum/microbody/M = P.body_type
		if (M.auto_immunize)
			immunity(P)
		pool(Q)
		logTheThing("pathology", src, null, "is cured of [pname].")

/mob/living/carbon/human/remission(var/datum/pathogen/P)
	if (isdead(src))
		return
	if (P.pathogen_uid in src.pathogens)
		var/datum/pathogen/Q = src.pathogens[P.pathogen_uid]
		Q.remission()
		logTheThing("pathology", src, null, "'s pathogen [Q] enters remission.")

/mob/living/carbon/human/immunity(var/datum/pathogen/P)
	if (isdead(src))
		return
	if (!(P.pathogen_uid in src.immunities))
		src.immunities += P.pathogen_uid
		logTheThing("pathology", src, null, "gains immunity to pathogen [P].")

/mob/living/carbon/human/shock(var/atom/origin, var/wattage, var/zone = "chest", var/stun_multiplier = 1, var/ignore_gloves = 0)
	if (!wattage)
		return 0
	var/prot = 1
	var/obj/item/clothing/gloves/G = src.gloves
	if (G && !ignore_gloves)
		prot = (G.hasProperty("conductivity") ? G.getProperty("conductivity") : 1)
	if (src.limbs.l_arm)
		prot = min(prot,src.limbs.l_arm.siemens_coefficient)
	if (src.limbs.r_arm)
		prot = min(prot,src.limbs.r_arm.siemens_coefficient)
	if (prot <= 0.29)
		return 0

	var/shock_damage = 0
	if (wattage > 7500)
		shock_damage = (max(rand(10,20), round(wattage * 0.00004)))*prot
	else if (wattage > 5000)
		shock_damage = 15 * prot
	else if (wattage > 2500)
		shock_damage = 5 * prot
	else
		shock_damage = 1 * prot

	for (var/uid in src.pathogens)
		var/datum/pathogen/P = src.pathogens[uid]
		shock_damage = P.onshocked(shock_damage, wattage)
		if (!shock_damage)
			return 0

	if (src.bioHolder.HasEffect("resist_electric") == 2)
		var/healing = 0
		healing = shock_damage / 3
		src.HealDamage("All", healing, healing)
		src.take_toxin_damage(0 - healing)
		boutput(src, "<span class='notice'>You absorb the electrical shock, healing your body!</span>")
		return 0
	else if (src.bioHolder.HasEffect("resist_electric") == 1)
		boutput(src, "<span class='notice'>You feel electricity course through you harmlessly!</span>")
		return 0

	switch(shock_damage)
		if (0 to 25)
			playsound(src.loc, "sound/effects/electric_shock.ogg", 50, 1)
		if (26 to 59)
			playsound(src.loc, "sound/effects/elec_bzzz.ogg", 50, 1)
		if (60 to 99)
			playsound(src.loc, "sound/effects/elec_bigzap.ogg", 50, 1)  // begin the fun arcflash
			boutput(src, "<span class='alert'><b>[origin] discharges a violent arc of electricity!</b></span>")
			src.apply_flash(60, 0, 10)
			if (ishuman(src))
				var/mob/living/carbon/human/H = src
				H.cust_one_state = pick("xcom","bart","zapped")
				H.set_face_icon_dirty()
		if (100 to INFINITY)  // cogwerks - here are the big fuckin murderflashes
			playsound(src.loc, "sound/effects/elec_bigzap.ogg", 50, 1)
			playsound(src.loc, "explosion", 50, 1)
			src.flash(60)
			if (ishuman(src))
				var/mob/living/carbon/human/H = src
				H.cust_one_state = pick("xcom","bart","zapped")
				H.set_face_icon_dirty()

			var/turf/T = get_turf(src)
			if (T)
				T.hotspot_expose(5000,125)
				explosion(origin, T, -1,-1,1,2)
			if (ishuman(src))
				if (prob(20))
					boutput(src, "<span class='alert'><b>[origin] vaporizes you with a lethal arc of electricity!</b></span>")
					if (src.shoes)
						src.drop_from_slot(src.shoes)
					make_cleanable(/obj/decal/cleanable/ash,src.loc)
					SPAWN_DBG(1 DECI SECOND)
						src.elecgib()
				else
					boutput(src, "<span class='alert'><b>[origin] blasts you with an arc flash!</b></span>")
					if (src.shoes)
						src.drop_from_slot(src.shoes)
					var/atom/targetTurf = get_edge_target_turf(src, get_dir(src, get_step_away(src, origin)))
					src.throw_at(targetTurf, 200, 4)
	shock_cyberheart(shock_damage)
	TakeDamage(zone, 0, shock_damage, 0, DAMAGE_BURN)
	boutput(src, "<span class='alert'><B>You feel a [wattage > 7500 ? "powerful" : "slight"] shock course through your body!</B></span>")
	src.unlock_medal("HIGH VOLTAGE", 1)
	src.Virus_ShockCure(min(wattage / 500, 100))
	sleep(0.1 SECONDS)

#ifdef USE_STAMINA_DISORIENT
	var/stun = (min((shock_damage/5), 12) * stun_multiplier)* 10
	src.do_disorient(100 + stun, weakened = stun, stunned = stun, disorient = stun + 40, remove_stamina_below_zero = 1)
#else
	src.changeStatus("stunned", (min((shock_damage/5), 12) * stun_multiplier)* 10)
	src.changeStatus("weakened", (min((shock_damage/5), 12) * stun_multiplier)* 10)
#endif

	return shock_damage

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
	..() // For resisting burning and grabs see living.dm
	// Added this here (Convair880).
	if (!isalive(src)) //can't resist when dead or unconscious
		return

	if (!src.restrained() && (src.shoes && src.shoes.chained))
		var/obj/item/clothing/shoes/SH = src.shoes
		if (ischangeling(src))
			src.u_equip(SH)
			SH.set_loc(get_turf(src))
			src.update_clothing()
			src.show_text("You briefly shrink your legs to remove the shackles.", "blue")
		else if (src.is_hulk() || ishunter(src) || iswerewolf(src))
			src.visible_message("<span class='alert'>[src] rips apart the shackles with pure brute strength!</b></span>", "<span class='notice'>You rip apart the shackles.</span>")
			var/obj/item/clothing/shoes/NEW = new SH.type
			// Fallback if type is chained by default. Don't think we can check without spawning a pair first.
			if (NEW.chained)
				qdel(NEW)
				NEW = new /obj/item/clothing/shoes/brown
			src.u_equip(SH)
			src.equip_if_possible(NEW, slot_shoes)
			src.update_clothing()
			qdel(SH)
		else if (src.limbs && (istype(src.limbs.l_leg, /obj/item/parts/robot_parts) && !istype(src.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/light)) && (istype(src.limbs.r_leg, /obj/item/parts/robot_parts) && !istype(src.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/light))) // Light cyborg legs don't count.
			src.visible_message("<span class='alert'>[src] rips apart the shackles with pure machine-like strength!</b></span>", "<span class='notice'>You rip apart the shackles.</span>")
			var/obj/item/clothing/shoes/NEW2 = new SH.type
			if (NEW2.chained)
				qdel(NEW2)
				NEW2 = new /obj/item/clothing/shoes/brown
			src.u_equip(SH)
			src.equip_if_possible(NEW2, slot_shoes)
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
				boutput(src, "<span class='notice'>You briefly shrink your hands to remove your handcuffs.</span>")
				src.handcuffs.drop_handcuffs(src)
				return
			if (ishunter(src))
				for (var/mob/O in AIviewers(src))
					O.show_message(text("<span class='alert'><B>[] rips apart the handcuffs with pure brute strength!</B></span>", src), 1)
				boutput(src, "<span class='notice'>You rip apart your handcuffs.</span>")

				if (src.handcuffs:material) //This is a bit hacky.
					src.handcuffs:material:triggerOnAttacked(src.handcuffs, src, src, src.handcuffs)
				src.handcuffs.destroy_handcuffs(src)
				return
			if (iswerewolf(src))
				if (src.handcuffs.werewolf_cant_rip())
					boutput(src, __red("You can't seem to rip apart these silver handcuffs. They burn!"))
					src.TakeDamage("l_arm", 0, 2, 0, DAMAGE_BURN)
					src.TakeDamage("r_arm", 0, 2, 0, DAMAGE_BURN)
					return
				else
					src.visible_message("<span class='alert'><B>[src] rips apart the handcuffs with pure brute strength!</b></span>")
					boutput(src, "<span class='notice'>You rip apart your handcuffs.</span>")
					if (src.handcuffs:material) //This is a bit hacky.
						src.handcuffs:material:triggerOnAttacked(src.handcuffs, src, src, src.handcuffs)
					src.handcuffs.destroy_handcuffs(src)
					return
		if (src.is_hulk())
			for (var/mob/O in AIviewers(src))
				O.show_message(text("<span class='alert'><B>[] rips apart the handcuffs with pure brute strength!</B></span>", src), 1)
			boutput(src, "<span class='notice'>You rip apart your handcuffs.</span>")

			if (src.handcuffs:material) //This is a bit hacky.
				src.handcuffs:material:triggerOnAttacked(src.handcuffs, src, src, src.handcuffs)
			src.handcuffs.destroy_handcuffs(src)
		else if ( src.limbs && (istype(src.limbs.l_arm, /obj/item/parts/robot_parts) && !istype(src.limbs.l_arm, /obj/item/parts/robot_parts/arm/left/light)) && (istype(src.limbs.r_arm, /obj/item/parts/robot_parts) && !istype(src.limbs.r_arm, /obj/item/parts/robot_parts/arm/right/light))) //Gotta be two standard borg arms
			for (var/mob/O in AIviewers(src))
				O.show_message(text("<span class='alert'><B>[] rips apart the handcuffs with machine-like strength!</B></span>", src), 1)
			boutput(src, "<span class='notice'>You rip apart your handcuffs.</span>")

			if (src.handcuffs:material) //This is a bit hacky.
				src.handcuffs:material:triggerOnAttacked(src.handcuffs, src, src, src.handcuffs)
			src.handcuffs.destroy_handcuffs(src)
		else
			src.last_resist = world.time + 100
			var/calcTime = src.handcuffs.material ? max((src.handcuffs.material.getProperty("hard") + src.handcuffs.material.getProperty("density")) * 10, 200) : (istype(src.handcuffs, /obj/item/handcuffs/guardbot) ? rand(150, 180) : (src.canmove ? rand(400,500) : rand(600,750)))
			boutput(src, "<span class='alert'>You attempt to remove your handcuffs. (This will take around [round(calcTime / 10)] seconds and you need to stand still)</span>")
			if (src.handcuffs:material) //This is a bit hacky.
				src.handcuffs:material:triggerOnAttacked(src.handcuffs, src, src, src.handcuffs)
			actions.start(new/datum/action/bar/private/icon/handcuffRemoval(calcTime), src)
	return 0

/mob/living/carbon/human/proc/spidergib()
	if (isobserver(src))
		var/list/virus = src.ailments
		gibs(src.loc, virus)
		return
#ifdef DATALOGGER
	game_stats.Increment("violence")
#endif

	src.death(1)
	var/atom/movable/overlay/gibs/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101

	if (ishuman(src))
		animation = new(src.loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("spidergib", animation)
		src.visible_message("<span class='alert'><font size=4><B>A swarm of spiders erupts from [src]'s mouth and devours them! OH GOD!</B></font></span>", "<span class='alert'><font size=4><B>A swarm of spiders erupts from your mouth! OH GOD!</B></font></span>", "<span class='alert'>You hear a vile chittering sound.</span>")
		playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 100, 1)
		SPAWN_DBG(1 SECOND)
			make_cleanable(/obj/decal/cleanable/vomit/spiders,src.loc)
			for (var/I = 0, I < 4, I++)
				new /obj/critter/spider/baby(src.loc)

	if (src.mind || src.client)
		ghostize()

	if (animation)
		animation.delaydispose()

	SPAWN_DBG(1.5 SECONDS)
		qdel(src)

/mob/living/carbon/human/get_equipped_items()
	. = ..()
	if (src.belt) . += src.belt
	if (src.glasses) . += src.glasses
	if (src.gloves) . += src.gloves
	if (src.head) . += src.head
	if (src.shoes) . += src.shoes
	if (src.wear_id) . += src.wear_id
	if (src.wear_suit) . += src.wear_suit
	if (src.w_uniform) . += src.w_uniform

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
		if (prob(50))
			var/obj/item/clothing/head/wig/W = create_wig()
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
		if (istype(A, /obj/screen)) // maybe people will stop gibbing out their stamina bars now  :|
			continue
		if (prob(dump_contents_chance) || istype(A, /obj/item/reagent_containers/food/snacks/shell)) //For dudes who got fried and eaten so they eject -ZeWaka
			ret += A
	return ret

/mob/living/carbon/human/proc/create_wig()
	if (!src.bioHolder || !src.bioHolder.mobAppearance)
		return null
	var/obj/item/clothing/head/wig/W = new(src)
	W.name = "[real_name]'s hair"
	W.real_name = "[real_name]'s hair" // The clothing parent setting real_name is probably good for other stuff so I'll just do this
/* commenting this out and making it an overlay to fix issues with colors stacking
	W.icon = 'icons/mob/human_hair.dmi'
	W.icon_state = cust_one_state
	W.color = src.bioHolder.mobAppearance.customization_first_color
	W.wear_image_icon = 'icons/mob/human_hair.dmi'
	W.wear_image = image(W.wear_image_icon, W.icon_state)
	W.wear_image.color = src.bioHolder.mobAppearance.customization_first_color*/

	if (src.bioHolder.mobAppearance.customization_first != "None")
		var/image/h_image = image('icons/mob/human_hair.dmi', cust_one_state)
		h_image.color = src.bioHolder.mobAppearance.customization_first_color
		W.overlays += h_image
		W.wear_image.overlays += h_image

	if (src.bioHolder.mobAppearance.customization_second != "None")
		var/image/f_image = image('icons/mob/human_hair.dmi', cust_two_state)
		f_image.color = src.bioHolder.mobAppearance.customization_second_color
		W.overlays += f_image
		W.wear_image.overlays += f_image

	if (src.bioHolder.mobAppearance.customization_third != "None")
		var/image/d_image = image('icons/mob/human_hair.dmi', cust_three_state)
		d_image.color = src.bioHolder.mobAppearance.customization_third_color
		W.overlays += d_image
		W.wear_image.overlays += d_image
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
		if (src.limbs.r_leg || src.limbs.l_leg) //legless people should still be able to interact
			return

	if (mutantrace && mutantrace.override_attack)
		mutantrace.custom_attack(target)
	else
		var/obj/item/parts/arm = null
		if (limbs) //Wire: fix for null.r_arm and null.l_arm
			arm = hand ? limbs.l_arm : limbs.r_arm // I'm so sorry I couldent kill all this shitcode at once
		if (arm)
			arm.limb_data.attack_hand(target, src, can_reach(src, target), params, location, control)

/mob/living/carbon/human/hand_range_attack(atom/target, params, location, control, origParams)
	//This looks bad but it really isn't anymore. <3

	var/list/valid_slots = list(
		slot_back,
		slot_wear_mask,
		slot_belt,
		slot_wear_id,
		slot_ears,
		slot_glasses,
		slot_gloves,
		slot_head,
		slot_shoes,
		slot_wear_suit,
		slot_w_uniform,
		slot_l_store,
		slot_r_store,
		slot_l_hand,
		slot_r_hand
	)

	for(var/slot in valid_slots)
		var/obj/item/slot_item = src.get_slot(slot)
		if(slot_item?.flags & HAS_EQUIP_CLICK && slot_item.equipment_click(src, target, params, location, control, origParams, slot))
			return

	if (src.lying)
		if (src.limbs.r_leg || src.limbs.l_leg) //legless people should still be able to interact
			return 0
	.=..()

/mob/living/carbon/human/bullet_act(var/obj/projectile/P)
	if (P.mob_shooter)
		src.was_harmed(P.mob_shooter)
	..()

/mob/living/carbon/human/proc/was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
	return

/mob/living/carbon/human/attack_hand(mob/M)
	..()
	if (!surgeryCheck(src, M))
		src.activate_chest_item_on_attack(M)
	if (M.a_intent in list(INTENT_HARM,INTENT_DISARM,INTENT_GRAB))
		src.was_harmed(M)

/mob/living/carbon/human/attackby(obj/item/W, mob/M)
	if (isghostcritter(M) && src.health < 80) //there's another one of these in attack_hand(). Same file. see, the quality of my code doens't matter as long as i leave a very helpful comment!!!
		boutput(M, "Your spectral conscience refuses to damage this human any further.")
		return
	var/oldbloss = get_brute_damage()
	var/oldfloss = get_burn_damage()
	..()
	var/newbloss = get_brute_damage()
	var/damage = ((newbloss - oldbloss) + (get_burn_damage() - oldfloss))
	if (reagents)
		reagents.physical_shock((newbloss - oldbloss) * 0.15)
	if (!surgeryCheck(src, M))
		src.activate_chest_item_on_attack(M)
	if ((damage > 0) || W.force)
		src.was_harmed(M, W)

/mob/living/carbon/human/understands_language(var/langname)
	if (mutantrace)
		if ((langname == "" || langname == "english") && !mutantrace.override_language)
			. = 1
		else if (mutantrace.override_language == langname)
			. = 1
		else if (langname in mutantrace.understood_languages)
			. = 1
		else
			. = 0
	else
		. = ..()
	if ((langname == "silicon" || langname == "binary") && (locate(/obj/item/implant/robotalk) in implant || src.traitHolder.hasTrait("roboears")))
		return 1
	return .

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	//Could just do a wearing_football_gear() check here, but I don't wanna deal with proc call overhead on every Bump()
	if ( (src.wear_suit && istype(src.wear_suit,/obj/item/clothing/suit/armor/football)) \
			&& (src.shoes && istype(src.shoes,/obj/item/clothing/shoes/cleats)) \
			&& (src.w_uniform && istype(src.w_uniform,/obj/item/clothing/under/football)) )
		src.tackle(AM)
	..()

/mob/living/carbon/human/get_special_language(var/secure_mode)
	if (secure_mode == "s" && (locate(/obj/item/implant/robotalk) in implant || src.traitHolder.hasTrait("roboears")))
		return "silicon"
	return null

/mob/living/carbon/human/HealBleeding(var/amt)
	bleeding = max(bleeding - amt, 0)

/mob/living/carbon/human/proc/juggling()
	if (islist(src.juggling) && src.juggling.len)
		return 1
	return 0

/mob/living/carbon/human/proc/drop_juggle()
	if (!src.juggling())
		return
	src.visible_message("<span class='alert'><b>[src]</b> drops everything they were juggling!</span>")
	for (var/obj/O in src.juggling)
		O.set_loc(src.loc)
		O.layer = initial(O.layer)
		if (prob(25))
			O.throw_at(get_step(src, pick(alldirs)), 1, 1)
		src.juggling -= O
	src.drop_from_slot(src.r_hand)
	src.drop_from_slot(src.l_hand)
	src.update_body()
	logTheThing("combat", src, null, "drops the items they were juggling")

/mob/living/carbon/human/proc/add_juggle(var/obj/thing as obj)
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
		for (var/obj/O in src.juggling)
			count ++
			if (src.juggling.len > 1 && count == src.juggling.len)
				items += " and [O]"
				continue
			items += ", [O]"
		items = copytext(items, 3)
		src.visible_message("<b>[src]</b> adds [thing] to the [items] [he_or_she(src)]'s already juggling!")
	else
		src.visible_message("<b>[src]</b> starts juggling [thing]!")
	src.juggling += thing
	if (isitem(thing))
		var/obj/item/i = thing
		i.on_spin_emote(src)
	src.update_body()
	logTheThing("combat", src, null, "juggles [thing]")

/mob/living/carbon/human/does_it_metabolize()
	return 1

/mob/living/carbon/human/canRideMailchutes()
	if (ismonkey(src)) // Why not, I guess?
		return 1
	else if (src.w_uniform && istype(src.w_uniform, /obj/item/clothing/under/misc/mail/syndicate))
		return 1
	else
		return 0

/mob/living/carbon/human/set_mutantrace(var/mutantrace_type)

	//Clean up the old mutantrace
	if (src.organHolder && src.organHolder.head && src.organHolder.head.donor == src)
		src.organHolder.head.donor_mutantrace = null

	if(src.mutantrace != null)
		qdel(src.mutantrace) // so that disposing() runs and removes mutant traits
		. = 1

	if(ispath(mutantrace_type, /datum/mutantrace) )	//Set a new mutantrace only if passed one
		src.mutantrace = new mutantrace_type(src)
		. = 1

	if(.) //If the mutantrace was changed do all the usual icon updates
		if(src.organHolder && src.organHolder.head && src.organHolder.head.donor == src)
			src.organHolder.head.donor_mutantrace = src.mutantrace
			src.organHolder.head.update_icon()
		src.set_face_icon_dirty()
		src.set_body_icon_dirty()
		src.get_static_image()


		if (src.bioHolder && src.bioHolder.mobAppearance)
			src.bioHolder.mobAppearance.UpdateMob()
		else
			src.update_body()
			src.update_clothing()

/mob/living/carbon/human/verb/change_hud_style()
	set name = "Change HUD Style"
	set desc = "Selects what style HUD you would like to use."
	set category = "Commands"

	if (!src.hud) // uh?
		return src.show_text("<b>Somehow you have no HUD! Please alert a coder!</b>", "red")

	var/selection = input(usr, "What style HUD style would you like?", "Selection") as null|anything in hud_style_selection
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
		logTheThing("combat", M, src, "activates [src.chest_item] embedded in [src]'s chest cavity at [log_loc(src)]")
		src.chest_item.attack_self(src)
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
			boutput(src, "<span class='alert'><b>[src.chest_item] spills its contents inside your chest!</span>")
			logTheThing("combat", src, src.chest_item, "transfers chemicals from [src.chest_item] [log_reagents(src.chest_item)] to [src] at [log_loc(src)]")
			src.chest_item.reagents.trans_to(src, maxVolumeAdd)
	return

/mob/living/carbon/human/proc/chest_item_attack_self_on_fart()
	if(!(src.chest_item && (src.chest_item in src.contents)))
		return
	src.show_text("You grunt and squeeze <B>[src.chest_item]</B> in your chest.")
	src.chest_item.attack_self(src) // Activate the item
	if (src.chest_item_sewn == 0 || istype(src.chest_item, /obj/item/cloaking_device))	// If item isn't sewn in, poop it onto the ground. No fartcloaks allowed
		// Item object is pooped out
		if (istype(src.chest_item, /obj/item/))
			// Determine ass and bleed damage based on item size
			var/poopingDamage = 0
			if (src.chest_item.w_class == 1 )
				poopingDamage = 5
				src.show_text("<B>[src.chest_item]</B> plops out of your rear and onto the floor.")
			else if (src.chest_item.w_class == 2 )
				poopingDamage = 10
				src.show_text("You poop out <B>[src.chest_item]</B>! Your butt aches a bit.")
			else if (src.chest_item.w_class == 3 )
				poopingDamage = 20
				src.show_text("<span class='alert'><B>[src.chest_item]</B> was shat out, that's got to hurt!</span>")
				src.changeStatus("stunned", 2 SECONDS)
				take_bleeding_damage(src, src, 5)
			else if (src.chest_item.w_class == 4 || src.chest_item.w_class == 5)
				poopingDamage = 50
				src.show_text("<span class='alert'><B>[src.chest_item] explodes out of your ass, jesus christ!</B></span>")
				src.changeStatus("stunned", 50)
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
				src.show_text("<span class='alert'><B>[src.chest_item] cut your butt off on the way out!</B></span>")
				src.organHolder.drop_organ("butt")
		// Other object is pooped out
		else
			// If it's not an "item", deal medium damage
			src.show_text("<span class='alert'><B>[src.chest_item]</B> was shat out, that's got to hurt!</span>")
			src.changeStatus("stunned", 1 SECOND)
			src.TakeDamage("chest", 20, 0, 0, DAMAGE_BLUNT)
			take_bleeding_damage(src, src, 5)
		// added log - cirr
		logTheThing("combat", src, src.chest_item, "takes damage from farting out [src.chest_item] embedded in [src]'s chest cavity at [log_loc(src)]")
		// Make copy of item on ground
		var/obj/item/outChestItem = src.chest_item
		outChestItem.set_loc(get_turf(src))
		src.chest_item = null

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
	.= -5
	if (src.mutantrace)
		.+= src.mutantrace.hand_offset

/mob/living/carbon/human/verb/show_inventory()
	set name = "Show Inventory"
	set src in view(1)
	set category = "Local"

	if (usr == src)
		src.hud.clicked("invtoggle", list()) // ha i copy the dumb thing
		return
	if (!src.can_strip(src, 1)) return
	if (LinkBlocked(src.loc,usr.loc)) return
	if (isAI(usr) || isAI(src)) return
	if (isghostcritter(usr) && !isdead(src)) return
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
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 50, 1)
				else
					if (src.footstep >= 2)
						src.footstep = 0
					else
						src.footstep += steps
					if (src.footstep == 0)
						playsound(NewLoc, NewLoc.active_liquid.step_sound, 20, 1)
		else if (src.shoes && src.shoes.step_sound && src.shoes.step_lots)
			if (src.m_intent == "run")
				if (src.footstep >= 2)
					src.footstep = 0
				else
					src.footstep += steps
				if (src.footstep == 0)
					playsound(NewLoc, src.shoes.step_sound, 50, 1)
			else
				playsound(NewLoc, src.shoes.step_sound, 20, 1)

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
							priority = NewLoc.step_material
						else if (priority < 0)
							priority = src.shoes ? src.shoes.step_sound : "step_barefoot"

						playsound(NewLoc, "[priority]", src.m_intent == "run" ? 65 : 40, 1, extrarange = 3)

	//STEP SOUND HANDLING OVER

	if (prob(5)) // Handling tied or cut shoelaces courtesy of /obj/item/gun/energy/pickpocket
		if (src.shoes && src.m_intent == "run" && src.shoes.laces != LACES_NORMAL)
			if (src.shoes.laces == LACES_TIED) // Laces tied
				boutput(src, "You stumble and fall headlong to the ground. Your shoelaces are a huge knot! <span class='alert'>FUCK!</span>")
				src.changeStatus("weakened", 3 SECONDS)
			else if (src.shoes.laces == LACES_CUT) // Laces cut
				var/obj/item/clothing/shoes/S = src.shoes
				src.u_equip(S)
				S.set_loc(src.loc)
				S.dropped(src)
				S.layer = initial(S.layer)
				if (prob(20)) boutput(src, "You run right the fuck out of your shoes. <span class='alert'>Shit!</span>")

	..()
#undef can_step_sfx


/mob/living/carbon/human/set_loc(var/newloc as turf|mob|obj in world)
	if (abilityHolder)
		abilityHolder.set_loc_callback(newloc)
	..()

/mob/living/carbon/human/get_id()
	. = ..()
	if(.)
		return
	if(istype(src.wear_id, /obj/item/card/id))
		return src.wear_id
	if(istype(src.wear_id, /obj/item/device/pda2))
		var/obj/item/device/pda2/pda = src.wear_id
		return pda.ID_card

/mob/living/carbon/human/is_hulk()
	if (src.bioHolder && src.bioHolder.HasEffect("hulk"))
		return 1
	else if (istype(src.gloves, /obj/item/clothing/gloves/ring/titanium))
		return 1
	return 0

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
	if (src.lying)
		missing_legs = 2
	else if (src.shoes && src.shoes.chained)
		missing_legs = 2

	if (missing_legs == 2)
		. += 14 - ((2-missing_arms) * 2) // each missing leg adds 7 of movement delay. Each functional arm reduces this by 2.
	else
		. += 7*missing_legs

	var/turf/T = get_turf(src)

	if (T)
		if (T.turf_flags & CAN_BE_SPACE_SAMPLE)
			. -= space_movement

		if (!(src.mutantrace && src.mutantrace.aquatic))
			if (aquatic_movement > 0)
				if (T.active_liquid || T.turf_flags & FLUID_MOVE)
					. -= aquatic_movement
			else
				if (T.active_liquid)
					. += T.active_liquid.movement_speed_mod
				else if (istype(T,/turf/space/fluid))
					. += 3
