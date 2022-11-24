/obj/item/weldingtool
	name = "weldingtool"
	desc = "A tool that, when turned on, uses fuel to emit a concentrated flame, welding metal together or slicing it apart."
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/weldingtool.dmi'
	icon_state = "weldingtool-off"
	item_state = "weldingtool-off"
	uses_multiple_icon_states = 1

	var/icon_state_variant_suffix = null
	var/item_state_variant_suffix = null

	var/welding = 0
	var/status = 0 // flamethrower construction :shobon:
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_WELDING
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	health = 5
	w_class = W_CLASS_SMALL
	m_amt = 30
	g_amt = 30
	stamina_damage = 10
	stamina_cost = 18
	stamina_crit_chance = 0
	rand_pos = 1
	inventory_counter_enabled = 1
	var/capacity = 20

	New()
		..()
		src.create_reagents(capacity)
		reagents.add_reagent("fuel", capacity)
		src.inventory_counter.update_number(get_fuel())

		src.setItemSpecial(/datum/item_special/flame)
		return

	examine()
		. = ..()
		. += "It has [get_fuel()] units of fuel left!"

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if (!src.welding)
			if (!src.cautery_surgery(M, user, 0, src.welding))
				return ..()
		if (!ismob(M))
			return
		src.add_fingerprint(user)
		if (ishuman(M) && (user.a_intent != INTENT_HARM))
			var/mob/living/carbon/human/H = M
			if (H.bleeding || (H.butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
				if (!src.cautery_surgery(H, user, 15, src.welding))
					return ..()
			else if (user.zone_sel.selecting != "chest" && user.zone_sel.selecting != "head")
				if (!H.limbs.vars[user.zone_sel.selecting])
					switch (user.zone_sel.selecting)
						if ("l_arm")
							if (H.limbs.l_arm_bleed) cauterise("l_arm")
							else
								boutput(user, "<span class='alert'>[H.name]'s left arm stump is not bleeding!</span>")
								return
						if ("r_arm")
							if (H.limbs.r_arm_bleed) cauterise("r_arm")
							else
								boutput(user, "<span class='alert'>[H.name]'s right arm stump is not bleeding!</span>")
								return
						if ("l_leg")
							if (H.limbs.l_leg_bleed) cauterise("l_leg")
							else
								boutput(user, "<span class='alert'>[H.name]'s left leg stump is not bleeding!</span>")
								return
						if ("r_leg")
							if (H.limbs.r_leg_bleed) cauterise("r_leg")
							else
								boutput(user, "<span class='alert'>[H.name]'s right leg stump is not bleeding!</span>")
								return
						else return ..()
				else
					if (!(locate(/obj/machinery/optable, M.loc) && M.lying) && !(locate(/obj/table, M.loc) && (M.getStatusDuration("paralysis") || M.stat)) && !(M.reagents && M.reagents.get_reagent_amount("ethanol") > 10 && M == user))
						return ..()
					switch (user.zone_sel.selecting)
						if ("l_arm")
							if (istype(H.limbs.l_arm, /obj/item/parts/robot_parts) && H.limbs.l_arm.remove_stage > 0)
								attach_robopart("l_arm")
							else
								boutput(user, "<span class='alert'>[H.name]'s left arm doesn't need welding on!</span>")
								return
						if ("r_arm")
							if (istype(H.limbs.r_arm, /obj/item/parts/robot_parts) && H.limbs.r_arm.remove_stage > 0)
								attach_robopart("r_arm")
							else
								boutput(user, "<span class='alert'>[H.name]'s right arm doesn't need welding on!</span>")
								return
						if ("l_leg")
							if (istype(H.limbs.l_leg, /obj/item/parts/robot_parts) && H.limbs.l_leg.remove_stage > 0)
								attach_robopart("l_leg")
							else
								boutput(user, "<span class='alert'>[H.name]'s left leg doesn't need welding on!</span>")
								return
						if ("r_leg")
							if (istype(H.limbs.r_leg, /obj/item/parts/robot_parts) && H.limbs.r_leg.remove_stage > 0)
								attach_robopart("r_leg")
							else
								boutput(user, "<span class='alert'>[H.name]'s right leg doesn't need welding on!</span>")
								return
						else return ..()
			else return ..()
		else return ..()

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			if (status)
				status = 0
				boutput(user, "<span class='notice'>You resecure the welder.</span>")
			else
				status = 1
				boutput(user, "<span class='notice'>The welder can now be attached and modified.</span>")

		else if (status == 1 && istype(W,/obj/item/rods))
			if (src.loc != user)
				boutput(user, "<span class='alert'>You need to be holding [src] to work on it!</span>")
				return
			boutput(user, "<span class='notice'>You attach the rod to the welding tool.</span>")
			var/obj/item/rods/R = new /obj/item/rods
			R.amount = 1
			var/obj/item/rods/S = W
			S.change_stack_amount(-1)
			var/obj/item/assembly/weld_rod/F = new /obj/item/assembly/weld_rod( user )
			src.set_loc(F)
			F.welder = src
			user.u_equip(src)
			user.put_in_hand_or_drop(F)
			R.master = F
			src.master = F
			src.layer = initial(src.layer)
			user.u_equip(src)
			src.set_loc(F)
			F.rod = R
			src.add_fingerprint(user)


	afterattack(obj/O as obj, mob/user as mob)
		if ((istype(O, /obj/reagent_dispensers/fueltank) || istype(O, /obj/item/reagent_containers/food/drinks/fueltank)) && BOUNDS_DIST(src, O) == 0)
			if  (!O.reagents.total_volume)
				boutput(user, "<span class='alert'>The [O.name] is empty!</span>")
				return
			if ("fuel" in O.reagents.reagent_list)
				O.reagents.trans_to(src, capacity, 1, 1, O.reagents.reagent_list.Find("fuel"))
				src.inventory_counter.update_number(get_fuel())
				boutput(user, "<span class='notice'>Welder refueled</span>")
				playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
				return
		if (src.welding)
			use_fuel((ismob(O) || istype(O, /obj/blob) || istype(O, /obj/critter)) ? 2 : 0.2)
			if (get_fuel() <= 0)
				boutput(user, "<span class='notice'>Need more fuel!</span>")
				src.welding = 0
				src.force = 3
				hit_type = DAMAGE_BLUNT
				set_icon_state("weldingtool-off" + src.icon_state_variant_suffix)
				src.item_state = "weldingtool-off" + src.item_state_variant_suffix
				user.update_inhands()
			var/turf/location = user.loc
			if (istype(location, /turf))
				location.hotspot_expose(700, 50, 1)
			if (O && !ismob(O) && O.reagents)
				boutput(user, "<span class='notice'>You heat \the [O.name]</span>")
				O.reagents.temperature_reagents(4000,50, 100, 100, 1)
		return

	attack_self(mob/user as mob)
		if (status > 1) return
		src.welding = !(src.welding)
		src.firesource = !(src.firesource)
		tooltip_rebuild = 1
		if (src.welding)
			if (get_fuel() <= 0)
				boutput(user, "<span class='notice'>Need more fuel!</span>")
				src.welding = 0
				return 0
			boutput(user, "<span class='notice'>You will now weld when you attack.</span>")
			src.force = 15
			hit_type = DAMAGE_BURN
			set_icon_state("weldingtool-on" + src.icon_state_variant_suffix)
			src.item_state = "weldingtool-on" + src.item_state_variant_suffix
			processing_items |= src
			if(user && !ON_COOLDOWN(src, "playsound", 1.3 SECONDS))
				playsound(src.loc, 'sound/effects/welder_ignite.ogg', 65, 1)
		else
			boutput(user, "<span class='notice'>Not welding anymore.</span>")
			src.force = 3
			hit_type = DAMAGE_BLUNT
			set_icon_state("weldingtool-off" + src.icon_state_variant_suffix)
			src.item_state = "weldingtool-off" + src.item_state_variant_suffix
		user.update_inhands()
		return

	blob_act(var/power)
		if (prob(power * 0.5))
			qdel(src)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if (exposed_temperature > 1000)
			return ..()
		return

	firesource_interact()
		if (reagents.get_reagent_amount("fuel"))
			reagents.remove_reagent("fuel", 1)

	process()
		if(!welding)
			processing_items.Remove(src)
			return
		var/turf/location = src.loc
		if (ismob(location))
			var/mob/M = location
			if (M.l_hand == src || M.r_hand == src)
				location = M.loc
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)
		if (prob(10))
			use_fuel(1)
			if (!get_fuel())
				welding = 0
				force = 3
				hit_type = DAMAGE_BLUNT
				set_icon_state("weldingtool-off" + src.icon_state_variant_suffix)
				src.item_state = "weldingtool-off" + src.item_state_variant_suffix
				processing_items.Remove(src)
				return

	proc/get_fuel()
		if (reagents)
			return reagents.get_reagent_amount("fuel")

	proc/use_fuel(var/amount)
		amount = min(get_fuel(), amount)
		if (reagents)
			reagents.remove_reagent("fuel", amount)
		src.inventory_counter.update_number(get_fuel())
		return

	proc/eyecheck(mob/user as mob)
		if(user.isBlindImmune())
			return
		//check eye protection
		var/safety = 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			// we want to check for the thermals first so having a polarized eye doesn't protect you if you also have a thermal eye
			if (istype(H.glasses, /obj/item/clothing/glasses/thermal) || H.eye_istype(/obj/item/organ/eye/cyber/thermal) || istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
				safety = -1
			else if (istype(H.head, /obj/item/clothing/head/helmet/welding))
				var/obj/item/clothing/head/helmet/welding/WH = H.head
				if(!WH.up)
					safety = 2
				else
					safety = 0
			else if (istype(H.head, /obj/item/clothing/head/helmet/space))
				safety = 2
			else if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || H.eye_istype(/obj/item/organ/eye/cyber/sunglass))
				safety = 1
		switch (safety)
			if (1)
				boutput(user, "<span class='alert'>Your eyes sting a little.</span>")
				user.take_eye_damage(rand(1, 2))
			if (0)
				boutput(user, "<span class='alert'>Your eyes burn.</span>")
				user.take_eye_damage(rand(2, 4))
			if (-1)
				boutput(user, "<span class='alert'><b>Your goggles intensify the welder's glow. Your eyes itch and burn severely.</b></span>")
				user.change_eye_blurry(rand(12, 20))
				user.take_eye_damage(rand(12, 16))

	proc/cauterise(mob/living/carbon/human/H as mob, mob/living/carbon/user as mob, var/part)
		if(!istype(H)) return
		if(!istype(user)) return
		if(!part) return

		var/variant = H.bioHolder.HasEffect("lost_[part]")
		if (!variant) return


		if(!src.try_weld(user, 5))
			return

		H.TakeDamage("chest",0,20)
		if (prob(50)) H.emote("scream")

		variant = max(1, variant-20)
		H.bioHolder.RemoveEffect("lost_[part]")
		H.bioHolder.AddEffect("lost_[part]", variant)

		for (var/mob/O in AIviewers(H, null))
			if (O == (user || H))
				continue
			if (H == user)
				O.show_message("<span class='alert'>[user.name] cauterises their own stump with [src]!</span>", 1)
			else
				O.show_message("<span class='alert'>[H.name] has their stump cauterised by [user.name] with [src].</span>", 1)

		if(H != user)
			boutput(H, "<span class='alert'>[user.name] cauterises your stump with [src].</span>")
			boutput(user, "<span class='alert'>You cauterise [H.name]'s stump with [src].</span>")
		else
			boutput(user, "<span class='alert'>You cauterise your own stump with [src].</span>")

		return

	proc/attach_robopart(mob/living/carbon/human/H as mob, mob/living/carbon/user as mob, var/part)
		if (!istype(H)) return
		if (!istype(user)) return
		if (!part) return

		if (!H.bioHolder.HasEffect("loose_robot_[part]")) return

		if(!src.try_weld(user, 5))
			return

		H.TakeDamage("chest",0,20)
		if (prob(50)) H.emote("scream")
		user.visible_message("<span class='alert'>[user.name] welds [H.name]'s robotic part to their stump with [src].</span>", "<span class='alert'>You weld [H.name]'s robotic part to their stump with [src].</span>")
		H.bioHolder.RemoveEffect("loose_robot_[part]")
		return

	proc/try_weld(mob/user, var/fuel_amt = 2, var/use_amt = -1, var/noisy=1, var/burn_eyes=1) //fuel amt is how much fuel is needed to weld, use_amt is how much fuel is used per action
		if (src.welding)
			if(use_amt == -1)
				use_amt = fuel_amt
			if (src.get_fuel() < fuel_amt)
				boutput(user, "<span class='notice'>Need more fuel!</span>")
				return 0 //welding, doesnt have fuel
			src.use_fuel(use_amt)
			if(noisy)
				playsound(user.loc, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[noisy], 40, 1)
			if(burn_eyes)
				src.eyecheck(user)
			return 1 //welding, has fuel
		return 0 //not welding

/obj/item/weldingtool/yellow
	icon_state = "weldingtool-off-yellow"
	item_state = "weldingtool-off-yellow"
	icon_state_variant_suffix = "-yellow"
	uses_multiple_icon_states = 1

/obj/item/weldingtool/vr
	icon_state = "weldingtool-off-vr"
	icon_state_variant_suffix = "-vr"

/obj/item/weldingtool/high_cap
	name = "high-capacity weldingtool"
	capacity = 100
