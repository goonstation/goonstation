///////////////////////
// FLOCK CONTROL PANEL

/chui/window/flockpanel
	name = "Flock Control"
	theme = "flock"
	windowSize = "600x400"
	var/datum/flock/associated
	var/list/tabs = list()


	New(var/datum/flock/associated)
		..(null) // there is no atom for this window, pass null
		src.associated = associated
		var/list/tabtypes = typesof(/datum/chui/tab/flock) - /datum/chui/tab/flock
		for(var/type in tabtypes)
			var/datum/chui/tab/flock/T = new type()
			tabs["[T.order]"] = T
		tabs = sortList(tabs)

	GetBody()
		var rendered = {"<div style='display: none' id='panel-ref'>\ref[src]</div>"}
		for(var/order in tabs)
			var/datum/chui/tab/flock/tab = tabs[order]
			rendered += {"<div class='tabcontent' id='tab-[tab.id]'>"}
			rendered += tab.GetTabBody(src.associated)
			rendered += {"</div>"}
		return rendered

	// needs to override parent proc completely because there's no way to inject tab params otherwise
	// (who the fuck designs something that can take params and then blocks you out of using those params?)
	// (aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)
	generate(var/client/user, var/body)
		var/list/tabids = list()
		for(var/order in tabs)
			var/datum/chui/tab/flock/tab = tabs[order]
			tabids[tab.id] = tab.name

		var/list/params = list(
			"js" = list(),
			"css" = list(),
			"title" = src.name,
			"tabs" = tabids,
			data = list( "ref" = "\ref[src]", "flags" = flags )
		)
		return theme.generateHeader(params) + theme.generateBody( body, params ) + theme.generateFooter()

	OnClick( var/client/who, var/id )
		// no op

	OnTopic(usr, href, href_list[])
		switch(href_list["action"])
			if("update")
				src.PushUpdate(src.associated.describe_state())
			if("jump_to")
				var/mob/living/intangible/flock/flockmind/F = src.associated.flockmind
				var/atom/movable/origin = locate(href_list["origin"])
				if(origin)
					var/turf/T = get_turf(origin)
					if(T.z != 1)
						// make sure they're not trying to spoof data and jump into a z-level they ought not to go
						boutput(F, "<span class='alert'>They seem to be beyond your capacity to reach.</span>")
					else
						F.set_loc(T)
			if("rally")
				var/mob/living/intangible/flock/flockmind/F = src.associated.flockmind
				var/mob/living/critter/flock/C = locate(href_list["origin"])
				if(C && C.flock == src.associated) // no ordering other flocks' drones around
					C.rally(get_turf(F))
			if("remove_enemy")
				var/mob/living/E = locate(href_list["origin"])
				if(E)
					src.associated.removeEnemy(E)
			if("eject_trace")
				var/mob/living/intangible/flock/trace/T = locate(href_list["origin"])
				if(T)
					var/mob/living/critter/flock/drone/host = T.loc
					if(istype(host))
						// kick them out of the drone
						boutput(host, "<span class='flocksay'><b>\[SYSTEM: The flockmind has removed you from your previous corporeal shell.\]</b></span>")
						host.release_control()
			if("delete_trace")
				var/mob/living/intangible/flock/trace/T = locate(href_list["origin"])
				if(T)
					if(alert(src.associated.flockmind, "This will destroy the flocktrace. Are you ABSOLUTELY SURE you want to do this?", "Confirmation", "Yes", "No") == "Yes")
						// if they're in a drone, kick them out
						var/mob/living/critter/flock/drone/host = T.loc
						if(istype(host))
							host.release_control()
						// DELETE
						flock_speak(null, "Partition [T.real_name] has been reintegrated into flock background processes.", src.associated)
						boutput(T, "<span class='flocksay'><b>\[SYSTEM: Your higher cognition has been forcibly reintegrated into the collective will of the flock.\]</b></span>")
						T.death()

	proc/PushUpdate(var/state)
		var/update = json_encode(state)
		//message_coders("<b>PushUpdate:</b> [update]")
		src.CallJSFunction("flock.receiveData", list(update))

////////////////////////
// FLOCKPANEL TABS

/datum/chui/tab/flock/GetTabBody(var/datum/flock/flock)
	return "<p>todo</p>"

/datum/chui/tab/flock/vitals
	id = "vitals"
	name = "Flock Vitals"
	order = 1

	GetTabBody(var/datum/flock/flock)
		return {"<table id='vitals'>
			<tbody>
				<tr>
					<td><strong>NAME</strong></td>
					<td class='value' id='vitals-name'></td>
				</tr>
				<tr>
					<td><strong>DRONES</strong></td>
					<td class='value' id='vitals-drones'></td>
				</tr>
				<tr>
					<td><strong>PARTITIONS</strong></td>
					<td class='value' id='vitals-partitions'></td>
				</tr>
			</tbody>
		</table>
		"}

/datum/chui/tab/flock/partitions
	id = "partitions"
	name = "Partitions"
	order = 2

	GetTabBody(var/datum/flock/flock)
		return {"<table id='partitions' class='entities'>
			<thead>
				<tr>
					<th class='noselect sortable' id='partitions-name'>NAME</th>
					<th class='noselect sortable' id='partitions-host'>HOST</th>
					<th class='noselect sortable' id='partitions-health'><i class='icon-heart'></i></th>
					<th>JUMP</th>
					<th>EJECT</th>
					<th>DELETE</th>
				</tr>
			</thead>
		</table>
		"}

/datum/chui/tab/flock/drones
	id = "drones"
	name = "Drones"
	order = 3

	GetTabBody(var/datum/flock/flock)
		var/rendered = {"<table id='drones' class='entities'>
			<thead>
				<tr>
					<th class='noselect sortable' id='drones-name'>NAME</th>
					<th class='noselect sortable' id='drones-health'><i class='icon-heart'></i></th>
					<th class='noselect sortable' id='drones-resources'><i class='icon-cog'></i></th>
					<th class='noselect sortable' id='drones-task'>TASK</th>
					<th class='noselect sortable' id='drones-area'>AREA</th>
					<th>JUMP</th>
					<th>RALLY</th>
				</tr>
			</thead>
		</table>"}
		return rendered

/datum/chui/tab/flock/structures
	id = "structures"
	name = "Structures"
	order = 4

/datum/chui/tab/flock/enemies
	id = "enemies"
	name = "Enemies"
	order = 5

	GetTabBody(var/datum/flock/flock)
		return {"<table id='enemies' class='entities'>
			<thead>
				<tr>
					<th class='noselect sortable' id='enemies-name'>NAME</th>
					<th class='noselect sortable' id='enemies-area'>LAST SEEN</th>
					<th>REMOVE</th>
				</tr>
			</thead>
		</table>
		"}
