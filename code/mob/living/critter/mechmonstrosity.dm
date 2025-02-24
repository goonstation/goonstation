/mob/living/critter/mechmonstrosity
	name = "mechanical monstrosity"
	real_name = "mechanical monstrosity"
	desc = "A severely disfigured human torso which is forcibly kept alive by the mechanical parts.."
	density = TRUE
	icon = 'icons/mob/critter/robotic/mechanical/monstrosity.dmi'
	icon_state = "mechmonstrosity"
	custom_gib_handler = /proc/robogibs
	blood_id = "oil"
	hand_count = 0
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	can_help = FALSE
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"
	faction = list(FACTION_DERELICT)

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
				boutput(src,pick(SPAN_ALERT("<b>You feel terrible.</b>"),SPAN_ALERT("<b>You are in severe agony. Why do they torture you like this!?</b>"),SPAN_ALERT("<b>You wish you could just die already but your augmentations keep you alive.</b>"),))
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
					playsound(src, 'sound/voice/killme.ogg', 70, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> begs for mercy!"

/mob/living/critter/mechmonstrosity/medical
	name = "V.I.V.I-SECT-10N"
	real_name = "V.I.V.I-SECT-10N"
	desc = "You better wish that apples will keep this thing away from you.."
	icon = 'icons/mob/critter/robotic/mechanical/vivisection.dmi'
	icon_state = "vivisection"
	hand_count = 2
	var/smashes_shit = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	can_help = TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "Syringe Injector"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "syringegun"				// the icon state of the hand UI background
		HH.limb_name = "Injector"					// name for the dummy holder
		HH.limb = new /datum/limb/gun/kinetic/syringe	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = FALSE
		HH.can_attack = FALSE
		HH.can_range_attack = TRUE

		HH = hands[2]
		HH.name = "Dual Saw"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "saw"				// the icon state of the hand UI background
		HH.limb_name = "Dual Saw"					// name for the dummy holder
		HH.limb = new /datum/limb/dualsaw	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE

	bump(atom/movable/AM)
		if(smashes_shit)
			if(isobj(AM))
				if (istype(AM, /obj/critter) || istype(AM, /obj/machinery/vehicle))
					return
				if(istype(AM, /obj/window))
					var/obj/window/W = AM
					W.health = 0
					W.smash()
				else if(istype(AM,/obj/mesh/grille))
					var/obj/mesh/grille/G = AM
					G.damage_blunt(30)
				else if(istype(AM, /obj/table))
					AM.meteorhit()
				else if(istype(AM, /obj/foamedmetal))
					AM.dispose()
				else
					AM.meteorhit()
				playsound(src.loc, 'sound/effects/exlow.ogg', 70,1)
				src.visible_message(SPAN_ALERT("<B>[src]</B> smashes through \the [AM]!"))
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
	var/stealthy = FALSE
	var/venom_id = "corruptnanites"
	var/inject_amount = 10
	cooldown = 60 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return TRUE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to inject there."))
				return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to inject."))
			return TRUE
		var/mob/MT = target
		if (!MT.reagents)
			boutput(holder.owner, SPAN_ALERT("That does not hold reagents, apparently."))
		if (!stealthy)
			playsound(holder.owner.loc, 'sound/items/hypo.ogg', 70,1)
			holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] injects [target]!</b>"))
		else
			holder.owner.show_message(SPAN_NOTICE("You stealthily inject [target]."))
		MT.reagents.add_reagent(venom_id, inject_amount)


/datum/targetable/critter/scarylook
	name = "Terrifying glare"
	desc = "Stuns one target for a short time."
	icon_state = "evilstare"
	targeted = TRUE
	target_nodamage_check = TRUE
	max_range = 14
	cooldown = 60 SECONDS

	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return TRUE

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to stun yourself?"))
			return TRUE

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return TRUE

		if (isdead(target))
			boutput(M, SPAN_ALERT("It would be a waste of time to stun the dead."))
			return TRUE

		. = ..()
		M.visible_message(SPAN_ALERT("<B>[M] glares angrily at [target]!</B>"))
		target.apply_flash(5, 5)
		boutput(target, SPAN_ALERT("You can feel a chill running down your spine as [M] glares at you with hatred burning in their  mechanical eyes."))
		target.emote("shiver")

		logTheThing(LOG_COMBAT, M, "uses glare on [constructTarget(target,"combat")] at [log_loc(M)].")
		return FALSE

/datum/action/bar/icon/mechanimateAbility
	duration = 8 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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
			O.show_message(SPAN_ALERT("<B>[owner] attempts to inject [target]!</B>"), 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(ownerMob && target && (BOUNDS_DIST(owner, target) == 0) && mechanimate?.cooldowncheck())
			logTheThing(LOG_COMBAT, ownerMob, "injects [constructTarget(target,"combat")]. Crawler transformation")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message(SPAN_ALERT("<B>[owner] successfully injected [target]!</B>"), 1)
			playsound(ownerMob, 'sound/items/hypo.ogg', 80, FALSE)

			var/mob/living/critter/robotic/crawler/crawler = new /mob/living/critter/robotic/crawler(get_turf(target))
			crawler.name = "[target]'s crawling head"
			crawler.desc = "A horrible crawling monstrosity, ravaged from the corpse of [target]."
			crawler.revivalChance = 100

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
	cooldown = 0 SECONDS
	var/actual_cooldown = 20 SECONDS
	icon_state = "pet"
	targeted = TRUE
	target_anything = TRUE

	proc/actionFinishCooldown()
		cooldown = actual_cooldown
		doCooldown()
		cooldown = initial(cooldown)

	cast(mob/target)
		var/mob/living/M = holder.owner

		if(!isdead(target))
			return TRUE

		if (M == target)
			boutput(M, SPAN_ALERT("You can't do that to yourself."))
			return TRUE

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return TRUE
		. = ..()
		holder.owner.say("Transformation protocol engaged. Please stand clear of the recipient.")
		actions.start(new/datum/action/bar/icon/mechanimateAbility(target, src), holder.owner)
		return FALSE

/datum/targetable/critter/dissect
	name = "Dissect"
	desc = "Removes ALL of the targets limbs."
	icon_state = "dissect"
	targeted = TRUE
	target_nodamage_check = TRUE
	max_range = 1
	cooldown = 60 SECONDS

	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner
		var/mob/living/carbon/human/H = target

		if (!M || !target || !ismob(target))
			return TRUE

		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to dissect yourself?"))
			return TRUE

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return TRUE

		. = ..()
		M.visible_message(SPAN_ALERT("<B>With their double saw whirling, [M] swiftly severs all [target]'s limbs!</B>"))
		H.sever_limb("r_arm")
		H.sever_limb("l_arm")
		H.sever_limb("r_leg")
		H.sever_limb("l_leg")
		playsound(M.loc, 'sound/effects/sawhit.ogg', 90,1)
		boutput(target, SPAN_ALERT("All of your limbs were severed by [M]!"))

		logTheThing(LOG_COMBAT, M, "uses dissect on [constructTarget(target,"combat")] at [log_loc(M)].")
		return FALSE

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
		if (!ismob(hit) || !hit.reagents)
			return
		if (islist(src.venom_id))
			for (var/id in src.venom_id)
				hit.reagents.add_reagent(id, inject_amount)
		else
			hit.reagents.add_reagent(venom_id, inject_amount)

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
		src.read_only = TRUE

/mob/living/critter/robotic/crawler
	name = "crawling monstrosity"
	desc = "A crawling mechanical monstrosity."
	icon = 'icons/mob/critter/robotic/mechanical/crawler.dmi'
	icon_state = "mechmonstrosity_c"
	icon_state_dead = "mechmonstrosity_c-dead"
	can_throw = FALSE
	can_grab = TRUE
	can_disarm = TRUE
	hand_count = 1
	health_brute = 20
	health_brute_vuln = 0.5
	health_burn = 20
	health_burn_vuln = 0.25
	faction = list(FACTION_DERELICT)
	is_npc = TRUE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	var/revivalChance = 0
	var/revivalDecrement = 20

	New()
		..()
		playsound(src.loc, 'sound/effects/glitchy1.ogg', 50, 0)

	setup_healths()
		add_hh_robot(src.health_brute, src.health_brute_vuln)
		add_hh_robot_burn(src.health_burn, src.health_brute_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.icon_state = "blade"
		HH.limb_name = "serrated claws"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				playsound(src.loc, 'sound/effects/glitchy1.ogg', 50, 0)

	death(var/gibbed)
		if (prob(src.revivalChance))
			..()
			src.revivalChance -= src.revivalDecrement
			SPAWN(rand(40 SECONDS, 80 SECONDS))
				src.full_heal()
				src.visible_message(SPAN_ALERT("[src] re-assembles and is ready to fight once more!"))
			return
		if (!gibbed)
			src.gib()

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
