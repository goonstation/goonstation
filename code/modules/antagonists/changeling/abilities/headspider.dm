
/datum/targetable/changeling/prepare_headspider
	name = "Prepare Headspider"
	desc = "Prepare a headspider to release on death."
	icon_state = "headspider"
	targeted = 0
	pointCost = 10
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast()
		if (..())
			return 1
		var/datum/abilityHolder/changeling/lingAbilityHolder = src.holder
		if(!istype(lingAbilityHolder))
			boutput(src.holder.owner, SPAN_ALERT("You're not a changeling so can't use this ability! Call 1800-CODER with F1 and file a bug report!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if(lingAbilityHolder.headspider_ready)
			boutput(src.holder.owner, SPAN_ALERT("We have already prepared a headspider..."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		boutput(src.holder.owner, SPAN_BOLD(SPAN_NOTICE("We prepared a headspider...")))
		lingAbilityHolder.headspider_ready = TRUE
		lingAbilityHolder.removeAbilityInstance(src)
