/// A borrow of stock
/datum/stock/borrow
	var/broker = ""
	var/borrower = ""
	var/datum/stock/ticker/stock = null
	var/lease_expires = 0
	var/lease_time = 0
	var/grace_time = 0
	var/grace_expires = 0
	var/share_amount = 0
	var/share_debt = 0
	var/deposit = 0
	var/offer_expires = 0
