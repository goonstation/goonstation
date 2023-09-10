
/mob/attackby(obj/item/W, mob/user, params, is_special = 0)
	actions.interrupt(src, INTERRUPT_ATTACKED)

	// why is this not in human/attackby?

	if (!(W.object_flags & NO_ARM_ATTACH || W.cant_drop || W.two_handed) && (user.zone_sel && (user.zone_sel.selecting in list("l_arm","r_arm"))) && surgeryCheck(src,user) )
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

	if (!shielded || !(W.flags & NOSHIELD))
		SPAWN( 0 )
		// drsingh Cannot read null.force
#ifdef DATALOGGER
			if (W.force)
				game_stats.Increment("violence")
#endif
			if (!isnull(W))
				W.attack(src, user, (user.zone_sel && user.zone_sel.selecting ? user.zone_sel.selecting : null), is_special) // def_zone var was apparently useless because the only thing that ever passed def_zone anything was shitty bill when he attacked people
				if (W && user != src) //ZeWaka: Fix for cannot read null.hide_attack
					var/anim_mult = clamp(0.5, W.force / 10, 4)
					if (!W.hide_attack)
						attack_particle(user,src)
						attack_twitch(user, anim_mult, anim_mult)
					else if (W.hide_attack == ATTACK_PARTIALLY_HIDDEN)
						attack_twitch(user, anim_mult, , anim_mult)


				if (W.force)
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
	SPAWN(time) attack_alert = 0

/mob/proc/temporary_suicide_alert(var/time = 600)
	//Only start the clock if there's time and we're not already alerting about suicides
	if(suicide_alert || !time) return

	suicide_alert = 1
	SPAWN(time) suicide_alert = 0
