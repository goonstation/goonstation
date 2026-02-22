/datum/trader/gragg
	// Rockworm guy.
	// Always buys mineral items from the station. Very honest and straightforward.
	name = "Gragg"
	picture = "gragg.png"
	crate_tag = "GRAGG"
	hiketolerance = 15
	base_patience = list(4,8)
	chance_leave = 10
	chance_arrive = 33

	base_goods_buy = alist(
		TRADER_RARITY_COMMON = list(/datum/commodity/trader/gragg/rock,
			/datum/commodity/trader/gragg/mauxite,
			/datum/commodity/trader/gragg/bohrum,
			/datum/commodity/trader/gragg/cobryl,
			/datum/commodity/trader/gragg/syreline
		),
		TRADER_RARITY_UNCOMMON = list(),
		TRADER_RARITY_RARE = list(/datum/commodity/trader/gragg/starstone)
	)

	base_goods_sell = alist(
		TRADER_RARITY_COMMON = list(/datum/commodity/trader/gragg/char,
			/datum/commodity/trader/gragg/erebite,
			/datum/commodity/trader/gragg/cerenkite,
			/datum/commodity/trader/gragg/plasmastone,
			/datum/commodity/trader/gragg/uqill,
			/datum/commodity/trader/gragg/artifact
		),
		TRADER_RARITY_UNCOMMON = list(),
		TRADER_RARITY_RARE = list()
	)

	dialogue_greet = list("HELLO. WANT BUY TASTY ROCKS. TRADE?",
	"HUNGRY. WANT ORE FOR EAT. TRADE?",
	"WANT DELICIOUS ORE. SELL YOU NOT SO DELICIOUS ORE. TRADE?")
	dialogue_leave = list("UGH. FUCK THIS.",
	"YOU TOO STUPID. GOING ELSEWHERE NOW.",
	"SQUISHY BRAIN TOO DUMB. STONE BRAIN BETTER. LEAVING NOW.")
	dialogue_purchase = list("ENJOY. GOT TASTY ROCKS TO TRADE?",
	"NOT KNOW WHY WANT THAT. BUT YOURS NOW ANYWAY.",
	"DEAL. NOW, GOT ORE FOR ME?")
	dialogue_haggle_accept = list("UGH. FINE.",
	"OKAY. BUT LESS TALK. MORE SELL ORE.",
	"FUCK SAKE. FINE.",
	"FINE. WHATEVER. CAN HAVE ORE YET?",
	"FINE. BUT ENOUGH TALK. TRADE NOW OR FORGET IT.")
	dialogue_haggle_reject = list("NO.",
	"NOT *THAT* HUNGRY. CHRIST.",
	"NOT GOOD DEAL. YOU STUPID?",
	"NO. NO. NO.",
	"NO. NO MORE TALK. TRADE NOW OR FORGET IT.")
	dialogue_wrong_haggle_accept = list("OK. NOT GOING COMPLAIN.")
	dialogue_wrong_haggle_reject = list("WHAT? NOT MAKE SENSE. YOU STUPID?")
	dialogue_cant_afford_that = list("NOT ENOUGH CREDITS. MAYBE SELL ORE TO ME FIRST.",
	"NO. TOO EXPENSIVE FOR YOU.",
	"HUMAN BANK ACCOUNT NOT HAVE ENOUGH DELICIOUS GOLD.")
	dialogue_out_of_stock = list("SORRY. NO MORE OF THAT.",
	"RAN OUT OF THAT.")

// Gragg is selling these things

/datum/commodity/trader/gragg/char
	comname = "Char"
	comtype = /obj/item/raw_material/char
	amount = 100
	price_boundary = list(PAY_UNTRAINED,PAY_UNTRAINED*2)
	possible_names = list("SELLING CHAR. NOT EVEN FOOD.",
	"SELLING CHAR ORE. TRIED TO COOK. BURNT IT.",
	"SELLING CHAR. FLAKY. GROSS.")

/datum/commodity/trader/gragg/erebite
	comname = "Strange Red Rock"
	comtype = /obj/item/raw_material/erebite
	amount = 5
	price_boundary = list(PAY_DOCTORATE*2,PAY_DOCTORATE*4)
	possible_names = list("SELLING GROSS SPICY ROCK. NOT GOOD EAT.",
	"SELLING WEIRD RED ROCK. GIVES GAS.",
	"SELLING TERRIBLE TO EAT RED ROCK.")

/datum/commodity/trader/gragg/cerenkite
	comname = "Toxic Blue Rock"
	comtype = /obj/item/raw_material/cerenkite
	amount = 5
	price_boundary = list(PAY_DOCTORATE,PAY_DOCTORATE*2)
	possible_names = list("SELLING BAD TASTING ROCK. NOT GOOD EAT.",
	"SELLING GLOWY BLUE ROCK. MAKES SICK.",
	"SELLING TERRIBLE TO EAT BLUE ROCK.")

/datum/commodity/trader/gragg/plasmastone
	comname = "Volatile Purple Rock"
	comtype = /obj/item/raw_material/plasmastone
	amount = 5
	price_boundary = list(PAY_DOCTORATE*2,PAY_DOCTORATE*4)
	possible_names = list("SELLING AWFUL PURPLE ROCK. TASTE TERRIBLE.",
	"SELLING NASTY PURPLE ROCK. EXPLODE KIND OF EASY.",
	"SELLING TERRIBLE TO EAT PURPLE ROCK.")

/datum/commodity/trader/gragg/uqill
	comname = "Rock Worm Poop"
	comtype = /obj/item/raw_material/uqill
	amount = 5
	price_boundary = list(PAY_IMPORTANT,PAY_IMPORTANT*2)
	possible_alt_types = list(/obj/item/raw_material/gemstone)
	alt_type_chance = 10
	possible_names = list("SELLING ROCK WORM POOP. NOT KNOW WHY YOU WANT THAT. BUT THERE IT IS.",
	"SELLING ROCK WORM POOP. NOT EATING THAT.",
	"SELLING SHIT. LITERAL SHIT. NEED MONEY OKAY. NO JUDGING.")

/datum/commodity/trader/gragg/artifact
	comname = "Unknown Item"
	comtype = /obj/artifact_type_spawner/gragg
	amount = 1
	price_boundary = list(PAY_IMPORTANT,PAY_EMBEZZLED)
	possible_alt_types = list(/obj/item/raw_material/miracle)
	alt_type_chance = 5
	possible_names = list("SELLING WEIRD THING I DUG UP. DONT KNOW WHAT IS.",
	"ODD LITTLE THING. DUG IT UP. NO IDEA. CAN BUY IF WANT.")

// Gragg wants these things

/datum/commodity/trader/gragg/rock
	comname = "Rock"
	comtype = /obj/item/raw_material/rock
	price_boundary = list(PAY_UNTRAINED/10,PAY_UNTRAINED/5)
	possible_names = list("BUYING PLAIN ROCK. NOT ORE, JUST ROCK. STOCKING UP ON FOOD.",
	"BUYING PLAIN ROCK. NOT METAL OR CRYSTAL, JUST STONE.")

/datum/commodity/trader/gragg/mauxite
	comname = "Mauxite"
	comtype = /obj/item/raw_material/mauxite
	price_boundary = list(PAY_UNTRAINED/2,PAY_UNTRAINED)
	possible_names = list("BUYING MAUXITE. CRUNCHY AND DELICIOUS.",
	"BUYING MAUXITE. GOOD MEAL FOR LITHOVORE. HELPS GROW STRONG CARAPACE.")

/datum/commodity/trader/gragg/bohrum
	comname = "Bohrum"
	comtype = /obj/item/raw_material/bohrum
	price_boundary = list(PAY_TRADESMAN,PAY_DOCTORATE)
	possible_names = list("BUYING BOHRUM. GOES GOOD IN STONE SOUP.",
	"BUYING BOHRUM. VERY DENSE. GOOD AND FILLING.")

/datum/commodity/trader/gragg/cobryl
	comname = "Cobryl"
	comtype = /obj/item/raw_material/cobryl
	price_boundary = list(PAY_TRADESMAN,PAY_DOCTORATE)
	possible_names = list("BUYING COBRYL. MAKE GOOD SNACK.",
	"BUYING COBRYL. TASTY.")

/datum/commodity/trader/gragg/syreline
	comname = "Syreline"
	comtype = /obj/item/raw_material/syreline
	price_boundary = list(PAY_DOCTORATE,PAY_IMPORTANT)
	possible_names = list("BUYING SYRELINE. NICE SWEET TREAT NOW AND THEN.",
	"BUYING SYRELINE. NOT TOO MANY THOUGH. DON'T WANT FAT.")

/datum/commodity/trader/gragg/starstone
	comname = "Rare star-shaped jewel"
	comtype = /obj/item/raw_material/starstone
	price_boundary = list(PAY_DONTBUYIT,PAY_DONTBUYIT*2)
	possible_names = list("WANT BUY PALE BLUE STAR-SHAPED GEMSTONE. EXTREMELY RARE. SELL TO ME IF FIND.")
