/obj/item/clothing/head/tinfoil_hat
	name = "tinfoil hat"
	desc = "Protects the wearer from mindcontrol and, apparently, weak martian psychic blasts which do not involve the liquification of brains."
	icon_state = "tinfoil"
	item_state = "tinfoil"

/obj/critter/martian
	name = "martian"
	desc = "Genocidal monsters from Mars."
	icon_state = "martian"
	density = 1
	health = 20
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1.5
	brutevuln = 1
	butcherable = 1
	flying = 1

	on_damaged(mob/user)
		if (src.alive && src.defensive && prob(10))
			MartianPsyblast(user)
			if (!(src in gauntlet_controller.gauntlet))
				src.visible_message("<span class='alert'><b>[src]</b> teleports away!</span>")
				CritterTeleport(8, 1, 0)

	on_pet()
		for(var/mob/O in hearers(src, null))
			O.show_message("<b>[src]</b> screeches, 'KXBQUB IJFDQVW??'", 1)


	proc/MartianPsyblast(mob/target as mob)
		for(var/mob/O in hearers(src, null))
			O.show_message("<b>[src]</b> screeches, 'GBVQW UVQWIBJZ PKDDR!!!'", 1)
		if (!ishuman(target))
			return
		playsound(target.loc, "sound/effects/ghost2.ogg", 100, 1)
		var/mob/living/carbon/human/H = target
		if (istype(H.head, /obj/item/clothing/head/tinfoil_hat))
			boutput(H, "<span class='notice'>Your tinfoil hat protects you from the psyblast!</span>")
		else
			boutput(H, "<span class='alert'>You are blasted by psychic energy!</span>")
			H.changeStatus("paralysis", 70)
			H.stuttering += 60
			H.take_brain_damage(20)
			H.TakeDamage("head", 0, 5)

	proc/CritterTeleport(var/telerange, var/dospark, var/dosmoke)
		if (!src.alive) return
		var/list/randomturfs = new/list()
		for(var/turf/T in orange(src, telerange))
			if(istype(T, /turf/space) || T.density) continue
			randomturfs.Add(T)
		src.set_loc(pick(randomturfs))
		if (dospark)
			elecflash(src)
		if (dosmoke)
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(10, 0, src.loc)
			smoke.start()
		src.task = "thinking"

/obj/critter/martian/soldier
	name = "martian soldier"
	icon_state = "martianS"
	health = 35
	aggressive = 1
	seekrange = 7

	dead
		icon_state = "martianS-dead"
		health = 0
		New()
			..()
			CritterDeath()
			icon_state = initial(icon_state)

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='alert'><b>[src]</b> shoots at [C.name]!</span>")
				playsound(src.loc, "sound/weapons/lasermed.ogg", 100, 1)
				if (prob(66))
					C.TakeDamage("chest", 0, rand(3,5)/C.get_ranged_protection())
					elecflash(C)
				else boutput(target, "<span class='alert'>The shot missed!</span>")
				src.attack = 0
				sleeping = 1
				return
			else
				continue
		task = "thinking"

/obj/critter/martian/psychic
	name = "martian mutant"
	icon_state = "martianP"
	health = 10
	aggressive = 1
	seekrange = 4
	var/gib_delay = 55
	var/do_stun = 1
	var/max_gib_distance = 6
	var/gib_counter = 0

	dead
		icon_state = "martianP-dead"
		health = 0
		New()
			..()
			CritterDeath()
			icon_state = initial(icon_state)

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='alert'><b>[src]</b> stares at [C.name]!</span>")
				playsound(src.loc, "sound/weapons/phaseroverload.ogg", 100, 1)
				boutput(C, "<span class='alert'>You feel a horrible pain in your head!</span>")
				gib_counter = 0
				if (do_stun)
					C.changeStatus("stunned", 2 SECONDS)
				SPAWN_DBG(0)
					for (var/i = 0, i <= round(gib_delay / 10), i++)
						if ((get_dist(src, C) <= max_gib_distance) && src.alive)
							if (gib_counter == gib_delay)
								C.visible_message("<span class='alert'><b>[C.name]'s</b> head explodes!</span>")
								logTheThing("combat", C, null, "was gibbed by [src] at [log_loc(src)].") // Some logging for instakill critters would be nice (Convair880).
								C.gib()
						else
							C.show_message("<span class='alert'>You no longer feel the [name]'s psychic glare.</span>")
							break
						if (gib_delay - gib_counter >= 10)
							gib_delay += 10
							sleep(1 SECOND)
						else
							var/slp = gib_delay - gib_counter
							gib_delay = gib_counter
							sleep(slp)
				src.attack = 0
				sleeping = 7
				return
			else continue

		src.task = "thinking"

/obj/critter/martian/psychic/weak
	name = "martian mutant initiate"
	gib_delay = 55
	do_stun = 0
	seekrange = 3
	max_gib_distance = 4

/obj/critter/martian/warrior
	name = "martian warrior"
	icon_state = "martianW"
	health = 35
	aggressive = 1
	seekrange = 7
	chase_text = "grabs at"


	dead
		icon_state = "martianW-dead"
		health = 0
		New()
			..()
			CritterDeath()
			icon_state = initial(icon_state)

	ChaseAttack(mob/M)
		..()
		if (prob(33)) M.changeStatus("weakened", 3 SECONDS)
		SPAWN_DBG(2.5 SECONDS)
			if (get_dist(src, M) <= 1)
				src.visible_message("<span class='alert'><B>[src]</B> starts strangling [M]!</span>")

	CritterAttack(mob/M)
		src.attacking = 1
		if (isliving(M))
			var/mob/living/H = M
			H.was_harmed(src)
		if (prob(95))
			if (prob(10))
				src.visible_message("<span class='alert'><B>[src]</B> wraps its tentacles around [M]'s neck!</span>")
			M.take_oxygen_deprivation(2)
			M.changeStatus("weakened", 1 SECOND)
		else
			src.visible_message("<span class='alert'><B>[src]'s</B> grip slips!</span>")
			M.delStatus("stunned")
			sleeping = 1
			SPAWN_DBG(1 SECOND)
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='alert'><b>[src]</b> screeches, 'KBWKB WVYPGD!!'</span>", 1)
			src.task = "thinking"
			src.attacking = 0

/obj/critter/martian/sapper
	name = "martian sapper"
	icon_state = "martianSP"
	health = 10
	aggressive = 0
	defensive = 0
	atkcarbon = 0
	atksilicon = 0
	task = "wandering"

	ai_think()
		switch(task)
			if("thinking")
				var/obj/machinery/martianbomb/B = new(src.loc)
				B.icon_state = "mbomb-timing"
				B.active = 1
				src.visible_message("<span class='alert'><B>[src]</B> plants a bomb and teleports away!</span>")
				qdel(src)
			else
				patrol_step()
				sleeping = 1

/obj/machinery/martianbomb
	name = "martian bomb"
	desc = "You'd best destroy this thing fast."
	icon = 'icons/misc/critter.dmi'
	icon_state = "mbomb-off"
	anchored = 1
	density = 1
	var/health = 100
	var/active = 0
	var/timeleft = 300

	process()
		if (src.active)
			src.icon_state = "mbomb-timing"
			src.timeleft -= 1
			if (src.timeleft <= 30) src.icon_state = "mbomb-det"
			if (src.timeleft == 0)
				explosion_new(src, src.loc, 62)
				qdel (src)
			//proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		else
			src.icon_state = "mbomb-off"

	ex_act(severity)
		if(severity)
			src.visible_message("<span class='notice'><B>[src]</B> crumbles away into dust!</span>")
			qdel (src)
		return

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		if(src.material) src.material.triggerOnBullet(src, src, P)

		if(P.proj_data.damage_type == D_KINETIC)
			if(damage >= 20)
				src.health -= damage
			else
				damage = 0
		else if(P.proj_data.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if(P.proj_data.damage_type == D_ENERGY)
			src.health -= damage
		else
			damage = 0

		if(damage >= 15)
			if (src.active && src.timeleft > 10)
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='alert'><B>[src]</B> begins buzzing loudly!</span>", 1)
				src.timeleft = 10

		if (src.health <= 0)
			src.visible_message("<span class='notice'><B>[src]</B> crumbles away into dust!</span>")
			qdel (src)

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		src.health -= W.force
		if (src.active && src.timeleft > 10)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='alert'><B>[src]</B> begins buzzing loudly!</span>", 1)
			src.timeleft = 10
		if (src.health <= 0)
			src.visible_message("<span class='notice'><B>[src]</B> crumbles away into dust!</span>")
			qdel (src)
