
/// Handles various global init and the position of the sun.
/datum/controller/process/world
	var/shuttle
	var/oven_recipe_html = null

	setup()
		name = "World"
		schedule_interval = 2.3 SECONDS

		last_object = "genResearch.setup"
		genResearch?.setup()

		last_object = "setup_radiocodes"
		src.setup_radiocodes()

		last_object = "setup_organ_thresholds"
		src.setup_organ_thresholds()

		last_object = "setup_oven_recipes"
		src.create_oven_recipe_html()

		last_object = "emergency_shuttle"
		emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()
		src.shuttle = emergency_shuttle

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/world/old_world = target
		src.shuttle = old_world.shuttle

	doWork()
		last_object = "sun.calc_position"
		sun.calc_position()

		last_object = "genResearch.progress"
		genResearch?.progress()

		for (var/byondkey in muted_keys)
			last_object = "muted_keys[byondkey]"
			var/value = muted_keys[byondkey]
			if (value > 1)
				muted_keys[byondkey] = value - 1
			else if (value == 1 || value == 0)
				muted_keys -= byondkey

/datum/controller/process/world/proc/setup_radiocodes()
	var/list/codewords = list("Alpha","Beta","Gamma","Zeta","Omega", "Bravo", "Epsilon", "Jeff", "Delta")
	var/tempword = null

	tempword = pick(codewords)
	netpass_heads = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_security = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_medical = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_banking = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_cargo = "[rand(1111,9999)] [tempword]-[rand(111,999)]"
	codewords -= tempword

	tempword = pick(codewords)
	netpass_syndicate = "[rand(111,999)]DET[tempword]=[rand(1111,9999)]"
	codewords -= tempword

/datum/controller/process/world/proc/setup_organ_thresholds()
	for(var/organ in cyberorgan_brute_threshold)
		var/amt = rand(10, 60)
		cyberorgan_brute_threshold[organ] = amt + rand(-5, 5)
		cyberorgan_burn_threshold[organ] = 70 - amt + rand(-5, 5)

/datum/controller/process/world/proc/create_oven_recipe_html()
	var/list/dat = list()
	// we are making it now ok
	dat += {"<!doctype html>
<html><head><title>Recipe Book</title><style type="text/css">
.icon {
	background: rgba(127, 127, 127, 0.5);
	vertical-align: middle;
	display: inline-block;
	border-radius: 4px;
	margin: 1px;
}
table { width: 100%; }
th { text-align: left; font-weight: normal;}
.item {
	position: relative;
	display: inline-block;
	}
.item span {
	position: absolute;
	bottom: -5px;
	right: -2px;
	background: white;
	color: black;
	border-radius: 50px;
	font-size: 70%;
	padding: 0px 1px;
	border-right: 1px solid #444;
	border-bottom: 1px solid #333;
	}
label {
	display: block;
	background: #555;
	color: white;
	text-align: center;
	font-size: 120%;
	cursor: pointer;
	padding: 0.3em;
	margin-top: 0.25em;
	}
label:hover {
	background: #999;
	}
tr:hover {
	background: rgba(127, 127, 127, 0.3);
}
input { display: none; }
input + div { display: none; }
input:checked + div { display: block; }
.x { width: 0%; text-align: right; white-space: pre; }
</style>
</head><body><h2>Recipe Book</h2>
"}
	var/datum/recipe_manager/RM = get_singleton(/datum/recipe_manager)
	var/list/recipies = list()
	for (var/datum/cookingrecipe/R in RM.oven_recipes)
		// do not show recipies set to a null category
		if (!R.category)
			continue
		var/list/tmp2 = list("<tr>")

		if (ispath(R.output))
			var/atom/item_path = R.output
			tmp2 += "<th>[bicon(R.output)][initial(item_path.name)]</th><td>"
		else
			tmp2 += "<th>???</th><td>"
		for(var/I in R.ingredients)
			var/atom/item_path = I
			tmp2 += "<div class='item' title=\"[html_encode(initial(item_path.name))]\">[bicon(I)][R.ingredients[I] > 1 ? "<span>x[R.ingredients[I]]</span>" : ""]</div>"

		tmp2 += "</td><td class='x'>[R.cookbonus >= 10 ? "[round(R.cookbonus / 2)] HI" : "[round(R.cookbonus)] LO"]</td></tr>"

		if (!recipies[R.category])
			recipies[R.category] = list("<label for='[R.category]'><b>[R.category]</b></label><input type='checkbox' id='[R.category]'><div><table>")
		// collapse all the list elements into one table row
		recipies[R.category] += tmp2.Join("\n")



	for (var/cat in recipies)
		var/list/tmp = recipies[cat]
		dat += tmp.Join("\n\n")
		dat += "</table></div>"
		LAGCHECK(LAG_HIGH)

	dat += {"
</body></html>
"}

	oven_recipe_html = dat.Join("\n")

	#ifndef SPACEMAN_DMM
	#pragma push
	#pragma ignore unused_var // http://www.byond.com/forum/post/2830902

	var/obj/machinery/cookingmachine/oven/our_oven = /obj/machinery/cookingmachine/oven
	our_oven.recipe_html = oven_recipe_html

	#pragma pop
	#endif
