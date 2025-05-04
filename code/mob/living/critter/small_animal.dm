/* -=-= What's here =-=-
 - small_critter parent
  - mice
   - Remy
  - cats
   - Jones
  - dogs (default is pug)
  	- corgi
  	- George
  	- shiba
  - birds (default is parrots)
   - owls
    - large owls
     - Hooty
   - turkeys
   - timberdoodles
   - seagulls
    - gannets
   - crows
   - geese
  - cockroaches
  - ferrets
  - frogs
  - possums
   - Morty
  - seals
  - walruses
  - floating eye
  - pigs
  - bats
   - angry bats
   - Dr. Acula
   - Tiny Bat Rina (admin office pet)
  - wasps
  - raccoons
  - slugs
   - snails
  - butterflies
  - moths
  - flies
  - lobsters
  - boogiebots
  - figures
  - mentor / admin mice
  - crabs
	- party crabs
	- lava crabs
todo: add more small animals!
*/
ABSTRACT_TYPE(/mob/living/critter/small_animal)
/mob/living/critter/small_animal
	name = "critter"
	real_name = "critter"
	desc = "you shouldn't be seeing this!"
	density = FALSE
	custom_gib_handler = /proc/gibs
	hand_count = 1
	can_help = TRUE
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	butcherable = BUTCHER_ALLOWED
	name_the_meat = TRUE
	max_skins = 1
	health_brute = 20 // moved up from birds since more than just they can use this, really
	health_brute_vuln = 1
	health_burn = 20
	health_burn_vuln = 1
	void_mindswappable = TRUE
	is_npc = TRUE
	ai_type = /datum/aiHolder/wanderer/floor_only
	ai_retaliates = TRUE
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_ONCE
	has_genes = TRUE
	p_class = 1

	var/aggressive = FALSE
	var/random_name = FALSE
	var/random_look = FALSE
	var/name_list = "names/pets.txt"
	var/player_can_spawn_with_pet = FALSE //! For the Pet Person trait that makes you spawn with a pet (do not confuse with is_pet!!!)

	var/fur_color = 0
	var/eye_color = 0

	var/is_pet = null // null = autodetect
	///Do we randomize stuff?
	var/generic = TRUE
	var/drop_contents_on_death = FALSE // Drop everything on death?

	New(loc)
		if(isnull(src.is_pet))
			src.is_pet = (copytext(src.name, 1, 2) in uppercase_letters)
		if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
			src.is_pet = 0
		if(src.is_pet)
			START_TRACKING_CAT(TR_CAT_PETS)
		..()

		src.add_stam_mod_max("small_animal", -(STAMINA_MAX*0.5))
		if (src.real_name == "critter")
			src.real_name = src.name
		if (src.random_name)
			src.randomize_name()

	disposing()
		if(src.is_pet)
			STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)
		add_health_holder(/datum/healthHolder/toxin)
		add_health_holder(/datum/healthHolder/brain)

	Cross(atom/mover)
		if (!src.density && istype(mover, /obj/projectile))
			return prob(50)
		else
			return ..()

	death(var/gibbed)
		if (!gibbed && src.drop_contents_on_death)
			src.unequip_all()
		..()

	canRideMailchutes()
		return src.fits_under_table

	get_symbol_color()
		return src.fur_color || ..()

	animate_lying(lying)
		animate_180_rest(src, !lying)

	proc/randomize_name()
		src.name = pick_string_autokey(name_list)
		src.real_name = src.name
		src.update_name_tag(src.name)

proc/filter_carrier_pets(var/type)
	var/mob/living/critter/small_animal/coolpet = type
	return initial(coolpet.player_can_spawn_with_pet)

/* =============================================== */
/* -------------------- Mouse -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/mouse
	name = "space mouse"
	real_name = "space mouse"
	desc = "A mouse.  In space."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2
	icon_state = "mouse_white"
	icon_state_dead = "mouse_white-dead"
	speechverb_say = "squeaks"
	speechverb_exclaim = "squeals"
	speechverb_ask = "squeaks"
	health_brute = 8
	health_burn = 8
	faction = list(FACTION_NEUTRAL)
	ai_type = /datum/aiHolder/mouse
	ai_retaliate_patience = 0 //retaliate when hit immediately
	ai_retaliate_persistence = RETALIATE_ONCE //but just hit back once
	player_can_spawn_with_pet = TRUE
	var/attack_damage = 3
	var/use_custom_color = TRUE
	var/shiny_chance = 4096 ///One in this chance of being shiny
	var/is_shiny = FALSE

	New()
		..()
		if(src.shiny_chance && (rand(1, src.shiny_chance) == 1))
			src.real_name = "shiny [src.name]"
			src.fur_color = "#aeff45"
			src.icon_state = "mouse-shiny"
			src.icon_state_dead = "mouse-shiny-dead"
			src.use_custom_color = FALSE
			src.name = src.real_name
			src.is_shiny = TRUE
			src.desc += " This one seems rare."
		else
			fur_color =	pick("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D","#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
		eye_color = "#FFFFF"
		setup_overlays()
		src.bioHolder.AddNewPoolEffect("albinism", scramble=TRUE)

	setup_overlays()
		if (src.use_custom_color)
			if (src.client)
				fur_color = src.client.preferences.AH.customizations["hair_bottom"].color
				eye_color = src.client.preferences.AH.e_color
			var/image/overlay = image(src.icon, "mouse_colorkey")
			overlay.color = fur_color
			src.UpdateOverlays(overlay, "hair")

			var/image/overlay_eyes = image(src.icon, "mouse_eyes")
			overlay_eyes.color = eye_color
			src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		if (src.use_custom_color)
			src.ClearAllOverlays()
			var/image/overlay = image(src.icon, "mouse_colorkey-dead")
			overlay.color = fur_color
			src.UpdateOverlays(overlay, "hair")
		..()

	full_heal()
		..()
		src.ClearAllOverlays()
		src.setup_overlays()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
			if ("smile")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> wiggles [his_or_her(src)] tail happily!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("smile")
				return 1
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/reagent_containers/food/snacks/ingredient/cheese) && ishuman(M))
			src.visible_message("[M] feeds \the [src] some [I].", "[M] feeds you some [I].")
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(5)
			qdel(I)
			return
		. = ..()

	critter_basic_attack(var/mob/target)
		playsound(src.loc, 'sound/weapons/handcuffs.ogg', 50, 1, -1)
		src.set_hand(2)
		..()

	can_critter_eat()
		set_hand(2) // mouth hand
		src.set_a_intent(INTENT_HELP)
		return can_act(src,TRUE)


/mob/living/critter/small_animal/mouse/dead
	player_can_spawn_with_pet = FALSE

	New()
		. = ..()
		src.death()

/mob/living/critter/small_animal/mouse/weak
	health_brute = 2
	health_burn = 2

/mob/living/critter/small_animal/mouse/mad
	faction = list()
	player_can_spawn_with_pet = FALSE
	ai_type = /datum/aiHolder/mouse/mad
	var/list/disease_types = list(/datum/ailment/disease/space_madness, /datum/ailment/disease/berserker)

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/small_animal/mouse)) return FALSE
		return ..()

	critter_basic_attack(var/mob/target)
		. = ..()
		if(. && prob(30) && ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!H.clothing_protects_from_chems())
				src.visible_message(SPAN_ALERT("[src] bites you hard enough to draw blood!"), SPAN_ALERT("You bite [H] with all your might!"))
				H.emote("scream")
				bleed(H, rand(5,8), 5)
				H.contract_disease(pick(src.disease_types), null, null, 1)

//for mice spawned by plaguerat dens
/mob/living/critter/small_animal/mouse/mad/rat_den
	var/obj/machinery/wraith/rat_den/linked_den = null
	player_can_spawn_with_pet = FALSE
	shiny_chance = 0

	death()
		if(linked_den?.linked_critters > 0)
			linked_den.linked_critters--
		..()
/* -------------------- Remy -------------------- */

/mob/living/critter/small_animal/mouse/remy
	name = "Remy"
	desc = "A rat.  In space... wait, is it wearing a chefs hat?"
	icon_state = "remy"
	icon_state_dead = "remy-dead"
	health_brute = 33
	health_burn = 33
	fits_under_table = 0
	pull_w_class = W_CLASS_NORMAL
	ai_type = /datum/aiHolder/mouse_remy
	use_custom_color = FALSE
	player_can_spawn_with_pet = FALSE
	shiny_chance = 0
	gender = MALE
	///Remy tries not to suggest the same thing twice in a row
	var/last_recipe = null

	New()
		. = ..()
		new /obj/item/implant/access/infinite/chef(src)

	setup_overlays()
		return

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/reagent_containers/food/food, mob/user)
		if (!istype(food))
			return ..()
		if (ON_COOLDOWN(src, "consider_food", 5 SECONDS))
			return
		src.visible_message("[src] sniffs \the [food].")
		var/list/possible_recipes = list()
		for (var/datum/cookingrecipe/recipe in global.oven_recipes)
			if (istypes(food, recipe.ingredients))
				possible_recipes += recipe
		src.set_dir(get_dir(src, user))
		src.ai.disable()
		SPAWN(2 SECONDS)
			if (length(possible_recipes))
				if (length(possible_recipes) > 2)
					possible_recipes -= src.last_recipe
				src.emote("scream")
				var/datum/cookingrecipe/chosen = pick(possible_recipes)
				boutput(user, chosen.render())
			else
				src.visible_message("[src] shakes [his_or_her(src)] head sadly.")
			sleep(1 SECOND)
			src.ai.enable()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					FLICK("remy-exclaim", src)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
		return ..()


/* ============================================= */
/* ------------------ Turtle ------------------- */
/* ============================================= */

/mob/living/critter/small_animal/turtle
	name = "turtle"
	real_name = "turtle"
	desc = "A turtle. They are noble creatures of the land and sea."
	icon_state = "turtle"
	icon_state_dead = "turtle-dead"
	health_brute = 20
	health_burn = 20
	stamina = 0 // Turtles are slow
	hand_count = 2
	ai_retaliate_persistence = RETALIATE_ONCE
	player_can_spawn_with_pet = TRUE
	density = FALSE
	drop_contents_on_death = FALSE

	var/shell_count = 0		//Count down to 0. Measured in process cycles. If they are in their shell when this is 0, exit.
	var/rigged = FALSE
	var/rigger = null
	var/exploding = FALSE
	var/costume_name = null
	var/image/costume_alive = null
	var/image/costume_shell = null
	var/image/costume_dead = null

	var/obj/item/wearing_beret = null
	var/beret_remove_job_needed = null
	var/list/allowed_hats = list(/obj/item/clothing/head/hos_hat, /obj/item/clothing/head/hosberet, new/obj/item/clothing/head/NTberet/commander)

	add_abilities = list(/datum/targetable/critter/charge)
	ai_attacks_per_ability = 0

	New(loc)
		. = ..()
		START_TRACKING

		#ifdef HALLOWEEN
		var/r = rand(1,4)
		costume_name = "sylv_costume_[r]"
		#endif

		if(!src.gender)
			if(prob(50))
				src.gender = MALE
			else
				src.gender = FEMALE

		if (costume_name)
			costume_alive = image(src.icon, "[costume_name]")
			costume_shell = image(src.icon, "[costume_name]-shell")
			costume_dead = image(src.icon, "[costume_name]-dead")

	disposing()
		. = ..()
		STOP_TRACKING

	get_desc()
		..()
		if (src.wearing_beret)
			. += "<br>[src] is wearing an adorable beret!."
		else
			. += "<br>[src] looks cold without some sort of hat on."

		if (src.costume_name)
			. += "And he's wearing an adorable costume! Wow!"

	update_icon()
		var/state = "turtle"
		if(!isalive(src))
			state += "-dead"
			if (costume_name)
				src.UpdateOverlays(costume_dead, "costume")
		else
			if(src.shell_count)
				src.icon_state = "turtle-shell"
				return
			if (costume_name)
				src.UpdateOverlays(costume_alive, "costume")
		if(src.wearing_beret)
			state += "-beret"
			if (istype(wearing_beret, /obj/item/clothing/head/NTberet/commander))
				state += "-com"
		src.icon_state = state

	bullet_act(var/obj/projectile/P)
		switch(P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				if (prob(70))
					src.enter_shell()
		..()

	attack_hand(mob/user)
		if (user.a_intent == INTENT_HARM && prob(80))
			src.enter_shell()
		.=..()

	attackby(obj/item/I, mob/living/user)
		for (var/hat_type in src.allowed_hats)
			if (istype(I, hat_type))
				if (give_beret(I, user))
					return
		if (prob(80))
			src.enter_shell() //Turtle is spooked
		. = ..()

	mouse_drop(atom/over_object as mob|obj)
		if (over_object == usr && ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if (in_interact_range(src, H))
				if (take_beret(H))
					return
		..()

	ex_act(severity)
		if(src.exploding)
			return
		if (src.shell_count)
			src.shell_count = 0

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "foreleg"
		HH.limb_name = "foot"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (getStatusDuration("burning"))
			return ..()

		if (isdead(src))
			return 0

		if (src.shell_count > 0)
			src.shell_count--
			if(!src.shell_count)
				src.exit_shell()
		..()

	death(var/gibbed)
		..()
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Head of Security")
				boutput(M, SPAN_ALERT("You feel a wave of sadness wash over you, something terrible has happened."))
		src.UpdateIcon()

	full_heal()
		..()
		src.UpdateIcon()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/charge/charge = src.abilityHolder.getAbility(/datum/targetable/critter/charge)
		if (charge && !charge.disabled && charge.cooldowncheck())
			charge.handleCast(target)
			return TRUE

	critter_basic_attack(var/the_target)
		if (istype(the_target, /obj/critter)) //grrrr obj critters
			var/obj/critter/C = the_target
			if (C.health <= 0 && C.alive)
				playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 20, 1, -1)
				C.health -= 2
				return TRUE
			return FALSE
		if (!ismob(the_target))
			return
		var/mob/target = the_target
		if(istype(target, /mob/living/critter/small_animal/mouse/weak/mentor) && prob(90))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> tries to bite [target] but \the [target] dodges [pick("nimbly", "effortlessly", "gracefully")]!"))
			return FALSE
		src.set_hand(2) //mouth
		src.set_a_intent(INTENT_HARM)
		src.hand_attack(target)
		if (ishuman(target))
			var/mob/living/carbon/human/human = target
			var/obj/item/heldthing = human.r_hand ? human.r_hand : human.l_hand ? human.l_hand : null
			if (prob(10) && heldthing)
				human.drop_item(heldthing)
				boutput(target, SPAN_ALERT("[src] bites your hand so hard you drop [heldthing]! [pick("Bad turtle", "Piece of shit", "Ow")]!"))
		return TRUE

//NOOOOOOO
	proc/rig_to_explode(mob/user)
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Head of Security")
				boutput(M, SPAN_ALERT("You feel a foreboding feeling about the imminent fate of a certain turtle in [get_area(src)], better act quick."))

		message_admins("[key_name(user)] rigged [src] to explode in [user.loc.loc], [log_loc(user)].")
		logTheThing(LOG_COMBAT, user, "rigged [src] to explode in [user.loc.loc] ([log_loc(user)])")
		src.rigged = TRUE
		src.rigger = user

		var/area/A = get_area(src)
		if(A?.lightswitch && A?.power_light)
			src.explode()

	proc/explode()
		SPAWN(0)
			src.rigged = FALSE
			src.rigger = null
			src.enter_shell()	//enter shell first to give a warning
			src.exploding = TRUE
			sleep(0.2 SECONDS)
			explosion(src, get_turf(src), 0, 1, 2, 2)
			sleep(4 SECONDS)
			src.exploding = FALSE
			var/message = "Check please!"
			var/chat_text = make_chat_maptext(src, message)
			for (var/mob/O in all_hearers(7, get_turf(src)))
				O.show_message("<span class='say bold'>[SPAN_NAME("[src]")]</span> says, [SPAN_MESSAGE("\"[message]\"")]", 2, assoc_maptext = chat_text)
			playsound(src.loc, 'sound/misc/rimshot.ogg', 50, 1)

	proc/enter_shell()
		if (src.shell_count) return 0
		src.shell_count = 10
		src.ai.disable()

		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXPLOPROT, "turtle_shell", 80)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_HEAD, "turtle_shell", 80)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_BODY, "turtle_shell", 80)

		if (costume_name)
			src.UpdateOverlays(costume_shell, "costume")
		density = TRUE
		src.UpdateIcon()
		src.visible_message(SPAN_ALERT("<b>[src]</b> retreats into [his_or_her(src)] shell!"))
		return 1

	proc/exit_shell()

		src.shell_count = 0
		src.ai.enable()

		REMOVE_ATOM_PROPERTY(src, PROP_MOB_EXPLOPROT, "turtle_shell")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_HEAD, "turtle_shell")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_MELEEPROT_BODY, "turtle_shell")

		if (costume_name)
			src.UpdateOverlays(costume_alive, "costume")
		density = FALSE
		src.UpdateIcon()
		src.visible_message(SPAN_NOTICE("<b>[src]</b> comes out of [his_or_her(src)] shell!"))
		return 1


	proc/give_beret(var/obj/hat, var/mob/user)
		if (src.shell_count || src.wearing_beret) return 0

		var/obj/item/clothing/head/hos_hat/beret = hat
		if (istype(beret))
			if (beret.folds == 0)
				beret.folds = 1
				beret.name = "HoS Beret"
				beret.icon_state = "hosberet"
				beret.item_state = "hosberet"
				boutput(user, SPAN_NOTICE("[src] folds the hat into a beret before putting it on! "))
		user.drop_item()
		hat.set_loc(src)
		src.wearing_beret = hat
		src.UpdateIcon()
		return 1

	proc/take_beret(var/mob/M)
		if (src.shell_count || !src.wearing_beret) return 0

		var/obj/item/clothing/head/beret = wearing_beret
		if (beret)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if ((H.job == src.beret_remove_job_needed) || !src.beret_remove_job_needed)
					H.put_in_hand_or_drop(beret)
				else
					if (isalive(src))
						boutput(M, SPAN_ALERT("You try to grab the beret, but [src] pulls into his shell before you can!"))
						playsound(src.loc, "rustle", 10, 1)
						src.enter_shell()
					return 0
			src.wearing_beret = null
			src.UpdateIcon()
			return 1
		return 0

//The HoS's pet turtle. He can wear the beret!
/mob/living/critter/small_animal/turtle/sylvester
	name = "Sylvester"
	desc = "This turtle looks both cute and indimidating. It's a tough line to walk, but he does it effortlessly."
	health_brute = 50
	health_burn = 50
	gender = MALE
	player_can_spawn_with_pet = FALSE
	is_pet = 2
	ai_type = /datum/aiHolder/aggressive
	ai_retaliate_patience = 1
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	#ifdef HALLOWEEN
	costume_name = "sylv_costume_1"
	#endif

	on_pet(mob/user)
		if (..())
			return 1
		if (src.ai?.enabled && ishuman(user))
			var/mob/living/carbon/human/human = user
			var/clown_tally = human.clown_tally()
			if (clown_tally>=2 || human.traitHolder.hasTrait("training_clown"))
				src.ai.priority_tasks += src.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src, src.ai.default_task))
				src.ai.interrupt()
				src.visible_message(SPAN_ALERT("[src] knocks [human] over!"))
				human.setStatus("resting", duration = INFINITE_STATUS)

	seek_target(range)
		. = list()
		var/list/hearers_list = hearers(range, src)
		for (var/mob/living/M in hearers_list)
			if (istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/human = M
				var/clown_tally = human.clown_tally()
				if (isalive(human) && (clown_tally>=2 || human.traitHolder.hasTrait("training_clown"))) //We only hate clowns
					. += human
		if (length(.))
			if (!ON_COOLDOWN(src,"clown_charge_alert", 2 MINUTES))
				src.visible_message(SPAN_ALERT("<b>[src]</b> notices a Clown and starts charging!"))

//Starts with the beret on!
/mob/living/critter/small_animal/turtle/sylvester/HoS
	beret_remove_job_needed = "Head of Security"

	New()
		..()
		//Make the beret
		var/obj/item/clothing/head/hos_hat/beret = new/obj/item/clothing/head/hos_hat(src)
		//fold it
		beret.folds = 1
		beret.name = "HoS Beret"
		beret.icon_state = "hosberet"
		beret.item_state = "hosberet"

		wearing_beret = beret
		src.UpdateIcon()

/mob/living/critter/small_animal/turtle/sylvester/Commander
	beret_remove_job_needed = "NanoTrasen Pod Commander"

	New()
		..()
		var/obj/item/clothing/head/NTberet/commander/beret = new/obj/item/clothing/head/NTberet/commander(src)
		//fold it
		beret.name = "Sylvester's Beret"
		wearing_beret = beret
		src.UpdateIcon()

		START_TRACKING_CAT(TR_CAT_PW_PETS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PW_PETS)
		..()


/* ============================================= */
/* -------------------- Cat -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/cat
	name = "space cat"
	real_name = "space cat"
	desc = "A cat. In space."
	icon_state = "cat1"
	icon_state_dead = "cat1-dead"
	hand_count = 2
	speechverb_say = "meows"
	speechverb_exclaim = "yowls"
	speechverb_ask = "mews"
	health_brute = 15
	health_burn = 15
	flags = TABLEPASS
	fits_under_table = TRUE
	add_abilities = list(/datum/targetable/critter/pounce)
	ai_retaliate_patience = 2 //hit back when you've been hit twice
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP //attack until they're knocked down
	ai_type = /datum/aiHolder/cat
	random_name = TRUE
	random_look = TRUE
	name_list = "names/cats.txt"
	player_can_spawn_with_pet = TRUE
	sound_scream = 'sound/voice/animal/cat.ogg'
	var/cattype = 1
	var/catnip = 0
	var/is_annoying = FALSE
	var/attack_damage = 3
	var/obj/item/clothing/head/hairbow/bow = null
	///if set, only accept bows of this type
	var/bow_type = null

	New()
		..()
		if (src.random_look)
#ifdef HALLOWEEN
			src.cattype = 3 //Black cats for halloween.
#else
			src.cattype = rand(1,9)
#endif
			src.icon_state = "cat[cattype]"
			src.icon_state_alive = src.icon_state
			src.icon_state_dead = "cat[cattype]-dead"


	update_body(...)
		. = ..()
		if (src.bow)
			src.UpdateOverlays(image('icons/misc/critterbowtie.dmi', src.bow_icon_state()), "bowtie")
		else
			src.ClearSpecificOverlays("bowtie")

	proc/bow_icon_state()
		return "[replacetext(src.bow.icon_state, "hbow", "bowtie")][isdead(src) ? "-dead" : ""]"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/W, mob/living/user)
		if (!isdead(src) && istype(W, /obj/item/plant/herb/catnip))
			user.visible_message("<b>[user]</b> gives [src] \the [W]!",\
			"You give [src] \the [W].")
			src.catnip_effect()
			user.u_equip(W)
			qdel(W)
		else if (istype(W, /obj/item/clothing/head/hairbow))
			if (src.bow_type && !istype(W, src.bow_type))
				boutput(user, "[src] gives you a withering look and refuses the bow. Perhaps they'd prefer a different color?")
				return
			var/oldbow = src.bow

			user.drop_item(W)
			src.bow = W
			W.set_loc(src)
			src.update_body()

			if (oldbow)
				user.put_in_hand_or_drop(oldbow)
		else
			..()

	proc/catnip_effect()
		src.catnip = 45
		src.visible_message("[src]'s eyes dilate.")

	Move(turf/NewLoc, direct)
		. = ..()
		if ((locate(/obj/table) in src.loc) && prob(5) && !ON_COOLDOWN(src, "knock_stuff_off_table", 10 SECONDS))
			knock_stuff_off_table()

	proc/knock_stuff_off_table()
		var/list/obj/item/items_here = list()
		for (var/obj/item/item_here in src.loc)
			if (!item_here.anchored)
				items_here += item_here
		var/list/target_turfs = list()
		for (var/turf/T in range(1, src))
			if (!(locate(/obj/table) in T) && !(locate(/obj/window) in T) && !T.density)
				target_turfs += T
		if (length(items_here) && length(target_turfs))
			var/obj/item/item = pick(items_here)
			src.visible_message(SPAN_ALERT("[src] [pick("knocks","pushes","shoves")] [item] off the table!"))
			item.throw_at(pick(target_turfs), 2, 1)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		//Cats meow sometimes
		if (src.is_npc && prob(5))
			src.emote("scream", 1)

		if (getStatusDuration("burning"))
			return ..()

		if (isdead(src))
			return 0

		if (src.catnip)
			SPAWN(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

			if (prob(10))
				src.visible_message("[src] [pick("purrs","frolics","rolls about","does a cute cat thing of some sort")]!")

			if (src.catnip-- < 1)
				src.visible_message("[src] calms down.")
		..()

	death(var/gibbed)
		if (!gibbed && prob(5))
			SPAWN(3 SECONDS)
				if (src && isdead(src))
					src.visible_message("<b>[src]</b> comes back to life, good thing [he_or_she(src)] has 9 lives!")
					src.full_heal()
					src.icon_state = "cat[cattype]"
					return
		else
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","meow")
				if (src.emote_check(voluntary, 50))
					playsound(src, src.sound_scream, 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> meows!")
			if ("smile","purr")
				if (src.emote_check(voluntary, 30))
					return SPAN_EMOTE("<b>[src]</b> purrs.")
			if ("frown","tail")
				if (src.emote_check(voluntary, 30))
					return SPAN_EMOTE("<b>[src]</b>'s tail swishes back and forth aggressively!") // cat do dis when mad.  mad catte
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/cat_hiss.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> hisses!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","meow")
				return 2
			if ("smile","purr")
				return 2
			if ("frown","tail")
				return 1
			if ("snap","hiss")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(10))
			src.audible_message("[src] purrs!",\
			"You purr!")
		if (src.ai?.enabled && ispug(user) && prob(10))
			ON_COOLDOWN(src, "recent_pug_pet", 15 SECONDS)
			src.ai.priority_tasks += src.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src, src.ai.default_task))
			src.ai.interrupt()
			src.visible_message(SPAN_NOTICE("[src] recoils and hisses at [user]'s attempt to pet them, then goes for the jugular!"))
			playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)

	Crossed(atom/movable/M as mob)
		..()
		if (!isalive(src))
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(10) && src.is_annoying)
				src.visible_message(SPAN_COMBAT("[src] weaves around [H]'s legs and trips [him_or_her(H)]!"))
				H.setStatus("resting", duration = INFINITE_STATUS)
				H.force_laydown_standup()
			else if (prob(4))
				boutput(src, SPAN_NOTICE("You weave around [H] to [pick("show your affection!", "get [him_or_her(H)] to feed you.", "annoy [him_or_her(H)] for no reason in particular.")]"))
				boutput(H, SPAN_NOTICE("[src] weaves around you, waving [his_or_her(src)] tail around. A bunch of hair clings to your clothes and some gets in your nose."))
				H.emote("sneeze")

	seek_target(range)
		. = list()
		var/list/hearers_list = hearers(range, src)
		for (var/mob/living/M in hearers_list)
			if (istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if (ispug(H) && isalive(H) && GET_COOLDOWN(src, "recent_pug_pet"))
					. += H
					return
			if (istype(M, /mob/living/critter/small_animal/mouse))
				var/mob/living/critter/small_animal/mouse/mouse = M
				if (isdead(mouse)) continue
				. += mouse
		for (var/mob/living/critter/small_animal/livingtail/tail in range(src, 3))
			. += tail

		if (length(.) && prob(20))
			playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("[src] hisses!"))

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/pounce/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/pounce)
		if (pounce && !pounce.disabled && pounce.cooldowncheck() && prob(50))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> pounces on [target] and trips [him_or_her(target)]!"), SPAN_COMBAT("You pounce on [target]!"))
			pounce.handleCast(target)
			return TRUE

		if ((src.catnip || prob(2) ) && (!ON_COOLDOWN(src, "claw_fury", 20 SECONDS)))
			var/attackCount = rand(5, 9)
			var/iteration = 0
			target.setStatus("knockdown", 2 SECONDS)
			src.visible_message(SPAN_COMBAT("[src] [pick("starts to claw the living <b>shit</b> out of ", "unleashes a flurry of claw at ")] [target]!"))
			SPAWN(0)
				while (iteration <= attackCount && (get_dist(src, target) <= 1))
					src.set_hand(1) //claws
					src.set_a_intent(INTENT_HARM)
					src.hand_attack(target)
					iteration++
					sleep(0.3 SECONDS)
			return TRUE

	critter_basic_attack(var/the_target)
		if (istype(the_target, /obj/critter)) //grrrr obj critters
			var/obj/critter/C = the_target
			if (C.health <= 0 && C.alive)
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
				C.health -= 2
				return TRUE
			return FALSE
		if (!ismob(the_target))
			return
		var/mob/target = the_target
		if(istype(target, /mob/living/critter/small_animal/mouse/weak/mentor) && prob(90))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> tries to bite [target] but \the [target] dodges [pick("nimbly", "effortlessly", "gracefully")]!"))
			return FALSE
		if (prob(50))
			src.set_hand(2) //mouth
			src.set_a_intent(INTENT_HARM)
			src.hand_attack(target)
		else
			src.set_hand(1) //claws
			src.set_a_intent(INTENT_HARM)
			src.hand_attack(target)
			if (prob(10))
				bleed(target, 2)
				boutput(target, SPAN_ALERT("[src] scratches you hard enough to draw some blood! [pick("Bad kitty", "Piece of shit", "Ow")]!"))
		return TRUE

/mob/living/critter/small_animal/cat/weak
	add_abilities = list()
	health_brute = 10
	health_burn = 10
	player_can_spawn_with_pet = FALSE

/mob/living/critter/small_animal/cat/synth
	icon_state = "catsynth"
	icon_state_dead = "catsynth-dead"
	cattype = "synth"
	random_name = FALSE
	random_look = FALSE
	desc = "Although this cat is vegan, it's still a carnivore."

/* -------------------- Jones -------------------- */

TYPEINFO(/mob/living/critter/small_animal/cat/jones)
	mats = list("viscerite" = 25)
/mob/living/critter/small_animal/cat/jones
	name = "Jones"
	desc = "The captain's loyal-ish companion! The texture of their fur feels a bit off."
	health = 30
	random_name = FALSE
	random_look = FALSE
	health_brute = 30
	health_burn = 30
	is_annoying = TRUE
	is_pet = 2
	is_syndicate = 1
	player_can_spawn_with_pet = FALSE
	var/swiped = 0

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		..()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (isdead(src) || cattype == "-emagged")
			return 0
		src.cattype = "-emagged"
		src.icon_state = "cat-emagged"
		src.icon_state_alive = src.icon_state
		src.icon_state_dead = "cat-emagged-dead"
		if (user)
			user.show_text("You swipe down [src]'s back in a petting motion...")
			src.show_text("[user] swipes the card down your back in a petting motion...")
		return 1

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/card/emag))
			emag_act(user, W)
		else
			..()

/mob/living/critter/small_animal/cat/jons
	name = "\proper jons the catte"
	desc = "How long has this cat been here?"
	icon_state = "cat6"
	icon_state_dead = "cat6-dead"
	random_name = FALSE
	random_look = FALSE
	is_pet = TRUE
	player_can_spawn_with_pet = FALSE
	is_annoying = TRUE

/* ============================================= */
/* -------------------- Dog -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/dog
	name = "space dog"
	real_name = "space dog"
	desc = "A dog. In space."
	icon_state = "pug"
	icon_state_dead = "pug-lying"
	hand_count = 2
	add_abilities = list(/datum/targetable/critter/pounce)
	speechverb_say = "barks"
	speechverb_exclaim = "howls"
	speechverb_ask = "yips"
	health_brute = 30
	health_burn = 30
	ai_retaliate_patience = 4 //dogoos are big softies, you can hit them 4 times before they attack back
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP //attack until you're knocked down
	ai_type = /datum/aiHolder/dog
	name_list = "names/dogs.txt"
	player_can_spawn_with_pet = TRUE
	var/dogtype = "pug"
	var/sound/sound_bark = 'sound/voice/animal/dogbark.ogg'
	var/gabe = 0 //sniff. bark bork. brork.
	var/attack_damage = 3
	///The item we run after if we are playing fetch
	var/obj/item/fetch_item = null
	///Who threw the item we are fetching?
	var/mob/living/fetch_playmate = null
	pull_w_class = W_CLASS_BULKY

	New(loc)
		. = ..()
		RegisterSignal(src, COMSIG_MOB_THROW_ITEM_NEARBY, PROC_REF(throw_response))
		AddComponent(/datum/component/waddling)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark")
				if (src.emote_check(voluntary, 50))
					if (src.gabe == 1) //sniff. bark bork. brork.
						playsound (get_turf(src), "gabe", 80, 1, channel=VOLUME_CHANNEL_EMOTE)
						return SPAN_EMOTE("<b>[src]</b> barks??")
					playsound(src, 'sound/voice/animal/dogbark.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> barks!")
			if ("smile","tail")
				if (src.emote_check(voluntary, 30))
					return SPAN_EMOTE("<b>[src]</b> wags [his_or_her(src)] tail happily!")
			if ("frown","growl")
				if (src.emote_check(voluntary, 30))
					return SPAN_EMOTE("<b>[src]</b>'s growls!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","bark")
				return 2
			if ("smile","tail")
				return 1
			if ("frown","growl")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(30))
			src.icon_state = "[src.dogtype]-lying"
			src.setStatus("unconscious", 10 SECONDS)
			src.setStatus("stunned", 10 SECONDS)
			src.setStatus("knockdown", 10 SECONDS)
			src.visible_message(SPAN_NOTICE("[src] flops on [his_or_her(src)] back! Scratch that belly!"),\
			SPAN_NOTICE("You flop on your back!"))
			SPAWN(3 SECONDS)
				if (src && !isdead(src))
					src.delStatus("unconscious")
					src.changeStatus("stunned", 10 SECONDS)
					src.delStatus("knockdown")
					src.icon_state = src.dogtype

	Life(datum/controller/process/mobs/parent)
		if (..())
			return TRUE

		//Dogs bark sometimes
		if (src.ai?.enabled && prob(1))
			src.emote("scream", TRUE)

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/pounce/pounce = src.abilityHolder.getAbility(/datum/targetable/critter/pounce)
		if (!pounce.disabled && pounce.cooldowncheck() && prob(50))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> barrels into [target] and trips [him_or_her(target)]!"), SPAN_COMBAT("You run into [target]!"))
			pounce.handleCast(target)
			return TRUE

	critter_basic_attack(mob/target)
		src.set_hand(2) //mouth
		return ..()

	disposing()
		. = ..()
		UnregisterSignal(src, COMSIG_MOB_THROW_ITEM_NEARBY)

	proc/throw_response(target, obj/item/item, mob/thrower)
		// Only ai dogs should play fetch
		if (src == thrower || is_incapacitated(src) || !istype(item) || !src.ai?.enabled || length(src.ai.priority_tasks) > 0)
			return
		if(prob(30)) //sometimes dogs don't feel like playing fetch
			return
		var/obj/item/the_item = item
		if (the_item.w_class >= W_CLASS_NORMAL)
			return
		src.fetch_item = item
		src.fetch_playmate = thrower
		src.ai.priority_tasks += src.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/dog/fetch, list(src.ai, src.ai.default_task))
		src.ai.interrupt()
		src.visible_message(SPAN_ALERT("[src] barks and starts running after [item]."))
		src.emote("scream")

	pug
		weak
			add_abilities = list()
			health_brute = 10
			health_burn = 10

/* -------------------- Reverse Pug -------------------- */
// the people demanded it
/mob/living/critter/small_animal/dog/reverse
	name = "god ecaps"
	real_name = "god ecaps"
	icon_state = "gup"
	icon_state_dead = "pug-lying"
	dogtype = "gup"
	speechverb_say = "skrab"
	speechverb_exclaim = "slwoh"
	speechverb_ask = "spiy"
	speechverb_stammer = "sremmats"
	speechverb_gasp = "spsag"
	player_can_spawn_with_pet = FALSE

	mob_flags = SPEECH_REVERSE
	/*
	say(var/message)
		message = strip_html(trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))
		if (!message)
			return
		if (dd_hasprefix(message, "*") && !src.stat)
			return ..()
		message = reverse_text(message)
		..(message)*/

	visible_message(var/message, var/self_message, var/blind_message, var/group)
		message = "<span style='-ms-transform: rotate(180deg)'>[message]</span>"
		if(self_message)
			self_message = "<span style='-ms-transform: rotate(180deg)'>[self_message]</span>"
		if(blind_message)
			blind_message = "<span style='-ms-transform: rotate(180deg)'>[blind_message]</span>"
		return ..(message,self_message,blind_message,group)

	audible_message(var/msg)
		msg = "<span style='-ms-transform: rotate(180deg)'>[msg]</span>"
		return ..(msg)



	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/dogbark.ogg', 80, FALSE, 0, -1, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> bark bark bark!")

/* -------------------- Corgi -------------------- */

/mob/living/critter/small_animal/dog/corgi
	icon_state = "corgi"
	icon_state_dead = "corgi-lying"
	dogtype = "corgi"

	weak
		add_abilities = list()
		health_brute = 10
		health_burn = 10

/* -------------------- George -------------------- */

/mob/living/critter/small_animal/dog/george
	name = "George"
	real_name = "George"
	desc = "Good dog."
	icon_state = "george"
	icon_state_dead = "george-lying"
	butcherable = BUTCHER_NOT_ALLOWED
	health_brute = 100
	health_burn = 100
	dogtype = "george"
	var/playing_dead = 0 // code mostly just c/p from possums, I'll shove this up on the parent somewhere at some point
	player_can_spawn_with_pet = FALSE

	New(loc)
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","bark","howl")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/animal/howl[rand(1,6)].ogg", 30, 1, channel=VOLUME_CHANNEL_EMOTE) // FUCK hearing a dog howling like it's dying at that volume as a near constant
					return SPAN_EMOTE("<b>[src]</b> [pick("barks","howls")]!")
		return ..()

	specific_emote_type(var/act)
		switch (act)
			if ("scream","bark","howl")
				return 2
		return ..()

	Life(datum/controller/process/mobs/parent)
		src.play_dead()
		. = ..(parent)

	death(var/gibbed)
		if (gibbed)
			return ..()
		else if (src.playing_dead)
			return
		else
			src.play_dead(rand(40,60))

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (I.force && src.playing_dead)
			src.playing_dead = 1
			src.play_dead()

	was_harmed(mob/M, obj/item/weapon, special, intent)
		. = ..()
		M.add_karma(-1)

	proc/play_dead(var/addtime = 0)
		if (addtime > 0) // we're adding more time
			if (src.playing_dead <= 0) // we don't already have time on the clock
				src.icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead" // so we gotta show the message + change icon + etc
				src.visible_message(SPAN_ALERT("<b>[src]</b> [pick("tires","tuckers out","gets pooped")] and lies down!!"),\
				SPAN_ALERT("<b>You get [pick("tired","tuckered out","pooped")] and lie down!!</b>"))
				src.set_density(0)
			src.playing_dead = clamp((src.playing_dead + addtime), 0, 100)
		if (src.playing_dead <= 0)
			return
		if (src.playing_dead == 1)
			src.playing_dead = 0
			src.set_density(1)
			src.full_heal()
			src.visible_message(SPAN_NOTICE("<b>[src]</b> wags [his_or_her(src)] tail and gets back up!"))
			boutput(src, SPAN_NOTICE("<b>You wag your tail and get back up!</b>")) // visible_message doesn't go through when this triggers
			src.hud.update_health()
			return
		else
			setunconscious(src)
			src.setStatus("unconscious", 10 SECONDS)
			src.setStatus("stunned", 10 SECONDS)
			src.setStatus("knockdown", 10 SECONDS)
			src.sleeping = 10
			src.playing_dead--
			src.hud.update_health()

	proc/howl()
		src.audible_message(SPAN_COMBAT("<b>[src]</b> [pick("howls","bays","whines","barks","croons")] to the music! [capitalize(he_or_she(src))] thinks [he_or_she(src)]'s singing!"))
		playsound(src, "sound/voice/animal/howl[rand(1,6)].ogg", 30, 0) // FUCK hearing a dog howling like it's dying at that volume as a near constant


/* -------------------- Shiba -------------------- */
/mob/living/critter/small_animal/dog/shiba
	icon_state = "shiba"
	icon_state_dead = "shiba-lying"
	dogtype = "shiba"
	var/randomize_shiba = 1
	var/static/list/shiba_names = list("Maru", "Coco", "Foxtrot", "Nectarine", "Moose", "Pecan", "Daikon", "Seaweed")

	New()
		..()
		if (src.randomize_shiba)
			src.name = pick(src.shiba_names)
			src.real_name = src.name

	weak
		add_abilities = list()
		health_brute = 10
		health_burn = 10

/* -------------------- Illegal -------------------- */

/mob/living/critter/small_animal/dog/illegal
	name = "highly illegal dog"
	real_name = "highly illegal dog"
	desc = "A highly illegal dog. In space."
	icon_state = "illegal"
	icon_state_dead = "illegal-lying"
	dogtype = "illegal"
	player_can_spawn_with_pet = FALSE

/* -------------------- Vaguely Illegal -------------------- */

/mob/living/critter/small_animal/dog/patrick
	name = "patrick"
	real_name = "patrick"
	desc = "patrick. In space."
	icon_state = "patrick"
	icon_state_dead = "patrick-dead"
	dogtype = "patrick"
	player_can_spawn_with_pet = FALSE

/* -------------------- Blair -------------------- */

/mob/living/critter/small_animal/dog/blair
	name = "Blair"
	real_name = "Blair"
	icon_state = "pug"
	dogtype = "pug"
	is_pet = 2
	player_can_spawn_with_pet = FALSE

	attack_hand(mob/user)
		if (prob(5) && isalive(src) && ispug(user))
			src.visible_message(SPAN_COMBAT("<b>[src]</b> pets [user]!"))
		else
			..()

/mob/living/critter/small_animal/dog/george/orwell
	name = "Orwell"
	icon_state = "corgi"
	icon_state_dead = "corgi-lying"
	dogtype = "corgi"
	is_pet = 2
	player_can_spawn_with_pet = FALSE

/* ============================================== */
/* -------------------- Bird -------------------- */
/* ============================================== */

/mob/living/critter/small_animal/bird
	name = "space parrot"
	real_name = "space parrot"
	desc = "A spacefaring species of parrot."
	icon = 'icons/misc/bird.dmi'
	icon_state = "parrot"
	icon_state_dead = "parrot-dead"
	speechverb_say = "chirps"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "squawks"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak squawk and keels over."
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 2
	pet_text = list("pets","cuddles","snuggles","scritches")
	add_abilities = list(/datum/targetable/critter/peck)
	var/species = "parrot"
	var/hops = 0
	var/hat_offset_y = -5
	var/hat_offset_x = 0
	var/feather_color = "#ba1418"
	var/last_feather_time = 0
	var/bird_call_msg = list("squawks", "shrieks")
	var/bird_call_sound = list('sound/voice/animal/squawk1.ogg','sound/voice/animal/squawk2.ogg', 'sound/voice/animal/squawk3.ogg')
	var/icon_state_poof = null // atm used for male turkeys and nothing else
	var/good_grip = 1 // they can hold any sized item because they are stronk birbs, otherwise small_critter limb
	health_brute = 15
	health_burn = 15
	pull_w_class = W_CLASS_BULKY
	player_can_spawn_with_pet = TRUE

	New(loc, nspecies)
		..()
		if (nspecies)
			src.apply_species(nspecies, 0)
		src.bioHolder.AddNewPoolEffect("beak_peck", scramble=TRUE)


	get_desc()
		..()
		if (src.equipped())
			. += "<br>[src] is holding \a [src.equipped()]."

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		if (src.good_grip >= 1)
			HH.limb = new /datum/limb
		else if (src.good_grip > 0) //values of 0.5 will give us medium strength
			HH.limb = new /datum/limb/small_critter/med
		else
			HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "claw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "beak"					// name for the dummy holder
		HH.can_hold_items = 0

	update_inhands()
		return // stop taping things to bird face, unwanted.  do not.

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears(src)
		equipment += new /datum/equipmentHolder/head/bird(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (bird_call_sound)
						playsound(src, bird_call_sound, 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> [islist(src.bird_call_msg) ? pick(src.bird_call_msg) : src.bird_call_msg]!")
			if ("smile","wink","poof")
				if (src.emote_check(voluntary, 30))
					if (src.icon_state_poof)
						src.icon_state = src.icon_state_poof
						SPAWN(3 SECONDS)
							if (src && !isdead(src))
								src.icon_state = src.species
					if (prob(3))
						SPAWN(0)
							src.create_feather()
					return SPAN_EMOTE("<b>[src]</b> [pick("poofs", "fluffs")] up!")
			if ("snap","click")
				if (src.emote_check(voluntary, 50))
					if (src.species == "goose" || src.species == "swan") // hardcoded thing because im loaf 2day.
						playsound(src, 'sound/voice/animal/cat_hiss.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
						return SPAN_EMOTE("<b>[src]</b> hisses!")
					else
						return SPAN_EMOTE("<b>[src]</b> clicks [his_or_her(src)] beak!")
			if ("dance","flap")
				if (src.emote_check(voluntary, 50))
					if (prob(20))
						src.icon_state = "[src.species]-flap"
						if (prob(3))
							SPAWN(0)
								src.create_feather()
						SPAWN(3.8 SECONDS)
							if (src && !isdead(src))
								src.icon_state = src.species
						return SPAN_EMOTE("<b>[src]</b> dances!")
					else
						FLICK("[src.species]-flaploop", src)
						if (prob(3))
							SPAWN(0)
								src.create_feather()
						return SPAN_EMOTE("<b>[src]</b> flaps and bobs happily!")
			if ("hiss")
				if ((src.species == "goose" || src.species == "swan") && src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/cat_hiss.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> hisses!")
			if ("wave","fuss","fussle")
				if (src.emote_check(voluntary, 50))
					var/holding_thing = src.equipped()
					if (holding_thing)
						if (prob(3))
							SPAWN(0)
								src.create_feather()
						return SPAN_EMOTE("<b>[src]</b> [pick("fusses with", "picks at", "pecks at", "throws around", "waves around", "nibbles on", "chews on", "tries to pry open")] [holding_thing].")

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("smile","wink","poof")
				return 1
			if ("snap","click")
				return 2
			if ("dance","flap")
				return 1
			if ("hiss")
				return 2
			if ("wave","fuss","fussle")
				return 1
		return ..()

	proc/apply_species(var/new_species = null, var/apply_random = 0)
		if (!(istext(new_species) || ispath(new_species)) || !islist(parrot_species)) // farrrrrtttt
			return

		if (islist(mob_bird_species) && mob_bird_species.Find(new_species))
			var/mob/living/critter/small_animal/bird/B = mob_bird_species[new_species]

			if ((src.species != "goose" && src.species != "swan") && (new_species == "goose" || new_species == "swan")) // add a tackle
				abilityHolder.addAbility(/datum/targetable/critter/tackle)
			else if ((src.species == "goose" || src.species == "swan") && (new_species != "goose" && new_species != "swan"))
				abilityHolder.removeAbility(/datum/targetable/critter/tackle) // remove a tackle
			abilityHolder.updateButtons()

			src.name = initial(B.name)
			src.real_name = initial(B.real_name)
			src.desc = initial(B.desc)
			src.species = initial(B.species)
			src.gender = initial(B.gender)
			src.icon = initial(B.icon)
			src.icon_state = initial(B.icon_state)
			src.icon_state_alive = initial(B.icon_state_alive)
			src.icon_state_dead = initial(B.icon_state_dead)
			src.icon_state_poof = initial(B.icon_state_poof)
			src.flags = initial(B.flags)
			src.fits_under_table = initial(B.fits_under_table)
			src.hops = initial(B.hops)
			src.hat_offset_y = initial(B.hat_offset_y)
			src.hat_offset_x = initial(B.hat_offset_x)
			src.feather_color = initial(B.feather_color)
			src.good_grip = initial(B.good_grip)
			src.bird_call_msg = initial(B.bird_call_msg)
			src.bird_call_sound = initial(B.bird_call_sound)
			src.health_brute = initial(B.health_brute)
			src.health_burn = initial(B.health_burn)
			src.update_clothing()
			return

		var/datum/species_info/parrot/info = ispath(new_species) ? new_species : parrot_species[new_species]
		if (!ispath(info))
			info = special_parrot_species[new_species]
			if (!ispath(info))
				return

		if (apply_random)
			var/list/rand_s = initial(info.subspecies)
			if (islist(rand_s) && length(rand_s))
				info = pick(rand_s)

		src.name = initial(info.name)
		src.real_name = src.name
		src.desc = initial(info.desc)
		src.species = initial(info.species)
		src.gender = initial(info.gender)
		src.icon = initial(info.icon)
		src.icon_state = src.species
		src.icon_state_alive = src.species
		src.icon_state_dead = "[src.species]-dead"
		src.pixel_x = initial(info.pixel_x)
		src.hops = initial(info.hops)
		src.hat_offset_y = initial(info.hat_offset_y)
		src.hat_offset_x = initial(info.hat_offset_x)
		src.feather_color = params2list(initial(info.feather_color))
		src.update_clothing()

	Move(var/atom/NewLoc, direct)
		.=..()
		if (prob(1) && prob(22) && (src.last_feather_time + 3000) <= world.time)
			src.create_feather()
		if (src.hops)
			var/opy = pixel_y
			animate( src )
			animate( src, pixel_y = 10, easing = SINE_EASING, time = ((NewLoc.y-y)>0)?3:1 )
			animate( pixel_y = opy, easing = SINE_EASING, time = 3 )
			playsound( get_turf(src), "sound/misc/boing/[rand(1,6)].ogg", 20, 1 )

	proc/create_feather(var/turf/T)
		if (!T)
			T = src.loc
		var/obj/item/feather/F = new(T)
		if (islist(src.feather_color))
			F.color = pick(src.feather_color)
		else
			F.color = src.feather_color
		src.visible_message("A feather falls off of [src].")
		src.last_feather_time = world.time
		return F

var/list/mob_bird_species = list("smallowl" = /mob/living/critter/small_animal/bird/owl,
	"owl" = /mob/living/critter/small_animal/bird/owl/large,
	"hooty" = /mob/living/critter/small_animal/bird/owl/large/hooty,
	"then" = /mob/living/critter/small_animal/bird/turkey/hen,
	"ttom" = /mob/living/critter/small_animal/bird/turkey/gobbler,
	"gull" = /mob/living/critter/small_animal/bird/seagull,
	"gannet" = /mob/living/critter/small_animal/bird/seagull/gannet,
	"crow" = /mob/living/critter/small_animal/bird/crow,
	"goose" = /mob/living/critter/small_animal/bird/goose,
	"swan" = /mob/living/critter/small_animal/bird/goose/swan,
	"cassowary" = /mob/living/critter/small_animal/bird/cassowary,
	"penguin" = /mob/living/critter/small_animal/bird/penguin)

/* -------------------- Random Parrot -------------------- */

/mob/living/critter/small_animal/bird/random
	species = null
	player_can_spawn_with_pet = TRUE
	New()
		..()
		if (!src.species)
			if (prob(1) && prob(10))
				src.apply_species(pick(special_parrot_species))
				return
			src.apply_species(pick(parrot_species))
			return

/* -------------------- Selectable Parrot -------------------- */

/mob/living/critter/small_animal/bird/selected
	species = null
	player_can_spawn_with_pet = FALSE
	New()
		..()
		SPAWN(0)
			if (!src.species && src.client && islist(parrot_species) && islist(special_parrot_species))
				var/new_species = input(src, "Select Species", "Select Species") as anything in (parrot_species + special_parrot_species)
				if (new_species)
					src.apply_species(new_species)

/* -------------------- Cassowary -------------------- */

/mob/living/critter/small_animal/bird/cassowary
	name = "cassowary"
	real_name = "cassowary"
	desc = "An exotic bird from the far away land of Space Australia."
	icon_state = "cassowary"
	icon_state_dead = "cassowary-dead"
	death_text = "%src% lets out a final squawk and keels over."
	good_grip = 0.5
	flags = null
	fits_under_table = 0
	species = "cassowary"

/* -------------------- Penguin -------------------- */

/mob/living/critter/small_animal/bird/penguin
	name = "penguin"
	real_name = "penguin"
	desc = "Its a penguin. They like the cold."
	icon_state = "penguin"
	icon_state_dead = "penguin-dead"
	death_text = "%src% lets out a final squawk and keels over."
	good_grip = 0
	flags = null
	fits_under_table = 0
	health_brute = 30
	health_burn = 30
	species = "penguin"
	ai_retaliates = TRUE
	ai_retaliate_patience = 0 //retaliate when hit immediately
	ai_retaliate_persistence = RETALIATE_ONCE //but just hit back once
/* -------------------- Owl -------------------- */

/mob/living/critter/small_animal/bird/owl
	name = "space owl"
	real_name = "space owl"
	desc = "Did you know? By 2063, it is expected that there will be more owls on Earth than human beings."
	icon_state = "smallowl"
	icon_state_dead = "smallowl-dead"
	speechverb_say = "hoos"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak hoot and keels over."
	feather_color = list("#803427","#7d5431")
	good_grip = 0
	species = "smallowl"
	bird_call_msg = list("hoots", "hoos")
	bird_call_sound = 'sound/voice/animal/hoot.ogg'

	attackby(obj/item/W, mob/M)
		if(istype(W, /obj/item/plutonium_core/hootonium_core)) //Owls interestingly are capable of absorbing hootonium into their bodies harmlessly. This is the only safe method of removing it.
			playsound(M.loc, 'sound/items/eatfood.ogg', 100, 1)
			boutput(M, SPAN_ALERT("<B>You feed the [src] the [W]. It looks [pick("confused", "annoyed", "worried", "satisfied", "upset", "a tad miffed", "at you and winks")].</B>"))
			M.drop_item()
			W.set_loc(src)

			SPAWN(1 MINUTE)
				src.visible_message(SPAN_ALERT("<B>The [src] suddenly regurgitates something!</B>"))
				playsound(src, pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
				make_cleanable( /obj/decal/cleanable/greenpuke,src.loc)

				for(var/turf/T in range(src, 2))
					if(prob(20))
						playsound(T, pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
						make_cleanable( /obj/decal/cleanable/greenpuke,T)

				new /obj/item/power_stones/Owl(src.loc)
		else
			. = ..()

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl
	name = "owl egg"
	critter_type = /mob/living/critter/small_animal/bird/owl

/* -------------------- Large Owl -------------------- */

/mob/living/critter/small_animal/bird/owl/large
	icon_state = "owl"
	icon_state_dead = "owl-dead"
	species = "owl"
	feather_color = list("#b59b76","#87683d","#632c0c")
	flags = null
	fits_under_table = 0
	health_brute = 30
	health_burn = 30
	good_grip = 0.5

/* -------------------- Hooty -------------------- */

/mob/living/critter/small_animal/bird/owl/large/hooty
	icon_state = "hooty"
	icon_state_dead = "hooty-dead"
	species = "hooty"
	feather_color = "#806055"
	player_can_spawn_with_pet = FALSE

/* -------------------- Hooter -------------------- */

/mob/living/critter/small_animal/bird/owl/large/hooter
	icon_state = "bhooty"
	icon_state_dead = "bhooty-dead"
	species = "bhooty"
	desc = "A space owl wearing a bikini. Hang on. That's not a bikini! That's just pink feathers!"
	feather_color = list("#806055","#ff0066")
	add_abilities = list(/datum/targetable/critter/hootat)
	player_can_spawn_with_pet = FALSE

/* -------------------- Turkey -------------------- */

/mob/living/critter/small_animal/bird/turkey
	name = "space turkey"
	real_name = "space turkey"
	desc = "A turkey that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "then"
	icon_state_dead = "then-dead"
	speechverb_say = "gobbles"
	speechverb_exclaim = "calls"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak gobble and keels over."
	feather_color = "#632c0c"
	flags = null
	fits_under_table = 0
	bird_call_msg = "gobbles"
	bird_call_sound = 'sound/voice/animal/turkey.ogg'
	good_grip = 0.5
	health_brute = 20
	health_burn = 20
	species = null
	gender = FEMALE

	New()
		..()
		var/set_gender = initial(src.gender)
		if (!src.species)
			src.species = pick("then", "ttom")
			src.apply_species(src.species)
			if (src.species == "ttom")
				set_gender = MALE
			else
				set_gender = FEMALE
		SPAWN(0)
			src.gender = set_gender // stop changing!!  stay how I set you!!!!

	butcher(mob/user)
		new /obj/item/reagent_containers/food/snacks/ingredient/turkey(get_turf(src))
		return ..(user, drop_brain = FALSE, drop_meat = FALSE)

/* -------------------- Turkey Hen -------------------- */

/mob/living/critter/small_animal/bird/turkey/hen
	species = "then"
	feather_color = "#632c0c"

/* -------------------- Turkey Gobbler -------------------- */

/mob/living/critter/small_animal/bird/turkey/gobbler
	icon_state = "ttom"
	species = "ttom"
	icon_state_dead = "ttom-dead"
	icon_state_poof = "ttom-poof"
	health_brute = 30
	health_burn = 30
	gender = MALE

/* -------------------- Timberdoodle -------------------- */

/mob/living/critter/small_animal/bird/timberdoodle
	name = "space timberdoodle"
	real_name = "space timberdoodle"
	desc = "More commonly known as a woodcock, the timberdoodle is a small bird within the <i>scolopacidae</i> family. It is commonly hunted for sport."
	species = "doodle"
	icon_state = "doodle"
	icon_state_dead = "doodle-dead"
	icon_state_poof = "doodle-poof"
	speechverb_say = "eents"
	speechverb_exclaim = "calls"
	speechverb_ask = "peents"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "chirps"
	death_text = "%src% lets out a final weak eent and keels over."
	feather_color = list("#ffd0a4","#cc9475","#b85a39","#572c26")
	bird_call_msg = list("peents", "eents")
	bird_call_sound = 'sound/voice/animal/woodcock.ogg'
	good_grip = 0
	health_brute = 20
	health_burn = 20

/mob/living/critter/small_animal/bird/timberdoodle/strong
	health_brute = 35
	health_burn = 35
	good_grip = 1
	player_can_spawn_with_pet = FALSE

	New()
		. = ..()
		src.remove_stam_mod_max("small_animal")

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		if(act == "flip" && istype(src.equipped(), /obj/item/grab) && src.emote_check(voluntary, 50))
			return src.do_suplex(src.equipped())
		return null

/* -------------------- Seagull -------------------- */

/mob/living/critter/small_animal/bird/seagull
	name = "space gull"
	real_name = "space gull"
	desc = "A spacefaring species of bird from the <i>Laridae</i> family."
	icon_state = "gull"
	icon_state_dead = "gull-dead"
	speechverb_say = "laughs"
	speechverb_exclaim = "calls"
	speechverb_ask = "caws"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak caw and keels over."
	feather_color = list("#ffffff","#949494","#353535")
	good_grip = 0
	species = "gull"

/* -------------------- Gannet -------------------- */

/mob/living/critter/small_animal/bird/seagull/gannet  // they're technically not gulls but they're gunna use basically all the same var settings so, um
	name = "space gannet"
	real_name = "space gannet"
	desc = "A spacefaring species of <i>morus bassanus</i>."
	icon_state = "gannet"
	icon_state_dead = "gannet-dead"
	species = "gannet"
	feather_color = list("#ffffff","#d4bb2f","#414141")

/* -------------------- Crow -------------------- */

/mob/living/critter/small_animal/bird/crow
	name = "space crow"
	real_name = "space crow"
	desc = "A spacefaring species of bird from the <i>Corvidae</i> family."
	icon_state = "crow"
	icon_state_dead = "crow-dead"
	speechverb_say = "caws"
	speechverb_exclaim = "calls"
	speechverb_ask = "caws"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak caw and keels over."
	feather_color = "#212121"
	good_grip = 1
	fits_under_table = 0
	species = "crow"
	add_abilities = list(/datum/targetable/critter/peck/crow)

	New()
		..()
		if (prob(5))
			src.name = replacetext(src.name, "crow", "raven")
			if (src.name != initial(src.name))
				src.real_name = src.name

/mob/living/critter/small_animal/bird/crow/strong
	health_brute = 30
	health_burn = 30
	player_can_spawn_with_pet = FALSE

/mob/living/critter/small_animal/bird/crow/strong/strongest
	name = "starry crow"
	icon_state = "space"
	health_brute = 100
	health_burn = 100
	player_can_spawn_with_pet = FALSE

/* -------------------- Goose -------------------- */

/mob/living/critter/small_animal/bird/goose
	name = "space goose"
	real_name = "space goose"
	desc = "An offshoot species of <i>branta canadensis</i> adapted for space."
	icon_state = "goose"
	icon_state_dead = "goose-dead"
	speechverb_say = "honks"
	speechverb_exclaim = "calls"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
	death_text = "%src% lets out a final weak honk and keels over."
	feather_color = list("#393939","#f2ebd5","#68422a","#ffffff")
	flags = null
	fits_under_table = FALSE
	good_grip = 0.5
	bird_call_msg = "honks"
	bird_call_sound = 'sound/voice/animal/goose.ogg'
	species = "goose"
	health_brute = 30
	health_burn = 30
	add_abilities = list(/datum/targetable/critter/peck, /datum/targetable/critter/tackle)
	ai_type = /datum/aiHolder/aggressive

	on_pet(var/mob/user)
		if(..())
			return

		if(prob(10))
			src.audible_message("<b>[src]</b> honks!")
			playsound(src.loc, 'sound/voice/animal/goose.ogg', 50, 1)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, 'sound/voice/animal/goose.ogg', 70, 1, channel = VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] honks!</b>")
			if ("flip", "flap")
				if (src.emote_check(voluntary, 50))
					if (isobj(src.loc))
						var/obj/container = src.loc
						container.mob_flip_inside(src)
					FLICK("[src.icon_state]-flap", src)
					playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1, channel = VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] hisses!</b>")
		return null

	seek_target(var/range = 4)
		. = ..()

		if (length(.) && prob(10))
			src.emote("flap")

	critter_basic_attack(mob/target)
		FLICK("[src.icon_state]-flap", src)
		playsound(src.loc, "swing_hit", 30, 0)
		..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/peck = src.abilityHolder.getAbility(/datum/targetable/critter/peck)
		if (!peck.disabled && peck.cooldowncheck())
			peck.handleCast(target)
			return TRUE
/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/goose
	name = "goose egg"
	critter_type = /mob/living/critter/small_animal/bird/goose

/* -------------------- Swan -------------------- */

/mob/living/critter/small_animal/bird/goose/swan
	name = "space swan"
	real_name = "space swan"
	desc = "An offshoot species of <i>cygnus olor</i> adapted for space."
	icon_state = "swan"
	icon_state_dead = "swan-dead"
	feather_color = "#FFFFFF"
	species = "swan"

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/swan
	name = "swan egg"
	critter_type = /mob/living/critter/small_animal/bird/goose/swan

/* =============================================== */
/* ------------------- Sparrow ------------------- */
/* =============================================== */

/* These are almost identical to space mice, but throwing them here directly under birbs */

/mob/living/critter/small_animal/sparrow
	name = "space sparrow"
	real_name = "space sparrow"
	desc = "A little bird. How cute."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2
	icon_state = "sparrow"
	icon_state_dead = "sparrow-dead"
	speechverb_say = "chirps"
	speechverb_exclaim = "chitters"
	speechverb_ask = "peeps"
	health_brute = 8
	health_burn = 8
	player_can_spawn_with_pet = TRUE

	New()
		..()
		fur_color =	"#ac5e41"
		eye_color = "#000000"

	setup_overlays()
		fur_color = src.client?.preferences.AH.customizations["hair_bottom"].color
		eye_color = src.client?.preferences.AH.e_color
		var/image/overlay = image('icons/misc/critter.dmi', "sparrow_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "sparrow_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		src.ClearAllOverlays()
		var/image/overlay = image('icons/misc/critter.dmi', "sparrow_colorkey-dead")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")
		..()

	full_heal()
		..()
		src.ClearAllOverlays()
		src.setup_overlays()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 40, TRUE, 0.1, 1.3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chirps!")
			if ("dance")
				if (src.emote_check(voluntary, 50))
					animate_bouncy(src)
					return SPAN_EMOTE("<b>[src]</b> hops about with joy!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("dance")
				return 1
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "foot"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "beak"					// the icon state of the hand UI background
		HH.name = "beak"						// designation of the hand - purely for show
		HH.limb_name = "beak"					// name for the dummy holder
		HH.can_hold_items = 0

/mob/living/critter/small_animal/sparrow/weak
	health_brute = 2
	health_burn = 2
	player_can_spawn_with_pet = FALSE

/* -------------------- Robin -------------------- */

/mob/living/critter/small_animal/sparrow/robin
	name = "space robin"
	real_name = "space robin"
	desc = "It's a little far from home."
	icon_state = "robin"
	icon_state_dead = "robin-dead"

	New()
		..()
		fur_color =	"#836857"
		eye_color = "#000000"

	setup_overlays()
		fur_color = src.client?.preferences.AH.customizations["hair_bottom"].color
		eye_color = src.client?.preferences.AH.e_color
		var/image/overlay = image('icons/misc/critter.dmi', "robin_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "sparrow_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		src.ClearAllOverlays()
		var/image/overlay = image('icons/misc/critter.dmi', "robin_colorkey-dead")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")
		..()

/mob/living/critter/small_animal/sparrow/robin/weak
	health_brute = 2
	health_burn = 2

/* =================================================== */
/* -------------------- Cockroach -------------------- */
/* =================================================== */

/mob/living/critter/small_animal/cockroach
	name = "cockroach"
	real_name = "cockroach"
	blood_id = "hemolymph"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	icon_state_dead = "roach-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 5
	health_burn = 5
	flags = TABLEPASS | DOORPASS
	faction = list(FACTION_NEUTRAL)
	fits_under_table = 1
	ai_type = /datum/aiHolder/roach
	ai_retaliates = FALSE
	player_can_spawn_with_pet = TRUE

	New()
		.=..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		START_TRACKING_CAT(TR_CAT_BUGS)
		src.bioHolder.AddNewPoolEffect("radioactive", scramble=TRUE)
		src.bioHolder.AddNewPoolEffect("skitter", scramble=TRUE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

	setup_healths()
		. = ..()
		qdel(src.healthlist["toxin"])
		src.healthlist -= "toxin"

	setup_overlays()
		fur_color = src.client?.preferences.AH.customizations["hair_bottom"].color
		eye_color = src.client?.preferences.AH.e_color

		var/image/overlay = image('icons/misc/critter.dmi', "roach_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image('icons/misc/critter.dmi', "roach_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		if (fur_color)
			var/image/overlay = image('icons/misc/critter.dmi', "roach_colorkey-dead")
			overlay.color = fur_color
			src.UpdateOverlays(overlay, "hair")
		..()


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chitters!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	attack_hand(mob/living/M)
		if (ishuman(M) && M.a_intent == INTENT_HARM)
			if(isdead(src))
				src.visible_message(SPAN_COMBAT("<B>[M] squishes [src] a little more for good measure.</B>"))
				return
			else
				if (prob(95))
					src.visible_message(SPAN_COMBAT("<B>[M] stomps [src], killing it instantly!</B>"))
					src.death()
					return
				else
					src.visible_message(SPAN_ALERT("Against all odds, [src] stops [M]'s foot and throws [him_or_her(M)] off balance! Woah!"), SPAN_ALERT("You use all your might to stop [M]'s foot before it crushes you!"))
					M.setStatus("knockdown", 5 SECONDS)
					return
		. = ..()

/* =================================================== */
/* -------------------- Scorpion --------------------- */
/* =================================================== */

/mob/living/critter/small_animal/scorpion
	name = "scorpion"
	real_name = "scorpion"
	blood_id = "hemolymph"
	desc = "Ack! Get it away! AAAAAAAA."
	icon_state = "spacescorpion"
	icon_state_dead = "spacescorpion-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 30
	health_burn = 30
	density = TRUE
	flags = TABLEPASS
	fits_under_table = TRUE
	can_lie = FALSE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliate_patience = 1
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	aggressive = TRUE
	player_can_spawn_with_pet = TRUE

	add_abilities = list(/datum/targetable/critter/wasp_sting/scorpion_sting,
						/datum/targetable/critter/pincer_grab)

	New()
		..()
		START_TRACKING_CAT(TR_CAT_BUGS)
		src.bioHolder.AddNewPoolEffect("scorpion_sting", scramble=TRUE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/pincers
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "pincers"
		HH.name = "pincers"
		HH.limb_name = "pincers"

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/reagent_containers/food/snacks) && ishuman(M) && !isdead(src))
			src.visible_message("[M] feeds \the [src] some [I].", "[M] feeds you some [I].")
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(5)
			src.health_brute = min(60, src.health_brute + 6)
			src.health_burn = min(60, src.health_burn + 6)
			if(M in src.friends)
				src.emote("chitter")
			else
				if(prob(20))
					friends += M
					src.visible_message("[src] chitters happily at the \the [I], and seems a little friendlier with [M].")
					src.emote("chitter")
				else
					src.visible_message(SPAN_NOTICE("[src] hated \the [I] and bit [M]'s hand!"))
					random_brute_damage(M, rand(6,12),1)
					src.emote("snip")
					M.emote("scream")
			I.Eat(src, src, TRUE)
			return
		. = ..()

	attack_hand(mob/M)
		if ((M.a_intent != INTENT_HARM) && (M in src.friends))
			if(M.a_intent == INTENT_HELP && src.aggressive)
				src.visible_message(SPAN_NOTICE("[M] pats [src] on the head in a soothing way. It won't attack anyone now."))
				src.aggressive = FALSE
				src.ai_retaliates = FALSE
				return
			else if((M.a_intent == INTENT_DISARM) && !src.aggressive)
				src.visible_message(SPAN_NOTICE("[M] shakes [src] to awaken [his_or_her(src)] killer instincts!"))
				src.aggressive = TRUE
				src.ai_retaliates = TRUE
				return
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chitters!")
			if ("snip", "snap")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Wirecutter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> snips its pincers!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter", "snip", "snap")
				return 2
		return ..()

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/wasp_sting/scorpion_sting/sting = src.abilityHolder.getAbility(/datum/targetable/critter/wasp_sting/scorpion_sting)
		var/datum/targetable/critter/pincer_grab/pincer_grab = src.abilityHolder.getAbility(/datum/targetable/critter/pincer_grab)

		if (!sting.disabled && sting.cooldowncheck() && prob(50))
			sting.handleCast(target)
			return TRUE
		if (!pincer_grab.disabled && pincer_grab.cooldowncheck() && prob(50))
			pincer_grab.handleCast(target)
			return TRUE

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/small_animal/rattlesnake)) return FALSE //don't attack space rattlesnakes(the snake would lose)
		return ..()

	seek_target(var/range = 8)
		if(!src.aggressive)
			return .
		. = ..()

		if(length(.) && prob(25))
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> snips [his_or_her(src)] pincers!"))

	death()
		src.reagents.add_reagent("toxin", 20, null)
		src.reagents.add_reagent("neurotoxin", 80, null)
		qdel(friends)
		return ..()

/* =================================================== */
/* ------------------- Rattlesnake ------------------- */
/* =================================================== */

/mob/living/critter/small_animal/rattlesnake
	name = "rattlesnake"
	real_name = "rattlesnake"
	blood_id = "blood"
	desc = "A snake. With a rattle. A rattlesnake."
	icon_state = "rattlesnake"
	icon_state_dead = "rattlesnake_dead"
	speechverb_say = "hisses"
	speechverb_exclaim = "rattles"
	speechverb_ask = "hisses"
	health_brute = 20
	health_burn = 20
	flags = TABLEPASS
	fits_under_table = TRUE
	can_lie = FALSE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliate_patience = 2
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP //annoy a snake enough and pay the price
	aggressive = TRUE
	player_can_spawn_with_pet = TRUE
	add_abilities = list(/datum/targetable/critter/wasp_sting/snake_bite)

	New()
		..()
		src.bioHolder.AddNewPoolEffect("snake_bite", scramble=TRUE)
		src.bioHolder.AddNewPoolEffect("slither", scramble=TRUE)
		src.AddComponent(/datum/component/proximity)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/reagent_containers/food/snacks) && ishuman(M) && !isdead(src))
			src.visible_message("[M] feeds \the [src] some [I].", "[M] feeds you some [I].")
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(5)
			src.health_brute = min(60, src.health_brute + 6)
			src.health_burn = min(60, src.health_burn + 6)
			if(M in src.friends)
				src.emote("rattle")
			else
				if(prob(20))
					friends += M
					src.visible_message("[src] hisses happily at the \the [I], and seems a little friendlier with [M].")
				else
					src.visible_message(SPAN_NOTICE("[src] hated \the [I] and bit [M]'s hand!"))
					random_brute_damage(M, rand(6,12),1)
					src.emote("hiss")
					M.emote("scream")
			I.Eat(src, src, TRUE)
			return
		. = ..()

	attack_hand(mob/M)
		if ((M.a_intent != INTENT_HARM) && (M in src.friends))
			if(M.a_intent == INTENT_HELP && src.aggressive)
				src.visible_message(SPAN_NOTICE("[M] pats [src] on the head in a soothing way. It won't attack anyone now."))
				src.aggressive = FALSE
				src.ai_retaliates = FALSE
				return
			else if((M.a_intent == INTENT_DISARM) && !src.aggressive)
				src.visible_message(SPAN_NOTICE("[M] shakes [src] to awaken [his_or_her(src)] killer instincts!"))
				src.aggressive = TRUE
				src.ai_retaliates = TRUE
				return
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> hisses!")
			if ("rattle", "snap")
				if (src.emote_check(voluntary, 50) && icon_state == "rattlesnake")
					icon_state = "rattlesnake_rattle"
					playsound(src, 'sound/musical_instruments/tambourine/tambourine_4.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(1 SECONDS)
						if(isalive(src))
							icon_state = "rattlesnake"
					return SPAN_EMOTE("<b>[src]</b> rattles [his_or_her(src)] tail!")
		return null

	specific_emote_type(var/act)
		if(act in list("scream", "hiss", "snip", "snap"))
			return 2
		return ..()

	critter_ability_attack(var/mob/target)
		var/datum/targetable/critter/wasp_sting/snake_bite/sting = src.abilityHolder.getAbility(/datum/targetable/critter/wasp_sting/snake_bite)
		if (!sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
		return TRUE

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/small_animal/scorpion)) return FALSE //don't attack scorpions(they can spawn together)
		if (ishuman(C) || issilicon(C))    //creating the snake's defensive behavior
			if(GET_DIST(src, C) <= 3 && GET_DIST(src, C) >= 1) //it will only actually target humans and silicons if in very close proximity
				if(!ON_COOLDOWN(src, "rattle", 3 SECONDS))      //it will rattle defensively if somewhat close
					icon_state = "rattlesnake_rattle"
					playsound(src, 'sound/musical_instruments/tambourine/tambourine_4.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(1 SECONDS)
						icon_state = "rattlesnake"
					src.visible_message(SPAN_COMBAT("<B>[src]</B> rattles, better not get much closer!"))
				return FALSE
			else if(GET_DIST(src, C) > 3) //humans and silicons that are farther than 3 tiles do not interest the snake
				return FALSE
		return ..()

	seek_target(var/range = 8)
		if(!src.aggressive)
			return .
		. = ..()

		if(length(.) && prob(25))
			playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<B>[src]</B> hisses!"))

	EnteredProximity(atom/movable/AM) //the part where it bites you if you pass by
		if ((ishuman(AM) || issilicon(AM)) && !isintangible(AM) && src.aggressive && !isdead(src) && !src.client && !(AM in src.friends))
			var/datum/targetable/critter/wasp_sting/snake_bite/sting = src.abilityHolder.getAbility(/datum/targetable/critter/wasp_sting/snake_bite)
			if (!sting.disabled && sting.cooldowncheck())
				if (!ON_COOLDOWN(src, "warning", 1 MINUTE)) //snake will not immediately bite, gives a warning strike first
					playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					src.visible_message(SPAN_COMBAT("<b>[src] hisses and gives a warning strike!</b>"))
					if(src.is_npc)
						src.ai.move_away(AM, 2)
				else
					sting.handleCast(AM)
		return

	death()
		src.reagents.add_reagent("hemotoxin", 40, null)
		src.friends = null
		return ..()

/mob/living/critter/small_animal/cockroach/weak
	health_brute = 1
	health_burn = 1

/mob/living/critter/small_animal/cockroach/robo
	name = "roboroach"
	real_name = "roboroach"
	blood_id = "oil"
	desc = "The vermin of the future!"
	health_brute = 10
	health_burn = 10
	icon_state = "robot_roach"
	icon_state_dead = "robot_roach-dead"
	pull_w_class = W_CLASS_NORMAL
	meat_type = /obj/item/reagent_containers/food/snacks/burger/roburger
	has_genes = FALSE

	base_move_delay = 1.6
	base_walk_delay = 2.1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	setup_overlays()
		return


	weak
		health_brute = 5
		health_burn = 5

		setup_hands()
			..()
			var/datum/handHolder/HH = hands[1]
			HH.limb = new /datum/limb/small_critter
			HH.icon = 'icons/mob/critter_ui.dmi'
			HH.icon_state = "handn"
			HH.name = "weird grabby foot thing"
			HH.limb_name = "foot"

/* ================================================ */
/* -------------------- Ferret -------------------- */
/* ================================================ */

/mob/living/critter/small_animal/meatslinky // ferrets for wire
	name = "space ferret"
	real_name = "space ferret"
	desc = "A ferret that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "ferret"
	icon_state_dead = "ferret-dead"
	hand_count = 2
	speechverb_say = "chatters"
	speechverb_exclaim = "squeaks"
	flags = TABLEPASS
	fits_under_table = 1
	var/freakout = 0
	add_abilities = list(/datum/targetable/critter/trip)
	player_can_spawn_with_pet = TRUE

	New()
		..()

		//50% chance to be a dark-colored ferret
		if (prob(50))
			src.icon_state = "ferret-dark"
			src.icon_state_dead = "ferret-dark-dead"

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"
		HH = hands[2]

		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (getStatusDuration("burning"))
			return ..()

		if (isdead(src))
			return 0

		if (src.freakout)
			SPAWN(0)
				var/x = rand(2,4)
				while (x-- > 0)
					src.pixel_x = rand(-6,6)
					src.pixel_y = rand(-6,6)
					sleep(0.2 SECONDS)

			if (prob(5))
				animate_spin(src, pick("L","R"))

			if (prob(10))
				src.visible_message("[src] [pick("wigs out","frolics","rolls about","freaks out","goes wild","wiggles","wobbles")]!")

			if (src.freakout-- < 1)
				src.visible_message("[src] calms down.")
		else if (!src.client && prob(2))
			src.freakout = rand(30,40)
		..()


/* ================================================ */
/* -------------------- Frog ---------------------- */
/* ================================================ */

/mob/living/critter/small_animal/frog
	name = "frog"
	real_name = "frog"
	desc = "Ribbit."
	icon_state = "frog"
	icon_state_dead = "frog-dead"
	hand_count = 2
	speechverb_say = "croaks"
	speechverb_exclaim = "croaks"
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	player_can_spawn_with_pet = TRUE
	var/frog_sound = list('sound/voice/screams/frogscream1.ogg','sound/voice/screams/frogscream3.ogg', 'sound/voice/screams/frogscream4.ogg')

	New()
		if (src.generic && prob(80))
			if (prob(1))
				src.icon_state = "frog-space"
				src.icon_state_dead = "frog-space-dead"
			else
				src.icon_state = "frog[pick("-blue","-gold","-red","-straw","-tree","-glass")]"
				src.icon_state_dead = "[src.icon_state]-dead"
		..()
		src.bioHolder.AddNewPoolEffect("jumpy", scramble=TRUE)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "foot"
		HH.limb_name = "pads"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","croak")
				if (src.emote_check(voluntary, 50))
					if (prob(1))
						playsound(src, frog_sound, 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
						return SPAN_EMOTE("<b>[src]</b> makes a horrifying noise!")
					else
						playsound(src, 'sound/misc/croak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
						return SPAN_EMOTE("<b>[src]</b> croaks!")

	weak
		health_brute = 10
		health_burn = 10

/* ================================================ */
/* -------------------- Possum -------------------- */
/* ================================================ */

/mob/living/critter/small_animal/opossum
	name = "space opossum"
	real_name = "space opossum"
	desc = "A possum that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "possum"
	icon_state_dead = "possum-dead"
	hand_count = 2
	speechverb_say = "hisses"
	speechverb_exclaim = "barks"
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	player_can_spawn_with_pet = TRUE
	var/playing_dead = 0

	New()
		. = ..()
		START_TRACKING
		src.bioHolder.AddNewPoolEffect("stinky", scramble=TRUE)

	disposing()
		. = ..()
		STOP_TRACKING

	setup_hands()
		..() // both of these do no damage (in return, possums are basically immortal)
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/possum
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small/possum
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	Life(datum/controller/process/mobs/parent)
		src.play_dead()
		. = ..(parent)

	death(var/gibbed)
		if (gibbed)
			return ..()
		else if (src.playing_dead)
			return
		else
			src.play_dead(rand(40,60))

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (I.force && src.playing_dead)
			src.playing_dead = 1
			src.play_dead()

	proc/play_dead(var/addtime = 0)
		if (addtime > 0) // we're adding more time
			if (src.playing_dead <= 0) // we don't already have time on the clock
				src.icon_state = icon_state_dead ? icon_state_dead : "[icon_state]-dead" // so we gotta show the message + change icon + etc
				src.visible_message(SPAN_ALERT("<b>[src]</b> dies!"),\
				SPAN_ALERT("<b>You play dead!</b>"))
			src.playing_dead = clamp((src.playing_dead + addtime), 0, 100)
		if (src.playing_dead <= 0)
			return
		if (src.playing_dead == 1)
			src.playing_dead = 0
			src.full_heal()
			src.visible_message(SPAN_NOTICE("<b>[src]</b> stops playing dead and gets back up!"))
			boutput(src, SPAN_NOTICE("<b>You stop playing dead and get back up!</b>")) // visible_message doesn't go through when this triggers
			src.hud.update_health()
			return
		else
			setunconscious(src)
			src.setStatus("unconscious", 6 SECONDS)
			src.setStatus("stunned", 6 SECONDS)
			src.setStatus("knockdown", 6 SECONDS)
			src.sleeping = 10
			src.playing_dead--
			src.hud.update_health()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> shrieks!")
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/cat_hiss.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> hisses!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","snap","hiss")
				return 2
		return ..()

/* -------------------- Morty -------------------- */

/mob/living/critter/small_animal/opossum/morty
	name = "Morty"
	real_name = "Morty"
	is_pet = TRUE
	player_can_spawn_with_pet = FALSE

/* ================================================ */
/* ----------------- Armadillo -------------------- */
/* ================================================ */

/mob/living/critter/small_animal/armadillo
	name = "space armadillo"
	real_name = "space armadillo"
	desc = "A armadillo that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "armadillo"
	icon_state_dead = "armadillo-dead"
	hand_count = 2
	speechverb_say = "hisses"
	speechverb_exclaim = "barks"
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	density = TRUE
	player_can_spawn_with_pet = TRUE
	var/obj/item/armadillo_ball/our_ball
	var/infected

	New()
		. = ..()
		infected = prob(20)
		START_TRACKING
		src.bioHolder.AddNewPoolEffect("claws", scramble=TRUE)
		src.bioHolder.AddNewPoolEffect("carapace", scramble=TRUE)

	disposing()
		. = ..()
		STOP_TRACKING
		qdel(our_ball)
		our_ball = null

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = FALSE

	Life(datum/controller/process/mobs/parent)
		. = ..(parent)

	attackby(var/obj/item/I, var/mob/M)
		..()
		if (!src.is_balled())
			if(prob(50))
				src.ball_up(emote=FALSE)

	attack_hand(mob/living/M, params, location, control)
		if (M.a_intent == INTENT_HARM || M.a_intent == INTENT_GRAB)
			if (!src.is_balled())
				if(prob(70))
					src.ball_up(emote=FALSE)
		..()
		if(infected && prob(1))
			M.contract_disease(/datum/ailment/disease/leprosy, null, null, 1) // path, name, strain, bypass resist

	death(var/gibbed)
		if(is_balled())
			ball_up(emote=FALSE, force=TRUE)
		..()

	set_loc(atom/new_loc, new_pixel_x = 0, new_pixel_y = 0)
		if(is_balled() && !QDELETED(our_ball))
			qdel(our_ball)
		..()

	proc/is_balled()
		. = istype(src.loc, /obj/item/armadillo_ball)

	proc/ball_up(emote, force)
		if(ON_COOLDOWN(src, "ball", 3.5 SECONDS))
			. = SPAN_ALERT("<b>[src]</b> wiggles!")
			return
		if(is_balled())
			if(ismob(our_ball.loc))
				var/mob/M = our_ball.loc
				M.remove_item(our_ball)
				boutput(M,SPAN_ALERT("The <b>[src]</b> slips out of your possession!"))
			src.set_loc(get_turf(src))
			if(!emote)
				src.visible_message(SPAN_ALERT("<b>[src]</b> uncurls from a ball!"),\
						SPAN_ALERT("<b>You relax out of your ball!</b>"))
			else
				. = SPAN_ALERT("<b>[src]</b> uncurls from a ball!")
			qdel(our_ball)
			our_ball = null
		else
			if(!emote)
				src.visible_message(SPAN_ALERT("<b>[src]</b> curls into a ball!"),\
						SPAN_ALERT("<b>You curl into a ball!</b>"))
			else
				. = SPAN_ALERT("<b>[src]</b> curls into a ball!")
			if(!isdead(src))
				for (var/obj/item/grab/G in src.grabbed_by)
					G.affecting.visible_message(SPAN_ALERT("[G.affecting] slips free of [G.assailant]'s grip!"))
					G.assailant.u_equip(G)
					qdel(G)
				our_ball = new(get_turf(src))
				src.set_loc(our_ball)
				our_ball.dir = src.dir
				our_ball.icon = src.icon

	Move(var/atom/NewLoc, direct)
		if(src.is_balled())
			ball_up(FALSE)
		else
			..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					. = SPAN_EMOTE("<b>[src]</b> shrieks!")
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/cat_hiss.ogg', 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					. = SPAN_EMOTE("<b>[src]</b> hisses!")
			if("flip")
				if (isobj(src.loc))
					var/obj/container = src.loc
					. = container.mob_flip_inside(src)
				else
					. = ball_up(TRUE)

	specific_emote_type(var/act)
		switch (act)
			if ("scream","snap","hiss")
				return 2
		return ..()

/* ================================================ */
/* ------------------- Iguana --------------------- */
/* ================================================ */

/mob/living/critter/small_animal/iguana
	name = "space iguana"
	real_name = "space iguana"
	desc = "An iguana that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "iguana1"
	icon_state_dead = "iguana1-dead"
	hand_count = 2
	speechverb_say = "hisses"
	speechverb_exclaim = "wheezes"
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	density = 1
	fits_under_table = TRUE
	player_can_spawn_with_pet = TRUE
	var/on_tree

	New()
		. = ..()
		START_TRACKING
		if(prob(20))
			icon_state = "iguana2"
			icon_state_dead = "iguana2-dead"
		AddComponent(/datum/component/waddling, height=4, angle=8)

	disposing()
		STOP_TRACKING
		. = ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "teeth"
		HH.can_hold_items = 0

	hand_attack(atom/target, params)
		if (istype(target, /obj/tree))
			var/obj/tree/T = target
			var/can_attach = FALSE
			var/fall_left_or_right
			var/new_pixel_x
			var/new_pixel_y
			if(target.icon == initial(T.icon) && target.icon_state == initial(T.icon_state) && target.y == src.y && !src.rest_mult)
				if(src.dir & (SOUTH | EAST) )
					fall_left_or_right = -1
					switch(T.dir)
						if(NORTH)
							new_pixel_x = 31
							new_pixel_y = 14
							can_attach = TRUE
						if(EAST)
							new_pixel_x = 28
							new_pixel_y = 12
							can_attach = TRUE
						if(WEST)
							new_pixel_x = 28
							new_pixel_y = 12
							can_attach = TRUE
				else
					fall_left_or_right = 1
					switch(T.dir)
						if(NORTH)
							new_pixel_x = -6
							new_pixel_y = 13
							can_attach = TRUE
						if(EAST)
							new_pixel_x = -9
							new_pixel_y = 13
							can_attach = TRUE
						if(WEST)
							new_pixel_x = -11
							new_pixel_y = 13
							can_attach = TRUE
			if(can_attach)
				src.setStatus("resting", INFINITE_STATUS)
				var/matrix/orig_transform = src.transform
				force_laydown_standup()
				animate(src, pixel_x = new_pixel_x, pixel_y = new_pixel_y, transform = orig_transform.Turn(fall_left_or_right * 90), time = 2, easing = LINEAR_EASING, flags=ANIMATION_PARALLEL)
				src.rest_mult = fall_left_or_right
				src.visible_message(SPAN_ALERT("[src] slinks onto [target]!"))
				on_tree = TRUE
				return
		. = ..()

	force_laydown_standup()
		if(src.on_tree)
			on_tree = FALSE
		. = ..()

	Move()
		if(src.on_tree && src.rest_mult)
			delStatus("resting")
			force_laydown_standup()
			if(prob(5))
				src.visible_message(SPAN_ALERT("[src] falls out of the tree!"),SPAN_ALERT("<B>You fall out of the tree!"))
				src.sleeping = 1
				return
		..()

/* ================================================ */
/* -------------------- Seal ---------------------- */
/* ================================================ */

/mob/living/critter/small_animal/seal
	name = "seal"
	real_name = "seal"
	desc = "Did you know, that when it snows, its eyes become large and the light that you shine can be seen?"
	icon_state = "seal"
	icon_state_dead = "seal-dead"
	hand_count = 2
	speechverb_say = "trills"
	speechverb_exclaim = "barks"
	death_text = "%src% lets out a final weak coo and keels over."
	butcherable = BUTCHER_YOU_MONSTER
	health_brute = 15
	health_burn = 15
	pet_text = list("gently baps", "pets", "cuddles")
	is_pet = TRUE
	name_list = "names/seals.txt"
	random_name = TRUE
	player_can_spawn_with_pet = FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "flipper"
		HH.limb_name = "flipper"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"
		HH.can_hold_items = FALSE

	on_pet(mob/user)
		if(..())
			return
		src.visible_message(SPAN_EMOTE("<b>[user]</b> [pick("hugs","pets","caresses","boops","squeezes")] [src]!"))
		if(prob(80))
			src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("coos","purrs","mewls","chirps","arfs","arps","urps")]."))
		else
			src.visible_message(SPAN_EMOTE("<b>[src]</b> hugs <b>[user]</b> back!"))
			if (user.reagents)
				user.reagents.add_reagent("hugs", 10)
			src.emote("coo")

	attackby(obj/item/W, mob/living/user)
		if (!src.ai?.enabled || is_incapacitated(src))
			return ..()
		if (istype(W, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/snack = W
			if(findtext(W.name,"seal")) // for you, spacemarine9
				src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("groans","yelps")]!"))
				src.visible_message(SPAN_NOTICE("<b>[src]</b> gets frightened by [snack]!"))
				if(src.is_npc)
					src.ai.move_away(user, 10)
					SPAWN(1 SECOND) walk(src,0)
				return

			if(prob(5))
				src.visible_message(SPAN_NOTICE("<b>[src]</b> gives [snack] back to <b>[user]</b> as if they wanted to share!"))
				playsound(src, 'sound/voice/babynoise.ogg', 50, 10,10)
				return

			snack.Eat(src, src)
			modify_christmas_cheer(1)
			src.HealDamage("all", 10, 10)
		else
			src.visible_message(SPAN_EMOTE("<b>[src]</b> [pick("groans","yelps")]!"))
			if(src.is_npc)
				src.ai.move_away(user, 10)
			return ..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon, var/special, var/intent)
		..()
		for (var/mob/living/critter/small_animal/walrus/walrus in view(7, src))
			if (!(is_incapacitated(walrus) && walrus.ai?.enabled))
				var/datum/aiTask/task = walrus.ai.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(walrus.ai, walrus.ai.default_task))
				walrus.ai.priority_tasks += task
				walrus.ai.interrupt()
				walrus.ai.target = M

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","coo")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/babynoise.ogg', 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> coos!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","coo")
				return 2
		return ..()

	death(var/gibbed)
		modify_christmas_cheer(-20)
		if (gibbed)
			return ..()
		src.desc = "The lifeless corpse of [src], why would anyone do such a thing?"

		for (var/mob/living/critter/small_animal/seal/seal in view(7, src))
			if (!(is_incapacitated(seal) && seal.ai?.enabled))
				seal.visible_message(SPAN_EMOTE("<b>[seal]</b> [pick("groans","yelps")]!"))
				if(seal.is_npc)
					seal.ai?.move_away(src, 10)

		..()

/* ================================================ */
/* -------------------- Walrus ---------------------- */
/* ================================================ */

/mob/living/critter/small_animal/walrus
	name = "walrus"
	real_name = "walrus"
	desc = "Usually found in the Arctic on Earth, this particular walrus specimen seems to thrive in space."
	icon_state = "walrus"
	icon_state_dead = "walrus-dead"
	hand_count = 2
	speechverb_say = "harrumphs"
	speechverb_exclaim = "roars"
	death_text = "%src% lets out a final weak grumble and keels over."
	butcherable = BUTCHER_YOU_MONSTER
	health_brute = 15
	health_brute_vuln = 0.5
	health_burn = 15
	health_burn_vuln = 0.5
	pet_text = list("gently baps", "pets")

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "flipper"
		HH.limb_name = "flipper"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "mouth"
		HH.limb_name = "mouth"
		HH.can_hold_items = FALSE

/* ====================================================== */
/* -------------------- Floating Eye -------------------- */
/* ====================================================== */
// vOv  it's in pets_small_animals.dm so it gets to live here too!
/mob/living/critter/small_animal/floateye
	name = "floating thing"
	real_name = "floating thing"
	desc = "You have never seen something like this before."
	icon_state = "floateye"
	icon_state_dead = "floateye-dead"
	health_brute = 10
	health_burn = 10
	faction = list(FACTION_NEUTRAL)
	isFlying = TRUE
	has_genes = FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird tentacle things"
		HH.limb_name = "tentacles"

	on_pet(mob/user)
		if (..())
			return 1
		boutput(user, SPAN_ALERT("You feel uncomfortable now."))

/// the floating eyes found in the watchful eye sensor array.
/mob/living/critter/small_animal/floateye/watchful
	desc = "It seems to be staring directly at the Purple Giant."
	ai_type = /datum/aiHolder/empty
	ai_retaliates = FALSE
	New()
		..()
		add_lifeprocess(/datum/lifeprocess/disability) // so that they stop jittering
		START_TRACKING
	disposing()
		. = ..()
		STOP_TRACKING

/* ============================================= */
/* -------------------- Bat -------------------- */
/* ============================================= */

/mob/living/critter/small_animal/bat // in objcritter form this is a large animal but I don't care I'm making it a small thing now
	name = "bat"
	real_name = "bat"
	desc = "skreee!"
	hand_count = 2
	icon_state = "bat"
	icon_state_dead = "bat-dead"
	speechverb_say = "squeaks"
	speechverb_exclaim = "shrieks"
	speechverb_ask = "squeaks"
	health_brute = 8
	health_burn = 8
	is_npc = FALSE // needs special AI will come later
	player_can_spawn_with_pet = TRUE

	New()
		..()
		if (prob(1))
			src.name = replacetext(src.name, "bat", "bart")
			if (src.name != initial(src.name))
				src.real_name = src.name

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> shrieks!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	Move()
		.=..()
		if (prob(15))
			playsound(src, "rustle", 10, 1)

	death(gibbed)
		if (!gibbed && src.reagents)
			src.reagents.add_reagent("woolofbat", 50, null)
		..()

/* -------------------- Angry Bat -------------------- */

/mob/living/critter/small_animal/bat/angry
	name = "angry bat"
	real_name = "angry bat"
	desc = "It doesn't look too happy!"
	icon_state = "scarybat"
	health_brute = 25
	health_burn = 25
	player_can_spawn_with_pet = FALSE

/* -------------------- Dr. Acula -------------------- */

/mob/living/critter/small_animal/bat/doctor
	name = "Dr. Acula"
	real_name = "Dr. Acula"
	desc = "If you ask nicely he might even write you a preskreeeption!"
	icon_state = "batdoctor"
	icon_state_dead = "batdoctor-dead"
	health_brute = 30
	health_burn = 30
	is_pet = 2
	player_can_spawn_with_pet = FALSE

/* ------------------ Tiny Bat Rina ------------------ */

/mob/living/critter/small_animal/bat/rina //for Jan's office
	name = "Tiny Bat Rina"
	real_name = "Tiny Bat Rina"
	desc = "Why does this little bat have a purple ponytail?"
	icon = 'icons/misc/janstuff.dmi'
	icon_state = "batrina"
	icon_state_dead = "batrina-dead"
	health_brute = 30
	health_burn = 30
	player_can_spawn_with_pet = FALSE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("dance")
				if (src.emote_check(voluntary, 50))
					FLICK("batrina-dance", src)
					return SPAN_EMOTE("<b>[src]</b> dances!")
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> makes a tiny bat squeak!")
		return ..()

	specific_emote_type(var/act)
		switch (act)
			if ("scream","dance")
				return 2
		return ..()

	animate_lying(lying)
		if (lying)
			src.icon_state = "batrina-sleeping"
		else
			src.icon_state = initial(src.icon_state)

/* ============================================== */
/* -------------------- Wasp -------------------- */
/* ============================================== */

/mob/living/critter/small_animal/wasp
	name = "space wasp"
	real_name = "space wasp"
	desc = "A wasp in space."
	icon_state = "wasp"
	icon_state_dead = "wasp-dead"
	speechverb_say = "buzzes"
	speechverb_exclaim = "screeches"
	speechverb_ask = "hums"
	health_brute = 5
	health_brute_vuln = 1
	health_burn = 5
	health_burn_vuln = 1
	reagent_capacity = 100
	flags = TABLEPASS
	fits_under_table = TRUE
	isFlying = TRUE
	player_can_spawn_with_pet = TRUE

	ai_retaliate_patience = 1
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD
	ai_type = /datum/aiHolder/aggressive

	add_abilities = list(/datum/targetable/critter/wasp_sting)
	ai_attacks_per_ability = 0

	faction = list(FACTION_BOTANY)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				src.emote("scream")
			else if (prob(1))
				src.emote("dance")

	death(var/gibbed)
		if (!gibbed)
			animate(src) // stop bumble / bounce
			src.reagents.add_reagent("toxin", 50, null)
			src.reagents.add_reagent("histamine", 50, null)
		return ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/critter/sting = src.abilityHolder.getAbility(/datum/targetable/critter/wasp_sting)
		if (!sting.disabled && sting.cooldowncheck())
			sting.handleCast(target)
			return TRUE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("dance")
				if (src.emote_check(voluntary, 50) && !src.shrunk)
					SPAWN(1 SECOND)
						animate_bumble(src)
					return SPAN_EMOTE("<b>[src]</b> bumbles menacingly!")
			if ("scream","buzz")
				if (src.emote_check(voluntary, 30))
					playsound(src, 'sound/voice/animal/fly_buzz.ogg', 90, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> buzzes!") // todo?: find buzz noise
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("flip","dance")
				return 1
			if ("scream","buzz")
				return 2
		return ..()

/mob/living/critter/small_animal/wasp/angry // Wasp bow & grenade
	desc = "A wasp in space. it looks angry"
	health_brute = 10
	health_brute_vuln = 1
	health_burn = 10
	health_burn_vuln = 0.8
	player_can_spawn_with_pet = FALSE

/mob/living/critter/small_animal/wasp/strong // Polymorph and admin spawn
	desc = "A wasp in space. it looks buff... somehow."
	health_brute = 25
	health_brute_vuln = 1
	health_burn = 25
	health_burn_vuln = 0.8
	is_npc = FALSE
	player_can_spawn_with_pet = FALSE

	setup_hands() // Stronger grip
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "weird grabby foot thing"
		HH.limb_name = "foot"

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp
	name = "space wasp egg"
	desc = "That doesn't seem right..."
	critter_type = /mob/living/critter/small_animal/wasp

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/wasp/angry
	name = "space wasp egg?"
	desc = "There is A LOT OF BUZZING coming from this thing..."
	critter_type = /mob/living/critter/small_animal/wasp/angry

/* ================================================= */
/* -------------------- Raccoon -------------------- */
/* ================================================= */

/mob/living/critter/small_animal/raccoon
	name = "space raccoon"
	real_name = "space raccoon"
	desc = "A raccoon that came from space. Or maybe went to space. Who knows how it got here?"
	icon_state = "raccoon"
	icon_state_dead = "raccoon-dead"
	hand_count = 2
	health_brute = 25
	health_burn = 25
	speechverb_say = "chatters"
	speechverb_exclaim = "barks"
	speechverb_ask = "squeaks"
	pet_text = list("pets","cuddles","snuggles","pats")
	flags = TABLEPASS
	fits_under_table = TRUE
	add_abilities = list(/datum/targetable/critter/pounce)
	player_can_spawn_with_pet = TRUE

	skinresult = /obj/item/clothing/head/raccoon
	max_skins = 1

	pull_w_class = W_CLASS_BULKY

	New()
		..()
		if (prob(1))
			src.name = replacetext(src.name, "raccoon", "washbear")
			src.desc = replacetext(src.desc, "raccoon", "washbear")
			if (src.name != initial(src.name))
				src.real_name = src.name

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> [pick("shriek","yowl","bark")]s!")
			if ("shriek","yowl","bark")
				if (src.emote_check(voluntary, 50))
					return SPAN_EMOTE("<b>[src]</b> [act]s!")
			if ("snap","hiss")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/cat_hiss.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> hisses!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","shriek","yowl","bark","snap","hiss")
				return 2
		return ..()

/* =============================================== */
/* -------------------- Snail -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/slug
	name = "slug"
	real_name = "slug"
	desc = "It doesn't have any arms or legs so it's kind of like a snake, but it's gross and unthreatening instead of cool and dangerous."
	icon_state = "slug"
	icon_state_dead = "slug-dead"
	blood_id = "hemolymph"
	speechverb_say = "blorps"
	speechverb_exclaim = "bloops"
	speechverb_ask = "burbles"
	health_brute = 5
	health_burn = 5
	flags = TABLEPASS
	fits_under_table = TRUE
	hand_count = 1
	base_move_delay = 6
	base_walk_delay = 8
	var/slime_chance = 22
	butcherable = BUTCHER_ALLOWED
	name_the_meat = FALSE
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug
	player_can_spawn_with_pet = TRUE


	New()
		..()
		AddComponent(/datum/component/floor_slime, "slime", slime_chance, 10)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "mouth thing"			// name for the dummy holder
		HH.can_hold_items = FALSE

/* -------------------- Snail -------------------- */

/mob/living/critter/small_animal/slug/snail
	name = "snail"
	real_name = "snail"
	desc = "It's basically just a slug with a shell on it. This makes it less gross."
	icon_state = "snail"
	icon_state_dead = "snail-dead"
	blood_id = "hemolymph"
	health_brute = 10
	health_burn = 10
	slime_chance = 11
	player_can_spawn_with_pet = TRUE

/mob/living/critter/small_animal/slug/snail/diner
	name = "Snaily Softserve"
	real_name = "snaildiner"
	desc = "It's Snaily Softserve! She's a bit slimy and slow, but she means well."
	icon_state = "snail"
	icon_state_dead = "snail-dead"
	blood_id = "hemolymph"
	health_brute = 30
	health_burn = 30
	slime_chance = 25
	blood_color = "#f846cc"
	color = "#ffabfb"
	pet_text = "gently pats"
	speechverb_say = "blurps"
	voice_name = "Snaily Softserve"
	memory = "i love being a snail..."
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	dir_locked = 1
	player_can_spawn_with_pet = FALSE

	New()
		..()
		var/image/bow = image('icons/obj/clothing/item_hats.dmi', "hbow-mint")
		bow.appearance_flags = KEEP_TOGETHER
		bow.pixel_y= 3
		bow.pixel_x= -9
		bow.loc = src
		bow.layer= src.layer +0.1
		src.overlays += bow
		/*src.UpdateOverlays(bow, "bow") */




/* =============================================== */
/* ------------------ Butterfly ------------------ */
/* =============================================== */

/mob/living/critter/small_animal/butterfly
	name = "butterfly"
	real_name = "butterfly"
	blood_id = "hemolymph"
	desc = "It's a beautiful butterfly! How did it get here?"
	hand_count = 2
	icon_state = "butterfly1"
	icon_state_dead = "butterfly1-dead"
	speechverb_say = "whispers"
	speechverb_exclaim = "hums"
	speechverb_ask = "muses"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/butter
	name_the_meat = FALSE
	death_text = "%src% disintegrates."
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	health_brute = 8
	health_burn = 8
	var/butterflytype = 1
	isFlying = TRUE
	player_can_spawn_with_pet = TRUE

	New()
		..()
		butterflytype = rand(1,5)
		src.icon_state = "butterfly[butterflytype]"
		src.icon_state_dead = "butterfly[butterflytype]-dead"
		START_TRACKING_CAT(TR_CAT_BUGS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "delicate limb things"
		HH.limb_name = "legs"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/butterflyscream.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> cheeps.")
			if ("flutter","dance")
				if (src.emote_check(voluntary, 50)) //copied from moonwalk code
					SPAWN(0)
						for (var/i in 1 to 4)
							src.pixel_x += 2
							sleep(0.2 SECONDS)
						for (var/i in 1 to 4)
							src.pixel_x -= 2
							sleep(0.2 SECONDS)
					return SPAN_EMOTE("<b>[src]</b> flutters.")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","flutter","dance")
				return 2
		return ..()

/mob/living/critter/small_animal/butterfly/weak
	health_brute = 2
	health_burn = 2
	player_can_spawn_with_pet = FALSE


/* =============================================== */
/* ------------------ Moth ----------------------- */
/* =============================================== */
// What do you mean moths arent butterflies. SHUT UP. GO AWAY.
/mob/living/critter/small_animal/butterfly/moth
	name = "moth"
	real_name = "moth"
	desc = "Ew a moth. Hope it doesn't get into the wardrobe."
	blood_id = "hemolymph"
	player_can_spawn_with_pet = TRUE

	New()
		..()
		var/type = pick("silk","cecropia","deathshead","rosymaple")
		icon_state = "moth-[type]"
		icon_state_dead = "moth-[type]-dead"

/* =============================================== */
/* ------------------ Fly	   ------------------- */
/* =============================================== */

/mob/living/critter/small_animal/fly
	name = "fly"
	real_name = "fly"
	desc = "It's a pesky housefly! How'd it get into space? No clue."
	hand_count = 2
	icon_state = "fly"
	icon_state_dead = "fly-dead"
	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "pesters"
	death_text = "%src% splats."
	blood_id = "hemolymph"
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	base_move_delay = 1.3
	base_walk_delay = 1.8
	health_brute = 8
	health_burn = 8
	isFlying = TRUE
	add_abilities = list(/datum/targetable/critter/vomit)

	New(loc)
		..()
		START_TRACKING_CAT(TR_CAT_BUGS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

	Move()
		. = ..()
		misstep_chance = 23

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "conniving crawlers"
		HH.limb_name = "arms"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/fly_buzz.ogg', 90, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> bzzts annoyingly.")

/mob/living/critter/small_animal/fly/weak
	health_brute = 2
	health_burn = 2

/* =============================================== */
/* ------------------- mosquito ------------------ */
/* =============================================== */

/mob/living/critter/small_animal/mosquito
	name = "mosquito"
	real_name = "mosquito"
	desc = "It's a pesky mosquito! How'd it get into space? No clue."
	hand_count = 2
	icon_state = "sqwibby"
	icon_state_dead = "sqwibby-dead"
	blood_id = "hemolymph"
	speechverb_say = "bzzs"
	speechverb_exclaim = "bzzts"
	speechverb_ask = "pesters"
	death_text = "%src% splats."
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	base_move_delay = 1.3
	base_walk_delay = 1.8
	health_brute = 8
	health_burn = 8
	isFlying = TRUE
	add_abilities = list(/datum/targetable/critter/blood_bite)

	New(loc)
		..()
		START_TRACKING_CAT(TR_CAT_BUGS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_BUGS)
		..()

	Move()
		. = ..()
		misstep_chance = 23

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "conniving crawlers"
		HH.limb_name = "arms"


		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "mouth"
		HH.name = "proboscis"
		HH.limb_name = "mouth"
		HH.can_hold_items = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/fly_buzz.ogg', 90, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> bzzts annoyingly.")

/mob/living/critter/small_animal/mosquito/weak
	health_brute = 2
	health_burn = 2

/* =============================================== */
/* ------------------- lobsterman ---------------- */
/* =============================================== */

/mob/living/critter/small_animal/lobsterman
	name = "lobster"
	real_name = "lobster"
	desc = "An unpleasantly humanoid lobster."
	icon_state = "lobsterman"
	var/start_icon = "lobsterman"
	icon_state_dead = "lobsterman-dead"

	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	hand_count = 2
	health_brute = 20
	health_burn = 20
	pull_w_class = W_CLASS_BULKY

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "lobster claw"
		HH.limb_name = "lobster claw"

		HH = hands[2]
		HH.limb = new /datum/limb/claw
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "lobster claw"
		HH.limb_name = "lobster claw"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					src.icon_state = "lobsterman-screech"
					SPAWN(1.5 SECONDS)
						if (src && !isdead(src))
							src.icon_state = start_icon
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE,0,0,0.8, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> screeches!")

			if ("dance","flap")
				if (src.emote_check(voluntary, 50))
					src.icon_state = "lobsterman-clack"
					SPAWN(3 SECONDS)
						if (src && !isdead(src))
							src.icon_state = start_icon
					return SPAN_EMOTE("<b>[src]</b> clacks [his_or_her(src)] claws!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
			if ("dance","flap")
				return 1
		return ..()

/mob/living/critter/small_animal/lobsterman/rock
	name = "rock lobster"
	real_name = "rock lobster"
	icon_state = "lobsterman-rock"
	start_icon = "lobsterman-rock"
	icon_state_dead = "lobsterman-dead"
	desc = "Not a rock."

/* =============================================== */
/* ------------------- boogiebot ----------------- */
/* =============================================== */

/mob/living/critter/small_animal/boogiebot
	name = "Boogiebot"
	real_name = "Boogiebot"
	desc = "A robot that looks ready to get down at any moment."
	flags = TABLEPASS | DOORPASS
	butcherable = BUTCHER_NOT_ALLOWED // TODO: move this to robotic critter
	fits_under_table = 1
	hand_count = 1
	icon = 'icons/mob/critter/robotic/boogie.dmi'
	icon_state = "boogie"
	icon_state_dead = "boogie-dead"
	speechverb_say = "sings"
	speechverb_exclaim = "yells"
	speechverb_ask = "asks"
	health_brute = 20
	health_burn = 20
	has_genes = FALSE
	var/emagged = FALSE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50) && !ON_COOLDOWN(src, "playsound", 5 SECONDS))
					playsound(src, 'sound/voice/screams/Robot_Scream_2.ogg', 50, TRUE, 0.1, 2.6, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")

			if ("dance")
				if (src.emote_check(voluntary, 50))
					if (emagged)
						SPAWN(0.5 SECONDS)
							for (var/mob/living/carbon/human/responseMonkey in orange(2, src)) // they don't have to be monkeys, but it's signifying monkey code
								LAGCHECK(LAG_MED)
								if (!can_act(responseMonkey, 0))
									continue
								responseMonkey.emote("dance")
					FLICK(pick("boogie-d1","boogie-d2","boogie-d3"), src)
					var/msg = pick("beeps and boops","does a little dance","gets down tonight","is feeling funky","is out of control","gets up to get down","busts a groove","begins clicking and whirring","emits an excited bloop","can't contain itself","can dance if it wants to")
					return SPAN_EMOTE("<b>[src]</b> [msg]!")

			if ("birdwell", "burp")
				if (src.emote_check(voluntary, 50) && !ON_COOLDOWN(src, "playsound", 5 SECONDS))
					playsound(src, 'sound/vox/birdwell.ogg', 50, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> birdwells.")

			if ("flip")
				if (!ON_COOLDOWN(src, "playsound", 5 SECONDS))
					var/mode = pick("honk", "fart", "burp", "squeak", "cat", "harmonica", "vuvuzela", "bang", "buzz", "gunshot", "siren", "coo", "rimshot", "trombone")
					switch(mode)
						if ("honk") playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("fart")
							if (farting_allowed)
								playsound(src.loc, 'sound/voice/farts/poo2_robot.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("burp") playsound(src.loc, 'sound/voice/burp_alien.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("squeak") playsound(src.loc, 'sound/misc/clownstep1.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("cat") playsound(src.loc, 'sound/voice/animal/cat.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("harmonica")
							var/which = rand(1,3)
							switch(which)
								if(1) playsound(src.loc, 'sound/musical_instruments/Harmonica_1.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
								if(2) playsound(src.loc, 'sound/musical_instruments/Harmonica_2.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
								if(3) playsound(src.loc, 'sound/musical_instruments/Harmonica_3.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("vuvuzela") playsound(src.loc, 'sound/musical_instruments/Vuvuzela_1.ogg', 45, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("bang") playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 40, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("buzz") playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("gunshot") playsound(src.loc, 'sound/weapons/Gunshot.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("siren") playsound(src.loc, 'sound/machines/siren_police.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("coo") playsound(src.loc, 'sound/voice/babynoise.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("rimshot") playsound(src.loc, 'sound/misc/rimshot.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						if ("trombone") playsound(src.loc, 'sound/musical_instruments/Trombone_Failiure.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						else playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					return

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("dance")
				return 1
			if ("birdwell", "burp")
				return 2
		return ..()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				src.emote("dance")

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.emagged)
			if(user)
				boutput(user, SPAN_ALERT("You short out the [src]'s dancing intensity setting to 'flashmob'."))
			src.visible_message(SPAN_ALERT("<b>[src] lights up with determination!</b>"))
			src.emagged = TRUE
			return TRUE
		return FALSE

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

/mob/living/critter/small_animal/boogiebot/weak
	health_brute = 4
	health_burn = 4

/* =============================================== */
/* ------------------- plush --------------------- */
/* =============================================== */

/mob/living/critter/small_animal/plush
	name = "plush toy"
	real_name = "plush toy"
	desc = "In your heart of hearts, you knew that they were real. And you never stopped believing!"
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	hand_count = 2
	icon = 'icons/obj/plushies.dmi'
	health_brute = 20
	health_burn = 20
	pull_w_class = W_CLASS_NORMAL
	var/pick_random_icon_state = 1
	is_npc = FALSE
	player_can_spawn_with_pet = TRUE
	has_genes = FALSE

	New()
		..()
		if(pick_random_icon_state)
			icon_state = pick("bee", "buddy", "kitten", "monkey", "possum", "brullbar", "bunny", "penguin")
		icon_state_alive = src.icon_state
		icon_state_dead = src.icon_state

	death(var/gibbed)
		if (!gibbed)
			src.Turn(180)
		..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
			if ("fart")
				if (src.emote_check(voluntary, 10))
					playsound(src, 'sound/voice/farts/poo2.ogg', 40, TRUE, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> farts!")
			if ("dance")
				if (src.emote_check(voluntary, 50))
					animate_bouncy(src)
					return SPAN_EMOTE("<b>[src]</b> dances!")
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

/* =============================================== */
/* ------------------- figure -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/figure
	name = "collectible figure"
	real_name = "collectible figure"
	desc = SPAN_ALERT("<b>WARNING: CHOKING HAZARD</b> - Small parts. Not for children under 3 years.")
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE
	hand_count = 2
	icon = 'icons/obj/items/figures.dmi'
	icon_state = "fig-"
	icon_state_dead = "fig-"
	health_brute = 20
	health_burn = 20
	var/datum/figure_info/info = 0
	var/voice_gender = "male"
	is_npc = FALSE
	has_genes = FALSE

	New()
		..()

		if (prob(50))
			voice_gender = "male"
		else
			voice_gender = "female"

		var/datum/figure_info/randomInfo
		if (prob(1))
			randomInfo = pick(figure_patreon_rarity)
		else if (prob(10))
			randomInfo = pick(figure_high_rarity)
		else
			randomInfo = pick(figure_low_rarity)
		src.info = new randomInfo(src)
		src.name = "[src.info.name] figure"
		src.real_name = src.name
		src.icon_state = "fig-[src.info.icon_state]"
		if (src.info.rare_varieties.len && prob(5))
			src.icon_state = "fig-[pick(src.info.rare_varieties)]"
		else if (src.info.varieties.len)
			src.icon_state = "fig-[pick(src.info.varieties)]"
		icon_state_dead = src.icon_state

		if (prob(1)) // rarely give a different material
			if (prob(1)) // VERY rarely give a super-fancy material
				var/list/rare_material_varieties = list("gold", "spacelag", "diamond", "ruby", "garnet", "topaz", "citrine", "peridot", "emerald", "jade", "aquamarine",
				"sapphire", "iolite", "amethyst", "alexandrite", "uqill", "uqillglass", "telecrystal", "miracle", "starstone", "flesh", "blob", "bone", "beeswax", "carbonfibre")
				src.setMaterial(getMaterial(pick(rare_material_varieties)))
			else // silly basic "rare" varieties of things that should probably just be fancy paintjobs or plastics, but whoever made these things are idiots and just made them out of the actual stuff.  I guess.
				var/list/material_varieties = list("steel", "glass", "silver", "quartz", "rosequartz", "plasmaglass", "onyx", "jasper", "malachite", "lapislazuli")
				src.setMaterial(getMaterial(pick(material_varieties)))

	death(var/gibbed)
		. = ..()
		if (!gibbed)
			new /obj/item/toy/figure(src.loc, info)
			ghostize()
			playsound(src.loc, 'sound/effects/suck.ogg', 40, 1, -1, 0.6)
			qdel(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, (voice_gender == "male" ? 'sound/voice/screams/male_scream.ogg' : 'sound/voice/screams/female_scream.ogg'), 40, 1, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
			if ("burp")
				if (src.emote_check(voluntary, 30))
					playsound(src, 'sound/voice/burp.ogg', 40, TRUE, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> burps.")
			if ("fart")
				if (src.emote_check(voluntary))
					playsound(src, 'sound/voice/farts/poo2.ogg', 40, TRUE, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> farts!")

		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
			if ("burp")
				return 2
			if ("fart")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tiny hand"
		HH.limb_name = "tiny hand"

/mob/living/critter/small_animal/figure/weak
	health_brute = 4
	health_burn = 4


/* =============================================== */
/* ----------- mentor & admin mice --------------- */
/* =============================================== */

/mob/living/critter/small_animal/mouse/weak/mentor
	name = "mentor mouse"
	real_name = "mentor mouse"
	desc = "A helpful mentor in the form of a mouse. Click to put them in your pocket so they can help you."
	var/status_name = "mentor_mouse"
	var/is_admin = 0
	var/mob/last_poked = null
	var/colorkey_overlays = 0
	icon_state = "mouse-mentor"
	icon_state_dead = "mouse-mentor-dead"
	var/icon_state_exclaim = "mouse-mentor-exclaim"
	health_brute = 35
	health_burn = 35
	is_npc = FALSE
	use_custom_color = FALSE
	var/allow_pickup_requests = TRUE
	void_mindswappable = FALSE
	player_can_spawn_with_pet = FALSE
	has_genes = FALSE
	shiny_chance = 0

	New()
		..()
		if(src.is_shiny)
			src.icon_state = "mouse-large-shiny"
			src.icon_state_dead = "mouse-large-shiny-dead"
			src.icon_state_exclaim = "mouse-large-shiny-exclaim"
		else
			src.real_name = "[pick_string("mentor_mice_prefixes.txt", "mentor_mouse_prefix")] [src.name]"
			src.fur_color = "#a175cf"
		src.name = src.real_name
		abilityHolder.addAbility(/datum/targetable/critter/mentordisappear)
		abilityHolder.addAbility(/datum/targetable/critter/mentortoggle)

	setup_overlays()
		if(!src.colorkey_overlays)
			return
		eye_color = src.client?.preferences.AH.e_color

		var/image/overlay = image(src.icon, "mouse_colorkey")
		overlay.color = fur_color
		src.UpdateOverlays(overlay, "hair")

		var/image/overlay_eyes = image(src.icon, "mouse_eyes")
		overlay_eyes.color = eye_color
		src.UpdateOverlays(overlay_eyes, "eyes")

	death()
		..()
		if(!src.colorkey_overlays)
			src.UpdateOverlays(null, "hair")

	attack_hand(mob/living/M)
		if (allow_pickup_requests)
			src.into_pocket(M)
		else
			. = ..()

	proc/into_pocket(mob/M, var/voluntary = 1)
		if(M == src || isdead(src))
			return // no recursive pockets, thank you. Also no dead mice in pockets
		if(locate(/mob/dead/target_observer/mentor_mouse_observer) in M)
			if(voluntary)
				boutput(M, "You already have a mouse helping you, don't be greedy.")
			else
				boutput(src, "[M] already has a mouse in [his_or_her(M)] pocket.")
			return
		if(voluntary && M != src.last_poked) // if we poked that person it means we implicitly agree
			boutput(M, "You extend your hand to the mouse, waiting for [him_or_her(src)] to accept.")
			if (ON_COOLDOWN(src, "mentor mouse pickup popup", 3 SECONDS))
				return
			if (tgui_alert(src, "[M] wants to pick you up and put you in [his_or_her(M)] pocket. Is that okay with you?", "Hop in the pocket", list("Yes", "No")) != "Yes")
				boutput(M, "\The [src] slips out as you try to pick it up.")
				return
		if(!src || !src.mind || !src.client)
			return
		if(voluntary)
			M.visible_message("[M] picks up \the [src] and puts it in [his_or_her(M)] pocket.", "You pick up \the [src] and put it in your pocket.")
		else
			M.visible_message("\The [src] jumps into [M]'s pocket.", "\The [src] jumps into your pocket.")
		boutput(M, "You can click on the status effect in the top right to kick the mouse out.")
		boutput(src, "<span style='color:red; font-size:1.5em'><b>You are now in someone's pocket, can talk to [him_or_her(M)], and click on [his_or_her(M)] screen to ping in the place where you're ctrl+clicking. This is a feature meant for teaching and helping players. Do not abuse it by using it to just chat with your friends!</b></span>")
		logTheThing(LOG_ADMIN, src, "jumps into [constructTarget(M, "admin")]'s pocket as a mentor mouse at [log_loc(M)].")
		var/mob/dead/target_observer/mentor_mouse_observer/obs = new(M, src.is_admin)
		obs.set_observe_target(M)
		obs.my_mouse = src
		src.set_loc(obs)
		if(src.mind)
			src.mind.transfer_to(obs)
		else if(src.client)
			obs.client = src.client
		M.setStatus(src.status_name, duration = null)

	hand_attack(atom/target, params, location, control, origParams)
		if(istype(target, /mob/living) && target != src && !is_admin)
			boutput(src, "<span class='game' class='mhelp'>You poke [target] in a way that clearly indicates you want to help [him_or_her(target)].</span>")
			boutput(target, "<span class='game' class='mhelp'>\The [src] seems willing to help you. Click on [him_or_her(src)] with an empty hand if you want to accept the offer.</span>")
			src.last_poked = target
			if(src.icon_state_exclaim)
				FLICK(src.icon_state_exclaim, src)
		else
			return ..()

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					if(src.icon_state_exclaim)
						FLICK(src.icon_state_exclaim, src)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
			if ("fart")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/farts/poo2.ogg', 40, TRUE, 0.1, 3, channel=VOLUME_CHANNEL_EMOTE)
					var/obj/item/bible/B = locate(/obj/item/bible) in get_turf(src)
					if(B)
						SPAWN(0.1 SECONDS) // so that this message happens second
							playsound(src, 'sound/voice/farts/poo2.ogg', 7, FALSE, 0, src.get_age_pitch() * 0.4, channel=VOLUME_CHANNEL_EMOTE)
							B.visible_message(SPAN_NOTICE("[B] toots back [pick("grumpily","complaintively","indignantly","sadly","annoyedly","gruffly","quietly","crossly")]."))
					return SPAN_EMOTE("<b>[src]</b> toots helpfully!")
			if ("dance")
				if (src.emote_check(voluntary, 50))
					animate_bouncy(src) // bouncy!
					return SPAN_EMOTE("<b>[src]</b> [pick("bounces","dances","boogies","frolics","prances","hops")] around with [pick("joy","fervor","excitement","vigor","happiness")]!")
		return ..()

	specific_emote_type(var/act)
		switch (act)
			if ("fart")
				return 2
		return ..()

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(src.client && !src.client.is_mentor() && !src.client.holder)
			src.make_critter(/mob/living/critter/small_animal/mouse/weak)
			return

/datum/targetable/critter/mentordisappear
	name = "Vanish"
	desc = "Leave your body and return to ghost form"
	icon_state = "mentordisappear"
	needs_turf = FALSE //always castable
	var/const/disappearance_time = 0.5 SECONDS
	do_logs = FALSE //we're already logged

	cast(mob/target)

		var/mob/living/M = holder.owner
		if (!holder)
			return 1
		. = ..()
		logTheThing(LOG_ADMIN, src, "turned from a mentor mouse to a ghost") // I can remove this but it seems like a good thing to have
		M.visible_message(SPAN_ALERT("<B>[M] does a funny little jiggle with [his_or_her(M)] body and then vanishes into thin air!</B>")) // MY ASCENSION BEGINS
		animate_bouncy(src)
		animate(M, alpha=0, time=disappearance_time)
		SPAWN(disappearance_time)
			M.ghostize()
			qdel(M)

	incapacitationCheck()
		return FALSE

/datum/targetable/critter/mentortoggle
	name = "Toggle Pick Up Requests"
	desc = "Enable or disable player pick up requests."
	icon_state = "mentordisappear"
	icon_state = "mentortoggle"
	needs_turf = FALSE //always castable
	do_logs = FALSE

	cast(mob/target)
		. = ..()
		var/mob/living/critter/small_animal/mouse/weak/mentor/M = holder.owner
		M.allow_pickup_requests = !M.allow_pickup_requests
		boutput(M, SPAN_NOTICE("You have toggled pick up requests [M.allow_pickup_requests ? "on" : "off"]"))
		logTheThing(LOG_ADMIN, src, "Toggled mentor mouse pick up requests [M.allow_pickup_requests ? "on" : "off"]")

	incapacitationCheck()
		return FALSE

/mob/living/critter/small_animal/mouse/weak/mentor/admin
	name = "admin mouse"
	real_name = "admin mouse"
	desc = "A helpful (?) admin in the form of a mouse. Click to put them in your pocket so they can help you."
	status_name = "admin_mouse"
	is_admin = 1
	icon_state = "mouse-admin"
	icon_state_dead = "mouse-admin-dead"
	icon_state_exclaim = "mouse-admin-exclaim"
	pull_w_class = W_CLASS_BULKY
	is_npc = FALSE
	use_custom_color = FALSE
	player_can_spawn_with_pet = FALSE
	shiny_chance = 1365 //Odds with the shiny charm, because of how charming these guys are before they run you over with a truck!

	New()
		. = ..()
		src.fur_color = "#be5a53"
		// true when making the mob to not make the respawn timer reset...false here to allow for crime
		ghost_spawned = FALSE
		new /obj/item/implant/access/infinite/admin_mouse(src)
		SPAWN(1 SECOND)
			src.bioHolder.AddEffect("radio_brain", power = 3, do_stability = FALSE, magical = TRUE)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

	hand_attack(atom/target, params, location, control, origParams)
		if(istype(target, /mob/living) && src.a_intent == INTENT_HELP)
			var/mob/living/M = target
			src.into_pocket(M, 0)
		else
			return ..()

	understands_language(language)
		if(language == "animal") // by default admin mice speak english but we want them to understand animal-ese
			return 1
		return ..()

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(src.client && !isadmin(src))
			src.make_critter(/mob/living/critter/small_animal/mouse/weak)
			return

/* =============================================== */
/* --------------------- crab -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/crab
	name = "crab"
	real_name = "crab"
	desc = "Snip snap"
	icon_state = "crab"
	blood_id = "hemolymph"
	hand_count = 2
	speechverb_say = "snips"
	speechverb_gasp = "claks"
	speechverb_exclaim = "snaps"
	health_brute = 15
	health_burn = 15
	pet_text = list("gently pets", "rubs", "cuddles", "coddles")
	player_can_spawn_with_pet = TRUE
	var/can_hat = TRUE

	faction = list(FACTION_AQUATIC)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/crab_chirp.ogg', 20, TRUE, 2, 2, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] blurbles!</b>")
		return null

	attackby(obj/item/W, mob/living/user)
		if (is_incapacitated(src) || !src.is_npc)
			return ..()
		if (istype(W, /obj/item/clothing/head/cowboy) && src.can_hat)
			user.visible_message("<b>[user]</b> gives [src] \the [W]!","You give [src] \the [W].")
			qdel(W)
			src.visible_message("[src] starts dancing!")
			new /mob/living/critter/small_animal/crab/party(get_turf(src))
			qdel(src)
		else
			..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "beak"
		HH.name = "left claw"
		HH.limb_name = "claw"

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "beak"
		HH.name = "right claw"
		HH.limb_name = "claw"

/mob/living/critter/small_animal/crab/party
	name = "party crab"
	real_name = "party crab"
	desc = "This crab is having way more fun than you."
	icon_state = "crab_party"
	can_hat = FALSE

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/crab_chirp.ogg', 20, TRUE, 2, 2, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_ALERT("<b>[src] blurbles!</b>")
			if ("dance")
				if (src.emote_check(voluntary, 50))
					var/msg = pick("gets down","yee claws", "is feelin' it now", "dances to that song! The one that goes \"beep boo boo bop boo boo beep\"", "does a little dance","dances like no one's watching")
					FLICK(pick("crab_party-getdown","crab_party-hop","crab_party-partyhard"), src)
					return SPAN_ALERT("<b>[src] [msg]!</b>")
		return null

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				src.emote("dance")

	proc/dance_response()
		if (is_incapacitated(src) || !src.ai?.enabled)
			return
		SPAWN(rand(0, 10))
			src.emote("dance")

/mob/living/critter/small_animal/crab/polymorph
	health_brute = 45
	health_burn = 20
	is_npc = FALSE
	can_hat = FALSE
	player_can_spawn_with_pet = FALSE
	add_abilities = list(/datum/targetable/critter/frenzy/crabmaul)
	has_genes = FALSE

/mob/living/critter/small_animal/crab/lava
	name = "magma crab"
	desc = "A strange beast resembling a crab boulder.  Not to be confused with a rock lobster."
	icon_state = "lavacrab"
	icon_state_dead = "lavacrab-dead"
	density = TRUE
	anchored = ANCHORED
	butcherable = BUTCHER_NOT_ALLOWED
	health_burn_vuln = 0.1
	health_brute_vuln = 0.5
	death_text = "%src% flops over dead!"
	ai_type = /datum/aiHolder/empty
	can_hat = FALSE

/mob/living/critter/small_animal/crab/lava/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_MOB_HEATPROT, "lava_crab", 100)

/mob/living/critter/small_animal/crab/lava/death(var/gibbed)
	..()
	src.anchored = UNANCHORED

/mob/living/critter/small_animal/crab/lava/Login()
	..()
	src.anchored = UNANCHORED

/mob/living/critter/small_animal/crab/lava/Logout()
	..()
	src.anchored = initial(src.anchored)

/mob/living/critter/small_animal/crab/lava/deep
	name = "deep magma crab"
	health_brute = 30
	health_burn = 30
	player_can_spawn_with_pet = FALSE

/* =============================================== */
/* ------------------- trilobite ----------------- */
/* =============================================== */

/mob/living/critter/small_animal/trilobite
	name = "trilobite"
	real_name = "trilobite"
	blood_id = "hemolymph"
	desc = "This is an alien trilobite."
	icon_state = "trilobite"
	icon_state_dead = "trilobite-dead"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 6
	health_burn = 6
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE

	density = TRUE

	base_move_delay = 4
	base_walk_delay = 5

	ai_type = /datum/aiHolder/trilobite
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD

	faction = list(FACTION_AQUATIC)

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("trilobite", -(STAMINA_MAX-10))
		abilityHolder.addAbility(/datum/targetable/critter/bury_hide)
		SPAWN(1 SECOND)
			animate_bumble(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med/dash
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "mouth"
		HH.limb_name = "mouth"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 1.3, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chitters!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	death(var/gibbed)
		playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 1.7)
		new /obj/item/raw_material/claretine(src.loc)
		new /obj/item/raw_material/chitin(src.loc)
		if (prob(70))
			new /obj/item/raw_material/claretine(src.loc)
			new /obj/item/raw_material/chitin(src.loc)
		..()

	critter_attack(mob/target)
		if (isliving(target) && prob(60)) //might be attacking a sub
			//dash attack
			src.set_dir(get_dir(src,target))
			src.set_a_intent(prob(66) ? INTENT_DISARM : INTENT_HARM)
			var/list/params = list()
			params["left"] = TRUE
			params["ai"] = TRUE
			src.hand_range_attack(target, params)
		else
			src.set_dir(get_dir(src,target))
			..() //punch attack

/* =============================================== */
/* ------------------ hallucigenia --------------- */
/* =============================================== */

/mob/living/critter/small_animal/hallucigenia
	name = "hallucigenia"
	real_name = "hallucigenia"
	desc = "This is an alien hallucigenia."
	icon_state = "hallucigenia"
	icon_state_dead = "hallucigenia-dead"
	blood_id = "hemolymph"
	speechverb_say = "clicks"
	speechverb_exclaim = "screeches"
	speechverb_ask = "chitters"
	health_brute = 4
	health_burn = 4
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE

	density = TRUE

	base_move_delay = 13
	base_walk_delay = 15

	ai_type = /datum/aiHolder/spike

	faction = list(FACTION_AQUATIC)

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("hallucigenia", -(STAMINA_MAX-100))
		src.add_sm_light("hallucigenia\ref[src]", list(255,100,100,0.8 * 255))

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/kinetic/spike
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.name = "spikes"
		HH.limb_name = "spikes"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 0.7, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chitters!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	death(var/gibbed)
		playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 0.6, channel=VOLUME_CHANNEL_EMOTE)
		new /obj/item/reagent_containers/food/snacks/healgoo(get_turf(src))
		..()

/* =============================================== */
/* ------------------- pikaia -------------------- */
/* =============================================== */

/mob/living/critter/small_animal/pikaia
	name = "pikaia"
	real_name = "pikaia"
	desc = "This is an alien pikaia."
	icon_state = "pikaia"
	icon_state_dead = "pikaia-dead"
	speechverb_say = "bloops"
	speechverb_exclaim = "blips"
	speechverb_ask = "blups"
	health_brute = 24
	health_burn = 24
	flags = TABLEPASS | DOORPASS
	fits_under_table = TRUE

	density = TRUE

	base_move_delay = 2.3
	base_walk_delay = 4

	ai_type = /datum/aiHolder/pikaia
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD

	faction = list(FACTION_AQUATIC)

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("pikaia", -(STAMINA_MAX-140))
		abilityHolder.addAbility(/datum/targetable/critter/bury_hide)
		SPAWN(1 SECOND)
			animate_bumble(src)

	is_hulk()
		.= 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "body"
		HH.limb_name = "body"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/misc/talk/buwoo_exclaim.ogg', 90, TRUE, pitch = 0.8, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeals!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	emote(act, voluntary)
		if (act == "flip")
			if (!emote_check(voluntary, 2 SECONDS))
				return
			for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
				var/mob/living/M = G.affecting
				if (M == src)
					continue
				if (!G.affecting)
					continue
				animate_spin(src, prob(50) ? "L" : "R", 1, 0)
				if (G.state >= GRAB_STRONG && isturf(src.loc) && isturf(G.affecting.loc))
					src.emote("scream")
					logTheThing(LOG_COMBAT, src, "crunches [constructTarget(G.affecting,"combat")] [log_loc(src)]")
					M.lastattacker = get_weakref(src)
					M.lastattackertime = world.time
					G.affecting.TakeDamage("head", rand(2,8), 0, 0, DAMAGE_BLUNT)
					playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1, pitch = 1.3)
					src.visible_message(SPAN_ALERT("<B>[src] crunches [G.affecting]!</B>"))
		else
			return ..()

	death(var/gibbed)
		playsound(src, 'sound/misc/talk/blub.ogg', 80, TRUE, pitch = 0.6)
		new /obj/item/reagent_containers/food/snacks/greengoo(get_turf(src))

		..()

	critter_attack(mob/target)
		src.set_a_intent(INTENT_GRAB)
		src.set_dir(get_dir(src, target))

		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE

		var/obj/item/grab/G = src.equipped()
		if (!istype(G)) //if it hasn't grabbed something, try to
			if(!isnull(G)) //if we somehow have something that isn't a grab in our hand
				src.drop_item()
			src.hand_attack(target, params)
		else
			if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
				src.drop_item()
				return

			if (G.state <= GRAB_PASSIVE)
				G.AttackSelf(src)
			else
				src.emote("flip")
				src.ai?.move_away(target,1)

/* =============================================== */
/* ----------------- living Tail ----------------- */
/* =============================================== */

/mob/living/critter/small_animal/livingtail
	name = "Living tail"
	desc = "A twitching saurian tail, you feel mildly uncomfortable looking at it."
	icon_state = "twitchytail"
	hand_count = 0
	health_brute = 10
	health_burn = 10
	flags = NOSPLASH | TABLEPASS
	generic = FALSE
	butcherable = BUTCHER_NOT_ALLOWED
	no_stamina_stuns = TRUE
	has_genes = FALSE

	ai_retaliates = FALSE

	var/obj/item/organ/tail/lizard/tail_memory = null
	var/max_life_timer = 5
	var/current_life_timer = 0
	var/primary_color = "#21a833"
	var/secondary_color = "#000000"

/mob/living/critter/small_animal/livingtail/New()
	..()
	src.max_life_timer = rand(10, 20)
	if (!tail_memory)
		src.primary_color = rgb(rand(50,190), rand(50,190), rand(50,190))
		src.secondary_color = rgb(rand(50,190), rand(50,190), rand(50,190))
	src.setup_overlays()

/mob/living/critter/small_animal/livingtail/setup_overlays()
	var/image/overlayprimary = image('icons/misc/critter.dmi', "twitchytail_colorkey1")
	overlayprimary.color = primary_color
	var/image/overlaysecondary = image('icons/misc/critter.dmi', "twitchytail_colorkey2")
	overlaysecondary.color = secondary_color
	src.UpdateOverlays(overlayprimary, "bottomdetail")
	src.UpdateOverlays(overlaysecondary, "topdetail")

/mob/living/critter/small_animal/livingtail/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1

	if (prob(70))
		playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
		make_cleanable(/obj/decal/cleanable/blood/splatter, src.loc)
	..()
	if (src.current_life_timer++ >= src.max_life_timer)
		src.death()

/mob/living/critter/small_animal/livingtail/death(var/gibbed)
	if (gibbed)
		return ..()
	if (tail_memory)
		tail_memory.set_loc(get_turf(src))
	else
		var/obj/item/organ/tail/lizard/tail = new /obj/item/organ/tail/lizard(get_turf(src))
		tail.organ_color_1 = src.secondary_color
		tail.organ_color_2 = src.primary_color
		tail.update_tail_icon()
	..()
	qdel(src)

/mob/living/critter/small_animal/livingtail/Crossed(atom/movable/M as mob)
	..()
	if (!isalive(src))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(25))
			src.visible_message(SPAN_COMBAT("[src] weaves around [H]'s legs and trips [him_or_her(H)]!"))
			H.setStatus("resting", duration = INFINITE_STATUS)
			H.force_laydown_standup()

/* =============================================== */
/* --------------- Bunny & Hare ------------------ */
/* =============================================== */

/mob/living/critter/small_animal/bunny
	name = "space bunny"
	real_name = "space bunny"
	desc = "A little bunny.  In space."
	flags = TABLEPASS
	fits_under_table = 1
	hand_count = 2
	icon_state = "bunny"
	speechverb_say = "mutters"
	speechverb_exclaim = "squeals"
	speechverb_ask = "squeaks"
	health_brute = 8
	health_burn = 8
	butcherable = BUTCHER_YOU_MONSTER
	faction = list(FACTION_NEUTRAL)
	ai_type = /datum/aiHolder/bunny
	ai_retaliate_patience = 0 //retaliate when hit immediately
	ai_retaliate_persistence = RETALIATE_ONCE //but just hit back once
	player_can_spawn_with_pet = TRUE
	var/attack_damage = 2

	New()
		. = ..()
		AddComponent(/datum/component/waddling, height=4, angle=8)
		src.bioHolder.AddNewPoolEffect("jumpy", scramble=TRUE)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> squeaks!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "paw"
		HH.limb_name = "claws"

		HH = hands[2]
		HH.limb = new /datum/limb/mouth/small	// if not null, the special limb to use when attack_handing
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "mouth"					// the icon state of the hand UI background
		HH.name = "mouth"						// designation of the hand - purely for show
		HH.limb_name = "teeth"					// name for the dummy holder
		HH.can_hold_items = 0

	attackby(obj/item/I, mob/M)
		if(istype(I, /obj/item/reagent_containers/food/snacks/plant) && ishuman(M))
			src.visible_message("[M] feeds \the [src] some [I].", "[M] feeds you some [I].")
			for(var/damage_type in src.healthlist)
				var/datum/healthHolder/hh = src.healthlist[damage_type]
				hh.HealDamage(5)
			qdel(I)
			return
		. = ..()

	can_critter_eat()
		set_hand(2) // mouth hand
		src.set_a_intent(INTENT_HELP)
		return can_act(src, TRUE)

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (src.ai?.enabled && !istype(src.ai?.current_task, /datum/aiTask/sequence/goalbased/critter/flight_range))
			src.ai.interrupt()

	seek_food_target(var/range = 5)
		. = list()
		for (var/obj/item/reagent_containers/food/snacks/plant/S in view(range, get_turf(src)))
			. += S

/mob/living/critter/small_animal/bunny/hare
	name = "space hare"
	real_name = "space hare"
	desc = "A spry hare.  In space."
	icon_state = "hare"
	health_brute = 14
	health_burn = 14

	New()
		..()
		src.bioHolder.ActivatePoolEffect(src.bioHolder.GetEffectFromPool("jumpy"), overrideDNA=TRUE, grant_research=FALSE)

/* =============================================== */
/* -------------- Large Jellyfish ---------------- */
/* =============================================== */

/mob/living/critter/small_animal/large_jellyfish
	name = "jellyfish"
	real_name = "jellyfish"
	desc = "An oversized and over-aggressive jellyfish. Oh no."
	icon = 'icons/misc/sea_critter.dmi'
	icon_state = "jellyfish_large"
	icon_state_dead = "jellyfish_large-dead"
	blood_id = "hemolymph"
	pet_text = "pokes"
	speechverb_say = "quibbles"
	speechverb_exclaim = "shudders"
	speechverb_ask = "blorps"
	health_brute = 15
	health_burn = 15
	hand_count = 1

	density = TRUE

	base_move_delay = 13
	base_walk_delay = 15

	ai_type = /datum/aiHolder/ranged

	faction = list(FACTION_AQUATIC)

	meat_type = /obj/item/device/light/glowstick/green_on

	New()
		..()
		src.remove_stam_mod_max("small_animal")
		src.add_stam_mod_max("hallucigenia", -(STAMINA_MAX-100))
		src.color = random_saturated_hex_color()
		var/list/color_list = rgb2num(src.color || "#ffffff")
		src.add_medium_light("jellyglow", color_list + list(100))
		src.bioHolder.AddNewPoolEffect("plasma_metabolism", scramble=TRUE)
		#ifdef MAP_OVERRIDE_NEON // they need to be immune to plasma coral on neon, otherwise *shrug
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		#endif

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/arcflash
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handzap"
		HH.name = "tendrils"
		HH.limb_name = "tendrils"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream","chitter")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 0.7, channel=VOLUME_CHANNEL_EMOTE)
					return SPAN_EMOTE("<b>[src]</b> chitters!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream","chitter")
				return 2
		return ..()

	death(var/gibbed)
		playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, TRUE, pitch = 0.6, channel=VOLUME_CHANNEL_EMOTE)
		new /obj/item/reagent_containers/food/snacks/healgoo(get_turf(src))
		..()

/mob/living/critter/small_animal/large_jellyfish/grabby
	name = "jellyfish"
	real_name = "jellyfish"
	desc = "An oversized and over-aggressive jellyfish. Oh no."
	icon = 'icons/misc/sea_critter.dmi'
	icon_state = "jellyfish_large"
	icon_state_dead = "jellyfish_large-dead"
	blood_id = "hemolymph"
	pet_text = "pokes"
	speechverb_say = "quibbles"
	speechverb_exclaim = "shudders"
	speechverb_ask = "blorps"
	health_brute = 15
	health_burn = 15
	hand_count = 1

	density = TRUE

	base_move_delay = 2.3
	base_walk_delay = 4

	ai_type = /datum/aiHolder/pikaia
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_DEAD

	faction = list(FACTION_AQUATIC)

	is_hulk()
		.= 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/small_critter/med
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.name = "tendrils"
		HH.limb_name = "tendrils"

	emote(act, voluntary)
		if (act == "flip")
			if (!emote_check(voluntary, 2 SECONDS))
				return
			for (var/obj/item/grab/G in src.equipped_list(check_for_magtractor = 0))
				var/mob/living/M = G.affecting
				if (M == src)
					continue
				if (!G.affecting)
					continue
				animate_spin(src, prob(50) ? "L" : "R", 1, 0)
				if (G.state >= GRAB_STRONG && isturf(src.loc) && isturf(G.affecting.loc))
					src.emote("scream")
					logTheThing(LOG_COMBAT, src, "crunches [constructTarget(G.affecting,"combat")] [log_loc(src)]")
					M.lastattacker = get_weakref(src)
					M.lastattackertime = world.time
					G.affecting.TakeDamage("head", rand(2,8), 0, 0, DAMAGE_BLUNT)
					playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1, pitch = 1.3)
					src.visible_message(SPAN_ALERT("<B>[src] crunches [G.affecting]!</B>"))
		else
			return ..()

	critter_attack(mob/target)
		src.set_a_intent(INTENT_GRAB)
		src.set_dir(get_dir(src, target))

		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE

		var/obj/item/grab/G = src.equipped()
		if (!istype(G)) //if it hasn't grabbed something, try to
			if(!isnull(G)) //if we somehow have something that isn't a grab in our hand
				src.drop_item()
			src.hand_attack(target, params)
		else
			if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
				src.drop_item()
				return

			if (G.state <= GRAB_PASSIVE)
				G.AttackSelf(src)
			else
				src.emote("flip")
				src.ai?.move_away(target,1)
