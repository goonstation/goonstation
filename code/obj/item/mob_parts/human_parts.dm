/obj/item/parts/human_parts
	name = "human parts"
	icon = 'icons/obj/items/human_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "arm-left"
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	var/mob/living/original_holder = null
	var/datum/appearanceHolder/holder_ahol
	force = 6
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 5
	skintoned = 1
	hitsound = 'sound/impact_sounds/meat_smack.ogg'
	var/original_DNA = null
	var/original_fprints = null
	var/show_on_examine = 0

	take_damage(brute, burn, tox, damage_type, disallow_limb_loss)
		if (brute <= 0 && burn <= 0)// && tox <= 0)
			return 0

		src.brute_dam += brute
		src.burn_dam += burn
		//src.tox_dam += tox

		health_update_queue |= holder
		return 1

	heal_damage(brute, burn, tox)
		if (brute_dam <= 0 && burn_dam <= 0 && tox_dam <= 0)
			return 0
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		src.tox_dam = max(0, src.tox_dam - tox)
		health_update_queue |= holder
		return 1

	get_damage()
		return src.brute_dam + src.burn_dam	+ src.tox_dam

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(!ismob(M))
			return

		src.add_fingerprint(user)

		if(user.zone_sel.selecting != slot || !ishuman(M))
			return ..()
		if (!src.easy_attach)
			if (!surgeryCheck(M,user))
				return ..()

		var/mob/living/carbon/human/H = M

		if(H.limbs.vars[src.slot])
			boutput(user, "<span class='alert'>[H.name] already has one of those!</span>")
			return

		attach(H,user)

		return

	New(mob/new_holder, var/datum/appearanceHolder/AHolAlmostThere)
		..()
		if(AHolAlmostThere && istype(AHolAlmostThere, /datum/appearanceHolder))
			src.holder_ahol = AHolAlmostThere
		if (ismob(new_holder))
			holder = new_holder
			original_holder = new_holder
			if(!src.holder_ahol && ishuman(original_holder))
				var/mob/living/carbon/human/H = original_holder
				src.holder_ahol = H?.bioHolder?.mobAppearance
			if (src.holder_ahol.special_style)
				icon = src.holder_ahol.body_icon
				partIcon = src.holder_ahol.body_icon
			if(!src.bones)
				src.bones = new /datum/bone(src)
			src.bones.donor = new_holder
			src.bones.parent_organ = "[src.name]"
			src.setMaterial(getMaterial("bone"), appearance = 0, setname = 0)

			src.add_fingerprint(holder)
			//https://forum.ss13.co/showthread.php?tid=1774
			// zam note - removing this again.
			SPAWN(2 SECONDS)
				if (new_holder && istype(new_holder))
					name = "[new_holder.real_name]'s [initial(name)]"
		if (src.skintoned)
			if (holder_ahol)
				colorize_limb_icon()
				set_skin_tone()
			else if(holder)	//
				SPAWN(1 SECOND)
					colorize_limb_icon()
					set_skin_tone()
					holder.set_body_icon_dirty()
					holder.set_face_icon_dirty()
					holder.set_clothing_icon_dirty()
			else
				colorize_limb_icon()
				set_skin_tone()
		if(limb_overlay_1_icon || handfoot_overlay_1_icon)
			setup_limb_overlay()

	disposing()
		src.bones?.dispose()
		src.bones = null
		original_holder = null
		holder = null
		..()

	proc/set_skin_tone()
		if (!skintoned)
			return
		var/this_skin_tone = src.skin_tone
		if (src.lyingImage)
			src.lyingImage.color = this_skin_tone
		if (src.standImage)
			src.standImage.color = this_skin_tone

	getMobIcon(var/lying)
		. = ..()
		if (skintoned)
			var/newrgb = src.skin_tone
			if (src.lyingImage)
				src.lyingImage.color = newrgb
			if (src.standImage)
				src.standImage.color = newrgb

	surgery(var/obj/item/tool)
		if(remove_stage > 0 && (istype(tool,/obj/item/staple_gun) || istype(tool,/obj/item/suture)) )
			remove_stage = 0

		else if(remove_stage == 0 || remove_stage == 2)
			if(istool(tool, TOOL_CUTTING))
				remove_stage++
			else
				return 0

		else if(remove_stage == 1)
			if(istool(tool, TOOL_SAWING))
				remove_stage++
			else
				return 0

		if(!isdead(holder)) //This goes up here 'cuz removing limbs nulls holder
			if(prob(40))
				holder.emote("scream")
		holder.TakeDamage("chest",20,0)
		take_bleeding_damage(holder, tool.the_mob, 15, DAMAGE_STAB, surgery_bleed = 1)

		switch(remove_stage)
			if(0)
				tool.the_mob.visible_message("<span class'alert'>[tool.the_mob] attaches [holder.name]'s [src.name] securely with [tool].</span>", "<span class='alert'>You attach [holder.name]'s [src.name] securely with [tool].</span>")
				logTheThing(LOG_COMBAT, tool.the_mob, "staples [constructTarget(holder,"combat")]'s [src.name] back on.")
				logTheThing(LOG_DIARY, tool.the_mob, "staples [constructTarget(holder,"diary")]'s [src.name] back on.", "combat")
			if(1)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] slices through the skin and flesh of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You slice through the skin and flesh of [holder.name]'s [src.name] with [tool].</span>")
			if(2)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] saws through the bone of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You saw through the bone of [holder.name]'s [src.name] with [tool].</span>")

				SPAWN(rand(150,200))
					if(remove_stage == 2)
						src.remove(0)
			if(3)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] cuts through the remaining strips of skin holding [holder.name]'s [src.name] on with [tool].</span>", "<span class='alert'>You cut through the remaining strips of skin holding [holder.name]'s [src.name] on with [tool].</span>")
				logTheThing(LOG_COMBAT, tool.the_mob, "removes [constructTarget(holder,"combat")]'s [src.name].")
				logTheThing(LOG_DIARY, tool.the_mob, "removes [constructTarget(holder,"diary")]'s [src.name]", "combat")
				src.remove(0)


		return 1

	remove(var/show_message = 1)
		if ((isnull(src.original_DNA) || isnull(src.original_fprints)) && ismob(src.original_holder))
			if (src.original_holder && src.original_holder.bioHolder) //ZeWaka: Fix for null.bioHolder
				src.original_DNA = src.original_holder.bioHolder.Uid
				src.original_fprints = src.original_holder.bioHolder.fingerprints
		return ..()

	attach(mob/living/carbon/human/attachee, mob/attacher, both_legs)
		. = ..()
		if (.) // A successful attachment
			if(ismob(attachee) && attachee?.bioHolder) // Whose limb is this?
				if(isnull(src.original_holder)) // Limb never had an original owner?
					src.original_holder = attachee // Now it does
					if (src.original_holder?.bioHolder)
						src.original_DNA = src.original_holder.bioHolder.Uid
						src.original_fprints = src.original_holder.bioHolder.fingerprints
					return
				if(src.original_DNA != attachee.bioHolder.Uid) // Limb isnt ours
					src.limb_is_transplanted = TRUE
				else // Maybe we got our old limb back?
					src.limb_is_transplanted = FALSE

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom == thr.return_target)
			var/mob/living/carbon/human/H = hit_atom
			if (isskeletonlimb(src) && isskeleton(H) && !H.limbs.get_limb(src.slot))
				src.attach(H)
				H.visible_message("<span class='alert'>[H] has been hit by [src].</span> <span class='notice'>It fuses instantly with [H]'s empty socket!</span>")
				playsound(H, 'sound/effects/attach.ogg', 50, 1)
			else
				hit_atom.visible_message("<span class='alert'><b>[hit_atom]</b> gets clonked in the face with [src]!</span>")
				playsound(hit_atom, 'sound/impact_sounds/Flesh_Break_1.ogg', 30, 1)
				hit_atom.changeStatus("stunned", 2 SECONDS)
			return
		..()

	/// Determines what the limb's skin tone should be
	proc/colorize_limb_icon()
		if (!src.skintoned) return // No colorizing things that have their own baked in colors! Also they dont need a bloody stump overlaid
		var/datum/appearanceHolder/AHLIMB = src.get_owner_appearance_holder()
		if (AHLIMB)
			if (AHLIMB.mob_appearance_flags & HAS_NO_SKINTONE)
				skin_tone = "#FFFFFF"
			else
				skin_tone = AHLIMB.s_tone
		else	// This is going to look *weird* if these somehow spawn on a mob
			if (istype(src, /obj/item/parts/human_parts/arm/mutant/lizard) || istype(src, /obj/item/parts/human_parts/arm/mutant/lizard))
				src.skin_tone = rgb(rand(50,190), rand(50,190), rand(50,190))	// If lizlimbs havent been colored, color them
			else
				var/blend_color = null
				blend_color = pick(standard_skintones)
				src.skin_tone = standard_skintones[blend_color]
		set_limb_icon_coloration()

	/// Applies the correct (hopefully) colors to the severed limbs
	proc/set_limb_icon_coloration()
		if (!src.skintoned || !isicon(src.icon))
			return // No colorizing things that have their own baked in colors! Also they dont need a bloody stump overlaid

		// All skintoned limbs also get a cool not-affected-by-coloration bloody stump!
		var/icon/limb_icon = new /icon(src.icon, "[src.icon_state]")	// Preferably a grayscale image
		limb_icon.Blend(src.skin_tone, ICON_MULTIPLY)

		// Extra bit? Throw it in!
		if(severed_overlay_1_icon)
			var/colorheck = "#FFFFFF"
			var/datum/appearanceHolder/AH_piece = get_owner_appearance_holder()
			if(istype(AH_piece, /datum/appearanceHolder))
				switch(src.severed_overlay_1_color)
					if(CUST_1)
						colorheck = AH_piece.customization_first_color
					if(CUST_2)
						colorheck = AH_piece.customization_second_color
					if(CUST_3)
						colorheck = AH_piece.customization_third_color
					if (SKIN_TONE)
						colorheck = src.skin_tone
					else
						colorheck = "#FFFFFF"
			var/icon/limb_detail_icon = new /icon(src.severed_overlay_1_icon, "[src.severed_overlay_1_state]")	// Preferably just about anything
			limb_detail_icon.Blend(colorheck, ICON_MULTIPLY)
			limb_icon.Blend(limb_detail_icon, ICON_OVERLAY)

		var/icon/limb_icon_overlay = new /icon(src.icon, "[src.icon_state]_blood") // Preferably blood-colored
		limb_icon.Blend(limb_icon_overlay, ICON_OVERLAY)

		src.icon = limb_icon

	/// Assembles the limb's overlays, if any
	proc/setup_limb_overlay()
		if(!limb_overlay_1_icon && !handfoot_overlay_1_icon) // Gotta have something
			return

		var/datum/appearanceHolder/AH_overlimb = src.get_owner_appearance_holder()
		var/colorlimb_heck = "#FFFFFF"
		if(istype(AH_overlimb, /datum/appearanceHolder))
			switch(src.limb_overlay_1_color)
				if(CUST_1)
					colorlimb_heck = AH_overlimb.customization_first_color
				if(CUST_2)
					colorlimb_heck = AH_overlimb.customization_second_color
				if(CUST_3)
					colorlimb_heck = AH_overlimb.customization_third_color
				if (SKIN_TONE)
					colorlimb_heck = src.skin_tone
				else
					colorlimb_heck = "#FFFFFF"
		var/colorhandfoot_heck = "#FFFFFF"
		if(istype(AH_overlimb, /datum/appearanceHolder))
			switch(src.handfoot_overlay_1_color)
				if(CUST_1)
					colorhandfoot_heck = AH_overlimb.customization_first_color
				if(CUST_2)
					colorhandfoot_heck = AH_overlimb.customization_second_color
				if(CUST_3)
					colorhandfoot_heck = AH_overlimb.customization_third_color
				if (SKIN_TONE)
					colorhandfoot_heck = src.skin_tone
				else
					colorhandfoot_heck = "#FFFFFF"
		src.limb_overlay_1 = image(icon = src.limb_overlay_1_icon, icon_state = src.limb_overlay_1_state)
		src.limb_overlay_1?.color = colorlimb_heck
		src.handfoot_overlay_1 = image(icon = src.handfoot_overlay_1_icon, icon_state = src.handfoot_overlay_1_state)
		src.handfoot_overlay_1?.color = colorhandfoot_heck

	/// Gets an appearanceholder, either the owner's or the one in the limb
	proc/get_owner_appearance_holder()
		if (src.original_holder?.bioHolder?.mobAppearance)
			. = src.original_holder.bioHolder.mobAppearance
		else if (istype(src.holder_ahol, /datum/appearanceHolder))
			. = src.holder_ahol

/obj/item/parts/human_parts/arm
	name = "placeholder item (don't use this!)"
	desc = "A human arm."
	override_attack_hand = 0 //to hit with an item instead of hand when used empty handed
	can_hold_items = 1
	var/rebelliousness = 0
	var/strangling = 0

	on_holder_examine()
		if (src.show_on_examine)
			return "has [bicon(src)] \an [initial(src.name)] attached as a"

	proc/foreign_limb_effect()
		if(rebelliousness < 10 && prob(20))
			rebelliousness += 1

		if(strangling == 1)
			if(holder.losebreath < 5) holder.losebreath = 5
			if(prob(20-rebelliousness))
				holder.visible_message("<span class='alert'>[holder.name] stops trying to strangle themself.</span>", "<span class='alert'>You manage to pull your [src.name] away from your throat!</span>")
				strangling = 0
				holder.losebreath -= 5
			return

		if(prob(rebelliousness*2)) //Emote
			boutput(holder, "<span class='alert'>Your [src.name] moves by itself!</span>")
			holder.emote(pick("snap", "shrug", "clap", "flap", "aflap", "raisehand", "crackknuckles","rude","gesticulate","wgesticulate","nosepick","flex","facepalm","airquote","flipoff","shakefist"))
		else if(prob(rebelliousness)) //Slap self
			boutput(holder, "<span class='alert'>Your [src.name] moves by itself!</span>")
			holder.emote("slap")
		else if(prob(rebelliousness) && holder.get_eye_blurry() == 0) //Poke own eye
			holder.visible_message("<span class='alert'>[holder.name] pokes themself in the eye with their [src.name].</span>", "<span class='alert'>Your [src.name] pokes you in the eye!</span>")
			holder.change_eye_blurry(10)
		else if(prob(rebelliousness) && holder.losebreath == 0) //Strangle self
			holder.visible_message("<span class='alert'>[holder.name] tries to strangle themself with their [src.name].</span>", "<span class='alert'>Your [src.name] tries to strangle you!</span>")
			holder.emote("gasp")
			holder.losebreath = 5
			strangling = 1

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


/obj/item/parts/human_parts/arm/left
	name = "left arm"
	desc = "According to superstition, left handed people are unlucky. Whoever lost this sure seems to back that belief up."
	icon_state = "arm_left"
	item_state = "arm-left"
	slot = "l_arm"
	handlistPart = "hand_left"

	disposing()
		if (src.holder)
			if (ishuman(src.holder))
				var/mob/living/carbon/human/H = src.holder
				H.drop_from_slot(H?.l_hand)
		. = ..()

/obj/item/parts/human_parts/arm/right
	name = "right arm"
	desc = "Someone's right hand.... hand. Or arm, whatever."
	icon_state = "arm_right"
	item_state = "arm-right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

	disposing()
		if (src.holder)
			if (ishuman(src.holder))
				var/mob/living/carbon/human/H = src.holder
				H.drop_from_slot(H?.r_hand)
		. = ..()

/obj/item/parts/human_parts/leg
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
			boutput(holder, "<span class='alert'><b>Your [src.name] moves by itself!</b></span>")
			holder.emote(pick("shakebutt", "flap", "aflap","stretch","dance","fart","twitch","twitch_v","flip"))
		else if(prob(rebelliousness)) //Trip over
			boutput(holder, "<span class='alert'><b>Your [src.name] moves by itself!</b></span>")
			holder.emote(pick("trip", "collapse"))
		else if(prob(rebelliousness)) //Slow down
			boutput(holder, "<span class='alert'><b>Your [src.name] is slowing you down!</b></span>")
			holder.setStatusMin("slowed", 1 SECOND)
		else if(prob(rebelliousness)) //Stumble around
			boutput(holder, "<span class='alert'><b>Your [src.name] won't do what you tell it to!</b></span>")
			if (holder.misstep_chance < 20)
				holder.change_misstep_chance(20)

/obj/item/parts/human_parts/leg/left
	name = "left leg"
	icon_state = "leg_left"
	item_state = "leg-left"
	slot = "l_leg"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/right
	name = "right leg"
	icon_state = "leg_right"
	item_state = "leg-right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//gimmick parts

#define ORIGINAL_FLAGS_CANT_DROP 1
#define ORIGINAL_FLAGS_CANT_SELF_REMOVE 2
#define ORIGINAL_FLAGS_CANT_OTHER_REMOVE 4

/obj/item/parts/human_parts/arm/left/item
	name = "left item arm"
	decomp_affected = 0
	limb_type = /datum/limb/item
	streak_decal = /obj/decal/cleanable/oil // what streaks everywhere when it's cut off?
	streak_descriptor = "oily" //bloody, oily, etc
	override_attack_hand = 1
	can_hold_items = 0
	remove_object = null
	handlistPart = null
	partlistPart = null
	no_icon = 1
	skintoned = 0
	var/special_icons = 'icons/mob/human.dmi'
	var/original_flags = 0
	var/image/handimage = 0
	random_limb_blacklisted = 1
	/// No more yee eating csaber arms
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ITEM)

	New(new_holder, var/obj/item/I)
		..()
		if (I)
			src.set_item(I)

	set_loc(var/newloc)
		..()
		if (!ismob(loc))
			return
		var/ret = null
		if (!ismob(newloc))
			if (remove_object)
				remove_object.set_loc(newloc)
				ret = remove_object
			src.loc = null
			if (!disposed)
				qdel(src)
		else
			ret = src
		return ret


	proc/set_item(var/obj/item/I)
		var/mob/living/carbon/human/H = null
		if (ishuman(src.holder))
			H = src.holder
		else if (ishuman(src.loc))
			H = src.loc
		if (H)
			H.l_hand = I
			if (istype(I))
				I.pickup(H)
			I.add_fingerprint(H)
			I.layer = HUD_LAYER+2
			I.screen_loc = ui_lhand
			if (H.client)
				H.client.screen += I
			H.update_inhands()

		name = "left [I.name] arm"
		remove_object = I//I.type
		I.set_loc(src)
		remove_object.temp_flags |= IS_LIMB_ITEM
		if (istype(I))
			//if(I.over_clothes) handlistPart += "l_arm_[I.arm_icon]"
			//else partlistPart += "l_arm_[I.arm_icon]"
			handlistPart += "l_arm_[I.arm_icon]"
			override_attack_hand = I.override_attack_hand
			can_hold_items = I.can_hold_items

			if (I.cant_drop)
				original_flags |= ORIGINAL_FLAGS_CANT_DROP
			if (I.cant_self_remove)
				original_flags |= ORIGINAL_FLAGS_CANT_SELF_REMOVE
			if (I.cant_other_remove)
				original_flags |= ORIGINAL_FLAGS_CANT_OTHER_REMOVE

			I.cant_drop = 1
			I.cant_self_remove = 1
			I.cant_other_remove = 1

			handimage = I.inhand_image
			var/state = I.item_state ? I.item_state + "-LR" : (I.icon_state ? I.icon_state + "-LR" : "LR")
			if(!(state in icon_states(I.inhand_image_icon)))
				state = I.item_state ? I.item_state + "-L" : (I.icon_state ? I.icon_state + "-L" : "L")
			handimage.icon_state = state

			if (H.mutantrace)
				handimage.pixel_y = H.mutantrace.hand_offset + 6
			else
				handimage.pixel_y = 6

			if (H)
				//H.update_clothing()
				H.update_body()
				H.update_inhands()
				H.hud.add_other_object(H.l_hand,H.hud.layouts[H.hud.layout_style]["lhand"])


	proc/remove_from_mob(delete = 0)

		if (isitem(remove_object))
			remove_object.cant_drop = (original_flags & ORIGINAL_FLAGS_CANT_DROP) ? 1 : 0
			remove_object.cant_self_remove = (original_flags & ORIGINAL_FLAGS_CANT_SELF_REMOVE) ? 1 : 0
			remove_object.cant_other_remove = (original_flags & ORIGINAL_FLAGS_CANT_OTHER_REMOVE) ? 1 : 0

			remove_object.temp_flags &= ~IS_LIMB_ITEM
		if (src.holder)
			src.holder.u_equip(remove_object)

			var/mob/living/carbon/human/H = null
			if (ishuman(src.holder))
				H = src.holder
			if (H && H.l_hand == remove_object)
				H.l_hand = null

		if (delete && remove_object)
			qdel(remove_object)
			remove_object = null

	getHandIconState()
		if (handlistPart && !(handlistPart in icon_states(special_icons)))
			.= handimage
		else
			.=..()

	getPartIconState()
		if (partlistPart && !(partlistPart in icon_states(special_icons)))
			.= handimage
		else
			.=..()


	remove(var/show_message = 1)
		remove_from_mob(0)
		..()

	sever()
		remove_from_mob(0)
		..()

	disposing()
		remove_from_mob(1)
		..()

	on_holder_examine()
		if (src.remove_object)
			return "has [bicon(src.remove_object)] \an [src.remove_object] attached as a"

/obj/item/parts/human_parts/arm/right/item
	name = "right item arm"
	decomp_affected = 0
	limb_type = /datum/limb/item
	streak_decal = /obj/decal/cleanable/oil // what streaks everywhere when it's cut off?
	streak_descriptor = "oily" //bloody, oily, etc
	override_attack_hand = 1
	can_hold_items = 0
	remove_object = null
	handlistPart = null
	partlistPart = null
	no_icon = 1
	skintoned = 0
	var/original_flags = 0
	var/image/handimage = 0
	var/special_icons = 'icons/mob/human.dmi'
	random_limb_blacklisted = 1
	/// Also, item arms are supposedly junk jammed into a severed limb's socket
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ITEM)

	New(new_holder, var/obj/item/I)
		..()
		if (I)
			src.set_item(I)

	proc/set_item(var/obj/item/I)
		var/mob/living/carbon/human/H = null
		if (ishuman(src.holder))
			H = src.holder
		else if (ishuman(src.loc))
			H = src.loc
		if (H)
			H.r_hand = I
			if (istype(I))
				I.pickup(H)
			I.add_fingerprint(H)
			I.layer = HUD_LAYER+2
			I.screen_loc = ui_rhand
			if (H.client)
				H.client.screen += I
			H.update_inhands()

		name = "right [I.name] arm"
		remove_object = I//.type
		I.set_loc(src)
		remove_object.temp_flags |= IS_LIMB_ITEM
		if (istype(I))
			//if(I.over_clothes) handlistPart += "r_arm_[I.arm_icon]"
			//else partlistPart += "r_arm_[I.arm_icon]"
			handlistPart += "r_arm_[I.arm_icon]"
			override_attack_hand = I.override_attack_hand
			can_hold_items = I.can_hold_items

			if (I.cant_drop)
				original_flags |= ORIGINAL_FLAGS_CANT_DROP
			if (I.cant_self_remove)
				original_flags |= ORIGINAL_FLAGS_CANT_SELF_REMOVE
			if (I.cant_other_remove)
				original_flags |= ORIGINAL_FLAGS_CANT_OTHER_REMOVE

			I.cant_drop = 1
			I.cant_self_remove = 1
			I.cant_other_remove = 1

			handimage = I.inhand_image
			var/state = I.item_state ? I.item_state + "-LR" : (I.icon_state ? I.icon_state + "-LR" : "LR")
			if(!(state in icon_states(I.inhand_image_icon)))
				state = I.item_state ? I.item_state + "-R" : (I.icon_state ? I.icon_state + "-R" : "R")

			handimage.icon_state = state
			if (H.mutantrace)
				handimage.pixel_y = H.mutantrace.hand_offset + 6
			else
				handimage.pixel_y = 6

			if (H)
				H.update_clothing()
				H.update_body()
				H.set_body_icon_dirty()
				H.update_inhands()
				H.hud.add_other_object(H.r_hand,H.hud.layouts[H.hud.layout_style]["rhand"])

	proc/remove_from_mob(delete = 0)
		if (isitem(remove_object))
			remove_object.cant_drop = (original_flags & ORIGINAL_FLAGS_CANT_DROP) ? 1 : 0
			remove_object.cant_self_remove = (original_flags & ORIGINAL_FLAGS_CANT_SELF_REMOVE) ? 1 : 0
			remove_object.cant_other_remove = (original_flags & ORIGINAL_FLAGS_CANT_OTHER_REMOVE) ? 1 : 0

			remove_object.temp_flags &= ~IS_LIMB_ITEM
		if (src.holder)
			src.holder.u_equip(remove_object)

			var/mob/living/carbon/human/H = null
			if (ishuman(src.holder))
				H = src.holder
			if (H && H.r_hand == remove_object)
				H.r_hand = null

		if (delete && remove_object)
			qdel(remove_object)

	getHandIconState()
		if (handlistPart && !(handlistPart in icon_states(special_icons)))
			.= handimage
		else
			.=..()

	getPartIconState()
		if (partlistPart && !(partlistPart in icon_states(special_icons)))
			.= handimage
		else
			.=..()

	remove(var/show_message = 1)
		remove_from_mob(0)
		..()

	sever()
		remove_from_mob(0)
		..()

	disposing()
		remove_from_mob(1)
		..()

	on_holder_examine()
		if (src.remove_object)
			return "has [bicon(src.remove_object)] \an [src.remove_object] attached as a"

/obj/item/parts/human_parts/arm/left/brullbar
	name = "left brullbar arm"
	icon_state = "arm_left_brullbar"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/brullbar
	handlistPart = "l_hand_brullbar"
	show_on_examine = 1
	/// Brullbar are pretty unnatural, and most people'd miss em if they suddenly turned into a lizard arm
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_brullbar")
		return standImage

/obj/item/parts/human_parts/arm/right/brullbar
	name = "right brullbar arm"
	icon_state = "arm_right_brullbar"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/brullbar
	handlistPart = "r_hand_brullbar"
	show_on_examine = 1
	/// If you went through the trouble to get yourself a wendy arm, you should keep it no matter how inhuman you become
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_brullbar")
		return standImage

/obj/item/parts/human_parts/arm/left/hot
	name = "left hot arm"
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	handlistPart = "hand_left"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_HOT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/right/hot
	name = "right hot arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	handlistPart = "hand_right"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_HOT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/parts/human_parts/arm/left/bear
	name = "left bear arm"
	desc = "Dear god it's still wiggling."
	icon_state = "arm_left_bear"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	handlistPart = "l_hand_bear"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BEAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		set_skin_tone()
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_bear")
		return standImage

/obj/item/parts/human_parts/arm/right/bear
	name = "right bear arm"
	desc = "Dear god it's still wiggling."
	icon_state = "arm_right_bear"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	handlistPart = "r_hand_bear"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BEAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		set_skin_tone()
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_bear")
		return standImage

/obj/item/parts/human_parts/arm/left/synth
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_left_plant"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	handlistPart = "l_hand_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1
	/// Plants are pretty unnatural
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/arm/right/synth
	name = "synthetic right arm"
	desc = "A right arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_right_plant"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	handlistPart = "r_hand_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/leg/left/synth
	name = "synthetic left leg"
	desc = "A left leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "leg_left_plant"
	slot = "l_leg"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	partlistPart = "l_foot_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/leg/right/synth
	name = "synthetic right leg"
	desc = "A right leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "leg_right_plant"
	slot = "r_leg"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	partlistPart = "r_foot_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_PLANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage


/obj/item/parts/human_parts/arm/left/synth/bloom
	desc = "A left arm. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "arm_left_plant_bloom"
	handlistPart = "l_hand_plant"
	name_thing = "plant_bloom"

/obj/item/parts/human_parts/arm/right/synth/bloom
	desc = "A right arm. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "arm_right_plant_bloom"
	handlistPart = "r_hand_plant"
	name_thing = "plant_bloom"

/obj/item/parts/human_parts/leg/left/synth/bloom
	desc = "A left leg. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "leg_left_plant_bloom"
	partlistPart = "l_foot_plant"
	name_thing = "plant_bloom"

/obj/item/parts/human_parts/leg/right/synth/bloom
	desc = "A right leg. Looks like a rope composed of vines. There's some little flowers on it."
	icon_state = "leg_right_plant_bloom"
	partlistPart = "r_foot_plant"
	name_thing = "plant_bloom"

// Added shambler, werewolf and hunter arms, including the sprites (Convair880).
/obj/item/parts/human_parts/arm/left/abomination
	name = "left chitinous tendril"
	desc = "Some sort of alien tendril with very sharp edges. Seems to be moving on its own..."
	icon_state = "arm_left_abomination"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination
	handlistPart = "l_hand_abomination"
	show_on_examine = 1
	/// About as unnatural as it gets
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ABOM)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	sever(mob/user)
		. = ..()
		src.visible_message("<span class='alert'>[src] rapidly keratinizes!</span>")
		var/obj/item/parts/human_parts/arm/left/claw/newlimb = new(src.loc)
		newlimb.original_DNA = src.original_DNA
		newlimb.original_holder = src.original_holder
		newlimb.original_fprints = src.original_fprints
		qdel(src)

	remove(show_message)
		. = ..()
		src.visible_message("<span class='alert'>[src] rapidly keratinizes!</span>")
		var/obj/item/parts/human_parts/arm/left/claw/newlimb = new(src.loc)
		newlimb.original_DNA = src.original_DNA
		newlimb.original_holder = src.original_holder
		newlimb.original_fprints = src.original_fprints
		qdel(src)

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_abomination")
		return standImage

/obj/item/parts/human_parts/arm/right/abomination
	name = "right chitinous tendril"
	desc = "Some sort of alien tendril with very sharp edges. Seems to be moving on its own..."
	icon_state = "arm_right_abomination"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination
	handlistPart = "r_hand_abomination"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ABOM)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	sever(mob/user)
		. = ..()
		src.visible_message("<span class='alert'>[src] rapidly keratinizes!</span>")
		var/obj/item/parts/human_parts/arm/right/claw/newlimb = new(src.loc)
		newlimb.original_DNA = src.original_DNA
		newlimb.original_holder = src.original_holder
		newlimb.original_fprints = src.original_fprints
		qdel(src)

	remove(show_message)
		. = ..()
		src.visible_message("<span class='alert'>[src] rapidly keratinizes!</span>")
		var/obj/item/parts/human_parts/arm/right/claw/newlimb = new(src.loc)
		newlimb.original_DNA = src.original_DNA
		newlimb.original_holder = src.original_holder
		newlimb.original_fprints = src.original_fprints
		qdel(src)

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_abomination")
		return standImage

/obj/item/parts/human_parts/arm/left/zombie
	name = "left rotten arm"
	desc = "A rotten hunk of human junk."
	icon = 'icons/mob/vampiric_thrall.dmi'
	partIcon = 'icons/mob/vampiric_thrall.dmi'
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	override_attack_hand = 1
	can_hold_items = 0
	limb_type = /datum/limb/zombie //Basically zombie arms am I right?
	skintoned = 1
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	/// Supernatural if not abnormally gross
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ZOMBIE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/right/zombie
	name = "right rotten arm"
	desc = "A rotten hunk of human junk."
	icon = 'icons/mob/vampiric_thrall.dmi'
	partIcon = 'icons/mob/vampiric_thrall.dmi'
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	override_attack_hand = 1
	can_hold_items = 0
	limb_type = /datum/limb/zombie //Basically zombie arms am I right?
	skintoned = 1
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ZOMBIE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()


/obj/item/parts/human_parts/arm/left/claw
	name = "left claw arm"
	icon_state = "arm_left_brullbar"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	handlistPart = "l_hand_brullbar"
	siemens_coefficient = 0
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_brullbar")
		return standImage

/obj/item/parts/human_parts/arm/right/claw
	name = "right claw arm"
	icon_state = "arm_right_brullbar"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	handlistPart = "r_hand_brullbar"
	siemens_coefficient = 0
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_BRULLBAR)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_brullbar")
		return standImage

/obj/item/parts/human_parts/arm/right/stone
	name = "synthetic right arm"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "arm_right_stone"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	handlistPart = "r_hand_stone"
	var/name_thing = "stone"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/arm/left/stone
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "arm_left_stone"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	handlistPart = "l_hand_stone"
	var/name_thing = "stone"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/leg/left/stone
	name = "synthetic left leg"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "leg_left_stone"
	slot = "l_leg"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	partlistPart = "l_foot_stone"
	var/name_thing = "stone"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/leg/right/stone
	name = "synthetic right leg"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "leg_right_stone"
	slot = "r_leg"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	partlistPart = "r_foot_stone"
	var/name_thing = "stone"
	show_on_examine = 1
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_STONE)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage


////// MUTANT PARENT PARTS //////
/obj/item/parts/human_parts/arm/mutant
	name = "left mutant arm"
	desc = "An arm that definitely does not look human."
	icon = 'icons/mob/cow.dmi'
	partIcon = 'icons/mob/cow.dmi'
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"
	skintoned = 0
	kind_of_limb = (LIMB_MUTANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/leg/mutant
	name = "left mutant leg!"
	desc = "A leg that definitely does not look human."
	icon = 'icons/mob/cow.dmi'
	partIcon = 'icons/mob/cow.dmi'
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"
	skintoned = 0
	kind_of_limb = (LIMB_MUTANT)

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

//// COW LIMBS ////
///// PARENT  /////

/obj/item/parts/human_parts/arm/mutant/cow
	icon = 'icons/mob/cow.dmi'
	partIcon = 'icons/mob/cow.dmi'

/obj/item/parts/human_parts/leg/mutant/cow
	icon = 'icons/mob/cow.dmi'
	partIcon = 'icons/mob/cow.dmi'
	limb_hit_bonus = 4
	skintoned = 1
	handfoot_overlay_1_icon = 'icons/mob/cow.dmi'
	handfoot_overlay_1_state = null
	handfoot_overlay_1_color = CUST_2

	New()
		handfoot_overlay_1_state = "[src.partlistPart]"
		. = ..()

//// LIMBS ////
/obj/item/parts/human_parts/arm/mutant/cow/left
	name = "left cow arm"
	desc = "A cow's left arm. Moo."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/cow/right
	name = "right cow arm"
	desc = "A cow's right arm. Oom."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/cow/left
	name = "left cow leg"
	desc = "A cow's left leg. Shanked a bit too hard, presumably."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/cow/right
	name = "right cow leg"
	desc = "A cow's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

	New(var/atom/holder)
		. = ..()
		if(prob(1))
			src.desc += " Bears the brand of a legendary roleplayer."

//// PUG LIMBS ////

/obj/item/parts/human_parts/arm/mutant/pug
	icon = 'icons/mob/pug/fawn.dmi'
	partIcon = 'icons/mob/pug/fawn.dmi'

/obj/item/parts/human_parts/arm/mutant/pug/left
	name = "left pug arm"
	desc = "A pug's left arm. Pawsitive."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/pug/right
	name = "right pug arm"
	desc = "A pug's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/pug
	icon = 'icons/mob/pug/fawn.dmi'
	partIcon = 'icons/mob/pug/fawn.dmi'

/obj/item/parts/human_parts/leg/mutant/pug/left
	name = "left pug leg"
	desc = "A pug's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/pug/right
	name = "right pug leg"
	desc = "A pug's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// LIZARD LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/lizard
	icon = 'icons/mob/lizard.dmi'
	partIcon = 'icons/mob/lizard.dmi'
	skintoned = 1

/obj/item/parts/human_parts/leg/mutant/lizard
	icon = 'icons/mob/lizard.dmi'
	partIcon = 'icons/mob/lizard.dmi'
	skintoned = 1

////// ACTUAL LIZARD LIMBS //////
/obj/item/parts/human_parts/arm/mutant/lizard/left
	name = "left lizard arm"
	desc = "A lizard'sss left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/lizard/right
	name = "right lizard arm"
	desc = "A lizard'ssss right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/lizard/left
	name = "left lizard leg"
	desc = "A lizard'ss left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/lizard/right
	name = "right lizard leg"
	desc = "A lizard'sssss right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// AMPHIBIAN LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/amphibian
	icon = 'icons/mob/amphibian.dmi'
	partIcon = 'icons/mob/amphibian.dmi'

/obj/item/parts/human_parts/leg/mutant/amphibian
	icon = 'icons/mob/amphibian.dmi'
	partIcon = 'icons/mob/amphibian.dmi'

////// ACTUAL AMPHIBIAN LIMBS //////
/obj/item/parts/human_parts/arm/mutant/amphibian/left
	name = "left amphibian arm"
	desc = "A amphibian's left arm. Croak."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/amphibian/right
	name = "right amphibian arm"
	desc = "A amphibian's right arm. Froak."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/amphibian/left
	name = "left amphibian leg"
	desc = "A amphibian's left leg. Croak."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/amphibian/right
	name = "right amphibian leg"
	desc = "A amphibian's right leg. Froak"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// SHELTERFROG LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/shelterfrog
	icon = 'icons/mob/shelterfrog.dmi'
	partIcon = 'icons/mob/shelterfrog.dmi'

/obj/item/parts/human_parts/leg/mutant/shelterfrog
	icon = 'icons/mob/shelterfrog.dmi'
	partIcon = 'icons/mob/shelterfrog.dmi'

////// ACTUAL SHELTERFROG LIMBS //////
/obj/item/parts/human_parts/arm/mutant/shelterfrog/left
	name = "left shelterfrog arm"
	desc = "A shelterfrog's left arm. CroOak."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/shelterfrog/right
	name = "right shelterfrog arm"
	desc = "A shelterfrog's right arm. FrOoOoak."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/shelterfrog/left
	name = "left shelterfrog leg"
	desc = "A shelterfrog's left leg. CroOoOk."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/shelterfrog/right
	name = "right shelterfrog leg"
	desc = "A shelterfrog's right leg. FroOoak"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// ROACH LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/roach
	icon = 'icons/mob/roach.dmi'
	partIcon = 'icons/mob/roach.dmi'
	skintoned = 1

/obj/item/parts/human_parts/leg/mutant/roach
	icon = 'icons/mob/roach.dmi'
	partIcon = 'icons/mob/roach.dmi'
	skintoned = 1

////// ACTUAL ROACH LIMBS //////
/obj/item/parts/human_parts/arm/mutant/roach/left
	name = "left roach arm"
	desc = "An enormous insect's left arm. Ew."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/roach/right
	name = "right roach arm"
	desc = "An enormous insect's right arm. Ew."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/roach/left
	name = "left roach leg"
	desc = "An enormous insect's left leg. Ew."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/roach/right
	name = "right roach leg"
	desc = "An enormous insect's right leg. Ew"
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// CAT LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/cat
	icon = 'icons/mob/cat.dmi'
	partIcon = 'icons/mob/cat.dmi'

/obj/item/parts/human_parts/leg/mutant/cat
	icon = 'icons/mob/cat.dmi'
	partIcon = 'icons/mob/cat.dmi'

////// ACTUAL CAT LIMBS //////
/obj/item/parts/human_parts/arm/mutant/cat/left
	name = "left cat arm"
	desc = "A cat's left arm. Meow."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/cat/right
	name = "right cat arm"
	desc = "A cat's right arm. =3"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/cat/left
	name = "left cat leg"
	desc = "A cat's left leg. =0w0="
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/cat/right
	name = "right cat leg"
	desc = "A cat's right leg. Mrow."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"


//// WEREWOLF LIMBS ////
////// PARENT	//////////
/obj/item/parts/human_parts/leg/mutant/werewolf
	icon = 'icons/mob/werewolf.dmi'
	partIcon = 'icons/mob/werewolf.dmi'
	kind_of_limb = (LIMB_MUTANT | LIMB_WOLF)

/obj/item/parts/human_parts/arm/mutant/werewolf
	icon = 'icons/mob/werewolf.dmi'
	partIcon = 'icons/mob/werewolf.dmi'
	limb_type = /datum/limb/abomination/werewolf
	kind_of_limb = (LIMB_MUTANT | LIMB_WOLF)

	sever(mob/user)
		. = ..()
		src.visible_message("<span class='notice'>[src] withers greatly as it falls off!</span>")
		src.limb_data = new/datum/limb/brullbar/severed_werewolf(src)

	remove(show_message)
		. = ..()
		src.visible_message("<span class='notice'>[src] withers greatly as it falls off!</span>")
		src.limb_data = new/datum/limb/brullbar/severed_werewolf(src)

//// THE ACTUAL WOLFLIMBS ////
/obj/item/parts/human_parts/leg/mutant/werewolf/left
	name = "left werewolf leg"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/werewolf/right
	name = "right werewolf leg"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

/obj/item/parts/human_parts/arm/mutant/werewolf/left
	name = "left werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon = 'icons/mob/werewolf.dmi'
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/mutant/werewolf/right
	name = "right werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon = 'icons/mob/werewolf.dmi'
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	handlistPart = "hand_right"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()
//// VAMPIRE ZOMBIE LIMBS ////
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/vampiric_thrall
	icon = 'icons/mob/vampiric_thrall.dmi'
	partIcon = 'icons/mob/vampiric_thrall.dmi'
	kind_of_limb = (LIMB_MUTANT | LIMB_ZOMBIE)
	limb_type = /datum/limb/zombie

/obj/item/parts/human_parts/leg/mutant/vampiric_thrall
	icon = 'icons/mob/vampiric_thrall.dmi'
	partIcon = 'icons/mob/vampiric_thrall.dmi'
	kind_of_limb = (LIMB_MUTANT | LIMB_ZOMBIE)

//// LIMBS ////
/obj/item/parts/human_parts/arm/mutant/vampiric_thrall/left
	name = "left vampiric thrall arm"
	desc = "A vampiric thrall's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/vampiric_thrall/right
	name = "right vampiric thrall arm"
	desc = "A vampiric thrall's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/vampiric_thrall/left
	name = "left vampiric thrall leg"
	desc = "A vampiric thrall's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/vampiric_thrall/right
	name = "right vampiric thrall leg"
	desc = "A vampiric thrall's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// SKELETON LIMBS ////
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/skeleton
	icon = 'icons/mob/skeleton.dmi'
	partIcon = 'icons/mob/skeleton.dmi'
	easy_attach = 1 // Its just a bone... full of meat. Kind of.
	kind_of_limb = (LIMB_MUTANT | LIMB_SKELLY)
	force = 10
	throw_return = TRUE

/obj/item/parts/human_parts/leg/mutant/skeleton
	icon = 'icons/mob/skeleton.dmi'
	partIcon = 'icons/mob/skeleton.dmi'
	easy_attach = 1
	kind_of_limb = (LIMB_MUTANT | LIMB_SKELLY)
	force = 10
	throw_return = TRUE

//// LIMBS ////
/obj/item/parts/human_parts/arm/mutant/skeleton/left
	name = "left skeleton arm"
	desc = "A skeletal left arm. Spooky."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/skeleton/right
	name = "right skeleton arm"
	desc = "A skeletal right arm. Humerus."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/skeleton/left
	name = "left skeleton leg"
	desc = "A skeletal left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/skeleton/right
	name = "right skeleton leg"
	desc = "A skeletal right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// MONKEY LIMBS ////
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/monkey
	icon = 'icons/mob/monkey.dmi'
	partIcon = 'icons/mob/monkey.dmi'

/obj/item/parts/human_parts/leg/mutant/monkey
	icon = 'icons/mob/monkey.dmi'
	partIcon = 'icons/mob/monkey.dmi'


//// LIMBS ////
/obj/item/parts/human_parts/arm/mutant/monkey/left
	name = "left monkey arm"
	desc = "A monkey's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/monkey/right
	name = "right monkey arm"
	desc = "A monkey's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/monkey/left
	name = "left monkey leg"
	desc = "A monkey's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/monkey/right
	name = "right monkey leg"
	desc = "A monkey's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// SEA MONKEY LIMBS ////
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/seamonkey
	icon = 'icons/mob/seamonkey.dmi'
	partIcon = 'icons/mob/seamonkey.dmi'

/obj/item/parts/human_parts/leg/mutant/seamonkey
	icon = 'icons/mob/seamonkey.dmi'
	partIcon = 'icons/mob/seamonkey.dmi'


//// LIMBS ////
/obj/item/parts/human_parts/arm/mutant/seamonkey/left
	name = "left seamonkey arm"
	desc = "A seamonkey's left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/seamonkey/right
	name = "right seamonkey arm"
	desc = "A seamonkey's right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/seamonkey/left
	name = "left seamonkey leg"
	desc = "A seamonkey's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/seamonkey/right
	name = "right seamonkey leg"
	desc = "A seamonkey's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

//// CHICKEN LIMBS ////
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/chicken
	icon = 'icons/mob/chicken.dmi'
	partIcon = 'icons/mob/chicken.dmi'

/obj/item/parts/human_parts/leg/mutant/chicken
	icon = 'icons/mob/chicken.dmi'
	partIcon = 'icons/mob/chicken.dmi'


//// LIMBS ////

/obj/item/parts/human_parts/leg/mutant/chicken/left
	name = "left chicken leg"
	desc = "A chicken's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

	New(mob/new_holder)
		. = ..()
		if(prob(10))
			src.desc = "A chicken's left drumstick."

/obj/item/parts/human_parts/leg/mutant/chicken/right
	name = "right chicken leg"
	desc = "A chicken's right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

	New(mob/new_holder)
		. = ..()
		if(prob(10))
			src.desc = "A chicken's right drumstick."

//// KUDZU LIMBS ////
//////  PARENT  //////

/obj/item/parts/human_parts/arm/mutant/kudzu
	icon = 'icons/obj/items/human_parts.dmi'
	partIcon = 'icons/mob/human.dmi'
	skintoned = 1
	limb_overlay_1_icon = 'icons/mob/kudzu.dmi'
	handfoot_overlay_1_icon = 'icons/mob/kudzu.dmi'
	severed_overlay_1_icon = 'icons/mob/kudzu.dmi'
	limb_overlay_1_color = null
	handfoot_overlay_1_color = null
	severed_overlay_1_color = null
	easy_attach = 1 // These plants really like humanoid flesh
	kind_of_limb = (LIMB_MUTANT | LIMB_PLANT)

	New()
		limb_overlay_1_state = "[src.slot]_kudzu"
		handfoot_overlay_1_state = "[src.handlistPart]_kudzu"
		severed_overlay_1_state = "[src.icon_state]_kudzu"
		. = ..()

/obj/item/parts/human_parts/leg/mutant/kudzu
	icon = 'icons/obj/items/human_parts.dmi'
	partIcon = 'icons/mob/human.dmi'
	skintoned = 1
	limb_overlay_1_icon = 'icons/mob/kudzu.dmi'
	handfoot_overlay_1_icon = 'icons/mob/kudzu.dmi'
	severed_overlay_1_icon = 'icons/mob/kudzu.dmi'
	limb_overlay_1_color = null
	handfoot_overlay_1_color = null
	severed_overlay_1_color = null
	easy_attach = 1
	kind_of_limb = (LIMB_MUTANT | LIMB_PLANT)

	New()
		limb_overlay_1_state = "[src.slot]_kudzu"
		handfoot_overlay_1_state = "[src.handlistPart]_kudzu"
		severed_overlay_1_state = "[src.icon_state]_kudzu"
		. = ..()

////// ACTUAL KUDZU LIMBS //////
/obj/item/parts/human_parts/arm/mutant/kudzu/left
	name = "left kudzu arm"
	desc = "A kudzu'sss left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/kudzu/right
	name = "right kudzu arm"
	desc = "A kudzu'ssss right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/kudzu/left
	name = "left kudzu leg"
	desc = "A kudzu'ss left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/kudzu/right
	name = "right kudzu leg"
	desc = "A kudzu'sssss right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

/// HUNTER LIMBS ///
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/hunter
	icon = 'icons/mob/hunter.dmi'
	partIcon = 'icons/mob/hunter.dmi'

/obj/item/parts/human_parts/leg/mutant/hunter
	icon = 'icons/mob/hunter.dmi'
	partIcon = 'icons/mob/hunter.dmi'

///// LIMBS /////

/obj/item/parts/human_parts/arm/mutant/hunter/left
	name = "left hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	handlistPart = "hand_left"
	show_on_examine = 1
	limb_is_unnatural = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/mutant/hunter/right
	name = "right hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	handlistPart = "hand_right"
	show_on_examine = 1
	limb_is_unnatural = TRUE

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/leg/mutant/hunter/left
	name = "left hunter leg"
	desc = "A muscular and strong left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/hunter/right
	name = "right hunter leg"
	desc = "A muscular and strong right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

/// VIRTUAL LIMBS ///
///// PARENT /////
/obj/item/parts/human_parts/arm/mutant/virtual
	icon = 'icons/mob/virtual.dmi'
	partIcon = 'icons/mob/virtual.dmi'

/obj/item/parts/human_parts/leg/mutant/virtual
	icon = 'icons/mob/virtual.dmi'
	partIcon = 'icons/mob/virtual.dmi'

///// LIMBS /////

/obj/item/parts/human_parts/arm/mutant/virtual/left
	name = "left virtual arm"
	desc = "A simulated left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/virtual/right
	name = "left virtual arm"
	desc = "A simulated right arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/virtual/left
	name = "left virtual leg"
	desc = "A simulated left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/virtual/right
	name = "right virtual leg"
	desc = "A simulated right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

/// ITHILLID LIMBS ///
///// PARENT /////
/obj/item/parts/human_parts/arm/mutant/ithillid
	icon = 'icons/mob/ithillid.dmi'
	partIcon = 'icons/mob/ithillid.dmi'

/obj/item/parts/human_parts/leg/mutant/ithillid
	icon = 'icons/mob/ithillid.dmi'
	partIcon = 'icons/mob/ithillid.dmi'

///// LIMBS /////

/obj/item/parts/human_parts/arm/mutant/ithillid/left
	name = "left squid arm"
	desc = "A squid's left blub."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/ithillid/right
	name = "left squid arm"
	desc = "Blub squid's right arm"
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/ithillid/left
	name = "left squid leg"
	desc = "A blub's left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/ithillid/right
	name = "right squid leg"
	desc = "A squid's blub leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"

/// PSYCHEDELIC LIMBS ///
///// PARENT /////

/obj/item/parts/human_parts/arm/mutant/flashy
	icon = 'icons/mob/flashy.dmi'
	partIcon = 'icons/mob/flashy.dmi'

/obj/item/parts/human_parts/leg/mutant/flashy
	icon = 'icons/mob/flashy.dmi'
	partIcon = 'icons/mob/flashy.dmi'

///// LIMBS /////

/obj/item/parts/human_parts/arm/mutant/flashy/left
	name = "psychedelic left arm"
	desc = "A polychromatic left arm."
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/mutant/flashy/right
	name = "psychedelic right arm"
	desc = "A polychromatic right arm."
	icon_state = "arm_right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg/mutant/flashy/left
	name = "psychedelic left leg"
	desc = "A polychromatic left leg."
	icon_state = "leg_left"
	slot = "l_leg"
	side = "left"
	partlistPart = "foot_left"
	step_image_state = "footprintsL"

/obj/item/parts/human_parts/leg/mutant/flashy/right
	name = "psychedelic right leg"
	desc = "A polychromatic right leg."
	icon_state = "leg_right"
	slot = "r_leg"
	side = "right"
	partlistPart = "foot_right"
	step_image_state = "footprintsR"
