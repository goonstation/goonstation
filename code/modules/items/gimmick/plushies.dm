/obj/submachine/claw_machine
	name = "claw machine"
	desc = "Sure we got our health insurance benefits cut, and yeah we don't get any overtime on holidays, but hey - free to play claw machines!"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw"
	anchored = 1
	density = 1
	deconstruct_flags = DECON_MULTITOOL | DECON_WRENCH | DECON_CROWBAR
	var/busy = 0
	var/list/prizes = list(/obj/item/toy/plush/small/bee,\
	/obj/item/toy/plush/small/buddy,\
	/obj/item/toy/plush/small/kitten,\
	/obj/item/toy/plush/small/monkey,\
	/obj/item/toy/plush/small/possum,\
	/obj/item/toy/plush/small/wendigo,\
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
	/obj/item/toy/plush/small/arthur)

/obj/submachine/claw_machine/attack_hand(var/mob/user as mob)
	src.add_dialog(user)
	if(src.busy)
		boutput(user, "<span class='alert'>Someone else is currently playing [src]. Be patient!</span>")
	else
		actions.start(new/datum/action/bar/icon/claw_machine(user,src), user)
		return

/datum/action/bar/icon/claw_machine
	duration = 100
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "claw_machine"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "claw_action"
	var/mob/M
	var/obj/submachine/claw_machine/CM

/datum/action/bar/icon/claw_machine/New(mob, machine)
	M = mob
	CM = machine
	..()

/datum/action/bar/icon/claw_machine/onUpdate()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	if(prob(10))
		playsound(get_turf(CM), 'sound/machines/claw_machine_fail.ogg', 80, 1)
		M.visible_message("<span class='alert'>[M] flubs up and the claw drops [his_or_her(M)] prize!</spawn>")
		interrupt(INTERRUPT_ALWAYS)
		return

/datum/action/bar/icon/claw_machine/onResume()
	..()
	state = ACTIONSTATE_DELETE

/datum/action/bar/icon/claw_machine/onInterrupt()
	..()
	CM.busy = 0
	CM.icon_state = "claw"

/datum/action/bar/icon/claw_machine/onStart()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	playsound(get_turf(CM), 'sound/machines/capsulebuy.ogg', 80, 1)
	CM.busy = 1
	CM.icon_state = "claw_playing"

/datum/action/bar/icon/claw_machine/onEnd()
	..()
	if(get_dist(M, CM) > 1 || M == null || CM == null)
		interrupt(INTERRUPT_ALWAYS)
		return
	CM.busy = 0
	CM.icon_state = "claw"
	playsound(get_turf(CM), 'sound/machines/claw_machine_success.ogg', 80, 1)
	M.visible_message("<span class='notice'>[M] successfully secures their precious goodie, and it drops into the prize chute with a satisfying <i>plop</i>.</span>")
	var/obj/item/P = pick(prob(20) ? (prob(20) ? CM.prizes_ultra_rare : CM.prizes_rare) : CM.prizes)
	P = new P(get_turf(src.M))
	P.desc = "Your new best friend, rescued from a cold and lonely claw machine."
	P.throw_at(M, 16, 3)




/obj/item/toy/plush
	name = "plush toy"
	icon = 'icons/obj/plushies.dmi'
	icon_state = "bear"
	desc = "A cute and cuddly plush toy!"
	throwforce = 3
	w_class = 4.0
	throw_speed = 2
	throw_range = 3
	rand_pos = 1

/obj/item/toy/plush/attack_self(mob/user as mob)
	if (!ishuman(user))
		return
	var/message = input("What should [src] say?")
	message = trim(copytext(sanitize(html_encode(message)), 1, MAX_MESSAGE_LEN))
	if (!message || get_dist(src, user) > 1)
		return
	logTheThing("say", user, null, "makes [src] say, \"[message]\"")
	user.audible_message("<span class='emote'>[src] says, \"[message]\"</span>")
	var/mob/living/carbon/human/H = user
	if (H.sims)
		H.sims.affectMotive("fun", 1)

/obj/item/toy/plush/attack(mob/M as mob, mob/user as mob)
	if (user.a_intent == INTENT_HELP)
		M.visible_message("<span class='emote'>[src] gives [M] a hug!</span>", "<span class='emote'>[src] gives you a hug!</span>")
	else
		. = ..()

/obj/item/toy/plush/small
	name = "small plush toy"
	desc = "You found a new friend!"
	w_class = 3.0
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

/obj/item/toy/plush/small/wendigo
	name = "wendigo plush toy"
	icon_state = "wendigo"

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
	var/spam_flag = 0

/obj/item/toy/plush/small/arthur/attack_hand(mob/user as mob)
	if (user == src.loc && spam_flag < world.time)
		playsound(user, "sound/voice/babynoise.ogg", 50, 1)
		src.audible_message("<span class='emote'>[src] awoos!</span>")
		spam_flag = world.time + 2 SECONDS
	else return ..()
