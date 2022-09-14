#define ADMIN_BEES_ONLY if(!src.non_admin_bee_allowed && src.client && !src.client.holder) {src.make_critter(/mob/living/critter/small_animal/wasp); return}

/* ============================================= */
/* -------------------- Bee -------------------- */
/* ============================================= */
// I will probably regret this but I think the time has finally come for PLAYABLE BEES
/mob/living/critter/small_animal/bee
	name = "greater domestic space-bee"
	real_name = "greater domestic space-bee"
	icon = 'icons/misc/bee.dmi'
#ifdef HALLOWEEN
	icon_state = "vorbees-wings"
	icon_state_dead = "vorbees-dead"
	var/icon_state_sleep = "vorbees-sleep"
	var/icon_state_zzzs = "beezzzs"
	var/icon_body = "vorbees"
	desc = "Seems like even the greater domestic space-bees are celebrating Spooktober."
#else
	icon_state = "petbee-wings"
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types."
	icon_state_dead = "petbee-dead"
	var/icon_state_sleep = "petbee-sleep"
	var/icon_state_zzzs = "beezzzs"
	var/icon_body = "petbee"
#endif
	var/icon_color = null
	var/has_color_overlay = 1
	var/image/image_color_overlay = null
	var/image/image_sleep_overlay = null
	speechverb_say = "bumbles"
	speechverb_exclaim = "buzzes"
	speechverb_ask = "bombles"
	pet_text = list("pets","hugs","snuggles","cuddles")
	health_brute = 25
	health_brute_vuln = 0.8
	health_burn = 25
	health_burn_vuln = 0.5
	metabolizes = 0 // for now?
	butcherable = 2
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 3
	add_abilities = list(/datum/targetable/critter/bite/bee,
						 /datum/targetable/critter/bee_sting)
	var/limb_path = /datum/limb/small_critter/bee
	var/mouth_path = /datum/limb/mouth/small/bee

	var/honey_production_amount = 50
	var/nectar_check = 10
	var/datum/plantgenes/pollen = null
	var/honey_color = 0
	var/is_dancing = 0
	var/shorn = 0
	var/shorn_time = 0

	var/non_admin_bee_allowed = 0

	New()
		..()
		// bee mobs should have their actual bee names
		real_name = name
		SPAWN(0)
			ADMIN_BEES_ONLY
			//statlog_bees(src)
			src.UpdateIcon()

			if (!isdead(src))
				animate_bumble(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("flip")
				if (src.emote_check(voluntary, 50) && !src.shrunk)
					SPAWN(1 SECOND)
						// animate_bumble(src)
						// either stays put or bumbles
						src.animate_lying(src.lying)
					return null
			if ("snap","buzz")
				if (src.emote_check(voluntary, 30))
					return "<b>[src]</b> buzzes!" // todo?: find buzz noise
			if ("dance")
				if (src.emote_check(voluntary, 100) && !src.is_dancing)
					src.dance()
					return "<b>[src]</b> dances!"
			if ("smile","bumble","bomble")
				if (src.emote_check(voluntary, 50))
					return "<b>[src]</b> [act == "smile" ? pick("bumbles","bombles") : "[act]s"] happily!"
			if ("sleep")
				if (src.hasStatus("resting"))
					src.sleeping = 2
					return null
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("flip")
				return 1
			if ("snap","buzz")
				return 2
			if ("dance")
				return 1
			if ("smile","bumble","bomble")
				return 1
			if ("sleep")
				return 1
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new src.limb_path
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left feet"
		HH.limb_name = "foot"

		HH = hands[2]
		HH.limb = new src.limb_path
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right feet"
		HH.limb_name = "foot"

		HH = hands[3]
		HH.limb = new src.mouth_path
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mandibles"
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		ADMIN_BEES_ONLY
		if (..(parent))
			return 1
		if (shorn && (world.time - shorn_time) >= 1800)
			shorn = 0

	death(gibbed)
		if (!gibbed)
			animate(src)
		for (var/obj/critter/domestic_bee/fellow_bee in view(7,src)) // once mobcritters have AI we can change this to the mob version of bees, but for now we do this
			if (fellow_bee?.alive)
				fellow_bee.aggressive = 1
				SPAWN(0.7 SECONDS)
					fellow_bee.aggressive = 0
		..()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		if (!isdead(src))
			animate_bumble(src) // please keep bumbling tia

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(15))
			for (var/mob/O in hearers(src, null))
				O.show_message("[src] buzzes[prob(50) ? " happily!" : ""]!",2)
		if (prob(10))
			user.visible_message("<span class='notice'>[src] hugs [user] back!</span>",\
			"<span class='notice'>[src] hugs you back!</span>")
			if (user.reagents)
				user.reagents.add_reagent("hugs", 10)


	// force_laydown_standup()
	// 	..()
	// 	if (src.sleeping > 0)
	// 	return

	animate_lying(is_lying)
		if (is_lying)
			// stop the bumbling animation
			animate(src, pixel_y = -4, time = 1)
		else
			animate_bumble(src)


	on_sleep()
		..()
		src.UpdateIcon()
		return

	on_wake()
		..()
		src.UpdateIcon()
		return

	attackby(obj/item/W, mob/living/user)
		if (isdead(src))
			return ..()
		if (issnippingtool(W))
			if (src.shorn)
				boutput(user, "<b>[src]</b> has barely any beefuzz left. Stop it.")
				return
			else
				src.shorn = 1
				src.shorn_time = world.time
				user.visible_message("<b>[user]</b> shears \the [src]!","You shear \the [src].")
				var/obj/item/material_piece/cloth/beewool/BW = new /obj/item/material_piece/cloth/beewool
				BW.set_loc(src.loc)
				return

		else if (istype(W, /obj/item/reagent_containers/food/snacks))
			if (findtext(W.name,"bee") && !istype(W, /obj/item/reagent_containers/food/snacks/beefood)) // You just know somebody will do this
				src.visible_message("<b>[src]</b> buzzes in a repulsed manner!", 1)
				return
			if (!W.reagents)
				boutput(user, "<b>[src]</b> respectfully declines, being a strict nectarian.")
				return
			var/nectarAmt = W.reagents.get_reagent_amount("nectar")
			var/isHoney = istype(W, /obj/item/reagent_containers/food/snacks/ingredient/honey) || istype(W, /obj/item/reagent_containers/food/snacks/pizza) || W.reagents.has_reagent("honey")
			if (!nectarAmt && !isHoney)
				boutput(user, "<b>[src]</b> respectfully declines, being a strict nectarian.")
				return

			user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src].")
			src.visible_message("<b>[src]</b> buzzes delightedly.", 1)

			user.HealDamage("All", 10, 10)
			W.reagents.del_reagent("nectar")

			src.reagents.add_reagent("honey", nectarAmt)
			W.reagents.trans_to(src, (isHoney ? W.reagents.total_volume * 0.75 : 100) )
			if (src.reagents.total_volume >= src.reagents.maximum_volume)
				src.puke_honey()
			qdel(W)
		else
			..()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		set waitfor = 0
		if (!user || !E)
			return 0
		if (isdead(src))
			return
		if (E.icon_state == "gold")
			user.visible_message("<b>[user]</b> offers [E] to [src], but [src] respectfully declines, as it didn't stay down the first time.",\
			"You offer [E] to [src], but [src] respectfully decline, as it didn't stay down the first time.")
			return
		E.layer = initial(src.layer)
		user.u_equip(E)
		E.set_loc(src)
		if (user)
			user.visible_message("<b>[user]</b> feeds [E] to [src]!",\
			"You feed [E] to [src]. Fuck!")

		sleep(2 SECONDS)
		E.icon_state = "gold"
		E.desc += "  It appears to be covered in honey.  Gross."
		src.visible_message("<b>[src]</b> regurgitates [E]!")
		E.name = "sticky [E.name]"
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		E.set_loc(get_turf(src))
		return

	proc/puke_honey()
		var/turf/honeyTurf = get_turf(src)
		var/obj/item/reagent_containers/food/snacks/pizza/floor_pizza = locate() in honeyTurf
		var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey
		if (istype(floor_pizza))
			honey = new /obj/item/reagent_containers/food/snacks/pizza(honeyTurf)
			src.visible_message("<b>[src]</b> regurgitates a blob of honey directly onto [floor_pizza]![prob(10) ? " This is a thing that makes sense." : null]",\
			"You regurgitate a blob of honey directly onto [floor_pizza]!")
			honey.name = replacetext(floor_pizza.name, "pizza", "beezza")
			qdel(floor_pizza)

		else
			honey = new /obj/item/reagent_containers/food/snacks/ingredient/honey(honeyTurf)
			src.visible_message("<b>[src]</b> regurgitates a blob of honey![prob(10) ? " Gross!" : null]",\
			"You regurgitate a blob of honey!")

		if (honey.reagents)
			// Increase the reagent container by the amount of honey we're generating
			// as honey starts with 15/50 and bees have 50
			// (meant that reagent transfers often didn't work since honey was too full)
			honey.reagents.maximum_volume += honey_production_amount

		src.reagents.trans_to(honey, honey_production_amount)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		if (src.honey_color)
			var/icon/composite = icon(honey.icon, honey.icon_state)
			composite.ColorTone( src.honey_color )
			honey.icon = composite

		return honey

	proc/dance()
		set waitfor = 0
		src.is_dancing = 1

		var/dir_choice = prob(50) ? -90 : 90
		var/sleep_time = (rand(1,20) / 10)
		var/time_time = (rand(15,20) / 10)

		sleep(sleep_time)
		animate_beespin(src, dir_choice, time_time, 1)

		sleep(time_time * 8)
		src.animate_lying(src.lying)
		// animate_bumble(src)
		src.is_dancing = 0

	update_icon()
		if (src.has_color_overlay && src.color)
			src.icon_color = src.color
			src.color = null
		else if (!src.has_color_overlay)
			src.UpdateOverlays(null, "coverlay")

		if (isdead(src))
			// src.icon_state = "[src.icon_body]-dead"
			src.icon_state = icon_state_dead
			src.UpdateOverlays(null, "zzzs")
			if (src.icon_color)
				if (!src.image_color_overlay)
					src.image_color_overlay = image(src.icon)
				src.image_color_overlay.icon_state = "[src.icon_state_dead]-color"
				src.image_color_overlay.color = src.icon_color
				src.UpdateOverlays(src.image_color_overlay, "coverlay")

		else
			if (src.sleeping)
				src.icon_state = icon_state_sleep // "[src.icon_body]-sleep"
				if (src.icon_state_zzzs)
					if (!src.image_sleep_overlay)
						src.image_sleep_overlay = image(src.icon, src.icon_state_zzzs)
					src.UpdateOverlays(src.image_sleep_overlay, "zzzs")
				if (src.icon_color)
					if (!src.image_color_overlay)
						src.image_color_overlay = image(src.icon)
					src.image_color_overlay.icon_state = "[src.icon_state_sleep]-color"
					src.image_color_overlay.color = src.icon_color
					src.UpdateOverlays(src.image_color_overlay, "coverlay")
			else
				src.icon_state = "[src.icon_body]-wings"
				src.UpdateOverlays(null, "zzzs")
				if (src.icon_color)
					if (!src.image_color_overlay)
						src.image_color_overlay = image(src.icon)
					src.image_color_overlay.icon_state = "[src.icon_body]-color"
					src.image_color_overlay.color = src.icon_color
					src.UpdateOverlays(src.image_color_overlay, "coverlay")

/* -------------------- Limbs -------------------- */

/datum/limb/mouth/small/bee // bee
	dam_low = 1
	dam_high = 2
	var/list/bite_adjectives = list("tiny","eeny-weeny","minute","little","nubby")

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			return ..()
		else if (isitem(target))
			var/obj/item/potentially_food = target
			if (findtext(target.name,"bee") && !istype(target, /obj/item/reagent_containers/food/snacks/beefood))
				boutput(user, "<span class='alert'>Oh god, that's <b>repulsive</b>!</span>")
				return
			else if (potentially_food.edible)
				potentially_food.Eat(user, user, 1)
				return
		else if (istype(target, /obj/machinery/plantpot) && user.reagents)
			var/obj/machinery/plantpot/planter = target
			if (planter.dead || !planter.reagents || !planter.current)
				return

			var/planterNectarAmt = planter.reagents.get_reagent_amount("nectar")

			if (planterNectarAmt < 5)
				return

			var/nectarTransferAmt = min( min( (user.reagents.maximum_volume - user.reagents.total_volume), planterNectarAmt), 25 )

			if (nectarTransferAmt <= 0)
				return

			if (planter.current.assoc_reagents.len || (planter.plantgenes && planter.plantgenes.mutation && length(planter.plantgenes.mutation.assoc_reagents)))
				var/list/additional_reagents = planter.current.assoc_reagents
				if (planter.plantgenes && planter.plantgenes.mutation && length(planter.plantgenes.mutation.assoc_reagents))
					additional_reagents = additional_reagents | planter.plantgenes.mutation.assoc_reagents

				planter.reagents.remove_reagent("nectar", nectarTransferAmt*0.75)
				user.reagents.add_reagent("honey", nectarTransferAmt*0.75)
				for (var/X in additional_reagents)
					user.reagents.add_reagent(X, (nectarTransferAmt*0.25) / additional_reagents.len)

			else
				planter.reagents.remove_reagent("nectar", nectarTransferAmt)
				user.reagents.add_reagent("honey", nectarTransferAmt)

			//Bee is good for plants.  Synergy.  Going to hold a business meeting and use only yellow and black in the powerpoints.
			if (prob(10) && planter.health < planter.current.starthealth)
				planter.health++

			user.visible_message("<b>[user]</b> [pick("slurps","sips","drinks")] nectar out of [planter].",\
			"You [pick("slurp","sip","drink")] nectar out of [planter].")
			user.HealDamage("All", 5, 5)

			if (user.reagents.total_volume >= user.reagents.maximum_volume)
				if (istype(user, /mob/living/critter/small_animal/bee))
					var/mob/living/critter/small_animal/bee/B = user
					B.puke_honey()
				else
					new /obj/item/reagent_containers/food/snacks/ingredient/honey(get_turf(user))
					user.visible_message("<b>[user]</b> regurgitates a blob of honey![prob(10) ? " Gross!" : null]",\
					"You regurgitate a blob of honey!")
				return

	harm(mob/target, var/mob/user)
		if (!user || !target)
			return 0
		if (!target.melee_attack_test(user))
			return
		src.custom_msg = "<b><span class='combat'>[user] bites [target] with [his_or_her(user)] [pick(src.bite_adjectives)] [prob(50) ? "mandibles" : "bee-teeth"]!</span></b>"
		..()

/datum/limb/mouth/small/bee/queen
	dam_low = 5
	dam_high = 8
	bite_adjectives = list("rather large","big","expansive","proportionally small but still sizable")

/datum/limb/small_critter/bee // can hold slightly larger things
	max_wclass = W_CLASS_NORMAL
	actions = list("pokes")
	sound_attack = null

/datum/limb/small_critter/bee/strong // can hold any sized thing (unless we have items with w_class > 99 somewhere I guess)
	max_wclass = 99

/datum/limb/small_critter/bee/strong/bubs // da bubs
	dam_low = 18
	dam_high = 22
	sound_attack = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	dmg_type = DAMAGE_STAB

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (check_target_immunity(target))
			return 0
		src.custom_msg = "<span class='combat'><b>[user]</b> shanks [target] with [his_or_her(user)] [pick("tiny","eeny-weeny","minute","little")] switchblade!</span>"
		..()

/* -------------------- Abilities -------------------- */

/datum/targetable/critter/bee_sting
	name = "Sting"
	desc = "Sting a mob, injecting them with venom."
	icon_state = "bee_sting"
	cooldown = 50
	targeted = 1
	target_anything = 1
	var/venom1 = "histamine"
	var/amt1 = 5
	var/venom2 = "toxin"
	var/amt2 = 4
	var/list/sting_adjectives = list("nubby little","stubby little","tiny little")
	var/brute_damage = 2

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to sting there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to sting.</span>")
			return 1
		var/mob/living/MT = target
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] pokes [MT] with [his_or_her(holder.owner)] [pick(src.sting_adjectives)] stinger!</b></span>")
		if (MT.reagents)
			if (MT.reagents.get_reagent_amount(venom1) < 10)
				MT.reagents.add_reagent(venom1, amt1)
			MT.reagents.add_reagent(venom2, amt2)
		MT.TakeDamage("All", src.brute_damage, 0, 0, DAMAGE_STAB)//armor piercing stingers
		return 0

/datum/targetable/critter/bee_sting/queen
	cooldown = 70
	venom1 = "neurotoxin"
	amt1 = 20
	venom2 = "morphine"
	amt2 = 10
	sting_adjectives = list("IMMENSE","COLOSSAL","GARGANTUAN","GIANT")
	brute_damage = 10

/datum/targetable/critter/bite/bee
	name = "Bite"
	desc = "Bite down on a mob, causing a little damage."
	icon_state = "bee_bite"
	cooldown = 30
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	brute_damage = 4
	var/list/bite_adjectives = list("tiny","eeny-weeny","minute","little","nubby")

	cast(atom/target)
		if (..())
			return 1
		if (!ismob(target))
			return 1
		var/mob/MT = target
		playsound(target, src.sound_bite, 100, 1, -1)
		MT.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT] with [his_or_her(holder.owner)] [pick(src.bite_adjectives)] [prob(50) ? "mandibles" : "bee-teeth"]!</b></span>")
		return 0

/datum/targetable/critter/bite/bee/queen
	cooldown = 50
	brute_damage = 10
	bite_adjectives = list("rather large","big","expansive","proportionally small but still sizable")

/datum/targetable/critter/bee_swallow
	name = "Swallow"
	desc = "Swallow a mob, trapping them in honey."
	icon_state = "bee_swallow"
	cooldown = 300
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to swallow there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to swallow.</span>")
			return 1
		var/mob/living/MT = target
		if (MT.loc != holder.owner)
			holder.owner.visible_message("<span class='combat'><b>[holder.owner] swallows [MT] whole!</b></span>")
			MT.set_loc(holder.owner)
			SPAWN(2 SECONDS)
				var/obj/icecube/honeycube = new /obj/icecube(src)
				MT.set_loc(honeycube)
				honeycube.name = "block of honey"
				honeycube.desc = "It's a block of honey. I guess there's someone trapped inside? Is it Han Solo?"
				honeycube.steam_on_death = 0
				honeycube.health = 100

				var/icon/composite = icon(honeycube.icon, honeycube.icon_state)
				composite.ColorTone( rgb(242,242,111) )
				honeycube.icon = composite
				honeycube.underlays += MT

				honeycube.set_loc(holder.owner.loc)
				holder.owner.visible_message("<b>[holder.owner] regurgitates [MT]!</b>")
				playsound(holder.owner, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		return 0

/datum/targetable/critter/bee_teleport
	name = "Stare"
	desc = "Stare at a mob, teleporting them away after a short time."
	icon_state = "bee_teleport"
	cooldown = 300
	targeted = 1
	target_anything = 1
	var/do_buzz = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to teleport there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		var/mob/living/MT = target
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to teleport away.</span>")
			return 1
		holder.owner.visible_message("<span class='combat'><b>[holder.owner]</b> stares at [MT]!</span>")
		if(do_buzz)
			playsound(holder.owner, 'sound/voice/animal/buzz.ogg', 100, 1)
		boutput(MT, "<span class='combat'>You feel a horrible pain in your head!</span>")
		MT.changeStatus("stunned", 2 SECONDS)
		SPAWN(2.5 SECONDS)
			if ((GET_DIST(holder.owner, MT) <= 6) && !isdead(holder.owner))
				MT.visible_message("<span class='combat'><b>[MT] clutches their temples!</b></span>")
				MT.emote("scream")
				MT.setStatusMin("paralysis", 20 SECONDS)
				MT.take_brain_damage(10)

				do_teleport(MT, locate((world.maxx/2) + rand(-10,10), (world.maxy/2) + rand(-10,10), 1), 0)

/* ================================================== */
/* -------------------- Subtypes -------------------- */
/* ================================================== */

/mob/living/critter/small_animal/bee/heisenbee
	name = "Heisenbee"
	desc = "The Research Director's pet domestic space-bee.  Heisenbee has been invaluable in the study of the effects of space on bee behaviors."
	health_brute = 30
	health_burn = 30
	var/jittered = 0
	honey_color = rgb(0, 255, 255)
	// halloween stuff can come a little later seeing as we just now finished halloween

	attackby(obj/item/W, mob/living/user)
		if (src.stat)
			return ..()

		if (istype(W, /obj/item/device/gps))
			if (src.jittered)
				boutput(user, "<span class='alert'>[src] politely declines.</span>")
				return

			src.jittered = 1
			user.visible_message("<span class='alert'>[user] hands [src] the [W.name]</span>","You hand [src] the [W.name].")

			W.layer = initial(src.layer)
			user.u_equip(W)
			W.set_loc(src)

			SPAWN(rand(10,20))
				src.visible_message("<span class='alert'><b>[src] begins to move at unpredicable speeds!</b></span>")
				animate_bumble(src, floatspeed = 3)
				sleep(rand(30,50))
				src.visible_message("<span class='alert'>[W] goes flying!</span>")
				if (W)
					W.set_loc(src.loc)
					var/edge = get_edge_target_turf(src, pick(alldirs))
					W.throw_at(edge, 25, 4)

				animate_bumble(src)
				src.visible_message("<b>[src]</b> gives off a dizzy buzz.")

		else if (istype(W, /obj/item/photo/heisenbee))
			user.visible_message("[user] shows [src] the [W.name].","You show [src] the [W.name].")
			src.visible_message("[src] bumbles in a slightly embarrassed manner.[prob(30) ? "  You can discern this degree of emotion from bumbling, ok." : null]")

		else
			..()

/mob/living/critter/small_animal/bee/buddy
	name = "B-33"
	desc = "It appears to be a hybrid of a domestic space-bee and a PR-6 Robuddy. How is that even possible?"
	icon_state = "buddybee-wings"
	icon_state_dead = "buddybee-dead"
	icon_state_sleep = "buddybee-sleep"
	icon_state_zzzs = "beezzzs-buddybee"
	icon_body = "buddybee"

/mob/living/critter/small_animal/bee/trauma
	name = "traumatized space bee"
	desc = "This poor bee has seen some serious shit."
	icon_state = "traumabee-wings"
	icon_state_dead = "traumabee-dead"
	icon_state_sleep = "traumabee-sleep"
	icon_body = "traumabee"

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(15))
			for (var/mob/O in hearers(src, null))
				O.show_message("[src] buzzes[prob(50) ? " in a comforted manner" : ""].",2)
		return

/mob/living/critter/small_animal/bee/chef
	desc = "Please do not think too hard about the circumstances that would result in a bee chef."
	icon_state = "chefbee-wings"
	icon_state_dead = "chefbee-dead"
	icon_state_sleep = "chefbee-sleep"
	icon_body = "chefbee"

/mob/living/critter/small_animal/bee/santa
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one has a little santa hat, aww."
	icon_state = "santabee-wings"
	icon_state_dead = "santabee-dead"
	icon_state_sleep = "santabee-sleep"
	icon_body = "santabee"
	honey_color = rgb(0, 255, 0)

/mob/living/critter/small_animal/bee/reindeer
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types. It seems to have antlers?"
	icon_state = "deerbee-wings"
	icon_state_dead = "deerbee-dead"
	icon_state_sleep = "deerbee-sleep"
	icon_body = "deerbee"

/mob/living/critter/small_animal/bee/fancy
	icon_state = "tophatbee-wings"
	icon_state_dead = "tophatbee-dead"
	icon_state_sleep = "tophatbee-sleep"
	icon_body = "tophatbee"

/mob/living/critter/small_animal/bee/creepy
	desc = "Genetically engineered for extreme size and indistinct segmen-<br>oh god what is wrong with its face<br><b>oh god it's looking at you</b>"
	icon_state = "creepybee-wings"
	icon_state_dead = "creepybee-dead"
	icon_state_sleep = "creepybee-sleep"
	icon_body = "creepybee"

/mob/living/critter/small_animal/bee/angry // the angry bee is like angry birds if angry birds was nothing like angry birds and was instead a bee that looked grumpy
	icon_state = "madbee-wings"
	icon_state_dead = "madbee-dead"
	icon_state_sleep = "madbee-sleep"
	icon_body = "madbee"

/mob/living/critter/small_animal/bee/moth
	name = "moth"
	desc = "It appears to be a hybrid of a domestic space-bee and a moth. How cute!"
	icon_state = "moth-wings"
	icon_state_dead = "moth-dead"
	icon_state_sleep = "moth-sleep"
	icon_body = "moth"
	honey_color = rgb(207, 207, 207)
	speechverb_say = "flutters"
	speechverb_exclaim = "squeaks"
	speechverb_ask = "flutters"

/mob/living/critter/small_animal/bee/zombee
	name = "zombee"
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic space-bee is increasingly popular among space traders and science-types.<br>This one seems kinda sick, poor thing."
	icon_state = "zombee-wings"
	icon_state_dead = "zombee-dead"
	icon_state_sleep = "zombee-sleep"
	icon_body = "zombee"
	honey_color = rgb(0, 255, 0)
	var/playing_dead = 0

	Life(datum/controller/process/mobs/parent)
		src.play_dead()
		. = ..(parent)

	death(var/gibbed)
		if (gibbed)
			return ..()
		else if (src.playing_dead)
			return
		else
			src.play_dead(rand(5,15))

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (I.force && src.playing_dead)
			src.playing_dead = 1
			src.play_dead()

	proc/play_dead(var/addtime = 0)
		if (addtime > 0) // we're adding more time
			if (src.playing_dead <= 0) // we don't already have time on the clock
				src.icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead" // so we gotta show the message + change icon + etc
				src.visible_message("<span class='alert'><b>[src]</b> dies!</span>",\
				"<span class='alert'><b>You die!</b></span>")
				src.set_density(0)
			src.playing_dead = clamp((src.playing_dead + addtime), 0, 30)
		if (src.playing_dead <= 0)
			return
		if (src.playing_dead == 1)
			src.playing_dead = 0
			src.set_density(1)
			src.full_heal()
			src.visible_message("<span class='notice'><b>[src]</b> seems to rise from the dead!</span>")
			boutput(src, "<span class='notice'><b>You rise from the dead!</b></span>") // visible_message doesn't go through when this triggers
			src.hud.update_health()
			return
		else
			setunconscious(src)
			src.setStatus("paralysis", 10 SECONDS)
			src.setStatus("stunned", 10 SECONDS)
			src.setStatus("weakened", 10 SECONDS)
			src.sleeping = 10
			src.playing_dead--
			src.hud.update_health()

/mob/living/critter/small_animal/bee/zombee/lich // sprite by mageziya, it's silly but cute imo
	name = "lich-bee"
	icon_state = "lichbee-wings"
	icon_state_dead = "lichbee-dead"
	icon_state_sleep = "lichbee-sleep"
	icon_body = "lichbee"
	honey_color = rgb(25, 55, 25)

/mob/living/critter/small_animal/bee/small
	icon_state = "lilbee-wings"
	icon_state_dead = "lilbee-dead"
	icon_state_sleep = "lilbee-sleep"
	icon_body = "lilbee"

/mob/living/critter/small_animal/bee/sea
	name = "greater domestic sea-bee"
	desc = "Genetically engineered for extreme size and indistinct segmentation and bred for docility, the greater domestic sea-bee is increasingly popular among ocean traders and science-types."
	icon_state = "seabee-wings"
	icon_state_dead = "seabee-dead"
	icon_state_sleep = "seabee-sleep"
	icon_body = "seabee"

/mob/living/critter/small_animal/bee/moon
	name = "Moon Bee"
	desc = "A moon bee.  It's like a regular space bee, but it has a peculiar gleam in its eyes..."
	var/hug_count = 0

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(15))
			for (var/mob/O in hearers(src, null))
				O.show_message("[src] buzzes[prob(50) ? " happily!" : ""]!",2)
		if (prob(10))
			user.visible_message("<span class='notice'>[src] hugs [user] back!</span>",\
			"<span class='notice'>[src] hugs you back!</span>")
			if (user.reagents)
				user.reagents.add_reagent("hugs", 10)
		switch (src.hug_count++)
			if (10)
				src.visible_message("<b>[src]</b> burps!  It smells like beeswax.")
			if (25)
				src.visible_message("<b>[src]</b> burps!  It smells...coppery.  What'd that bee eat?")
			if (100)
				src.visible_message("<b>[src]</b> regurgitates a...key? Huh!")
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				if (src.name == "sun bee")
					new /obj/item/device/key {name = "solar key"; desc = "A metal key with a sun icon on the bow.";} (src.loc)
				else
					new /obj/item/device/key {name = "lunar key"; desc = "A metal key with a moon icon on the bow.";} (src.loc)

/mob/living/critter/small_animal/bee/overbee
	name = "THE OVERBEE"
	real_name = "THE OVERBEE"
	desc = "Not to be confused with that other stinging over-insect."
	health_brute = 500
	health_brute_vuln = 0.2
	health_burn = 500
	health_burn_vuln = 0.2
	icon_state = "overbee-wings"
	icon_state_dead = "overbee-dead"
	icon_state_sleep = "overbee-sleep"
	icon_body = "overbee"
	add_abilities = list(/datum/targetable/critter/bite/bee,
						 /datum/targetable/critter/bee_sting,
						 /datum/targetable/critter/bee_teleport)

	puke_honey()
		var/turf/T = locate(src.x + rand(-2,2), src.y + rand(-2,2), src.z)
		if (!T)
			return null
		;
		new /obj/overlay/self_deleting {name = "hole in space time"; layer=2.2; icon = 'icons/misc/lavamoon.dmi'; icon_state="voidwarp";} (T, 20)
		elecflash(src,power = 3)

		var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey = new /obj/item/reagent_containers/food/snacks/ingredient/honey(T)
		. = honey
		if (honey.reagents)
			honey.reagents.maximum_volume = honey_production_amount
		src.reagents.trans_to(honey, honey_production_amount)
		src.visible_message("<b>[src]</b> wills a blob of honey into existence![prob(10) ? " Weird!" : null]")
		playsound(src.loc, 'sound/effects/mag_forcewall.ogg', 50, 1)

	attackby(obj/item/W, mob/living/user)
		if (src.stat)
			return ..()

		if (istype(W, /obj/item/device/key))
			if (dd_hasprefix(lowertext(W.name), "gold"))
				boutput(user, "<b>[src]</b> respectfully declines, as it didn't stay down the first time.")
				return
			if (!dd_hasprefix(lowertext(W.name), "lead"))
				boutput(user, "<b>[src]</b> doesn't seem to be interested.  Maybe it's the color?  The metal?")
				return

			W.layer = initial(src.layer)
			user.u_equip(W)
			W.set_loc(src)
			user.visible_message("<b>[user]</b> feeds [W] to [src]!","You feed [W] to [src]. Fuck!")
			SPAWN(2 SECONDS)
				W.icon_state = "key_gold"
				W.desc += "  It appears to be covered in honey.  Gross."
				src.visible_message("<b>[src]</b> regurgitates [W]!")
				W.name = "golden key"
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				W.set_loc(get_turf(src))
		else
			return ..()

/mob/living/critter/small_animal/bee/bubs
	name = "fat and sassy space-bee"
	desc = "A greater domestic space-bee that happens to be particularly pudgy and obstinate."
	health_brute = 500
	health_burn = 500
	icon_state = "bubsbee-wings"
	icon_state_dead = "bubsbee-dead"
	icon_state_sleep = "bubsbee-sleep"
	icon_body = "bubsbee"
	flags = 0
	fits_under_table = 0
	density = 1 // well I mean... duh
	limb_path = /datum/limb/small_critter/bee/strong/bubs

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		set waitfor = 0
		if (!user || !E)
			return 0
		if (isdead(src))
			return
		E.layer = initial(src.layer)
		user.u_equip(E)
		E.set_loc(src)
		if (user)
			user.visible_message("<b>[user]</b> feeds [E] to [src]!",\
			"You feed [E] to [src]. Fuck!")

		sleep(2 SECONDS)
		qdel(E)
		src.visible_message("<b>[src]</b> burps.")

		sleep(1 SECOND)
		src.visible_message("<b>[src]</b> bumbles happily!")
		//src.dance()

		sleep(17 SECONDS)
		if (GET_DIST(src, user) <= 7)
			src.visible_message("<b>[src]</b> buzzes in a clueless manner as to why [user] looks so dejected.[prob(5)?" You can tell because you studied bee linguistics, ok?": null]")

			//Is this a bad idea? It probably is a bad idea.
			sleep(2 SECONDS)
			var/obj/item/dagger/D = new /obj/item/dagger/syndicate(src.loc)
			D.name = "tiny switchblade"
			D.desc = "Why would a bee even have this!?"
			src.visible_message("<b>[src]</b> drops \a [D] on the floor in an attempt to cheer [user] up!")
			playsound(D.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg' , 30, 1)

	dance()
		set waitfor = 0
		src.is_dancing = 1

		var/dir_choice = prob(50) ? -90 : 90
		var/sleep_time = (rand(1,20) / 10)
		var/time_time = (rand(15,20) / 10)

		sleep(sleep_time)
		animate_beespin(src, dir_choice, time_time, 1)

		sleep(time_time * 8)
		src.icon_state = "bubsbee-8I"
		src.canmove = 0
		animate(src, pixel_y = -6, time = 20, easing = BOUNCE_EASING)

		sleep(2 SECONDS)
		src.pixel_y = 0
		src.icon_state = "bubsbee"
		src.sleeping = rand(10, 20)
		src.setStatus("paralysis", 2 SECONDS)
		src.UpdateIcon()
		src.visible_message("<span class='notice'>[src] gets tired from all that work and takes a nap!</span>")
		src.is_dancing = 0

/mob/living/critter/small_animal/bee/queen
	name = "queen greater domestic space-bee"
	desc = "Despite the royal title, the greater domestic space-bee cannot actually lay eggs--those are produced in large biochemical engineering tanks.  The stinger of this species is, unlike its terrestrial brethren, not a modified ovipositor but instead formed of keratin.  You probably expected this description to just be \"holy shit what a big bee!\" or something, right?"
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 50
	icon = 'icons/misc/bigcritter.dmi'
	icon_state = "queenbee-wings"
	icon_state_dead = "queenbee-dead"
	icon_state_sleep = "queenbee-sleep"
	icon_body = "queenbee"
	pixel_x = -16
	pixel_y = -16
	layer = 10 // should be over windows and shit like that
	honey_production_amount = 100
	flags = 0
	fits_under_table = 0
	add_abilities = list(/datum/targetable/critter/bite/bee/queen,
						 /datum/targetable/critter/bee_sting/queen,
						 /datum/targetable/critter/bee_swallow)
	limb_path = /datum/limb/small_critter/bee/strong
	mouth_path = /datum/limb/mouth/small/bee/queen

	puke_honey()
		. = ..()
		if (.)
			var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey = .
			honey.icon_state = "bighoneyblob"
			honey.bites_left++

/mob/living/critter/small_animal/bee/queen/buddy
	desc = "It appears to be a hybrid of a queen domestic space-bee and a PR-6 Robuddy. How is that even possible?"
	icon_state = "buddybee-wings"
	icon_state_dead = "buddybee-dead"
	icon_state_sleep = "buddybee-sleep"
	icon_body = "buddybee"

/mob/living/critter/small_animal/bee/queen/big
	desc = "Despite the royal title, the greater domestic space-bee cannot actually lay eggs--those are produced in large biochemical engineering tanks.  The stinger of this species is, unlike its terrestrial brethren, not a modified ovipositor but instead formed of keratin. This one's a little bigger than normal."
	health_brute = 75
	health_brute_vuln = 0.5
	health_burn = 75
	health_burn_vuln = 0.4
	icon_state = "bigqueenbee-wings"
	icon_state_dead = "bigqueenbee-dead"
	icon_state_sleep = "bigqueenbee-sleep"
	icon_body = "bigqueenbee"
	honey_production_amount = 150

/mob/living/critter/small_animal/bee/queen/omega
	name = "queen greatest domestic space-bee"
	desc = "That's a big bee, that is."
	pixel_x = -48
	pixel_y = -48
	health_brute = 500
	health_brute_vuln = 0.3
	health_burn = 500
	health_burn_vuln = 0.2
	honey_production_amount = 200
	icon = 'icons/misc/biggercritter.dmi'
	icon_state = "omega-wings"
	icon_state_dead = "omega-dead"
	icon_state_sleep = "omega-sleep"
	icon_body = "omega"

/mob/living/critter/small_animal/bee/beestation //A special bee that should allow non-admins to play as a bee.
	non_admin_bee_allowed = 1

/mob/living/critter/small_animal/bee/ascbee
	name = "ASCBee"
	desc = "This bee looks rather... old school."
	icon_body = "ascbee"
	icon_state = "ascbee-wings"
	icon_state_sleep = "ascbee-sleep"
	honey_color = rgb(0, 255, 0)

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(15))
			for (var/mob/O in hearers(src, null))
				O.show_message("[src] beeps[prob(50) ? " in a comforted manner, and gives [user] the ASCII" : ""].",2)
		return


obj/effects/bees
	plane = PLANE_NOSHADOW_ABOVE
	particles = new/particles/swarm/bees

	New(atom/movable/A)
		..()
		if(istype(A))
			A.vis_contents += src


particles/swarm/bees
	icon = 'icons/misc/bee.dmi'
	icon_state = list("mini-bee"=1, "mini-bee2"=1)
	friction = 0.1
	count = 10
	spawning = 0.35
	fade = 5
#ifndef SPACEMAN_DMM
	fadein = 5
#endif
	lifespan = generator("num", 50, 80, LINEAR_RAND)
	width = 64
	position = generator("box", list(-10,-10,0), list(10,10,50))
	bound1 = list(-32, -32, -100)
	bound2 = list(32, 32, 100)
	gravity = list(0, -0.1)
	drift = generator("box", list(-0.4, -0.1, 0), list(0.4, 0.15, 0))
	velocity = generator("box", list(-2, -0.1, 0), list(2, 0.5, 0))
	height = 64

	start_none
		count = 0

#undef ADMIN_BEES_ONLY
