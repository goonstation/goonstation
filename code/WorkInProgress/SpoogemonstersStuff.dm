/datum/beakerSpec
	var/list/chems = list()
	var/list/amounts = list()
	var/temp = T0C

	proc/addChem(var/chem as text, var/amount=0)
		if(chems.Find(chem))
			removeChem(chem)

		if(istext(amount))
			amount = text2num_safe(amount)

		chems.Add(chem)
		amounts[chem] = amount

	proc/removeChem(var/chem as text)
		chems.Remove(chem)
		amounts[chem] = 0

	proc/setTemp(var/ttemp as text)
		temp = text2num_safe(ttemp)

	proc/createBeaker(var/holder)
		var/obj/item/reagent_containers/glass/B = new(holder)

		var/total = 0

		for(var/chem in chems)
			total += amounts[chem]
			B.reagents.maximum_volume = total
			B.reagents.add_reagent(chem, amounts[chem], null, 0, 1)
			B.reagents.set_reagent_temp(temp)

		return B

	proc/createReagents()
		var/datum/reagents/R = new(1000)

		var/total = 0
		for(var/chem in chems)
			total += amounts[chem]
			R.maximum_volume = total
			R.add_reagent(chem, amounts[chem], null, 0, 1)

		return R

	proc/toJson()
		var/first = 1
		var/json = "{\"chems\": \["

		for(var/chem in chems)
			var amount = amounts[chem]

			if(!first)
				json += ","
			else
				first = 0

			json += "{\"chem\":\"[chem]\",\"amount\":[amount]}"

		json += "],\"temp\":[temp]}"
		return json

/obj/machinery/chem_dispenser_admin/
	name = "chem dispenser"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	flags = NOSPLASH
	var/beaker = null

	var/glass_path = /obj/item/reagent_containers/glass
	var/glass_name = "beaker"
	var/dispenser_name = "Chemical"
	var/obj/item/card/id/user_id = null
	var/datum/reagent_group_account/current_account = null
	var/list/accounts = list()
	var/list/chems1 = list()
	var/list/amounts1 = list()
	var/list/chems2 = list()
	var/list/amounts2 = list()
	var/list/chems3 = list()
	var/list/amounts3 = list()
	var/list/beakerSpecs = list()
	var/list/temps = list()

	New()
		..()
		UnsubscribeProcess()

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(power * 1.25))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/beakerSpecsToJson()
		var/first = 1
		var/json = "\["

		for(var/datum/beakerSpec/S in beakerSpecs)
			if(!first)
				json += ","
			else
				first = 0

			json += S.toJson()

		json += "]"
		return json

	Topic(href, href_list)
		switch(href_list["action"])
			if("add")
				addChem(href_list["chem"], text2num_safe(href_list["amount"]), text2num_safe(href_list["beaker"]))

				usr << output(href_list["chem"] + ";" + href_list["amount"], "cheminterface.browser:addCallback")
			if("remove")
				removeChem(href_list["chem"], text2num_safe(href_list["beaker"]))

			if("temp")
				setTemp(href_list["temp"], text2num_safe(href_list["beaker"]))

			if("grenade")
				grenade(href_list["name"])

			if("syringe")
				syringe(href_list["name"])

			if("lbeaker")
				lbeaker(href_list["name"])

			if("patch")
				patch(href_list["name"])

			if("getBeakerSpecs")
				usr << output(beakerSpecsToJson(), "cheminterface.browser:loadBeakerSpecsCallback")

			if("newBeaker")
				beakerSpecs.len++
				beakerSpecs[beakerSpecs.len] = new /datum/beakerSpec()

			else
				usr << output("bar", "cheminterface.browser:out")

	proc/removeChem(var/chem as text, var/beaker=1)
		if(istext(beaker))
			beaker = text2num_safe(beaker)

		if(beaker > beakerSpecs.len || isnull(beakerSpecs[beaker]))
			return

		var/datum/beakerSpec/beakerSpec = beakerSpecs[beaker]
		beakerSpec.removeChem(chem)

	proc/addChem(var/chem as text, var/amount=0, var/beaker=1)
		if(isnull(beakerSpecs[beaker]))
			beakerSpecs[beaker] = new /datum/beakerSpec()

		var/datum/beakerSpec/beakerSpec = beakerSpecs[beaker]
		beakerSpec.addChem(chem, amount)

	proc/setTemp(var/temp as text, var/beaker=1)
		if(isnull(beakerSpecs[beaker]))
			return

		var/datum/beakerSpec/beakerSpec = beakerSpecs[beaker]
		beakerSpec.setTemp(temp)


	proc/grenade(var/name as text)
		var/obj/item/chem_grenade/adminGrenade = new /obj/item/chem_grenade(src.loc)

		if(name == "" || isnull(name))
			adminGrenade.name = "grief grenade"
		else
			adminGrenade.name = name
		adminGrenade.desc = "This shit is dangerous."
		adminGrenade.stage = 2
		adminGrenade.icon_state = "chemg3"

		var/total = 0

		for(var/datum/beakerSpec/S in beakerSpecs)
			var/obj/item/reagent_containers/glass/B = S.createBeaker(adminGrenade)
			total += B.reagents.maximum_volume
			adminGrenade.beakers += B

		adminGrenade.reagents.maximum_volume = total
		return

	proc/syringe(var/name as text)
		var/obj/item/reagent_containers/syringe/adminSyringe = new(src.loc)

		if(name == "" || isnull(name))
			adminSyringe.name = "An unlabeled syringe"
		else
			adminSyringe.name = name

		var/datum/beakerSpec/S = beakerSpecs[1]
		var/datum/reagents/R = S.createReagents()

		adminSyringe.reagents.my_atom = null
		adminSyringe.reagents.dispose()
		adminSyringe.reagents = R
		R.my_atom = adminSyringe
		return

	proc/lbeaker(var/name as text)
		var/obj/item/reagent_containers/glass/beaker/large/adminBeaker = new(src.loc)

		if(name == "" || isnull(name))
			adminBeaker.name = "mysterious large beaker"
		else
			adminBeaker.name = name

		var/datum/beakerSpec/S = beakerSpecs[1]
		var/datum/reagents/R = S.createReagents()

		adminBeaker.reagents.my_atom = null
		adminBeaker.reagents.dispose()
		adminBeaker.reagents = R
		R.my_atom = adminBeaker
		return

	proc/patch(var/name as text)
		var/obj/item/reagent_containers/patch/adminPatch = new(src.loc)

		if(name == "" || isnull(name))
			adminPatch.name = "An unmarked patch"
		else
			adminPatch.name = name

		var/datum/beakerSpec/S = beakerSpecs[1]
		var/datum/reagents/R = S.createReagents()

		adminPatch.reagents.my_atom = null
		adminPatch.reagents.dispose()
		adminPatch.reagents = R
		R.my_atom = adminPatch
		return

	attack_hand(mob/user)
		if(!isadmin(user) && current_state < GAME_STATE_FINISHED)
			boutput(user, "<span class='alert'>This dispenser is too powerful for you!</span>")
			return
		panel()

	proc/panel()
		set background = 1

		if(beakerSpecs.len == 0)
			beakerSpecs.len++
			beakerSpecs[beakerSpecs.len] = new /datum/beakerSpec()

		//setup
		var/datum/tag/page/html = new
		var/datum/tag/heading/h = new (1)
		var/datum/tag/title/title = new
		html.addToBody(h)
		html.addToHead(title)
		//heading
		h.setText("Chemofabricator")

		//container
		var/datum/tag/div/container = new
		container.addClass("container-fluid")
		html.addToBody(container)

		//Top row with chem select and amount
		var/datum/tag/div/row = new
		row.addClass("row-fluid")
		container.addChildElement(row)
		var/datum/tag/div/span = new
		span.addClass("span8")
		row.addChildElement(span)
		var/datum/tag/select/chemSelect = new
		span.addChildElement(chemSelect)
		chemSelect.setId("chemselect")
		chemSelect.setName("chemselect")
		for(var/rtype in all_functional_reagent_ids)
			chemSelect.addOption(rtype,rtype)

		span = new
		var/datum/tag/input/chemAmount = new ("text")
		span.addChildElement(chemAmount)
		span.addClass("span4")
		row.addChildElement(span)
		chemAmount.setName("chemamount")
		chemAmount.setId("chemamount")
		chemAmount.setValue("10")

		var/datum/tag/div/beakerContainer = new
		beakerContainer.addClass("container-fluid")
		html.addToBody(beakerContainer)
		beakerContainer.setId("beaker-container")

		//Grenade button
		row = new
		row.addClass("row-fluid")
		container.addChildElement(row)
		span = new
		span.addClass("span3")
		row.addChildElement(span)
		span.innerHtml = "Name: "

		span = new
		span.addClass("span6")
		row.addChildElement(span)
		var/datum/tag/input/name = new ("text")
		span.addChildElement(name)
		name.setId("grenadeName")
		name.setName("grenadeName")

		row = new
		row.addClass("row-fluid")
		container.addChildElement(row)

		span = new
		span.addClass("span3")
		row.addChildElement(span)
		var/datum/tag/button/grenade = new
		grenade.setText("Grenade")
		grenade.setId("grenadeButton")
		span.addChildElement(grenade)

		span = new
		span.addClass("span3")
		row.addChildElement(span)
		var/datum/tag/button/syringe = new
		syringe.setText("Syringe")
		syringe.setId("syringeButton")
		span.addChildElement(syringe)

		span = new
		span.addClass("span3")
		row.addChildElement(span)
		var/datum/tag/button/lbeaker = new
		lbeaker.setText("Large Beaker")
		lbeaker.setId("lbeakerButton")
		span.addChildElement(lbeaker)

		span = new
		span.addClass("span3")
		row.addChildElement(span)
		var/datum/tag/button/patch = new
		patch.setText("Patch")
		patch.setId("patchButton")
		span.addChildElement(patch)

		row = new
		row.addClass("row-fluid")
		container.addChildElement(row)
		span = new
		span.addClass("span3")
		row.addChildElement(span)

		var/datum/tag/button/newBeaker = new
		newBeaker.setText("Add Beaker")
		newBeaker.setId("newBeaker")
		newBeaker.addClass("btn btn-default")
		span.addChildElement(newBeaker)

		span = new
		span.addClass("span3")
		row.addChildElement(span)

		var/datum/tag/button/refresh = new
		refresh.setText("Refresh")
		refresh.setId("refresh")
		refresh.addClass("btn btn-default")
		span.addChildElement(refresh)

		var/datum/tag/script/controlscr = new

		controlscr.setContent( {"
			var specs = {beakerSpecs: \[]};
			function loadBeakerSpecsCallback(spec) {
				var bspecs = $.parseJSON(spec);
				$.observable(specs).setProperty("beakerSpecs", bspecs);
			}

			function loadBeakerSpecs() {
				window.location = '?src=\ref[src];action=getBeakerSpecs';
			}

			function addReagentClick(event) {
				var chem = $('#chemselect').val();
				var amount = $('#chemamount').val();
				var beaker = $(event.target).data("beaker");
				window.location='?src=\ref[src];action=add;chem=' + chem + ';amount=' + amount + ';beaker=' + beaker;
				setTimeout(loadBeakerSpecs, 300);
			}

			function removeReagentClick(event) {
				var beaker = $(event.target).data("beaker");
				var chem = $('#addedRegs' + beaker).val();
				window.location='?src=\ref[src];action=remove;chem=' + chem + ';beaker=' + beaker;
				setTimeout(loadBeakerSpecs, 300);
			}

			function tempButtonClick(event) {
				var beaker = $(event.target).data("beaker");
				var temp = $('#temp' + beaker).val();
				window.location='?src=\ref[src];action=temp;temp=' + temp + ';beaker=' + beaker;
				setTimeout(loadBeakerSpecs, 300);
			}

			$(function() {
				var beakerTemplate = $.templates("#beakerTemplate");
				beakerTemplate.link("#beaker-container", specs);

				$(specs).on("propertyChange", function() {
					$('.addButton').on("click", addReagentClick);
					$('.removeButton').on("click", removeReagentClick);
					$('.tempButton').on("click", tempButtonClick);
				});
				loadBeakerSpecs();

				$('#newBeaker').click(function() {
					window.location='?src=\ref[src];action=newBeaker';
					setTimeout(loadBeakerSpecs, 300);
				});

				$('#refresh').click(function() {
					setTimeout(loadBeakerSpecs, 300);
				});

				function removeReg(beaker, chem, send) {
					$('#addedRegs' + beaker).find('#reg' + beaker + '-' + chem).remove();
					if(typeof send !== 'undefined' && send)
						window.location='?src=\ref[src];action=remove;chem=' + chem + ';beaker=' + beaker;
				}


				$('#grenadeButton').click(function() {
					var name = $('#grenadeName').val();
					window.location='?src=\ref[src];action=grenade;name=' + name;
				});


				$('#syringeButton').click(function() {
					var name = $('#grenadeName').val();
					window.location='?src=\ref[src];action=syringe;name=' + name;
				});


				$('#lbeakerButton').click(function() {
					var name = $('#grenadeName').val();
					window.location='?src=\ref[src];action=lbeaker;name=' + name;
				});


				$('#patchButton').click(function() {
					var name = $('#grenadeName').val();
					window.location='?src=\ref[src];action=patch;name=' + name;
				});
			});


		"})
		html.addToBody(controlscr)

		var/datum/tag/script/scr = new
		scr.setContent({"
		function out(txt) {
			//alert(txt);
		}
		function addCallback(chem, amount) {
			//alert("chem: " + chem + " amount: " + amount);
		}
		"})
		html.addToBody(scr)

		var/datum/tag/cssinclude/bootstrap = new
		bootstrap.setHref(resource("css/bootstrap.min.css"))
		html.addToHead(bootstrap)

		var/datum/tag/cssinclude/bootstrapResponsive = new
		bootstrapResponsive.setHref(resource("css/bootstrap-responsive.min.css"))
		html.addToHead(bootstrapResponsive)

		var/datum/tag/scriptinclude/jquery = new
		jquery.setSrc(resource("js/jquery.min.js"))
		html.addToHead(jquery)

		var/datum/tag/scriptinclude/jqueryMigrate = new
		jqueryMigrate.setSrc(resource("js/jquery.migrate.js"))
		html.addToHead(jqueryMigrate)

		var/datum/tag/scriptinclude/bootstrapJs = new
		bootstrapJs.setSrc(resource("js/bootstrap.min.js"))
		html.addToBody(bootstrapJs)

		var/datum/tag/scriptinclude/jsviews = new
		jsviews.setSrc(resource("js/jsviews.min.js"))
		html.addToBody(jsviews)

		var/datum/tag/script/beakerTemplate = new
		beakerTemplate.setId("beakerTemplate")
		beakerTemplate.setAttribute("type", "text/x-jsrender")
		html.addToBody(beakerTemplate)

		beakerTemplate.setContent({"
			{^{for beakerSpecs}}
				<div class="row-fluid">
					<div class="span12">
						<h4>Beaker {{:#index + 1}}</h4>
					</div>
				</div>
				<div class="row-fluid">
					<div class="span5">
						<button class="btn btn-primary addButton" id="addButton{{:#index + 1}}" data-beaker="{{:#index + 1}}">Add</button>
						<button class="btn btn-danger removeButton" id="removeButton{{:#index + 1}}" data-beaker="{{:#index + 1}}">Remove</button>
						<input type="text" name="temp{{:#index + 1}}" id="temp{{:#index + 1}}">
						<button class="btn btn-default tempButton" id="tempButton{{:#index + 1}}" data-beaker="{{:#index + 1}}">Temp</button>
						<span>{{:temp}}</span>
					</div>
					<div class="span7">
						<select multiple="multiple" id="addedRegs{{:#index + 1}}">
						{^{for chems}}
							<option value="{{:chem}}">{{:chem}}: {{:amount}}</option>
						{{/for}}
						</select>
					</div>
				</div>

			{{/for}}
		"})

		/*
		row = new
		row.addClass("row-fluid")
		beakerTemplate.addChildElement(row)
		span = new
		span.addClass("span12")
		row.addChildElement(span)
		h = new(4)
		h.setText("Beaker 3")
		span.addChildElement(h)

		row = new
		row.addClass("row-fluid")
		beakerTemplate.addChildElement(row)

		span = new
		span.addClass("span3")
		row.addChildElement(span)
		var/datum/tag/button/add3 = new
		add3.setText("Add #3")
		add3.setId("addButton3")
		span.addChildElement(add3)
		var/datum/tag/button/remove3 = new
		remove3.setText("Remove #3")
		remove3.setId("removeButton3")
		span.addChildElement(remove3)

		span = new
		span.addClass("span9")
		row.addChildElement(span)
		var/datum/tag/select/multi/added3 = new
		added3.setId("addedRegs3")
		for(var/chem in chems3)
			var/amt = amounts3[chem]
			added3.addOption(chem, "[chem]: [amt]")
		span.addChildElement(added3)*/

		/*var/datum/tag/firebug/fb = new
		html.addToHead(fb)*/

		usr.Browse(html.toHtml(), "window=cheminterface;size=600x600")
