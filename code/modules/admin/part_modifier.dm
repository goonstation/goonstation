
/datum/admins/var/datum/partmod_holder/part_modifier = null

var/list/default_organ_paths = list("head" = /obj/item/organ/head, "skull" = /obj/item/skull, "brain" = /obj/item/organ/brain, "left_eye" = /obj/item/organ/eye, "right_eye" = /obj/item/organ/eye, "chest" = /obj/item/organ/chest, "heart" = /obj/item/organ/heart, "left_lung" = /obj/item/organ/lung, "right_lung" = /obj/item/organ/lung, "butt" = /obj/item/clothing/head/butt, "liver" = /obj/item/organ/liver, "stomach" = /obj/item/organ/stomach, "intestines" = /obj/item/organ/intestines, "pancreas" = /obj/item/organ/pancreas, "spleen" = /obj/item/organ/spleen, "appendix" = /obj/item/organ/appendix, "left_kidney" = /obj/item/organ/kidney, "right_kidney" = /obj/item/organ/kidney, "tail" = /obj/item/organ/tail)
var/list/default_limb_paths = list("l_arm" = /obj/item/parts/human_parts/arm/left, "r_arm" = /obj/item/parts/human_parts/arm/right, "l_leg" = /obj/item/parts/human_parts/leg/left, "r_leg" = /obj/item/parts/human_parts/leg/right)

/client/proc/modify_parts(var/mob/living/carbon/human/target as mob)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!istype(target))
		return
	if (!target.limbs)
		boutput(src, "Mob limb holder is broken.")
		return
	if (!target.organHolder)
		boutput(src, "Mob organ holder is broken.")
		return

	if (!src.holder.part_modifier)
		src.holder.part_modifier = new

	src.holder.part_modifier.show_window(target, src)

/datum/partmod_holder
	Topic(href, href_list)
		..()
		if (!href_list["action"] || !usr)
			return
		USR_ADMIN_ONLY
		switch (href_list["action"])
// refresh
			if ("refresh")
				var/mob/living/carbon/human/H = locate(href_list["target"])
				if (!H)
					return
				src.show_window(H, usr)
// view vars
			if ("view_vars")
				if (!usr.client || !(usr.client.holder && usr.client.holder.level >= LEVEL_PA))
					boutput(usr, "Error: you must be a Primary Administrator or higher to view and edit vars.")
					return

				var/obj/O = locate(href_list["target"])
				if (!O)
					boutput(usr, "Error: invalid target.")
					return
				usr.client.debug_variables(O)
// sever limbs
			if ("sever_limb")
				var/datum/human_limbs/limbs = locate(href_list["target"])
				var/target_limb = href_list["part"]
				if (!limbs || !target_limb || !limbs.holder)
					boutput(usr, "Error: invalid target limb(s).")
					return
				if (limbs.sever(target_limb, usr)) // returns 1 when at least one limb is severed
					message_admins("[key_name(usr)] severed [key_name(limbs.holder)]'s limb(s): [uppertext(target_limb)]")
				src.show_window(limbs.holder, usr)
// replace limbs
			if ("replace_limb")
				var/datum/human_limbs/limbs = locate(href_list["target"])
				var/target_limb = href_list["part"]
				if (!limbs || !target_limb || !limbs.holder)
					boutput(usr, "Error: invalid target limb(s).")
					return

				var/new_type = get_one_match(input("Type path", "Type path", "[ispath(default_limb_paths[target_limb]) ? default_limb_paths[target_limb] : /obj/item/parts/human_parts]"), /obj)
				if (!new_type)
					return

				if (!ispath(new_type, /obj/item))
					if (!(usr.client && usr.client.holder && usr.client.holder.level >= LEVEL_PA))
						boutput(usr, "You need to be at least a Primary Admin to give people limbs that aren't /obj/item things!")
						return
					if (alert(usr, "Giving someone an arm that isn't an /obj/item WILL cause runtimes! Runtimes are bad! Be sure you want to do this!", "WARNING", "OK", "Cancel") == "Cancel")
						return

				if (limbs.replace_with(target_limb, new_type, usr)) // returns 1 or greater when at least one limb is replaced
					message_admins("[key_name(usr)] replaced [key_name(limbs.holder)]'s limb(s): [uppertext(target_limb)] (new type: [new_type])")
				src.show_window(limbs.holder, usr)
// replace all limbs
			if ("replace_all_limbs")
				var/datum/human_limbs/limbs = locate(href_list["target"])
				if (!limbs || !limbs.holder)
					boutput(usr, "Error: invalid target.")
					return
				limbs.mend()
				logTheThing(LOG_ADMIN, usr, "replaced all of [constructTarget(limbs.holder,"admin")]'s missing limbs")
				message_admins("[key_name(usr)] replaced all of [key_name(limbs.holder)]'s missing limbs")
				limbs.holder.set_body_icon_dirty()
				src.show_window(limbs.holder, usr)
// randomise limb
			if ("randomise_limb")
				var/datum/human_limbs/limbs = locate(href_list["target"])
				var/target_limb = href_list["part"]

				if(target_limb == "both_arms")
					var/count = limbs.randomize("both_arms",usr)

					if(count > 0)
						message_admins("[key_name(usr)] randomised [count > 1 ? "both" : "one"] of [key_name(limbs.holder)]'s arms. New arms: [limbs.l_arm.type], [limbs.r_arm.type]")

				else if(target_limb == "both_legs")
					var/count = limbs.randomize("both_legs",usr)

					if(count > 0)
						message_admins("[key_name(usr)] randomised [count > 1 ? "both" : "one"] of [key_name(limbs.holder)]'s legs. New legs: [limbs.l_leg.type], [limbs.r_leg.type]")

				else
					if (!limbs || !target_limb || !limbs.holder || !ispath(default_limb_paths[target_limb]))
						boutput(usr, "Error: invalid target limb(s).")
						return

					if (limbs.randomize(target_limb,usr)) // returns 1 or greater when at least one limb is replaced
						var/obj/item/parts/new_limb = limbs.get_limb(target_limb)
						message_admins("[key_name(usr)] randomised [key_name(limbs.holder)]'s limb: [uppertext(target_limb)] (new type: [new_limb.type])")
				src.show_window(limbs.holder, usr)
// randomise all limbs
			if ("randomise_all_limbs")
				var/datum/human_limbs/limbs = locate(href_list["target"])
				if (!limbs || !limbs.holder)
					boutput(usr, "Error: invalid target.")
					return

				var/count = limbs.randomize("all", usr)

				if(count > 0)
					message_admins("[key_name(usr)] randomised [count] of [key_name(limbs.holder)]'s limbs. New limbs: [limbs.l_arm.type], [limbs.r_arm.type], [limbs.l_leg.type], [limbs.r_leg.type]")
// drop organs
			if ("drop_organ")
				var/datum/organHolder/organs = locate(href_list["target"])
				var/target_organ = href_list["part"]
				if (!organs || !target_organ || !organs.donor)
					boutput(usr, "Error: invalid target organ(s).")
					return
				if (target_organ == "all" && alert(usr, "Are you sure you want to make [organs.donor] drop every single organ? This will kill them!", "Confirmation", "Yes", "No") == "No")
					return
				if (organs.drop_organ(target_organ, null)) // returns with the organ when at least one organ is dropped
					logTheThing(LOG_ADMIN, usr, "made [constructTarget(organs.donor,"admin")] drop their organ(s): [uppertext(target_organ)]")
					message_admins("[key_name(usr)] made [key_name(organs.donor)] drop their organ(s): [uppertext(target_organ)]")
				src.show_window(organs.donor, usr)
// replace organs
			if ("replace_organ")
				var/datum/organHolder/organs = locate(href_list["target"])
				var/target_organ = href_list["part"]
				if (!organs || !target_organ || !organs.donor)
					boutput(usr, "Error: invalid target organ(s).")
					return

				var/new_type = get_one_match(input("Type path", "Type path", "[ispath(default_organ_paths[target_organ]) ? default_organ_paths[target_organ] : /obj/item/organ]"), /obj)
				if (!new_type)
					return

				if (!ispath(new_type, /obj/item))
					if (!(usr.client && usr.client.holder && usr.client.holder.level >= LEVEL_PA))
						boutput(usr, "You need to be at least a Primary Admin to give people organs that aren't /obj/item things!")
						return
					if (alert(usr, "Giving someone an organ that isn't an /obj/item WILL cause runtimes! Runtimes are bad! Be sure you want to do this!", "WARNING", "OK", "Cancel") == "Cancel")
						return

				var/obj/item/I = new new_type(organs.donor)
				if (organs.receive_organ(I, target_organ, 0.0, 1)) // returns 1 if replace was successful
					logTheThing(LOG_ADMIN, usr, "replaced [constructTarget(organs.donor,"admin")]'s [uppertext(target_organ)] with [new_type]")
					message_admins("[key_name(usr)] replaced [key_name(organs.donor)]'s organ(s): [uppertext(target_organ)] (new type: [new_type])")
				else
					qdel(I) // ugly  :/
				src.show_window(organs.donor, usr)
// replace all organs
			if ("replace_all_organs")
				var/datum/organHolder/organs = locate(href_list["target"])
				if (!organs || !organs.donor)
					boutput(usr, "Error: invalid target.")
					return
				organs.create_organs()
				logTheThing(LOG_ADMIN, usr, "replaced all of [constructTarget(organs.donor,"admin")]'s missing organs")
				message_admins("[key_name(usr)] replaced all of [key_name(organs.donor)]'s missing organs")
				organs.donor.set_body_icon_dirty()
				src.show_window(organs.donor, usr)

	proc/show_window(var/mob/living/carbon/human/target as mob, var/mob/user)
		if (!istype(target) || !user)
			return
		if (!target.limbs)
			if (alert(user, "[target]'s limb holder is broken, recreate?", "Error", "Yes", "No") == "Yes")
				target.limbs = new(target)
			else
				return
		if (!target.organHolder)
			if (alert(user, "[target]'s organ holder is broken, recreate?", "Error", "Yes", "No") == "Yes")
				target.organHolder = new(target)
			else
				return

		var/datum/human_limbs/limbs = target.limbs
		var/datum/organHolder/organs = target.organHolder

		var/see_vars = 0
		if (ismob(user) && user.client?.holder?.level >= LEVEL_PA)
			see_vars = 1
		else if (isclient(user))
			var/client/C = user
			if (C.holder?.level >= LEVEL_PA)
				see_vars = 1
		else if (user?.client?.holder?.level >= LEVEL_PA) // ONE OF YOU HAS TO EXIST
			see_vars = 1

		var/HTML = {"<head><style>
		div {position: relative;}
		h1 {font-size: 18px; margin: 0; text-align: center; padding: 0 50px;}
		.refresh {position: absolute; top: 0; right: 0; width: 50px;}
		</style></head>
		<h1>Part Modifier: [see_vars ? "<a href='byond://?src=\ref[src];action=view_vars;target=\ref[target]'>[target]</a>" : "[target]"]</h1>
		<a href='byond://?src=\ref[src];action=refresh;target=\ref[target]' class='refresh'>Refresh</a>
		<hr>
		<table style="width:100%">
		<tbody>
			<tr>
				<th style='width:11%'>Limb</th>
				<th>Name</th>
				<th>Type</th>
				<th style='width:11%'>Sever</th>
				<th style='width:11%'>New</th>
				<th style='width:11%'>Random</th>
				[see_vars ? "<th style='width:11%'>Vars</th>" : null]
			</tr>
			<tr>
				<td>Left Arm</td>
				<td>[limbs.l_arm ? limbs.l_arm : "None"]</td>
				<td>[limbs.l_arm ? limbs.l_arm.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=l_arm'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=l_arm'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=l_arm'>\[X\]</a></td>
				[(see_vars) ? "[limbs.l_arm ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[limbs.l_arm]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Right Arm</td>
				<td>[limbs.r_arm ? limbs.r_arm : "None"]</td>
				<td>[limbs.r_arm ? limbs.r_arm.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=r_arm'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=r_arm'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=r_arm'>\[X\]</a></td>
				[(see_vars) ? "[limbs.r_arm ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[limbs.r_arm]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Left Leg</td>
				<td>[limbs.l_leg ? limbs.l_leg : "None"]</td>
				<td>[limbs.l_leg ? limbs.l_leg.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=l_leg'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=l_leg'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=l_leg'>\[X\]</a></td>
				[(see_vars) ? "[limbs.l_leg ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[limbs.l_leg]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Right Leg</td>
				<td>[limbs.r_leg ? limbs.r_leg : "None"]</td>
				<td>[limbs.r_leg ? limbs.r_leg.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=r_leg'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=r_leg'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=r_leg'>\[X\]</a></td>
				[(see_vars) ? "[limbs.r_leg ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[limbs.r_leg]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Both Arms</td>
				<td><i>N/A</i></td>
				<td><i>N/A</i></td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=both_arms'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=both_arms'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=both_arms'>\[X\]</a></td>
				[see_vars ? "<td><i>N/A</i></td>" : null]
			</tr>
			<tr>
				<td>Both Legs</td>
				<td><i>N/A</i></td>
				<td><i>N/A</i></td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=both_legs'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_limb;target=\ref[limbs];part=both_legs'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_limb;target=\ref[limbs];part=both_legs'>\[X\]</a></td>
				[see_vars ? "<td><i>N/A</i></td>" : null]
			</tr>
			<tr>
				<td>All Limbs</td>
				<td><i>N/A</i></td>
				<td><i>N/A</i></td>
				<td><a href='byond://?src=\ref[src];action=sever_limb;target=\ref[limbs];part=all'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_all_limbs;target=\ref[limbs]'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=randomise_all_limbs;target=\ref[limbs]'>\[X\]</a></td>
				[see_vars ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[limbs]'>\[X\]</a></td>" : null]
			</tr>
		</tbody></table>
		<hr>
		<table style="width:100%">
		<tbody>
			<tr>
				<th style='width:13%'>Organ</th>
				<th>Name</th>
				<th>Type</th>
				<th style='width:8%'>Drop</th>
				<th style='width:8%'>New</th>
				[see_vars ? "<th style='width:8%'>Vars</th>" : null]
			</tr>
			<tr>
				<td>Head</td>
				<td>[organs.head ? organs.head : "None"]</td>
				<td>[organs.head ? organs.head.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=head'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=head'>\[X\]</a></td>
				[(see_vars) ? "[organs.skull ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.head]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Skull</td>
				<td>[organs.skull ? organs.skull : "None"]</td>
				<td>[organs.skull ? organs.skull.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=skull'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=skull'>\[X\]</a></td>
				[(see_vars) ? "[organs.skull ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.skull]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Brain</td>
				<td>[organs.brain ? organs.brain : "None"]</td>
				<td>[organs.brain ? organs.brain.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=brain'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=brain'>\[X\]</a></td>
				[(see_vars) ? "[organs.brain ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.brain]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Left Eye</td>
				<td>[organs.left_eye ? organs.left_eye : "None"]</td>
				<td>[organs.left_eye ? organs.left_eye.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=left_eye'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=left_eye'>\[X\]</a></td>
				[(see_vars) ? "[organs.left_eye ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.left_eye]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Right Eye</td>
				<td>[organs.right_eye ? organs.right_eye : "None"]</td>
				<td>[organs.right_eye ? organs.right_eye.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=right_eye'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=right_eye'>\[X\]</a></td>
				[(see_vars) ? "[organs.right_eye ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.right_eye]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Chest</td>
				<td>[organs.chest ? organs.chest : "None"]</td>
				<td>[organs.chest ? organs.chest.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=chest'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=chest'>\[X\]</a></td>
				[(see_vars) ? "[organs.chest ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.chest]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Heart</td>
				<td>[organs.heart ? organs.heart : "None"]</td>
				<td>[organs.heart ? organs.heart.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=heart'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=heart'>\[X\]</a></td>
				[(see_vars) ? "[organs.heart ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.heart]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Left Lung</td>
				<td>[organs.left_lung ? organs.left_lung : "None"]</td>
				<td>[organs.left_lung ? organs.left_lung.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=left_lung'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=left_lung'>\[X\]</a></td>
				[(see_vars) ? "[organs.left_lung ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.left_lung]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Right Lung</td>
				<td>[organs.right_lung ? organs.right_lung : "None"]</td>
				<td>[organs.right_lung ? organs.right_lung.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=right_lung'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=right_lung'>\[X\]</a></td>
				[(see_vars) ? "[organs.right_lung ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.right_lung]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Butt</td>
				<td>[organs.butt ? organs.butt : "None"]</td>
				<td>[organs.butt ? organs.butt.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=butt'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=butt'>\[X\]</a></td>
				[(see_vars) ? "[organs.butt ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.butt]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Left Kidney</td>
				<td>[organs.left_kidney ? organs.left_kidney : "None"]</td>
				<td>[organs.left_kidney ? organs.left_kidney.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=left_kidney'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=left_kidney'>\[X\]</a></td>
				[(see_vars) ? "[organs.left_kidney ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.left_kidney]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Right Kidney</td>
				<td>[organs.right_kidney ? organs.right_kidney : "None"]</td>
				<td>[organs.right_kidney ? organs.right_kidney.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=right_kidney'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=right_kidney'>\[X\]</a></td>
				[(see_vars) ? "[organs.right_kidney ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.right_kidney]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Liver</td>
				<td>[organs.liver ? organs.liver : "None"]</td>
				<td>[organs.liver ? organs.liver.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=liver'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=liver'>\[X\]</a></td>
				[(see_vars) ? "[organs.liver ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.liver]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Stomach</td>
				<td>[organs.stomach ? organs.stomach : "None"]</td>
				<td>[organs.stomach ? organs.stomach.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=stomach'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=stomach'>\[X\]</a></td>
				[(see_vars) ? "[organs.stomach ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.stomach]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Intestines</td>
				<td>[organs.intestines ? organs.intestines : "None"]</td>
				<td>[organs.intestines ? organs.intestines.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=intestines'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=intestines'>\[X\]</a></td>
				[(see_vars) ? "[organs.intestines ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.intestines]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Spleen</td>
				<td>[organs.spleen ? organs.spleen : "None"]</td>
				<td>[organs.spleen ? organs.spleen.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=spleen'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=spleen'>\[X\]</a></td>
				[(see_vars) ? "[organs.spleen ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.spleen]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Pancreas</td>
				<td>[organs.pancreas ? organs.pancreas : "None"]</td>
				<td>[organs.pancreas ? organs.pancreas.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=pancreas'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=pancreas'>\[X\]</a></td>
				[(see_vars) ? "[organs.pancreas ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.pancreas]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Appendix</td>
				<td>[organs.appendix ? organs.appendix : "None"]</td>
				<td>[organs.appendix ? organs.appendix.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=appendix'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=appendix'>\[X\]</a></td>
				[(see_vars) ? "[organs.appendix ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.appendix]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			<tr>
				<td>Tail</td>
				<td>[organs.tail ? organs.tail : "None"]</td>
				<td>[organs.tail ? organs.tail.type : "None"]</td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=tail'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_organ;target=\ref[organs];part=tail'>\[X\]</a></td>
				[(see_vars) ? "[organs.tail ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs.tail]'>\[X\]</a></td>" : "<td>None</td>"]" : null]
			</tr>
			------------------------------------
			<tr>
				<td>All Organs</td>
				<td><i>N/A</i></td>
				<td><i>N/A</i></td>
				<td><a href='byond://?src=\ref[src];action=drop_organ;target=\ref[organs];part=all'>\[X\]</a></td>
				<td><a href='byond://?src=\ref[src];action=replace_all_organs;target=\ref[organs]'>\[X\]</a></td>
				[see_vars ? "<td><a href='byond://?src=\ref[src];action=view_vars;target=\ref[organs]'>\[X\]</a></td>" : null]
			</tr>
		</tbody></table>
		"}

		user.Browse(HTML,"window=part_mod_[target.ckey ? target.ckey : target];size=680x680")
