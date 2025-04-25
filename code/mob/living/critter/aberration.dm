// A terrible post-human cloud of murder.
/mob/living/critter/aberration
	name = "transposed particle field"
	desc = {"A cloud of particles transposed by some manner of dangerous science, echoing some mannerisms of their previous configuration. In layman's
		terms, a goddamned science ghost."}
	icon_state = "aberration"
	density = TRUE
	anchored = ANCHORED

	hand_count = 1

	ai_type = /datum/aiHolder/aggressive
	is_npc = TRUE

	speechverb_say = "materializes"
	speechverb_ask = "emits"
	speechverb_exclaim = "forces"
	speechverb_stammer = "creates"
	speechverb_gasp = "rasps"
	speech_void = TRUE

	can_burn = FALSE
	can_implant = FALSE
	canbegrabbed = FALSE
	throws_can_hit_me = FALSE
	reagent_capacity = 0
	faction = list(FACTION_DERELICT)
	blood_id = null
	can_bleed = FALSE
	metabolizes = FALSE
	use_stamina = FALSE
	ailment_immune = TRUE
	throws_can_hit_me = FALSE

	grabresistmessage = "but their hands pass right through!"
	death_text = "%src% dissipates!"

	New()
		..()

		remove_lifeprocess(/datum/lifeprocess/blood)
		remove_lifeprocess(/datum/lifeprocess/chems)
		remove_lifeprocess(/datum/lifeprocess/mutations)
		remove_lifeprocess(/datum/lifeprocess/organs)
		remove_lifeprocess(/datum/lifeprocess/stuns_lying)
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/radiation)

		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_EXT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)

	death()
		..()
		qdel(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/aberration_field
		HH.name = "particle field"
		HH.limb_name = HH.name
		HH.can_hold_items = FALSE

	setup_healths()
		var/datum/healthHolder/brute = src.add_health_holder(/datum/healthHolder/aberration)
		brute.value = 100
		brute.maximum_value = 100
		brute.last_value = 100

	attack_hand(mob/living/M, params, location, control)
		boutput(M, SPAN_COMBAT("<b>Your hand passes right through! It's so cold...</b>"))
		return

	attackby(obj/item/I, mob/M)
		if (!istype(I, /obj/item/baton))
			boutput(M, SPAN_COMBAT("<b>[I] passes right through!</b>"))
			return

		var/obj/item/baton/B = I
		if (!B.can_stun(1, M))
			return
		M.visible_message(SPAN_COMBAT("<b>[M] shocks the [src.name] with [I]!</b>"),
			SPAN_COMBAT("<b>While your baton passes through, the [src.name] appears damaged!</b>"))
		M.lastattacked = get_weakref(src)
		B.process_charges(-1, M)

		src.hurt(50)

	bullet_act(obj/projectile/P)
		if (P.proj_data.hits_ghosts || (P.proj_data.damage_type == D_ENERGY && round(P.power * (1 - P.proj_data.ks_ratio), 1) > 1))
			src.hurt(100)

	projCanHit(datum/projectile/P)
		return P.damage_type == D_ENERGY

	do_disorient(stamina_damage, knockdown, stunned, unconscious, disorient = 60, remove_stamina_below_zero = 0, target_type = DISORIENT_BODY, stack_stuns = 1)
		return

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		return // no healing

	ex_act(severity)
		return

	blob_act(power)
		return

	is_spacefaring()
		return TRUE

	proc/hurt(damage)
		var/datum/healthHolder/Br = src.get_health_holder("brute")
		Br?.TakeDamage(damage)

	valid_target(var/mob/living/C)
		. = ..()
		if (istype(C, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if (istype(H.head, /obj/item/clothing/head/void_crown))
				. = FALSE

	Cross(atom/movable/mover)
		if (!istype(mover, /mob))
			return ..()
		var/mob/M = mover
		if (M.lying)
			return FALSE
		return ..()

	bump(atom/A)
		if (istype(A, /obj/machinery/door))
			var/obj/machinery/door/door = A
			door.open()
			return
		return ..()

	can_pull(atom/A)
		return FALSE

/datum/limb/aberration_field
	can_beat_up_robots = TRUE

	harm(mob/living/target, mob/living/user)
		if (GET_COOLDOWN(user, "envelop_attack"))
			return
		actions.start(new/datum/action/bar/icon/envelopAbility/critter(target, null), user)
		ON_COOLDOWN(user, "envelop_attack", 7 SECONDS)

/datum/healthHolder/aberration
	name = "connection"
	associated_damage_type = "brute"

	TakeDamage(damage)
		..(damage, FALSE)

