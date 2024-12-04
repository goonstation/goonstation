var/global/shut_up_about_the_fucking_numbers_station = 1

/client/proc/toggle_numbers_station_messages()
	set name = "Toggle Numbers Station Alerts"
	set desc = "I DON'T CARE WHEN SPACE NUMBERS STATION LINCOLNSHIRE IS BROADCASTING SO SHUT UP ABOUT IT"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	shut_up_about_the_fucking_numbers_station = !(shut_up_about_the_fucking_numbers_station)
	logTheThing(LOG_ADMIN, usr, "toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"].")
	logTheThing(LOG_DIARY, usr, "toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled numbers station alerts [shut_up_about_the_fucking_numbers_station ? "off" : "on"]")

/area/spyshack
	name = "Space Shack"
	icon_state = "yellow"
	lightswitch = FALSE

/obj/item/paper/mission_outline
	name = "gibberish note"
	info = {"YWTMBYVWZSVRWFWDZVHZRULFBDYCGEZOOPOLMKPFKHTMBHDAOICVXWQPMCLPWEIXKSQWJNCE<br>
ICWRAIWSWFTCAAIMFJOPRXIUPKKTPENMLHNVQCXLQXUYHAXQIUVVDXJNDQVJMWCOJITURUBN<br>
WUMGOFCDVYHPSZGJENGUXOYGEPEDQAOSUOUOKOSCSXNAMQXICOSCSHGIZBDFASSIDFSGNFAW<br>
UQFNBSOJJGKISGYIOGYOWUXRTROLAIEEOTNJCWSWTKXLNEHHUTLOBUZXVHMBPJECPUQECKNQ<br>
ITAYIULHQNCMUOKYBJVRGCPGZBMVIYCQVSOSGLUWVJFUPSEJRIJXQICSGIBCUQCRSBORGQWB<br>
MBNEEDWMKCEZRNYLTREWBFQKNRYJMYLCOFSDSXITAPZB<br><br>

<i><b>On the back of the note is a scribbling:</b> When Blaise says the name of the target, the key of the other unlocks the knowledge.</i>"}

/obj/item/paper/otp
	name = "gibberish note"
	info = {"<i>There are multiple pages of gibberish in this notepad. The first page says:</i>
SXSUZEUKQMUPBHFLFXKOVYKUMWTRPIPSZKHNFWXKBLKEJMTMSHMBCGXOOAOSEYVMTWYAYUPL<br>
HQDFGMEYYIUBTDETHNAMKMVDZMOAXIVQUBAMGMJCHSLTUOAYWFLBJAWWAIKNHZSVZCLGDTBU<br>
MTRYNJKJXBFAQXWESKASBIPKZSLXDTTFWJAYTBKHRQBBJJENYKLNLYYJUEHYIQAWXNJPGTDT<br>
NXRSOCZWETSNAGNIQYMBRMYUOFQFIUIDDAAEWVAKXOPNDDEINMUTLHVNGZZBVYZHXCJBKVGZ<br>
HJEBZAMNJBVKDMHNDRCMSQTLFCHABZQOUTGTWUGNINGYWWBNVZMDIRJAERFLGUJMECGPVBPI<br>
OJSSDONANBRYRWKZIITDCIZULMFCKZZGHLUHNQHPYEKU<br>
"}

/obj/item/paper/intelligence_report
	name = "intelligence report"
	info = {"<b>Clandestine Positronics intelligence report on possible threats regarding the facility</b><br><br>

<i>This information is for the eyes of the facility administrator. If you are not authorized to read this report, please report to your facility administrator for bloodline termination.</i><br><br>

Nanotrasen awareness regarding the facility is currently low. High command is mobilizing infiltrator teams, but military action is not expected for a while.<br>
Thanks to our agents inside the organization, we were able to identify two infiltrators working undercover as scientists. Their designation follows: <br>
- #94413, medium field training, medium value in research. Suggesting immediate elimination in field mission.<br>
- #84153, low field training, extremely high value researcher. Suggesting assignment as primary researcher until further notice."}

/obj/item/paper/numbers_note
	name = "bloody piece of paper"
	desc = "It seems to have some interesting scribblings."
	icon_state = "paper_caution_bloody"

	sizex = 400
	sizey = 600

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:0px'><img src='[resource("images/bloody_numbers_note.png")]'></body></html>"

	examine()
		return ..()

	attackby()
		return



/obj/item/paper/requisitionF49A
	name = "requisition form f49-a"
	desc = "Not to be confused with f49-b or f49-c, of course."
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-A </b><br>

Site: <b>NT COLONY X03-B 'New Tharros'</b><br>
Quartermaster: <i>J.B. Fiske</i>
<ul>
<br>
REQUEST 1 of 3: Botany Outpost - APPROVED
<li>14 Barrels, GroBoost Nutrients</li>
<li>15 Barrels, TopCrop Nutrients</li>
<li>8 Barrels, Weedkiller</li><br>
<i>Reason: resupply</i><br><br>
REQUEST 2 of 3: Mining Outpost - APPROVED
<li>1 Automated Drill Rover</li>
<li>1 Crate, Mining Helmets(5/pk)</li>
<li>1 Vending Machine Repair Kit</li><br>
<i>Reason: repairs, resupply</i><br><br>
REQUEST 3 of 3: Atmos Facility - APPROVED
<li>2 MULEXL Wheel Assemblies</li>
<li>1 MULEXL Rear Axle Replacement Kit</li>
<li>2 Medical Crates, Standard</li>
<li>6 High Volume Air Canisters</li>
<li>1 Crate, Bodybags(5/pk)</li><br>
<i>Reason: repairs, resupply</i><br><br>

Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: Merchant | Teleporter | Shuttle | Pod | <br>
Mass Driver | <u>Sub-Orbital Drop</u> | Freighter | Rocket | Other <br><br>

-T.Nakamoto<br>
Regional Supply Director<br>
Logistics and Requisitions<br>
Nanotrasen, Inc.<br>

"}


/obj/item/paper/requisitionF49B
	name = "requisition form f49-b"
	desc = "Not to be confused with f49-a or f49-c, of course. It's stamped 'DELIVERED'"
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-B </b><br>

Site: <b>NT X05 Research Complex</b><br>
Head of Personnel: <i>Otis Oates</i>
<ul>
<br>
REQUEST 1 of 2: Outpost Sigma - APPROVED
<li>1 Engineer</li>
<li>2 Assistants</li>
<li>1 Janitor</li>
<br>
<i>Reason: monthly support staff rotation</i><br><br>
REQUEST 2 of 2: Outpost Gamma - APPROVED
<li>2 Security Guards</li>
<li>3 Assistants</li>
<li>1 Medical Doctor</li>
<li>1 Shovel</li>
<li>1 Entertainment Contractor, 1-Day Contract "Rent-a-Wrestler"</li>
<i>Reason: incident, welcome party for new hires</i><br><br>


Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: Merchant | Teleporter | <u>Shuttle</u> | Pod | <br>
Mass Driver | Sub-Orbital Drop | Freighter | Rocket | Other <br><br>

-Thad Davies<br>
Regional Assistant Director<br>
Human Resources<br>
Nanotrasen, Inc.<br>

"}



/obj/item/paper/requisitionF49A/theta
	name = "requisition form f49-a"
	desc = "Not to be confused with f49-b or f49-c, of course. It's stamped 'DELIVERED'"
	info = {"<html><head></head><body><b>REQUISITION FORM NT-F49-A </b><br>

Site: <b>NT X15 Outpost Theta</b><br>
Research Director: <i>Bob "Bob" Fredrickksen</i>
<ul>
<br>
REQUEST 1 of 1: Research Pod, Surface - APPROVED
<li>1 reindeer sweater</li>
<li>1 snowflake sweater</li>
<li>1 diamond sweater</li>
<br>
<i>Reason: staff appreciation day</i><br><br>


Allocation has been | <u>AUTHORIZED</u> | NOT AUTHORIZED <br> <br>
Fulfillment Method: <u>Merchant</u> | Teleporter | Shuttle | Pod | <br>
Mass Driver | Sub-Orbital Drop | Freighter | Rocket | Other <br><br>

-T.Nakamoto<br>
Regional Supply Director<br>
Logistics and Requisitions<br>
Nanotrasen, Inc.<br>

"}





/obj/item/paper/empty_bloody
	name = "bloody piece of paper"
	desc = "It's blank. Well, other than the blood, anyway."
	icon_state = "paper_caution_bloody"
	info = "<i>The paper is full of eraser marks and scratches but there is nothing legible on here.</i>"
	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/paper/diner_invoice
	name = "bloody piece of paper"
	desc = "It seems to have some interesting scribblings."
	info = {"<html><head></head><body><b>Delivery invoice</b><br><br>

<b>Articles:</b><br>
<ul><li>4 key lime pies</li>
<li>4 lemon meringue pies</li>
<li>3 jumbo size human meat substitute burgers</li><br><br>

<b>Total:</b> 4134 space credits<br>
<b>Thank</b>... <i>the rest of the invoice is covered in blood and illegible</i>"}
	icon_state = "paper_caution_bloody"

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)

/obj/item/onyxphoto
	name = "photo of onyx key"
	icon = 'icons/misc/terra8.dmi'
	icon_state = "onyx_photo"
	desc = "You can see a dark key carved of onyx. It's been set on a lab bench with measurement scales alongside it. You feel uneasy looking at this for some reason."
	var/used = 0

/obj/item/storage/secure/ssafe/pilot_cargo1
	name = "pilot's lockbox"

/obj/item/storage/secure/ssafe/pilot_cargo2
	name = "pilot's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/paper/requisitionF49B,
	/obj/item/currency/spacecash/thousand, /obj/item/currency/spacecash/thousand, /obj/item/reagent_containers/food/drinks/bottle/fancy_beer)

/obj/item/storage/secure/ssafe/pilot_cargo3
	name = "pilot's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/paper/requisitionF49A/theta,
	/obj/item/reagent_containers/emergency_injector/random,/obj/item/reagent_containers/emergency_injector/random,
	/obj/item/reagent_containers/food/drinks/bottle/hobo_wine)

var/global/datum/numbers_station/lincolnshire = null

/datum/numbers_station // This is not a physical entity!
	var/name = "Space Lincolnshire"
	var/frequency = 1487
	var/sound_channel = 174
	var/login_signal = 'sound/misc/lincolnshire.ogg'
	var/list/numbers = list(0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0)
	var/list/listeners = list()
	var/play_interval = 9000 // 15 minutes
	var/next_warning = 0
	var/next_play = 0

	New()
		..()
		processing_items |= src
		if (ticker)
			while (next_play <= ticker.round_elapsed_ticks)
				next_play += play_interval
		else
			next_play = play_interval
		next_warning = next_play - 300
		try
			var/datum/apiRoute/numbersstation/get/getNumbers = new
			var/datum/apiModel/NumbersStationPasswordResource/numbersStationPassword = apiHandler.queryAPI(getNumbers)
			lincolnshire_numbers(numbersStationPassword.numbers)
		catch
			// pass

	proc/gather_listeners()
		listeners = list()
		for (var/mob/living/carbon/human/H in mobs)
			LAGCHECK(LAG_LOW)
			for (var/obj/item/device/radio/Hs in H)
				if (Hs.frequency == frequency)
					listeners += H
					boutput(H, SPAN_NOTICE("A peculiar noise intrudes upon the radio frequency of your [Hs.name]."))
				break
		for (var/mob/living/silicon/robot/R in mobs)
			LAGCHECK(LAG_LOW)
			if (istype(R.radio, /obj/item/device/radio))
				var/obj/item/device/radio/Hs = R.radio
				if (Hs.frequency == frequency)
					listeners += R
					boutput(R, SPAN_NOTICE("A peculiar noise intrudes upon your radio frequency."))

	proc/play_all_numbers()
		var/batch = 0
		var/period = get_vox_by_string(".")
		for (var/number in numbers)
			play_number(number)
			broadcast_sound(period)
			batch++
			if (batch >= 3)
				sleep(0.1 SECONDS)

	proc/process()
		if (ticker.round_elapsed_ticks >= next_warning)
			next_warning += play_interval
			if (!shut_up_about_the_fucking_numbers_station) // SHUT UP
				message_coders("Numbers station [name] broadcasting in about 30 seconds.")
			return
		if (ticker.round_elapsed_ticks >= next_play)
			next_play += play_interval
			if (!shut_up_about_the_fucking_numbers_station)
				message_coders("Numbers station [name] broadcasting now.")
			logTheThing(LOG_DEBUG, null, "<b>Numbers station</b>: [name] is broadcasting on frequency [frequency / 10].")
			gather_listeners()
			if (!listeners.len)
				logTheThing(LOG_DEBUG, null, "<b>Numbers station:</b> [name] broadcast aborted: no listeners.")
				return
			SPAWN(1 SECOND)
				broadcast_sound(login_signal)
				play_all_numbers()
				var/doop = get_vox_by_string("doop")
				var/deeoo = get_vox_by_string("deeoo")
				broadcast_sound(doop)
				broadcast_sound(deeoo)
				broadcast_sound(doop)
				play_all_numbers()

	proc/broadcast_sound(var/soundfile)
		for (var/mob/M in listeners)
			if (M.client)
				M.playsound_local_not_inworld(soundfile, vol=50, wait=TRUE)

	proc/get_tens(var/n)
		if (n >= 20)
			var/tens = round(n / 10)
			switch (tens)
				if (2)
					return "twenty"
				if (3)
					return "thirty"
				if (4)
					return "fourty"
				if (5)
					return "fifty"
				if (6)
					return "sixty"
				if (7)
					return "seventy"
				if (8)
					return "eighty"
				if (9)
					return "ninety"
		return null

	proc/get_ones(var/n)
		if (n == 0)
			return "zero"
		if (n >= 10 && n < 20)
			switch (n)
				if (10)
					return "ten"
				if (11)
					return "eleven"
				if (12)
					return "twelve"
				if (13)
					return "thirteen"
				if (14)
					return "fourteen"
				if (15)
					return "fifteen"
				if (16)
					return "sixteen"
				if (17)
					return "seventeen"
				if (18)
					return "eighteen"
				if (19)
					return "nineteen"
		else
			var/ones = n % 10
			switch (ones)
				if (1)
					return "one"
				if (2)
					return "two"
				if (3)
					return "three"
				if (4)
					return "four"
				if (5)
					return "five"
				if (6)
					return "six"
				if (7)
					return "seven"
				if (8)
					return "eight"
				if (9)
					return "nine"
		return null

	proc/get_vox_by_string(var/vt)
		if (!vt)
			return null
		var/datum/VOXsound/vs = voxsounds[vt]
		if (!vs)
			return null
		return vs.ogg

	proc/play_number(var/n)
		var/stens = get_tens(n)
		var/ogg = get_vox_by_string(stens)
		if (ogg)
			broadcast_sound(ogg)
		var/sones = get_ones(n)
		ogg = get_vox_by_string(sones)
		if (ogg)
			broadcast_sound(ogg)

/proc/debug_lincolnshire()
	lincolnshire.next_warning = 0
	lincolnshire.process()
	lincolnshire.next_play = 0
	lincolnshire.process()

/proc/lincolnshire_numbers(numbers)
	logTheThing(LOG_DEBUG, null, "<b>Numbers station</b>: numbers: [numbers]")
	if (numbers == null)
		return FALSE
	var/list/nums = splittext(numbers, " ")
	if (length(nums) < 21)
		logTheThing(LOG_DEBUG, null, "<b>Numbers station</b> got too few numbers.")
		return FALSE
	for (var/i = 1, i <= 21, i++)
		lincolnshire.numbers[i] = text2num(nums[i])
	logTheThing(LOG_DEBUG, null, "<b>Numbers station</b> woo success")
	return TRUE


// This particular edition of the handbook is used as the cipher for the numbers station.
/obj/item/paper/book/numbers_station_hydroguide
	name = "The Helpful Hydroponics Handbook"
	icon_state = "book3"
	info = {"<html>
<head>
<style type="text/css">
div.code
{
padding:5px;
border:1px solid black;
margin:1px;
font-family:"courier";
font-size:12px;
background-color:lightgray;
}
div.tips
{
padding:10px;
border:5px solid gray;
margin:0px;
font-family:"Arial";
font-size:12px;
font-weight:bold;
}
body
{
color:black;
background-color:white;
}
h1
{
font-family:"Arial Black";
text-align:center;
font-size:24px;
font-weight:bold;
}
h2
{
font-family:"Arial Black";
text-align:left;
font-size:18px;
}
p
{
font-family:"Arial";
font-size:14px;
}
</style>
</head>

<body>

<h1>The Helpful Hydroponics Handbook</h1>
<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date.<br>
<h2>Introduction</h2>
<p>Hello! Do you have QUESTIONS about PROBLEMS? Are those problems of a gardening and plants nature? Well boy howdy is this the book for you! It's time to put an end to those plant woes!</p>

<h2>The Target Demographic</h2>
<p>Obviously, this book is targeted mainly at Botanists, Gardeners and other plant-growing folks.<br>
Of course if you are not one of these people there's no reason you can't try your hand anyway!
Gardening is awesome, easy and fun! I hope you like the smell of dirt!</p>
<p>If you're already an experienced gardener, keep an eye out for advanced tips, which look like this:
<div class="tips">
<li>This is a tip! Get the hint?</div>
<br><br>
<h2>Chapter 1: Basic Gardening</h2>
<p>So, you've got an empty Hydroponics tray, some seeds and a burning desire to grow some goddamn plants. The next step should be obvious: Plant that seed in the tray!</p>
<p>If you're using one of the standard issue Hydroponics growing trays, the plant should begin to grow almost immediatley. Most issues with the plant will be taken care of automatically by the tray.</p>
<p>However, you will need to ensure that the tray is kept filled with water - but not too much! Apart from this, simply tend to the plant until it becomes ready to harvest, as will be indicated by a green light.</p>
<p>Now, I know what you're thinking. "It can't be that simple, surely!" Well you're wrong! If all you want to do is simply plant, grow and harvest, this is literally all you need to do. Even a prehistoric hunter-gatherer can do it!</p>
<p>However, there are other things you can do to ensure a much better harvest and gardening experience. For example, you can add compost and other nutrients to the plant's solution to ensure the plant becomes and stays very healthy.</p>
<p>A healthy plant is a happy plant, and a happy plant will grow more viable produce!</p>
<p>Also, consider regularly checking the plant by hand - this will alert you to any issues with the tray or the plant that require correction.</p>
<div class="tips">
<li> Keep an eye on the LED displays on your Hydroponics tray. Green means a harvest is ready, Red means the plant is in poor condition. The bar on the side shows you how much water you have - aim for green!
<li> If trays are kept empty, eventually strange weeds may start to grow in them. Even keeping a dead plant in a tray will prevent weeds! Some weeds can be rather bad to have around!
</div>
<br><br>
<h2>Chapter 2: Tools of the Trade</h2>
<p>Well, now you know how to grow a plant and harvest it all well and good. You may find yourself asking however, what do I use to go about doing this?! What is all the stuff in here!? Slow down junior. We'll get to that.</p>
<p>A good Botanist is provided with many different tools to perform their work. Most likely, you'll be able to find an assortment of these tools in either a supplied set of lockers, or in a hydroponics tool vending machine.</p>
<p>First of all, we have the humble and iconic Watering Can. A symbol for any gardener! Standard watering cans can hold quite a lot of reagents, but you'll mostly just want to keep water in it. Most often botanists will be supplied with a high-capacity water tank.</p>
<p>The water tank holds a LOT of water inside - just attach the Watering Can to the spigot, give it a turn, and you'll have a lot of water to feed your plants! The tank will automatically fill the can as full as it can get, so don't worry about spills.</p>
<p>Bags of Compost are another item that should be used often and well. These familiar old brown bags contain a lot of nutritious mulch that will make your plants healthy. Specifics will be covered later.</p>
<p>There is also the trusty green and brown Compost Bin! This device not only stores quite a lot of compost mulch for refilling your bags, but it can also convert any unwanted produce into more mulch! Just place the produce inside and the process is automatic.</p>
<p>A good Botanist is also advised to make a lot of use of Produce Satchels. These handy little bags can hold a lot of food, plants, and seeds. Anything that's related to hydroponics and/or cooking can go in one of these bags! They hold a lot of stuff!</p>
<p>Sometimes though, there's times where plants decide to be a pain. Getting annoyed at Creepers killing your plants? Radweed giving you a nasty case of poisoning? This is where you'll want to use your trusty Chainsaw! Just hack up the plant and it's as good as gone!</p>
<p>If the Chainsaw doesn't work, try Weedkiller. Weedkiller solution has an extremely toxic effect on undesirable weed-like plants, while being completely harmless to regular plants. This is especially good against pesky Lasher plants!</p>
<p>The Plant Analyzer isn't neccessary if you're just doing basic planting and harvesting, but it's a must-have if you want to get into botanical genetic engineering. This will be covered in a later chapter.</p>
<p>The Seed Fabricator is the large, vending machine-like object that you can't take with you (unless you want to be crushed I guess), but it's vital - without it, you wouldn't be able to get any plant seeds! Any seeds obtained from this will have a completely clean genetic slate, also.</p>
<p>The Reagent Extractor accepts various produce, and extracts valuable reagents from them. This is especially important if you want to farm herbs!</p>
<p>Finally, we have the PlantMaster Mk3 plant genetics manipulator, seed extractor and seed infuser! This is the piece de resistance if you want to engage in genetic engineering - but that's a complicated subject we'll tackle later!</p>
<div class="tips">
<li> Other common objects can come in handy, too. Beakers can be inserted in the Reagent Extractor and PlantMaster, and screwdrivers can be used to bolt down trays so they don't get knocked around.
</div>
<h2>Chapter 3: Nutrient Solutions</h2>
<p>So, now we know the basics of plant maintenance, growing, and harvesting. What can we do to become better at our craft?</p>
<p>As was mentioned before, adding nutrients and other additives to the soil is a good idea - they encourage growth and good health in your plants, which is better for your harvests.</p>
<p>However, there are many different kinds of additives, some good and some bad. Obviously adding bad things like toxins or chlorine to the soil won't do you much good at all!</p>
<p>So what can we add? Most Botanists are equipped by standard with compost bags and weedkiller bottles. Weedkiller is harmless to normal plants, but will destroy undesirable plants such as Creepers or Lashers.</p>
<p>Compost is a very basic additive which will slowly make a plant healthier as it absorbs the nutrients. There are no drawbacks - however, it is not very quick or efficient! Ammonia, if available, will have a similar effect to compost.</p>
<p>Phosphorus and Diethylamine, if available, will encourage the plant to grow quicker by offering more stimulating nutrients. Again however, they are not the most efficient of additives.</p>
<p>There exist other additive solutions - they are very efficient, but often come with drawbacks. Unfortunately, the recipes for these are closely guarded formulas. All we can tell you is that they all use plant nutrients as a base!</p>
<p>Due to the high availability of these additives however, Botanists are often supplied with one or two bottles of each. After that, it is up to the botanist to experiment with chemistry and see if they can find how to make more!</p>
<div class="tips">
<li> Mutagenic Formula encourages the plant to mutate wildly. However, it does cause some damage to the plant as well as stunted growth.
<li> Ammonia encourages very rapid plant growth, but will cause the tray to dry out much faster than usual.
<li> Potash encourages large harvests. However, it has been known to shorten the plant's lifespan.
<li> Saltpetre can help create much more potent produce, but it can result in smaller crop yields.
<li> Mutadone Formula is a healthy plant solution that aims to rectify genetic problems. Sadly, plant growth will be slowed to near-zero while it is present in the solution.
</div>
<h2>Chapter 4: Gladly Grow Genetically Great Goods</h2>
<p>So, you're finally rolling in the brassicas, huh? Growing large batches of well-tended and healthy crops, supplying everyone with more food and medicine than they can possibly eat. This is the life, huh?</p>
<p>What if I told you there's more. That's right! You've only glimpsed a tiny bit of the potential inherent in Hydroponics! Through manipulating the genes of plants, you can create new strains of plant that live longer, produce more, produce better, and ARE better for everyone!</p>
<p>I'm sure you're just jonesing to sign up for some mad science. Well you're in luck! Remember the Plant Analyzer and PlantMaster Mk3 mentioned back in chapter two of this handbook? This is where those two tools come in - your gateway to genetic engineering!</p>
<p>Plant Analyzers can be used on growing plants, fruit, and seeds. When used, the analyzer will give a readout of every useful gene in the plant's genetic structure, as well as detailing the plant's species and a few other things.</p>
<p>Maturation Rate is the gene that influences how long a plant takes to grow from a small sapling into an adult plant. With this gene, a lower readout is better as it means a quicker growth cycle.</p>
<p>Production Rate is the gene dealing with how long it takes an adult plant to produce viable crops. Again, lower is better. Essentially, every time a plant is harvested it is returned to the beginning of the adult stage of its growth cycle -
 a plant could take a long time to grow but produce new batches of crop relatively quickly between harvests thanks to this gene.</p>
<p>The Lifespan gene differs somewhat in function between fruits and other plants. In fruits, it controls how many harvests a plant can produce before it will die. In other plants it is not quite as useful, but still important - the gene controls how healthy a plant will generally be
when it is first planted. A poor Lifespan gene in a non-fruit plant will result in a sickly plant that requires a lot of care to nurse it back to health. So keep this one high irregardless!</p>
<p>The Yield gene simply influences how much viable produce a plant can generate per harvest. If the yield gene falls too low, a plant may not produce anything at all!</p>
<p>Potency mainly comes into play when producing herbs, but it can also affect certain other crops. Generally speaking, the more potent a plant is, the more concentrated the reagent it produces will be within the leaves, fruits or what-have-you that you harvest. If you're growing
 medicinal herbs, this is a very important gene as it allows you to squeeze more reagent out of each herb!</p>
<p>Endurance deals with the plant's ability to resist damage from various sources. Generally speaking, drought and poison are the most commonly resisted types of damage. Fire and physical damage usually are too much for a plant to resist, and thus this gene will do nothing against them.</p>
<p>The Analyzer will also display any genetic strains that are present - these are mutant strains that can affect various things about a plant. Known strains will be covered in an addendum. This section will also show if abnormal genetic strains are present - these are rare mutations that
drastically affect a plant's crop production. Most often these will also be directly visible by observing the plant itself - mutated plants often manifest strange alterations to their appearance!</p>
<p>Next to each gene (and the species) you will see either "D" or "r". This denotes whether that gene is Dominant or Recessive - this will be important later!</p>
<p>Several different things cause a plant's genes to mutate. Plants will mutate somewhat naturally whenever they are first planted in a tray. Exposure to mutagens or radiation will also cause mutations of varying severity - the stronger the source, the more drastic the mutation.</p>
<p>In addition to the nutrient tonics mentioned earlier, the PlantMaster Mk3 allows you much more control over this wild and wacky process they call genetic development! Firstly, the PlantMaster features a seed extractor - this simply maximises the amount of seeds you have to work with
by extracting as many as it can from a piece of produce. All seeds within a single piece of produce will share the same genetic makeup too, so you'll have a lot more room for error!</p>
<p>Secondly, the PlantMaster allows you to splice two seeds together to create a new hybrid seed. This is where dominance and recession comes into play! Select two seeds, and you'll be told their chances of successfully splicing - the chances will be much higher if you use two seeds
from species that are similar, such as two fruits, or two herbs. You can splice seeds between species lines, but it will be much more difficult.</p>
<p>When two seeds are successfully spliced, the genes will be mixed. Dominant genes will take precedence over recessive genes! If you have a seed with a bad dominant yield gene and one with a good recessive yield gene, think twice before you splice! The resultant hybrid seed will
take the bad gene, because it's dominant! If your two seeds are both dominant or recessive in one gene however, what will happen most often is that the hybrid's gene will be an average of the two genes. This does not apply to the species gene however - try as we might, we still can't
grow those sweet, sweet corn melon hybrids. So don't try and fuse two species together! It won't work!</p>
<p>Through splicing, you can potentially take a seed with good genes in one area, splice it with a seed that covers the weak genes or adds further advantages, and end up with a seed that has the benefits of both and drawbacks of neither! There are other benefits to splicing seeds, too -
genetic strains that normally only manifest in one species of plant will be shared in the new hybrid. That prized Immortality strain in your Cannabis plant can finally be a reality!</p>
<p>The PlantMaster is also capable of performing infusions. Infusion is a process whereby a reagent is injected into paticular parts of a seed, hopefully without killing it, in order to forcibly induce genetic changes. You will need at least ten units of a reagent to perform this process,
and a beaker of course! Also a seed. That's important too. Different species can react differently to different kinds of reagent, but some have a universal effect on all plants. For instance, infusing a seed with one of the plant nutrient tonics is most likely a great idea - they are designed
to stimulate genes, and what better way to do that than by injecting it directly into the seed's genes? You might not want to infuse a seed with acid, though. That tends to just dissolve it.</p>
<p>Of course, due to the physical damage involved in injecting a seed full of stuff, infusion will always damage the seed a little - certain reagents might cause a lot of damage in addition to this! In some cases, infusions can also trigger drastic mutations in a plant - try infusing a wheat
seed with iron and see what happens. We love that one! Don't be afraid to experiment - you don't have to use your best genetically engineered seeds for infusing, after all. That's what science is all about!</p>
<p>Now you've learned most of what we know. We hope this handbook has been of great use to you! Don't forget to check the addendums for further information!</p>
<div class="tips">
<li> Don't infuse a single seed too much - in addition to the risk of destroying it, damaged seeds tend to grow unhealthy plants. You'll have to nurse any plant growing from a damaged seed back to good health before it'll produce much in the way of crops.
</div>
<h2>Addendum 1: Common Weeds</h2>
<p><b>Spaceborne Fungus</b> (<i>metafungi</i>)</p>
<p>It is not known whether terrestrial mushroom spores were accidentally brought into space or smuggled deliberately, but they now propagate quite rapidly in many space stations, the ventilation systems helping their spores to get around most of the stations.
A subspecies of these mushrooms are often found as a mold growing in damp, dark and poorly travelled places aboard space stations. Mostly harmless.</p>
<p><b>Space Grass</b> (<i>metagraminoidae</i>)</p>
<p>Often humorously termed "Astro Turf", this spaceborne grass is of terrestrial origin and has adapted so well to space that it can grow harmlessly on nearly any surface if seeds of this plant are scattered upon it.</p>
<p><b>Lasher Brambles</b> (<i>metasalsola lividium</i>)</p>
<p>A strange, space-borne mutation of the terrestrial tumbleweed, Lashers are a thorny, bright cyan plant known to be sensitive to nearby motion. They often "lash out" at nearby lifeforms, cutting them with thorny vines. Extermination recommended.</p>
<p><b>Creeper Vine</b> (<i>metahedera pervasis</i>)</p>
<p>These fuschia roots and vines are known for their rapid growth and displacement of other plant species. If a tray is contaminated by Creepers and cannot be disinfected, keep it away from other nearby trays. The creeper vine has been known to actively seek other plants
to attack them and replace them with more instances of itself.</p>
<p><b>Radiator Weed</b> (<i>xenocuries nauseus</i>)</p>
<p>One of the first non-terrestrial plants discovered, spores of this fungus-like plant are often found floating dormantly in space. Unfortunately, it is rather dangerous - the main "bulb" of the plant has been known to emit dangerous levels of ionizing radiation.
The plant takes a while to reach this stage - when the green bulb begins glowing, the plant should be considered a health hazard. It can induce radiation poisoning in humans, and mutations and damage to nearby plants.</p>
<p><b>Toxic Slurry Pod</b> (<i>xenobulba putrescens</i>)</p>
<p>A more recently discovered alien plant, it is sadly no less dangerous or pervasive than the Radiator Weed. The main body of the plant is a green fleshy mass which contains a putrid sludge of unknown function - this sludge is known to be very toxic and can have significant
negative effects on human and plant health. The main body of the plant has been known to fill itself with this sludge to such a degree that it reaches an internal pressure it is no longer capable of withstanding and bursts, splattering the sludge across a large radius. Hardened
globules of this sludge can be harvested from the plant however - with proper processing to remove the toxins, the "slurryfruit" has caught on in some colonies as a delicacy.</p>
<h2>Addendum 2: Known Gene Strains</h2>
<p><b>Fast Metabolism</b>: This strain accelerates a plant's growth, but causes it to drain reagents from its environment more quickly.</p>
<p><b>Slow Metabolism</b>: This strain causes a plant to grow more slowly but also use less reagents.</p>
<p><b>Toxin Immunity</b>: Any kind of toxin or poison will not harm a plant carrying this strain.</p>
<p><b>Drought Resistance</b>: When no water is available, plants with this strain will deteriorate a lot slower.</p>
<p><b>Enhanced Yield</b>: Harvests from plants with this strain will be much more bountiful.</p>
<p><b>Stunted Yield</b>: The harvest yield from plants with this strain will be poor.</p>
<p><b>Immortal</b>: A highly desirable strain that ensures a fruiting plant will never die from being harvested.</p>
<p><b>Unstable</b>: Plants carrying this strain will continually mutate by themselves.</p>
<p><b>Rapid Growth</b>: A very desirable strain that causes the plant to grow far faster than usual.</p>
<p><b>Stunted Growth</b>: This strain will cause the plant to grow much more slowly.</p>
<p><b>Poor Health</b>: The condition of plants carrying this strain will deteriorate over time.</p>
<p><b>Seedless</b>: A very negative strain that prevents the host plant from reproducing at all.</p>
</body>
</html>

"}
