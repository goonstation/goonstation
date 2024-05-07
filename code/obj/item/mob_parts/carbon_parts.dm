ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/carbon_part)

/obj/item/mob_part/humanoid_part/carbon_part
	name = "carbon part"
	icon = 'icons/obj/items/human_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "arm-left"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 6
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 5
	hitsound = 'sound/impact_sounds/meat_smack.ogg'

	cut_messages = list("slices", "slice")
	saw_messages = list("saws", "saw")
	limb_material = list("skin and flesh","bone","strips of skin")

	random_limb_blacklisted = FALSE

	/// is this affected by human skin tones? Also overlays a severed stump, which is typically baked into non-skintoned limbs
	var/skintoned = TRUE

	/// the original mob (probably a carbon/human) that this was a part of
	var/mob/living/original_holder = null
	/// the appearance holder that this was a part of, modified in certain cases (such as genetic recoloration)
	var/datum/appearanceHolder/holder_ahol
	/// the DNA of this limb
	var/limb_DNA = null
	/// the fingerprints of this limb, if any
	var/limb_fingerprints = null
	/// the skin tone of this limb
	var/skin_tone = "#FFFFFF"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!ismob(target))
			return

		src.add_fingerprint(user)

		if(user.zone_sel.selecting != slot || !ishuman(target))
			return ..()
		if (!src.easy_attach)
			if (!surgeryCheck(target,user))
				return ..()

		var/mob/living/carbon/human/H = target

		if(H.limbs.vars[src.slot])
			boutput(user, SPAN_ALERT("[H.name] already has one of those!"))
			return

		attach(H,user)

		return

	New(mob/new_holder)
		..()
		if (ismob(new_holder))
			holder = new_holder
			original_holder = new_holder
			if(!src.holder_ahol && ishuman(original_holder))
				var/mob/living/carbon/human/H = original_holder
				src.holder_ahol = H?.bioHolder?.mobAppearance
			if ((src.holder_ahol.special_style) && (istype_exact(src, src.holder_ahol.mutant_race?.r_limb_arm_type_mutantrace) || istype_exact(src, src.holder_ahol.mutant_race?.l_limb_arm_type_mutantrace) || istype_exact(src, src.holder_ahol.mutant_race?.r_limb_leg_type_mutantrace) || istype_exact(src, src.holder_ahol.mutant_race?.l_limb_leg_type_mutantrace)))
				icon = src.holder_ahol.body_icon
				part_icon = src.holder_ahol.body_icon

			src.add_fingerprint(holder)
			//https://forum.ss13.co/showthread.php?tid=1774
			// zam note - removing this again.
			SPAWN(2 SECONDS)
				if (new_holder && istype(new_holder))
					name = "[new_holder.real_name]'s [initial(name)]"
		if (src.skintoned)
			if (holder_ahol)
				src.update_skin_tone()
			else if(holder)	//
				SPAWN(1 SECOND)
					src.update_skin_tone()
					holder.set_body_icon_dirty()
					holder.set_face_icon_dirty()
					holder.set_clothing_icon_dirty()
			else
				src.update_skin_tone()

	disposing()
		original_holder = null
		holder = null
		..()

	update_images(var/decomp_stage = DECOMP_STAGE_NO_ROT)
		..()
		if (src.skintoned)
			src.limb_layer_image?.color = src.skin_tone
			src.hand_layer_image?.color = src.skin_tone

	remove(var/show_message = 1)
		if ((isnull(src.limb_DNA) || isnull(src.limb_fingerprints)) && ismob(src.original_holder))
			if (src.original_holder && src.original_holder.bioHolder) //ZeWaka: Fix for null.bioHolder
				src.limb_DNA = src.original_holder.bioHolder.Uid
				src.limb_fingerprints = src.original_holder.bioHolder.fingerprints
		return ..()

	sever(mob/user)
		if ((isnull(src.limb_DNA) || isnull(src.limb_fingerprints)) && ismob(src.original_holder))
			if (src.original_holder && src.original_holder.bioHolder) //ZeWaka: Fix for null.bioHolder
				src.limb_DNA = src.original_holder.bioHolder.Uid
				src.limb_fingerprints = src.original_holder.bioHolder.fingerprints
		return ..()

	attach(mob/living/carbon/human/attachee, mob/attacher, both_legs)
		. = ..()
		if (.) // A successful attachment
			if(ismob(attachee) && attachee?.bioHolder) // Whose limb is this?
				if(isnull(src.original_holder)) // Limb never had an original owner?
					src.original_holder = attachee // Now it does
					if (src.original_holder?.bioHolder)
						src.limb_DNA = src.original_holder.bioHolder.Uid
						src.limb_fingerprints = src.original_holder.bioHolder.fingerprints
					return
				if(src.limb_DNA != attachee.bioHolder.Uid) // Limb isnt ours
					src.limb_is_transplanted = TRUE
				else // Maybe we got our old limb back?
					src.limb_is_transplanted = FALSE

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom == thr.return_target)
			var/mob/living/carbon/human/H = hit_atom
			if (isskeletonlimb(src) && isskeleton(H) && !H.limbs.get_limb(src.slot))
				src.attach(H)
				H.visible_message("[SPAN_ALERT("[H] has been hit by [src].")] [SPAN_NOTICE("It fuses instantly with [H]'s empty socket!")]")
				playsound(H, 'sound/effects/attach.ogg', 50, TRUE)
			else
				hit_atom.visible_message(SPAN_ALERT("<b>[hit_atom]</b> gets clonked in the face with [src]!"))
				playsound(hit_atom, 'sound/impact_sounds/Flesh_Break_1.ogg', 30, TRUE)
				hit_atom.changeStatus("stunned", 2 SECONDS)
			return
		..()

	/// Determines what the limb's skin tone should be, optionally setting the s_tone of the stored appearance holder to the holder's
	proc/update_skin_tone(reset = FALSE)
		if (!src.skintoned)
			return // No colorizing things that have their own baked in colors!

		if (reset && istype(src.holder_ahol, /datum/appearanceHolder) && ishuman(src.holder))
			var/mob/living/carbon/human/H = src.holder
			if (H.bioHolder?.mobAppearance)
				src.holder_ahol.s_tone = H.bioHolder.mobAppearance.s_tone

		var/datum/appearanceHolder/AHLIMB = src.get_owner_appearance_holder()
		if (AHLIMB)
			if (AHLIMB.mob_appearance_flags & HAS_NO_SKINTONE)
				src.skin_tone = "#FFFFFF"
			else
				src.skin_tone = AHLIMB.s_tone
		else	// This is going to look *weird* if these somehow spawn on a mob
			if (istype(src, /obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/lizard) || istype(src, /obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/lizard))
				src.skin_tone = rgb(rand(50,190), rand(50,190), rand(50,190))	// If lizlimbs havent been colored, color them
			else
				var/blend_color = null
				blend_color = pick(standard_skintones)
				src.skin_tone = standard_skintones[blend_color]

		update_images()
		update_severed_icon()

	/// Applies the correct (hopefully) colors to the severed limbs
	proc/update_severed_icon()
		if (!src.skintoned || !isicon(src.icon))
			return // No colorizing things that have their own baked in colors! Also they dont need a bloody stump overlaid

		// All skintoned limbs also get a cool not-affected-by-coloration bloody stump!
		var/icon/limb_icon = new /icon(src.icon, "[src.icon_state]")	// Preferably a grayscale image
		limb_icon.Blend(src.skin_tone, ICON_MULTIPLY)

		var/icon/limb_icon_overlay = new /icon(src.icon, "[src.icon_state]_blood") // Preferably blood-colored
		limb_icon.Blend(limb_icon_overlay, ICON_OVERLAY)

		src.icon = limb_icon

	/// Gets an appearanceholder, either the owner's or the one in the limb
	proc/get_owner_appearance_holder()
		if (istype(src.holder_ahol, /datum/appearanceHolder))
			. = src.holder_ahol
		else if (src.original_holder?.bioHolder?.mobAppearance)
			. = src.original_holder.bioHolder.mobAppearance

/obj/item/mob_part/humanoid_part/carbon_part/arm
	name = "placeholder item (don't use this!)"
	desc = "A human arm."
	override_attack_hand = 0 //to hit with an item instead of hand when used empty handed
	can_hold_items = 1
	var/rebelliousness = 0
	var/strangling = FALSE

	on_holder_examine()
		if (src.show_on_examine)
			return "has [bicon(src)] \an [initial(src.name)] attached as a"

	proc/foreign_limb_effect()
		if(rebelliousness < 10 && prob(20))
			rebelliousness += 1

		if(strangling)
			if(holder.losebreath < 5) holder.losebreath = 5
			if(prob(20-rebelliousness))
				holder.visible_message(SPAN_ALERT("[holder.name] stops trying to strangle themself."), SPAN_ALERT("You manage to pull your [src.name] away from your throat!"))
				strangling = FALSE
				holder.losebreath -= 5
			return

		if(prob(rebelliousness*2)) //Emote
			boutput(holder, SPAN_ALERT("Your [src.name] moves by itself!"))
			holder.emote(pick("snap", "shrug", "clap", "flap", "aflap", "raisehand", "crackknuckles","rude","gesticulate","wgesticulate","nosepick","flex","facepalm","airquote","flipoff","shakefist"))
		else if(prob(rebelliousness)) //Slap self
			boutput(holder, SPAN_ALERT("Your [src.name] moves by itself!"))
			holder.emote("slap")
		else if(prob(rebelliousness) && holder.get_eye_blurry() == 0) //Poke own eye
			holder.visible_message(SPAN_ALERT("[holder.name] pokes themself in the eye with their [src.name]."), SPAN_ALERT("Your [src.name] pokes you in the eye!"))
			holder.change_eye_blurry(10)
		else if(prob(rebelliousness) && holder.losebreath == 0) //Strangle self
			holder.visible_message(SPAN_ALERT("[holder.name] tries to strangle themself with their [src.name]."), SPAN_ALERT("Your [src.name] tries to strangle you!"))
			holder.emote("gasp")
			holder.losebreath = 5
			strangling = TRUE

	sever(mob/user)
		if(holder?.handcuffs)
			var/obj/item/I = holder.handcuffs
			holder.u_equip(I)
			I.set_loc(holder.loc)
		. = ..()

	disposing()
		if(ismob(holder) && holder.handcuffs)
			var/obj/item/I = holder.handcuffs
			holder.u_equip(I)
			I.set_loc(holder.loc)
		. = ..()

	remove(show_message = 1)
		if(holder?.handcuffs)
			var/obj/item/I = holder.handcuffs
			holder.u_equip(I)
			I.set_loc(holder.loc)
		. = ..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/left
	name = "left arm"
	desc = "According to superstition, left handed people are unlucky. Whoever lost this sure seems to back that belief up."
	icon_state = "arm_left"
	item_state = "arm-left"
	slot = "l_arm"
	hand_layer_icon_state = "hand_left"

	disposing()
		if (src.holder)
			if (ishuman(src.holder))
				var/mob/living/carbon/human/H = src.holder
				H.drop_from_slot(H?.l_hand)
		. = ..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right
	name = "right arm"
	desc = "Someone's right hand.... hand. Or arm, whatever."
	icon_state = "arm_right"
	item_state = "arm-right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

	disposing()
		if (src.holder)
			if (ishuman(src.holder))
				var/mob/living/carbon/human/H = src.holder
				H.drop_from_slot(H?.r_hand)
		. = ..()

/obj/item/mob_part/humanoid_part/carbon_part/leg
	name = "placeholder item (don't use this!)"
	desc = "A human leg, pretty important for mobility."
	object_flags = NO_ARM_ATTACH
	var/rebelliousness = 0

	on_holder_examine()
		if (src.show_on_examine)
			return "has [bicon(src)] \an [initial(src.name)] attached as a"

	proc/foreign_limb_effect()
		if(rebelliousness < 10 && prob(20))
			rebelliousness += 1

		if(prob(rebelliousness*2)) //Emote
			boutput(holder, SPAN_ALERT("<b>Your [src.name] moves by itself!</b>"))
			holder.emote(pick("shakebutt", "flap", "aflap","stretch","dance","fart","twitch","twitch_v","flip"))
		else if(prob(rebelliousness)) //Trip over
			boutput(holder, SPAN_ALERT("<b>Your [src.name] moves by itself!</b>"))
			holder.emote(pick("trip", "collapse"))
		else if(prob(rebelliousness)) //Slow down
			boutput(holder, SPAN_ALERT("<b>Your [src.name] is slowing you down!</b>"))
			holder.setStatusMin("slowed", 1 SECOND)
		else if(prob(rebelliousness)) //Stumble around
			boutput(holder, SPAN_ALERT("<b>Your [src.name] won't do what you tell it to!</b>"))
			if (holder.misstep_chance < 20)
				holder.change_misstep_chance(20)

/obj/item/mob_part/humanoid_part/carbon_part/leg/left
	name = "left leg"
	icon_state = "leg_left"
	item_state = "leg-left"
	slot = "l_leg"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/right
	name = "right leg"
	icon_state = "leg_right"
	item_state = "leg-right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/brullbar
	name = "left brullbar arm"
	icon_state = "arm_left_brullbar"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/brullbar
	hand_layer_icon_state = "l_hand_brullbar"
	limb_icon_suffix = "brullbar"
	show_on_examine = TRUE
	/// Brullbar are pretty unnatural, and most people'd miss em if they suddenly turned into a lizard arm
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/brullbar/king
	name = "left king brullbar arm"
	icon_state = "arm_left_brullbar"
	limb_type = /datum/limb/brullbar/king

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/brullbar
	name = "right brullbar arm"
	icon_state = "arm_right_brullbar"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/brullbar
	hand_layer_icon_state = "r_hand_brullbar"
	limb_icon_suffix = "brullbar"
	show_on_examine = TRUE
	/// If you went through the trouble to get yourself a brullbar arm, you should keep it no matter how inhuman you become
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/brullbar/king
	name = "right king brullbar arm"
	icon_state = "arm_right_brullbar"
	limb_type = /datum/limb/brullbar/king

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/hot
	name = "left hot arm"
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	hand_layer_icon_state = "hand_left"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_HOT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/hot
	name = "right hot arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	hand_layer_icon_state = "hand_right"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_HOT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/mob_part/humanoid_part/carbon_part/arm/left/bear
	name = "left bear arm"
	desc = "Dear god it's still wiggling."
	icon_state = "arm_left_bear"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	hand_layer_icon_state = "l_hand_bear"
	limb_icon_suffix = "bear"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BEAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/mob_part/humanoid_part/carbon_part/arm/right/bear
	name = "right bear arm"
	desc = "Dear god it's still wiggling."
	icon_state = "arm_right_bear"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	hand_layer_icon_state = "r_hand_bear"
	limb_icon_suffix = "bear"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BEAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/synth
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_left_plant"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "l_hand_plant"
	limb_icon_suffix = "plant"
	show_on_examine = TRUE
	easy_attach = TRUE
	/// Plants are pretty unnatural
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/synth
	name = "synthetic right arm"
	desc = "A right arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_right_plant"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "r_hand_plant"
	limb_icon_suffix = "plant"
	show_on_examine = TRUE
	easy_attach = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/left/synth
	name = "synthetic left leg"
	desc = "A left leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "leg_left_plant"
	slot = "l_leg"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "l_foot_plant"
	limb_icon_suffix = "plant"
	show_on_examine = TRUE
	easy_attach = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/right/synth
	name = "synthetic right leg"
	desc = "A right leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "leg_right_plant"
	slot = "r_leg"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "r_foot_plant"
	limb_icon_suffix = "plant"
	show_on_examine = TRUE
	easy_attach = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/mob_part/humanoid_part/carbon_part/arm/left/synth/bloom
	desc = "A left arm. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "arm_left_plant_bloom"
	hand_layer_icon_state = "l_hand_plant"
	limb_icon_suffix = "plant_bloom"

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/synth/bloom
	desc = "A right arm. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "arm_right_plant_bloom"
	hand_layer_icon_state = "r_hand_plant"
	limb_icon_suffix = "plant_bloom"

/obj/item/mob_part/humanoid_part/carbon_part/leg/left/synth/bloom
	desc = "A left leg. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "leg_left_plant_bloom"
	hand_layer_icon_state = "l_foot_plant"
	limb_icon_suffix = "plant_bloom"

/obj/item/mob_part/humanoid_part/carbon_part/leg/right/synth/bloom
	desc = "A right leg. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "leg_right_plant_bloom"
	hand_layer_icon_state = "r_foot_plant"
	limb_icon_suffix = "plant_bloom"

// Added shambler, werewolf and hunter arms, including the sprites (Convair880).
/obj/item/mob_part/humanoid_part/carbon_part/arm/left/abomination
	name = "left chitinous tendril"
	desc = "Some sort of alien tendril with very sharp edges. Seems to be moving on its own..."
	icon_state = "arm_left_abomination"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/abomination
	hand_layer_icon_state = "l_hand_abomination"
	limb_icon_suffix = "abomination"
	show_on_examine = TRUE
	/// About as unnatural as it gets
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ABOM)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	remove(show_message)
		..()
		src.visible_message(SPAN_ALERT("[src] rapidly keratinizes!"))
		var/obj/item/mob_part/humanoid_part/carbon_part/arm/left/claw/newlimb = new(src.loc)
		newlimb.limb_DNA = src.limb_DNA
		newlimb.original_holder = src.original_holder
		newlimb.limb_fingerprints = src.limb_fingerprints
		qdel(src)
		return newlimb

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/abomination
	name = "right chitinous tendril"
	desc = "Some sort of alien tendril with very sharp edges. Seems to be moving on its own..."
	icon_state = "arm_right_abomination"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/abomination
	hand_layer_icon_state = "r_hand_abomination"
	limb_icon_suffix = "abomination"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ABOM)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	remove(show_message)
		..()
		src.visible_message(SPAN_ALERT("[src] rapidly keratinizes!"))
		var/obj/item/mob_part/humanoid_part/carbon_part/arm/right/claw/newlimb = new(src.loc)
		newlimb.limb_DNA = src.limb_DNA
		newlimb.original_holder = src.original_holder
		newlimb.limb_fingerprints = src.limb_fingerprints
		qdel(src)
		return newlimb

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/zombie
	name = "left rotten arm"
	desc = "A rotten hunk of human junk."
	icon = 'icons/mob/vampiric_thrall.dmi'
	part_icon = 'icons/mob/vampiric_thrall.dmi'
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	override_attack_hand = 1
	can_hold_items = 0
	limb_type = /datum/limb/zombie //Basically zombie arms am I right?
	skintoned = TRUE
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	/// Supernatural if not abnormally gross
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ZOMBIE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/zombie
	name = "right rotten arm"
	desc = "A rotten hunk of human junk."
	icon = 'icons/mob/vampiric_thrall.dmi'
	part_icon = 'icons/mob/vampiric_thrall.dmi'
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	override_attack_hand = 1
	can_hold_items = 0
	limb_type = /datum/limb/zombie //Basically zombie arms am I right?
	skintoned = TRUE
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ZOMBIE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/mob_part/humanoid_part/carbon_part/arm/left/claw
	name = "left claw arm"
	icon_state = "arm_left_brullbar"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	hand_layer_icon_state = "l_hand_brullbar"
	limb_icon_suffix = "brullbar"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/claw
	name = "right claw arm"
	icon_state = "arm_right_brullbar"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	hand_layer_icon_state = "r_hand_brullbar"
	limb_icon_suffix = "brullbar"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/right/stone
	name = "synthetic right arm"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "arm_right_stone"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "r_hand_stone"
	limb_icon_suffix = "stone"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/left/stone
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_left_stone"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "l_hand_stone"
	limb_icon_suffix = "stone"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/left/stone
	name = "synthetic left leg"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "leg_left_stone"
	slot = "l_leg"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "l_foot_stone"
	limb_icon_suffix = "stone"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/right/stone
	name = "synthetic right leg"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "leg_right_stone"
	slot = "r_leg"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	hand_layer_icon_state = "r_foot_stone"
	limb_icon_suffix = "stone"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


////// MUTANT PARENT PARTS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant
	name = "left mutant arm"
	desc = "An arm that definitely does not look human."
	icon = 'icons/mob/cow.dmi'
	part_icon = 'icons/mob/cow.dmi'
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"
	skintoned = FALSE
	kind_of_limb = (LIMB_MUTANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant
	name = "left mutant leg!"
	desc = "A leg that definitely does not look human."
	icon = 'icons/mob/cow.dmi'
	part_icon = 'icons/mob/cow.dmi'
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"
	skintoned = FALSE
	kind_of_limb = (LIMB_MUTANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

//// COW LIMBS ////
///// PARENT  /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cow
	icon = 'icons/mob/cow.dmi'
	part_icon = 'icons/mob/cow.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cow
	icon = 'icons/mob/cow.dmi'
	part_icon = 'icons/mob/cow.dmi'
	limb_hit_bonus = 4
	skintoned = TRUE

	update_images()
		..()
		if (src.hand_layer_image)
			var/datum/appearanceHolder/aholder = src.get_owner_appearance_holder()
			if(aholder)
				src.hand_layer_image.color = aholder.customization_second_color

//// LIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cow/left
	name = "left cow arm"
	desc = "A cow's left arm. Moo."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cow/right
	name = "right cow arm"
	desc = "A cow's right arm. Oom."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cow/left
	name = "left cow leg"
	desc = "A cow's left leg. Shanked a bit too hard, presumably."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cow/right
	name = "right cow leg"
	desc = "A cow's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

	New(var/atom/holder)
		. = ..()
		if(prob(1))
			src.desc += " Bears the brand of a legendary roleplayer."

//// PUG LIMBS ////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/pug
	icon = 'icons/mob/pug/fawn.dmi'
	part_icon = 'icons/mob/pug/fawn.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/pug/left
	name = "left pug arm"
	desc = "A pug's left arm. Pawsitive."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/pug/right
	name = "right pug arm"
	desc = "A pug's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/pug
	icon = 'icons/mob/pug/fawn.dmi'
	part_icon = 'icons/mob/pug/fawn.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/pug/left
	name = "left pug leg"
	desc = "A pug's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/pug/right
	name = "right pug leg"
	desc = "A pug's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// LIZARD LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/lizard
	icon = 'icons/mob/lizard.dmi'
	part_icon = 'icons/mob/lizard.dmi'
	skintoned = TRUE

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/lizard
	icon = 'icons/mob/lizard.dmi'
	part_icon = 'icons/mob/lizard.dmi'
	skintoned = TRUE

////// ACTUAL LIZARD LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/lizard/left
	name = "left lizard arm"
	desc = "A lizard'sss left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/lizard/right
	name = "right lizard arm"
	desc = "A lizard'ssss right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/lizard/left
	name = "left lizard leg"
	desc = "A lizard'ss left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/lizard/right
	name = "right lizard leg"
	desc = "A lizard'sssss right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// AMPHIBIAN LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/amphibian
	icon = 'icons/mob/amphibian.dmi'
	part_icon = 'icons/mob/amphibian.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/amphibian
	icon = 'icons/mob/amphibian.dmi'
	part_icon = 'icons/mob/amphibian.dmi'

////// ACTUAL AMPHIBIAN LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/amphibian/left
	name = "left amphibian arm"
	desc = "A amphibian's left arm. Croak."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/amphibian/right
	name = "right amphibian arm"
	desc = "A amphibian's right arm. Froak."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/amphibian/left
	name = "left amphibian leg"
	desc = "A amphibian's left leg. Croak."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/amphibian/right
	name = "right amphibian leg"
	desc = "A amphibian's right leg. Froak"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// SHELTERFROG LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/shelterfrog
	icon = 'icons/mob/shelterfrog.dmi'
	part_icon = 'icons/mob/shelterfrog.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/shelterfrog
	icon = 'icons/mob/shelterfrog.dmi'
	part_icon = 'icons/mob/shelterfrog.dmi'

////// ACTUAL SHELTERFROG LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/shelterfrog/left
	name = "left shelterfrog arm"
	desc = "A shelterfrog's left arm. CroOak."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/shelterfrog/right
	name = "right shelterfrog arm"
	desc = "A shelterfrog's right arm. FrOoOoak."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/shelterfrog/left
	name = "left shelterfrog leg"
	desc = "A shelterfrog's left leg. CroOoOk."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/shelterfrog/right
	name = "right shelterfrog leg"
	desc = "A shelterfrog's right leg. FroOoak"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// ROACH LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/roach
	icon = 'icons/mob/roach.dmi'
	part_icon = 'icons/mob/roach.dmi'
	skintoned = TRUE

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/roach
	icon = 'icons/mob/roach.dmi'
	part_icon = 'icons/mob/roach.dmi'
	skintoned = TRUE

////// ACTUAL ROACH LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/roach/left
	name = "left roach arm"
	desc = "An enormous insect's left arm. Ew."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/roach/right
	name = "right roach arm"
	desc = "An enormous insect's right arm. Ew."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/roach/left
	name = "left roach leg"
	desc = "An enormous insect's left leg. Ew."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/roach/right
	name = "right roach leg"
	desc = "An enormous insect's right leg. Ew"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// CAT LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat
	icon = 'icons/mob/cat.dmi'
	part_icon = 'icons/mob/cat.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat
	icon = 'icons/mob/cat.dmi'
	part_icon = 'icons/mob/cat.dmi'

////// ACTUAL CAT LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat/left
	name = "left cat arm"
	desc = "A cat's left arm. Meow."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat/right
	name = "right cat arm"
	desc = "A cat's right arm. =3"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat/left
	name = "left cat leg"
	desc = "A cat's left leg. =0w0="
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat/right
	name = "right cat leg"
	desc = "A cat's right leg. Mrow."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

// bingus limbs hehehe

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat/bingus
	icon = 'icons/mob/bingus.dmi'
	part_icon = 'icons/mob/bingus.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat/bingus
	icon = 'icons/mob/bingus.dmi'
	part_icon = 'icons/mob/bingus.dmi'

////// ACTUAL CAT LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat/bingus/left
	name = "left cat arm"
	desc = "A cat's left arm. Meow."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/cat/bingus/right
	name = "right cat arm"
	desc = "A cat's right arm. =3"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat/bingus/left
	name = "left cat leg"
	desc = "A cat's left leg. =0w0="
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/cat/bingus/right
	name = "right cat leg"
	desc = "A cat's right leg. Mrow."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// WEREWOLF LIMBS ////
////// PARENT	//////////
/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/werewolf
	icon = 'icons/mob/werewolf.dmi'
	part_icon = 'icons/mob/werewolf.dmi'
	kind_of_limb = (LIMB_MUTANT | LIMB_WOLF)

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/werewolf
	icon = 'icons/mob/werewolf.dmi'
	part_icon = 'icons/mob/werewolf.dmi'
	limb_type = /datum/limb/abomination/werewolf
	kind_of_limb = (LIMB_MUTANT | LIMB_WOLF)

	sever(mob/user)
		. = ..()
		src.visible_message(SPAN_NOTICE("[src] withers greatly as it falls off!"))
		src.limb_data = new/datum/limb/brullbar/severed_werewolf(src)

	remove(show_message)
		. = ..()
		src.visible_message(SPAN_NOTICE("[src] withers greatly as it falls off!"))
		src.limb_data = new/datum/limb/brullbar/severed_werewolf(src)

//// THE ACTUAL WOLFLIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/werewolf/left
	name = "left werewolf leg"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/werewolf/right
	name = "right werewolf leg"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/werewolf/left
	name = "left werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon = 'icons/mob/werewolf.dmi'
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	show_on_examine = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/werewolf/right
	name = "right werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon = 'icons/mob/werewolf.dmi'
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	hand_layer_icon_state = "hand_right"
	show_on_examine = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()
//// VAMPIRE ZOMBIE LIMBS ////
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/vampiric_thrall
	icon = 'icons/mob/vampiric_thrall.dmi'
	part_icon = 'icons/mob/vampiric_thrall.dmi'
	kind_of_limb = LIMB_MUTANT

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/vampiric_thrall
	icon = 'icons/mob/vampiric_thrall.dmi'
	part_icon = 'icons/mob/vampiric_thrall.dmi'
	kind_of_limb = LIMB_MUTANT

//// LIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/vampiric_thrall/left
	name = "left vampiric thrall arm"
	desc = "A vampiric thrall's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/vampiric_thrall/right
	name = "right vampiric thrall arm"
	desc = "A vampiric thrall's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/vampiric_thrall/left
	name = "left vampiric thrall leg"
	desc = "A vampiric thrall's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/vampiric_thrall/right
	name = "right vampiric thrall leg"
	desc = "A vampiric thrall's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// SKELETON LIMBS ////
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/skeleton
	icon = 'icons/mob/skeleton.dmi'
	part_icon = 'icons/mob/skeleton.dmi'
	easy_attach = TRUE // Its just a bone... full of meat. Kind of.
	kind_of_limb = (LIMB_MUTANT | LIMB_SKELLY)
	force = 10
	throw_return = TRUE

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/skeleton
	icon = 'icons/mob/skeleton.dmi'
	part_icon = 'icons/mob/skeleton.dmi'
	easy_attach = TRUE
	kind_of_limb = (LIMB_MUTANT | LIMB_SKELLY)
	force = 10
	throw_return = TRUE

//// LIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/skeleton/left
	name = "left skeleton arm"
	desc = "A skeletal left arm. Spooky."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/skeleton/right
	name = "right skeleton arm"
	desc = "A skeletal right arm. Humerus."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/skeleton/left
	name = "left skeleton leg"
	desc = "A skeletal left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/skeleton/right
	name = "right skeleton leg"
	desc = "A skeletal right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// MONKEY LIMBS ////
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/monkey
	icon = 'icons/mob/monkey.dmi'
	part_icon = 'icons/mob/monkey.dmi'
	part_decomp_icon = 'icons/mob/monkey_decomp.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/monkey
	icon = 'icons/mob/monkey.dmi'
	part_icon = 'icons/mob/monkey.dmi'
	part_decomp_icon = 'icons/mob/monkey_decomp.dmi'


//// LIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/monkey/left
	name = "left monkey arm"
	desc = "A monkey's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/monkey/right
	name = "right monkey arm"
	desc = "A monkey's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/monkey/left
	name = "left monkey leg"
	desc = "A monkey's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/monkey/right
	name = "right monkey leg"
	desc = "A monkey's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// SEA MONKEY LIMBS ////
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/seamonkey
	icon = 'icons/mob/seamonkey.dmi'
	part_icon = 'icons/mob/seamonkey.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/seamonkey
	icon = 'icons/mob/seamonkey.dmi'
	part_icon = 'icons/mob/seamonkey.dmi'


//// LIMBS ////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/seamonkey/left
	name = "left seamonkey arm"
	desc = "A seamonkey's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/seamonkey/right
	name = "right seamonkey arm"
	desc = "A seamonkey's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/seamonkey/left
	name = "left seamonkey leg"
	desc = "A seamonkey's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/seamonkey/right
	name = "right seamonkey leg"
	desc = "A seamonkey's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

//// CHICKEN LIMBS ////
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/chicken
	icon = 'icons/mob/chicken.dmi'
	part_icon = 'icons/mob/chicken.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/chicken
	icon = 'icons/mob/chicken.dmi'
	part_icon = 'icons/mob/chicken.dmi'


//// LIMBS ////

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/chicken/left
	name = "left chicken leg"
	desc = "A chicken's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

	New(mob/new_holder)
		. = ..()
		if(prob(10))
			src.desc = "A chicken's left drumstick."

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/chicken/right
	name = "right chicken leg"
	desc = "A chicken's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

	New(mob/new_holder)
		. = ..()
		if(prob(10))
			src.desc = "A chicken's right drumstick."

//// KUDZU LIMBS ////
//////  PARENT  //////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/kudzu
	icon = 'icons/obj/items/human_parts.dmi'
	part_icon = 'icons/mob/human.dmi'
	skintoned = TRUE
	easy_attach = TRUE // These plants really like humanoid flesh
	kind_of_limb = (LIMB_MUTANT | LIMB_PLANT)

	update_images()
		..()
		if (src.limb_layer_image)
			src.limb_layer_image.overlays += image('icons/mob/kudzu.dmi', src.limb_layer_image, "[src.slot]_kudzu")
		if (src.hand_layer_image)
			src.hand_layer_image.overlays += image('icons/mob/kudzu.dmi', src.hand_layer_image, "[src.hand_layer_icon_state]_kudzu")

	update_severed_icon()
		var/image/overlay = SafeGetOverlayImage("overlay", 'icons/mob/kudzu.dmi', "[src.icon_state]_kudzu")
		UpdateOverlays(overlay, "overlay")

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/kudzu
	icon = 'icons/obj/items/human_parts.dmi'
	part_icon = 'icons/mob/human.dmi'
	skintoned = TRUE
	var/kudzu_overlay_icon = 'icons/mob/kudzu.dmi'
	easy_attach = TRUE
	kind_of_limb = (LIMB_MUTANT | LIMB_PLANT)

	update_images()
		..()
		if (src.limb_layer_image)
			src.limb_layer_image.overlays += image('icons/mob/kudzu.dmi', src.limb_layer_image, "[src.slot]_kudzu")
		if (src.hand_layer_image)
			src.hand_layer_image.overlays += image('icons/mob/kudzu.dmi', src.hand_layer_image, "[src.hand_layer_icon_state]_kudzu")

	update_severed_icon()
		var/image/overlay = SafeGetOverlayImage("overlay", 'icons/mob/kudzu.dmi', "[src.icon_state]_kudzu")
		UpdateOverlays(overlay, "overlay")

////// ACTUAL KUDZU LIMBS //////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/kudzu/left
	name = "left kudzu arm"
	desc = "A kudzu'sss left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/kudzu/right
	name = "right kudzu arm"
	desc = "A kudzu'ssss right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/kudzu/left
	name = "left kudzu leg"
	desc = "A kudzu'ss left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/kudzu/right
	name = "right kudzu leg"
	desc = "A kudzu'sssss right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/// HUNTER LIMBS ///
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/hunter
	icon = 'icons/mob/hunter.dmi'
	part_icon = 'icons/mob/hunter.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/hunter
	icon = 'icons/mob/hunter.dmi'
	part_icon = 'icons/mob/hunter.dmi'

///// LIMBS /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/hunter/left
	name = "left hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	hand_layer_icon_state = "hand_left"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/hunter/right
	name = "right hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = FALSE
	skintoned = FALSE
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	hand_layer_icon_state = "hand_right"
	show_on_examine = TRUE
	limb_is_unnatural = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/hunter/left
	name = "left hunter leg"
	desc = "A muscular and strong left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/hunter/right
	name = "right hunter leg"
	desc = "A muscular and strong right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/// VIRTUAL LIMBS ///
///// PARENT /////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/virtual
	icon = 'icons/mob/virtual.dmi'
	part_icon = 'icons/mob/virtual.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/virtual
	icon = 'icons/mob/virtual.dmi'
	part_icon = 'icons/mob/virtual.dmi'

///// LIMBS /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/virtual/left
	name = "left virtual arm"
	desc = "A simulated left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/virtual/right
	name = "left virtual arm"
	desc = "A simulated right arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/virtual/left
	name = "left virtual leg"
	desc = "A simulated left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/virtual/right
	name = "right virtual leg"
	desc = "A simulated right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/// ITHILLID LIMBS ///
///// PARENT /////
/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/ithillid
	icon = 'icons/mob/ithillid.dmi'
	part_icon = 'icons/mob/ithillid.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/ithillid
	icon = 'icons/mob/ithillid.dmi'
	part_icon = 'icons/mob/ithillid.dmi'

///// LIMBS /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/ithillid/left
	name = "left squid arm"
	desc = "A squid's left blub."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/ithillid/right
	name = "left squid arm"
	desc = "Blub squid's right arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/ithillid/left
	name = "left squid leg"
	desc = "A blub's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/ithillid/right
	name = "right squid leg"
	desc = "A squid's blub leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"

/// PSYCHEDELIC LIMBS ///
///// PARENT /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/flashy
	icon = 'icons/mob/flashy.dmi'
	part_icon = 'icons/mob/flashy.dmi'

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/flashy
	icon = 'icons/mob/flashy.dmi'
	part_icon = 'icons/mob/flashy.dmi'

///// LIMBS /////

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/flashy/left
	name = "psychedelic left arm"
	desc = "A polychromatic left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	hand_layer_icon_state = "hand_left"

/obj/item/mob_part/humanoid_part/carbon_part/arm/mutant/flashy/right
	name = "psychedelic right arm"
	desc = "A polychromatic right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	hand_layer_icon_state = "hand_right"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/flashy/left
	name = "psychedelic left leg"
	desc = "A polychromatic left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	hand_layer_icon_state = "foot_left"
	step_image_state = "footprintsL"

/obj/item/mob_part/humanoid_part/carbon_part/leg/mutant/flashy/right
	name = "psychedelic right leg"
	desc = "A polychromatic right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	hand_layer_icon_state = "foot_right"
	step_image_state = "footprintsR"
