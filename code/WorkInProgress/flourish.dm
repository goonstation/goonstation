/obj/item/device/ticket_writer/odd
	name = "Security TicketWriter 3000"
	desc = "This new and improved edition features upgraded hardware and extra crime-deterring features."
	icon_state = "ticketwriter-odd"

	ticket(mob/user)
		var/target_key = ..()
		if (isnull(target_key))
			return
		var/mob/M = ckey_to_mob(target_key)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/limb = pick("l_arm","r_arm","l_leg","r_leg")
			H.sever_limb(limb)

/obj/death_button/hotdog

	attack_hand(mob/user)
		if (current_state < GAME_STATE_FINISHED && !isadmin(user))
			boutput(user, "<span class='alert'>Looks like you can't press this yet.</span>")
			return
		if (user.stat)
			return
		var/turf/T = get_turf(src)
		T.fluid_react_single("hot_dog", 3000)
		new /obj/effect/supplyexplosion(T)
		playsound(T, 'sound/effects/ExplosionFirey.ogg', 100, 1)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.limbs.sever("all")
		else
			user.gib()



