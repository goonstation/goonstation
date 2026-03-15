TYPEINFO(/obj/item/device/prisoner_scanner)
	mats = 3

/obj/item/device/prisoner_scanner
	name = "security RecordTrak"
	desc = "A device used to scan in prisoners and update their security records."
	icon_state = "recordtrak"
	var/datum/db_record/active1 = null
	var/datum/db_record/active2 = null
	item_state = "recordtrak"
	flags = TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = ONBELT

	#define PRISONER_MODE_NONE 1
	#define PRISONER_MODE_PAROLED 2
	#define PRISONER_MODE_RELEASED 3
	#define PRISONER_MODE_INCARCERATED 4
	#define PRISONER_MODE_SUSPECT 5

	///List of record settings
	var/static/list/modes = list(PRISONER_MODE_NONE, PRISONER_MODE_PAROLED, PRISONER_MODE_INCARCERATED, PRISONER_MODE_RELEASED, PRISONER_MODE_SUSPECT)
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

		////General Records
		var/found = 0
		//if( !istype(get_area(src), /area/security/prison) && !istype(get_area(src), /area/security/main))
		//	boutput(user, SPAN_ALERT("Device only works in designated security areas!"))
		//	return
		boutput(user, SPAN_NOTICE("You scan in [target]."))
		boutput(target, SPAN_ALERT("[user] scans you with the RecordTrak!"))
		for(var/datum/db_record/R as anything in data_core.general.records)
			if (lowertext(R["name"]) == lowertext(target.real_name))
				//Update Information
				R["name"] = target.real_name
				R["sex"] = target.gender
				R["pronouns"] = target.get_pronouns().name
				R["age"] = target.bioHolder.age
				if (!target.gloves?.print_mask)
					R["fingerprint_right"] = "[target.limbs?.r_arm?.limb_print.id]"
					R["fingerprint_left"] = "[target.limbs?.l_arm?.limb_print.id]"
				R["p_stat"] = "Active"
				R["m_stat"] = "Stable"
				src.active1 = R
				found = 1

		if(found == 0)
			src.active1 = new /datum/db_record()
			src.active1["id"] = num2hex(rand(1, 0xffffff),6)
			src.active1["rank"] = "Unassigned"
			//Update Information
			src.active1["name"] = target.real_name
			src.active1["sex"] = target.gender
			src.active1["pronouns"] = target.get_pronouns().name
			src.active1["age"] = target.bioHolder.age
			/////Fingerprint record update
			if (target.gloves?.print_mask && target.gloves?.print_mask.id != FORENSIC_GLOVE_MASK_FINGERLESS)
				src.active1["fingerprint_right"] = "Unknown"
				src.active1["fingerprint_left"] = "Unknown"
			else
				if(target.limbs?.r_arm?.limb_print)
					src.active1["fingerprint_right"] = "[target.limbs?.r_arm?.limb_print]"
				else
					src.active1["fingerprint_right"] = "None"
				if(target.limbs?.l_arm?.limb_print)
					src.active1["fingerprint_left"] = "[target.limbs?.l_arm?.limb_print]"
				else
					src.active1["fingerprint_right"] = "None"
			src.active1["p_stat"] = "Active"
			src.active1["m_stat"] = "Stable"
			data_core.general.add_record(src.active1)

			// Bank Records
			var/bank_record = new/datum/db_record()
			bank_record["name"] = src.active1["name"]
			bank_record["id"] = src.active1["id"]
			bank_record["current_money"] = 0
			bank_record["unionized"] = "No"
			bank_record["wage"] = 0
			bank_record["notes"] = "No notes."
			if(istype(target.wear_id, /obj/item/device/pda2))
				var/obj/item/device/pda2/worn_pda = target.wear_id
				bank_record["pda_net_id"] = worn_pda.net_id
			data_core.bank.add_record(bank_record)

		////Security Records
		var/datum/db_record/E = data_core.security.find_record("name", src.active1["name"])
		if(E)
			switch (mode)
				if(PRISONER_MODE_NONE)
					E["criminal"] = ARREST_STATE_NONE

				if(PRISONER_MODE_PAROLED)
					E["criminal"] = ARREST_STATE_PAROLE

				if(PRISONER_MODE_RELEASED)
					E["criminal"] = ARREST_STATE_RELEASED

				if(PRISONER_MODE_INCARCERATED)
					E["criminal"] = ARREST_STATE_INCARCERATED

				if(PRISONER_MODE_SUSPECT)
					E["criminal"] = ARREST_STATE_SUSPECT
			E["sec_flag"] = src.sechud_flag
			target.update_arrest_icon()
			return


		src.active2 = new /datum/db_record()
		src.active2["name"] = src.active1["name"]
		src.active2["id"] = src.active1["id"]
		switch (mode)
			if(PRISONER_MODE_NONE)
				src.active2["criminal"] = ARREST_STATE_ARREST

			if(PRISONER_MODE_PAROLED)
				src.active2["criminal"] = ARREST_STATE_PAROLE

			if(PRISONER_MODE_RELEASED)
				src.active2["criminal"] = ARREST_STATE_RELEASED

			if(PRISONER_MODE_INCARCERATED)
				src.active2["criminal"] = ARREST_STATE_INCARCERATED

			if(PRISONER_MODE_SUSPECT)
				src.active2["criminal"] = ARREST_STATE_SUSPECT

		src.active2["sec_flag"] = src.sechud_flag
		src.active2["mi_crim"] = "None"
		src.active2["mi_crim_d"] = "No minor crime convictions."
		src.active2["ma_crim"] = "None"
		src.active2["ma_crim_d"] = "No major crime convictions."
		src.active2["notes"] = "No notes."
		data_core.security.add_record(src.active2)

		target.update_arrest_icon()

		return

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	proc/switch_mode(var/mode, set_flag, var/mob/user)
		if (set_flag)
			var/flag = tgui_input_text(user, "Flag:", "Set SecHUD Flag", initial(src.sechud_flag), SECHUD_FLAG_MAX_CHARS)
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
