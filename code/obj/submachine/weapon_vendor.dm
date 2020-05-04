// Stolen from GTMs
// Meant for nuclear operatives to use to order gear on the battlecruiser

/obj/submachine/GTM
	name = "GTM"
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "gtm"
	desc = "Discount Dan's loves you too!"
	density = 0
	opacity = 0
	anchored = 1

	deconstruct_flags = DECON_MULTITOOL

	var/current_tickets = 0
	var/temp = null
	var/datum/light/light
	var/list/datum/ticket_rewards = list()

	New()
		..()
		ticket_rewards += new/datum/ticket_reward/cap
		ticket_rewards += new/datum/ticket_reward/magnifying_glass
		ticket_rewards += new/datum/ticket_reward/flashlight_module
		ticket_rewards += new/datum/ticket_reward/mug
		ticket_rewards += new/datum/ticket_reward/tonic
		ticket_rewards += new/datum/ticket_reward/ale
		ticket_rewards += new/datum/ticket_reward/peach_drink
		ticket_rewards += new/datum/ticket_reward/fortune_cookie
		ticket_rewards += new/datum/ticket_reward/donut
		ticket_rewards += new/datum/ticket_reward/strudel
		ticket_rewards += new/datum/ticket_reward/peach_rings
		ticket_rewards += new/datum/ticket_reward/cereal
		ticket_rewards += new/datum/ticket_reward/jersey
		ticket_rewards += new/datum/ticket_reward/lshirt_red
		ticket_rewards += new/datum/ticket_reward/lshirt_blue
		ticket_rewards += new/datum/ticket_reward/jacket
		ticket_rewards += new/datum/ticket_reward/labcoat
		ticket_rewards += new/datum/ticket_reward/lighter

		light = new/datum/light/point
		light.set_brightness(0.4)
		light.attach(src)
		light.enable()

	attackby(var/obj/item/I as obj, user as mob)
		if(istype(I, /obj/item/ticket/golden))
			qdel(I)
			boutput(user, "<span class='notice'>You insert the golden ticket into the GTM.</span>")
			src.current_tickets++
			src.updateUsrDialog()
		else
			src.attack_hand(user)
		return

	attack_hand(var/mob/user as mob)
		if(..())
			return

		user.machine = src
		var/dat = "<span style=\"inline-flex\">"
		dat += "<BR>Current balance: [src.current_tickets] tickets"

		if (src.temp)
			dat += src.temp
		else
			dat += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem tickets</A>"

		dat += "<BR><A HREF='?action=mach_close&window=gtm'>Close</A></span>"
		user.Browse(dat, "window=gtm;size=400x500;title=Golden Ticket Machine")
		onclose(user, "gtm")

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src

		if(href_list["redeem"])
			src.temp = "<BR><B>Please select the rewards that you would like to redeem your tickets for:</B><BR><BR>"

			src.temp += {"<style>
				table {border-collapse: collapse;}
				th,td {padding: 5px;}
				.reward {display:block; color:white; padding: 2px 5px; margin: -5px -5px 2px -5px;
																width: auto;
																height: auto;
																filter: glow(color=black,strength=1);
																text-shadow: -1px -1px 0 #000,
																							1px -1px 0 #000,
																							-1px 1px 0 #000,
																							 1px 1px 0 #000;}
			</style>"}

			src.temp += "<table border=1>"
			src.temp += "<tr><th>Reward</th><th>Cost</th><th>Description</th></tr>"

			for (var/datum/ticket_reward/R in ticket_rewards)
				src.temp += "<tr><td><a href='?src=\ref[src];buy=\ref[R]'><b><u>[R.name]</u></b></a></td><td>[R.cost]</td><td>[R.description]</td></tr>"

			src.temp += "</table></div>"

		if (href_list["buy"])
			var/datum/ticket_reward/R = locate(href_list["buy"]) in ticket_rewards
			if(istype(R))
				if(src.current_tickets < R.cost)
					src.temp = "<BR>Insufficient tickets.<BR>"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem tickets</A>"
				else
					src.current_tickets -= R.cost
					src.temp = "<BR>Thank you for your loyalty to Discount Dan's!"
					src.temp += "<BR><A HREF='?src=\ref[src];redeem=1'>Redeem tickets</A>"
					new R.path(src.loc)

		src.updateUsrDialog()

// Golden ticket rewards

/datum/ticket_reward
	var/name = "Totally amazing item"
	var/cost = 1
	var/path = null
	var/description = "All these descriptions are such bullshit."

/datum/ticket_reward/cap
	name = "Apprentice's Cap"
	path = /obj/item/clothing/head/apprentice/dan
	description = "A gorgeous piece of headwear, imbued with magical forces and pithy expressions."

	// Tickets

/obj/item/ticket
	name = "ticket"
	desc = "It's a ticket."
	icon = 'icons/obj/discountdans.dmi'
	w_class = 1.0

/obj/item/ticket/golden
	name = "golden ticket"
	desc = "A (partially) golden ticket! It has the Discount Dan's logo emblazoned on it. The fine print tells you that you can redeem this shimmery piece of foil at your nearest vending machine. Huh!"
	icon_state = "golden"
