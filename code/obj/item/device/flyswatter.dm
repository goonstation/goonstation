TYPEINFO(/obj/item/device/flyswatter)
	mats = 15

/obj/item/device/flyswatter
	name = "fly swatter"
	desc = "It's one of those fancy electric types, so you can hear that satisfying zap, zap, <i>zap</i>!"
	icon_state = "flyswatter"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10
	hit_type = DAMAGE_BURN
	w_class = W_CLASS_BULKY
	throwforce = 12
	throw_range = 10
	throw_speed = 2
	m_amt = 100

	New()
		..()
		src.setItemSpecial(/datum/item_special/elecflash)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ismobcritter(target))
			var/mob/living/critter/MC = target
			if (istype(MC, /mob/living/critter/small_animal/fly) || istype(MC, /mob/living/critter/small_animal/butterfly) || istype(MC, /mob/living/critter/small_animal/cockroach) || istype(MC, /mob/living/critter/small_animal/wasp))
				SEND_SIGNAL(target, COMSIG_MOB_ATTACKED_PRE, user, src)
				if (SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_PRE, target, user) & ATTACK_PRE_DONT_ATTACK)
					return
				smack_bug(target, user)
				logTheThing(LOG_COMBAT, user, "kills [constructTarget(target,"combat")] with [src] ([type], object name: [initial(name)]).")
				SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_POST, target, user, 20)
				return
		return ..()

	proc/smack_bug(atom/target as obj|mob, mob/user as mob)
		user.visible_message(SPAN_NOTICE("<b>[user] smacks [target] with [src]. KO!</b>"))
		playsound(target, 'sound/effects/electric_shock_short.ogg', 50, TRUE)
		SPAWN(0.2 SECONDS)
			playsound(target, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, TRUE)
		if (ismobcritter(target))
			var/mob/living/critter/MC = target
			MC.TakeDamage("all", 20, 20)
			if (!isdead(MC))
				MC.death() // KO means KO!
		else if (iscritter(target))
			var/obj/critter/C = target
			C.CritterDeath()
