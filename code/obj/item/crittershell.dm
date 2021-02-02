/obj/item/critter_shell
	name = "some kind of thing that holds a critter"
	desc = "oh"
	icon = 'icons/obj/foodNdrink/food_yuck.dmi'
	icon_state = "fried"
	var/atom/movable/held_critter = null
	var/obj/critter/held_objcritter = null
	var/mob/living/critter/held_mobcritter = null
	w_class = 1

	disposing()
		. = ..()
		if(src.held_critter)
			UnregisterSignal(src.held_critter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_OBJ_CRITTER_DEATH, COMSIG_MOB_DEATH))
			src.held_critter.set_loc(get_turf(src))
			src.held_critter = null
			src.held_objcritter?.metaholder = null
			src.held_mobcritter = null
			src.held_mobcritter?.metaholder = null
			src.held_mobcritter = null

	attackby(obj/item/W, mob/user, params)
		if(istype(src.held_critter))
			src.held_critter.attackby(W, user)

	attack_ai(user)
		if(istype(src.held_critter))
			src.held_critter.attack_ai(user)

	attack_hand(mob/user)
		if(!user.is_in_hands(src)) // Not in your hand? Might be in your backpack
			. = ..() // Go get it then
			return
		if(!user.a_intent == INTENT_GRAB && istype(src.held_critter)) //
			src.held_critter.attack_hand(user)

	/// eat it, pet it, strangle it, intent based?
	attack_self(mob/user)
		if(istype(src.held_critter))
			if(user.a_intent == INTENT_HARM)
				src.Eat(user, user)
				return
			src.held_critter.attack_hand(user)
		. = ..()

	/// Attack somebody with this critter
	attack(mob/M, mob/user, def_zone, is_special)
		. = ..()

	dropped(mob/user)
		if(!istype(src.loc, /mob) && !istype(src.loc, /obj/item/storage)) // Only unshell it if it stops being in a mob or a container
			src.unshellify_critter()
		. = ..()


	/// Puts a critter-thing inside this thing and sets up the listeners or something
	proc/shellify_critter(atom/movable/AM, mob/living/L)
		if(!AM || !L)
			qdel(src)
			return FALSE

		if(!L.put_in_hand(src))
			L.u_equip(src)
			boutput(world, "[AM] cantnt be shelled")
			return src.unshellify_critter()
		else
			boutput(world, "[AM] shelled inside [src]!!!")

		AM.set_loc(src)
		src.icon = AM.icon
		src.icon_state = AM.icon_state
		src.name = AM.name
		src.held_critter = AM
		if(istype(AM, /obj/critter))
			src.held_objcritter = AM
			var/obj/critter/o_critter = AM
			o_critter.grabber = L
		else if(istype(AM, /mob/living/critter))
			src.held_mobcritter = AM
		RegisterSignal(src.held_critter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_OBJ_CRITTER_DEATH, COMSIG_MOB_DEATH), .proc/update_icon)
		return TRUE // it worked!

	/// Makes the object look more like the critter when it move
	proc/update_icon()
		src.set_dir(src.held_critter.dir)
		if(length(src.held_critter.overlays) || length(src.held_critter.underlays))
			var/image/critter_overlays = new(src.held_critter.icon, src.held_critter.icon_state)
			for(var/O in src.held_critter.underlays + src.held_critter.overlays)
				var/image/I = O
				critter_overlays += image(I.icon, I.icon_state)
			src.UpdateOverlays(critter_overlays, "critter_overlays")
		else
			src.UpdateOverlays(null, "critter_overlays")

	/// dumps the critter out and self destructs. Also returns the atom inside
	proc/unshellify_critter()
		if(src.held_critter)
			UnregisterSignal(src.held_critter, list(COMSIG_ATOM_DIR_CHANGED, COMSIG_OBJ_CRITTER_DEATH, COMSIG_MOB_DEATH))
			src.held_critter.set_loc(get_turf(src))
			src.held_critter = null
			src.held_objcritter?.metaholder = null
			src.held_mobcritter = null
			src.held_mobcritter?.metaholder = null
			src.held_mobcritter = null
		qdel(src)

	/// Well, more like eating the thing inside
	Eat(mob/M, mob/user)
		if(!src.held_critter)
			return FALSE
		if(M != user)
			return FALSE // No forcefeeding rats to people
		if (!istype(src.held_critter))
			return FALSE
		if (M?.bioHolder && !M.bioHolder.HasEffect("mattereater"))
			if(ON_COOLDOWN(M, "eat", EAT_COOLDOWN))
				return FALSE
		// var/edibility_override = SEND_SIGNAL(M, COMSIG_ITEM_CONSUMED_PRE, user, src.held_mobcritter)
		// edibility_override |= SEND_SIGNAL(M, COMSIG_ITEM_CONSUMED_PRE, user, src.held_objcritter)
		// if (!(edibility_override & FORCE_EDIBILITY))
		// 	return FALSE

		var/critter_health_max
		var/critter_health

		if(istype(src.held_mobcritter))
			critter_health_max = src.held_mobcritter.max_health
			critter_health = src.held_mobcritter.health
		else if (istype(src.held_objcritter))
			critter_health_max = initial(src.held_objcritter.health)
			critter_health = src.held_objcritter.health
		else
			return FALSE // gotta be something!

		if(critter_health <= 0)
			boutput(user, "There's nothing there to eat!")
			return FALSE

		M.visible_message("<span class='notice'>[M] takes a bite out of [src.held_critter]!</span>",\
		"<span class='notice'>You take a bite out of [src.held_critter]!</span>")

		// if (src.material && src.material.edible)
		// 	src.material.triggerEat(M, src)

		if (src.held_critter?.reagents?.total_volume)
			src.held_critter.reagents.reaction(M, INGEST)
			SPAWN_DBG(0.5 SECONDS) // Necessary.
				if(src?.held_critter)
					src.held_critter.reagents.trans_to(M, src.held_critter.reagents.total_volume / max(critter_health / max(critter_health_max, 1), 1))

		playsound(M.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
		eat_twitch(M)
		SPAWN_DBG(1 SECOND)
			if (!src || !M || !user)
				return

			var/bite_damage = min(15, critter_health_max * 0.4)
			hit_twitch(src)
			// var/critter_died = 0
			if(istype(src.held_mobcritter))
				src.held_mobcritter.TakeDamage("All", bite_damage, damage_type = DAMAGE_CRUSH)
				src.held_mobcritter.was_harmed(M)
				// if(isdead(src.held_mobcritter))
				// 	critter_died = 1
			else if(istype(src.held_objcritter))
				src.held_objcritter.health -= bite_damage * src.held_objcritter.brutevuln
				if (src.held_objcritter.hitsound)
					playsound(get_turf(src.held_objcritter), src.held_objcritter.hitsound, 50, 1)
				if (src.held_objcritter.alive && src.held_objcritter.health <= 0)
					src.held_objcritter.CritterDeath()
					// critter_died = 1
				if (src.held_objcritter.alive)
					src.held_objcritter.on_damaged(M)
				if (src.held_objcritter.defensive)
					if (src.held_objcritter.target == M && src.held_objcritter.task == "attacking")
						if (prob(50))
							src.held_objcritter.visible_message("<span class='alert'><b>[src.held_objcritter]</b> flinches!</span>")
					src.held_objcritter.target = M
					src.held_objcritter.oldtarget_name = M.name
					src.held_objcritter.visible_message("<span class='alert'><b>[src.held_objcritter]</b> [src.held_objcritter.angertext] [M.name]!</span>")
					src.held_objcritter.task = "chasing"
					src.held_objcritter.on_grump()

			M.visible_message("<span class='alert'>[M] finishes eating [src.held_objcritter].</span>",\
			"<span class='alert'>You finish eating [src.held_objcritter].</span>")
			SEND_SIGNAL(M, COMSIG_ITEM_CONSUMED, user, src.held_objcritter)
			// if(critter_died)
			// 	user.u_equip(src)
			// 	src.unshellify_critter()
		return 1
