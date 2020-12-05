/obj/item/device/flyswatter
	name = "fly swatter"
	desc = "It's one of those fancy electric types, so you can hear that satisfying zap, zap, <i>zap</i>!"
	icon_state = "flyswatter"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	hit_type = DAMAGE_BURN
	w_class = 4.0
	throwforce = 12
	throw_range = 10
	throw_speed = 2
	m_amt = 100
	mats = 15
	module_research = list("tools" = 2, "devices" = 10)

	New()
		..()
		src.setItemSpecial(/datum/item_special/elecflash)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (ismobcritter(M))
			var/mob/living/critter/MC = M
			if (istype(MC, /mob/living/critter/small_animal/fly) || istype(MC, /mob/living/critter/small_animal/butterfly) || istype(MC, /mob/living/critter/small_animal/cockroach) || istype(MC, /mob/living/critter/small_animal/wasp))
				SEND_SIGNAL(M, COMSIG_MOB_ATTACKED_PRE, user, src)
				if (SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_PRE, M, user) & ATTACK_PRE_DONT_ATTACK)
					return
				smack_bug(M, user)
				logTheThing("combat", user, M, "kills [constructTarget(M,"combat")] with [src] ([type], object name: [initial(name)]).")
				SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_POST, M, user, 20)
				return
		return ..()

	proc/smack_bug(atom/target as obj|mob, mob/user as mob)
		user.visible_message("<span class='notice'><b>[user] smacks [target] with [src]. KO!</b></span>")
		playsound(get_turf(target), "sound/effects/electric_shock_short.ogg", 50, 1)
		SPAWN_DBG(0.2 SECONDS)
			playsound(get_turf(target), "sound/impact_sounds/Flesh_Crush_1.ogg", 50, 1)
		if (ismobcritter(target))
			var/mob/living/critter/MC = target
			MC.TakeDamage("all", 20, 20)
			if (!isdead(MC))
				MC.death() // KO means KO!
		else if (iscritter(target))
			var/obj/critter/C = target
			C.CritterDeath()
