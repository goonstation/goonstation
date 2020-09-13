#define CC_ERROR_INVALID_SX				1
#define CC_ERROR_INVALID_TX				2
#define CC_ERROR_INVALID_CONTAINER_SX	3
#define CC_ERROR_INVALID_CONTAINER_TX	4
#define CC_ERROR_INVALID_TEMPERATURE	5
#define CC_ERROR_CODE_PROTECTED			6
#define CC_ERROR_INSTRUCTION_LIMIT		7
#define CC_NOTIFICATION_COMPLETE		101
#define CC_NOTIFICATION_SAVED			102

#define CC_STATUS_IDLE					1
#define CC_STATUS_RUNNING				2

/**
 * Chemicompiler
 * v1.0 By volundr 9/24/14
 * This device is a programmable chemistry mixing and heating device.
 * The javascript code to run the frontend is in browserassets/js/chemicompiler.min.js
 *   which is minified javascript from browserassets/js/chemicompiler.js
 *   If you make changes to the uncompressed javascript, you'll need to install node.js,
 *   and run `npm install -g uglify-js`
 *   then run `uglifyjs browserassets/js/chemicompiler.js -c > browserassets/js/chemicompiler.min.js` to rebuild the compressed version.
 */

/datum/chemicompiler_core
	var/list/buttons[6]
	var/list/cbf[6]
	var/output = ""
	var/maxExpensiveOperations = 5 // maximum number of transfers per machine tick

	var/list/currentProg
	var/dp // data pointer
	var/list/data // data
	var/ip // instruction pointer

	//Registers
	var/sx // Source register
	var/tx // Target register
	var/ax // Amount register

	var/textBuffer
	var/count
	var/exec

	var/running = 0
	var/is_heating = 0
	var/html
	var/datum/tag/page/htmlTag
	var/errorCallback = "err"
	var/transferCallback = "transferReagents"
	var/isolateCallback = "isolateReagent"
	var/heatCallback = "heatReagents"
	var/messageCallback = "showMessage"
	var/reservoirClickCallback = "reservoirClick"
	var/reservoirCheckCallback = "reservoirCheck"
	var/topicPermissionCheckCallback = "topicPermissionCheck"
	var/statusChangeCallback
	var/minReservoir = 1
	var/maxReservoir = 10
	var/datum/holder
	var/heading = "don't touch!!!"

/datum/chemicompiler_core/New(datum/holder)
	..()
	if(!istype(holder))
		del(src)
		return

	src.holder = holder
	initHtml()

/datum/chemicompiler_core/Topic(href, href_list)
	if(!topicPermissionCheck(href_list["action"]))
		return
	switch(href_list["action"])
		if("getUIState")
			updatePanel()

		if("reservoir")
			var/resId = text2num(href_list["id"])
			if(resId < minReservoir || resId > maxReservoir)
				return

			reservoirClick(resId)
			updatePanel()

		if("loadCode")
			var/buttId = validateButtId(href_list["id"])
			if(!buttId)
				return
			if(buttons[buttId] == 0)
				throwError(CC_ERROR_CODE_PROTECTED)
				output = "E5.NOACC"
			else
				output = html_encode(buttons[buttId])

			windowCall("loadCodeCallback")
			updatePanel()

		if("saveCode")
			var/buttId = validateButtId(href_list["id"])
			if(!buttId)
				return
			var/code = href_list["code"]
			buttons[buttId] = code
			cbf[buttId] = parseCBF(code, buttId)
			output = ""
			updatePanel()
			throwError(CC_NOTIFICATION_SAVED) // Saved!

			windowCall("saveCodeCallback")

		if("executeCode")
			var/buttId = validateButtId(href_list["id"])
			if(!buttId)
				return
			//var/code = buttons[buttId]
			//boutput(world, "Executing CBF code: '[code]'")
			if(islist(cbf[buttId]))
				runCBF(cbf[buttId])

		if("reportError")
			var/errorMessage = href_list["message"]
			CRASH("Error reported from chemicompiler frontend: [errorMessage]")
		else

/*	attack_self(mob/user as mob)
		panel()*/

/** Callbacks */
/datum/chemicompiler_core/proc/topicPermissionCheck(action)
	if(!istype(src.holder))
		del(src)
		return
	if(topicPermissionCheckCallback)
		return call(src.holder, topicPermissionCheckCallback)(action)

/datum/chemicompiler_core/proc/showMessage(message)
	if(!istype(src.holder))
		del(src)
		return
	message = "<span class='alert'>[message]</span>"
	if(messageCallback)
		return call(src.holder, messageCallback)(message)

/datum/chemicompiler_core/proc/throwError(errorCode)
	if(!istype(src.holder))
		del(src)
		return
	if(errorCallback)
		return call(src.holder, errorCallback)(errorCode)

/datum/chemicompiler_core/proc/reservoirClick(resId)
	if(!istype(src.holder))
		del(src)
		return
	if(reservoirClickCallback)
		return call(src.holder, reservoirClickCallback)(resId)

/datum/chemicompiler_core/proc/reservoirCheck(resId)
	if(!istype(src.holder))
		del(src)
		return
	if (reservoirCheckCallback)
		return call(src.holder, reservoirCheckCallback)(resId)

/datum/chemicompiler_core/proc/transfer(source, target, amount)
	if(!istype(src.holder))
		del(src)
		return
	if (transferCallback)
		return call(src.holder, transferCallback)(source, target, amount)

/datum/chemicompiler_core/proc/isolate(source, target, amount, index)
	if(!istype(src.holder))
		del(src)
		return
	if (isolateCallback)
		return call(src.holder, isolateCallback)(source, target, amount, index)

/datum/chemicompiler_core/proc/heat(res, temp)
	if(!istype(src.holder))
		del(src)
		return
	if (heatCallback)
		var/datum/chemicompiler_executor/E = src.holder
		if ( !src.is_heating )
			showMessage("[E.holder] clicks.") // Relay kicking on
			src.is_heating = 1
		. = call(src.holder, heatCallback)(res, temp)
		if ( !. )
			src.is_heating = 0
			showMessage("[E.holder] clicks.") // Relay kicking off
		else
			ip-- //repeat the heat command until it succeeds


/datum/chemicompiler_core/proc/statusChange(oldStatus, newStatus)
	if(!istype(src.holder))
		del(src)
		return
	return call(src.holder, "statusChange")(oldStatus, newStatus)

/datum/chemicompiler_core/proc/validateButtId(var/id as text)
	var/buttId = text2num(id)
	if(buttId < 1 || buttId > 6)
		return 0
	return buttId

/datum/chemicompiler_core/proc/getReservoirStatuses()
	var/list/ret[maxReservoir]
	for(var/i=minReservoir,i<=maxReservoir,i++)
		ret[i] = reservoirCheck(i)
	return ret

/datum/chemicompiler_core/proc/windowCall(var/function, var/data = null)
	//boutput(world, "calling window func [function] with data: '[url_encode(data)]'")
	usr << output(data, "chemicompiler.browser:[function]")

/datum/chemicompiler_core/proc/updatePanel()
	var json = "{\"reservoirs\":\[null"
	var/i
	var/list/reservoirs = getReservoirStatuses()
	for(i = minReservoir,i<=maxReservoir,i++)
		json += ",[!isnull(reservoirs[i])? "true" : "false"]"
	json += "],\"buttons\":\[null"
	for(i = 1,i <= 6, i++)
		json += ",[!isnull(buttons[i])? "true" : "false"]"
	json += "], \"output\": \"[url_encode(output)]\","
	json += "\"sx\":\"[sx]\","
	json += "\"tx\":\"[tx]\","
	json += "\"ax\":\"[ax]\""
	json += "}"
	windowCall("setUIState", json)

/datum/chemicompiler_core/proc/parseCBF(var/string, var/button)
	var/list/tokens = list(">", "<", "+", "-", ".",",", "\[", "]", "{", "}", "(", ")", "^", "'", "$", "@","#")
	var/l = length(string)
	var/list/inst = new
	var/token

	for(var/i = 1, i <= l, i++)
		token = copytext(string, i, i+1)
		if(tokens.Find(token))
			inst.Add(token)

		// ~ means don't allow reading the source code
		if(token == "~")
			buttons[button] = 0

	. = inst

/datum/chemicompiler_core/proc/resetVM()
	dp = 0; // data pointer
	data = list(0) // data
	ip = 1; // instruction pointer

	//Registers
	sx = 0 // Source register
	tx = 0 // Target register
	ax = 0 // Amount register

	textBuffer = ""
	count = 0
	exec = 0;

/datum/chemicompiler_core/proc/runCBF(var/list/inst)
	if(!istype(src.holder))
		del(src)
		return
	resetVM()
	running = 1
	statusChange(CC_STATUS_RUNNING)
	currentProg = inst

/datum/chemicompiler_core/proc/on_process()
	if ( !running || !currentProg )
		return
	if(!istype(src.holder))
		del(src)
		return
	if(running)
		var/loopUsed
		for (loopUsed = 0, loopUsed < 30, loopUsed++)
			if(ip > currentProg.len)
				running = 0
				break
			//LAGCHECK(LAG_MED)
			exec++
			if(exec > 50000)
				throwError(CC_ERROR_INSTRUCTION_LIMIT) // Instruction limit reached.
				running = 0
				break
			switch(currentProg[ip++])
				if(">") //inrement pointer
					dp++
					if(dp > 1023) // RAM limit is 1024 bytes.
						dp = 0
				if("<") //decrement pointer
					dp--
					if(dp < 0) // RAM limit is 1024 bytes.
						dp = 1023
				if("+") //increment value at pointer
					data[dp + 1]++
				if("-") //decrement value at pointer
					data[dp + 1]--
				if(".") //buffer text
					textBuffer += ascii2text(data[dp+1])
					loopUsed += 19
				if(",") //load volume of sx into ax
					loopUsed += 9
					var/datum/chemicompiler_executor/E = src.holder
					ax = E.reagent_volume(sx)
				if("\[") //start loop
					if(data[dp + 1] == 0)
						count = 1
						while(ip <= currentProg.len && count > 0)
							if(currentProg[ip] == "\[")
								count++
							if(currentProg[ip] == "]")
								count--
							ip++
				if("]") //end loop
					loopUsed += 9
					if(data[dp + 1] != 0)
						count = 1
						ip--
						while(ip > 1 && count > 0)
							ip--
							if(currentProg[ip] == "\[")
								count--
							if(currentProg[ip] == "]")
								count++
						if(ip == 1 && count > 0)
							return //failed to find matching brace...
				if("{")
					data[dp + 1] = sx
				if("}")
					sx = data[dp + 1]
				if("(")
					data[dp + 1] = tx
				if(")")
					tx = data[dp + 1]
				if("^")
					data[dp + 1] = ax
				if("'")
					ax = data[dp + 1]
				if("$") //heat
					loopUsed = 30
					var/heatTo = (273 - tx) + ax
					heatReagents(sx, heatTo)
				if("@") //transfer
					loopUsed = 30
					transferReagents(sx, tx, ax)
				/*if("?") //compare *ptr to sx, using operation tx, store result in ax
					switch(tx)
						if(0) // =
							ax = (data[dp+1] == sx)
						if(1) // !=
							ax = (data[dp+1] != sx)
						if(2) // <
							ax = (data[dp+1] < sx)
						if(3) // <=
							ax = (data[dp+1] <= sx)
						if(4) // >
							ax = (data[dp+1] > sx)
						if(5) // >=
							ax = (data[dp+1] >= sx)
						else
							ax = 0*/
				if("#") //move individual reagent from container
					loopUsed = 30
					isolateReagent(sx, tx, ax, data[dp+1])
				else

			if(data.len < dp + 1)
				data.len = dp + 1
			if(length(textBuffer) > 80)
				output += "[textBuffer]<br>"
				textBuffer = ""
				updatePanel()

			/*if(exec % 100 == 0) //NO RECURSION. NO.
				SPAWN_DBG(0)
					resumeCBF()
				break
			*/
	if(!running)
		output += textBuffer
		updatePanel()
		statusChange(CC_STATUS_IDLE)
		throwError(CC_NOTIFICATION_COMPLETE)

/datum/chemicompiler_core/proc/transferReagents(var/source, var/target, var/amount)
	if(source < minReservoir || source > maxReservoir)
		throwError(CC_ERROR_INVALID_SX) // Invalid source id.
		return
	if(target < minReservoir || target > maxReservoir + 3)
		throwError(CC_ERROR_INVALID_TX) // Invalid target id.
		return
	if(!reservoirCheck(source))
		throwError(CC_ERROR_INVALID_CONTAINER_SX) // No reservoir loaded in source
		return
	if(target <= maxReservoir && !reservoirCheck(target))
		throwError(CC_ERROR_INVALID_CONTAINER_TX) // No reservoir loaded in target
		return

	transfer(source, target, amount)

/datum/chemicompiler_core/proc/isolateReagent(var/source, var/target, var/amount, index)
	if(source < minReservoir || source > maxReservoir)
		throwError(CC_ERROR_INVALID_SX) // Invalid source id.
		return
	if(target < minReservoir || target > maxReservoir + 3)
		throwError(CC_ERROR_INVALID_TX) // Invalid target id.
		return
	if(!reservoirCheck(source))
		throwError(CC_ERROR_INVALID_CONTAINER_SX) // No reservoir loaded in source
		return
	if(target <= maxReservoir && !reservoirCheck(target))
		throwError(CC_ERROR_INVALID_CONTAINER_TX) // No reservoir loaded in target
		return

	isolate(source, target, amount, index)

/datum/chemicompiler_core/proc/heatReagents(var/rid, var/temp)
	if(rid < minReservoir || rid > maxReservoir)
		throwError(CC_ERROR_INVALID_SX) // Invalid reservoir id
		return
	if(!reservoirCheck(rid))
		throwError(CC_ERROR_INVALID_CONTAINER_SX) // No reservoir loaded in specified position
		return
	if(temp < 1 || temp > 9000) //lol you wacky fuck
		throwError(CC_ERROR_INVALID_TEMPERATURE) // Invalid temperature value
		return

	heat(rid, temp)

/datum/chemicompiler_core/proc/panel()
	set background = 1

	// HTML is built only once, via New() -- all subsequent updates are done using javascript. Slick.
	usr.Browse(html, "window=chemicompiler;size=420x600")

/datum/chemicompiler_core/proc/initHtml()
	set background = 1
	var/i
	htmlTag = new

	var/datum/tag/script/controlscr = new
	controlscr.setContent( {"
	var ref = '\ref[src]';
	"})
	htmlTag.addToHead(controlscr)

	var/datum/tag/heading/h = new(1)
	h.setText("ChemiCompiler")
	h.setStyle("color", "#F3F1FC")
	h.setStyle("padding", "10px")
	h.setStyle("border-bottom", "3px solid #243030")
	h.setStyle("border-right", "2px solid #243030")
	htmlTag.addToBody(h)

	var/datum/tag/div/dataDiv = new
	dataDiv.setId("data")
	htmlTag.addToBody(dataDiv)

	var/datum/tag/div/codeDiv = new
	codeDiv.setId("code-container")
	htmlTag.addToBody(codeDiv)
	var/datum/tag/textarea/codeInput = new
	codeInput.setId("code-input")
	codeDiv.addChildElement(codeInput)

	var/datum/tag/div/container = new
	container.addClass("container-fluid")
	htmlTag.addToBody(container)
	var/datum/tag/div/row = new
	row.addClass("row-fluid")
	container.addChildElement(row)

	var/datum/tag/button/butt_load = new
	var/datum/tag/button/butt_save = new
	butt_load.setText("load")
	butt_save.setText("save")
	butt_load.setId("butt-load")
	butt_save.setId("butt-save")
	butt_load.addClass("btn btn-primary btn-sl")
	butt_save.addClass("btn btn-danger btn-sl")
	row.addChildElement(butt_load)
	row.addChildElement(butt_save)

	row = new
	row.addClass("row-fluid")
	container.addChildElement(row)

	// lol butts
	var/datum/tag/button/butt
	for(i=1,i<=6,i++)
		butt = new
		butt.setText(i)
		butt.setId("butt-[i]")
		butt.addClass("btn btn-default btn-c")
		butt.setAttribute("data-btn-id", i)
		row.addChildElement(butt)

	row = new
	row.addClass("row-fluid")
	container.addChildElement(row)
	var/datum/tag/button/resBtn
	for(i=minReservoir,i<=maxReservoir,i++)
		resBtn = new
		resBtn.setText("r[i]")
		resBtn.setId("reservoir-[i]")
		resBtn.addClass("btn reservoir-button")
		resBtn.setAttribute("data-id", i)
		row.addChildElement(resBtn)

		if(i % 5 == 0)
			row = new
			row.addClass("row-fluid")
			container.addChildElement(row)

	row = new
	row.addClass("row-fluid")
	container.addChildElement(row)
	var/datum/tag/label/sxLabel = new
	var/datum/tag/label/txLabel = new
	var/datum/tag/label/axLabel = new
	sxLabel.setText("sx ")
	txLabel.setText("tx ")
	axLabel.setText("ax ")
	var/datum/tag/input/sx = new
	var/datum/tag/input/tx = new
	var/datum/tag/input/ax = new
	sxLabel.addChildElement(sx)
	txLabel.addChildElement(tx)
	axLabel.addChildElement(ax)
	sx.setId("sx-input")
	tx.setId("tx-input")
	ax.setId("ax-input")
	sx.setAttribute("onfocus", "$(this).blur()")
	tx.setAttribute("onfocus", "$(this).blur()")
	ax.setAttribute("onfocus", "$(this).blur()")
	row.addChildElement(sxLabel)
	row.addChildElement(txLabel)
	row.addChildElement(axLabel)

	var/datum/tag/cssinclude/bootstrap = new
	bootstrap.setHref(resource("css/bootstrap.min.css"))
	htmlTag.addToHead(bootstrap)

	var/datum/tag/cssinclude/chemicss = new
	chemicss.setHref(resource("css/chemicompiler.css"))
	htmlTag.addToHead(chemicss)

	var/datum/tag/scriptinclude/json2 = new
	json2.setSrc(resource("js/json2.min.js"))
	htmlTag.addToHead(json2)

	var/datum/tag/scriptinclude/jquery = new
	jquery.setSrc(resource("js/jquery.min.js"))
	htmlTag.addToHead(jquery)

	var/datum/tag/scriptinclude/jqueryMigrate = new
	jqueryMigrate.setSrc(resource("js/jquery.migrate.js"))
	htmlTag.addToHead(jqueryMigrate)

	var/datum/tag/scriptinclude/bootstrapJs = new
	bootstrapJs.setSrc(resource("js/bootstrap.min.js"))
	htmlTag.addToBody(bootstrapJs)

	var/datum/tag/scriptinclude/chemicompilerJs = new
	chemicompilerJs.setSrc(resource("js/chemicompiler.js"))
	htmlTag.addToBody(chemicompilerJs)

	//var/datum/tag/firebug/fb = new
	//htmlTag.addToBody(fb)

	html = htmlTag.toHtml()

/datum/chemicompiler_core/testCore
	errorCallback = "err"
	transferCallback = "transfer"
	heatCallback = "heat"
	messageCallback = "msg"
	reservoirClickCallback = "reservoirClick"
	reservoirCheckCallback = "reservoirCheck"
	topicPermissionCheckCallback = "topicPermissionCheck"

/datum/testChemicompilerHolder
	var/datum/chemicompiler_core/cc

	New()
		..()
		cc = new /datum/chemicompiler_core/testCore(src)
	proc
		err(errorCode)
			var/errorMessage = interpretError(errorCode)
			boutput(world, "Chemicompiler error: [errorCode]; [errorMessage]")
		interpretError(errorCode)
			switch(errorCode)
				if(CC_ERROR_INVALID_SX)
					return "Error: invalid source reservor id."
				if(CC_ERROR_INVALID_TX)
					return "Error: invalid target reservoir id."
				if(CC_ERROR_INVALID_CONTAINER_SX)
					return "Error: invalid or missing container in source reservoir slot."
				if(CC_ERROR_INVALID_CONTAINER_TX)
					return "Error: invalid or missing container in target reservoir slot."
				if(CC_ERROR_INVALID_TEMPERATURE)
					return "Error: Invalid temperature passed to heat proc."
				if(CC_ERROR_CODE_PROTECTED)
					return "Error: code protected - cannot retrieve."
				if(CC_ERROR_INSTRUCTION_LIMIT)
					return "Error: instruction limit reached."
				if(CC_NOTIFICATION_COMPLETE)
					return "Notification: program complete."
				if(CC_NOTIFICATION_SAVED)
					return "Notification: code saved."
				else
					return "Unknown error code: [errorCode]"

		transfer(source, target, amount)
			boutput(world, "Chemicompiler transfer [amount] units from [source] to [target]")
		heat(rid, temp)
			boutput(world, "Chemicompiler heat [rid] to [temp]K")
		msg(message)
			boutput(world, message)
		reservoirClick(rid)
			boutput(world, "Clicked reservoir #[rid]")
		reservoirCheck(rid)
			boutput(world, "Checked existence for reservoir #[rid]")
			return 1
		topicPermissionCheck(action)
			boutput(world, "Topic permission check for \ref[usr], [action]")
			return 1

/datum/chemicompiler_executor
	var/list/reservoirs = list()
	var/datum/holder
	var/datum/chemicompiler_core/core

/datum/chemicompiler_executor/New(datum/holder, corePath = /datum/chemicompiler_core/portableCore)
	..()
	if(!istype(holder))
		del(src)
		return

	src.holder = holder
	src.core = new corePath(src)
	src.reservoirs.len = src.core.maxReservoir

	for(var/i=src.core.minReservoir,i<=src.core.maxReservoir,i++)
		reservoirs[i] = null

/datum/chemicompiler_executor/proc/panel()
	core.panel()

/datum/chemicompiler_executor/proc/err(errorCode)
	switch(errorCode)
		if(CC_ERROR_INVALID_SX)
			beepCode(1, 1)
		if(CC_ERROR_INVALID_TX)
			beepCode(1, 1)
		if(CC_ERROR_INVALID_CONTAINER_SX)
			beepCode(3, 1)
		if(CC_ERROR_INVALID_CONTAINER_TX)
			beepCode(3, 1)
		if(CC_ERROR_INVALID_TEMPERATURE)
			beepCode(4, 1)
		if(CC_ERROR_CODE_PROTECTED)
			beepCode(5, 1)
		if(CC_ERROR_INSTRUCTION_LIMIT)
			beepCode(2, 1)
		if(CC_NOTIFICATION_COMPLETE)
			beepCode(1)
		if(CC_NOTIFICATION_SAVED)
			beepCode(2)
		else

/datum/chemicompiler_executor/proc/on_process()
	if ( !src.core )
		return
	return src.core.on_process()

/datum/chemicompiler_executor/proc/reservoirCheck(resId)
	if(istype(reservoirs[resId], /obj/item/reagent_containers/glass))
		return 1
/datum/chemicompiler_executor/proc/reservoirClick(resId)
	if(!istype(src.holder))
		del(src)
		return
	if(istype(reservoirs[resId], /obj/item/reagent_containers/glass))
		// Taking a res out
		if(!usr.equipped())
			boutput(usr, "<span class='notice'>You remove the [reservoirs[resId]] from the [src.holder].</span>")
			usr.put_in_hand_or_drop(reservoirs[resId])
			reservoirs[resId] = null
		else
			var/obj/item/reagent_containers/glass/B = reservoirs[resId]
			B.attackby(usr.equipped(), usr)

	else
		// Putting SOMETHING in
		var/obj/item/I = usr.equipped()
		if(istype(I, /obj/item/reagent_containers/glass))
			//putting a reagent container in
			boutput(usr, "<span class='notice'>You place the [I] into the [src.holder].</span>")
			usr.drop_item()
			I.set_loc(holder)
			reservoirs[resId] = I

/datum/chemicompiler_executor/proc/topicPermissionCheck(action)
	if(!istype(src.holder))
		del(src)
		return
	return call(src.holder, "topicPermissionCheck")(action)

/**
 * beep codes
 * loud:
 *  1: Invalid sx or tx value
 *  2: Instruction limit reached
 *  3: No container loaded at source or target
 *  4: Invalid temperature value
 *  5: Code is protected, cannot load
 * soft:
 *  1: done executing
 *  2: code saved
 */
/datum/chemicompiler_executor/proc/beepCode(var/number = 1, var/loud = 0)
	var/how = loud ? "loudly" : "quietly"
	var/howmany = number == 1 ? "once" : "[number] times"
	var/message = "[src.holder] beeps [how] [howmany]."
	showMessage(message)

/datum/chemicompiler_executor/proc/showMessage(message)
	if(!istype(holder))
		del(src)
		return
	message = "<span class='alert'>[message]</span>"
	if(istype(holder:loc, /mob))
		boutput(holder:loc, message)
	else
		holder:visible_message(message)


/datum/chemicompiler_executor/proc/isolateReagent(var/source, var/target, var/amount, index)
	if(!istype(src.holder))
		del(src)
		return
	if(source < 1 || source > 10 || target < 1 || target > 13)
		beepCode(1, 1) // Invalid source or target id.
		return
	if(!istype(reservoirs[source], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in source or target
		return
	if(target < 11 && !istype(reservoirs[target], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in source or target
		return

	showMessage("[src.holder] emits a slight humming sound.")

	var/obj/item/reagent_containers/holder = reservoirs[source]
	var/datum/reagents/RS = holder.reagents

	if(target < 11)
		var/obj/RT = reservoirs[target]
		RS.trans_to(RT, amount, 1 , 1, index)
	if (target == 11)
		// Generate pill
		showMessage("[src.holder] makes an alarming grinding noise!")
		var/obj/item/reagent_containers/pill/P = new(get_turf(src.holder))
		RS.trans_to(P, amount, 1 , 1, index)
		showMessage("[src.holder] ejects a pill.")
	if (target == 12)
		// Generate vial
		var/obj/item/reagent_containers/glass/vial/V = new(get_turf(src.holder))
		RS.trans_to(V, amount, 1 , 1, index)
		showMessage("[src.holder] ejects a vial of some unknown substance.")
	if (target == 13)
		RS.trans_to(get_turf(src.holder), amount, 1 , 1, index)
		showMessage("Something drips out the side of [src.holder].")

/datum/chemicompiler_executor/proc/transferReagents(var/source, var/target, var/amount)
	if(!istype(src.holder))
		del(src)
		return
	if(source < 1 || source > 10 || target < 1 || target > 13)
		beepCode(1, 1) // Invalid source or target id.
		return
	if(!istype(reservoirs[source], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in source or target
		return
	if(target < 11 && !istype(reservoirs[target], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in source or target
		return

	showMessage("[src.holder] emits a slight humming sound.")
	var/obj/item/reagent_containers/holder = reservoirs[source]
	var/datum/reagents/RS = holder.reagents

	if(target < 11)
		var/obj/RT = reservoirs[target]
		RS.trans_to(RT, amount)
	if (target == 11)
		// Generate pill
		showMessage("[src.holder] makes an alarming grinding noise!")
		var/obj/item/reagent_containers/pill/P = new(get_turf(src.holder))
		RS.trans_to(P, amount)
		showMessage("[src.holder] ejects a pill.")
	if (target == 12)
		// Generate vial
		var/obj/item/reagent_containers/glass/vial/V = new(get_turf(src.holder))
		RS.trans_to(V, amount)
		showMessage("[src.holder] ejects a vial of some unknown substance.")
	if (target == 13)
		RS.trans_to(get_turf(src.holder), amount)
		showMessage("Something drips out the side of [src.holder].")

/datum/chemicompiler_executor/proc/heatReagents(var/rid, var/temp)
	if(!istype(src.holder))
		del(src)
		return
	if(rid < 1 || rid > 10)
		beepCode(1, 1) // Invalid reservoir id
		return
	if(!istype(reservoirs[rid], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in specified position
		return
	if(temp < 1 || temp > 9000) //lol you wacky fuck
		beepCode(4, 1) // Invalid temperature value
		return

	// Ok now heat this bitch
	var/obj/item/reagent_containers/holder = reservoirs[rid]
	var/datum/reagents/R = holder.reagents
	var/heating_in_progress = 1
	//while(R.total_volume && heating_in_progress)

	//heater settings
	var/h_exposed_volume = 10
	var/h_divisor = 10
	var/h_change_cap = 25

	var/element_temp = R.total_temperature < temp ? 9000 : 0												//Sidewinder7: Smart heating system. Allows the CC to heat at full power for more of the duration, and prevents reheating of reacted elements.
	var/max_temp_change = abs(R.total_temperature - temp)
	var/next_temp_change = min(max((abs(R.total_temperature - element_temp) / h_divisor), 1), h_change_cap)	// Formula used by temperature_reagents() to determine how much to change the temp
	if(next_temp_change >= max_temp_change)																	// Check if this tick will cause the temperature to overshoot if heated/cooled at full power. Use >= to prevent reheating in the case the values line up perfectly
		var/element_temp_offset = max_temp_change * h_divisor												// Compute the exact exposure temperature to reach the target
		element_temp = R.total_temperature + element_temp_offset * (temp > R.total_temperature ? 1 : -1)
		heating_in_progress = 0

	R.temperature_reagents(element_temp, h_exposed_volume, h_divisor, h_change_cap)

	return heating_in_progress

/datum/chemicompiler_executor/proc/statusChange(oldStatus, newStatus)
	if(!istype(src.holder))
		del(src)
		return
	if (core.statusChangeCallback)
		return call(holder, core.statusChangeCallback)(oldStatus, newStatus)

/datum/chemicompiler_executor/proc/reagent_volume(rid)
	if(!istype(src.holder))
		del(src)
		return
	if(rid < 1 || rid > 10)
		beepCode(1, 1) // Invalid reservoir id
		return 0
	if(!istype(reservoirs[rid], /obj/item/reagent_containers/glass))
		beepCode(3, 1) // No reservoir loaded in specified position
		return 0
	var/obj/item/reagent_containers/holder = reservoirs[rid]
	return holder.reagents.total_volume
