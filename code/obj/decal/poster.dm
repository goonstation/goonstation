
/obj/decal/poster
	desc = "A piece of paper with an image on it. Clearly dealing with incredible technology here."
	name = "poster"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "poster"
	anchored = 1
	opacity = 0
	density = 0
	deconstruct_flags = DECON_WIRECUTTERS
	var/imgw = 600
	var/imgh = 400
	var/popup_win = 0
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

		neonicecream
			name = "Ice-Cream"
			desc = "A neon sign shaped like ice cream!"
			icon = 'icons/misc/walp_decor.dmi'
			icon_state = "neonsign_ice"

		neonsparkle
			name = "sparkle neon sign"
			desc = "A neon sign shaped like cute sparkles."
			icon = 'icons/misc/walp_decor.dmi'
			icon_state = "neonsign_sparkle"

		neonretro
			name = "retro neon sign"
			desc = "A relic from the past, or a grim prediction of the future."
			icon = 'icons/misc/walp_decor.dmi'
			icon_state = "neonsign_80s"

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
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "wall_poster_hair"

		poster_cool
			name = "cool poster"
			desc = "There's a couple people pictured on this poster, looking pretty cool."
			icon = 'icons/obj/decals/posters.dmi'
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
			name = "\improper NanoTrasen recruitment poster"
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
			random_icon_states = list(
				"wall_poster_cool",
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
				"wall_poster_eyetest"
			)

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
			desc = "Seems to be a poster of some sort."
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "teaparty"

			New()
				..()

				var/which = pick(
					// the fuck II poster
					30;"fuckII",
					// new contest winners
					50;"contest1",
					50;"contest2",
					50;"contest3",
					50;"contest4",
					50;"contest5",
					// new contest not-winners but cool nonetheless
					5 ;"contest-other1",
					5 ;"contest-other2",
					5 ;"contest-other3",
					5 ;"contest-other4",
					5 ;"contest-other5",
					5 ;"contest-other6",
					5 ;"contest-other7"
					)
				switch(which)
					if("fuckII")
						src.name = "\proper fuck II"
						src.desc = "A poster for \"<em>fuck II: Plumb Fuckled.\"</em>"
						src.icon_state = "fuckII"
					if("contest1")
						src.name = "Explore the Trench"
						src.icon_state = "explore_the_trench"
					if("contest2")
						src.name = "🐟"
						src.icon_state = "fish_hook"
					if("contest3")
						src.name = "Bird Up!"
						src.icon_state = "bird_up"
					if("contest4")
						src.name = "A New You"
						src.icon_state = "a_new_you"
					if("contest5")
						src.name = "Work! Ranch"
						src.icon_state = "work_ranch"
					if("contest-other1")
						src.name = "Pack Smart"
						src.icon_state = "pack_smart"
					if("contest-other2")
						src.name = "Mindhacker Device Poster"
						src.icon_state = "mindhacked"
					if("contest-other3")
						src.name = "Edit Wiki"
						src.icon_state = "edit_wiki"
					if("contest-other4")
						src.name = "Join Us For Boom"
						src.icon_state = "join_us_for_boom"
					if("contest-other5")
						src.name = "Grow Food Not Weed"
						src.icon_state = "grow_food_not_weed"
					if("contest-other6")
						src.name = "More Laser Power"
						src.icon_state = "more_laser_power"
					if("contest-other7")
						src.name = "Code"
						src.icon_state = "code"

			attack_hand(mob/user)
				. = ..()
				switch(src.icon_state)
					if("code")
						user << link("https://github.com/goonstation/goonstation")
					if("edit_wiki")
						user << link("https://wiki.ss13.co/")

		lesb_flag //lesbeean prefab thingy - subtle environmental storytelling, you know?
			name = "lesbian pride flag"
			desc = "Neat!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "lesb"

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

		wizard
			desc = "A tasteful portrait of a wizard."
			name = "Portrait"
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "picture_wizard"

		teleport_sign
			name = "Teleport Sign"
			desc = "A sign that points to the nearest teleporter."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "wall_teleport"

		escape_sign
			name = "Escape Sign"
			desc = "A sign that points to the station's departures wing."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "escape"

		security_sign
			name = "Security Sign"
			desc = "A sign that points to the station's security department."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "security"

		engine_sign
			name = "Engine Sign"
			desc = "A sign that points to the station's engineering department."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "engine"

		research_sign
			name = "Teleport Sign"
			desc = "A handy sign that points to the source of all your problems."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "research"

		medbay_sign
			name = "Medbay Sign"
			desc = "A sign that points to the station's medical department."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "medbay"

		botany_sign
			name = "Botany Sign"
			desc = "A sign that points to the station's botany department."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "botany"

		customs_sign
			name = "Customs Sign"
			desc = "A sign that points to the station's customs desk, commonly referred to as the Head of Personnel's office even if that is not the case."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "customs"

		no_smoking
			name = "Sign"
			desc = "No smoking in this area!"
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "nosmoking"

		read_me
			name = "Important Sign"
			desc = "The huge header takes up most of the sign, everything else is so tiny it's illegible."
			icon = 'icons/obj/decals/wallsigns.dmi'
			icon_state = "read_me"

		landscape
			desc = "A beautiful painting of a landscape that is engulfed by flames."
			name = "painting"
			icon = 'icons/obj/large/64x32.dmi'
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

		psa_bucket
			desc = "<span class='alert'><i>Stuck</i></b></span> behind a mop bucket? Never fear! Just <span class='notice'><i>slide</i></span> yourself over it!"
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "bucket" // sprite by BatElite!

		keep_it_or_melt
			name = "KEEP IT or MELT"
			desc = "A poster depicting an emergency suit with large text that reads \"KEEP IT or MELT\". A tiny row of text at the bottom reads \"All personnel receive suits rated for three minutes of exposure.\""
			icon = 'icons/obj/decals/posters.dmi'
			icon_state = "keep_it_or_melt"

		eiffelposter //for Jan's office
			desc = "A poster of the Eiffel Tower in Paris, France."
			name = "Eiffel Poster"
			icon = 'icons/misc/janstuff.dmi'
			icon_state = "poster_eiffel"

///////////////////////////////////////
// AZUNGAR'S HEAD OF DEPARTMENT ITEMS// + FIREBARRAGE HELPED TOO BUT HE SMELLS
///////////////////////////////////////

		framed_award
			name = "A framed award"
			desc = "Just some generic award"
			var/award_text = null
			var/obj/item/award_type = /obj/item/rddiploma
			var/award_name ="diploma"
			var/usage_state = 0		// 0 = GLASS, AWARD 1 = GLASS OFF, AWARD IN CASE, 2 = GLASS OFF, AWARD GONE,
			var/owner_job = "Research Director"
			var/icon_glass = "rddiploma1"
			var/icon_award = "rddiploma"
			var/icon_empty = "frame"
			icon_state = "rddiploma"
			pixel_y = -6

			New()
				..()
				var/obj/item/M = new award_type(src.loc)
				M.desc = src.desc
				src.contents.Add(M)

			get_desc()
				if(award_text)
					return award_text
				else
					// Do we have a player of the right job?
					for(var/mob/living/carbon/human/player in mobs)
						if(!player.mind)
							continue
						if(player.mind.assigned_role == owner_job)
							award_text = src.get_award_text(player.mind)
							return award_text


			attack_hand(mob/user)
				if (user.stat || isghostdrone(user) || !isliving(user))
					return

				switch (usage_state)
					if (0)
						if (issilicon(user)) return
						src.usage_state = 1
						src.icon_state = icon_glass
						user.visible_message("[user] takes off the glass frame.", "You take off the glass frame.")
						var/obj/item/sheet/glass/G = new /obj/item/sheet/glass()
						G.amount = 1
						src.add_fingerprint(user)
						user.put_in_hand_or_drop(G)

					if (1)
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						var/obj/item/award_item = locate(award_type) in src
						if(award_item)
							award_item.desc = src.desc
							user.put_in_hand_or_drop(award_item)
							user.visible_message("[user] takes the [award_name] from the frame.", "You take the [award_name] out of the frame.")
							src.icon_state = icon_empty
							src.add_fingerprint(user)
							src.usage_state = 2

			attackby(obj/item/W, mob/user)
				if (user.stat)
					return

				if (src.usage_state == 2)
					if (istype(W, award_type))
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						user.u_equip(W)
						W.set_loc(src)
						user.visible_message("[user] places the [award_name] back in the frame.", "You place the [award_name] back in the frame.")
						src.usage_state = 1
						src.icon_state = icon_glass

				if (src.usage_state == 1)
					if (istype(W, /obj/item/sheet/glass))
						if (W.amount >= 1)
							playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
							user.u_equip(W)
							qdel(W)
							user.visible_message("[user] places glass back in the frame.", "You place the glass back in the frame.")
							src.usage_state = 0
							src.icon_state = icon_award


			proc/get_award_text(var/datum/mind/M)
				. = "Awarded to some chump for achieving something."

		framed_award/hos_medal
			name = "framed medal"
			desc = "A dusty old war medal."
			award_type = /obj/item/clothing/suit/hosmedal/
			award_name = "medal"
			owner_job = "Head of Security"
			icon_glass = "medal1"
			icon_award = "medal"
			icon_empty = "frame"
			icon_state = "medal"

			attackby(obj/item/W, mob/user)
				if (user.stat)
					return

				if (istype(W, /obj/item/diary))
					var/obj/item/paper/book/from_file/space_law/first/newbook = new /obj/item/paper/book/from_file/space_law/first
					user.u_equip(W)
					user.put_in_hand_or_drop(newbook)
					boutput(user, "<span class='alert'>Beepsky's private journal transforms into Space Law 1st Print.</span>")
					qdel(W)

				..()

			get_award_text(var/datum/mind/M)
				var/hosname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					hosname = M.current.client.preferences.name_last
				var/hosage = 50
				if(M?.current?.bioHolder?.age)
					hosage = M.current.bioHolder.age
				. = "Awarded to [pick("Pvt.","Sgt","Cpl.","Maj.","Cpt.","Col.","Gen.")] "
				. += "[hosname] for [pick("Outstanding","Astounding","Incredible")] "
				. += "[pick("Bravery","Courage","Sneakiness","Competence","Participation","Robustness")] in the "
				. += "[pick("Great","Scary","Bloody","")] [pick("War","Battle","Massacre","Riot","Kerfuffle","Undeclared Conflict")] of "
				. += "'[(CURRENT_SPACE_YEAR - rand((hosage - 18),hosage)) % 100]."

		framed_award/firstbill
			name = "framed space currency"
			desc = "A single bill of space currency."
			award_type = /obj/item/firstbill/
			award_name = "first bill"
			owner_job = "Head of Personnel"
			icon_glass = "hopcredit1"
			icon_award = "hopcredit"
			icon_empty = "frame"
			icon_state = "hopcredit"

			get_award_text(var/datum/mind/M)
				var/hopname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					hopname = M.current.client.preferences.name_last
				. = "The first [pick("Space","NT", "Golden","Silver")] "
				. += "[pick("Dollar","Doubloon","Buck","Peso","Credit")] earned by [hopname] "
				. += "for selling a [pick("Amazing","Mediocre","Suspicious","Quality","Decent","Odd")] "
				. += "[pick("Time share","Hamburger", "Clown shoe","Corporate secrets")]"

		framed_award/rddiploma
			name = "research directors diploma"
			desc = "A fancy space diploma."
			award_type = /obj/item/rddiploma/

			get_desc(dist)
				if(award_text)
					return award_text
				if (dist <= 1 & prob(50))
					. += ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
				else
					// Do we have a rd?
					..()

			get_award_text(var/datum/mind/M)
				var/rdname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					rdname = M.current.client.preferences.name_last
				. += "It says \ [rdname] has been awarded the degree of [pick("Associate", "Bachelor")] of [pick("arts","science")] "
				. += "Master of [pick("arts","science")], "
				. += "in [pick("Superstition","Quantum","Avian","Simian","Relative","Absolute","Computational","Philosophical","Practical","Inadvisably-applied","Impractical","Hyper", "Mega", "Giga", "Probabilistic")] [pick("Physics","Astronomy","Plasmatology", "Astrology","Cosmetology", "Dentistry","Botany","Science","Ologylogy","Wumbology")].\""

		framed_award/mdlicense
			name = "medical directors medical license"
			desc = "There's just no way this is real."
			award_type = /obj/item/mdlicense/
			award_name = "medical license"
			owner_job = "Medical Director"
			icon_glass = "mdlicense1"
			icon_award = "mdlicense"
			icon_empty = "frame"
			icon_state = "mdlicense"

			get_award_text(var/datum/mind/M)
				var/mdname = "Anonymous"
				if(M?.current?.client?.preferences?.name_last)
					mdname = M.current.client.preferences.name_last
				. += "It says \ [mdname] has been granted a license as a Physician and Surgeon entitled to practice the profession of medicine in space."

/obj/decal/poster/wallsign/pod_build
	name = "poster"
	icon = 'icons/obj/decals/posters_64x32.dmi'
	icon_state = "nt-pod-poster"
	popup_win = 1

	show_popup_win(var/client/C)
		if (!C || !src.popup_win)
			return
		C.Browse(grabResource("html/how_to_build_a_pod.html"),"window=how_to_build_a_pod;size=[imgw]x[imgh];title=How to Build a Space Pod")

/obj/decal/poster/wallsign/pod_build/nt
	icon_state = "nt-pod-poster"
/obj/decal/poster/wallsign/pod_build/sy
	icon_state = "sy-pod-poster"

/obj/decal/poster/wallsign/pw_map
	name = "Map"
	desc = "A map affixed to the wall!'."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "pw_map"
	popup_win = 1
	imgw = 702
	imgh = 702

	show_popup_win(var/client/C)
		if (!C || !src.popup_win)
			return

		C.Browse("<img src=\"[resource("images/pw_map.png")]\">","window=Map;size=[imgw]x[imgh];title=Map")

/obj/decal/poster/banner
	name = "banner"
	desc = "An unfinished banner, try adding some color to it by using a crayon!"
	icon = 'icons/obj/decals/banners.dmi'
	icon_state = "banner_base"
	popup_win = 0
	var/colored = FALSE
	var/static/image/banner_holder = image('icons/obj/decals/banners.dmi', "banner_holder")
	var/chosen_overlay
	var/static/list/choosable_overlays = list("Horizontal Stripes","Vertical Stripes","Diagonal Stripes","Cross","Diagonal Cross","Full","Full Gradient",
	"Left Line","Middle Line","Right Line","Northwest Line","Northeast Line","Southwest Line","Southeast Line","Big Ball","Medium Ball","Small Ball",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","+","-","=")

	proc/clear_banner()
		if (src.material)
			src.color = src.material.color
		else
			src.color = "#ffffff" // In case the material is null
		src.overlays = null
		src.colored = FALSE
		usr.visible_message("<span class='alert'>[usr] clears the [src.name].</span>", "<span class='alert'>You clear the [src.name].</span>")

	New()
		. = ..()
		banner_holder.appearance_flags = RESET_COLOR
		src.underlays.Add(banner_holder)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/pen/crayon))
			if(src.colored)
				chosen_overlay = tgui_input_list(user, "What do you want to draw?", "Drawings Options", choosable_overlays)
				if (!chosen_overlay) return
				var/mutable_appearance/new_overlay = mutable_appearance(src.icon, chosen_overlay)
				new_overlay.appearance_flags = RESET_COLOR
				new_overlay.color = W.color
				src.overlays.Add(new_overlay)
				logTheThing(LOG_STATION, user, "Drew a [chosen_overlay] in the [src] with [W] at [log_loc(user)].")
				desc = "A banner, colored and decorated"
				if(istype(W,/obj/item/pen/crayon/rainbow))
					var/obj/item/pen/crayon/rainbow/R = W
					R.font_color = random_saturated_hex_color(1)
					R.color_name = hex2color_name(R.font_color)
					R.color = R.font_color

			else
				src.color = W.color
				src.colored = TRUE
				desc = "A colored banner, try adding some drawings to it with a crayon!"

		if(istool(W,TOOL_SNIPPING | TOOL_CUTTING | TOOL_SAWING))
			user.visible_message("<span class='alert'>[user] cuts off the [src.name] with [W].</span>", "<span class='alert'>You cut off the [src.name] with [W].</span>")
			var/obj/item/material_piece/cloth/C = new(user.loc)
			if (src.material) C.setMaterial(src.material)
			else C.setMaterial(getMaterial("cotton")) // In case the material is null
			qdel(src)

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		if (usr.stat || usr.restrained() || !can_reach(usr, src))
			return

		else
			if(tgui_alert(usr, "Are you sure you want to clear the banner?", "Confirmation", list("Yes", "No")) == "Yes")
				clear_banner()
			else
				return
