//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Posters And Decals ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/decal/poster/wallsign/morrigan
	name = "ADF Morrigan"
	desc = "Poster of ADF Morrigan, looks very fancy!"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "morrigan"

/obj/decal/poster/wallsign/report
	name = "Vigilance Poster"
	desc = "Keen eyes keep the station safe! Report suspicious behavior to Security."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "report"

/obj/decal/poster/wallsign/betray
	name = "Not too late!"
	desc = "You have a place here, with us, the Syndicate."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "n_for_s"

/obj/decal/poster/wallsign/looselips
	name = "Loose Lips"
	desc = "Loose Lips Sink SpaceShips."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "looselips"

/obj/decal/poster/wallsign/you4s
	name = "Join Security"
	desc = "Help keep your station secure today."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "you_4_s"

/obj/decal/poster/wallsign/mod21
	name = "Mod. 21 Deneb"
	desc = "Our new staple ! With multiple functions!"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "mod21"

/obj/decal/poster/wallsign/syndicateposter
	name = "Syndicate Poster"
	desc = "A poster promoting the Syndicate."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "wall_poster_syndicate"

/obj/decal/poster/wallsign/syndicatebanner
	name = "Syndicate Banner"
	desc = "A banner promoting the Syndicate"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "syndicateposter"

/obj/decal/poster/wallsign/nomask
	name = "No Masks"
	desc = "No Masks in this area."
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "nomask"

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Fake Objects ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/item/broken_stun
	name = "broken taser gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_taser"
	desc = "Totally busted..."
	item_state = "taser"
	force = 5

/obj/item/broken_signi
	name = "destroyed signifer gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_signi"
	desc = "It's burnt, the cell must've exploded"
	item_state = "signifer_2"
	force = 5

/obj/item/broken_mod21
	name = "unsalvagable mod.21 gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_mod21"
	desc = "About as useful as a stick."
	item_state = "hafpistol"
	force = 5
/obj/item/spent_scrambler
	name = "Used Syringe"
	desc = "Hmm... have you seen this item before ?"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "spent_scrambler"
	force = 0
/obj/item/broken_optio
	name = "spent optio gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_optio"
	desc = "Mangled beyond repair..."
	item_state = "protopistol"
	force = 5

/obj/item/strangesyringe
	name = "Strange Syringe"
	desc = "Gelgoos Solution 500mg... what's that ?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "syringemorg"
	item_state = "emerg_inj-yellow"
	force = 1
/obj/item/broken_cornicern
	name = "Dinged up cornicern gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_cornicern"
	desc = "totally busted."
	item_state = "gun"
	force = 5
/obj/decal/fakeobjects/hafmech
	name = "Strange Machine"
	desc = "This does not come in smaller sizes..."
	icon_state = "mech"
	icon = 'icons/obj/adventurezones/morrigan/decoration.dmi'
	bound_width = 128
	bound_height = 128
	density = TRUE
	anchored = TRUE

/obj/decal/fakeobjects/missile
	name = "Escape Missile"
	icon = 'icons/obj/large/32x64.dmi'
	bound_width = 32
	bound_height = 64
	anchored = TRUE
	density = TRUE

/obj/decal/fakeobjects/missile/syndicate
	icon_state = "arrival_missile_synd"


/obj/decal/fakeobjects/pod
	name = "Pod"
	icon = 'icons/effects/64x64.dmi'
	bound_width = 64
	bound_height = 64
	anchored = TRUE
	density = TRUE

/obj/decal/fakeobjects/pod/syndicate/racepod
	name = "Syndicate Security Pod"
	desc = "A Syndicate-crafted light pod, seems locked."
	icon_state = "pod_raceRed"

/obj/decal/fakeobjects/pod/nanotrasen/racepod
	name = "Nanotrasen Light Pod"
	desc = "A Nanotrasen light Pod! It seems locked.. "
	icon_state = "pod_raceBlue"

/obj/decal/fakeobjects/pod/black
	name = "Black Pod"
	desc = "A black pod, seems locked."
	icon_state = "pod_black"

/obj/decal/fakeobjects/miniputt
	name = "Miniputt"
	icon = 'icons/obj/ship.dmi'
	anchored = TRUE
	density = TRUE


/obj/decal/fakeobjects/miniputt/syndicate/raceputt
	name = "Syndicate Security MiniPutt"
	desc = "A Syndicate-crafted light miniputt, seems locked."
	icon_state = "putt_raceRed_alt"

/obj/decal/fakeobjects/miniputt/nanotrasen/raceputt
	name = "Nanotrasen Light MiniPutt"
	desc = "A Nanotrasen light miniputt! It seems locked..."
	icon_state = "putt_raceBlue"

/obj/decal/fakeobjects/miniputt/black
	name = "Black Miniputt"
	desc = "A black miniputt, seems locked."
	icon_state = "putt_black"

/obj/decal/fakeobjects/weapon_racks
	name = "Weapon Rack"
	icon = 'icons/obj/weapon_rack.dmi'
	anchored = TRUE
	density = TRUE

/obj/decal/fakeobjects/weapon_racks/plasmagun1
	name = "\improper Plasma Rifle Rack"
	icon_state = "plasmarifle_rack1"

/obj/decal/fakeobjects/gunbotrep
	name = "Unfinished drones"
	icon = 'icons/obj/adventurezones/morrigan/gunbot.dmi'
	density = TRUE
	anchored = TRUE

/obj/decal/fakeobjects/gunbotrep/gunrep1
	name = "Unfinised Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep1"

/obj/decal/fakeobjects/gunbotrep/inactivesentinel
	name = "Inactive Sentinel Unit"
	desc = "Syndicate's fearsome model, this one seems to be inactive."
	icon = 'icons/mob/critter/robotic/gunbot.dmi'
	icon_state = "nukebot"


/obj/decal/fakeobjects/gunbotrep/gunrep2
	name = "Unfinished Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep2"
/obj/decal/fakeobjects/gunbotrep/gunrep3
	name = "Damaged Sentinel"
	desc = "Seems worse for wear."
	icon_state = "gunbot_rep3"

/obj/decal/fakeobjects/gunbotrep/gunrep4
	name = "Unfinished Sentinel"
	desc = "Hafgan's fearsome model, this one seems to be unfinished."
	icon_state = "gunbot_rep4"

/obj/decal/fakeobjects/gunbotrep/clawbot
	name = "Unfinished CQC Unit"
	icon_state = "clawbot_rep"

/obj/decal/fakeobjects/gunbotrep/gunbotarm
	name = "Gun Arm"
	icon_state = "gunbot_arm"

/obj/decal/fakeobjects/gunbotrep/gunbotarm2
	name = "Gun Arm"
	icon_state = "gunbot_arm2"

/obj/decal/fakeobjects/gunbotrep/engineerbot
	name = "Unfinished 	MULTI Unit"
	icon_state = "engineerbot_rep"

/obj/decal/fakeobjects/gunbotrep/riotbot
	name = "Unfinished Riot Unit"
	icon_state = "riotbot"
/obj/decal/fakeobjects/gunbotrep/jacklift
	name = "Jack-lift"
	desc = "Used to lift up units that need repairs or require finishing."
	icon_state = "jacklift"

/obj/decal/fakeobjects/gunbotrep/clawbotinactive
	name = "Inactive CQC Unit"
	icon_state = "clawbotina"

/obj/decal/fakeobjects/gunbotrep/engineerbotinactive
	name = "Inactive MULTI Unit"
	icon_state = "engina"

/obj/decal/fakeobjects/gunbotrep/medibotinactive
	name = "Inactive Medical Unit"
	icon_state = "medibotina"

/obj/decal/fakeobjects/gunbotrep/riotbotina
	name = "Inactive Riot Unit"
	icon_state = "riotbotina"

/obj/decal/fakeobjects/tpractice
	name = "Target Practice Dummy"
	desc = "You can just IMAGINE why it's blue..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bopbagsyd"
	anchored = TRUE
	density = 1

/obj/decal/fakeobjects/shipart
	name = "random gun"
	desc = "big boy"
	bound_height = 96
	bound_width = 96
	anchored = TRUE
	icon = 'icons/obj/adventurezones/morrigan/shipart.dmi'

/obj/decal/fakeobjects/shipart/beamcannon
	name = "Mod. 504 'Stella Proditor' "
	desc = "A Massive mounted weapon able to rotate 180 degrees. Fires concentrated superheated plasma bursts that wreak havoc on stations and ships alike."
	icon_state = "beamcannon"

/obj/decal/fakeobjects/shipart/fire
	name = "Thruster"
	desc = "It's fuel burning..."
	icon_state = "fuel"

/obj/decal/fakeobjects/factory
	name = "Machine"
	icon = 'icons/obj/adventurezones/morrigan/factory64x64.dmi'
	bound_width = 64
	bound_height = 64
	anchored = TRUE
	density = 1

/obj/decal/fakeobjects/factory/claw
	name = "Factory Arm"
	icon_state = "arm"
	anchored = TRUE

/obj/decal/fakeobjects/factory/drill
	name = "Factory Arm"
	icon_state = "drill"
	anchored = TRUE

/obj/decal/fakeobjects/factory/bolt
	name = "Factory Arm"
	icon_state = "bolter"
	anchored = TRUE

/obj/decal/fakeobjects/factory/weld
	name = "Factory Weld"
	icon_state = "welder"
	anchored = TRUE

/obj/decal/fakeobjects/midfactory
	name = "Machine"
	icon = 'icons/obj/large/32x48.dmi'
	bound_width = 32
	bound_height = 48

/obj/decal/fakeobjects/midfactory/enginething
	name = "Factory Machine"
	icon_state = "stomper0"

/obj/decal/fakeobjects/midfactory/enginething2
	name = "Factory Machine"
	icon_state = "bigatmos1_1"

/obj/decal/fakeobjects/midfactory/enginething3
	name = "Factory Machine"
	icon_state = "bigatmos2"

/obj/decal/fakeobjects/cabinet1
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab1"

/obj/decal/fakeobjects/cabinet2
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab2"

/obj/decal/fakeobjects/cabinet3
	name = "Machine Things"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "cab3"

/obj/decal/fakeobjects/ships
	name = "Drone Pods"
	icon = 'icons/obj/adventurezones/morrigan/ships.dmi'
	anchored = TRUE
	density = TRUE

/obj/decal/fakeobjects/ships/dronerep
	name = "Unfinished Drone"
	icon_state = "dronerep"

/obj/decal/fakeobjects/ships/dronerep2
	name = "Unfinished Drone"
	icon_state = "dronerep_2"

/obj/decal/fakeobjects/ships/dronesnip
	name = "Prototype Drone"
	icon_state = "dronesnip"

/obj/decal/fakeobjects/ships/dronerep3
	name = "Unfinished Drone"
	icon_state = "dronerep_3"

/obj/decal/fakeobjects/ships/dronerep4
	name = "Unfinished Drone"
	icon_state = "dronerep_4"

/obj/decal/fakeobjects/ships/dronebomb
	name = "Prototype Drone"
	icon_state = "dronebomb"

/obj/decoration/ntcratesmall/syndicrate
	name = "Metal Crate"
	icon_state = "syndiecrate"

/obj/decoration/ntcratesmall/ammo
	name = "Ammo Crate"
	desc = "Seems to be holding large ammo."
	icon_state = "ammo"

/obj/decoration/ntcratesmall/ammoloader
	name = "Ammo Loader"
	desc = "Seems to be holding large ammo."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "loader"

/obj/decoration/ntcratesmall/opencrate
	name = "Open Crate"
	icon_state = "opencrate"

//varedits made me insane
//could probably move to other file later?
/obj/decal/fakeobjects/fake_vendor
	name = "broken vending machine"
	desc = "The goods inside the machine probably expired before you were even born."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/vending.dmi'
	icon_state = "coffee"

	med
		icon_state = "med"

	med_off
		icon_state = "med-off"

	grife
		icon_state = "grife"

	grife_falled
		icon_state = "grife-fallen"

	robust
		icon_state = "robust"

	broken_robust
		icon_state = "robust-broken"

	snack
		icon_state = "snack"

	broken_snack
		icon_state = "snack-broken"

	standart_frame
		icon_state = "standard-frame"

//▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ Floor Icon ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
/obj/decal/morrigansign
	name = ""
	bound_height = 160
	bound_width = 160
	icon = 'icons/obj/adventurezones/morrigan/morrigan_icon.dmi'
	mouse_opacity = 0
	anchored = ANCHORED
	density = 0
	plane = PLANE_FLOOR

/obj/decal/morrigansign/logo
	icon_state = "morrigan"

/obj/decal/morrigansign/lero
	icon_state = "lero"
