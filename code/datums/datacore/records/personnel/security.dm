/datum/db_record/personnel/security

/datum/db_record/personnel/security/build_fields()
	return alist(
		BUILD_FIELD("id",			/datum/record_field/string,				"ID", "000000", @"[a-f0-9]{6}"),
		BUILD_FIELD("criminal",		/datum/record_field/choice/criminal,	"Criminal Status"),
		BUILD_FIELD("sec_flag",		/datum/record_field/string/sec_flag,	"SecHUD Flag"),
		BUILD_FIELD("citations",	/datum/record_field/record_list,		"Citations"),
		BUILD_FIELD("mi_crim",		/datum/record_field/string,				"Minor Crimes", "None"),
		BUILD_FIELD("mi_crim_d",	/datum/record_field/string,				"Details", "No minor crime convictions."),
		BUILD_FIELD("ma_crim",		/datum/record_field/string,				"Major Crimes", "None"),
		BUILD_FIELD("ma_crim_d",	/datum/record_field/string,				"Details", "No major crime convictions."),
		BUILD_FIELD("notes",		/datum/record_field/string,				"Important Notes", "No notes."),
	)

/datum/db_record/personnel/security/New(source)
	. = ..()

	var/datum/record_field/record_list/citations = src.get_field_datum("citations")
	citations.record_group = new /datum/db_record_group/citation/record(src)

	src.RegisterSignal(src.get_field_datum("criminal"), COMSIG_FIELD_VALUE_CHANGED, PROC_REF(on_criminal_status_change))

/datum/db_record/personnel/security/disposing()
	src["criminal"] = SECURITY::ARREST::STATE::NONE
	src.UnregisterSignal(src.get_field_datum("criminal"), COMSIG_FIELD_VALUE_CHANGED)
	. = ..()

/datum/db_record/personnel/security/init_from_human(mob/living/carbon/human/H)
	src["id"] = H.datacore_id

	if (H.traitHolder?.hasTrait("training_clown"))
		src["criminal"] = SECURITY::ARREST::STATE::CLOWN
		src["mi_crim"] = "Clown"

	if (H.client?.preferences?.security_note)
		src["notes"] = H.client?.preferences?.security_note

/// Called when the value of the criminal status field is updated.
/datum/db_record/personnel/security/proc/on_criminal_status_change()
	var/datum/db_record/personnel/general/record = global.data_core.get_general_record(id = src["id"])
	if (!istype(record))
		return

	var/target_name = record["name"]
	for_by_tcl(H, /mob/living/carbon/human)
		if ((H.real_name == target_name) || (H.name == target_name))
			H.update_arrest_icon()
