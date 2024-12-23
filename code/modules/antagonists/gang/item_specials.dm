
/datum/item_special/graffiti
	cooldown = 3 SECONDS
	staminaCost = 5
	moveDelay = 5
	moveDelayDuration = 5

	damageMult = 1

	image = "swipe"
	name = "Spray Burst"
	desc = "Use a burst of spray paint to harmlessly blind, deface & disorient an opponent."
	var/spray_color
	/// If true, the swipe will ignite stuff in it's reach.
	var/ignition = FALSE
	var/flipped = FALSE

	pixelaction(atom/target, list/params, mob/user, reach)
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user)) return
		if(!params["left"] || !master || !get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
			return
		preUse(user)
		var/direction = get_dir_pixel(user, target, params)
		if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
			direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

		var/list/attacked = list()

		var/turf/one = get_step(master, direction)
		var/turf/effect = get_step(one, direction)
		var/turf/two = get_step(one, turn(direction, 90))
		var/turf/three = get_step(one, turn(direction, -90))
		var/obj/itemspecialeffect/graffiti
		if (flipped)
			graffiti = new /obj/itemspecialeffect/graffiti_flipped
		else
			graffiti = new /obj/itemspecialeffect/graffiti
		flipped = !flipped
		graffiti.color = pick("#FF0000","#FF9A00","#FFFF00","#00FF78","#00FFFF","#0081DF","#CC00FF","#FFCCFF","#EBE6EB")

		graffiti.setup(effect)
		graffiti.set_dir(direction)

		for(var/turf/T in list(one, two, three))
			for(var/atom/movable/A in T)
				if(A in attacked) continue
				if(!isliving(A) || isintangible(A)) continue
				var/mob/living/loser = A
				var/tag_int = pick(1,2,3)
				var/image/tag = image('icons/effects/effects.dmi',"graffiti_mask_[tag_int]")
				tag.pixel_y = rand(-1,5)
				if (user.get_gang() && prob(30))
					var/datum/gang/usergang = user.get_gang()
					tag = image('icons/obj/decals/gang_tags.dmi', "gangtag[usergang.gang_tag]")
					tag.pixel_y = 5
					SPAWN (2 DECI SECONDS)
						playsound(A.loc, 'sound/effects/graffiti_hit.ogg', 10, TRUE)
				if (ismonkey(A))
					tag.pixel_y = tag.pixel_y - 6
				if (loser.bioHolder.HasEffect("dwarf"))
					tag.pixel_y = tag.pixel_y - 4
				tag.blend_mode = BLEND_INSET_OVERLAY
				tag.alpha = 200
				tag.color = graffiti.color
				tag.appearance_flags = KEEP_TOGETHER
				A.setStatus("graffiti_blind", 8 SECONDS)
				var/datum/statusEffect/graffiti/status = A.hasStatus("graffiti_blind")
				A.UpdateOverlays(tag,"graffitisplat[length(status.tag_images)+1]")
				status.tag_images += tag

				hit_twitch(A)
				if (ishuman(A) && prob(40))
					var/mob/living/carbon/human/victim = A
					victim.emote("cough")
				attacked += A

		afterUse(user)
		playsound(master, 'sound/items/graffitispray3.ogg', 50, TRUE)



/datum/item_special/massacre
	cooldown = 2 SECONDS
	staminaCost = 0
	moveDelay = 5
	moveDelayDuration = 10
	damageMult = 1
	image = "dagger"
	name = "Butcher"
	desc = "Repeatedly attack a target. Deals more damage and costs more stamina for every hit landed."

	var/current_chain = 0
	/// Maximum number of hits
	var/max_chain = 10
	/// Damage multiplier, initial
	var/damage_mult_start = 0.4
	/// Damage multiplier increase per chain
	var/damage_mult_increment = 0.075
	///Stamina cost per extra swing
	var/staminacost_chain = 0
	///Stamina cost increase per extra swing
	var/staminacost_chain_additive = 5
	///Disorient and drain stamina when interrupted
	var/penalty_disorient = TRUE
	var/alternate = FALSE
	onAdd()
		if(master)
			overrideStaminaDamage = master.stamina_damage * 0.8

	pixelaction(atom/target, params, mob/user, reach)
		damageMult = damage_mult_start
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user) || !isliving(user)) return

		var/mob/living/H = user
		if(!params["left"] || !master || !get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
			return
		preUse(user)
		current_chain = 0
		var/direction = get_dir_pixel(user, target, params)
		var/turf/turf = get_step(master, direction)

		var/obj/itemspecialeffect/cleave/cleave_effect = new /obj/itemspecialeffect/cleave
		cleave_effect.set_dir(direction)
		cleave_effect.setup(turf)
		alternate = TRUE
		var/hit = FALSE
		for(var/atom/A in turf)
			if(isTarget(A))
				A.Attackby(master, user, params, TRUE)
				hit = TRUE
				break
		if (!hit)
			playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, FALSE, 0.1, 1.4)

		while (hit && H.stamina > (staminacost_chain + staminacost_chain_additive*current_chain) && H.equipped() == master && current_chain < max_chain)
			H.next_click = world.time + 5 SECONDS
			last_use = world.time
			current_chain++
			H.remove_stamina(staminacost_chain + staminacost_chain_additive*current_chain)
			if (current_chain == 13)
				sleep(0.2 SECONDS)
				var/string ="[H] raises the machete up high!"
				H.show_message(SPAN_ALERT(string), 1, assoc_maptext = make_chat_maptext(H, "<I>[string]</I>", "color: #C2BEBE;", alpha = 140))
				sleep(2 SECONDS)
				damageMult = 5
			else if (current_chain == 3)
				sleep(0.2 SECONDS)
				user.emote("twirl")
				sleep(1.4 SECONDS)
				damageMult = damage_mult_start+(current_chain*damage_mult_increment)
			else if (current_chain < 3)
				damageMult = damage_mult_start+(current_chain*damage_mult_increment)
				sleep(rand(7,9) DECI SECONDS)
			else
				sleep(rand(4,6) DECI SECONDS)
			turf = get_step(master, direction)
			if (alternate)
				cleave_effect = new/obj/itemspecialeffect/cleave_flipped
			else
				cleave_effect = new/obj/itemspecialeffect/cleave
			alternate = !alternate
			cleave_effect.set_dir(direction)
			cleave_effect.setup(turf)
			if (prob(10) && current_chain > 3)
				user.emote(pick("laugh","cackle","grin"))

			hit = 0
			for(var/atom/A as anything in turf)
				if(isTarget(A))
					A.Attackby(master, user, params, TRUE)
					hit = TRUE
					break
			if (!hit)
				playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, FALSE, 0.1, 1.4)

		if (current_chain > 3 && current_chain < max_chain && penalty_disorient) // penalise getting interrupted after the third swing
			var/string ="[H] swings their machete too hard and loses their balance!"
			H.show_message(SPAN_ALERT(string), 1)
			H.do_disorient(H.get_stamina(), 0, 0, 0, 4 SECONDS, FALSE)
		afterUse(user)

	afterUse(mob/user)
		last_use = world.time
		user.next_click = world.time + 5 SECONDS
		..()

	modify_attack_result(mob/user, mob/target, datum/attackResults/msgs) //bleed on crit!
		if (msgs.damage > 0 && (msgs.stamina_crit || current_chain > 3))
			msgs.bleed_always = TRUE
			var/slash_flipped = (current_chain%2) * 180
			var/blood_dir = angle2dir(get_angle(user,target)+90 - slash_flipped)
			blood_slash(target,1,null, blood_dir, 3)
			if (current_chain > 3)
				msgs.played_sound= pick('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Slimy_Splat_1.ogg')
		return msgs

	slasher
		name = "Massacre"
		desc = "Repeatedly attack a target. Decapitate if left uninterrupted."
		max_chain = 13
		staminacost_chain_additive = 0
		damage_mult_start = 0.6
		damage_mult_increment = 0.1
		penalty_disorient = FALSE
		modify_attack_result(mob/user, mob/target, datum/attackResults/msgs)
			..()
			if (msgs.damage > 0 && isliving(target))
				var/mob/living/carbon/human/H = target
				var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
				var/the_limb = null
				if (current_chain > 10 && current_chain < 13)
					msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_2.ogg'
					if (user.zone_sel.selecting in limbs)
						the_limb = user.zone_sel.selecting
					else
						the_limb = pick("l_arm","r_arm","l_leg","r_leg")

					if (the_limb)
						H.sever_limb(the_limb)
				else if (current_chain == 13)
					msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_2.ogg'
					H.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1)
					user.emote("laugh")
			return msgs

