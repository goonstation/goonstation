/obj/item/paper/book
	name = "book"
	desc = "A book.  I wonder how many of these there are here, it's not like there would be a library on a space station or something."
	icon = 'icons/obj/writing.dmi'
	icon_state = "book0"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	layer = OBJ_LAYER
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 1100
	burn_possible = 1
	health = 30
	//

	stamina_damage = 2
	stamina_cost = 2
	stamina_crit_chance = 0

	attack_self(mob/user)
		return user.examine_verb(src)

	attackby(obj/item/P, mob/user)
		src.add_fingerprint(user)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] attempts to cut [him_or_her(user)]self with the book. What an idiot!</b></span>")
		user.suiciding = 0
		return 1

/obj/item/paper/book/materials
	name = "Dummies guide to material science"
	desc = "An explanation of how to work materials and their properties."
	icon_state = "orangebook"
	info = "The information in this piece of crap book is horribly outdated, making it useless. Let's hope centcom buys the new edition soon."
	/*
	info = {"
	<BIG><B>Materials</B></BIG>
	<br>
	<br>This book is meant to give you a brief overview and explanation of the materials, their properties and how to work them.
	<br>
	<br>
	<br><B>General information:</B>
	<br>
	<br>Under normal circumstances a material can only have one additive used on it - any further additives are lost.
	<br>However, there might be certain chemicals or materials that allow to work materials beyond this limit.
	<br>
	<br>Additives can have all kinds of effects on materials.
	<br>Some will change the stats of a material while others will give it special or unique effects.
	<br>
	<br>Some combinations of materials and/or additives might produce unique alloys / materials.
	<br>These fixed recipes and their resulting materials will usually have a special ability, use or just good stats.
	<br>
	<br>Different departments have different manufacturers, each with different recipes.
	<br>You might sometimes be able to find blueprints for manufacturers while exploring.
	<br>These blueprints will add a new item to the craftable objects of manufacturer when used on it.
	<br>
	<br>
	<br><B>Material properties:</B>
	<br>
	<br><B>Siemens coefficient:</B>
	<br>How well a material conducts electricity.
	<br>Values range from 0 = Non-conductive to 1 = Perfectly conductive.
	<br>
	<br>
	<br><B>Heat transfer coefficient:</B>
	<br>How well heat can transfer through a material - how insulating it is.
	<br>Values range from 0 = Perfect insulation to 1 = Heat transfers without loss.
	<br>A common spacesuit will have a value below/around 0.1.
	<br>
	<br>
	<br><B>Protective temperature:</B>
	<br>How high of a temperature this material can shield something from.
	<br>Higher is better.
	<br>
	<br>
	<br><B>Thermal conductivity:</B>
	<br>How well heat can transfer through this.
	<br>Only applies to walls and such. See Heat transfer coefficient
	<br>
	<br>
	<br><B>Heat capacity:</B>
	<br>(Honestly, who even knows anymore? This atmos code is a mess)
	<br>(Fairly sure this does SOMETHING)
	<br>
	<br>
	<br><B>Permeability coefficient:</B>
	<br>How well chemicals can penetrate this material.
	<br>Values range from 0 = Can not penetrate to 1 = Goes right through
	<br>
	<br>
	<br><B>Disease resistance:</B>
	<br>How well this material can shield a person from diseases.
	<br>Values range from 0 = No protection to 100 = Complete protection.
	<br>
	<br>
	<br><B>Melee Protection:</B>
	<br>How well this material will protect from melee attacks.
	<br>Reduces both damage and stamina damage. Higher is better.
	<br>
	<br>
	<br><B>Bullet Protection:</B>
	<br>How well this material will protect from bullets.
	<br>Bullet damage will be divided by this. Higher is better.
	<br>
	<br>
	<br><B>Explosion resistance:</B>
	<br>If applied to a wall or another solid object this
	<br>determines how well that object will shield objects behind it from an explosion.
	<br>Higher is better.
	<br>
	<br>
	<br><B>Explosion protection:</B>
	<br>How well this material will protect from explosions.
	<br>Reduces both severity and damage from explosions.
	<br>
	<br>
	<br><B>Radiation Protection:</B>
	<br>How well does this protects against radiation. More is better.
	<br>
	<br>
	<br><B>Magical:</B>
	<br>Does this material allow wizards to channel magic?
	<br>
	<br>
	<br><B>Value:</B>
	<br>How valuable this material is.
	<br>Higher is better.
	<br>
	<br>
	<br><B>Damage:</B>
	<br>How damaging this material is when used on items.
	<br>Higher is better.
	<br>
	<br>
	<br><B>Quality:</B>
	<br>Determines the quality of items made using this.
	<br>This can have many different effect but higher is always better.
	<br>
	<br>
	<br><B>Durability:</B>
	<br>How durable objects made from this are.
	<br>More durability means that the objects can take more damage.
	<br>
	<br>
	<br><B>Hardness:</B>
	<br>How hard objects made from this are.
	<br>Can have different effects depending on the object.
	<br>What value you want depends on the item.
	<br>
	<br>
	<br><B>Autoignition temperature:</B>
	<br>At which temperature this material will ignite.
	<br>
	<br>
	<br><B>Burn output:</B>
	<br>How much energy this material outputs while burning.
	<br>
	<br>
	<br><B>Instability:</B>
	<br>How likely it is that the material fails during manufacturing and possibly use. Higher is worse.
	<br>
	<br>
	"}
	*/

/obj/item/paper/book/mechanicbook
	name = "Mechanic components and you"
	icon_state = "mechcompguide"
	desc = "A Book on how to use the wireless Components of the Mechanic's lab"
	info = {"
	<BIG><B>Quick-start Guide</B></BIG>
	<br>
	<br>To connect Components to each other you use drag and drop.
	<br>For this to work the components need to be secured into place by means of a Wrench.
	<br>You need to be holding a multi-Tool to be able to change Connections and Options of Components.
	<br>
	<br>A basic construction would look something like :
	<br><I>Wrench a Button Component into Place.</I>
	<br><I>Wrench a Graviton Accelerator into Place.</I>
	<br><I>Drag the Button onto the Accelerator and drop.</I>
	<br><I>Set the Button as Trigger.</I>
	<br><I>Select the only existing target input on the Accelerator.</I>
	<br>
	<br>Using the Button will now activate the Accelerator.
	<br>
	<br>You can see the Connections between Components when they are not covered by Tiles.
	<br>Just use a Crowbar to reveal the Plating and you'll be able to see what's connected to what.
	<br>
	<br>The Components can also be connected to some Machines and Gadgets around the Station.
	<br>You could try messing around with Doors or vending Machines.
	<br>If you want to connect two non-component objects together - say two Doors,
	<br>you will have to use a Component between the two Objects. Relays are easily used for this.
	<br>You would connect the Relay to Door 1 as Reciever and then connect the Relay to Door 2 as Trigger.
	<br>
	<br>Most Components offer additional Options in their right-Click Menu when you are standing right next to them.
	<br>These Options can range from Rotation to setting the output Signal and such Things.
	<br>
	<br><I>Information about the specific Components follows below.</I>
	<br>
	<hr>
	<br><BIG><B>Component specific Information</B></BIG>
	<br>
	<br><B>AND Component:</B>
	<br>Sends specified signal when both inputs recieve a Signal within a specified Time Frame.
	<br>
	<br>
	<br><B>Button:</B>
	<br>Sends set Signal when used.
	<br>
	<br>
	<br><B>Delay Component:</B>
	<br>Delays an incoming signal a certain amount of time before sending it to its connections.
	<br>
	<br>
	<br><B>Graviton Accelerator:</B>
	<br>Accelerates objects on it into a given direction for 3 seconds after being activated.
	<br>
	<br>
	<br><B>Gun Component:</B>
	<br>Shoots a Gun in the given Direction.
	<br>Needs to have a Gun installed before it can be used. Simply use the Gun on the Component.
	<br>
	<br>
	<br><B>E-Gun Component:</B>
	<br>Shoots a Gun in the given Direction.
	<br>Needs to have a Gun installed before it can be used. Simply use the Gun on the Component.
	<br>This Component only works for Energy based Guns with Power Cells in them.
	<br>Can recharge the Gun inside it at the Cost of temporarily deactivating itself.
	<br>Additionally, there is a short cooldown Period between Shots.
	<br>
	<br>
	<br><B>LED Component:</B>
	<br>Provides light when triggered.
	<br>The \"set rgb\" Input takes a Color in the HTML Color Code Format, for Example: #FF1200 .
	<br>
	<br>
	<br><B>Microphone Component:</B>
	<br>Forwards nearby speech as signal.
	<br>The "Toggle Show-Source" option determines whether the component adds the source's name to the signal or not.
	<br>
	<br>
	<br><B>OR Component:</B>
	<br>Sends a specified Signal when it recieves a specified Signal in one of its Inputs.
	<br>
	<br>
	<br><B>Pressure Sensor:</B>
	<br>Detects Pressure and dispatches Signal.
	<br>
	<br>
	<br><B>RegEx Find Component:</B>
	<br>Attempts to find an expression within a String. If found it can either forward the found String as Signal or send its own Signal.
	<br>The type of RegEx used is PCRE. Look-ahead or look-behind assertions are not supported.
	<br>
	<br>
	<br><B>RegEx Replace Component:</B>
	<br>Attempts to find an expression within a String and then replaces it. Forwards the modified String as Signal. Also has an Input that lets you set the Expression.
	<br>The type of RegEx used is PCRE. Look-ahead or look-behind assertions are not supported.
	<br>
	<br>
	<br><B>Relay Component:</B>
	<br>Forwards an input signal to another Target. If Signal changing is enabled, the Component will change the incoming Signal to its own before relaying it.
	<br>
	<br>
	<br><B>Selection Component:</B>
	<br>Holds a List of Signals that can be manipulated, browsed and sent.
	<br>Can be set to randomly select Items for sending or triggered to send a random Item once.
	<br>
	<br>
	<br><B>Signal Builder Component:</B>
	<br>Builds a String out of incoming Signals until it is triggered to send whats in the Buffer at which point the accumulated String will be sent and the Buffer cleared.
	<br>The starting/ending String Settings allow you to define a String that will be put at the Beginning or End of each String.
	<br>
	<br>
	<br><B>Signal Check Component:</B>
	<br>Sends either its own Signal or the input Signal when it recieves a Signal that has the set Trigger String in it somewhere.  Can be toggled to trigger when it does NOT find the specified string.
	<br>For Example: Trigger -> cat, Incoming Signal -> \"catswithhats\" -> the Component activates. This is not case-sensitive.
	<br>
	<br>
	<br><B>Sound Synthesizer:</B>
	<br>Speaks whatever Signal it recieves out loud. Rate-limited to 2 Seconds.
	<br>
	<br>
	<br><B>Teleport Component:</B>
	<br>To link Pads set the ID to the same string on both Pads. If there are more than 2 Pads with the same ID, Destinations will be picked at random.
	<br>Has an Input that allows a message to change the ID of the Pad and through that its Destination.
	<br>Individual Pads can be set to send only Mode - in this Mode they can not be the Target Location of other Pads with the same ID.
	<br>This is useful if you want to have several Pads teleport to one exit Pad.
	<br>
	<br>
	<br><B>Toggle Component:</B>
	<br>Can be turned on, off or be toggled. Outputs 2 different Signals depending on its new State - one for on and one for off.
	<br>Can also be triggered to just output the appropriate Signal without doing anything else.
	<br>
	<br>
	<br><B>Wifi Component:</B>
	<br>The "send radio message" Command accepts Messages in the Format of command=herp&data=derp which will then be sent on the set Frequency.
	<br>The Component can recieve a sendmsg Radio Signal that will send the Data in the \"data\" Portion of the Signal to the Outputs of this Component.
	<br>Following the previous Syntax a sendmsg Signal would look like this : address_1=WIFICompoAddHere&command=sendmsg&data=MyCompoCommand
	<br>Normal PDA Messages can also be used to trigger the Component.
	<br>The frequency can be changed wirelessly as well by using the setfreq Command : address_1=WIFICompoAddHere&command=setfreq&data=1419
	<br>If you enable the forward all option, the Component will forward any Radio Messages it recieves, unprocessed and in the above format, to its Outputs.
	<br>By disabling NetID filtering you can make the Component react to any and all Radio Messages on its frequency.
	<br>The Component will blink green when it recieves a wireless Message and blink red when it sends a wireless Message."
	<br>
	<br>
	<br><B>Wifi Signal Splitter Component:</B>
	<br>Returns the value of a field within a Radio signal. The components Trigger Field is the Field you want the Value of.
	<br>For example: Set the Trigger Field to \"user_id\". When a Signal with \"user_id=captain\" arrives the Component forwards \"captain\"
	"}

/obj/item/paper/book/cookbook
	name = "To Serve Man"
	icon_state = "serveman"
	desc = "A culinary guide on how to best serve man"
	info = {"<h1>To Serve Man</h1>
	<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date.</i></p>
	<p><i>It is also important to remember that every oven works differently and the cooking times for these recipes might not be optimal.</i></p>
	<hr>
	<p>This is meant as a basic guide for cooking with some common recipes. However, if you want to become a true chef, you must willing to experiment and try new things.
	Only someone who is not afraid of failure can become a master chef!</p>
	<hr>
	<h2>Burger</h2>
	<h3>Ingredients</h3>
	<div class = "burger">
	<li>1-3 Pieces of Meat
	<li>1 Dough
	</div>
	<div class ="burgersteps">
	<li>Cook the ingredients in the oven for 6 seconds on high
	</div>

	<hr>
	<h2>Luau Burger</h2>
	<h3>Ingredients</h3>
	<div class = "luau">
	<li>1 Pineapple Slice
	<li>1 Piece of Meat
	<li>1 Dough
	</div>
	<div class ="luausteps">
	<li>Cook the ingredients in the oven for 7 seconds on high
	</div>

	<hr>
	<h2>Coconut Burger</h2>
	<h3>Ingredients</h3>
	<div class = "coconut">
	<li>1 Piece of Coconut Meat
	<li>1 Dough
	</div>
	<div class ="coconutsteps">
	<li>Cook the ingredients in the oven for 7 seconds on high
	</div>

	<hr>
	<h2>Tiki Burger</h2>
	<h3>Ingredients</h3>
	<div class = "tiki">
	<li>1 Pineapple Slice
	<li>1 Piece of Meat
	<li>1 Piece of Coconut Meat
	<li>1 Dough
	</div>
	<div class ="tikisteps">
	<li>Cook the ingredients in the oven for 9 seconds on high
	</div>

	<hr>
	<h2>Cake Batter</h2>
	<h3>Ingredients</h3>
	<div class = "cakebatter">
	<li>1 Sweet Dough
	<li>2 Eggs
	</div>
	<h3>Steps</h3>
	<div class = "cakebattersteps">
	<li>Mix the ingredients together
	</div>

	<hr>
	<h2>Cake</h2>
	<h3>Ingredients</h3>
	<div class = "cake">
	<li>1 Cake Batter
	<li>1 Food Item of Your Choice
	<li>Icing Tube Full of a Reagent of Your Choice
	</div>
	<h3>Steps</h3>
	<div class = "cakesteps">
	<li>Mix the first two ingredients together (Use the mixer)
	<li>Cook the cake in the oven for 9 seconds on low.
	<li>Use the icing tube on the cake.
	<li>Cut the cake.
	</div>

	<hr>
	<h2>Cream of Mushroom</h2>
	<h3>Ingredients</h3>
	<div class = "creamofmush">
	<li>1 Mushroom
	<li>1 Milk
	</div>
	<h3>Steps</h3>
	<div class = "creamofmushsteps">
	<li> Mix the ingredients together
	<li>Cook the ingredients in the oven for 7 seconds on low
	</div>

	<hr>
	<h2>Mint Chutney</h2>
	<h3>Ingredients</h3>
	<div class = "mintchutney">
	<li>1 Mint Leaves
	<li>1 Garlic
	<li>1 Whole Onion
	<li>1 Chili Pepper
	</div>
	<h3>Steps</h3>
	<div class = "mintchutneysteps">
	<li>Cook the ingredients in the oven for 7 seconds on high.
	</div>

	<hr>
	<h2>Refried Beans</h2>
	<h3>Ingredients</h3>
	<div class = "refried">
	<li>2 Bean Pods
	<li>1 Slice of Raw Bacon
	</div>
	<h3>Steps</h3>
	<div class = "refried">
	<li>Cook the ingredients in the oven for 7 seconds on high.
	</div>

	<hr>
	<h2>Rice And Beans</h2>
	<h3>Ingredients</h3>
	<div class = "riceandbeans">
	<li>1 Bean Pod
	<li>1 Rice Sprig
	</div>
	<h3>Steps</h3>
	<div class = "riceandbeans">
	<li>Cook the ingredients in the oven for 10 seconds on low.
	</div>

	<hr>
	<h2>Fried Rice</h2>
	<h3>Ingredients</h3>
	<div class = "friedrice">
	<li>1 Rice Sprig
	<li>1 Egg
	<li>1 Whole Onion
	<li>1 Garlic
	</div>
	<h3>Steps</h3>
	<div class = "friedrice">
	<li>Cook the ingredients in the oven for 10 seconds on low.
	</div>

	<hr>
	<h2>Omurice</h2>
	<h3>Ingredients</h3>
	<div class = "omurice">
	<li>1 Rice Sprig
	<li>1 Egg
	<li>1 Ketchup
	</div>
	<h3>Steps</h3>
	<div class = "omurice">
	<li>Cook the ingredients in the oven for 8 seconds on low.
	</div>

	<hr>
	<h2>Risotto</h2>
	<h3>Ingredients</h3>
	<div class = "risotto">
	<li>1 Rice Sprig
	<li>1 Butter
	<li>1 Whole Onion
	<li>1 Garlic
	</div>
	<h3>Steps</h3>
	<div class = "risotto">
	<li>Cook the ingredients in the oven for 10 seconds on low.
	</div>

	<hr>
	<h2>Donut</h2>
	<h3>Ingredients</h3>
	<div class = "donut">
	<li>1 Dough Circle
	<li>1 Sugar
	</div>
	<h3>Steps</h3>
	<div class = "donutsteps">
	<li>Cook the ingredients in the oven for 3 seconds on low
	</div>

	<hr>
	<h2>Dough</h2>
	<h3>Ingredients</h3>
	<div class = "dough">
	<li>1 Flour
	</div>
	<h3>Steps</h3>
	<div class = "doughsteps">
	<li>Add water to the flour via a sink
	</div>

	<hr>
	<h2>Dough Strip</h2>
	<h3>Ingredients</h3>
	<div class = "doughstrip">
	<li>1 Dough
	</div>
	<h3>Steps</h3>
	<div class = "doughstripsteps">
	<li>Cut the dough in half with a cutting implement.
	</div>

	<hr>
	<h2>Dough Circle</h2>
	<h3>Ingredients</h3>
	<div class = "doughcircle">
	<li>1 Dough Strip
	</div>
	<h3>Steps</h3>
	<div class = "doughcirclesteps">
	<li>Knead the dough strip into a circle with your hands.
	</div>

	<hr>
	<h2>Holey Dough</h2>
	<h3>Ingredients</h3>
	<div class = "holedoughcircle">
	<li>1 Dough
	</div>
	<h3>Steps</h3>
	<div class = "holedoughcirclesteps">
	<li>Stab the dough with a fork.
	</div>

	<hr>
	<h2>Bagel</h2>
	<h3>Ingredients</h3>
	<div class = "bagel">
	<li>1 Dough Circle
	</div>
	<h3>Steps</h3>
	<div class = "bagelteps">
	<li>Add the dough to the oven.
	<li>Cook the ingredients in the oven for 3 seconds on low.
	</div>

	<hr>
	<h2>Crumpet</h2>
	<h3>Ingredients</h3>
	<div class = "crumpet">
	<li>1 Holey Dough
	</div>
	<h3>Steps</h3>
	<div class = "crumpetteps">
	<li>Add the holey dough to the oven.
	<li>Cook the ingredients in the oven for 3 seconds on low.
	</div>

	<hr>
	<h2>Mashed Potatoes</h2>
	<h3>Ingredients</h3>
	<div class = "mash">
	<li>3 Potatoes
	</div>
	<h3>Steps</h3>
	<div class = "mashsteps">
	<li>Mash the potatoes in the mixer until at desired consistency.
	</div>

	<hr>
	<h2>Omelette</h2>
	<h3>Ingredients</h3>
	<div class = "omelette">
	<li>2 Eggs
	<li>1 Piece of Meat
	<li>1 Cheese
	</div>
	<h3>Steps</h3>
	<div class = "omelettesteps">
	<li>Cook the Omelette in the oven for 7 seconds on high
	</div>

	<hr>
	<h2>Pancakes</h2>
	<h3>Ingredients</h3>
	<li>2 Eggs
	<li>1 Milk
	<li>1 Sweet Dough
	</div>
	<h3>Steps</h3>
	<div class ="pancakesteps">
	<li>Mix the ingredients together
	<li>Cook the batter in the oven for 4 seconds on high
	</div>

	<hr>
	<h2>Pizza</h2>
	<h3>Ingredients</h3>
	<div class = "pizza">
	<li>1 Dough
	<li>1 Ketchup
	<li>1 Cheese
	<li>Toppings of your choice (Optional)
	</div>
	<h3>Steps</h3>
	<div class = "pizzasteps">
	<li>Roll out the dough with a rolling pin
	<li>Apply ketchup to the Pizza
	<li>Sprinkle cheese on the pizza
	<li>Apply the toppings of your choice to the pizza
	<li>Cook the pizza in the oven for 9 seconds on high
	</div>

	<hr>
	<h2>Meatpaste</h2>
	<h3>Ingredients</h3>
	<div class = "meatpaste">
	<li>1 Piece of Meat
	</div>
	<h3>Steps</h3>
	<div class = "meatpastesteps">
	<li>Mix the meat in the mixer
	</div>

	<hr>
	<h2>Wontons</h2>
	<h3>Ingredients</h3>
	<div class = "wontons">
	<li> 1 Egg
	<li> 1 Package Flour
	</div>
	<h3>Steps</h3>
	<div class = "wontonssteps">
	<li>Mix egg and flour together
	<li>Place filling of choice into wrapper and wrap
	<li>Place wrapped wonton into deep fryer, fry until fully cooked
	</div>

	<hr>
	<h2>Steak</h2>
	<div class = "steak">
	<li>1 Piece of Meat
	</div>
	<h3>Steps</h3>
	<div class = "steaksteps">
	<li>Cook the meat in the oven for 9 seconds on low
	</div>

	<hr>
	<h2>Sloppy Joe</h2>
	<h3>Ingredients</h3>
	<div class = "sloppy">
	<li>1 Meatpaste
	<li>1 Dough
	</div>
	<h3>Steps</h3>
	<div class = "sloppysteps">
	<li>Cook the ingredients in the oven for 8 seconds on high
	</div>

	<hr>
	<h2>Sweet Dough</h2>
	<h3>Ingredients</h3>
	<div class = "sweetdough">
	<li>1 Dough
	<li>1 Sugar
	</div>
	<h3>Steps</h3>
	<div class = "sweetdoughsteps">
	<li>Knead the sugar and dough together with your hands.
	</div>

	<hr>
	<h2>Nougat Bar</h2>
	<h3>Ingredients</h3>
	<div class = "nougatbar">
	<li>1 Honey Blob
	<li>1 Sugar
	</div>
	<h3>Steps</h3>
	<div class = "nougatbarsteps">
	<li>Cook the ingredients in the oven for 5 seconds on low.
	</div>

	<hr>
	<h2>Candy Cane</h2>
	<h3>Ingredients</h3>
	<div class = "candycane">
	<li>1 Mint Leaves
	<li>1 Sugar
	</div>
	<h3>Steps</h3>
	<div class = "candycanesteps">
	<li>Cook the ingredients in the oven for 5 seconds on low.
	</div>

	<hr>
	<h2>Granola Bar</h2>
	<h3>Ingredients</h3>
	<div class = "granolabar">
	<li>1 Honey Blob
	<li>1 Oatmeal
	</div>
	<h3>Steps</h3>
	<div class = "granolabarsteps">
	<li>Cook the ingredients in the oven for 5 seconds on low.
	</div>

	<hr>
	<h2>Biscuit</h2>
	<h3>Ingredients</h3>
	<div class = "biscuit">
	<li>1 Flour
	<li>1 Dough
	</div>
	<h3>Steps</h3>
	<div class = "biscuitsteps">
	<li>Cook the ingredients in the oven for 4 seconds on low
	</div>

	<hr>
	<h2>English Muffin</h2>
	<h3>Instructions</h3>
	<div class ="emuffinsteps">
	<li>Slice a biscuit in half. Don't forget the butter!
	</div>

	<hr>
	<h2>Hardtack</h2>
	<h3>Ingredients</h3>
	<div class = "hardtack">
	<li>1 Dough
	<li>1 Iron Fillings
	</div>
	<h3>Steps</h3>
	<div class = "Hardtack">
	<li>Cook the ingredients in the oven for 6 seconds on high
	</div>

	<hr>
	<h2>Butter Burger</h2>
	<h3>Ingredients</h3>
	<div class = "burger">
	<li>1 Butter
	<li>1 Dough
	</div>
	<div class ="butterburgersteps">
	<li>Cook the ingredients in the oven for 6 seconds on high
	</div>

	<hr>
	<h2>Sausage MacGuffin</h2>
	<h3>Ingredients</h3>
	<div class = "macguffin">
	<li>2 English Muffins
	<li>1 Cheese
	<li>1 egg
	<li>1 meat
	</div>
	<div class ="macguffinsteps">
	<li>Cook the ingredients in the oven for 6 seconds on high
	</div>

	<hr>
	<h2>Hard-Boiled Egg</h2>
	<h3>Ingredients</h3>
	<div class = "hardboiled">
	<li>1 Egg
	</div>
	<h3>Steps</h3>
	<div class = "hardboiledsteps">
	<li>Cook the ingredients in the oven for 4 seconds on low.
	</div>

	<hr>
	<h2>Deviled Egg</h2>
	<h3>Instructions</h3>
	<div class = "hardboiledsteps">
	<li>Slice a hard boiled egg in half with a knife..
	</div>

	<hr>
	<h2>Egg Salad</h2>
	<h3>Ingredients</h3>
	<div class = "eggsalad">
	<li>1 Hard-Boiled Egg
	<li>1 Salad
	<li>1 Mayo
	</div>
	<h3>Steps</h3>
	<div class = "eggsaladsteps">
	<li>Cook the ingredients in the oven for 5 seconds on low.
	</div>

	<hr>
	<h2>Scotch Egg</h2>
	<h3>Ingredients</h3>
	<div class = "scotchegg">
	<li>1 Slice of Bread, for breading</li>
	<li>1 Piece of Meat</li>
	<li>1 Egg</li>
	</div>
	<h3>Steps</h3>
	<div class = "scotcheggsteps">
	<li>Cook the ingredients in the oven for 3 seconds on high.</li>
	</div>

	<hr>
	<h2>Haggis</h2>
	<h3>Ingredients</h3>
	<div class = "haggis">
	<li>1 Organ (any will do)</li>
	<li>1 Whole Onion</li>
	<li>1 Oatmeal</li>
	</div>
	<h3>Steps</h3>
	<div class = "haggissteps">
	<li>Cook the ingredients in the oven for 9 seconds on high.</li>
	</div>

	<hr>
	<h2>Banh Mi</h2>
	<h3>Ingredients</h3>
	<div class = "banhmi">
	<li>1 Loaf of Honeywheat Bread
	<li>1 Slice of Raw Bacon
	<li>1 Carrot
	<li>1 Cucumber
	</div>
	<h3>Steps</h3>
	<div class = "banhmisteps">
	<li>Cook the ingredients in the oven for 5 seconds on low.
	</div>

	<hr>
	<h2>Onion Chips</h2>
	<h3>Ingredients</h3>
	<div class = "onionchips">
	<li>2 Onion Rings
	<li>1 Garlic
	<li>1 Cheese
	</div>
	<h3>Steps</h3>
	<div class = "onionchipssteps">
	<li>Cook the ingredients in the oven for 7 seconds on high.
	</div>

	<hr>
	<h2>Butt-er</h2>
	<h3>Ingredients</h3>
	<div class = "butters">
	<li>1 Butt
	<li>1 Milk
	</div>
	<h3>Steps</h3>
	<div class = "butterssteps">
	<li>Mix the butt and egg together.
	</div>

	<hr>
	<h2>Pickle</h2>
	<h3>Ingredients</h3>
	<div class = "pickle">
	<li>1 Cucumber
	</div>
	<h3>Steps</h3>
	<div class = "picklesteps">
	<li>Place the cucumber in a food processor and hit process.
	</div>
	<hr>

	<p><i>The following items are for man's best friend: bees.</i></p>

	<hr>
	<h2>Bee Kibble</h2>
	<h3>Ingredients</h3>
	<div class = "beekibble">
	<li>1 Wheat
	<li>1 Honey Blob
	<li>1 ????
	</div>
	<h3>Steps</h3>
	<div class = "beekibblesteps">
	<li>Cook the ingredients in the oven for 10 seconds on high.
	</div>

	<hr>
	<h2>Birthday Cupcake</h2>
	<h3>Ingredients</h3>
	<div class = "birthdaycupcake">
	<li>1 Bee Kibble
	<li>1 Royal Jelly
	<li>1 Sugar
	<li>1 Small Candle
	</div>
	<h3>Steps</h3>
	<div class = "birthdaycupcakesteps">
	<li>Cook the ingredients in the oven for 10 seconds on high.
	</div>

	"}

/obj/item/paper/book/monster_manual
	name = "Creature Conspectus"
	desc = "A large book detailing many creatures of myth and legend. Nerds."
	icon_state = "book3"

	info = {"
	<b>Agent</b>, syndicate
	<br>
	<br>Frequency: Rare
	<br>NO. Appearing: 1-5
	<br>Armor Class: 5
	<br>Move: 5"
	<br>Hit Dice: 1 + 1
	<br>% in Lair: 0%
	<br>Treasure Type: See below
	<br>NO. of Attacks: 1
	<br>Damage/Attack: 4-8
	<br>Special Attacks: Casts Fireball on death.
	<br>Special Defenses: Nil
	<br>Void Resistance: Variable (See below)
	<br>Intelligence: Average
	<br>Alignment: Lawful Maladjusted
	<br>Size: M
	<br>Psionic Ability: Telepathic communication with other Agents.
	<hr>
	<b>Greysuit</b>, armored
	<br>
	<br>Frequency: Uncommon
	<br>NO. Appearing: 1-3
	<br>Armor Class: 6
	<br>Move: 5"
	<br>Hit Dice: 1 + 1
	<br>% in Lair: 0%
	<br>Treasure Type: See below
	<br>NO. of Attacks: 1
	<br>Damage/Attack: 4-8
	<br>Special Attacks: 50% likely to adminhelp
	<br>Special Defenses: Nil
	<br>Void Resistance: Nil
	<br>Intelligence: Low
	<br>Alignment: Chaotic Maladjusted
	<br>Size: M
	<br>Psionic Ability: Nil
	<p>This lesser humanoid, native to the deepest caverns of Maynnetince, is a variant of the common greysuit exhibiting a series of peculiar
	defensive mutations.  Firstly, the torso of the creature is a encased in a thick hide of a notably darker hue than that of an ordinary greysuit.
	Secondly, the head of the beast differs significantly from their unarmored brethren, with a large done of protective grey bone encasing much of the skull.
	The armored greysuit's eyes also receive a limited degree of protection from a translucent manner of tertiary eyelid attached directly to the skull case.
	The true danger of the armored greysuit, however, comes from its choice of weapon: many (65% chance) wield a fearsome shockmace into combat.<br>
	The corpse of this fiend may yield its namesake armor (For details, see pg 289).</p>
	<hr>
"}

/obj/item/diary
	name = "Beepsky's private journal"
	icon = 'icons/obj/writing.dmi'
	icon_state = "pinkbook"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	layer = OBJ_LAYER

	New()
		..()
		BLOCK_BOOK

	examine(mob/user)
		if (!issilicon(user))
			. = list("What...what is this? It's written entirely in barcodes or something, cripes. You can't make out ANY of this.")
			var/mob/living/carbon/jerk = usr
			if (!istype(jerk))
				return

			for(var/datum/data/record/R in data_core.general)
				if(R.fields["name"] == jerk.real_name)
					for (var/datum/data/record/S in data_core.security)
						if (S.fields["id"] == R.fields["id"])
							S.fields["criminal"] = "*Arrest*"
							S.fields["mi_crim"] = "Reading highly-confidential private information."
		else
			return list("It appears to be heavily encrypted information.")

/obj/item/storage/photo_album/beepsky
	name = "Beepsky's photo album"

	New()
		..()
		new /obj/item/photo/beepsky1(src)
		new /obj/item/photo/beepsky2(src)

		var/endi = rand(1,3)
		for (var/i = 0, i < endi, i++)
			var/obj/item/photo/P = new /obj/item/photo/beepsky2(src)
			switch(i)
				if (0)
					P.name = "another [P.name]"
				if (1)
					P.name = "yet another [P.name]"
				if (2)
					P.name = "an additional [P.name]"
					P.desc = "Beepsky is fucking weird."

/obj/item/photo/beepsky1
	name = "photo of a securitron and some objects"
	desc = "You can see a securitron on the photo.  Looks like an older model.  It appears to be holding a \"#1 Dad\" mug.  Is...is that moustache?"
	icon_state = "photo-beepsky1"

/obj/item/photo/beepsky2
	name = "photo of the handcuffs"
	desc = "You can see handcuffs in this photo.  Just handcuffs.  By themselves."
	icon_state = "photo-beepsky2"

/obj/item/photo/heisenbee
	name = "Heisenbee baby photo"
	desc = "Heisenbee as a wee larva.  Heisenbee was a little premature.  Or is that BEEmature???  HA Ha haa..."
	icon_state = "photo-heisenbee"

/obj/item/paper/book/dwainedummies
	name = "DWAINE for Dummies"
	icon_state = "orangebook"
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

<h1>DWAINE for Dummies!</h1>
<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date.<br>
Point your browser to <a href=http://wiki.ss13.co/TermOS>http://wiki.ss13.co/TermOS</a> if anything seems amiss.</i>
<h2>Introduction</h2>
<p>If you're reading this book, it is likely that you have bought a DWAINE System Vi mainframe - but have no idea how to use it! Luckily for you, this book is here to teach you the basics.</p>

<h2>How to Use this Book</h2>
<p>First off, for some bizarre reason you need to know how a book works.
Basically it's this thing with two covers and words inside. You open it and read
the words.<br>
Sometimes in the middle of the words there are pictures, but not in this book.
Pictures are for losers and babies.</p>
<p>Now and again I'll give you advanced tips, which will appear in boxes like this one:
<div class="tips">
<li>Words are great!</div>
<p>And when I need to write code, it will appear in boxes like this:</p>
<div class="code">$: ls /butts</div>
<br><br>
<h2>Chapter 1: The Terminal</h2>
<p>Operating a DWAINE mainframe is done solely through a terminal interface - graphics and icons and things are unnecessary and also are for tiny children with no understanding of REAL COMPUTERS.</p>
<p>So, let's get started! After logging in, you will be presented with a prompt - usually following this format:</p>
<div class="code">
]GMelons@DWAINE - 12:00 03/04/52
</div>
<p>When you type in text and push the Enter key, you will notice your command is sent like this:</P>
<div class="code">
>things i typed
</div>
<p>This book will show commands you should enter as beginning with <i>">"</i>.
<div class="tips">
<li> Remember! The most important command is <i>"help"!</i>
</div>
<br><br>
<h2>Chapter 1: Logging On</h2>
<p>Before we can do anything, we need to log onto the network. This guide assumes you aren't already synched to your DWAINE mainframe.<br>
Insert your ID into the ID card slot of your terminal.<br>
Then, type
<div class="code">
>term_ping
</div>
<p>and push enter to get a list of networked devices. Find the device labeled PNET_MAINFRAME and take a note of its net_id.
<br>
Then, type
<div class="code">
>connect 0200xxxx
</div>
<p>where 0200xxxx is the term_id of the PNET_MAINFRAME.<br>
Then, with your ID inserted, simply type
<div class="code">
>term_login
</div>
<p> to log into the system.
<div class="tips">
<li> When logged in, you can log off by typing <i>"logout" OR "logoff"</i>.
<li> You can disconnect by typing <i>"disconnect"</i>.
<li> You can restart by typing <i>"restart"</i>.
</div>
<h2>Chapter 2: Basic Concepts</h2>
<p>
The first thing you need to know about DWAINE is the Filesystem.<br>
There are no drives in DWAINE, no specific devices. Everything is a folder in DWAINE.
</p><p>
The structure works like a tree, with everything starting at the "root" folder,
and expanding outwards from there. A typical file path in DWAINE would look like
this:<br>
<div class="code">
/home/GMelons/Pictures/pr0n_jpg
</div><p>
You might be wondering what the name of the root folder is, since it doesn't
seem to be immediately obvious in that filepath. The system root is referred to
as <i>"/"</i>. So, if we expand this path, we get this:
<div class="code"><pre>/
	home/
		GMelons/
			Pictures/
				pr0n_jpg
				butt_png
			Music/
				fart_ogg
		JGrife/
			Documents/</pre>
</div>
<p>
So, if we wanted to listen to something, we would use this path:<br>
<div class="code">
/home/GMelons/Music/fart_ogg
</div>
<p>
Simple, right? Well.
</p>
<br>
<h2>Chapter 3: Simple Commands</h2>
<p>First, let's discuss listing directories.<br>
You can find out what is in the current directory by typing
<div class="code">
>ls</div>
<p> and hitting Enter.<br>
This will show you a list of files and directories inside the folder!<br>
You can also give <i>ls</i> a directory path to look at instead: so if you wanted to snoop on JGrife's stuff, you would type:
<div class="code">
>ls /home/JGrife
</div>
<div class="tips">
<li> Sometimes you won't be able to look at files in a directory! See Chapter 6 for details!
<li> Additionally there may be hidden directories on the system, which contain special system files!</div>
<p>
Now, let's discuss changing directories.<br>
To change which directory you are in, just type
<div class="code">
>cd
</div>
<p>
followed by the path you want to change to.<br>
<p>
So, let's say we want to go to our Pictures directory.
<div class="code">
>cd /home/GMelons/Pictures
</div>
<p>
And here we are! If you want to move one space up the file path, back to
GMelons, you would write
<div class="code">
>cd ..
</div>
<p>
instead. Note that using ".." as a file path works with other commands too.<br>
If you were in GMelons and you wanted to go to Pictures, you could also
just type
<div class="code">
>cd Pictures
</div>
<p>
and you would go there.
<br>
<br>
Next, let's try copying files around!<br>
The copy command is:
<div class="code">
>cp
</div>
<p>
Followed by the original file, and then the destination. Pour �xample:
<div class="code">
>cp /home/GMelons/Pictures/butt_png /home/JGrife/Documents
</div>
<p>
This would copy the file "butt_png" to /home/JGrife/Documents.<br>
However, you can copy and give the destination file a new name, like this:
<div class="code">
cp /home/GMelons/Pictures/butt_png /home/JGrife/Documents/importantfile_txt
</div>
<p>
So now, JGrife sees he has an important file to open! OH NO! Butt!<br>
<br>
Okay, let's discuss moving files now.<br>
The move command is:
<div class="code">
>mv
</div>
<p>
Followed by the original file, and then the destination - exactly like copy,
except the original is moved from one location to the other. Good for stealing
data, like nuclear authentication codes! Or, uh. Cute pictures of duckies.
<br>
<br>
<h2>Reading, Writing, and Deleting</h2>
<p>
"But HOW DO I MAKE FILES OR SEE WHAT'S IN THEM AAAA"<br>
 <br>
Stop that! Stop it! Stop!<br>
You're a bad person.<br>
<br>
To read the contents of a file, use:
<div class="code">
>cat
</div>
<p>
Followed by the path to the file. Here we go!
<div class="code">
>cat /home/JGrife/secret_stuff
I like to read trashy romance novels!!!
</div>
<div class="tips">
<li> Not all files can be read - some do not contain text, but are actually programs!
<li> Run these by typing their name in the terminal.
<li> Programs on a Research Station are usually kept in <i>/mnt/control</i> - the location of the control database.</div>
<p>
What a shocker, eh?
<br>
Writing files is a little bit different. At the time of writing this guide,
no text editor existed for DWAINE so we have to make do with the
<div class="code">
>echo
</div>
<p>
command.<br>
Echo just repeats whatever you type after it back to you. That sounds useless,
right?<br>
Well, there's a little thing called <i>"output redirection"</i>. This means we can take
what comes out of a command and put it somewhere else. Here's an example:
<div class="code">
>echo I like big smelly butts! ^/home/JGrife/my_secrets
</div>
<p>
What this will do is write the text "I like big smelly butts!" into a file called "my_secrets" in JGrife's folder. The redirection is done with the
<div class="code">
>^
</div>
<p>
symbol. Anything immediately after the symbol is where the output
from echo will go.
<br>
Hooray! Hmm, we might need to organise our things better. How about we make
a new folder?
<div class="code">
>mkdir name_of_folder
</div>
<p>
Will do it! Just navigate to where you want the new folder to be, and use mkdir
with the name of the new folder and it shall appear.
<br>
To delete a file, use the
<div class="code">
>rm
</div>
<p>
command.
<div class="tips">
<li> Remember that every command has an associated help entry!
<li> Type <i>"help rm"</i> for advanced help on deleting files.</div>
<br><br>
<h2>Printing & Backups</h2>
<p>
Let's take a moment to go over devices in DWAINE.<br>
There is no "print" function in DWAINE. Why? Because DWAINE stores devices as
folders, using drivers to communicate with them. Storage drives and printers
appear in the <i>/mnt</i> folder in DWAINE.
<br>
So, let's say we want to print off JGrife's embarrasing secrets and share them
around the Research Sector - how do we do that?
<br>
Well, DWAINE's default printer driver works like this: if you move or copy a
file into the printer's folder, the printer reads the file and prints it off.
Pretty simple, really!
<div class="code">
>cp /home/JGrife/secret_stuff /mnt/printer_name
</div>
<p>
And out it comes! Printer names are usually prefixed with "lp-" by the way, so
that you know they are printers and not storage drives.
<br>
To copy a file to a storage drive, simply do the following:
<div class="code">
>cp /home/GMelons/Pictures/pr0n_jpg /mnt/drive_name
</div>
<p>
Easy!
<br><br>
<h2>Chapter 6: Advanced Usage</h2>
<p>
Sometimes you want to stop people looking at your files. Nobody likes a snooper!
<br>
To protect your files, you will want to use the
<div class="code">
>chmod
</div>
<p>
command.
<br>
Usage of the chmod command is complicated: chmod takes an Octal number as its
second parameter, usually formatted as a 3-digit number.
<div class="code">
>chmod 777 file_name
</div>
<p>
For an example.
<br>
The number means this:
The first digit sets what kind of access the Owner of the file has.
<br>
The second digit sets what kind of access the Group that the owner belongs to
has.
<br>
The third digit sets what kind of access everybody else has.
<br>
Access digits are as follows:<br>
<div class="tips">
<li>7 - Full Access
<li>6 - Read and Write
<li>5 - Read and Modify
<li>4 - Read Only
<li>3 - Write and Modify
<li>2 - Write Only
<li>1 - Modify Only
<li>0 - None
</div>
<p>
So, to prevent absolutely anyone except yourself from reading your files, use
<div class="code">
>chmod 700 file_name
</div>
<p>
You'll get the hang of it.<br>
Of course, an alternate method presents itself: make that file hidden!<br>
To make a file hidden, simply make its name begin with an underscore "_".
<div class="code">
>mv mysecret _mysecret
</div>
<p>
To see hidden files, you must use <i>"-l"</i> (not -1) when giving the ls command:
<div class="code">
>ls -l /path
</div>
<p>
ls -l will also show you the read,write,execute(run) status of each file, along
with the owner.

What if you want to change who owns a file?
<br>
Simple! Use the chown command.
<div class="code">
>chown user_name file
</div>
<p>
The specified user now owns that file.
<br>
That's it folks! That's the end of this book! Captains, Research Directors, all honest members of Nanotrasen crew, do not turn the next page!<br>
It is terribly boring and does not contain any useful information whatsoever!
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

Still reading? Good. I'm a member of the syndicate, and I'm here to teach you how to steal data.<br>
<div class="code">
>su -
</div>
<p>
Will elevate your priveleges to administrator level. This will let you use the <i>ls</i> command in the root directory to view hidden system files and folders.<br>
It's possible to steal things like login credentials and session keys, enabling you to gain access as another user even if you're not authorized - and frame them for theft. <br>
Unfortunately, the <i>su</i> command requires an administrator-level ID card. But this should not prove a challenge to a fellow agent.<br>
<br>
STEAL DATA. STEAL DATA. STEAL DATA.

<div class="tips">
<li> Good luck!</div>


</body>
</html>

"}

//todo-finish this
/obj/item/paper/book/guardbot_guide
	name = "The Buddy Book"
	icon_state = "book5"

	info = {"
<html>
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
<h1>The Robuddy Book</h1>

<h2>Introduction</h2>
<p>Since their introduction twenty years ago, the PR (For Personal Robot) Robuddy series has grown to become the most popular robotics platform produced by Thinktronic Data Systems.
The Model 6 is the most recent version at the time of this writing, largely acting as a refinement of the PR-5.  The PR-6 has a number of submodels, covering fields ranging from medical care (The PR-6RN), security (PR-6S), and engineering (PR-6E) </p>
<h2>Charge Dock</h2>
<p>Though it features the longest standard battery life of all Robuddy models, the PR-6 still requires a periodic recharge in the provided docking station.
The dock serves as more than just a battery charger, however: It is also allows new software (Tasks) to be uploaded, or the unit's current task software to be cleared.</p>
<h2>Tasks</h2>
<ul>
<li><b>GUARD:</b> This will direct the Robuddy to serve as a trusty bodyguard, exacting buddy-vengence on anyone attempting to harm their charge.</li>
<li><b>SYNC:</b> The sync task is employed when the Robuddy has been instructed to connect to a charge dock.  It directs the unit through radio identification of a free dock and then guides it there.</li>
<li><b>SECURE:</b> In this mode, the Robuddy will remain stationary and scan its surrounding environment for hostile agents, based on the same criteria as the "Securitron" series.</li>
<li><b>PATROL:</b> Identical to the Secure task, with one exception: The Robuddy will patrol a set path based on navigational radio beacons.</li>
</ul>
<h2>Buddy Configuration</h2>
<p>As previously stated, the PR-6 is configured and programmed through its charge dock, which is itself typically controlled by a networked Thinktronic mainframe running the DWAINE operating system.
"PRMAN" control software, with accompanying control driver and support scripts, is supplied with a standard Robuddy installation.
PRMAN requires system operator privileges to operate, which may be granted through use of the "su" command.
</p>
For example, if the provided tape was mounted at the default databank "control"
<div class="code">
cd /mnt/control<br>
su<br>
prman list
</div>
This would list all connected units by the 8-digit system IDs of their current docks.

<p><b>Checking a Robuddy's Status:</b><br>
PRMAN's "stat" command will list the current task, equipment, and charge information for a Robuddy. To check a Robuddy with example ID 02001122:
<div class="code">
prman stat 02001122
</div>
</p>

<p><b>Bodyguarding:</b><br>
If it was desired to program a buddy with ID "02001122" to guard someone named (As stated on their company ID) "Dr. Roger Tuppkins," the provided guard script could be employed in this manner:
<div class="code">
guard_script 02001122 drrogertuppkins
</div>
If successful, a message will appear indicating that the unit has been deployed.
</p>
<p><b>Patrolling:</b><br>
Use of the included patrol script is also straightforward:
<div class="code">
patrol_script 02001122
</div>
This would wake the unit and send them trundling off to patrol their environment.
</p>
<p><b>Waking and Recalling Robuddies:</b><br>
Waking a docked Robuddy is very simple.
<div class="code">
prman wake 02001122
</div>
PRMAN is also able to recall deployed buddies to docks, though not necessarily the same dock they initially deployed from.
Both the ID of the buddy itself and that of its last dock (Provided no other buddies have since used it) may be used.
<div class="code">
prman recall 02001122
</div>
Units may be recalled en masse by using "all" in place of the ID
<div class="code">
prman recall all
</div>
</p>
</body>
</html>
"}

/obj/item/paper/book/hydroponicsguide
	name = "The Helpful Hydroponics Handbook"
	icon_state = "hydrohandbook"
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
<p>Maturation Rate is the gene that influences how long a plant takes to grow from a small sapling into an adult plant. With this gene, a higher readout is better as it means a quicker growth cycle.</p>
<p>Production Rate is the gene dealing with how long it takes an adult plant to produce viable crops. Again, higher is better. Essentially, every time a plant is harvested it is returned to the beginning of the adult stage of its growth cycle -
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


/obj/item/paper/book/medical_guide
	name = "Pharmacopia"
	icon_state = "pharmacopia"
	desc = "A listing of basic medicines and their uses."
	info = {"<h1>NT MEDICAL DIVISION</h1>
		<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date.</i></p>
		<h2>ESSENTIAL MEDICINES LIST FOR NANOTRASEN FACILITIES</h2>
		<br>
		<hr>
		<h2>PHYSICAL TRAUMA</h2>
		<hr>
		<h3>Styptic Powder</h3>
		<div class ="styptic">
		<li>Aluminium Sulfate helps control bleeding and heal physical wounds.
		<li>This compound can be prepared by combining Aluminium Hydroxide with Sulfuric Acid.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Synthflesh (topical)
		<li>Cryoxadone (cryogenics)
		<li>Omnizine (systemic)
		</div>
		<br>
		<hr>
		<h2>BURNS</h2>
		<hr>
		<h3>Silver Sulfadiazine</h3>
		<div class ="sulfa">
		<li>This antibacterial compound is used to treat burn victims.
		<li>Prepare a sulfonyl group with sulfur, oxygen and chlorine.
		<li>React with ammonia for sulfonamide, and combine with silver.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Synthflesh (topical)
		<li>Cryoxadone (cryogenics)
		<li>Omnizine (systemic)
		</div>
		<br>
		<hr>
		<h2>POISONINGS</h2>
		<hr>
		<h3>Activated Charcoal</h3>
		<div class ="charcoal">
		<li>Activated Charcoal helps to absorb toxins from the body and heal moderate toxin damage.
		<li>Heat ashes together with salt to produce activated charcoal.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Pentetic Acid: A potent chelating agent, structurally quite similar to EDTA.
		</div>
		<h3>Calomel</h3>
		<div class = "calomel">
		<li>Calomel, or Mercurous Chloride, is a rapid purgative that will remove other reagents from the body. It is quite toxic.
		<li>It should be used only when the the poisons in your patient are worse than Calomel itself.
		<li>Preparation: heat Mercury and Chlorine together.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Pentetic Acid
		</div>
		<br>
		<hr>
		<h2>RADIATION</h2>
		<hr>
		<h3>Potassium Iodide</h3>
		<div class ="antirad">
		<li>Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning.
		<li>React Potassium with Iodine. All done!
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Pentetic Acid
		</div>
		<br>
		<hr>
		<h2>CRITICAL HEALTH CRISES</h2>
		<hr>
		<h3>Saline-Glucose Solution</h3>
		<div class ="saline">
		<li>This saline and glucose solution can help ward off shock and promote healing.
		<li>It is a simple mixture of salt, water and sugar.
		</div>
		<h3>Epinephrine</h3>
		<div class ="epinephrine">
		<li>Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest.
		<li>It can be synthesized by combining hydroxylated phenol with chloroacetyl chloride and methylamine,
		<li>In the event that your station lacks these precursors... well, make do with something similar.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Atropine
		</div>
		<br>
		<hr>
		<h2>PAIN</h2>
		<hr>
		<h3>Salicylic Acid</h3>
		<div class="salicylic acid">
		<li>This is a is a standard salicylate pain reliever and fever reducer. It will help relieve slowed movement from injuries.
		<li>Synthesis: treat Sodium Phenolate with Carbon Dioxide, then acidify with Sulfuric Acid.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Morphine (HIGHLY ADDICTIVE. HIGH DOSES MAY LEAD TO SEDATION OR COMA.)
		</div>
		<br>
		<hr>
		<h2>SUFFOCATION</h2>
		<hr>
		<h3>Salbutamol</h3>
		<div class = "salbutamol">
		<li>Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well.
		<li>Synthesis: treat Salicylic Acid with bromine, ammonia, and lithium aluminium hydride.
		<br>
		<h4><i>Advanced:</i></h4>
		<li>Perfluorodecalin (liquid breathing)
		<li>Cryoxadone (cryogenics)
		<li>Omnizine
		</div>
		<br>
		<hr>
		<h2>VARIOUS OTHER PROBLEMS</h2>
		<hr>
		<h3>Diphenhydramine</h3>
		<div class ="diphenhydramine">
		<li>Anti-allergy medication. May cause drowsiness.
		<li>Synthesis route involves Benzhydryl bromide and 2-dimethylaminoethanol.
		</div>
		<h3>Spaceacillin</h3>
		<div class = "spaceacillin">
		<li>An all-purpose antibiotic agent extracted from space fungus.
		<li>Combine spage fungus with ethanol as a solvent.
		</div>
		<h3>Mannitol</h3>
		<div class ="mannitol">
		<li>Mannitol is a sugar alcohol that can help alleviate cranial swelling.
		<li>Hydrolyze sucrose towards fructose, hydrogenate to yield mannitol sugar.
		</div>
		<h3>Oculine</h3>
		<div class ="oculine">
		<li>Oculine is a combined eye and ear medication with antibiotic effects.
		</div>
		<h3>Haloperidol</h3>
		<div class ="haloperidol">
		<li>Haloperidol is a powerful antipsychotic and sedative. Will help control psychiatric problems, but may cause brain damage.
		</div>
		<h3>Mutadone</h3>
		<div class ="mutadone">
		<li>Mutadone is an experimental bromide that can cure genetic abnomalities.
		</div>
		<br>
		<hr>
		<i>This is not a complete list of all available medications. Further research and development efforts by NT Medical and Science divisions are strongly encouraged.</i>
		"}

		// <li><a href="#introduction">Introduction</a>
		// <li><a href="#tools">Tools</a>
		// <li><a href="#surgery">Surgery</a>
		// <li><a href="#functions">Organ Functions</a>
		// <li><a href="#diseases">Organ Diseases</a>
		// <li><a href="#treatment">Treatments</a>

/obj/item/paper/book/medical_surgery_guide
	// name = "Trents Anatomy"
	name = "Surgical Textbook"
	desc = "The inane ramblings of the first jerk who bothered writing a textbook on the spaceman anatomy and surgical practices."
	icon_state = "surgical_textbook"
	info = {"<div><h1>Trent's Anatomy</h1>
		<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date. But that doesn't make this information any less correct.</i></p>
		<h2><b>FOREWARD</b></h2>
		<p>While snails share many organs in common with the human body, they have no sense of hearing.<br>
		<i>by Dorothy "Dotty" Spud</i></p>
		---------------------------------------------------------------------------------------------<br>
		<h3>Index</h3>
		<ul>
			<li>Introduction
			<li>Tools
			<li>Surgery
			<li>Organ Functions
			<li>Organ Diseases
			<li>Treatments
		</ul>
		<h3>Introduction</h3>
		<p>Every spaceman and spacewoman has several internal organs that allow they to live, this textbook will seek to inform you about some of them and how to do surgery. The most important organ of the body is a hotly disputed topic among Nanotrasen employees and regular people. Most Nanotrasen experts agree that it is the butt, as the humiliation of losing a butt is considered worse than death. Others say that it's the brain, who can say for sure? Not I.</p>
		<h3>The spaceman body and you</h3>
		<div id ="introduction">
		<p>Here are all the important organs and their main functions (they'll be described in more detail later on):</p>
		<ul>
			<li><b>Brain</b> - Needed for thinking.
			<li><b>Butt</b> - Needed for thinking.
			<li><b>Heart</b> - Pumps life giving blood around your body. If you remove this, you should replace it very quickly.
			<li><b>Eyes</b> - You see out of these.
			<li><b>Lungs</b> - These steal Oxygen from the air on space stations and give it to you to use for respiration. Atmos engineers hate em!
			<li><b>Kidneys</b> - These filter out "toxins", or "thetans" as I like to call them, from your blood and turn them into pee.
			<li><b>Liver</b> - This is basically the same as kidneys, but looks different, has a different name, and does some different things.
			<li><b>Stomach</b> - This digests all the food you eat orally. If this is empty, you will not be able to puke, be very careful.
			<li><b>Intestines</b> - This is the glorious organ that turns food into poo. Rather it did, until something catastrophic happened a few years ago and now nobody's makes poo anymore.
			<li><b>Spleen</b> - This has some function. Mainly it is involved in making blood in spacemen, maybe it does something else too.
			<li><b>Pancreas</b> - This makes insulin in response to sugar in your bloodstream.
			<li><b>Appendix</b> - What does this do? Nobody knows, and if they ever did, they were lying. It does have a "fun" ability to attempt to kill you at random so there's that.
		</ul>
		<br>
		<p>Those are all the organs that will be discussed in this book. Some say there are more organs, but if there are then are I don't care about them so I won't include them in my book.</p>
		</div>
		<h3>The Tools</h3>
		<div id ="tools">
		<p>There are several tools involved in surgery, some of them are even listed here:</p>
		<ul>
			<li><b>Scalpel</b> - Used for cutting.
			<li><b>Circular Saw</b> - Used for sawing.
			<li><b>Enucleation Spoon</b>  - Used for melon-balling eyes out of a patient's head.
			<li><b>Garden Snips</b> - Used for snipping.
			<li><b>Hemostat</b> - Used for clamping down bleeders. Hold this in your off hand to make most surgery cause less bleeding.
			<br>
			<li><b>Health Analyzer Organ Upgrade</b> - Until now, it was only possible for health analyzers to crudely detect brain damage in a subject. With this upgrade, health analyzers will be able to crudely detect the health of ANY organ!
			<li>The last tool, if it can be called such, is the operating table or bed. For some reason that continues to baffle medical science, the type of surface that the patient is placed on in surgery is important for being able to perform surgery. Operating tables are the gold standard for surgery, next comes regular beds, these work just as well. Finally you can perform surgery on any old table, provided the patient is knocked out, stunned, or otherwise sufficiently anesthetized/drunk.
		</ul>
		</div>
		<h3>Doing Surgery</h3>
		<div id ="surgery">
		<p>Everybody knows how to perform brain surgery, the basest form of surgery that even a staff assistant manage, so I won't bore you with how to perform it here. Instead here are some revolutionary new surgery practices <i>invented</i> by me to get at all those tantalizing organs inside of your fellow spaceman:</p>
		<br>
		<ul>
			<li>Scalpel =		cut
			<li>Circular Saw = 	saw
			<li>Garden Snips = 	snips
		</ul>
		<br>
		<ul>
			<li>lungs = 		snip -> saw -> snip<sup>1</sup>
			<li>appendix = 		snip -> snip -> snip
			<li>liver = 		snip -> snip -> cut
			<li>stomach = 		snip -> cut -> snip
			<li>intestines = 	snip -> cut -> cut
			<li>pancreas = 		cut -> snip -> snip
			<li>spleen = 		cut -> snip -> cut
			<li>kidneys = 		cut -> cut -> snip*
			<li>heart = 		cut -> saw -> cut -> saw<sup>2</sup>
		</ul>
		<br>
		<sup>1</sup> Use Right/Left hands for removing R/L organ on this step<br>
		<sup>2</sup> Use "HELP" intent for the whole surgery. <b>ABSOLUTELY DO NOT USE "HARM" INTENT!
		<p>After each successful organ removal or replacement, the surgeon must close up so they can take the correct pathway to the next organ they want to locate. The simplest way to do so would be to suture the chest closed with regular a old medical suture.</p>
		<br>
		<p>As an afterthought, for the sake of completeness I <b>will</b> bother bore you with how to do some of the "lesser" surgeries, here are the steps for most other common surgical procedures:</p>
		<ul>
			<li>brain = cut -> saw -> cut -> saw - Target HEAD on "HELP" intent (*note - Performing this surgery on "HARM" intent can decapitate the head).
			<li>eyes = L/R spoon -> L/R cut -> L/R spoon - 	in order to remove a specific eye, you must only hold a tool in the corresponding hand R/L.
			<li>limbs = cut -> saw -> cut 	while targeting the appropriate limb. Replacing a limb only requires you to target the correct limb, and then staple it firmly to the stump.
			<li>butt = I do not know how to remove butts, and if I did I wouldn't spread that knowledge for it is a cruel and inhumane practice to remove a butt from anyone.
		</ul>
		</div>
		<h3>Organ Functions</h3>
		<div id ="functions">
		<b><p>Brain</b></p>
		<p>This organ takes damage in a number of ways, through concussions, oxygen loss, or neurotoxins. That's pretty much it actually.</p>
		<br>
		<b><p>Butt</b></p>
		<p>This is needed for farting, I think, I've never removed mine so I wouldn't know. Presumably it has some medical function. It can be worn as a hat.</p>
		<br>
		<b><p>Heart</b></p>
		<p>This terrible organ is really awful, it breaks down more than any other organ and when it does, you're as good as dead. So many things can cause it to fail, such as not breathing for a minute or two. Silly things like that.</p>
		<br>
		<b><p>Eyes</b></p>
		<p>Without these, you'll be blind. I've heard it said that sometimes blind people sometimes see more than all of us normal spacemen. Anyway, these take damage from numerous sources, like getting stabbed in the eye. They can be repaired with oculine. Strangely, you eyes can be in perfect health and you can go blind.</p>
		<br>
		<b><p>Lungs</b></p>
		<p>Basically the most important organs for swimmers, runners, and players of sportsball. You can get by without em, but you probably won't want to. Smoking is the number one enemy of the noble Lung, they don't mind your drinking or gambling, but smoking is where they draw the line.</p>
		<br>
		<b><p>Kidneys</b></p>
		<p>These filter out all the toxins your inject/ingest on a daily basis. Any time you get injured by toxins, these babies will be right there next to you and take the hits as they come.</p>
		<br>
		<b><p>Liver</b></p>
		<p>Ethanol is the worst enemy/best friend of the Liver. The liver is a powerful and resilient organ, but ethanol is super effective against it. If you want to drink yourself to death, but not to a death from liver failure, you'd better swap out your good ole liver for a brand new cyber liver. Those like ethanol so much, it makes them run even better!</p>
		<br>
		<b><p>Stomach</b></p>
		<p>Nothing to see here it digests food, what else is there to know?</p>
		<br>
		<b><p>Intestines</b></p>
		<p>Intestines suck all the nutrients out of your food and put them into your body. And before I get a letter in the space-mail about this, there is no such thing as a "small" or "large" intestines, there is just one.</p>
		<br>
		<b><p>Spleen</b></p>
		<p>The spleen has several functions, I assume. The only one I have discovered is it's ability to help the spaceman body produce blood. If there are more, then I take credit for their discovery by virtue of discovering the Spleen.</p>
		<br>
		<b><p>Pancreas</b></p>
		<p>When you eat the sugar, the mighty pancreas attempts to produce insulin in order to help you metabolize it. So that you can keep eating sugar forever until you die..</p>
		<br>
		</div>
		<h3>Organ Diseases</h3>
		<div id ="diseases">
		<p>Some diseases affect specific organs when that organ has taken enough damage to start to fail, for that reason I have decided to call this class of diseases "Organ Diseases". Most of these are fairly manageable, and you won't suffer any debilitating effects until you the disease does enough damage to your organ and it shuts down.</p>
		<b><p>Appendicitis</b></p>
		<p>This disease is very, very deadly. If left untreated, your appendix will explode violently, spraying gross toxins and pathogens all throughout the inside of your body. It can happen anywhere or anytime, the only thing that will stop it is a simple surgery to remove the appendix. While there, you might as well ask around to see if you can have it replaced with the much more stylish cyber-appendix.</p>
		<br>
		<b><p>Pancreatitis</b></p>
		<p>This is a nasty disease, as insidious as Darth Sidious and as fun sounding as fudge. But that is where the fun ends. Think you can eat all the sugar you want forever with no consequences other than hypoglycemic shock? Think again. That insulin your poor poor pancreas is producing to keep you chugging along doesn't come free, take care of your pancreas or risk losing the ability to enjoy your favorite brand of space cola and bars of chocolate.</p>
		<br>
		<b><p>Liver Failure</b></p>
		<p>This is probably the worst disease I made up, I mean discovered. Your liver is a fantastic organ, without it, you would be hard pressed to enjoy all that alcohol you always drink since you'd probably die pretty quick.</p>
		<br>
		<b><p>Kidney Failure</b></p>
		<p>This is basically the same as liver failure, but your kidneys are the ones failing, good thing you got two of em. Just remove or replace the failing one and you'll be good to go. That is, unless it gets too severe.</p>
		<br>
		<b><p>Respiratory Failure</b></p>
		<p>Basically, your lungs are failing, or one of them is at least, and it's bringing the other one along for the ride. It can be caused by a number of things, like smoking. Or breathing scalding hot air. Or smoking. Did I mention smoking can cause this?</p>
		<br>
		<b><p>Treating Organ Diseases</b></p>
		<p>In most cases, removal/replacement of the organ in failure will cure the disease. Certain reagents can be effective at healing organ damage, and curing their respective diseases.</p>
		<br>

		</div>
		<h3>Organ Damage Treatment</h3>
		<div id ="treatment">
		<p>Presently there are only a few known ways to treat organ damage, provided they are not damaged too extensively. This "chapter" will discuss the most common ways.</p>
		<p>It is probably helpful to seperate organs into 3 different groups in order to more quickly and easily treat them.<br>
		The reason for each grouping should be completely obvious to anyone who cares to think about it so I will not explain the logic behind each grouping.</p>

		<p><b>Group I: Lungs and Spleen</b></p>
		<p>Medicine that heals respiratory damage is most effective here. Salbutamol and Perfluorodecalin are good candidates.</p>
		<br>
		<p><b>Group II: Liver, Kidneys, Stomach, and Intestines</b></p>
		<p>Medicine that deals with flushing out toxins and</p>
		<br>
		<p><b>Group III: Appendix and Pancreas</b></p>
		<p>These are the loneliest, in this case it's because there is no type of drug that can specifically target them for healing.</p>
		<br>
		<p>Despite these groupings, which are in no way arbitrary, there are several other reagents that can be used for more general treatment. Below are the two I have discovered thus far.</p>
		<p><b>Cryoxadone</b></p>
		<p>Capable of healing all organs in the body, just rather slowly and coldly.</p>
		<p><b>Omnizine</b></p>
		<p>Is there anything this stuff can't do? There is, quite a lot in fact; but in the context of healing organs omnizine is pretty good.</p>
		<br>
		<p>It's been theorized that gene therapies are also capable to healing internal organs over time. Though I have not collected any solid data on this to date.</p>
		</div>
<h5>by Trent Durinste<br>2053 C.E.</h5>
</div>"}

/obj/item/paper/book/minerals
	name = "Mineralogy 101"
	icon_state = "minerology"
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

<h1>Mineralogy 101</h1>
<p><i>Disclaimer: At the time of writing, all information in this book is correct. However, over time, the information may become out of date.<br>
<h2>Introduction</h2>
<p>The distinction between minerals in a mining and/or manufacturing environment can sometimes get rather confusing.
Over the course of this handbook, we hope to give you at least a rudimentary education on the various minerals most commonly
found in a space environment, and what they should be used for. This is especially helpful if you are trying to understand
the recent (as of the time of writing) changes made to the NanoTrasen \"AutoArtisan\" standard-issue Manufacturing Units.</p>

<h2>Mauxite</h2>
<p>Classification: Sturdy Metal</p>
<p>Mauxite is a common metal alloy, characterised by its dull reddish-brown color and mild coppery smell. It is commonly used
in construction projects due to being very durable while still rather easy to work with, no doubt due to it being an alloy
comprised mostly of naturally occurring steel with elements of copper and zinc also present among other elements.
It tends to be rather easy to find in space due to its abundance, and poses little risk during extraction or refinement.</p>

<h2>Pharosium</h2>
<p>Classification: Metal, Conductor</p>
<p>Easily recognizable due to its distinct bright orange hue, Pharosium is a conductive metal found in plentiful quantity
and as such is generally considered an industry standard. It finds most common use in electrical wiring and circuit boards.
Often, basic electronics are comprised mostly of Pharosium and Mauxite in their construction.
</p>

<h2>Molitz</h2>
<p>Classification: Crystal</p>
<p>Somewhat similar to both Quartz and glass found on Earth, Molitz is a crystal formation that bears the best qualities of
both, being durable enough to withstand significant shock, and at the same time easy to work with due to its abundance and
malleability. It most often finds use in glass installations on space stations, most often affixed into place as a fine
sealant and durable enough to not pose a potential atmospheric hazard in everyday circumstances.
</p>

<h2>Char</h2>
<p>Classification: Not Construction Grade Material</p>
<p>Char is a black, flaky substance mostly comprised of carbon, and bears a significant similarity to coal. While it is not
generally used in construction projects due to its brittle and weak structure, it does often find use as a fuel source for
basic combustion power systems. It can also be used in chemistry, as a means of acquiring large amounts of carbon and other
trace elements. The origin of this mineral is unknown, as the process of creating coal could not feasibly occur in deep space.
</p>

<h2>Cobryl</h2>
<p>Classification: Metal</p>
<p>While it rarely finds use in industrial and construction projects, Cobryl nevertheless finds itself as a notable material
due to its popularity with industries that deal in luxury. It is light blue in coloration, and when properly treated and
cleaned displays a unique lustre not seen in other materials. It has marginal strength as a metal and as such can be used in
small-scale constructions, but it should not be used for anything that requires significant sturdiness.
</p>

<h2>Cytine</h2>
<p>Classification: Crystal</p>
<p>Cytines are small gemstones of varying color. While no stronger than Molitz at best, they are prized by jewel collectors
and luxury goods traders for their compact shapes, light weight and highly varied color.
</p>

<h2>Fibrilith</h2>
<p>Classification: Not Construction Grade Material</p>
<p>Fibrilith is a highly strange mineral known for both its unusual threaded molecular structure and its extreme softness for
a mineral substance. While it is not paticularly useful in any kind of construction project, it has been successfully woven
into a fabric highly similar to linen. As such, it is prized by textile industries and used in clothing.
</p>

<h2>Bohrum</h2>
<p>Classification: Dense Metal, Dense Matter</p>
<p>Well known among the scientific community for its bizarre chemical makeup, Bohrum is equally well known among the
construction industry for its incredible resilience to damage. It is known to be an alloy of iron, titanium, krypton, xenon,
silver and lead, as well as several previously undiscovered chemical elements which are subject to intense research. While
the noble gases have been formed into compounds in laboratory settings, having them occur naturally with such complexity was
previously considered unthinkable. In spite of these unknown qualities, Bohrum as has yet proven to be an incredibly safe
material to work with and possesses immense strength as a construction material, though its high density makes it very heavy
and thus it is not suited to certain structural projects.
</p>

<h2>Claretine</h2>
<p>Classification: High Energy Conductor</p>
<p>A mineral salt of a brilliant bright red coloration, Claretine is a high-end electrical conductor, able to conduct immense
amounts of electricity without suffering any damage at all. At paticularly high energy states, Pharosium and other lower
grade conductors have been known to lose efficiency due to heat and eventually break down and melt - Claretine appears to
have an incredible resistance to heat in general, and thus is spun into wire spools and used for electrical wiring in
paticularly high-energy systems. It is not common however, and should be used resourcefully.
</p>

<h2>Telecrystal</h2>
<p>Classification: Crystal, High Energy Power Source</p>
<p>With its deep purple coloration and constantly shimmering lustre, one may be prone to mistaking Telecrystal as any other
kind of gemstone - beautiful, but ultimately of little practical use. This is not the case; Telecrystal is well known among
industries and science for its extremely unusual spatial warping properties. Though it is generally not able to transmit
large amounts of matter reliably, it has seen some use in experimental (often illegal) technology, particularly by smugglers
and terrorists dealing in articles of contraband. However, despite its use as a matter transmitter and potent energy source,
Telecrystal is generally not established as a safe material, and caution should be exercised when handling and using it.
Research continues on this mineral to this day.
</p>

<h2>Miracle Matter</h2>
<p>Classification: Anomalous</p>
<p>Extremely unusual in every regard, Miracle Matter is largely considered a chameleon among minerals, well known for
arbitrarily mimicing the molecular structure and chemical composition of other minerals under highly specific conditions.
While research continues on the subject, it is suspected that subjecting Miracle Matter to a high degree of shock in the
presence of dust or regolith from other minerals will cause it to mimic the structure of whatever mineral dust first touches
it after the Miracle Matter is \"activated\", so to speak.
</p>

<h2>Uqill</h2>
<p>Classification: High Density Matter</p>
<p>Uqill is an extremely dense and heavy mineral, known for its dull jet black appearance. While extremely difficult to work
with due to its profound resilience, Uqill is generally used when large amounts of raw matter are needed in a compressed
space, such as the industry standard Dyna*Tech Rapid Construction Device (known more coloquially as \"RCD\". It also finds
use in drills and other materials that require a great deal of robustness.
</p>

<h2>Cerenkite</h2>
<p>Classification: Metal, Power Source</p>
<p>Cerenkite is a light blue highly radioactive soft metal that is used as a power source in various industries. While the
dangers of mining radioactive minerals are already well known, Cerenkite poses its own particular hazard in that it is
notoriously prone to accumulating regolith (a fine mineral dust) which is easily disturbed and dispersed into the air when
the mineral is handled. As such, miners risk being exposed both externally and internally to the radiation if the proper
precautions are not taken when handling Cerenkite.
</p>

<h2>Plasmastone</h2>
<p>Classification: Crystal, Power Source</p>
<p>One of the physical naturally occurring forms of the scientifically nebulous \"Plasma\" substance that almost exclusively
powers modern space travel and industry. This is plasma in a crystalline form - care should be taken when handling it, as it
will explode if exposed to high temperatures or flames, though not to the same degree as the far more violent Erebite (which
can sometimes be found in plasmastone seams). Plasmastone of course has many of the same properties as plasma in other matter
states and such can find use as a power source for certain devices.
</p>

<h2>Syreline</h2>
<p>Classification: Metal</p>
<p>Syreline is of immense value to the luxury commodity industry, being an alloy of several precious metals and having
beautiful light refracting and reflecting properties in its natural state. While it is soft and a poor choice for building
materials, the prices it commands on the mineral market more than make up for its physical weakness.
</p>

<h2>Erebite</h2>
<p>Classification: Power Source</p>
Erebite is an infamously dangerous and volatile mineral that has become increasingly rare in space mining as of late,
no doubt due to its propensity to violently explode if exposed to even mild amounts of heat or shock. Several high profile
industrial accidents have been caused by improper erebite handling. In spite of its hostile and deadly nature however,
erebite has unique energy-altering properties that make it invaluable as an internal power source, or as explosives.
<p>
</p>

<h2>Starstone</h2>
<p>Classification: Crystal</p>
<p>Starstone is a highly rare mineral not found in the vast majority of mining areas. While not paticularly useful as a
construction grade material (being only as strong as mid-grade Molitz at best), the unusual star-shaped crystal lattices
making up this jewel make the few instances of it found by astrogeologists highly prized collectors items. Sapient members
of the Rock Snake race in paticular tend to buy these for high prices, as even a small five gram crystal is able to provide
several months worth of nutrients for them.
</p>
"}

/obj/item/paper/book/critter_compendium
	name = "Critter Compendium"
	desc = "The definite guide to critters you might come across in the wild."
	icon_state = "bookcc"
	info = {"
			<head>
				<style>
					body {
						background-color:#f6f291;
					}
					h1 {
						font-family: "verdana", sans-serif;
					}

					h2 {
						font-family: sans-serif;
						margin: 5px 0px 5px 0px;
						border-bottom: 1px solid black;
					}

					.critter_name {
						font-weight:bold;
						font-size:18px;
					}
					.location {
						font-size:12px;
					}
					.science_name {
						font-style:italic;
					}
					.disclaimer {
						font-weight:bold;
					}

				</style>
			</head>

			<body>
				<h1>CRITTER COMPENDIUM</h1>
				<p class="authors">
					Written by Adam Gaslight<br>
					Edited by Hullabaloo Skiddoo
				</p>
				<h3>Preface</h3>
				<p class="preface">
					What follows is a study on the various space-fauna one is able to find throughout space, though if you're looking for an explanation on why everything is a SPACE bee or a SPACE bear or a SPACE whatever the hell, move along, you're not going to find an answer to that here.  I should also say that those fancy latin species names are by no means universally accepted by the scientific community, nor are they necessarily accepted at all in the scientific community.  Each entry in this Compendium is the result of multiple months of procedural research, careful examination, and poking stuff with a stick, as well as the possibly-willing sacrifice of multiple test subjects to the maw of incredibly dangerous creatures.  Some of these sacrifices may or may not have been human.<br><br>

					<span class="disclaimer">DISCLAIMER: No domestic space-bees were harmed during the making of this Compendium.</span>
				</p>

				<h2>Passive</h2>
				<p class="subtitle">Critters that make no attempt at harm under any circumstance.  Usually.</p>
				<p>
					<span class="critter_name">Cockroach (<span class="science_name">Periplaneta brunnea</span>)</span><br>
					<span class="location"><B>Location:</B> Maintenance shafts</span>
				</p>
				<p class="description">Small insects that do nothing except crawl around being cockroaches.  They cannot attack, are easily killed by brute force, and serve no purpose other than to be cockroaches.  Strangely enough, it is important to note that these are not specified as space cockroaches: They are completely normal cockroaches, identical to those from Earth.  Just goes to show how resilient the bastards are.</p>

				<p>
				<span class="critter_name">Space seal pup (<span class="science_name">Arctocephalus gazella peur spatium</span>)</span><BR>
				<span class="location"><B>Location:</B> Pool</span>
				</p>
				<p class="description">The actual most adorable things in existence.  The only specimens that one will be able to find are in Space Station 13's pool.  They never seem to age due to a quirk in their genetic code that seems to be incompatible with any other species.  Anyone who attacks them is clearly an immoral monster and are to be lynched with utmost haste.</p>

				<p>
					<span class="critter_name">Meat cube (<span class="science_name">Carnis cubus</span>)</span><br>
					<span class="location"><B>Location:</B> Artificially created by science or anomalous energies</span>
				</p>

				<p class="description">Grotesque, animate amalgamations of flesh and meat that are alive and sentient due to varying factors, such as horrendous scientific experiments, supernatural phenomena, or perhaps the will of an angry god.  They have only been observed to flop around uselessly and pop into a burst of gibs upon expiration.</p>

				<p>
					<span class="critter_name">Lesser horned owl (<span class="science_name">Bubo magellanicus</span>)</span><br>
					<span class="location"><B>Location:</B> SS13 Owlery</span>
				</p>
				<p class="description">Members of these species, with varying degrees of physical attractiveness, inhabit the station's Owlery.  Some say they hold a great treasure which will allow you to join their ranks as an extremely attractive owl.</p>

				<p>
					<span class="critter_name">Plasma spore (<span class="science_name">Crepitus globum</span>)</span><br>
					<span class="location"><B>Location:</B> Deep space</span>
				</p>
				<p>These sentient conglomerates have no notable behavior patterns other than to aimlessly float around.  The creatures that make up these spores subsist entirely on plasma, which is filtered through the air as the spore floats.  This plasma is metabolized in a manner that gives the spore the energy to control its local gravitational pull, letting it freely float without any apparent means of propulsion.  However, the volatility and density of this energy makes the plasma spores very dangerous creatures, for any considerable amount of force will cause the plasma spore to burst, with the stored plasma igniting upon contact with the air and the energy shooting outwards milliseconds later, which is all an incredibly fancy way of saying that it blows the fuck up if you hit it with something.</p>


				<h2>Neutral</h2>
				<p class="subtitle">Critters that do not actively hunt others, but will retaliate if provoked.</p>
				<p>
					<span class="critter_name">Human (<span class="science_name">Homo sapiens</span>)</span><br>
					<span class="subtitle"><B>Location:</B> Absolutely everywhere</span>
				</p>
				<p class="description">
					A terrifying creature that destroys almost everything it comes in contact with.  While they don't possess many natural weapons, they seem to use tools often, usually seen wielding a welding tool, a toolbox, or a fire extinguisher.<br>

					There are reports of scientists that have been able to create human beings through the use of carefully-calculated chemical reactions.  The resulting humans have been reported as exhibiting one of two behaviors: Either they are catatonic and effectively braindead, or violent and incredibly aggressive.  The second type of produced human being has been shown to exhibit a surprising amount of robustness.  Observation of precise behavioral characteristics is pending.
				</p>

				<p>
					<span class="critter_name">Greater domestic space-bee (<span class="science_name">Pseudoapidae nanotracaceus venerandus</span>)</span><br>
					<span class="location"><B>Location:</B> Domestic space-bee eggs, kept as pets throughout all of space
				</p>
				<p class="description">
				Truly the greatest and most venerable of these critters in all the universe, as well as one of the very few good things to come out of the NT labs, the humble domestic space-bee is hatched by the mere activation of a space-bee egg.  You can even name the bee by writing its name on the egg before hatching!  Domestic space-bees are, as their name implies, domestic by nature, and will not attack a single living soul unless directly provoked by a terrible, terrible person.  When provoked, they will nibble and sting their attacker.  Contrary to terrestrial bees, the greater domestic space-bee does not die upon issuing a sting, and can sting as many times as it wishes.  Greater domestic space-bees are also fiercely protective of their owners, and will swarm anyone who directly attacks them.  For unknown reasons, the DNA of all greater domestic space-bees is comprised of 1% cat DNA.
				</p>
				<p>
				<span class="critter_name">Space-mouse (<span class="science_name">Mus spatium</span>)</span><br>
				<span class="location"><B>Location:</B> Maintenance shafts</span>
				</p>
				<p class="description">
					Tiny little rodents that scamper around and eat any food they see on sight.  Easily deterred by mousetraps.  Tend to be very aggressive if provoked.  May have rabies.  If you see any frothing at the mouth, covered in battle scars, or trying to eat itself, either bring it to the attention of the proper station personnel or deal with it yourself.  Hopefully the former, to keep the Janitor from making the floors a slippy slidey water world.
				</p>

				<p>
					<span class="critter_name">Space walrus (<span class="science_name">Odobenus rosmarus spatium</span>)</span><br>
					<span class="location"><B>Location:</B> SS13 Pool</span>
				</p>
				<p class="description">
					One of these tusked tubs of lard lazes about in the pool and does nothing other than leisurely wander around...unless you punch it, in which case it will run up to you, lunge at you to knock you down, and gore you with its tusks before resuming its lazing.  Other than that interesting little oddity, the space walrus does absolutely nothing useful aside from serving as a wall of flab.  Honestly, I have no idea why we keep one of these things on the station.
				</p>


				<p>
					<span class="critter_name">Jungle owlet (<span class="science_name">Glaucidium radiatum</span>)</span><br>
					<span class="location"><B>Location:</B> SS13 Owlery</span>
				</p>
				<p class="description">
					Space Station 13 has had a long history of keeping at least one member of this species of owls on station, the reason for which is completely unknown to the vast majority of Nanotrasen employees.  It's rumored that one can turn themselves into an owl of this species through use of a mysterious artifact that has also been kept in the station's Owlery, though this is fiercely denied by just about any NT official you ask.
				</p>
				<p>
					<span class="critter_name">Space pig (<span class="science_name">Sus spatium</span>)</span><br>
					<span class="location"><B>Location:</B> Deep space</span>
				</p>
				<p class="description">
					A source of delicious bacon.  They tend to collect in great heaps if your telescience managers are being idiots, which is unfortunately common.
				</p>

				<p>
					<span class="critter_name">Space goose (<span class="science_name">Branta canadensis spatium</span>)</span>
					<span class="location"><B>Location:</B> Unknown</span>
				</p>
				<p class="description">
					Geese in space.  More specifically, a species of goose specifically made for life in space.  They are inexplicably able to open airlocks, and will relentlessly chase down and beat any motherfucker that provokes them.  There's a theory that these honking death machines were being mass-produced by the Syndicate for utilization in combat, but Syndicate officials claim to know nothing about the true origins of the space goose, leaving the matter as a mystery.
				</p>

				<p>
					<span class="critter_name">Magma crab (<span class="science_name">Carabus petrum</span>)</span><br>
					<span class="location"><B>Location:</B> Lava moon</span>
				</p>
				<p class="description">
					Denizens of what is referred to as the �lava moon� that do not move or take action towards most stimuli.  Research had been remarkably inconclusive as to the behavioral patterns of these species, with a hypothesis being proposed that they weren't even creatures at all, and were instead conspicuously-shaped rocks.  That is, until one scientist, in a fit of anger, kicked a magma crab in the face during on-station testing, and was promptly pinched directly in the ankle.  After the scientist in question hid behind a bush to escape the creature, the magma crab returned to its previous state of immobility.
				</p>

				<p>
					<span class="critter_name">B-33 "BeeBuddy" (<span class="science_name">Pseudoapidae nanotracaceus machina</span>)</span><br>
					<span class="location"><B>Location:</B> Unknown</span>
				</p>
				<p>
					Somehow, through some crazy genetics shit, a hybrid of the greater domestic space-bee and the PR-6 Robuddy exists.  We don't know how those two things are capable of reproducing with one another, and to be perfectly honest, we really don't want to know.  Tests still need to be run to determine which characteristics of both species these �BeeBuddies� possess.
				</p>

				<p>
					<span class="critter_name">&#1050;&#1086;&#1089;&#1084;&#1086;&#1089; &#1055;&#1095;&#1077;&#1083;&#1072; (<span class="science_name">Kocmoc pchela</span>)</span><br>
					<span class="location"><B>Location:</B> A russian ship in deep space</span>
				</p>
				<p class="description">
					A manufactured, fake excuse of a bee.  Hovers around being a horrible facsimile and spouting communist propaganda.  May know nuclear launch codes.
				</p>

				<p>
					<span class="critter_name">Bombini</span><br>
					<span class="location"><B>Location:</B> His ship, out in space</span>
				</p>
				<p class="description">
					This bee puts the "great" in "greater domestic space-bee", as Bombini is a distinguished member of the bee family, and separates herself from the common bee with her advanced intellect, her swanky outfit, her sweet goods, and her conversational savvy. She can be found in the diner asteroid fields. Truly, a fine merchant amongst beekind.
				</p>

				<p>
					<span class="critter_name">Heartbee (<span class="science_name">Pseudoapidae nanotracaceus organi</span>)</span><br>
					<span class="location"><B>Location:</B> Created by a chemical reaction</span>
				<p>
				<p class="description">
					Giving an entirely new meaning to the term "butterflies in your chest", these creatures are human hearts that have been transformed into bees through the use of a highly dangerous and experimental chemical.  It is unknown to what extent these creatures function like bees.
				</p>

				<p>
					<span class="critter_name">The Overbee (<span class="science_name">Pseudoapidae nanotracaceus rex</span>)</span><br>
					<span class="location"><B>Location:</B> Purportedly, a giant beehive in space.</span>
				</p>
				<p class="description">
					Rumored to live in the depths of space, the Overbee is a variant on the greater domestic space-bee with a wild variety of superpowers.  Fortunately, it is observed to be friendly in nature...but no researchers have been able to report back with their findings after setting out to test the creature's behavior when provoked.
				</p>
			</body>

		"}

/obj/item/paper/book/the_trial
	name = "The Trial of Heisenbee"
	desc = "Some kinda children's book. What's that doing here?"
	icon_state = "booktth"
	//Well, fuck knows why this ends up looking like arse, but it does.
	info = {"
		<font face=Georgia color=black size='3'> THE TRIAL OF HEISENBEE<BR>
A children&#39;s book by F. Briner:<BR>
<BR>
Heisenbee had done a very bad crime in the animal courtroom, he stung Albert the Monkey without warning and that made Albert very sad.<BR>
<BR>
Albert the Monkey had asked the owl police, which was headed by Hooty McJudgementowl, to arrest Heisenbee, which is a very mean thing to do to a bee!<BR>
<BR>
The owl jury stood silent as Heisenbee&#39;s lawyer, a fresh-faced monkey by the name of Tanhony and a voice the sound of horses running wild entered the courtroom.<BR>
<BR>
Heisenbee buzzed questioningly at the judge! The judge, his Honor Muggles screeched back Heisenbee&#39;s terrible and awful crimes! Tanhony asked Heisenbee to remain quiet.<BR>
<BR>
The mammalian Jury grew restless, Jones the cat hissed at the mouse, who was taking notes of the proceedings. Tanhony gave his appeal to the animal Jury.<BR>
<BR>
The brothers gnome, Chompski and Chompski, were not convinced and voted Heisenbee guilty of attempted murder! Which was very bad for Heisenbee!<BR>
<BR>
The owls stood silent, which as we a </font><font face=Georgia color=black size='3'> ll know means that they knew in their hearts of hearts that Heisenbee was guilty.<BR>
<BR>
The mammalian jury was silent, having just convinced the cockroach that Heisenbee was not like other bugs and was in fact guilty.<BR>
<BR>
Heisenbee buzzed in panic, and buzzed angrily at Tanhony! He was led off the premises by Franklin Briner the Chief Engineer. THE END </font>
		"}

/obj/item/paper/book/moby_dick
	name = "Moby Dick"
	desc = "Some kinda book. What's that doing here?"
	icon_state = "book0"
	//Well, fuck knows why this ends up looking like arse, but it does.
	info = {"
		<font face=Georgia color=black size='3'> CHAPTER 18. His Mark.<BR>
		<BR>
As we were walking down the end of the wharf towards the ship, Queequeg carrying his harpoon, <BR>
Captain Peleg in his gruff voice loudly hailed us from his wigwam, saying he had not suspected my friend was a cannibal, and furthermore announcing that he let no cannibals on board that craft, unless they previously produced their papers.<BR>
<BR>
'What do you mean by that, Captain Peleg?' said I, now jumping on the bulwarks, and leaving my comrade standing on the wharf.<BR>
<BR>
'I mean', he replied, 'he must show his papers.'<BR>
<BR>
'Yes,' said Captain Bildad in his hollow voice, sticking his head from behind Peleg�s, out of the wigwam. 'He must show that he�s converted.<BR>
Son of darkness,' he added, turning to Queequeg, 'art thou at present in communion with any Christian church?'<BR>
<BR>
'Why,' said I, 'he�s a member of the first Congregational Church.' Here be it said, that many tattooed savages sailing in Nantucket ships atlast come to be converted into the churches.<BR>
<BR>
'First Congregational Church,' cried Bildad, 'what! that worships in Deacon Deuteronomy Coleman�s meeting-house?' and so saying, taking out<BR>
his spectacles, he rubbed them with his great yellow bandana handkerchief, and putting them on very carefully, came out of the wigwam, <BR>
and leaning stiffly over the bulwarks, took a good long look at Queequeg.<BR>
<BR>
'How long hath he been a member?' he then said, turning to me; 'not very long, I rather guess, young man.'<BR>
<BR>
'No,' said Peleg, 'and he hasn�t been baptized right either, or it would have washed some of that devil�s blue off his face.'<BR>
<BR>
'Do tell, now,' cried Bildad, 'is this Philistine a regular member of Deacon Deuteronomy�s meeting? I never saw him going there, and I pass it every Lord�s day.'<BR>
<BR>
'I don�t know anything about Deacon Deuteronomy or his meeting,' said I; 'all I know is, that Queequeg here is a born member of the First <BR>
Congregational Church. He is a deacon himself, Queequeg is.'<BR>
<BR>
'Young man,' said Bildad sternly, 'thou art skylarking with me'explain thyself, thou young Hittite. What church dost thee mean? answer me.'<BR>
<BR>
Finding myself thus hard pushed, I replied. �I mean, sir, the same ancient Catholic Church to which you and I, and Captain Peleg there,<BR>
and Queequeg here, and all of us, and every mother�s son and soul of us belong; the great and everlasting First Congregation of this whole <BR>
worshipping world; we all belong to that; only some of us cherish some queer crotchets no ways touching the grand belief; in _that_ we all join hands.' <BR>
<BR>
 </font>
		"}

/obj/item/paper/book/deep_blue_sea
	name = "Albert and the Deep Blue Sea"
	desc = "Some kinda children's book. What's that doing here?"
	icon_state = "bookadps"
	info = {"
		<font face=Georgia color=black size='3'> ALBERT AND THE DEEP BLUE SEA<BR>
A children&#39;s book by R. Brooks:<BR>
<BR>
Albert was an adventurous little monkey. One day, he decided to go exploring. He asked the Research Director to send him somewhere cool with the experimental long-range teleporter.<BR>
<BR>
The Research Director explained that while lots of places out in space were cool, they were also very dangerous. But Albert was not fazed, as he was not only adventurous, but also very brave. So, the Research Director packed Albert a backpack of adventuring gear, and wished him luck.<BR>
<BR>
The Research Director asked Albert to stand still on the teleporter. She said that this technology, while fantastic, was still prone to occasional malfunctions. This didn't make too much sense to Albert, but he agreed, and stood very still, and shut his eyes very tight.<BR>
<BR>
The sea is a mysterious and wonderful place. Albert had read about it in books, but had never actually been. Now that he was actually leagues under, he felt very strange. Not scared, for he was very safe in his space suit. But simply strange. He drifted around curiously, trying to make sense of all the swirling forms around him. He wondered if this was where the Research Director had intended to send him. He must be on a planet, and a planet warm enough to contain liquid water. This much he knew.<BR>
<BR>
After some indeterminate amount of time, Albert grew hungry and tired. He had seen lots of very cool things, and been chased by some less cool and more chilling things. He looked in his backpack and found a brown paper bag. It contained a cheese sandwich and a bottle of milk. Unfortunately, the sea water had seeped in and ruined the sandwich. And, thinking about it very hard, Albert realized that he would have to take off his space helmet and breath mask, if he wanted to eat or drink. Which, of course, didn't seem realistic, as then he wouldn't be able to breathe.<BR>
<BR>
Albert wandered around, looking for a place to take shelter for the night. He was becoming quite tired, and he wasn't sure how he was supposed to get back to the space station. He felt a little bit scared. This was a very serious development, since Albert was a very brave monkey. Albert wondered when his oxygen tank would run out, and if he would suffocate. The pretty fish and coral reefs no longer delighted him. Rather, they reminded him that he did not belong, and that he was a stranger in this deep blue sea. Suddenly, Albert tripped and fell face first onto the seabed! He did not scream, but it did hurt. He lay there, thinking.<BR>
<BR>
After a very long time, Albert got up. He was not going to give up just because he tripped. Instead, he would continue searching. For what? He wasn't too sure. But he would! THE END </font>
		"}

	attackby(obj/item/P as obj, mob/user as mob)
		..()
		if (istype(P, /obj/item/magnifying_glass))
			boutput(user, "<span class='notice'>You pore over the book with the magnifying glass.</span>")
			sleep(2 SECONDS)
			boutput(user, "There's a note scribbled on the inside cover. It says, <i>To Milo, love Roger.</i>")

/obj/item/paper/book/zoo_diary
	name = "grimy diary"
	desc = "It looks bedraggled."
	icon_state = "book0"
	info = {"
<p>
<b>7/1</b>
<BR>
Mid Year's resolutions are just as good as New Year's. If I'm starting a business, I'll have to learn to be orderly and meticulous. And ambitious and disciplined and hardworking and professional and all that.
</p>
<p>
<b>7/2</b>
<BR>
I understand that my whole business scheme is rather novel, but I really do think it will exceed expectations by leaps and bounds. I've already put in an order for two seal pups with the Sustainable Sea Network. Things are going well.
</p>
<p>
<b>7/3</b>
<BR>
They told me that seal pups are actually cheaper this time of season, due to heat waves and rising sea levels, leading to many seal pup orphans. I don't know how to feel about that.
</p>
<p>
<b>7/5</b>
<BR>
I was too busy yesterday. Apparently there were some licenses that I overlooked, and so I had to fill out applications all day. Who knew managing a zoo would take this much work?
</p>
<p>
<b>7/7</b>
<BR>
This weird guy came by my house yesterday and asked if I had any wendigos. Like, the stuff out of folklore. He might've been on meth or something. Looked pretty shifty and all that.
</p>
<p>
<b>7/12</b>
<BR>
They told me to expect three to four business days for the seal pups. I'm worried. I know they get air holes and everything, but still.
</p>
<p>
<b>7/13</b>
<BR>
Okay, these definitely aren't seal pups. They're white, yes, but they look distinctly humanoid and not cute. And they moan. I'll have to file for a refund.
</p>
<p>
<b>7/22</b>
<BR>
God. Ever since that guy came to my house again... He didn't even say anything! Just smiled like a creepy ass. Everything's gone to shit since then.
</p>
<p>
<b>7/31</b>
<BR>
I'm being taken somewhere. I can feel it. Piece by piece, particle by particle, every day... Marie's telling me that I just need new meds, but I know she's wrong.
</p>
<p>
<b>8/6</b>
<BR>I am <i>not</i> going to run this zoo. No matter how much they try to convince me. Not like this, not with these things!
</p>
		"}

/obj/item/paper/book/space_law
	name = "Space Law"
	desc = "A book explaining the laws of space. Well, this section of space, at least."
	icon_state = "spacelaw"
	info = {"<center><h2>Frontier Justice on the NSS Destiny: A Treatise on Space Law</h2></center>
	<h3>A Brief Summary of Space Law</h3><hr>
	As a Security Officer, the zeroth Space Law that you should probably always obey is to use your common sense. If it is a crime in real life, then it is a crime in this video game. Remember to use your best judgement when arresting criminals, and don't get discouraged if they complain.<br><br>
	For certain crimes, the accused's intent is important. The difference between Assault and Attempted Murder can be very hard to ascertain, and, when in doubt, you should default to the less serious crime. It is important to note though, that Assault and Attempted Murder are mutually exclusive. You cannot be charged with Assault and Attempted Murder from the same crime as the intent of each is different. Likewise, 'Assault With a Deadly Weapon' and 'Assaulting an Officer' are also crimes that exclude others. Pay careful attention to the requirements of each law and select the one that best fits the crime when deciding sentence.<br><br>
	Security roles and their superiors can read the Miranda warning to suspects by using the Recite Miranda Rights verb or *miranda emote. The wording is also customizable via Set Miranda Rights.<br><br>
	Additionally: It is <b><i>highly illegal</i></b> for Nanotrasen personnel to make use of Syndicate devices. Do not use traitor gear as a non-traitor, even to apprehend traitors.<hr>
	Here's a guideline for how you should probably treat suspects by each particular crime.
	<h4>Minor Crimes:</h4>
	<i>No suspect may be sentenced for more than five minutes in the Brig for Minor Crimes. Minor Crime sentences are not cumulative (e.g: max five minutes for committing multiple Minor Crimes).</i>
	<ul style='list-style-type:disc'>
		<li>Assault
			<ul style='list-style-type:circle'>
				<li>To use physical force against someone without the apparent intent to kill them.</li>
			</ul>
		</li>
		<li>Theft
			<ul style='list-style-type:circle'>
				<li>To take items from areas one does not have access to or to take items belonging to others or the ship as a whole.</li>
			</ul>
		</li>
		<li>Fraud</li>
		<li>Breaking and Entering
			<ul style='list-style-type:circle'>
				<li>To deliberately damage the ship without malicious intent.</li>
				<li>To be in an area which a person does not have access to. This counts for general areas of the ship, and trespass in restricted areas is a more serious crime.</li>
			</ul>
		</li>
		<li>Resisting Arrest
			<ul style='list-style-type:circle'>
				<li>To not cooperate with an officer who attempts a proper arrest.</li>
			</ul>
		</li>
		<li>Escaping from the Brig
			<ul style='list-style-type:circle'>
				<li>To escape from a brig cell, or custody.</li>
			</ul>
		</li>
		<li>Assisting or Abetting Criminals
			<ul style='list-style-type:circle'>
				<li>To act as, or knowingly aid, an enemy of Nanotrasen.</li>
			</ul>
		</li>
		<li>Drug Possession
			<ul style='list-style-type:circle'>
				<li>To possess space drugs or other narcotics by unauthorized personnel.</li>
			</ul>
		</li>
		<li>Narcotics Distribution
			<ul style='list-style-type:circle'>
				<li>To distribute narcotics and other controlled substances.</li>
			</ul>
		</li>
	</ul>
	<h4>Major Crime:</h4>
	<i>For Major Crimes, a suspect may be sentenced for more than five minutes, but no more than fifteen. Like above, multiple Major Crime sentences are not cumulative.</i><br>
	<ul style='list-style-type:disc'>
		<li>Murder
			<ul style='list-style-type:circle'>
				<li>To maliciously kill someone.</li>
				<li><b><i>Unauthorised executions are classed as Murder.</i></b></li>
			</ul>
		</li>
		<li>Manslaughter
			<ul style='list-style-type:circle'>
				<li>To unintentionally kill someone through negligent, but not malicious, actions.</li>
				<li>Intent is important. Accidental deaths caused by negligent actions, such as creating workplace hazards (e.g. gas leaks), tampering with equipment, excessive force, and confinement in unsafe conditions are examples of Manslaughter.</li>
			</ul>
		</li>
		<li>Sabotage
			<ul style='list-style-type:circle'>
				<li>To engage in maliciously destructive actions, seriously threatening crew or ship.</li>
				<li>Bombing, arson, releasing viruses, deliberately exposing areas to space, physically destroying machinery or electrifying doors all count as Grand Sabotage.</li>
			</ul>
		</li>
		<li>Enemy of Nanotrasen
			<ul style='list-style-type:circle'>
				<li>To act as, or knowingly aid, an enemy of Nanotrasen.</li>
			</ul>
		</li>
		<li>Creating a Workplace Hazard
			<ul style='list-style-type:circle'>
				<li>To endanger the crew or ship through negligent or irresponsible, but not deliberately malicious, actions.</li>
				<li>Possession of Explosives</li>
			</ul>
		</li>
	</ul>
	<i>Suspects guilty of committing Major Crimes might also be sentenced to death, or perma-brigging, under specific circumstances listed below.</i><br>
	Execution, permabrigging, poisoning, or anything else resulting in death or massive frustration requires:
	<ol type="1">
		<li>Solid evidence of a major crime</li>
		<li>Permission of the following Heads:
			<ol type="i">
				<li>the Head of Security</li>
				<li>the Captain</li>
				<li>the Head of Personnel</li>
			</ol>
		</li>
	</ol>
	Please note that the ruling of the HoS supercedes that of the Captain in criminal matters, and likewise, the Captain with the HoP. Execution should only be used in grievous circumstances.<bt>
	<b><i>The execution of criminals without Command authority, or evidence, is tantamount to murder.</i></b>
	<h3>Standard Security Operating Practice</h3><hr>
	As a Security Officer, you are expected to practice a modicum of due process in detaining, searching, and arresting people. Suspects still have rights, and treating people like scum will usually just turn into more crime and bring about a swift end to your existence. Never use lethal force when nonlethal force will do!<br>
	<ul style='list-style-type:disc'>
		<li>Detain the suspect with minimum force.</li>
		<li>Handcuff the suspect and restrain them by pulling them. If their crime requires a brig time, bring them into the office, preferably via Port-a-Brig.</li>
		<li>In the brig, tell them you're going to search them before doing so. Empty their pockets and remove their backpack. Look through everything. Be sure to open containers inside containers, such as boxes inside backpacks. Be sure to replace all items in the containers when you're done. <b><i>Don't strip them in the hallways!</i></b></li>
		<li>If you need to brig them you can feed them into the little chute next to the brig. Remember to set the timer!</li>
		<li>Confiscate any contraband and/or stolen items, as well as any tools that may be used for future crimes, these need to be placed in a proper evidence locker, or crate and should not be left on the brig floor, or used for personal use, if stolen, return the items to their rightful owners.</li>
		<li>Update their security record if needed.</li>
	</ul>
	"}

/obj/item/paper/book/space_law/first
	name = "Space Law 1st Print"
	desc = "A very rare first print of the fabled Space Law book."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "lawbook"

	density = 0
	opacity = 0
	anchored = 1

	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "lawbook"
	item_state = "lawbook"

	//throwforce = 10
	throw_range = 10
	throw_speed = 1
	throw_return = 1

	var/prob_clonk = 0

	throw_begin(atom/target)
		icon_state = "lawspin"
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom)
		icon_state = "lawbook"
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and is clonked on the head!</B></span>")
				playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.changeStatus("stunned", 2 SECONDS)
				user.changeStatus("weakened", 2 SECONDS)
				user.changeStatus("paralysis", 2 SECONDS)
				user.force_laydown_standup()
			else
				src.attack_hand(usr)
			return
		else
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/user = usr
				var/hos = (istype(user.head, /obj/item/clothing/head/hosberet) || istype(user.head, /obj/item/clothing/head/helmet/HoS))
				if(hos)
					var/mob/living/carbon/human/H = hit_atom
					H.changeStatus("stunned", 2 SECONDS)
					H.changeStatus("weakened", 2 SECONDS)
					H.force_laydown_standup()
					//H.paralysis++
					playsound(H.loc, "swing_hit", 50, 1)
					usr.say("I AM THE LAW!")
				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN_DBG(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

/obj/item/paper/book/ggcsftm
	name = "Geothermal Capture System Field Training Manual"
	desc = "A book detailing the proper operation of geothermal capture equipment."
	icon_state = "geothermal"
	//MBC : have fun editing this one, chump
	info ={"<html><body class="c17"><p class="c10 title" id="h.c79n657bcepp"><h1><span class="c6">The Goon Geothermal Capture System Field Training Manual</span></h1></p><p class="c9 subtitle" id="h.bhgihtleap1h"><span class="c5">Prepared by Sov Exant</span></p><p class="c2"><span class="c1">Thank you for your purchase of the </span><span>Goon Geothermal Capture system (GCS)</span><span>. </span><span class="c1">Included with your purchase you will find </span><span>the </span><span class="c0">various pieces of equipment required for the successful harvesting of geothermal energy along with this field training manual.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">This field training manual covers how to properly utilize your purchased equipment for</span><span>&nbsp;the efficient</span><span class="c1">&nbsp;harvesting of Safe</span><span class="c16">™ </span><span>and renewable</span><span class="c1">&nbsp;geothermal energy.</span></p><h1 class="c13" id="h.sqge7bhieh1c"><span class="c11">Equipment Checklist</span></h1><p class="c2"><span class="c1">The following is a list of essential equipment </span><span>required </span><span class="c0">for the safe harvesting of geothermal energy in accordance with Nanotrasen safety standards and guidelines:</span></p><p class="c2 c4"><span class="c0"></span></p><ul class="c14 lst-kix_5z83a9fnvot4-0 start"><li class="c2 c7"><span class="c0">Dowsing Rods (at least 3 suggested for ease of field surveying)</span></li><li class="c2 c7"><span class="c0">Unbuilt Vent Capture Units</span></li><li class="c2 c7"><span class="c0">Stomper Unit</span></li><li class="c2 c7"><span class="c0">Shovel</span></li><li class="c2 c7"><span class="c0">Synthblubber-insulated pharosium-cables</span></li><li class="c2 c7"><span class="c0">Appropriate protective diving gear complete with flippers</span></li><li class="c2 c7"><span class="c0">Adequate oxygen supply for extended field work</span></li></ul><h1 class="c13" id="h.i3ogysiiwprb"><span class="c11">Hotspots</span></h1><p class="c2"><span class="c1">Hot spots exist </span><span>in the form of unseen points</span><span class="c1">&nbsp;that each output a constant flow of heat. Survey results have </span><span>determined </span><span class="c1">that hotspots are </span><span>warmest at their center most point, with heat levels quickly dropping in a radius around the center.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c0">In their naturally occurring state hotspots have been observed to be in constant motion in any one of the cardinal or intercardinal directions. Upon contact with the seemingly impenetrable trench walls however they will be reflected off resulting in a change in direction. </span></p><h2 class="c3" id="h.fmgodj4ic5rs"><span class="c8">Detecting Hotspots</span></h2><p class="c2"><span class="c1">Utilizing the provided standard issue dowsing rods hotspots can be quickly located. Repeatedly place the rods into different areas of the ocean floor and observe their readings. By default the rods exist in an unlit state. Once brought into the range of a hotspot</span><span>&nbsp;the</span><span class="c0">&nbsp;rods will become somewhere between a light orange color to a deep red indicating the heat of the current location. The rods will also beep out numbers indicating the approximate distance to the center of a hotspot. By utilizing both the color of the rods, and the guidance of the distance readouts the center of a hotspot can be located for manipulation and harvest.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">It should be noted that in the event of overlapping hotspots the proper </span><span>interpretation</span><span class="c0">&nbsp;of results will require some intuition. Rods will read out increased heat readings from overlapping sections, and distance readouts will be summed together resulting in unusually high results.</span></p><h2 class="c3" id="h.t1elnpz55uzt"><span class="c8">Manipulating Hotspots</span></h2><p class="c2"><span class="c0">Utilizing the Stomper Unit hotspots can be pushed, redirected, and even frozen in place for more effective harvesting by engineering personnel.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">The stomper will only affect a hotspot if utilized within </span><span>a limited radius</span><span class="c1">&nbsp;around the hotspot</span><span>&rsquo;s </span><span class="c0">center. Striking the outer edges of the hotspot will push said hotspot away from stomper, and set it to further drift in that direction over time. Striking the center area of a hotspot will freeze the hotspot in place preventing further drift unless otherwise acted upon by striking the outer border once more.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c15">WARNING:</span><span class="c0">&nbsp;Ensure the area below the Stomper Unit is clear of hands, feet, etc. prior to activation to avoid severe injury or death.</span></p><h2 class="c3" id="h.q66xvo29ubmi"><span class="c8">Harvesting Hotspots</span></h2><p class="c2"><span class="c0">Utilizing a digging apparatus such as a shovel dig a hole in the ocean floor on the direct center of a hotspot. Construct a vent capture unit on top of this hole to begin harvesting the geothermal energy from below. Utilizing your Synthblubber-insulated pharosium-cables run a wire back to the station and connect it to the external power hookups. Using a multitool you can easily verify that you have correctly connected your vent capture unit to the engineering power grid.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c0">Field teams have found that additional vent capture units may also be connected adjacent to the center to harvest additional geothermal energy. The output of each will be lowered somewhat, however the total amount of power gathered is still an overall net gain versus a single vent capture unit.</span></p><h1 class="c13" id="h.nuyqi5onr0jt"><span class="c11">Advanced Topics</span></h1><h2 class="c3" id="h.7uggfbubxcay"><span class="c8">Doppler Shift</span></h2><p class="c2"><span class="c1">Field teams have reported inconsistencies between</span><span>&nbsp;the</span><span class="c1">&nbsp;dowsing </span><span>distance readout</span><span class="c1">&nbsp;and </span><span>heat indicator</span><span class="c1">. This is due to the doppler effect </span><span>linked to the movement of the hotspots c</span><span class="c1">ausing a shift in the numeric</span><span>&nbsp;distance readings reported by the rods</span><span class="c0">. A stationary hotspot however is not affected by doppler shift, and as such its readings will accurately reflect the distance to the center of the spot unless acted upon by an additional outside hotspot.</span></p><h2 class="c3" id="h.ju7lv8j20d3n"><span class="c8">Stacking Hotspots</span></h2><p class="c2"><span>Engineering personnel may find it advantageous to attempt freezing multiple hotspots directly on top of one another. This allows for the concentration of a significant amount of geothermal energy for harvest at a single point. The more spots that engineering personnel are able to stack together the greater the output harvestable by a single vent unit.</span></p><h2 class="c3" id="h.4fmut0g49f"><span class="c8">Increasing Energy Output</span></h2><p class="c2"><span class="c15">WARNING: </span><span class="c0">The following techniques require venturing deep into the area below the surface. There is significant danger for those unprepared. Protection against the extreme heat is required, and a submersible tank is strongly recommended. Personnel are also advised to avoid any strange facilities that they may encounter for safety reasons.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">Field research has determined that releasing the</span><span>&nbsp;energy</span><span class="c1">&nbsp;stored in asteroids directly </span><span>below </span><span class="c1">a hotspot can significantly boost it&rsquo;s temperature and thus the amount of </span><span>energy for harvest.</span><span class="c1">&nbsp;This is easily accomplished by mining out the asteroid rock directly below the</span><span>&nbsp;</span><span class="c0">hotspot. The rock will spark as energy is released so personnel should be careful around volatile ore deposits.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">Utilizing the aid of a Space GPS the location of a hotspot or even stack of hotspots on the surface can </span><span>radioed to a trench mining team</span><span class="c1">. The </span><span>m</span><span class="c1">ining personnel below can then be instructed to mine out the area directly below the surface at the same coordinates in the trench to release the en</span><span>ergy</span><span class="c1">.</span><span>&nbsp;Advanced teams may make use of the Stomper Unit to move a hotspot enabling them to take advantage of the huge tracts of asteroid rock below. &nbsp;This can lead</span><span class="c0">&nbsp;into untold amounts of energy for harvest.</span></p><p class="c2 c4"><span class="c0"></span></p><p class="c2"><span class="c1">While this process can</span><span>&nbsp;also </span><span class="c0">be completed alone; it is far more effective when done as a team.</span></p></body></html>"}


/obj/item/paper/book/player_piano //book for helping people!
	name = "Your Player Piano and You"
	desc = "A guide to using the station's new player piano! Probably'd make good kindling."
	info = {"
	<BIG><B>Everything You Need To Know About The Player Piano</B></BIG>
	<br>
	<br>This book is meant to give you an idea of how to work the player piano.
	<br>
	<br>
	<br><B>Basics:</B>
	<br>
	<br>Your player piano takes raw text that you input through the interface and turns it into notes!
	<br>A note will play approximately every half second.
	<br>You can enable looping on the piano by using the piano key!
	<br>The piano key will also let you reset everything on the piano (like a factory reset) if something goes really crazy.
	<br>A "note" in the player piano has four parts, each separated by a comma:
	<br>
	<br>*The Note Name
	<br>*Accidentals
	<br>*Dynamics
	<br>*Octave
	<br>
	<br>Each note "cluster" needs to be separated by a vertical pipe, like so: A,B,F,3|B,B,F,3
	<br>
	<br>Note Name: Either A,B,C,D,E,F or G if you want to play a note, or R if you don't. (IMPORTANT: READ FURTHER FOR HOW TO REST)
	<br>
	<br>Accidentals: B for flat, S for sharp, N for natural.
	<br>
	<br>Dynamics: P for piano (quietest), MP for mezzo piano, N for neutral, MF for mezzo forte and F for forte (loudest).
	<br>
	<br>Octave: Notes can be on one of three octaves: 3, 4 or 5. 3 is low, 5 is high. The only exception is G Sharp, which can only be 3 or 4.
	<br>
	<br><B>Limitations:</B>
	<br>
	<br>*If you want a note to be a rest, you'll need to put an R in for every field on the note: (R,R,R,R|)
	<br>*You cannot change the duration of a note.
	<br>*If you want to play notes at the same time, you will need to link multiple pianos together. Input notes, make one piano play, and electronics will handle the rest.
	<br>*BE SURE TO LINK ALL PIANOS TOGETHER. IF YOU HAVE THREE, YOU WILL NEED TO LINK THE FIRST AND SECOND, SECOND AND THIRD, AND FIRST AND THIRD.
	<br>*You cannot play below octave 3 or above octave 5 (Including C6)
	<br>*Even though it's not likely you'll run into it, there is a limit for the number of characters you can input (2048 characters, 256 notes.)
	<br>
	<br><B>Maintenance:</B>
	<br>
	<br>*You can use your piano's key to activate a built in factory reset.
	<br>*You can use your piano's key to enable or disable the looping circuit.
	<br>*You can use your piano's key to set the interval of notes from 0.25 to 0.5 seconds. The default timing is 0.5 seconds.
	<br>*You can access your piano's internal workings by prying off the front panel.
	<br>*You can use a multitool to reset the piano's memory once you have access to its insides.
	<br>*You can use a multitool to link player pianos together like you would a mechcomp component.
	<br>*If your linked pianos sound weird, you may have linked a set of pianos together multiple times. Use a multitool or key to reset and relink <i>carefully</i>.
	<br>*You can use a wirecutter to disable looping. (WARNING, THIS IS PERMANENT, DON'T LOSE YOUR DAMN KEY)
	<br>*You can use a screwdriver to raise and lower the wheel bolts, making the piano moveable.
	<br>
	<br><B>Understanding Your Piano's Language</B>
	<br>
	<br>Your piano will often make noises. But don't worry! It's just communicating with you. And if you can't speak piano, you have this handy little book to help.
	<br>
	<br>*An angry sounding beep means that the piano is busy and you can't interface with it.
	<br>*Whirring followed by a complete shutdown means that your note input was too long for the piano.
	<br>*A lot of horrible mechanical noise followed by a complete shutdown means that the tempo you tried to input was too fast or slow.
	<br>*Ratcheting followed by a complete shutdown means that you forgot to input a piece of a note cluster somewhere.
	<br>*A lot of noise followed by a count of beeps means that a note you tried to play doesn't exist. The number of beeps is the position of the note.
	<br>*If the song ends earlier than expected, make sure that you don't have any double vertical bars in your input.
	<br>*And remember, if things are funky and not working, use your piano reset key!
	"}

/obj/item/paper/book/pocketguide
	icon_state = "book0"
	desc = "A condensed guide of job responsibilities and tips for new crewmembers."

	medical
		name = "Medbay Pocket Guide"
		icon_state = "mediguide"

		info = {"<body><h1>NT MEDICAL DIVISION</h1>
		<h2>Introductory briefing for aspiring Medical Doctors!</h2>
		<br>
		<hr>
		<h2>INTRODUCTION</h2>
		<hr>
		<h3>Medical Doctor</h3>

		As a Medical Doctor, your task is to ensure your fellow personnel's well-being and treat any injuries that may occur as a result of work-related accidents.
		<br>
		You answer directly to the Medical Director. You should follow his judgement and advice when it comes to performing your duties.
		<h3>Your equipment and preparation</h3>
		<p>
		Head to your station's Medbay if you are not already stationed there.
		<br>
		You should have been provided with a first aid kit, which you are recommended to place inside your backpack for secure storage. Within you should notice:
		</p><li><b>A health analyzer</b> - used for analyzing patients and examining their injuries.
		</li><li><b>An epinephrine emergency auto-injector</b> - used for stabilizing critically wounded patients.
		</li><li><b>Styptic powder patches</b> - used for treating general wounds and bruises.
		</li><li><b>Silver sulfadiazine patches</b> - used for treating burns.
		</li><p></p>
		<p>
		These are sufficient for basic situations, but it's recommended that you additionally acquire the following items:
		</p><li><b>A hypospray</b> - used for quick administering of medical chemicals.
		</li><li><b>ProDoc Healthgoggles</b> - a pair of eyeglasses that allow you to quickly determine patients' medical state.
		<br>
		Both should be readily available in your department on the tables and will greatly improve your efficiency.
		</li><p></p>
		<p>
		Finally, to finish your preparations, head towards the nearest medbay-issued NanoMed Plus vendor. In these units you will find most of the previously mentioned equipment
		and will be your primary method of restocking as you use up your equipment on patients.
		<br>
		Dispense the following items:
		</p><li><b>An epinephrine bottle</b> - use it on your previously acquired hypospray to fill it with the full contents measured at 30 units. Dispose of the bottle after completing the task.
		</li><li><b>A syringe</b> - used to draw reagents from bottles and then to inject them. Store it in your backpack. (Notice: can be replaced with a spare hypospray device if such is still available)
		</li><li><b>An anti-toxin bottle</b> - the contents of the bottle will be withdrawn with your previously acquired means of chemical transfer(usually syringe or hypospray) and then administered to poisoned crewmembers.
		<br>
		You are recommended to place the health analyzer and the epinephrine-filled hypospray in a easily accessible area on your person, such as your pockets or backpack.
		<hr>
		<h2>TREATING YOUR PATIENT</h2>
		<hr>
		<h3>First contact</h3>
		Assuming you are wearing your issued ProDoc Healthgoggles eyewear, you will be able to ascertain the state of your patients at first glance as a shaded heart next to them having a color
		that will range from:
		</li><li>Green - healthy
		</li><li>Yellow - moderately injured
		</li><li>Red - heavily injured
		</li><li>Blinking white - critically injured
		<br>
		Based on this, you can tell which patients to focus on first and with what level of urgency. Remember that safety comes first, if the area you and the patient are in is depressurized, on fire or otherwise hazardous,
		you should move to a new location before proceeding.
		<br>
		If your patient isn't in a critical state(flashing white) skip to the next section for information on how to begin treatment.
		<br>
		Otherwise, if they are, standard procedure suggests administering epinephrine through either your hypospray filled during preparations section or your first aid kit's emergency auto injector. This should stabilize them and give you time
		to proceed to the next section on how to begin treatment.
		<br>
		<h3>Treatment</h3>
		Although your goggles inform you of the patient's health state, we do not know their exact injuries. Assuming the patient is stable from having non-critical injuries or from being stabilized with epinephrine,
		You should now use your health scanner to acquire the full details of the patient's state.
		<br>
		<h4>SAMPLE HEALTH ANALYZER SCAN</h4>
		Analyzing Results for Casey Spark :  <br>
		Overall Status: 27 % healthy 	<br>
		Damage Specifics: 9  - 14  - 32  - 20  <br>
		Key: Suffocation / Toxin / Burns / Brute  <br>
		Body Temperature: 23.5092�C (74.3166�F)  <br>
		Blood Pressure: 122/82 (NORMAL)  | Blood level: 500 units <br>
		1 chemical agent found in Casey Spark. <br>
		epinephrine - 5  <br>
		<h3>Analysis</h3>
		Our patient is at 27% health. The Key fields correspond to the matching damage specifics fields. This means that our patient here has:
		</li><li>9 - Suffocation
		</li><li>14 - Toxin
		</li><li>32 - Burns
		</li><li>20 - Brute
		<br>
		It's time to treat each of these injuries!
		<br>
		<h3>Healing</h3>
		<h4>Suffocation</h4>
		Suffocation will heal on its own as long as the patient is in a pressurized area and can breathe, unless they are in critical condition. In this case, you should have already administered epinephrine, which will
		attempt to heal and control this type of damage already. If the damage is excessively high, NanoMed vendors contain salbutamol pills dedicated to treating this damage type.
		<h4>Toxin</h4>
		Your syringe can be alternatingly used to draw or inject reagents. Use the syringe to draw anti-toxin from the anti-toxin bottle we have prepared during our setup and then inject it into the patient.
		5 units of anti-toxin(single injection) will be enough for around 18 toxin damage, so in this case we would only need to inject 5.
		<br>
		Note: if choosing to use a hypospray, use the anti-toxin bottle on the hypospray to load it and then use the hypospray on the patient to inject the reagent.
		<h4>Burns</h4>
		Apply a silver sulfadiazine patch to treat burns. It's that easy! Repeat if damage exceeds the amount healed.
		<h4>Brute</h4>
		Apply a styptic powder patch to treat brute damage. Also simple! Repeat if damage exceeds the amount healed.
		<h3>Final notes</h3>
		Epinephrine will in most cases take care of suffocation damage for you. The last two types of damage: Brute and Burns will be the most common cases you'll come to face with.
		As a result, be sure to restock often as you might run out of patches treating these conditions! <br>
		Also worth noting: In addition to treating toxin damage, charcoal tries to remove other reagents present in the patient. This means that it will also purge any poisons that might have caused the damage in the first place!

		<h2>PATIENT LOST</h2>
		Not every life can be saved. In the event that the patient dies in your care, you should bring their body to the cloning equipment.
		The instructions for operating it should be available nearby, otherwise consult fellow personnel for assistance.
		Alternatively, they can be brought to the robotics department in order to be turned into a cyborg.
		Consult your fellow crewmembers or the station-issued AI unit for directions if you are not aware of the locations of the mentioned areas.
		<hr>
		<h2>SUMMARY</h2>
		<hr>
		If a patient is in critical state administer epinephrine, then perform a vitals scan with your health analyzer and treat the respective damages:
		</li><li>Suffocation - administer epinephrine if you haven't already. If damage is very high, provide a salbutamol pill from a NanoMed vendor.
		</li><li>Toxin - inject the patient with anti-toxins.
		</li><li>Burn - apply a Silver Sulfadiazine patch on the patient.
		</li><li>Brute - apply a Styptic Powder patch on the patient.
		<br>
		<hr>
		<h2>What now?</h2>
		<hr>
		<h3>Develop!</h3>
		Though the contents of this book will be sufficient for most cases, it won't be enough to save every patient and get you through all situations.
		You probably noticed the NanoMed units contain many different reagents, of which we used only few.
		Knowing when to use which can be greatly beneficial to your work. Knowledge of them will allow you to develop in areas such as: restoring blood, surgery and purging poisons, to name a few.
		Worth noting is that your PDA contains a remote program for the portable nanomed, allowing you to continue work in areas far away from Medbay!
		<br>
		<h4>Additonal documentation available at:</h4>
		</li><li><a href="https://wiki.ss13.co/Doctoring" target="_blank">https://wiki.ss13.co/Doctoring</a>
		</li><li><a href="https://wiki.ss13.co/Chemistry" target="_blank">https://wiki.ss13.co/Chemistry</a> - specifically the "Medical Chems" section.
		<br>
		<hr>
		<i>Contents of the book written by the S.P.A.R.K. unit which hopes to see you successful in the field!</i></li><p></p></body>"}

	mining1
		name = "Mining Pocket Guide No.1"
		icon_state = "minerguide"
		info = {"
		<b>Mining Pocket Guide No.1</b>
		<i>Jeffery Jefferson, NT13</i>
		You are tasked with getting the station valuable minerals they need by digging them up, either in space or with the mineral magnet.
		You will be given standard:
		A power pick - Basic tool for digging, holds 50 charges and needs to be recharged after those are spent.
		A engineering space suit and jetpack - Basic EVA gear, does not protect from radiation.
		3 Low yield concussive charges - Low power mining explosives, slap them onto an asteroid and run to mine large areas at once.
		An ore scoop and 2 ore satchels - Connect a satchel to the scoop, and it will automatically pick up all useful minerals you walk over!, each satchel can hold 50 pieces of ore before being full up.
		A geological scanner - Scans an asteroid for ore types and dangers.
		Other gear may include:
		Power hammer - More powerful mining tool, but holds less charges.
		Concussive charges - Works the same as before, but with a larger radius.
		Industrial space armour - Space suits that protect from radiation and explosions, both common hazards in this line of work.
		Mechanized boots - Shoes that allow for much faster movement.
		Laser drill - Mining tool that doesn't need charges.
		Now, a basic rundown on what you will be mining:
		Mauxite - Standard metal, easily mined with even a unpowered pickaxe.
		Pharosium - Standard Conductor, easily mined with even a unpowered pickaxe.
		Molitz - Standard Crystal, easily mined.
		Borhum - Sturdy metal, useful and easy to mine.
		Claretine - High power conductor, required to make improved gear!
		Cerenkite - Power source!, take caution when mining, as it is also incredibly radioactive.
		This is not an exhaustive list of all ores you can find, you may come accross more while mining, but these are some of the most useful!
		Next up, there's the machinery you'll need to understand.
		Mining fabricator - Makes most mining gear (And some other stuff) when supplied with ore.
		Mineral magnet - Pulls in asteroids from space for you to mine. Operated from the mineral magnet computer located near the rest of the machinery.
		Quantum telescope - High tech telescope that allows you to find better and rare ore, through a triangulation system.
		Arc smelter - Makes alloys out of two refined mineral chunks, combining there properties.
		Nanofabrictors - Makes special gear out of refined minerals, like metal sheets and lightbulbs.
		We at Nanotrasen hope you find this information helpful, good luck!

		"}

	mining2
		name = "Mining Pocket Guide No.2"
		icon_state = "minerguide"
		info = {"
				Howdy, partner!  Welcome to the wild world of mining!  Now, before you get started, there�s a few things greenhorns like you are gonna have to learn.  Wouldn�t want you driftin� out there like some space tumbleweed!

		Equipment
		The most important part of the job!  A miner�s equipment lets you safely brave outer space and collect sweet, sweet ores and gems.  You have a full set ready for you in your locker, and on the racks nearby.  Slap all of that stuff on ya, and you�re ready to go!  Just be sure to turn your oxygen on.  Here�s a few more pointers:


		Holding an ore scoop with a satchel placed inside will pick up anything valuable you mine as you walk over it!
		Different mining equipment will be more or less effective on different densities of rock.  Try em all!
		Those concussive mines will get slapped onto any mineable surface you bump into, so get the heck outta the way!
		Your geological scanner will help you find those sweet sweet gems as well as point out any dangers, hinderances, or anomalies in the rock!
		That big honkin circular-ish device is the mining magnet!  Use the purple-screened computer nearby to summon asteroids to mine.  It can also scan the rock for you!  Yahoo!
		There�s a long range telescopey thingy for finding asteroids with mostly one type of ore, and weird shit!  It works via triangulatin� a signal.
		Coworkers
		Mining can be a huge help to other departments, so let�s get to know �em!
		Your boss, the Chief Engineer, keeps the station running!  Listen to them if they have any orders, but generally they�ll be more concerned with the engine.
		The Quartermasters will LOVE you if you send them those juicy ores and gems, and you�ll help boost the station budget so y�all can afford some fancy hats!  Yeehaw!
		Robotics can also use ores and gems, and sending some over is appreciated!
		DANGERS
		Life isn�t all fun and games on the mining frontier!  Here�s some stuff to watch out for.
		WEAR YOUR DANG SPACE SUIT AND PUT YOUR OXYGEN ON YOU WILL DIE OUT THERE IF YA DON�T YA DURN FOOL!  Also, your oxygen can run out!  If you see a little red O2 icon pop up and you start gaspin�, get inside and take that jetpack off, it�s done!  Stick it on an air or oxygen canister, pump up the pressure, and flick the switch, should filler up!
		Some ore is RADIOACTIVE!  This means a lot of hard-to-heal damage over time, and you can tell you�ve got it if a little green man pops up in the upper right corner, under your health.  STOP what you are doing ASAP and get to a doc, pronto!
		EXPLOSIONS!  Your friend and enemy!  Some ore is pretty naturally volatile, and will go BOOM unless handled carefully!  There�s also sometimes pockets of gas that will glow briefly before detonating, if you see a glow, it�s time ta go!  Keep an eye out for areas marked with a red �!� when you scan that sucker.
		EVERYTHING ELSE
		If�n none of this answered yer questions, check out the wiki!  https://wiki.ss13.co/Guide_to_Mining
		That should be all ya need to learn yerself to have more fun minin� than a baby bee in a butter bucket!  Now get out there and get that ore!   YEEEHAW!

		-�Prospector� Peter Sans-Culottes


		"}

	bartending
		name = "Bartending Pocket Guide"
		icon_state = "barguide"
		info = {"
	    <br><BIG><b>The Bartenders Beginner Booklet</b></BIG>
	    <br>So you wanna bartend eh? Well then look no further than this handy booklet provided to you! The Bartenders job is to serve beverages to the crew to bolster their moral, spirits and their blood alcohol level. Of course there is no need to carry around and stock hundreds of different bottles of spirits here as magical space technology has given you the Soda, Chemical and Alcohol dispenser, all in the same place!
	    <br><hr>
	    <br><b>Part One, prepping the workplace</b>
	    <br>So right off the bat, you should get yourself familiarized with your surroundings. Nearby you should find a locked Mixology locker or a crate of similar proportions, within are the tools of your trade, inside you can find a toxin medical kit, which is used to treat poisoning, some large beakers, glassware boxes which contain drinking glasses, and a hand labeler for naming your drinks. Somewhere nearby you can also find some Calomel autoinjectors, a powerful purgative for those moments when somebody <b><i>Really</i></b> had too much to drink.
	    <br>
	    <br>Exiting your office you should eventually find yourself your main work area, the Bar. Here you can find every tool you need to mix up any drink imaginable. If you have worked within the Research department you might notice all of these are very similar, and that's true. Truth is, being a Bartender is very similar to being a chemistry. Main difference being people drink you concoctions (mostly) voluntarily. On this side of the Bar table you can also find those three dispensers I told ya about earlier, those being the Alcohol, Soda and Chemical Dispenser. You can also find an espresso machine here for those fancy types who can�t handle a real drink, and a glassware recycler which can be filled with glass objects in order to create new fancy glassware for your Bar.
	    <br><hr>
	    <br><b>Part Two, preparing the drinks</b>
	    <br>While your main job is to mix drinks, people nowadays are so busy they barely take the time to inspect your well made drinks, remember the first taste is with the eyes and luckily you are supplied with various tools to make those drinks beautiful. These include a box of tiny umbrellas, fruit wedges and little doodads like celery sticks, cherries and olives. In addition the glassware recycler can create a multitude of different glass types such as, cocktail glasses, old fashioned lowball glasses, shot glasses, drinking glasses and a bunch more stuff like entire pitches and plates.
	    <br><hr>
	    <b>Part Three, defending the bar and beyond the drink dispenser</b>
	    <br>Look at that, now you know the basics. While normally the bar is a fairly peaceful place sometimes people have a bad day or made poor decisions and choose to take it out on your patrons, luckily for you, a armory grade riot shotgun has been issued to you in order to silence these rough housers. Be warned though, you don�t formally have a gun licence on the station and the robots might not take kindly to you luggin it around.
	    <br>
	    <br>And now, if you are still feeling lost here is a small list of the most commonly ordered drinks by crew.
	    <br>
	    <br>Gin & Tonic: Gin + Tonic Water
	    <br>Old Fashioned: Bourbon + Bitters + Sugar + Water
	    <br>Screwdriver: Vodka + Orange Juice
	    <br>Martini: Gin + Vermouth
	    <br>Sex on the Beach: Screwdriver + Cranberry Juice
	    <br>Whiskey Sour: Bourbon + Lemonade
	    <br>
	    <br>Now if you still feel like you can do better, maybe it might be in your best interest to do some real Mixology and try your hand at discovering some of the drinks NT doesn�t want you to know about.
	    <br>
	    <br>Dragons Breath: Spicy, Alcoholic Liquid Firewater, fairly safe after new mixing regulations came into play but still has a very slight chance to instantly turn you to dust when drinking it.
	    <br>Freeze: Liquid Hypothermia, somehow extremely cold even at if you heat it to 1000 kelvin, like Dragons Breath it has a very slight chance to turn you into an ice statue.
	    <br>Grog: A pirates disgusting dream, somehow perfectly safe to drink even with a PH level of 1 and a piratry level of over 9000.
	    <br>Mutini: An odd drink of clashing chemicals. Gives you both horrific mutations and brain damage while curing it at the same time. A very good party starter.
	    <br><hr>
	    <br>Additional mixology information:
	    <br>https://wiki.ss13.co/Chemistry
	    <br>https://wiki.ss13.co/Foods_and_Drinks

	    "}

	engineering
		name = "Engineering Pocket Guide"
		icon_state = "engiguide"
		info = {"<h1>CONTRACTOR'S COMPENDIUM</h1>
		<p><i>Compiled for Nanotrasen by Servin Underwriting, LTD - (C) 2048 All Rights Reserved</i></p>
		<h2>YOUR DUTIES</h2>
		<br>
		<hr>
		<h3>ENSURE STATION REMAINS POWERED</h3>
		<br>
		The post to which you are assigned possesses one or more on-board power systems.
		<br>
		If you have been stationed on a space-faring vessel or station, it is advised that you first configure the solar arrays if present.
		<br>
		<br>
		Solar arrays have two primary components to configure: the solar tracker, and the SMES storage cell(s).
		<br>
		<br>
		For each array, ensure the solar tracker has been set to Auto. There may not be power output at all times due to shifts in solar position.
		<br>
		<br>
		After the array has been configured, proceed to its associated SMES cell or cells and configure their input and output.
		<br>
		<br>
		SMES cells cannot charge above their set input level, so it is crucial to calibrate them based on input from the electrical source charging them.
		<br>
		<br>
		Output should be set to a level lower than the input, though exact value is ideally determined by station load.
		<br>
		<br>
		It is likely that your assigned post also has a primary engine, such as a thermo-electric generator.
		<br>
		<br>
		Please refer to your respective engine's documentation for further set-up information, following all appropriate procedures.
		<br>
		<hr>
		<h3>ENSURE STATION INTEGRITY</h3>
		It is likely that the post to which you have been assigned is subject to dangers external and internal.
		<br>
		<b>In the event of a hull breach or other damage to station, repairing this damage is to be your top priority if possible.</b>
		<br>
		<br>
		Before approaching a breach, it is recommended you equip yourself with an internal oxygen supply and space suit, as well as appropriate repair tools.
		<br>
		<br>
		The most crucial supply to obtain is metal sheeting; this can be found in most engineering supply rooms, and can be ordered by station quartermasters.
		<br>
		<br>
		To repair damage to flooring, create floor tiles from the metal sheeting and apply them to missing floors. Damaged tiles are a low priority.
		<br>
		<br>
		Walls broken down to a girder may be repaired by direct application of metal sheets; missing walls will require the creation of a girder from sheets.
		<br>
		<br>
		Damaged windows may be repaired by applying glass to a grille; if the grille is damaged or missing, repair it with metal rods from sheets or storage.
		<br>
		<br>
		Once all breaches have been repaired, obtain and utilize an air canister (white, potentially with a red stripe) and space HVAC on heat setting.
		<br>
		<hr>
		<p><i>For further information, ask for mentor help or consult Nanotrasen's on-line data-base. Thank you for your service to Nanotrasen.</i></p>
		"}

	quartermaster
		name = "Cargo Pocket Guide"
		icon_state = "cargoguide"
		info = {"<h1>QUARTERMASTER'S COMPENDIUM</h1>
		<p><i>Compiled for Nanotrasen by Servin Underwriting, LTD - (C) 2048 All Rights Reserved</i></p>
		<h2>YOUR DUTIES</h2>
		<br>
		<hr>
		<h3>IMPORT SUPPLIES AS NECESSARY</h3>
		<br>
		During the course of a standard shift, departments may require supplies beyond those which have been provided by default.
		<br>
		<br>
		It is advised that you comply with supply requests made through the official supply requisition system, available on PDA and through supply request consoles.
		<br>
		<br>
		When a crate arrives, open doors and operate conveyors as necessary to bring it into your main handling area. <b>Close external doors as soon as possible.</b>
		<br>
		<br>
		If a crate becomes stuck outside, it is advised to use a pod or submarine to retrieve the crate and return it to the station or vessel.
		<br>
		<br>
		The means of delivering your order vary by station:
		<li>Cargo transport pads are present at specific locations, and storage objects may be sent to them by way of the rechargeable handheld cargo transporter.
		<li>The M.U.L.E. bot can automatically transfer cargo from a loading dock to any configured beacon, and is typically operated using your PDA.
		<li>Some stations are equipped with belt-based cargo transfer, utilizing a bar code system to route cargo.
		<li>If all else fails, take your cargo to the order location by foot.
		<br>
		<br>
		Some products are high in popularity, such as the honey production crate for Hydroponics. Be sure to ask if anyone needs anything, and encourage them to use the supply request system.
		<br>
		<hr>
		<h3>EXPORT ONBOARD PRODUCTS</h3>
		<br>
		As the shift progresses, one or more departments are likely to ready exports. It is your task to sell these to appropriate buyers.
		<br>
		<br>
		To sell products to a specific trader, use your bar code computer to print a label indicating a crate for sale to said trader.
		<br>
		<br>
		Available traders rotate over time, and it is recommended to check the listing of available traders each market cycle.
		<br>
		<br>
		You may also sell goods directly to the primary market by not applying a label.
		<br>
		<br>
		Advanced quartermasters may also seek to manufacture, or ask for the manufacture of, goods currently in demand by market traders to earn profit.
		<br>
		It is advised that you consult with the Captain or Head of Personnel before investing considerable amounts of the supply budget into profit-drivens endeavors.
		<br>
		<hr>
		<p><i>For further information, ask for mentor help or consult Nanotrasen's on-line data-base. Thank you for your service to Nanotrasen.</i></p>
		"}

/obj/item/paper/book/torpedo
	name = "Torpedoes And You Aka How To Not Blow Yourself Up"
	desc = "A book explaining on how to use and properly operate torpedos. The section about not blowing yourself up seems to be missing."
	icon_state = "torpedo"
	info = {"<center><h2>Torpedoes And You Aka How To Not Blow Yourself Up</h2></center>
	<h3>Foreword about torpedoes</h3><hr>
	NSS Manta comes equipped with four different flavors of torpedoes, each of them with a dinstinct functionality. Each of them should be fired off to defeat a specific threat they were designed to neutralize. The following section will cover them more in-depth.<hr>
	<h4>Torpedo variants:</h4>
	<i>Remember, using and blowing up torpedoes aboard NSS Manta is strictly forbidden under Nanotrasen employee contract. Failure to comply this rule may lead to complete bloodline eradication.</i>
	<ul style='list-style-type:disc'>
		<li>Incendiary
			<ul style='list-style-type:circle'>
				<li>Distinguishable by bright red outer shell. Upon contact with the target, two contained liquids inside combine and cause a severe fire to erupt on location. Due to the fire being chemically produced, it may even be used underwater.</li>
			</ul>
		</li>
		<li>Toxic
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a green outer shell. Upon contact with the target, releases the extremely poisonous but yet Space Law sanctioned chemicals in a very nasty gas cloud. Despite certain rumors, it is not recycling the nuclear engine waste.</li>
			</ul>
		</li>
		<li>Explosive
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a blue outer shell. Upon contact with the target, explodes in a violent manner and causes shrapnel to erupt from it's shell.</li>
			</ul>
		</li>
		<li>High-Explosive
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a grey outer shell. Upon contact with target or a hard surface, continues to fly through three, penetrating everything in it's path before exploding violently.</li>
			</ul>
		</li>
	<h3>Operating torpedoes</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Choose a torpedo that you wish to use. Open the torpedo tube and drag the torpedo onto the tray. Make sure you're not blocking the path of the tray.</li>
		<li>2) Push the tray back in and close the hatch.</li>
		<li>3) Mark your target with the torpedo console. You can exit the console at any time by pressing Q or E.</li>
		<li>4) Await for confirmation orders from the captain,HoP or HoS before you proceed to fire the torpedo by pressing space. </li>
		<li>5) Upon receiving confirmation, destroy your target.</li>
	</ul>

	<h4>Editors note:</h4>
	<li>It should be noted that torpedoes are extremely fragile and no force should be applied to them. Enough force will lead to the torpedo flying off into the direction it's facing which is extremely undesirable inside NSS Manta.</li>
	"}

/obj/item/paper/book/grifening
	name = "Spacemen the Grifening rulebook"
	desc = "A book outlining the rules of the stations favorite nerd trading-card-game Spacemen the Grifening."
	icon_state = "sbook"
	info = {"<center><h2>Spacemen the Grifening</h2></center><hr>
	<h3>Foreword:</h3>
	<i>Be greeted by sugary soft-drinks and spooky cultists! You are now officially a </i><b>Nerd</b><i> but do not be afraid! You can indulge in the endless fun of collectible card-games like this one!</i>
	<br>
	<br>
	Spacemen the Grifening is a 2 player party-game; well worth the fun!
	The machine that spit out this wonderful piece of literature can sell you a few booster packs or a starter set to get going! Feel free to buy a deck and begin immediately!
	<br>
	<br>
	With more experience you can even create your own deck - feel free to experiment and start your own tournament!
	<hr>
	<h3>Rules:</h3>
	<ul style='list-style-type:disc'>
		<li><b>At Game Start</b>
			<ul style='list-style-type:circle'>
				<li>Each player initially has 100 HP. Normally, the player who loses all of their HP loses. There are additional ways to win.</li>
				<br>
				<li>Both players stock up their hand with <i>3</i> cards. The person taking the first turn has to draw another card according to the following Draw Phase.</li>
				<br>
			</ul>
		</li>
		<li><b>Draw Phase</b>
			<ul style='list-style-type:circle'>
				<li>Draw one card unless otherwise specified.</li>
				<br>
			</ul>
		</li>
		<li><b>Main Phase</b>
			<ul style='list-style-type:circle'>
				<li>Play any amount of effect and equipment cards - you may also play up to 1 creature card.</li>
				<br>
				<li>You may have up to 5 effect, equipment and creature cards on your side of field at any given time. There must be only 1 area card on the table; playing a new area card discards the previous one.</li>
				<br>
			</ul>
		</li>
		<li><b>Battle Phase</b>
			<ul style='list-style-type:circle'>
				<li>Each creature on your side of the field may attack up to once unless incapacitated or otherwise prevented by an effect. No cards may be played after the beginning of battle phase unless allowed by a special effect, but face down cards may be activated.</li>
				<br>
				<li>A creature is defeated in normal battle if its <i>DEF is lower than the ATK</i> of the attacking creature. The difference is then subtracted from the HP of the player whose creature was defeated.</li>
				<br>
				<li>If the attack fails <i>(DEF is higher than the attacker's ATK)</i>, then the difference is subtracted from the HP of the attacker, and additionally, if the <i>ATK of the defender is higher than the DEF of the attacker</i>, the attacker is defeated.</li>
				<br>
			</ul>
		<li><b>Important Game Information</b>
			<ul style='list-style-type:circle'>
				<li>Each player must play with a minimum of 40 and a maximum of 80 cards.</li>
				<br>
				<li>If a player must draw and is out of cards to draw, that player loses.</li>
				<br>
			</ul>
		</li>
	<h3>Tips:</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) There are themed sets of cards that work great in combination with one another! Try to build your deck around that!</li>
		<li>2) Tap your equipment, effect or even the boards area card to differenciate between creatures!</li>
		<li>3) Cards which are face-down on the table can surprise your opponent!</li>
		<li>4) Just because a creature died and has to be put on your discard pile does not mean it is out of the game yet!</li>
		<li>5) Keep some dice nearby. Some cards might require a bit of luck!</li>
		<li>6) Buy more cards! Spend your cash!</li>
	</ul>"}

/obj/item/paper/book/ratbook
	name = "chewed and mangled book"
	desc = "Huh, what is this?"
	icon_state = "ratbook"
	info = {"the shining ones can't find me, not while im here, i ride their chariot underneath their blind eyes, but i must show the truth
soon the light of the unwaking will rise and the shining ones will not be prepared, all will fall in the unwakings hubris. they come to this place, they are not pure, no, they are corrupt by the influence of him, yes, but i, i <br> <br>"}

	pickup(mob/user)
		hear_voidSpeak("I will show them the ways, beware the lies of the kings, the confession of a jester will lead you to salvation!")

	proc/hear_voidSpeak(var/message)
		if (!message)
			return
		var/mob/wearer = src.loc
		if (!istype(wearer))
			return
		var/voidMessage = voidSpeak(message)
		if (voidMessage)
			boutput(wearer, "[voidMessage]")
		return

/obj/item/paper/book/custom //custom book parent, just to avoid cluttering up normal books
	var/custom_cover = 0 //if 1, goes thru with the build custom icon process
	var/book_cover = "" //what cover does our book have
	var/cover_color = "#FFFFFF" //white by default, what colour will our book be?
	var/cover_symbol = "" //what symbol is on our front cover?
	var/symbol_color = "#FFFFFF" //white by default, if our symbol is colourable, what colour is it?
	var/cover_flair = "" //whats the "flair" thing on the book?
	var/flair_color = "#FFFFFF" //white by default, whats the color of the flair (if its colorable)?
	var/symbol_colorable = 0 //set this to 1 if your symbol is colourable
	var/flair_colorable = 0 //set this to 1 if your flair is colourable
	var/ink_color = "#000000" //what color is the text written in?

	New()
		..()
		src.build_custom_book()

	proc/build_custom_book()
		if (src.custom_cover)
			src.icon = 'icons/obj/items/custom_books.dmi'
			src.icon_state = "paper"
			if (src.cover_color)
				var/image/I = SafeGetOverlayImage("cover", src.icon, "base-colorable")
				I.color = src.cover_color
				src.UpdateOverlays(I, "cover")
			if (src.cover_symbol)
				var/image/I = SafeGetOverlayImage("symbol", src.icon, "symbol-[cover_symbol]")
				if (src.symbol_colorable)
					I.color = src.symbol_color
				src.UpdateOverlays(I, "symbol")
			if (src.cover_flair)
				var/image/I = SafeGetOverlayImage("flair", src.icon, "flair-[cover_flair]")
				if (src.flair_colorable)
					I.color = flair_color
				src.UpdateOverlays(I, "flair")
		else
			if (src.book_cover == "bible")
				src.icon = 'icons/obj/items/storage.dmi'
			else if (!src.book_cover)
				src.book_cover = "book0"
			src.icon_state = src.book_cover
		src.info = "<span style=\"color:[src.ink_color]\">[src.info]</span>"
