/obj/blob
	name = "blob"
	desc = "A mysterious alien blob-like organism."
	icon = 'icons/mob/blob.dmi'
	icon_state = "15"
	var/state_overlay = null
	var/anim_overlay = null // hack, there HAS to be a better way of doing this

	color = "#FF0000"
	var/original_color = "#FF0000"
	alpha = 180
	density = 1
	opacity = 0
	anchored = 1
	event_handler_flags = USE_FLUID_ENTER
	var/health = 30         // current health of the blob
	var/health_max = 30     // health cap
	var/armor = 1           // how much incoming damage gets divided by unless it bypasses armor
	var/ideal_temp = 310    // what temperature the blob is safe at
	var/mob/living/intangible/blob_overmind/overmind = null // who's the player controlling this blob
	var/gen_rate_value = 0  // how much gen rate upkeep the overmind is paying on this tile
	var/can_spread_from_this = 1
	var/can_attack_from_this = 1
	var/poison = 0
	var/can_absorb = 1
	var/special_icon = 0
	var/spread_type = null
	var/spread_value = 0
	var/movable = 0
	var/in_disposing = 0
	var/datum/action/bar/blob_health/healthbar //Hack.
	var/static/image/poisoned_image
	var/fire_coefficient = 1
	var/poison_coefficient = 1
	var/poison_spread_coefficient = 0.5
	var/poison_depletion = 0.75
	var/heat_divisor = 15
	var/temp_tolerance = 40
	mat_changename = 0
	mat_changedesc = 0
	var/runOnLife = 0 //Should this obj run Life?

	New()
		..()
		START_TRACKING
		if (!poisoned_image)
			poisoned_image = image('icons/mob/blob.dmi', "poison")
		src.UpdateIcon()
		update_surrounding_blob_icons(get_turf(src))
		var/datum/controller/process/blob/B = get_master_blob_controller()
		B?.blobs += src
		for (var/obj/machinery/camera/C in get_turf(src))
			qdel(C)

		healthbar = new
		healthbar.owner = src
		healthbar.onStart()
		healthbar.onUpdate()

		SPAWN(0.1 SECONDS)
			for (var/mob/living/carbon/human/H in src.loc)
				if (H.decomp_stage == DECOMP_STAGE_SKELETONIZED || check_target_immunity(H))//too decomposed or too cool to be eaten
					continue
				H.was_harmed(src)
				src.visible_message("<span class='alert'><b>The blob starts trying to absorb [H.name]!</b></span>")
				actions.start(new /datum/action/bar/blob_absorb(H, overmind), src)
				playsound(src.loc, "sound/voice/blob/blobsucc[rand(1, 3)].ogg", 10, 1)

		spawn_animation()

	proc/spawn_animation()
		var/target_alpha = src.alpha
		src.alpha = 50
		var/list/obj/blob/blob_sources = list()
		for(var/obj/blob/B in src.loc)
			if(B != src)
				blob_sources += B
		if(!length(blob_sources))
			for(var/dir in ordinal)
				var/obj/blob/blob = locate(/obj/blob) in get_step(src, dir)
				if(blob && (locate(/obj/blob) in get_step(src, dir & (NORTH | SOUTH))) && (locate(/obj/blob) in get_step(src, dir & (EAST | WEST))))
					blob_sources += blob
		if(!length(blob_sources))
			for(var/dir in cardinal)
				var/obj/blob/blob = locate(/obj/blob) in get_step(src, dir)
				if(blob)
					blob_sources += blob
		var/matrix/midmatrix = null
		var/shiftsize = 18
		var/x_shift_comp = 0
		var/y_shift_comp = 0
		if(length(blob_sources))
			var/obj/blob/blob_source = pick(blob_sources)
			var/source_dir = get_dir(src, blob_source)
			var/xshift = ((source_dir & EAST) ? 1 : 0) + ((source_dir & WEST) ? -1 : 0)
			var/yshift = ((source_dir & NORTH) ? 1 : 0) + ((source_dir & SOUTH) ? -1 : 0)
			if(!xshift && !yshift)
				src.transform = src.transform.Scale(1.5, 1.5)
			else
				src.transform = src.transform.Scale(xshift ? 0.1 : 1, yshift ? 0.1 : 1)
			src.transform = src.transform.Translate(xshift * shiftsize, yshift * shiftsize)
			midmatrix = matrix(null, xshift * 3 , yshift * 3, MATRIX_TRANSLATE)
			x_shift_comp = -xshift
			y_shift_comp = -yshift
		animate(src, pixel_x=x_shift_comp * 3, pixel_y=y_shift_comp * 3, time=0.4 SECONDS)
		//animate(src, pixel_x=x_shift_comp * 2, pixel_y=y_shift_comp * 2, easing=JUMP_EASING, time=1.3 SECONDS)
		animate(transform=midmatrix, alpha=target_alpha, time=1.4 SECONDS, easing=ELASTIC_EASING, flags=ANIMATION_PARALLEL)
		animate(pixel_x=0, pixel_y=0, transform=null, time=2 SECONDS, easing=JUMP_EASING)

	proc/right_click_action()
		usr.examine_verb(src)

	Click(location, control, params)
		if (usr != overmind)
			return
		var/list/pa = params2list(params)
		if ("right" in pa)
			right_click_action()
		else
			..()

	Cross(atom/movable/mover)
		. = ..()
		var/obj/projectile/P = mover
		if (istype(P) && P.proj_data) //Wire note: Fix for Cannot read null.type
			if (P.proj_data.type == /datum/projectile/slime)
				return 1
		if (istype(mover, /obj/decal))
			return 1

	set_loc(newloc)
		var/atom/old_loc = loc
		. = ..()
		if(!("anim_overlay" in overlay_refs))
			update_overlays(overmind?.organ_color || src.color)
		if(isturf(old_loc))
			update_surrounding_blob_icons(old_loc)
		UpdateIcon()
		if(isturf(newloc))
			update_surrounding_blob_icons(newloc)

	proc/update_overlays(organ_color)
		if( state_overlay )
			var/image/blob_image
			if (special_icon)
				blob_image = image('icons/mob/blob_organs.dmi')
			else
				blob_image = image('icons/mob/blob.dmi')
			blob_image.appearance_flags |= RESET_COLOR
			blob_image.plane = PLANE_ABOVE_LIGHTING

			blob_image.color = organ_color
			blob_image.icon_state = state_overlay
			UpdateOverlays(blob_image,"overmind")
		if ( anim_overlay )
			var/image/blob_anim_image = image('icons/mob/blob_organs.dmi')
			blob_anim_image.appearance_flags |= RESET_COLOR
			blob_anim_image.plane = PLANE_ABOVE_LIGHTING
			blob_anim_image.layer = 100

			blob_anim_image.color = organ_color
			blob_anim_image.icon_state = anim_overlay
			UpdateOverlays(blob_anim_image,"anim_overlay")

	proc/setOvermind(var/mob/living/intangible/blob_overmind/O)
		if (overmind == O)
			return
		if (overmind)
			overmind.blobs -= src
		if (O)
			overmind = O
			setMaterial(copyMaterial(O.my_material))
			color = material.color
			original_color = color
			O.blobs |= src
			onAttach(O)
			update_overlays(O.organ_color)
			if ( O.hat && istype(src,/obj/blob/nucleus))
				O.hat.pixel_y += 5 //hat needs to match position of perspective nucleus
				UpdateOverlays(O.hat,"hat")

	proc/onAttach(var/mob/living/intangible/blob_overmind/new_overmind)
		if (istype(new_overmind))
			if (spread_value)
				new_overmind.spread_mitigation += spread_value

	proc/attack(var/turf/T)
		particleMaster.SpawnSystem(new /datum/particleSystem/blobattack(T,overmind.color))
		if (T?.density)
			T.blob_act(overmind.attack_power * 20)
			T.material?.triggerOnBlobHit(T, overmind.attack_power * 20)

		else
			for (var/mob/M in T.contents)
				M.blob_act(overmind.attack_power * 20)
				if(isliving(M))
					var/mob/living/L = M
					L.was_harmed(src)
			for (var/obj/O in T.contents)
				O.blob_act(overmind.attack_power * 20)
				O.material?.triggerOnBlobHit(O, overmind.attack_power * 20)


	proc/attack_random()
		var/list/allowed = list()
		for (var/D in cardinal)
			var/turf/Q = get_step(get_turf(src), D)
			if (Q && !(locate(/obj/blob) in Q))
				allowed += Q
		if (allowed.len)
			attack(pick(allowed))

	disposing()
		if (qdeled || in_disposing)
			return
		STOP_TRACKING
		in_disposing = 1
		var/datum/controller/process/blob/B = get_master_blob_controller()
		B.blobs -= src
		if (istype(overmind))
			overmind.blobs -= src
			if (gen_rate_value > 0)
				overmind.gen_rate_used = max(0,overmind.gen_rate_used - gen_rate_value)
				gen_rate_value = 0
			overmind.spread_mitigation -= spread_value
		var/turf/T = get_turf(src)
		healthbar?.onDelete()
		qdel(healthbar)
		healthbar = null
		..()
		update_surrounding_blob_icons(T)
		in_disposing = 0

	ex_act(severity)
		var/damage = 0
		var/damage_mult = 1
		switch(severity)
			if(1)
				damage = rand(30,50)
				damage_mult = 8
			if(2)
				damage = rand(25,40)
				damage_mult = 4
			if(3)
				damage = rand(10,20)
				damage_mult = 2
				if (prob(5))
					create_chunk(get_turf(src))

		src.take_damage(damage,damage_mult,"mixed")
		return

	bullet_act(var/obj/projectile/P)
		if(src.material) src.material.triggerOnBullet(src, src, P)
		var/damage = round((P.power*P.proj_data.ks_ratio), 1.0)
		var/damage_mult = 1
		var/damtype = "brute"
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				damage_mult = 0.5
				damtype = "brute"
			if(D_PIERCING)
				damage_mult = 0.25
				damtype = "brute"
			if(D_ENERGY)
				damage_mult = 1
				damtype = "laser" // a type of burn damage that fire resistant membranes don't protect against
			if(D_BURNING)
				damage_mult = 2
				damtype = "burn"
			if(D_SLASHING)
				damage_mult = 1.5
				damtype = "brute"

		src.take_damage(damage,damage_mult,damtype)
		return

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		var/temp_difference = abs(temperature - src.ideal_temp)
		var/tolerance = temp_tolerance
		if (material)
			material.triggerTemp(src, temperature)

		if (src.has_upgrade(/datum/blob_upgrade/fire_resist))
			tolerance *= 3
		if(temp_difference > tolerance)
			temp_difference = abs(temp_difference - tolerance)

			src.take_damage(temp_difference / heat_divisor * min(1, volume / (CELL_VOLUME/3)), 1, "burn")

	attack_hand(var/mob/user)
		user.lastattacked = src
		var/adj1
		var/adj2 = pick_string("blob.txt", "adj2")
		var/act1
		var/act2 = pick_string("blob.txt", "act2")
		switch(user.a_intent)
			if(INTENT_HELP)
				adj1 = "help"
			if(INTENT_DISARM)
				adj1 = "disarm"
			if(INTENT_GRAB)
				adj1 = "grab"
			if(INTENT_HARM)
				adj1 = "harm"
		act1 = pick_string("blob.txt", "act1_[adj1]")
		adj1 = pick_string("blob.txt", "adj1_[adj1]")
		playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
		src.visible_message("<span class='combat'><b>[user.name]</b> [adj1] [act1] [src]! That's [adj2] [act2]!</span>")
		return

	attackby(var/obj/item/W, var/mob/user)
		user.lastattacked = src
		if(ismobcritter(user) && user:ghost_spawned || isghostdrone(user))
			src.visible_message("<span class='combat'><b>[user.name]</b> feebly attacks [src] with [W], but is too weak to harm it!</span>")
			return
		if( istype(W,/obj/item/clothing/head) && overmind )
			user.drop_item()
			overmind.setHat(W)
			user.visible_message( "<span class='notice'>[user] places the [W] on the blob!</span>" )
			user.visible_message( "<span class='notice'>The blob disperses the hat!</span>" )
			overmind.show_message( "<span class='notice'>[user] places the [W] on you!</span>" )
			return
		src.visible_message("<span class='combat'><b>[user.name]</b> attacks [src] with [W]!</span>")
		playsound(src.loc, "sound/voice/blob/blobdamaged[rand(1, 3)].ogg", 75, 1)
		if (W.hitsound)
			playsound(src.loc, W.hitsound, 50, 1)

		var/damage = W.force
		var/damage_mult = 1
		var/damtype = "brute"
		if (W.hit_type == DAMAGE_BURN)
			damtype = "burn"

		if (damage)
			if (overmind)
				overmind.onBlobHit(src, user)

			if (src.type == /obj/blob && W.hit_type != DAMAGE_BURN)
				var/chunk_chance = 2
				if (W.hit_type == DAMAGE_CUT)
					chunk_chance = 8
				if (prob(chunk_chance))
					create_chunk(get_turf(user))

		if (material)
			material.triggerOnAttacked(src, user, src, W)

		src.take_damage(damage,damage_mult,damtype,user)

		if (ispryingtool(W))
			user.unlock_medal("Is it really that time again?", 1)

		return

	proc/create_chunk(var/turf/T)
		var/obj/item/material_piece/wad/blob/BC = new
		BC.set_loc(T)
		BC.setMaterial(copyMaterial(material))
		BC.name = "chunk of blob"

	proc/take_damage(var/amount,var/damage_mult = 1,var/damtype = "brute",var/mob/user)
		if (!isnum(amount) || amount <= 0)
			return

		if (damage_mult <= 0)
			damage_mult = 1

		if (damtype == "mixed")
			var/brute = round(amount / 2)
			var/burn = amount - brute
			take_damage(brute, damage_mult, "brute", user)
			take_damage(burn,  damage_mult, "burn",  user)
			return

		var/armor_value = armor
		var/ignore_armor = 0
		switch (damtype)
			if ("burn")
				if (!src.has_upgrade(/datum/blob_upgrade/fire_resist))
					ignore_armor = 1
				else
					amount = min(amount, health_max * 0.8)
				amount *= fire_coefficient
				//search for ectothermids.
				if (amount)
					for_by_tcl(T, /obj/blob/ectothermid)
						if (IN_RANGE(src, T, T.protect_range) && amount > 0)
							amount *= T.absorb(min(amount * damage_mult, src.health))
							break
			if ("laser")
				ignore_armor = 1
			if ("poison","self_poison")
				if (!src.has_upgrade(/datum/blob_upgrade/poison_resist))
					ignore_armor = 1
				else
					armor_value = max(2, armor)
				amount *= poison_coefficient
				//handle poison overlay
				if (amount && damtype == "poison")
					src.poison += amount * damage_mult
					updatePoisonOverlay()
					if (!overmind)
						SPAWN(1 SECOND)
							while (poison)
								Life()
								sleep(1 SECOND)
					return
			if ("chaos")
				ignore_armor = 1
		if (!ignore_armor && armor_value > 0)
			amount /= armor_value

		amount *= damage_mult

		if (!amount)
			return


		src.health -= amount
		src.health = clamp(src.health, 0, src.health_max)

		if (src.health <= 0)
			src.onKilled()
			if (overmind)
				overmind.onBlobDeath(src, user)
			playsound(src.loc, "sound/voice/blob/blobspread[rand(1, 2)].ogg", 100, 1)
			qdel(src)
		else
			src.UpdateIcon()
			if (healthbar) //ZeWaka: Fix for null.onUpdate
				healthbar.onUpdate()
		return

	proc/updatePoisonOverlay()
		if (!poison)
			animate(src)
			color = original_color
		else
			animate(src, color="#00FF00", time=10, loop=-1)

	proc/onKilled()
		if (poison)
			poison = poison * poison_spread_coefficient
			var/list/spread = list()
			for (var/d in cardinal)
				var/turf/T = get_step(loc, d)
				if (T)
					var/obj/blob/B = locate() in T
					if (B)
						spread += B
			if (spread.len)
				var/amt = poison / length(spread)
				for (var/obj/blob/B in spread)
					B.poison += amt

	proc/heal_damage(var/amount)
		if (!isnum(amount) || amount < 1)
			return
		if (src.poison)
			amount /= 4
		src.health += amount
		src.health = clamp(src.health, 0, src.health_max)
		particleMaster.SpawnSystem(new /datum/particleSystem/blobheal(get_turf(src),src.color))
		src.UpdateIcon()
		healthbar.onUpdate()

	update_icon()

		if (!src)
			return

		if (!special_icon || istype(src,/obj/blob/nucleus))
			var/dirs = 0
			for (var/dir in cardinal)
				var/turf/T = get_step(src, dir)
				if (!T)
					continue

				var/obj/blob/B = T.get_blob_on_this_turf()
				if (B)
					dirs |= dir
			icon_state = num2text(dirs)

		//else if(istext( special_icon ))
		//	if(!BLOB_OVERLAYS[ special_icon ])
		//		CRASH( "Invalid blob special icon [special_icon]." )
		//	else


		src.setMaterial(src.material)
		var/healthperc = get_fraction_of_percentage_and_whole(src.health,src.health_max)
		switch(healthperc)
			if (-INFINITY to 33)
				src.alpha *= 0.25
			if (34 to 66)
				src.alpha *= 0.5
			if (66 to 99)
				src.alpha *= 0.8
		src.alpha = max(src.alpha, 32)

	proc/spread(var/turf/T)
		if (!istype(T) || !T.can_blob_spread_here(null, null, isadmin(overmind) || overmind.admin_override))
			return

		var/blob_type = /obj/blob/
		if (ispath(src.spread_type))
			blob_type = src.spread_type

		var/obj/blob/B = new blob_type(T)
		B.setOvermind(overmind)

		return B

	proc/Life()
		if (disposed)
			return 1
		if (!overmind)
			return 1
		if (overmind.tutorial)
			if (!overmind.tutorial.PerformSilentAction("blob-life", src))
				return 0
		if (src.poison)
			var/damage_taken = clamp(src.poison, 1, 10)
			take_damage(damage_taken, 1, "self_poison")
			src.poison -= damage_taken * poison_depletion
			src.poison = max(src.poison, 0)
			updatePoisonOverlay()

		return 0

	proc/has_upgrade(var/upgrade_path)
		if (!ispath(upgrade_path) && !istype(src.overmind))
			return 0
		if (src.overmind && src.overmind.has_upgrade(upgrade_path))
			return 1
		else
			return 0

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (O == src)
			return
		if (O.disposed)
			return
		if (overmind != user)
			return
		if (isitem(O))
			if (BOUNDS_DIST(O, src) > 0)
				return
			var/datum/blob_ability/devour_item/D = overmind.get_ability(/datum/blob_ability/devour_item)
			if (D)
				D.onUse(O)
			return
		if (!istype(O, /obj/blob))
			return
		if (overmind.tutorial)
			if (!overmind.tutorial.PerformAction("mousedrop", list(O, src)))
				return
		if (istype(O, /obj/blob) && src.type == /obj/blob) // I'M LAZY. i'll fix this up if needed
			var/obj/blob/Q = O
			if (Q.movable)
				Q.onMove(src)

	proc/onMove(var/obj/blob/B)
		return


/obj/blob/nucleus
	name = "blob nucleus"
	state_overlay = "nucleus"
	anim_overlay = "nucleus_blink"
	special_icon = 1
	desc = "The core of the blob. Destroying all nuclei effectively stops the organism dead in its tracks."
	armor = 1.5
	health_max = 500
	health = 500
	temp_tolerance = 1200
	fire_coefficient = 0.5
	poison_coefficient = 0.5
	poison_depletion = 3
	var/nextAttackMsg = 0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	bullet_act(var/obj/projectile/P)
		if (P.proj_data.damage_type == D_ENERGY && src.overmind && prob(src.overmind.nucleus_reflectivity))
			shoot_reflected_to_sender(P, src)
			playsound(src.loc, "sound/voice/blob/blobreflect[rand(1, 5)].ogg", 100, 1)
		else
			..()

	onAttach(var/mob/living/intangible/blob_overmind/O)
		..()
		O.nuclei += src
		if(O.nucleus_overlay && O.nucleus_overlay.alpha)
			src.UpdateOverlays(O.nucleus_overlay, "reflectivity")

	take_damage(amount, mult, damtype, mob/user)
		var/now = world.timeofday
		if (!src.nextAttackMsg || now >= src.nextAttackMsg) //every 5 seconds supposedly
			boutput(overmind, "<span class='blobalert'>Your nucleus in [get_area(src)] is taking damage!</span>")
			src.nextAttackMsg = now + 50 //every 5 seconds

		..()

	onKilled()
		if (!(src in overmind.nuclei))
			return

		overmind.nuclei -= src

		//still got some nuclei left!
		if (length(overmind.nuclei))
			//give a downside to having a nucleus destroyed. wipe biopoints and temp nerf generation (handled in blob overmind Life())
			overmind.bio_points = 0
			overmind.debuff_timestamp = world.timeofday + overmind.debuff_duration

			out(overmind, "<span class='blobalert'>Your nucleus in [get_area(src)] has been destroyed! You feel a lot weaker for a short time...</span>")

			if (prob(1))
				src.visible_message("<span class='blobalert'>With a great almighty wobble, the nucleus and nearby blob pieces wither and die! The time of jiggles is truly over.</span>")
			else
				src.visible_message("<span class='blobalert'>The nucleus and nearby blob pieces wither and die!</span>")

		//all dead :(
		else
			out(overmind, "<span class='blobalert'>Your nucleus in [get_area(src)] has been destroyed!</span>")
			if (prob(50))
				playsound(src.loc, 'sound/voice/blob/blobdeploy.ogg', 100, 1)
			else
				playsound(src.loc, 'sound/voice/blob/blobdeath.ogg', 100, 1)

		//destroy blob tiles near the destroyed nucleus
		for (var/obj/blob/B in orange(1, src))
			//dont insta-kill nearby nuclei tho...
			if (!istype(B, /obj/blob/nucleus))
				B.onKilled()
				qdel(B)

		..()


/obj/blob/mutant
	name = "mutated blob"
	icon_state = "mutant"
	special_icon = 1
	desc = "It's a mutated blob bit. For all intents and purposes, it is useless."
	armor = 0
	can_absorb = 0
	movable = 0

/obj/blob/launcher
	name = "slime launcher"
	state_overlay = "cannon"

	special_icon = 1
	desc = "It's a slime ball launcher. The organic equivalent of a defense turret."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	runOnLife = 1
	var/slime_cost = 2
	var/firing_range = 7
	var/last_color = null
	var/datum/projectile/slime/current_projectile = new
	var/static/image/underlay_image = null

	New()
		..()
		if (!underlay_image)
			underlay_image = image('icons/mob/blob.dmi', "deposit-reagent")

	proc/update_reagent_underlay()
		if (disposed)
			return
		if (src.reagents.total_volume <= 0)
			underlays.len = 0
			return
		var/curr_color = src.reagents.get_average_rgb()
		if (curr_color != last_color)
			underlays.len = 0
			underlay_image.color = curr_color
			last_color = curr_color
			underlays += underlay_image

	Life()
		if (..())
			return 1

		var/cost = 2
		if (reagents)
			if (reagents.total_volume)
				cost = 0

		if (cost && !overmind.hasPoints(slime_cost))
			return 1

		var/list/targets_primary = list()
		var/list/targets_secondary = list()

		//turrets can fire on humans, mobcritters and pods
		for (var/mob/living/M in view(firing_range, src))
			if ((ishuman(M) || (ismobcritter(M) && !M:ghost_spawned) || issilicon(M)) && !isdead(M) && !check_target_immunity(M))
				if (isnpcmonkey(M))
					targets_secondary += M
				else
					targets_primary += M

		for(var/obj/machinery/vehicle/pod_smooth/P in view(firing_range, src))
			targets_secondary += P

		if (!targets_primary.len && !length(targets_secondary))
			return 1

		var/atom/Target = null

		if (targets_primary.len)
			Target = pick(targets_primary)
		else
			Target = pick(targets_secondary)

		if (!Target)
			return 1

		var/obj/projectile/L = initialize_projectile_ST(src, current_projectile, Target)

		if (!L)
			return
		L.setup()

		if (!cost)
			L.reagents = new /datum/reagents(15)
			L.reagents.my_atom = L
			reagents.trans_to(L, 5, 3)
			L.color = L.reagents.get_average_rgb()
			L.name = "[L.reagents.get_master_reagent_name()]-infused slime"
			update_reagent_underlay()
		else
			overmind.usePoints(slime_cost)
			L.color = overmind.color

		visible_message("<span class='alert'><b>[src] fires slime at [Target]!</b></span>")
		L.launch()

/datum/projectile/slime
	name = "slime"
	icon = 'icons/obj/projectiles.dmi'
	//state_overlay = "slime"
	color_red = 0
	color_green = 0
	color_blue = 0
	color_icon = "#ffffff"
	damage = 10
	stun = 10//yassTODO
	cost = 0
	dissipation_rate = 25
	dissipation_delay = 8
	sname = "slime"
	shot_sound = 'sound/voice/blob/blobshoot.ogg'
	shot_number = 0
	damage_type = D_SPECIAL
	hit_ground_chance = 50
	window_pass = 0
	override_color = 1

	on_hit(atom/hit, angle, var/obj/projectile/O)
		..()

		if (O.reagents)
			O.reagents.reaction(hit, TOUCH)
			if (ismob(hit))
				O.reagents.trans_to(hit, 15)

		if (ismob(hit))
			var/mob/asshole = hit
			asshole.TakeDamage("All", 8, 0) //haha fuck armor amiright? blobs don't need a nerf in this department
			if (ishuman(asshole))
				var/mob/living/carbon/human/literal_asshole = asshole
				literal_asshole.remove_stamina(45)
				playsound(hit.loc, 'sound/voice/blob/blobhit.ogg', 100, 1)

			if (prob(8))
				asshole.drop_item()

/obj/blob/mitochondria
	name = "mitochondria"
	state_overlay = "mitochondria"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to be knitting together nearby holes in the blob... and pushing around any toxins."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	runOnLife = 1
	poison_spread_coefficient = 2
	var/heal_range = 2
	var/heal_amount = 4

	Life()
		if (..())
			return 1
		for (var/obj/blob/B in view(heal_range,src))
			if (B.health < B.health_max)
				B.heal_damage(heal_amount)

			if(B.poison && !istype(B, /obj/blob/mitochondria) && !istype(B, /obj/blob/lipid))
				src.poison += B.poison/2
				B.poison = 0

		for (var/obj/blob/lipid/B in view(1))
			if(istype(B, /obj/blob/lipid))
				if(B.poison < 50)
					B.poison += src.poison / 2 + 2
					src.poison /= 2
					src.poison -= 2

/obj/blob/reflective
	name = "reflective membrane"
	state_overlay = "reflective"
	special_icon = 1
	desc = "This cell seems to reflect light."
	armor = 0
	gen_rate_value = 0
	can_absorb = 0
	opacity = 1
	health = 40
	health_max = 40
	gas_impermeable = TRUE

	bullet_act(var/obj/projectile/P)
		if (P.proj_data.damage_type == D_ENERGY)
			shoot_reflected_to_sender(P, src)
			playsound(src.loc, "sound/voice/blob/blobreflect[rand(1, 5)].ogg", 100, 1)
		else
			..()

/obj/blob/ectothermid
	name = "ectothermid"
	state_overlay = "ectothermid"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to store heat energy."
	armor = 0
	gen_rate_value = 1
	can_absorb = 0
	runOnLife = 1
	var/protect_range = 3
	var/temptemp = 0
	var/absorbed_temp = 0
	var/removed = 0
	var/dead = 0

	New()
		. = ..()
		START_TRACKING

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (temperature > T20C)
			temperature = T20C
		..(air, temperature, volume)

	onAttach(var/mob/living/intangible/blob_overmind/O)
		..()
		O.gen_rate_bonus -= 0.5
		removed = 0.5

	disposing()
		..()
		STOP_TRACKING
		if (overmind)
			overmind.gen_rate_bonus += removed
			removed = 0

	Life()
		if (..())
			return 1
		absorbed_temp += temptemp * 0.25 + 50
		temptemp *= 0.75
		temptemp -= 50
		for (var/turf/simulated/floor/T in range(protect_range,src))
			var/datum/gas_mixture/air = T.air
			if (air.temperature > T20C)
				air.temperature /= 2
				air.temperature -= 100
				if(air.temperature > T20C)
					absorbed_temp += log(2, air.temperature)

	proc/absorb(amount)
		if(!dead)
			temptemp += amount
			return clamp(0.0005 * (temptemp - 100), 0, 1)
		else
			return 1

	onKilled()
		. = ..()
		dead = 1
		if(absorbed_temp > 1000)
			fireflash_s(get_turf(src), protect_range + 1, absorbed_temp + temptemp, (absorbed_temp + temptemp)/protect_range)


/obj/blob/plasmaphyll
	name = "plasmaphyll"
	state_overlay = "plasmaphyll"
	special_icon = 1
	desc = "It's a giant energy converting cell. It seems to feed on certain gases."
	armor = 0
	gen_rate_value = 1
	can_absorb = 0
	runOnLife = 1
	poison_coefficient = 0.5
	var/protect_range = 3
	var/consume_per_tick = 5.5
	var/plasma_per_point = 2

	Life()
		if (..())
			return 1
		var/toxins_consumed = 0
		for (var/turf/simulated/floor/T in range(protect_range,src))
			var/datum/gas_mixture/air = T.air
			if (air.toxins > 0)
				if (air.temperature > T20C)
					air.temperature = T20C + (air.temperature - T20C) / 1.25
				toxins_consumed += min(consume_per_tick, air.toxins)
				air.toxins = max(air.toxins - consume_per_tick, 0)
		if (!toxins_consumed)
			return
		overmind.bio_points = min(overmind.bio_points + round(toxins_consumed / plasma_per_point), overmind.bio_points_max)

/obj/blob/lipid
	name = "lipid"
	state_overlay = "lipid"
	special_icon = 1
	desc = "It's an energy storage cell. It stores biopoints... and toxins."
	armor = 0
	can_absorb = 0
	fire_coefficient = 1.5
	poison_coefficient = 0

	onAttach(var/mob/living/intangible/blob_overmind/O)
		..()
		O.lipids += src

	proc/use()
		overmind.lipids -= src
		overmind.bio_points += 4
		var/turf/T = get_turf(src)
		set_loc(null)
		var/obj/blob/B = new /obj/blob(T)
		B.overmind = overmind
		B.poison = src.poison
		overmind.blobs += B
		B.color = overmind.color
		qdel(src)

// TODO: REPLACE WITH SOMETHING COOLER - URS
/obj/blob/ribosome
	name = "ribosome"
	state_overlay = "ribosome"
	special_icon = 1
	desc = "It's a protein sequencing cell. It enhances the blob's ability to spread."
	poison_spread_coefficient = 1
	armor = 0
	can_absorb = 0
	var/added = 0
	var/list/affected_blobs = list()

	onAttach(var/mob/living/intangible/blob_overmind/O)
		..()
		O.gen_rate_bonus += 0.1
		added = 0.1

	update_icon()

		return

	disposing()
		..()
		if (overmind)
			overmind.gen_rate_bonus -= added
			added = 0


/obj/blob/wall
	name = "thick membrane"
	desc = "This blob is encased in a tough membrane. It'll be harder to get rid of."
	state_overlay = "wall"
	opacity = 1
	special_icon = 1
	armor = 2
	health = 75
	health_max = 75
	can_absorb = 0
	gas_impermeable = TRUE
	flags = ALWAYS_SOLID_FLUID

	take_damage(var/amount,var/damage_mult = 1,var/damtype,var/mob/user)
		if (damage_mult == 0)
			return
		if (damtype != "mixed")
			if (amount * damage_mult > health_max * 0.6)
				amount = health_max * 0.6 / damage_mult
		..(amount, damage_mult, damtype, user)

	update_icon()

		return

/obj/blob/firewall
	name = "fire-resistant membrane"
	desc = "This blob is encased in a fireproof membrane."
	state_overlay = "firewall"
	opacity = 1
	special_icon = 1
	armor = 1
	can_absorb = 0
	gas_impermeable = TRUE
	health = 40
	health_max = 40

	take_damage(amount, mult, damtype, mob/user)
		if (damtype == "burn")
			return
		else if (damtype == "laser")
			return ..(amount/3,mult,damtype,user)
		else return ..()

	update_icon(override_parent)
		return

/////////////////////////
/// BLOB RELATED PROCS //
/////////////////////////

/atom/proc/blob_act(var/power)
	return

/turf/proc/get_object_for_blob_to_attack()
	if (!src)
		return null

	if (src.contents.len < 1)
		return null

	for (var/obj/O in src.contents)
		if (O.density)
			return O

	for (var/mob/M in src.contents)
		if (!isdead(M))
			return M

	return null

/turf/proc/can_blob_spread_here(var/mob/feedback, var/skip_adjacent, var/admin_overmind = 0)
	if (!src)
		return 0

	if (istype(src,/turf/space/))
		if (feedback)
			boutput(feedback, "<span class='alert'>You can't spread the blob into space.</span>")
		return 0

	if (!admin_overmind) //admins can spread wherever (within reason)
		if (istype(src,/turf/unsimulated/) && !istype(src,/turf/unsimulated/floor/shuttle))
			if (feedback)
				boutput(feedback, "<span class='alert'>You can't spread the blob onto that kind of tile.</span>")
			return 0

	if (src.density)
		if (feedback)
			boutput(feedback, "<span class='alert'>You can't spread the blob into a wall.</span>")
		return 0

	for (var/obj/O in src.contents)
		if (O.density)
			if (feedback)
				boutput(feedback, "<span class='alert'>That tile is blocked by [O].</span>")
			return 0

	if (skip_adjacent)
		return 1

	var/turf/checked
	for (var/dir in cardinal)
		checked = get_step(src, dir)
		for (var/obj/blob/B in checked.contents)
			if (B.type != /obj/blob/mutant)
				return B

	if (feedback)
		boutput(feedback, "<span class='alert'>There is no blob adjacent to this tile to spread from.</span>")

	return 0

/turf/proc/is_blob_adjacent()
	if (!src)
		return 0

	var/turf/checked
	for (var/dir in cardinal)
		checked = get_step(src, dir)
		for (var/obj/blob/B in checked.contents)
			return 1

	return 0

/turf/proc/get_blob_on_this_turf()
	if (!src)
		return null

	for (var/obj/blob/B in src.contents)
		return B

	return null

/proc/get_master_blob_controller()
	if(!processScheduler)
		return null
	for (var/datum/controller/process/blob/B in processScheduler.processes)
		return B
	return null

/proc/update_surrounding_blob_icons(var/turf/T)
	if (!istype(T))
		return
	for (var/obj/blob/B in orange(1,T))
		B.UpdateIcon()
