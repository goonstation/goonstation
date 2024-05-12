/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "possession"
	desc = "Channel your energy and slowly gain control over a living being. This requires 50 possession points, and the victim will immediately know that something is happening."
	pointCost = 400
	targeted = 1
	cooldown = 3 MINUTES
	ignore_holder_lock = 0

	cast(mob/target)
		if (..())
			return TRUE
		if (!istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			return TRUE
		var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
		var/datum/abilityHolder/wraith/AH = W.abilityHolder
		if (AH.possession_points < W.points_to_possess)
			boutput(holder.owner, SPAN_ALERT("You cannot possess with only [AH.possession_points] possession power. You'll need at least [(W.points_to_possess - AH.possession_points)] more."))
			return TRUE
		if (!ishuman(target) || isdead(target))
			return TRUE
		var/mob/living/carbon/human/H = target
		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, SPAN_ALERT("As you try to reach inside this creature's mind, it instantly kicks you back into the aether!"))
			return
		AH.possession_points = 0
		actions.start(new/datum/action/bar/private/icon/trickster_possession(target), holder.owner)
		return

/datum/action/bar/private/icon/trickster_possession
	duration = 32 SECONDS
	interrupt_flags = INTERRUPT_NONE
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "possession_over"
	var/mob/living/target
	var/last_time_spent = 0

	New(Target)
		target = Target
		..()

	onStart()
		..()
		boutput(owner, SPAN_NOTICE("You begin to force yourself into [target]'s mind. This will take some time..."))
		boutput(target, SPAN_ALERT("You suddenly feel awfully woozy..."))
		target.emote("scream")
		target.change_misstep_chance(20)

	onUpdate()
		..()
		if (QDELETED(owner) || QDELETED(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (owner.z != target.z)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/time_spent = src.time_spent()
		if (time_spent >= 10 SECONDS && last_time_spent < 10 SECONDS)
			boutput(target, SPAN_ALERT("You hear a cacophony of otherwordly voices in your head!"))
			target.emote("faint")
			target.setStatusMin("knockdown", 5 SECONDS)
		if (time_spent >= 25 SECONDS && last_time_spent < 25 SECONDS)
			boutput(target, SPAN_ALERT("<font size=+2>Something is forcing its way into your mind!!</font>"))
			target.change_misstep_chance(-20)
			target.emote("scream")
			target.setStatusMin("knockdown", 8 SECONDS)
			target.setStatusMin("unconscious", 8 SECONDS)
		last_time_spent = time_spent

	onEnd()
		..()
		var/datum/statusEffect/trickster_possessed/TP = target.setStatus("trickster_possessed", 65 SECONDS)
		TP.setup(owner, target)

/datum/statusEffect/trickster_possessed
	id = "trickster_possessed"
	name = "Possessed"
	icon_state = "possess"
	unique = TRUE
	maxDuration = 65 SECONDS
	var/mob/dead/target_observer/slasher_ghost/SG
	var/mob/living/intangible/wraith/W
	var/wraith_key
	var/datum/mind/wraith_mind = null
	var/datum/mind/human_mind = null
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
				target_player.dnr--;
			src.human_mind.transfer_to(src.owner)
			playsound(src.owner, 'sound/effects/ghost2.ogg', 50, FALSE)
		qdel(SG)
		if (isliving(src.owner))
			var/mob/living/L = src.owner
			L.take_brain_damage(30)
		W.set_loc(get_turf(src.owner))
		W.set_dir(src.owner.dir)
		src.owner.setStatus("knockdown", 5 SECOND)
		boutput(src.owner, SPAN_ALERT("The presence has left your body and you are thrust back into it, immediately assaulted with a ringing headache."))

	onUpdate(timePassed)
		..()
		if (duration <= 20 SECONDS && last_duration > 20 SECONDS)
			boutput(src.owner, "<span class='bold' style='color:red;font-size:150%'>Your control on this body is weakening! You will soon be kicked out of it.</span>")
		last_duration = src.duration

	proc/setup(mob/living/W, mob/living/T)
		src.W = W
		src.wraith_key = W.key
		src.wraith_mind = W.mind
		var/datum/player/target_player = T.mind?.get_player()
		if (target_player != null)
			target_player?.dnr++
			var/mob/dead/observer/O = T.ghostize()
			if (O?.mind)
				human_mind = O.mind
				boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
				src.SG = O.insert_slasher_observer(T)
		src.wraith_mind.transfer_to(T)
		boutput(T, "<span class='bold' style='color:red;font-size:150%'>You have assumed control of this body! You don't have long...</span>")
		RegisterSignal(T, COMSIG_MOB_DEATH, PROC_REF(return_wraith))
		APPLY_ATOM_PROPERTY(T, PROP_MOB_NO_SELF_HARM, T)

	proc/return_wraith()
		UnregisterSignal(src.owner, COMSIG_MOB_DEATH)
		if (QDELETED(src.W) || src.W.mind == src.wraith_mind)
			return
		//yes this is expensive as hell, but we need to be SURE
		var/mob/M = ckey_to_mob_maybe_disconnected(src.wraith_key, FALSE)
		M.mind.transfer_to(src.W)
