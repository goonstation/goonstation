#define MAX_DICE_GROUP 6
var/list/rollList = list()

/obj/item/dice
	name = "die"
	desc = "A six-sided die."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "d6_6"
	throwforce = 0
	w_class = W_CLASS_TINY
	stamina_damage = 0
	stamina_cost = 0
	var/sides = 6
	var/last_roll = null
	var/can_have_pals = 1
	var/list/obj/item/dice/dicePals = list() // for combined dice rolls, up to 9 in a stack
	var/sound_roll = 'sound/items/dicedrop.ogg'
	var/icon/paloverlay
	var/image/paloverlayimage
	var/icon/decoyimageicon //magic trick part 1
	var/image/decoyimage //it was a trick. the whole time *giggles in coder language*
	var/colorcache
	var/loadnumber
	var/loadprob
	var/mob/living/carbon/human/hitmob
	rand_pos = 1
	var/initialName = "die"
	var/initialDesc = "A six-sided die."

	New()
		..()
		SPAWN(0)
			initialName = name
			initialDesc = desc

	get_desc()
		if (src.last_roll && !length(src.dicePals))
			if (isnum(src.last_roll))
				. += "<br>[src] currently shows [get_english_num(src.last_roll)]."
			else
				. += "<br>[src] currently shows [src.last_roll]."

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] attempts to swallow [src] and chokes on it.</b>"))
		user.take_oxygen_deprivation(160)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/roll_dat_thang() // fine if I can't use proc/roll() then we'll all just have to suffer this
		if (ON_COOLDOWN(src,"roll", 3 SECONDS))
			return
		var/roll_total = null

		if (src.sound_roll)
			playsound(src, src.sound_roll, 50, 1)

		if (!src.cant_drop)
			if (!src.cant_drop && ismob(src.loc))
				var/mob/user = src.loc
				user.u_equip(src)
			src.set_loc(get_turf(src))
			src.pixel_y = rand(-8,8)
			src.pixel_x = rand(-8,8)

		src.name = initialName
		src.desc = initialDesc
		if(src.colorcache)
			src.color = src.colorcache
			src.colorcache = null
		src.ClearAllOverlays()

		if (src.sides && isnum(src.sides))
			if(src.loadprob && src.loadnumber && prob(src.loadprob)) //important for loading dice
				src.last_roll = src.loadnumber
				if(prob(33))
					src.visible_message(SPAN_ALERT("<b>Something wasn't right about that roll...</b>"))
			else
				src.last_roll = rand(1, src.sides)
			roll_total = src.last_roll
			rollList.Add(list(list("sides"=src.sides,"roll"=src.last_roll,"color"=src.color))) //need a check for dice without a color
			if(src.sides == 6)
				src.icon_state = "d6_[src.last_roll]"

#ifdef HALLOWEEN
			if (last_roll == 13 && prob(5))
				var/turf/T = get_turf(src)
				var/area/tarea = get_area(T)
				for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
					if (get_area(apc) != tarea)
						continue
					apc.overload_lighting()

				playsound(T, 'sound/effects/ghost.ogg', 75, FALSE)
				new /obj/critter/bloodling(T)
#endif

		else if (src.sides && islist(src.sides) && src.sides:len)
			src.last_roll = pick(src.sides)
			src.visible_message("[src] shows <i>[src.last_roll]</i>.")
		else
			src.last_roll = null
			src.visible_message("[src] shows... um. Something. It hurts to look at. [pick("What the fuck?", "You should probably find the chaplain.")]")
		tooltip_rebuild = TRUE
		if (src.dicePals.len)
			shuffle_list(src.dicePals) // so they don't all roll in the same order they went into the pile
			for (var/obj/item/dice/D in src.dicePals)
				if (!D.cant_drop)
					D.set_loc(get_turf(src))
				if (prob(75))
					step_rand(D)
				roll_total += D.roll_dat_thang()
			for (var/i= src.dicePals.len, i > 0, i--)
				src.UpdateOverlays(null, "die[i]")
				src.dicePals = list()
		return roll_total

	proc/load()
		if(!(istype(src,/obj/item/dice/coin))&&!(istype(src,/obj/item/dice/magic8ball)))
			if(src.loadnumber && src.loadprob)
				return
			if(src.last_roll)
				src.loadnumber = src.last_roll
			else
				switch(src.type)
					if(/obj/item/dice/d4)
						src.loadnumber = 4
					if(/obj/item/dice/d8)
						src.loadnumber = 8
					if(/obj/item/dice/d10)
						src.loadnumber = 10
					if(/obj/item/dice/d12)
						src.loadnumber = 12
					if(/obj/item/dice/d20)
						src.loadnumber = 20
					if(/obj/item/dice/d100)
						src.loadnumber = 100
					if(/obj/item/dice)
						src.loadnumber = 6
			src.loadprob = rand(10,33)

	proc/addPal(var/obj/item/dice/Pal, var/mob/user as mob)
		if (!Pal || Pal == src || !istype(Pal, /obj/item/dice) || (src.dicePals.len + Pal.dicePals.len) >= MAX_DICE_GROUP)
			return 0
		if (!src.can_have_pals || !Pal.can_have_pals)
			return 0
		if (Pal.stored)
			return 0

		src.dicePals += Pal

		if (Pal.dicePals.len)

			for (var/obj/item/dice/D in Pal.dicePals)
				if (D.stored)
					Pal.dicePals -= D
					continue
				if (ismob(D.loc))
					D.loc:u_equip(D)
				D.set_loc(src)

		else
			initialName = name
			initialDesc = desc
		if (ismob(Pal.loc))
			Pal.loc:u_equip(Pal)
		Pal.set_loc(src)

		if(length(src.dicePals) == 1) //magic trick time
			src.colorcache = src.color //removes src color, then overlays a decoy image to make the icon look unchanged
			src.color = null
			src.decoyimageicon = new /icon(src.icon,src.icon_state)
			if(src.colorcache)
				decoyimageicon.Blend(src.colorcache, ICON_MULTIPLY)
			src.decoyimage = image(decoyimageicon)
			src.UpdateOverlays(src.decoyimage,"0") //dats a zero :P

		if(Pal.dicePals.len)
			if(Pal.colorcache) //beginning of pal overlay clear
				Pal.color = Pal.colorcache
				Pal.colorcache = null

		src.paloverlay = new /icon(Pal.icon,Pal.icon_state)
		if((Pal.color)&&(Pal.color != "null"))
			paloverlay.Blend(Pal.color, ICON_MULTIPLY)
		src.paloverlayimage = image(src.paloverlay)
		src.paloverlayimage.pixel_y = Pal.pixel_y
		src.paloverlayimage.pixel_x = Pal.pixel_x
		src.UpdateOverlays(src.paloverlayimage,"[src.dicePals.len]")
		src.name = "bunch of dice"
		src.desc = "Some dice, bunched up together and ready to be thrown."
		if(Pal.dicePals.len)
			src.dicePals |= Pal.dicePals // |= adds things to lists that aren't already present

			var/startoverlay = length(src.overlays)
			var/endoverlay = (src.overlays.len-1)+(Pal.overlays.len-1)

			for(var/i=startoverlay, i<=endoverlay, i++) //src.overlays.len will return dice position + 1 as the decoy overlay will be registered
				src.paloverlay = new /icon(Pal.dicePals[1].icon,Pal.dicePals[1].icon_state)
				if((Pal.dicePals[1].color)&&(Pal.dicePals[1].color != "null"))
					paloverlay.Blend(Pal.dicePals[1].color, ICON_MULTIPLY)
				src.paloverlayimage = image(src.paloverlay)
				Pal.dicePals[1].pixel_y = rand(-8,8)
				Pal.dicePals[1].pixel_x = rand(-8,8)
				src.paloverlayimage.pixel_y = Pal.dicePals[1].pixel_y
				src.paloverlayimage.pixel_x = Pal.dicePals[1].pixel_x
				src.UpdateOverlays(src.paloverlayimage,"[i]")
				Pal.dicePals -= Pal.dicePals[1]

			Pal.ClearAllOverlays()
			Pal.name = initial(Pal.name)
			Pal.desc = initial(Pal.desc)
			Pal.dicePals = list()
		return 1
	proc/diceInChat(var/privateroll=0,var/list/localrolls=rollList)
		var/htmlstring = "<span>"
		var/icon/dieType
		var/icon/diePng
		var/offset = 0
		var/total = 0
		for(var/i=1, i<=localrolls.len, i++)
			offset = 12
			switch(localrolls[i]["sides"])
				if(4)
					dieType = "d4"
				if(6)
					dieType = "d6"
				if(8)
					dieType = "d8"
				if(10)
					dieType = "d10"
				if(12)
					dieType = "d12"
				if(20)
					dieType = "d20"
				if(100)
					dieType = "d100"
			if(!(localrolls[i]["roll"] > 0))
				src.visible_message("<span><b>[usr.name]'s Roll:</b></span>")
			if((localrolls[i]["roll"] > 9) && (localrolls[i]["roll"] < 100))
				offset = 7
			else if(localrolls[i]["roll"] >= 100)
				offset = 4
			else if((localrolls[i]["roll"] == 4) && (dieType == "d4"))
				offset = 11
			diePng = new /icon('icons/obj/dicechat.dmi',dieType)
			if((localrolls[i]["color"])&&(localrolls[i]["color"]!="null"))
				diePng.Blend(localrolls[i]["color"], ICON_MULTIPLY)
			htmlstring += "<div style=\"position:relative;text-align:center;color:black;display:inline-block;\"><img src=\"data:image/png;base64,[icon2base64(diePng)]\" width=\"32\" height=\"32\"><div style=\"position: absolute; top: 7px;left: [offset]px;\"><b>[localrolls[i]["roll"]]</b></div></div>&nbsp;"
			total += localrolls[i]["roll"]
		htmlstring += "</span>"
		if((privateroll==0)&&(total > 0))
			src.visible_message(htmlstring)
			src.visible_message("<span><b>Total: [total]</b></span>")
		else
			return htmlstring


	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/dice))
			if (src.addPal(W, user))
				user.show_text("You add [W] to [src].")
		else
			return ..()

	attack_self(mob/user as mob)
		src.roll_dat_thang()
		diceInChat()
		rollList = list()

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if(istype(hit_atom, /mob))
			if((istype(src, /obj/item/dice/weighted)) && (istype(hit_atom, /mob/living/carbon/human)))
				src.hitmob = hit_atom
			return
		else
			..()
			var/total = src.roll_dat_thang()
			diceInChat()
			rollList = list()
			if((istype(src,/obj/item/dice/weighted)) && (src.hitmob))
				src.hitmob.TakeDamage("head",total/*src.last_roll*/)
				src.hitmob = null

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (src.can_have_pals && istype(O, /obj/item/dice))
			if (src.addPal(O, user))
				user.visible_message("<b>[user]</b> gathers up some dice.",\
				"You gather up some dice.")
				SPAWN(0.2 SECONDS)
					for (var/obj/item/dice/D in range(1, user))
						if (D == src)
							continue
						if (!src.addPal(D, user))
							break
						else
							sleep(0.2 SECONDS)
					return
		else
			return ..()

// /obj/item/dice/Crossed(atom/movable/AM as mob|obj)
// 	if(ismob(AM))
// 		var/mob/M = AM
// 		if(ishuman(M))
// 			var/mob/living/carbon/human/H = M
// 			if(istype(H.mutantrace, /datum/mutantrace/abomination))
// 				return
// 			if(!H.shoes)
// 				if((prob(2))&&(!istype(src,/obj/item/dice/magic8ball))&&(!istype(src,/obj/item/dice/coin)))
// 					H.visible_message(SPAN_ALERT("<B>[H.name] steps on the [src]!</B>"), SPAN_ALERT("<B>You step on the [src]!</B>"))
// 					var/obj/item/affecting = H.organs[pick("l_leg", "r_leg")]
// 					H.weakened = max(3, H.weakened)
// 					affecting.take_damage(5, 0)
// 					H.UpdateDamageIcon()
// 			if((prob(2)) && (H.m_intent != "walk") && (!istype(src,/obj/item/dice/coin)))
// 				H.visible_message(SPAN_ALERT("<B>[H.name] comically slips on the [src]!</B>"), SPAN_ALERT("<B>You comically slip on the [src]!</B>"))
// 				H.weakened = max(2, M.weakened)
// 				H.stunned = max(2, M.stunned)
// 	..()


/obj/item/dice/coin // dumb but it helped test non-numeric rolls
	name = "coin"
	desc = "A little coin that will probably vanish into a couch eventually."
	icon_state = "coin-silver"
	sides = list("heads", "tails")
	sound_roll = 'sound/items/coindrop.ogg'
	can_have_pals = 0

/obj/item/dice/magic8ball // farte
	name = "magic 8 ball"
	desc = "Think of a yes-or-no question, shake it, and it'll tell you the answer! You probably shouldn't use it for playing an actual game of pool."
	icon_state = "8ball"
	can_have_pals = 0
	sides = list("It is certain",\
	"It is decidedly so",\
	"Without a doubt",\
	"Yes definitely",\
	"You may rely on it",\
	"As I see it, yes",\
	"Most likely",\
	"Outlook good",\
	"Yes",\
	"Signs point to yes",\
	"Reply hazy try again",\
	"Ask again later",\
	"Better not tell you now",\
	"Cannot predict now",\
	"Concentrate and ask again",\
	"Don't count on it",\
	"My reply is no",\
	"My sources say no",\
	"Outlook not so good",\
	"Very doubtful")
	sound_roll = 'sound/impact_sounds/Liquid_Slosh_2.ogg'

	addPal()
		return 0

	custom_suicide = 1
	suicide_in_hand = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] drop kicks [src], but it barely moves!</b>"))
		user.visible_message("[src] shows <i>[pick("Goodbye","You done fucked up now","Time to die","Outlook terrible","That was a mistake","You should not have done that","Foolish","Very well")]</i>.")
		if (src.loc == user)
			user.u_equip(src)
			src.layer = initial(src.layer)
			src.set_loc(user.loc)
		SPAWN(1 SECOND)
			user.visible_message(SPAN_ALERT("<b>[user] is crushed into a bloody ball by an unseen force, and vanishes into nothingness!</b>"))
			user.implode()
		return 1

/obj/item/dice/d4
	name = "\improper D4"
	desc = "A tetrahedral die informally known as a D4."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d8
	name = "\improper D8"
	desc = "An octahedral die informally known as a D8."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "\improper D10"
	desc = "A decahedral die informally known as a D10."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d12
	name = "\improper D12"
	desc = "A dodecahedral die informally known as a D12."
	icon_state = "d20"
	sides = 12

/obj/item/dice/d20
	name = "\improper D20"
	desc = "An icosahedral die informally known as a D20."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "\improper D100"
	desc = "It's not so much a die as much as it is a ball with numbers on it."
	icon_state = "d100"
	sides = 100

/obj/item/dice/d100/satan
	name = "Devilish D100"
	desc = "If you're rolling this your life went wrong at some point."
	icon_state = "d100red"

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] attempts to swallow [src] and gets sucked in!</b>"))
		user.mind.damned = 1
		user.implode()
		user.suiciding = 0
		return 1

	roll_dat_thang() // fine if I can't use proc/roll() then we'll all just have to suffer this
		if (ON_COOLDOWN(src,"roll", 3 SECONDS))
			return
		var/roll_total = null

		if (usr.name != "Satan")
			usr.mind.damned = 1

		if (src.sound_roll)
			playsound(src, src.sound_roll, 50, 1)

		if (!src.cant_drop)
			src.set_loc(get_turf(src))
			src.pixel_y = rand(-8,8)
			src.pixel_x = rand(-8,8)

		src.name = initialName
		src.desc = initialDesc

		if (src.sides && isnum(src.sides))
			src.last_roll = rand(1, src.sides)
			roll_total = src.last_roll
			src.visible_message("[src] shows [get_english_num(src.last_roll)].")

#ifdef HALLOWEEN
			if (last_roll == 13 && prob(5))
				var/turf/T = get_turf(src)
				var/area/tarea = get_area(T)
				for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
					if (get_area(apc) != tarea)
						continue
					apc.overload_lighting()

				playsound(T, 'sound/effects/ghost.ogg', 75, FALSE)
				new /obj/critter/bloodling(T)
#endif

		else if (src.sides && islist(src.sides) && src.sides:len)
			src.last_roll = pick(src.sides)
			src.visible_message("[src] shows <i>[src.last_roll]</i>.")
		else
			src.last_roll = null
			src.visible_message("[src] shows... um. Something. It hurts to look at. [pick("What the fuck?", "You should probably find the chaplain.")]")

		if (src.dicePals.len)
			shuffle_list(src.dicePals) // so they don't all roll in the same order they went into the pile
			for (var/obj/item/dice/D in src.dicePals)
				if (!D.cant_drop)
					D.set_loc(get_turf(src))
				if (prob(75))
					step_rand(D)
				roll_total += D.roll_dat_thang()
			for (var/i= src.dicePals.len, i > 0, i--)
				src.UpdateOverlays(null, "die[i]")
			src.dicePals = list()
			src.visible_message("<b>The total of all the dice is [roll_total < 999999 ? "[get_english_num(roll_total)]" : "[roll_total]"].</b>")
		return roll_total

/obj/item/dice/d1
	name = "\improper D1"
	desc = "Uh. It has... one side? I guess? Maybe?"
	icon_state = "d6_6"
	sides = 1

/obj/item/dice/weighted
	name = "D6"
	color = "#A3A3A3"

/obj/item/dice/robot
	name = "probability cube"
	desc = "A device for the calculation of random probabilities. Especially ones between one and six."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "d6_6"
	w_class = W_CLASS_TINY
	sides = 6
	can_have_pals = FALSE
	flags = SUPPRESSATTACK

	New()
		..()
		name = "[initial(name)] (d[sides])"
		desc = "A device for the calculation of random probabilities. Especially ones between one and [get_english_num(sides)]."

	attack_self(mob/user)
		var/old_name = src.name
		switch (src.sides)
			if (4)
				src.name = "probability cube (d6)"
				src.sides = 6
				src.icon_state = "d6_6"
			if (6)
				src.name = "probability pentagonal trapezohedron (d10)" // yes, it's actually called that
				src.sides = 10
				src.icon_state = "d20"
			if (10)
				src.name = "probability dodecahedron (d12)"
				src.sides = 12
				src.icon_state = "d20"
			if (12)
				src.name = "probability icosahedron (d20)"
				src.sides = 20
				src.icon_state = "d20"
			if (20)
				src.name = "probability zocchihedron (d100)"
				src.sides = 100
				src.icon_state = "d100"
			else
				src.name = "probability tetrahedron (d4)"
				src.sides = 4
				src.icon_state = "d4"

		src.desc = "A device for the calculation of random probabilities. Especially ones between one and [get_english_num(src.sides)]."
		src.initialName = src.name
		src.initialDesc = src.desc
		src.last_roll = null
		tooltip_rebuild = TRUE

		user.show_text("You reconfigure the [old_name] into a [name].")
		return

	afterattack(atom/target, mob/user, inrange)
		if (!src.cant_drop)
			user.u_equip(src)
		var/total = roll_dat_thang()
		user.visible_message("[src] shows [get_english_num(total)].")
		rollList = list()
		return

	d4
		name = "probability tetrahedron"
		sides = 4
		icon_state = "d4"
	d10
		name = "probability pentagonal trapezohedron" // yes, it's still actually called that
		sides = 10
		icon_state = "d20"
	d12
		name = "probability dodecahedron"
		sides = 12
		icon_state = "d20"
	d20
		name = "probability icosahedron"
		sides = 20
		icon_state = "d20"
	d100
		name = "probability zocchihedron"
		sides = 100
		icon_state = "d100"

/obj/item/diceholder
	name = "holder of dice (not an actual item)"
	desc = "Parent item of various dice holders"
	icon = 'icons/obj/items/items.dmi'
	var/list/obj/item/dice/dicelist = list()
	var/diceposition = 0
	var/icon/overlaydie
	var/image/overlaydieimage //yay conversions of conversions
	var/addeddice = 0 //handles adding pals
	var/list/localRollList = list()
	var/localtotal
	var/diceowner
	var/diceinchatstring

	proc/addDice(var/obj/item/dice/D as obj, var/baseoverlay, mob/living/user as mob) //takes a dice object, a base overlay (dicecup, diceboxt), and a user must be passed to the proc
		var/looplength = length(D.dicePals)
		for(var/i=1,i<=looplength,i++)
			if((istype(D.dicePals[i], /obj/item/dice/coin)) || (istype(D.dicePals[i], /obj/item/dice/magic8ball)))
				user.put_in_hand_or_drop(D.contents[i])
				D.dicePals -= D.dicePals[i]
				i--
				looplength--
		if((D.dicePals.len)&&(src.diceposition <5))
			for(var/i=1, i<=D.dicePals.len, i++)
				src.diceposition++
				src.overlaydie = new /icon('icons/obj/items/items.dmi',"[baseoverlay][src.diceposition]")
				if((D.dicePals[i].color)&&(D.dicePals[i].color != "null"))
					src.overlaydie.Blend(D.dicePals[i].color, ICON_MULTIPLY)
				src.overlaydieimage = image(src.overlaydie)
				src.UpdateOverlays(src.overlaydieimage, "[src.diceposition]")
				src.dicelist.Add(D.dicePals[i])
				D.dicePals[i].set_loc(src)
				src.addeddice++
				if(diceposition == 5)
					break
			if(length(D.dicePals) == src.addeddice)
				D.dicePals = list()
				if(D.colorcache)
					D.color = D.colorcache
					D.colorcache = null
				D.ClearAllOverlays()
				D.name = initial(D.name)
				D.desc = initial(D.desc)
				src.addeddice = 0
			else
				for(var/i=1, i<=addeddice, i++)
					D.ClearSpecificOverlays("[i]")
				while(addeddice>0)
					D.dicePals -= D.dicePals[1]
					addeddice--
			if(!D.dicePals.len)
				if(D.colorcache)
					D.color = D.colorcache
					D.colorcache = null
				D.ClearAllOverlays()
				D.name = initial(D.name)
				D.desc = initial(D.desc)
		if((!D.dicePals.len)&&(src.diceposition<5))
			if((!istype(D,/obj/item/dice/magic8ball))&&(!istype(D,/obj/item/dice/coin)))
				src.diceposition++
				user.visible_message(SPAN_SUCCESS("[user] adds the [D] to the [src]"),SPAN_SUCCESS("You add the [D] to the [src]."))
				src.overlaydie = new /icon('icons/obj/items/items.dmi',"[baseoverlay][src.diceposition]")
				if((D.color)&&(D.color != "null"))
					src.overlaydie.Blend(D.color, ICON_MULTIPLY)
				src.overlaydieimage = image(src.overlaydie)
				src.UpdateOverlays(src.overlaydieimage, "[src.diceposition]")
				src.dicelist.Add(D)
				user.u_equip(D)
				D.set_loc(src)
		else
			user.visible_message(SPAN_ALERT("The [src] is full!"))

	proc/removeDie(mob/living/user as mob) //requires the user to be passed to the proc
		if(istype(src.dicelist[src.diceposition], /obj/item/dice))
			user.put_in_hand_or_drop(src.dicelist[src.diceposition])
			src.dicelist -= src.dicelist[src.diceposition]
			src.ClearSpecificOverlays("[src.diceposition]")
			src.diceposition--

	proc/hiddenroll()
		localtotal = 0
		src.localRollList = list()
		for(var/i=1, i<=dicelist.len, i++) //shuffle the overlay colors to give the illusion of dice rolling inside the cup?
			if (src.dicelist[i].sides && isnum(src.dicelist[i].sides)) //index out of bounds
				src.dicelist[i].last_roll = rand(1, src.dicelist[i].sides)
				src.dicelist[i].tooltip_rebuild = TRUE
				src.localRollList.Add(list(list("sides"=src.dicelist[i].sides,"roll"=src.dicelist[i].last_roll,"color"=src.dicelist[i].color))) //need a check for dice without a color
				if(src.dicelist[i].sides == 6)
					src.dicelist[i].icon_state = "d6_[src.dicelist[i].last_roll]"
				src.localtotal += src.dicelist[i].last_roll

	proc/dicespawn(var/targetlocation)//takes the location of where you want to spawn the dice
		for(var/i=1, i<=dicelist.len, i++)
			src.localRollList = list()
			src.dicelist[i].set_loc(get_turf(targetlocation))
			src.dicelist[i].pixel_y = rand(-8,8)
			src.dicelist[i].pixel_x = rand(-8,8)
			src.dicelist[i].name = initial(src.dicelist[i].name)
			src.dicelist[i].desc = initial(src.dicelist[i].desc)
			src.dicelist[i].ClearAllOverlays()
			src.diceposition--
		src.dicelist = list()

	proc/pourout(atom/target,mob/living/user as mob) //requires the target and user to be passed to the proc
		if((src.dicelist.len)&&(istype(target, /turf/simulated/floor)) || length(src.dicelist) && (istype(target, /turf/unsimulated/floor)))
			hiddenroll()
			src.ClearAllOverlays()
			src.diceinchatstring = src.dicelist[1].diceInChat(1,src.localRollList)
			dicespawn(target)
			user.visible_message("<b>[user]'s roll:</b><br>[src.diceinchatstring]<br><b>Total: [src.localtotal]</b>")
			src.diceinchatstring = ""

/obj/item/diceholder/dicebox
	name = "dice box"
	desc = "A fancy box for holding up to five dice."
	icon_state = "dicebox"
	var/firstopen = 1 //helps organize overlays
	var/setcolor //color of the dice set

	afterattack(atom/target, mob/user as mob)
		if(src.icon_state != "dicebox")
			pourout(target,user)

	attack_self(mob/user as mob)
		if(src.icon_state == "dicebox")
			src.icon_state = "diceboxe"
			if(src.firstopen == 0)
				for(var/i=1, i<=src.diceposition, i++)
					src.UpdateOverlays(src.GetOverlayImage("[i]"),"[i]")
			else
				src.setcolor = pick("#D65555","#D88A41","#D8D856","#5FBF91","#6AC2D8","#9F6AD8", "null","#D882B3")
				for(var/i=1, i<=5, i++) //populate contents with dice and initialize overlays
					src.diceposition++
					src.dicelist.Add(new /obj/item/dice)
					src.dicelist[i].color = src.setcolor
					src.overlaydie = new /icon('icons/obj/items/items.dmi',"diceboxt[src.diceposition]")
					if(src.setcolor != "null")
						src.overlaydie.Blend(src.setcolor, ICON_MULTIPLY)
					src.overlaydieimage = image(src.overlaydie)
					src.UpdateOverlays(src.overlaydieimage, "[src.diceposition]")
				src.firstopen = 0
		else
			for(var/i=1, i<=src.diceposition, i++)
				src.UpdateOverlays(null,"[i]",0,1)
			src.icon_state = "dicebox"

	attack_hand(mob/user)
		if((src in user.contents) && (src.icon_state != "dicebox"))
			removeDie(user)
		else
			..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/dice))
			if(src.icon_state != "dicebox")
				addDice(I,"diceboxt",user)

/obj/item/diceholder/dicecup
	name = "dice cup"
	desc = "<span>A cup for rolling your dice!</span><br><span class='notice'>- Click a floor tile to roll your dice.</span><br><span class='notice'>- Click a table or drop on a non-help intent to flip the cup, concealing your roll.</span><br><span class='notice'>- Help Intent: view hidden roll</span><br><span class='notice'>- Non-help Intent: reveal dice</span><br>"
	icon_state = "dicecup"

	afterattack(atom/target, mob/user as mob)
		if(src.icon_state != "dicecupf")
			pourout(target,user)

	dropped(mob/user as mob)
		. = ..()
		if((dicelist.len) && (user.a_intent != "help"))
			src.ClearAllOverlays()
			src.icon_state = "dicecupf"
			src.diceowner = user.name
			hiddenroll()
			src.diceinchatstring = src.dicelist[1].diceInChat(1,src.localRollList)


	attack_self(mob/user as mob)
		if(src.icon_state == "dicecup")
			if(dicelist.len)
				user.visible_message(SPAN_NOTICE("[user] shakes the dice cup!"),SPAN_NOTICE("You shake the dice cup!"))
				hiddenroll()

	attack_hand(mob/user)
		if((src in user.contents) && (src.icon_state == "dicecup"))
			if(dicelist.len)
				removeDie(user)
		else if(src.icon_state == "dicecupf")
			if(user.a_intent == "help")
				if(user.name == diceowner)
					user.visible_message(SPAN_NOTICE("[user] peeks at their dice. "),"<b>Your roll:</b><br>[src.diceinchatstring]<br><b>Total: [src.localtotal]</b>")
				else
					user.visible_message(SPAN_ALERT("[user] peeks at [diceowner]'s dice!"),"<b>[src.diceowner]'s roll:</b><br>[src.diceinchatstring]<br><b>Total: [src.localtotal]</b>")
			else
				dicespawn(src.loc)
				src.icon_state = "dicecup"
				user.put_in_hand_or_drop(src)
				user.visible_message("<b>[src.diceowner]'s roll:</b><br>[src.diceinchatstring]<br><b>Total: [src.localtotal]</b>")
				src.diceinchatstring = ""
		else
			..()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/dice))
			if(src.icon_state == "dicecup")
				addDice(I,"dicecup",user)

/obj/item/storage/dicepouch
	name = "dice pouch"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "dicepouch"
	max_wclass = W_CLASS_TINY
	w_class = W_CLASS_TINY
	var/setcolor
	can_hold=list(/obj/item/dice)
	spawn_contents = list(/obj/item/dice/d4,/obj/item/dice,/obj/item/dice/d8,/obj/item/dice/d10,/obj/item/dice/d12,/obj/item/dice/d20,/obj/item/dice/d100)

	proc/colorpick()
		src.setcolor = pick("#D65555","#D88A41","#D8D856","#5FBF91","#6AC2D8","#9F6AD8", "null","#D882B3")
		for(var/obj/item/dice/i in src.storage.get_contents())
			i.color = src.setcolor

	make_my_stuff()
		..()
		colorpick()


#undef MAX_DICE_GROUP
