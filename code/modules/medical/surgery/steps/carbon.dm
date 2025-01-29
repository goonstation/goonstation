

/datum/surgery_step
	suture
		name = "Suture"
		desc = "Suture the wound."
		icon_state = "suture"
		success_text = "sutures the wound"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "screws up!"

		tools_required = list(/obj/item/suture)
	snip
		name = "Snip"
		desc = "Snip out some tissue."
		icon_state = "scissor"
		success_text = "snips out various tissues and tendons"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = " loses control of the scissors and drags it across the patient's entire chest"
		flags_required = TOOL_SNIPPING

	cut
		name = "Cut"
		desc = "Cut through the flesh."
		icon_state = "scalpel"
		success_text = "cuts through the flesh"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "cuts too deep and messes up!"
		flags_required = TOOL_CUTTING
	saw
		name = "Saw"
		desc = "Saw through the bone."
		icon_state = "saw"
		success_text = "cuts through the flesh"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "cuts too deep and messes up!"
		flags_required = TOOL_SAWING
	bandage
		name = "Bandage"
		desc = "Bandage the wound."
		icon_state = "bandage"
		success_text = "bandages the wound"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		slipup_text = "screws up!"
		tools_required = list(/obj/item/bandage)

	organ
		var/affected_organ
		New(datum/surgery/parent_surgery, the_organ)
			src.affected_organ = the_organ
			..(parent_surgery)

		snip
			name = "Snip"
			desc = "Disconnect the organ."
			icon_state = "scissor"
			success_text = "snips out various tissues and tendons"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = " loses control of the scissors and drags it across the patient's entire chest"
			flags_required = TOOL_SNIPPING
			on_complete(mob/user, obj/item/tool)
				parent_surgery.patient.organHolder.vars[affected_organ].in_surgery = TRUE
		cut
			name = "Cut"
			desc = "Cut connective tissues from the organ."
			icon_state = "scalpel"
			success_text = "cuts through the flesh"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts too deep and messes up!"
			flags_required = TOOL_CUTTING
			on_complete(mob/user, obj/item/tool)
				parent_surgery.patient.organHolder.vars[affected_organ].secure = FALSE

		remove
			name = "Remove"
			desc = "Remove the organ."
			icon_state = "scalpel"
			success_text = "cuts out organ"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts too deep and messes up!"
			flags_required = TOOL_CUTTING
			on_complete(mob/user, obj/item/tool)
				parent_surgery.patient.organHolder.drop_organ(affected_organ)

		add
			name = "Add"
			desc = "Add the organ."
			icon_state = "scalpel"
			success_text = "adds organ"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "slips!"
			on_complete(mob/surgeon, obj/item/tool)
				var/datum/organHolder/H = parent_surgery.patient.organHolder
				if (surgeon.find_in_hand(tool))
					surgeon.u_equip(tool)
				H.receive_organ(tool, affected_organ)

			tool_requirement(mob/surgeon, obj/item/tool)
				if (istype(tool, /obj/item/organ))
					var/obj/item/organ/O = tool
					if (O.organ_holder_name == affected_organ)
						return TRUE
				return FALSE



	limb
		var/affected_limb
		New(datum/surgery/parent_surgery, affected_limb)
			src.affected_limb = affected_limb
			..(parent_surgery)
		cut
			name = "Cut"
			desc = "Cut connective tissues from the limb."
			icon_state = "scalpel"
			success_text = "scalp through the flesh"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts too deep and messes up!"
			flags_required = TOOL_CUTTING
			on_complete(mob/user, obj/item/tool)

				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				limb.remove_stage = 1
		saw
			name = "Saw"
			desc = "Saw through the bone."
			icon_state = "saw"
			success_text = "saw through the flesh"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts"
			flags_required = TOOL_SAWING
			on_complete(mob/user, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				limb.remove_stage = 2
		remove
			name = "Remove"
			desc = "Remove the limb."
			icon_state = "saw"
			success_text = "remove da limb"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts"
			flags_required = TOOL_CUTTING
			on_complete(mob/user, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/obj/item/parts/limb = C.limbs.vars[affected_limb]
				limb.remove(0)
		attach
			name = "Add"
			desc = "Add the limb."
			icon_state = "scalpel"
			success_text = "adds limb"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "slips!"
			flags_required = TOOL_CUTTING

			attempt_surgery_step(mob/surgeon, obj/item/tool)
				if (tool.object_flags & NO_ARM_ATTACH || tool.cant_drop || tool.two_handed)
					boutput(surgeon, SPAN_ALERT("You try to attach [tool] to [parent_surgery.patient]'s stump, but it politely declines!"))
					return
				if (!parent_surgery.patient.limbs?.get_limb(affected_limb))
					return FALSE
				return ..()

			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/datum/human_limbs/H = C.limbs
				if (surgeon.find_in_hand(tool))
					surgeon.u_equip(tool)
				H.vars[affected_limb] = tool
				tool.holder = parent_surgery.patient

				var/can_secure = ismob(attacher) && (attacher?.find_type_in_hand(/obj/item/suture) || attacher?.find_type_in_hand(/obj/item/staple_gun))
				new_arm.remove_stage = can_secure ? 0 : 2


			tool_requirement(mob/surgeon, obj/item/tool)

				if (istype(tool, /obj/item/organ))
					var/obj/item/organ/O = tool
					if (O.organ_holder_name == affected_limb)
						return TRUE
				return FALSE
