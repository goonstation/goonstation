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
			src.ClearSpecificOverlays("disks_[i]")
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
	var/list/disk_data[MAX_DISKS]
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (disk)
			disk_data[i] = list("name" = disk.name, "color" = disk.disk_color)
	return list("disks" = disk_data)

/obj/machinery/disk_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .
	if (action == "action")
		var/index = text2num_safe(params["id"])
		if (index < 1 || index > MAX_DISKS) //nu
			return FALSE
		if (src.disks[index])
			src.remove_disk(index, ui.user)
			return TRUE
		var/obj/item/disk/data/floppy/disk = ui.user.equipped()
		if (!istype(disk))
			return FALSE
		src.insert_disk(index, disk, ui.user)
		return TRUE

/obj/machinery/disk_rack/proc/remove_disk(index, mob/user)
	user.put_in_hand_or_drop(src.disks[index])
	src.disks[index] = null
	playsound(src, 'sound/machines/law_insert.ogg', 60) //TODO: distinct sound for smaller disks?
	src.UpdateIcon()

/obj/machinery/disk_rack/proc/insert_disk(index, obj/item/disk/data/floppy/disk, mob/user)
	src.disks[index] = disk
	user.drop_item(disk)
	disk.set_loc(src)
	playsound(src, 'sound/machines/law_insert.ogg', 60) //TODO: distinct sound for smaller disks?
	src.UpdateIcon()

/obj/machinery/disk_rack/attackby(obj/item/disk/data/floppy/disk, mob/user)
	if (istype(disk))
		for (var/i in 1 to MAX_DISKS)
			if (src.disks[i])
				continue
			src.insert_disk(i, disk, user)
			return
	. = ..()

/obj/machinery/disk_rack/clone
	name = "clone rack"
	desc = "A big clunky rack for storing cloning records in."

#define LIGHT_KEY "angry_light_[i]"

/obj/machinery/disk_rack/clone/process(mult)
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
