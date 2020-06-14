//TODO:
// - Stun and ghost checks for the verbs
// - Buttons can be picked up with the hands full. Woops.
// - Message Datum pooling and recycling.
// - Check if something is already connected and prevent from double connecting.

//Important Notes:
//
//Please try to always re-use incoming signals for your outgoing signals.
//Just modify the message of the incoming signal and send it along.
//This is important because each message keeps track of which nodes it traveled trough.
//It's through that list that we can prevent infinite loops. Or at least try to.
//(People can probably still create infinite loops somehow. They always manage)
//Always use the newSignal proc of the mechanics holder of the sending object when creating a new message.

#define MECHFAILSTRING "You must be holding a Multitool to change Connections or Options."

//Global list of telepads so we don't have to loop through the entire world aaaahhh.
var/list/mechanics_telepads = new/list()

/datum/mechanicsMessage
	var/signal = "1"
	var/list/nodes = list()

	proc/addNode(var/datum/mechanics_holder/H)
		nodes.Add(H)

	proc/removeNode(var/datum/mechanics_holder/H)
		nodes.Remove(H)

	proc/hasNode(var/datum/mechanics_holder/H)

		return nodes.Find(H)

	proc/isTrue() //Thanks for not having bools , byond.
		if(istext(signal))
			if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
		else if (isnum(signal))
			if(signal == 1) return 1
		return 0

/datum/mechanics_holder
	var/atom/master = null
	var/list/connected_outgoing = list()
	var/list/connected_incoming = list()
	var/list/inputs = list()

	var/outputSignal = "1"
	var/triggerSignal = "1"

	var/filtered = 0
	var/list/outgoing_filters = list()
	var/exact_match = 0

	disposing()
		wipeIncoming()
		wipeOutgoing()
		master = null
		..()

	//Adds an input "slot" to the holder /w a proc mapping.
	proc/addInput(var/name, var/toCall)
		if(inputs.Find(name)) inputs.Remove(name)
		inputs.Add(name)
		inputs[name] = toCall
		return

	//Fire given input by names with the message as argument.
	proc/fireInput(var/name, var/datum/mechanicsMessage/msg)
		if(!inputs.Find(name)) return
		var/path = inputs[name]
		SPAWN_DBG(1 DECI SECOND) call(master, path)(msg)
		return

	//Fire an outgoing connection with given value. Try to re-use incoming messages for outgoing signals whenever possible!
	//This reduces load AND preserves the node list which prevents infinite loops.
	proc/fireOutgoing(var/datum/mechanicsMessage/msg)

		//If we're already in the node list we will not send the signal on.
		if(!msg.hasNode(src))
			msg.addNode(src)
		else
			return 0

		var/fired = 0
		for(var/atom/M in connected_outgoing)
			if(M.mechanics)
				if (filtered && outgoing_filters[M] && !allowFiltered(msg.signal, outgoing_filters[M]))
					continue
				M.mechanics.fireInput(connected_outgoing[M], cloneMessage(msg))
				fired = 1
		return fired

	proc/allowFiltered(var/signal, var/list/filters)
		for (var/filter in filters)
			var/text_found = findtext(signal, filter)
			if (exact_match)
				text_found = text_found && (length(signal) == length(filter))
			if (text_found)
				return 1
		return 0

	//Used to copy a message because we don't want to pass a single message to multiple components which might end up modifying it both at the same time.
	proc/cloneMessage(var/datum/mechanicsMessage/msg)
		var/datum/mechanicsMessage/msg2 = newSignal(msg.signal)
		msg2.nodes = msg.nodes.Copy()
		return msg2

	//ALWAYS use this to create new messages!!!
	proc/newSignal(var/sig)
		var/datum/mechanicsMessage/ret = new/datum/mechanicsMessage
		ret.signal = sig
		return ret

	//Delete all incoming connections
	proc/wipeIncoming()
		for(var/atom/M in connected_incoming)
			if(M.mechanics)
				M.mechanics.connected_outgoing.Remove(master)
				if (M.mechanics.outgoing_filters.Find(master)) M.mechanics.outgoing_filters.Remove(master)
			connected_incoming.Remove(M)
		return

	//Delete all outgoing connections.
	proc/wipeOutgoing()
		for(var/atom/M in connected_outgoing)
			if(M.mechanics) M.mechanics.connected_incoming.Remove(master)
			connected_outgoing.Remove(M)
		outgoing_filters.Cut()
		return

	//Called when a component is dragged onto another one.
	proc/dropConnect(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)
		if(!O || O == master || !O.mechanics) return //ZeWaka: Fix for null.mechanics

		var/typesel = input(usr, "Use [master] as:", "Connection Type") in list("Trigger", "Receiver", "*CANCEL*")
		if(typesel == "*CANCEL*") return
		switch(typesel)

			if("Trigger")
				if(O.mechanics.connected_outgoing.Find(master))
					boutput(usr, "<span class='alert'>Can not create a direct loop between 2 components.</span>")
					return

				if(O.mechanics.inputs.len)
					var/selected_input = input(usr, "Select \"[O]\" Input", "Input Selection") in O.mechanics.inputs + "*CANCEL*"
					if(selected_input == "*CANCEL*") return
					connected_outgoing.Add(O)
					connected_outgoing[O] = selected_input
					O.mechanics.connected_incoming.Add(master)
					boutput(usr, "<span class='success'>You connect the [master.name] to the [O.name].</span>")
					logTheThing("station", usr, null, "connects a <b>[master.name]</b> to a <b>[O.name]</b> at [log_loc(src_location)].")
					if (filtered)
						var/filter = input(usr, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
						if (length(filter))
							if (!outgoing_filters[O]) outgoing_filters[O] = list()
							outgoing_filters.Add(O)
							outgoing_filters[O] = splittext(filter, ",")
							boutput(usr, "<span class='success'>Only passing messages that [exact_match ? "match" : "contain"] [filter] to the [O.name]</span>")
						else
							boutput(usr, "<span class='success'>Passing all messages to the [O.name]</span>")
				else
					boutput(usr, "<span class='alert'>[O] has no input slots. Can not connect [master] as Trigger.</span>")

			if("Receiver")
				if(O.mechanics.connected_incoming.Find(master))
					boutput(usr, "<span class='alert'>Can not create a direct loop between 2 components.</span>")
					return

				if(inputs.len)
					var/selected_input = input(usr, "Select \"[master]\" Input", "Input Selection") in inputs + "*CANCEL*"
					if(selected_input == "*CANCEL*") return
					O.mechanics.connected_outgoing.Add(master)
					O.mechanics.connected_outgoing[master] = selected_input
					connected_incoming.Add(O)
					boutput(usr, "<span class='success'>You connect the [master.name] to the [O.name].</span>")
					logTheThing("station", usr, null, "connects a <b>[master.name]</b> to a <b>[O.name]</b> at [log_loc(src_location)].")
					if (O.mechanics.filtered)
						var/filter = input(usr, "Add filters for this connection?(Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
						if(length(filter))
							if(!O.mechanics.outgoing_filters[master]) O.mechanics.outgoing_filters[master] = list()
							O.mechanics.outgoing_filters.Add(master)
							O.mechanics.outgoing_filters[master] = splittext(filter, ",")
							boutput(usr, "<span class='success'>Only passing messages that [O.mechanics.exact_match ? "match" : "contain"] [filter] to the [master.name]</span>")
						else
							boutput(usr, "<span class='success'>Passing all messages to the [O.name]</span>")
				else
					boutput(usr, "<span class='alert'>[master] has no input slots. Can not connect [O] as Trigger.</span>")

			if("*CANCEL*")
				return
		return


/obj/item/mechanics
	name = "testhing"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_unk"
	item_state = "swat_suit"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 1.0
	level = 2
	var/under_floor = 0
	var/can_rotate = 0
	var/list/particles = new/list()
	var/list/configs = list()

	New()
		mechanics = new(src)
		mechanics.master = src
		if (!(src in processing_items))
			processing_items.Add(src)
		return ..()

	proc/cutParticles()
		if(particles.len)
			for(var/datum/particleSystem/mechanic/M in particles)
				M.Die()
			particles.Cut()
		return

	process()
		if(level == 2 || under_floor)
			cutParticles()
			return

		if(mechanics && particles.len != mechanics.connected_outgoing.len)
			cutParticles()
			for(var/atom/X in mechanics.connected_outgoing)
				particles.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(src.loc, X.loc)))

		return

	attack_hand(mob/user as mob)
		if(level == 1) return
		if(issilicon(user) || isAI(user)) return
		else return ..(user)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)
	proc/secure()
	proc/loosen()
	proc/append_default_configs(var/modifier) //no modifier adds all, 1 = add "Set Send-Signal", 2 = add "Disconnect All"
		if(modifier == 1)
			configs.Add(list("Set Send-Signal"))
		else if(modifier == 2)
			configs.Add(list("Disconnect All"))
		else
			configs.Add(list("Set Send-Signal","Disconnect All"))
	proc/modify_configs()
		if(!isliving(usr))
			return
		if(usr.stat)
			return
		if(src.configs.len)
			var/input = input("Select a config to modify!", "Config", null) as null|anything in src.configs
			if(input && (usr in range(1,src)))
				switch(input)
					if("Set Send-Signal")
						var/inp = input(usr,"Please enter Signal:","Signal setting","1") as text
						inp = trim(adminscrub(inp), 1)
						if(length(inp))
							mechanics.outputSignal = inp
							boutput(usr, "Signal set to [inp]")
						return 0
					if("Disconnect All")
						mechanics.wipeIncoming()
						mechanics.wipeOutgoing()
						boutput(usr, "<span class='notice'>You disconnect [src].</span>")
						return 0
				return input
			else
				return 0

	proc/rotate()
		src.dir = turn(src.dir, -90)

	attackby(obj/item/W as obj, mob/user as mob)
		if (ispryingtool(W))
			if (can_rotate)
				if (!anchored)
					rotate()
				else
					boutput(user, "You must unsecure the [src] in order to rotate it.")
			return 1
		else if(iswrenchingtool(W))
			switch(level)
				if(1) //Level 1 = wrenched into place
					boutput(user, "You detach the [src] from the underfloor and deactivate it.")
					logTheThing("station", usr, null, "detaches a <b>[src]</b> from the underfloor and deactivates it at [log_loc(src)].")
					level = 2
					anchored = 0
					loosen()
				if(2) //Level 2 = loose
					if(!isturf(src.loc))
						boutput(usr, "<span class='alert'>[src] needs to be on the ground for that to work.</span>")
						return 0
					//var/turf/T = src.loc
					//var/can_deploy = 1
					/*if (T.density) // a wall or something
						can_deploy = 0
					else if (T.z == 2)
						for (var/obj/O in T)
							if (O.density)
								can_deploy = 0
								break
					if (!can_deploy)
						boutput(usr, "<span class='alert'>There's something in the way of [src], it can't be attached here!</span>")
						return 0*///why. why.
					boutput(user, "You attach the [src] to the underfloor and activate it.")
					logTheThing("station", usr, null, "attaches a <b>[src]</b> to the underfloor  at [log_loc(src)].")
					level = 1
					anchored = 1
					secure()

			var/turf/T = src.loc
			if(isturf(T))
				hide(T.intact)
			else
				hide()

			mechanics.wipeIncoming()
			mechanics.wipeOutgoing()
			return 1
		return 0

	pickup()
		if(level == 1) return
		mechanics.wipeIncoming()
		mechanics.wipeOutgoing()
		return ..()

	dropped()
		mechanics.wipeIncoming()
		mechanics.wipeOutgoing()
		return ..()

	MouseDrop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)

		if(!isliving(usr))
			return

		if(level == 2 || (istype(O, /obj/item/mechanics) && O.level == 2))
			boutput(usr, "<span class='alert'>Both components need to be secured into place before they can be connected.</span>")
			return

		if(usr.stat)
			return

		if (!usr.find_tool_in_hand(TOOL_PULSING))
			boutput(usr, "<span class='alert'>[MECHFAILSTRING]</span>")
			return

		mechanics.dropConnect(O, null, src_location, control_orig, control_new, params)
		return ..()

	proc/componentSay(var/string)
		string = trim(sanitize(html_encode(string)), 1)
		for(var/mob/O in all_hearers(7, src.loc))
			O.show_message("<span class='game radio'><span class='name'>[src]</span><b> [bicon(src)] [pick("squawks", "beeps", "boops", "says", "screeches")], </b> <span class='message'>\"[string]\"</span></span>",2)

	hide(var/intact)
		under_floor = (intact && level==1)
		updateIcon()
		return

	proc/updateIcon()
		return

/obj/item/mechanics/cashmoney
	name = "Payment component"
	desc = ""
	icon_state = "comp_money"
	density = 0
	var/price = 100
	var/code = null
	var/collected = 0
	var/current_buffer = 0
	var/ready = 1

	var/thank_string = ""

	get_desc()
		. += {"<br><span class='notice'>Collected money: [collected]<br>
		Current price: [price] credits</span>"}

	New()
		..()
		configs.Add(list("Set Price","Set Code","Set Thank-String","Eject Money"))
		src.append_default_configs()
		mechanics.addInput("eject money", "emoney")

	proc/emoney(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(input.signal == code)
				ejectmoney()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if ("Set Price")
					if (code)
						var/codecheck = strip_html(input(user,"Please enter current code:","Code check","") as text)
						if (codecheck != code)
							boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
							return
					var/inp = input(user,"Enter new price:","Price setting", price) as num
					if (inp)
						if (inp < 0)
							user.show_text("You cannot set a negative price.", "red") // Infinite credits exploit.
							return
						if (inp == 0)
							user.show_text("Please set a price higher than zero.", "red")
							return
						if (inp > 1000000) // ...and just to be on the safe side. Should be plenty.
							inp = 1000000
							user.show_text("[src] is not designed to handle such large transactions. Input has been set to the allowable limit.", "red")
						price = inp
						boutput(user, "Price set to [inp]")
				if ("Set Code")
					if (code)
						var/codecheck = adminscrub(input(user,"Please enter current code:","Code check","") as text)
						if (codecheck != code)
							boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
							return
					var/inp = adminscrub(input(user,"Please enter new code:","Code setting","dosh") as text)
					if (length(inp))
						code = inp
						boutput(user, "Code set to [inp]")
				if ("Set Thank-String")
					thank_string = adminscrub(input(user,"Please enter string:","string","Thanks for using this mechcomp service!") as text)
				if ("Eject Money")
					if(code)
						var/codecheck = strip_html(input(user,"Please enter current code:","Code check","") as text)
						if (codecheck != code)
							boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
							return
					ejectmoney()
		else if (istype(W, /obj/item/spacecash) && ready)
			ready = 0
			current_buffer += W.amount
			if (src.price <= 0)
				src.price = initial(src.price)
			if (current_buffer >= price)
				if (length(thank_string))
					componentSay("[thank_string]")

				if (current_buffer > price)
					componentSay("Here is your change!")
					var/obj/item/spacecash/C = new /obj/item/spacecash(user.loc, current_buffer - price)
					user.put_in_hand_or_drop(C)

				collected += price
				current_buffer = 0

				usr.drop_item()
				pool(W)

				var/datum/mechanicsMessage/msg = mechanics.newSignal(mechanics.outputSignal)
				mechanics.fireOutgoing(msg)
				flick("comp_money1", src)

				ready = 1
		return


	proc/ejectmoney()
		if (collected)
			var/obj/item/spacecash/S = unpool(/obj/item/spacecash)
			S.setup(get_turf(src), collected)
			collected = 0
		return

/obj/item/mechanics/flushcomp
	name = "Flusher component"
	desc = ""
	icon_state = "comp_flush"

	var/ready = 1
	var/obj/disposalpipe/trunk/trunk = null
	var/datum/gas_mixture/air_contents

	New()
		. = ..()
		mechanics.addInput("flush", "flushp")
		src.append_default_configs(2)

	disposing()
		if(air_contents)
			pool(air_contents)
			air_contents = null
		trunk = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user))
			if(src.level == 1) //wrenched down
				trunk = locate() in src.loc
				if(trunk)
					trunk.linked = src
					air_contents = unpool(/datum/gas_mixture)
			else if (src.level == 2) //loose
				if (trunk) //ZeWaka: Fix for null.linked
					trunk.linked = null
				if(air_contents)
					pool(air_contents)
				air_contents = null
				trunk = null
		else if (ispulsingtool(W))
			src.modify_configs()

	proc/flushp(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input && input.signal && ready && trunk)
			ready = 0
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isAI(M)) continue
				M.set_loc(src)
			flushit()
			SPAWN_DBG(2 SECONDS) ready = 1
		return

	proc/flushit()
		if(!trunk) return
		var/obj/disposalholder/H = unpool(/obj/disposalholder)

		H.init(src)

		air_contents.zero()

		flick("comp_flush1", src)
		sleep(1 SECOND)
		playsound(src, "sound/machines/disposalflush.ogg", 50, 0, 0)

		H.start(src) // start the holder processing movement
		return

	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			SPAWN_DBG(1 DECI SECOND)
				if(AM)
					AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		pool(H)

/obj/item/mechanics/thprint
	name = "Thermal printer"
	desc = ""
	icon_state = "comp_tprint"
	var/ready = 1
	var/paper_name = "thermal paper"

	New()
		..()
		mechanics.addInput("print", "print")
		src.configs.Add("Set Paper Name")
		src.append_default_configs()

	proc/print(var/datum/mechanicsMessage/input)
		if(level == 2 || !ready) return
		if(input)
			ready = 0
			SPAWN_DBG(5 SECONDS) ready = 1
			flick("comp_tprint1",src)
			playsound(src.loc, "sound/machines/printer_thermal.ogg", 60, 0)
			var/obj/item/paper/thermal/P = new/obj/item/paper/thermal(src.loc)
			P.info = strip_html(html_decode(input.signal))
			P.name = paper_name
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if (ispulsingtool(W))
			switch (src.modify_configs())
				if (0)
					return
				if ("Set Paper Name")
					var/inp = input(user,"Please enter name:","name setting", paper_name) as text
					paper_name = adminscrub(inp)
					boutput(user, "String set to [paper_name]")

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.loc = target
		return

/obj/item/mechanics/pscan
	name = "Paper scanner"
	desc = ""
	icon_state = "comp_pscan"
	var/del_paper = 1
	var/thermal_only = 1
	var/ready = 1

	New()
		..()
		configs.Add(list("Toggle Paper Consumption","Toggle Thermal Paper Mode"))
		src.append_default_configs()

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.loc = target
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if (ispulsingtool(W))
			switch (src.modify_configs())
				if (0)
					return
				if ("Toggle Paper Consumption")
					del_paper = !del_paper
					boutput(user, "[del_paper ? "Now consuming paper":"Now NOT consuming paper"]")
				if ("Toggle Thermal Paper Mode")
					thermal_only = !thermal_only
					boutput(user, "[thermal_only ? "Now accepting only thermal paper":"Now accepting any paper"]")
		else if (istype(W, /obj/item/paper) && ready)
			if(thermal_only && !istype(W, /obj/item/paper/thermal))
				boutput(user, "<span class='alert'>This scanner only accepts thermal paper.</span>")
				return
			ready = 0
			SPAWN_DBG(3 SECONDS) ready = 1
			flick("comp_pscan1",src)
			playsound(src.loc, "sound/machines/twobeep2.ogg", 90, 0)
			var/obj/item/paper/P = W
			var/saniStr = strip_html(sanitize(html_encode(P.info)))
			var/datum/mechanicsMessage/msg = mechanics.newSignal(saniStr)
			mechanics.fireOutgoing(msg)
			if(del_paper)
				del(W)

//todo: merge with the secscanner?
/obj/mechbeam
	//Would use the /obj/beam but its not extensible enough.
	name = "trip laser"
	desc = "A beam of light that will trigger a device when passed."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	anchored = 1
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New(var/loc, var/obj/item/mechanics/triplaser/t)
		holder = t
		..()

	var/obj/item/mechanics/triplaser/holder

	proc/tripped()
		if (!holder)
			qdel(src)
		else
			holder.tripped()

	HasEntered(atom/movable/AM as mob|obj)
		if (isobserver(AM) || !AM.density) return
		if (!istype(AM, /obj/mechbeam))
			SPAWN_DBG(0) tripped()

/obj/item/mechanics/triplaser
	name = "Trip laser"
	desc = "Fires a signal when someone passes through the beam."
	icon = 'icons/obj/networked.dmi'
	icon_state = "secdetector0"
	can_rotate = 1
	var/range = 5
	var/list/beamobjs = new/list(5)//just to avoid someone doing something dumb and making it impossible for us to clear out the beams
	var/active = 0
	var/sendstr = "1"

	New()
		..()
		mechanics.addInput("toggle", "toggle")
		configs.Add("Set Range")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Range")
					var/rng = input("Range is limited between 1-5.", "Enter a new range", range) as num
					range = clamp(rng, 1, 5)
					boutput(user, "<span class='notice'>Range set to [range]!</span>")
					if(level == 1)
						rebeam()

	proc/toggle()
		if(active)
			loosen()
		else
			secure()
	loosen()
		active = 0
		for(var/beam in beamobjs)
			qdel(beam)
	secure()
		rebeam()

	rotate()
		if(level == 1)
			rebeam()

	disposing()
		loosen()
		..()

	proc/tripped()
		mechanics.fireOutgoing(mechanics.newSignal(mechanics.outputSignal))

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.loc = target
		return

	proc/rebeam()
		loosen()
		active = 1
		beamobjs = list()
		var/turf/lastturf = get_step(get_turf(src), dir)
		for(var/i = 1, i<range, i++)
			if(lastturf.opacity || !lastturf.canpass())
				break
			var/obj/mechbeam/newbeam = new(lastturf, src)
			newbeam.dir = src.dir
			beamobjs[++beamobjs.len] = newbeam
			lastturf = get_step(lastturf, dir)

/obj/item/mechanics/hscan
	name = "Hand scanner"
	desc = ""
	icon_state = "comp_hscan"
	var/send_name = 0
	var/ready = 1

	New()
		..()
		configs.Add("Toggle Signal Type")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Toggle Signal Type")
					send_name = !send_name
					boutput(user, "[send_name ? "Now sending user NAME":"Now sending user FINGERPRINT"]")

	attack_hand(mob/user as mob)
		if(level != 2 && ready)
			if(ishuman(user) && user.bioHolder)
				ready = 0
				SPAWN_DBG(3 SECONDS) ready = 1
				flick("comp_hscan1",src)
				playsound(src.loc, "sound/machines/twobeep2.ogg", 90, 0)
				var/sendstr = (send_name ? user.real_name : user.bioHolder.uid_hash)
				var/datum/mechanicsMessage/msg = mechanics.newSignal(sendstr)
				mechanics.fireOutgoing(msg)
			else
				boutput(user, "<span class='alert'>The hand scanner can only be used by humanoids.</span>")
				return
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.loc = target
		return

/obj/item/mechanics/accelerator
	name = "Graviton accelerator"
	desc = ""
	icon_state = "comp_accel"
	can_rotate = 1
	var/active = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		..()
		mechanics.addInput("activate", "activateproc")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			src.modify_configs()

	proc/drivecurrent()
		if(level == 2) return
		var/count = 0
		for(var/atom/movable/M in src.loc)
			if(M.anchored) continue
			count++
			if(M == src) continue
			throwstuff(M)
			if(count > 50) return
			if(world.tick_usage > 100) return //fuck it, failsafe

	proc/activateproc(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(active) return
			particleMaster.SpawnSystem(new /datum/particleSystem/gravaccel(src.loc, src.dir))
			SPAWN_DBG(0)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_accel1"
					active = 1
					SPAWN_DBG(0) drivecurrent()
					SPAWN_DBG(0.5 SECONDS) drivecurrent()
				sleep(3 SECONDS)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_accel"
					active = 0
		return

	proc/throwstuff(atom/movable/AM as mob|obj)
		if(level == 2 || AM.anchored || AM == src) return
		if(AM.throwing) return
		var/atom/target = get_edge_target_turf(AM, src.dir)
		SPAWN_DBG(0) AM.throw_at(target, 50, 1)
		return

	HasEntered(atom/movable/AM as mob|obj)
		if(level == 2) return
		if(active)
			throwstuff(AM)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_accel"
		return

/obj/item/mechanics/pausecomp
	name = "Delay Component"
	desc = ""
	icon_state = "comp_wait"
	var/active = 0
	var/delay = 10
	var/changesig = 0

	get_desc()
		. += "<br><span class='notice'>Current Delay: [delay]</span>"

	New()
		..()
		mechanics.addInput("delay", "delayproc")
		configs.Add("Set Delay")
		configs.Add("Toggle Signal Changing")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Delay")
					var/inp = input(user, "Enter delay in 10ths of a second:", "Set delay", 10) as num
					inp = max(inp, 10)
					if(inp)
						delay = inp
						boutput(user, "Set delay to [inp]")
				if("Toggle Signal Changing")
					changesig = !changesig
					boutput(user, "Signal changing now [changesig ? "on":"off"]")

	proc/delayproc(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(active) return
			SPAWN_DBG(0)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_wait1"
					active = 1
				sleep(delay)
				if(src)
					if(changesig)
						input.signal = mechanics.outputSignal
					mechanics.fireOutgoing(input)
					icon_state = "[under_floor ? "u":""]comp_wait"
					active = 0
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_wait"
		return

/obj/item/mechanics/andcomp
	name = "AND Component"
	desc = ""
	icon_state = "comp_and"
	var/timeframe = 30
	var/inp1 = 0
	var/inp2 = 0

	get_desc()
		. += "<br><span class='notice'>Current Time Frame: [timeframe]</span>"

	New()
		..()
		mechanics.addInput("input 1", "fire1")
		mechanics.addInput("input 2", "fire2")
		configs.Add("Set Time Frame")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Time Frame")
					var/inp = input(user, "Enter Time Frame in 10ths of a second:", "Set Time Frame", timeframe) as num
					if(inp)
						timeframe = inp
						boutput(user, "Set Time Frame to [inp]")

	proc/fire1(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(inp1) return

		inp1 = 1

		if(inp2)
			input.signal = mechanics.outputSignal
			mechanics.fireOutgoing(input)
			inp1 = 0
			inp2 = 0
			return

		SPAWN_DBG(timeframe)
			inp1 = 0

		return

	proc/fire2(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(inp2) return

		inp2 = 1

		if(inp1)
			input.signal = mechanics.outputSignal
			mechanics.fireOutgoing(input)
			inp1 = 0
			inp2 = 0
			return

		SPAWN_DBG(timeframe)
			inp2 = 0

		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_and"
		return

/obj/item/mechanics/orcomp
	name = "OR Component"
	desc = ""
	icon_state = "comp_or"

	New()
		..()
		mechanics.addInput("input 1", "fire")
		mechanics.addInput("input 2", "fire")
		mechanics.addInput("input 3", "fire")
		mechanics.addInput("input 4", "fire")
		mechanics.addInput("input 5", "fire")
		mechanics.addInput("input 6", "fire")
		mechanics.addInput("input 7", "fire")
		mechanics.addInput("input 8", "fire")
		mechanics.addInput("input 9", "fire")
		mechanics.addInput("input 10", "fire")
		configs.Add("Set Trigger-Signal")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Trigger-Signal")
					var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
					if(length(inp))
						inp = strip_html(html_decode(inp))
						mechanics.triggerSignal = inp
						boutput(user, "Signal set to [inp]")

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input.signal == mechanics.triggerSignal)
			input.signal = mechanics.outputSignal
			mechanics.fireOutgoing(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_or"
		return

/obj/item/mechanics/wifisplit
	name = "Wifi Signal Splitter Component"
	desc = ""
	icon_state = "comp_split"

	get_desc()
		. += "<br><span class='notice'>Current Trigger Field: [mechanics.triggerSignal]</span>"

	New()
		..()
		mechanics.addInput("split", "split")
		configs.Add("Set Trigger Field")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Trigger Field")
					var/inp = input(user,"Please enter Trigger Field:","Trigger Field setting","1") as text
					if(length(inp))
						inp = strip_html(html_decode(inp))
						mechanics.triggerSignal = inp
						boutput(user, "Trigger Field set to [inp]")

	proc/split(var/datum/mechanicsMessage/input)
		if(level == 2) return
		var/list/converted = params2list(input.signal)
		if(converted.len)
			if(converted.Find(mechanics.triggerSignal))
				input.signal = converted[mechanics.triggerSignal]
				mechanics.fireOutgoing(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_split"
		return

/obj/item/mechanics/regreplace
	name = "RegEx Replace Component"
	desc = ""
	icon_state = "comp_regrep"
	var/expression = "original/replacement/g"
	var/expressionpatt = "original"
	var/expressionrepl = "replacement"
	var/expressionflag = "g"

	get_desc()
		. += "<span class='notice'>Current Expression: [html_encode(expression)]</span><br/>"
		. += "<span class='notice'>Current Replacement: [html_encode(expressionrepl)]</span><br/>"
		. += "Your replacement string can contain $0-$9 to insert that matched group(things between parenthesis)<br/>"
		. += "$` will be replaced with the text that came before the match, and $' will be replaced by the text after the match.<br/>"
		. += "$0 or $& will be the entire matched string."

	New()
		..()
		mechanics.addInput("replace string", "checkstr")
		mechanics.addInput("set regex", "setregex")
		mechanics.addInput("set regex replacement", "setregexreplace")
		configs.Add(list("Set Pattern","Set Replacement","Set Flags","Set Regular Expression Replacement"))
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Pattern")
					var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
					if(inp != null)
						//var/regex/R = new(inp) // How would you even check this anymore?
						//if(!R)
						//	boutput(user, "<span class='alert'>Bad regex</span>")
						//else
						expressionpatt = inp
						inp = sanitize(html_encode(inp))
						expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
						boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expression))]")
				if("Set Replacement")
					var/inp = input(user,"Please enter Expression Replacement:","Expression setting", expressionrepl) as text
					if(inp != null)
						expressionrepl = inp
						inp = sanitize(html_encode(inp))
						expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
						boutput(user, "Expression Replacement set to [inp], Current Expression: [sanitize(html_encode(expression))]")
				if("Set Flags")
					var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
					if(inp != null)
						expressionflag = inp
						inp = sanitize(html_encode(inp))
						expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
						boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expression))]")
				if("Set Regular Expression Replacement")
					var/inp = input(user,"Please enter Replacement:","Replacement setting", expressionrepl) as text
					if(length(inp))
						expressionrepl = inp
						boutput(user, "Replacement set to [html_encode(inp)]")

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expressionpatt)) return
		var/regex/R = new(expressionpatt,expressionflag)

		if(!R) return

		var/mod = R.Replace(input.signal, expressionrepl)
		mod = strip_html(sanitize(html_encode(mod)))//U G H

		if(mod)
			input.signal = mod
			mechanics.fireOutgoing(input)

		return
	proc/setregex(var/datum/mechanicsMessage/input)
		expression = input.signal

	proc/setregexreplace(var/datum/mechanicsMessage/input)
		expressionrepl = input.signal

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_regrep"
		return

/obj/item/mechanics/regfind
	name = "RegEx Find Component"
	desc = ""
	icon_state = "comp_regfind"
	var/replacesignal = 0
	var/expression = "/\[a-Z\]*/"
	var/expressionpatt
	var/expressionflag

	get_desc()
		. += {"<br><span class='notice'>Current Expression: [sanitize(html_encode(expression))]<br>
		Replace Signal is [replacesignal ? "on.":"off."]</span>"}

	New()
		..()
		mechanics.addInput("check string", "checkstr")
		mechanics.addInput("set regex", "setregex")
		configs.Add(list("Set Expression Pattern","Set Expression Flags","Toggle Signal replacing"))
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Expression Pattern")
					var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
					if(inp != null)
						expressionpatt = inp
						expression =("[expressionpatt]/[expressionflag]")
						inp = sanitize(html_encode(inp))
						boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expression))]")
				if("Set Expression Flags")
					var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
					if(inp != null)
						expressionflag = inp
						expression =("[expressionpatt]/[expressionflag]")
						inp = sanitize(html_encode(inp))
						boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expression))]")
				if("Toggle Signal replacing")
					replacesignal = !replacesignal
					boutput(user, "[replacesignal ? "Now forwarding own Signal":"Now forwarding found String"]")

	proc/setregex(var/datum/mechanicsMessage/input)
		expression = input.signal
	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expression)) return
		var/regex/R = new(expressionpatt, expressionflag)

		if(!R) return

		if(R.Find(input.signal))
			if(replacesignal)
				input.signal = mechanics.outputSignal
			else
				input.signal = R.match
			mechanics.fireOutgoing(input)

		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_regfind"
		return

/obj/item/mechanics/sigcheckcomp
	name = "Signal-Check Component"
	desc = ""
	icon_state = "comp_check"
	var/not = 0
	var/changesig = 0

	get_desc()
		. += {"<br><span class='notice'>[not ? "Component triggers when Signal is NOT found.":"Component triggers when Signal IS found."]<br>
		Replace Signal is [changesig ? "on.":"off."]<br>
		Currently checking for: [sanitize(html_encode(mechanics.triggerSignal))]</span>"}

	New()
		..()
		mechanics.addInput("check string", "checkstr")
		mechanics.addInput("set trigger", "settrigger")
		src.configs.Add(list("Set Trigger-String","Invert Trigger","Toggle Replace Signal"))
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Trigger-String")
					var/inp = input(user,"Please enter String:","String setting","1") as text
					if(length(inp))
						inp = adminscrub(inp)
						mechanics.triggerSignal = inp
						boutput(user, "String set to [inp]")
				if("Invert Trigger")
					not = !not
					boutput(user, "[not ? "Component will now trigger when the String is NOT found.":"Component will now trigger when the String IS found."]")
				if("Toggle Replace Signal")
					changesig = !changesig
					boutput(user, "Signal changing now [changesig ? "on":"off"]")

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(findtext(input.signal, mechanics.triggerSignal))
			if(!not)
				if(changesig) input.signal = mechanics.outputSignal
				mechanics.fireOutgoing(input)
		else
			if(not)
				if(changesig) input.signal = mechanics.outputSignal
				mechanics.fireOutgoing(input)
		return

	proc/settrigger(var/datum/mechanicsMessage/input)
		mechanics.triggerSignal = input.signal

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_check"
		return

/obj/item/mechanics/dispatchcomp
	name = "Dispatch Component"
	desc = ""
	icon_state = "comp_disp"

	get_desc()
		. += "<br><span class='notice'>Exact match mode: [mechanics.exact_match ? "on" : "off"]</span>"

	New()
		..()
		mechanics.filtered = 1
		mechanics.addInput("dispatch", "dispatch")
		configs.Add("Toggle Exact Match")
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Toggle Exact Match")
					mechanics.exact_match = !mechanics.exact_match
					boutput(user, "Exact match mode now [mechanics.exact_match ? "on" : "off"]")

	proc/dispatch(var/datum/mechanicsMessage/input)
		if (level == 2) return
		var/sent = mechanics.fireOutgoing(input) //Filtering is handled by mechanics_holder based on filtered flag
		if(sent) animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_disp"
		return

/obj/item/mechanics/sigbuilder
	name = "Signal Builder Component"
	desc = ""
	icon_state = "comp_builder"
	var/buffer = ""
	var/bstr = ""
	var/astr = ""

	get_desc()
		. += {"<br><span class='notice'>Current Buffer Contents: [html_encode(sanitize(buffer))]<br>"
		Current starting String: [html_encode(sanitize(bstr))]<br>"
		Current ending String: [html_encode(sanitize(astr))]</span>"}

	New()
		..()
		mechanics.addInput("add to string", "addstr")
		mechanics.addInput("add to string + send", "addstrsend")
		mechanics.addInput("send", "sendstr")
		mechanics.addInput("clear buffer", "clrbff")
		configs.Add(list("Set starting String","Set ending String"))
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set starting String")
					var/inp = input(user,"Please enter String:","String setting", bstr) as text
					inp = strip_html(inp)
					bstr = inp
					boutput(user, "String set to [inp]")
				if("Set ending String")
					var/inp = input(user,"Please enter String:","String setting", astr)
					inp = strip_html(inp)
					astr = inp
					boutput(user, "String set to [inp]")

	proc/clrbff(var/datum/mechanicsMessage/input)
		if(level == 2) return
		buffer = ""
		return

	proc/sendstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		var/finished = "[bstr][buffer][astr]"
		finished = strip_html(sanitize(finished))
		input.signal = finished
		mechanics.fireOutgoing(input)
		buffer = ""
		return

	proc/addstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		buffer = "[buffer][input.signal]"
		return

	proc/addstrsend(var/datum/mechanicsMessage/input)
		if(level == 2) return
		buffer = "[buffer][input.signal]"
		sendstr(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_builder"
		return

/obj/item/mechanics/relaycomp
	name = "Relay Component"
	desc = ""
	icon_state = "comp_relay"
	var/ready = 1
	var/changesig = 0

	get_desc()
		. += "<br><span class='notice'>Replace Signal is [changesig ? "on.":"off."]</span>"

	New()
		..()
		mechanics.addInput("relay", "relay")
		configs.Add("Toggle Signal Changing")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Toggle Signal Changing")
					changesig = !changesig
					boutput(user, "Signal changing now [changesig ? "on":"off"]")

	proc/relay(var/datum/mechanicsMessage/input)
		if(level == 2 || !ready) return
		ready = 0
		SPAWN_DBG(3 SECONDS) ready = 1
		flick("[under_floor ? "u":""]comp_relay1", src)
		if(changesig)
			input.signal = mechanics.outputSignal
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_relay"
		return

/obj/item/mechanics/wificomp
	name = "Wifi Component"
	desc = ""
	icon_state = "comp_radiosig"
	var/ready = 1
	var/send_full = 0
	var/only_directed = 1

	var/net_id = null //What is our ID on the network?
	var/last_ping = 0
	var/range = 0

	var/frequency = 1419
	var/datum/radio_frequency/radio_connection

	get_desc()
		. += {"<br><span class='notice'>[send_full ? "Sending full unprocessed Signals.":"Sending only processed sendmsg and pda Message Signals."]<br>
		[only_directed ? "Only reacting to Messages directed at this Component.":"Reacting to ALL Messages received."]<br>
		Current Frequency: [frequency]<br>
		Current NetID: [net_id]</span>"}

	New()
		..()
		mechanics.addInput("send radio message", "send")
		mechanics.addInput("set frequency", "setfreq")
		configs.Add(list("Set Frequency","Toggle NetID Filtering","Toggle Forward All"))
		src.append_default_configs()

		if(radio_controller)
			set_frequency(frequency)

		src.net_id = format_net_id("\ref[src]")

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Frequency")
					var/inp = input(user,"Please enter Frequency:","Frequency setting", frequency) as num
					if(inp)
						set_frequency(inp)
						boutput(user, "Frequency set to [inp]")
				if("Toggle NetID Filtering")
					only_directed = !only_directed
					boutput(user, "[only_directed ? "Now only reacting to Messages directed at this Component":"Now reacting to ALL Messages."]")
				if("Toggle Forward All")
					send_full = !send_full
					boutput(user, "[send_full ? "Now forwarding all Radio Messages as they are.":"Now processing only sendmsg and normal PDA messages."]")

	proc/setfreq(var/datum/mechanicsMessage/input)
		var/newfreq = text2num(input.signal)
		if(!newfreq) return
		set_frequency(newfreq)
		return

	proc/send(var/datum/mechanicsMessage/input)
		if(level == 2) return
		var/list/converted = params2list(input.signal)
		if(!converted.len || !ready) return

		ready = 0
		SPAWN_DBG(3 SECONDS) ready = 1

		var/datum/signal/sendsig = get_free_signal()

		sendsig.source = src
		sendsig.data["sender"] = src.net_id
		sendsig.transmission_method = TRANSMISSION_RADIO

		for(var/X in converted)
			sendsig.data["[X]"] = "[converted[X]]"
			if(X == "command" && converted[X] == "text_message")
				logTheThing("pdamsg", usr, null, "sends a PDA message <b>[input.signal]</b> using a wifi component at [log_loc(src)].")

		SPAWN_DBG(0) src.radio_connection.post_signal(src, sendsig, src.range)

		animate_flash_color_fill(src,"#FF0000",2, 2)
		return

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption || level == 2)
			return

		if((only_directed && signal.data["address_1"] == src.net_id) || !only_directed || (signal.data["address_1"] == "ping"))

			if(send_full)
				var/datum/mechanicsMessage/msg = mechanics.newSignal(html_decode(list2params_noencode(signal.data)))
				mechanics.fireOutgoing(msg)
				animate_flash_color_fill(src,"#00FF00",2, 2)
				return

			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "COMP_WIFI"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.data["data"] = "Wifi Component"
				pingsignal.transmission_method = TRANSMISSION_RADIO

				SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
					src.radio_connection.post_signal(src, pingsignal, src.range)

			else if(signal.data["command"] == "sendmsg" && signal.data["data"])
				var/datum/mechanicsMessage/msg = mechanics.newSignal(html_decode(signal.data["data"]))
				mechanics.fireOutgoing(msg)
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "text_message" && signal.data["message"])
				var/datum/mechanicsMessage/msg = mechanics.newSignal(html_decode(signal.data["message"]))
				mechanics.fireOutgoing(msg)
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "setfreq" && signal.data["data"])
				var/newfreq = text2num(signal.data["data"])
				if(!newfreq) return
				set_frequency(newfreq)
				animate_flash_color_fill(src,"#00FF00",2, 2)

		return

	proc/set_frequency(new_frequency)
		if(!radio_controller) return
		new_frequency = max(1000, min(new_frequency, 1500))
		radio_controller.remove_object(src, "[frequency]")
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, "[frequency]")

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_radiosig"
		return


/obj/item/mechanics/selectcomp
	name = "Selection Component"
	desc = ""
	icon_state = "comp_selector"
	var/list/signals = new/list()
	var/current_index = 1
	var/announce = 0
	var/random = 0
	var/allowDuplicates = 1

	get_desc()
		. += {"<br><span class='notice'>[random ? "Sending random Signals.":"Sending selected Signals."]<br>
		[announce ? "Announcing Changes.":"Not announcing Changes."]<br>
		[allowDuplicates ? "Duplicate entries allowed." : "Duplicate entries not allowed."]<br>
		Current Selection: [(!current_index || current_index > signals.len ||!signals.len) ? "Empty":"[current_index] -> [signals[current_index]]"]<br>
		Currently contains [signals.len] Items:<br></span>
		[signals.Join("<br>")]"}

	New()
		..()
		mechanics.addInput("add item", "additem")
		mechanics.addInput("remove item", "remitem")
		mechanics.addInput("remove all items", "remallitem")
		mechanics.addInput("select item", "selitem")
		mechanics.addInput("select item + send", "selitemplus")
		mechanics.addInput("next", "next")
		mechanics.addInput("previous", "previous")
		mechanics.addInput("next + send", "nextplus")
		mechanics.addInput("previous + send", "previousplus")
		mechanics.addInput("send selected", "sendCurrent")
		mechanics.addInput("send random", "sendRand")
		configs.Add(list("Set Signal List","Set Signal List(Delimeted)","Toggle Announcements","Toggle Random","Toggle Allow Duplicate Entries"))
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Signal List")
					var/numsig = input(user,"How many Signals would you like to define?","# Signals:", 3) as num
					numsig = round(numsig)
					if(numsig > 10) //Needs a limit because nerds are nerds
						boutput(user, "<span class='alert'>This component can't handle more than 10 signals!</span>")
						return
					if(numsig)
						signals.Cut()
						boutput(user, "Defining [numsig] Signals ...")
						for(var/i=0, i<numsig, i++)
							var/signew = input(user,"Content of Signal #[i]","Content:", "signal[i]") as text
							signew = adminscrub(signew) //SANITIZE THAT SHIT! FUCK!!!!
							if(length(signew))
								signals.Add(signew)
							else
								signals.Cut()
								return
						boutput(user, "Set [numsig] Signals!")
						for(var/a in signals)
							boutput(user, a)
				if("Set Signal List(Delimeted)")
					var/newsigs = ""
					while(1)
						newsigs = input(user, "Enter a string delimited by ; for every item you want in the list.", "Enter a thing. Max length is 2048 characters", newsigs)
						if(!newsigs)
							boutput(user, "<span class='notice'>Signals remain unchanged!</span>")
							break
						if(length(newsigs) >= 2048)
							alert(user, "That's far too long. Trim it down some!")
							continue
						var/list/built = splittext(newsigs, ";")
						var/done = 1
						for(var/i = 1, i <= built.len, i++)
							if(!built[i])
								done = 0
								alert(user, "You have an empty signal in there, try again!(todo, just remove these)")
								break
						if(done)
							signals = built
							current_index = 1
							boutput(user, "<span class='notice'>There are now [signals.len] signals in the list.</span>")
							break
				if("Toggle Announcements")
					announce = !announce
					boutput(user, "Announcements now [announce ? "on":"off"]")
				if("Toggle Random")
					random = !random
					boutput(user, "[random ? "Now picking Items at random.":"Now using selected Items."]")
				if("Toggle Allow Duplicate Entries")
					allowDuplicates = !allowDuplicates
					boutput(user, "[allowDuplicates ? "Allowing addition of duplicate items." : "Not allowing addition of duplicate items."]")

	proc/selitem(var/datum/mechanicsMessage/input)
		if(!input) return

		if(signals.Find(input.signal))
			current_index = signals.Find(input.signal)

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return

	proc/selitemplus(var/datum/mechanicsMessage/input)
		if(!input) return

		if(signals.Find(input.signal))
			current_index = signals.Find(input.signal)
		else
			return // Don't send out a signal if not found

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")

		input.signal = signals[current_index]
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	proc/remitem(var/datum/mechanicsMessage/input)
		if(!input) return

		if(signals.Find(input.signal))
			signals.Remove(input.signal)
			if(announce)
				componentSay("Removed : [input.signal]")

		return

	proc/remallitem(var/datum/mechanicsMessage/input)
		if(!input) return

		for(var/s in signals)
			signals.Remove(s)

		if(announce)
			componentSay("Removed all signals.")

		return

	proc/additem(var/datum/mechanicsMessage/input)
		if(!input) return

		if(allowDuplicates)
			signals.Add(input.signal)
			signals[input.signal] = 1
			if(announce)
				componentSay("Added: [input.signal]")

		else
			if(!signals[input.signal])
				signals[input.signal] = 1
				if(announce)
					componentSay("Added: [input.signal]")
			else if(announce)
				componentSay("Duplicate entry - rejected: [input.signal]")

	proc/sendRand(var/datum/mechanicsMessage/input)
		if(!input) return
		//I feel bad for doing this.
		var/orig = random
		random = 1
		sendCurrent(input)
		random = orig
		return

	proc/sendCurrent(var/datum/mechanicsMessage/input)
		if(!input) return
		if(!current_index || current_index > signals.len ||!signals.len) return

		if(random) input.signal = pick(signals)
		else input.signal = signals[current_index]

		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	proc/next(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(!signals.len) return
		if((current_index + 1) > signals.len)
			current_index = 1
		else
			current_index++

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return

	proc/nextplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(!signals.len) return
		if((current_index + 1) > signals.len)
			current_index = 1
		else
			current_index++

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")

		sendCurrent(input)
		return

	proc/previous(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(!signals.len) return
		if((current_index - 1) < 1)
			current_index = signals.len
		else
			current_index--

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return

	proc/previousplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(!signals.len) return
		if((current_index - 1) < 1)
			current_index = signals.len
		else
			current_index--

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")

		sendCurrent(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_selector"
		return

/obj/item/mechanics/togglecomp
	name = "Toggle Component"
	desc = ""
	icon_state = "comp_toggle"
	var/on = 0
	var/signal_on = "1"
	var/signal_off = "0"

	get_desc()
		. += {"<br><span class='notice'>Currently [on ? "ON":"OFF"].<br>
		Current ON Signal: [signal_on]<br>
		Current OFF Signal: [signal_off]</span>"}

	New()
		..()
		mechanics.addInput("activate", "activate")
		mechanics.addInput("deactivate", "deactivate")
		mechanics.addInput("toggle", "toggle")
		mechanics.addInput("output state", "state")
		configs.Add(list("Set On-Signal","Set Off-Signal"))
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set On-Signal")
					var/inp = input(user,"Please enter Signal:","Signal setting",signal_on) as text
					if(length(inp))
						inp = adminscrub(inp)
						signal_on = inp
						boutput(user, "On-Signal set to [inp]")
				if("Set Off-Signal")
					var/inp = input(user,"Please enter Signal:","Signal setting",signal_off) as text
					if(length(inp))
						inp = adminscrub(inp)
						signal_off = inp
						boutput(user, "Off-Signal set to [inp]")

	proc/activate(var/datum/mechanicsMessage/input)
		if(level == 2) return
		on = 1
		input.signal = signal_on
		updateIcon()
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	proc/deactivate(var/datum/mechanicsMessage/input)
		if(level == 2) return
		on = 0
		input.signal = signal_off
		updateIcon()
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == 2) return
		on = !on
		input.signal = (on ? signal_on : signal_off)
		updateIcon()
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	proc/state(var/datum/mechanicsMessage/input)
		if(level == 2) return
		input.signal = (on ? signal_on : signal_off)
		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_toggle[on ? "1":""]"
		return

/obj/item/mechanics/telecomp
	name = "Teleport Component"
	desc = ""
	icon_state = "comp_tele"
	var/ready = 1
	var/teleID = "tele1"
	var/send_only = 0

	get_desc()
		. += {"<br><span class='notice'>Current ID: [teleID].<br>
		Send only Mode: [send_only ? "On":"Off"].</span>"}

	New()
		..()
		mechanics_telepads.Add(src)
		mechanics.addInput("activate", "activate")
		mechanics.addInput("setID", "setidmsg")
		configs.Add(list("Set Teleporter ID","Toggle Send-only Mode"))
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Teleporter ID")
					var/inp = input(user,"Please enter ID:","ID setting",teleID) as text
					if(length(inp))
						inp = adminscrub(inp)
						teleID = inp
						boutput(user, "ID set to [inp]")
				if("Toggle Send-only Mode")
					send_only = !send_only
					if(send_only)
						src.overlays += image('icons/misc/mechanicsExpansion.dmi', icon_state = "comp_teleoverlay")
					else
						src.overlays.Cut()
					boutput(user, "Send-only Mode now [send_only ? "on":"off"]")

	proc/setidmsg(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input.signal)
			teleID = input.signal
 		componentSay("ID Changed to : [input.signal]")
		return

	proc/activate(var/datum/mechanicsMessage/input)
		if(level == 2 || !ready) return
		ready = 0
		SPAWN_DBG(3 SECONDS) ready = 1
		flick("[under_floor ? "u":""]comp_tele1", src)
		particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(src.loc)))
		playsound(src.loc, "sound/mksounds/boost.ogg", 50, 1)
		var/list/destinations = new/list()

		for(var/obj/item/mechanics/telecomp/T in mechanics_telepads)
			if(T == src || T.level == 2 || !isturf(T.loc)  || isrestrictedz(T.z)|| T.send_only) continue

#ifdef UNDERWATER_MAP
			if (!(T.z == 5 && src.z == 1) && !(T.z == 1 && src.z == 5)) //underwater : allow TP to/from trench
				if(T.z != src.z) continue
#else
			if (T.z != src.z) continue
#endif

			if (T.teleID == src.teleID)
				destinations.Add(T)

		if(destinations.len)
			var/atom/picked = pick(destinations)
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(picked.loc)))
			for(var/atom/movable/M in src.loc)
				if(M == src || M.invisibility || M.anchored) continue
				M.set_loc(get_turf(picked.loc))

		SPAWN_DBG(0)
			mechanics.fireOutgoing(input)
		return

	disposing()
		mechanics_telepads.Remove(src)
		return ..()

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_tele"
		return

/obj/item/mechanics/ledcomp
	name = "LED Component"
	desc = ""
	icon_state = "comp_led"
	var/light_level = 2
	var/active = 0
	var/selcolor = "#FFFFFF"
	var/datum/light/light
	color = "#AAAAAA"

	get_desc()
		. += "<br><span class='notice'>Current Color: [selcolor].</span>"

	New()
		..()
		mechanics.addInput("toggle", "toggle")
		mechanics.addInput("activate", "turnon")
		mechanics.addInput("deactivate", "turnoff")
		mechanics.addInput("set rgb", "setrgb")
		configs.Add(list("Set Color","Set Range"))
		src.append_default_configs(2)
		light = new /datum/light/point
		light.attach(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set Color")
					var/red = input(user,"Red Color(0.0 - 1.0):","Color setting", 1.0) as num
					red = max(red, 0.0)
					red = min(red, 1.0)

					var/green = input(user,"Green Color(0.0 - 1.0):","Color setting", 1.0) as num
					green = max(green, 0.0)
					green = min(green, 1.0)

					var/blue = input(user,"Blue Color(0.0 - 1.0):","Color setting", 1.0) as num
					blue = max(blue, 0.0)
					blue = min(blue, 1.0)

					selcolor = rgb(red * 255, green * 255, blue * 255)

					light.set_color(red, green, blue)
				if("Set Range")
					var/inp = input(user,"Please enter Range(1 - 7):","Range setting", light_level) as num
					if(get_dist(user, src) > 1 || user.stat)
						return

					inp = round(inp)
					inp = max(inp, 1)
					inp = min(inp, 7)

					boutput(user, "Range set to [inp]")

					light.set_brightness(inp / 7)

	pickup()
		active = 0
		light.disable()
		src.color = "#AAAAAA"
		return ..()

	proc/setrgb(var/datum/mechanicsMessage/input)

		if(length(input.signal) == 7 && copytext(input.signal, 1, 2) == "#")
			if(active)
				color = input.signal
			selcolor = input.signal
			SPAWN_DBG(0) light.set_color(GetRedPart(selcolor) / 255, GetGreenPart(selcolor) / 255, GetBluePart(selcolor) / 255)

	proc/turnon(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if (usr && usr.stat)
			return
		active = 1
		light.enable()
		src.color = selcolor
		return

	proc/turnoff(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if (usr && usr.stat)
			return
		active = 0
		light.disable()
		src.color = "#AAAAAA"
		return

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if (usr && usr.stat)
			return
		if(active)
			turnoff(input)
		else
			turnon(input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_led"
		return

/obj/item/mechanics/miccomp
	name = "Microphone Component"
	desc = ""
	icon_state = "comp_mic"
	var/add_sender = 0

	New()
		..()
		configs.Add("Toggle Show-Source")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Toggle Show-Source")
					add_sender = !add_sender
					boutput(user, "Show-Source now [add_sender ? "on":"off"]")

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		if(level == 2) return
		var/message = msg[2]
		if(lang_id in list("english", ""))
			message = msg[1]
		message = strip_html(html_decode(message))
		var/heardname = M.name
		if (real_name)
			heardname = real_name
		var/datum/mechanicsMessage/sigmsg = mechanics.newSignal((add_sender ? "[heardname] : [message]":"[message]"))
		mechanics.fireOutgoing(sigmsg)
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_mic"
		return

/obj/item/mechanics/radioscanner
	name = "Radio Scanner Component"
	desc = ""
	icon_state = "comp_radioscanner"

	var/frequency = R_FREQ_DEFAULT
	var/datum/radio_frequency/radio_connection

	get_desc()
		. += "<br><span style=\"color:blue\">Current Frequency: [frequency]</span>"

	New()
		..()
		mechanics.addInput("set frequency", "setfreq")
		configs.Add(list("Set Frequency"))
		src.append_default_configs(2)

		if(radio_controller)
			set_frequency(frequency)

	attackby(obj/item/W as obj, mob/user as mob)
		if (..(W, user)) return
		else if (ispulsingtool(W))
			switch (src.modify_configs())
				if (0)
					return
				if ("Set Frequency")
					var/inp = input(user, "New frequency ([R_FREQ_MINIMUM] - [R_FREQ_MAXIMUM]):", "Enter new frequency", frequency) as num
					if (inp)
						set_frequency(inp)
						boutput(user, "Frequency set to [frequency]")

	proc/setfreq(var/datum/mechanicsMessage/input)
		var/newfreq = text2num(input.signal)
		if (!newfreq) return
		set_frequency(newfreq)
		return

	proc/set_frequency(new_frequency)
		if (!radio_controller) return
		new_frequency = sanitize_frequency(new_frequency)
		componentSay("New frequency: [new_frequency]")
		radio_controller.remove_object(src, "[frequency]")
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, "[frequency]")

	proc/hear_radio(mob/M as mob, msg, lang_id)
		if (level == 2) return
		var/message = msg[2]
		if (lang_id in list("english", ""))
			message = msg[1]
		message = strip_html(html_decode(message))
		var/heardname = M.real_name
		if (M.wear_mask && M.wear_mask.vchange)
			heardname = M:wear_id ? M:wear_id:registered : "Unknown"
		var/datum/mechanicsMessage/sigmsg = mechanics.newSignal("name=[heardname]&message=[message]")
		mechanics.fireOutgoing(sigmsg)
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	updateIcon()
		icon_state = "[under_floor ? "u" : ""]comp_radioscanner"
		return

/obj/item/mechanics/synthcomp
	name = "Sound Synthesizer"
	desc = ""
	icon_state = "comp_synth"
	var/ready = 1

	New()
		..()
		mechanics.addInput("input", "fire")
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			src.modify_configs()

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2 || !ready) return
		ready = 0
		SPAWN_DBG(2 SECONDS) ready = 1
		if(input)
			componentSay("[input.signal]")
		return

	updateIcon()
		icon_state = "comp_synth"
		return

/obj/item/mechanics/trigger/pressureSensor
	name = "Pressure Sensor"
	desc = ""
	icon_state = "comp_pressure"
	var/tmp/limiter = 0

	New()
		..()
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			src.modify_configs()

	Crossed(atom/movable/AM as mob|obj)
		if (level == 2)
			return
		if (isobserver(AM))
			return
		if (limiter && (ticker.round_elapsed_ticks < limiter))
			return

		limiter = ticker.round_elapsed_ticks + 10
		mechanics.fireOutgoing(mechanics.newSignal(mechanics.outputSignal))
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_pressure"
		return

/obj/item/mechanics/trigger/button
	name = "Button"
	desc = ""
	icon_state = "comp_button"
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"
	density = 1

	New()
		..()
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			src.modify_configs()
			return
		attack_hand(user)

	get_desc()
		. += "<br><span class='notice'>Current Signal: [html_encode(sanitize(mechanics.outputSignal))].</span>"

	attack_hand(mob/user as mob)
		if(level == 1)
			flick(icon_down, src)
			mechanics.fireOutgoing(mechanics.newSignal(mechanics.outputSignal))
		else
			..(user)
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target))
				user.drop_item()
				if(isturf(target) && target.density)
					icon_up = "comp_switch"
					icon_down = "comp_switch2"
				else
					icon_up = "comp_button"
					icon_down = "comp_button2"
				icon_state = icon_up
				src.loc = target
		return
	updateIcon()
		icon_state = icon_up
		return

/obj/item/mechanics/trigger/buttonPanel
	name = "Button Panel"
	desc = ""
	icon_state = "comp_buttpanel"
	var/icon_up = "comp_buttpanel"
	var/icon_down = "comp_buttpanel1"
	var/list/active_buttons = list()

	New()
		..()
		configs.Add(list("Add Button","Remove Button"))
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Add Button")
					if(src.active_buttons.len >= 10)
						boutput(user, "<span class='alert'>There's no room to add another button - the panel is full</span>")
						return

					var/new_label = input(user, "Button label", "Button Panel") as text
					var/new_signal = input(user, "Button signal", "Button Panel") as text
					if(length(new_label) && length(new_signal))
						new_label = adminscrub(new_label)
						new_signal = adminscrub(new_signal)
						if(src.active_buttons.Find(new_label))
							boutput(user, "There's already a button with that label.")
							return
						src.active_buttons.Add(new_label)
						src.active_buttons[new_label] = new_signal
						boutput(user, "Added button with label: [new_label] and value: [new_signal]")
				if("Remove Button")
					if(!src.active_buttons.len)
						boutput(user, "<span class='alert'>[src] has no active buttons - there's nothing to remove!</span>")
					else
						var/to_remove = input(user, "Choose button to remove", "Button Panel") in src.active_buttons + "*CANCEL*"
						if(!to_remove || to_remove == "*CANCEL*") return
						src.active_buttons.Remove(to_remove)
						boutput(user, "Removed button labeled [to_remove]")

	get_desc()
		. += "<br><span class='notice'>Buttons:</span>"
		for (var/button in src.active_buttons)
			. += "<br><span class='notice'>Label: [button], Value: [src.active_buttons[button]]</span>"

	attack_hand(mob/user as mob)
		if (level == 1)
			if (src.active_buttons.len)
				var/selected_button = input(usr, "Press a button", "Button Panel") in src.active_buttons + "*CANCEL*"
				if (!selected_button || selected_button == "*CANCEL*" || !in_range(src, usr)) return
				flick(icon_down, src)
				mechanics.fireOutgoing(mechanics.newSignal(src.active_buttons[selected_button]))
			else
				boutput(usr, "<span class='alert'>[src] has no active buttons - there's nothing to press!</span>")
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
			if(isturf(target))
				user.drop_item()
				src.loc = target
		return

	updateIcon()
		icon_state = icon_up
		return


// Updated these things for pixel bullets. Also improved user feedback and added log entries here and there (Convair880).
/obj/item/mechanics/gunholder
	name = "Gun Component"
	desc = ""
	icon_state = "comp_gun"
	density = 0
	can_rotate = 1
	var/obj/item/gun/Gun = null
	var/compatible_guns = /obj/item/gun/kinetic

	get_desc()
		. += "<br><span class='notice'>Current Gun: [Gun ? "[Gun] [Gun.canshoot() ? "(ready to fire)" : "(out of [istype(Gun, /obj/item/gun/energy) ? "charge)" : "ammo)"]"]" : "None"]</span>"

	New()
		..()
		mechanics.addInput("fire", "fire")
		configs.Add("Remove Gun")
		src.append_default_configs()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Remove Gun")
					if(Gun)
						logTheThing("station", user, null, "removes [Gun] from [src] at [log_loc(src)].")
						Gun.loc = get_turf(src)
						Gun = null
					else
						boutput(user, "<span class='alert'>There is no gun inside this component.</span>")
		else if(istype(W, src.compatible_guns))
			if(!Gun)
				boutput(usr, "You put the [W] inside the [src].")
				logTheThing("station", usr, null, "adds [W] to [src] at [log_loc(src)].")
				usr.drop_item()
				Gun = W
				Gun.loc = src
			else
				boutput(usr, "There is already a [Gun] inside the [src]")
		else
			user.show_text("The [W.name] isn't compatible with this component.", "red")

	proc/getTarget()
		var/atom/trg = get_turf(src)
		for(var/mob/living/L in trg)
			return get_turf_loc(L)
		for(var/i=0, i<7, i++)
			trg = get_step(trg, src.dir)
			for(var/mob/living/L in trg)
				return get_turf_loc(L)
		return get_edge_target_turf(src, src.dir)

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input && Gun)
			if(Gun.canshoot())
				var/atom/target = getTarget()
				if(target)
					//DEBUG_MESSAGE("Target: [log_loc(target)]. Src: [src]")
					Gun.shoot(target, get_turf(src), src)
			else
				src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"The [Gun.name] has no [istype(Gun, /obj/item/gun/energy) ? "charge" : "ammo"] remaining.\"</span>")
				playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
		else
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"No gun installed.\"</span>")
			playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
		return

	updateIcon()
		icon_state = "comp_gun"
		return

/obj/item/mechanics/gunholder/recharging
	name = "E-Gun Component"
	desc = ""
	icon_state = "comp_gun2"
	density = 0
	compatible_guns = /obj/item/gun/energy
	var/charging = 0
	var/ready = 1

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += charging ? "<br><span class='notice'>Component is charging.</span>" : null

	New()
		..()
		mechanics.addInput("recharge", "recharge")

	process()
		..()
		if(level == 2)
			if(charging) charging = 0
			return

		if(!Gun && charging)
			charging = 0
			updateIcon()

		if(!istype(Gun, /obj/item/gun/energy) || !charging)
			return

		var/obj/item/gun/energy/E = Gun

		// Can't recharge the crossbow. Same as the other recharger.
		if (!E.rechargeable)
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"This gun cannot be recharged manually.\"</span>")
			playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
			charging = 0
			updateIcon()
			return

		if (E.cell)
			if (E.cell.charge(15) != 1) // Same as other recharger.
				src.charging = 0
				src.updateIcon()

		E.update_icon()
		return

	proc/recharge(var/datum/mechanicsMessage/input)
		if(charging || !Gun || level == 2) return
		if(!istype(Gun, /obj/item/gun/energy)) return
		charging = 1
		updateIcon()
		return

	fire(var/datum/mechanicsMessage/input)
		if(charging || !ready) return
		ready = 0
		SPAWN_DBG(3 SECONDS) ready = 1
		return ..()

	updateIcon()
		icon_state = charging ? "comp_gun2x" : "comp_gun2"
		return

/obj/item/mechanics/instrumentPlayer //Grayshift's musical madness
	name = "Instrument Player"
	desc = ""
	icon_state = "comp_instrument"
	density = 0
	var/obj/item/instrument = null
	var/pitchUnlocked = 0 // varedit this to 1 to permit really goofy pitch values!
	var/ready = 1
	var/delay = 10
	var/sounds = null
	var/volume = 50

	get_desc()
		. += "<br><span class='notice'>Current Instrument: [instrument ? "[instrument]" : "None"]</span>"

	New()
		..()
		mechanics.addInput("play", "fire")
		configs.Add("Remove Instrument")
		src.append_default_configs()

	proc/fire(var/datum/mechanicsMessage/input)
		if (level == 2 || !ready || !instrument) return
		ready = 0
		SPAWN_DBG(delay) ready = 1
		var/signum = text2num(input.signal)
		if (signum &&((signum >= 0.4 && signum <= 2) ||(signum <= -0.4 && signum >= -2) || pitchUnlocked))
			flick("comp_instrument1", src)
			playsound(src.loc, sounds, volume, 0, 0, signum)
		else
			flick("comp_instrument1", src)
			playsound(src.loc, sounds, volume, 1)
			return

	updateIcon()
		icon_state = "comp_instrument"
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (..(W, user)) return // I don't know what this does but I'm copying it blindly. I guess it checks if there's a predefined action for hitting this with that?
		else if (ispulsingtool(W))
			switch (src.modify_configs())
				if (0)
					return
				if ("Remove Instrument")
					if(instrument)
						logTheThing("station", user, null, "removes [instrument] from [src] at [log_loc(src)].")
						instrument.loc = get_turf(src)
						instrument = null
					else
						boutput(user, "<span class='alert'>There is no instrument inside this component.</span>")
			return
		else if (instrument) // Already got one, chief!
			boutput(usr, "There is already \a [instrument] inside the [src].")
			return
		else if (istype(W, /obj/item/instrument)) //BLUH these aren't consolidated under any combined type hello elseif chain // i fix - haine
			var/obj/item/instrument/I = W
			instrument = I
			sounds = I.sounds_instrument
			volume = I.volume
			delay = I.note_time
		else if (istype(W, /obj/item/clothing/head/butt))
			instrument = W
			sounds = 'sound/voice/farts/poo2.ogg'
			volume = 100
			delay = 5
		else if (istype(W, /obj/item/clothing/shoes/clown_shoes))
			instrument = W
			sounds = list('sound/misc/clownstep1.ogg','sound/misc/clownstep2.ogg')
			volume = 50
			delay = 5
		else if (istype(W, /obj/item/artifact/instrument))
			var/obj/item/artifact/instrument/I = W
			instrument = I
			sounds = islist(I.sounds_instrument) ? I.sounds_instrument : list(I.sounds_instrument)
			volume = I.volume
			delay = I.spam_timer
		else // IT DON'T FIT
			user.show_text("\The [W] isn't compatible with this component.", "red")

		if (instrument) // You did it, boss. Now log it because someone will figure out a way to abuse it
			boutput(usr, "You put [W] inside [src].")
			logTheThing("station", usr, null, "adds [W] to [src] at [log_loc(src)].")
			usr.drop_item()
			instrument.loc = src

/obj/item/mechanics/math
	name = "Arithmetic Component"
	desc = "Do number things! Component list<br/>rng: Generates a random number from A to B<br/>add: Adds A + B<br/>sub: Subtracts A - B<br/>mul: Multiplies A * B<br/>div: Divides A / B<br/>pow: Power of A ^ B<br/>mod: Modulos A % B<br/>eq|neq|gt|lt|gte|lte: Equal/NotEqual/GreaterThan/LessThan/GreaterEqual/LessEqual -- will output 1 if true. Example: A GT B = 1 if A is larger than B"
	icon_state = "comp_arith"
	var/A = 1
	var/B = 1

	var/mode = "rng"
	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br><span class='notice'>Current Mode: [mode] | A = [A] | B = [B]</span>"
	secure()
		icon_state = "comp_arith1"
	loosen()
		icon_state = "comp_arith"
	New()
		..()
		mechanics.addInput("Set A", "setA")
		mechanics.addInput("Set B", "setB")
		mechanics.addInput("Evaluate", "evaluate")
		configs.Add(list("Set A","Set B","Set Mode"))
		src.append_default_configs(2)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			switch(src.modify_configs())
				if(0)
					return
				if("Set A")
					var/input = input("Set A to what?", "A", A) as num
					if(!isnull(input))
						A = input
				if("Set B")
					var/input = input("Set B to what?", "B", B) as num
					if(!isnull(input))
						B = input
				if("Set Mode")
					mode = input("Set the math mode to what?", "Mode Selector", mode) in list("add","mul","div","sub","mod","pow","rng","eq","neq","gt","lt","gte","lte")

	proc/setA(var/datum/mechanicsMessage/input)
		if (!isnull(text2num(input.signal)))
			A = text2num(input.signal)

	proc/setB(var/datum/mechanicsMessage/input)
		if (!isnull(text2num(input.signal)))
			B = text2num(input.signal)

	proc/evaluate()
		switch(mode)
			if("add")
				. = A + B
			if("sub")
				. = A - B
			if("div")
				if (B == 0)
					src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"Attempted division by zero!\"</span>")
					return
				. = A / B
			if("mul")
				. = A * B
			if("mod")
				. = A % B
			if("pow")
				. = A ** B
			if("rng")
				. = rand(A, B)
			if("gt")
				. = A > B
			if("lt")
				. = A < B
			if("gte")
				. = A >= B
			if("lte")
				. = A <= B
			if("eq")
				. = A == B
			if("neq")
				. = A != B
			else
				return
		if(. == .)
			mechanics.fireOutgoing(mechanics.newSignal("[.]"))

/obj/mecharrow
	name = ""
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "connectionArrow"
