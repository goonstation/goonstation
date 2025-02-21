

/datum/surgery_step
	suture
		name = "Suture"
		desc = "Suture the wound."
		icon_state = "suture"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		tools_required = list(/obj/item/suture)
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> sutures [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] wounds with [tool]!"),\
				SPAN_ALERT("You suture [surgeon == patient ? "your" : "[patient]'s"] wounds with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You suture" : "<b>[surgeon]</b> sutures"] your wounds with [tool]!"))
	snip
		name = "Snip"
		desc = "Snip out some tissue."
		icon_state = "scissor"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SNIPPING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> makes a cut on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest with [tool]!"),\
				SPAN_ALERT("You make a cut on [surgeon == patient ? "your" : "[patient]'s"] chest with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You make a cut" : "<b>[surgeon]</b> makes a cut"] on your chest with [tool]!"))

	cut
		name = "Cut"
		desc = "Cut through the flesh."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts through [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] flesh with [tool]!"),\
				SPAN_ALERT("You cut through [surgeon == patient ? "your" : "[patient]'s"] flesh with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] through your flesh with [tool]!"))

	saw
		name = "Saw"
		desc = "Saw through the bone."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> saws through [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] bone with [tool]!"),\
				SPAN_ALERT("You saw through [surgeon == C ? "your" : "[C]'s"] bone with [tool]!"),\
				SPAN_ALERT("[C == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through your bone with [tool]!"))
	bandage
		name = "Bandage"
		desc = "Bandage the wound."
		icon_state = "bandage"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		tools_required = list(/obj/item/bandage)
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/C = parent_surgery.patient
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> bandages [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] wounds with [tool]!"),\
				SPAN_ALERT("You bandage [surgeon == C ? "your" : "[C]'s"] wounds with [tool]!"),\
				SPAN_ALERT("[C == surgeon ? "You bandage" : "<b>[surgeon]</b> bandages"] your wounds with [tool]!"))

	skull
	organ
		var/affected_organ
		New(datum/surgery/parent_surgery, the_organ)
			src.affected_organ = the_organ
			..(parent_surgery)

		snip
			name = "Snip"
			desc = "Disconnect the organ."
			icon_state = "scissor"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_SNIPPING
			on_complete(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = parent_surgery.patient.organHolder.vars[affected_organ]
				O.in_surgery = TRUE
				var/mob/living/carbon/human/C = parent_surgery.patient
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> snips out various veins and tendons from [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [affected_organ] with [tool]!"),\
					SPAN_ALERT("You snip out various veins and tendons from [surgeon == C ? "your" : "[C]'s"] [affected_organ] with [tool]!"),\
					SPAN_ALERT("[C == surgeon ? "You snip" : "<b>[surgeon]</b> snips"] out various veins and tendons from your [affected_organ] with [tool]!"))

		cut
			name = "Cut"
			desc = "Cut connective tissues from the organ."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			on_complete(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = parent_surgery.patient.organHolder.vars[affected_organ]
				O.secure = FALSE
				var/mob/living/carbon/human/C = parent_surgery.patient
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts through the flesh holding [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [affected_organ] in with [tool]!"),\
					SPAN_ALERT("You cut through the flesh holding [surgeon == C ? "your" : "[C]'s"] [affected_organ] in with [tool]!"), \
					SPAN_ALERT("[C == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] through the flesh holding your [affected_organ] in with [tool]!"))

		remove
			name = "Remove"
			desc = "Remove the organ."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			on_complete(mob/surgeon, obj/item/tool)
				var/patient = parent_surgery.patient
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> takes out [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] [affected_organ]."),\
					SPAN_NOTICE("You take out [surgeon == patient ? "your" : "[patient]'s"] [affected_organ]."),\
					SPAN_ALERT("[patient == surgeon ? "You take" : "<b>[surgeon]</b> takes"] out your [affected_organ]!"))
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [affected_organ].")
				parent_surgery.patient.organHolder.drop_organ(affected_organ)

		add
			name = "Add"
			desc = "Add the organ."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			on_complete(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = tool
				O.attach_organ(parent_surgery.patient, surgeon)
			tool_requirement(mob/surgeon, obj/item/tool)
				if (istype(tool, /obj/item/organ))
					var/obj/item/organ/O = tool
					if (O.organ_holder_name == affected_organ)
						if (O.can_attach_organ(parent_surgery.patient, surgeon))
							return TRUE
				return FALSE



		eye
			var/target_side
			New(datum/surgery/parent_surgery, the_organ)
				if (the_organ == "left_eye")
					src.target_side = "left"
				else
					src.target_side = "right"
				..(parent_surgery, the_organ)

			attempt_surgery_step(mob/surgeon, obj/item/tool)
				if (affected_organ == "left_eye")
					if (surgeon.find_in_hand(tool) != surgeon.l_hand)
						return FALSE
				if (affected_organ == "right_eye")
					if (surgeon.find_in_hand(tool) != surgeon.r_hand)
						return FALSE
				if (!headSurgeryCheck(parent_surgery.patient))
					surgeon.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
					return FALSE
				if (!parent_surgery.patient.organHolder.head)
					boutput(surgeon, SPAN_ALERT("[parent_surgery.patient] doesn't have a head!"))
					return FALSE
				if (surgeon.find_in_hand(tool, "middle"))
					surgeon.show_text("Hey, there's no middle eye!")
					return FALSE
				. = ..()

			dislodge
				name = "Dislodge"
				desc = "Dislodge the eye."
				icon_state = "scalpel"
				success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
				flags_required = TOOL_SPOONING
				on_complete(mob/surgeon, obj/item/tool)
					var/patient = parent_surgery.patient
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> inserts [tool] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] eye socket!"),\
						SPAN_ALERT("You insert [tool] into [surgeon == patient ? "your" : "[patient]'s"] [target_side] eye socket!"), \
						SPAN_ALERT("[patient == surgeon ? "You insert" : "<b>[surgeon]</b> inserts"] [tool] into your [target_side] eye socket!"))

			cut
				name = "Cut"
				desc = "Cut the optic nerve."
				icon_state = "scalpel"
				success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
				flags_required = TOOL_CUTTING
				on_complete(mob/surgeon, obj/item/tool)
					var/patient = parent_surgery.patient
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts away the flesh holding [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] right eye in with [tool]!"),\
						SPAN_ALERT("You cut away the flesh holding [surgeon == patient ? "your" : "[patient]'s"] right eye in with [tool]!"), \
						SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] away the flesh holding your right eye in with [tool]!"))

			scoop
				name = "Scoop"
				desc = "Scoop out the eye."
				icon_state = "scalpel"
				success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
				flags_required = TOOL_SPOONING
				on_complete(mob/surgeon, obj/item/tool)
					var/mob/living/patient = parent_surgery.patient
					surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> removes [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [target_side] eye with [tool]!"),\
						SPAN_ALERT("You remove [surgeon == patient ? "your" : "[patient]'s"] [target_side] eye with [tool]!"),\
						SPAN_ALERT("[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] your [target_side] eye with [tool]!"))
					logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [target_side] eye with [tool].")
					var/datum/organHolder/holder = patient.organHolder
					holder.drop_organ("[target_side]_eye")
	limb
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
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts through the flesh holding [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [affected_limb] in with [tool]!"),\
					SPAN_ALERT("You cut through the flesh holding [surgeon == C ? "your" : "[C]'s"] [affected_limb] in with [tool]!"), \
					SPAN_ALERT("[C == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] through the flesh holding your [affected_limb] in with [tool]!"))
				logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s [affected_limb] with [tool].")

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
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> saws through the bone in [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [affected_limb] with [tool]!"),\
					SPAN_ALERT("You saw through the bone in [surgeon == C ? "your" : "[C]'s"] [affected_limb] with [tool]!"), \
					SPAN_ALERT("[C == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through the bone in your [affected_limb] with [tool]!"))

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
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> removes [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [affected_limb] with [tool]!"),\
					SPAN_ALERT("You remove [surgeon == C ? "your" : "[C]'s"] [affected_limb] with [tool]!"),\
					SPAN_ALERT("[C == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] your [affected_limb] with [tool]!"))
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(C,"combat")]'s [affected_limb].")

		attach_arm
			name = "Add"
			desc = "Add the limb."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'

			attempt_surgery_step(mob/surgeon, obj/item/tool)
				if (tool.object_flags & NO_ARM_ATTACH || tool.cant_drop || tool.two_handed)
					boutput(surgeon, SPAN_ALERT("You try to attach [tool] to [parent_surgery.patient]'s stump, but it politely declines!"))
					return
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
	item
		insert
			name = "Insert"
			desc = "Insert the item."
			icon_state = "in"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			tool_requirement(mob/surgeon, obj/item/tool)
				if(tool.w_class > W_CLASS_NORMAL && !(tool.type in chestitem_whitelist))
					boutput(surgeon, SPAN_ALERT("[tool] is too big to fit into [parent_surgery.patient]'s chest cavity."))
					return FALSE
				return TRUE

			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
				surgeon.drop_item(tool)
				tool.set_loc(patient)
				patient.chest_item = tool
				logTheThing(LOG_COMBAT, patient, "received a surgical chest item implant of \the [tool] ([tool.type]) by [constructTarget(surgeon,"combat")]")

				if(surgeon.find_type_in_hand(/obj/item/suture))
					patient.chest_item_sewn = TRUE
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> shoves [tool] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest and sutures it up."),\
						SPAN_NOTICE("You shove [tool] into [surgeon == patient ? "your" : "[patient]'s"] chest and suture it up."),\
						SPAN_NOTICE("[patient == surgeon ? "You shove [tool] into your chest and suture it up" : "<b>[surgeon]</b> shoves [tool] into your chest and sutures it up"]."))
					patient.TakeDamage("chest", rand(5, 15), 0)
				else
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> shoves [tool] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest."),\
						SPAN_NOTICE("You shove [tool] into [surgeon == patient ? "your" : "[patient]'s"] chest."),\
						SPAN_NOTICE("[patient == surgeon ? "You shove" : "<b>[surgeon]</b> shoves"] [tool] into your chest."))

		secure
			name = "Secure"
			desc = "Secure the item."
			icon_state = "suture"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			tools_required = list(/obj/item/suture)
			optional = TRUE
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				patient.chest_item_sewn = TRUE
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the [patient.chest_item] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity with [src]."),\
					SPAN_NOTICE("You sew the [patient.chest_item] securely into [surgeon == patient ? "your" : "[patient]'s"] chest cavity with [src]."),\
					SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the [patient.chest_item] into your chest cavity with [src]."))
		remove
			name = "Remove"
			desc = "Remove the item."
			icon_state = "out"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			optional = TRUE
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> removes the [patient.chest_item] from [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity."),\
					SPAN_NOTICE("You remove the [patient.chest_item] from [surgeon == patient ? "your" : "[patient]'s"] chest cavity."),\
					SPAN_NOTICE("[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] the [patient.chest_item] from your chest cavity."))
				logTheThing(LOG_COMBAT, patient, "had their [patient.chest_item] removed by [constructTarget(surgeon,"combat")]")
				patient.chest_item.set_loc(get_turf(patient))
				patient.chest_item = null
