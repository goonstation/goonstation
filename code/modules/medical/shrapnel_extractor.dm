#define CAUSE_EXPECTED_PAIN(victim, damage)\
	random_brute_damage(victim, damage);\
	take_bleeding_damage(victim, null, damage);\
	victim.emote("scream");

#define DRUM_BUFFER_SIZE 5

/// This tool is mainly used by NanoTrasen Emergency Paramedics. It lets you remove shrapnel from someone whos standing up, at the cost of hurting. Its kind of a pseudo surgery that really hurts.
/obj/item/shrapnel_extractor
	name = "Shrapnel Extractor"
	desc = "An inovative tool that barely reached the minimal safety requirment to become a marketable medical product. \
	 You can use it on anyone who got embedded with shrapnel to suck it out with <I>acceptable</I> levels of bleeding. \
	 "
	icon = 'icons/obj/surgery.dmi'
	icon_state = "shrapnel_extractor-empty" // icon by TekoTheTeapot
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "shrapnel_extractor"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	hit_type = DAMAGE_BLUNT
	force = 5
	w_class = W_CLASS_SMALL
	tooltip_flags = REBUILD_ALWAYS
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	stamina_damage = 5
	stamina_cost = DRUM_BUFFER_SIZE
	stamina_crit_chance = 35
	move_triggered = FALSE

	HELP_MESSAGE_OVERRIDE("Use on a person with embedded shrapnel in them to extract it. Use in hand to dump the shrapnel you extracted.")

	var/base_icon = "shrapnel_extractor"
	var/interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_ACT

/obj/item/shrapnel_extractor/New()
	..()
	src.create_storage(/datum/storage/no_hud,
			prevent_holding = list(/obj/item),
			can_hold=list(/obj/item/implant/projectile, /obj/item/organ/eye),
			slots = DRUM_BUFFER_SIZE,
			params = list("use_inventory_counter" = TRUE)
	)

	if(prob(5)) // :pensive:
		desc += " After 7 month in R&D, hopefully it's been worth the wait."

/obj/item/shrapnel_extractor/get_desc(dist, mob/user)
	. = ..()
	. += " It currently housing [length(src.storage)]/[DRUM_BUFFER_SIZE] shrapnel fragments."

/obj/item/shrapnel_extractor/attack(mob/target, mob/user, def_zone, is_special, params)
	if(is_special || !ishuman(target) || user.a_intent != INTENT_HELP)
		return ..()

	if(isnull(src.storage)) // should not happen but cant risk it.
		boutput(user, SPAN_NOTICE("The internal collection drum broke! you can not use this!"))
		return

	if(src.storage.is_full())
		boutput(user, SPAN_NOTICE("The internal collection drum is full! dump it before you can use it again."))
		playsound(user, 'sound/effects/brrp.ogg', 20, TRUE, 0, 0.8)
		return

	var/mob/living/carbon/human/patient = target

	if (length(patient.implant) == 0)
		boutput(user, SPAN_NOTICE("You can not find any remnent within [target]."))
		return

	SETUP_GENERIC_ACTIONBAR(user, src, 1 SECONDS ,PROC_REF(attempt_extraction), list(patient, user), src.icon, src.icon_state, null, src.interrupt_flags)

/obj/item/shrapnel_extractor/attack_self(mob/user)
	. = ..()
	if(isnull(src.storage) || !length(src.storage.get_contents()))
		return .

	for (var/obj/item/I as anything in src.storage.get_contents())
		src.storage.transfer_stored_item(I, get_turf(src))
		I.pixel_x = rand(-4, 10)
		I.pixel_y = rand(-4, 10)

	playsound(src, "sound/weapons/casings/casing-small-0[rand(1,6)].ogg", 30, 0.1)


/obj/item/shrapnel_extractor/update_icon()
	. = ..()
	if(isnull(src.storage) || length(src.storage.get_contents()))
		src.icon_state = "[src.base_icon]-full"
	else
		src.icon_state = "[src.base_icon]-empty"


/obj/item/shrapnel_extractor/proc/attempt_extraction(var/mob/living/carbon/human/patient as mob, var/mob/living/surgeon as mob)
	var/fluff = pick(" messes up", "'s hand slips", " nearly drops [src]", "'s hand twitches", " accidentally vacuum their nose")

	var/screw_up_prob = calc_screw_up_prob(patient, surgeon, 10)

	var/damage_low = calc_surgery_damage(surgeon, screw_up_prob, rand(1,5))
	var/damage_high = calc_surgery_damage(surgeon, screw_up_prob, rand(5,10))

	if (surgeon.bioHolder.HasEffect("clumsy") && prob(30))
		surgeon.visible_message(\
		SPAN_ALERT("<b>[surgeon]</b> points the [src] to [his_or_her(surgeon)] face to check if its working and sucks [his_or_her(surgeon)] eyeball!"), \
		SPAN_ALERT("You point the [src] to your face and suck in your eyeball!"))

		surgeon.changeStatus("disorient", 2 SECOND)
		JOB_XP(surgeon, "Clown", 1)

		CAUSE_EXPECTED_PAIN(surgeon, damage_high)
		return

	playsound(patient, 'sound/effects/suck.ogg', 20, TRUE)

	if(prob(screw_up_prob))
		do_slipup(surgeon, patient, "chest", damage_low, fluff)
		return

	for (var/obj/item/implant/projectile/I in patient.implant)
		surgeon.tri_message(patient, \
			SPAN_ALERT("<b>[surgeon]</b> reaches with the [src] into [patient == surgeon ? his_or_her(patient) : "[patient]'s"] wound and pull \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : patient] with the [src]!"),\
			SPAN_ALERT("You suck out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [src]!"),\
			SPAN_ALERT("[patient == surgeon ? "You suck" : "<b>[surgeon]</b> suck"] out \an [I] from you with [src]!"))

		I.on_remove(patient)
		patient.implant.Remove(I)

		src.storage.add_contents(I, surgeon, visible=FALSE)

		// This tool is sophisticated, but operating on a patient who's awake, moving (and probably full of adrelaline) with a glorified handheld vacuum is risky.
		CAUSE_EXPECTED_PAIN(patient, damage_low)

		return


#undef CAUSE_EXPECTED_PAIN
#undef DRUM_BUFFER_SIZE
