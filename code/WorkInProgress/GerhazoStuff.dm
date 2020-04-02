/mob/living/carbon/human/cyalume_knight
	var/obj/item/sword/my_sword
	New()
		..()
		SPAWN_DBG(0)
			bioHolder.mobAppearance.customization_first = "Trimmed"
			bioHolder.mobAppearance.customization_second = "Full Beard"
			bioHolder.mobAppearance.customization_third = "Eyebrows"
			bioHolder.mobAppearance.customization_first_color = "#555555"
			bioHolder.mobAppearance.customization_second_color = "#555555"
			bioHolder.mobAppearance.customization_third_color = "#555555"

			src.add_ability_holder(/datum/abilityHolder/cyalume_knight)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/recall_sword)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/push)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_heal)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_lightning)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_choke)

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()
				abilityHolder.updateButtons()

			real_name = "Cyalume Knight"
			desc = "A knight of modern times."
			gender = "male"

			src.equip_new_if_possible(/obj/item/clothing/under/misc/syndicate, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/armor/cknight_robe, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/head/helmet/cknight_hood, slot_head)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/card/id/syndicate, slot_wear_id)
			var/obj/item/clothing/mask/gas/my_mask = new /obj/item/clothing/mask/gas/swat(src)
			my_mask.vchange = new(src) // apply voice changer on the mask
			src.equip_if_possible(my_mask, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/storage/belt/security, slot_belt)

			src.equip_new_if_possible(/obj/item/tank/emergency_oxygen, slot_r_store)

			my_sword = new /obj/item/sword(src)
			my_sword.bladecolor = "P"
			src.equip_if_possible(my_sword, slot_l_store)

	bullet_act(obj/projectile/P, mob/meatshield) // deflect energy projectiles, cut bullets
		var/obj/item/sword/deflecting_sword
		if(istype(src.r_hand, /obj/item/sword))
			deflecting_sword = src.r_hand
		else if(istype(src.l_hand, /obj/item/sword))
			deflecting_sword = src.l_hand

		if(deflecting_sword)
			if(deflecting_sword.active == 0)  // turn the sword on if it's off
				deflecting_sword.attack_self(src)
				src.visible_message("<span style=\"color:red\">[src] instinctively switches his [deflecting_sword] on in response to the incoming [P.name]!</span>")
			var/datum/abilityHolder/cyalume_knight/my_ability_holder = src.get_ability_holder(/datum/abilityHolder/cyalume_knight)
			var/force_drain_multiplier = 0.3  // projectile's damage(power) is multiplied by this and then subtracted from ability holder's points
			var/drained_force = 5 + (P.power * force_drain_multiplier)
			my_ability_holder.points -= drained_force
			if(my_ability_holder.points > 0) // we didn't run out of ability holder points, deflect successful
				if(P.proj_data.damage_type == D_ENERGY || P.proj_data.damage_type == D_BURNING || P.proj_data.damage_type == D_TOXIC || P.proj_data.damage_type == D_RADIOACTIVE) // energy-related damage types
					src.visible_message("<span style=\"color:red\">[src] deflects the [P.name] with his [deflecting_sword]!</span>")
					shoot_reflected(P, src)
					P.die()
					playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 60, 0.1, 0, 2.6)
					return
				else
					src.visible_message("<span style=\"color:red\">[src] vaporizes the [P.name] in its trajectory with [deflecting_sword]!</span>")
					P.die()
					playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 90, 0.1, 0, 2.6)
					return
			else
				my_ability_holder.points = 0
		..()  // failed to deflect, taking the hit

/obj/item/clothing/suit/armor/cknight_robe
	name = "Cyalume Knight Robe"
	desc = "An ominous armored article of clothing."
	icon_state = "cknight_robe"

	setupProperties()
		..()
		setProperty("coldprot", 90)
		setProperty("heatprot", 30)

/obj/item/clothing/head/helmet/cknight_hood
	name = "Cyalume Knight Helmet"
	desc = "An ominous armored article of clothing."
	icon_state = "cknight_hood"
	see_face = 0

/obj/screen/ability/topBar/cyalume_knight
	clicked(params)
		var/datum/targetable/cyalume_knight/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if(!istype(spell))
			return
		if(!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.updateIcon()
				boutput(usr, "<span style=\"color:blue\">Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span style=\"color:red\">You can't use this spell here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()
		return

////////////////////////////////////////////////// Ability holder /////////////////////////////////////////////

/datum/abilityHolder/cyalume_knight
	usesPoints = 1
	regenRate = 3
	tabName = "Cyalume Knight"
	// notEnoughPointsMessage = "<span style=\"color:red\">You need more blood to use this ability.</span>"
	points = 100
	pointName = "force"
	//var/obj/screen/kudzu/meter/nutrients_meter = null
	var/const/MAX_POINTS = 100

	onLife(var/mult = 1)
		if(..()) return
		generatePoints(mult)
		if (points > MAX_POINTS)
			points = MAX_POINTS

/datum/targetable/cyalume_knight
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "cknight_base"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/cyalume_knight

	New()
		var/obj/screen/ability/topBar/cyalume_knight/B = new /obj/screen/ability/topBar/cyalume_knight(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/cyalume_knight/recall_sword
	name = "Recall Sword"
	desc = "Guide your sword towards yourself."
	icon_state = "cknight_return_sword"
	targeted = 0
	cooldown = 6 SECONDS
	pointCost = 0

	cast(atom/target)
		if (..())
			return 1


		if(!istype(holder.owner, /mob/living/carbon/human/cyalume_knight))
			boutput(holder.owner, "<span style=\"color:red\">You aren't a true cyalume knight to be able to recall your sword!</span>")
			return 1

		var/mob/living/carbon/human/cyalume_knight/my_mob = holder.owner

		if(!my_mob.my_sword)
			boutput(holder.owner, "<span style=\"color:red\">Your sword appears to have been banished from the physical realm!</span>")
			return 1
		var/obj/item/sword = my_mob.my_sword

		my_mob.visible_message("<span style=\"color:red\"><b>[holder.owner] raises his hand into the air wide open!</b></span>")
		playsound(get_turf(sword), 'sound/effects/gust.ogg', 70, 1)

		if (ismob(sword.loc))
			if(sword.loc == my_mob)
				boutput(holder.owner, "<span style=\"color:red\">You're already holding your [sword]!</span>")
				return 1
			else
				var/mob/HH = sword.loc
				HH.visible_message("<span style=\"color:red\">[sword] somehow escapes [HH]'s grasp!</span>", "<span style=\"color:red\">The [sword] somehow escapes your grasp!</span>")
				HH.u_equip(sword)
				sword.set_loc(get_turf(HH))
		if (istype(sword.loc, /obj/item/storage))
			var/obj/item/storage/S_temp = sword.loc
			var/datum/hud/storage/H_temp = S_temp.hud
			H_temp.remove_object(sword)
			sword.set_loc(get_turf(sword))
			sword.visible_message("<span style=\"color:red\">[sword] somehow escapes the [S_temp] that it was inside of!</span>")

		// assuming no super weird things happened, the sword should be on the ground at this point
		for(var/i=0, i<100, i++)
			step_to(sword, my_mob)
			if (get_dist(sword,my_mob) <= 1)
				playsound(get_turf(my_mob), 'sound/effects/throw.ogg', 50, 1)
				sword.set_loc(get_turf(my_mob))
				if (my_mob.put_in_hand(sword))
					my_mob.visible_message("<span style=\"color:red\"><b>[my_mob] catches the [sword]!</b></span>")
				else
					my_mob.visible_message("<span style=\"color:red\"><b>[sword] lands at [my_mob]'s feet!</b></span>")
				i=100
			sleep(1)

/datum/projectile/force_wave
	name = "force wave"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "crescent_white"
	shot_sound = null
	power = 0
	dissipation_delay = 8
	dissipation_rate = 5
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	icon_turf_hit = "bhole"
	implanted = null
	casing = null

	on_hit(atom/hit, dirflag)
		if (ishuman(hit))
			var/mob/living/carbon/human/M = hit
			var/turf/target = get_edge_target_turf(M, dirflag)
			SPAWN_DBG(0)
				//if(!M.stat) M.emote("scream")
				M.do_disorient(15, weakened = 10)
				M.throw_at(target, 6, 3, throw_type = THROW_GUNIMPACT)
				M.update_canmove()

/datum/targetable/cyalume_knight/push
	name = "Push"
	desc = "Knock back and unbalance your foes."
	icon_state = "cknight_push"
	targeted = 1
	target_anything = 1
	cooldown = 10 SECONDS
	pointCost = 20
	var/start_angle = -50
	var/end_angle = 50
	var/num_projectiles = 12
	var/datum/projectile/fired_projectile

	New()
		..()
		fired_projectile = new /datum/projectile/force_wave()

	cast(atom/target)
		if (..())
			return 1

		var/turf/S = get_turf(holder.owner)
		if (get_turf(target) == S)
			boutput(holder.owner, "<span style=\"color:red\">You have to aim in a direction!</span>")
			return 1

		var/mob/owner_mob = holder.owner
		owner_mob.visible_message("<span style=\"color:red\"><b>[holder.owner] thrusts the palm of his hand forward, releasing an overwhelming gust of wind!</b></span>")
		playsound(get_turf(holder.owner), 'sound/effects/gust.ogg', 50, 1)
		var/increment_value = (end_angle - start_angle) / (num_projectiles - 1)
		var/current_angle = start_angle
		var/i
		for(i = 0; i < num_projectiles; i++)
			var/obj/projectile/P = initialize_projectile_ST(holder.owner, fired_projectile, target)
			if (P)
				P.mob_shooter = holder.owner
				P.rotateDirection(current_angle)
				P.launch()
				current_angle += increment_value
		return

/datum/targetable/cyalume_knight/force_lightning
	name = "Lightning"
	desc = "Unleash a storm of lightning bolts on a nearby targeted area."
	icon_state = "cknight_lightning"
	targeted = 1
	target_anything = 1
	max_range = 6
	cooldown = 15 SECONDS
	pointCost = 25
	var/radius = 2

	cast(atom/target)
		if (..())
			return 1

		var/turf/S = get_turf(holder.owner)
		var/turf/target_turf = get_turf(target)
		if (target_turf == S)
			boutput(holder.owner, "<span style=\"color:red\">You have to aim in a direction!</span>")
			return 1

		var/mob/living/M = holder.owner

		if (get_dist(holder.owner,target_turf) < radius + 1)
			var/distance = get_dist(M,target_turf)
			var/difference = (radius + 1) - distance
			var/i
			for(i = 0; i < difference; i++)
				target_turf = get_step_away(target_turf, M)

			if(get_dist(holder.owner, target_turf) < (radius + 1)) // we could have hit the edge of the map or otherwise couldn't maneuver into a proper distance
				boutput(M, "<span style=\"color:red\">That's too close, you could end up frying yourself.</span>")
				return 1

		var/list/lightning_targets = list()
		for (var/turf/T in range(radius, target_turf))
			lightning_targets += T

		M.visible_message("<span style=\"color:red\"><b>[M] starts to release a storm of lightning from his hands!</b></span>")

		actions.start(new/datum/action/bar/icon/force_lightning_action(M,holder,target_turf,src,lightning_targets), M)

/datum/action/bar/icon/force_lightning_action // UNLIMITED POWER
	duration = 5
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cyalumeknight_lightning"
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "cknight_lightning_action"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/cyalume_knight/H
	var/turf/HH
	var/datum/targetable/cyalume_knight/force_lightning/lightningability
	var/list/lightning_targets


	New(user,knightabilityholder,targetturf,lightningabil,potentiallightningtargets)
		M = user
		H = knightabilityholder
		HH = targetturf
		lightningability = lightningabil
		lightning_targets = potentiallightningtargets
		..()


	onUpdate()
		..()
		if(M == null || lightningability == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(M == null || lightningability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		/*
		if (!H.can_bite(HH, is_pointblank = 1))
			interrupt(INTERRUPT_ALWAYS)
			return
		*/

	onEnd()
		..()
		if(M == null || lightningability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/targetcounter = rand(4,7)
		var/i
		for(i = 0; i < targetcounter; i++)
			var/shock_target = pick(lightning_targets)
			if(prob(30)) // likely to focus on mobs
				for(var/mob/nearbyMob in range(1, shock_target))
					if(nearbyMob && nearbyMob != M)
						shock_target = get_turf(nearbyMob)
						break
			if(shock_target)
				arcFlashTurf(M, shock_target, 20000)
		H.points -= targetcounter
		if(H.points <= 0)
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.interrupt_flags &= ~INTERRUPT_ACTION
		actions.start(new/datum/action/bar/icon/force_lightning_action(M,H,HH,lightningability,lightning_targets), M)

	onInterrupt()
		..()
		if (H.points == 0)
			boutput(M, "<span style=\"color:red\">You don't have enough energy to continue casting the lightning.</span>")
		else
			boutput(M, "<span style=\"color:red\">Your lightning ability was interrupted.</span>")

/datum/targetable/cyalume_knight/force_choke
	name = "Telekinetic Grip"
	desc = "Paralyse and choke out your target through telekinesis."
	icon_state = "cknight_grip"
	targeted = 1
	target_anything = 0
	max_range = 8
	cooldown = 20 SECONDS
	pointCost = 25
	var/radius = 2

	cast(atom/target)
		if (..())
			return 1

		if (target == holder.owner)
			boutput(holder.owner, "<span style=\"color:red\">No choking yourself!</span>")
			return 1

		var/mob/living/M = holder.owner

		var/mob/living/mob_target = target

		var/original_pixel_y = mob_target.pixel_y

		M.visible_message("<span style=\"color:red\"><b>[M] extends his open hand forward in a grasping motion, freezing [mob_target] in place!</b></span>")
		mob_target.changeStatus("stunned", 150)
		mob_target.force_laydown_standup()

		sleep(15)
		M.visible_message("<span style=\"color:red\"><b>[M] begins lifting his hand, with [mob_target] following!</b></span>")
		var/i
		for(i = 0; i < 12; i++)
			mob_target.pixel_y += 2
			sleep(1)
		sleep(5)
		M.visible_message("<span style=\"color:red\"><b>[M] closes his grip!</b></span>")
		mob_target.losebreath += 10

		actions.start(new/datum/action/bar/icon/force_choke_action(M,holder,mob_target,src,original_pixel_y), M)


/datum/action/bar/icon/force_choke_action
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cyalumeknight_choke"
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "cknight_grip_action"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/cyalume_knight/H
	var/mob/living/HH
	var/datum/targetable/cyalume_knight/force_choke/chokeability
	var/original_pixel_y


	New(user,knightabilityholder,targetmob,chokeabil,potentiallightningtargets,origpixely)
		M = user
		H = knightabilityholder
		HH = targetmob
		chokeability = chokeabil
		original_pixel_y = origpixely
		..()


	onUpdate()
		..()
		if(M == null || chokeability == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(M == null || chokeability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(M == null || chokeability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(HH.losebreath < 8)
			HH.losebreath += 5
			HH.visible_message("<span style=\"color:red\"><b>[HH] is grasping their neck desperately trying to breathe in!</b></span>", "<span style=\"color:red\"><b>Something is constricting your throat, you cannot breathe!</b></span>")
		HH.changeStatus("stunned", 10 SECONDS)

		H.points -= 5

		if(H.points <= 0)
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.interrupt_flags &= ~INTERRUPT_ACTION // this action is already finished, this prevents it from getting interrupted by starting a new one
		actions.start(new/datum/action/bar/icon/force_choke_action(M,H,HH,chokeability,original_pixel_y), M)

	onInterrupt()
		..()
		HH.pixel_y = original_pixel_y
		if (H.points == 0)
			boutput(M, "<span style=\"color:red\">You don't have enough energy to continue gripping the target.</span>")
		else
			boutput(M, "<span style=\"color:red\">Your grip ability was interrupted.</span>")

/datum/targetable/cyalume_knight/force_heal
	name = "Heal"
	desc = "Meditate and slowly heal your wounds."
	icon_state = "cknight_heal"
	targeted = 0
	cooldown = 20 SECONDS
	pointCost = 20

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/M = holder.owner

		M.visible_message("<span style=\"color:red\"><b>[M] stands still, focused in meditation!</b></span>", "<span style=\"color:red\"><b>You begin meditation.</b></span>")

		actions.start(new/datum/action/bar/icon/force_heal_action(M,holder,src), M)

/datum/action/bar/icon/force_heal_action
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cyalumeknight_heal"
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "cknight_heal_action"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/cyalume_knight/H
	var/datum/targetable/cyalume_knight/force_choke/healability

	New(user,knightabilityholder,healabil)
		M = user
		H = knightabilityholder
		healability = healabil
		..()


	onUpdate()
		..()
		if(M == null || healability == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(M == null || healability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(M == null || healability == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (M.get_burn_damage() > 0 || M.get_toxin_damage() > 0 || M.get_brute_damage() > 0 || M.get_oxygen_deprivation() > 0 || M.losebreath > 0)
			M.HealDamage("All", 15, 15)
			M.take_toxin_damage(-15)
			M.take_oxygen_deprivation(-15)
			M.losebreath = max(0, M.losebreath - 10)
			M.updatehealth()
			M.visible_message("<span style=\"color:red\">Some of [M]'s wounds slowly fade away!</span>", "<span style=\"color:red\">Your wounds begin to fade away.</span>")
			playsound(get_turf(M), 'sound/items/mender.ogg', 50, 1)
		else
			boutput(M, "<span style=\"color:red\">You don't have any lingering wounds to heal.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		H.points -= 15

		if(H.points <= 0)
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.interrupt_flags &= ~INTERRUPT_ACTION // this action is already finished, this prevents it from getting interrupted by starting a new one
		actions.start(new/datum/action/bar/icon/force_heal_action(M,H,healability), M)

	onInterrupt()
		..()
		if (H.points == 0)
			boutput(M, "<span style=\"color:red\">You don't have enough energy to continue healing.</span>")
		else
			boutput(M, "<span style=\"color:red\">Your healing meditation was interrupted.</span>")
