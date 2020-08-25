
/obj/decal/poster
	desc = "A piece of paper with an image on it. Clearly dealing with incredible technology here."
	name = "poster"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "poster"
	anchored = 1
	opacity = 0
	density = 0
	var/imgw = 600
	var/imgh = 400
	var/popup_win = 1
	layer = EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_ABOVE

	examine()
		if (usr.client && src.popup_win)
			src.show_popup_win(usr)
			return list()
		else
			return ..()

	proc/show_popup_win(var/client/C)
		if (!C || !src.popup_win)
			return
		// wtf why is this using wizardtips... with a custom size... fuck it im leaving this one out of the centralization -singh
		C.Browse(grabResource("html/traitorTips/wizardTips.html"),"window=antagTips;size=[imgw]x[imgh];title=Antagonist Tips")

	wallsign
		desc = "A sign, on a wall. Wow!"
		icon = 'icons/obj/decals/wallsigns.dmi'
		popup_win = 0
		var/pixel_var = 0

		New()
			..()
			if (src.pixel_var)
				src.pixel_y += rand(-4,4)
				src.pixel_x += rand(-4,4)

		stencil // font: "space frigate", free and adapted by cogwerks
			name = "stencil"
			desc = ""
			icon = 'icons/obj/decals/stencils.dmi'
			alpha = 200
			pixel_y = 9
			mouse_opacity = 0
			icon_state = "a"

			// splitting this shit up into children seems easier than assigning them all in the mapmaker with varediting.
			// it'll make it way easier to assemble stencils while maintaining controlled spacing
			// this is not a monospaced font so manual adjustments are necessary after laying out text
			// should be a close-enough estimate for starters though
			// characters may fit as dublets or triplets on one turf
			// i suppose it would have been more sensical to just dump out a bunch of full words from gimp
			// instead of hand-setting a typeface inside a fucking spaceman game
			// but fuck it, this will let other mappers write whatever hull stencils they want from it. have fun?
			// going piece by piece should also make damage look more realistic, no floating words over a breach
			// i'm aligning stencils against corners, so stencils on opposite sides of an airbridge will be either l or r aligned

			left
				pixel_x = -3 //fine-tune from this offset

				a
					name = "a"
					icon_state = "a"
				b
					name = "b"
					icon_state = "b"
				c
					name = "c"
					icon_state = "c"
				d
					name = "d"
					icon_state = "d"
				e
					name = "e"
					icon_state = "e"
				f
					name = "f"
					icon_state = "f"
				g
					name = "g"
					icon_state = "g"
				h
					name = "h"
					icon_state = "h"
				i
					name = "i"
					icon_state = "i"
				j
					name = "j"
					icon_state = "j"
				k
					name = "k"
					icon_state = "k"
				l
					name = "l"
					icon_state = "l"
				m
					name = "m"
					icon_state = "m"
				n
					name = "n"
					icon_state = "n"
				o
					name = "o"
					icon_state = "o"
				p
					name = "p"
					icon_state = "p"
				q
					name = "q"
					icon_state = "q"
				r
					name = "r"
					icon_state = "r"
				s
					name = "s"
					icon_state = "s"
				t
					name = "t"
					icon_state = "t"
				u
					name = "u"
					icon_state = "u"
				v
					name = "v"
					icon_state = "v"
				w
					name = "w"
					icon_state = "w"
				x
					name = "x"
					icon_state = "x"
				y
					name = "y"
					icon_state = "y"
				z
					name = "z"
					icon_state = "z"
				one
					name = "one"
					icon_state = "1"
				two
					name = "two"
					icon_state = "2"
				three
					name = "three"
					icon_state = "3"
				four
					name = "four"
					icon_state = "4"
				five
					name = "five"
					icon_state = "5"
				six
					name = "six"
					icon_state = "6"
				seven
					name = "seven"
					icon_state = "7"
				eight
					name = "eight"
					icon_state = "8"
				nine
					name = "nine"
					icon_state = "9"
				zero
					name = "zero"
					icon_state = "0"

			right
				pixel_x = 11 // fine-tune from this offset

				a
					name = "a"
					icon_state = "a"
				b
					name = "b"
					icon_state = "b"
				c
					name = "c"
					icon_state = "c"
				d
					name = "d"
					icon_state = "d"
				e
					name = "e"
					icon_state = "e"
				f
					name = "f"
					icon_state = "f"
				g
					name = "g"
					icon_state = "g"
				h
					name = "h"
					icon_state = "h"
				i
					name = "i"
					icon_state = "i"
				j
					name = "j"
					icon_state = "j"
				k
					name = "k"
					icon_state = "k"
				l
					name = "l"
					icon_state = "l"
				m
					name = "m"
					icon_state = "m"
				n
					name = "n"
					icon_state = "n"
				o
					name = "o"
					icon_state = "o"
				p
					name = "p"
					icon_state = "p"
				q
					name = "q"
					icon_state = "q"
				r
					name = "r"
					icon_state = "r"
				s
					name = "s"
					icon_state = "s"
				t
					name = "t"
					icon_state = "t"
				u
					name = "u"
					icon_state = "u"
				v
					name = "v"
					icon_state = "v"
				w
					name = "w"
					icon_state = "w"
				x
					name = "x"
					icon_state = "x"
				y
					name = "y"
					icon_state = "y"
				z
					name = "z"
					icon_state = "z"
				one
					name = "one"
					icon_state = "1"
				two
					name = "two"
					icon_state = "2"
				three
					name = "three"
					icon_state = "3"
				four
					name = "four"
					icon_state = "4"
				five
					name = "five"
					icon_state = "5"
				six
					name = "six"
					icon_state = "6"
				seven
					name = "seven"
					icon_state = "7"
				eight
					name = "eight"
					icon_state = "8"
				nine
					name = "nine"
					icon_state = "9"
				zero
					name = "zero"
					icon_state = "0"

		chsl
			name = "CLEAN HANDS SAVE LIVES"
			desc = "A poster that reads 'CLEAN HANDS SAVE LIVES'."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "chsl"

		chsc
			name = "CLEAN HANDS SAVE CASH"
			desc = "A poster that reads 'CLEAN HANDS SAVE CASH: Today's unwashed palm is tomorrow's class action suit!'."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "chsc"

		danger_highvolt
			name = "Danger: High Voltage"
			icon_state = "shock"

		medbay
			name = "Medical Bay"
			icon_state = "wall_sign_medbay"

		security
			name = "Security"
			icon_state = "wall_sign_security"

		engineering
			name = "Engineering"
			icon_state = "wall_sign_engineering"

		space
			name = "VACUUM AREA"
			desc = "A warning sign which reads 'EXTERNAL AIRLOCK'."
			icon_state = "space"

		construction
			name = "CONSTRUCTION AREA"
			desc = "A warning sign which reads 'CONSTRUCTION AREA'."
			icon_state = "wall_sign_danger"

		pool
			name = "Pool"
			icon_state = "pool"

		fire
			name = "FIRE HAZARD"
			desc = "A warning sign which reads 'FIRE HAZARD'."
			icon_state = "wall_sign_fire"

		biohazard
			name = "BIOHAZARD"
			desc = "A warning sign which reads 'BIOHAZARD'."
			icon_state = "bio"

		gym
			name = "Barkley Ballin' Gym"
			icon_state = "gym"

		barber
			name = "The Snip"
			icon = 'icons/obj/barber_shop.dmi'
			icon_state = "thesnip"

		bar
			name = "Bar"
			icon = 'icons/obj/stationobjs.dmi'
			icon_state = "barsign"

		coffee
			name ="Coffee Shop"
			desc = "A cute little coffee cup poster."
			icon = 'icons/obj/foodNdrink/espresso.dmi'
			icon_state ="fancycoffeecup"

		magnet
			name = "ACTIVE MAGNET AREA"
			desc = "A warning sign. I guess this area is dangerous."
			icon_state = "wall_sign_mag"

		cdnp
			name = "CRIME DOES NOT PAY"
			desc = "A warning sign which suggests that you reconsider your poor life choices."
			icon_state = "crime"

		dont_panic
			name = "DON'T PANIC"
			desc = "A sign which suggests that you remain calm, as everything is surely just fine."
			icon_state = "centcomfail"
			New()
				..()
				icon_state = pick("centcomfail", "centcomfail2")

		fudad
			name = "Arthur Muggins Memorial Jazz Lounge"
			desc = "In memory of Arthur \"F. U. Dad\" Muggins, the bravest, toughest Vice Cop SS13 has ever known. Loved by all. R.I.P."
			icon_state = "rip"

		escape
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape"

		escape_left
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape_arrow_l"

		escape_right
			name = "ESCAPE"
			desc = "Follow this to find Escape! Or fire. Or death. One of those."
			icon_state = "wall_escape_arrow_r"

		medbay_text
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay"

		medbay_left
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay_arrow_l"

		medbay_right
			name = "MEDICAL BAY"
			desc = "Follow this to find Medbay! Or fire. Or death. One of those."
			icon_state = "wall_medbay_arrow_r"

		security_wall
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security"

		security_left
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security_arrow_l"

		security_right
			name = "SECURITY"
			desc = "Follow this to find Security! Or fire. Or death. One of those."
			icon_state = "wall_security_arrow_r"

		submarines
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines"

		submarines_left
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines_arrow_l"

		submarines_right
			name = "SUBMARINES"
			desc = "Follow this to find Submarines! Or fire. Or death. One of those."
			icon_state = "wall_submarines_arrow_r"

		hazard_stripe
			name = "hazard stripe"
			desc = ""
			icon_state = "stripe"

		hazard_caution
			name = "CAUTION"
			icon_state = "wall_caution"

		hazard_danger
			name = "DANGER"
			icon_state = "wall_danger"

		hazard_bio
			name = "BIOHAZARD"
			icon_state = "wall_biohazard"

		hazard_rad
			name = "RADIATION"
			icon_state = "wall_radiation"

		hazard_exheat
			name = "EXTREME HEAT"
			icon_state = "wall_extremeheat"

		hazard_electrical
			name = "ELECTRICAL HAZARD"
			icon_state = "wall_electricalhazard"

		hazard_hotloop
			name = "HOT LOOP"
			icon_state = "wall_hotloop"

		hazard_coldloop
			name = "COLD LOOP"
			icon_state = "wall_coldloop"

		poster_hair
			name = "Fabulous Hair!"
			desc = "There's a bunch of ladies with really fancy hair pictured on this."
			icon_state = "wall_poster_hair"

		poster_cool
			name = "cool poster"
			desc = "There's a couple people pictured on this poster, looking pretty cool."
			icon_state = "wall_poster_cool3"
			random_icon_states = list("wall_poster_cool", "wall_poster_cool2", "wall_poster_cool3")

		poster_human
			name = "poster"
			desc = "There's a person pictured on this poster. Some sort of celebrity."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_human"
			//todo: implement procedural celebrities

		poster_borg
			name = "poster"
			desc = "There's a cyborg pictured on this poster, but you aren't really sure what the message is. Is it trying to advertise something?"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_borg"

		poster_sol
			name = "poster"
			desc = "There's a star and the word 'SOL' pictured on this poster."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_sol"

		poster_clown
			name = "poster"
			desc = "There's a clown pictured on this poster."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_clown"

		poster_nt
			name = "\improper NanoTrasen poster"
			desc = "A cheerful-looking version of the NT corporate logo."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_nt"

		poster_ptoe
			name = "periodic table of elements"
			desc = "A chart listing all known chemical elements."
			icon_state = "ptoe"

		poster_y4nt
			name = "\improper NanoTrasen poster"
			desc = "A huge poster that reads 'I want YOU for NT!'"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "you_4_nt"

		poster_beach
			name = "beach poster"
			desc = "Sun, sea, and sand! Just visit VR."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_beach"

		poster_discount
			name = "grimy poster"
			desc = "Buy Discount Dans! Now legally food."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_discount"

		poster_octocluwne
			name = "spooky poster"
			desc = "Coming to theatres this summer: THE OCTOCLUWNE FROM MARS!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_octocluwne"

		poster_eyetest
			name = "eye chart"
			desc = "It's hard to make out anything. You're at a loss as to what even the first letter is." //heh
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_eyetest"

		poster_rand
			name = "poster"
			desc = "You aren't really sure what the message is. Is it trying to advertise something?"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_cool3"
			pixel_var = 1
			random_icon_states = list("wall_poster_cool",
																"wall_poster_cool2",
																"wall_poster_cool3",
																"wall_poster_hair",
																"wall_poster_human",
																"wall_poster_borg",
																"wall_poster_sol",
																"wall_poster_clown",
																"wall_poster_beach",
																"wall_poster_discount",
																"wall_poster_octocluwne",
																"wall_poser_eyetest")

		poster_mining
			name = "mining poster"
			desc = "Seems like the miners union is planning yet another strike.."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_mining"

		portrait_scientist
			name = "portrait"
			desc = "It's a portrait of a rather famous plasma scientist, Sawa Hiromi."
			icon_state = "portrait_scientist"

		warning1
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning1"

		warning2
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning2"

		warning3
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning3"

		warning4
			name = "warning sign"
			desc = "A sign warning you of something."
			icon_state = "wall_warning4"

		statistics1
			name = "statistics poster"
			desc = "A poster with a bar chart depicting the rapid growth of chemistry lab related explosions. Although who the fuck even uses a bar chart when you could be using a line chart.."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_statistics1"

		statistics2
			name = "statistics poster"
			desc = "A poster with a line chart depicting the rapid growth of artifact lab related accidents."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_statistics2"

		newtonscrew
			name = "Newtons Crew Memorial Plaque"
			desc = "In memory of the first to go where none had gone before. Sailor Dave,  Faffotron, Bethany Parks, Jake Marshall, Luis Smith, Monte Lowe, Parker Unk, Ygor Savage, Valterak Balmue, Jenny Antonsson, Edison Lootin,"
			icon_state = "rip"

		testsubject
			name = "Anatomy of a test subject"
			desc = "This poster showcases all of the weak points of a monkey test subject. Sadly it does not have any weak points."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "testsubject"

		mantaposter
			name = "NSS Manta poster"
			desc = "Pre-eliminary signing up for Nanotrasen's newest military vessel NSS Manta has now begun. Reach out to your head of personnel or a local Nanotrasen recruiting officer to find out more about new job oppurtunities aboard NSS Manta! "
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "mantaposter"

		teaparty
			name = "Weird poster"
			desc = "Huh."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "teaparty"

			New()
				..()
				var/which = rand(1, 4)
				switch(which)
					if(1)
						src.name = "Tea Hell and Back"
						src.desc = "<i>Starring Camryn Stern, Edgar Palmer, Ryan Yeets, Jebediah Hawkins, and Frederick Cooper.</i>"
					if(2)
						src.icon_state = "teaparty2"
						src.name = "It Came from the Void"
						src.desc = "<i>Starring William Carr, Bruce Isaman, and Julio Hayhurst.</i>"
					if(3)
						src.icon_state = "teaparty3"
						src.name = "Afterlife Activity"
						src.desc = "<i>Starring Marmalade Addison, Lily White, cockroach, and Darcey Paynter.</i>"
					if (4)
						src.name = "\proper fuck II"
						src.desc = "A poster for \"<em>fuck II: Plumb Fuckled.\"</em>"
						src.icon_state = "fuckII"

		fuck1 //do not add this to the random sign rotation, fuck I is a long-lost relic overshadowed entirely by its successor
			name = "\proper fuck"
			desc = "No... it can't be... the original?! This is a vintage!!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "fuckI"

		fuck2
			name = "\proper fuck II"
			desc = "A poster for \"<em>fuck II: Plumb Fuckled.\"</em>"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "fuckII"

		bookcase
			name = "bookcase"
			desc = "A bookcase filled to the brim with marvelous works of lit-... Hey! This is just bookcase wallpaper!"
			icon = 'icons/turf/adventure.dmi'
			icon_state = "bookcase_full_wall"
			pixel_y = -4
			layer = 3


		landscape
			desc = "A beautiful painting of a landscape that is engulfed by flames."
			name = "painting"
			icon = 'icons/obj/64x32.dmi'
			icon_state = "landscape"

		garbagegarbssign
			desc = "Come down over to Garbage Garbs, we've got both garbs -AND- garbage!"
			name = "Garbage Garbs sign"
			icon = 'icons/effects/96x32.dmi' //Maybe not the best place but it was the only ready 96x32 dmi
			icon_state = "garbagegarbs"
			bound_width  = 96

		fuq3
			desc = "Our premier line of clothing is so diverse, you'll be sure to cry 'What le fuq?'"
			name = "Fuq III"
			icon = 'icons/effects/96x32.dmi'
			icon_state = "fuq3"
			bound_width  = 96
			plane = -99

///////////////////////////////////////
// AZUNGAR'S HEAD OF DEPARTMENT ITEMS// + FIREBARRAGE HELPED TOO BUT HE SMELLS
///////////////////////////////////////

		medal
			name = "framed medal"
			desc = "A dusty old war medal."
			var/award_text = null
			var/usageState = 0
			icon_state = "medal"
			pixel_y = -6

			// 0 = GLASS, MEDAL 1 = GLASS OFF, MEDAL IN CASE, 2 = GLASS OFF, MEDAL GONE,

			get_desc()
				if(award_text)
					return award_text
				else
					// Do we have a hos?
					for(var/mob/living/carbon/human/player in mobs)
						if(!player.mind)
							continue
						if(player.mind.assigned_role == "Head of Security")
							award_text = src.get_award_text(player.mind)
							return award_text


			attack_hand(mob/user as mob)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usageState)
					if (0)
						if (issilicon(user)) return
						src.usageState = 1
						src.icon_state = "medal1"
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						var/obj/item/hosmedal/M = new /obj/item/hosmedal()
						M.desc = src.desc
						user.put_in_hand_or_drop(M)
						user.visible_message("[user] takes the medal from the frame.", "You take the medal out of the frame.")
						src.icon_state = "frame"
						src.add_fingerprint(user)
						src.usageState = 2

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (istype(W, /obj/item/diary))
					var/obj/item/paper/book/space_law/first/newbook = new /obj/item/paper/book/space_law/first
					user.u_equip(W)
					user.put_in_hand_or_drop(newbook)
					boutput(user, "<span class='alert'>Beepsky's private journal transforms into Space Law 1st Print.</span>")
					qdel(W)

				if (src.usageState == 2)
					if (istype(W, /obj/item/hosmedal))
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						user.u_equip(W)
						qdel(W)
						user.visible_message("[user] places the medal back in the frame.", "You place the medal back in the frame.")
						src.usageState = 1
						src.icon_state = "medal1"

				if (src.usageState == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usageState = 0
							src.icon_state = "medal"


			proc/get_award_text(var/datum/mind/M)
				var/hosname = "Anonymous"
				if(M && M.current && M.current.client && M.current.client.preferences && M.current.client.preferences.name_last)
					hosname = M.current.client.preferences.name_last
				var/hosage = 50
				if(M && M.current && M.current.bioHolder && M.current.bioHolder.age)
					hosage = M.current.bioHolder.age
				. = "Awarded to [pick("Pvt.","Sgt","Cpl.","Maj.","Cpt.","Col.","Gen.")] "
				. += "[hosname] for [pick("Outstanding","Astounding","Incredible")] "
				. += "[pick("Bravery","Courage","Sneakiness","Competence","Participation","Robustness")] in the "
				. += "[pick("Great","Scary","Bloody","")] [pick("War","Battle","Massacre","Riot","Kerfuffle","Undeclared Conflict")] of "
				. += "'[(CURRENT_SPACE_YEAR - rand((hosage - 18),hosage)) % 100]."

		firstbill
			name = "framed space currency"
			desc = "A single space currency in a glass frame."
			var/award_text_hop = null
			var/usageState = 0
			icon_state = "hopcredit"
			pixel_y = -6

			get_desc()
				if(award_text_hop)
					return award_text_hop
				else
					// Do we have a hop?
					for(var/mob/living/carbon/human/player in mobs)
						if(!player.mind)
							continue
						if(player.mind.assigned_role == "Head of Personnel")
							award_text_hop = src.get_award_text_hop(player.mind)
							return award_text_hop

			attack_hand(mob/user as mob)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usageState)
					if (0)
						if (issilicon(user)) return
						src.usageState = 1
						src.icon_state = "hopcredit1"
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						var/obj/item/firstbill/M = new /obj/item/firstbill()
						M.desc = src.desc
						user.put_in_hand_or_drop(M)
						user.visible_message("[user] takes the first bill from the frame.", "You take the first bill out of the frame.")
						src.icon_state = "frame"
						src.add_fingerprint(user)
						src.usageState = 2

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (src.usageState == 2)
					if (istype(W, /obj/item/firstbill))
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						user.u_equip(W)
						qdel(W)
						user.visible_message("[user] places the first bill back in the frame.", "You place the first bill back in the frame.")
						src.usageState = 1
						src.icon_state = "hopcredit1"

				if (src.usageState == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usageState = 0
							src.icon_state = "hopcredit"

			proc/get_award_text_hop(var/datum/mind/M)
				var/hopname = "Anonymous"
				if(M && M.current && M.current.client && M.current.client.preferences && M.current.client.preferences.name_last)
					hopname = M.current.client.preferences.name_last
				. = "The first [pick("Space","NT", "Golden","Silver")] "
				. += "[pick("Dollar","Doubloon","Buck","Peso","Credit")] earned by [hopname]"
				. += "for selling a [pick("Amazing","Mediocre","Suspicious","Quality","Decent","Odd")]"
				. += "[pick("Time share","Hamburger", "Clown shoe","Corporate secrets")]"



		rddiploma
			name = "research directors diploma"
			desc = "A fancy space diploma in a glass frame."
			var/award_text_rd = null
			var/usageState = 0
			icon_state = "rddiploma"
			pixel_y = -6

			get_desc(dist)
				if(award_text_rd)
					return award_text_rd
				if (dist <= 1 & prob(50))
					. += ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
				else
					// Do we have a rd?
					for(var/mob/living/carbon/human/player in mobs)
						if(!player.mind)
							continue
						if(player.mind.assigned_role == "Research Director")
							award_text_rd = src.get_award_text_rd(player.mind)
							return award_text_rd

			attack_hand(mob/user as mob)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usageState)
					if (0)
						if (issilicon(user)) return
						src.usageState = 1
						src.icon_state = "rddiploma1"
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						var/obj/item/rddiploma/M = new /obj/item/rddiploma()
						user.put_in_hand_or_drop(M)
						user.visible_message("[user] takes the diploma from the frame.", "You take the diploma out of the frame.")
						src.icon_state = "frame"
						src.add_fingerprint(user)
						src.usageState = 2

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (src.usageState == 2)
					if (istype(W, /obj/item/rddiploma))
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						user.u_equip(W)
						qdel(W)
						user.visible_message("[user] places the diploma back in the frame.", "You place the diploma back in the frame.")
						src.usageState = 1
						src.icon_state = "rddiploma1"

				if (src.usageState == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usageState = 0
							src.icon_state = "rddiploma"

			proc/get_award_text_rd(var/datum/mind/M)
				var/rdname = "Anonymous"
				if(M && M.current && M.current.client && M.current.client.preferences && M.current.client.preferences.name_last)
					rdname = M.current.client.preferences.name_last
				. += "It says \ [rdname] has been awarded the degree of [pick("Associate", "Bachelor")] of [pick("arts","science")]"
				. += "Master of [pick("arts","science")],"
				. += "in [pick("Superstition","Quantum","Avian","Simian","Relative","Absolute","Computational","Philosophical","Practical","Inadvisably-applied","Impractical","Hyper", "Mega", "Giga", "Probabilistic")] [pick("Physics","Astronomy","Plasmatology", "Astrology","Cosmetology", "Dentistry","Botany","Science","Ologylogy","Wumbology")].\""

		mdlicense
			name = "medical directors medical license"
			desc = "There's just no way this is real."
			icon_state = "mdlicense"
			var/usageState = 0
			pixel_y = -6

			attack_hand(mob/user as mob)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usageState)
					if (0)
						if (issilicon(user)) return
						src.usageState = 1
						src.icon_state = "mdlicense1"
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						var/obj/item/mdlicense/M = new /obj/item/mdlicense()
						M.desc = src.desc
						user.put_in_hand_or_drop(M)
						user.visible_message("[user] takes the medical license from the frame.", "You take the medical license out of the frame.")
						src.icon_state = "frame"
						src.add_fingerprint(user)
						src.usageState = 2

			attackby(obj/item/W as obj, mob/user as mob)
				if (user.stat)
					return

				if (src.usageState == 2)
					if (istype(W, /obj/item/mdlicense))
						playsound(src.loc, "sound/machines/click.ogg", 50, 1)
						user.u_equip(W)
						qdel(W)
						user.visible_message("[user] places the medical license back in the frame.", "You place the medical license back in the frame.")
						src.usageState = 1
						src.icon_state = "mdlicense1"

				if (src.usageState == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, "sound/machines/click.ogg", 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usageState = 0
							src.icon_state = "mdlicense"
