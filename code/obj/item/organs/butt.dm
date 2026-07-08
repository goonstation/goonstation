/*========================*/
/*----------Butt----------*/
/*========================*/

TYPEINFO(/obj/item/clothing/head/butt)
	mat_appearances_to_ignore = list("butt")
/obj/item/clothing/head/butt
	name = "butt"
	desc = "It's a butt. It goes on your head."
	var/organ_holder_name = "butt"
	var/organ_holder_location = "chest"
	icon = 'icons/obj/items/organs/butt.dmi'
	icon_state = "butt-nc"
	force = 1
	w_class = W_CLASS_TINY
	throwforce = 1
	throw_speed = 3
	throw_range = 5
	c_flags = COVERSEYES
	tool_flags = TOOL_ASSEMBLY_APPLIER
	var/toned = 1
	var/s_tone = "#FAD7D0"
	var/stapled = 0
	var/allow_staple = 1
	var/op_stage = 0
	rand_pos = 1
	var/mob/living/carbon/human/donor = null
	var/donor_name = null
	var/donor_DNA = null
	var/datum/organHolder/holder = null
	var/sound/sound_fart = null // this is the life I live, making it so you can change the fart sound of your butt (that you can wear on your head) so that you can make artifact butts with weird farts
	default_material = "butt"
	mat_changename = "butt"
	var/static/list/random_fart_sounds = list( // some nice variety in our fart sounds for random butt shennanigans
			'sound/voice/farts/poo2.ogg',
			'sound/voice/farts/fart1.ogg',
			'sound/voice/farts/fart2.ogg',
			'sound/voice/farts/fart3.ogg',
			'sound/voice/farts/fart4.ogg',
			'sound/voice/farts/fart5.ogg',
			'sound/voice/farts/fart6.ogg',
			'sound/voice/farts/fart7.ogg'
		)

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL)
		if (holder)
			holder.butt = null

		..()
		donor = null
		holder = null

	New(loc, datum/organHolder/nholder)
		..()
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, PROC_REF(assembly_removal))
		if (istype(nholder) && nholder.donor)
			src.holder = nholder
			src.donor = nholder.donor
		if (src.donor)
			src.donor_name = src.donor.real_name
			src.name = "[src.donor_name]’s [initial(src.name)]"
			src.real_name = "[src.donor_name]’s [initial(src.name)]" // Gotta do this somewhere!
			src.donor_DNA = src.donor.bioHolder ? src.donor.bioHolder.Uid : null
			if (src.toned && src.donor.bioHolder) //NO RACIALLY INSENSITIVE ASSHATS ALLOWED
				src.s_tone = src.donor.bioHolder.mobAppearance.s_tone
				if (src.s_tone)
					src.color = src.s_tone


	/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

	proc/assembly_application(var/manipulated_grenade, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
		if(!ON_COOLDOWN(src, "fart_play", 1 SECOND))
			var/turf/T = get_turf(src)
			playsound(T, (src.sound_fart ? src.sound_fart : 'sound/voice/farts/poo2.ogg'), 40, 1, -1)
			if (issimulatedturf(T))
				var/datum/gas_mixture/fart_gas = new /datum/gas_mixture
				fart_gas.farts = 0.17 // A quarter of a normal fart
				fart_gas.temperature = T20C
				fart_gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
				T.assume_air(fart_gas)

	proc/assembly_setup(var/manipulated_bomb, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
		//we need to displace the icon a bit more with butts than with other items
		if (is_build_in && parent_assembly.target == src)
			parent_assembly.icon_base_offset = 5
			if(src.toned)
				//for the assembly, we assume a normal butt, else it shows up non-coloured
				icon_state = "butt"



	proc/assembly_removal(var/manipulated_bomb, var/obj/item/assembly/parent_assembly, var/mob/user)
		//we need to reset the base icon offset
		parent_assembly.icon_base_offset = 0
		if(src.toned)
			//we changed the butt, now we change it back
			icon_state = initial(src.icon_state)
	/// ----------------------------------------------


	attack(var/mob/living/carbon/M, mob/living/carbon/user)
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

		if (!can_act(user))
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

		if (H.organHolder?.back_op_stage >= BACK_SURGERY_OPENED)
			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff]s [src] onto the [fluff2] where [H == user ? "[his_or_her(H)]" : "[H]'s"] butt used to be!"),\
				SPAN_ALERT("You [fluff] [src] onto the [fluff2] where [H == user ? "your" : "[H]'s"] butt used to be!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff]s [src] onto the [fluff2] where your butt used to be!"))

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "butt", 3.0)
			return 1
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
			SPAWN(5 SECONDS)
				allow_staple = 1

	handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
		. = ..() && !src.stapled
		if (!source || !target) return
		if( src.unstaple()) //Try a staple if it worked, yay
			if (!src.stapled) //That's the last staple!
				source.visible_message(SPAN_ALERT("<B>[source.name] rips out the staples from \the [src]!</B>"), SPAN_ALERT("<B>You rip out the staples from \the [src]!</B>"), SPAN_ALERT("You hear a loud ripping noise."))
				. = 1
			else //Did you get some of them?
				source.visible_message(SPAN_ALERT("<B>[source.name] rips out some of the staples from \the [src]!</B>"), SPAN_ALERT("<B>You rip out some of the staples from \the [src]!</B>"), SPAN_ALERT("You hear a loud ripping noise."))
				. = 0

			//Commence owie
			take_bleeding_damage(target, null, rand(4, 8), DAMAGE_BLUNT)	//My
			playsound(target, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE) //head,
			target.emote("scream") 									//FUCKING
			target.TakeDamage("head", rand(8, 16), 0) 				//OW!

			logTheThing(LOG_COMBAT, source, "rips out the staples on [constructTarget(target,"combat")]'s butt hat") //Crime

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/machinery/bot/buttbot/B = new /obj/machinery/bot/buttbot(src, W)
			// Let's not rat out changelings through their butt name, as funny as it is
			if(findtext(src.name, "mutagenic"))
				B.name = "mutagenic buttbot"
			else if (src.donor || src.donor_name)
				B.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] buttbot"
			user.show_text("You add [W] to [src]. Fantastic.", "blue")
			B.set_loc(get_turf(src))
			src.set_loc(B)
			user.u_equip(src)
			W.set_loc(B)
			user.u_equip(W)

		else
			return ..()

	on_forensic_scan(datum/forensic_scan/scan)
		. = ..()
		if(src.donor_DNA)
			scan.add_text("Butt's DNA: [src.donor_DNA]")

	proc/explode_butt()
		var/turf/T = get_turf(src)
		playsound(T, 'sound/voice/farts/superfart.ogg', 45, 1)
		new /obj/effects/explosion(T)
		if (issimulatedturf(T))
			var/datum/gas_mixture/fart_gas = new /datum/gas_mixture
			fart_gas.farts = 3.45 // five times the amount of a normal fart
			fart_gas.temperature = T20C
			fart_gas.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
			T.assume_air(fart_gas)
		qdel(src)

	proc/on_fart(var/mob/farted_on) // what is wrong with me
		return

	proc/setup_butt_prank(obj/machinery/door/targetDoor, mob/user) // balance a butt above a wooden door to prank the next person who opens it. based on the bucket prank code
		if(locate(/obj/item/clothing/head/butt) in targetDoor)
			boutput(user, "<b>There's already a butt prank set up!</b>")
			return
		logTheThing(LOG_COMBAT, user, "Set up a butt-door-prank on [targetDoor]")
		RegisterSignal(targetDoor, COMSIG_DOOR_OPENED, PROC_REF(butt_prank))
		user.u_equip(src)
		src.set_loc(targetDoor)
		user.visible_message(SPAN_ALERT("[user] props \the [src] above \the [targetDoor]!"), SPAN_ALERT("You prop \the [src] above \the [targetDoor]. The next person to come through will get a butt on their head!"))

		var/image/I = image(src.icon, src, src.icon_state, targetDoor.layer+0.1)
		I.color = src.color
		I.transform = matrix(I.transform, 0.5, 0.5, MATRIX_SCALE)
		I.transform = matrix(I.transform, (targetDoor.dir & (WEST | EAST) ? 0 : -16), (targetDoor.dir & (NORTH | SOUTH) ? 0 : -16), MATRIX_TRANSLATE)
		targetDoor.UpdateOverlays(I, "buttprank")

	proc/butt_prank(obj/machinery/door/targetDoor, atom/movable/AM)
		//fall off the door, land on their head if you can
		//note that AM can be null, and this is caught by !IN_RANGE

		UnregisterSignal(targetDoor, COMSIG_DOOR_OPENED)
		targetDoor.UpdateOverlays(null, "buttprank")

		if(!IN_RANGE(AM, targetDoor, 1))
			src.set_loc(get_turf(targetDoor))
			src.visible_message(SPAN_ALERT("[src] falls unhindered from \the [targetDoor], farting sadly upon hitting the floor.")) //butts have emotions
			playsound(src, (src.sound_fart ? src.sound_fart : pick(random_fart_sounds)), 50, TRUE)
			return

		logTheThing(LOG_COMBAT, AM, "Victim of butt-door-prank on [targetDoor]")

		if(!ishuman(AM))
			src.set_loc(get_turf(targetDoor))
			targetDoor.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], bouncing off [AM] and landing on the floor with a disappointed fart."))
			playsound(src, (src.sound_fart ? src.sound_fart : pick(random_fart_sounds)), 50, TRUE)
			return

		var/mob/living/carbon/human/H = AM

		if(H.head)
			src.set_loc(get_turf(H))
			H.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], bouncing off [H]'s hat and landing on the floor with an indignant fart!"), \
								SPAN_ALERT("[src] falls from \the [targetDoor], bouncing off your hat and landing on the floor with an indignant fart!"))
			playsound(H, (src.sound_fart ? src.sound_fart : pick(random_fart_sounds)), 50, TRUE)
			return


		src.set_loc(get_turf(H))
		H.equip_if_possible(src, SLOT_HEAD)
		H.set_clothing_icon_dirty()
		H.visible_message(SPAN_ALERT("[src] falls from \the [targetDoor], landing on [H]'s head with a gleeful fart! [pick("Butthead!", "Nerd!", "What a dork!")]"), \
							SPAN_ALERT("[src] falls from \the [targetDoor], landing on your head with a gleeful fart!"))
		playsound(H, (src.sound_fart ? src.sound_fart : pick(random_fart_sounds)), 50, TRUE)


	afterattack(obj/target, mob/user, flag)
		if(!istype(target, /obj/machinery/door/unpowered/wood))
			return ..()
		if(locate(/obj/item/clothing/head/butt) in target)
			boutput(user, "<b>There's already a butt prank set up!</b>")
			return
		boutput(user, "You start propping \the [src] above \the [target]...")
		SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(setup_butt_prank), list(target, user), src.icon, src.icon_state, \
					src.visible_message(SPAN_ALERT("<B>[user] props \the [src] above \the [target]</B>")), \
					INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

TYPEINFO(/obj/item/clothing/head/butt/cyberbutt)
	mat_appearances_to_ignore = list("pharosium")
/obj/item/clothing/head/butt/cyberbutt // what the fuck am I doing with my life
	name = "robutt"
	desc = "This is a butt, made of metal. A futuristic butt. Okay."
	icon_state = "butt-cyber"
	allow_staple = 0
	toned = 0
	default_material = "pharosium"
	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
// no this is not done and I dunno when it will be done
// I am a bad person who accepts bribes of freaky macho butt drawings and then doesn't prioritize the request the bribe was for

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/machinery/bot/buttbot/cyber/B = new /obj/machinery/bot/buttbot/cyber(src, W)
			if (src.donor || src.donor_name)
				B.name = "[src.donor_name ? "[src.donor_name]" : "[src.donor.real_name]"] robuttbot"
			user.show_text("You add [W] to [src]. Fantastic.", "blue")
			B.set_loc(get_turf(src))
			src.set_loc(B)
			user.u_equip(src)
			W.set_loc(B)
			user.u_equip(W)
		else
			return ..()

	emp_act()
		. = ..()
		donor?.emote("fart", FALSE)

// moving this from plants_crop.dm because SERIOUSLY WHY -- cirr
/obj/item/clothing/head/butt/synth
	name = "synthetic butt"
	desc = "Why would you even grow this. What the fuck is wrong with you?"
	icon_state = "butt-plant"
	toned = 0
