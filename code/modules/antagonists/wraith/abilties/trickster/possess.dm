/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "possession"
	desc = "Channel your energy and slowly gain control over a living being. This requires 50 possession points, and the victim will immediately know that something is happening."
	pointCost = 400
	targeted = TRUE
	cooldown = 3 MINUTES
	ignore_holder_lock = FALSE

	allowcast()
		var/mob/living/intangible/wraith/wraith_trickster/W = src.holder.owner
		var/datum/abilityHolder/wraith/AH = src.holder
		if (istype(W) && istype(AH) && AH.possession_points < W.points_to_possess)
			return
		return ..()

	cast(mob/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/mob/living/intangible/wraith/wraith_trickster/W = src.holder.owner
		if (!istype(W))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/datum/abilityHolder/wraith/AH = src.holder
		if (AH.possession_points < W.points_to_possess)
			boutput(src.holder.owner, SPAN_ALERT("You cannot possess with only [AH.possession_points] possession power. You'll need at least [(W.points_to_possess - AH.possession_points)] more."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("This ability can only affect humans."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/mob/living/carbon/human/H = target
		if (isdead(H))
			boutput(src.holder.owner, SPAN_ALERT(pick(
				"You couldn't possibly possess a dead body! What are you, a harbinger? Gosh.",
				"What a mundane trick. Possessing a dead body is beneath you.")))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(src.holder.owner, SPAN_ALERT("As you try to reach inside this creature's mind, it instantly kicks you back into the aether!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		AH.possession_points = 0
		actions.start(new/datum/action/bar/icon/trickster_possession(H), holder.owner)
		return CAST_ATTEMPT_SUCCESS



/datum/action/bar/icon/trickster_possession
	duration = 32 SECONDS
	interrupt_flags = INTERRUPT_NONE
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "possession_over"
	var/mob/living/target
	var/last_time_spent = 0

	New(Target)
		src.target = Target
		..()

	onStart()
		..()
		boutput(src.owner, SPAN_NOTICE("You begin to force yourself into [src.target]'s mind. This will take some time..."))
		boutput(src.target, SPAN_ALERT("You suddenly feel awfully woozy..."))
		src.target.emote("scream")
		src.target.change_misstep_chance(20)
		APPLY_ATOM_PROPERTY(src.target, PROP_MOB_PRE_POSSESSION, "\ref[src]")

	onUpdate()
		..()
		if (QDELETED(src.owner) || QDELETED(src.target))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.owner.z != src.target.z)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/time_spent = src.time_spent()
		if (time_spent >= 10 SECONDS && last_time_spent < 10 SECONDS)
			boutput(src.target, SPAN_ALERT("You hear a cacophony of otherwordly voices in your head!"))
			src.target.emote("faint")
			src.target.setStatusMin("knockdown", 5 SECONDS)
		if (time_spent >= 25 SECONDS && last_time_spent < 25 SECONDS)
			boutput(src.target, SPAN_ALERT("<font size=+2>Something is forcing its way into your mind!!</font>"))
			src.target.change_misstep_chance(-20)
			src.target.emote("scream")
			src.target.setStatusMin("knockdown", 8 SECONDS)
			src.target.setStatusMin("unconscious", 8 SECONDS)
		last_time_spent = time_spent

	onEnd()
		..()
		var/datum/statusEffect/trickster_possessed/TP = src.target.setStatus("trickster_possessed", 65 SECONDS)
		TP.setup(src.owner, src.target)
		REMOVE_ATOM_PROPERTY(src.target, PROP_MOB_PRE_POSSESSION, "\ref[src]")

	onInterrupt(flag)
		REMOVE_ATOM_PROPERTY(src.target, PROP_MOB_PRE_POSSESSION, "\ref[src]")
		. = ..()



/datum/statusEffect/trickster_possessed
	id = "trickster_possessed"
	name = "Possessed"
	icon_state = "possess"
	unique = TRUE
	maxDuration = 65 SECONDS
	var/mob/dead/target_observer/slasher_ghost/human_observer
	var/mob/living/intangible/wraith/wraith_mob
	var/wraith_key
	var/datum/mind/wraith_mind
	var/datum/mind/human_mind
	var/last_duration = 0

	getTooltip()
		// The victim can see the parent's status effects, so this makes sure that they see a unique tooltip when they hover over this one
		if (usr.mind == src.wraith_mind)
			return "You have temporarily assumed control of this body! When the duration expires, you will return to incorporeal form."
		else
			return "You're a prisoner in your own body! You're powerless to move or act until the possession fades..."

	onRemove()
		..()
		if (QDELETED(src.owner))
			return
		boutput(src.owner, "<span class='bold' style='color:red;font-size:150%'>Your hold on this body has been broken! You return to the aether.</span>")
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_SELF_HARM, src.owner)
		src.return_wraith()
		if (src.human_mind)
			var/datum/player/target_player = src.human_mind.get_player()
			if (target_player != null)
				target_player.dnr--
			src.human_mind.transfer_to(src.owner)
			playsound(src.owner, 'sound/effects/ghost2.ogg', 50)
		qdel(src.human_observer)
		if (isliving(src.owner))
			var/mob/living/L = src.owner
			L.take_brain_damage(30)
		src.owner.setStatus("knockdown", 5 SECOND)
		boutput(src.owner, SPAN_ALERT("The presence has left your body and you are thrust back into it, immediately assaulted with a ringing headache."))

	onUpdate(timePassed)
		..()
		if (duration <= 20 SECONDS && last_duration > 20 SECONDS)
			boutput(src.owner, "<span class='bold' style='color:red;font-size:150%'>Your control on this body is weakening! You will soon be kicked out of it.</span>")
		last_duration = src.duration

	proc/setup(mob/living/W, mob/living/T)
		src.wraith_mob = W
		src.wraith_key = W.key
		src.wraith_mind = W.mind
		var/datum/player/target_player = T.mind?.get_player()
		if (target_player != null)
			target_player?.dnr++
			var/mob/dead/observer/O = T.ghostize()
			if (O?.mind)
				human_mind = O.mind
				boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
				src.human_observer = O.insert_slasher_observer(T)
		src.wraith_mind.transfer_to(T)
		src.wraith_mob.delStatus("corporeal")
		src.wraith_mob.set_loc(T)
		boutput(T, "<span class='bold' style='color:red;font-size:150%'>You have assumed control of this body! You don't have long...</span>")
		RegisterSignal(T, COMSIG_MOB_DEATH, PROC_REF(return_wraith))
		APPLY_ATOM_PROPERTY(T, PROP_MOB_NO_SELF_HARM, T)
		message_ghosts("<b>[src.wraith_mob]</b> has possessed <b>[src.owner]</b> at [log_loc(src.owner, ghostjump = TRUE)]!")
		for (var/mob/dead/target_observer/TO in src.wraith_mob.observers)
			if (TO == src.human_observer)
				continue
			TO.set_observe_target(src.owner)

	proc/return_wraith()
		UnregisterSignal(src.owner, COMSIG_MOB_DEATH)
		if (QDELETED(src.wraith_mob) || src.wraith_mob.mind == src.wraith_mind)
			return
		src.wraith_mob.set_loc(get_turf(src.owner))
		src.wraith_mob.set_dir(src.owner.dir)
		message_ghosts("<b>[src.wraith_mob]</b> is no longer possessing <b>[src.owner]</b> at [log_loc(src.wraith_mob, ghostjump = TRUE)].")
		var/mob/owner_mob = src.owner
		for (var/mob/dead/target_observer/TO in owner_mob.observers)
			if (TO == src.human_observer)
				continue
			TO.set_observe_target(src.wraith_mob)
		//yes this is expensive as hell, but we need to be SURE
		var/mob/M = ckey_to_mob_maybe_disconnected(src.wraith_key, FALSE)
		M.mind.transfer_to(src.wraith_mob)
