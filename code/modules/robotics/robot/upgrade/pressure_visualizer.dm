/obj/item/roboupgrade/pressure_visualizer
	name = "cyborg pressure visualizer upgrade"
	desc = "A sensing array that enables a cyborg to see atmospheric pressures."
	icon_state = "up-convis"
	drainrate = 5
	borg_overlay = "up-meson"

/obj/item/roboupgrade/pressure_visualizer/upgrade_activate(mob/living/silicon/robot/user)
	if (..())
		return
	user.AddComponent(/datum/component/pressure_vision, TRUE)

/obj/item/roboupgrade/pressure_visualizer/upgrade_deactivate(mob/living/silicon/robot/user)
	if (..())
		return
	user.RemoveComponentsOfType(/datum/component/pressure_vision)
