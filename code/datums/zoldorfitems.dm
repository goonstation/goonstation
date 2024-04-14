ABSTRACT_TYPE(/datum/zoldorfitem)
/// Zoldorf Player Shop Item
/datum/zoldorfitem
	/// Name of the Zoldorf item
	var/name = ""
	/// Object path the Zoldorf Item
	var/path = null
	/// Amount of stock (overridden by `infinite`)
	var/stock = 0
	/// Does this item have infinite stock (overrides `stock`)
	var/infinite = FALSE
	/// Base64 image for the UI
	var/img = null

	proc/on_bought(mob/living/carbon/human/user)
		user.put_in_hand_or_drop(new src.path)

	New()
		. = ..()
		if(src.img)
			return
		var/product = src.path
		var/atom/dummy_atom = new product
		sleep(0) // give it a chance to do icon changes
		var/icon/dummy_icon = getFlatIcon(dummy_atom,initial(dummy_atom.dir),no_anim=TRUE)
		qdel(dummy_atom)
		src.img = icon2base64(dummy_icon)

ABSTRACT_TYPE(/datum/zoldorfitem/soul)
/// Zoldorf items that cost part of user's soul
/datum/zoldorfitem/soul
	var/soul_percentage = 0

/datum/zoldorfitem/soul/demonichealing
	name = "Demonic Healing"
	path = /obj/item/reagent_containers/food/snacks/plant/potato
	soul_percentage = 25
	infinite = TRUE

	on_bought(var/mob/living/carbon/human/user)
		boutput(user, SPAN_ALERT("<b>Your wounds fade away, but at a cost...</b>"))
		user.full_heal()
		return 1

/*
/datum/zoldorfitem/soul/zoldorfdeck
	name = "Normal Deck of Cards"
	path = /obj/item/zoldorfdeck
	soul_percentage = 75
	stock = 1
*/

/datum/zoldorfitem/soul/weighteddice
	name = "Weighted Dice"
	path = /obj/item/dice/weighted
	soul_percentage = 10
	stock = 8

/datum/zoldorfitem/soul/demon
	name = "Summon Demon"
	path = /obj/item/zspellscroll/demon
	soul_percentage = 30
	infinite = TRUE

/datum/zoldorfitem/soul/hat
	name = "Magician's Hat Trick"
	path = /obj/item/zspellscroll/hat
	soul_percentage = 20
	infinite = TRUE

/datum/zoldorfitem/soul/presto
	name = "Presto!"
	path = /obj/item/zspellscroll/presto
	soul_percentage = 20
	infinite = TRUE

ABSTRACT_TYPE(/datum/zoldorfitem/credit)
/// Zoldorf items that cost credits
/datum/zoldorfitem/credit
	var/price = 0

/datum/zoldorfitem/credit/soulsell101
	name = "Selling Your Soul"
	path = /obj/item/paper/soulsell101
	price = 1
	stock = 10

/datum/zoldorfitem/credit/tarot
	name = "Deck of Tarot Cards"
	path = /obj/item/card_box/tarot
	price = 25
	stock = 5

/datum/zoldorfitem/credit/zolscroll
	name = "Weird Burrito"
	path = /obj/item/zolscroll
	price = 100
	infinite = TRUE
