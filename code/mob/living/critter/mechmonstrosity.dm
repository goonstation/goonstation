/mob/living/critter/mechmonstrosity
	name = "Mechanical Monstrosity"
	real_name = "mechmonstrosity"
	desc = "A severely disfigured human torso which is forcibly kept alive by the mechanical parts.."
	density = 1
	icon = 'icons/misc/critter.dmi'
	icon_state = "mechmonstrosity"
	custom_gib_handler = /proc/robogibs
	blood_id = "oil"
	hand_count = 0
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	can_help = 0
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"

	setup_healths()
		add_hh_robot(100, 1)
		add_hh_robot_burn(100, 1)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/suffocation)
		var/datum/healthHolder/Brain = add_health_holder(/datum/healthHolder/brain)
		Brain.maximum_value = 0
		Brain.value = 0
		Brain.minimum_value = -250
		Brain.depletion_threshold = -100
		Brain.last_value = 0

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/slam)
		abilityHolder.updateButtons()

	death(var/gibbed)
		if (!gibbed)
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			gibs(src.loc)
			ghostize()
			qdel(src)
		else
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/screams/robot_scream.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

/mob/living/critter/mechmonstrosity/suffering

	Life(datum/controller/process/mobs/parent)
		. = ..()
		var/speech_type = rand(1,50)

		switch(speech_type)
			if(1)
				boutput(src,pick("<span class='alert'><b>You feel terrible.</b></span>","<span class='alert'><b>You are in severe agony. Why do they torture you like this!?</b></span>","<span class='alert'><b>You wish you could just die already but your augmentations keep you alive.</b></span>",))
			if(2)
				src.emote("scream")
			if(3)
				boutput(src,"<b>You hear a voice in your head... <i>Your suffering amuses me, insect.</i></b>")
			if(4)
				boutput(src,"<b>You hear a voice in your head... <i>I have cured your curse of the flesh, insect. You should be most grateful.</i></b>")
			if(5)
				src.emote("fart")

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/killme.ogg', 70, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> begs for mercy!"

/mob/living/critter/mechmonstrosity/medical
	icon_state = "mechmonstrosity_m"
	name = "V.I.V.I-SECT-10N"
	real_name = "V.I.V.I-SECT-10N"
	desc = "You better wish that apples will keep this thing away from you.."
	hand_count = 2
	var/smashes_shit = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "Syringe Injector"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "syringegun"				// the icon state of the hand UI background
		HH.limb_name = "Injector"					// name for the dummy holder
		HH.limb = new /datum/limb/gun/syringe	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[2]
		HH.name = "Dual Saw"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "saw"				// the icon state of the hand UI background
		HH.limb_name = "Dual Saw"					// name for the dummy holder
		HH.limb = new /datum/limb/dualsaw	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0
		HH.can_attack = 1

	bump(atom/movable/AM)
		if(smashes_shit)
			if(isobj(AM))
				if (istype(AM, /obj/critter) || istype(AM, /obj/machinery/vehicle))
					return
				if(istype(AM, /obj/window))
					var/obj/window/W = AM
					W.health = 0
					W.smash()
				else if(istype(AM,/obj/grille))
					var/obj/grille/G = AM
					G.damage_blunt(30)
				else if(istype(AM, /obj/table))
					AM.meteorhit()
				else if(istype(AM, /obj/foamedmetal))
					AM.dispose()
				else
					AM.meteorhit()
				playsound(src.loc, 'sound/effects/exlow.ogg', 70,1)
				src.visible_message("<span class='alert'><B>[src]</B> smashes through \the [AM]!</span>")
		..()

	setup_healths()
		add_hh_robot(500, 1)
		add_hh_robot_burn(500, 1)

	death(var/gibbed)
		. = ..()
		src.visible_message("<b>[src]</b> collapses into broken components...")
		if (src.loc)
			robogibs(src.loc)
		new /obj/item/disk/data/floppy/read_only/replicants1(src.loc)
		ghostize()
		qdel(src)

	New()
		..()
		abilityHolder.addAbility(/datum/targetable/critter/inject)
		abilityHolder.addAbility(/datum/targetable/critter/scarylook)
		abilityHolder.addAbility(/datum/targetable/critter/mechanimate)
		abilityHolder.addAbility(/datum/targetable/critter/dissect)
		abilityHolder.updateButtons()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("laugh")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/mechmonstrositylaugh.ogg' , 80, 1, channel=VOLUME_CHANNEL_EMOTE)

/datum/targetable/critter/inject
	name = "Inject Corrupted Nanites"
	desc = "Transfer corrupted nanites into your target."
	icon_state = "inject"
	var/stealthy = 0
	var/venom_id = "corruptnanites"
	var/inject_amount = 10
	cooldown = 600
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to inject there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to inject.</span>")
			return 1
		var/mob/MT = target
		if (!MT.reagents)
			boutput(holder.owner, "<span class='alert'>That does not hold reagents, apparently.</span>")
		if (!stealthy)
			playsound(holder.owner.loc, 'sound/items/hypo.ogg', 70,1)
			holder.owner.visible_message("<span class='alert'><b>[holder.owner] injects [target]!</b></span>")
		else
			holder.owner.show_message("<span class='notice'>You stealthily inject [target].</span>")
		MT.reagents.add_reagent(venom_id, inject_amount)


/datum/targetable/critter/scarylook
	name = "Terrifying glare"
	desc = "Stuns one target for a short time."
	icon_state = "evilstare"
	targeted = 1
	target_nodamage_check = 1
	max_range = 14
	cooldown = 600

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to stun yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (target.stat == 2)
			boutput(M, "<span class='alert'>It would be a waste of time to stun the dead.</span>")
			return 1

		M.visible_message("<span class='alert'><B>[M] glares angrily at [target]!</B></span>")
		target.apply_flash(5, 5)
		boutput(target, "<span class='alert'>You can feel a chill running down your spine as [M] glares at you with hatred burning in their  mechanical eyes.</span>")
		target.emote("shiver")

		logTheThing(LOG_COMBAT, M, "uses glare on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0

/datum/action/bar/icon/mechanimateAbility
	duration = 80
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "mechanimate"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "turn_over"
	var/mob/living/target
	var/datum/targetable/critter/mechanimate/mechanimate

	New(Target, Mechanimate)
		target = Target
		mechanimate = Mechanimate
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !mechanimate || !mechanimate.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !mechanimate || !mechanimate.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to inject [target]!</B></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(ownerMob && target && (BOUNDS_DIST(owner, target) == 0) && mechanimate?.cooldowncheck())
			logTheThing(LOG_COMBAT, ownerMob, "injects [constructTarget(target,"combat")]. Crawler transformation")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><B>[owner] successfully injected [target]!</B></span>", 1)
			playsound(ownerMob, 'sound/items/hypo.ogg', 80, 0)

			var/obj/critter/mechmonstrositycrawler/FUCK = new /obj/critter/mechmonstrositycrawler(get_turf(target))
			FUCK.CustomizeMechMon(target.real_name, ismonkey(target))

		for(var/obj/item/I in target)
			if(isitem(target))
				target.u_equip(I)
				if(I)
					I.set_loc(target.loc)
					I.dropped(target)
		target.gib(1)

		mechanimate.actionFinishCooldown()

/datum/targetable/critter/mechanimate
	name = "Mechanically Animate"
	desc = "After a short delay, convert a human corpse into a crawler."
	cooldown = 0
	var/actual_cooldown = 200
	icon_state = "pet"
	targeted = 1
	target_anything = 1

	proc/actionFinishCooldown()
		cooldown = actual_cooldown
		doCooldown()
		cooldown = initial(cooldown)

	cast(mob/target)
		var/mob/living/M = holder.owner

		if(!isdead(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>You can't do that to yourself.</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1
		holder.owner.say("Transformation protocol engaged. Please stand clear of the recipient.")
		actions.start(new/datum/action/bar/icon/mechanimateAbility(target, src), holder.owner)
		return 0

/datum/targetable/critter/dissect
	name = "Dissect"
	desc = "Removes ALL of the targets limbs."
	icon_state = "dissect"
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 600

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/mob/living/carbon/human/H = target

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to dissect yourself?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		M.visible_message("<span class='alert'><B>With their double saw whirling, [M] swiftly severs all [target]'s limbs!</B></span>")
		H.sever_limb("r_arm")
		H.sever_limb("l_arm")
		H.sever_limb("r_leg")
		H.sever_limb("l_leg")
		playsound(M.loc, 'sound/effects/sawhit.ogg', 90,1)
		boutput(target, "<span class='alert'>All of your limbs were severed by [M]!</span>")

		logTheThing(LOG_COMBAT, M, "uses dissect on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0

/datum/projectile/syringefilled
	name = "syringe"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "syringeproj"
	dissipation_rate = 1
	dissipation_delay = 7
	damage = 1
	hit_ground_chance = 10
	shot_sound = 'sound/effects/syringeproj.ogg'
	var/venom_id = "corruptnanites"
	var/inject_amount = 15

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if (ismob(hit))
			if (hit.reagents)
				hit.reagents.add_reagent( venom_id, inject_amount)


/datum/computer/file/record/replicants

	Profound_Medical01
		name = "Profound_Medical01"

		New()
			..()
			fields = strings("replicant/replicant_records.txt","Profound_Medical01")
			/*list("Despite our best efforts to correct the irrational",
					"behaviour in our V.I.V.I-SECT-10N model,",
					"we haven't managed reduce it's eagerness to dissect",
					"any organism that it comes across, be it alive or dead.",
					"We are slowly running out of time with this project",
					"and in general it is not showing the great promise",
					"that we expected out of it. I think it would be much",
					"wiser for us to focus on D.O.C as they seem to be more",
					"promising, despite their unexplainable fascination with different",
					"body parts. Anyway, someone ought to haul V.I.V.I-SECT-10N to a",
					"secure storage facility until we figure out what to",
					"do with it.")*/

	Profound_Medical02
		name = "Profound_Medical02"

		New()
			..()
			fields = strings("replicant/replicant_records.txt","Profound_Medical02")
			/*list("Fucking hell.. How am I going to explain to anyone that",
					"a bunch of rogue robots broke into our storage facility",
					"and made an escape while dragging the V.I.V.I-SECT-10N ",
					"model with them? Nobody is going to believe that..",
					"Well, whatever. Good riddance, I know that I certainly",
					"won't miss working on that model,",
					"hopefully it won't cause any",
					"harm to anyone else, wherever it might end up.")*/

/obj/item/disk/data/floppy/read_only/replicants1
	name = "data disk-'Profound Medical'"
	desc = "Huh, was this disk inside that creepy robot?"
	title = "Profound Medical"

	New()
		..()
		src.root.add_file( new /datum/computer/file/record/replicants/Profound_Medical01 {name = "Profound_Medical01";} (src))
		src.root.add_file( new /datum/computer/file/record/replicants/Profound_Medical02 {name = "Profound_Medical02";} (src))
		src.read_only = 1

/obj/critter/mechmonstrositycrawler
	name = "Crawling Monstrosity"
	desc = "A crawling mechanical monstrosity."
	icon_state = "mechmonstrosity_c"
	dead_state = "mechmonstrosity_c-dead"
	density = 1
	health = 40
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.25
	brutevuln = 0.5
	var/revivalChance = 0 // Chance to revive when killed, out of 100. Wizard spell will set to 100, defaults to 0 because skeletons appear in telesci/other sources
	var/revivalDecrement = 16 // Decreases revival chance each successful revival. Set to 0 and revivalChance=100 for a permanently reviving skeleton

	New()
		..()
		playsound(src.loc, 'sound/effects/glitchy1.ogg', 50, 0)

	seek_target()

		if (!src.alive) return
		var/mob/living/Cc
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (ismobcritter(C))  continue //do not attack our master
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (isdead(C)) continue
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1
			Cc = C

		if (src.attack)
			src.target = Cc
			src.oldtarget_name = Cc.name
			src.visible_message("<span class='combat'><b>[src]</b> crawls towards [Cc.name]!</span>")
			playsound(src.loc, 'sound/effects/glitchy1.ogg', 50, 0)
			src.task = "chasing"
			return

	proc/CustomizeMechMon(var/NM, var/is_monkey)
		src.name = "[NM]'s crawling head"
		src.desc = "A horrible crawling monstrosity, ravaged from the corpse of [NM]."
		src.revivalChance = 100

		if (is_monkey)
			icon = 'icons/mob/monkey.dmi'

		return

	ChaseAttack(mob/M)
		if (!src.alive) return
		M.visible_message("<span class='combat'><B>[src]</B> bashes [src.target]!</span>")
		playsound(M.loc, "punch", 25, 1, -1)
		random_brute_damage(M, rand(5,10),1)
		if(prob(15)) // too mean before
			M.visible_message("<span class='combat'><B>[M]</B> staggers!</span>")
			M.changeStatus("stunned", 2 SECONDS)
			M.changeStatus("weakened", 2 SECONDS)

	CritterAttack(mob/M)
		if (!src.alive) return
		src.attacking = 1
		if(!M.stat)
			M.visible_message("<span class='combat'><B>[src]</B> scratches [src.target] mercilessly!</span>")
			playsound(src.loc, 'sound/impact_sounds/Blade_Small.ogg', 50, 1, -1)
			if(prob(10)) // lowered probability slightly
				M.visible_message("<span class='combat'><B>[M]</B> staggers!</span>")
				M.changeStatus("stunned", 2 SECONDS)
				M.changeStatus("weakened", 2 SECONDS)
			random_brute_damage(M, rand(5,10),1)
		else
			M.visible_message("<span class='combat'><B>[src]</B> hits [src.target] with a mechanical arm!</span>")
			playsound(src.loc, "punch", 30, 1, -2)
			random_brute_damage(M, rand(10,15),1)

		SPAWN(1 SECOND)
			src.attacking = 0

	CritterDeath(mob/M)
		if (!src.alive) return
		..()
		if (rand(100) <= revivalChance)
			src.revivalChance -= revivalDecrement
			SPAWN(rand(400,800))
				src.alive = 1
				src.set_density(1)
				src.health = initial(src.health)
				src.icon_state = initial(src.icon_state)
				for(var/mob/O in viewers(src, null))
					O.show_message("<span class='alert'><b>[src]</b> re-assembles itself and is ready to fight once more!</span>")
		return

/*/mob/living/critter/mechmonstrosity/test
	name = "Mechanical Monstrosity"
	real_name = "mechmonstrosity"
	desc = "A severely disfigured human torso which is forcibly kept alive by the mechanical parts.."
	density = 1
	icon = 'icons/misc/bigrobot.dmi'
	icon_state = "bigrobot"
	custom_gib_handler = /proc/robogibs
	blood_id = "oil"
	stepsound = null
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
	base_move_delay = 5
	base_walk_delay = 5
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"
	bound_height = 32
	bound_width = 32
	var/icon/northsouth = null
	var/icon/eastwest = null
	var/lastdir = null

	New()
		northsouth = icon('icons/misc/bigrobot.dmi')
		eastwest = icon('icons/misc/bigrobot.dmi')
		changeIcon()
		..()

	bump(atom/O)
		. = ..()
		changeIcon(0)
		return .

	proc/changeIcon(var/rebuildOverlays = 0)
		if(dir == NORTH || dir == SOUTH)
			icon = northsouth
			pixel_x = -9
		if(dir == EAST)
			icon = eastwest
		if(dir == WEST)
			icon = eastwest
		return

	Move()
		stepsound = pick(sounds_mechanicalfootstep)
		if(dir != lastdir)
			if(dir == NORTHEAST || dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST)
				set_dir(lastdir)
				changeIcon()
			else
				lastdir = dir
				changeIcon()
		..()

	set_loc(var/newloc as turf|mob|obj in world)
		..(newloc)
		changeIcon()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"

*/
