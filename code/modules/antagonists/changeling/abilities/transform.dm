/datum/targetable/changeling/transform
	name = "Transform"
	desc = "Become someone else!"
	icon_state = "transform"
	cooldown = 0
	targeted = 0
	target_anything = 0
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

		if(src.headless_skeleton_warning()) // Headless skeletons die if they use this.
			return 1

		var/target_name = tgui_input_list(holder.owner, "Select the target DNA:", "Target DNA", sortList(H.absorbed_dna, /proc/cmp_text_asc))
		if (!target_name)
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		var/datum/absorbedIdentity/current_ident = H.current_ident
		if (target_name == src.holder.owner.real_name && !current_ident.always_switch)
			return 1

		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] transforms!</B>"))
		logTheThing(LOG_COMBAT, holder.owner, "transforms into [target_name] as a changeling [log_loc(holder.owner)].")
		var/mob/living/carbon/human/C = holder.owner
		var/datum/absorbedIdentity/face = H.absorbed_dna[target_name]
		//re-store the current identity, it may have been modified
		if (!current_ident.do_not_store && !face.do_not_store)
			current_ident = new(C)
			H.absorbed_dna[src.holder.owner.real_name] = current_ident
		face.apply_to(C)
		if (istype(face, /datum/absorbedIdentity/monkey) || face.bioHolder.HasEffect("monkey"))
			if (C.hasStatus("handcuffed"))
				C.handcuffs.drop_handcuffs(C)
			C.delStatus("pinned") // slip out of the grab
		H.current_ident = face
		return 0
