/datum/targetable/vampire/vamp_cloak
	name = "Turn on Illusory Shroud"
	desc = "Toggles an illusory shroud, shielding you from being closely examined in dim lighting."
	icon_state = "darkcloak_cd"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0
	interrupt_action_bars = FALSE
	do_logs = FALSE

	cast(mob/target)
		if (!src.holder) return 1

		var/mob/living/M = holder.owner
		if (!M) return 1

		if (!M.bioHolder)
			boutput(M, SPAN_ALERT("You can't use this ability in your current form."))
			return 1

		. = ..()

		if (M.bioHolder.HasEffect("dark_examine_stopper"))
			M.bioHolder.RemoveEffect("dark_examine_stopper")
			src.name = "Turn on Illusory Shroud"
			src.icon_state = "darkcloak_cd"
		else
			M.bioHolder.AddEffect("dark_examine_stopper")
			src.name = "Turn off Illusory Shroud"
			src.icon_state = "darkcloak"
		return

/datum/bioEffect/dark_examine_stopper
	name = "Illusory Shroud"
	desc = "Allows the subject to blend in with dark enviornments, making identification all but impossible."
	id = "dark_examine_stopper"
	effectType = EFFECT_TYPE_POWER
	isBad = 0
	probability = 0
	msgGain = "You cover yourself in shadow."
	msgLose = "You allow your true form to be known."
	var/is_active = FALSE
	var/obj/effect/mist = null

	proc/apply_shroud()
		if (src.is_active) return
		src.is_active = TRUE
		src.owner.alpha = 0
		src.mist.alpha = 255
		APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_NOEXAMINE, src, 3)

	proc/remove_shroud()
		if (!src.is_active) return
		src.is_active = FALSE
		src.owner.alpha = 255
		src.mist.alpha = 0
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NOEXAMINE, src)

	OnAdd()
		src.is_active = FALSE
		src.mist = new(src.owner)
		src.mist.icon = 'icons/effects/genetics.dmi'
		src.mist.icon_state = "blank"
		src.mist.layer = MOB_OVERLAY_BASE
		src.mist.alpha = 0
		src.mist.color = "#666"
		src.mist.vis_flags = VIS_INHERIT_DIR
		src.mist.appearance_flags = RESET_ALPHA | KEEP_APART
		animate_wave(src.mist)
		src.owner.vis_contents.Add(src.mist)
		var/turf/T = get_turf(src.owner)
		if (isturf(T) && !T.is_lit())
			src.apply_shroud()
		. = ..()

	OnRemove()
		src.remove_shroud()
		src.owner.vis_contents.Remove(src.mist)
		qdel(src.mist)
		. = ..()

	OnLife(mult)
		if(..())
			return
		if (!isliving(owner))
			src.remove_shroud()
			return

		var/mob/living/L = owner
		var/turf/T = get_turf(L)

		if (!isturf(T) || T.is_lit())
			src.remove_shroud()
		else if (can_act(src.owner))
			src.apply_shroud()
