/* ====== CONSTRUCTION WORKER ====== */
// Used for Construction game mode, where you build the station
/datum/outfit/station_builder
	outfit_name = "Station Builder"

	slot_belt = list(/obj/item/storage/belt/utility/prepared)
	slot_under = list(/obj/item/clothing/under/rank/engineer)
	slot_shoes = list(/obj/item/clothing/shoes/magnetic)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	right_hand = list(/obj/item/tank/jetpack)
	slot_eyes = list(/obj/item/clothing/glasses/construction)
	left_pocket = list(/obj/item/currency/spacecash/fivehundred)
	right_pocket = list(/obj/item/room_planner)
	slot_outer = list(/obj/item/clothing/suit/space/engineer)
	slot_head = list(/obj/item/clothing/head/helmet/space/engineer)
	slot_mask = list(/obj/item/clothing/mask/breath)

	backpack_items = list(/obj/item/rcd/construction, /obj/item/rcd_ammo/big, /obj/item/rcd_ammo/big, /obj/item/material_shaper,/obj/item/room_marker)

/* ====== EXTRA STATION JOBS ====== */
// Dailies and random job outfits

/datum/outfit/boxer
	outfit_name = "Boxer"

	slot_under = list(/obj/item/clothing/under/shorts)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_gloves = list(/obj/item/clothing/gloves/boxing)

/datum/outfit/dungeoneer
	outfit_name = "Dungeoneer"

	slot_belt = list(/obj/item/device/pda2)
	slot_mask = list(/obj/item/clothing/mask/skull)
	slot_under = list(/obj/item/clothing/under/color/brown)
	slot_outer = list(/obj/item/clothing/suit/cultist/nerd)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	left_pocket = list(/obj/item/pen/omni)
	right_pocket = list(/obj/item/paper)
	backpack_items = list(/obj/item/storage/box/nerd_kit)

/datum/outfit/mailman
	outfit_name = "Mailman"

	slot_under = list(/obj/item/clothing/under/misc/mail/syndicate)
	slot_head = list(/obj/item/clothing/head/mailcap)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_ears = list(/obj/item/device/radio/headset/mail)
	backpack_items = list(/obj/item/wrapping_paper, /obj/item/paper_bin, /obj/item/scissors, /obj/item/stamp)

/datum/outfit/tourist
	outfit_name = "Tourist"

	slot_belt = list(/obj/item/storage/fanny)
	slot_under = list(/obj/item/clothing/under/misc/tourist)
	left_pocket = list(/obj/item/camera_film)
	right_pocket = list(/obj/item/currency/spacecash/tourist)
	slot_shoes = list(/obj/item/clothing/shoes/tourist)
	left_hand = list(/obj/item/camera)
	right_hand = list(/obj/item/storage/photo_album)

/datum/outfit/musician
	outfit_name = "Musician"

	slot_under = list(/obj/item/clothing/under/suit/pinstripe)
	slot_head = list(/obj/item/clothing/head/flatcap)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	backpack_items = list(/obj/item/instrument/saxophone,/obj/item/instrument/guitar,/obj/item/instrument/bagpipe,/obj/item/instrument/fiddle)

/datum/outfit/barber
	outfit_name = "Barber"

	slot_under = list(/obj/item/clothing/under/misc/barber)
	slot_head = list(/obj/item/clothing/head/boater_hat)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	left_pocket = list(/obj/item/scissors)
	right_pocket = list(/obj/item/razor_blade)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

/datum/outfit/mime
	outfit_name = "Mime"

	slot_belt = list(/obj/item/device/pda2)
	slot_head = list(/obj/item/clothing/head/mime_bowler)
	slot_mask = list(/obj/item/clothing/mask/mime)
	slot_under = list(/obj/item/clothing/under/misc/mime/alt)
	slot_outer = list(/obj/item/clothing/suit/scarf)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	left_pocket = list(/obj/item/pen/crayon/white)
	right_pocket = list(/obj/item/paper)
	backpack_items = list(/obj/item/baguette)

/datum/outfit/attorney
	outfit_name = "Attorney"

	slot_under = list(/obj/item/clothing/under/misc/lawyer)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	left_hand = list(/obj/item/storage/briefcase)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

/datum/outfit/vice_officer
	outfit_name = "Vice Officer"

	slot_back = list(/obj/item/storage/backpack/withO2)
	slot_belt = list(/obj/item/device/pda2/security)
	slot_under = list(/obj/item/clothing/under/misc/vice)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list( /obj/item/device/radio/headset/security)
	left_pocket = list(/obj/item/storage/security_pouch)
	right_pocket = list(/obj/item/requisition_token/security)

/datum/outfit/forensic_technician
	outfit_name = "Forensic Technician"

	slot_belt = list(/obj/item/device/pda2/security)
	slot_under = list(/obj/item/clothing/under/color/darkred)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_ears = list(/obj/item/device/radio/headset/security)
	left_pocket = list(/obj/item/device/detective_scanner)
	backpack_items = list(/obj/item/tank/emergency_oxygen)

/datum/outfit/toxins_researcher
	outfit_name = "Toxins Researcher"

	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_under = list(/obj/item/clothing/under/rank/scientist)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_mask = list(/obj/item/clothing/mask/gas)
	left_hand = list(/obj/item/tank/air)
	slot_ears = list(/obj/item/device/radio/headset/research)

/datum/outfit/chemist
	outfit_name = "Chemist"

	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_under = list(/obj/item/clothing/under/rank/scientist)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_ears = list(/obj/item/device/radio/headset/research)

/datum/outfit/research_assistant
	outfit_name = "Research Assistant"

	slot_under = list(/obj/item/clothing/under/color/white)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	slot_belt = list(/obj/item/device/pda2/toxins)
	slot_ears = list(/obj/item/device/radio/headset/research)

/datum/outfit/medical_assistant
	outfit_name = "Medical Assistant"

	slot_under = list(/obj/item/clothing/under/scrub = 30,/obj/item/clothing/under/scrub/teal = 14,/obj/item/clothing/under/scrub/blue = 14,/obj/item/clothing/under/scrub/purple = 14,/obj/item/clothing/under/scrub/orange = 14,/obj/item/clothing/under/scrub/pink = 14)
	slot_shoes = list(/obj/item/clothing/shoes/red)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	slot_belt = list(/obj/item/device/pda2/medical)

/datum/outfit/atmospheric_technician
	outfit_name = "Atmospherish Technician"

	slot_belt = list(/obj/item/device/pda2/atmos)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/atmos)
	slot_under = list(/obj/item/clothing/under/misc/atmospheric_technician)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	left_hand = list(/obj/item/storage/toolbox/mechanical)
	left_pocket = list(/obj/item/device/analyzer/atmospheric)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	backpack_items = list(/obj/item/tank/mini_oxygen,/obj/item/crowbar)

/datum/outfit/tech_assistant
	outfit_name = "Technical Assistant"

	slot_under = list(/obj/item/clothing/under/color/yellow)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/engineer)
	slot_belt = list(/obj/item/device/pda2/technical_assistant)

/datum/outfit/space_cowboy
	outfit_name = "Space Cowboy"

	slot_under = list(/obj/item/clothing/under/rank/det)
	slot_belt = list(/obj/item/gun/kinetic/single_action/colt_saa)
	slot_head = list(/obj/item/clothing/head/cowboy)
	slot_mask = list(/obj/item/clothing/mask/cigarette/random)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_shoes = list(/obj/item/clothing/shoes/cowboy)
	left_pocket = list(/obj/item/cigpacket/random)
	right_pocket = list(/obj/item/device/light/zippo/gold)
	left_hand = list(/obj/item/whip)
	slot_back = list(/obj/item/storage/backpack/satchel)

/datum/outfit/actor
	outfit_name = "Hollywood Actor"

	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/suit/purple)
	slot_belt = list(/obj/item/device/pda2)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_back = list(/obj/item/storage/backpack)

/datum/outfit/medical_specialist
	outfit_name = "Medical Specialist"

	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/medic)
	slot_under = list(/obj/item/clothing/under/scrub/maroon)
	slot_outer = list(/obj/item/clothing/suit/apron/surgeon)
	slot_head = list(/obj/item/clothing/head/bouffant)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	right_hand = list(/obj/item/storage/firstaid/docbag)
	left_pocket = list(/obj/item/device/pda2/medical_director)

/datum/outfit/vip
	outfit_name = "VIP"

	slot_under = list(/obj/item/clothing/under/suit/black)
	slot_head = list(/obj/item/clothing/head/that)
	slot_eyes = list(/obj/item/clothing/glasses/monocle)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	left_hand = list(/obj/item/storage/secure/sbriefcase)
	backpack_items = list(/obj/item/baton/cane)

/datum/outfit/inspector
	outfit_name = "Inspector"

	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_under = list(/obj/item/clothing/under/misc/lawyer/black) // so they can slam tables
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_outer = list(/obj/item/clothing/suit/armor/NT)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	left_hand = list(/obj/item/storage/briefcase)
	right_hand = list(/obj/item/device/ticket_writer)
	backpack_items = list(/obj/item/device/flash)

/datum/outfit/director
	outfit_name = "Regional Director"

	slot_back = list(/obj/item/storage/backpack)
	slot_belt = list(/obj/item/device/pda2/heads)
	slot_under = list(/obj/item/clothing/under/misc/NT)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_ears = list(/obj/item/device/radio/headset/command)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_outer = list(/obj/item/clothing/suit/wcoat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	left_hand = list(/obj/item/clipboard/with_pen)
	backpack_items = list(/obj/item/device/flash)

/datum/outfit/diplomat
	outfit_name = "Diplomat"

	left_hand = list(/obj/item/storage/briefcase)
	slot_under = list(/obj/item/clothing/under/misc/lawyer)
	slot_shoes = list(/obj/item/clothing/shoes/brown)

/datum/outfit/testsubject
	outfit_name = "Test Subject"

	slot_under = list(/obj/item/clothing/under/shorts)
	slot_mask = list(/obj/item/clothing/mask/monkey_translator)

/datum/outfit/union
	outfit_name = "Union Rep"

	slot_under = list(/obj/item/clothing/under/misc/lawyer)
	left_hand = list(/obj/item/storage/briefcase)
	slot_shoes = list(/obj/item/clothing/shoes/brown)

/datum/outfit/salesman
	outfit_name = "Salesman"

	slot_outer = list(/obj/item/clothing/suit/merchant)
	slot_under = list(/obj/item/clothing/under/gimmick/merchant)
	slot_head = list(/obj/item/clothing/head/merchant_hat)
	left_hand = list(/obj/item/storage/briefcase)
	slot_shoes = list(/obj/item/clothing/shoes/brown)

/datum/outfit/coach
	outfit_name = "Coach"

	slot_under = list(/obj/item/clothing/under/jersey)
	slot_outer = list(/obj/item/clothing/suit/armor/vest/macho)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_shoes = list(/obj/item/clothing/shoes/white)
	left_pocket = list(/obj/item/instrument/whistle)
	slot_gloves = list(/obj/item/clothing/gloves/boxing)
	backpack_items = list(/obj/item/football,/obj/item/football,/obj/item/basketball,/obj/item/basketball)

/datum/outfit/journalist
	outfit_name = "Journalist"

	slot_under = list(/obj/item/clothing/under/suit/red)
	slot_head = list(/obj/item/clothing/head/fedora)
	left_hand = list(/obj/item/storage/briefcase)
	left_pocket = list(/obj/item/camera)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	backpack_items = list(/obj/item/camera_film/large)

/datum/outfit/beekeeper
	outfit_name = "Apiculturist"

	slot_under = list(/obj/item/clothing/under/rank/beekeeper)
	slot_outer = list(/obj/item/clothing/suit/bio_suit/beekeeper)
	slot_head = list(/obj/item/clothing/head/bio_hood/beekeeper)
	left_pocket = list(/obj/item/reagent_containers/food/snacks/beefood)
	right_pocket = list(/obj/item/paper/book/from_file/bee_book)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2/botanist)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	backpack_items = list(/obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/bee_egg_carton, /obj/item/reagent_containers/food/snacks/beefood, /obj/item/reagent_containers/food/snacks/beefood)

/datum/outfit/angler
	outfit_name = "Angler"

	slot_under = list(/obj/item/clothing/under/rank/angler)
	slot_head = list(/obj/item/clothing/head/black)
	slot_shoes = list(/obj/item/clothing/shoes/galoshes/waders)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	backpack_items = list(/obj/item/fishing_rod/basic)

/datum/outfit/souschef
	outfit_name = "Sous-Chef"

	slot_belt = list(/obj/item/device/pda2/chef)
	slot_under = list(/obj/item/clothing/under/misc/souschef)
	slot_shoes = list(/obj/item/clothing/shoes/chef)
	slot_head = list(/obj/item/clothing/head/souschefhat)
	slot_outer = list(/obj/item/clothing/suit/apron)
	slot_ears = list(/obj/item/device/radio/headset/civilian)

/datum/outfit/waiter
	outfit_name = "Waiter"

	slot_under = list(/obj/item/clothing/under/rank/bartender)
	slot_outer = list(/obj/item/clothing/suit/wcoat)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	left_hand = list(/obj/item/plate/tray)
	left_pocket = list(/obj/item/cloth/towel/white)
	backpack_items = list(/obj/item/storage/box/glassbox,/obj/item/storage/box/cutlery)

/datum/outfit/pharmacist
	outfit_name = "Pharmacist"

	slot_belt = list(/obj/item/device/pda2/medical)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/shirt_pants)
	slot_outer = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	backpack_items = list(/obj/item/storage/box/beakerbox, /obj/item/storage/pill_bottle/cyberpunk)

/datum/outfit/radioshowhost
	outfit_name = "Radio Show Host"

	slot_ears = list(/obj/item/device/radio/headset/command/radio_show_host)
	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_under = list(/obj/item/clothing/under/shirt_pants)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/reagent_containers/food/drinks/coffee)
	backpack_items = list(/obj/item/device/camera_viewer, /obj/item/device/audio_log, /obj/item/storage/box/record/radio/host)

/datum/outfit/psychiatrist
	outfit_name = "Psychiatrist"

	slot_eyes = list(/obj/item/clothing/glasses/regular)
	slot_belt = list(/obj/item/device/pda2/medical)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/shirt_pants)
	slot_outer = list(/obj/item/clothing/suit/labcoat)
	slot_ears = list(/obj/item/device/radio/headset/medical)
	left_pocket = list(/obj/item/reagent_containers/food/drinks/tea)
	right_pocket = list(/obj/item/reagent_containers/food/drinks/bottle/gin)
	backpack_items = list(/obj/item/luggable_computer/personal, /obj/item/clipboard/with_pen, /obj/item/paper_bin, /obj/item/stamp)

/datum/outfit/artist
	outfit_name = "Artist"

	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_under = list(/obj/item/clothing/under/misc/casualjeansblue)
	slot_head = list(/obj/item/clothing/head/mime_beret)
	slot_ears = list(/obj/item/device/radio/headset/civilian)
	left_pocket = list(/obj/item/currency/spacecash/twenty)
	right_pocket = list(/obj/item/pen/pencil)
	left_hand = list(/obj/item/storage/toolbox/artistic)
	backpack_items = list(/obj/item/canvas, /obj/item/canvas, /obj/item/storage/box/crayon/basic ,/obj/item/paint_can/random)

/* ====== HALLOWEEN OUTFITS ====== */

/datum/outfit/blue_clown
	outfit_name = "Blue Clown"

	slot_mask = list(/obj/item/clothing/mask/clown_hat/blue)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/misc/clown/blue)
	slot_shoes = list(/obj/item/clothing/shoes/clown_shoes/blue)
	slot_belt = list(/obj/item/storage/fanny/funny)
	left_pocket = list(/obj/item/bananapeel)
	right_pocket = list(/obj/item/device/pda2/clown)
	left_hand = list(/obj/item/instrument/bikehorn)

/datum/outfit/candy_salesman
	outfit_name = "Candy Salesman"

	slot_head = list(/obj/item/clothing/head/that/purple)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/suit/purple)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/storage/pill_bottle/cyberpunk)
	right_pocket = list(/obj/item/storage/pill_bottle/catdrugs)
	backpack_items = list(/obj/item/storage/goodybag, /obj/item/kitchen/everyflavor_box, /obj/item/item_box/heartcandy, /obj/item/kitchen/peach_rings)

/datum/outfit/pumpkin_head
	outfit_name = "Pumpkin Head"

	slot_head = list(/obj/item/clothing/head/pumpkin)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/color/orange)
	slot_shoes = list(/obj/item/clothing/shoes/orange)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/reagent_containers/food/snacks/candy/candy_corn)
	right_pocket = list(/obj/item/item_box/assorted/stickers/stickers_limited)

/datum/outfit/wanna_bee
	outfit_name = "WannaBEE"

	slot_head = list(/obj/item/clothing/head/headband/bee)
	slot_outer = list(/obj/item/clothing/suit/bee)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/rank/beekeeper)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee)
	right_pocket = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee/buddy)
	backpack_items = list(/obj/item/reagent_containers/food/snacks/b_cupcake, /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly)

/datum/outfit/dracula
	outfit_name = "Discount Dracula"

	slot_head = list(/obj/item/clothing/head/that)
	slot_outer = list(/obj/item/clothing/suit/gimmick/vampire)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/gimmick/vampire)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/reagent_containers/syringe)
	right_pocket = list(/obj/item/reagent_containers/glass/beaker/large)
	slot_back = list(/obj/item/storage/backpack/satchel)

/datum/outfit/werewolf
	outfit_name = "Discount Werewolf"

	slot_head = list(/obj/item/clothing/head/werewolf)
	slot_under = list(/obj/item/clothing/under/shorts)
	slot_outer = list(/obj/item/clothing/suit/gimmick/werewolf)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

/datum/outfit/mummy
	outfit_name = "Discount Mummy"

	slot_mask = list(/obj/item/clothing/mask/mummy)
	slot_under = list(/obj/item/clothing/under/gimmick/mummy)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)

/datum/outfit/hotdog
	outfit_name = "Hot Dog"

	slot_under = list(/obj/item/clothing/under/shorts)
	slot_outer = list(/obj/item/clothing/suit/gimmick/hotdog)
	slot_shoes = list(/obj/item/clothing/shoes/black)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/randoseru)
	left_pocket = list(/obj/item/shaker/ketchup)
	right_pocket = list(/obj/item/shaker/mustard)

/datum/outfit/godzilla
	outfit_name = "Discount Godzilla"

	slot_head = list(/obj/item/clothing/head/biglizard)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/color/green)
	slot_outer = list(/obj/item/clothing/suit/gimmick/dinosaur)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/toy/figure)
	right_pocket = list(/obj/item/toy/figure)

/datum/outfit/discount_macho
	outfit_name = "Discount Macho Man"

	slot_head = list(/obj/item/clothing/head/helmet/macho)
	slot_eyes = list(/obj/item/clothing/glasses/macho)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/gimmick/macho)
	slot_shoes = list(/obj/item/clothing/shoes/macho)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/reagent_containers/food/snacks/ingredient/sugar)
	right_pocket = list(/obj/item/sticker/ribbon/first_place)

/datum/outfit/ghost
	outfit_name = "Ghost"

	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_outer = list(/obj/item/clothing/suit/bedsheet)
	slot_ears = list(/obj/item/device/radio/headset)

/datum/outfit/ghost_buster
	outfit_name = "Ghost Buster"

	slot_ears = list(/obj/item/device/radio/headset/ghost_buster)
	slot_eyes = list(/obj/item/clothing/glasses/regular/ecto/goggles)
	slot_under = list(/obj/item/clothing/under/shirt_pants)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_back = list(/obj/item/storage/backpack/satchel)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/magnifying_glass)
	right_pocket = list(/obj/item/shaker/salt)
	backpack_items = list(/obj/item/device/camera_viewer, /obj/item/device/audio_log, /obj/item/gun/energy/ghost)

/datum/outfit/angel
	outfit_name = "Angel"

	slot_head = list(/obj/item/clothing/head/laurels/gold)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/gimmick/birdman)
	slot_shoes = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/coin)
	right_pocket = list(/obj/item/plant/herb/cannabis/white/spawnable)

/datum/outfit/vendor
	outfit_name = "Costume Vendor"

	slot_under = list(/obj/item/clothing/under/gimmick/trashsinglet)
	slot_shoes = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	slot_back = list(/obj/item/storage/backpack/satchel/anello)
	backpack_items = list(/obj/item/storage/box/costume/abomination,
	/obj/item/storage/box/costume/werewolf/odd,
	/obj/item/storage/box/costume/monkey,
	/obj/item/storage/box/costume/eighties,
	/obj/item/clothing/head/zombie)

/datum/outfit/devil
	outfit_name = "Devil"

	slot_head = list(/obj/item/clothing/head/devil)
	slot_mask = list(/obj/item/clothing/mask/moustache/safe)
	slot_ears = list(/obj/item/device/radio/headset)
	slot_under = list(/obj/item/clothing/under/misc/lawyer/red/demonic)
	slot_shoes = list(/obj/item/clothing/shoes/sandal)
	slot_belt = list(/obj/item/device/pda2)
	left_pocket = list(/obj/item/pen/fancy/satan)
	right_pocket = list(/obj/item/contract/juggle)

/datum/outfit/superhero
	outfit_name = "Discount Vigilante Superhero"

	slot_ears = list(/obj/item/device/radio/headset/security)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud/superhero)
	slot_gloves = list(/obj/item/clothing/gloves/latex/blue)
	slot_under = list(/obj/item/clothing/under/gimmick/superhero)
	slot_shoes = list(/obj/item/clothing/shoes/tourist)
	slot_belt = list(/obj/item/storage/belt/utility/superhero)
	right_pocket = list(/obj/item/device/pda2)

/datum/outfit/pickle
	outfit_name = "Pickle"

	slot_ears = list(/obj/item/device/radio/headset)
	slot_outer = list(/obj/item/clothing/suit/gimmick/pickle)
	slot_under = list(/obj/item/clothing/under/color/green)
	slot_belt = list(/obj/item/device/pda2)
	slot_shoes = list(/obj/item/clothing/shoes/black)

/* ====== SYNDICATE ====== */

/datum/outfit/syndicate_operative
	outfit_name = "Syndicate Operative"

/datum/outfit/syndicate_operative/leader
	outfit_name = "Syndicate Operative Commander"

/datum/outfit/syndicate_weak
	outfit_name = "Junior Syndicate Operative"

	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_belt = list(/obj/item/gun/kinetic/pistol)
	slot_under = list(/obj/item/clothing/under/misc/syndicate)
	slot_outer = list()
	slot_head = list()
	slot_shoes = list(/obj/item/clothing/shoes/swat/noslip)
	slot_gloves = list(/obj/item/clothing/gloves/swat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list()
	slot_mask = list(/obj/item/clothing/mask/gas/swat/syndicate)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	right_pocket = list(/obj/item/storage/pouch/bullet_9mm)
	left_hand = list()
	right_hand = list()
	backpack_items = list(
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/suit/space/syndicate)

/datum/outfit/syndicate_weak/no_ammo
	outfit_name = "Poorly Equipped Junior Syndicate Operative"

	right_pocket = list()

// hidden jobs for nt-so vs syndicate spec-ops

/datum/outfit/syndicate_specialist
	outfit_name = "Syndicate Special Operative"

	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_belt = list(/obj/item/storage/belt/gun/pistol)
	slot_under = list(/obj/item/clothing/under/misc/syndicate)
	slot_outer = list(/obj/item/clothing/suit/space/syndicate/specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_shoes = list(/obj/item/clothing/shoes/swat/noslip)
	slot_gloves = list(/obj/item/clothing/gloves/swat)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses)
	slot_ears = list(/obj/item/device/radio/headset/syndicate) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/swat/syndicate)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	right_pocket = list(/obj/item/storage/pouch/assault_rifle)
	left_hand = list()
	right_hand = list(/obj/item/tank/jetpack/syndicate)
	backpack_items = list(/obj/item/gun/kinetic/assault_rifle,
							/obj/item/old_grenade/stinger/frag,
							/obj/item/breaching_charge,
							/obj/item/remote/syndicate_teleporter)

/* ====== PIRATES ====== */

/datum/outfit/pirate
	outfit_name = "Space Pirate"

	slot_belt = list()
	slot_back = list()
	slot_under = list()
	slot_shoes = list()
	slot_head = list()
	slot_eyes = list()
	slot_ears = list()
	left_pocket = list()
	right_pocket = list()

/datum/outfit/pirate/First_mate
	outfit_name = "Space Pirate First Mate"

/datum/outfit/pirate/captain
	outfit_name = "Space Pirate Captain"

/* ====== JUICER ====== */

/datum/outfit/juicer_specialist
	outfit_name = "Juicer Security"

	slot_back = list(/obj/item/gun/energy/blaster_cannon)
	slot_belt = list(/obj/item/storage/fanny)

/* ====== NANOTRASEN ====== */

/datum/outfit/ntso_specialist
	outfit_name = "Nanotrasen Special Operative"

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security/ntso)
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_outer = list(/obj/item/clothing/suit/space/ntso)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_gloves = list(/obj/item/clothing/gloves/swat/NT)
	slot_eyes = list(/obj/item/clothing/glasses/nightvision/sechud/flashblocking)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	left_pocket = list(/obj/item/device/pda2/heads)
	right_pocket = list(/obj/item/storage/ntsc_pouch/ntso)
	backpack_items = list(/obj/item/storage/firstaid/regular,
							/obj/item/clothing/head/NTberet,
							/obj/item/currency/spacecash/fivehundred)

/datum/outfit/nt_engineer
	outfit_name = "Nanotrasen Emergency Repair Technician"

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/utility/nt_engineer)
	slot_under = list(/obj/item/clothing/under/rank/engineer)
	slot_outer = list(/obj/item/clothing/suit/space/industrial/nt_specialist)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_shoes = list(/obj/item/clothing/shoes/magnetic)
	slot_gloves = list(/obj/item/clothing/gloves/yellow)
	slot_eyes = list(/obj/item/clothing/glasses/toggleable/meson)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	backpack_items = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/sheet/steel/fullstack,
							/obj/item/sheet/glass/reinforced/fullstack)

/datum/outfit/nt_medical
	outfit_name = "Nanotrasen Emergency Medic"

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/medical/prepared)
	slot_under = list(/obj/item/clothing/under/rank/medical)
	slot_outer = list(/obj/item/clothing/suit/bio_suit/paramedic/armored)
	slot_head = list(/obj/item/clothing/head/helmet/space/ntso)
	slot_shoes = list(/obj/item/clothing/shoes/brown)
	slot_gloves = list(/obj/item/clothing/gloves/latex)
	slot_eyes = list(/obj/item/clothing/glasses/healthgoggles/upgraded)
	slot_ears = list(/obj/item/device/radio/headset/command/nt) //needs their own secret channel
	slot_mask = list(/obj/item/clothing/mask/gas/NTSO)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	backpack_items = list(/obj/item/storage/firstaid/regular,
							/obj/item/device/flash,
							/obj/item/reagent_containers/glass/bottle/omnizine,
							/obj/item/reagent_containers/glass/bottle/ether)

/datum/outfit/nt_security
	outfit_name = "Nanotrasen Security Consultant"

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/storage/belt/security/ntsc) //special secbelt subtype that spawns with the NTSO gear inside
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/NTberet)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_gloves = list(/obj/item/clothing/gloves/swat/NT)
	slot_eyes = list(/obj/item/clothing/glasses/sunglasses/sechud)
	slot_ears = list(/obj/item/device/radio/headset/command/nt/consultant) //needs their own secret channel
	left_pocket = list(/obj/item/device/pda2/ntso)
	right_pocket = list(/obj/item/currency/spacecash/fivehundred)
	backpack_items = list(/obj/item/storage/firstaid/regular,
							/obj/item/clothing/head/helmet/space/ntso,
							/obj/item/clothing/suit/space/ntso,
							/obj/item/cloth/handkerchief/nt)

/* ====== GIMMICKS ====== */

/datum/outfit/headminer
	outfit_name = "Head of Mining"

	slot_belt = list(/obj/item/device/pda2/mining)
	slot_under = list(/obj/item/clothing/under/rank/overalls)
	slot_shoes = list(/obj/item/clothing/shoes/orange)
	slot_gloves = list(/obj/item/clothing/gloves/black)
	slot_ears = list(/obj/item/device/radio/headset/command/ce)
	backpack_items = list(/obj/item/tank/emergency_oxygen,/obj/item/crowbar)

/datum/outfit/machoman
	outfit_name = "Macho Man"

	slot_ears = list()
	slot_back = list()
	backpack_items = list()

/datum/outfit/football
	outfit_name = "Football Player"

/datum/outfit/slasher
	outfit_name = "The Slasher"

	slot_ears = list()
	slot_back = list()
	backpack_items = list()

/datum/outfit/samurai
	outfit_name = "Samurai"

	slot_under = list(/obj/item/clothing/under/gimmick/hakama/random)
	slot_head = list(/obj/item/clothing/head/bandana/random_color)
	slot_shoes = list(/obj/item/clothing/shoes/sandal/magic/wizard)
	left_hand = list(/obj/item/dojohammer)
	slot_belt = list(/obj/item/swords_sheaths/katana/reverse)
	slot_back = list(/obj/item/storage/backpack/randoseru)

/datum/outfit/created
	outfit_name = "Created Outfit"
