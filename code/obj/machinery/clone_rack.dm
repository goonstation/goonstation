#define MAX_DISKS 8
/obj/machinery/disk_rack
	name = "disk rack"
	desc = "A big clunky rack for storing floppy disks in."
	icon = 'icons/obj/clone_rack.dmi'
	icon_state = "clone_rack"
	density = TRUE
	anchored = ANCHORED
	var/list/obj/item/disk/data/floppy/disks[MAX_DISKS]

/obj/machinery/disk_rack/update_icon(...)
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk)
			continue
		var/image/overlay = image(src.icon, "disk_overlay")
		overlay.color = disk.disk_color
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, "disks_[i]")

/obj/machinery/disk_rack/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DiskRack")
		ui.open()

/obj/machinery/disk_rack/ui_data(mob/user)
	var/list/disk_names[MAX_DISKS]
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		disk_names[i] = disk?.name
	return list("disks" = disk_names)

/obj/machinery/disk_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	if (action == "action")
		var/index = text2num_safe(params["id"])
		if (index < 1 || index > MAX_DISKS) //nu
			return
		if (src.disks[index])
			ui.user.put_in_hand_or_drop(src.disks[index])
			src.disks[index] = null
			return TRUE


/obj/machinery/disk_rack/attackby(obj/item/disk/data/floppy/disk, mob/user)
	if (istype(disk))
		for (var/i in 1 to MAX_DISKS)
			if (src.disks[i])
				continue
			src.disks[i] = disk
			user.drop_item(disk)
			disk.set_loc(src)
			playsound(src, 'sound/machines/law_insert.ogg', 60) //TODO: distinct sound for smaller disks?
			src.UpdateIcon()
			return
	. = ..()

/obj/machinery/disk_rack/clone_rack
	name = "clone rack"
	desc = "A big clunky rack for storing cloning records in."

#define LIGHT_KEY "angry_light_[i]"

/obj/machinery/disk_rack/clone_rack/process(mult)
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk)
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		var/datum/computer/file/clone/cloneRecord = locate() in disk.root.contents
		if (!cloneRecord)
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		var/datum/mind/mind = cloneRecord.fields["mind"]
		var/mob/selected = mind?.current
		if (!selected || selected.mind?.get_player()?.dnr || !eligible_to_clone(mind))
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		if (src.GetOverlayImage(LIGHT_KEY))
			return
		var/image/overlay = image(src.icon, "angry_light")
		overlay.plane = PLANE_SELFILLUM
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, LIGHT_KEY)

#undef LIGHT_KEY
