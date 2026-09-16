/obj/item/stamp
	name = "rubber stamp"
	desc = "A no-nonsense National Notary rubber stamp for stamping important documents. It has a simple acrylic handle."
	icon = 'icons/obj/writing.dmi'
	icon_state = "stamp"
	item_state = "stamp"
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	default_material = "synthrubber"
	var/special_mode = null
	var/is_reassignable = 1
	var/assignment = null
	var/available_modes = list("Granted", "Denied", "Void", "Current Time", "Your Name");
	var/current_mode = "Granted"
	var/current_state = null

/obj/item/stamp/New()
	..()
	if(special_mode)
		available_modes += special_mode
		current_mode = special_mode

/obj/item/stamp/proc/set_assignment(A)
	if (istext(A))
		src.assignment = A
		src.desc = "A rubber stamp for stamping important documents. It is assigned to: \"[A]\"."
		return
	else
		src.assignment = null
		src.desc = "A rubber stamp for stamping important documents."
		return

/obj/item/stamp/attackby(obj/item/C, mob/user)// assignment with ID
	if (istype(C, /obj/item/card/id))
		var/obj/item/card/id/ID = C
		if (!src.is_reassignable)
			boutput(user, SPAN_ALERT("This rubber stamp cannot be reassigned!"))
			return
		if (!isnull(src.assignment))
			boutput(user, SPAN_ALERT("This rubber stamp has already been assigned!"))
			return
		else if (!ID.assignment)
			boutput(user, SPAN_ALERT("This ID isn't assigned to a job!"))
			return
		src.set_assignment(ID.assignment)
		boutput(user, SPAN_NOTICE("You update the assignment of the rubber stamp."))
		return

/obj/item/stamp/attack_self() // change current mode
	var/NM = input(usr, "Configure \the [src]?", "[src.name]", src.current_mode) in src.available_modes
	if (!NM || !length(NM) || !(NM in src.available_modes))
		return
	src.current_mode = NM
	boutput(usr, SPAN_NOTICE("You set \the [src] to '[NM]'."))
	return

/obj/item/stamp/get_desc()
	. = ..()
	. += "It is set to '[current_mode]' mode."

/obj/item/stamp/reagent_act(reagent_id, volume)
	if (..())
		return
	switch(reagent_id)
		if ("acetone") // allow reassigning with acetone
			if (isnull(src.assignment) || !src.is_reassignable)
				return
			var/turf/T = get_turf(src)
			T.visible_message("<span>The acetone eats away at the rubber stamp's structure; it is now unassigned.</span>")
			src.set_assignment(null)
	return

// Suicide options
/obj/item/stamp/custom_suicide = 1
/obj/item/stamp/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message(SPAN_ALERT("<b>[user] stamps 'VOID' on [his_or_her(user)] forehead!</b>"))
	user.TakeDamage("head", 250, 0)
	return 1

/// Optional side effect to trigger when successfully stamping a piece of paper
/obj/item/stamp/proc/on_stamp(obj/item/paper/stamped_paper, mob/user)
	return

// ----------------------------------- //
// Special stamps
// ----------------------------------- //
/obj/item/stamp/cap
	name = "\improper captain's rubber stamp"
	desc = "The Captain's rubber stamp for stamping important documents. Ooh, it's the really fancy National Notary 'Congressional' model with the fine ebony handle."
	icon_state = "stamp-cap"
	default_material = "synthrubber_green"
	special_mode = "Captain"
	is_reassignable = 0
	assignment = "stamp-cap"

/obj/item/stamp/hop
	name = "\improper head of personnel's rubber stamp"
	desc = "The Head of Personnel's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Continental' models with the kingwood handle."
	icon_state = "stamp-hop"
	default_material = "synthrubber_blue"
	special_mode = "Head of Personnel"
	is_reassignable = 0
	assignment = "stamp-hop"

/obj/item/stamp/hos
	name = "\improper head of security's rubber stamp"
	desc = "The Head of Security's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Bancroft' models with the bloodwood handle."
	icon_state = "stamp-hos"
	special_mode = "Head of Security"
	is_reassignable = 0
	assignment = "stamp-hos"

/obj/item/stamp/ce
	name = "\improper chief engineer's rubber stamp"
	desc = "The Chief Engineer's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Mary' models with the ironwood handle."
	icon_state = "stamp-ce"
	default_material = "synthrubber_yellow"
	special_mode = "Chief Engineer"
	is_reassignable = 0
	assignment = "stamp-ce"

/obj/item/stamp/md
	name = "\improper medical director's rubber stamp"
	desc = "The Medical Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Anne' models with the rosewood handle."
	icon_state = "stamp-md"
	default_material = "synthrubber_blue"
	special_mode = "Medical Director"
	is_reassignable = 0
	assignment = "stamp-md"

/obj/item/stamp/rd
	name = "\improper research director's rubber stamp"
	desc = "The Research Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. John' models with the purpleheart handle."
	icon_state = "stamp-rd"
	default_material = "synthrubber_purple"
	special_mode = "Research Director"
	is_reassignable = 0
	assignment = "stamp-rd"

/obj/item/stamp/clown
	name = "\improper clown's rubber stamp"
	desc = "The Clown's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
	icon_state = "stamp-honk"
	default_material = "synthrubber_hotpink"
	special_mode = "Clown"
	is_reassignable = 0
	assignment = "stamp-honk"

/obj/item/stamp/centcom
	name = "\improper centcom executive rubber stamp"
	desc = "Some bureaucrat from Centcom probably lost this. Dang, is that National Notary's 'Admiral Sampson' model with the exclusive blackwood handle?"
	icon_state = "stamp-centcom"
	default_material = "synthrubber_blue"
	special_mode = "Centcom"
	is_reassignable = 0
	assignment = "stamp-centcom"

/obj/item/stamp/mime
	name = "\improper mime's rubber stamp"
	desc = "The Mime's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
	icon_state = "stamp-mime"
	default_material = "synthrubber_white"
	special_mode = "Mime"
	is_reassignable = 0
	assignment = "stamp-mime"

/obj/item/stamp/chap
	name = "\improper chaplain's rubber stamp"
	desc = "The Chaplain's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the National Notary 'Chesapeake' model in varnished oak."
	icon_state = "stamp-chap"
	default_material = "synthrubber_black"
	special_mode = "Chaplain"
	is_reassignable = 0
	assignment = "stamp-chap"

/obj/item/stamp/qm
	name = "\improper quartermaster's rubber stamp"
	desc = "The Quartermaster's rubber stamp for stamping whatever important documents they've gotten their hands on. A classic National Notary 'Eastport' model in oiled black walnut."
	icon_state = "stamp-qm"
	default_material = "synthrubber_yellow"
	special_mode = "Quartermaster"
	is_reassignable = 0
	assignment = "stamp-qm"

/obj/item/stamp/syndicate
	name = "\improper syndicate rubber stamp"
	desc = "Syndicate rubber stamp for stamping whatever important documents they've gotten their hands on. Surprisingly, it's also a National Notary 'Continental'. Not many choices out here."
	icon_state = "stamp-syndicate"
	special_mode = "Syndicate"
	is_reassignable = 0
	assignment = "stamp-syndicate"

/obj/item/stamp/law
	name = "\improper security's rubber stamp"
	desc = "Security's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the rugged National Notary 'Severn' model with the rock maple handle."
	icon_state = "stamp-law"
	special_mode = "Security"
	is_reassignable = 0
	assignment = "stamp-law"

/obj/item/stamp/angler
	name = "\improper angler's rubber stamp"
	desc = "The Angler's rubber stamp for stamping whatever important fishing documents they've gotten their hands on. It's the National Notary 'Wye' model in polished yew. Its a little cold and moist."
	icon_state = "stamp-angler"
	default_material = "synthrubber_blue"
	special_mode = "Angler"
	is_reassignable = 0
	assignment = "stamp-angler"

/obj/item/stamp/flock
	name = "\improper Inky Antenna"
	desc = "It looks kinda like a National Notary stamp of an unfamilar model. Theres small rods sticking out of it though. You doubt you can use it for whatever important documents you've gotten your hands on"
	icon_state = "stamp-flock"
	special_mode = "Flock"
	is_reassignable = 0
	assignment = "stamp-flock"
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/item/stamp/vampire
	name = "\improper vampiric stamp"
	desc = "a unique vampirism-themed stamp for whatever <b>spooky</b> documents you may have gotten your hands on.\
	It is a Natonal Notary 'ac-count-ant' model with the ebony handle. \
	It was made as promotional halloween toy by National Notary to get kids excited about paperwork, \
	sadly it was discontinued due to the users cutting themslves on the sharp bat wings."
	special_mode = "Vamp"
	icon_state = "stamp-vamp"
	assignment = "stamp-vamp"
	hit_type = DAMAGE_STAB
	force = 5

	on_stamp(obj/item/paper/stamped_paper, mob/user)
		if(!user || !isliving(user) || issilicon(user))
			return

		if(prob(20) && !isvampire(user))
			bleed(user, 1, 3)
			boutput(user, SPAN_COMBAT("\The [src]'s wings are too sharp you cut yourself on them! Why would they put them on the handle!?"))
			user.emote("scream")
