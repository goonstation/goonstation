
/datum/surgery_step/limb
	var/affected_limb
	New(datum/surgery/parent_surgery, affected_limb)
		src.affected_limb = affected_limb
		..(parent_surgery)
	cut
		name = "Cut"
		desc = "Cut connective tissues from the limb."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		success_damage = 20
		on_complete(mob/surgeon, obj/item/tool)

			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove_stage = 1
			if(!isdead(C) && prob(40))
				C.emote("scream")
			tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] slices through the skin and flesh of [C.name]'s [limb.name] with [tool]."), SPAN_ALERT("You slice through the skin and flesh of [C.name]'s [limb.name] with [tool]."))
			logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s [limb] with [tool].")

	saw
		name = "Saw"
		desc = "Saw through the bone."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		success_damage = 20
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove_stage = 2
			if(!isdead(C) && prob(40))
				C.emote("scream")
			tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] saws through the bone of [C.name]'s [limb] with [tool]."), SPAN_ALERT("You saw through the bone of [C.name]'s [limb.name] with [tool]."))
			SPAWN(rand(150,200))
				if(limb.remove_stage == 2)
					limb.remove(0)

	remove
		name = "Remove"
		desc = "Remove the limb."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove(0)
			tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] cuts through the remaining strips of skin holding [C.name]'s [limb.name] on with [tool]."), SPAN_ALERT("You cut through the remaining strips of skin holding [C.name]'s [limb.name] on with [tool]."))
			logTheThing(LOG_COMBAT, tool.the_mob, "removes [constructTarget(C,"combat")]'s [limb.name].")
			logTheThing(LOG_DIARY, tool.the_mob, "removes [constructTarget(C,"diary")]'s [limb.name]", "combat")

	attach_arm
		name = "Add"
		desc = "Add the limb."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		success_damage = 0
		do_surgery_step(mob/surgeon, obj/item/tool)
			if (tool.object_flags & NO_ARM_ATTACH || tool.cant_drop || tool.two_handed)
				boutput(surgeon, SPAN_ALERT("You try to attach [tool] to [parent_surgery.patient]'s stump, but it politely declines!"))
				return FALSE
			var/mob/living/carbon/human/C = parent_surgery.patient
			if (C.limbs?.get_limb(affected_limb))
				boutput(surgeon, SPAN_ALERT("[C.name] already has one of those!"))
				return FALSE
			if (!istype(tool,/obj/item/parts/human_parts))
				return FALSE
			return ..()

		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			if (surgeon.find_in_hand(tool))
				surgeon.u_equip(tool)
			var/obj/item/parts/human_parts/arm/limb = null
			if (!istype(tool, /obj/item/parts/human_parts/arm))
				if (affected_limb == "l_arm")
					limb = new /obj/item/parts/human_parts/arm/left/item(patient)
				else if (affected_limb == "r_arm")
					limb = new /obj/item/parts/human_parts/arm/right/item(patient)
				limb.cant_drop = 1
				limb:set_item(tool)
			else
				limb = tool
			limb.attach(patient, surgeon)


		tool_requirement(mob/surgeon, obj/item/tool)
			if (tool.can_arm_attach())
				return TRUE
			return FALSE
	attach_leg
		name = "Add"
		desc = "Add the limb."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			if (surgeon.find_in_hand(tool))
				surgeon.u_equip(tool)
			var/obj/item/parts/human_parts/arm/limb = tool
			limb.attach(C)
			var/can_secure = ismob(surgeon) && (limb.easy_attach || surgeon?.find_type_in_hand(/obj/item/suture) || surgeon?.find_type_in_hand(/obj/item/staple_gun))
			limb.remove_stage = can_secure ? 0 : 2

	skeleton
		can_fail = FALSE
		wrench
			name = "Loosen"
			desc = "Loosen the limb from the socket."
			icon_state = "wrench"
			success_sound = 'sound/items/Screwdriver.ogg'
			flags_required = TOOL_WRENCHING
			success_damage = 0
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> loosens [limb] with [tool]."))
				limb.remove_stage = 1
				logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s [limb] with [tool].")


		crowbar
			name = "Pry"
			desc = "Pry the limb from the socket."
			icon_state = "crowbar"
			success_sound = 'sound/items/Crowbar.ogg'
			flags_required = TOOL_PRYING
			success_damage = 0
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> pries [limb] loose with [tool]."))
				limb.remove_stage = 2
				logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s [limb] with [tool].")


		remove
			name = "Remove"
			desc = "Remove the limb."
			icon_state = "wrench"
			success_sound = 'sound/items/Ratchet.ogg'
			flags_required = TOOL_WRENCHING
			success_damage = 0
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				limb.remove(0)
				surgeon.visible_message(SPAN_ALERT("<b>[surgeon]</b> twists [limb] off with [tool]."))
				logTheThing(LOG_COMBAT, tool.the_mob, "removes [constructTarget(C,"combat")]'s [limb.name].")
				logTheThing(LOG_DIARY, tool.the_mob, "removes [constructTarget(C,"diary")]'s [limb.name]", "combat")
