/* =============================================== */
/* -------------------- Mouse -------------------- */
/* =============================================== */

ADMIN_INTERACT_PROCS(/mob/living/critter/small_animal/mouse, proc/glorp)

/mob/living/critter/small_animal/mouse/proc/glorp()
	src.icon_state = "mouse-glorp"
	src.icon_state_dead = "mouse-glorp-dead"
	src.fur_color = "#42BC52"
	src.real_name = "alien mouse"
	src.desc = "Gleep glorp bzeewop?"
	src.sound_scream = 'sound/voice/animal/glorp/glorp1.ogg'
	src.icon_state_exclaim = "mouse-glorp-exclaim"
	src.use_custom_color = FALSE
	src.UpdateName()
	src.setup_overlays()

/mob/living/critter/small_animal/mouse
	name = "space mouse"
	desc = "A mouse.  In space."
	flags = TABLEPASS | DOORPASS
	fits_under_table = 1
	hand_count = 2
	icon_state = "mouse_white"
	icon_state_dead = "mouse_white-dead"
	speech_verb_say = "squeaks"
	speech_verb_exclaim = "squeals"
	speech_verb_ask = "squeaks"
	health_brute = 8
	health_burn = 8
	faction = list(FACTION_NEUTRAL)
	ai_type = /datum/aiHolder/mouse
	ai_retaliate_patience = 0 //retaliate when hit immediately
	ai_retaliate_persistence = RETALIATE_ONCE //but just hit back once
	player_can_spawn_with_pet = TRUE
	sound_scream = 'sound/voice/animal/mouse_squeak.ogg'
	var/attack_damage = 3
	var/use_custom_color = TRUE
	var/shiny_chance = 4096 ///One in this chance of being shiny
	var/is_shiny = FALSE
	/// If set, flick to this icon state on scream emote
	var/icon_state_exclaim = null

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
					playsound(src, src.sound_scream, 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
					if(src.icon_state_exclaim)
						FLICK(src.icon_state_exclaim, src)
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

/* =============================================== */
/* ----------- mentor & admin mice --------------- */
/* =============================================== */

/mob/living/critter/small_animal/mouse/weak/mentor
	name = "mentor mouse"
	desc = "A helpful mentor in the form of a mouse. Click to put them in your pocket so they can help you."
	var/status_name = "mentor_mouse"
	var/is_admin = 0
	var/mob/last_poked = null
	var/colorkey_overlays = 0
	icon_state = "mouse-mentor"
	icon_state_dead = "mouse-mentor-dead"
	icon_state_exclaim = "mouse-mentor-exclaim"
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
		M.ensure_listen_tree().AddListenInput(LISTEN_INPUT_MENTOR_MOUSE)
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

TYPEINFO(/mob/living/critter/small_animal/mouse/weak/mentor/admin)
	start_listen_languages = list(LANGUAGE_ENGLISH, LANGUAGE_ANIMAL)

/mob/living/critter/small_animal/mouse/weak/mentor/admin
	name = "admin mouse"
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
	say_language = LANGUAGE_ENGLISH
	shiny_chance = 1365 //Odds with the shiny charm, because of how charming these guys are before they run you over with a truck!

	New()
		. = ..()
		src.fur_color = "#be5a53"
		// true when making the mob to not make the respawn timer reset...false here to allow for crime
		ghost_spawned = FALSE
		new /obj/item/implant/access/infinite/admin_mouse(src)
		SPAWN(1 SECOND)
			src.bioHolder?.AddEffect("radio_brain", power = 3, do_stability = FALSE, magical = TRUE)

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

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if(src.client && !isadmin(src))
			src.make_critter(/mob/living/critter/small_animal/mouse/weak)
			return
