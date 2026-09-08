/datum/trader/steve
	// Totally human person and not a ling wearing a smiley mask
	// Buys brains and stuff reminding them of themselves or icemoon, sells some "normal" organic stuff & friends from home.
	name = "Human Steve"
	picture = "shambles.png" // art by cogworks
	crate_tag = "STEVE"
	hiketolerance = 10
	base_patience = list(4,6)
	chance_leave = 5
	chance_arrive = 10
	chance_restock = 15

	base_goods_buy = alist(
		TRADER_RARITY_COMMON = list(/datum/commodity/trader/steve/brains,
			/datum/commodity/trader/steve/ice,
			/datum/commodity/trader/steve/fire_suit
		),
		TRADER_RARITY_UNCOMMON = list(/datum/commodity/trader/steve/dna,
						/datum/commodity/trader/steve/brain_burgers,
		),
		TRADER_RARITY_RARE = list(/datum/commodity/trader/steve/lingfish)
	)

	base_goods_sell = alist(
		TRADER_RARITY_COMMON = list(/datum/commodity/trader/steve/lingmeat),
		TRADER_RARITY_UNCOMMON = list(/datum/commodity/trader/steve/lingblood),
		TRADER_RARITY_RARE = list(/datum/commodity/trader/steve/live_brullbar,
			/datum/commodity/trader/steve/ling_recording
		)
	)

	dialogue_greet = list("Hello fellow human friend! We- I would like to participate in human trade!",
	"Yes, yes we're just a normal guy man person! You're always invited to our ship friend- MEAT! FLESH! BRAIN- we mean um.. uh...",
	"We are many! Join us- Err, in trade of course! Yes, trade... What did we mean by join? We... I mean I meant join in commercial partnership!")
	dialogue_leave = list("Mean human! Bad human! We hate you! *steve spits something green at the console and the connection cuts*",
	"Sorry fellow human person earthling, We... We mean I must go on a hunt! We, um, errr we mean go for a human pizza lunch break!",
	"We go! We leave! We stop trade now! We don't want to perscive you now! We- *connection terminated*")
	dialogue_purchase = list("Yes yes! Buy buy! Your human money is most appericated",
	"Good deal human friend, why don't you come over and we shake on it? Our ship is safe! We are safe to be around!",
	"Yes yes yes yes, good good good good, Keep buying, yes.")
	dialogue_haggle_accept = list("Errr... Fine! Fine! We accept, but only if you <b>promise</b> to pay us a visit later.",
	"We- I accept, fine fine, but don't try our patiance...")
	dialogue_haggle_reject = list("Bad! Bad! Bad! Bad deal we hate!",
	"Mean Mean! all of my three normal human brains thought about your offer and hated it!",
	"*Monster scream* No no no no! Bad price!")
	dialogue_wrong_haggle_accept = list("Yes yes yes! Sure we accept- Customer's brain to dumb to assimilate- Shut up us!")
	dialogue_wrong_haggle_reject = list("What?")
	dialogue_cant_afford_that = list("You don't have enough human money! We are disappointed in your inability to- Broke! Broke human! Ew!- I'm sorry...",
	"More! More More More More More! Get us more credits first!")
	dialogue_out_of_stock = list("Sorry, We're sorry friend- Your gluttony sickens us! We mean, we ran out of the thing you want human friend...",
	"We- I ran of this! We hunt for more later!")

// Things steve wants:

/datum/commodity/trader/steve/brains
	comname = "Yummy Brains"
	comtype = /obj/item/organ/brain
	price_boundary = list(PAY::DOCTORATE,PAY::DOCTORATE*2)
	possible_names = list("Yes yes yes! Brain, We- I want brains! Please send human ones!",
	"Hungry! Hungry hungry hungry- errm, we need brains for... science")

/datum/commodity/trader/steve/brain_burgers
	comname = "Yummy Cooked Brains"
	comtype = /obj/item/reagent_containers/food/snacks/burger/brainburger
	price_boundary = list(PAY::DOCTORATE*1.2,PAY::DOCTORATE*2)
	possible_names = list("Brains yes, Cooked ones this time!",
	"Please don't ask why we want them human person friend.")

/datum/commodity/trader/steve/fire_suit
	comname = "Fire Fighter's Suit"
	comtype = /obj/item/clothing/suit/hazard/fire
	price_boundary = list(PAY::TRADESMAN*2.5,PAY::TRADESMAN*3) // They *really* hate fire
	possible_names = list("Suit that stops fire? Need! We need! Give it to us!",
	"Fire is bad! Bad bad bad! We want- NEED! DEMEND! REQUIRE! Erm, just sell those to us please")

/datum/commodity/trader/steve/ice
	comname = "Ice"
	comtype = /obj/item/raw_material/ice
	price_boundary = list(PAY::UNTRAINED/10,PAY::UNTRAINED/5)
	possible_names = list("Cold! We love cold! give us cold cold water!",
	"Ice! Yes yes! Reminds us of homeworld! Erm, We mean earth of course!")

/datum/commodity/trader/steve/dna
	comname = "DNA syringes"
	comtype = list(/obj/item/genetics_injector/dna_injector)
	price_boundary = list(PAY::TRADESMAN,PAY::TRADESMAN*1.4)
	possible_names = list("Glass tubes! Pointy bit! Full of human DNA! Give! Give!",
	"Injector of human DNA. Give it to us! Give!")

/datum/commodity/trader/steve/lingfish
	comname = "Fish Shaped Like Steve"
	comtype = /obj/item/reagent_containers/food/fish/lingfish
	price_boundary = list(PAY::DOCTORATE*2,PAY::DOCTORATE*2.5)
	possible_names = list("We heard, heard of fish shaped like us! We want!")

// Things steve sells:

/datum/commodity/trader/steve/lingmeat
	comname = "Normal meat"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling
	amount = 30
	price_boundary = list(PAY::TRADESMAN*0.8,PAY::TRADESMAN*1.5)
	possible_names = list("Very normal meat! We- I promise it only sometimes bite!",
	"Just regular good ol' meat, dont ask why it has legs please!")

/datum/commodity/trader/steve/lingblood
	comname = "Normal Human Blood"
	comtype = /obj/item/reagent_containers/iv_drip/blood/ling
	amount = 25
	price_boundary = list(PAY::DOCTORATE*2,PAY::DOCTORATE*3)
	possible_names = list("We love to donate blood! Put our blood in everyone!",
	"Normal human blood donated by ourselves, please do not heat it.")

/datum/commodity/trader/steve/live_brullbar
	comname = "Pale Humanoid"
	comtype = /mob/living/critter/brullbar // lol, lmao even -ANNmagedon
	amount = 1
	price_boundary = list(PAY::DONTBUYIT*0.8,PAY::DONTBUYIT*1.2)
	possible_names = list("Pale creature from homeworld, very loud.",
	"Creature from homeworld, cries too much, please buy.")

/datum/commodity/trader/steve/ling_recording
	comname = "Our Mixtape"
	comtype = /obj/item/sound_tape/ling_recording
	amount = 1
	price_boundary = list(PAY::DONTBUYIT*1.5,PAY::DONTBUYIT*3.5)
	possible_names = list("The recording of us- me, a human who is a singular person, singing. We feel sheepish about selling this.")
