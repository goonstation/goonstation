/*
TODO: YETI MOB CRITTER, MAYBE? DUNNO.
TODO: MIGRATE MORE GENETIC EFFECTS INTO TRAITS
TODO: MAYBE ADD MORE?
TODO: MAYBE MIGRATE INTO USING MORE DATUMS?
TODO: USE COMPONENTS TO HANDLE SOUL COUNT FOR THE SCALING ITEMS??? (IS THIS NECESSARY?)
Whatever, it's been cleaned up a lot and it's no longer quite so awful.
*/


/proc/soulbuff(var/obj/item/to_buff)
	if(!to_buff)
		return 0
	to_buff.force = (initial(to_buff.force)) + total_souls_value
	to_buff.throwforce = (initial(to_buff.throwforce)) + total_souls_value //these were originally capped at 30, but that seemed arbitrary and pointless in hindsight
	to_buff.tooltip_rebuild = 1
	return 1

/proc/souladjust(var/to_adjust as num)
	if (!to_adjust)
		return 0
	total_souls_value = max(0, (total_souls_value + to_adjust))
	total_souls_sold = max(total_souls_sold, (total_souls_sold + to_adjust)) //total souls sold can never go down
	if (length(by_cat[TR_CAT_SOUL_TRACKING_ITEMS]))
		for (var/obj/item/Q as anything in by_cat[TR_CAT_SOUL_TRACKING_ITEMS])
			soulbuff(Q)
	return 1

var/list/strongcontracts = filtered_concrete_typesof(/obj/item/contract, /proc/is_strong_rollable_contract)
var/list/weakcontracts = filtered_concrete_typesof(/obj/item/contract, /proc/is_weak_rollable_contract)

proc/is_strong_rollable_contract(type)
	var/obj/item/contract/fakeInstance = type
	return (initial(fakeInstance.strong) && initial(fakeInstance.can_roll))

proc/is_weak_rollable_contract(type)
	var/obj/item/contract/fakeInstance = type
	return (!(initial(fakeInstance.strong)) && initial(fakeInstance.can_roll))


/proc/spawncontract(var/mob/badguy as mob, var/strong = 0, var/pen = 0) //Used for both the vanish proc and the WIP contract market.
	if(strong)
		var/tempcontract = pick(strongcontracts)
		var/obj/item/contract/U = new tempcontract(badguy)
		U.merchant = badguy
		if (!badguy.put_in_hand(U))
			U.set_loc(get_turf(badguy))
			if(pen)
				var/obj/item/pen/fancy/satan/P = new /obj/item/pen/fancy/satan(badguy)
				P.set_loc(get_turf(badguy))
				badguy.show_text("<h3>A new contract suddenly appears at your feet along with a free pen for being such an evil customer!</h3>", "blue")
			else
				badguy.show_text("<h3>A new contract suddenly appears at your feet!</h3>", "blue")
		else
			badguy.show_text("<h3>A new contract suddenly appears in your hand!</h3>", "blue")
			if(pen)
				var/obj/item/pen/fancy/satan/Q = new /obj/item/pen/fancy/satan(badguy)
				if (!badguy.put_in_hand(Q))
					Q.set_loc(get_turf(badguy))
					badguy.show_text("<h3>And a new pen appears at your feet!</h3>", "blue")
				else
					badguy.show_text("<h3>And a new pen appears in your other hand!</h3>", "blue")
	else
		var/tempcontract = pick(weakcontracts)
		var/obj/item/contract/U = new tempcontract(badguy)
		U.merchant = badguy
		if (!badguy.put_in_hand(U))
			U.set_loc(get_turf(badguy))
			if(pen)
				var/obj/item/pen/fancy/satan/P = new /obj/item/pen/fancy/satan(badguy)
				P.set_loc(get_turf(badguy))
				badguy.show_text("<h3>A new contract suddenly appears at your feet along with a free pen for being such an evil customer!</h3>", "blue")
			else
				badguy.show_text("<h3>A new contract suddenly appears at your feet!</h3>", "blue")
		else
			badguy.show_text("<h3>A new contract suddenly appears in your hand!</h3>", "blue")
			if(pen)
				var/obj/item/pen/fancy/satan/Q = new /obj/item/pen/fancy/satan(badguy)
				if (!badguy.put_in_hand(Q))
					Q.set_loc(get_turf(badguy))
					badguy.show_text("<h3>And a new pen appears at your feet!</h3>", "blue")
				else
					badguy.show_text("<h3>And a new pen appears in your other hand!</h3>", "blue")

/mob/proc/horse()
	var/mob/living/carbon/human/H = src
	if(H.mind && (H.mind.assigned_role != "Horse") || (!H.mind || !H.client)) //I am shamelessly copying this from the wizard cluwne spell
		boutput(H, "<span class='alert'><B>You NEIGH painfully!</B></span>")
		H.take_brain_damage(80)
		H.stuttering = 120
		H.mind?.assigned_role = "Horse"
		H.contract_disease(/datum/ailment/disability/clumsy,null,null,1)
		playsound(H, pick('sound/voice/cluwnelaugh1.ogg','sound/voice/cluwnelaugh2.ogg','sound/voice/cluwnelaugh3.ogg'), 35, 0, 0, clamp(1.0 + (30 - H.bioHolder.age)/50, 0.7, 1.4))
		H.change_misstep_chance(66)
		animate_clownspell(H)
		H.drop_from_slot(H.wear_suit)
		H.drop_from_slot(H.wear_mask)
		H.equip_if_possible(new /obj/item/clothing/suit/cultist/cursed(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/mask/horse_mask/cursed(H), H.slot_wear_mask)
		H.real_name = "HORSE"

/proc/neigh(var/string)
	var/modded = ""
	var/list/text_tokens = splittext(string, " ")
	for(var/token in text_tokens)
		modded += "NEIGH "
	modded += "NEIGH!"
	if(prob(15))
		modded += " - NEEEEEEIIIIGH!!!"

	return modded

/mob/proc/makesuperyeti()
	new /obj/critter/yeti/super(src.loc)
	src.unequip_all()
	src.partygib()

/proc/soulcheck(var/mob/M as mob)
	M?.abilityHolder?.updateText()
	if ((ishuman(M)) && (isdiabolical(M)))
		if (total_souls_value >= 10)
			if (!M.bioHolder.HasEffect("demon_horns"))
				M.bioHolder.AddEffect("demon_horns", 0, 0, 1)
			if (!M.bioHolder.HasEffect("hell_fire"))
				M.bioHolder.AddEffect("hell_fire", 0, 0, 1)
			return
		else if (!(total_souls_value >= 10))
			if (M.bioHolder.HasEffect("demon_horns"))
				M.bioHolder.RemoveEffect("demon_horns", 0, 0, 1)
			if (M.bioHolder.HasEffect("hell_fire"))
				M.bioHolder.RemoveEffect("hell_fire", 0, 0, 1)
			return
	else
		return

/mob/proc/satanclownize()
	src.transforming = 1
	src.canmove = 0
	APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
	for(var/obj/item/clothing/Q in src)
		src.u_equip(Q)
		if (Q)
			Q.set_loc(src.loc)
			Q.dropped(src)
			Q.layer = initial(Q.layer)

	var/mob/living/carbon/human/cluwne/satan/C = new(src.loc)
	if(src.mind)
		src.mind.transfer_to(C)
	else
		C.key = src.key

	var/acount = 0 //borrowing this from his grace
	var/amax = rand(10,15)
	var/screamstring = null
	var/asize = 1
	while(acount <= amax)
		screamstring += "<font size=[asize]>a</font>"
		if(acount > (amax/2))
			asize--
		else
			asize++
		acount++
	src.playsound_local(C.loc,'sound/effects/screech.ogg', 50, 1)
	if(C.mind)
		shake_camera(C, 20, 16)
		boutput(C, "<font color=red>[screamstring]</font>")
		boutput(C, "<span style=\"color:purple; font-size:150%\"><i><b><font face = Tempus Sans ITC>You have sold your soul and become a Faustian cluwne! Oh no!</font></b></i></span>")
		logTheThing(LOG_ADMIN, src, "has signed a contract and turned into a Faustian cluwne at [log_loc(C)]!")
		C.choose_name(3)
	else
		return

	SPAWN(1 SECOND)
		qdel(src)



/obj/item/pen/fancy/satan
	name = "demonic pen"
	desc = "A pen once owned by Old Nick himself. The point is as sharp as the Devil's wit, so it makes an excellent improvised throwing or stabbing weapon."
	force = 15
	throwforce = 15
	throw_range = 20
	burn_possible = 0
	hit_type = DAMAGE_STAB
	color = "#FF0000"
	font_color = "#FF0000"

	New()
		..()
		START_TRACKING_CAT(TR_CAT_SOUL_TRACKING_ITEMS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_SOUL_TRACKING_ITEMS)
		..()

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			if (ismob(usr))
				A:lastattacker = usr
				A:lastattackertime = world.time
			A.changeStatus("weakened", total_souls_value SECONDS) //scales with souls stolen, was capped, no longer capped, souls much harder to get without monkeys
			take_bleeding_damage(A, null, total_souls_value, DAMAGE_STAB)
		..()

	attack(target, mob/user)
		playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(!isdead(C))
				take_bleeding_damage(C, user, total_souls_value, DAMAGE_STAB) //scales with souls
		..()


/obj/item/storage/box/evil // the one you get in your briefcase
	name = "box of demonic pens"
	desc = "Contains a set of seven pens, great for collectors."
	spawn_contents = list(/obj/item/pen/fancy/satan = 4)
	burn_possible = 0 //Only makes sense since it's from hell.

/obj/item/paper/soul_selling_kit
	color = "#FF0000"
	name = "Paper-'Soul Stealing 101'"
	burn_possible = 0 //Only makes sense since it's from hell.
	info = {"<b>You shouldn't be seeing this yet!</b>"}

	New()
		..()
		info = {"<center><b>SO YOU WANT TO STEAL SOULS?</b></center><ul>
			<li>Step One: Grab a complimentary extra-sharp demonic pen and your infernal contract of choice from your devilish briefcase.</li>
			<li>Step Two: Present your contract to your victim by clicking on them with said contract, but be sure you have your hellish writing utensil handy in your other hand!</li>
			<li>Step Three: It takes about four seconds for you to force your victim to sign their name, be sure not to move during this process or the ink will smear!</li></ul>
			<b>Alternatively, you can just have people sign the contract willingly, but where's the fun in that?</b>
			<li>Your contracts are written in legalese, so anyone not wearing your lawyer suit is unable to read them!</li>
			<li>Your lawyer suit, in addition to looking stylish, doubles as a suit of body armor. Similarly, your briefcase is a great bludgeoning tool, and your pens make excellent throwing daggers.</li>
			<li>As you collect more souls, your briefcase and pens will grow stronger and will gain unique powers.</li>
			<li>You can expend [CONTRACT_COST] collected souls to summon another major contract, but your weapons will weaken as a result.</li>
			<li>To do so, click on the Summon Contract ability under the tab labeled Souls. Alternatively, right click on your briefcase while holding it in your hand and then select the option labelled Summon Contract.</li>
			<b><li>Oh, and if you ever find something that talks about horses, use it in your hand. Just trust your old pal Nick on this one.</li></b>"}


/obj/item/storage/briefcase/satan
	name = "devilish briefcase"
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	color = "#FF0000"
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 8
	burn_possible = 0 //Only makes sense since it's from hell.
	item_function_flags = IMMUNE_TO_ACID // we don't get a spare, better make sure it lasts.
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	desc = "A diabolical human leather-bound briefcase, capable of holding a number of small objects and tormented souls. All those tormented souls give it a good deal of heft; you could use it as a great improvised bludgeoning weapon."
	stamina_damage = 80 //buffed from 40
	stamina_cost = 20 //nerfed from 10
	stamina_crit_chance = 40 //buffed from 25
	spawn_contents = list(/obj/item/paper/soul_selling_kit, /obj/item/storage/box/evil, /obj/item/clothing/under/misc/lawyer/red/demonic)
	var/merchant = null

	New()
		..()
		START_TRACKING_CAT(TR_CAT_SOUL_TRACKING_ITEMS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_SOUL_TRACKING_ITEMS)
		..()

	make_my_stuff()
		..()
		SPAWN(0.5 SECONDS) //to give the buylist enough time to assign a merchant var to the briefcase

			var/tempcontract = null
			tempcontract = pick(strongcontracts)
			var/obj/item/contract/I = new tempcontract(src)
			I.merchant = src.merchant

			var/list/tempweakcontracts = weakcontracts.Copy()
			for (var/i in 1 to 3)
				tempcontract = pick(tempweakcontracts)
				tempweakcontracts.Remove(tempcontract)
				var/obj/item/contract/T = new tempcontract(src)
				T.merchant = src.merchant

	attack(mob/M, mob/user, def_zone)
		..()
		if (total_souls_value >= 6)
			var/mob/living/L = M
			if(istype(L))
				L.update_burning(total_souls_value) //sets people on fire above 5 souls sold, scales with souls.
		if (total_souls_value >= 10)
			wrestler_backfist(user, M) //sends people flying above 10 souls sold, does not scale with souls.

/obj/item/storage/briefcase/satan/verb/summon_contract()
	set name = "Summon Contract"
	set desc = "Spend 3 souls to summon another major contract." //HEY, CAN'T USE DEFINES IN VERB DESCS, BUT THE NUMBER IN HERE SHOULD CORRESPOND TO WHATEVER CONTRACT_COST IS. PLEASE UPDATE THIS NUMBER IF YOU CHANGE CONTRACT_COST
	set category = "Local"
	set src in usr

	if (!(isdiabolical(usr)))
		boutput(usr, "<span class='notice'>You aren't evil enough to buy an infernal contract!</span>")
		return
	if (!(total_souls_value >= CONTRACT_COST))
		boutput(usr, "<span class='notice'>You don't have enough souls to summon another contract! You need [CONTRACT_COST - total_souls_value] more to afford it.</span>")
		return
	else if ((total_souls_value >= CONTRACT_COST) && (isdiabolical(usr)))
		souladjust(-CONTRACT_COST)
		spawncontract(usr, 1, 1)
		boutput(usr, "<span class='notice'>You have spent [CONTRACT_COST] souls to summon another contract! Your weapons are weaker as a result.</span>")
		soulcheck(usr)
		return
	else
		boutput(usr, "<span class='alert'>Something is horribly broken. Please report this to a coder.</span>")
		return

ABSTRACT_TYPE(/obj/item/contract)

/*

SO YOU WANT TO MAKE YOUR OWN CONTRACTS:

FOLLOW THIS FORMAT FOR AN EASY AND DIGESTIBLE WAY TO BUILD YOUR OWN NEW CONTRACTS

obj/item/contract/replace_this_with_the_name_of_your_contract
	desc = "A contract that is full of boilerplate description text but you can shake it up however you like"
	limiteduse = 0 //OPTIONAL: Defaults to 0. Set this to 1 to make the contract vanish after it's used a certain number of times, otherwise OMIT
	contractlines = 3 //OPTIONAL: Defaults to 3. does nothing unless limiteduse is set to 1, determines how many times you can use a limiteduse contract before it vanishes
	strong = 0 //OPTIONAL: Defaults to 0. If set to 1, contract will be added to the pool of strong contracts (1 strong contract per briefcase, 20% chance to roll on vanish, 100% chance to roll on contract purchase)
	can_roll = 1 //OPTIONAL: Defaults to 1. IF SET TO 0, MAKES CONTRACT ADMIN-SPAWN ONLY.
	//THERE ARE SOME ADDITIONAL VARS STANDARD TO ALL CONTRACTS, BUT YOU SHOULDN'T EVER REALLY BE SETTING THEM DIRECTLY, SO THEY HAVE BEEN OMITTED FROM THIS EXAMPLE
	//YOU CAN ADD YOUR OWN VARS TO DO STUFF SPECIFIC TO YOUR CONTRACT (for an example: look at obj/item/contract/greed)

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			HERE'S WHERE YOU ACTUALLY DO MOST OF YOUR COOL EFFECTS AND STUFF
			user is the victim, the one you wanna be doing the cool things TO
			badguy is the person who owns the contract or who forced the victim to sign
			user is *always* passed in the arguments, but badguy is occasionally omitted
			in general, badguy is mostly used for behind-the-scenes code
			if you DO wind up using badguy in your code, be sure to check that it actually exists and that it's actually the type you expect it to be
			DON'T WORRY ABOUT HANDLING SOULS, THAT STUFF IS ALL HANDLED ALREADY
			IF YOU *DO* NEED TO DO SOME CUSTOM STUFF WITH SOULS THEN:
			total_souls_value is the number of souls CURRENTLY stockpiled (this number can go up OR down)
			total_souls_sold is the total number of souls that have been sold so far this round (this number can only go up)
			DO NOT DIRECTLY MODIFY THE VALUES OF THESE TWO VARIABLES. IF YOU NEED TO ADD OR SUBTRACT SOULS, THEN:
			use souladjust(num) to add num worth of souls to the soul tracking variables. Use a negative value for num to subtract souls.
		return 1

	You can define additional procs inside your contract if necessary,
	but all the actual *action* should take place inside the SPAWN_DGB block in MagicEffect

END GUIDE
*/

/obj/item/contract
	name = "infernal contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	var/uses = 4
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	color = "#FF0000"
	throw_speed = 4
	throw_range = 10
	desc = "A blank contract that's gone missing from hell."
	burn_possible = 0 //Only makes sense since it's from hell.
	var/limiteduse = 0 //whether it has a limited number of uses. 1 is limited, 0 is unlimited.
	var/inuse = 0 //is someone currently signing this thing?
	var/used = 0 // how many times a limited use contract has been signed so far
	var/contractlines = 3 //number of times it can be signed if limiteduse is true
	var/strong = 0 //0 if not strong, 1 if strong
	var/can_roll = 1 //1 if it can be generated by players, 0 if admin-spawn only
	var/merchant = null //who is *buying* the soul?
	showTooltipDesc = 0

	New()
		..()
		src.color = random_color()

	examine(mob/user)
		if ((ishuman(user) && istype(user:w_uniform, /obj/item/clothing/under/misc/lawyer/red/demonic)) || isobserver(user))
			return ..()
		else
			return list("A strange piece of old crinkled paper, covered in mysterious gibberish legalese.")

	get_desc()
		if (src.limiteduse == 0)
			. += "Somehow, it seems like an endless number of signatures could fit on this thing."
		else if (src.contractlines - src.used == 1)
			. += "It looks like only one more signature will fit on this thing."
		else
			. += "It looks like [src.contractlines - src.used] more signatures will fit on this thing."

	proc/MagicEffect(var/mob/user as mob, var/mob/badguy as mob) //this calls the actual contract effect
		if (!user)
			return 0
		if (isdiabolical(user))
			boutput(user, "<span class='notice'>You can't sell your soul to yourself!</span>")
			return 0
		src.visible_message("<span class='alert'><b>[user] signs [his_or_her(user)] name in blood upon [src]!</b></span>")
		logTheThing(LOG_ADMIN, user, "signed a [src.type] contract at [log_loc(user)]!")
		. = user.sell_soul(100, 0, 1)
		if(!.)
			boutput(badguy, "[user] signed [src] but had no soul to give!")

	proc/updateuses(var/mob/user as mob, var/mob/badguy as mob)
		if (src.limiteduse == 1)
			src.used++
			tooltip_rebuild = 1
			SPAWN(0)
				if (src.used >= src.contractlines)
					src.vanish(user, badguy)
	proc/vanish(var/mob/user as mob, var/mob/badguy as mob)
		if(user)
			boutput(user, "<span class='notice'><b>The depleted contract vanishes in a puff of smoke!</b></span>")
		playsound(src.loc, pick('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg'), 50, 1)
		if(badguy)
			spawncontract(badguy, (prob(20) ? 1 : 0), 0) //20 percent chance of rolling a strong contract
		SPAWN(1 DECI SECOND)
			qdel(src)

	attack(mob/M, mob/user, def_zone)
		if (!isliving(M) || isghostdrone(M) || issilicon(M) || isintangible(M))
			return
		if (!user.find_type_in_hand(/obj/item/pen/fancy/satan))
			return
		else if (isdiabolical(user))
			if (isnpc(M))
				boutput(user, "<span class='notice'>They don't have a soul to sell!</span>")
				return
			if (M == user)
				boutput(user, "<span class='notice'>You can't sell your soul to yourself!</span>")
				return
			if (!M.literate)
				boutput(user, "<span class='notice'>Unfortunately they don't know how to write. Their signature will mean nothing.</span>")
				return
			if (ismobcritter(M))
				var/mob/living/critter/C = M
				if (C.is_npc)
					boutput(user, "<span class='notice'>Despite your best efforts [M] refuses to sell you their soul!</span>")
					return
			if (src.inuse != 1)
				actions.start(new/datum/action/bar/icon/force_sign(user, M, src), user)

		else
			return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/pen))
			if (isdiabolical(user))
				boutput(user, "<span class='notice'>You can't sell your soul to yourself!</span>")
				return
			else if (user.mind && user.mind.soul < 100)
				boutput(user, "<span class='notice'>You don't have a soul to sell!</span>")
				return
			else if (!isliving(user))
				return
			else if(!isliving(user) || isghostdrone(user) || issilicon(user))
				return
			else if (istype(W, /obj/item/pen/fancy/satan))
				MagicEffect(user, src.merchant)
				SPAWN(1 DECI SECOND)
					soulcheck(src.merchant)
					updateuses(user, src.merchant)
			else
				user.visible_message("<span class='alert'><b>[user] looks puzzled as [he_or_she(user)] realizes [his_or_her(user)] pen isn't evil enough to sign [src]!</b></span>")
				return
		else
			return

/datum/action/bar/icon/force_sign
	var/mob/living/target
	var/obj/item/contract/my_contract
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 4 SECONDS

	New(owner, target, contract)
		. = ..()
		src.owner = owner
		src.target = target
		src.my_contract = contract
		icon = my_contract.icon
		icon_state = my_contract.icon_state

	onStart()
		. = ..()
		if (!isliving(target) || isghostdrone(target) || issilicon(target) || isintangible(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ismobcritter(target))
			var/mob/living/critter/C = target
			if (C.is_npc)
				interrupt(INTERRUPT_ALWAYS)
				return
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || my_contract == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/user = owner
		if (!user.find_type_in_hand(/obj/item/pen/fancy/satan))
			interrupt(INTERRUPT_ALWAYS)
			return
		target.visible_message("<span class='alert'><B>[owner] is guiding [target]'s hand to the signature field of [my_contract]!</B></span>")


	onUpdate()
		..()
		if (BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || my_contract == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/living/user = owner
		if (!user.find_type_in_hand(/obj/item/pen/fancy/satan))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(flag)
		. = ..()
		var/mob/living/user = owner
		user.show_text("You were interrupted!", "red")
		my_contract.inuse = 0

	onEnd()
		. = ..()
		target.visible_message("<span class='alert'>[owner] forces [target] to sign [my_contract]!</span>")
		logTheThing(LOG_COMBAT, owner, "forces [target] to sign a [my_contract] at [log_loc(owner)].")
		my_contract.MagicEffect(target, owner)
		SPAWN(1 DECI SECOND)
			my_contract.inuse = 0
			soulcheck(owner)
			my_contract.updateuses(target, owner)

obj/item/contract/satan
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read."
	limiteduse = 1
	contractlines = 2 //I'm not sure about this one, might be okay to leave it at 3.
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.unequip_all()
			user.satanclownize()
			//boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			//this didn't actually render for the user due to the order in which these procs were called, so most people never saw this alert
			//given the content of the OTHER big, highly visible text message, I think that moving this up would break with the current precident
		return 1

obj/item/contract/macho
	desc = "A contract that promises to bestow upon whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."
	limiteduse = 1 //why was this missing before????
	contractlines = 1
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.unequip_all()
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			user.machoize(1)

		return 1

obj/item/contract/wrestle
	desc = "A contract that promises to bestow upon whomever signs it athletic prowess, showmanship, and some other stuff you can't be bothered to read."
	limiteduse = 1
	contractlines = 2 //addiction is crippling, but surmountable. Should not be 3.
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			sleep(0.1 SECONDS)
			user.make_wrestler(1)
			user.traitHolder.addTrait("addict") //HEH
			user.traitHolder.addTrait("clutz")
			user.traitHolder.addTrait("leftfeet")
			user.traitHolder.addTrait("nervous")
			user.reagents.add_reagent(pick("methamphetamine", "crank", "LSD"), rand(1,75))
			boutput(user, "<span class='notice'>Oh cripes, looks like your years of drug abuse caught up with you! </span>")
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			user.visible_message("<span class='alert'>[user]'s pupils dilate.</span>")
			user.changeStatus("stunned", 100 SECONDS)

		return 1

obj/item/contract/yeti
	desc = "A contract that promises to bestow upon whomever signs it near infinite power, an unending hunger, and some other stuff you can't be bothered to read."
	limiteduse = 1
	contractlines = 1 //was originally 3
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.unequip_all()
			user.makesuperyeti()
			// UNNEEDED UNTIL YETI CRITTER MOB IMPLEMENTED boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")

		return 1

obj/item/contract/genetic
	desc = "A contract that promises to unlock the hidden potential of whomever signs it."
	limiteduse = 0

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("activator", 0, 0, 1)
			user.bioHolder.AddEffect("mutagenic_field", 0, 0, 1)
			boutput(user, "<span class='success'>You have finally achieved your full potential! Mom would so proud!</span>")
			if ((prob(5)) || (src.limiteduse == 1))
				SPAWN(1 SECOND)
					boutput(user, "<span class='success'>You feel an upwelling of additional power!</span>")
					user:unkillable = 1
					user.bioHolder.AddEffect("mutagenic_field_prenerf", 0, 0, 1)
					SPAWN(0.2 SECONDS)
						boutput(user, "<span class='success'>You have ascended beyond mere humanity!</span>")

		return 1

obj/item/contract/genetic/demigod
	desc = "A contract that promises to unlock the hidden potential (and more) of whomever signs it."
	limiteduse = 1
	contractlines = 2
	strong = 1

obj/item/contract/horse
	name = "eldritch tome"
	desc = "An ancient tome filled with nearly indecipherable scrawl. You can just barely make out something about horses, signatures, and souls. It seems like it might be some kind of bizarre doomsday prophecy."
	icon_state = "necrobook"
	item_state = "spellbook"
	strong = 1

	attack_self(mob/user as mob)
		if((ishuman(user)) && (isdiabolical(user)))
			if (total_souls_value >= HORSE_COST) //HORSE_COST (currently 15) souls needed to start the end-times. Sufficiently difficult?
				boutput(user, "<span class='alert'><font size=6><B>NEIGH!</b></font></span>")
				src.endtimes()
				SPAWN(1 DECI SECOND)
					soulcheck(user)
				return
			else
				boutput(user, "<span class='alert'><font size=3><B>You currently have [total_souls_value] souls. You need [HORSE_COST] soul points to begin the end times. </b></font></span>")
		else
			boutput(user, "<span class='notice'>Nothing happens.</span>")

	proc/endtimes()
		souladjust(-HORSE_COST)
		SPAWN(0)
			var/turf/spawn_turf = get_turf(src)
			new /obj/effects/ydrone_summon/horseman(spawn_turf)

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.horse()
			user.traitHolder.addTrait("soggy")
			boutput(user, "<span class='alert'><font size=6><B>NEIGH</b></font></span>")

		return 1

obj/item/contract/mummy
	desc = "A contract that promises to turn whomever signs it into a mummy. That's it. No tricks."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			var/list/limbs = list("l_arm","r_arm","l_leg","r_leg","head","chest")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				for (var/target in limbs)
					if (!H.bandaged.Find(target))
						H.bandaged += target
						H.update_body()
			user.reagents?.add_reagent("formaldehyde", 300) //embalming fluid for mummies
			if((prob(10)) || (src.limiteduse == 1))
				boutput(user, "<span class='notice'>Wow, that contract did a really thorough job of mummifying you! It removed your organs and everything!</span>")
				if(isliving(user))
					var/mob/living/L = user
					L.organHolder.drop_organ("all")

		return 1

obj/item/contract/mummy/thorough
	limiteduse = 1

obj/item/contract/vampire
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read. There's some warning about not using this one in the chapel written on the back."
	limiteduse = 1
	contractlines = 1
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.make_vampire(1)
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")

		return 1

obj/item/contract/juggle
	desc = "It's a piece of paper with a portait of a person juggling skulls. Something about this image is both vaguely familiar and deeply unsettling."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("juggler", 0, 0, 1)

		return 1

obj/item/contract/fart
	desc = "It's just a piece of paper with the word 'fart' written all over it."
	strong = 1
	can_roll = 0 //it probably wasn't a good idea to make this player accessible in the first place. Admin spawn only now.

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("linkedfart", 0, 0, 1)

		return 1

obj/item/contract/bee
	desc = "This contract promises to bestow bees upon whomever signs it. Unlimited bees."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_bee", 0, 0, 1)

		return 1

obj/item/contract/rested
	desc = "This contract promises to keep whomever signs it healthy and well rested."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_pentetic", 0, 0, 1)
			user.bioHolder.AddEffect("regenerator_super", 0, 0, 1)
			user.bioHolder.AddEffect("narcolepsy_super", 0, 0, 1) //basically, the signer's very vulnerable but exceptionally difficult to actually kill.

		return 1

obj/item/contract/reversal
	desc = "This contract promises to make the strong weak and the weak strong."
	limiteduse = 1
	contractlines = 1
	can_roll = 0 //BROKEN AS SHIT, HEALTH CODE MAKES ME WANT TO DIE, TRIED TO CLEAN IT UP FOR HOURS, DIDN'T WORK, FUCK IT, SAVE IT FOR A DUMB GIMMICK OR SMTH

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("breathless_contract", 0, 0, 1)
			user.traitHolder.addTrait("reversal")
			boutput(user, "<span class='notice'>You feel like you could take a shotgun blast to the face without getting a scratch on you!</span>")

		return 1

obj/item/contract/krampus
	desc = "This contract smells of meat and ghosts"
	limiteduse = 1
	contractlines = 1
	strong = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			boutput(user, "<span class='notice'>YOU CRUNCHIFY! OH GOD! </span>")
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one. (try click dragging some distant items)</b></span>")
			user.make_cube(/mob/living/carbon/cube/meat/krampus/telekinetic, INFINITY, get_turf(user))
		return 1

obj/item/contract/chemical
	desc = "This contract is adorned with a crude drawing of a werewolf imploding into a pile flaming spiders. What the hell?"

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_random", 0, 0, 1)

		return 1

obj/item/contract/hair
	desc = "This contract promises to make the undersigned individual have supernaturally fantastic and incredibly novel hair."


	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.traitHolder.addTrait("contract_hair")

		return 1

obj/item/contract/limbs
	desc = "This contract is really just a sketch of one of those inflatable air tube dancer things you see near used pod dealerships with some signature fields tacked onto the bottom."


	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			user.traitHolder.addTrait("contract_limbs")

		return 1

obj/item/contract/greed
	desc = "This contract is positively covered in dollar signs."
	var/number_of_cash_piles = 7

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN(1 DECI SECOND)
			for(var/i in 1 to number_of_cash_piles)
				var/obj/item/spacecash/random/tourist/S = new /obj/item/spacecash/random/tourist
				S.setup(user.loc)
			boutput(user, "<span class='notice'>Some money appears at your feet. What, did you expect some sort of catch or trick?</span>")
			if (prob(90)) //used to be 50/50, now it's only a 10% chance to get midased
				SPAWN(10 SECONDS)
					boutput(user, "<span class='notice'>What, not enough for you? Fine.</span>")
					var/turf/T = get_turf(user)
					if (T)
						playsound(T, 'sound/items/coindrop.ogg', 30, 1)
						new /obj/item/coin(T)
						for (var/i = 1; i<= 8; i= i*2)
							if (istype(get_turf(get_step(T,i)),/turf/simulated/floor))
								new /obj/item/coin (get_step(T,i))
							else
								new /obj/item/coin(T)
			else
				SPAWN(10 SECONDS)
					boutput(user, "<span class='notice'>Well, you were right.</span>")
					var/mob/living/carbon/human/H = user
					H.become_statue(getMaterial("gold"))

		return 1
