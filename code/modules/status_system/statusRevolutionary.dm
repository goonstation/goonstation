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

/datum/statusEffect/weakened_loyalty
	id = "weakened_loyalty"
	name = "Weakened Loyalty"
	desc = "You shouldn't see me!"
	visible = FALSE
	unique = 1
	maxDuration = /datum/game_mode/revolution::keywords_maximum_duration
	effect_quality = STATUS_QUALITY_NEGATIVE
	var/datum/action/bar/weakened_loyalty/progress_bar //Hack.

	preCheck(atom/A)
		if(!iscarbon(A))
			return FALSE
		return ..()

	onAdd(optional)
		. = ..()
		src.setup_bar()

	onRemove()
		. = ..()
		QDEL_NULL(src.progress_bar)

	onChange(optional)
		. = ..()
		src.progress_bar.onUpdate()

	onUpdate(optional)
		. = ..()
		src.progress_bar.onUpdate()

	proc/setup_bar()
		src.progress_bar = new()
		src.progress_bar.owner = src.owner
		src.progress_bar.onStart()
		src.progress_bar.onUpdate()

/datum/action/bar/weakened_loyalty // Hacky, copying from blob health
	border_icon_state = "border_thin_loyalty"
	bar_y_offset = 7

	onStart()
		. = ..()
		src.bar.icon = null
		src.border.icon = null
		var/datum/client_image_group/rev_image_group = global.get_image_group(ROLE_REVOLUTIONARY)
		rev_image_group.add_image(src.bar.img)
		rev_image_group.add_image(src.border.img)

	onUpdate()
		var/datum/statusEffect/weakened_loyalty/loyalty_status = src.owner.hasStatus("weakened_loyalty")
		if (!owner || !istype(owner)|| !bar || !border)
			return
		if(!loyalty_status || !istype(loyalty_status)) //Owner lost the effect, remove the bar.
			src.interrupt(INTERRUPT_ALWAYS)
			return
		var/complete = clamp((1 - (loyalty_status.duration / loyalty_status.maxDuration)), 0, 1)
		if(loyalty_status.duration >= /datum/game_mode/revolution::keywords_required_duration_to_convert)
			src.bar.color = "#00FF00"
		else if (complete < 0.7)
			src.bar.color = "#ff8800"
		else
			src.bar.color = "#FF0000"
		var/bar_width = complete * 0.8 //take 20% off so the loyalty icon on the left side can be shown
		src.bar.transform = matrix(bar_width, 1, MATRIX_SCALE)
		var/bar_pixel_width = round(30 * bar_width)
		src.bar.pixel_x = 4 - round((26 - bar_pixel_width) / 2) //Offset by an additional 6 so the loyalty icon is shown

