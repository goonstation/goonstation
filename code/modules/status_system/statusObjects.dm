// Silver nitrate is applied to
/datum/statusEffect/forensic_silver_nitrate
	id = "forensic_silver_nitrate"
	name = "Silver Nitrate"
	icon_state = "oil"
	maxDuration = 60 SECONDS
	unique = 1
	visible = FALSE

	getExamine()
		if(!owner.forensic_holder.get_group(FORENSIC_GROUP_FINGERPRINTS))
			return null
		. = "Fingerprints appear more visible."
