//scroll used to take on zoldorf's curse
/obj/item/zolscroll //the contract people sign to become zoldorf. stores the name of the signer so players cant sell someone elses soul in a forced zoldorfing
	name = "weird burrito"
	desc = "Hmmm...It's a burrito with no filling and the texture of old parchment."
	icon = 'icons/obj/zoldorf.dmi'
	inhand_image_icon = 'icons/obj/zoldorf.dmi'
	icon_state = "scrollclosed"
	item_state = "scroll"
	var/signer

	attack_self(mob/user as mob)
		if(src.icon_state == "scrollclosed")
			src.name = "demonic contract?"
			src.icon_state = "scrollopen"
			src.desc = "This is one WEIRD burrito..."

	attackby(obj/item/weapon, mob/user)
		if(istype(weapon, /obj/item/pen) && src.icon_state=="scrollopen")
			user.visible_message("<span class='alert'><b>[user.name] stabs themself with the [weapon] and starts signing the contract in blood!</b></span>","<span class='alert'><b>You stab yourself with the [weapon] and start signing the contract in blood!</b></span>")
			playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
			take_bleeding_damage(user, null, 10, DAMAGE_STAB)
			src.icon_state = "signing"
			if (do_after(user, 4.6 SECONDS))
				user.visible_message("<span class='alert'><b>[user.name] finishes signing the contract in blood!</b></span>","<span class='alert'><b>You finish signing the contract in blood!</b></span>")
				src.signer = user.real_name
				src.name = "[user.real_name]'s signed demonic contract"
				src.icon_state = "signed"
			else
				src.icon_state = "scrollopen"

	attack(mob/user, mob/target)
		if((user == target)&&(src.icon_state == "scrollclosed"))
			user.visible_message("<span class='alert'><b>[user.name] bites into the [src]. They didn't seem to enjoy it.</b></span>","<span class='alert'><b>Blegh! This doesn't taste like a burrito!</b></span>")

//fortunes from player zoldorfs
/obj/item/paper/thermal/playerfortune
	name = "fortune"
	desc = "Learn your fate!"
	var/branded
	var/referencedorf

	examine()
		. = ..()

		if((src.branded)&&(src.referencedorf))
			if(istype(src.referencedorf,/obj/machinery/playerzoldorf) && (istype(usr,/mob/living/carbon/human)))
				var/obj/machinery/playerzoldorf/pz = src.referencedorf
				var/mob/living/carbon/human/user = usr
				if(!(usr in pz.brandlist))
					pz.brandlist.Add(user)
					src.icon_state = ("fortunepaper")
					user.visible_message("<span class='success'><b>[user.name]'s skin seems to glow faintly.</b></span>","<span class='success'><b>You feel an otherworldly presence coursing through you!</b></span>")
					. += "<span class='success'><b>Tip:</b> This will allow the zoldorf player to observe you like a ghost, if you wish to remain unseen, splashing yourself with holy water will clear the brand.</span>"
					if(the_zoldorf.len)
						boutput(the_zoldorf[1],"<span class='notice'><b>[user.name] has been branded!</b> You may now observe them via Astral Projection.</span>")
					src.branded = 0

			else if (istype(src.referencedorf,/obj/machinery/playerzoldorf) && (istype(usr,/mob/zoldorf)))
				. += "<span class='success'><b>This fortune is branded!</b></span>"

//Totally Normal Deck of Cards (TM)
/obj/item/zoldorfdeck //deck of many things code is a bit messy, but the deck stores the card information and player interaction, the card item stores the effects passed to them by the deck
	name = "Deck of Cards"
	desc = "Wow. These look creepy..."
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "deck1"
	w_class = W_CLASS_TINY
	var/inuse = 0
	var/nextcard
	var/can_move = 1

	var/list/cards = list("Unbalance","Freeze","Security","Discount Dan","Admin","Syndicate Operative","Robusted","Quartermaster"\
	,"Cluwne","Clown","Armory","Bee","Head of Personnel","Traitor","Roboticist","Crusher","Geneticist","Scientist","Staff Assistant"\
	,"Captain","Wizard","Rajaijah")

	var/list/usedcards = list()

	proc/inventorycheck(mob/user as mob)
		if((src in user.contents) && (src.inuse == 1))
			return 1
		else if(src.inuse == 0)
			return 2
		else
			return 0

	proc/carddraw(mob/user as mob, var/cardnumber = 1) //lots of checks to make sure players arent trying to abuse the system, so the thing is extremely volatile...
		src.inuse = 1
		var/cardname
		var/invcheck = inventorycheck(user)
		for(var/i=1,i<=cardnumber,i++)
			if(invcheck == 2)
				return
			else if(invcheck == 0)
				src.set_loc(user.loc)
				src.inuse = 0
				user.gib(1)
				return
			if(nextcard)
				cardname = nextcard
				nextcard = null
			else
				cardname = pick(cards)
			cards -= cardname
			if(cardname != "Head of Personnel")
				usedcards += cardname
			if(cards.len == 11)
				src.icon_state = "deck2"
			if(cards.len == 5)
				src.icon_state = "deck3"
			var/obj/item/zoldorfcard/card = new /obj/item/zoldorfcard
			user.put_in_hand_or_drop(card)
			var/buffer = card.effect(cardname,user,src)
			if(buffer != 0)
				var/list/bufferlist = buffer
				if(bufferlist[1] == 0)
					cardnumber = i
				else
					cardnumber += bufferlist[1]
					qdel(bufferlist[2])
			if(cards.len == 0)
				src.inuse = 0
				for(var/atom/movable/AM in contents)
					AM.set_loc(get_turf(src))
				qdel(src)

	attack_hand(mob/user)
		if(src.loc != user)
			..()
			return
		src.inuse = 1
		var/cardnumber
		var/invcheck = inventorycheck(user)
		cardnumber = input("How many cards would you like to draw?","Cards to Draw",null) as null|num //check if number works
		if(!user || !invcheck || !cardnumber || !isnum_safe(cardnumber))
			src.inuse = 0
			return
		if(cardnumber < 0)
			cardnumber = 0
		else if(cardnumber > cards.len)
			cardnumber = length(cards)
		carddraw(user, cardnumber)
		src.inuse = 0

	attack_self(mob/user as mob)
		var/extradraw = carddraw(user)
		while(extradraw)
			if(extradraw > 1)
				carddraw(user,1,extradraw,1)
			else if(extradraw == 1)
				extradraw = carddraw(user)
		src.inuse = 0


	dropped(mob/user as mob) //volatility 100
		..()

		SPAWN(0.1 SECONDS)
			if(src.loc != user)
				if(src.inuse)
					src.inuse = 0
					user.gib(1)

	relaymove(var/mob/user, direction)
		if(can_move&&(!istype(src.loc,/obj)&&(!istype(src.loc,/mob))))
			can_move = 0
			SPAWN(1 SECOND)
				can_move = 1
			step(src,direction)
		return

	ex_act(var/severity)
		return

	disposing()
		for(var/mob/m in src.contents)
			m.set_loc(get_turf(src.loc))
		..()

/obj/item/zoldorfcard //pretty much a carrier item for card effects, though some cards persist while their prompts are active or for use later.
	name = "placeholder"
	desc = "A super creepy looking card"
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "clown"

	var/fateseffect

	proc/effect(var/cardname, mob/living/carbon/user as mob, var/obj/item/zoldorfdeck/deck)
		src.name = cardname
		var/redraw
		var/reference
		var/keep
		var/list/returnlist = list()
		boutput(user,"<span class='success'><b>You have drawn the [cardname]!</b></span>")
		if(cardname == "Head of Personnel")
			src.icon_state = "hop"
			var/yn = tgui_alert(user, "Do you wish to repeat an effect of an already drawn card or cancel your queued draws?", "Choice", list("Repeat", "Cancel"))
			if(!yn)
				yn = pick("Repeat","Cancel")
			if(yn == "Repeat")
				var/repeat = input(user,"Choose a card!","Choice") as anything in deck.usedcards
				if(!deck.usedcards.len)
					boutput(user,"<span class='alert'><b>There are no card effects to be repeated!</b></span>")
				if(!repeat)
					repeat = pick(deck.usedcards)
				else
					cardname = repeat
		switch(cardname)
			if("Unbalance")
				if(istype(user,/mob/living))
					var/mob/living/h = user
					h.change_misstep_chance(35)
			if("Freeze")
				if(istype(user,/mob/living/carbon/human))
					var/mob/living/carbon/human/h = user
					deck.inuse = 0
					user.u_equip(deck)
					deck.set_loc(get_turf(user))
					h.become_statue_ice()
				else
					user.reagents.add_reagent("cryostylane", 50)
			if("Security")
				boutput(user,"<span class='alert'><b>OH GOD THE DECK SUCKS YOU IN!</b></span>")
				deck.inuse = 0
				user.u_equip(deck)
				deck.set_loc(get_turf(user))
				user.set_loc(deck)
			if("Discount Dan")
				var/mob/living/carbon/h = user
				h.add_stam_mod_max("domt", -100)
			if("Admin")
				src.icon_state = "admin"
				fateseffect = get_turf(user)
				src.desc = "A unique card allowing the user to teleport back to the location it was drawn, but only once!"
				keep = 1
			if("Syndicate Operative")
				user.reagents.add_reagent("saxitoxin", 50)
				qdel(src)
			if("Robusted")
				user.TakeDamage("head",user.max_health)
				boutput(user,"<span class='alert'><b>You are forced to draw again!</b></span>")
				redraw = 1
				reference = src
			if("Quartermaster")
				var/obj/item/spacecash/money = new /obj/item/spacecash(get_turf(src),25000)
				user.put_in_hand_or_drop(money)
			if("Cluwne")
				user.contract_disease(/datum/ailment/disease/cluwneing_around,null,null,1)
			if("Clown")
				var/input = tgui_alert(user, "Would you prefer to learn the secrets of the clown or the secret to clown immunity?", "Choice", list("Clown", "Immunity"))
				if(!input)
					input = pick("Clown","Immunity")
				if(input == "Clown")
					if(istype(user,/mob/living/carbon/human))
						var/mob/living/carbon/human/h = user
						h.can_juggle = 1
						boutput(user,"<span class='success'>You feel the clown energy surround you. You now know how to juggle!</span>")
					else
						boutput(user,"<span class='success'>Hmmm...Your body doesn't seem suited for juggling. Here's a bike horn instead.</span>")
						user.put_in_hand_or_drop(new /obj/item/instrument/bikehorn)
				else if(input == "Immunity")
					boutput(user,"<span class='success'>You will never slip again!</span>")
					user.put_in_hand_or_drop (new /obj/item/clothing/shoes/sandal)
				input = tgui_alert(user, "Do you wish to draw two more cards?", "Choice", list("Yes", "No"))
				if(!input)
					input = "No"
				if (input == "Yes")
					boutput(user,"<span class='alert'><b>You draw twice more!</b></span>")
					redraw = 2
					reference = src
			if("Armory")
				user.put_in_hand_or_drop(new /obj/item/gun/energy/egun)
			if("Bee")
				var/obj/critter/domestic_bee/queen/q = new /obj/critter/domestic_bee/queen
				q.beeMom = user
				q.beeMomCkey = ckey(user.name)
				q.name = "[user.real_name]'s loyal guardian"
				q.set_loc(get_turf(user))
			if("Head of Personnel")
				src.icon_state = "hop"
				redraw = 0
				reference = src
			if("Traitor")
				var/list/buylist = concrete_typesof(/datum/syndicate_buylist)
				var/datum/syndicate_buylist/thing = pick(buylist)
				var/datum/syndicate_buylist/thing2 = new thing
				if(thing2.item != null)
					user.put_in_hand_or_drop(new thing2.item)
				else
					boutput(user,"<span class='alert'>Hmmm...The card seems to have shorted out.</span>")
				qdel(thing2)
			if("Roboticist")
				user.contract_disease(/datum/ailment/disease/robotic_transformation,null,null,1)
			if("Crusher")
				deck.inuse = 0
				user.u_equip(deck)
				deck.set_loc(get_turf(user))
				logTheThing(LOG_COMBAT, user, "was gibbed by Zoldorf's crusher card at [log_loc(user)].")
				user.gib(1)
			if("Geneticist")
				var/list/effectpool = list("xray","hulk","breathless","thermal_resist","regenerator","detox")
				user.bioHolder.AddEffect(pick(effectpool))
			if("Scientist")
				var/list/loot = list("implant","pack","oxy","med")
				var/result = pick(loot)

				switch(result)
					if("implant")
						user.put_in_hand_or_drop(new /obj/item/implant/robust)
					if("pack")
						var/obj/item/storage/fanny/pack = new /obj/item/storage/fanny
						new /obj/item/crowbar(pack)
						new /obj/item/screwdriver(pack)
						new /obj/item/wirecutters(pack)
						new /obj/item/wrench(pack)
						new /obj/item/weldingtool(pack)
						new /obj/item/device/multitool(pack)
						user.put_in_hand_or_drop(pack)
					if("oxy")
						user.put_in_hand_or_drop(new /obj/item/tank/emergency_oxygen)
					if("med")
						user.put_in_hand_or_drop(new /obj/item/storage/firstaid/regular)
			if("Staff Assistant")
				for (var/obj/item/W in user)
					if ((istype(W, /obj/item/parts) && W:holder == user) || istype(W,/obj/item/zoldorfdeck) || (W == src) || istype(W,/obj/item/organ) || istype(W,/obj/item/skull))
						continue
					user.u_equip(W) //flashlight modules in pdas error for some reason when deleted by this
					qdel(W)
			if("Captain")
				user.put_in_hand_or_drop(new /obj/item/card/id/captains_spare)
			if("Wizard")
				if(deck.cards)
					deck.nextcard = pick(deck.cards)
					boutput(user,"<span class='success'>You divine that the next card will be the [deck.nextcard]!</span>")
				else
					boutput(user,"<span class='success'>You divine that there are no cards left in the deck! Wow!</span>")
			if("Rajaijah")
				user.take_brain_damage(50)
				var/mob/living/carbon/human/H = user
				if(istype(H))
					H.ai_init()
					H.ai_aggressive = 1
				user.u_equip(deck)
				deck.set_loc(get_turf(user))

		if(redraw)
			returnlist.Add(redraw)
			returnlist.Add(reference)
			user.u_equip(src)
			return returnlist
		else
			if(keep == 1)
				return 0
			user.u_equip(src)
			qdel(src)
			return 0


	attack_self(mob/user as mob)
		if(src.fateseffect)
			user.u_equip(src)
			user.set_loc(fateseffect)
			elecflash(user)
			qdel(src)

/obj/item/zspellscroll //speeeeells //there arent that many so i pretty much just packed it into a single item type
	name = "spell scroll"
	desc = ""
	icon = 'icons/obj/zoldorf.dmi'
	inhand_image_icon = 'icons/obj/zoldorf.dmi'
	icon_state = "scrollclosed"
	item_state = "scroll"
	burn_point = 220
	burn_output = 9
	burn_possible = 1
	var/scrolltype
	var/hat
	var/obj/item/hatstorage
	var/mob/hatuser
	var/used = 0

	attack_self(mob/user as mob)
		switch(src.icon_state)
			if("scrollred")
				src.icon_state = "animred"
				sleep(1.1 SECONDS)
				src.icon_state = "scrollclosed"
			if("scrollblue")
				src.icon_state = "animblue"
				sleep(1.1 SECONDS)
				src.icon_state = "scrollclosed"
			if("scrollpurple")
				src.icon_state = "animpurple"
				sleep(1.1 SECONDS)
				src.icon_state = "scrollclosed"
			if("scrollclosed")
				switch(src.scrolltype)
					if("demon")
						src.icon_state = "demon"
						src.name = "Scroll of Summon Lesser Demon"
					if("presto")
						src.icon_state = "presto"
						src.name = "Scroll of Presto!"
					if("hat")
						src.hat = 1
						src.icon_state = "hat"
						src.name = "Scroll of Magician's Hat Trick"
			if("demon")
				if(src.used)
					return
				src.used = 1
				user.u_equip(src)
				src.set_loc(user) //while spell effects resolve, i temporarily stick them inside the player and delete them later in case of lag or need for the item to stick around longer (i.e. hat trick)
				user.visible_message("<span class='alert'><b>[user.name] opens a portal to hell! Oh GOD! SOMETHING IS COMING! ITS! a securitron?</b></span>","<span class='alert'><b>The scroll burns in your hands and a portal to the depths of insanity manifests itself. A Lesser Demon is brought forth from hell.</b></span>")
				var/obj/machinery/bot/secbot/bot = new /obj/machinery/bot/secbot
				bot.name = "Lesser Demon"
				bot.desc = "If they weren't demonic enough already..."
				bot.hat = "that"
				bot.set_loc(get_turf(user))
			if("presto")
				if(src.used)
					return
				src.used = 1
				user.u_equip(src)
				src.set_loc(user)
				if(!isturf(user.loc))
					boutput(user,"<span class='alert'>You cannot cast this spell here!</span>")
					return
				if(isrestrictedz(user.z))
					boutput(user, "<span class='alert'>You are suddenly zapped apart!</span>")
					logTheThing(LOG_COMBAT, user, "was gibbed for trying to use Zoldorf's presto scroll at [log_loc(user)].")
					user.gib()

				var/list/randomturfs = new/list()
				for(var/turf/T in orange(user, 10))
					if(istype(T, /turf/space) || T.density)
						continue
					randomturfs.Add(T)
				if(randomturfs.len > 0)
					boutput(user, "<span class='alert'>You are suddenly zapped away elsewhere!</span>")
					user.set_loc(pick(randomturfs))
					elecflash(user)
			if("hat")
				boutput(user,"<span class='success'>You must strike a tiny-normal item with the scroll!</span>")

	afterattack(atom/target as obj, mob/user as mob)
		if(src.hat && istype(target,/obj/item) && (!istype(target,/obj/item/device/radio/intercom)) && (!src.used))
			var/obj/item/titem = target
			if(titem.w_class <= W_CLASS_SMALL)
				src.used = 1
				src.health = 5
				if(titem.loc == user)
					user.u_equip(titem)
				src.hatstorage = titem
				titem.set_loc(src)
				src.hatuser = user
				user.visible_message("<span class='alert'><b>The [target.name] disappears! Wow!</b></span>")
				user.u_equip(src)
				src.set_loc(user)
				sleep(10 SECONDS)
				if(!user)
					return
				if(istype(user, /mob/living/carbon/human))
					var/mob/living/carbon/human/h = user
					if(h.head)
						src.hatuser.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Magic!</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat!</b></span>")
					else
						src.hatuser.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Wait...Where did they get the hat?</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat! Wait...Where did you get the hat?</b></span>")
					h.equip_if_possible(new /obj/item/clothing/head/that(h), h.slot_head)

				else
					user.put_in_hand_or_drop(new /obj/item/clothing/head/that)
					user.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Wait...Where did they get the hat?</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat! Wait...Where did you get the hat?</b></span>")
				src.hatstorage.set_loc(get_turf(hatuser))

				src.hatuser = null
				src.hat = null
				src.hatstorage = null
			else
				boutput(user,"<span class='alert'>This item is too big!</span>")

	disposing()
		if(src.hat && src.hatstorage && src.hatuser)
			if(istype(src.hatuser, /mob/living/carbon/human))
				var/mob/living/carbon/human/h = src.hatuser
				if(h.head)
					src.hatuser.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Magic!</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat!</b></span>")
				else
					src.hatuser.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Wait...Where did they get the hat?</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat! Wait...Where did you get the hat?</b></span>")
				h.equip_if_possible(new /obj/item/clothing/head/that, h.slot_head)
			else
				src.hatuser.put_in_hand_or_drop(new /obj/item/clothing/head/that)
				src.hatuser.visible_message("<span class='alert'><b>The [src.hatstorage] tumbles out of [src.hatuser.name]'s hat! Wait...Where did they get the hat?</b></span>","<span class='alert'><b>The [src.hatstorage] tumbles out of your hat! Wait...Where did you get the hat?</b></span>")
			src.hatstorage.set_loc(get_turf(src.hatuser))
		..()

/obj/item/zspellscroll/demon
	icon_state = "scrollred"
	scrolltype = "demon"

/obj/item/zspellscroll/presto
	icon_state = "scrollblue"
	scrolltype = "presto"

/obj/item/zspellscroll/hat
	icon_state = "scrollpurple"
	scrolltype = "hat"
