/datum/trader/pianzi_hundan
	// Lizardman dude in chinese finery.
	// A total asshole who'll rip you off most of the time.
	name = "Pianzi Hundan"
	picture = "lizardman.png"
	crate_tag = "PIANZI"
	hiketolerance = 33
	base_patience = list(12,20)
	chance_leave = 25
	chance_arrive = 25
	asshole = 1

	max_goods_buy = 2
	max_goods_sell = 5

	base_goods_buy = list(/datum/commodity/trader/pianzi/herbs,
	/datum/commodity/trader/pianzi/crystalglass,
	/datum/commodity/trader/pianzi/telecrystal,
	/datum/commodity/trader/pianzi/artifact,
	/datum/commodity/trader/pianzi/cigarettes)
	base_goods_sell = list(/datum/commodity/trader/pianzi/metal,
	/datum/commodity/trader/pianzi/bees,
	/datum/commodity/trader/pianzi/cameraviewers,
	/datum/commodity/trader/pianzi/scanners,
	/datum/commodity/trader/pianzi/concgloves,
	/datum/commodity/trader/pianzi/medicine,
	/datum/commodity/trader/pianzi/wine,
	/datum/commodity/trader/pianzi/recdrugs,
	/datum/commodity/trader/pianzi/seeds)

	dialogue_greet = list("Why hello there, my good friend! Plenty of wares today, as usual! Care to take a browse?",
	"Ahh, my good friend, a pleasure to see you as always! Come to browse Pianzi's menagerie of delightful goods?",
	"Welcome, welcome my good friend! How nice to see you! Do take advantage of my deals, hee hee! It's why I make them!")
	dialogue_leave = list("My goodness, DO look at the time! I must be off, deals to make! Ta-ta for now, my good friend!",
	"Ah.. I er.. have a business meeting to attend to. I forgot all about it! Ciao for now, my good friend!",
	"Ugh... *cough* Um, I do apologize my good friend, but I must depart. Important business to attend to! Arrivederci!")
	dialogue_purchase = list("Another fine transaction, my good friend! I knew I could count on your raw business acumen!",
	"Another deal for Pianzi. And you, too! Don't you love the fruits of mutual business deals? Hee hee!",
	"Excellent choice, my good friend. Capital! You and I make quite the team when it comes to profits!")
	dialogue_haggle_accept = list("Ah! My good friend, you wound me. I can concede this much, though...",
	"Well, perhaps if we meet halfway... is this an acceptable price?",
	"Oh my. You'll make poor Pianzi go broke at this rate!",
	"Good grief. I thought we were friends? Nevertheless, I can forgive you if we agree on this much...",
	"Well, my good friend. This is my final offer, I'd have to be insane to cut you a better bargain than this!")
	dialogue_haggle_reject = list("Now now, my good friend. Let's not get TOO eager.",
	"Well now! That's just rude! Fortunatley I can forgive you, since we're such good friends.",
	"I don't think I heard you correctly there, my good friend.",
	"Oh come now, I know you don't really mean that.",
	"I can see you're not having the best of days, my good friend. I suggest we make a trade now and stop all this silly haggling, hmm?")
	dialogue_wrong_haggle_accept = list("Why, that's just capital! A wonderful proposition! Don't mind if I do!")
	dialogue_wrong_haggle_reject = list("Ah my good friend, tha- wait, what? Hee hee! I think you typed the wrong number!")
	dialogue_cant_afford_that = list("Oh dear, oh dear. It looks like your reserves of capital are running a little too dry for Pianzi's taste, my good friend!",
	"Ahh, such a pity. You haven't enough credits! You really aught to stop making deals with those other traders. They're just ripping you off, you know!",
	"Oh my. Not enough credits! That's a shame, such a shame. I thought you had more business sense than this, my good friend!")
	dialogue_out_of_stock = list("Hmm. That item appears to be out of stock! No suprise, with such quality! Hee hee!",
	"Oh dear. My reserves of that item have ran out! Too bad, my good friend!")

// Pianzi is selling these things

/datum/commodity/trader/pianzi/metal
	comname = "Sheets of Construction Supplies"
	comtype = /obj/item/sheet/steel
	price_boundary = list(5,9)
	possible_alt_types = list(/obj/item/paper)
	alt_type_chance = 80
	possible_names = list("I am selling sheets of a lightweight and flexible building material! Very useful!",
	"Now for sale, I have these material sheets - very light, very flexible. Could be used for anything, theoretically!")

/datum/commodity/trader/pianzi/bees
	comname = "Live Insects"
	comtype = /obj/critter/domestic_bee
	amount = 10
	price_boundary = list(75,120)
	possible_alt_types = list(/mob/living/critter/small_animal/cockroach)
	alt_type_chance = 50
	possible_names = list("I have a number of very friendly live insects for sale! Very cute too!",
	"I'm now selling some very adorable bugs! They could be very useful for hydroponics work!")

/datum/commodity/trader/pianzi/cameraviewers
	comname = "Camera Viewing Devices"
	comtype = /obj/item/device/camera_viewer
	amount = 3
	price_boundary = list(300,500)
	possible_alt_types = list(/obj/item/device/light/flashlight)
	alt_type_chance = 50
	possible_names = list("Now for sale; a handful of devices that can be used for viewing cameras far more easily!",
	"I happen to have a few devices that will make camera viewing much easier! It's a bargain for this price!")

/datum/commodity/trader/pianzi/scanners
	comname = "Scanning Devices"
	comtype = /obj/item/emeter
	amount = 10
	price_boundary = list(100,500)
	possible_alt_types = list(/obj/item/oreprospector,/obj/item/plantanalyzer,/obj/item/device/analyzer/healthanalyzer)
	alt_type_chance = 40
	possible_names = list("I have some spare scanning devices for sale! Think of all the data you could scan, my good friend!",
	"I seem to have quite a lot of spare left over scanners. I could sell them to you, for a price!")

/datum/commodity/trader/pianzi/concgloves
	comname = "Mining Gloves"
	comtype = /obj/item/clothing/gloves/concussive
	amount = 2
	price_boundary = list(1000,2500)
	possible_alt_types = list(/obj/item/clothing/gloves/black, /obj/item/clothing/gloves/yellow/unsulated)
	alt_type_chance = 70
	possible_names = list("I've got some gloves your miners may find very useful! Very stylish and substantial!",
	"Now for sale, some gloves i've been informed your mining crew will love!")

/datum/commodity/trader/pianzi/medicine
	comname = "Medicine"
	comtype = /obj/item/reagent_containers/glass/beaker/large/brute
	amount = 5
	price_boundary = list(250,1000)
	possible_alt_types = list(/obj/item/reagent_containers/glass/beaker/large/epinephrine,/obj/item/storage/firstaid/old)
	alt_type_chance = 25
	possible_names = list("Everyone needs medicine at some point. Luckily, Pianzi has some for sale!",
	"Heal what ails you with this medicine I have for sale!")

/datum/commodity/trader/pianzi/wine
	comname = "Vintage Drink"
	comtype = /obj/item/reagent_containers/food/drinks/bottle/wine
	amount = 8
	price_boundary = list(25,75)
	possible_alt_types = list(/obj/item/reagent_containers/food/drinks/bottle/vintage)
	alt_type_chance = 50
	possible_names = list("Cause to celebrate? This deal certainly is! Vintage drink of the best quality!",
	"I've come across some very prized vintage drink! Excellent for parties!")

/datum/commodity/trader/pianzi/recdrugs
	comname = "Addiction Aid Patches"
	comtype = /obj/item/reagent_containers/patch/nicotine
	amount = 50
	price_boundary = list(15,150)
	possible_alt_types = list(/obj/item/reagent_containers/patch/LSD)
	alt_type_chance = 33
	possible_names = list("Having trouble with addictive drugs? No worries! Just slap on one of these patches and your worries will go away!",
	"Now for sale, some light drug patches. Addiction won't be a problem if you use these!")

/datum/commodity/trader/pianzi/seeds
	comname = "Unusual Plant Seeds"
	comtype = /obj/item/seed/alien
	price_boundary = list(90,150)
	possible_alt_types = list(/obj/item/seed/creeper)
	alt_type_chance = 75
	possible_names = list("Love growing unusual plants? Then these seeds are for you, my good friend!",
	"Your botanists will love the opportunity to grow these very strange and unusual plant seeds!")

// Pianzi wants these things

/datum/commodity/trader/pianzi/herbs
	comname = "Medical Herbs"
	comtype = /obj/item/plant/herb/
	price_boundary = list(30,250)
	possible_names = list("My good friend, I am rather low on medical herbs right now. Perhaps you could sell me some, hmm?",
	"Everyone's in need of medical herbs, and Pianzi is no exception! I'll pay top premium, as always!")

/datum/commodity/trader/pianzi/crystalglass
	comname = "Crystal Glass"
	comtype = /obj/item/sheet/glass/crystal/
	price_boundary = list(400,600)
	possible_names = list("I have need of some glass made from crystallised plasma, my good friend! I'll pay a very good price!",
	"I'm currently paying a very good price for crystallised plasma glass! It's all the rage, I'm sure you know!")

/datum/commodity/trader/pianzi/telecrystal
	comname = "Telecrystal"
	comtype = /obj/item/raw_material/telecrystal
	price_boundary = list(500,2500)
	possible_names = list("Right now I'm in need of raw Telecrystals. Buying for top price as always!",
	"Telecrystals, weird little things aren't they? What's even more weird is that i'm also buying them for such a great price!")

/datum/commodity/trader/pianzi/artifact
	comname = "Useless Handheld Artifacts"
	comtype = /obj/item/artifact/
	price_boundary = list(1000,4000)
	possible_names = list("I'm collecting handheld artifacts! I only want inert ones, though!",
	"Right now i'd like to get my hands on some inert handheld artifacts! Keep the dangerous ones for yourself though.")

/datum/commodity/trader/pianzi/cigarettes
	comname = "Cigarettes"
	comtype = /obj/item/clothing/mask/cigarette/
	price_boundary = list(60,500)
	possible_names = list("Cigarettes are always a good trade. Right now, I'd like to buy any you have!",
	"Did you know cigarettes are currency on some colonies? That's why I'd like to buy any you can spare!")
