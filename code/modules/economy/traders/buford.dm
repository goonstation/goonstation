/datum/trader/buford
	// Stoner frog.
	// Buys and sells drugs, gardening stuff, etc. Is sometimes REALLY fucking high.
	name = "Buford Tenin"
	picture = "gethighfrog.png"
	crate_tag = "BUFO420"
	hiketolerance = 30
	base_patience = list(10,15)
	chance_leave = 66
	chance_arrive = 100

	max_goods_buy = 4
	max_goods_sell = 6

	base_goods_buy = list(/datum/commodity/trader/buford/vennecure,
	/datum/commodity/trader/buford/megaweed,
	/datum/commodity/trader/buford/whiteweed,
	/datum/commodity/trader/buford/omegaweed,
	/datum/commodity/trader/buford/psilocybin,
	/datum/commodity/trader/buford/pizza)

	base_goods_sell = list(/datum/commodity/trader/buford/alienseeds,
	/datum/commodity/trader/buford/weedseeds,
	/datum/commodity/trader/buford/powerplant,
	/datum/commodity/trader/buford/mutriant,
	/datum/commodity/trader/buford/groboost,
	/datum/commodity/trader/buford/fruitful,
	/datum/commodity/trader/buford/topcrop,
	/datum/commodity/trader/buford/weedkiller)// 8

	dialogue_greet = list("Hey man. Got the good shit for sale, yeah.",
	"Sup brother, what's goin' on. Got the damn fresh shit for you here.",
	"Hey, how's it goin? Got the best shit right here, you know it.")
	dialogue_leave = list("GET OUT.")
	dialogue_purchase = list("Aw yeah. I know you're gonna enjoy this shit, man.",
	"Thanks man. You always come through. Enjoy the shit, ha ha.",
	"Good buys, man, good buys. Got more deals if you're interested?")
	dialogue_haggle_accept = list("Ehh... alright. Don't see why not.",
	"Sure, not like I can't just grow more of this shit, ha ha.",
	"I'm down with that.",
	"Yeah okay, cool.",
	"Aight man, but you're really pushing it. Let's make the trade now, yeah?")
	dialogue_haggle_reject = list("Woah man. Bit much there.",
	"I'm not THAT high, dude.",
	"No way man, I gotta make some profit here.",
	"Nooooo way.",
	"Look brother, you're kinda getting on my nerves. How about we just make the trade now?")
	dialogue_wrong_haggle_accept = list("Sure man, I appreciate it.")
	dialogue_wrong_haggle_reject = list("Ha, are you more blazed than I am or what?")
	dialogue_cant_afford_that = list("Sorry brother, you ain't got the ducats for that.",
	"Hey, as much as I like you, I can't just give this stuff away. Get some cash first.",
	"Aw man, how'd you run outta cash already? Bummer.")
	dialogue_out_of_stock = list("Whoops, ha ha, guess I already smo.. er, sold all of that.",
	"Sorry man, none of that left.")

	New()
		..()
		if(prob(10))
			// sometimes he is really, REALLY fucking high and can barely function as a trader
			src.hiketolerance = 95
			src.base_patience = list(50,200)
			src.patience = rand(src.base_patience[1],src.base_patience[2])
			src.dialogue_greet = list("Hey m... uh.. good shit.. i think? Yeah...",
			"Hey man, what if like... oh.. wait, it's you.. wait, where the fuck am I again? Ha ha.",
			"Man I.. ha ha. Got any like.. pizza? Or any shit like that? ...wait, who are you again?")
			src.dialogue_leave = list("GET OUT.")
			src.dialogue_purchase = list("Buy... what now? Uh... sure... I think..?",
			"Thanks man... ha ha. Man what if.. you could buy like... the moon? Ha ha.",
			"Like.. oh shit, wait? Was I supposed to send you some shit?")
			src.dialogue_haggle_accept = list("Ahahaha, fuckin' hilarious man.",
			"Woah that's like.. cosmic, yeah?",
			"Uhh.. fuck I dunno what you even just said? Sure I guess...?",
			"I uh.. yeah okay? I dunno. Is that a good idea?",
			"Uh.. shit.. sure! I think? ..fuck. I'm getting a headache.")
			src.dialogue_haggle_reject = list("Nah man. That's like.. it's like.. if a snake was just like.. a head with a tail, you know?",
			"Fuck... uh.. no. I'm not THAT high.. I.. think? Ha ha...",
			"Fuck that shit. I wanna.. talk about... lighthouses. You don't like lighthouses.. you suck.",
			"Never mind that shit, what if like... fuck. I forgot...",
			"Man no. You're harshing my mellow. Ugh. Think i'm getting a headache.")
			src.dialogue_wrong_haggle_accept = list("Like.. more than I asked for..? Woah, sure... ha ha. I'ma buy pizza.")
			src.dialogue_wrong_haggle_reject = list("What? Sorry, wasn't listening. Ha ha.")
			src.dialogue_cant_afford_that = list("FUCK A DRAGON.. oh wait shit, never mind. Ha ha. Uh.. some shit about not enough cash is on my screen. Dunno.",
			"Uhh.. well my computer says no.. yeah i'ma go with that. I don't give a fuck right now. Ha ha.")
			src.dialogue_out_of_stock = list("Oh I ain't got any of that? Where is it? Where'd it go? Huh.")

// Buford is selling these things

/datum/commodity/trader/buford/alienseeds
	comname = "Strange Seeds"
	comtype = /obj/item/seed/alien
	amount = 5
	price_boundary = list(200,400)
	possible_names = list("Got these weirdo alien plant seeds. Dunno what they'll grow.",
	"I got some strange seeds, maybe they'll grow some good shit. It's some alien shit.",
	"Some real strange alien plant seeds for sale here. I dunno what they grow into.")

/datum/commodity/trader/buford/weedseeds
	comname = "Cannabis Seeds"
	comtype = /obj/item/seed/cannabis
	price_boundary = list(3,5)
	possible_names = list("Got some good weed seeds here for sale.",
	"If you can't get your hands on some weed seeds, i'll sell you some.")

/datum/commodity/trader/buford/powerplant
	comname = "Saltpetre Plant Formula"
	comtype = /obj/item/reagent_containers/glass/bottle/powerplant
	amount = 20
	price_boundary = list(50,100)
	possible_names = list("Got some good nutrients to make your plants more potent.",
	"I'm selling some Powerplant formula. It's great for making your herbs more potent.")

/datum/commodity/trader/buford/mutriant
	comname = "Mutagenic Plant Formula"
	comtype = /obj/item/reagent_containers/glass/bottle/mutriant
	amount = 20
	price_boundary = list(50,100)
	possible_names = list("Got some weird plant nutrients. It makes your plants mutate more often.",
	"Mutriant formula for sale. Makes your plants go all fucked up and weird. In a good way. I hope.")

/datum/commodity/trader/buford/topcrop
	comname = "Potash Plant Formula"
	comtype = /obj/item/reagent_containers/glass/bottle/topcrop
	amount = 20
	price_boundary = list(50,100)
	possible_names = list("Got some plant nutrients that'll encourage huge yields.",
	"Got some good old Top Crop formula. I'm buying most of the good shit you grow, by the way.")

/datum/commodity/trader/buford/groboost
	comname = "Ammonia Plant Formula"
	comtype = /obj/item/reagent_containers/glass/bottle/groboost
	amount = 20
	price_boundary = list(50,100)
	possible_names = list("Selling some great nutrients for making plants grow fast.",
	"Gro-Boost for sale, great nutrients that make your plants grow really quickly.")

/datum/commodity/trader/buford/fruitful
	comname = "Mutadone Plant Formula"
	comtype = /obj/item/reagent_containers/glass/bottle/fruitful
	amount = 20
	price_boundary = list(50,100)
	possible_names = list("Got some nutrients that'll fix any bad shit on your plants.",
	"Got some good Fruitful Farming formula here. Got any ill plants, this'll fix em.")

/datum/commodity/trader/buford/weedkiller
	comname = "Weedkiller"
	comtype = /obj/item/reagent_containers/glass/bottle/weedkiller
	amount = 20
	price_boundary = list(20,60)
	possible_names = list("Selling some good ol' weedkiller. Got any shitty plants, douse em with this.",
	"Weedkiller for sale. Like, for shitty weeds, not good weed. Ha ha.")

// Buford wants these things

/datum/commodity/trader/buford/vennecure
	comname = "Curative Venne"
	comtype = /obj/item/plant/herb/venne/curative
	price_boundary = list(40,250)
	possible_names = list("I hear there's a mutation of Venne that's a cool sunset color. Hit me up with some of that, brother.")

/datum/commodity/trader/buford/megaweed
	comname = "Rainbow Weed"
	comtype = /obj/item/plant/herb/cannabis/mega
	price_boundary = list(50,500)
	possible_names = list("I'd like to buy any rainbow weed you got. Good stuff.")

/datum/commodity/trader/buford/whiteweed
	comname = "White Weed"
	comtype = /obj/item/plant/herb/cannabis/white
	price_boundary = list(50,400)
	possible_names = list("You got any of that white cannabis?")

/datum/commodity/trader/buford/omegaweed
	comname = "Omega Weed"
	comtype = /obj/item/plant/herb/cannabis/omega
	price_boundary = list(500,1500)
	possible_names = list("I hear there's a super-potent mutant strain of Cannabis. Got any of that?")

/datum/commodity/trader/buford/psilocybin
	comname = "Psilocybin Mushrooms"
	comtype = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	price_boundary = list(100,650)
	possible_names = list("You got any magic mushrooms? The Psilocybin kind.")

/datum/commodity/trader/buford/pizza
	comname = "Pizza (Priced per Slice)"
	comtype = /obj/item/reagent_containers/food/snacks/pizza
	price_boundary = list(10,42)
	possible_names = list("You got any pizza?","Got some pizza? I'm dying for a slice, man. Or, like. Maybe a whole one.")
