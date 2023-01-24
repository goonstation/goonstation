#define IV_INJECT 1
#define IV_DRAW 0

/* ================================================= */
/* -------------------- IV Drip -------------------- */
/* ================================================= */

/obj/item/reagent_containers/iv_drip
	name = "\improper IV drip"
	desc = "A bag with a fine needle attached at the end, for injecting patients with fluids."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IV"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "IV"
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK | OPENCONTAINER
	rc_flags = RC_VISIBLE | RC_FULLNESS | RC_SPECTRO
	amount_per_transfer_from_this = 5
	initial_volume = 250//100
	var/image/fluid_image = null
	var/image/image_inj_dr = null
	var/mob/living/carbon/human/patient = null
	var/obj/iv_stand/stand = null
	var/mode = IV_DRAW
	var/in_use = 0
	var/slashed = 0

	on_reagent_change()
		..()
		src.UpdateIcon()
		if (src.stand)
			src.stand.UpdateIcon()

	update_icon()
		if (src.reagents && src.reagents.total_volume)
			var/iv_state = clamp(round((src.reagents.total_volume / src.reagents.maximum_volume) * 100, 10) / 10, 0, 100) //Look away, you fool! Like the sun, this section of code is harmful for your eyes if you look directly at it
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "IV-0")
			src.fluid_image.icon_state = "IV-[iv_state]"
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
			src.name = src.reagents.get_master_reagent_name() == "blood" ? "blood pack" : "[src.reagents.get_master_reagent_name()] drip"
		else
			src.UpdateOverlays(null, "fluid")
			if (src.fluid_image) //ZeWaka: Fix for null.icon_state
				src.fluid_image.icon_state = "IV-0"
			src.name = "\improper IV drip"
		if (ismob(src.loc))
			if (!src.image_inj_dr)
				src.image_inj_dr = image(src.icon)
			src.image_inj_dr.icon_state = src.mode ? "inject" : "draw"
			src.UpdateOverlays(src.image_inj_dr, "inj_dr")
		else
			src.UpdateOverlays(null, "inj_dr")
		signal_event("icon_updated")

	is_open_container()
		return 1

	pickup(mob/user)
		..()
		src.UpdateIcon()

	dropped(mob/user)
		..()
		SPAWN(0)
			src.UpdateIcon()

	attack_self(mob/user as mob)
		src.mode = !(src.mode)
		user.show_text("You switch [src] to [src.mode ? "inject" : "draw"].")
		src.UpdateIcon()

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if (!ishuman(M))
			return ..()
		var/mob/living/carbon/human/H = M

		if (in_use && src.patient)
			if (src.patient != H)
				user.show_text("[src] is already being used by someone else!", "red")
				return
			else if (src.patient == H)
				H.tri_message(user, "<span class='notice'><b>[user]</b> removes [src]'s needle from [H == user ? "[his_or_her(H)]" : "[H]'s"] arm.</span>",\
					"<span class='notice'>You remove [src]'s needle from [H == user ? "your" : "[H]'s"] arm.</span>",\
					"<span class='notice'>[H == user ? "You remove" : "<b>[user]</b> removes"] [src]'s needle from your arm.</span>")
				src.stop_transfusion()
				return
		else
			if (src.mode == IV_INJECT)
				if (!src.reagents.total_volume)
					user.show_text("There's nothing left in [src]!", "red")
					return
				if (H.reagents && H.reagents.is_full())
					user.show_text("[H]'s blood pressure seems dangerously high as it is, there's probably no room for anything else!", "red")
					return

			else if (src.mode == IV_DRAW)
				if (src.reagents.is_full())
					user.show_text("[src] is full!", "red")
					return
				// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
				// Also ignore that second container of blood entirely if it's a vampire (Convair880).
				if ((isvampire(H) && (H.get_vampire_blood() <= 0)) || (!isvampire(H) && !H.blood_volume))
					user.show_text("[H] doesn't have anything left to give!", "red")
					return

			H.tri_message(user, "<span class='notice'><b>[user]</b> begins inserting [src]'s needle into [H == user ? "[his_or_her(H)]" : "[H]'s"] arm.</span>",\
				"<span class='notice'>[H == user ? "You begin" : "<b>[user]</b> begins"] inserting [src]'s needle into your arm.</span>",\
				"<span class='notice'>You begin inserting [src]'s needle into [H == user ? "your" : "[H]'s"] arm.</span>")
			logTheThing(LOG_COMBAT, user, "tries to hook up an IV drip [log_reagents(src)] to [constructTarget(H,"combat")] at [log_loc(user)].")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/item/reagent_containers/iv_drip/proc/insert_needle, list(H, user), src.icon, src.icon_state, null, null)
			return

	attackby(obj/A, mob/user)
		if (iscuttingtool(A) && !(src.slashed))
			src.slashed = 1
			src.desc = "[src.desc] It has been sliced open with a scalpel."
			boutput(user, "You carefully slice [src] open.")
			return
		else if (iscuttingtool(A) && (src.slashed))
			boutput(user, "[src] has already been sliced open.")
			return

	process(var/mob/living/carbon/human/H as mob)
		if (!src.patient || !ishuman(src.patient) || !src.patient.reagents)
			src.stop_transfusion()
			return

		if ((!src.stand && !in_interact_range(src, src.patient)) || (src.stand && !in_interact_range(src.stand, src.patient)))
			var/fluff = pick("pulled", "yanked", "ripped")
			src.patient.visible_message("<span class='alert'><b>[src]'s needle gets [fluff] out of [src.patient]'s arm!</b></span>",\
			"<span class='alert'><b>[src]'s needle gets [fluff] out of your arm!</b></span>")
			src.stop_transfusion()
			return

		if (src.mode == IV_INJECT)
			if (src.patient.reagents.is_full())
				src.patient.visible_message("<span class='notice'><b>[src.patient]</b>'s transfusion finishes.</span>",\
				"<span class='notice'>Your transfusion finishes.</span>")
				src.stop_transfusion()
				return
			if (!src.reagents.total_volume)
				src.patient.visible_message("<span class='alert'>[src] runs out of fluid!</span>")
				src.stop_transfusion()
				return

			// the part where shit's actually transferred
			src.reagents.trans_to(src.patient, src.amount_per_transfer_from_this)
			src.patient.reagents.reaction(src.patient, INGEST, src.amount_per_transfer_from_this)
			return

		else if (src.mode == IV_DRAW)
			if (src.reagents.is_full())
				src.patient.visible_message("<span class='notice'>[src] fills up and stops drawing blood from [src.patient].</span>",\
				"<span class='notice'>[src] fills up and stops drawing blood from you.</span>")
				src.stop_transfusion()
				return
			// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back.
			// Also ignore that second container of blood entirely if it's a vampire (Convair880).
			if ((isvampire(src.patient) && (src.patient.get_vampire_blood() <= 0)) || (!isvampire(src.patient) && !src.patient.reagents.total_volume && !src.patient.blood_volume))
				src.patient.visible_message("<span class='alert'>[src] can't seem to draw anything more out of [src.patient]!</span>",\
				"<span class='alert'>Your veins feel utterly empty!</span>")
				src.stop_transfusion()
				return

			// actual transfer
			transfer_blood(src.patient, src, src.amount_per_transfer_from_this)
			return

	proc/insert_needle(var/mob/living/carbon/human/H as mob, mob/living/carbon/user as mob)
		src.patient = H
		H.tri_message(user, "<span class='notice'><b>[user]</b> inserts [src]'s needle into [H == user ? "[his_or_her(H)]" : "[H]'s"] arm.</span>",\
			"<span class='notice'>[H == user ? "You insert" : "<b>[user]</b> inserts"] [src]'s needle into your arm.</span>",\
			"<span class='notice'>You insert [src]'s needle into [H == user ? "your" : "[H]'s"] arm.</span>")
		logTheThing(LOG_COMBAT, user, "connects an IV drip [log_reagents(src)] to [constructTarget(H,"combat")] at [log_loc(user)].")
		src.start_transfusion()

	proc/start_transfusion()
		src.in_use = 1
		processing_items |= src

	proc/stop_transfusion()
		processing_items -= src
		src.in_use = 0
		src.patient = null

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/iv_drip/blood
	desc = "A bag filled with some odd, synthetic blood. There's a fine needle at the end that can be used to transfer it to someone."
	icon_state = "IV-blood"
	mode = IV_INJECT
	initial_reagents = "blood"

/obj/item/reagent_containers/iv_drip/blood/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/iv_drip/saline
	desc = "A bag filled with saline. There's a fine needle at the end that can be used to transfer it to someone."
	mode = IV_INJECT
	initial_reagents = "saline"

/* ================================================== */
/* -------------------- IV Stand -------------------- */
/* ================================================== */

TYPEINFO(/obj/iv_stand)
	mats = 10

/obj/iv_stand
	name = "\improper IV stand"
	desc = "A metal pole that you can hang IV bags on, which is useful since we aren't animals that go leaving our sanitized medical equipment all over the ground or anything!"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IVstand"
	anchored = 0
	density = 0
	var/image/fluid_image = null
	var/image/bag_image = null
	var/obj/item/reagent_containers/iv_drip/IV = null
	var/obj/paired_obj = null

	get_desc()
		if (src.IV)
			var/list/examine_list = src.IV.examine()
			return examine_list.Join("\n")

	update_icon()
		if (!src.IV)
			src.icon_state = "IVstand"
			src.name = "\improper IV stand"
			src.UpdateOverlays(null, "fluid")
			src.UpdateOverlays(null, "bag")
		else
			if(!src.bag_image)
				src.bag_image = image(src.icon, icon_state = "IVstand1")
			src.UpdateOverlays(src.bag_image, "bag")
			src.name = "\improper IV stand ([src.IV])"
			if (src.IV.reagents.total_volume)
				if (!src.fluid_image)
					src.fluid_image = image(src.icon, icon_state = "IVstand1-fluid")
				src.fluid_image.icon_state = "IVstand1-fluid"
				var/datum/color/average = src.IV.reagents.get_average_color()
				src.fluid_image.color = average.to_rgba()
				src.UpdateOverlays(src.fluid_image, "fluid")
			else
				src.UpdateOverlays(null, "fluid")

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 20), user)
			return
		else if (!src.IV && istype(W, /obj/item/reagent_containers/iv_drip))
			if (isrobot(user)) // are they a borg? it's probably a mediborg's IV then, don't take that!
				return
			var/obj/item/reagent_containers/iv_drip/newIV = W
			user.visible_message("<span class='notice'>[user] hangs [newIV] on [src].</span>",\
			"<span class='notice'>You hang [newIV] on [src].</span>")
			user.u_equip(newIV)
			newIV.set_loc(src)
			src.IV = newIV
			newIV.stand = src
			src.UpdateIcon()
			return
		else if (src.IV)
			//src.IV.Attackby(W, user)
			W.AfterAttack(src.IV, user)
			return
		else
			return ..()

	attack_hand(mob/user)
		if (src.IV && !isrobot(user))
			var/obj/item/reagent_containers/iv_drip/oldIV = src.IV
			user.visible_message("<span class='notice'>[user] takes [oldIV] down from [src].</span>",\
			"<span class='notice'>You take [oldIV] down from [src].</span>")
			user.put_in_hand_or_drop(oldIV)
			oldIV.stand = null
			src.IV = null
			src.UpdateIcon()
			return
		else
			return ..()

	mouse_drop(atom/over_object as mob|obj)
		var/atom/movable/A = over_object
		if (usr && !usr.restrained() && !usr.stat && in_interact_range(src, usr) && in_interact_range(over_object, usr) && istype(A))
			if (src.IV && ishuman(over_object))
				src.IV.attack(over_object, usr)
				return
			else if (src.IV && over_object == src)
				src.IV.AttackSelf(usr)
				return
			else if (istype(over_object, /obj/stool/bed) || istype(over_object, /obj/stool/chair) || istype(over_object, /obj/machinery/optable))
				if (A == src.paired_obj && src.detach_from())
					src.visible_message("[usr] detaches [src] from [over_object].")
					return
				else if (src.attach_to(A))
					src.visible_message("[usr] attaches [src] to [over_object].")
					return
			else
				return ..()
		else
			return ..()

	proc/attach_to(var/obj/O as obj)
		if (!O)
			return 0
		if (src.paired_obj && !src.detach_from()) // detach_from() defaults to removing our paired_obj so we don't have to pass it anything
			return 0
		if (islist(O.attached_objs) && O.attached_objs.Find(src)) // we're already attached to this thing!!
			return 0
		mutual_attach(src, O)
		src.set_loc(O.loc)
		src.layer = (O.layer-0.1)
		src.pixel_y = 8
		src.paired_obj = O
		return 1

	proc/detach_from(var/obj/O as obj)
		if (!O && src.paired_obj)
			O = src.paired_obj
		if (!O)
			return 0
		mutual_detach(src, O)
		src.layer = initial(src.layer)
		src.pixel_y = initial(src.pixel_y)
		if (src.paired_obj == O)
			src.paired_obj = null
		return 1

	proc/deconstruct()
		if (src.IV)
			src.IV.set_loc(get_turf(src))
			src.IV.stand = null
			src.IV = null
		var/obj/item/furniture_parts/IVstand/P = new /obj/item/furniture_parts/IVstand(src.loc)
		if (P && src.material)
			P.setMaterial(src.material)
		qdel(src)
		return

	disposing()
		if (src.paired_obj)
			src.detach_from()
		if (src.IV)
			src.IV.set_loc(get_turf(src))
			src.IV.stand = null
			src.IV = null
		..()

/* ---------- IV Stand Parts ---------- */
/obj/item/furniture_parts/IVstand
	name = "\improper IV stand parts"
	desc = "A collection of parts that can be used to make an IV stand."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "IVstand_parts"
	force = 2
	stamina_damage = 10
	stamina_cost = 8
	furniture_type = /obj/iv_stand
	furniture_name = "\improper IV stand"
	build_duration = 25

#undef IV_INJECT
#undef IV_DRAW
