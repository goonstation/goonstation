/// Makes the user functions as a radio jammer for the duration. Functions by applying a status effect with a visible aura.
/datum/targetable/arcfiend/jamming_field
	name = "Jamming Field"
	desc = "Emit an aura of interference for 30 seconds, jamming nearby radio transmissions."
	icon_state = "jamming_field"
	cooldown = 2 MINUTES
	pointCost = 150
	var/duration = 30 SECONDS

	cast(atom/target)
		. = ..()
		src.holder.owner.changeStatus("jamming_field", src.duration)
		playsound(src.holder.owner, 'sound/effects/radio_sweep2.ogg', 30)

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
		src.aura = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
		src.aura.color = "#FF0"

	onAdd(optional)
		. = ..()
		if (!(src.owner in by_cat[TR_CAT_RADIO_JAMMERS]))
			OTHER_START_TRACKING_CAT(src.owner, TR_CAT_RADIO_JAMMERS)
		src.owner.AddOverlays(src.aura, "jamming_field_aura")

	onRemove()
		. = ..()
		if (src.owner in by_cat[TR_CAT_RADIO_JAMMERS])
			OTHER_STOP_TRACKING_CAT(src.owner, TR_CAT_RADIO_JAMMERS)
		src.owner.ClearSpecificOverlays("jamming_field_aura")
