/datum/targetable/changeling/monkey
	name = "Lesser Form"
	desc = "Become something much less powerful."
	icon_state = "lesser"
	cooldown = 50
	targeted = 0
	target_anything = 0
	can_use_in_container = 1
	var/last_used_name = null

	onAttach(var/datum/abilityHolder/H)
		..()
		if (H?.owner) //Wire note: Fix for Cannot read null.real_name
			last_used_name = H.owner.real_name

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if(!istype(H))
			return 1
		if(isskeleton(H) && !H.organHolder.head) // Warn them if they're a headless skeleton.
			if(tgui_alert(H, "We currently lack a head. Shifting forms in this state WILL kill us.", "Hesitation", list("Continue Anyways", "Stop")) != "Continue Anyways")
				return 1
		if (ismonkey(H))
			if (!istype(H.default_mutantrace, /datum/mutantrace/monkey))
				if (tgui_alert(H,"Are we sure?","Exit this lesser form?",list("Yes","No")) != "Yes")
					return 1
				doCooldown()

				H.transforming = 1
				H.canmove = 0
				H.icon = null
				APPLY_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
				var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
				animation.icon_state = "blank"
				animation.icon = 'icons/mob/mob.dmi'
				animation.master = src
				FLICK("monkey2h", animation)
				sleep(1 SECOND)
				qdel(animation)
				qdel(H.mutantrace)
				H.set_mutantrace(null)
				H.transforming = 0
				H.canmove = 1
				H.icon = initial(H.icon)
				REMOVE_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, "transform")
				H.update_face()
				H.update_body()
				H.update_clothing()
				H.real_name = last_used_name
				H.abilityHolder.updateButtons()
				logTheThing(LOG_COMBAT, H, "leaves lesser form as a changeling, [log_loc(H)].")
				return 0
			else
				boutput(H, "We cannot leave this form in this way.")
				return 1
		else
			if (tgui_alert(H,"Are we sure?","Assume lesser form?",list("Yes","No")) != "Yes")
				return 1
			last_used_name = H.real_name
			if (H.hasStatus("handcuffed"))
				H.handcuffs.drop_handcuffs(H)
			H.delStatus("pinned") // slip out of the grab
			H.monkeyize()
			H.abilityHolder.updateButtons()
			logTheThing(LOG_COMBAT, H, "enters lesser form as a changeling, [log_loc(H)].")
			return 0

/datum/targetable/changeling/transform
	name = "Transform"
	desc = "Become someone else!"
	icon_state = "transform"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 1
	can_use_in_container = 1
	lock_holder = FALSE

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		if (length(H.absorbed_dna) < 2)
			boutput(holder.owner, SPAN_ALERT("We need to absorb more DNA to use this ability."))
			return 1

		if(headless_skeleton_warning(H)) // Warn them if they're a headless skeleton.
			return 1

		var/target_name = tgui_input_list(holder.owner, "Select the target DNA:", "Target DNA", sortList(H.absorbed_dna, /proc/cmp_text_asc))
		if (!target_name)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] transforms!</B>"))
		logTheThing(LOG_COMBAT, holder.owner, "transforms into [target_name] as a changeling [log_loc(holder.owner)].")
		var/mob/living/carbon/human/C = holder.owner
		var/datum/absorbedIdentity/face = H.absorbed_dna[target_name]
		face.apply_to(C)
		return 0

	/// Checks if a given changeling holder's owner is a headless skeleton. Warns them if
	/// they are, and returns TRUE if the warning isn't heeded-- returns FALSE otherwise.
	proc/headless_skeleton_warning(var/datum/abilityHolder/changeling/changeling_holder)
		if(!ishuman(changeling_holder.owner))
			return FALSE

		var/mob/living/carbon/human/skeleton_owner = changeling_holder.owner
		if(!isskeleton(skeleton_owner))
			return FALSE

		if(skeleton_owner.organHolder.head)
			return FALSE

		if(tgui_alert(skeleton_owner, "We currently lack a head. Shifting forms in this state WILL kill us.", "Hesitation", list("Continue Anyways", "Stop")) == "Continue Anyways")
			return FALSE
		return TRUE
