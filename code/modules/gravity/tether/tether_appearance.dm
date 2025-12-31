/obj/machinery/gravity_tether/update_icon()
	var/list/ma_overlays = src.MA.overlays
	ma_overlays.Cut()

	ma_overlays += src.ma_graviton

	if (door_state == TETHER_DOOR_OPEN || door_state == TETHER_DOOR_MISSING)
		if (src.cell)
			ma_overlays += src.ma_cell
		else // hidden by battery
			ma_overlays += src.ma_wires
		// lays on top and has transparency
		ma_overlays += src.ma_tamper

	if (src.has_no_power())
		if (door_state != TETHER_DOOR_MISSING)
			ma_overlays += src.ma_door
		src.update_light()
		src.UpdateOverlays(MA, "overlays", force=TRUE)
		return

	ma_overlays += src.ma_graph
	ma_overlays += src.ma_screen
	ma_overlays += src.ma_bat
	ma_overlays += src.ma_status
	ma_overlays += src.ma_intensity
	ma_overlays += src.ma_dials

	// open door clips other overlays, set it last
	if (door_state != TETHER_DOOR_MISSING)
		ma_overlays += src.ma_door

	src.update_light()
	src.overlays = MA.overlays

/obj/machinery/gravity_tether/proc/update_light()
	if (src.has_no_power())
		src.light.disable()
	var/new_r = 0.4
	var/new_b = 0.4
	var/new_g = 0.1

	switch(src.charge_pct_state)
		if (TETHER_BATTERY_CHARGE_LOW)
			new_r += 0.2
		if (TETHER_BATTERY_CHARGE_MEDIUM)
			new_r += 0.1
			new_g += 0.1
		if (TETHER_BATTERY_CHARGE_HIGH)
			new_g += 0.2
		if (TETHER_BATTERY_CHARGE_FULL)
			new_b += 0.1
			new_g += 0.1
	if (src.gforce_intensity > 1.5)
		new_r += 0.2
	if (src.gforce_intensity > 1)
		new_r += 0.1
		new_g += 0.1
	if (src.gforce_intensity > 0.5)
		new_g += 0.2
	if (src.gforce_intensity > 0)
		new_b += 0.2

	if (src.is_broken())
		new_r += 0.2
		new_b += 0.1

	src.light.set_color(new_r, new_g, new_b)
	src.light.enable()

/obj/machinery/gravity_tether/proc/update_ma_screen()
	if (src.processing_state != TETHER_PROCESSING_STABLE)
		src.ma_screen.icon_state = "screen-cooldown"
	else if (src.status & BROKEN)
		src.ma_screen.icon_state = "screen-crash"
	else if (src.locked)
		src.ma_screen.icon_state = "screen-locked"
	else
		src.ma_screen.icon_state = "screen-unlocked"

/obj/machinery/gravity_tether/proc/update_ma_dials()
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		if (src.target_intensity > src.gforce_intensity)
			src.ma_dials.icon_state = "dials-spinup"
		else
			src.ma_dials.icon_state = "dials-spindown"
	else
		if (src.wire_state == TETHER_WIRES_CUT)
			src.ma_dials.icon_state = "dials-wild"
		else
			src.ma_dials.icon_state = "dials-regular"

/obj/machinery/gravity_tether/proc/update_ma_status()
	if (src.processing_state == TETHER_PROCESSING_PENDING)
		src.ma_status.icon_state = "status-processing"
	else if (src.status & BROKEN)
		src.ma_status.icon_state = "status-broken"
	else if (src.gforce_intensity > 0)
		src.ma_status.icon_state = "status-working"
	else
		src.ma_status.icon_state = "status-idle"

/obj/machinery/gravity_tether/proc/update_ma_bat()
	// TODO: Why the fuck can't we filter this?
	var/list/ma_overlays = src.ma_bat.overlays
	ma_overlays.Cut()
	if (!src.cell)
		src.ma_bat.icon_state = "battery-critical"
		return

	switch (src.charge_pct_state)
		if (TETHER_BATTERY_CHARGE_FULL to INFINITY)
			src.ma_bat.icon_state = "battery-full"
		if (TETHER_BATTERY_CHARGE_HIGH to TETHER_BATTERY_CHARGE_FULL)
			src.ma_bat.icon_state = "battery-high"
		if (TETHER_BATTERY_CHARGE_MEDIUM to TETHER_BATTERY_CHARGE_HIGH)
			src.ma_bat.icon_state = "battery-medium"
		if (-INFINITY to TETHER_BATTERY_CHARGE_MEDIUM)
			src.ma_bat.icon_state = "battery-low"

	switch(src.charging_state)
		if (TETHER_CHARGE_CHARGING)
			src.ma_bat_charge.icon_state = "mask-charging"
			ma_overlays += src.ma_bat_charge
		if (TETHER_CHARGE_DRAINING)
			src.ma_bat_charge.icon_state = "mask-draining"
			ma_overlays += src.ma_bat_charge

/obj/machinery/gravity_tether/proc/update_ma_graviton()
	if (src.has_no_power() || src.gforce_intensity <= 0.01)
		src.ma_graviton.icon_state = "graviton-idle"
	else if (src.status & BROKEN)
		src.ma_graviton.icon_state = "graviton-wonky"
	else
		src.ma_graviton.icon_state = "graviton-nominal"

/obj/machinery/gravity_tether/proc/update_ma_cell()
	if (!src.cell)
		return

	if (src.cell.artifact)
		src.ma_cell.icon_state = "apc-[src.cell.artifact.artiappear.name]"
	else
		src.ma_cell.icon_state = "apc-[src.cell.icon_state]"

	src.ma_cell.overlays.Cut()
	if (src.cell.charge < 0.01 || src.cell.specialicon)
		return

	if(src.cell.charge/src.cell.maxcharge >=0.995)
		src.ma_cell_charge.icon_state = "cell-o2"
	else
		src.ma_cell_charge.icon_state = "cell-o1"
	src.ma_cell.overlays += src.ma_cell_charge

/obj/machinery/gravity_tether/proc/update_ma_tamper()
	if (!src.locked)
		src.ma_tamper.icon_state = "tamper-raised"
	else
		if (src.tamper_intact)
			src.ma_tamper.icon_state = "tamper-secure"
		else
			src.ma_tamper.icon_state = "tamper-cut"

/obj/machinery/gravity_tether/proc/update_ma_graph()
	if (!(src.status & BROKEN))
		if (src.disturbed_end_time)
			src.ma_graph.icon_state = "graph-bad"
		else
			if (src.gforce_intensity > 0)
				src.ma_graph.icon_state = "graph-good"
			else
				src.ma_graph.icon_state = "graph-okay"

/obj/machinery/gravity_tether/proc/update_ma_door()
	switch (src.door_state)
		if (TETHER_DOOR_WELDED)
			src.ma_door.icon_state = "door-welded"
		if (TETHER_DOOR_CLOSED)
			src.ma_door.icon_state = "door-closed"
		if (TETHER_DOOR_OPEN)
			src.ma_door.icon_state = "door-open"

/obj/machinery/gravity_tether/proc/update_ma_wires()
	switch (src.wire_state)
		if (TETHER_WIRES_INTACT)
			src.ma_wires.icon_state = "wires-intact"
		if (TETHER_WIRES_BURNED)
			src.ma_wires.icon_state = "wires-burned"
		if (TETHER_WIRES_CUT)
			src.ma_wires.icon_state = "wires-cut"

/obj/machinery/gravity_tether/proc/update_ma_intensity()
	switch (src.gforce_intensity)
		if (1)
			src.ma_intensity.icon_state = "intensity-2"
		if (-INFINITY to 0)
			src.ma_intensity.icon_state = "intensity-0"
		if (0 to 0.5)
			src.ma_intensity.icon_state = "intensity-1"
		if (0.5 to 1)
			src.ma_intensity.icon_state = "intensity-2"
		if (1 to 1.5)
			src.ma_intensity.icon_state = "intensity-3"
		if (1.5 to INFINITY)
			src.ma_intensity.icon_state = "intensity-4"
