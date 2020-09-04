////////////////////////////////////////////////// Cyalume knight stuff /////////////////////////////////////////////

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

			src.add_ability_holder(/datum/abilityHolder/cyalume_knight)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/recall_sword)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/push)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_heal)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_lightning)
			abilityHolder.addAbility(/datum/targetable/cyalume_knight/force_choke)

			sleep(1 SECOND)

			bioHolder.mobAppearance.UpdateMob()
			abilityHolder.updateButtons()

	bullet_act(obj/projectile/P, mob/meatshield) // deflect energy projectiles, cut bullets
		var/obj/item/sword/deflecting_sword
		if(istype(src.r_hand, /obj/item/sword))
			deflecting_sword = src.r_hand
		else if(istype(src.l_hand, /obj/item/sword))
			deflecting_sword = src.l_hand

		if(deflecting_sword)
			if(deflecting_sword.active == 0)  // turn the sword on if it's off
				deflecting_sword.attack_self(src)
				src.visible_message("<span class='alert'>[src] instinctively switches his [deflecting_sword] on in response to the incoming [P.name]!</span>")
			var/datum/abilityHolder/cyalume_knight/my_ability_holder = src.get_ability_holder(/datum/abilityHolder/cyalume_knight)
			var/force_drain_multiplier = 0.3  // projectile's damage(power) is multiplied by this and then subtracted from ability holder's points
			var/drained_force = 5 + (P.power * force_drain_multiplier)
			my_ability_holder.points -= drained_force
			if(my_ability_holder.points > 0) // we didn't run out of ability holder points, deflect successful
				if(P.proj_data.damage_type == D_ENERGY || P.proj_data.damage_type == D_BURNING || P.proj_data.damage_type == D_TOXIC || P.proj_data.damage_type == D_RADIOACTIVE) // energy-related damage types
					src.visible_message("<span class='alert'>[src] deflects the [P.name] with his [deflecting_sword]!</span>")
					shoot_reflected_to_sender(P, src)
					P.die()
					playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 60, 0.1, 0, 2.6)
					return
				else
					src.visible_message("<span class='alert'>[src] vaporizes the [P.name] in its trajectory with [deflecting_sword]!</span>")
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
				boutput(usr, "<span class='hint'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this spell here.</span>")
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
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
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

	New(datum/abilityHolder/holder)
		..(holder)
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
	var/obj/item/sword/sword = null

	onAttach(datum/abilityHolder/holder)
		..(holder)

		if(istype(holder.owner, /mob/living/carbon/human/cyalume_knight))
			var/mob/living/carbon/human/cyalume_knight/my_mob = holder.owner
			src.sword = my_mob.my_sword


		if(!src.sword)
			boutput(holder.owner, "<span class='alert'>Your sword appears to have been banished from the physical realm!</span>")
			return 1

	disposing()
		sword = null
		..()

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/my_mob = holder.owner
		if(!src.sword)
			boutput(my_mob, "<span class='alert'>Your sword appears to have been banished from the physical realm!</span>")
			var/obj/item/R = my_mob.find_type_in_hand(/obj/item/sword, "right") // same with grabs
			var/obj/item/L = my_mob.find_type_in_hand(/obj/item/sword, "left") // same for the other hand
			if (R)
				src.sword = R
				if (istype(my_mob, /mob/living/carbon/human/cyalume_knight))
					var/mob/living/carbon/human/cyalume_knight/knight = my_mob
					knight.my_sword = R
			else if (L)
				src.sword = L
				if (istype(my_mob, /mob/living/carbon/human/cyalume_knight))
					var/mob/living/carbon/human/cyalume_knight/knight = my_mob
					knight.my_sword = L

			if (src.sword)
				boutput(my_mob, "<span class='notice'>You have claimed [src.sword] as your own! You'll be able to call it back to you!</span>")
			return 1

		my_mob.visible_message("<span class='alert'><b>[holder.owner] raises his hand into the air wide open!</b></span>")
		playsound(get_turf(sword), 'sound/effects/gust.ogg', 70, 1)

		if (ismob(sword.loc))
			if(sword.loc == my_mob)
				boutput(holder.owner, "<span class='alert'>You're already holding your [sword]!</span>")
				return 1
			else
				var/mob/HH = sword.loc
				HH.visible_message("<span class='alert'>[sword] somehow escapes [HH]'s grasp!</span>", "<span class='alert'>The [sword] somehow escapes your grasp!</span>")
				HH.u_equip(sword)
				sword.set_loc(get_turf(HH))
		if (istype(sword.loc, /obj/item/storage))
			var/obj/item/storage/S_temp = sword.loc
			var/datum/hud/storage/H_temp = S_temp.hud
			H_temp.remove_object(sword)
			sword.set_loc(get_turf(sword))
			sword.visible_message("<span class='alert'>[sword] somehow escapes the [S_temp] that it was inside of!</span>")

		// assuming no super weird things happened, the sword should be on the ground at this point
		for(var/i=0, i<100, i++)
			step_to(sword, my_mob)
			if (get_dist(sword,my_mob) <= 1)
				playsound(get_turf(my_mob), 'sound/effects/throw.ogg', 50, 1)
				sword.set_loc(get_turf(my_mob))
				if (my_mob.put_in_hand(sword))
					my_mob.visible_message("<span class='alert'><b>[my_mob] catches the [sword]!</b></span>")
				else
					my_mob.visible_message("<span class='alert'><b>[sword] lands at [my_mob]'s feet!</b></span>")
				i=100
			sleep(0.1 SECONDS)

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
			boutput(holder.owner, "<span class='alert'>You have to aim in a direction!</span>")
			return 1

		var/mob/owner_mob = holder.owner
		owner_mob.visible_message("<span class='alert'><b>[holder.owner] thrusts the palm of his hand forward, releasing an overwhelming gust of wind!</b></span>")
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
			boutput(holder.owner, "<span class='alert'>You have to aim in a direction!</span>")
			return 1

		var/mob/living/M = holder.owner

		if (get_dist(holder.owner,target_turf) < radius + 1)
			var/distance = get_dist(M,target_turf)
			var/difference = (radius + 1) - distance
			var/i
			for(i = 0; i < difference; i++)
				target_turf = get_step_away(target_turf, M)

			if(get_dist(holder.owner, target_turf) < (radius + 1)) // we could have hit the edge of the map or otherwise couldn't maneuver into a proper distance
				boutput(M, "<span class='alert'>That's too close, you could end up frying yourself.</span>")
				return 1

		var/list/lightning_targets = list()
		for (var/turf/T in range(radius, target_turf))
			lightning_targets += T

		M.visible_message("<span class='alert'><b>[M] starts to release a storm of lightning from his hands!</b></span>")

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

	proc/checkNulls()
		if(M == null || lightningability == null)
			interrupt(INTERRUPT_ALWAYS)
			return 0
		return 1

	onUpdate()
		..()
		checkNulls()

	onStart()
		..()
		src.loopStart()

	loopStart()
		..()
		checkNulls()

	onEnd()
		if(!checkNulls())
			..()
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
			..()
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.onRestart()

	onInterrupt()
		..()
		if (H.points == 0)
			boutput(M, "<span class='alert'>You don't have enough energy to continue casting the lightning.</span>")
		else
			boutput(M, "<span class='alert'>Your lightning ability was interrupted.</span>")

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
			boutput(holder.owner, "<span class='alert'>No choking yourself!</span>")
			return 1

		var/mob/living/M = holder.owner

		var/mob/living/mob_target = target

		var/original_pixel_y = mob_target.pixel_y

		M.visible_message("<span class='alert'><b>[M] extends his open hand forward in a grasping motion, freezing [mob_target] in place!</b></span>")
		mob_target.changeStatus("stunned", 150)
		mob_target.force_laydown_standup()

		sleep(1.5 SECONDS)
		M.visible_message("<span class='alert'><b>[M] begins lifting his hand, with [mob_target] following!</b></span>")
		var/i
		for(i = 0; i < 12; i++)
			mob_target.pixel_y += 2
			sleep(0.1 SECONDS)
		sleep(0.5 SECONDS)
		M.visible_message("<span class='alert'><b>[M] closes his grip!</b></span>")
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

	proc/checkNulls()
		if(M == null || chokeability == null)
			interrupt(INTERRUPT_ALWAYS)
			return 0
		return 1

	onUpdate()
		..()
		checkNulls()

	onStart()
		..()
		src.loopStart()

	loopStart()
		..()
		checkNulls()

	onEnd()
		if(!checkNulls())
			..()
			return

		if(HH.losebreath < 8)
			HH.losebreath += 5
			HH.visible_message("<span class='alert'><b>[HH] is grasping their neck desperately trying to breathe in!</b></span>", "<span class='alert'><b>Something is constricting your throat, you cannot breathe!</b></span>")
		HH.changeStatus("stunned", 10 SECONDS)

		H.points -= 5

		if(H.points <= 0)
			..()
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.onRestart()

	onInterrupt()
		..()
		HH.pixel_y = original_pixel_y
		if (H.points == 0)
			boutput(M, "<span class='alert'>You don't have enough energy to continue gripping the target.</span>")
		else
			boutput(M, "<span class='alert'>Your grip ability was interrupted.</span>")

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

		M.visible_message("<span class='alert'><b>[M] stands still, focused in meditation!</b></span>", "<span class='alert'><b>You begin meditation.</b></span>")

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

	proc/checkNulls()
		if(M == null || healability == null)
			interrupt(INTERRUPT_ALWAYS)
			return 0
		return 1

	onUpdate()
		..()
		checkNulls()

	onStart()
		..()
		src.loopStart()

	loopStart()
		..()
		checkNulls()

	onEnd()
		if(!checkNulls())
			..()
			return

		if (M.get_burn_damage() > 0 || M.get_toxin_damage() > 0 || M.get_brute_damage() > 0 || M.get_oxygen_deprivation() > 0 || M.losebreath > 0)
			M.HealDamage("All", 15, 15)
			M.take_toxin_damage(-15)
			M.take_oxygen_deprivation(-15)
			M.losebreath = max(0, M.losebreath - 10)
			M.visible_message("<span class='alert'>Some of [M]'s wounds slowly fade away!</span>", "<span class='alert'>Your wounds begin to fade away.</span>")
			playsound(get_turf(M), 'sound/items/mender.ogg', 50, 1)
		else
			..()
			boutput(M, "<span class='alert'>You don't have any lingering wounds to heal.</span>")
			interrupt(INTERRUPT_ALWAYS)
			return

		H.points -= 15

		if(H.points <= 0)
			..()
			H.points = 0
			interrupt(INTERRUPT_ALWAYS)
			return
		src.onRestart()

	onInterrupt()
		..()
		if (H.points == 0)
			boutput(M, "<span class='alert'>You don't have enough energy to continue healing.</span>")
		else
			boutput(M, "<span class='alert'>Your healing meditation was interrupted.</span>")

////////////////////////////////////////////////// Cyalume knight stuff /////////////////////////////////////////////

////////////////////////////////////////////////// Guardbuddy stuff /////////////////////////////////////////////

/mob/living/silicon/robot/buddy/responsive
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "robuddy-idle"

	Login()
		..()
		boutput(src, "<span class='notice'>Access special emotes through *neutral, *sad, *happy, *flip, *wave!</span>")


	emote(var/act, var/voluntary = 1)
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			act = copytext(act, 1, t1)

		switch(lowertext(act))
			if ("sad")
				src.icon_state = "robuddy-sad"

			if ("happy")
				src.icon_state = "robuddy-vibin"

			if("flip")
				flick("robuddy-speen", src)
				..(act, voluntary) // to let the regular emote also occur

			if("wave")
				flick("robuddy-wave", src)
				..(act, voluntary) // to let the regular wave(wave message, etc) also occur

			if("neutral")
				src.icon_state = "robuddy-idle"

			else
				..(act, voluntary)
////////////////////////////////////////////////// Guardbuddy stuff /////////////////////////////////////////////

////////////////////////////////////////////////// Mutation orb stuff ///////////////////////////////////////////////
/datum/mutation_orb_mutdata
	// AddEffect arguments
	var/id
	var/variant
	var/time  // how long they have the mutation, 0 means forever
	var/stabilized  // doesn't affect genetic stability
	var/magical  // can't be removed and costs no genetic stability

	// additional settings
	var/powerboosted = 0
	var/energyboosted = 0
	var/synchronized = 0
	var/reinforced = 0
	var/hardoverride = 0 // AddEffect won't add a power if the subject already has it. If this is 1, it will remove and overwrite any pre-existing mutations of the same type.

	New(id, variant = 0, time = 0, stabilized = 0, magical = 0, powerboosted = 0, energyboosted = 0, synchronized = 0, reinforced = 0, hardoverride = 0)
		. = ..()
		src.id = id
		src.variant = variant
		src.time = time
		src.stabilized = stabilized
		src.magical = magical
		src.powerboosted = powerboosted
		src.energyboosted = energyboosted
		src.synchronized = synchronized
		src.reinforced = reinforced
		src.hardoverride = hardoverride


/obj/item/mutation_orb
	name = "empty orb"
	desc = "You have a feeling you shouldn't be able to see this."
	hide_attack = 2

	var/list/datum/mutation_orb_mutdata/mutations_to_add
	var/envelop_message // envelops [user] in [envelop_message]
	var/leaving_message // before [leaving_message]!

	attack(mob/M as mob, mob/user as mob)
		return

	attack_self(mob/user as mob)
		if (!iscarbon(user))
			boutput(user, "<span class='alert'>\The [src] rejects you!</span>")
			return

		var/mutations_length = length(mutations_to_add)
		if(user.bioHolder && mutations_length)
			var/turf/T = get_turf(user)
			T.visible_message("<span class='notice'>\The [src] envelops [user] in [envelop_message] before [leaving_message]!</span>")
			playsound(T, 'sound/effects/mag_warp.ogg', 70, 1)
			for (var/i = 1 to mutations_length)
				var/datum/mutation_orb_mutdata/mut = mutations_to_add[i]

				if (mut.hardoverride) // if overwriting, remove pre-existing mutation if one exists
					user.bioHolder.RemoveEffect(mut.id)

				var/datum/bioEffect/added_effect = user.bioHolder.AddEffect(mut.id, mut.variant, mut.time, mut.stabilized, mut.magical)

				if (!mut.magical && mut.reinforced)
					added_effect.curable_by_mutadone = mut.reinforced

				if (istype(added_effect, /datum/bioEffect/power/)) // apply chromosomes if provided and the mutation is a power
					var/datum/bioEffect/power/added_power = added_effect
					added_power.power = mut.powerboosted
					added_power.safety = mut.synchronized
					if (mut.energyboosted)
						if (added_effect.cooldown != 0)
							added_effect.cooldown /= 2

			qdel(src)

	afterattack(var/atom/target, mob/user, flag)
		if (target == user)
			src.attack_self(user)
		else
			. = ..()

/obj/item/mutation_orb/fire_orb
	name = "essence of fire"
	desc = "Embers of flame, all seemingly drawn to a single spot."
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "orb_fire"

	envelop_message = "fiery embers"
	leaving_message = "dispersing"

	New()
		. = ..()
		mutations_to_add = list(new /datum/mutation_orb_mutdata(id = "fire_resist", magical = 1),
		new /datum/mutation_orb_mutdata(id = "aura_fire", magical = 1),
		new /datum/mutation_orb_mutdata(id = "fire_breath", stabilized = 1)
		//new /datum/mutation_orb_mutdata(id = "immolate", stabilized = 1, powerboosted = 1)
		)

////////////////////////////////////////////////// Mutation orb stuff ///////////////////////////////////////////////

////////////////////////////////////////////////// Generic unique items stuff ///////////////////////////////////////////////

/obj/item/rejuvenation_feather
	name = "fiery feather"
	desc = "With the surface resembling that of a flame, this doesn't look like a normal feather. Occasional embers crackle from within, as if to remind of its unexplained nature. Merely holding it soothes your hand, indicative of its regenerative properties."
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "feather_fire"
	color = "#ff8902"
	hide_attack = 2

	attack(mob/M as mob, mob/user as mob)
		return

	afterattack(var/atom/target, mob/user, flag)
		var/did_something = 0

		if (ismob(target))
			var/mob/target_mob = target
			target_mob.full_heal()
			did_something = 1

		else if (iscritter(target))
			var/obj/critter/target_critter = target
			if (!target_critter.alive)
				target_critter.revive_critter()
				did_something = 1

		if (did_something)
			var/turf/T = get_turf(target)
			T.visible_message("<span class='notice'>As [user] brings \the [src] near [target], \the [src] spontaneously bursts into flames and [target]'s wounds appear to fade away!</span>")
			var/obj/heavenly_light/lightbeam = new /obj/heavenly_light
			lightbeam.set_loc(T)
			lightbeam.alpha = 0
			playsound(T, "sound/voice/heavenly.ogg", 100, 1, 0)
			animate(lightbeam, alpha=255, time=3.5 SECONDS)
			SPAWN_DBG(30)
				animate(lightbeam,alpha = 0, time=3.5 SECONDS)
				sleep(3.5 SECONDS)
				qdel(lightbeam)
			qdel(src)
		else
			boutput(user, "<span class='notice'>\The [src] doesn't seem to do anything as you touch [target] with it.</span>")

////////////////////////////////////////////////// Generic unique items stuff ///////////////////////////////////////////////

////////////////////////////////////////////////// Clothing properties stuff ///////////////////////////////////////////////

/datum/property_setter_property
	var/incrementative = 0 // if 0, sets the properties to desired value. if 1, increases it by the amount
	var/cap = 100   // maximum cap
	var/property_name
	var/property_value
	var/inverse = 0  // stupid negative stats AAH *scream

	New(incrementative, cap, property_name, property_value, inverse = 0)
		. = ..()
		src.incrementative = incrementative
		src.cap = cap
		src.property_name = property_name
		src.property_value = property_value
		src.inverse = inverse


/obj/item/property_setter
	name = "property setter"
	desc = "You shouldn't see this."
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "fabric"
	hide_attack = 2
	var/list/datum/property_setter_property/properties_to_set
	var/prefix_to_set = ""
	var/suffix_to_set = ""
	var/color_to_set

	attack(mob/M as mob, mob/user as mob)
		return

	afterattack(var/atom/target, mob/user, flag)
		var/did_something = 0

		if (istype(target, /obj/item/clothing/))
			var/obj/item/clothing/target_clothing = target
			var/properties_length = length(properties_to_set)
			if (properties_length)
				var/datum/property_setter_property/property
				for (property in properties_to_set)
					var/target_property_value = target_clothing.getProperty(property.property_name)
					if (property.incrementative)
						if (!property.inverse) // not reverse stats, bigger = better
							if (target_property_value < property.cap) // target clothing doesn't exceed cap already
								if (target_property_value + property.property_value >= property.cap) // if increasing property exceeds cap, just set it to cap
									target_clothing.setProperty(property.property_name, property.cap)
									did_something = 1
								else // increasing property doesn't exceed cap, increase normally
									target_clothing.setProperty(property.property_name, property.property_value + target_property_value)
									did_something = 1
						else // inverse stats, lower = better
							if (target_property_value > property.cap) // target clothing doesn't exceed cap already
								if (target_property_value + property.property_value <= property.cap) // if increasing property exceeds cap, just set it to cap
									target_clothing.setProperty(property.property_name, property.cap)
									did_something = 1
								else // increasing property doesn't exceed cap, increase normally
									target_clothing.setProperty(property.property_name, property.property_value + target_property_value)
									did_something = 1
					else // not incrementative, just set the value
						if (property.property_value > target_clothing.getProperty(property.property_name)) // make sure set value is bigger than what the clothing already has
							target_clothing.setProperty(property.property_name, property.property_value)
							did_something = 1

			if (did_something) // some property got changed, display a message and delete src
				var/turf/T = get_turf(target)
				playsound(T, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
				T.visible_message("<span class='notice'>As [user] brings \the [src] towards \the [target], \the [src] begins to smoothly meld into \the [target]!</span>")
				if (length(src.prefix_to_set))
					target.name_prefix(prefix_to_set)
					target.UpdateName()
				if (length(src.suffix_to_set))
					target.name_suffix(suffix_to_set)
					target.UpdateName()
				if (src.color_to_set)
					target.color = src.color_to_set
				if (src.loc)
					if (ishuman(src.loc))
						var/mob/living/carbon/human/wearer = src.loc
						wearer.update_clothing()
						wearer.update_equipped_modifiers() // required for things like movespeed changes
				qdel(src)
			else // nothing got changed, stats might be at cap already
				boutput(user, "<span class='notice'>You can't seem to find a way to improve \the [target] with \the [src].</span>")

		else
			..()

/obj/item/property_setter/fire_jewel
	name = "fire jewel"
	desc = "A sparkling red jewel. It sounds cliche, but something draws you towards inserting this into a clothing article."
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "gem_fire"
	color = "#ff8902"
	prefix_to_set = "fire-imbued"
	color_to_set = "#ff8902"

	New()
		. = ..()
		properties_to_set = list(new /datum/property_setter_property(incrementative = 0, cap = 100, property_name = "heatprot", property_value = 100))


/obj/item/property_setter/reinforce
	name = "reinforcing fabric"
	desc = "An extremely malleable sheet of armored fabric. You feel confident in that you could apply this to a piece of clothing to make it more resistant to outside force."
	color = "#9ddcfa"
	prefix_to_set = "reinforced"
	color_to_set = "#9ddcfa"

	New()
		. = ..()
		properties_to_set = list(new /datum/property_setter_property(incrementative = 1, cap = 12, property_name = "meleeprot", property_value = 4),
		new /datum/property_setter_property(incrementative = 1, cap = 8, property_name = "rangedprot", property_value = 2))

/obj/item/property_setter/thermal
	name = "thermal fabric"
	desc = "An extremely malleable sheet of fabric. This appears to be an expensive thermal fabric, advertised to regulate and maintain temperature, but even then, this seems too advanced to be of a consumer brand. You feel confident in that you could apply this to a piece of clothing to make it more resistant to extreme temperatures."
	color = "#fcca91"
	prefix_to_set = "thermal"
	color_to_set = "#fcca91"

	New()
		. = ..()
		properties_to_set = list(new /datum/property_setter_property(incrementative = 1, cap = 100, property_name = "coldprot", property_value = 60),
		new /datum/property_setter_property(incrementative = 1, cap = 100, property_name = "heatprot", property_value = 45))

/obj/item/property_setter/speedy
	name = "light fabric"
	desc = "An extremely malleable sheet of fabric. This appears to be an experimental light fabric, supposed to make movement more agile and faster, far too expensive for consumer market and banned from several sports competitions. Upon closer inspection, you realise the trade secret is tiny smart rocket boosters. You feel confident in that you could apply this to a piece of clothing to make it more agile to move with."
	color = "#0040b8"
	prefix_to_set = "speedy"
	color_to_set = "#0040b8"

	New()
		. = ..()
		properties_to_set = list(new /datum/property_setter_property(incrementative = 1, cap = -0.3, property_name = "movespeed", property_value = -0.15, inverse = 1),
		new /datum/property_setter_property(incrementative = 1, cap = -0.3, property_name = "space_movespeed", property_value = -0.15, inverse = 1))


////////////////////////////////////////////////// Clothing properties stuff ///////////////////////////////////////////////
