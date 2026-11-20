/datum/statusEffect/mutiny
	id = "mutiny"
	name = "Mutiny"
	desc = "You can sense the aura of revolutionary activity! Your bossy attitude grants you health and stamina bonuses."
	icon_state = "mutiny"
	visible = FALSE
	unique = 1
	maxDuration = 1 MINUTES
	effect_quality = STATUS_QUALITY_POSITIVE
	var/const/max_health = 60
	var/const/max_stam = 30
	var/const/regen_stam = 5
	var/mob/living/carbon/human/H

	onAdd(optional=null)
		. = ..()
		if (ishuman(owner))
			H = owner
		else
			owner.delStatus("mutiny")
		H.max_health += max_health
		health_update_queue |= H
		H.add_stam_mod_max("mutiny_max", max_stam)
		APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "mutiny_regen", regen_stam)

	onRemove()
		. = ..()
		H.max_health -= max_health
		health_update_queue |= H
		H.remove_stam_mod_max("mutiny_max")
		REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "mutiny_regen")

	getTooltip()
		. = "Your max health, max stamina, and stamina regen have been increased because of your bossy attitude."


/datum/statusEffect/revspirit
	id = "revspirit"
	name = "Revolutionary Spirit"
	desc = "Your saw your revolution leaders holding some great signs. The cameraderie motivating you to fight harder!"
	icon_state = "revspirit"
	unique = 1
	maxDuration = 20 SECONDS
	effect_quality = STATUS_QUALITY_POSITIVE
	var/const/max_health = 20
	var/const/max_stam = 15
	var/const/regen_stam = 3
	var/mob/living/carbon/human/H

	onAdd(optional=null)
		. = ..()
		if (ishuman(owner))
			H = owner
		else
			owner.delStatus("revspirit")
		H.max_health += max_health
		health_update_queue |= H
		H.add_stam_mod_max("revspirit_max", max_stam)
		APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "revspirit_regen", regen_stam)

	onRemove()
		. = ..()
		H.max_health -= max_health
		health_update_queue |= H
		H.remove_stam_mod_max("revspirit_max")
		REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "revspirit_regen")

	getTooltip()
		. = "Your max stamina and stamina regen have been increased slightly."

/datum/statusEffect/newcause
	id = "newcause"
	name = "Newfound cause"
	desc = "Your newfound purpose in life has encouraged you to toughen up a little!"
	icon_state = "revspirit"
	unique = 1
	maxDuration = 5 SECONDS
	effect_quality = STATUS_QUALITY_POSITIVE
	onAdd(optional = 8)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_MELEEPROT_BODY, src, optional)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_MELEEPROT_HEAD, src, optional)

	onRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_MELEEPROT_BODY, src)
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_MELEEPROT_HEAD, src)
