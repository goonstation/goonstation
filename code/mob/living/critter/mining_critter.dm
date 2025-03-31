///////////////////////////////////////////////
// FERMID LIMBS (basically tweaked bee limbs)
///////////////////////////////////////////////

/datum/limb/small_critter/fermid // can hold slightly larger things than base small critter
	max_wclass = W_CLASS_NORMAL
	actions = list("jabs", "prods", "pokes", "taps")
	sound_attack = 'sound/impact_sounds/Flesh_Stab_1.ogg'

/datum/limb/mouth/fermid
	var/list/bite_adjectives = list("vicious","vengeful","violent")
	sound_attack = 'sound/impact_sounds/Flesh_Tear_1.ogg'
	can_beat_up_robots = TRUE //angry space ants

	harm(mob/target, var/mob/user)
		if (!user || !target)
			return 0
		if (!target.melee_attack_test(user))
			return
		src.custom_msg = SPAN_COMBAT("<b>[user] bites [target] with [his_or_her(user)] [pick(src.bite_adjectives)] mandibles!</b>")
		..()

///////////////////////////////////////////////
// FERMID
///////////////////////////////////////////////

/mob/living/critter/fermid
	name = "fermid"
	real_name = "fermid"
	desc = "Extremely hostile asteroid-dwelling bugs. Best to avoid them wherever possible."
	icon_state = "fermid"
	icon_state_dead = "fermid-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "clacks"
	speechverb_ask = "chitters"
	speechverb_gasp = "rattles"
	speechverb_stammer = "click-clacks"
	butcherable = BUTCHER_ALLOWED
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	pull_w_class = W_CLASS_NORMAL
	hand_count = 3
	reagent_capacity = 100
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 0.3
	is_npc = TRUE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid)
	no_stamina_stuns = TRUE
	var/recolor = null

	New()
		..()
		LAZYLISTADDUNIQUE(src.faction, FACTION_FERMID)
		START_TRACKING_CAT(TR_CAT_BUGS)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 80) // They live in asteroids so they should be resistant
		if(recolor)
			color = color_mapping_matrix(inp=list("#cc0303", "#9d9696", "#444142"), out=list(recolor, "#9d9696", "#444142"))

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()


	is_spacefaring()
		return TRUE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/fermid
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mandibles"
		HH.can_hold_items = FALSE

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter/fermid
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"
		HH.name = "left foot"
		HH.limb_name = "foot"

		HH = hands[3]
		HH.limb = new /datum/limb/small_critter/fermid
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handr"
		HH.name = "right foot"
		HH.limb_name = "foot"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","hiss","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> chitters!"
			if ("snap","clack","click","clak")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Scissor.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src]</b> claks!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","hiss","chitter")
				return 2
			if ("snap","clack","click","clak")
				return 3
		return ..()

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/sting = src.abilityHolder.getAbility(/datum/targetable/critter/sting/fermid)
		var/datum/targetable/critter/bite = src.abilityHolder.getAbility(/datum/targetable/critter/bite/fermid_bite)
		if (sting && !sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
			return TRUE
		else if (bite && !bite.disabled && bite.cooldowncheck())
			bite.handleCast(target)
			return TRUE

	critter_basic_attack(mob/target)
		if(prob(30))
			src.swap_hand()
		return ..()

	death()
		src.reagents.add_reagent("atropine", 50, null)
		src.reagents.add_reagent("haloperidol", 50, null)
		return ..()

	radioactive
		New()
			..()
			AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
/mob/living/critter/fermid/polymorph
	desc = "Extremely hostile asteroid-dwelling bugs. This one looks particularly annoyed about something."
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 0.1
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid/polymorph, /datum/targetable/critter/slam/polymorph)
	is_npc = FALSE // Typically is a crewmember

///////////////////////////////////////////////
///////////////////////////////////////////////
// STUPID GIMMICKRY BY CIRR BELOW HERE
///////////////////////////////////////////////
///////////////////////////////////////////////

///////////////////////////////////////////////
// FERMID WORKER
///////////////////////////////////////////////
/mob/living/critter/fermid/worker
	name = "fermid"
	real_name = "fermid"
	desc = "Extremely hostile asteroid-dwelling bugs. Small, numble, and a whole lot of mandible."
	icon_state = "fermid-s"
	icon_state_dead = "fermid-s-dead"
	health_brute = 20
	health_burn = 20
	flags = TABLEPASS
	fits_under_table = 1

	green
		recolor = "#05da17"

/mob/living/critter/fermid/spitter
	name = "fermid"
	real_name = "fermid"
	desc = "Extremely hostile asteroid-dwelling bugs. Best to avoid whatever is in that enlarged gaster."
	icon_state = "fermid-r"
	icon_state_dead = "fermid-r-dead"
	health_brute = 30
	health_burn = 30
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid, /datum/targetable/critter/spit)

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/spit/spit = src.abilityHolder.getAbility(/datum/targetable/critter/spit)
		if (!spit.disabled && spit.cooldowncheck())
			spit.handleCast(target)
			return TRUE
		. = ..()

	orange
		recolor = "#ca710a"
		add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid, /datum/targetable/critter/flamethrower)

		critter_ability_attack(var/mob/target)
			var/datum/targetable/critter/fire = src.abilityHolder.getAbility(/datum/targetable/critter/flamethrower)
			if (!fire.disabled && fire.cooldowncheck())
				fire.handleCast(target)
				return TRUE
			. = ..()

	blue
		recolor = "#1156d8"
		add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid, /datum/targetable/critter/arcflash)

		critter_ability_attack(var/mob/target)
			var/datum/targetable/critter/arc = src.abilityHolder.getAbility(/datum/targetable/critter/arcflash)
			if (!arc.disabled && arc.cooldowncheck())
				arc.handleCast(target)
				return TRUE
			. = ..()


///////////////////////////////////////////////
// FERMID QUEEN
///////////////////////////////////////////////
/datum/movement_modifier/big_fermid
	additive_slowdown = 2.5

/mob/living/critter/fermid/queen
	name = "fermid queen"
	real_name = "fermid queen"
	desc = "Extremely hostile asteroid-dwelling mother of bugs. A risk to life as we know it if left unchecked."
	icon = 'icons/misc/bigcritter.dmi'
	icon_state = "fermid-queen"
	icon_state_dead = "fermid-queen-dead"
	health_brute = 50
	health_brute_vuln = 0.6
	health_burn = 25
	health_burn_vuln = 0.1
	pull_w_class = W_CLASS_BULKY

	New()
		..()
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/big_fermid, src)

/mob/living/critter/fermid/hulk
	name = "fermid hulk"
	real_name = "fermid hulk"
	desc = "Extremely hostile asteroid-dwelling mother of bugs. A huge guardian of some riches."
	icon = 'icons/misc/bigcritter.dmi'
	icon_state = "fermid-hulk"
	icon_state_dead = "fermid-hulk-dead"
	health_brute = 40
	health_brute_vuln = 0.5
	health_burn = 25
	health_burn_vuln = 0.1
	pull_w_class = W_CLASS_BULKY

	New()
		..()
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/big_fermid, src)

	purple
		recolor = "#b90fab"

	radioactive
		New()
			..()
			AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)


///////////////////////////////////////////////
// FERMID GRUB
///////////////////////////////////////////////
/datum/movement_modifier/grub_fermid
	additive_slowdown = 4

/mob/living/critter/fermid/grub
	name = "fermid grub"
	real_name = "fermid grub"
	desc = "Extremely hostile asteroid-dwelling bugs. Best to avoid them wherever possible."
	icon_state = "fermid-g"
	icon_state_dead = "fermid-g-dead"
	flags = TABLEPASS
	fits_under_table = 1
	pull_w_class = W_CLASS_NORMAL
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 0.5
	add_abilities = list(/datum/targetable/critter/bite/fermid_bite)

	New()
		..()
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/grub_fermid, src)

///////////////////////////////////////////////
// FERMID EGG
///////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/fermid
	name = "insectoid egg"
	desc = "Looks like this could hatch into something fermid like."
	icon_state = "fermid-egg"
	critter_type = /mob/living/critter/fermid

	New()
		..()
		color = null

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/fermid/random
	New()
		critter_type = weighted_pick(list(/mob/living/critter/fermid=10,
										  /mob/living/critter/fermid/radioactive=1,
										  /mob/living/critter/fermid/worker/green=5,
										  /mob/living/critter/fermid/hulk/purple=1,
										  /mob/living/critter/fermid/spitter/orange=2,
										  /mob/living/critter/fermid/spitter/blue=2))
		..()


/obj/overlay/tile_effect/cracks/spawner/fermid
	icon = 'icons/turf/walls/asteroid.dmi'
	icon_state = "orifice2"
	spawntype = /mob/living/critter/fermid

	New()
		..()
		SPAWN(2 SECONDS)
			update_icon()



	update_icon(...)
		. = ..()
		var/dirs = get_connected_directions_bitflag(list(/turf/simulated/wall/auto/asteroid=1), null, TRUE, FALSE)
		if(dirs)
			for(var/direction in (cardinal - SOUTH))
				if(dirs & direction)
					if(prob(80))
						var/turf/T = get_step(get_turf(src),direction)
						icon_state = "orifice_wall"
						src.color = T.color
						src.dir = turn(direction, 180)
						var/angle = dir2angle(direction)
						src.pixel_x = (32) * sin(angle)
						src.pixel_y = (32) * cos(angle)

	random
		New()
			spawntype = weighted_pick(list(/mob/living/critter/fermid=10,
										/mob/living/critter/fermid/radioactive=1,
										/mob/living/critter/fermid/worker/green=5,
										/mob/living/critter/fermid/hulk/purple=1,
										/mob/living/critter/fermid/spitter/orange=2,
										/mob/living/critter/fermid/spitter/blue=2))
			..()


///////////////////////////////////////////////
// ROCK WORM
///////////////////////////////////////////////

/mob/living/critter/rockworm
	name = "rock worm"
	real_name = "rock worm"
	desc = "Tough lithovoric worms."
	icon_state = "rockworm"
	icon_state_dead = "rockworm-dead"
	hand_count = 1
	can_throw = FALSE
	can_grab = FALSE
	can_disarm = FALSE
	health_brute = 40
	health_brute_vuln = 1
	health_burn = 40
	health_burn_vuln = 0.1
	ai_type = /datum/aiHolder/rockworm
	is_npc = TRUE
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_ONCE
	add_abilities = list(/datum/targetable/critter/vomit_ore)
	butcherable = BUTCHER_ALLOWED
	var/tamed = FALSE
	var/seek_ore = TRUE
	var/eaten = 0
	var/const/rocks_per_gem = 10

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 80) // They live in asteroids so they should be resistant
		AddComponent(/datum/component/consume/can_eat_raw_materials, FALSE)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	is_spacefaring()
		return TRUE

	on_pet(mob/user)
		if (..())
			return 1
		if (src.tamed && src.ai?.enabled)
			if (src.seek_ore)
				src.seek_ore = FALSE
				src.visible_message(SPAN_NOTICE("[user] pats [src] on the back. It won't seek ores now!"))
			else
				src.seek_ore = TRUE
				src.visible_message(SPAN_NOTICE("[user] shakes [src] to awaken its hunger!"))

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/raw_material) && !isdead(src))
			if((istype(I, /obj/item/raw_material/shard)) || (istype(I, /obj/item/raw_material/scrap_metal)))
				src.visible_message("[M] tries to feed [src] but they won't take it!")
				return
			if (src.tamed)
				src.visible_message("[M] tries to feed [src] but they seem full...")
				return
			if(prob(40))
				src.tamed = TRUE
				src.ai_retaliates = FALSE
				src.visible_message("[src] enjoyed the [I] and seems more docile!")
				src.emote("burp")
			src.aftereat()
			I.Eat(src, src)
			return
		..()

	seek_food_target(var/range = 5)
		. = list()
		for (var/obj/item/raw_material/ore in view(range, get_turf(src)))
			if (istype(ore, /obj/item/raw_material/shard)) continue
			if (istype(ore, /obj/item/raw_material/scrap_metal)) continue
			if (!(istype(ore, /obj/item/raw_material/rock)) && prob(30)) continue // can eat not rocks with lower chance
			. += ore

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = FALSE

	proc/aftereat()
		var/datum/targetable/critter/vomit_ore/vomit = src.abilityHolder.getAbility(/datum/targetable/critter/vomit_ore)
		var/max_dist = 4
		src.eaten++
		if (src.eaten >= src.rocks_per_gem && src.ai?.enabled)
			for(var/turf/T in view(max_dist, src))
				if(!is_blocked_turf(T))
					if (!vomit.disabled && vomit.cooldowncheck())
						vomit.handleCast(T)
					break

/mob/living/critter/rockworm/gary
	name = "Gary the rockworm"
