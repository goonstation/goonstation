/obj/submachine/claw_machine
	name = "claw machine"
	desc = "Sure we got our health insurance benefits cut, and yeah we don't get any overtime on holidays, but hey - free to play claw machines!"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw"
	anchored = 1
	density = 1
	mats = list("MET-1"=5, "CON-1"=5, "CRY-1"=5, "FAB-1"=5)
	deconstruct_flags = DECON_MULTITOOL | DECON_WRENCH | DECON_CROWBAR
	var/busy = 0
	var/list/prizes = list(/obj/item/toy/plush/small/bee,\
	/obj/item/toy/plush/small/buddy,\
	/obj/item/toy/plush/small/kitten,\
	/obj/item/toy/plush/small/monkey,\
	/obj/item/toy/plush/small/possum,\
	/obj/item/toy/plush/small/brullbar,\
	/obj/item/toy/plush/small/bunny,\
	/obj/item/toy/plush/small/penguin)
	var/list/prizes_rare = list(/obj/item/toy/plush/small/bee/cute,\
	/obj/item/toy/plush/small/buddy/future,\
	/obj/item/toy/plush/small/kitten/wizard,\
	/obj/item/toy/plush/small/monkey/assistant,\
	/obj/item/toy/plush/small/bunny/mask,\
	/obj/item/toy/plush/small/penguin/cool)
	var/list/prizes_ultra_rare = list(/obj/item/toy/plush/small/orca,\
	/obj/item/toy/plush/small/tuba,\
	/obj/item/toy/plush/small/chris,\
	/obj/item/toy/plush/small/fancyflippers,\
	/obj/item/toy/plush/small/billy,\
	/obj/item/toy/plush/small/arthur,\
	/obj/item/toy/plush/small/deneb,\
	/obj/item/toy/plush/small/singuloose)
	var/has_plushies = TRUE

/obj/submachine/claw_machine/attack_hand(var/mob/user)
	src.add_dialog(user)
	if(src.busy)
		boutput(user, "<span class='alert'>Someone else is currently playing [src]. Be patient!</span>")
	else
		if(!has_plushies && !length(src.contents))
			boutput(user, "<span class='alert'>[src] seems to be out of prizes, oh no! You could try adding a prize.</span>")
			return
		actions.start(new/datum/action/bar/icon/claw_machine(user,src), user)
		return

/obj/submachine/claw_machine/get_desc(dist)
	. = ..()
	if(length(src.contents))
		var/list/prizes = list()
		for(var/obj/item/I in src)
			prizes += "\a [I]"
		if(has_plushies)
			prizes += "a lot of plushies"
		if(length(prizes) == 1)
			if(has_plushies)
				. += "There are [prizes[1]] inside!"
			else
				. += "There is [prizes[1]] inside!"
		else
			. += "There are "
			. += jointext(prizes.Copy(1, length(prizes)), ", ")
			. += " and [prizes[length(prizes)]] inside!"
	else
		if(src.has_plushies)
			. += "There are a lot of plushies inside!"
		else
			. += "It is currently empty."

/obj/submachine/claw_machine/attackby(obj/item/I, mob/user)
	if(I.cant_drop || I.tool_flags)
		return ..()
	user.drop_item()
	I.set_loc(src)
	boutput(user, "<span class='notice'>You insert \the [I] into \the [src] as a prize.</span>")

/datum/action/bar/icon/claw_machine
	duration = 100
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "claw_machine"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw_action"
	resumable = FALSE
	var/mob/M
	var/obj/submachine/claw_machine/CM

/datum/action/bar/icon/claw_machine/New(mob, machine)
	M = mob
	CM = machine
	..()

/datum/action/bar/icon/claw_machine/onUpdate()
	..()
	if(BOUNDS_DIST(M, CM) > 0 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	if(prob(10) && !M.traitHolder?.hasTrait("claw"))
		playsound(CM, 'sound/machines/claw_machine_fail.ogg', 80, 1)
		M.visible_message("<span class='alert'>[M] flubs up and the claw drops [his_or_her(M)] prize!</spawn>")
		interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/claw_machine/onInterrupt()
	..()
	CM.busy = 0
	CM.icon_state = "claw"

/datum/action/bar/icon/claw_machine/onStart()
	..()
	if(BOUNDS_DIST(M, CM) > 0 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	playsound(CM, 'sound/machines/capsulebuy.ogg', 80, 1)
	CM.busy = 1
	CM.icon_state = "claw_playing"

/datum/action/bar/icon/claw_machine/onEnd()
	..()
	if(BOUNDS_DIST(M, CM) > 0 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	CM.busy = 0
	CM.icon_state = "claw"
	if(!CM.has_plushies && !length(CM.contents))
		playsound(CM, 'sound/machines/claw_machine_fail.ogg', 80, 1)
		M.visible_message("<span class='alert'>[CM] seems to be out of prizes, oh no!</spawn>")
		return
	playsound(CM, 'sound/machines/claw_machine_success.ogg', 80, 1)
	M.visible_message("<span class='notice'>[M] successfully secures their precious goodie, and it drops into the prize chute with a satisfying <i>plop</i>.</span>")
	var/list/prize_pool = null
	if(CM.has_plushies)
		prize_pool = prob(20) ? (prob(33) ? CM.prizes_ultra_rare : CM.prizes_rare) : CM.prizes
	if(length(CM.contents) && (prob(50) || isnull(prize_pool)))
		prize_pool = CM.contents
	var/obj/item/P = pick(prize_pool)
	if(ispath(P))
		P = new P(get_turf(src.M))
		P.desc = "Your new best friend, rescued from a cold and lonely claw machine."
	else
		P.set_loc(get_turf(src.M))
	P.throw_at(M, 16, 3)

/obj/item/toy/plush
	name = "plush toy"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "bear"
	desc = "A cute and cuddly plush toy!"
	throwforce = 3
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 3
	rand_pos = 1

/obj/item/toy/plush/proc/say_something(mob/user as mob)
	if(user.client && !isghostcritter(user)) // stupid monkeys...
		var/message = input("What should [src] say?")
		message = trim(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
		if (!message || BOUNDS_DIST(src, user) > 0)
			return
		phrase_log.log_phrase("plushie", message)
		logTheThing(LOG_SAY, user, "makes [src] say, \"[message]\"")
		user.audible_message("<span class='emote'>[src] says, \"[message]\"</span>")
		var/mob/living/carbon/human/H = user
		if (H.sims)
			H.sims.affectMotive("fun", 1)

/obj/item/toy/plush/attack_self(mob/user as mob)
	src.say_something(user)

/obj/item/toy/plush/attack(mob/M, mob/user)
	if (user.a_intent == INTENT_HELP)
		M.visible_message("<span class='emote'>[src] gives [M] a hug!</span>", "<span class='emote'>[src] gives you a hug!</span>")
	else
		. = ..()

/obj/item/toy/plush/small
	name = "small plush toy"
	desc = "You found a new friend!"
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 5

/obj/item/toy/plush/small/bee
	name = "bee plush toy"
	icon_state = "bee"

/obj/item/toy/plush/small/bee/cute
	name = "super cute bee plush toy"
	icon_state = "bee_cute"

/obj/item/toy/plush/small/buddy
	name = "buddy plush toy"
	icon_state = "buddy"

/obj/item/toy/plush/small/buddy/future
	name = "future buddy plush toy"
	icon_state = "buddy_future"

/obj/item/toy/plush/small/kitten
	name = "kitten plush toy"
	icon_state = "kitten"

/obj/item/toy/plush/small/kitten/wizard
	name = "wizard kitten plush toy"
	icon_state = "kitten_wizard"

/obj/item/toy/plush/small/monkey
	name = "monkey plush toy"
	icon_state = "monkey"

/obj/item/toy/plush/small/monkey/assistant
	name = "assistant monkey plush toy"
	icon_state = "monkey_assistant"

/obj/item/toy/plush/small/monkey/george
	name = "curious george monkey plush toy"
	icon_state = "monkey_george"

/obj/item/toy/plush/small/possum
	name = "possum plush toy"
	icon_state = "possum"

/obj/item/toy/plush/small/brullbar
	name = "brullbar plush toy"
	icon_state = "brullbar"

/obj/item/toy/plush/small/bunny
	name = "bunny plush toy"
	icon_state = "bunny"

/obj/item/toy/plush/small/bunny/mask
	name = "gas mask bunny plush toy"
	icon_state = "bunny_mask"

/obj/item/toy/plush/small/penguin
	name = "penguin plush toy"
	icon_state = "penguin"

/obj/item/toy/plush/small/penguin/cool
	name = "super cool penguin plush toy"
	icon_state = "penguin_cool"

/obj/item/toy/plush/small/orca
	name = "Lilac the orca"
	icon_state = "orca"

/obj/item/toy/plush/small/tuba
	name = "Tuba the rat"
	icon_state = "tuba"

/obj/item/toy/plush/small/chris
	name = "Chris the goat"
	icon_state = "chris"

/obj/item/toy/plush/small/fancyflippers
	name = "Fancyflippers the gentoo penguin"
	icon_state = "fancyflippers"

/obj/item/toy/plush/small/billy
	name = "Billy the hungry fish"
	icon_state = "billy"

/obj/item/toy/plush/small/arthur
	name = "Arthur the bumblespider"
	icon_state = "arthur"

/obj/item/toy/plush/small/arthur/attack_self(mob/user as mob)
	var/menuchoice = tgui_alert(user, "What would you like to do with [src]?", "Use [src]", list("Awoo", "Say"))
	if (!menuchoice)
		return
	if (menuchoice == "Awoo" && !ON_COOLDOWN(src, "playsound", 2 SECONDS))
		playsound(user, 'sound/voice/babynoise.ogg', 50, 1)
		src.audible_message("<span class='emote'>[src] awoos!</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/stress_ball
	name = "stress ball"
	desc = "Talk and fidget things out. It'll be okay."
	icon_state = "stress_ball"
	throw_range = 10

/obj/item/toy/plush/small/stress_ball/attack_self(mob/user as mob)
	var/menuchoice = tgui_alert(user, "What would you like to do with [src]?", "Use [src]", list("Fidget", "Say"))
	if (!menuchoice)
		return
	if (menuchoice == "Fidget")
		user.visible_message("<span class='emote'>[user] fidgets with [src].</span>")
		boutput(user, "<span class='notice'>You feel [pick("a bit", "slightly", "a teeny bit", "somewhat", "surprisingly", "")] [pick("better", "more calm", "more composed", "less stressed")].</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/deneb
	name = "Deneb the swan"
	icon_state = "deneb"

/obj/item/toy/plush/small/deneb/attack_self(mob/user as mob)
	var/menuchoice = tgui_alert(user, "What would you like to do with [src]?", "Use [src]", list("Honk", "Say"))
	if (!menuchoice)
		return
	if (menuchoice == "Honk" && !ON_COOLDOWN(src, "playsound", 2 SECONDS))
		playsound(user, 'sound/items/rubberduck.ogg', 50, 1)
		src.audible_message("<span class='emote'>[src] honks!</span>")
	else if (menuchoice == "Say")
		src.say_something(user)

/obj/item/toy/plush/small/singuloose
	name = "Singuloose the Singulo"
	icon_state = "singuloose"
