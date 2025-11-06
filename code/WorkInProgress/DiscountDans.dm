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

/datum/ticket_reward/magnifying_glass
	name = "Magnifying Glass"
	path = /obj/item/magnifying_glass
	description = "A revelationary magnifying glass, constructed from solid oak and the finest crystal."

/datum/ticket_reward/flashlight_module
	name = "Flashlight Module"
	path = /obj/item/device/pda_module/flashlight/dan
	description = "An energy efficient, exceedingly visionary flashlight module."

/datum/ticket_reward/mug
	name = "Mug"
	path = /obj/item/reagent_containers/food/drinks/mug/dan
	description = "A limited edition high capacity ceramic mug, now in a striking orange hue."

/datum/ticket_reward/tonic
	name = "Tonic"
	path = /obj/item/reagent_containers/food/drinks/bottle/soda/drowsy
	description = "A divine lemon soda tonic that synchronizes your circadian rhythm and empowers your REM sleep."

/datum/ticket_reward/ale
	name = "Ginger Ale"
	path = /obj/item/reagent_containers/food/drinks/bottle/soda/gingerale
	description = "A soothing ginger root drink, chock full of vitamins A through K."

/datum/ticket_reward/peach_drink
	name = "Peach Drink"
	path = /obj/item/reagent_containers/food/drinks/peach
	description = "A socially hip and conscious peach drink."

/datum/ticket_reward/fortune_cookie
	name = "Fortune Cookie"
	path = /obj/item/reagent_containers/food/snacks/fortune_cookie
	description = "A delicious and powerfully predictive crispy cookie."

/datum/ticket_reward/donut
	name = "Donut"
	path = /obj/item/reagent_containers/food/snacks/donut/custom/cinnamon
	description = "An absurdly delicious cinammon donut."

/datum/ticket_reward/strudel
	name = "Strudel"
	path = /obj/item/reagent_containers/food/snacks/strudel
	description = "A generously proportioned and sensational strawberry strudel."

/datum/ticket_reward/peach_rings
	name = "Peach Rings"
	path = /obj/item/kitchen/peach_rings
	description = "A bag of sustainably farmed, ethically organized sugar-dusted peach rings."

/datum/ticket_reward/cereal
	name = "Cereal"
	path = /obj/item/reagent_containers/food/snacks/cereal_box/syndie
	description = "A collector's edition box of awesomely nutritious cereal."

/datum/ticket_reward/jersey
	name = "Jersey"
	cost = 2
	path = /obj/item/clothing/under/jersey/dan
	description = "A fine silk basketball jersey with antimicrobial and 3-pointer-making properties."

/datum/ticket_reward/lshirt_red
	name = "Red Shirt"
	cost = 2
	path = /obj/item/clothing/suit/lshirt/dan_red
	description = "An impressively modern long sleeved shirt in red."

/datum/ticket_reward/lshirt_blue
	name = "Blue Shirt"
	cost = 2
	path = /obj/item/clothing/suit/lshirt/dan_blue
	description = "An impressively modern long sleeved shirt in blue."

/datum/ticket_reward/jacket
	name = "Jacket"
	cost = 2
	path = /obj/item/clothing/suit/jacket/dan
	description = "A wonderfully stitched and styled cerulean jacket." // It's teal! Hah!

/datum/ticket_reward/labcoat
	name = "Labcoat"
	cost = 2
	path = /obj/item/clothing/suit/labcoat/dan
	description = "A professional and rumors-of-malpractice-assuaging labcoat, embroidered with distinctive orange threads."

/datum/ticket_reward/lighter
	name = "Lighter"
	cost = 2
	path = /obj/item/device/light/zippo/dan
	description = "An artisanally crafted zippo lighter with a beautiful flame and a stainless chrome finish."

// Void golden ticket rewards


// GTM - Golden Ticket Machine

/obj/submachine/GTM
	name = "GTM"
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "gtm"
	desc = "Discount Dan's loves you too!"
	density = 0
	opacity = 0
	anchored = ANCHORED

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

	attackby(var/obj/item/I, user)
		if(istype(I, /obj/item/ticket/golden))
			qdel(I)
			boutput(user, SPAN_NOTICE("You insert the golden ticket into the GTM."))
			src.current_tickets++
			src.updateUsrDialog()
		else
			src.Attackhand(user)
		return

	attack_hand(var/mob/user)
		if(..())
			return

		src.add_dialog(user)
		var/dat = "<span style=\"inline-flex\">"
		dat += "<BR>Current balance: [src.current_tickets] tickets"

		if (src.temp)
			dat += src.temp
		else
			dat += "<BR><A HREF='byond://?src=\ref[src];redeem=1'>Redeem tickets</A>"

		dat += "<BR><A HREF='byond://?action=mach_close&window=gtm'>Close</A></span>"
		user.Browse(dat, "window=gtm;size=400x500;title=Golden Ticket Machine")
		onclose(user, "gtm")

	Topic(href, href_list)
		if(..())
			return
		src.add_dialog(usr)

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
				src.temp += "<tr><td><a href='byond://?src=\ref[src];buy=\ref[R]'><b><u>[R.name]</u></b></a></td><td>[R.cost]</td><td>[R.description]</td></tr>"

			src.temp += "</table></div>"

		if (href_list["buy"])
			var/datum/ticket_reward/R = locate(href_list["buy"]) in ticket_rewards
			if(istype(R))
				if(src.current_tickets < R.cost)
					src.temp = "<BR>Insufficient tickets.<BR>"
					src.temp += "<BR><A HREF='byond://?src=\ref[src];redeem=1'>Redeem tickets</A>"
				else
					src.current_tickets -= R.cost
					src.temp = "<BR>Thank you for your loyalty to Discount Dan's!"
					src.temp += "<BR><A HREF='byond://?src=\ref[src];redeem=1'>Redeem tickets</A>"
					new R.path(src.loc)

		src.updateUsrDialog()

// Void GTM

/obj/submachine/GTM/void
	name = "GTM"
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "gtm-rusty"
	desc = "A GTM, but it's all rusty and gross."

// Tickets

/obj/item/ticket
	name = "ticket"
	desc = "It's a ticket."
	icon = 'icons/obj/discountdans.dmi'
	w_class = W_CLASS_TINY

/obj/item/ticket/golden
	name = "golden ticket"
	desc = "A (partially) golden ticket! It has the Discount Dan's logo emblazoned on it. The fine print tells you that you can redeem this shimmery piece of foil at your nearest vending machine. Huh!"
	icon_state = "golden"

/obj/item/ticket/platinum
	name = "platinum ticket"
	desc = "A (partially) platinum ticket! It has the Discount Dan's logo emblazoned on it. The fine print congratulates you on winning an all expenses paid trip to the Delightful Dan's Corporate HQ. Huh!"
	icon_state = "platinum"

// Magnifying glass

/obj/item/magnifying_glass
	name = "magnifying glass"
	desc = "A magnifying glass made from solid oak, which is quite rare in space. It has a huge lens and the letters DD etched on the handle."
	icon = 'icons/obj/discountdans.dmi'
	icon_state = "magnifying_glass"
	w_class = W_CLASS_SMALL

/* Idea stuff here

	Hey Cathy,

	Don't you think we should ditch those clunky cans for the Peach Punch, and go with something more eco-friendly to suit our image?
	Maybe biodegradeable juice boxes or something equally cute? I'm sure the space hippies would love it. They'd probably give it to their kids, too.
	We could probably market it as some effort to help reduce waste and save the our space stations. Everyone likes Delightful Dan's. I'm sure we'd get good publicity.

	Priscilla

	Pris,

	Good idea. Bring it up during our next meeting, and I'll back you. Cyborg Sigma-89's still doing inspections, so you'll have to really sell it and pretend like you actually care about this shit.

	Cathy Gladys
	cgladys@delightfuldans
	Delightful Dan's Central Division General Manager

	Hi Cathy,

	Did you hear about what happened to that guy that ate our galaxy donuts? They said he grew like ten extra limbs all over the place and can't even properly talk to his lawyer. Something about radiation?

	Priscilla

	Pris,

	Shut the hell up. You know you're not supposed to talk about this.

	Cathy Gladys
	cgladys@delightfuldans
	Delightful Dan's Central Division General Manager

	Pris,

	Decirprevo claims that we copied their label design for our ginger ale. That's bullshit, right? Didn't you say that you commissioned it from some artist type?

	Cathy Gladys
	cgladys@delightfuldans
	Delightful Dan's Central Division General Manager

	About that... Can we meet up and talk?

	Priscilla

	You are so in trouble. You better make it good.

	Cathy Gladys
	cgladys@delightfuldans
	Delightful Dan's Central Division General Manager

	Hi all,

	Have you seen my mug around somewhere? It's the orange high-capacity one, the one I always use for coffee. I thought I had just left it at home or something, but when I checked, it wasn't anywhere. But I doubt someone would steal it. It's old... And kinda gross, to be honest? Anyways, please let me know if you see it, or just put in back in my office cabinet.

	Thanks a bunch,

	Monica

	Hey Cathy,

	Did you hear about what happened with Sam? Some idiot from NanoTrasen sent him a record for his collection, but it actually contained a song entirely out of farts! Honestly it's kinda hilarious, but apparently he's gone to visit that guy's station and file a complaint. He was muttering about smashing that record on that guy's head, too. I hope he doesn't get arrested for assault or something. Or, maybe, I do hope so. That might convince the board to give me his position. And maybe even a corner office like you have...

	Priscilla

	Priscilla,

	I will do everything in my capacity to help you secure a promotion. You're a valuable asset and a hard worker. That being said, I do think it's rather indecent of you to be scheming for a coworker's job. We are a team, here at Delightful Dan's, and I must ask you to respect me and my position and how I got here. Let's set up a meeting for when I get back to HQ.

	Best,

	Samuel Sterling
	ssterling@delightfuldans
	Delightful Dan's Central Division Deputy General Manager

	Hi Sam,

	I am so incredibly sorry! I have no idea what made me write such a horrible email to you! I must not have had enough tea. Please excuse me, and please don't take what I said so seriously! It was a genuine mistake and I deeply apologize.

	Priscilla

	Pris,

	We're getting harassed by some nosey activists. Save the sea unicorns or whatever bullshit. Like, seriously dude, we have a license and everything. Calm the fuck down. The sea's already fucked up and some more sewage won't make it worse. Can you figure out a way to stop them from picketing and clogging up our lines and all that shit? It's seriously affecting my ability to concentrate on my work!

	Cathy Gladys
	cgladys@delightfuldans
	Delightful Dan's Central Division General Manager

	Hi Cathy,

	Of course! I'll talk to them and let it slip that Grones Soda is illegally stealing piss to bottle. It should be enough to get them off our case.

	Priscilla

	Red and yellow just don't go well together, you know? It's like ketchup and mustard - they look disgusting together even if they taste delicious on a soy hotdog.

	Milo,

	For the love of all things good and holy, please please please

*/
