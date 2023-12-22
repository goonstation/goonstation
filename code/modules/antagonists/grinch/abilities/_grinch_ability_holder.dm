// Converted everything related to grinches from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

//////////////////////////////////////////// Ability holder /////////////////////////////////////////
/datum/abilityHolder/grinch
	usesPoints = FALSE
	tabName = "Grinch"

/////////////////////////////////////////////// Grinch spell parent ////////////////////////////

/datum/targetable/grinch
	icon = 'icons/mob/grinch_ui.dmi'
	icon_state = "grinchtemplate"
	preferred_holder_type = /datum/abilityHolder/grinch
