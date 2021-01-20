/*========================*/
/*----------Butt----------*/
/*========================*/

/obj/item/clothing/head/butt
	name = "butt"
	desc = "It's a butt. It goes on your head."
	var/organ_holder_name = "butt"
	var/organ_holder_location = "chest"
	var/organ_holder_required_op_stage = 4.0
	icon = 'icons/obj/surgery.dmi'
	icon_state = "butt-nc"
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	c_flags = COVERSEYES
	var/toned = 1
	var/s_tone = "#FAD7D0"
	var/stapled = 0
	var/allow_staple = 1
	module_research = list("medical" = 1)
	module_research_type = /obj/item/clothing/head/butt
	var/op_stage = 0.0
	rand_pos = 1
	var/mob/living/carbon/human/donor = null
	var/donor_name = null
	var/donor_DNA = null
	var/datum/organHolder/holder = null
	var/sound/sound_fart = null // this is the life I live, making it so you can change the fart sound of your butt (that you can wear on your head) so that you can make artifact butts with weird farts
	var/made_from = "butt"

	disposing()
		if (donor?.organs)
			donor.organs -= src
		if (holder)
			holder.butt = null

		..()
		donor = null
		holder = null

	New(loc, datum/organHolder/nholder)
		..()
		SPAWN_DBG(0)
			src.setMaterial(getMaterial(made_from), appearance = 0, setname = 0)
			if (istype(nholder) && nholder.donor)
				src.holder = nholder
				src.donor = nholder.donor
			if (src.donor)
				src.donor_name = src.donor.real_name
				src.name = "[src.donor_name]'s [initial(src.name)]"
				src.real_name = "[src.donor_name]'s [initial(src.name)]" // Gotta do this somewhere!
				src.donor_DNA = src.donor.bioHolder ? src.donor.bioHolder.Uid : null
				if (src.toned && src.donor.bioHolder) //NO RACIALLY INSENSITIVE ASSHATS ALLOWED
					src.s_tone = src.donor.bioHolder.mobAppearance.s_tone
					if (src.s_tone)
						src.color = src.s_tone

	attack(var/mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (!ismob(M))
			return

		src.add_fingerprint(user)

		var/attach_result = src.attach_organ(M, user)
		if (attach_result == 1) // success
			return
		else if (isnull(attach_result)) // failure but don't attack
			return
		else // failure and attack them with the organ
			..()

	proc/can_attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Impliments organ functions for butts. Checks if a butt can be attached to a target mob */
		if (!(user.zone_sel.selecting == "chest"))
			return 0

		if (!surgeryCheck(M, user))
			return 0

		var/mob/living/carbon/human/H = M
		if (!H.organHolder || !ishuman(H))
			return 0

		return 1

	proc/attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Impliments organ functions for butts. For butt reattachment. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		var/fluff = pick("shove", "place", "drop")
		var/fluff2 = pick("hole", "gaping hole", "incision", "wound")

		if (H.butt_op_stage == 4.0)
			H.tri_message("<span class='alert'><b>[user]</b> [fluff]s [src] onto the [fluff2] where [H == user ? "[his_or_her(H)]" : "[H]'s"] butt used to be!</span>",\
			user, "<span class='alert'>You [fluff] [src] onto the [fluff2] where [H == user ? "your" : "[H]'s"] butt used to be!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff]s [src] onto the [fluff2] where your butt used to be!</span>")

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "butt", 3.0)
			H.butt_op_stage = 3.0
			return 1
		else if (H.butt_op_stage == 5.0)
			H.tri_message("<span class='alert'><b>[user]</b> [fluff]s [src] onto the [fluff2] where [H == user ? "[his_or_her(H)]" : "[H]'s"] butt used to be, but the [fluff2] has been cauterized closed and [src] falls right off!</span>",\
			user, "<span class='alert'>You [fluff] [src] onto the [fluff2] where [H == user ? "your" : "[H]'s"] butt used to be, but the [fluff2] has been cauterized closed and [src] falls right off!</span>",\
			H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff]s [src] onto the [fluff2] where your butt used to be, but the [fluff2] has been cauterized closed and [src] falls right off!</span>")
			if (user.find_in_hand(src))
				user.u_equip(src)
			return null
		else
			return 0

	proc/staple()
		if (src.stapled <=0)
			src.cant_self_remove = 1
			src.stapled = max(src.stapled, 0)
		src.stapled += 1

	proc/unstaple()
		. = 0
		if (stapled && allow_staple )	//Did an unstaple operation take place?
			if ( --src.stapled <= 0 ) //Got all the staples
				src.cant_self_remove = 0
				src.stapled = 0
			. = 1
			allow_staple = 0
			SPAWN_DBG(5 SECONDS)
				allow_staple = 1

	handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
		. = ..() && !src.stapled
		if (!source || !target) return
		if( src.unstaple()) //Try a staple if it worked, yay
			if (!src.stapled) //That's the last staple!
				source.visible_message("<span class='alert'><B>[source.name] rips out the staples from \the [src]!</B></span>", "<span class='alert'><B>You rip out the staples from \the [src]!</B></span>", "<span class='alert'>You hear a loud ripping noise.</span>")
				. = 1
			else //Did you get some of them?
				source.visible_message("<span class='alert'><B>[source.name] rips out some of the staples from \the [src]!</B></span>", "<span class='alert'><B>You rip out some of the staples from \the [src]!</B></span>", "<span class='alert'>You hear a loud ripping noise.</span>")
				. = 0

			//Commence owie
			take_bleeding_damage(target, null, rand(4, 8), DAMAGE_BLUNT)	//My
			playsound(get_turf(target), "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1) //head,
			target.emote("scream") 									//FUCKING
			target.TakeDamage("head", rand(8, 16), 0) 				//OW!

			logTheThing("combat", source, target, "rips out the staples on [constructTarget(target,"combat")]'s butt hat") //Crime

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/timer))
			var/obj/item/gimmickbomb/butt/B = new /obj/item/gimmickbomb/butt
			B.set_loc(get_turf(user))
			user.show_text("You add the timer to the butt!", "blue")
			qdel(W)
			qdel(src)
		else if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/machinery/bot/buttbot/B = new /obj/machinery/bot/buttbot
			if (src.toned)
				B.toned = 1
				B.s_tone = src.s_tone

			if (src.donor || src.donor_name)
				B.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] buttbot"
			user.show_text("You add [W] to [src]. Fantastic.", "blue")
			B.set_loc(get_turf(user))
			qdel(W)
			qdel(src)

		else if (istype(W, /obj/item/spacecash) && W.type != /obj/item/spacecash/buttcoin)
			user.u_equip(W)
			pool(W)

			var/obj/item/spacecash/buttcoin/S = unpool(/obj/item/spacecash/buttcoin)
			S.setup(get_turf(src))
			user.put_in_hand_or_drop(S)

			user.show_text("You stuff the cash into the butt... (What is wrong with you?)")
			qdel(src)

		else
			return ..()

	proc/on_fart(var/mob/farted_on) // what is wrong with me
		return

/obj/item/clothing/head/butt/cyberbutt // what the fuck am I doing with my life
	name = "robutt"
	desc = "This is a butt, made of metal. A futuristic butt. Okay."
	icon_state = "butt-cyber"
	allow_staple = 0
	toned = 0
	made_from = "pharosium"
	sound_fart = "sound/voice/farts/poo2_robot.ogg"
// no this is not done and I dunno when it will be done
// I am a bad person who accepts bribes of freaky macho butt drawings and then doesn't prioritize the request the bribe was for

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/machinery/bot/buttbot/cyber/B = new /obj/machinery/bot/buttbot/cyber(get_turf(user))
			if (src.donor || src.donor_name)
				B.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] robuttbot"
			user.show_text("You add [W] to [src]. Fantastic.", "blue")
			qdel(W)
			qdel(src)
		else
			return ..()

// moving this from plants_crop.dm because SERIOUSLY WHY -- cirr
/obj/item/clothing/head/butt/synth
	name = "synthetic butt"
	desc = "Why would you even grow this. What the fuck is wrong with you?"
	icon_state = "butt-plant"
