
/* ================================================== */
/* -------------------- Syringes -------------------- */
/* ================================================== */
#define S_DRAW 0
#define S_INJECT 1
/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A hollow device with a metal tip. Used to draw or deposit reagents into containers, and with co-operation, people."
	icon = 'icons/obj/syringe.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "syringe_0"
	var/icon_prefix = "syringe"
	icon_state = "syringe_0"
	initial_volume = 15
	amount_per_transfer_from_this = 5
	/// The amount each visual stage of the icon increments by. Defaults to amount_per_transfer_from_this
	var/amount_per_stage = -1
	var/mode = S_DRAW
	var/image/fluid_image
	var/image/image_inj_dr
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	New()
		..()
		if (amount_per_stage < 0)
			amount_per_stage = amount_per_transfer_from_this

	on_reagent_change()
		..()
		if (src.reagents.is_full() && src.mode == S_DRAW)
			src.mode = S_INJECT
		else if (!src.reagents.total_volume && src.mode == S_INJECT)
			src.mode = S_DRAW
		src.UpdateIcon()

	update_icon()
		var/scaled_vol = ((reagents ? reagents.total_volume : 0) / initial_volume) * initial_volume
		// drsingh for cannot read null.total_volume
		var/rounded_vol = round(scaled_vol, amount_per_stage)
		icon_state = "[icon_prefix]_[rounded_vol]"
		item_state = "syringe_[rounded_vol]"
		src.underlays = null
		if (ismob(loc))
			if (!src.image_inj_dr)
				src.image_inj_dr = image(src.icon)
			src.image_inj_dr.icon_state = src.mode ? "inject" : "draw"
			src.UpdateOverlays(src.image_inj_dr, "inj_dr")
		else
			src.UpdateOverlays(null, "inj_dr")
		if (!src.fluid_image)
			src.fluid_image = image('icons/obj/syringe.dmi')
		src.fluid_image.icon_state = "[icon_prefix]_f"
		if(reagents) // fix for Cannot execute null.get average color().
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
		src.underlays += src.fluid_image
		signal_event("icon_updated")

	pickup(mob/user)
		..()
		UpdateIcon()

	dropped(mob/user)
		..()
		SPAWN(0)
			UpdateIcon()

	attack_self(mob/user as mob)
		src.mode = !(src.mode)
		user.show_text("You switch [src] to [src.mode ? "inject" : "draw"].")
		UpdateIcon()

	attack_hand(mob/user)
		..()
		UpdateIcon()

	attackby(obj/item/I, mob/user)
		return

	afterattack(var/atom/target, mob/user, flag)
		if(isghostcritter(user)) return
		if (!target.reagents) return
		if(istype(target, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/t = target
			if(t.current_lid)
				boutput(user, SPAN_ALERT("You cannot transfer liquids with the [target.name] while it has a lid on it!"))
				return

		switch(mode)
			if (S_DRAW)
				if (isliving(target))//Blood!
					var/mob/living/L = target
					if (!L.blood_id)
						return

					if (reagents.total_volume >= reagents.maximum_volume)
						boutput(user, SPAN_ALERT("The [src.name] is full."))
						return

					if (target != user)
						logTheThing(LOG_COMBAT, user, "tries to draw 5 units of reagents from [constructTarget(target, "combat")] [log_reagents(target)] with a [src] [log_reagents(src)] at [log_loc(user)].")
						user.visible_message(SPAN_ALERT("<B>[user] is trying to draw blood from [target]!</B>"))
						actions.start(new/datum/action/bar/icon/syringe(target, src, src.icon, src.icon_state), user)
					else
						syringe_action(user, target)
					return

				if (!target.reagents.total_volume)
					boutput(user, SPAN_ALERT("[target] is empty."))
					return

				if (reagents.total_volume >= reagents.maximum_volume)
					boutput(user, SPAN_ALERT("The [src.name] is full."))
					return

				if (!target.is_open_container() && (!istype(target,/obj/reagent_dispensers) && !istype(target,/obj/item/clothing/mask/cigarette/custom)))
					boutput(user, SPAN_ALERT("You cannot directly remove reagents from this object."))
					return

				target.reagents.trans_to(src, src.amount_per_transfer_from_this)
				logTheThing(LOG_CHEMISTRY, user, "draws 5 units of reagents from [constructTarget(target,"combat")] [log_reagents(target)] with a syringe [log_reagents(src)] at [log_loc(user)].")
				user.update_inhands()

				boutput(user, SPAN_NOTICE("You fill [src] with [src.amount_per_transfer_from_this] units of the solution."))

			if (S_INJECT)
				// drsingh for Cannot read null.total_volume
				if (!reagents || !reagents.total_volume)
					boutput(user, SPAN_ALERT("The [src.name] is empty."))
					return

				if (istype(target, /obj/item/bloodslide))
					var/obj/item/bloodslide/BL = target
					if (BL.reagents.total_volume)
						boutput(user, SPAN_ALERT("There is already a sample on [target]."))
						return
					var/transferred = src.reagents.trans_to(target, src.amount_per_transfer_from_this)
					user.update_inhands()
					boutput(user, SPAN_NOTICE("You fill the blood slide with [transferred] units of the solution."))
					BL.on_reagent_change()
					return

				if (target.reagents.total_volume >= target.reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[target] is full."))
					return

				if (target.is_open_container(TRUE) != 1 && !ismob(target) && !istype(target,/obj/item/reagent_containers/food) && !istype(target,/obj/item/clothing/mask/cigarette/custom) && !istype(target,/obj/item/reagent_containers/patch))
					boutput(user, SPAN_ALERT("You cannot directly fill this object."))
					return

				if (iscarbon(target) || ismobcritter(target))
					if (!src.reagents || !src.reagents.total_volume)
						user.show_text("[src] doesn't contain any reagents.", "red")
						return

					if (target != user)
						logTheThing(LOG_COMBAT, user, "tries to inject [constructTarget(target,"combat")] with a [src] [log_reagents(src)] at [log_loc(user)].")
						user.visible_message(SPAN_ALERT("<B>[user] is trying to inject [target] with [src]!</B>"))
						actions.start(new/datum/action/bar/icon/syringe(target, src, src.icon, src.icon_state), user)
					else
						syringe_action(user, target)
					return

				if (istype(target,/obj/item/reagent_containers/patch))
					var/obj/item/reagent_containers/patch/P = target
					boutput(user, SPAN_NOTICE("You fill [P]."))
					if (P.medical == 1)
						//break the seal
						boutput(user, SPAN_ALERT("You break [P]'s tamper-proof seal!"))
						P.medical = 0


				if (src?.reagents && target?.reagents)
					logTheThing((!ismob(target) || target == user) ? LOG_CHEMISTRY : LOG_COMBAT, user, "injects [constructTarget(target,"combat")] with a [src.name] [log_reagents(src)] at [log_loc(user)].")
					// Convair880: Seems more efficient than separate calls. I believe this shouldn't clutter up the logs, as the number of targets you can inject is limited.
					// Also wraps up injecting food (advertised in the 'Tip of the Day' list) and transferring chems to other containers (i.e. brought in line with beakers and droppers).
					src.reagents.trans_to(target, src.amount_per_transfer_from_this)
					user.update_inhands()

					if (istype(target,/obj/item/reagent_containers/patch))
						//patch auto-naming thing
						var/patch_name = ""
						for (var/reagent_id in target.reagents.reagent_list)
							patch_name += "[reagent_id]-"
						patch_name += "patch"
						target.name = patch_name

	proc/syringe_action(mob/user, mob/target)
		switch(src.mode)
			if(S_DRAW)
				// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
				// Also ignore that second container of blood entirely if it's a vampire (Convair880).
				var/mob/living/carbon/human/H = target
				if (istype(H))
					if ((isvampire(H) && (H.get_vampire_blood() <= 0)) || (!isvampire(H) && (H.blood_volume + H.reagents.total_volume == 0)))
						user.show_text("[H]'s veins appear to be completely dry!", "red")
						return

				transfer_blood(target, src, src.amount_per_transfer_from_this)
				user.visible_message(SPAN_ALERT("[user.name] draws blood from [target == user ? himself_or_herself(user) : target.name] with [src]!"),\
				SPAN_NOTICE("You fill [src] with [src.amount_per_transfer_from_this] units of [target == user ? "your own" : target.name + "'s"] blood."))
				logTheThing(LOG_COMBAT, user, "draws 5 units of reagents from [constructTarget(target,"combat")] [log_reagents(target)] with a syringe [log_reagents(src)] at [log_loc(user)].")

			if(S_INJECT)
				// Why would you do this
				var/mob/living/critter/small_animal/turtle/turtle = target
				if(istype(turtle) && !turtle?.rigged && src.reagents.has_reagent("plasma", 1))
					turtle.rig_to_explode(user)
				src.reagents.reaction(target, INGEST, src.amount_per_transfer_from_this)
				src.reagents.trans_to(target, src.amount_per_transfer_from_this)
				user.visible_message(SPAN_ALERT("[user.name] injects [target == user ? himself_or_herself(user) : target.name] with [src]!"),\
				SPAN_NOTICE("You inject [target == user ? "yourself" : target.name] with [src]!"))
				logTheThing(LOG_COMBAT, user, "injects [constructTarget(target,"combat")] with a [src.name] [log_reagents(src)] at [log_loc(user)].")

		user.update_inhands()

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/syringe/robot
	name = "syringe (mixed)"
	desc = "Contains epinephrine & anti-toxins."
	initial_reagents = list("epinephrine"=7, "charcoal"=8)
	mode = S_INJECT

/obj/item/reagent_containers/syringe/epinephrine
	name = "syringe (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	initial_reagents = "epinephrine"

/obj/item/reagent_containers/syringe/insulin
	name = "syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	initial_reagents = "insulin"

/obj/item/reagent_containers/syringe/haloperidol
	name = "syringe (haloperidol)"
	desc = "Contains haloperidol - used for sedation and to counter violent psychosis."
	initial_reagents = "haloperidol"

/obj/item/reagent_containers/syringe/antitoxin
	name = "syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	initial_reagents = "charcoal"

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antibacterial agents."
	initial_reagents = "spaceacillin"

/obj/item/reagent_containers/syringe/atropine
	name = "syringe (atropine)"
	desc = "Contains atropine, a rapid antidote for nerve gas exposure."
	initial_reagents = "atropine"

/obj/item/reagent_containers/syringe/heparin
	name = "syringe (heparin)"
	desc = "Contains heparin, a blood anticoagulant."
	initial_reagents = "heparin"

/obj/item/reagent_containers/syringe/proconvertin
	name = "syringe (proconvertin)"
	desc = "Contains proconvertin, a blood coagulant."
	initial_reagents = "proconvertin"

/obj/item/reagent_containers/syringe/filgrastim
	name = "syringe (filgrastim)"
	desc = "Contains filgrastim, a hematopoiesis stimulant."
	initial_reagents = "filgrastim"

// drugs

/obj/item/reagent_containers/syringe/krokodil
	name = "syringe (krokodil)"
	desc = "Contains krokodil, a sketchy homemade opiate often used by disgruntled Cosmonauts.."
	initial_reagents = "krokodil"

/obj/item/reagent_containers/syringe/morphine
	name = "syringe (morphine)"
	desc = "Contains morphine, a strong but highly addictive opiate painkiller with sedative side effects."
	initial_reagents = "morphine"

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel, which be used to purge impurities, but is highly toxic itself."
	initial_reagents = "calomel"

/obj/item/reagent_containers/syringe/synaptizine
	name = "syringe (synaptizine)"
	desc = "Contains synaptizine, a mild stimulant to increase alertness."
	initial_reagents = "synaptizine"

/obj/item/reagent_containers/syringe/formaldehyde
	name = "syringe (embalming fluid)"
	desc = "Contains formaldehyde, a chemical that prevents corpses from decaying."
	initial_reagents = "formaldehyde"

/obj/item/reagent_containers/syringe/baster
	name = "baster"
	desc = "For adding delicious liquids to food."
	icon_prefix = "baster"
	icon_state = "baster_0"
	initial_volume = 100
	amount_per_transfer_from_this = 25
	flags = TABLEPASS | SUPPRESSATTACK | ACCEPTS_MOUSEDROP_REAGENTS

	afterattack(var/atom/target, mob/user, flag)
		switch (mode)
			if (S_DRAW)
				if (!istype(target, /obj/item/reagent_containers))
					boutput(user, SPAN_ALERT("You can't fit [src]'s nozzle in that."))
					return
			if (S_INJECT)
				if (!istype(target, /obj/item/reagent_containers/food) && !istype(target, /obj/item/reagent_containers/glass))
					boutput(user, SPAN_ALERT("You can't fit [src]'s nozzle in that."))
					return
		..()

#undef S_DRAW
#undef S_INJECT
