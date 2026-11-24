TYPEINFO(/obj/item/device/prisoner_scanner)
	mats = 3

/obj/item/device/prisoner_scanner
	name = "security RecordTrak"
	desc = "A device used to scan in prisoners and update their security records."
	icon_state = "recordtrak"
	item_state = "recordtrak"
	flags = TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = ONBELT

	#define PRISONER_MODE_NONE 1
	#define PRISONER_MODE_PAROLED 2
	#define PRISONER_MODE_RELEASED 3
	#define PRISONER_MODE_INCARCERATED 4
	#define PRISONER_MODE_SUSPECT 5

	///List of record settings
	VAR_PRIVATE/static/alist/modes = alist(
		PRISONER_MODE_NONE			= SECURITY::ARREST::STATE::NONE,
		PRISONER_MODE_PAROLED		= SECURITY::ARREST::STATE::PAROLE,
		PRISONER_MODE_INCARCERATED	= SECURITY::ARREST::STATE::INCARCERATED,
		PRISONER_MODE_RELEASED		= SECURITY::ARREST::STATE::RELEASED,
		PRISONER_MODE_SUSPECT		= SECURITY::ARREST::STATE::SUSPECT,
	)
	///The current setting
	var/mode = PRISONER_MODE_NONE
	/// The sechud flag that will be applied when scanning someone
	var/sechud_flag = "None"

	var/list/datum/contextAction/contexts = list()

	New()
		var/datum/contextLayout/experimentalcircle/context_menu = new
		context_menu.center = TRUE
		src.contextLayout = context_menu
		..()
		for(var/actionType in childrentypesof(/datum/contextAction/prisoner_scanner))
			var/datum/contextAction/prisoner_scanner/action = new actionType()
			if (action.mode in src.modes)
				src.contexts += action

	get_desc()
		. = ..()
		var/mode_string = "None"
		if (src.mode == PRISONER_MODE_PAROLED)
			mode_string = "Paroled"
		else if (src.mode == PRISONER_MODE_RELEASED)
			mode_string = "Released"
		else if (src.mode == PRISONER_MODE_INCARCERATED)
			mode_string = "Incarcerated"
		else if (src.mode == PRISONER_MODE_SUSPECT)
			mode_string = "Suspect"

		. += "<br>Arrest mode: [SPAN_NOTICE("[mode_string]")]"
		if (sechud_flag != initial(src.sechud_flag))
			. += "<br>Active SecHUD Flag: [SPAN_NOTICE("[src.sechud_flag]")]"

	attack(mob/living/carbon/human/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!istype(target))
			boutput(user, SPAN_ALERT("The device displays an error about an \"incompatible target\"."))
			return

		if (!target.face_visible())
			boutput(user, SPAN_ALERT("The device displays an error, the target's face must be visible."))
			return

		boutput(user, SPAN_NOTICE("You scan in [target]."))
		boutput(target, SPAN_ALERT("[user] scans you with the RecordTrak!"))

		// Arrests
		var/list/datum/db_record/citation/arrest/arrests = global.data_core.get_open_arrests(target.real_name)
		if (length(arrests))
			var/assignment = "Unknown"
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				assignment = global.get_id_card(H.wear_id)?.assignment

			for (var/datum/db_record/citation/arrest/arrest as anything in arrests)
				arrest.close(user.name, assignment, "Warrant closed via RecordTrak.")

		// General
		var/datum/db_record/personnel/general/general = global.data_core.get_general_record(target.real_name, ensure_record = TRUE)
		var/record_id = general["id"]
		general.update_from_scan(target)

		// Medical
		var/datum/db_record/personnel/medical/medical = global.data_core.get_medical_record(id = record_id, ensure_record = TRUE)
		medical.update_from_scan(target)

		// Security
		var/datum/db_record/personnel/security/security = global.data_core.get_security_record(id = record_id, ensure_record = TRUE)
		security.update_from_scan(target)
		security["criminal"] = src.modes[src.mode]
		security["sec_flag"] = src.sechud_flag

		// Bank
		var/datum/db_record/personnel/bank/bank = global.data_core.get_bank_record(id = record_id, ensure_record = TRUE)
		bank.update_from_scan(target)

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	proc/switch_mode(var/mode, set_flag, var/mob/user)
		if (set_flag)
			var/flag = tgui_input_text(user, "Flag:", "Set SecHUD Flag", initial(src.sechud_flag), SECURITY::ARREST::SECHUD_FLAG_MAX_CHARS)
			if (!isnull(flag) && src.sechud_flag != flag)
				src.sechud_flag = flag
				tooltip_rebuild = TRUE
		else if (src.mode != mode)
			src.mode = mode
			tooltip_rebuild = TRUE

			switch (mode)
				if(PRISONER_MODE_NONE)
					boutput(user, SPAN_NOTICE("you switch the record mode to None."))

				if(PRISONER_MODE_PAROLED)
					boutput(user, SPAN_NOTICE("you switch the record mode to Paroled."))

				if(PRISONER_MODE_RELEASED)
					boutput(user, SPAN_NOTICE("you switch the record mode to Released."))

				if(PRISONER_MODE_INCARCERATED)
					boutput(user, SPAN_NOTICE("you switch the record mode to Incarcerated."))

				if(PRISONER_MODE_SUSPECT)
					boutput(user, SPAN_NOTICE("you switch the record mode to Suspect."))

		add_fingerprint(user)
		return

	dropped(var/mob/user)
		. = ..()
		if (src.sechud_flag != initial(src.sechud_flag))
			src.sechud_flag = initial(src.sechud_flag)
			tooltip_rebuild = TRUE
		user.closeContextActions()

//// Prisoner Scanner Context Action
/datum/contextAction/prisoner_scanner
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "wrench"
	var/mode = PRISONER_MODE_NONE

	execute(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		if(!istype(prisoner_scanner))
			return
		prisoner_scanner.switch_mode(src.mode, istype(src, /datum/contextAction/prisoner_scanner/set_sechud_flag), user)

	checkRequirements(var/obj/item/device/prisoner_scanner/prisoner_scanner, var/mob/user)
		if(!can_act(user) || !in_interact_range(prisoner_scanner, user))
			return FALSE
		return prisoner_scanner in user

	// a "mode" that acts as a simple way to set the sechud flag
	set_sechud_flag
		name = "Set Flag"
		icon_state = "flag"
	Paroled
		name = "Paroled"
		icon_state = "paroled"
		mode = PRISONER_MODE_PAROLED
	incarcerated
		name = "Incarcerated"
		icon_state = "incarcerated"
		mode = PRISONER_MODE_INCARCERATED
	released
		name = "Released"
		icon_state = "released"
		mode = PRISONER_MODE_RELEASED
	suspect
		name = "Suspect"
		icon_state = "suspect"
		mode = PRISONER_MODE_SUSPECT
	none
		name = "None"
		icon_state = "none"
		mode = PRISONER_MODE_NONE

#undef PRISONER_MODE_NONE
#undef PRISONER_MODE_PAROLED
#undef PRISONER_MODE_RELEASED
#undef PRISONER_MODE_INCARCERATED
#undef PRISONER_MODE_SUSPECT
