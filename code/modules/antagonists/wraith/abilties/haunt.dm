/datum/targetable/wraithAbility/haunt
	name = "Haunt"
	icon_state = "haunt"
	desc = "Become corporeal for 30 seconds. During this time, you gain additional wraith points, depending on the amount of humans in your vicinity. Use this ability again while corporeal to fade back into the aether."
	targeted = 0
	pointCost = 0
	cooldown = 30 SECONDS
	min_req_dist = INFINITY
	start_on_cooldown = 1

	cast()
		if (..())
			return 1

		if(istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			var/mob/living/critter/wraith/trickster_puppet/P = holder.owner
			P.demanifest()
			return 0

		var/mob/living/intangible/wraith/K = src.holder.owner
		if (!K.forced_manifest && K.hasStatus("corporeal"))
			boutput(holder.owner, SPAN_NOTICE("You fade back into the shadows."))
			cooldown = 0 SECONDS
			return K.delStatus("corporeal")
		else
			boutput(holder.owner, SPAN_NOTICE("You show yourself."))
			var/mob/living/intangible/wraith/W = holder.owner

			cooldown = 30 SECONDS

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
					puppet.stepsound = T.copied_footstep_sound
					puppet.remove_typing_indicator()
					puppet.remove_emote_typing_indicator()
					puppet.voice_type = T.copied_voice
					T.set_loc(puppet)
					return 0

			//check done in case a poltergeist uses this from within their master.
			if (iswraith(W.loc))
				boutput(W, SPAN_ALERT("You can't become corporeal while inside another wraith! How would that even work?!"))
				return 1
			if (W.hasStatus("corporeal"))
				return 1
			else
				W.setStatus("corporeal", INFINITE_STATUS)
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
			return 0
