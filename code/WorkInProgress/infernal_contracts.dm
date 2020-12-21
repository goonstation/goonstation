/proc/spawncontract(var/mob/badguy as mob, var/strong = 0, var/pen = 0) //Used for both the vanish proc and the WIP contract market.
	if(strong)
		var/list/replacementcontracts = list(/obj/item/contract/yeti,
		/obj/item/contract/genetic,
		/obj/item/contract/vampire,
		/obj/item/contract/wrestle,
		/obj/item/contract/satan)

		var/tempcontract = pick(replacementcontracts)
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
		var/list/replacementcontracts = list(/obj/item/contract/greed,
												/obj/item/contract/mummy,
												/obj/item/contract/hair,
												/obj/item/contract/genetic/demigod,
												/obj/item/contract/juggle,
												/obj/item/contract/bee,
												/obj/item/contract/rested,
												/obj/item/contract/reversal,
												/obj/item/contract/chemical,
												/obj/item/contract/mummy/thorough)

		var/tempcontract = pick(replacementcontracts)
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
		playsound(get_turf(H), pick("sound/voice/cluwnelaugh1.ogg","sound/voice/cluwnelaugh2.ogg","sound/voice/cluwnelaugh3.ogg"), 35, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
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
	src.invisibility = 101
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
	src.playsound_local(C.loc,"sound/effects/screech.ogg", 100, 1)
	if(C.mind)
		shake_camera(C, 20, 16)
		boutput(C, "<font color=red>[screamstring]</font>")
		boutput(C, "<i><b><font face = Tempus Sans ITC>You have sold your soul and become an avatar of evil! Spread darkness across the land!</font></b></i>")
		C.mind.special_role = "Faustian Cluwne"
		logTheThing("admin", src, null, "has transformed into a demonic cluwne at [log_loc(C)]!")
		ticker.mode.Agimmicks.Add(C)
		C.choose_name(3)
	else
		return

	SPAWN_DBG(1 SECOND)
		qdel(src)

/obj/item/pen/fancy/satan
	name = "demonic pen"
	desc = "A pen once owned by Old Nick himself. The point is as sharp as the Devil's wit, so it makes an excellent improvised throwing or stabbing weapon."
	force = 15
	throwforce = 15
	burn_possible = 0
	hit_type = DAMAGE_STAB
	color = "#FF0000"
	font_color = "#FF0000"

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			if (ismob(usr))
				A:lastattacker = usr
				A:lastattackertime = world.time
			A.changeStatus("weakened",  min((total_souls_value), 15) * 10) //scales with souls stolen, up to 15
			take_bleeding_damage(A, null, total_souls_value, DAMAGE_STAB)
		..()

	attack(target as mob, mob/user as mob)
		src.force = min((15 + total_souls_value), 30)
		playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 60, 1)
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
	info = {"<center><b>SO YOU WANT TO STEAL SOULS?</b></center><ul>
			<li>Step One: Grab a complimentary extra-sharp demonic pen and your infernal contract of choice from your devilish briefcase.</li>
			<li>Step Two: Present your contract to your victim by clicking on them with said contract, but be sure you have your hellish writing utensil handy in your other hand!</li>
			<li>Step Three: It takes about fifteen seconds for you to force your victim to sign their name, be sure not to move during this process or the ink will smear!</li></ul>
			<b>Alternatively, you can just have people sign the contract willingly, but where's the fun in that?</b>
			<li>Your contracts are written in legalese, so anyone not wearing your lawyer suit is unable to read them!</li>
			<li>Your lawyer suit, in addition to looking stylish, doubles as a suit of body armor. Similarly, your briefcase is a great bludgeoning tool, and your pens make excellent throwing daggers.</li>
			<li>As you collect more souls, your briefcase and pens will grow stronger and will gain unique powers.</li>
			<li>You can expend five collected souls to summon another major contract, but your weapons will weaken as a result.</li>
			<li>To do so, click on the Summon Contract ability under the tab labeled Souls. Alternatively, right click on your briefcase while holding it in your hand and then select the option labelled Summon Contract.</li>
			<b><li>Oh, and if you ever find something that talks about horses, use it in your hand. Just trust your old pal Nick on this one.</li></b>"}


/obj/item/storage/briefcase/satan
	name = "devilish briefcase"
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	color = "#FF0000"
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	burn_possible = 0 //Only makes sense since it's from hell.
	w_class = 4.0
	max_wclass = 3
	desc = "A diabolical human leather-bound briefcase, capable of holding a number of small objects and tormented souls. All those tormented souls give it a good deal of heft; you could use it as a great improvised bludgeoning weapon."
	stamina_damage = 40
	stamina_cost = 10
	stamina_crit_chance = 25
	spawn_contents = list(/obj/item/paper/soul_selling_kit, /obj/item/storage/box/evil, /obj/item/clothing/under/misc/lawyer/red/demonic)
	var/merchant = null

	make_my_stuff()
		..()
		SPAWN_DBG(0.5 SECONDS) //to give the buylist enough time to assign a merchant var to the briefcase
			var/list/contracts = list(/obj/item/contract/yeti,
			/obj/item/contract/genetic/demigod,
			/obj/item/contract/vampire,
			/obj/item/contract/wrestle,
			/obj/item/contract/satan)

			var/tempcontract = null
			if (prob(3)) //gotta be rare enough for it to not get stale
				var/loot = rand(1,2)
				switch(loot)
					if (1)
						var/obj/item/contract/horse/H = new /obj/item/contract/horse(src)
						H.merchant = src.merchant
					if (2)
						var/obj/item/contract/fart/F = new /obj/item/contract/fart(src)
						F.merchant = src.merchant
			else
				tempcontract = pick(contracts)
				var/obj/item/I = new tempcontract(src)
				I:merchant = src.merchant
				contracts -= tempcontract

			contracts = list(/obj/item/contract/greed,
			/obj/item/contract/mummy,
			/obj/item/contract/hair,
			/obj/item/contract/genetic,
			/obj/item/contract/juggle,
			/obj/item/contract/bee,
			/obj/item/contract/rested,
			/obj/item/contract/reversal,
			/obj/item/contract/chemical,
			/obj/item/contract/mummy/thorough)

			tempcontract = pick(contracts)
			var/obj/item/C = new tempcontract(src)
			C:merchant = src.merchant
			contracts -= tempcontract

			tempcontract = pick(contracts)
			var/obj/item/P = new tempcontract(src)
			P:merchant = src.merchant
			contracts -= tempcontract

			tempcontract = pick(contracts)
			var/obj/item/Z = new tempcontract(src)
			Z:merchant = src.merchant
			contracts -= tempcontract

	attack(mob/M as mob, mob/user as mob, def_zone)
		src.force = min((15 + total_souls_value), 30) //capped at 30 max force
		..()
		if (total_souls_value >= 6)
			var/mob/living/L = M
			if(istype(L))
				L.update_burning(total_souls_value) //sets people on fire above 5 souls sold, scales with souls.
		if (total_souls_value >= 10)
			wrestler_backfist(user, M) //sends people flying above 10 souls sold, does not scale with souls.

	throw_impact(atom/A, datum/thrown_thing/thr)
		src.throwforce = min((15 + total_souls_value), 30) //capped at 30 max throwforce.
		..()

/obj/item/storage/briefcase/satan/verb/summon_contract()
	set name = "Summon Contract"
	set desc = "Spend five souls to summon another major contract."
	set category = "Local"
	set src in usr

	if (!(isdiabolical(usr)))
		boutput(usr, "<span class='notice'>You aren't evil enough to buy an infernal contract!</span>")
		return
	if (!(total_souls_value >= 5))
		boutput(usr, "<span class='notice'>You don't have enough souls to summon another contract! You need [5 - total_souls_value] more to afford it.</span>")
		return
	else if ((total_souls_value >= 5) && (isdiabolical(usr)))
		total_souls_value -= 5
		spawncontract(usr, 1, 1)
		boutput(usr, "<span class='notice'>You have spent five souls to summon another contract! Your weapons are weaker as a result.</span>")
		soulcheck(usr)
		return
	else
		boutput(usr, "<span class='alert'>Something is horribly broken. Please report this to a coder.</span>")
		return

/obj/item/contract
	name = "infernal contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	var/uses = 4.0
	flags = FPRINT | TABLEPASS
	w_class = 2.0
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
	var/merchant = null
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
		logTheThing("admin", user, null, "signed a [src.type] contract at [log_loc(user)]!")
		return user.sell_soul(100, 0, 1)

	proc/vanish(var/mob/user as mob, var/mob/badguy as mob)
		if(user)
			boutput(user, "<span class='notice'><b>The depleted contract vanishes in a puff of smoke!</b></span>")
		playsound(src.loc, pick('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg'), 50, 1)
		spawncontract(badguy, 0, 0) //huzzah for efficient code
		SPAWN_DBG(1 DECI SECOND)
			qdel(src)

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (!isliving(M) || isghostdrone(M) || issilicon(M))
			return
		if (!user.find_type_in_hand(/obj/item/pen/fancy/satan))
			return
		else if (isdiabolical(user))
			if (M == user)
				boutput(user, "<span class='notice'>You can't sell your soul to yourself!</span>")
				return
			else if (!M.literate)
				boutput(user, "<span class='notice'>Unfortunately they don't know how to write. Their signature will mean nothing.</span>")
				return
			else if (src.inuse != 1)
				src.inuse = 1
				M.visible_message("<span class='alert'><B>[user] is guiding [M]'s hand to the signature field of [src]!</B></span>")
				if (!do_mob(user, M, 70)) //150 (or 15 seconds) was way too long to actually be useful
					if (user && ismob(user))
						user.show_text("You were interrupted!", "red")
						src.inuse = 0
						return
				M.visible_message("<span class='alert'>[user] forces [M] to sign [src]!</span>")
				logTheThing("combat", user, M, "forces [M] to sign a [src] at [log_loc(user)].")
				MagicEffect(M, user)
				SPAWN_DBG(1 DECI SECOND)
					src.inuse = 0
					soulcheck(user)
		else
			return

	attackby(obj/item/W as obj, mob/user as mob)
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
				SPAWN_DBG(1 DECI SECOND)
					soulcheck(src.merchant)
			else
				user.visible_message("<span class='alert'><b>[user] looks puzzled as [he_or_she(user)] realizes [his_or_her(user)] pen isn't evil enough to sign [src]!</b></span>")
				return
		else
			return

obj/item/contract/satan
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read."
	limiteduse = 1
	contractlines = 2 //I'm not sure about this one, might be okay to leave it at 3.

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.satanclownize()
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/macho
	desc = "A contract that promises to bestow upon whomever signs it everlasting machismo, drugs, and some other stuff you can't be bothered to read."
	contractlines = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.machoize(1)
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/wrestle
	desc = "A contract that promises to bestow upon whomever signs it athletic prowess, showmanship, and some other stuff you can't be bothered to read."
	limiteduse = 1
	contractlines = 2 //addiction is crippling, but surmountable. Should not be 3.

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.mind.special_role = "Faustian Wrestler"
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
			user.changeStatus("stunned", 1000)
			ticker.mode.Agimmicks.Add(user)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/yeti
	desc = "A contract that promises to bestow upon whomever signs it near infinite power, an unending hunger, and some other stuff you can't be bothered to read."
	limiteduse = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.makesuperyeti()
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/genetic
	desc = "A contract that promises to unlock the hidden potential of whomever signs it."
	limiteduse = 0

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("activator", 0, 0, 1)
			user.bioHolder.AddEffect("mutagenic_field", 0, 0, 1)
			boutput(user, "<span class='success'>You have finally achieved your full potential! Mom would so proud!</span>")
			if ((prob(5)) || (src.limiteduse == 1))
				SPAWN_DBG(1 SECOND)
					boutput(user, "<span class='success'>You feel an upwelling of additional power!</span>")
					user:unkillable = 1
					user.bioHolder.AddEffect("mutagenic_field_prenerf", 0, 0, 1)
					SPAWN_DBG(0.2 SECONDS)
						boutput(user, "<span class='success'>You have ascended beyond mere humanity!</span>")
						user.mind.special_role = "Genetic Demigod"
						ticker.mode.Agimmicks.Add(user)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/genetic/demigod
	limiteduse = 1

obj/item/contract/horse
	name = "eldritch tome"
	desc = "An ancient tome filled with nearly indecipherable scrawl. You can just barely make out something about horses, signatures, and souls. It seems like it might be some kind of bizarre doomsday prophecy."
	icon_state = "necrobook"
	item_state = "spellbook"

	attack_self(mob/user as mob)
		if((ishuman(user)) && (isdiabolical(user)))
			if (total_souls_value >= 20) //20 souls needed to start the end-times. Sufficiently difficult?
				boutput(user, "<span class='alert'><font size=6><B>NEIGH!</b></font></span>")
				src.endtimes()
				SPAWN_DBG(1 DECI SECOND)
					soulcheck(user)
				return
			else
				boutput(user, "<span class='alert'><font size=3><B>You currently have [total_souls_value] souls. You need 20 soul points to begin the end times. </b></font></span>")
		else
			boutput(user, "<span class='notice'>Nothing happens.</span>")

	proc/endtimes()
		total_souls_value -= 20
		SPAWN_DBG(0)
			var/turf/spawn_turf = get_turf(src)
			new /obj/effects/ydrone_summon/horseman(spawn_turf)

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.horse()
			user.traitHolder.addTrait("soggy")
			boutput(user, "<span class='alert'><font size=6><B>NEIGH</b></font></span>")
			user.mind.special_role = "Faustian Horse"
			ticker.mode.Agimmicks.Add(user)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/mummy
	desc = "A contract that promises to turn whomever signs it into a mummy. That's it. No tricks."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
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
		if (src.limiteduse == 1)
			src.used++
			tooltip_rebuild = 1
			SPAWN_DBG(0)
				if (src.used >= src.contractlines)
					src.vanish(user, badguy)
		return 1

obj/item/contract/mummy/thorough
	limiteduse = 1

obj/item/contract/vampire
	desc = "A contract that promises to bestow upon whomever signs it near immortality, great power, and some other stuff you can't be bothered to read. There's some warning about not using this one in the chapel written on the back."
	limiteduse = 1
	contractlines = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.mind.special_role = "vampire"
			user.make_vampire(1)
			ticker.mode.Agimmicks.Add(user)
			boutput(user, "<span style=\"color:red; font-size:150%\"><b>Note that you are not an antagonist (unless you were already one), you simply have some of the powers of one.</b></span>")
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/juggle
	desc = "It's a piece of paper with a portait of a person juggling skulls. Something about this image is both vaguely familiar and deeply unsettling."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("juggler", 0, 0, 1)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/fart
	desc = "It's just a piece of paper with the word 'fart' written all over it."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("linkedfart", 0, 0, 1)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/bee
	desc = "This contract promises to bestow bees upon whomever signs it. Unlimited bees."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_bee", 0, 0, 1)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/rested
	desc = "This contract promises to keep whomever signs it healthy and well rested."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_pentetic", 0, 0, 1)
			user.bioHolder.AddEffect("regenerator_super", 0, 0, 1)
			user.bioHolder.AddEffect("narcolepsy_super", 0, 0, 1) //basically, the signer's very vulnerable but exceptionally difficult to actually kill.
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/reversal
	desc = "This contract promises to make the strong weak and the weak strong."
	limiteduse = 1
	contractlines = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("breathless_contract", 0, 0, 1)
			user.traitHolder.addTrait("reversal")
			boutput(user, "<span class='notice'>You feel like you could take a shotgun blast to the face without getting a scratch on you!</span>")
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/chemical
	desc = "This contract is adorned with a crude drawing of a werewolf imploding into a pile flaming spiders. What the hell?"

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			user.bioHolder.AddEffect("drunk_random", 0, 0, 1)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/hair
	desc = "This contract promises to make the undersigned individual have the best hair of anybody within 10 kilometers."
	limiteduse = 1
	contractlines = 1

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			for(var/mob/living/carbon/human/H in mobs)
				if (H == user || isdiabolical(H))
					continue
				else
					H.bioHolder.mobAppearance.customization_first = "None"
					H.bioHolder.mobAppearance.customization_first_original = "None"
					H.bioHolder.mobAppearance.customization_second = "None"
					H.bioHolder.mobAppearance.customization_second_original = "None"
					H.bioHolder.mobAppearance.customization_third = "None"
					H.bioHolder.mobAppearance.customization_third_original = "None"
					H.update_colorful_parts()
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1

obj/item/contract/greed
	desc = "This contract is positively covered in dollar signs."

	MagicEffect(var/mob/user as mob, var/mob/badguy as mob)
		if(!..())
			return 0
		SPAWN_DBG(1 DECI SECOND)
			var/obj/item/spacecash/random/tourist/S = unpool(/obj/item/spacecash/random/tourist)
			S.setup(user.loc)

			boutput(user, "<span class='notice'>Some money appears at your feet. What, did you expect some sort of catch or trick?</span>")
			var/wealthy = rand(1,2)
			if (wealthy == 1)
				SPAWN_DBG(10 SECONDS)
					boutput(user, "<span class='notice'>What, not enough for you? Fine.</span>")
					var/turf/T = get_turf(user)
					if (T)
						playsound(user.loc, "sound/misc/coindrop.ogg", 100, 1)
						new /obj/item/coin(T)
						for (var/i = 1; i<= 8; i= i*2)
							if (istype(get_turf(get_step(T,i)),/turf/simulated/floor))
								new /obj/item/coin (get_step(T,i))
							else
								new /obj/item/coin(T)
			if (wealthy == 2)
				SPAWN_DBG(10 SECONDS)
					boutput(user, "<span class='notice'>Well, you were right.</span>")
					var/mob/living/carbon/human/H = user
					H.become_gold_statue(1)
			if (src.limiteduse == 1)
				src.used++
				tooltip_rebuild = 1
				SPAWN_DBG(0)
					if (src.used >= src.contractlines)
						src.vanish(user, badguy)
			else
				return
		return 1
