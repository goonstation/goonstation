/datum/targetable/spell/iceburst
	name = "Ice Burst"
	desc = "Launches freezing bolts at nearby foes."
	icon_state = "iceburst"
	targeted = 0
	cooldown = 200
	requires_robes = 1
	requires_being_on_turf = TRUE
	offensive = 1
	voice_grim = 'sound/voice/wizard/IceBurstGrim.ogg'
	voice_fem = 'sound/voice/wizard/IceBurstFem.ogg'
	voice_other = 'sound/voice/wizard/IceBurstLoud.ogg'
	maptext_colors = list("#55eec2", "#62a5ee", "#3c6dc3", "#12135b", "#3c6dc3", "#62a5ee")

	cast()
		if(!holder)
			return
		var/count = 0
		var/count2 = 0
		var/moblimit = 3

		for(var/mob/living/M as mob in oview())
			if(isdead(M)) continue
			count2++
		if(!count2)
			boutput(holder.owner, "No one is in range!")
			return 1

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("NYTH ERRIN", FALSE, maptext_style, maptext_colors)
		..()

		if(!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, SPAN_ALERT("Your spell is weak without a staff to focus it!"))

		for (var/mob/living/M as mob in oview())
			if(isdead(M)) continue
			if (ishuman(M))
				if (M.traitHolder.hasTrait("training_chaplain"))
					boutput(holder.owner, SPAN_ALERT("[M] has divine protection! The spell refuses to target [him_or_her(M)]!"))
					JOB_XP(M, "Chaplain", 2)
					continue
			if (iswizard(M))
				boutput(holder.owner, SPAN_ALERT("[M] has arcane protection! The spell refuses to target [him_or_her(M)]!"))
				continue
			else if(check_target_immunity( M ))
				boutput(holder.owner, SPAN_ALERT("[M] seems to be warded from the effects!") )
				continue

			playsound(holder.owner.loc, 'sound/effects/mag_iceburstlaunch.ogg', 25, 1, -1)
			if ((!holder.owner.wizard_spellpower(src) && count >= 1) || (count >= moblimit)) break
			count++
			SPAWN(0)
				var/obj/overlay/A = new /obj/overlay( holder.owner.loc )
				A.icon_state = "icem"
				A.icon = 'icons/obj/wizard.dmi'
				A.name = "ice bolt"
				A.anchored = UNANCHORED
				A.set_density(0)
				A.layer = MOB_EFFECT_LAYER
				//A.sd_SetLuminosity(3)
				//A.sd_SetColor(0, 0.1, 0.8)
				var/i
				for(i=0, i<20, i++)
					if (holder.owner.wizard_spellpower(src))
						if (!locate(/obj/decal/icefloor) in A.loc)
							var/obj/decal/icefloor/B = new /obj/decal/icefloor(A.loc)
							//B.sd_SetLuminosity(1)
							//B.sd_SetColor(0, 0.1, 0.8)
							SPAWN(20 SECONDS)
								qdel (B)
					step_to(A,M,0)
					if (GET_DIST(A,M) == 0)
						boutput(M, SPAN_NOTICE("You are chilled by a burst of magical ice!"))
						M.visible_message(SPAN_ALERT("[M] is struck by magical ice!"))
						playsound(holder.owner.loc, 'sound/effects/mag_iceburstimpact.ogg', 25, 1, -1)
						M.bodytemperature = 0
						M.lastattacker = get_weakref(holder.owner)
						M.lastattackertime = world.time
						qdel(A)
						if(prob(40))
							M.visible_message(SPAN_ALERT("[M] is frozen solid!"))
							new /obj/icecube(M.loc, M)
						return
					sleep(0.5 SECONDS)
				qdel(A)

// /obj/decal/icefloor moved to decal.dm

/obj/icecube
	name = "ice cube"
	desc = "That is a surprisingly large ice cube."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "icecube"
	density = 1
	layer = EFFECTS_LAYER_BASE
	var/health = 10
	var/steam_on_death = 1
	var/add_underlay = 1

	/// the temperature the cube will try to cool you to. changing this allows you to more aggressively cool
	var/cooltemp = T0C
	/// the temperature the cube will start taking damage at
	var/melttemp = T0C

	var/does_cooling = TRUE

	var/mob/held_mob

	New(loc, mob/iced as mob)
		..()
		if(iced && !isAI(iced) && !isblob(iced) && !iswraith(iced))
			if(istype(iced.loc, /obj/icecube)) //Already in a cube?
				qdel(src)
				return

			iced.set_loc(src)
			src.held_mob = iced

			if (add_underlay)
				src.underlays += iced
			boutput(iced, SPAN_ALERT("You are trapped within [src]!")) // since this is used in at least two places to trap people in things other than ice cubes

		if (istype(iced, /mob/living/critter/ice_phoenix))
			qdel(src)
			return

		if (iced) //apparently a blank ice cube spawns in adventure
			iced.last_cubed = world.time

		src.health *= (rand(10,20)/10)

		if (src.does_cooling)
			for(var/mob/M in src)
				if (!ishuman(M)) // bodytemp loop handles it for humans
					src.RegisterSignal(M, COMSIG_LIVING_LIFE_TICK, PROC_REF(PassiveCool))

	disposing()
		processing_items.Remove(src)
		for(var/atom/movable/AM in src)
			if(ismob(AM))
				var/mob/M = AM
				M.visible_message(SPAN_ALERT("<b>[M]</b> breaks out of [src]!"),SPAN_ALERT("You break out of [src]!"))
				M.last_cubed = world.time
				UnregisterSignal(M, COMSIG_LIVING_LIFE_TICK)
			AM.set_loc(src.loc)

		if (steam_on_death)
			if (!(locate(/datum/effects/system/steam_spread) in src.loc))
				var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
				steam.set_up(10, 0, get_turf(src))
				steam.attach(src)
				steam.start(clear_holder=1)
		if (src.hasStatus("cold_snap") && !istype(get_area(src), /area/phoenix_nest))
			src.held_mob.changeStatus("cold_snap", 5 SECONDS)
		src.held_mob = null
		..()

	relaymove(mob/user as mob)
		if (user.stat)
			return

		if(prob(25))
			takeDamage(1)
		return

	proc/takeDamage(var/damage)
		src.health -= damage
		if(src.health <= 0)
			qdel(src)
			return
		else
			var/wiggle = 3
			while(wiggle > 0)
				wiggle--
				src.pixel_x = rand(-2,2)
				src.pixel_y = rand(-2,2)
				sleep(0.5)
			src.pixel_x = 0
			src.pixel_y = 0

	proc/PassiveCool(var/mob/M, mult)
		if(M.bodytemperature >= src.cooltemp)
			M.bodytemperature = max(M.bodytemperature - (20 * mult),src.cooltemp)
		if(M.bodytemperature > src.melttemp)
			takeDamage(1 * mult)

	attack_hand(mob/user)
		user.visible_message(SPAN_COMBAT("<b>[user]</b> kicks [src]!"), SPAN_NOTICE("You kick [src]."))
		takeDamage(2)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/2)*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if(D_KINETIC)
				takeDamage(damage*2)
			if(D_PIERCING)
				takeDamage(damage/2)
			if(D_ENERGY)
				takeDamage(damage/4)

	attackby(obj/item/W, mob/user)
		takeDamage(W.force)

	mob_flip_inside(var/mob/user)
		..(user)
		user.show_text(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]."))
		src.takeDamage(6)

	ex_act(severity)
		for(var/atom/A in src)
			A.ex_act(severity)
		SPAWN(0)
			takeDamage(20 / severity)
		..()

/obj/icecube/spider
	name = "bundle of web"
	desc = "A big wad of web. Someone seems to be stuck inside it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "web2"
	steam_on_death = FALSE
	does_cooling = FALSE

	clown
		name = "bundle of cotton candy"
		desc = "What the fuck spins webs out of - y'know what, scratch that. You don't want to find out."
		icon = 'icons/effects/effects.dmi'
		icon_state = "candyweb2"

