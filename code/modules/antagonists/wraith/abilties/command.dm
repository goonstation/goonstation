/datum/targetable/wraithAbility/command
	name = "Command"
	icon_state = "command"
	desc = "Command a few objects to hurl themselves at the target location."
	targeted = 1
	target_anything = 1
	pointCost = 50
	cooldown = 20 SECONDS
	min_req_dist = 15

	cast(atom/T)
		var/list/thrown = list()
		var/current_prob = 100
		if(..())
			return 1
		if (ishuman(T))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, SPAN_ALERT("Some mysterious force protects [T] from your influence."))
				return 1
			else
				H.setStatus("stunned", max(H.getStatusDuration("knockdown"), max(H.getStatusDuration("stunned"), 3))) // change status "stunned" to max(stunned,weakened,3)
				// T:stunned = max(max(T:weakened, T:stunned), 3)
				H.delStatus("knockdown")
				H.lying = 0
				H.show_message(SPAN_ALERT("A ghostly force compels you to be still on your feet."))
		for (var/obj/O in view(7, holder.owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= 0.35 // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(T, 32, 2)

		return 0
