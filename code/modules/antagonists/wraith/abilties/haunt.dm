/datum/targetable/wraithAbility/haunt
	name = "Haunt"
	icon_state = "haunt"
	desc = "Become corporeal until disabled, with a 30 second minimum haunt duration. During this time, you gain additional biopoints, depending on the amount of humans in your vicinity. Use this ability again while corporeal to fade back into the aether."
	cooldown = 30 SECONDS
	targeted = FALSE
	start_on_cooldown = TRUE

	cast()
		. = ..()
		if(istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			var/mob/living/critter/wraith/trickster_puppet/P = holder.owner
			P.demanifest()
			return FALSE

		var/mob/living/intangible/wraith/K = src.holder.owner
		if (!K.forced_manifest && K.hasStatus("corporeal"))
			boutput(holder.owner, "<span class='alert'>We fade back into the shadows...</span>")
			src.cooldown = 0 SECONDS
			K.delStatus("corporeal")
		else
			var/mob/living/intangible/wraith/W = holder.owner

			src.cooldown = initial(src.cooldown)

			if ((istype(W, /mob/living/intangible/wraith/wraith_trickster)))	//Trickster can appear as a human, living or dead.
				var/mob/living/intangible/wraith/wraith_trickster/T = holder.owner
				if (T.copied_appearance != null)
					var/mob/living/critter/wraith/trickster_puppet/puppet = new /mob/living/critter/wraith/trickster_puppet(get_turf(T), T, T.copied_name, T.copied_real_name)
					puppet.name_tag.set_info_tag(T.copied_pronouns)
					puppet.name_tag.set_name(puppet.name, strip_parentheses=TRUE)
					T.mind.transfer_to(puppet)
					puppet.appearance = T.copied_appearance
					puppet.desc = T.copied_desc
					puppet.traps_laid = T.traps_laid
					puppet.playsound_local(puppet.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
					puppet.alpha = 0
					animate(puppet, alpha=255, time=2 SECONDS)
					puppet.flags &= UNCRUSHABLE
					T.set_loc(puppet)
					return FALSE

			//check done in case a poltergeist uses this from within their master.
			if (iswraith(W.loc))
				boutput(W, "You can't become corporeal while inside another wraith! How would that even work?!")
				return TRUE
			if (W.hasStatus("corporeal"))
				return TRUE
			else
				W.setStatus("corporeal", INFINITE_STATUS)
				src.holder.owner.playsound_local(src.holder.owner.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
