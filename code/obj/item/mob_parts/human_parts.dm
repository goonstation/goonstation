/obj/item/parts/human_parts
	name = "human parts"
	icon = 'icons/obj/items/human_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "arm-left"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	var/skin_tone = "#FFCC99"
	var/mob/living/original_holder = null
	force = 6
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 5
	skintoned = 1
	module_research = list("medicine" = 1)
	module_research_type = /obj/item/parts/human_parts
	var/original_DNA = null
	var/original_fprints = null
	var/show_on_examine = 0

	take_damage(brute, burn, tox, damage_type, disallow_limb_loss)
		if (brute <= 0 && burn <= 0)// && tox <= 0)
			return 0

		src.brute_dam += brute
		src.burn_dam += burn
		//src.tox_dam += tox

		if (ishuman(holder))
			var/mob/living/carbon/human/H = holder
			hit_twitch(H)
			if (brute > 30 && prob(brute - 30) && !disallow_limb_loss)
				src.sever()
			else if (bone_system && src.bones && brute && prob(brute * 2))
				src.bones.take_damage(damage_type)
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

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
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

	New(mob/new_holder)
		..()
		holder = new_holder
		original_holder = new_holder
		if(!src.bones)
			src.bones = new /datum/bone(src)
		src.bones.donor = new_holder
		src.bones.parent_organ = "[src.name]"
		src.setMaterial(getMaterial("bone"), appearance = 0, setname = 0)

		src.add_fingerprint(holder)
		//https://forum.ss13.co/showthread.php?tid=1774
		// zam note - removing this again.
		SPAWN_DBG(2 SECONDS)
			if (new_holder && istype(new_holder))
				name = "[new_holder.real_name]'s [initial(name)]"

		set_skin_tone()


	disposing()
		if(src.bones)
			src.bones.dispose()
		src.bones = null
		original_holder = null
		holder = null
		..()

	proc/set_skin_tone()
		if (!skintoned)
			return
		if (holder && ismob(holder) && holder.bioHolder && holder.bioHolder.mobAppearance)
			skin_tone = holder.bioHolder.mobAppearance.s_tone

		if (src.lyingImage)
			src.lyingImage.color = skin_tone
		if (src.standImage)
			src.standImage.color = skin_tone

	getMobIcon(var/lying)
		. = ..()
		if (skintoned)
			var/newrgb = skin_tone
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

		switch(remove_stage)
			if(0)
				tool.the_mob.visible_message("<span class'alert'>[tool.the_mob] attaches [holder.name]'s [src.name] securely with [tool].</span>", "<span class='alert'>You attach [holder.name]'s [src.name] securely with [tool].</span>")
				logTheThing("combat", tool.the_mob, holder, "staples [constructTarget(holder,"combat")]'s [src.name] back on")
				logTheThing("diary", tool.the_mob, holder, "staples [constructTarget(holder,"diary")]'s [src.name] back on", "combat")
			if(1)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] slices through the skin and flesh of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You slice through the skin and flesh of [holder.name]'s [src.name] with [tool].</span>")
			if(2)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] saws through the bone of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You saw through the bone of [holder.name]'s [src.name] with [tool].</span>")

				SPAWN_DBG(rand(150,200))
					if(remove_stage == 2)
						src.remove(0)
			if(3)
				tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] cuts through the remaining strips of skin holding [holder.name]'s [src.name] on with [tool].</span>", "<span class='alert'>You cut through the remaining strips of skin holding [holder.name]'s [src.name] on with [tool].</span>")
				logTheThing("combat", tool.the_mob, holder, "removes [constructTarget(holder,"combat")]'s [src.name]")
				logTheThing("diary", tool.the_mob, holder, "removes [constructTarget(holder,"diary")]'s [src.name]", "combat")
				src.remove(0)

		if(!isdead(holder))
			if(prob(40))
				holder.emote("scream")
		holder.TakeDamage("chest",20,0)
		take_bleeding_damage(holder, null, 15, DAMAGE_STAB)

		return 1

	remove(var/show_message = 1)
		if ((isnull(src.original_DNA) || isnull(src.original_fprints)) && ismob(src.original_holder))
			if (src.original_holder && src.original_holder.bioHolder) //ZeWaka: Fix for null.bioHolder
				src.original_DNA = src.original_holder.bioHolder.Uid
				src.original_fprints = src.original_holder.bioHolder.uid_hash
		return ..()

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
		if(holder?.handcuffs)
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
	icon_state = "arm_left"
	item_state = "arm-left"
	slot = "l_arm"
	handlistPart = "hand_left"

/obj/item/parts/human_parts/arm/right
	name = "right arm"
	icon_state = "arm_right"
	item_state = "arm-right"
	slot = "r_arm"
	side = "right"
	handlistPart = "hand_right"

/obj/item/parts/human_parts/leg
	name = "placeholder item (don't use this!)"
	desc = "A human leg."
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
			holder.setStatus("slowed", max(holder.getStatusDuration("slowed"), 10))
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

/*
/obj/item/parts/human_parts/arm/left/synth
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of flesh coloured vines. And tofu??"

/obj/item/parts/human_parts/arm/right/synth
	name = "synthetic right arm"
	desc = "A right arm. Looks like a rope composed of flesh coloured vines."

/obj/item/parts/human_parts/leg/left/synth
	name = "synthetic left leg"
	desc = "A left leg. Looks like a rope composed of flesh coloured vines."

/obj/item/parts/human_parts/leg/right/synth
	name = "synthetic right leg"
	desc = "A right leg. Looks like a rope composed of flesh coloured vines."
*/
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
			remove_object = null
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

/obj/item/parts/human_parts/arm/left/wendigo
	name = "left wendigo arm"
	icon_state = "arm_left_wendigo"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/wendigo
	handlistPart = "l_hand_wendigo"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_wendigo")
		return standImage

/obj/item/parts/human_parts/arm/right/wendigo
	name = "right wendigo arm"
	icon_state = "arm_right_wendigo"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/wendigo
	handlistPart = "r_hand_wendigo"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_wendigo")
		return standImage

#if ASS_JAM
/obj/item/parts/human_parts/arm/left/hot
	name = "left hot arm"
	icon_state = "arm_left"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	handlistPart = "hand_left"
	show_on_examine = 1

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
	streak_descriptor = "bloody"
	override_attack_hand = 1
	limb_type = /datum/limb/hot
	handlistPart = "hand_right"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()
#endif

/obj/item/parts/human_parts/arm/left/bear
	name = "left bear arm"
	desc = "Dear god it's still wiggling."
	icon_state = "arm_left_bear"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 1
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	handlistPart = "l_hand_bear"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	skintoned = 1
	streak_descriptor = "bearly"
	override_attack_hand = 1
	limb_type = /datum/limb/bear
	handlistPart = "r_hand_bear"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	handlistPart = "l_hand_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	handlistPart = "r_hand_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	partlistPart = "l_foot_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	partlistPart = "r_foot_plant"
	var/name_thing = "plant"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_abomination")
		return standImage

/obj/item/parts/human_parts/arm/left/werewolf
	name = "left werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "arm_left_werewolf"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	handlistPart = "l_hand_werewolf"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_werewolf")
		return standImage

/obj/item/parts/human_parts/arm/right/werewolf
	name = "right werewolf arm"
	desc = "Huh, lots of fur and very sharp claws."
	icon_state = "arm_right_werewolf"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/abomination/werewolf
	handlistPart = "r_hand_werewolf"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_werewolf")
		return standImage

/obj/item/parts/human_parts/arm/left/zombie
	name = "left rotten arm"
	desc = "A rotten hunk of human junk."
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	override_attack_hand = 1
	limb_type = /datum/limb/bear/zombie //Basically zombie arms am I right?
	skintoned = 1
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/right/zombie
	name = "right rotten arm"
	desc = "A rotten hunk of human junk."
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	override_attack_hand = 1
	limb_type = /datum/limb/bear/zombie //Basically zombie arms am I right?
	skintoned = 1
	streak_descriptor = "undeadly"
	override_attack_hand = 1
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

/obj/item/parts/human_parts/arm/left/hunter
	name = "left hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_left_hunter"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	handlistPart = "l_hand_hunter"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_hunter")
		return standImage

/obj/item/parts/human_parts/arm/right/hunter
	name = "right hunter arm"
	desc = "A muscular and strong arm."
	icon_state = "arm_right_hunter"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	skintoned = 0
	override_attack_hand = 1
	limb_type = /datum/limb/hunter
	handlistPart = "r_hand_hunter"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_hunter")
		return standImage

/obj/item/parts/human_parts/arm/left/claw
	name = "left claw arm"
	icon_state = "arm_left_wendigo"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	handlistPart = "l_hand_wendigo"
	siemens_coefficient = 0
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_wendigo")
		return standImage

/obj/item/parts/human_parts/arm/right/claw
	name = "right claw arm"
	icon_state = "arm_right_wendigo"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	streak_descriptor = "eerie"
	override_attack_hand = 1
	limb_type = /datum/limb/claw
	handlistPart = "r_hand_wendigo"
	siemens_coefficient = 0
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_wendigo")
		return standImage

obj/item/parts/human_parts/arm/right/stone
	name = "synthetic right arm"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "arm_right_stone"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	handlistPart = "r_hand_stone"
	var/name_thing = "stone"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	handlistPart = "l_hand_stone"
	var/name_thing = "stone"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	partlistPart = "l_foot_stone"
	var/name_thing = "stone"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
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
	partlistPart = "r_foot_stone"
	var/name_thing = "stone"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage


obj/item/parts/human_parts/arm/right/reliquary
	name = "synthetic right arm"
	desc = "A right arm. Looks like it's made out of stone. How is that even possible?"
	icon_state = "r_arm_reli"
	slot = "r_arm"
	side = "right"
	decomp_affected = 0
	handlistPart = "hand_right_reli"
	var/name_thing = "reli"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/arm/left/reliquary
	name = "synthetic left arm"
	desc = "A left arm. Looks like a rope composed of vines. And tofu??"
	icon_state = "l_arm_reli"
	slot = "l_arm"
	side = "left"
	decomp_affected = 0
	handlistPart = "hand_left_reli"
	var/name_thing = "reli"
	show_on_examine = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")

/obj/item/parts/human_parts/leg/right/reliquary
	name = "synthetic right leg"
	desc = "A right leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "r_leg_reli"
	slot = "r_leg"
	side = "right"
	decomp_affected = 0
	partlistPart = "foot_right_reli"
	var/name_thing = "reli"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage

/obj/item/parts/human_parts/leg/left/reliquary
	name = "synthetic right leg"
	desc = "A right leg. Looks like a rope composed of vines. And tofu??"
	icon_state = "l_leg_reli"
	slot = "l_leg"
	side = "left"
	decomp_affected = 0
	partlistPart = "foot_left_reli"
	var/name_thing = "reli"
	show_on_examine = 1
	easy_attach = 1

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying, var/decomp_stage = 0)
		if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
			return src.standImage
		current_decomp_stage_s = decomp_stage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
		return standImage
