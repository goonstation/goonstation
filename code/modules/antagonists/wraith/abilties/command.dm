/datum/targetable/wraithAbility/command
	name = "Command"
	icon_state = "command"
	desc = "Command a few objects to hurl themselves at the target location. If targeted at a living being, they will be briefly stunned."
	targeted = TRUE
	target_anything = TRUE
	pointCost = 50
	cooldown = 20 SECONDS
	min_req_dist = 15

	cast(atom/target)
		. = ..()
		var/list/thrown = list()
		var/current_prob = 100
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
		if (ishuman(target))
			var/mob/living/carbon/H = target
			if (H.traitHolder.hasTrait("training_chaplain")) // we still throw stuff, but they aren't stunned
				boutput(src.holder.owner, "<span class='alert'>Some mysterious force protects [H] from your influence.</span>")
			else
				H.setStatus("stunned", max(H.getStatusDuration("weakened"), max(H.getStatusDuration("stunned"), 3 SECONDS))) // change status "stunned" to max(stunned,weakened,3)
				H.delStatus("weakened")
				H.lying = FALSE
				H.update_lying()
			H.show_message("<span class='alert'>A ghostly force compels you to be still on your feet.</span>")
		for (var/obj/O in view(7, holder.owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= 0.35 // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN(1 SECOND)
			for (var/obj/O in thrown)
				if (!QDELETED(O)) // just in case
					O.throw_at(target, 32, 2)
