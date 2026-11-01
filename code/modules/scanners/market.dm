TYPEINFO(/obj/item/device/appraisal)
	mats = 5

/obj/item/device/appraisal
	name = "cargo appraiser"
	desc = "Handheld scanner hooked up to Cargo's market computers. Estimates sale value of various items."
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	m_amt = 150
	icon_state = "CargoA"
	item_state = "accessgun"

	var/last_scan_name = null
	var/last_scan_text = null
	var/last_scan_value = null
	var/last_scan_timestamp = null

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		return

	attack_self(mob/user)
		if (isnull(src.last_scan_value))
			boutput(user, SPAN_NOTICE("No previous scan results located."))
			return
		src.print_receipt(user)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0)
			return

		var/datum/artifact/art = null
		var/obj/O = A
		if (isobj(A))
			art = O.artifact
		else
			// objs only
			return

		var/sell_value = 0
		var/out_text = ""
		if (art)
			var/obj/item/sticker/postit/artifact_paper/pap = locate(/obj/item/sticker/postit/artifact_paper/) in O.vis_contents
			if (pap?.artifactType)
				out_text = "<strong>The following values depend on correct analysis of the artifact<br>Average price for [pap.artifactType] type artifacts</strong><br>"
				// the unrandomized sell value for an artifact of the type detailed on the form, with perfect analysis
				sell_value = shippingmarket.calculate_artifact_price(artifact_controls.artifact_types_from_name[pap.artifactType].get_rarity_modifier(), 3)
				sell_value = round(sell_value, 5)
			else if (pap)
				boutput(user, SPAN_ALERT("Attached Analysis Form&trade; needs to be filled out!"))
				return
			else
				boutput(user, SPAN_ALERT("Artifact appraisal is only possible via an attached Analysis Form&trade;!"))
				return

		else if (istype(A, /obj/storage/crate))
			sell_value = -1
			var/obj/storage/crate/C = A
			if (C.delivery_destination)
				for (var/datum/trader/T in shippingmarket.active_traders)
					if (T.crate_tag == C.delivery_destination)
						sell_value = shippingmarket.appraise_value(C.contents, T.goods_buy, sell = 0)
						out_text = "<strong>Prices from [T.name]</strong><br>"
				for (var/datum/req_contract/RC in shippingmarket.req_contracts)
					if(C.delivery_destination == "REQ_THIRDPARTY")
						out_text = "<strong>Cannot evaluate third-party sales.</strong><br>"
					else if (RC.req_code == C.delivery_destination)
						var/evaluated = RC.requisify(C,TRUE)
						if(evaluated == "Contents sufficient for marked requisition.")
							sell_value = RC.payout
						out_text = "<strong>[evaluated]</strong><br>"

			if (sell_value == -1)
				// no trader on the crate
				sell_value = shippingmarket.appraise_value(A.contents, sell = 0)

		else if (istype(A, /obj/storage))
			var/obj/storage/S = A
			if (S.welded)
				// you cant do this
				boutput(user, SPAN_ALERT("\The [A] is welded shut and can't be scanned."))
				return
			if (S.locked)
				// you cant do this either
				boutput(user, SPAN_ALERT("\The [A] is locked closed and can't be scanned."))
				return

			out_text = "[SPAN_ALERT("Contents must be placed in a crate to be sold!")]<br>"
			sell_value = shippingmarket.appraise_value(S.contents, sell = 0)

		else if (istype(A, /obj/item/satchel))
			out_text = "[SPAN_ALERT("Contents must be placed in a crate to be sold!")]<br>"
			sell_value = shippingmarket.appraise_value(A.contents, sell = 0)

		else if (istype(A, /obj/item))
			sell_value = shippingmarket.appraise_value(list( A ), sell = 0)

		// replace with boutput
		boutput(user, SPAN_NOTICE("[out_text]Estimated value: <strong>[sell_value] credit\s.</strong>"))
		if (sell_value > 0)
			src.last_scan_text = out_text
			src.last_scan_value = sell_value
			src.last_scan_name = A.name
			src.last_scan_timestamp = time2text(world.timeofday, "DD MMM [CURRENT_SPACE_YEAR], hh:mm:ss")
			playsound(src, 'sound/machines/chime.ogg', 10, TRUE)

		DISPLAY_MAPTEXT(A, list(user), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/appraisal, sell_value)

	proc/print_receipt(mob/user)
		if (!src.last_scan_value)
			boutput(user, SPAN_ALERT("\The [src] has nothing to print — scan something first!"))
			return
		if (!ON_COOLDOWN(src, "print_receipt", 4 SECONDS))
			var/receipt_text = {"
			<span style="text-transform:uppercase;font-family:Monospace;">
				<table>
					<tbody>
					<tr>
						<td colspan="2" style="text-align:center">*-----MARKET APPRAISAL RECEIPT-----*</td>
					</tr>
					<tr>
						<td>Item</td>
						<td style="text-align:right">[src.last_scan_name]</td>
					</tr>
					<tr>
						<td>Value</td>
						<td style="text-align:right">[src.last_scan_value][CREDIT_SIGN]</td>
					</tr>
					<tr>
						<td>Taken At</td>
						<td style="text-align:right">[src.last_scan_timestamp]</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align:center">*-------------- NOTES -------------*</td>
					</tr>
					<tr>
						<td colspan="2">[src.last_scan_text ? src.last_scan_text : "N/A"]</td>
					</tr>
					</tbody>
				</table>
			</span>
			"}

			var/obj/item/paper/P = new /obj/item/paper/thermal(user.loc)
			P.name = "appraisal receipt"
			P.info = receipt_text
			user.put_in_hand_or_eject(P)
			playsound(src, 'sound/machines/printer_thermal.ogg', 25, TRUE)
