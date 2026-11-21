/datum/targetable/ai/program/change_arrest
	name = "Close Arrest Warrant"
	desc = "Close out an arrest warrant."
	targeted = TRUE
	target_anything = FALSE
	icon_state = "scan_prisoner"

	cast(atom/target)
		. = ..()
		if (.)
			return .

		if (!ishuman(target))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/mob/living/carbon/human/H = target

		if (!H.face_visible())
			boutput(src.holder.owner, SPAN_ALERT("The target's face must be visible!"))
			return

		var/new_arrest = tgui_input_list(src.holder.owner, "Select the new criminal status", "Select Criminal Status", list(
			SECURITY::ARREST::STATE::NONE,
			SECURITY::ARREST::STATE::PAROLE,
			SECURITY::ARREST::STATE::INCARCERATED,
			SECURITY::ARREST::STATE::RELEASED,
			SECURITY::ARREST::STATE::SUSPECT
		))

		if (!new_arrest)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		// Arrests
		var/list/datum/db_record/citation/arrest/arrests = global.data_core.get_open_arrests(H.real_name)
		if (length(arrests))
			var/assignment = "Unknown"
			if (isAI(src.holder.owner))
				assignment = "AIUSR"
			else if (ishuman(src.holder.owner))
				var/mob/living/carbon/human/my_human = src.holder.owner
				assignment = global.get_id_card(my_human.wear_id)?.assignment

			for (var/datum/db_record/citation/arrest/arrest as anything in arrests)
				arrest.close(src.holder.owner.name, assignment, "Warrant closed via wireless prisoner scanner.")

		// General
		var/datum/db_record/personnel/general/general = global.data_core.get_general_record(H.real_name, ensure_record = TRUE)
		var/record_id = general["id"]
		general.update_from_scan(H)

		// Medical
		var/datum/db_record/personnel/medical/medical = global.data_core.get_medical_record(id = record_id, ensure_record = TRUE)
		medical.update_from_scan(H)

		// Security
		var/datum/db_record/personnel/security/security = global.data_core.get_security_record(id = record_id, ensure_record = TRUE)
		security.update_from_scan(H)
		security["criminal"] = new_arrest

		// Bank
		var/datum/db_record/personnel/bank/bank = global.data_core.get_bank_record(id = record_id, ensure_record = TRUE)
		bank.update_from_scan(target)
