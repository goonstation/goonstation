/datum/zoldorfitem
	var/name = ""
	var/path = ""
	var/cost = ""
	var/stock
	var/list/raw_list

	proc/on_bought(var/mob/living/carbon/human/user)
		return 0

	proc/soul_cost()
		if(isnum(src.cost))
			return 0
		return text2num(copytext(cost, 1, length(cost)))

//database used to construct the zlist and zsecuritylist

//soul items
/datum/zoldorfitem/demonichealing
	name = "Demonic Healing"
	path = /obj/item/reagent_containers/food/snacks/plant/potato
	cost = "25%"
	stock = "i"

	on_bought(var/mob/living/carbon/human/user)
		boutput(user, "<span class='alert'><b>Your wounds fade away, but at a cost...</b></span>")
		user.full_heal()
		return 1

/*
/datum/zoldorfitem/zoldorfdeck
	name = "Normal Deck of Cards"
	path = /obj/item/zoldorfdeck
	cost = "75%"
	stock = 1
*/

/datum/zoldorfitem/weighteddice
	name = "Weighted Dice"
	path = /obj/item/dice/weighted
	cost = "10%"
	stock = 8

/datum/zoldorfitem/demon
	name = "Summon Demon"
	path = /obj/item/zspellscroll/demon
	cost = "30%"
	stock = "i"

/datum/zoldorfitem/hat
	name = "Magician's Hat Trick"
	path = /obj/item/zspellscroll/hat
	cost = "20%"
	stock = "i"

/datum/zoldorfitem/presto
	name = "Presto!"
	path = /obj/item/zspellscroll/presto
	cost = "20%"
	stock = "i"

//credit items
/datum/zoldorfitem/soulsell101
	name = "Selling Your Soul"
	path = /obj/item/paper/soulsell101
	cost = 1
	stock = 10

/datum/zoldorfitem/tarot
	name = "Deck of Tarot Cards"
	path = /obj/item/card_box/tarot
	cost = 25
	stock = 5

/datum/zoldorfitem/zolscroll
	name = "Weird Burrito"
	path = /obj/item/zolscroll
	cost = 100
	stock = "i"
