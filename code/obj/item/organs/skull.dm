/*=========================*/
/*----------Skull----------*/
/*=========================*/
// it's uhh.  it's close enough to an organ.

/obj/item/skull
	name = "skull"
	desc = "It's a SKULL!"
	var/preddesc = "A trophy from a less interesting kill." // See assign_gimmick_skull().
	icon = 'icons/obj/surgery.dmi'
	icon_state = "skull"
	health = 4
	w_class = W_CLASS_TINY
	var/mob/donor = null
	var/donor_name = null
	var/datum/organHolder/holder = null
	//var/owner_job = null
	var/value = 1
	var/op_stage = 0.0
	var/obj/item/device/key/skull/key = null //May randomly contain a key
	rand_pos = 1
	var/made_from = "bone"
	var/last_use = 0

	New(loc, datum/organHolder/nholder)
		..()
		SPAWN(0)
			if (istype(nholder) && nholder.donor)
				src.holder = nholder
				src.donor = nholder.donor
			if (src.donor)
				src.donor_name = src.donor.real_name
				src.name = "[src.donor_name]'s [initial(src.name)]"
			src.setMaterial(getMaterial(made_from), appearance = 0, setname = 0)

	disposing()
		..()
		if (holder)
			holder.skull = null
		holder = null
		donor = null
		key = null

	examine() // For the hunter-specific objective (Convair880).
		. = ..()
		if (ishunter(usr))
			. += "[src.preddesc]\nThis trophy has a value of [src.value]."

	attack(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Override so we can check to see if we want to reinsert a skull into a corpse/body */
		if (!ismob(M))
			return ..()

		src.add_fingerprint(user)

		var/attach_result = src.attach_organ(M, user)
		if (attach_result == 1) // success
			return
		else if (isnull(attach_result)) // failure but don't attack
			return
		else // failure and attack them with the organ
			return ..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/parts/robot_parts/leg))
			var/obj/machinery/bot/skullbot/B

			if (src.icon_state == "skull_crystal" || istype(src, /obj/item/skull/crystal))
				B = new /obj/machinery/bot/skullbot/crystal(get_turf(user))

			else if (src.icon_state == "skullP" || istype(src, /obj/item/skull/strange))
				B = new /obj/machinery/bot/skullbot/strange(get_turf(user))

			else if (src.icon_state == "skull_strange" || istype(src, /obj/item/skull/peculiar))
				B = new /obj/machinery/bot/skullbot/peculiar(get_turf(user))

			else if (src.icon_state == "skullA" || istype(src, /obj/item/skull/odd))
				B = new /obj/machinery/bot/skullbot/odd(get_turf(user))

			else if (src.icon_state == "skull_noface" || istype(src, /obj/item/skull/noface))
				B = new /obj/machinery/bot/skullbot/faceless(get_turf(user))

			else if (src.icon_state == "skull_gold" || istype(src, /obj/item/skull/gold))
				B = new /obj/machinery/bot/skullbot/gold(get_turf(user))

			else
				B = new /obj/machinery/bot/skullbot(get_turf(user))

			if (src.donor || src.donor_name)
				B.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] skullbot"

			user.show_text("You add [W] to [src]. That's neat.", "blue")
			qdel(W)
			qdel(src)
			return

		if (istype(W, /obj/item/rods) && W.amount > 0)
			W.change_stack_amount(-1)
			user.visible_message("<b>[user]</b> jams a rod into the bottom of [src]. Welp.",\
			"You jam a rod into the bottom of [src]. Welp.")
			var/obj/item/reagent_containers/food/drinks/skull_chalice/C = new /obj/item/reagent_containers/food/drinks/skull_chalice(src.loc)
			user.put_in_hand_or_drop(C)
			qdel(src)
			return

		if (istool(W, TOOL_SAWING))
			user.visible_message("<span class='notice'>[user] hollows out [src].</span>")
			var/obj/item/clothing/mask/skull/smask = new /obj/item/clothing/mask/skull
			playsound(user.loc, "sound/machines/mixer.ogg", 50, 1)

			if (src.key)
				var/obj/item/device/key/skull/SK = src.key
				SK.set_loc(get_turf(user))
				SK.visible_message("<span class='alert'><B>A key clatters out of \the [src]!</B></span>")
				src.key = null

			smask.set_loc(get_turf(user))
			if (src.donor || src.donor_name)
				smask.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] skull mask"
				smask.desc = "The hollowed out skull of [src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"]"
			qdel(src)
			return

		else
			return ..()

	attack_self(mob/user as mob)
		var/nerdlist = list()
		if(last_use + 6 SECONDS < world.time)
			for (var/mob/living/carbon/M in oview(4,user))
				if (M == user || user.loc != get_turf(user))
					continue
				nerdlist += M
			user.visible_message("<span class='notice'>[user] holds out [src] and stares into it.</span>")
			if(src.donor || src.donor_name)
				user.say("Alas, poor [src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"]! I knew him, [length(nerdlist) != 0 ? pick(nerdlist) : "Horatio"], a fellow of infinite jest, of most excellent fancy.")
			else
				user.say("Alas, poor Yorick! I knew him, [length(nerdlist) != 0 ? pick(nerdlist) : "Horatio"], a fellow of infinite jest, of most excellent fancy.")
			last_use = world.time
			// Now cracks a noble heart.—Good night, sweet prince, And flights of angels sing thee to thy rest.

	proc/can_attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Impliments organ functions for skulls. Checks if a skull can be attached to a target mob */
		if (!(user.zone_sel.selecting == "head"))
			return 0

		if (!surgeryCheck(M, user))
			return 0

		if (!can_act(user))
			return 0

		var/mob/living/carbon/human/H = M
		if (!H.organHolder || !ishuman(H))
			return 0

		return 1

	proc/attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Impliments organ functions for skulls, just in case you wanted to put it back for some reason. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/obj/item/organ/organ_location = H.organHolder.get_organ("head")

		if (!organ_location)
			boutput(user, "<span class='notice'>Where are you putting that again? You need a head to hold the skull.</span>")
			return null

		if (!headSurgeryCheck(H))
			boutput(user, "<span class='notice'>You're going to need to remove that mask/helmet/glasses first.</span>")
			return null

		if (!H.organHolder.get_organ("skull") && H.organHolder.head.scalp_op_stage == 5.0)
			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] head!</span>",\
			user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] head!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your head!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "skull", 1.0)
			return 1

		return 0


/obj/item/skull/strange // Hunters get this one (Convair880).
	name = "strange skull"
	desc = "This thing is weird."
	icon_state = "skullP"
	value = 5

/obj/item/skull/odd // Changelings.
	name = "odd skull"
	desc = "What the hell was wrong with this person's FACE?! Were they even human?!"
	icon_state = "skullA"
	value = 4
	made_from = "viscerite"

/obj/item/skull/peculiar // Wizards.
	name = "peculiar skull"
	desc = "You feel extremely uncomfortable near this thing."
	icon_state = "skull_strange"
	value = 3

/obj/item/skull/crystal // Omnitraitors.
	name = "crystal skull"
	desc = "Does this mean there's an alien race with crystal bones somewhere?"
	icon_state = "skull_crystal"
	value = 10
	made_from = "molitz"

/obj/item/skull/gold // Macho man.
	name = "golden skull"
	desc = "Is this thing solid gold, or just gold-plated? Yeesh."
	icon_state = "skull_gold"
	value = 7
	made_from = "gold"

/obj/item/skull/noface // Cluwnes.
	name = "faceless skull"
	desc = "Fuck that's creepy."
	icon_state = "skull_noface"
	value = -1
