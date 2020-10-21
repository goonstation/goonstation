/datum/trader/vurdalak
	// Dude in a cloak in the dark.
	// A creepy guy who buys and sells really suspicious shit.
	name = "Vurdalak the Shrouded"
	picture = "cloakdude.png"
	crate_tag = "SHROUD"
	hiketolerance = 10
	base_patience = list(2,12)
	chance_leave = 10
	chance_arrive = 10

	max_goods_buy = 3
	max_goods_sell = 1

	base_goods_buy = list(/datum/commodity/trader/vurdalak/meat,
	/datum/commodity/trader/vurdalak/brains,
	/datum/commodity/trader/vurdalak/deathweed,
	/datum/commodity/trader/vurdalak/toxicvenne,
	/datum/commodity/trader/vurdalak/amanita,
	/datum/commodity/trader/vurdalak/roburger)
	base_goods_sell = list(/datum/commodity/trader/vurdalak/artifact)

	dialogue_greet = list("Well met. We have several items for sale, as well as several desired articles.",
	"Greetings. We believe it would be mutually profitable for the both of us to engage in commerce.",
	"Hail. We have been led to believe you have several items we are interested in acquiring. Perhaps an agreement could be reached.")
	dialogue_leave = list("We can delay here no longer. These negotiations have become most unproductive. Farewell.",
	"Fool. You have not treated these proceedings with the due consideration they require. We are leaving.",
	"This is a waste of time. We will take our leave to engage in more important pursuits.")
	dialogue_purchase = list("We thank you for your custom.",
	"Excellent. You will recieve your goods shortly.",
	"As we suspected, this has benefited us both.")
	dialogue_haggle_accept = list("If that is what it takes to facilitate this transaction, so be it.",
	"Very well. You should find this compromise to be adequate.",
	"We would find your proposition offensive, were we not in such need of commerce.",
	"We find this compromise to be... satisfactory. Barely.",
	"We will afford you no further leniency. Make the transaction now.")
	dialogue_haggle_reject = list("We find your offer unacceptable. We suggest you begin taking this proposition seriously.",
	"This is no time for levity, fool.",
	"That offer is unacceptable.",
	"We refuse your foolish and nonsensical offer.",
	"Enough of your nonsense. Make a trade now, or we shall depart.")
	dialogue_wrong_haggle_accept = list("Offer accepted.")
	dialogue_wrong_haggle_reject = list("It makes no sense for you to spend more credits than we have requested, you fool.")
	dialogue_cant_afford_that = list("You cannot afford that transaction.",
	"Your budget is too diminished to fulfill these terms.",
	"We do not give charity. You require more credits.")
	dialogue_out_of_stock = list("Unfortunatley, we no longer possess any of that item to sell.",
	"Our stocks of that item have been exhausted.")

	set_up_goods()
		..()
		var/datum/commodity/the_commodity = null
		var/pickwhich = rand(1,3)
		switch(pickwhich)
			if(1)
				the_commodity = /datum/commodity/trader/vurdalak/obsidiancrown
			if(2)
				the_commodity = /datum/commodity/trader/vurdalak/ancientarmor
			if(3)
				the_commodity = /datum/commodity/trader/vurdalak/relic
		var/datum/commodity/COM = new the_commodity(src)
		src.goods_buy += COM

// Vurdalak is selling these things

/datum/commodity/trader/vurdalak/artifact
	comname = "Alien Artifacts"
	comtype = /obj/artifact_type_spawner/vurdalak
	amount = 4
	price_boundary = list(4000,6000)
	possible_names = list("We are selling artifacts of alien origin. We cannot verify their purpose.",
	"We have a collection of alien artifacts you may be interested in.")

// Vurdalak wants these things

/datum/commodity/trader/vurdalak/meat
	comname = "Raw Meat"
	comtype = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	price_boundary = list(30,150)
	possible_names = list("Our stocks of raw meat are running low. The condition is of no concern.",
	"We wish to purchase raw meat of any kind. Spoilage is not an issue.")

/datum/commodity/trader/vurdalak/brains
	comname = "Brains"
	comtype = /obj/item/organ/brain/
	price_boundary = list(1000,3500)
	possible_names = list("Our stocks of brains are running low. We care not for the condition.",
	"We require the excised brains of living creatures. If you have such an item, sell it to us.")

/datum/commodity/trader/vurdalak/deathweed
	comname = "Deathweed Cannabis"
	comtype = /obj/item/plant/herb/cannabis/black
	price_boundary = list(75,400)
	possible_names = list("We require black leaves from a mutated cannabis plant.",
	"There is a mutation of the cannabis plant that renders the plant a deep black. We wish to purchase leaves of this strain.")

/datum/commodity/trader/vurdalak/toxicvenne
	comname = "Black Venne"
	comtype = /obj/item/plant/herb/venne/toxic
	price_boundary = list(50,500)
	possible_names = list("The venne plant has a mutation that turns its fibers black. Sell us these fibers.",
	"We require black venne fibers from a mutated venne plant.")

/datum/commodity/trader/vurdalak/amanita
	comname = "Amanita Mushrooms"
	comtype = /obj/item/reagent_containers/food/snacks/mushroom/amanita
	price_boundary = list(180,520)
	possible_names = list("We wish to buy white amanita mushrooms.",
	"We require white mushrooms grown from a mutated mushroom plant.")

/datum/commodity/trader/vurdalak/roburger
	comname = "Roburgers"
	comtype = /obj/item/reagent_containers/food/snacks/burger/roburger
	price_boundary = list(125,550)
	possible_names = list("There is a burger known to transmute living beings into machines. We wish to purchase these.",
	"We are looking to buy the human culinary creation known as \"Roburgers\".")

// Unique things that Vurdalak wants

/datum/commodity/trader/vurdalak/obsidiancrown
	comname = "Strange Relic"
	comtype = /obj/item/clothing/head/void_crown
	price_boundary = list(20000,100000)
	possible_names = list({"We are looking to buy a reputedly unique relic that is said to be jet-black and horned in appearance,
	and hails from another dimension of space and time. We are willing to pay a considerable premium to purchase it,
	should you locate the curio in question."})

/datum/commodity/trader/vurdalak/ancientarmor
	comname = "Black Armor"
	possible_names = list({"We have heard of an unusual relic that takes on the appearance of a black suit of armor adorned with bones.
	If you come by such an item, we strongly advise against wearing it. Instead, sell it to us, we have a great deal of funds
	allocated specifically for purchasing this item."})
	comtype = /obj/item/clothing/suit/armor/ancient
	price_boundary = list(20000,100000)

/datum/commodity/trader/vurdalak/relic
	comname = "Strange Relic"
	possible_names = list({"We are seeking a reputed relic that takes the appearance of a small grey box adorned with a simplistic
	symbol. If you have such an item, we are willing to pay a very large price for it."})
	comtype = /obj/item/relic
	price_boundary = list(15000,75000)
