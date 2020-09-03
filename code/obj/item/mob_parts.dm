/obj/item/parts
	name = "body part"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = FPRINT | ONBELT | TABLEPASS
	override_attack_hand = 0
	var/slot = null // which part of the person or robot suit does it go on???????
	var/streak_decal = /obj/decal/cleanable/blood // what streaks everywhere when it's cut off?
	var/streak_descriptor = "bloody" //bloody, oily, etc
	var/datum/limb/limb_data = null // used by arms for attack_hand overrides
	var/limb_type = /datum/limb // the type of limb_data
	var/obj/item/remove_object = null //set to create an item when severed rather than removing the arm itself
	var/side = "left" //used for streak direction
	var/remove_stage = 0 //2 will fall off, 3 is removed
	var/no_icon = 0 //if the only icon is above the clothes layer ie. in the handlistPart list
	var/skintoned = 1 // is this affected by human skin tones?
	var/easy_attach = 0 //Attachable without surgery?

	var/decomp_affected = 1 // set to 1 if this limb has decomposition icons
	var/current_decomp_stage_l = -1
	var/current_decomp_stage_s = -1

	var/mob/living/holder = null

	var/image/standImage
	var/image/lyingImage
	var/partIcon = 'icons/mob/human.dmi'
	var/partDecompIcon = 'icons/mob/human_decomp.dmi'
	var/handlistPart
	var/partlistPart
	var/datum/bone/bones = null // for medical crap
	var/brute_dam = 0
	var/burn_dam = 0
	var/tox_dam = 0
	var/siemens_coefficient = 1
	var/step_image_state = null // for legs, we leave footprints in this style (located in blood.dmi)
	var/accepts_normal_human_overlays = 1 //for avoiding istype in update icon
	var/datum/movement_modifier/movement_modifier // When attached, applies this movement modifier

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

		if (holder)
			if (holder.organHolder)
				for(var/thing in holder.organHolder.organ_list)
					if(thing == "all")
						continue
					if(holder.organHolder.organ_list[thing] == src)
						holder.organHolder.organ_list[thing] = null

			if (holder.organs)
				holder.organs -= src
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
		if(hasvar(object,"skin_tone"))
			object:skin_tone = holder.bioHolder.mobAppearance.s_tone

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
			logTheThing("admin", user, src.holder, "severed [constructTarget(src.holder,"admin")]'s limb, [src] (<i>type: [src.type], side: [src.side]</i>)")

		var/obj/item/object = src
		if(remove_object)
			object = remove_object
			object.set_loc(src.loc)
			object.layer = initial(object.layer)
		else
			remove_stage = 3

		object.set_loc(src.holder.loc)
		var/direction = src.holder.dir
		if(hasvar(object,"skin_tone"))
			object:skin_tone = holder.bioHolder.mobAppearance.s_tone

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
			object.streak(direction, src.streak_decal)

		if(prob(60)) holder.emote("scream")

		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			holder = null
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

		return object

	//for humans
	attach(var/mob/living/carbon/human/attachee,var/mob/attacher,var/both_legs = 0)
		if(!src.easy_attach)
			if(!surgeryCheck(attachee, attacher))
				return

		if(!both_legs)
			if(attacher.zone_sel.selecting != slot || !ishuman(attachee))
				return ..()

			if(attachee.limbs.vars[src.slot])
				boutput(attacher, "<span class='alert'>[attachee.name] already has one of those!</span>")
				return

			attachee.limbs.vars[src.slot] = src
		else
			if (!(attacher.zone_sel.selecting in list("l_leg","r_leg")))
				return ..()
			else if(attachee.limbs.vars["l_leg"] || attachee.limbs.vars["r_leg"])
				boutput(attacher, "<span class='alert'>[attachee.name] still has one leg!</span>")
				return

			attachee.limbs.l_leg = src
			attachee.limbs.r_leg = src
		src.holder = attachee
		attacher.remove_item(src)
		src.layer = initial(src.layer)
		src.screen_loc = ""
		src.set_loc(attachee)
		src.remove_stage = 2

		if (movement_modifier)
			APPLY_MOVEMENT_MODIFIER(src.holder, movement_modifier, src.type)

		for(var/mob/O in AIviewers(attachee, null))
			if(O == (attacher || attachee))
				continue
			if(attacher == attachee)
				O.show_message("<span class='alert'>[attacher] attaches a [src] to \his own stump[both_legs? "s" : ""]!</span>", 1)
			else
				O.show_message("<span class='alert'>[attachee] has a [src] attached to \his stump[both_legs? "s" : ""] by [attacher].</span>", 1)

		if (src.easy_attach) //No need to make it drop off later if it attaches instantly.
			if(attachee != attacher)
				boutput(attachee, "<span class='alert'>[attacher] attaches a [src] to your stump[both_legs? "s" : ""]. It fuses instantly with the muscles and tendons!</span>")
				boutput(attacher, "<span class='alert'>You attach a [src] to [attachee]'s stump[both_legs? "s" : ""]. It fuses instantly with the muscle and tendons!</span>")
			else
				boutput(attacher, "<span class='alert'>You attach a [src] to your own stump[both_legs? "s" : ""]. It fuses instantly with the muscle and tendons!</span>")
			src.remove_stage = 0
		else
			if(attachee != attacher)
				boutput(attachee, "<span class='alert'>[attacher] attaches a [src] to your stump[both_legs? "s" : ""]. It doesn't look very secure!</span>")
				boutput(attacher, "<span class='alert'>You attach a [src] to [attachee]'s stump[both_legs? "s" : ""]. It doesn't look very secure!</span>")
			else
				boutput(attacher, "<span class='alert'>You attach a [src] to your own stump[both_legs? "s" : ""]. It doesn't look very secure!</span>")

			SPAWN_DBG(rand(150,200))
				if(remove_stage == 2) src.remove()

		attachee.update_clothing()
		attachee.update_body()
		attachee.set_body_icon_dirty()
		attachee.UpdateDamageIcon()
		if (src.slot == "l_arm" || src.slot == "r_arm")
			attachee.hud.update_hands()

		return

	proc/surgery(var/obj/item/I) //placeholder
		return

	proc/getMobIcon(var/lying, var/decomp_stage = 0)
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

	proc/getAttachmentIcon(var/decomp_stage = 0)
		if (src.decomp_affected && decomp_stage)
			return src.partDecompIcon
		return src.partIcon

	proc/getHandIconState(var/lying, var/decomp_stage = 0)
		var/decomp = ""
		if (src.decomp_affected && decomp_stage)
			decomp = "_decomp[decomp_stage]"

		//boutput(world, "Attaching standing hand [src.slot][decomp]_s on decomp stage [decomp_stage].")
		return "[src.handlistPart][decomp]"

	proc/getPartIconState(var/lying, var/decomp_stage = 0)
		var/decomp = ""
		if (src.decomp_affected && decomp_stage)
			decomp = "_decomp[decomp_stage]"

		//boutput(world, "Attaching standing part [src.slot][decomp]_s on decomp stage [decomp_stage].")
		return "[src.partlistPart][decomp]"

	proc/on_holder_examine()
		return

/obj/item/proc/streak(var/direction, var/streak_splatter) //stolen from gibs
	SPAWN_DBG (0)
		if (istype(direction, /list))
			direction = pick(direction)
		for (var/i = 0, i < rand(1,3), i++)
			LAGCHECK(LAG_LOW)//sleep(0.3 SECONDS)
			if (i > 0 && ispath(streak_splatter))
				make_cleanable(streak_splatter,src.loc)
			if (!step_to(src, get_step(src, direction), 0))
				break
