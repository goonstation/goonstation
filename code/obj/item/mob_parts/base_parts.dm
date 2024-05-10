ABSTRACT_TYPE(/obj/item/mob_part)

/obj/item/mob_part
	name = "body part"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	override_attack_hand = 0
	/// where can it fit?
	var/slot = null
	/// what streaks everywhere when it's cut off?
	var/streak_decal = /obj/decal/cleanable/blood
	/// bloody, oily, etc
	var/streak_descriptor = "bloody"
	/// used by arms for attack_hand overrides
	var/datum/limb/limb_data = null
	/// the type of limb_data
	var/limb_type = /datum/limb

	/// how attached this part is
	var/remove_stage = LIMB_SURGERY_ATTACHED

	/// the mob this part is attached to
	var/mob/living/holder = null

	/// When attached, applies this movement modifier
	var/datum/movement_modifier/movement_modifier
	/// Part is not attached to its original owner
	var/part_is_transplanted = FALSE

	/// set to create an item when severed rather than removing the arm itself
	var/obj/item/remove_object = null

	New(atom/new_holder)
		..()
		if(istype(new_holder, /mob/living))
			src.holder = new_holder
		src.limb_data = new src.limb_type(src)
		if (src.holder && src.movement_modifier)
			APPLY_MOVEMENT_MODIFIER(holder, movement_modifier, src)

	disposing()
		if (src.limb_data)
			src.limb_data.holder = null
			src.limb_data = null

		if (src.holder && src.holder.organHolder)
			for(var/thing in src.holder.organHolder.organ_list)
				if(thing == "all")
					continue
				if(src.holder.organHolder.organ_list[thing] == src)
					src.holder.organHolder.organ_list[thing] = null

		src.holder = null
		..()

	/// just get rid of it. don't put it on the floor, don't show a message
	proc/delete()
		if (src.holder && src.movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(holder, movement_modifier, src)

		qdel(src)
		return

	/// Cut it off, put it on the floor, and show a message sometimes
	proc/remove(var/show_message = TRUE)
		if (!src.holder) // fix for Cannot read null.loc, hopefully - haine
			return

		if (movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(src.holder, src.movement_modifier, src)

		var/obj/item/object = src
		if(remove_object)
			object = remove_object
			object.set_loc(src.loc)
			object.layer = initial(object.layer)
		else
			src.remove_stage = LIMB_SURGERY_DETACHED

		object.set_loc(src.holder.loc)

		object.add_fingerprint(src.holder)

		if(show_message)
			holder.visible_message(SPAN_ALERT("[src.holder.name]'s [object.name] falls off!"))

		if(!QDELETED(src))
			src.holder = null
		return object

	/// Called every life tick when attached to a mob
	proc/on_life(datum/controller/process/mobs/parent)
		return

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part)

/obj/item/mob_part/humanoid_part
	name = "humanoid part"

	/// Which side of the body this limb goes on
	var/side = null
	/// The icon file the mob sprite uses when attached, change if that icon_state isn't in 'icons/mob/human.dmi'
	var/part_icon = 'icons/mob/human.dmi'
	/// The icon file the mob sprite uses when attached and decomposed, change if those icon_states aren't in 'icons/mob/human_decomp.dmi'
	var/part_decomp_icon = 'icons/mob/human_decomp.dmi'

	/// Appended to "[src.slot]_" to form the icon_state, i.e. "brullbar" for brullbar arms
	var/limb_icon_suffix = null
	/// The icon_state of hand_layer_image
	var/hand_layer_icon_state = null

	/// Stores an image to pass off to update_body set on MOB_LIMB_LAYER (this is usually a limb with no hand or foot)
	var/image/limb_layer_image
	/// Stores an image to pass off to update_body set to MOB_HAND_LAYER1 (this is usually a hand or foot)
	var/image/hand_layer_image

	/// If TRUE, it'll resist mutantraces trying to change them
	var/limb_is_unnatural = FALSE
	/// Limb is not attached to its original owner
	var/limb_is_transplanted = FALSE
	/// What kind of limb is this? So we dont have to do dozens of typechecks. is bitflags, check defines/item.dm
	var/kind_of_limb
	/// Can we roll this limb as a random humanoid limb?
	var/random_limb_blacklisted = TRUE
	/// for avoiding istype in update icon
	var/accepts_normal_human_overlays = TRUE

	/// whether this limb appends a unique message on examine
	var/show_on_examine = FALSE

	/// for legs, we leave footprints in this style (located in blood.dmi)
	var/step_image_state = null

	/// set to TRUE if this limb has decomposition icons
	var/decomp_affected = TRUE
	var/current_decomp_stage = DECOMP_STAGE_NO_ROT

	///Attachable without surgery?
	var/easy_attach = FALSE

	/// brute damage taken per surgery stage (times 3.5 for self-surgery)
	var/surgery_brute = 10
	/// bleeding damage taken per surgery stage
	var/surgery_bleeding = 15

	/// stage 1 and 3 surgery messages (for patient/surgeon)
	var/list/cut_messages = list("stupidly slices through", "stupidly slice through")
	/// stage 2 surgery messages (for patient/surgeon)
	var/list/saw_messages = list("throws the saw aside and tears through", "throw the saw aside and tear through")
	/// surgery material messages (per stage)
	var/limb_material = list("Source missing texture","unobtanium","strangelet loaf crust")

	New(var/holder)
		..()
		if (ishuman(holder))
			var/mob/living/carbon/human/H = src.holder
			src.update_images()
			H.update_body()
			H.set_body_icon_dirty()
			H.UpdateDamageIcon()

	delete()
		if(ishuman(src.holder))
			var/mob/living/carbon/human/H = src.holder
			H.limbs.vars[src.slot] = null
			H.update_clothing()
			H.update_body()
			H.set_body_icon_dirty()
			H.UpdateDamageIcon()
		..()

	disposing()
		if(ishuman(src.holder))
			var/mob/living/carbon/human/H = src.holder
			if(H.limbs.vars[src.slot] == src)
				H.limbs.vars[src.slot] = null
		..()

	remove()
		if(ishuman(holder))
			var/mob/living/carbon/human/H = holder
			H.limbs.vars[src.slot] = null
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
		return ..()

	/// A flashier version of remove
	proc/sever(var/mob/user)
		if (user)
			logTheThing(LOG_ADMIN, user, "severed [constructTarget(src.holder,"admin")]'s limb, [src] (<i>type: [src.type], side: [src.side]</i>)")

		var/direction = src.holder.dir
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
		if(prob(60))
			INVOKE_ASYNC(holder, TYPE_PROC_REF(/mob, emote), "scream")
		holder.visible_message(SPAN_ALERT("[holder.name]'s [src.name] flies off in a [src.streak_descriptor] arc!"))

		var/obj/item/object = src.remove(FALSE)
		if (isitem(object))
			object.streak_object(direction, src.streak_decal)

		return object

	/// Updates limb_layer_image and hand_layer_image
	proc/update_images()
		var/decomp = ""
		var/used_icon = src.part_icon
		if (src.decomp_affected && src.current_decomp_stage)
			decomp = "_decomp[src.current_decomp_stage]"
			used_icon = src.part_decomp_icon

		if(src.hand_layer_icon_state)
			src.hand_layer_image = image(used_icon, "[src.hand_layer_icon_state][decomp]", MOB_HAND_LAYER1)

		var/limb_layer_icon_state = "[src.slot][src.limb_icon_suffix ? "_[src.limb_icon_suffix]" : ""][decomp]"
		if (ishuman(src.holder))
			var/mob/living/carbon/human/H = src.holder
			var/typeinfo/datum/mutantrace/typeinfo = H.mutantrace?.get_typeinfo()
			if (H?.mutantrace?.override_limb_icons && (limb_layer_icon_state in typeinfo?.icon_states))
				used_icon = typeinfo.icon // monkeys use this to get smaller cyborg/synthlimbs, etc

		src.limb_layer_image = image(used_icon, limb_layer_icon_state, MOB_LIMB_LAYER)

	proc/surgery(obj/item/tool, mob/surgeon)
		if(remove_stage > 0 && (istype(tool, /obj/item/staple_gun) || istype(tool, /obj/item/suture)) )
			remove_stage = 0

		else if(remove_stage == LIMB_SURGERY_ATTACHED || remove_stage == LIMB_SURGERY_STEP_TWO)
			if(istool(tool, TOOL_CUTTING))
				src.remove_stage++
			else
				return FALSE

		else if(remove_stage == LIMB_SURGERY_STEP_ONE)
			if(istool(tool, TOOL_SAWING))
				src.remove_stage++
			else
				return FALSE

		if(isalive(holder)) // dont scream if dead or unconscious
			if(prob(clamp(src.surgery_brute * 2, 0, 100)))
				holder.emote("scream")

		holder.TakeDamage("chest", src.surgery_brute, 0, 0, DAMAGE_STAB)
		take_bleeding_damage(holder, surgeon, src.surgery_bleeding, DAMAGE_STAB, surgery_bleed = TRUE)

		switch(remove_stage)
			if(LIMB_SURGERY_ATTACHED)
				surgeon.visible_message("<span class'alert'>[surgeon] attaches [src.name] to [holder.name] with [tool].</span>", SPAN_ALERT("You attach [src.name] to [holder.name] with [tool]."))
				logTheThing(LOG_COMBAT, surgeon, "attaches [src.name] to [constructTarget(holder,"combat")].")
			if(LIMB_SURGERY_STEP_ONE)
				surgeon.visible_message(SPAN_ALERT("[surgeon] [src.cut_messages[1]] the [src.limb_material[1]] of [holder.name]'s [src.name] with [tool]."), SPAN_ALERT("You [src.cut_messages[2]] the [src.limb_material[1]] of [holder.name]'s [src.name] with [tool]."))
			if(LIMB_SURGERY_STEP_TWO)
				surgeon.visible_message(SPAN_ALERT("[surgeon] [src.saw_messages[1]] the [src.limb_material[2]] of [holder.name]'s [src.name] with [tool]."), SPAN_ALERT("You [src.saw_messages[2]] the [src.limb_material[2]] of [holder.name]'s [src.name] with [tool]."))

				SPAWN(rand(15, 20) SECONDS)
					if(remove_stage == 2)
						src.remove(FALSE)
			if(LIMB_SURGERY_DETACHED)
				surgeon.visible_message(SPAN_ALERT("[surgeon] [src.cut_messages[1]] the remaining [src.limb_material[3]] holding [holder.name]'s [src.name] on with [tool]."), SPAN_ALERT("You [src.cut_messages[2]] the remaining [src.limb_material[3]] holding [holder.name]'s [src.name] on with [tool]."))
				logTheThing(LOG_COMBAT, surgeon, "removes [src.name] to [constructTarget(holder,"combat")].")
				src.remove(FALSE)

		return TRUE

	attach(var/mob/living/carbon/human/attachee,var/mob/attacher)
		if(!ishuman(attachee) || attachee.limbs.vars[src.slot])
			return FALSE

		var/can_secure = FALSE
		if(attacher)
			can_secure = ismob(attacher) && (attacher?.find_type_in_hand(/obj/item/suture) || attacher?.find_type_in_hand(/obj/item/staple_gun))

			if(!can_act(attacher))
				return
			if(!src.easy_attach)
				if(!surgeryCheck(attachee, attacher))
					return
			if(attacher.zone_sel.selecting != slot)
				return ..()

			attacher.remove_item(src)

			playsound(attachee, 'sound/effects/attach.ogg', 50, TRUE)
			attacher.visible_message(SPAN_ALERT("[attacher] attaches [src] to [attacher == attachee ? his_or_her(attacher) : "[attachee]'s"] stump. It [src.easy_attach ? "fuses instantly" : can_secure ? "looks very secure" : "doesn't look very secure"]!"))

		attachee.limbs.vars[src.slot] = src
		src.holder = attachee
		src.layer = initial(src.layer)
		src.screen_loc = ""
		src.set_loc(attachee)
		src.remove_stage = (src.easy_attach || can_secure) ? 0 : 2

		if (movement_modifier)
			APPLY_MOVEMENT_MODIFIER(src.holder, movement_modifier, src)

		SPAWN(rand(15 SECONDS, 20 SECONDS))
			if(remove_stage == 2)
				src.remove()

		attachee.update_clothing()
		attachee.update_body()
		attachee.set_body_icon_dirty()
		attachee.UpdateDamageIcon()
		if (src.slot == "l_arm" || src.slot == "r_arm")
			attachee.hud.update_hands()

		return TRUE

	proc/on_holder_examine()
		if (src.show_on_examine)
			return "has [bicon(src)] \an [initial(src.name)] attached as a"

#define ORIGINAL_FLAGS_CANT_DROP 1
#define ORIGINAL_FLAGS_CANT_SELF_REMOVE 2
#define ORIGINAL_FLAGS_CANT_OTHER_REMOVE 4

ABSTRACT_TYPE(/obj/item/mob_part/humanoid_part/item_arm)

/obj/item/mob_part/humanoid_part/item_arm
	name = "item arm"
	decomp_affected = FALSE
	limb_type = /datum/limb/item
	streak_decal = /obj/decal/cleanable/oil
	streak_descriptor = "oily"
	override_attack_hand = 1
	can_hold_items = 0
	remove_object = null
	hand_layer_image = null
	hand_layer_icon_state = null
	/// uses defines and flags to determine if you can drop or remove it.
	var/original_flags = 0
	/// temporary until bitflag slots
	var/side_letter = null
	random_limb_blacklisted = TRUE
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
			if (side == "left")
				H.l_hand = I
			else
				H.r_hand = I
			if (istype(I))
				I.pickup(H)
			I.add_fingerprint(H)
			I.layer = HUD_LAYER+2
			I.screen_loc = ui_lhand
			if (H.client)
				H.client.screen += I
			H.update_inhands()

		name = "[side] [I.name] arm"
		remove_object = I//I.type
		I.set_loc(src)
		remove_object.temp_flags |= IS_LIMB_ITEM
		if (istype(I))
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

			src.hand_layer_image = I.inhand_image
			var/state = I.item_state ? I.item_state + "-LR" : (I.icon_state ? I.icon_state + "-LR" : "LR")
			if(!(state in icon_states(I.inhand_image_icon)))
				state = I.item_state ? I.item_state + "-[src.side_letter]" : (I.icon_state ? I.icon_state + "-[src.side_letter]" : "[src.side_letter]")
			src.hand_layer_image.icon_state = state

			if (H)
				H.update_body()
				H.update_inhands()
				H.hud.add_other_object(H.l_hand,H.hud.layouts[H.hud.layout_style]["[src.side == "left" ? "lhand" : "rhand"]"])

	proc/remove_from_mob(delete = FALSE)
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
			if (src.side == "left")
				if(H.l_hand == remove_object)
					H.l_hand = null
			else if(H.r_hand == remove_object)
				H.r_hand = null

		if (delete && remove_object)
			qdel(remove_object)
			remove_object = null

	remove(var/show_message = TRUE)
		remove_from_mob(FALSE)
		..()

	sever()
		remove_from_mob(FALSE)
		..()

	disposing()
		remove_from_mob(TRUE)
		..()

	on_holder_examine()
		if (src.remove_object)
			return "has [bicon(src.remove_object)] \an [src.remove_object] attached as a"

/obj/item/mob_part/humanoid_part/item_arm/left
	name = "left item arm"
	side = "left"
	slot = "l_arm"
	side_letter = "L"

/obj/item/mob_part/humanoid_part/item_arm/right
	name = "right item arm"
	side = "right"
	slot = "r_arm"
	side_letter = "R"

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
		var/num_splats = randfloat(round(dist * 0.2), dist) + 1
		for (var/turf/T in linepath)
			if(step_to(src, T, 0, 300) || num_splats-- >= 1)
				if (ispath(streak_splatter))
					make_cleanable(streak_splatter,src.loc)
			sleep(0.1 SECONDS)

var/global/list/all_valid_random_right_arms = filtered_concrete_typesof(/obj/item/mob_part/humanoid_part, /proc/goes_in_right_arm_slot)
var/global/list/all_valid_random_left_arms = filtered_concrete_typesof(/obj/item/mob_part/humanoid_part, /proc/goes_in_left_arm_slot)
var/global/list/all_valid_random_right_legs = filtered_concrete_typesof(/obj/item/mob_part/humanoid_part, /proc/goes_in_right_leg_slot)
var/global/list/all_valid_random_left_legs = filtered_concrete_typesof(/obj/item/mob_part/humanoid_part, /proc/goes_in_left_leg_slot)

/proc/goes_in_right_arm_slot(var/type)
	var/obj/item/mob_part/humanoid_part/fakeInstance = type
	return (((initial(fakeInstance.slot) == "r_arm")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_left_arm_slot(var/type)
	var/obj/item/mob_part/humanoid_part/fakeInstance = type
	return (((initial(fakeInstance.slot) == "l_arm")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_right_leg_slot(var/type)
	var/obj/item/mob_part/humanoid_part/fakeInstance = type
	return (((initial(fakeInstance.slot) == "r_leg")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/goes_in_left_leg_slot(var/type)
	var/obj/item/mob_part/humanoid_part/fakeInstance = type
	return (((initial(fakeInstance.slot) == "l_leg")) && !(initial(fakeInstance.random_limb_blacklisted)))

/proc/randomize_mob_limbs(var/mob/living/carbon/human/target, var/mob/user, var/zone = "all", var/showmessage = 1)
	if (!target)
		return 0
	var/datum/human_limbs/targetlimbs = target.limbs
	if (!targetlimbs)
		return 0
	return targetlimbs.randomize(zone, user, showmessage)
