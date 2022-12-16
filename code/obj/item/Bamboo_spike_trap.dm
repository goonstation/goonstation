/obj/item/bamboo_spike_trap
	name = "spike trap"
	desc = "Curious is the trapmaker's art; his efficacy unwitnessed by his own eyes. Can be laced with chemicals."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "Bamboo_Spike_Trap-Packet"
	item_state = "table_parts"
	flags = TABLEPASS | FPRINT | NOSPLASH
	w_class = W_CLASS_NORMAL
	force = 3
	throwforce = 5
	var/armed = FALSE ///This determinates if the trap is armed or not
	var/armed_force = 9 ///how much damage the trap does when stepped upon
	var/armed_weakened = 2 SECONDS ///how long you are weakened after stepping into the trap
	var/crashed_force = 20 ///how much damage the trap does when crashed into
	var/crashed_weakened = 3 SECONDS ///how long you are stunned if you crash into the trap
	var/reagent_storage = 15 ///How much the max amount of chems is the trap should be able to hold
	var/transfer_multiplier = 0.5 ///Multiplier to damage to calculate the amount of chems tranferred
	var/target_zone = "chest" ///which zone the trap tries to target and calculate the damage resist from
	var/disarming_time = 2 SECONDS ///how long disarming with a wrench should take
	var/arming_time = 2 SECONDS ///how long arming should take
	var/break_down_time = 1 SECONDS ///how long an unarmed trap should take to disassemble with a wrench
	var/break_down_amount = 3 ///how much bamboo is created when this gets broken down, should be less or equal to the amount needed to create it
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5

	New()
		..()
		src.create_reagents(src.reagent_storage)

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's armed.</span>"


	attackby(obj/item/W, mob/user)
		if(issnippingtool(W))
			if (src.armed)
				if (ON_COOLDOWN(user, "disarming_spike_trap", user.combat_click_delay))
					return
				playsound(src.loc, 'sound/items/Scissor.ogg', 60)
				user.visible_message("[user] starts disarming [src]...")
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
					user,
					src,
					src.disarming_time,
					/obj/item/bamboo_spike_trap/proc/disarm,\list(user),
					W.icon,
					W.icon_state,
					"[user] finishes disarming [src]")
				actions.start(action_bar, user)
				return
			else
				if (ON_COOLDOWN(user, "dismantling_spike_trap", user.combat_click_delay))
					return
				playsound(src.loc, 'sound/items/Scissor.ogg', 60)
				user.visible_message("[user] starts breaking down [src]...")
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
					user,
					src,
					src.break_down_time,
					/obj/item/bamboo_spike_trap/proc/break_down,
					\list(user),
					W.icon,
					W.icon_state,
					"[user] finishes breaking down [src]")
				actions.start(action_bar, user)
				return
		if(istype(W, /obj/item/reagent_containers/glass/))
			if(!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to lace [src] with!</span>")
				return
			else
				var/transferable_amount = min(W:amount_per_transfer_from_this, W.reagents.total_volume, src.reagents.maximum_volume - src.reagents.total_volume)
				if (transferable_amount <= 0)
					boutput(user, "<span class='alert'>[src] cannot hold any more chemicals!</span>")
					return
				user.visible_message("<span class='notice'>[user] laces [src] with [transferable_amount] units of [W]'s contents.</span>")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				W.reagents.trans_to(src, transferable_amount)
				return
		..()

	ex_act(severity)
		//no reuseable explosive chem traps, sorry
		qdel(src)

	proc/arm(mob/user)
		if (!src)
			return
		for(var/obj/item/B in get_turf(src))
			if (istype(B, /obj/item/bamboo_spike_trap))
				var/obj/item/bamboo_spike_trap/BM = B
				if (BM.armed)
					boutput(user, "<span class='alert'>A trap is already placed here!</span>")
					return
		if (!src.armed)
			logTheThing(LOG_COMBAT, user, "armed a spike trap at [src.loc]")
			set_icon_state("Bamboo_Spike_Trap-Assembled")
			user?.drop_item(src)
			src.armed = TRUE
			src.anchored = TRUE

	proc/disarm(mob/user)
		if (!src)
			return
		if (src.armed)
			set_icon_state("Bamboo_Spike_Trap-Packet")
			logTheThing(LOG_COMBAT, user, "disarmed a spike trap at [src.loc]")
			src.armed = FALSE
			src.anchored = FALSE

	proc/break_down(mob/user)
		//breaks down into multiple bamboo parts
		if (!src)
			return
		var/obj/item/material_piece/organic/bamboo/A = new /obj/item/material_piece/organic/bamboo(get_turf(src))
		if (src.break_down_amount > 1)
			A.change_stack_amount(src.break_down_amount - 1)
		A.add_fingerprint(user)
		qdel(src)



	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (src.armed && ishuman(AM) && AM.throwing)
			var/mob/living/carbon/human/victim = AM
			//crashes into the trap when being thrown/slipped at it
			victim.visible_message("<span class='alert'><B>[victim] crashes into the spike trap!</B></span>",\
			"<span class='alert'><B>You crash into the spike trap!</B></span>")
			crash_into(victim)
			qdel(src) //if crashed into, destroys the trap

	attack_self(mob/user as mob)
		if (!src.armed)
			for(var/obj/item/B in get_turf(src))
				if (istype(B, /obj/item/bamboo_spike_trap))
					var/obj/item/bamboo_spike_trap/BM = B
					if (BM.armed)
						boutput(user, "<span class='alert'>A trap is already placed here!</span>")
						return
			user.show_text("You start to arm the trap...", "blue")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
				user,
				src,
				src.arming_time,
				/obj/item/bamboo_spike_trap/proc/arm,
				\list(user),
				src.icon,
				src.icon_state,
				"[user] finishes arming [src]")
			actions.start(action_bar, user)
			return
		..()


	Crossed(atom/movable/AM as mob|obj)
		..()
		if (src.armed && ishuman(AM))
			var/mob/living/carbon/human/victim = AM
			//crawling or just walking between the sticks is a viable counter
			//getting thrown at the trap has a different effect we want to check seperately
			if(victim.lying || victim.throwing || !victim.running_check(walking_matters = 1, ignore_actual_delay = 1))
				return
			//If any checks failed, well, you step into the trap
			victim.visible_message("<span class='alert'><B>[victim] steps into the spike trap!</B></span>",\
			"<span class='alert'><B>You step into the spike trap!</B></span>")
			step_on(victim)

	proc/crash_into(mob/living/carbon/human/victim as mob)
		if (!src || !victim || !src.armed)
			return
		logTheThing(LOG_COMBAT, victim, "crashed into [src] at [log_loc(src)].")
		victim.changeStatus("weakened", src.crashed_weakened)
		victim.force_laydown_standup()
		src.trap_damage(victim, src.crashed_force)
		playsound(victim.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 80, 1)
		victim.UpdateDamageIcon()


	proc/step_on(mob/living/carbon/human/victim as mob)
		if (!src || !victim || !src.armed)
			return
		logTheThing(LOG_COMBAT, victim, "stepped into [src] at [log_loc(src)].")
		victim.changeStatus("weakened", src.armed_weakened)
		victim.force_laydown_standup()
		src.trap_damage(victim, src.armed_force)
		playsound(victim.loc, 'sound/impact_sounds/Flesh_stab_1.ogg', 80, 1)
		victim.UpdateDamageIcon()

	proc/trap_damage(mob/living/carbon/human/victim as mob, damage)
		if (!src || !victim)
			return
		var/target = "All"
		if (victim.organHolder[src.target_zone])
			target = src.target_zone
		// we need this to calculate how much chems get transfered
		// This means damage against the zone, reduced by melee protection, multiplied by transfer multiplier and then rounded
		var/injected_amount = max(0, round((damage - victim.get_melee_protection(target, DAMAGE_STAB))*src.transfer_multiplier))
		victim.TakeDamageAccountArmor(target, damage, 0, 0, DAMAGE_STAB)
		// If injected_amount is greater than 0 and there are reagents in the trap, inject the victim
		if (src.reagents && src.reagents.total_volume && injected_amount > 0)
			logTheThing(LOG_COMBAT, src, "injected [victim] at [log_loc(src)] with [min(injected_amount, src.reagents.total_volume)]u of reagents.")
			src.reagents.trans_to(victim, injected_amount)
