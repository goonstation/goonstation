/datum/surgery_step
	fluff //! steps that are entirely just to fluff out surgeries. you could change these to have their verbs/message passed in the constructor
		name = "Fluff Surgery"
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

		back_cut
			name = "Cut"
			desc = "Cut through the lower back."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_CUTTING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] lower back open with [tool]!"),\
					SPAN_ALERT("You cut [surgeon == patient ? "your" : "[patient]'s"] lower back open with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] your lower back open with [tool]!"))
		back_cut_2
			name = "Cut"
			desc = "Disconnect the intestines."
			icon_state = "scalpel"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> severs [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] intestines with [tool]!"),\
					SPAN_ALERT("You sever [surgeon == patient ? "your" : "[patient]'s"] intestines with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You sever" : "<b>[surgeon]</b> severs"] your intestines with [tool]!"))


		back_saw
			name = "Saw"
			desc = "Saw through the butt."
			icon_state = "saw"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			flags_required = TOOL_SAWING
			on_complete(mob/surgeon, obj/item/tool)
				var/mob/living/carbon/human/patient = parent_surgery.patient
				surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> saws open [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] back with [tool]!"),\
					SPAN_ALERT("You saw open [surgeon == patient ? "your" : "[patient]'s"] back with [tool]!"),\
					SPAN_ALERT("[patient == surgeon ? "You saw" : "<b>[surgeon]</b> saws"] open your back with [tool]!"))
