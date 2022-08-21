/datum/trader/segfault
	name = "Segmentation Fault"
	picture = "segfault.gif"
	crate_tag = "SEGFAULT"

	hiketolerance = 10
	base_patience = list(2,12)
	chance_leave = 10
	chance_arrive = 10

	max_goods_buy = 3
	max_goods_sell = 1

	base_goods_buy = list()
	base_goods_sell = list()

	dialogue_greet = list("Well met. We have several items for sale, as well as several desired articles.",
	"Greetings. We believe it would be mutually profitable for the both of us to engage in commerce.",
	"Hail. We have been led to believe you have several items we are interested in acquiring. Perhaps an agreement could be reached.")
	dialogue_leave = list("We can delay here no longer. These negotiations have become most unproductive. Farewell.",
	"Fool. You have not treated these proceedings with the due consideration they require. We are leaving.",
	"This is a waste of time. We will take our leave to engage in more important pursuits.")
	dialogue_purchase = list("We thank you for your custom.",
	"Excellent. You will receive your goods shortly.",
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

/datum/commodity/trader/vurdalak/roburger
	comname = "Roburgers"
	comtype = /obj/item/reagent_containers/food/snacks/burger/roburger
	price_boundary = list(125,550)
	possible_names = list("There is a burger known to transmute living beings into machines. We wish to purchase these.",
	"We are looking to buy the human culinary creation known as \"Roburgers\".")

/datum/commodity/mat_bar/pharosium
	comname = "Pharosium Bar"
	comtype = /obj/item/material_piece/pharosium
	onmarket = 0
	desc = "A Material Bar of some type."
	desc_buy = "The Promethus Consortium is currently gathering resources for a research project and is willing to buy this item"
	desc_buy_demand = "The colony on Regus X has had their main power reactor break down and need this item for repairs"
	price = 70
	baseprice = 70
	upperfluc = 30
	lowerfluc = -30
