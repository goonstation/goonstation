
/mob/attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0, mob/meatshield)
	actions.interrupt(src, INTERRUPT_ATTACKED)

	// why is this not in human/attackby?

	if (!(W.object_flags & NO_ARM_ATTACH) && (user.zone_sel && (user.zone_sel.selecting in list("l_arm","r_arm"))) && surgeryCheck(src,user) )
		var/mob/living/carbon/human/H = src

		if (!H.limbs.vars[user.zone_sel.selecting])
			W.attach(src,user)
			return

	user.lastattacked = src

	if (user.mob_flags & AT_GUNPOINT)
		for(var/obj/item/grab/gunpoint/G in user.grabbed_by)
			G.shoot()

	var/obj/item/grab/block/block = user.check_block()
	if (block)
		block.attack(src,user)
		return

	var/shielded = 0
	if (src.spellshield)
		shielded = 1
		boutput(user, "<span class='alert'><b>[src]'s Spell Shield prevents your attack!</b></span>")
	else
		if (!src.spellshield)
			for(var/obj/item/device/shield/S in src)
				if (S.active)
					shielded = 1

	if (!meatshield && locate(/obj/item/grab, src))
		var/mob/safe = null
		var/obj/item/grab/G = null
		if (istype(src.l_hand, /obj/item/grab))
			G = src.l_hand
			if (G.state >= 2 && G.affecting != user) //(get_dir(src, user) == src.dir) removed to match projectiles
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/grab))
			G = src.r_hand
			if (G.state >= 2 && G.affecting != user)
				safe = G.affecting
		if (safe)
			safe.attackby(W, user, params, is_special, src)

			//after attackby so the attack message itself displays first
			if(prob(20))
				safe.visible_message("<span class='combat bold'>[safe] is knocked out of [src]'s grip by the force of the blow!</span>")
				qdel(G)

			return
	if ((!( shielded ) || !( W.flags ) & NOSHIELD))
		SPAWN_DBG( 0 )
		// drsingh Cannot read null.force
#ifdef DATALOGGER
			if (!isnull(W) && W.force)
				game_stats.Increment("violence")
#endif
			if (!isnull(W))
				W.attack(src, user, (user.zone_sel && user.zone_sel.selecting ? user.zone_sel.selecting : null), is_special) // def_zone var was apparently useless because the only thing that ever passed def_zone anything was shitty bill when he attacked people
				if (W && user != src) //ZeWaka: Fix for cannot read null.hide_attack
					if (!W.hide_attack)
						attack_particle(user,src)
						attack_twitch(user)
					else if (W.hide_attack == 2)
						attack_twitch(user)


				if (W?.force) //Wire: Fix for Cannot read null.force
					message_admin_on_attack(user, "uses \a [W.name] on")
			return
	return


/mob/proc/message_admin_on_attack(var/mob/attacker, var/attack_type = "attacks")
	//Due to how attacking is set up we will need
	if(!attacker.attack_alert || !src.key || attacker == src || isdead(src)) return //Only send the alert if we're hitting an actual, living person who isn't ourselves
	if(master_mode != "battle_royale")
		message_attack("[key_name(attacker)] [attack_type] [key_name(src)] shortly after spawning!")


/mob/proc/temporary_attack_alert(var/time = 600)
	//Only start the clock if there's time and we're not already alerting about attacks
	if(attack_alert || !time) return

	attack_alert = 1
	SPAWN_DBG(time) attack_alert = 0

/mob/proc/temporary_suicide_alert(var/time = 600)
	//Only start the clock if there's time and we're not already alerting about suicides
	if(suicide_alert || !time) return

	suicide_alert = 1
	SPAWN_DBG(time) suicide_alert = 0
