ABSTRACT_TYPE(/obj/item/parts)

/obj/item/parts
	name = "body part"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = FPRINT | ONBELT | TABLEPASS
	override_attack_hand = 0
	var/skin_tone = "#FFFFFF"
	var/slot = null // which part of the person or robot suit does it go on???????
	var/streak_decal = /obj/decal/cleanable/blood // what streaks everywhere when it's cut off?
	var/streak_descriptor = "bloody" //bloody, oily, etc
	var/datum/limb/limb_data = null // used by arms for attack_hand overrides
	var/limb_type = /datum/limb // the type of limb_data
	var/obj/item/remove_object = null //set to create an item when severed rather than removing the arm itself
	var/side = "left" //used for streak direction
	var/remove_stage = 0 //2 will fall off, 3 is removed
	var/no_icon = 0 //if the only icon is above the clothes layer ie. in the handlistPart list
	var/skintoned = 1 // is this affected by human skin tones? Also if the severed limb uses a separate bloody-stump icon layered on top

	/// Gets overlaid onto the severed limb, under the stump if the limb is skintoned
	/// The icon of this overlay
	var/severed_overlay_1_icon
	/// The state of this overlay
	var/severed_overlay_1_state
	/// The color reference. null for uncolored("#ffffff"), CUST_1/2/3 for one of the mob's haircolors, SKIN_TONE for the mob's skintone
	var/severed_overlay_1_color

	/// Gets sent to update_body to overlay something onto this limb, like kudzu vines. Only handles the limb, not the hand/foot!
	var/image/limb_overlay_1
	/// The icon of this overlay
	var/limb_overlay_1_icon
	/// The state of this overlay
	var/limb_overlay_1_state
	/// The color reference. null for uncolored("#ffffff"), CUST_1/2/3 for one of the mob's haircolors, SKIN_TONE for the mob's skintone
	var/limb_overlay_1_color

	/// Gets sent to update_body to overlay something onto this hand/foot, like kudzu vines. Only handles the hand/foot, not the limb!
	var/image/handfoot_overlay_1
	/// The icon of this overlay
	var/handfoot_overlay_1_icon
	/// The state of this overlay
	var/handfoot_overlay_1_state
	/// The color reference. null for uncolored("#ffffff"), CUST_1/2/3 for one of the mob's haircolors, SKIN_TONE for the mob's skintone
	var/handfoot_overlay_1_color

	var/easy_attach = 0 //Attachable without surgery?

	var/decomp_affected = 1 // set to 1 if this limb has decomposition icons
	var/current_decomp_stage_l = -1
	var/current_decomp_stage_s = -1

	var/mob/living/holder = null

	var/image/standImage	// Used by getMobIcon to pass off to update_body. Typically holds image(the_limb's_icon, "[src.slot]")
	var/image/lyingImage	// Appears to be unused, since we just rotate the sprite through animagic
	var/partIcon = 'icons/mob/human.dmi'	// The icon the mob sprite uses when attached, change if the limb's icon isnt in 'icons/mob/human.dmi'
	var/partDecompIcon = 'icons/mob/human_decomp.dmi'
	var/handlistPart	// Used by getHandIconState to determine the attached-to-mob-sprite hand sprite
	var/partlistPart	// Ditto, but for foot sprites, presumably
	var/datum/bone/bones = null // for medical crap
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0
	var/siemens_coefficient = 1
	var/step_image_state = null // for legs, we leave footprints in this style (located in blood.dmi)
	var/accepts_normal_human_overlays = 1 //for avoiding istype in update icon
	var/datum/movement_modifier/movement_modifier // When attached, applies this movement modifier
	/// If TRUE, it'll resist mutantraces trying to change them
	var/limb_is_unnatural = FALSE
	/// Limb is not attached to its original owner
	var/limb_is_transplanted = FALSE
	/// What kind of limb is this? So we dont have to do dozens of typechecks. is bitflags, check defines/item.dm
	var/kind_of_limb
	/// Can we roll this limb as a random limb?
	var/random_limb_blacklisted = 0

	New(atom/new_holder)
		..()
		if(istype(new_holder, /mob/living))
			src.holder = new_holder
		src.limb_data = new src.limb_type(src)
		if (holder && movement_modifier)
			APPLY_MOVEMENT_MODIFIER(holder, movement_modifier, src.type)

	disposing()
		if (limb_data)
			limb_data.holder = null
		limb_data = null

		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			if(H.limbs.vars[src.slot] == src)
				H.limbs.vars[src.slot] = null

		if (holder)
			if (holder.organHolder)
				for(var/thing in holder.organHolder.organ_list)
					if(thing == "all")
						continue
					if(holder.organHolder.organ_list[thing] == src)
						holder.organHolder.organ_list[thing] = null

			if (holder?.organs?[src.slot] == src)
				holder.organs[src.slot] = null
		holder = null

		if (bones)
			bones.dispose()

		..()

	//just get rid of it. don't put it on the floor, don't show a message
	proc/delete()
		if (holder && movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(holder, movement_modifier, src.type)
		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			H.limbs.vars[src.slot] = null
			H.organs[src.slot] = null
			if(remove_object)
				if (H.l_hand == remove_object)
					H.l_hand = null
				if (H.r_hand == remove_object)
					H.r_hand = null
				src.remove_object = null
			H.update_clothing()
			H.update_body()
			H.set_body_icon_dirty()
			H.UpdateDamageIcon()
		qdel(src)
		return

	proc/remove(var/show_message = 1)
		if (!src.holder) // fix for Cannot read null.loc, hopefully - haine
			if (remove_object)
				src.remove_object = null
				holder = null
				qdel(src)
			return

		if (movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(holder, movement_modifier, src.type)

		var/obj/item/object = src
		if(remove_object)
			object = remove_object
			object.set_loc(src.loc)
			object.cant_drop = initial(object.cant_drop)
		else
			remove_stage = 3
		object.set_loc(src.holder.loc)

		//https://forum.ss13.co/showthread.php?tid=1774
		//object.name = "[src.holder.real_name]'s [initial(object.name)]"
		object.add_fingerprint(src.holder)

		if(show_message) holder.visible_message("<span class='alert'>[holder.name]'s [object.name] falls off!</span>")

		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			H.limbs.vars[src.slot] = null
			if(remove_object)
				src.remove_object = null
				qdel(src)
			//fix for gloves/shoes still displaying after limb loss
			H.update_clothing()
			H.update_body()
			H.set_body_icon_dirty()
			H.UpdateDamageIcon()
			if (src.slot == "l_arm")
				H.drop_from_slot(H.l_hand)
				H.hud.update_hands()
			else if (src.slot == "r_arm")
				H.drop_from_slot(H.r_hand)
				H.hud.update_hands()

		else if(remove_object)
			src.remove_object = null
			qdel(src)
		if(!QDELETED(src))
			src.holder = null
		return object

	proc/sever(var/mob/user)
		if (!src.holder) // fix for Cannot read null.loc, hopefully - haine
			if (remove_object)
				src.remove_object = null
				holder = null
				qdel(src)
			return

		if (movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(holder, movement_modifier, src.type)

		if (user)
			logTheThing(LOG_ADMIN, user, "severed [constructTarget(src.holder,"admin")]'s limb, [src] (<i>type: [src.type], side: [src.side]</i>)")

		var/obj/item/object = src
		if(remove_object)
			object = remove_object
			object.set_loc(src.loc)
			object.layer = initial(object.layer)
		else
			remove_stage = 3

		object.set_loc(src.holder.loc)
		var/direction = src.holder.dir

		//https://forum.ss13.co/showthread.php?tid=1774
		//object.name = "[src.holder.real_name]'s [initial(object.name)]" //Luis Smith's Dr. Kay's Luis Smith's Sailor Dave's Left Arm
		object.add_fingerprint(src.holder)

		holder.visible_message("<span class='alert'>[holder.name]'s [object.name] flies off in a [src.streak_descriptor] arc!</span>")

		switch(direction)
			if(NORTH)
				direction = WEST
			if(EAST)
				direction = NORTH
			if(SOUTH)
				direction = EAST
			if(WEST)
				direction = SOUTH

		if(side != "left")
			direction = turn(direction,180)

		if (isitem(object))
			object.streak_object(direction, src.streak_decal)

		if(prob(60))
			INVOKE_ASYNC(holder, /mob.proc/emote, "scream")

		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			holder = null
			if(H.limbs.vars[src.slot] == src) //BAD BAD HACK FUCK FUCK UGLY SHITCODE - Tarm
				H.limbs.vars[src.slot] = null
			if(remove_object)
				src.remove_object = null
				qdel(src)
			//fix for gloves/shoes still displaying after limb loss
			H.update_clothing()
			H.update_body()
			H.set_body_icon_dirty()
			H.UpdateDamageIcon()
			if (src.slot == "l_arm")
				H.drop_from_slot(H.l_hand)
				H.hud.update_hands()
			else if (src.slot == "r_arm")
				H.drop_from_slot(H.r_hand)
				H.hud.update_hands()

		else if(remove_object)
			src.remove_object = null
			holder = null
			qdel(src)
		if(!QDELETED(src))
			src.holder = null
		return object

	//for humans
	attach(var/mob/living/carbon/human/attachee,var/mob/attacher)
		if(!ishuman(attachee) || attachee.limbs.vars[src.slot])
			return ..()
		if(attacher)
			if(!can_act(attacher))
				return
			if(!src.easy_attach)
				if(!surgeryCheck(attachee, attacher))
					return
			if(attacher.zone_sel.selecting != slot)
				return ..()

			attacher.remove_item(src)

			playsound(attachee, 'sound/effects/attach.ogg', 50, 1)
			attacher.visible_message("<span class='alert'>[attacher] attaches [src] to [attacher == attachee ? his_or_her(attacher) : "[attachee]'s"] stump. It [src.easy_attach ? "fuses instantly" : "doesn't look very secure"]!</span>")

		attachee.limbs.vars[src.slot] = src
		src.holder = attachee
		src.layer = initial(src.layer)
		src.screen_loc = ""
		src.set_loc(attachee)
		src.remove_stage = src.easy_attach ? 0 : 2

		if (movement_modifier)
			APPLY_MOVEMENT_MODIFIER(src.holder, movement_modifier, src.type)

		SPAWN(rand(150,200))
			if(remove_stage == 2) src.remove()

		attachee.update_clothing()
		attachee.update_body()
		attachee.UpdateDamageIcon()
		if (src.slot == "l_arm" || src.slot == "r_arm")
			attachee.hud.update_hands()

		return TRUE

	proc/surgery(var/obj/item/I) //placeholder
		return

	proc/getMobIcon(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if(no_icon) return 0
		var/decomp = ""
		if (src.decomp_affected && decomp_stage)
			decomp = "_decomp[decomp_stage]"
		var/used_icon = getAttachmentIcon(decomp_stage)

		if (lying)
			if (src.lyingImage && ((src.decomp_affected && src.current_decomp_stage_l == decomp_stage) || !src.decomp_affected))
				return src.lyingImage
			//boutput(world, "Attaching lying limb [src.slot][decomp]_l on decomp stage [decomp_stage].")
			current_decomp_stage_l = decomp_stage
			src.lyingImage = image(used_icon, "[src.slot][decomp]_l")
			return lyingImage

		else
			if (src.standImage && ((src.decomp_affected && src.current_decomp_stage_s == decomp_stage) || !src.decomp_affected))
				return src.standImage
			//boutput(world, "Attaching standing limb [src.slot][decomp]_s on decomp stage [decomp_stage].")
			current_decomp_stage_s = decomp_stage
			src.standImage = image(used_icon, "[src.slot][decomp]")
			return standImage

	proc/getAttachmentIcon(var/decomp_stage = DECOMP_STAGE_NO_ROT)
		if (src.decomp_affected && decomp_stage)
			return src.partDecompIcon
		return src.partIcon

	proc/getHandIconState(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		var/decomp = ""
		if (src.decomp_affected && decomp_stage)
			decomp = "_decomp[decomp_stage]"

		//boutput(world, "Attaching standing hand [src.slot][decomp]_s on decomp stage [decomp_stage].")
		return "[src.handlistPart][decomp]"

	proc/getPartIconState(var/lying, var/decomp_stage = DECOMP_STAGE_NO_ROT)
		var/decomp = ""
		if (src.decomp_affected && decomp_stage)
			decomp = "_decomp[decomp_stage]"

		//boutput(world, "Attaching standing part [src.slot][decomp]_s on decomp stage [decomp_stage].")
		return "[src.partlistPart][decomp]"

	proc/on_holder_examine()
		return

/obj/item/proc/streak_object(var/list/directions, var/streak_splatter) //stolen from gibs
	var/destination
	var/dist = rand(1,6)
	if(prob(10))
		dist = 30 // Occasionally throw the chunk somewhere *interesting*
	if(length(directions))
		destination = pick(directions)
		if(!(destination in cardinal))
			destination = null

	if(destination)
		destination = GetRandomPerimeterTurf(get_turf(src), dist, destination)
	else
		destination = GetRandomPerimeterTurf(get_turf(src), dist)

	var/list/linepath = getline(src, destination)

	SPAWN(0)
		/// Number of tiles where it should try to make a splatter
		var/num_splats = rand(round(dist * 0.2), dist) + 1
		for (var/turf/T in linepath)
			if(step_to(src, T, 0, 300) || num_splats-- >= 1)
				if (ispath(streak_splatter))
					make_cleanable(streak_splatter,src.loc)
			sleep(0.1 SECONDS)


var/global/list/all_valid_random_right_arms = filtered_concrete_typesof(/obj/item/parts, /proc/goes_in_right_arm_slot)
var/global/list/all_valid_random_left_arms = filtered_concrete_typesof(/obj/item/parts, /proc/goes_in_left_arm_slot)
var/global/list/all_valid_random_right_legs = filtered_concrete_typesof(/obj/item/parts, /proc/goes_in_right_leg_slot)
var/global/list/all_valid_random_left_legs = filtered_concrete_typesof(/obj/item/parts, /proc/goes_in_left_leg_slot)

/proc/goes_in_right_arm_slot(var/type)
	var/obj/item/parts/fakeInstance = type
	return (((initial(fakeInstance.slot) == "r_arm")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_left_arm_slot(var/type)
	var/obj/item/parts/fakeInstance = type
	return (((initial(fakeInstance.slot) == "l_arm")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_right_leg_slot(var/type)
	var/obj/item/parts/fakeInstance = type
	return (((initial(fakeInstance.slot) == "r_leg")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_left_leg_slot(var/type)
	var/obj/item/parts/fakeInstance = type
	return (((initial(fakeInstance.slot) == "l_leg")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/randomize_mob_limbs(var/mob/living/carbon/human/target, var/mob/user, var/zone = "all", var/showmessage = 1)
	if (!target)
		return 0
	var/datum/human_limbs/targetlimbs = target.limbs
	if (!targetlimbs)
		return 0
	return targetlimbs.randomize(zone, user, showmessage)


