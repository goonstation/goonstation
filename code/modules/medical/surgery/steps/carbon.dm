

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
		var/obj/item/organ/affected_organ
		New(datum/surgery/parent_surgery, /obj/item/organ/the_organ)
			affected_organ = the_organ
			..(parent_surgery)
		snip
			name = "Snip"
			desc = "Disconnect the organ."
			icon_state = "scissor"
			success_text = "snips out various tissues and tendons"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = " loses control of the scissors and drags it across the patient's entire chest"
			flags_required = TOOL_SNIPPING

		cut
			name = "Cut"
			desc = "Cut the organ out."
			icon_state = "scalpel"
			success_text = "cuts through the flesh"
			success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
			slipup_text = "cuts too deep and messes up!"
			flags_required = TOOL_CUTTING
