/datum/targetable/brain_slug/inject_brood
	name = "Inject brood"
	desc = "Inject your brood into a corpse, letting them burst out and attack after a short time."
	icon_state = "brood"
	cooldown = 80 SECONDS
	targeted = 1

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return TRUE
		if (!istype(target, /mob/living/carbon/human))
			boutput(holder.owner, "<span class='notice'>That isn't something you can plant your brood into.</span>")
			return TRUE
		var/mob/living/carbon/human/H = target
		if (!isdead(H))
			boutput(holder.owner, "<span class='notice'>[H] is still alive.</span>")
			return TRUE
		hit_twitch(H)
		holder.owner.visible_message("<span class='alert'>[holder.owner] jabs [H] with one of it's appendages</span>", "<span class='notice'>You plant some of your brood inside [H]</span>")
		SPAWN (15 SECONDS)
			if (!H) return
			violent_standup_twitch(H)
			SPAWN (5 SECONDS)
				if (!H) return
				new/mob/living/critter/small_animal/broodling(H.loc, holder.owner, 3 MINUTES)
				new/mob/living/critter/small_animal/broodling(H.loc, holder.owner, 3 MINUTES)
				new/mob/living/critter/small_animal/broodling(H.loc, holder.owner, 3 MINUTES)
				H.visible_message("<span class='alert'>[H]'s flesh is ripped apart as some horrible creatures pour out of them!")
				gibs(H.loc, headbits = FALSE)
				random_brute_damage(H, 80)
				return
