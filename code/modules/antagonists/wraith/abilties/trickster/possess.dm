/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "possession"
	desc = "Channel your energy and slowly gain control over a living being."
	pointCost = 400
	targeted = 1
	cooldown = 3 MINUTES
	ignore_holder_lock = 0
	var/wraith_key = null
	var/datum/mind/wraith_mind = null
	var/datum/mind/human_mind = null

	cast(mob/target)
		if (..())
			return TRUE
		if (!istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			return TRUE
		var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
		var/datum/abilityHolder/wraith/AH = W.abilityHolder
		if (AH.possession_points < W.points_to_possess)
			boutput(holder.owner, "You cannot possess with only [AH.possession_points] possession power. You'll need at least [(W.points_to_possess - AH.possession_points)] more.")
			return TRUE
		if (!ishuman(target) || isdead(target))
			return TRUE
		var/mob/living/carbon/human/H = target
		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>As you try to reach inside this creature's mind, it instantly kicks you back into the aether!</span>")
			return FALSE
		var/mob/dead/target_observer/slasher_ghost/WG = null
		wraith_key = holder.owner.ckey
		H.emote("scream")
		boutput(H, "<span class='alert'>You are feeling awfully woozy.</span>")
		H.change_misstep_chance(20)
		SPAWN(10 SECONDS)
			if (!(H?.loc && W?.loc)) return
			boutput(H, "<span class='alert'>You hear a cacophony of otherwordly voices in your head.</span>")
			H.emote("faint")
			H.setStatusMin("weakened", 5 SECONDS)
			sleep(15 SECONDS)
			if (!(H?.loc && W?.loc)) return
			H.change_misstep_chance(-20)
			H.emote("scream")
			H.setStatusMin("weakened", 8 SECONDS)
			H.setStatusMin("paralysis", 8 SECONDS)
			sleep(8 SECONDS)
			if (!(H?.loc && W?.loc)) return	//Wraith and the human are both gone, abort
			if(isnull(W.mind))	//Wraith died or was removed in the meantime
				return
			var/datum/player/target_player = H.mind?.get_player()
			target_player?.dnr++
			var/mob/dead/observer/O = H.ghostize()
			if (O?.mind)
				human_mind = O.mind
				boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
				WG = O.insert_slasher_observer(H)
			wraith_mind = W.mind
			W.mind.transfer_to(H)
			RegisterSignal(H, COMSIG_MOB_DEATH, .proc/return_wraith)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)	//Subject to change.
			sleep(45 SECONDS)
			if (!H?.loc)
				target_player?.dnr--
				return
			boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your control on this body is weakening, you will soon be kicked out of it.</span>")
			sleep(20 SECONDS)
			if(!H?.loc && !W.loc) //Everyone's dead, go home
				target_player?.dnr--
				return
			if(!W.loc) //wraith got gibbed, kick them into the aether and put the human back
				boutput(H, "<span class='alert'>You are torn apart from the body you were in but cannot find your ethereal self! You are thrown into the otherworld as a powerless ghost.</span>")
				H.ghostize()
				REMOVE_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)
				if (human_mind)
					human_mind.transfer_to(H)
					playsound(H, 'sound/effects/ghost2.ogg', 50, 0)
					boutput(H, "<span class='notice'>You slowly regain control of your body. It's as if the presence within you dissipated into nothingness.</span>")
				target_player?.dnr--
				return
			target_player?.dnr--
			if(!H?.loc) //Human gibbed, put the wraith back into their body
				src.return_wraith(H)
			else
				boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your hold on this body has been broken! You return to the aether.</span>")
				REMOVE_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)
				src.return_wraith(H)
				if (human_mind)
					human_mind.transfer_to(H)
					playsound(H, 'sound/effects/ghost2.ogg', 50, 0)
			qdel(WG)
			H.take_brain_damage(30)
			H.setStatus("weakened", 5 SECOND)
			boutput(H, "<span class='notice'>The presence has left your body and you are thrusted back into it, immediately assaulted with a ringing headache.</span>")
		return FALSE

	proc/return_wraith(mob/possessed) //we want to be absolutely sure the wraith goes back to their body no matter what
		var/datum/abilityHolder/wraith/AH = src.holder
		AH.possession_points = 0
		UnregisterSignal(possessed, COMSIG_MOB_DEATH)
		if (QDELETED(src.holder.owner)) //hopefully catch the wraith dying?
			return
		//yes this is expensive as hell, but we need to be SURE
		var/mob/M = ckey_to_mob_maybe_disconnected(wraith_key, FALSE)
		M.mind.transfer_to(src.holder.owner)

	disposing()
		wraith_mind = null
		human_mind = null
		. = ..()
