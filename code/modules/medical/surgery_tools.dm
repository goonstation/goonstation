/*
CONTAINS:
	- SCALPEL
	- CIRCULAR SAW
	- STAPLE GUN
	- DEFIBRILLATOR
	- SUTURE
	- BANDAGE
	- BODY BAG
	- HEMOSTAT
	- REFLEX HAMMER
	- PENLIGHT
	- SURGERY TRAY
	- SURGICAL SCISSORS
*/
/* ================================================= */
/* -------------------- Scalpel -------------------- */
/* ================================================= */

/obj/item/scalpel
	name = "scalpel"
	desc = "A surgeon's tool, used to cut precisely into a subject's body."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel1"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "scalpel"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_CUTTING
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 5
	w_class = W_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	move_triggered = 1

	New()
		..()
		src.create_reagents(5)
		setProperty("piercing", 80)
		BLOCK_SETUP(BLOCK_KNIFE)


	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.reagents && src.reagents.total_volume)
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
		else
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>)")
		if (is_special || !scalpel_surgery(target, user))
			return ..()
		else
			if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
				src.reagents.trans_to(target,5)
			return

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/scalpel/vr
	icon = 'icons/effects/VR.dmi'
	icon_state = "scalpel"

/* ====================================================== */
/* -------------------- Circular Saw -------------------- */
/* ====================================================== */

/obj/item/circular_saw
	name = "circular saw"
	desc = "A saw used to slice through bone in surgeries, and attackers in self defense."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "saw"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SAWING
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/circsaw.ogg'
	force = 8
	w_class = W_CLASS_TINY
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	move_triggered = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/double)
		src.create_reagents(5)
		BLOCK_SETUP(BLOCK_LARGE)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.reagents && src.reagents.total_volume)
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
		else
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>)")
		if (is_special || !saw_surgery(target,user))
			return ..()
		else
			if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
				src.reagents.trans_to(target,5)
			return
	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slashes [his_or_her(user)] own throat with [src]!</b>"))
		blood_slash(user, 25)
		playsound(user.loc, src.hitsound, 50, 1)
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

/obj/item/circular_saw/vr
	icon = 'icons/effects/VR.dmi'
	icon_state = "saw"

/* =========================================================== */
/* -------------------- Enucleation Spoon -------------------- */
/* =========================================================== */

/obj/item/surgical_spoon
	name = "enucleation spoon"
	desc = "A surgeon's tool, used to protect the globe of the eye during eye removal surgery, and to lift the eye out of the socket. You could eat food with it too, I guess."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "spoon"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "scalpel"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SPOONING
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	force = 5
	w_class = W_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	move_triggered = 1

	New()
		..()
		src.create_reagents(5)
		setProperty("piercing", 80)


	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.reagents && src.reagents.total_volume)
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(src)]")
		else
			logTheThing(LOG_COMBAT, user, "used [src] on [constructTarget(target,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>)")
		if (is_special || !spoon_surgery(target, user))
			return ..()
		else
			if (src.reagents && src.reagents.total_volume)//ugly but this is the sanest way I can see to make the surgical use 'ignore' armor
				src.reagents.trans_to(target,5)
			return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message(SPAN_ALERT("<b>[user] jabs [src] straight through [hisher] eye and into [hisher] brain!</b>"))
		blood_slash(user, 25)
		user.TakeDamage("head", 150, 0)
		playsound(user.loc, 'sound/effects/espoon_suicide.ogg', 50, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

/* ==================================================== */
/* -------------------- Staple Gun -------------------- */
/* ==================================================== */

/obj/item/staple_gun
	name = "staple gun"
	desc = "A medical staple gun for securely reattaching limbs."
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "staplegun"
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	throw_speed = 4
	throw_range = 20
	force = 5
	c_flags = ONBELT
	object_flags = NO_ARM_ATTACH | NO_GHOSTCRITTER
	var/datum/projectile/staple = new/datum/projectile/bullet/staple
	var/ammo = 20
	stamina_damage = 15
	stamina_cost = 7
	stamina_crit_chance = 15

	// Every bit of usability helps (Convair880).
	examine()
		. = ..()
		. += "There are [src.ammo] staples left."

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!ismob(target))
			return

		src.add_fingerprint(user)

		if (src.ammo < 1)
			user.show_text("*click* *click*", "red")
			playsound(user, 'sound/weapons/Gunclick.ogg', 50, TRUE)
			return ..()

		if (user.a_intent != "help" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.visible_message(SPAN_ALERT("<B>[user] shoots [H] point-blank with [src]!</B>"))
			hit_with_projectile(user, staple, H)
			src.ammo--
			if (H && isalive(H))
				H.lastgasp()
			return

		if (!ishuman(target) || !(user.zone_sel && (user.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg", "head"))))
			return ..()

		var/mob/living/carbon/human/H = target

		//Attach butt to head
		if (user.zone_sel.selecting == "head")
			if (istype(H.head, /obj/item/clothing/head/butt))
				var/obj/item/clothing/head/butt/B = H.head
				B.staple()
				if (src.staple.shot_sound)
					playsound(user, src.staple.shot_sound, 50, 1)
				if (user == H)
					user.visible_message(SPAN_ALERT("<b>[user] staples \the [B.name] to [his_or_her(user)] own head! [prob(10) ? pick("Woah!", "What a goof!", "Wow!", "WHY!?", "Huh!"): null]"))
				else
					user.visible_message(SPAN_ALERT("<b>[user] staples \the [B.name] to [H.name]'s head!"))
				if (H.stat!=2)
					H.emote(pick("cry", "wail", "weep", "sob", "shame", "twitch"))
				src.ammo--
				logTheThing(LOG_COMBAT, user, "staples a butt to [constructTarget(H,"combat")]'s head")
				return

			else if (istype(H.wear_mask, /obj/item/clothing/mask/))
				var/obj/item/clothing/mask/K = H.wear_mask
				K.staple()
				if (src.staple.shot_sound)
					playsound(user, src.staple.shot_sound, 50, 1)
				if (user == H)
					user.visible_message(SPAN_ALERT("<b>[user] staples [K] to [his_or_her(user)] own head! [prob(10) ? pick("Woah!", "What a goof!", "Wow!", "WHY!?", "Huh!"): null]"))
				else
					user.visible_message(SPAN_ALERT("<b>[user] staples [K] to [H]'s head!"))
				if (H.stat!=2)
					H.emote(pick("shake", "flinch", "tremble", "shudder", "twitch_v", "twitch"))
				src.ammo--
				logTheThing(LOG_COMBAT, user, "staples [K] to [constructTarget(H,"combat")]'s head")
				return

		if (!surgeryCheck(H, user))
			return ..()

		if (user.zone_sel.selecting in H.limbs.vars) //ugly copy paste in surgery_procs.dm for suture
			var/obj/item/parts/surgery_limb = H.limbs.vars[user.zone_sel.selecting]
			if (istype(surgery_limb))
				src.ammo--
				surgery_limb.surgery(src)
			return


// a mostly decorative thing from z2 areas I want to add to office closets
/obj/item/staple_gun/red
	name = "stapler"
	desc = "A red stapler.  No, not THAT red stapler."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "stapler"
	item_state = "stapler"

/* =============================================== */
/* -------------------- Defib -------------------- */
/* =============================================== */

TYPEINFO(/obj/item/robodefibrillator)
	mats = 10
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/item/robodefibrillator
	name = "defibrillator"
	desc = "Uses electrical currents to restart the hearts of critical patients."
	flags = TABLEPASS | CONDUCT
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "defib-off"
	item_state = "defib"
	pickup_sfx = 'sound/items/pickup_defib.ogg'
	speech_verb_say = "beeps"

	var/icon_base = "defib"
	var/charge_time = 100
	var/emagged = 0
	var/makeshift = 0
	var/mounted = FALSE
	var/obj/item/cell/cell = null

	emag_act(var/mob/user)
		if (src.makeshift)
			if (user)
				user.show_text("You prod at [src], but it doesn't do anything.", "red")
			return 0
		if (!src.emagged)
			if (user)
				user.show_text("You short out the on board medical scanner!", "blue")
			src.desc += " The screen only shows the word KILL flashing over and over."
			src.emagged = 1
			return 1
		else
			if (user)
				user.show_text("This has already been tampered with.", "red")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You reapair the on board medical scanner.", "blue")
			src.desc = null
			src.desc = "Uses electrical currents to restart the hearts of critical patients."
		src.emagged = 0
		return 1

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!isliving(target) || issilicon(target))
			return ..()
		if (src.defibrillate(target, user, src.emagged, src.makeshift, src.cell))
			JOB_XP(user, "Medical Doctor", 5)
			src.delStatus("defib_charged")
			if(istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				var/obj/machinery/atmospherics/unary/cryo_cell/cryo = src.loc
				cryo.shock_icon()
			flick("[src.icon_base]-shock", src)

	attack_self(mob/user as mob)
		if(ON_COOLDOWN(src, "defib_cooldown", src.charge_time))
			user.show_text("[src] is [src.hasStatus("defib_charged") ? "already primed" : "still recharging"]!", "red")
			return
		if(!src.hasStatus("defib_charged"))
			user.visible_message(SPAN_ALERT("[user] rubs the paddles of [src] together."), SPAN_NOTICE("You rub the paddles of [src] together."), SPAN_ALERT("You hear an electrical whine."))
			playsound(user.loc, 'sound/items/defib_charge.ogg', 90, 0)
			SETUP_GENERIC_ACTIONBAR(user, src, 0.2 SECONDS, PROC_REF(charge), user, src.icon, "[src.icon_base]-on", null, INTERRUPT_NONE)

	proc/charge(mob/user)
		if(prob(1))
			user.say("CLEAR!")
		src.setStatus("defib_charged", 3 SECONDS)

	proc/do_the_shocky_thing(mob/user as mob)
		if (!src.hasStatus("defib_charged"))
			user.show_text("[src] needs to be primed first!", "red")
			return 0
		playsound(src.loc, 'sound/impact_sounds/Energy_Hit_3.ogg', 75, 1, pitch = 0.92)
		src.delStatus("defib_charged")
		if(istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/obj/machinery/atmospherics/unary/cryo_cell/cryo = src.loc
			cryo.shock_icon()
		flick("[src.icon_base]-shock", src)
		return 1

	disposing()
		..()
		if (src.cell)
			src.cell.dispose()
			src.cell = null

	get_desc()
		..()
		if (istype(src.cell))
			if (src.cell.artifact)
				return
			else
				. += "The charge meter reads [round(src.cell.percent())]%."

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.defibrillate(user, user, src.emagged, src.makeshift, src.cell, 1))
			SPAWN(50 SECONDS)
				if (user && !isdead(user))
					user.suiciding = 0
		else
			user.suiciding = 0
		return 1

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/item/robodefibrillator/proc/defibrillate(var/mob/living/patient as mob, var/mob/living/user as mob, var/emagged = 0, var/faulty = 0, var/obj/item/cell/cell = null, var/suiciding = 0)
	if (!isliving(patient))
		return 0

	if (cell && cell.percent() <= 0)
		user.show_text("[src] doesn't have enough power in its cell!", "red")
		return 0

	var/shockcure = 0
	for (var/datum/ailment_data/V in patient.ailments)
		if (V.cure_flags & CURE_ELEC_SHOCK)
			shockcure = 1
			break

	if(!istype(src.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		user.visible_message(SPAN_ALERT("<b>[user]</b> places the electrodes of [src] onto [user == patient ? "[his_or_her(user)] own" : "[patient]'s"] [suiciding ? "eyes" : "chest"]!"),\
		SPAN_ALERT("You place the electrodes of [src] onto [user == patient ? "your own" : "[patient]'s"] [suiciding ? "eyes" : "chest"]!"))

	if (emagged || (patient.health < 0 && !faulty) || (shockcure && !faulty) || (faulty && prob(25 + suiciding)) || (suiciding && prob(44)))

		if (!do_the_shocky_thing(user))
			// shit done didnt work dangit
			return 0

		user.visible_message(SPAN_ALERT("<b>[user]</b> shocks [user == patient ? "[him_or_her(user)]self" : patient] with [src]!"),\
		SPAN_ALERT("You shock [user == patient ? "yourself" : patient] with [src]!"))
		logTheThing(LOG_COMBAT, patient, "was defibrillated by [constructTarget(user,"combat")] with [src] [log_loc(patient)]")


		if (patient.bioHolder.HasEffect("resist_electric"))
			patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond at all!"),\
			SPAN_NOTICE("You resist the shock!"))
			src.say("ERROR: Unable to complete circuit for shock delivery!")
			return 1

		else if (isdead(patient))
			patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond at all!"))
			src.say("ERROR: Patient is deceased.")
			patient.setStatus("defibbed", 1.5 SECONDS)
			return 1

		else

			if ((patient.hasStatus("defibbed") && prob(90)) || prob(75)) // it was a 100% chance before... probably
				patient.cure_disease_by_path(/datum/ailment/malady/flatline)
			if (!patient.find_ailment_by_type(/datum/ailment/malady/flatline))
				src.say("Normal cardiac rhythm restored.")
			else
				src.say("Lethal dysrhythmia detected. Patient is still in cardiac arrest!")
			patient.Virus_ShockCure(35)	// so it doesnt have a 100% chance to cure roboTF
			patient.setStatus("defibbed", user == patient ? 6 SECONDS : 12 SECONDS)

			if (ishuman(patient)) //remove later when we give nonhumans pathogen / organ response?
				var/mob/living/carbon/human/H = patient
				var/sumdamage = patient.get_brute_damage() + patient.get_burn_damage() + patient.get_toxin_damage()
				if (suiciding)
					; // do nothing
				else if (patient.health < 0)
					if (sumdamage >= 90)
						user.show_text("<b>[patient]</b> looks horribly injured. Resuscitation alone may not help revive them.", "red")
						src.say("Patient has life-threatening injuries. Patient is unlikely to survive unless these wounds are treated.")
					if (prob(66))
						patient.visible_message(SPAN_NOTICE("<b>[patient]</b> inhales deeply!"))
						patient.take_oxygen_deprivation(-50)
						if (H.organHolder && H.organHolder.heart)
							H.get_organ("heart").heal_damage(10,10,10)
					else if (patient.hasStatus("defibbed")) // Always gonna get *something* if you keep shocking them
						patient.visible_message(SPAN_NOTICE("<b>[patient]</b> inhales sharply!"))
						patient.take_oxygen_deprivation(-10)
						if (H.organHolder && H.organHolder.heart)
							H.get_organ("heart").heal_damage(3,3,3)
					else
						patient.visible_message(SPAN_ALERT("<b>[patient]</b> doesn't respond!"))

			if (cell)
				var/adjust = cell.charge
				if (adjust <= 0) // bwuh??
					adjust = 1000 // fu
				patient.changeStatus("unconscious", min(0.002 * adjust, 10) SECONDS)
				patient.stuttering += min(0.005 * adjust, 25)
				//DEBUG_MESSAGE("[src]'s defibrillate(): adjust = [adjust], paralysis + [min(0.001 * adjust, 5)], stunned + [min(0.002 * adjust, 10)], weakened + [min(0.002 * adjust, 10)], stuttering + [min(0.005 * adjust, 25)]")

			else if (faulty)
				patient.changeStatus("unconscious", 1.5 SECONDS)
				patient.stuttering += 5
			else
#ifdef USE_STAMINA_DISORIENT
				if (emagged)
					patient.do_disorient(130, knockdown = 50, stunned = 50, unconscious = 40, disorient = 60, remove_stamina_below_zero = 0)
				else
					patient.changeStatus("unconscious", 5 SECONDS)
#else
				patient.changeStatus("unconscious", 5 SECONDS)

#endif
				patient.stuttering += 10

			patient.show_text("You feel a powerful jolt[suiciding ? " wrack your brain" : null]!", "red")
			patient.shock_cyberheart(100)
			patient.emote("twitch_v")
			if (suiciding)
				user.take_brain_damage(119)
				user.TakeDamage("head", 0, 99)

			if (cell)
				cell.zap(patient, 1)
				if (prob(25 + suiciding))
					cell.zap(user)
				cell.use(cell.charge)
				src.tooltip_rebuild = 1

			if (emagged && !faulty && prob(10))
				user.show_text("[src]'s on board scanner indicates that the target is undergoing a cardiac arrest!", "red")
				patient.contract_disease(/datum/ailment/malady/flatline, null, null, 1) // path, name, strain, bypass resist
			return 1

	else
		if (faulty)
			user.visible_message("Nothing happens!", SPAN_ALERT("[src] doesn't discharge!"))
		else
			if (do_the_shocky_thing(user))
				user.visible_message(SPAN_ALERT("<b>[user]</b> shocks [user == patient ? "[him_or_her(user)]self" : patient] with [src]!"),\
				SPAN_ALERT("You shock [user == patient ? "yourself" : patient] with [src]!"))
				logTheThing(LOG_COMBAT, patient, "was defibrillated by [constructTarget(user,"combat")] with [src] when they didn't need it at [log_loc(patient)]")
				patient.changeStatus("knockdown", 0.1 SECONDS)
				patient.force_laydown_standup()
				patient.remove_stamina(45)
				if (isdead(patient) && !patient.bioHolder.HasEffect("resist_electric"))
					patient.setStatus("defibbed", 1.5 SECONDS)

		return 0

/obj/item/robodefibrillator/emagged
	emagged = 1
	desc = "Uses electrical currents to restart the hearts of critical patients. The screen only shows the word KILL flashing over and over."

/obj/item/robodefibrillator/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/robodefibrillator/makeshift
	name = "shoddy-looking makeshift defibrillator"
	desc = "It might restart your heart, I guess, or it might barbeque your insides."
	icon_state = "cell-on"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "cell"
	icon_base = "cell"
	makeshift = 1

	New(var/location, var/obj/item/cell/newcell)
		..()
		if (!istype(newcell))
			newcell = new /obj/item/cell/charged(src)
		src.cell = newcell
		newcell.set_loc(src)


/obj/item/robodefibrillator/mounted
	var/obj/machinery/defib_mount/parent = null	//temp set while not attached
	w_class = W_CLASS_BULKY
	mounted = TRUE

	disposing()
		parent?.defib = null
		parent = null
		..()

TYPEINFO(/obj/machinery/defib_mount)
	mats = 25

/obj/machinery/defib_mount
	name = "mounted defibrillator"
	icon = 'icons/obj/compact_machines.dmi'
	desc = "Uses electrical currents to restart the hearts of critical patients."
	icon_state = "defib1"
	anchored = ANCHORED
	density = 0
	status = REQ_PHYSICAL_ACCESS
	/// defibrillator, when out of mount
	var/obj/item/robodefibrillator/mounted/defib = null

	New()
		..()
		if (!defib)
			src.defib = new /obj/item/robodefibrillator/mounted(src)
		RegisterSignal(src, COMSIG_CORD_RETRACT, PROC_REF(put_back_defib))

	emag_act()
		..()
		return defib?.emag_act()

	disposing()
		if (defib)
			qdel(defib)
			defib = null
		..()

	process()
		if(!QDELETED(src.defib))
			if (BOUNDS_DIST(src.defib, src) > 0)
				src.put_back_defib()
		else
			src.defib = null
		..()

	update_icon()
		if (defib && defib.loc == src)
			icon_state = "defib1"
		else
			icon_state = "defib0"

	attack_hand(mob/living/user)
		if (isAI(user) || isintangible(user) || isobserver(user) || !in_interact_range(src, user)) return
		user.lastattacked = src
		..()
		if(!defib || QDELETED(defib))
			defib = null // ditch the ref, just in case we're QDEL'd but defib is still holding on
			return //maybe a bird ate it
		if(defib.loc != src)
			return //if someone else has it, don't put it in user's hand
		src.AddComponent(/datum/component/cord, src.defib, base_offset_x = 0, base_offset_y = -2)
		user.put_in_hand_or_drop(src.defib)
		src.defib.parent = src
		playsound(src, 'sound/items/pickup_defib.ogg', 65, vary=0.2)
		UpdateIcon()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = src
		if (W == src.defib)
			src.put_back_defib()

	/// Put the defib back in the mount, by force if necessary.
	proc/put_back_defib()
		if (src.defib)
			src.RemoveComponentsOfType(/datum/component/cord)
			src.defib.force_drop(sever=TRUE)
			src.defib.set_loc(src)
			src.defib.parent = null
			src.ClearSpecificOverlays("cord_\ref[src]")
			playsound(src, 'sound/items/putback_defib.ogg', 65, vary=0.2)
			UpdateIcon()

/* ================================================ */
/* -------------------- Suture -------------------- */
/* ================================================ */

/obj/item/suture
	name = "suture"
	desc = "A fine, curved needle with a length of absorbable polyglycolide suture thread."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "suture"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "suture"
	flags = TABLEPASS | CONDUCT
	hit_type = DAMAGE_STAB
	object_flags = NO_ARM_ATTACH | NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	force = 1
	throwforce = 1
	throw_speed = 4
	throw_range = 20
	m_amt = 5000
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	var/in_use = 0
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (is_special)
			return ..()
		if (!suture_surgery(target,user))
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/zone = user.zone_sel.selecting
				var/surgery_status = H.get_surgery_status(zone)
				if (surgery_status && H.organHolder)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 10, zone, surgery_status, rand(1,2), Vrb = "sutur"), user)
					src.in_use = 1
				else if (H.bleeding)
					actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 15, 0, 0, 5, Vrb = "sutur"), user)
					src.in_use = 1
				else
					user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to close!", "red")
					H.organHolder.chest.op_stage = 0
					H.organHolder.close_surgery_regions()
					src.in_use = 0
					return
		else
			return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] rapidly sews [his_or_her(user)] mouth and nose closed with [src]! Holy shit, how?!</b>"))
		user.take_oxygen_deprivation(160)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/suture/vr
	icon = 'icons/effects/VR.dmi'

/* ================================================= */
/* -------------------- Bandage -------------------- */
/* ================================================= */

/obj/item/bandage
	name = "bandage"
	desc = "A length of gauze that will help stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bandage-item-3"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "bandage"
	flags = TABLEPASS
	object_flags = NO_ARM_ATTACH
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 1
	throw_speed = 4
	throw_range = 20
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	var/uses = 6
	var/in_use = 0
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	//if we want this bandage to do some healing. choose how much healing of each type of damage it should do per application.
	var/brute_heal = 0
	var/burn_heal = 0

	get_desc()
		..()
		if (src.uses >= 0)
			switch (src.uses)
				if (-INFINITY to 0)
					. += SPAN_ALERT("There's none left.")
				if (1 to 5)
					. += SPAN_ALERT("There's enough left to bandage about [src.uses] wound[s_es(src.uses)].")
				if (6 to INFINITY)
					. += "None of it has been used."

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!src.uses || src.icon_state == "bandage-item-0")
			user.show_text("There's nothing left of [src]!", "red")
			return
		if (src.in_use)
			return
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/zone = user.zone_sel.selecting
			var/surgery_status = H.get_surgery_status(zone)
			if (surgery_status && H.organHolder)
				actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 10, zone, surgery_status, rand(2,5), brute_heal, burn_heal, "bandag"), user)
				src.in_use = 1
			else if (H.bleeding)
				actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 1, zone, 0, rand(4,6), brute_heal, burn_heal, "bandag"), user)
				src.in_use = 1
			else if ((brute_heal || burn_heal) && target.health < target.max_health)
				actions.start(new /datum/action/bar/icon/medical_suture_bandage(H, src, 5 SECONDS, 0, 0, 5, brute_heal, burn_heal, "bandag"), user)
				src.in_use = 1
			else
				user.show_text("[H == user ? "You have" : "[H] has"] no wounds or incisions on [H == user ? "your" : his_or_her(H)] [zone_sel2name[zone]] to bandage!", "red")
				src.in_use = 0
				return
		else
			return ..()

	update_icon()
		switch (src.uses)
			if (-INFINITY to 0)
				src.icon_state = "bandage-item-0"
			if (1 to 2)
				src.icon_state = "bandage-item-1"
			if (3 to 4)
				src.icon_state = "bandage-item-2"
			if (5 to INFINITY)
				src.icon_state = "bandage-item-3"

/obj/item/bandage/vr
	icon = 'icons/effects/VR.dmi'

/* =============================================================== */
/* -------------------- Suture/Bandage Action -------------------- */
/* =============================================================== */

/datum/action/bar/icon/medical_suture_bandage
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 15
	icon = 'icons/obj/surgery.dmi'
	icon_state = "suture"
	var/mob/living/carbon/human/target
	var/obj/item/tool
	var/zone
	var/surgery_status
	var/repair_amount
	var/vrb
	var/brute_heal
	var/burn_heal

	New(Target, Tool, Time, Zone, Status, Repair, brute_heal, burn_heal, Vrb)
		src.target = Target
		src.tool = Tool
		src.duration = Time
		src.zone = Zone
		src.surgery_status = Status
		src.repair_amount = Repair
		src.brute_heal = brute_heal
		src.burn_heal = burn_heal

		vrb = Vrb
		if (zone && surgery_status)
			duration = clamp((duration * surgery_status), 5, 50)
		else if (ishuman(target))
			duration = clamp((duration * target.bleeding), 5, 50)
		if (tool)
			icon = tool.icon
			icon_state = tool.icon_state
		..()

	onUpdate()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(var/flag)
		..()
		boutput(owner, SPAN_ALERT("You were interrupted!"))
		if (tool)
			tool:in_use = 0

	onStart()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || !ishuman(target) || owner == null || tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (zone && surgery_status)
			target.visible_message(SPAN_NOTICE("[owner] begins [vrb]ing the surgical incisions on [owner == target ? his_or_her(owner) : "[target]'s"] [zone_sel2name[zone]] closed with [tool]."),\
			SPAN_NOTICE("[owner == target ? "You begin" : "[owner] begins"] [vrb]ing the surgical incisions on your [zone_sel2name[zone]] closed with [tool]."))
		else
			target.visible_message(SPAN_NOTICE("[owner] begins [vrb]ing [owner == target ? his_or_her(owner) : "[target]'s"] wounds closed with [tool]."),\
			SPAN_NOTICE("[owner == target ? "You begin" : "[owner] begins"] [vrb]ing your wounds closed with [tool]."))

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (owner && ownerMob && target && tool && tool == ownerMob.equipped() && BOUNDS_DIST(owner, target) == 0)
			if (zone && surgery_status)
				target.visible_message(SPAN_SUCCESS("[owner] [vrb]es the surgical incisions on [owner == target ? his_or_her(owner) : "[target]'s"] [zone_sel2name[zone]] closed with [tool]."),
				SPAN_SUCCESS("[owner == target ? "You [vrb]e" : "[owner] [vrb]es"] the surgical incisions on your [zone_sel2name[zone]] closed with [tool]."))
				if (target.organHolder)
					if (zone == "chest")
						if (target.organHolder.heart)
							target.organHolder.heart.op_stage = 0
						if (target.organHolder.chest)
							target.organHolder.chest.op_stage = 0
						if (target.organHolder.back_op_stage)
							target.organHolder.back_op_stage = BACK_SURGERY_CLOSED
						target.TakeDamage("chest", 2, 0)
					else if (zone == "head")
						if (target.organHolder.head)
							target.organHolder.head.op_stage = 0
						if (target.organHolder.skull)
							target.organHolder.skull.op_stage = 0
						if (target.organHolder.brain)
							target.organHolder.brain.op_stage = 0
				if (target.bleeding)
					repair_bleeding_damage(target, 100, repair_amount)
			else
				target.visible_message(SPAN_SUCCESS("[owner] [vrb]es [owner == target ? "[his_or_her(owner)]" : "[target]'s"] wounds closed with [tool]."),\
				SPAN_SUCCESS("[owner == target ? "You [vrb]e" : "[owner] [vrb]es"] your wounds closed with [tool]."))
				repair_bleeding_damage(target, 100, repair_amount)
				if (brute_heal || burn_heal)
					target.HealDamage("All", brute_heal, burn_heal)

			if (zone && vrb == "bandag" && !target.bandaged.Find(zone))
				target.bandaged += zone
				target.update_body()
			if (istype(tool, /obj/item/suture))
				var/obj/item/suture/S = tool
				S.in_use = 0
			else if (istype(tool, /obj/item/bandage))
				var/obj/item/bandage/B = tool
				B.in_use = 0
				B.uses --
				B.tooltip_rebuild = 1
				B.UpdateIcon()
				if (B.uses <= 0)
					boutput(ownerMob, SPAN_ALERT("You use up the last of the bandages."))
					ownerMob.u_equip(tool)
					qdel(tool)

			else if (istype(tool, /obj/item/material_piece/cloth))
				var/obj/item/material_piece/cloth/C = tool
				C.in_use = FALSE
				C.change_stack_amount(-1)

/* ================================================== */
/* -------------------- Body Bag -------------------- */
/* ================================================== */

/obj/item/body_bag
	name = "body bag"
	desc = "A heavy bag, used for carrying stuff around. The stuff is usually dead bodies. Hence the name."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bodybag"
	flags = TABLEPASS
	object_flags = NO_GHOSTCRITTER | NO_ARM_ATTACH
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 1
	throw_speed = 4
	throw_range = 20
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	var/open = 0
	var/image/open_image = null
	var/sound_zipper = 'sound/items/zipper.ogg'

	New()
		..()
		src.open_image = image(src.icon, src, "bodybag-open1", EFFECTS_LAYER_BASE)

	disposing()
		for(var/atom/movable/AM in src)
			AM.set_loc(get_turf(src))
		..()

	update_icon()
		if (src.open && src.open_image)
			src.overlays += src.open_image
			src.icon_state = "bodybag-open"
			src.w_class = W_CLASS_BULKY
		else if (!src.open)
			src.overlays -= src.open_image
			if (src.contents && length(src.contents))
				src.icon_state = "bodybag-closed1"
			else
				src.icon_state = "bodybag-closed0"
			src.w_class = W_CLASS_BULKY
		else
			src.overlays -= src.open_image
			src.icon_state = "bodybag"
			src.w_class = W_CLASS_TINY

	attack_self(mob/user as mob)
		if (src.icon_state == "bodybag" && src.w_class == W_CLASS_TINY)
			user.visible_message("<b>[user]</b> unfolds [src].",\
			"You unfold [src].")
			user.drop_item()
			pixel_x = 0
			pixel_y = 0
			src.UpdateIcon()
		else
			return

	attack_hand(mob/user)
		add_fingerprint(user)
		if (src.icon_state == "bodybag" && src.w_class == W_CLASS_TINY)
			return ..()
		else if(!ON_COOLDOWN(user, "bodybag_zip", 1 SECOND))
			if (src.open)
				src.close()
			else
				src.open()
			return

	relaymove(mob/user as mob)
		if (user.stat)
			return
		if (prob(75))
			user.show_text("You fuss with [src], trying to find the zipper, but it's no use!", "red")
			for (var/mob/M in hearers(src, null))
				M.show_text("<FONT size=[max(0, 5 - GET_DIST(src, M))]>...rustle...</FONT>")
			return
		src.open()
		src.visible_message(SPAN_ALERT("<b>[user]</b> unzips themselves from [src]!"))

	mouse_drop(atom/over_object)
		if (!over_object) return
		if(isturf(over_object))
			..() //Lets it do the turf-to-turf slide
			return
		else if (istype(over_object, /atom/movable/screen/hud))
			over_object = usr //Try to fold & pick up the bag with your mob instead
		else if (!(over_object == usr))
			return
		..()
		if (!length(src.contents) && usr.can_use_hands() && isalive(usr) && BOUNDS_DIST(src, usr) == 0 && !issilicon(usr))
			if (src.icon_state != "bodybag")
				usr.visible_message("<b>[usr]</b> folds up [src].",\
				"You fold up [src].")
			src.overlays -= src.open_image
			src.icon_state = "bodybag"
			src.w_class = W_CLASS_TINY
			src.Attackhand(usr)

	attackby(obj/item/W, mob/user, params)
		if(length(src.contents) && istool(W, TOOL_CUTTING | TOOL_SNIPPING)) //don't cut open empty bags, what's the point?
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, PROC_REF(cut_open), null, W.icon, W.icon_state, "[user] cuts open [src]!", null)
		else
			. = ..()

	proc/cut_open()
		for (var/obj/O in src)
			O.set_loc(get_turf(src))
		for (var/mob/M in src)
			M.changeStatus("knockdown", 0.5 SECONDS)
			M.set_loc(get_turf(src))
		var/obj/decal/cleanable/balloon/B = make_cleanable(/obj/decal/cleanable/balloon, get_turf(src))
		B.icon_state = "balloon_black_pop"
		B.name = "body bag"
		B.desc = "The remains of a body bag"
		qdel(src)

	proc/open()
		playsound(src, src.sound_zipper, 100, 1, , 6)
		for (var/obj/O in src)
			O.set_loc(get_turf(src))
		for (var/mob/M in src)
			M.changeStatus("knockdown", 0.5 SECONDS)
			SPAWN(0.3 SECONDS)
				M.set_loc(get_turf(src))
		src.open = 1
		src.UpdateIcon()

	proc/close()
		playsound(src, src.sound_zipper, 100, 1, , 6)
		for (var/obj/O in get_turf(src))
			if (O.density || O.anchored || O == src)
				continue
			O.set_loc(src)
		for (var/mob/M in get_turf(src))
			if (!(M.lying || (ismobcritter(M) && isdead(M))) || M.anchored || M.buckled)
				continue
			M.set_loc(src)
		src.open = 0
		src.UpdateIcon()

/* ================================================== */
/* -------------------- Hemostat -------------------- */
/* ================================================== */

/obj/item/hemostat
	name = "hemostat"
	desc = "A surgical tool used for the control and reduction of bleeding during surgery."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "hemostat"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	force = 1.5
	w_class = W_CLASS_TINY
	throwforce = 3
	throw_speed = 3
	throw_range = 6
	m_amt = 7000
	g_amt = 3500
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 15
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!ishuman(target))
			if (user.a_intent == INTENT_HELP)
				return
			return ..()
		var/mob/living/carbon/human/H = target
		var/surgery_status = H.get_surgery_status(user.zone_sel.selecting)
		if (!surgery_status)
			if (user.a_intent == INTENT_HELP)
				return
			return ..()
		if (!surgeryCheck(H, user))
			if (user.a_intent == INTENT_HELP)
				return
			return ..()
		if (H.chest_cavity_clamped && !H.bleeding)
			boutput(user, SPAN_NOTICE("[target]'s blood vessels are already clamped."))
			return
		if (H.organHolder.chest.op_stage > 0 || H.bleeding)
			user.tri_message(H, SPAN_ALERT("<b>[user]</b> begins clamping the bleeders in [H == user ? "[his_or_her(H)]" : "[H]'s"] incision with [src]."),\
				SPAN_ALERT("You begin clamping the bleeders in [user == H ? "your" : "[H]'s"] incision with [src]."),\
				SPAN_ALERT("[H == user ? "You begin" : "<b>[user]</b> begins"] clamping the bleeders in your incision with [src]."))

			actions.start(new/datum/action/bar/icon/clamp_bleeders(user, H), user)
			return

/* ======================================================= */
/* -------------------- Reflex Hammer -------------------- */
/* ======================================================= */
/*
/obj/item/tinyhammer/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	// todo: give people's limbs the ol' tappa tappa
	// also make sure intent, force and armor matter
	if (!def_zone)
		def_zone = (user?.zone_sel?.selecting) ? user.zone_sel.selecting : "chest" // may as well default to head idk

	var/my_damage = src.force
	var/my_sound = 'sound/impact_sounds/Generic_Stab_1.ogg'
	var/clumsy = 0 // time to be rude :T
	var/doctor = 0

	if (user.bioHolder)
		if (user.bioHolder.HasEffect("clumsy"))
			clumsy = 1
		if (user.get_brain_damage() >= 60) // little bit of a gibbering mess
			clumsy = 1
		if (user.traitHolder.hasTrait("training_medical") && user.a_intent != INTENT_HARM)
			doctor = 1

	if (ishuman(target)) // tappa tappa
		var/mob/living/carbon/human/H = target
		switch (def_zone)
			if ("head")
				if (!H.get_organ("head")) // ain't got NO HEAD TO TAP, WHAT YOU TRYIN TO PULL HERE SON
					H.visible_message("[user][doctor ? " gently" : null] swings [src] at [H == user ? "[his_or_her(H)] own" : "[H]'s"] head, <span style='color:red;font-weight:bold'>but [H == user ? he_or_she(H) : H] has no head to tap!</span>[H == user ? " How did [he_or_she(H)] even pull that off?!" : null]")
					my_damage = 0
					my_sound = 'sound/impact_sounds/Generic_Swing_1.ogg'

				else if (clumsy && !doctor && prob(1)) // extreme clumsiness can lead to extremely unintended examination results
					var/obj/item/organ/head/head = H.drop_organ("head")
					H.visible_message("<span style='color:red;font-weight:bold'>[user] swings [src] way too hard at [H == user ? "[his_or_her(H)] own" : "[H]'s"] head and hits it clean off [H == user ? "[his_or_her(H)] own" : "[H]'s"] shoulders!</span>")
					playsound(H, 'sound/impact_sounds/Flesh_Stab_1.ogg', 80, TRUE)
					if (head)
						head.throw_at(get_dir(user, H), 3, 3)
					return

				else if (clumsy && prob(33)) // WHACK
					H.visible_message("<span style='color:red;font-weight:bold'>[user] swings [src] way too hard at [H == user ? "[his_or_her(H)] own" : "[H]'s"] head!</span>")
					playsound(H, 'sound/impact_sounds/Generic_Hit_1.ogg', 80, TRUE)
					my_damage = (max(my_damage, 2) * 3)

				else if (!headSurgeryCheck(H))
					H.visible_message("[user][doctor ? " gently" : null] taps [H == user ? "[him_or_her(H)]self" : H] on the head with [src].<br>&emsp;You can't tell how [H]'s head sounds because of [H]'s headgear!")
					my_damage = 0

				else if (!H.get_organ("brain")) // no brain, hollow head
					H.visible_message("[user][doctor ? " gently" : null] taps [H == user ? "[him_or_her(H)]self" : H] on the head with [src].<br>&emsp;[H]'s head sounds hollow.")

				else // all is normal
					H.visible_message("[user][doctor ? " gently" : null] taps [H == user ? "[him_or_her(H)]self" : H] on the head with [src].<br>&emsp;[H]'s head sounds normal.")
/*
			if ("l_arm","r_arm")
				var/obj/item/parts/my_arm
				if (H.limbs)

				if (!H.limbs || !H.
*/
		H.TakeDamage(def_zone, my_damage)
		playsound(H, my_sound, 80, TRUE)
		return

	//else if (isrobot(M)) // clonk clonk
		//var/mob/living/silicon/robot/R = M
*/
/obj/item/tinyhammer/reflex
	name = "reflex hammer"
	desc = "A tiny hammer used for testing deep tendon reflexes."
	force = 0
	throwforce = 1
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 1
	default_material = "synthrubber"

/* ================================================== */
/* -------------------- Penlight -------------------- */
/* ================================================== */

TYPEINFO(/obj/item/device/light/flashlight/penlight)
	mats = 1

/obj/item/device/light/flashlight/penlight
	name = "penlight"
	desc = "A small light used for testing photopupillary reflexes."
	icon_state = "penlight0"
	item_state = "pen"
	icon_on = "penlight1"
	icon_off = "penlight0"
	icon_broken = "penlightbroken"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 7
	throw_range = 15
	m_amt = 50
	g_amt = 10
	col_r = 0.9
	col_g = 0.8
	col_b = 0.7
	brightness = 2
	var/anim_duration = 10 // testing var so I can adjust in-game to see what looks nice

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		// todo: check zone, make sure people are shining the light 1) at a human 2) in the eyes, clauses for whatever else
		if (!def_zone && user?.zone_sel?.selecting)
			def_zone = user.zone_sel.selecting
		else if (!def_zone)
			return ..()

		if (user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(33))
			target = user // hold the pen the right way, dingus!
			JOB_XP(user, "Clown", 1)

		if (!src.on || def_zone != "head")
			user.tri_message(target, "[user] wiggles [src] at [target == user ? "[his_or_her(user)] own" : "[target]'s"] [zone_sel2name[def_zone]].[!src.on ? " \The [src] isn't on, so it doesn't do much." : null]",\
				"You wiggle [src] at [target == user ? "your own" : "[target]'s"] [zone_sel2name[def_zone]].[!src.on ? " \The [src] isn't on, so it doesn't do much." : null]",\
				"[target == user ? "You wiggle" : "<b>[user]</b> wiggles"] [src] at your[target == user ? " own" : null] [zone_sel2name[def_zone]].[!src.on ? " \The [src] isn't on, so it doesn't do much." : null]")
			return

		var/results_msg = "&emsp;Nothing happens." // shown to everyone but the target (you can't see your own eyes!! also we have no mirrors)

		if (ishuman(target))
			var/mob/living/carbon/human/H = target

			if (istype(H.glasses) && !istype(H.glasses, /obj/item/clothing/glasses/regular) && H.glasses.c_flags & COVERSEYES) // check all the normal things that could cover eyes
				results_msg = "&emsp;[SPAN_ALERT("It's hard to accurately judge how [H]'s eyes reacted through [his_or_her(H)] [H.glasses.name]!")]"
			else if (istype(H.wear_mask) && H.wear_mask.c_flags & COVERSEYES)
				results_msg = "&emsp;[SPAN_ALERT("It's hard to accurately judge how [H]'s eyes reacted through [his_or_her(H)] [H.wear_mask.name]!")]"
			else if (istype(H.head) && H.head.c_flags & COVERSEYES)
				results_msg = "&emsp;[SPAN_ALERT("It's hard to accurately judge how [H]'s eyes reacted through [his_or_her(H)] [H.head.name]!")]"
			else if (istype(H.wear_suit) && H.wear_suit.c_flags & COVERSEYES)
				results_msg = "&emsp;[SPAN_ALERT("It's hard to accurately judge how [H]'s eyes reacted through [his_or_her(H)] [H.wear_suit.name]!")]"

			else // okay move on to actual diagnostic stuff
				var/obj/item/organ/eye/leye = H.get_organ("left_eye")
				var/obj/item/organ/eye/reye = H.get_organ("right_eye")
				var/His_Her = capitalize(his_or_her(H))
				var/He_She = capitalize(he_or_she(H))

				if (!leye && !reye) // oops, we uhh can't test reflexes if there's no eyes
					results_msg = "&emsp;[SPAN_ALERT("Nothing happens because [he_or_she(H)] <b>has no eyes!</b>")]"
				else
					var/lmove = null // left movement
					//var/lpupil = null // left pupil dialation/constriction
					var/lpstatus = null // left pupil dialation/constriction
					var/lpreact = null // left pupil light reaction
					var/rmove = null // right movement
					//var/rpupil = null // right pupil dialation/constriction
					var/rpstatus = null // right pupil dialation/constriction
					var/rpreact = null // right pupil light reaction

					if (H.reagents)
						var/list/con_reagents = list("morphine", "space_drugs") // drugs that cause pupil constriction
						var/list/dia_reagents = list("atropine", "antihistamine", "methamphetamine", "crank", "bathsalts", "catdrugs") // drugs that cause pupil dialation (todo: finish cocaine and add it here)
						var/list/both_reagents = con_reagents + dia_reagents

						var/datum/reagent/BIGR = null // the for() below will look for the BIGGEST CHEM from the lists, and we'll use that to determine the messages given
						for (var/current_id in H.reagents.reagent_list)
							if (!H || !H.reagents || !H.reagents.reagent_list)
								break
							if (!both_reagents.Find(current_id)) // not something we care about
								continue
							var/datum/reagent/R = H.reagents.reagent_list[current_id]
							if (!istype(R))
								continue
							if (!BIGR || BIGR.volume < R.volume)
								BIGR = R
						if (BIGR)
							var/con_or_dia = con_reagents.Find(BIGR.id) ? "constricted" : "dialated"
							if (BIGR.overdose <= BIGR.volume) // we're oding, messages should be more severe
								con_or_dia = "very " + con_or_dia
							if (leye)
								lpstatus = " The pupil is [con_or_dia] and "
								lpreact = "doesn't react to the light much."
							if (reye)
								rpstatus = " The pupil is [con_or_dia] and "
								rpreact = "doesn't react to the light much."

					// unilateral mydriasis (blown pupil) can be a sign of abnormally high intracranial pressure, aka brain has an ouchie :(
					// will show up for active bloot clots (stroke) as an injury to the right side of the brain, and left for brain damage (since injuries to the left side can cause slurring, or in our case, gibbering)
					// irl these things can affect either side of the brain but this will help differentiate them in a video game context I think
					// (also: injuries to the brain show up as issues on the opposite side of the body, so a left injury affects the right eye, etc)
					var/datum/ailment_data/malady/AD = H.find_ailment_by_type(/datum/ailment/malady/bloodclot)
					if (AD?.state == "Active" && AD.affected_area == "head") // having a stroke!!
						if (leye)
							lmove = "[His_Her] left eye doesn't follow the light at all!"
							lpreact = "doesn't react to the light at all!"

					var/the_brain = H.get_organ("brain") // don't need to know anything about it other than "is it there?"
					var/braind = H.get_brain_damage()
					if (!the_brain || isnum(braind))
						if (!the_brain || braind >= 100) // braindead as heck
							if (leye) lmove = "[His_Her] left eye doesn't follow the light at all!"
							if (reye) rmove = "[His_Her] right eye doesn't follow the light at all!"
							if (!the_brain)
								if (leye) lpreact = "doesn't react to the light at all!"
								if (reye) rpreact = "doesn't react to the light at all!"
						else if (braind >= 60) // when one becomes a gibbering mess
							if (reye)
								rmove = "[His_Her] right eye doesn't follow the light at all!"
								rpstatus = " The pupil is very dialated and "
								rpreact = "doesn't react to the light at all!"
						else if (braind >= 35) // mid point where things are gettin serious
							if (reye)
								rmove = "[His_Her] right eye doesn't follow the light well."
								rpstatus = " The pupil is dialated and "
								rpreact = "doesn't react to the light much."
						else if (braind >= 10) // mild damage like a concussion
							if (reye) rpstatus = " The pupil is slightly dialated and "

					if (!leye)
						lmove = SPAN_ALERT("[He_She] has no left eye!")
						lpstatus = null
						lpreact = null
					else
						if (!lmove) lmove = "[His_Her] left eye follows the light easily."
						if (!lpstatus) lpstatus = " The pupil "
						if (!lpreact) lpreact = "constricts normally."

					if (!reye)
						rmove = SPAN_ALERT("[He_She] has no right eye!")
						rpstatus = null
						rpreact = null
					else
						if (!rmove) rmove = "[His_Her] right eye follows the light easily."
						if (!rpstatus) rpstatus = " The pupil "
						if (!rpreact) rpreact = "constricts normally."

					results_msg = "&emsp;[lmove][lpstatus][lpreact]<br>&emsp;[rmove][rpstatus][rpreact]"


		user.tri_message(target, "[user] shines [src] in [target == user ? "[his_or_her(user)] own" : "[target]'s"] eyes.[results_msg ? "<br>[results_msg]" : null]",\
			"You shine [src] in [target == user ? "your own" : "[target]'s"] eyes.[(target != user && results_msg) ? "<br>[results_msg]" : null]",\
			"[target == user ? "You shine" : "<b>[user]</b> shines"] [src] in your[target == user ? " own" : null] eyes.")

/* ====================================================== */
/* -------------------- Surgery Tray -------------------- */
/* ====================================================== */

/obj/surgery_tray
	name = "tray"
	desc = "A lightweight tray with little wheels on it. You can place stuff on this and then move the stuff elsewhere! Isn't that totally amazing??"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tray"
	density = 1
	anchored = UNANCHORED
	layer = STORAGE_LAYER
	var/max_to_move = 10
	p_class = 1.5

	New()
		..()
		if (!islist(src.attached_objs))
			src.attached_objs = list()
		if (world.game_state <= GAME_STATE_PREGAME) // pre-roundstart, this is a thing made on the map so we want to grab whatever's been placed on top of us automatically
			SPAWN(0)
				var/stuff_added = 0
				for (var/obj/item/I in src.loc?.contents)
					if (I.anchored || I.layer < src.layer)
						continue
					else
						attach(I)
						stuff_added++
						if (stuff_added >= src.max_to_move)
							break

	Move(NewLoc,Dir)
		. = ..()
		if (.)
			if (prob(75))
				playsound(src, "sound/misc/chair/office/scoot[rand(1,5)].ogg", 40, 1)

			//if we're over the max amount a table can fit, have a chance to drop an item. Chance increases with items on tray
			if (prob((src.contents.len-max_to_move)*1.1))
				var/obj/item/falling = pick(src.attached_objs)
				detach(falling)
				// src.visible_message("[falling] falls off of [src]!")
				var/target = get_offset_target_turf(get_turf(src), rand(5)-rand(5), rand(5)-rand(5))
				falling.set_loc(get_turf(src))

				falling?.throw_at(target, 1, 1)


	attackby(obj/item/W, mob/user, params)
		if (iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (istype(W, /obj/item/mechanics))
			user.show_text("[W] slips off [src].")
			return ..()
		else if (src.place_on(W, user, params))
			user.show_text("You place [W] on [src].")
			src.attach(W)
			return
		else
			return ..()

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (isitem(AM))
			src.visible_message("[AM] lands on [src]!")
			AM.set_loc(get_turf(src))
			attach(AM)

	disposing()
		for (var/obj/item/I in src.attached_objs)
			detach(I)
		..()

	proc/deconstruct()
		var/obj/item/furniture_parts/surgery_tray/P = new /obj/item/furniture_parts/surgery_tray(src.loc)
		if (P && src.material)
			P.setMaterial(src.material)
		qdel(src)
		return

	proc/attach(obj/item/I as obj)
		if(I.anchored) return
		else if (istype(I, /obj/item/mechanics) || istype(I, /obj/item/storage/mechanics))
			return
		src.attached_objs.Add(I) // attach the item to the table
		I.glide_size = 0 // required for smooth movement with the tray
		// register for pickup, register for being pulled off the table, register for item deletion while attached to table
		SPAWN(0)
			RegisterSignals(I, list(COMSIG_ITEM_PICKUP, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_PRE_DISPOSING, COMSIG_ATOM_MOUSEDROP), PROC_REF(detach))

	proc/detach(obj/item/I as obj) //remove from the attached items list and deregister signals
		src.attached_objs.Remove(I)
		UnregisterSignal(I, list(COMSIG_ITEM_PICKUP, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_PRE_DISPOSING, COMSIG_ATOM_MOUSEDROP))

	proc/toggle_brake(mob/user)
		src.anchored = !src.anchored
		boutput(user, "You [src.anchored ? "apply" : "release"] \the [src.name]'s brake.")

	attack_hand(mob/user)
		..()
		toggle_brake(user)

	attack_ai(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || isAI(user))
			return
		toggle_brake(user)

/* ---------- Surgery Tray Parts ---------- */
/obj/item/furniture_parts/surgery_tray
	name = "tray parts"
	desc = "A collection of parts that can be used to make a tray."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tray_parts"
	force = 3
	stamina_damage = 7
	stamina_cost = 7
	furniture_type = /obj/surgery_tray
	furniture_name = "tray"
	build_duration = 30

/* ================================================== */
/* -------------- Surgical Scissors ----------------- */
/* ================================================== */

/obj/item/scissors/surgical_scissors
	name = "surgical scissors"
	desc = "Used for precisely cutting up people in surgery. I guess you could use them on paper too."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical-scissors"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "surgical_scissors"

	flags = TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SNIPPING
	force = 8
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 35
	w_class = W_CLASS_TINY
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'

	throwforce = 5
	throw_speed = 3
	throw_range = 5
	move_triggered = 1

	New()
		..()
		src.create_reagents(5)

	disposing()
		..()

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	bloody
		New()
			. = ..()
			SPAWN(1 DECI SECOND) //sync with the organs spawn
				make_cleanable(/obj/decal/cleanable/blood/gibs, src.loc)
