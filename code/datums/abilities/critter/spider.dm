// -----------------
// Spider bite skill
// -----------------
/datum/targetable/critter/spider_bite
	name = "Bite"
	desc = "Bite a mob, doing a little damage and injecting them with your venom. (You do have venom, don't you?)"
	icon_state = "clown_spider_bite"
	cooldown = 200
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
				boutput(holder.owner, __red("Nothing to bite there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to bite."))
			return 1
		var/mob/MT = target
		var/mob/living/critter/spider/S = holder.owner
		MT.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_BLUNT)
		MT.changeStatus("stunned", 2 SECONDS)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>",\
		"<span class='combat'><b>You bite [MT]!</b></span>")
		if (istype(S))
			S.venom_bite(MT)
		else // no venom, very sad
			playsound(get_turf(holder.owner), "sound/weapons/handcuffs.ogg", 50, 1, pitch = 1.6)
			if (issilicon(MT))
				var/mob/living/silicon/robot/R = MT
				R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(2,4))
			else
				MT.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_STAB)
		return 0

/datum/targetable/critter/spider_bite/cluwne
	icon_state = "cluwne_spider_bite"

// -----------------
// Spider flail skill
// -----------------
/datum/targetable/critter/spider_flail
	name = "Flail"
	desc = "Flail at a mob, stunning them and injecting them with your venom. (You do have venom, don't you?)"
	cooldown = 300
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (disabled && world.time > last_cast)
			disabled = 0 // break the deadlock
		if (disabled)
			return 1
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/M in target)
				if (M != src && M.getStatusDuration("weakened"))
					target = M
					break
			if (!ismob(target))
				boutput(holder.owner, __red("Nothing to flail at there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to flail at."))
			return 1
		var/mob/MT = target
		var/mob/living/critter/spider/S = holder.owner
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] dives on [MT]!</b></span>",\
		"<span class='combat'><b>You dive on [MT]!</b></span>")
		playsound(get_turf(holder.owner), "sound/impact_sounds/Generic_Shove_1.ogg", 50, 0, pitch = 1.6)
		MT.TakeDamageAccountArmor("All", rand(4,10), 0, 0, DAMAGE_STAB)
		if (!isdead(MT))
			MT.emote("scream")
		disabled = 1
		SPAWN_DBG(0)
			var/flail = rand(10, 15)
			holder.owner.canmove = 0
			while (flail > 0 && MT && !MT.disposed)
				MT.changeStatus("weakened", 2 SECONDS)
				MT.canmove = 0
				if (MT.loc)
					holder.owner.set_loc(MT.loc)
				if (holder.owner.getStatusDuration("stunned") || holder.owner.getStatusDuration("weakened") || holder.owner.getStatusDuration("paralysis"))
					break
				if (istype(S))
					S.venom_bite(MT)
				else // no venom, very sad
					playsound(get_turf(holder.owner), "sound/weapons/handcuffs.ogg", 50, 1)
					if (issilicon(MT))
						var/mob/living/silicon/robot/R = MT
						R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(2,4))
					else
						MT.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_STAB)
				if (prob(30))
					holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>",\
					"<span class='combat'><b>You bite [MT]!</b></span>")
				holder.owner.dir = pick(cardinal)
				holder.owner.pixel_x = rand(-2,2) * 2
				holder.owner.pixel_y = rand(-2,2) * 2
				sleep(0.4 SECONDS)
				flail--
			if (MT)
				MT.canmove = 1
			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1

// -----------------
// Spider drain skill
// -----------------
/datum/targetable/critter/spider_drain
	name = "Drain"
	desc = "Drain a dead human."
	icon_state = "clown_spider_drain"
	cooldown = 300
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (disabled && world.time > last_cast)
			disabled = 0 // break the deadlock
		if (disabled)
			return 1
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/carbon/human/H in target)
				if (isdead(H))
					target = H
					break
			if (!ishuman(target))
				boutput(holder.owner, __red("Nothing to drain there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to drain."))
			return 1
		var/mob/living/carbon/human/H = target
		var/mob/living/critter/spider/S = holder.owner
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] starts draining the fluids out of [H]!</b></span>",\
		"<span class='combat'><b>You start draining the fluids out of [H]!</b></span>")
		playsound(get_turf(holder.owner), "sound/misc/pourdrink.ogg", 50, 0, pitch = 0.7)
		disabled = 1
		SPAWN_DBG(0)
			var/drain = rand(65, 75)
			holder.owner.set_loc(H.loc)
			holder.owner.canmove = 0
			while (drain > 0 && H && H.stat && !H.disposed)
				if (H.loc && holder.owner.loc != H.loc)
					break
				if (holder.owner.getStatusDuration("stunned") || holder.owner.getStatusDuration("weakened") || holder.owner.getStatusDuration("paralysis"))
					break
				holder.owner.HealDamage("All", 1, 1)
				sleep(0.4 SECONDS)
				drain--
			if (H && H.stat && holder.owner.loc == H.loc)
				holder.owner.visible_message("<span class='combat'><b>[src] drains [H] dry!</b></span>",\
				"<span class='combat'><b>You drain [H] dry!</b></span>")
				H.death(0)
				H.real_name = "Unknown"
				if (H.bioHolder)
					H.bioHolder.AddEffect("husk")
				playsound(get_turf(holder.owner), "sound/misc/fuse.ogg", 50, 1)
				holder.owner.set_loc(get_step(holder.owner, pick(alldirs)))
				SPAWN_DBG(0)
					var/obj/icecube/cube = new /obj/icecube(get_turf(H), H)
					H.set_loc(cube)
					if (istype(S))
						switch (S.encase_in_web)
							if (2)
								holder.owner.visible_message("<span class='combat'><b>[holder.owner] encases [H] in cotton candy!</b></span>",\
								"<span class='combat'><b>You encase [H] in cotton candy!</b></span>")
								cube.name = "bundle of cotton candy"
								cube.desc = "What the fuck spins webs out of - y'know what, scratch that. You don't want to find out."
								cube.icon_state = "candyweb2"
								cube.steam_on_death = 0

							if (1)
								holder.owner.visible_message("<span class='combat'><b>[holder.owner] encases [H] in web!</b></span>",\
								"<span class='combat'><b>You encase [H] in web!</b></span>")
								cube.name = "bundle of web"
								cube.desc = "A big wad of web. Someone seems to be stuck inside it."
								cube.icon_state = "web2"
								cube.steam_on_death = 0

							if (0)
								holder.owner.visible_message("<span class='combat'><b>[holder.owner] encases [H] in ice!</b></span>",\
								"<span class='combat'><b>You encase [H] in ice!</b></span>")

				if (istype(S) && S.babyspider)
					SPAWN_DBG(0)
						S.grow_up()

			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1

/datum/targetable/critter/spider_drain/cluwne
	icon_state = "cluwne_spider_drain"

// -----------------
// Baby clownspider kick
// -----------------
/datum/targetable/critter/clownspider_kick // for clown/cluwnespiders
	name = "Kick"
	desc = "Kick a mob, doing a little damage and possibly causing a short stun."
	cooldown = 100
	targeted = 1
	target_anything = 1
	var/sound/sound_kick = 'sound/musical_instruments/Bikehorn_1.ogg'

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to kick there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to kick."))
			return 1
		var/mob/MT = target
		MT.TakeDamageAccountArmor("All", rand(1,5), 0, 0, DAMAGE_BLUNT)
		MT.changeStatus("stunned", 2 SECONDS)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] kicks [MT]!</b></span>", "<span class='combat'>You kick [MT]!</span>")
		playsound(get_turf(holder.owner), "swing_hit", 30, 0)
		if (prob(10))
			playsound(get_turf(holder.owner), src.sound_kick, 50, 0)
		return 0

/datum/targetable/critter/clownspider_kick/cluwne
	sound_kick = 'sound/voice/cluwnelaugh3.ogg'


// -----------------
// Queen clownspider kick fiesta
// -----------------

/datum/targetable/critter/clownspider_trample
	name = "Trample"
	desc = "Kick the SHIT out of a mob with all eight legs."
	icon_state = "clown_spider_trample"
	cooldown = 300
	targeted = 1
	target_anything = 1
	var/sound/sound_kick = "clownstep"

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (disabled && world.time > last_cast)
			disabled = 0 // break the deadlock
		if (disabled)
			return 1
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/M in target)
				if (M != src && M.getStatusDuration("weakened"))
					target = M
					break
			if (!ismob(target))
				boutput(holder.owner, __red("Nothing to trample there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to trample."))
			return 1
		var/mob/MT = target
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] pounces on top of [MT]!</b></span>",\
		"<span class='combat'><b>You pounce onto [MT]!</b></span>")
		playsound(get_turf(holder.owner), "sound/impact_sounds/Generic_Shove_1.ogg", 50, 0)
		MT.TakeDamageAccountArmor("All", rand(4,10), 0, 0, DAMAGE_STAB)
		if (!isdead(MT))
			MT.emote("scream")
		disabled = 1
		SPAWN_DBG(0)
			var/flail = 8
			holder.owner.canmove = 0
			while (flail > 0 && MT && !MT.disposed)
				MT.changeStatus("weakened", 2 SECONDS)
				MT.canmove = 0
				if (MT.loc)
					holder.owner.set_loc(MT.loc)
				MT.changeStatus("stunned", 1 SECOND)
				if (holder.owner.getStatusDuration("stunned") || holder.owner.getStatusDuration("weakened") || holder.owner.getStatusDuration("paralysis"))
					break
				playsound(get_turf(holder.owner), "sound/impact_sounds/flesh_break_1.ogg", 50, 1)
				playsound(get_turf(holder.owner), src.sound_kick, 50, 1)
				if (issilicon(MT))
					var/mob/living/silicon/robot/R = MT
					R.compborg_take_critter_damage("[pick("l","r")]_[pick("arm","leg")]", rand(4,7))
				else
					MT.TakeDamageAccountArmor("All", rand(5,8), 0, 0, DAMAGE_STAB)
				holder.owner.visible_message("<span class='combat'><b>[holder.owner] stomps on [MT]!</b></span>",\
				"<span class='combat'><b>You stomp on [MT]!</b></span>")
				holder.owner.dir = pick(cardinal)
				holder.owner.pixel_x = rand(-2,2) * 2
				holder.owner.pixel_y = rand(-2,2) * 2
				sleep(0.4 SECONDS)
				flail--
			if (MT)
				MT.canmove = 1
			doCooldown()
			disabled = 0
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			holder.owner.canmove = 1


/datum/targetable/critter/clownspider_trample/cluwne
	sound_kick = "cluwnestep"
	icon_state = "cluwne_spider_trample"

/datum/targetable/critter/vomitegg
	name = "Vomit Egg"
	desc = "Lay Egg is True. Horribly, horribly true."
	icon_state = "clown_spider_egg"
	cooldown = 150
	targeted = 1
	target_anything = 1
	var/egg_path = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/clown
	var/flavor_text = "clown"

	cast(atom/T)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/ammo = new egg_path(holder.owner.loc)
		ammo.parent = holder.owner
		ammo.throw_at(T, 32, 2)
		doCooldown()

		if (istype(holder.owner, /mob/living/critter/spider/clownqueen))
			var/mob/living/critter/spider/clownqueen/queen = holder.owner
			if (islist(queen.babies) && queen.babies.len > queen.max_defensive_babies)
				boutput(queen, "<span class='alert'><b>You make a new baby, but know in your [flavor_text] heart that it does not love you.</b></span>")


/datum/targetable/critter/vomitegg/cluwne
	icon_state = "cluwne_spider_egg"
	egg_path = /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/cluwne
	flavor_text = "cluwne"
