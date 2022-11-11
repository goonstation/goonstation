//CONTENTS
//Email daemon thing

/datum/computer/file/mainframe_program/srv/email
	name = "mail"
	size = 1

	var/setup_email_folder = "/etc/mail"
	var/setup_mailgroup_table = "groups"
	var/defaultDomain = "NT13"

	initialize(var/initparams)
		if (..() || !useracc)
			mainframe_prog_exit
			return
		//todo: all of this.  All of this forever.

		//boutput(world, "[initparams]")

		var/command = null
		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			command = "index"
		else
			command = ckey(initlist[1])

		var/user_name = dd_hasprefix(useracc.user_name, "SRV") ? copytext(useracc.user_name, 4, length(useracc.user_name)) : copytext(useracc.user_name, 1, length(useracc.user_name))

		//boutput(world, "Username: \"[useracc.user_name]\" -> \"[user_name]\"")

		switch (command)
			if ("index")
				var/group = null
				if (initlist.len > 1)
					group = initlist[2]
				var/list/mail_subjects = list_mail_subjects(user_name, group)
				var/message = "mail_index"
				if (mail_subjects.len)
					message += "|n" + jointext(mail_subjects, "|n")
				message_user(message, "record")

			if ("get")
				var/index = 0
				var/group = null
				if (initlist.len > 1)
					index = max( round(text2num_safe(initlist[2])), 1)

					if (initlist.len > 2)
						group = initlist[3]

					var/list/mailList = list_mail_for(user_name, group)
					if (!istype(mailList) || mailList.len < index)
						mainframe_prog_exit
						return

					var/datum/computer/file/record/targetMail = mailList[index]
					if (istype(targetMail) && parent_task)
						targetMail = format_outgoing_mail(targetMail)
						message_user("mail_entry",null,targetMail)

			if ("send")
				if (initlist.len > 1)
					var/sentMailPath = initlist[2]
					if (!dd_hasprefix(sentMailPath, "/"))
						sentMailPath = "/[sentMailPath]"

					var/datum/computer/file/record/sentMail = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[sentMailPath]"))
					if (istype(sentMail))
						sentMail = sentMail.copy_file()
						sentMail.fields = sentMail.fields.Copy()
						if (send_mail_to(sentMail) == 0)
							message_user("ack")
						else
							message_user("nack")

			if ("delete")
				var/index = 0
				var/group = null
				if (initlist.len > 1)
					index = max( round(text2num_safe(initlist[2])), 1)

					if (initlist.len > 2)
						group = initlist[3]

					var/list/mailList = list_mail_for(user_name, group)
					if (!istype(mailList) || mailList.len < index)
						mainframe_prog_exit
						return

					var/datum/computer/file/record/targetMail = mailList[index]
					if (istype(targetMail) && dd_hassuffix(targetMail.name, user_name))
						if (signal_program(1, list("command"=DWAINE_COMMAND_FKILL, "path"="[setup_email_folder]/[targetMail.name]")) == ESIG_SUCCESS)
							message_user("ack")
						else
							message_user("nack")
					else
						message_user("nack")

		mainframe_prog_exit
		return

	proc
		format_outgoing_mail(var/datum/computer/file/record/mail)
			if (!istype(mail) || !mail.fields || (mail.fields.len < 6))
				return null

			var/datum/computer/file/record/newMail = mail.copy_file()
			newMail.fields = newMail.fields.Copy()
			var/compactHeader = "mailnet=[mail.fields[1] ? mail.fields[1] : "???"]&group=[mail.fields[2] ? mail.fields[2] : "???"]"
			compactHeader += "&sender=[mail.fields[3] ? mail.fields[3] : "???"]&target=[mail.fields[4] ? mail.fields[4] : "???"]"
			compactHeader += "&priority=[mail.fields[5] ? mail.fields[5] : "LOW"]&subj=[mail.fields[6] ? mail.fields[6] : "???"]"

			newMail.fields[1] = compactHeader
			newMail.fields.Cut(2, 7)

			return newMail

		send_mail_to(var/datum/computer/file/record/mail)
			if (!istype(mail) || !length(mail.fields))
				return 1

			var/list/mailHeader = params2list(mail.fields[1])
			if (!mailHeader)
				return 2

			var/target = mailHeader["target"]
			var/target_name = target
			var/atLocation = findtext(target, "@")
			if (atLocation)
				target_name = copytext(target,1, atLocation)

			var/mailgroup = ckey(mailHeader["group"]) ? mailHeader["group"] : "*NONE"

			if (!target && !mailgroup)
				return 3

			var/datum/computer/folder/mailgroupTable = null
			if (mailgroup && lowertext(mailgroup) != "*all" && lowertext(mailgroup) != "*none")
				mailgroupTable = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[setup_email_folder]/[setup_mailgroup_table]"))
				if (!istype(mailgroupTable))
					return 4

			mail.fields.Cut(1,2)
			mail.name = "[copytext("\ref[mail]", 4, 12)][target_name ? lowertext(target_name) : "all"]"
			mail.fields.Insert(1, "PUBLIC_NT", "[uppertext(mailgroup)]","[ckeyEx(mailHeader["sender"]) ? copytext(uppertext(ckeyEx(mailHeader["sender"])), 1, 33) : "???"][dd_hassuffix(mailHeader["sender"], "@[defaultDomain]") ? null : "@[defaultDomain]"]",\
			"[target ? target : "ALL"]",\
			"[ckeyEx(mailHeader["priority"]) ? copytext(uppertext(ckeyEx(mailHeader["priority"])), 1, 9) : "LOW"]",\
			"[ckeyEx(mailHeader["subj"]) ? copytext(uppertext(mailHeader["subj"]), 1, 33) : "???"]")

			if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE, "path"="[setup_email_folder]", "mkdir"=1), mail) == ESIG_SUCCESS)
				return 0

			return 5

		list_mail_for(var/target, var/mailgroup=null)//"*all")
			if (!target && !mailgroup)
				return

			var/list/mailList = list()
			var/datum/computer/folder/mailFolder = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[setup_email_folder]"))
			if (!istype(mailFolder))
				return mailList

			var/datum/computer/file/record/mailgroupTable = null
			var/list/groupTargets = null
			if (!(mailgroup && lowertext(mailgroup) != "*all"))
				groupTargets = list()
				mailgroupTable = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[setup_email_folder]/[setup_mailgroup_table]"))
				if (istype(mailgroupTable))
					for (var/groupDef in mailgroupTable.fields)
						if (findtext(groupDef, "[target],"))
							groupTargets += "[copytext(groupDef, 1, findtext(groupDef, ":"))]"
							break

			for(var/datum/computer/file/record/emailRec in mailFolder.contents)
				if (!check_read_permission(emailRec, useracc))
					continue

				if ((length(emailRec.fields) >= 2) && lowertext(emailRec.fields[2]) == "*all")
					mailList += emailRec
					continue

				if (length(groupTargets))
					var/success = 0
					for (var/groupMember in groupTargets)
						if (length(emailRec.fields) >= 2 && (lowertext(groupMember) ==  lowertext(emailRec.fields[2])))
							mailList += emailRec
							success = 1
							break

					if (success)
						continue

				if (target && dd_hassuffix(emailRec.name, target))
					mailList += emailRec
					continue

			return mailList


		list_mail_subjects(var/target, var/mailgroup=null)//"*all")
			if (!target && !mailgroup)
				return

			var/list/mailSubjs = list()
			var/datum/computer/folder/mailFolder = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[setup_email_folder]"))
			if (!istype(mailFolder))
				return mailSubjs

			var/datum/computer/file/record/mailgroupTable = null
			var/list/groupTargets = null
			if (!(mailgroup && lowertext(mailgroup) != "*all"))
				groupTargets = list()
				mailgroupTable = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[setup_email_folder]/[setup_mailgroup_table]"))
				if (istype(mailgroupTable))
					for (var/groupDef in mailgroupTable.fields)
						if (findtext(groupDef, "[target],"))
							groupTargets += "[copytext(groupDef, 1, findtext(groupDef, ":"))]"
							break

			for(var/datum/computer/file/record/emailRec in mailFolder.contents)
				if (!check_read_permission(emailRec, useracc))
					continue

				if (!emailRec.fields || emailRec.fields.len < 6)
					continue

				if (lowertext(emailRec.fields[2]) == "*all")
					mailSubjs.len++
					mailSubjs[mailSubjs.len] = copytext(emailRec.fields[6], 1, 33)
					continue

				if (length(groupTargets))
					var/success = 0
					for (var/groupMember in groupTargets)
						if (lowertext(groupMember) == lowertext(emailRec.fields[2]))
							mailSubjs.len++
							mailSubjs[mailSubjs.len] = copytext(emailRec.fields[6], 1, 33)
							success = 1
							break

					if (success)
						continue

				if (target && dd_hassuffix(emailRec.name, target))
					mailSubjs.len++
					mailSubjs[mailSubjs.len] = copytext(emailRec.fields[6], 1, 33)
					continue

			return mailSubjs
