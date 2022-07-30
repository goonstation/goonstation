/**
 * Jamming Field
 * Makes you into a walking radio jammer for 30 seconds.
 */
/datum/targetable/arcfiend/jamming_field
	name = "Jamming Field"
	desc = "Emit an aura of interference for 30 seconds, jamming nearby radios. This will be obvious to everyone nearby."
	icon_state = "jamming_field"
	cooldown = 2 MINUTES
	pointCost = 150
	container_safety_bypass = TRUE
	var/duration = 30 SECONDS

	cast(atom/target)
		. = ..()
		holder.owner.changeStatus("jamming_field", duration)
		playsound(holder.owner, "sound/effects/radio_sweep2.ogg", 30)

/datum/statusEffect/jamming_field
	id = "jamming_field"
	name = "Jamming Field"
	desc = "You're radiating out electromagnetic waves that are jamming nearby broadcasts."
	icon_state = "empulsar"
	unique = TRUE
	maxDuration = 30 SECONDS
	var/image/aura = null

	New()
		. = ..()
		aura = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
		aura.color = "#FF0"

	onAdd(optional)
		. = ..()
		if (!(owner in by_cat[TR_CAT_RADIO_JAMMERS]))
			OTHER_START_TRACKING_CAT(owner, TR_CAT_RADIO_JAMMERS)
		owner.UpdateOverlays(aura, "jamming_field_aura")

	onRemove()
		. = ..()
		if (owner in by_cat[TR_CAT_RADIO_JAMMERS])
			OTHER_STOP_TRACKING_CAT(owner, TR_CAT_RADIO_JAMMERS)
		owner.ClearSpecificOverlays("jamming_field_aura")
