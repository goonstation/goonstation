/obj/item/device/ticket_writer/odd
	name = "Security TicketWriter 3000"
	desc = "This new and improved edition features upgraded hardware and extra crime-deterring features."
	icon_state = "ticketwriter-odd"

	ticket(mob/user)
		var/target_key = ..()
		if (isnull(target_key))
			return
		var/mob/M = ckey_to_mob(target_key)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/limb = pick("l_arm","r_arm","l_leg","r_leg")
			H.sever_limb(limb)

/obj/death_button/hotdog

	attack_hand(mob/user)
		if (current_state < GAME_STATE_FINISHED && !isadmin(user))
			boutput(user, "<span class='alert'>Looks like you can't press this yet.</span>")
			return
		if (user.stat)
			return
		var/turf/T = get_turf(src)
		T.fluid_react_single("hot_dog", 3000)
		new /obj/effect/supplyexplosion(T)
		playsound(T, 'sound/effects/ExplosionFirey.ogg', 100, 1)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.limbs.sever("all")
		else
			user.gib()

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/pet
	warm_count = 25

	hatch_check(var/shouldThrow = 0, var/mob/user, var/turf/T)
		var/obj/critter/C = ..()
		if (!C)
			return
		C.AddComponent(/datum/component/pet, user)

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/pet/cat
	critter_type = /mob/living/critter/small_animal/cat

/datum/component/pet
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/critter/critter
	var/mob/critter_parent

TYPEINFO(/datum/component/pet)
	initialization_args = list(
		ARG_INFO("critter_parent", DATA_INPUT_MOB_REFERENCE, "Critter parent mob")
	)

/datum/component/pet/Initialize(mob/critter_parent)
	if(!istype(parent, /obj/critter))
		return COMPONENT_INCOMPATIBLE
	src.critter = parent
	src.critter_parent = critter_parent
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/try_grab)
	RegisterSignal(critter_parent, COMSIG_MOB_DEATH, .proc/on_parent_die)

/datum/component/pet/proc/try_grab(obj/critter/C, mob/user)
	if(!(user == critter_parent && user.a_intent == INTENT_GRAB && C.alive))
		return
	user.set_pulling(C)
	C.wanderer = FALSE
	C.task = "thinking"
	C.wrangler = user
	C.visible_message("<span class='alert'><b>[user]</b> wrangles [C].</span>")

/datum/component/pet/proc/on_parent_die()
	if(IN_RANGE(critter, critter_parent, (SQUARE_TILE_WIDTH + 1) / 2))
		critter.visible_message("<span class='alert'><b>[critter]</b> droops their head mournfully.</span>")

/datum/component/pet/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKHAND)
	UnregisterSignal(critter_parent, COMSIG_MOB_DEATH)
	. = ..()

/datum/betting_controller
