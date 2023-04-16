/*
CONTAINS:
DATA CARD
EMAG
ID CARD
GAUNTLET CARDS
*/

/obj/item/card
	name = "card"
	icon = 'icons/obj/items/card.dmi'
	icon_state = "id"
	wear_image_icon = 'icons/mob/clothing/card.dmi'
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	burn_type = 1
	stamina_damage = 0
	stamina_cost = 0
	var/list/files = list("tools" = 1)

	disposing()
		if (istype(src.loc,/obj/machinery/bot))
			var/obj/machinery/bot/B = src.loc
			if (B.botcard == src)
				B.botcard = null
		..()

TYPEINFO(/obj/item/card/emag)
	mats = 8

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry. Commonly referred to as an EMAG"
	name = "Electromagnetic Card"
	icon_state = "emag"
	item_state = "card-id"
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	layer = 6.0 // TODO fix layer
	is_syndicate = 1
	contraband = 6

	afterattack(var/atom/A, var/mob/user)
		if(!A || !user)
			return
		A.emag_act(user, src)

	attack()	//Fucking attack messages up in this joint.
		return

/obj/item/card/emag/fake
//delicious fake emag
	attack_hand(mob/user)
		boutput(user, "<span class='combat'>Turns out that card was actually a kind of [pick("deadly chameleon","spiny anteater","Discount Dan's latest product prototype","Syndicate Top Trumps Card","bag of neckbeard shavings")] in disguise! It stabs you!</span>")
		user.changeStatus("paralysis", 10 SECONDS)
		SPAWN(1 SECOND)
			var/obj/storage/closet/C = new/obj/storage/closet(get_turf(user))
			user.set_loc(C)
			C.layer = OBJ_LAYER
			C.name = "an ordinary closet"
			C.desc = "What? It's just an ordinary closet."
			C.welded = 1

/obj/item/card/data
	name = "data card"
	icon_state = "data"
	item_state = "card-id"
	desc = "A microchipped card used for storing data."
	var/datum/reagent_group_account/reagent_account = null

// ID CARDS

/obj/item/card/id
	name = "identification card"
	icon_state = "id"
	uses_multiple_icon_states = 1
	item_state = "card-id"
	desc = "A standardized NanoTrasen microchipped identification card that contains data that is scanned when attempting to access various doors and computers."
	flags = FPRINT | TABLEPASS | ATTACK_SELF_DELAY
	click_delay = 0.4 SECONDS
	wear_layer = MOB_BELT_LAYER
	var/datum/pronouns/pronouns = null
	var/list/access = list()
	var/registered = null
	var/assignment = null
	var/title = null
	var/emagged = 0
	var/datum/reagent_group_account/reagent_account = null
	/// this determines if the icon_state of the ID changes if it is given a new job
	var/keep_icon = FALSE

	// YOU START WITH  NO  CREDITS
	// WOW
	var/money = 0
	var/pin = 0000

	//It's a..smart card.  Sure.
	var/datum/computer/file/cardfile = null

	proc/update_name()
		name = "[src.registered]'s ID Card ([src.assignment])"

	get_desc()
		. = ..()
		if(src.pronouns)
			. += " Pronouns: [src.pronouns.name]"

	registered_owner()
		.= registered

/obj/item/card/id/New()
	..()
	src.pin = rand(1000,9999)
	START_TRACKING

/obj/item/card/id/disposing()
	STOP_TRACKING
	. = ..()

/obj/item/card/id/command
	icon_state = "id_com"

/obj/item/card/id/security
	icon_state = "id_sec"

/obj/item/card/id/research
	icon_state = "id_res"

/obj/item/card/id/engineering
	icon_state = "id_eng"

/obj/item/card/id/civilian
	icon_state = "id_civ"

/obj/item/card/id/clown
	icon_state = "id_clown"
	desc = "Wait, this isn't even an ID Card. It's a piece of a Chips Ahoy wrapper with crayon scribbles on it. What the fuck?"
	keep_icon = TRUE

/obj/item/card/id/gold
	name = "identification card"
	icon_state = "gold"
	item_state = "gold_id"
	desc = "This card is important!"
	keep_icon = TRUE

/obj/item/card/id/blank_deluxe
	name = "Deluxe ID"
	icon_state = "gold"
	item_state = "gold_id"
	registered = "Member"
	assignment = "Member"
	keep_icon = TRUE

/obj/item/card/id/captains_spare
	name = "Captain's spare ID"
	icon_state = "gold"
	item_state = "gold_id"
	registered = "Captain"
	assignment = "Captain"
	keep_icon = TRUE
	var/touched = FALSE
	New()
		..()
		access = get_access("Captain")
		src.AddComponent(/datum/component/log_item_pickup, "Captain")

//ABSTRACT_TYPE(/obj/item/card/id/pod_wars)
/obj/item/card/id/pod_wars
	desc = "An ID card to help open doors, lock pods, and identify your body."
	var/team = 0
#if defined(MAP_OVERRIDE_POD_WARS)
	//You can only pick this up if you're on the correct team, otherwise it explodes.
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team)
			..()
		else
			var/flavor = pick("doesn't like you", "can tell you don't deserve it", "saw into your very soul and found you wanting", "hates you", "thinks you stink", "thinks you two should start seeing other people", "doesn't trust you", "finds your lack of faith disturbing", "is just not that into you", "gently weeps")
			//stolen from Captain's Explosive Spare ID down below...
			boutput(user, "<span class='alert'>The ID card [flavor] and <b>explodes!</b></span>")
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
#endif

	nanotrasen
		name = "NanoTrasen Pilot"
		icon_state = "polaris"
		assignment = "NanoTrasen Pilot"
		access = list(access_heads)
		team = 1

		commander
			name = "NanoTrasen Commander"
			assignment = "NanoTrasen Commander"
			access = list(access_heads, access_captain)

	syndicate
		name = "Syndicate Pilot"
		icon_state = "id_syndie"
		assignment = "Syndicate Pilot"
		access = list(access_syndicate_shuttle)
		team = 2

		commander
			name = "Syndicate Commander"
			assignment = "Syndicate Commander"
			access = list(access_syndicate_shuttle, access_syndicate_commander)

/obj/item/card/id/dabbing_license
	name = "Dabbing License"
	icon_state = "id_dab"
	registered = "Dabber"
	assignment = "Dabber"
	desc = "This card authorizes the person wearing it to perform sick dabs."
	keep_icon = TRUE
	var/dab_count = 0
	var/dabbed_on_count = 0
	var/arm_count = 0
	var/brain_damage_count = 0
	New()
		access = list()
		..()

	get_desc()
		. = {"<br>
		Dabs performed: [dab_count]<br/>
		Arms lost: [arm_count]<br/>
		Brain Damage accumulated: [brain_damage_count]<br/>
		People dabbed on: [dabbed_on_count]<br/>"}

/obj/item/card/id/dabbing_license/attack_self(mob/user as mob)
	user.visible_message("[user] shows you: [bicon(src)] [src.name]: [get_desc(0, user)]")

	src.add_fingerprint(user)
	return

/obj/item/card/id/captains_spare/explosive
	pickup(mob/user)
		boutput(user, "<span class='alert'>The ID-Card explodes.</span>")
		user.transforming = 1
		var/obj/overlay/O = new/obj/overlay(get_turf(user))
		O.anchored = ANCHORED
		O.name = "Explosion"
		O.layer = NOLIGHT_EFFECTS_LAYER_BASE
		O.pixel_x = -92
		O.pixel_y = -96
		O.icon = 'icons/effects/214x246.dmi'
		O.icon_state = "explosion"
		SPAWN(3.5 SECONDS) qdel(O)
		logTheThing(LOG_COMBAT, user, "was gibbed by the explosive Captain's Spare at [log_loc(user)].")
		user.gib()

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message("[user] shows you: [bicon(src)] [src.name]: assignment: [src.assignment]", "You show off your card: [bicon(src)] [src.name]: assignment: [src.assignment]")

	src.add_fingerprint(user)
	return

/obj/item/card/id/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		if (user && E)
			user.show_text("You run [E] over [src], but nothing seems to happen.", "red")
		return FALSE
	src.access = list() // clear what used to be there
	var/list/all_accesses = get_all_accesses()
	for (var/i = rand(2,25), i > 0, i--)
		var/new_access = pick(all_accesses)
		src.access += new_access
		all_accesses -= new_access
		if (istype(src, /obj/item/card/id/syndicate)) // Nuke ops unable to exit their station (Convair880).
			src.access += access_syndicate_shuttle
		DEBUG_MESSAGE("[get_access_desc(new_access)] added to [src]")
	user?.show_text("You run [E] over [src], scrambling its access.", "red")
	logTheThing(LOG_STATION, user || usr, "emagged [src], scrambling its access and granting random access at [log_loc(user || usr)].")
	src.emagged = 1
	return TRUE

/*
/obj/item/card/id/verb/read()
	set src in usr

	boutput(usr, "[bicon(src)] [src.name]: The current assignment on the card is [src.assignment].")
	return
*/

/obj/item/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate_shuttle)

/obj/item/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered)
		var/reg = copytext(src.sanitize_name(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)), 1, 100)
		var/ass = copytext(src.sanitize_name(input(user, "What occupation would you like to put on this card?\n Note: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Staff Assistant"), 1), 1, 100)
		var/color = input(user, "What color should the ID's color band be?\nClick cancel to abort the forging process.") as null|anything in list("clown","golden","blue","red","green","purple","yellow","No band")
		var/datum/pronouns/pronouns = choose_pronouns(user, "What pronouns would you like to put on this card?", "Pronouns")
		src.pronouns = pronouns
		switch (color)
			if ("clown")
				src.icon_state = "id_clown"
			if ("golden")
				src.icon_state = "gold"
			if ("No band")
				src.icon_state = "id"
			if ("blue")
				src.icon_state = "id_civ"
			if ("red")
				src.icon_state = "id_sec"
			if ("green")
				src.icon_state = "id_com"
			if ("purple")
				src.icon_state = "id_res"
			if ("yellow")
				src.icon_state = "id_eng"
			else
				return // Abort process.
		src.registered = reg
		src.assignment = ass
		src.name = "[src.registered]'s ID Card ([src.assignment])"
		boutput(user, "<span class='notice'>You successfully forge the ID card.</span>")
	else
		..()

/obj/item/card/id/syndicate/attackby(obj/item/W, mob/user)
	var/obj/item/card/id/sourceCard = W
	if (istype(sourceCard))
		boutput(user, "You copy [sourceCard]'s accesses to [src].")
		src.access |= sourceCard.access
	else
		return ..()

/obj/item/card/id/syndicate/proc/sanitize_name(var/input, var/strip_bad_stuff_only = 0)
	input = strip_html(input, MAX_MESSAGE_LEN, 1)
	if (strip_bad_stuff_only)
		return input
	var/list/namecheck = splittext(trim(input), " ")
	for(var/i = 1, i <= namecheck.len, i++)
		namecheck[i] = capitalize(namecheck[i])
	input = jointext(namecheck, " ")
	return input

/obj/item/card/id/syndicate/commander
	name = "commander card"
	access = list(access_maint_tunnels, access_syndicate_shuttle, access_syndicate_commander)

/obj/item/card/id/temporary
	name = "temporary identification card"
	icon_state = "id"
	item_state = "card-id"
	desc = "A temporary NanoTrasen Identification Card. Its access will be revoked once it expires."
	var/duration = 60 //seconds
	var/starting_access = list()
	var/timer = 0 //if 1, description shows time remaining
	var/end_time = 0

/obj/item/card/id/temporary/New()
	..()
	SPAWN(0) //to give time for duration and starting access to be set
		starting_access = access
		end_time = ticker.round_elapsed_ticks + duration*10
		sleep(duration * 10)
		if(access == starting_access) //don't delete access if it's modified with an ID computer
			access = list()

/obj/item/card/id/temporary/examine(mob/user)
	. = ..()
	if(user.client && src.timer)
		. += "A small display in the corner reads: \"Time remaining: [max(0,round((end_time-ticker.round_elapsed_ticks)/10))] seconds.\""

/obj/item/card/id/gauntlet
	icon = 'icons/effects/VR.dmi'
	icon_state = "id_clown"
	New(var/L, var/mob/user)
		..()
		if (!user)
			registered = "???"
			assignment = "unknown phantom entity (no.. mob? this is awkward)"
		else
			if (istype(user, /mob/living/carbon/human/virtual))
				var/mob/living/LI = user:body
				if (LI)
					registered = LI.real_name
				else
					registered = user.real_name
			else
				registered = user.real_name

			if (!user.client)
				assignment = "literal meat shield (no client)"
			else
				assignment = "loading arena matches..."
				tag = "gauntlet-id-[user.client.key]"
				queryGauntletMatches(1, user.client.key)
		name = "[registered]'s ID Card ([assignment])"

	proc/SetMatchCount(var/matches)
		switch (matches)
			if (-INFINITY to 0)
				icon_state = "id_clown"
				assignment = "Gauntlet Newbie ([matches] rounds played)"
			if (1 to 10)
				icon_state = "id_civ"
				assignment = "Rookie Gladiator ([matches] rounds played)"
			if (11 to 20)
				icon_state = "id_res"
				assignment = "Beginner Gladiator ([matches] rounds played)"
			if (21 to 35)
				icon_state = "id_eng"
				assignment = "Skilled Gladiator ([matches] rounds played)"
			if (36 to 55)
				icon_state = "id_sec"
				assignment = "Advanced Gladiator ([matches] rounds played)"
			if (56 to 75)
				icon_state = "id_com"
				assignment = "Expert Gladiator ([matches] rounds played)"
			if (76 to INFINITY)
				icon_state = "gold"
				assignment = "Legendary Gladiator ([matches] rounds played)"
			else
				assignment = "what the fuck ([matches] rounds played)"
		name = "[registered]'s ID Card ([assignment])"

// Experimental item that may be made into a 100k spacebux reward in the future?
/obj/item/card/license_to_kill
	name = "License to Kill"
	desc = "The bearer of this license is allowed to kill any player they like, but only as long as it is in their inventory. Yes, even if you arent an antag. No, you dont need to ahelp this we already know if you have it. Get to it!"
	icon_state="fingerprint1"
	var/mob/owner = null
	var/is_very_visible = 0
	var/obj/maptext_junk/indicator = null

	very_visible
		is_very_visible = 1

	New()
		..()
		processing_items.Add(src)
		if (is_very_visible)
			indicator = new(src)
			indicator.maptext_x = -100
			indicator.maptext_y = 38
			indicator.maptext_width = 232
			indicator.maptext_height = 64
			var/col1 = "color: #fff; -dm-text-outline: 2px #000;"
			var/col2 = "color: #f00; -dm-text-outline: 2px #000;"
			var/blink1 = "<span class='c vb ps2p' style='[col1]'><span class='vga'>KILL</span>\n↓</span>"
			var/blink2 = "<span class='c vb ps2p' style='[col2]'><span class='vga'>KILL</span>\n↓</span>"
			indicator.maptext = blink1
			animate(indicator, maptext = blink1, time = 3, loop = -1)
			animate(maptext = blink2, time = 3, loop = -1)



	process()
		if(!owner) return
		if(!owner.contains(src))
			boutput(owner, "<h3><span class='alert'>You have lost your license to kill!</span></h3>")
			logTheThing(LOG_COMBAT, owner, "dropped their license to kill")
			logTheThing(LOG_ADMIN, owner, "dropped their license to kill")
			message_admins("[key_name(owner)] dropped their license to kill")
			owner.mind?.remove_antagonist(ROLE_LICENSED)
			if (is_very_visible)
				owner.vis_contents -= indicator
			owner = null

	pickup(mob/user as mob)
		if(user != owner)
			logTheThing(LOG_COMBAT, user, "picked up a license to kill")
			logTheThing(LOG_ADMIN, user, "picked up a license to kill")
			message_admins("[key_name(user)] picked up a license to kill")
			boutput(user, "<h3><span class='alert'>You now have a license to kill!</span></h3>")
			user.mind?.add_antagonist(ROLE_LICENSED)
			if (is_very_visible)
				user.vis_contents += indicator

			if(owner)
				boutput(owner, "<h2>You have lost your license to kill!</h2>")
				logTheThing(LOG_COMBAT, owner, "dropped their license to kill")
				logTheThing(LOG_ADMIN, owner, "dropped their license to kill")
				message_admins("[key_name(owner)] dropped their license to kill")
				owner.mind?.remove_antagonist(ROLE_LICENSED)
				if (is_very_visible)
					owner.vis_contents -= indicator
			owner = user
		..()
