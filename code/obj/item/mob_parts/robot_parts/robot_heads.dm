ABSTRACT_TYPE(/obj/item/parts/robot_parts/head)
/obj/item/parts/robot_parts/head
	name = "cyborg head"
	desc = "A serviceable head unit for a potential cyborg."
	icon_state_base = "head"
	icon_state = "head-generic"
	slot = "head"
	material_amt = ROBOT_HEAD_COST

	var/obj/item/organ/brain/brain = null
	var/obj/item/ai_interface/ai_interface = null
	var/visible_eyes = 1
	// Screen head specific
	/// lod (light-on-dark) or dol (dark-on-light)
	var/mode = "lod"
	var/face = "happy"

	examine()
		. = ..()
		if (src.brain)
			. += SPAN_NOTICE("This head unit has [src.brain] inside. Use a wrench if you want to remove it.")
		else if (src.ai_interface)
			. += SPAN_NOTICE("This head unit has [src.ai_interface] inside. Use a wrench if you want to remove it.")
		else
			. += SPAN_ALERT("This head unit is empty.")

	attackby(obj/item/W, mob/user)
		if (!W)
			return
		if (istype(W,/obj/item/organ/brain))
			if (src.brain)
				boutput(user, SPAN_ALERT("There is already a brain in there. Use a wrench to remove it."))
				return

			if (src.ai_interface)
				boutput(user, SPAN_ALERT("There is already \an [src.ai_interface] in there. Use a wrench to remove it."))
				return

			var/obj/item/organ/brain/B = W
			if ( !(B.owner && B.owner.key) && !istype(W, /obj/item/organ/brain/latejoin) )
				boutput(user, SPAN_ALERT("This brain doesn't look any good to use."))
				return
			user.drop_item()
			B.set_loc(src)
			src.brain = B
			boutput(user, SPAN_NOTICE("You insert the brain."))
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
			return

		else if (istype(W, /obj/item/ai_interface))
			if (src.brain)
				boutput(user, SPAN_ALERT("There is already a brain in there. Use a wrench to remove it."))
				return

			if (src.ai_interface)
				boutput(user, SPAN_ALERT("There is already \an [src.ai_interface] in there!"))
				return

			var/obj/item/ai_interface/I = W
			user.drop_item()
			I.set_loc(src)
			src.ai_interface = I
			boutput(user, SPAN_NOTICE("You insert [I]."))
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
			return

		else if (iswrenchingtool(W))
			if (!src.brain && !src.ai_interface)
				boutput(user, SPAN_ALERT("There's no brain or AI interface chip in there to remove."))
				return
			playsound(src, 'sound/items/Ratchet.ogg', 40, TRUE)
			if (src.ai_interface)
				boutput(user, SPAN_NOTICE("You open the head's compartment and take out [src.ai_interface]."))
				user.put_in_hand_or_drop(src.ai_interface)
				src.ai_interface = null
			else if (src.brain)
				boutput(user, SPAN_NOTICE("You open the head's compartment and take out [src.brain]."))
				user.put_in_hand_or_drop(src.brain)
				src.brain = null
		else
			..()

	reinforce(var/obj/item/sheet/M, var/mob/user, var/obj/item/parts/robot_parts/result, var/need_reinforced)
		if (!src.can_reinforce(M, user, need_reinforced))
			return

		var/obj/item/parts/robot_parts/newitem = new result(get_turf(src))
		newitem.setMaterial(src.material)

		var/obj/item/parts/robot_parts/head/newhead = newitem
		var/obj/item/parts/robot_parts/head/oldhead = src
		if (oldhead.brain)
			newhead.brain = oldhead.brain
			oldhead.brain.set_loc(newhead)
		else if (oldhead.ai_interface)
			newhead.ai_interface = oldhead.ai_interface
			oldhead.ai_interface.set_loc(newhead)

		boutput(user, SPAN_NOTICE("You reinforce [src.name] with the metal."))
		M.change_stack_amount(-2)
		if (M.amount < 1)
			user.drop_item()
			qdel(M)
		SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, newitem, user)
		qdel(src)

/obj/item/parts/robot_parts/head/standard
	name = "standard cyborg head"
	max_health = 160
	robot_movement_modifier = /datum/movement_modifier/robot_part/standard_head
	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/head/sturdy, FALSE)
		else
			..()

/obj/item/parts/robot_parts/head/sturdy
	name = "sturdy cyborg head"
	desc = "A reinforced head unit capable of taking more abuse than usual."
	appearanceString = "sturdy"
	icon_state = "head-sturdy"
	material_amt = ROBOT_HEAD_COST + ROBOT_STURDY_COST
	max_health = 225
	weight = 0.2
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_head
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY) // shush

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/head/heavy, TRUE)
		else
			..()

/obj/item/parts/robot_parts/head/heavy
	name = "heavy cyborg head"
	desc = "A heavily reinforced head unit intended for use on cyborgs that perform tough and dangerous work."
	appearanceString = "heavy"
	icon_state = "head-heavy"
	material_amt = ROBOT_HEAD_COST + ROBOT_HEAVY_COST
	max_health = 350
	weight = 0.4
	robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_head
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

/obj/item/parts/robot_parts/head/light
	name = "light cyborg head"
	desc = "A cyborg head with little reinforcement, to be built in times of scarce resources."
	appearanceString = "light"
	icon_state = "head-light"
	material_amt = ROBOT_HEAD_COST * ROBOT_LIGHT_COST_MOD
	max_health = 60
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_head
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

/obj/item/parts/robot_parts/head/antique
	name = "antique cyborg head"
	desc = "Looks like a discarded prop from some sorta low-budget scifi movie."
	appearanceString = "android"
	icon_state = "head-android"
	max_health = 150
	visible_eyes = 0
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_head

/obj/item/parts/robot_parts/head/screen
	name = "cyborg screen head"
	desc = "A somewhat fragile head unit with a screen addressable by the cyborg."
	appearanceString = "screen"
	icon_state = "head-screen"
	material_amt = ROBOT_SCREEN_METAL_COST
	max_health = 90
	var/list/expressions = list("happy", "veryhappy", "neutral", "sad", "angry", "curious", "surprised", "unsure", "content", "tired", "cheeky","nervous","ditzy","annoyed","skull","eye","sly","elated","blush","battery","error","loading","pong","hypnotized")
	var/smashed = FALSE

	update_icon(...)
		if (src.smashed)
			src.UpdateOverlays(image('icons/obj/robot_parts.dmi', "head-screen-smashed"), "smashed")
		else
			src.UpdateOverlays(null, "smashed")

	ropart_take_damage(var/bluntdmg = 0,var/burnsdmg = 0)
		. = ..() //parent calls del if we get destroyed so no need to handle not doing this
		if (!src.smashed && (bluntdmg > 10 || bluntdmg > 3 && prob(20)))
			src.smashed = TRUE
			src.UpdateIcon()
			var/mob/living/silicon/robot/robo_holder = src.holder
			robo_holder.update_bodypart("head")

	ropart_ex_act(severity, lasttouched, power)
		if (!src.smashed && (severity == 1 || prob(60)))
			src.smashed = TRUE
			src.UpdateIcon()
			//no need to update the holder here as robots do a full update on exploding

	attackby(obj/item/W, mob/user)
		if (src.smashed && istype(W, /obj/item/sheet) && W.material.getMaterialFlags() & MATERIAL_CRYSTAL)
			src.start_repair(W, user)
		else
			..()

	proc/start_repair(obj/item/W, mob/user)
		SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, TYPE_PROC_REF(/obj/item/parts/robot_parts/head/screen, repair), list(W, user),\
			W.icon, W.icon_state, SPAN_ALERT("[user] repairs [src]."), INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	proc/repair(obj/item/sheet/sheets, mob/user)
		sheets.change_stack_amount(-1)
		src.smashed = FALSE
		var/mob/living/silicon/robot/robo_holder = src.holder
		robo_holder?.update_bodypart("head")
		src.UpdateIcon()
		playsound(get_turf(src.holder || src), 'sound/items/Deconstruct.ogg', 40, 1)

/obj/item/parts/robot_parts/head/ancient
	name = "ancient head"
	desc = "The pseudocranium of an ancient silicon utility construct."
	icon_state = "head-ancient"
	appearanceString = "ancient"
	max_health = 200
	weight = 0.5
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_head

	stonecutter
		name = "stonecutter head"
		desc = "The pseudocranium of an ancient silicon stonecutter."
		icon_state = "head-ancient2"
		appearanceString = "ancient2"
		max_health = 100
		weight = 0.3
		robot_movement_modifier = /datum/movement_modifier/robot_part/light_head

	actuator
		name = "actuator head"
		desc = "The pseudocranium of an ancient silicon loader."
		icon_state = "head-ancient3"
		appearanceString = "ancient3"
		max_health = 300
		weight = 0.6
		robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_head

		New()
			. = ..()
			AddComponent(/datum/component/loctargeting/medium_directional_light, 255, 0, 0, 210)
			SEND_SIGNAL(src, COMSIG_LIGHT_ENABLE)

	worker
		name = "worker head"
		desc = "The pseudocranium of an ancient silicon worker."
		icon_state = "head-ancient4"
		appearanceString = "ancient4"
		max_health = 200
		weight = 0.3
		robot_movement_modifier = /datum/movement_modifier/robot_part/standard_head

	guardian
		name = "guardian head"
		desc = "The pseudocranium of an ancient silicon guardian."
		icon_state = "head-ancient5"
		appearanceString = "ancient5"
		max_health = 400
		weight = 0.6
		robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_head
