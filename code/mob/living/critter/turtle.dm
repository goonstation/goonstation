
/* ============================================= */
/* ------------------ Turtle ------------------- */
/* ============================================= */

/mob/living/critter/small_animal/turtle
	name = "turtle"
	desc = "A turtle. They are noble creatures of the land and sea."
	icon = 'icons/mob/critter/nonhuman/turtle.dmi'
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
	var/list/allowed_hats = list(/obj/item/clothing/head/hos_hat, /obj/item/clothing/head/hosberet, /obj/item/clothing/head/NTberet, \
								/obj/item/clothing/head/janiberet, /obj/item/clothing/head/beret/syndicate)

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
			if (istype(wearing_beret, /obj/item/clothing/head/NTberet))
				state += "-nt"
				if (istype(wearing_beret, /obj/item/clothing/head/NTberet/commander))
					state += "-com"
			else if (istype(wearing_beret, /obj/item/clothing/head/janiberet))
				state += "-jani"
			else if (istype(wearing_beret, /obj/item/clothing/head/beret/syndicate))
				state += "-syn"
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
			src.say("Check please!")
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


/mob/living/critter/small_animal/turtle/commander
	icon_state = "turtle-beret-nt-com"
	player_can_spawn_with_pet = FALSE
	is_pet = 1
	ai_type = /datum/aiHolder/empty

	New()
		..()
		var/obj/item/clothing/head/NTberet/commander/beret = new/obj/item/clothing/head/NTberet/commander(src)
		src.wearing_beret = beret
		src.UpdateIcon()

	take_beret(var/mob/M)
		if(!(isadmin(M)))
			boutput(M, SPAN_ALERT("You try to grab the beret, but [src] pulls into his shell before you can!"))
			playsound(src.loc, "rustle", 10, 1)
			src.enter_shell()
			return 0
		return ..()

/mob/living/critter/small_animal/turtle/leonardo //Kyle's new, beloved pet turtle

	name = "Leonardo"
	desc = "You are filled with the knowledge that if this turtle could carry a sword, it would."
	icon_state = "turtle-beret-nt"
	player_can_spawn_with_pet = FALSE
	is_pet = FALSE
	ai_type = /datum/aiHolder/empty

	New()
		..()
		var/obj/item/clothing/head/NTberet/beret = new/obj/item/clothing/head/NTberet(src)
		wearing_beret = beret
		src.UpdateIcon()
