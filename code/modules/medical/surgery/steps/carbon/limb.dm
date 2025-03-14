
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

		on_complete(mob/surgeon, obj/item/tool)

			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove_stage = 1
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts through the flesh holding [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [limb] in with [tool]!"),\
				SPAN_ALERT("You cut through the flesh holding [surgeon == C ? "your" : "[C]'s"] [limb] in with [tool]!"), \
				SPAN_ALERT("[C == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] through the flesh holding your [limb] in with [tool]!"))
			logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s [limb] with [tool].")

	saw
		name = "Saw"
		desc = "Saw through the bone."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove_stage = 2
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> saws through the bone in [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [limb] with [tool]!"),\
				SPAN_ALERT("You saw through the bone in [surgeon == C ? "your" : "[C]'s"] [limb] with [tool]!"), \
				SPAN_ALERT("[C == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through the bone in your [limb] with [tool]!"))

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
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> removes [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [limb] with [tool]!"),\
				SPAN_ALERT("You remove [surgeon == C ? "your" : "[C]'s"] [limb] with [tool]!"),\
				SPAN_ALERT("[C == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] your [limb] with [tool]!"))
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(C,"combat")]'s [limb].")

	attach_arm
		name = "Add"
		desc = "Add the limb."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'

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
			var/mob/living/carbon/human/C = parent_surgery.patient
			if (surgeon.find_in_hand(tool))
				surgeon.u_equip(tool)
			var/obj/item/parts/human_parts/arm/limb = null
			if (!istype(tool, /obj/item/parts/human_parts/arm))
				if (affected_limb == "l_arm")
					limb = new /obj/item/parts/human_parts/arm/left/item(C)
				else if (affected_limb == "r_arm")
					limb = new /obj/item/parts/human_parts/arm/right/item(C)
				limb.cant_drop = 1
				limb:set_item(tool)
			else
				limb = tool
			limb.attach(C)
			var/can_secure = ismob(surgeon) && (limb.easy_attach || surgeon?.find_type_in_hand(/obj/item/suture) || surgeon?.find_type_in_hand(/obj/item/staple_gun))
			limb.remove_stage = can_secure ? 0 : 2


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
	secure
		name = "Secure"
		desc = "Secure the limb."
		icon_state = "suture"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		tools_required = list(/obj/item/suture)
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			var/obj/item/parts/limb = C.limbs.vars[affected_limb]
			limb.remove_stage = 0
