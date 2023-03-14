/datum/targetable/flockmindAbility/controlPanel
	name = "Flock Control Panel"
	desc = "Open the Flock control panel."
	icon_state = "radio_stun"
	targeted = FALSE
	cooldown = 0

/datum/targetable/flockmindAbility/controlPanel/cast(atom/target)
	if(..())
		return TRUE
	if (!src.tutorial_check(FLOCK_ACTION_CONTROL_PANEL, target))
		return TRUE
	var/mob/living/intangible/flock/flockmind/F = holder.owner
	F.flock.ui_interact(holder.get_controlling_mob(), F.flock.flockpanel)
