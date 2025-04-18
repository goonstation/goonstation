// the heirarchies in here could be reorganized. alas i am but 1 gamer versus 3~4 thousand lines of spaghettified surgery code
// for instance, butt/skull/eye surgery can probably cleanly reuse organ removal code. my head hurts - hooligan

/datum/surgery_step/head
	cut
		name = "Cut"
		desc = "Cut through the neck."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/obj/item/organ/O = parent_surgery.patient.organHolder.head
			O.op_stage = 1

			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts the skin of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck open with [tool]!"),\
				SPAN_ALERT("You cut the skin of [surgeon == patient ? "your" : "[patient]'s"] neck open with [tool]!"), \
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] the skin of your neck open with [tool]!"))

	cut2
		name = "Cut"
		desc = "Cut through the remaining tissues."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			var/obj/item/organ/O = parent_surgery.patient.organHolder.head
			O.op_stage = 3
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> slices the tissue around [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] spine with [tool]!"),\
				SPAN_ALERT("You slice the tissue around [surgeon == patient ? "your" : "[patient]'s"] spine with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You slice" : "<b>[surgeon]</b> slices"] the tissue around your spine with [tool]!"))

	saw
		name = "Saw"
		desc = "Saw through the neck."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			var/obj/item/organ/O = parent_surgery.patient.organHolder.vars["head"]
			O.op_stage = 2
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> severs most of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck with [tool]!"),\
				SPAN_ALERT("You sever most of [surgeon == patient ? "your" : "[patient]'s"] neck with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] most of your neck with [tool]!"))

	remove
		name = "Saw"
		desc = "Remove the head."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws through the last of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head's connections to [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] body with [tool]!"),\
				SPAN_ALERT("You saw through the last of [surgeon == patient ? "your" : "[patient]'s"] head's connections to [surgeon == patient ? "your" : "[his_or_her(patient)]"] body with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through the last of your head's connection to your body with [tool]!"))
			if (patient.organHolder.brain)
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s head and brain with [src].")
				patient.death()
			patient.organHolder.drop_organ("head")

/datum/surgery_step/chest
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
			patient.chest_cavity_clamped = FALSE
	clamp
		name = "Clamp"
		desc = "Clamp the bleeders."
		icon_state = "clamp"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		optional = TRUE
		visible = FALSE
		repeatable = TRUE
		damage_dealt = 0
		tools_required = list(/obj/item/hemostat)
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> begins clamping the bleeders in [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] incision with [src]."),\
				SPAN_ALERT("You begin clamping the bleeders in [surgeon == patient ? "your" : "[patient]'s"] incision with [src]."),\
				SPAN_ALERT("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] clamping the bleeders in your incision with [src]."))

			actions.start(new/datum/action/bar/icon/clamp_bleeders(surgeon, patient, src.parent_surgery), surgeon)
			return

/datum/surgery_step/organ
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
			O.op_stage = 2
			var/mob/living/carbon/human/C = parent_surgery.patient
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> snips out various veins and tendons from [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [O.name] with [tool]!"),\
				SPAN_ALERT("You snip out various veins and tendons from [surgeon == C ? "your" : "[C]'s"] [O.name] with [tool]!"),\
				SPAN_ALERT("[C == surgeon ? "You snip" : "<b>[surgeon]</b> snips"] out various veins and tendons from your [O.name] with [tool]!"))

	cut
		name = "Cut"
		desc = "Cut connective tissues from the organ."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/obj/item/organ/O = parent_surgery.patient.organHolder.vars[affected_organ]
			O.op_stage = 1
			var/mob/living/carbon/human/C = parent_surgery.patient
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts through the flesh holding [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [O.name] in with [tool]!"),\
				SPAN_ALERT("You cut through the flesh holding [surgeon == C ? "your" : "[C]'s"] [O.name] in with [tool]!"), \
				SPAN_ALERT("[C == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] through the flesh holding your [O.name] in with [tool]!"))

	remove
		name = "Remove"
		desc = "Remove the organ."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/patient = parent_surgery.patient
			var/obj/item/organ/O = parent_surgery.patient.organHolder.vars[affected_organ]
			O.op_stage = 4
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> takes out [surgeon == patient ? "[his_or_her(patient)]" : "[patient]'s"] [O.name]."),\
				SPAN_NOTICE("You take out [surgeon == patient ? "your" : "[patient]'s"] [O.name]."),\
				SPAN_ALERT("[patient == surgeon ? "You take" : "<b>[surgeon]</b> takes"] out your [O.name]!"))
			logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(patient,"combat")]'s [affected_organ].")
			parent_surgery.patient.organHolder.drop_organ(affected_organ)
		saw
			flags_required = TOOL_SAWING
			icon_state = "saw"
	saw
		name = "Saw"
		desc = "Saw through the organ."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/obj/item/organ/O = parent_surgery.patient.organHolder.vars[affected_organ]
			O.op_stage = 3
			var/mob/living/carbon/human/C = parent_surgery.patient
			surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> saws through [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] [O.name] with [tool]!"),\
				SPAN_ALERT("You saw through [surgeon == C ? "your" : "[C]'s"] [O.name] with [tool]!"),\
				SPAN_ALERT("[C == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] through your [O.name] with [tool]!"))

	add
		name = "Add"
		desc = "Add the organ."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		optional = TRUE
		on_complete(mob/surgeon, obj/item/tool)
			var/obj/item/organ/O = tool
			O.attach_organ(parent_surgery.patient, surgeon)
			//secure, as per old behavior
			O.op_stage = 0
		tool_requirement(mob/surgeon, obj/item/tool)
			if (istype(tool, /obj/item/organ))
				var/obj/item/organ/O = tool
				if (O.organ_holder_name == affected_organ)
					if (O.can_attach_organ(parent_surgery.patient, surgeon))
						return TRUE
			return FALSE
		head
			on_complete(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = tool
				O.attach_organ(parent_surgery.patient, surgeon)

		eye

			tool_requirement(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = tool
				if (O.can_attach_organ(parent_surgery.patient, surgeon))
					return TRUE
			tools_required = list(/obj/item/organ/eye)
		skull
			tool_requirement(mob/surgeon, obj/item/tool)
				var/obj/item/organ/O = tool
				if (O.can_attach_organ(parent_surgery.patient, surgeon))
					return TRUE
			tools_required = list(/obj/item/skull)


	eye
		var/target_side
		New(datum/surgery/parent_surgery, the_organ)
			if (the_organ == "left_eye")
				src.target_side = "left"
			else
				src.target_side = "right"
			..(parent_surgery, the_organ)

		do_surgery_step(mob/surgeon, obj/item/tool)
			if (affected_organ == "left_eye")
				if (surgeon.find_in_hand(tool) != surgeon.l_hand)
					return FALSE
			if (affected_organ == "right_eye")
				if (surgeon.find_in_hand(tool) != surgeon.r_hand)
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
	brain
		cut
			name = "Cut"
			desc = "Cut around the scalp."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] head open with [tool]!"),\
					SPAN_ALERT("You cut [surgeon == C ? "your" : "[C]'s"] head open with [tool]!"), \
					SPAN_ALERT("[C == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your head open with [tool]!"))
				logTheThing(LOG_COMBAT, surgeon, "started removing [constructTarget(C,"combat")]'s brain with [tool].")
				C.organHolder.brain.op_stage = 1

		cut2
			name = "Cut"
			icon_state = "scalpel"
			desc = "Disconnect the brain."
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				if (C.organHolder.brain)
					surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> removes the connections to [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] brain with [tool]!"),\
						SPAN_ALERT("You remove [surgeon == C ? "your" : "[C]'s"] connections to [surgeon == C ? "your" : "[his_or_her(C)]"] brain with [tool]!"),\
						SPAN_ALERT("[C == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] the connections to your brain with [tool]!"))
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> opens the area around [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] brain cavity with [tool]!"),\
						SPAN_ALERT("You open the area around [surgeon == C ? "your" : "[C]'s"] brain cavity with [tool]!"),\
						SPAN_ALERT("[C == surgeon ? "You open" : "<b>[surgeon]</b> opens"] the area around your brain cavity with [tool]!"))
				C.organHolder.brain.op_stage = 3


		saw
			name = "Saw"
			desc = "Saw through the skull."
			icon_state = "saw"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_SAWING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				var/missing_fluff = ""
				if (!C.organHolder.skull)
					// If the skull is gone, but the suture site was closed and we're re-opening
					missing_fluff = pick("region", "area")
				surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> saws open [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] skull [missing_fluff] with [tool]!"),\
					SPAN_ALERT("You saw open [surgeon == C ? "your" : "[C]'s"] skull [missing_fluff] with [tool]!"),\
					SPAN_ALERT("[C == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your skull [missing_fluff] with [tool]!"))
				C.organHolder.brain.op_stage = 2


		remove
			name = "Remove"
			desc = "Remove the brain, or open the cavity."
			icon_state = "saw"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_SAWING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/C = parent_surgery.patient
				if (C.organHolder.brain)
					surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> severs [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] brain's connection to the spine with [tool]!"),\
						SPAN_ALERT("You sever [surgeon == C ? "your" : "[C]'s"] brain's connection to the spine with [tool]!"),\
						SPAN_ALERT("[C == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your brain's connection to the spine with [tool]!"))

					C.organHolder.drop_organ("brain")
				else
					// If the brain is gone, but the suture site was closed and we're re-opening
					surgeon.tri_message(C, SPAN_ALERT("<b>[surgeon]</b> cuts open [C == surgeon ? "[his_or_her(C)]" : "[C]'s"] brain cavity with [tool]!"),\
						SPAN_ALERT("You cut open [surgeon == C ? "your" : "[C]'s"] brain cavity with [tool]!"),\
						SPAN_ALERT("[C == surgeon ? "You cut open" : "<b>[surgeon]</b> cuts open "] your brain cavity with [tool]!"))
				C.death()
				logTheThing(LOG_COMBAT, surgeon, "removed [constructTarget(C,"combat")]'s brain.")
/datum/surgery_step/skull
	cut

		name = "Cut"
		desc = "Cut the skull from the flesh."
		icon_state = "scalpel"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			if (patient.organHolder.skull)
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull away from the skin with [tool]!"),\
					SPAN_ALERT("You cut [surgeon == patient ? "your" : "[patient]'s"] skull away from the skin with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your skull away from the skin with [tool]!"))
			else
				// If the skull is gone, but the suture site was closed and we're re-opening
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> opens [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull cavity with [tool]!"),\
					SPAN_ALERT("You open [surgeon == patient ? "your" : "[patient]'s"] skull cavity with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You open" : "<b>[surgeon]</b> opens"] your skull cavity with [tool]!"))

	remove
		name = "Remove"
		desc = "Remove the brain, or open the cavity."
		icon_state = "saw"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_SAWING
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			if (patient.organHolder.skull)
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] skull out with [tool]!"),\
					SPAN_ALERT("You saw [surgeon == patient ? "your" : "[patient]'s"] skull out with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] your skull out with [tool]!"))

				patient.visible_message(SPAN_ALERT("<b>[patient]</b>'s head collapses into a useless pile of skin with no skull to keep it in its proper shape!"),\
				SPAN_ALERT("Your head collapses into a useless pile of skin with no skull to keep it in its proper shape!"))
				patient.organHolder.drop_organ("skull")
			else
				// If the skull is gone, but the suture site was closed and we're re-opening
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws the top of [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] head open with [tool]!"),\
					SPAN_ALERT("You saw the top of [surgeon == patient ? "your" : "[patient]'s"] head open with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] the top of your head open with [tool]!"))
			patient.real_name = "Unknown"
			patient.unlock_medal("Red Hood", 1)
			patient.set_clothing_icon_dirty()
