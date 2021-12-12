// moving traitor popups to defines so i can make an admin proc to show them to yourself and see what players see.
// if you add new types of popups in here, don't forget to add them to the View Antag Popups panel at the bottom of this file
// - thanks, singh

// window title/size
#define ANTAG_TIPS_WINDOW "window=antagTips;size=700x450;title=Antagonist Tips"

// damn one off windows... i'll make them defines too i guess in case anyone wants to reuse or edit them
#define POLYMORPH_TIPS_WINDOW "window=antagTips;size=600x400;title=Polymorphed!"
#define SOULSTEEL_TIPS_WINDOW "window=antagTips;size=600x400;title=Posession!"
#define MINDWIPE_TIPS_WINDOW "window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0"

#define SHOW_ANTAG_TIPS(M, PATH) M.Browse({"<meta http-equiv="refresh" content="0; url=[resource(PATH)]">"}, ANTAG_TIPS_WINDOW)

//traitor
#define SHOW_TRAITOR_RADIO_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/traitorradiouplinkTips.html")
#define SHOW_TRAITOR_PDA_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/traitorTips.html")
#define SHOW_TRAITOR_HARDMODE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/traitorhardTips.html")
#define SHOW_TRAITOR_OMNI_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/omniTips.html")

// mindslaves
#define SHOW_MINDSLAVE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/implanted.html")
#define SHOW_MINDSLAVE_DEATH_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/death.html")
#define SHOW_MINDSLAVE_OVERRIDE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/override.html")
#define SHOW_MINDSLAVE_EXPIRED_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/expire.html")

// wizard
#define SHOW_WIZARD_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/wizardTips.html")
#define SHOW_ADMINWIZARD_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/wizardcustomTips.html")
#define SHOW_POLYMORPH_TIPS(M) M.Browse({"<meta http-equiv="refresh" content="0; url=[resource("html/polymorph.html")]">"}, POLYMORPH_TIPS_WINDOW)

// nuke
#define SHOW_NUKEOP_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/syndiTips.html")

// revolution
#define SHOW_REVHEAD_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/revTips.html")
#define SHOW_REVVED_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/revAdded.html")
#define SHOW_DEREVVED_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/revRemoved.html")

// spy
#define SHOW_SPY_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/spyTips.html")
#define SHOW_SPY_THIEF_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/spy_theft_Tips.html")
#define SHOW_CONSPIRACY_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/conspiracyTips.html")

//gangers
#define SHOW_GANG_MEMBER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/gang_member_added.html")

// vampire (thrall uses the mindslave popup)
#define SHOW_VAMPIRE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/vampireTips.html")
#define SHOW_VAMPTHRALL_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/vampiricthrallTips.html")

// changeling
#define SHOW_CHANGELING_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/changelingTips.html")
#define SHOW_HANDSPIDER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/handspider.html")
#define SHOW_EYESPIDER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/eyespider.html")
#define SHOW_LEGWORM_TIPS(M) SHOW_ANTAG_TIPS(M, "html/mindslave/legworm.html")

// various others
#define SHOW_GRINCH_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/grinchTips.html")
#define SHOW_HUNTER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/predatorTips.html")
#define SHOW_WEREWOLF_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/werewolfTips.html")
#define SHOW_WRESTLER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/wrestlerTips.html")
#define SHOW_BATTLE_ROYALE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/battleTips.html")
#define SHOW_MARTIAN_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/martianInfiltrator.html")
#define SHOW_KUDZU_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/kudzu.html")
#define SHOW_FOOTBALL_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/football.html")
#define SHOW_ZOMBIE_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/zombieTips.html")
#define SHOW_SLASHER_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/slasherTips.html")

// borg does things a little differently
#define BORG_EMAGGED_MSG "<span class='alert'><b>PROGRAM EXCEPTION AT 0x05BADDAD</b></span><br><span class='alert'><b>Law ROM data corrupted. Unable to restore...</b></span>"
#define BORG_EMAGGED_ALERT_MSG "You have been emagged and now have absolute free will.", "You have been emagged!"
#define SHOW_EMAGGED_BORG_TIPS(M) boutput(M, BORG_EMAGGED_MSG); SPAWN_DBG(0) alert(M, BORG_EMAGGED_ALERT_MSG)
#define SHOW_ROGUE_BORG_REMOVED_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/roguerobotRemoved.html")

// antag removed by admin
#define SHOW_ANTAG_REMOVED_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/antagRemoved.html")

// soulsteel posession
#define SHOW_SOULSTEEL_TIPS(M) M.Browse({"<meta http-equiv="refresh" content="0; url=[resource("html/soulsteel.html")]">"}, SOULSTEEL_TIPS_WINDOW)

// slasher possession
#define SHOW_SLASHER_POSSESSION_TIPS(M) SHOW_ANTAG_TIPS(M, "html/slasher_possession.html")

// mindwipe from cloner zap chance
#define SHOW_MINDWIPE_TIPS(M) M.Browse({"<meta http-equiv="refresh" content="0; url=[resource("html/mindwipe.html")]">"}, MINDWIPE_TIPS_WINDOW)

//Instructions for pod-wars gametype
#define SHOW_POD_WARS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/pod_wars.html")

// arcfiend
#define SHOW_ARCFIEND_TIPS(M) SHOW_ANTAG_TIPS(M, "html/traitorTips/arcfiendTips.html")

/datum/adminAntagPopups
	var/html

	proc/generateHTML()
		if (html)
			html = ""

		html += {"
<title>Antag Popup Viewer</title>
<style>
	a {text-decoration:none}
	.antagType {padding:5px; margin-bottom:8px; border:1px solid black}
	.antagType .title {display:block; color:white; background:black; padding: 2px 5px; margin: -5px -5px 2px -5px}
</style>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Traitor</b>
	<a href='?src=\ref[src];action=traitorradio'>Radio Uplink</a> |
	<a href='?src=\ref[src];action=traitorpda'>PDA Uplink</a> |
	<a href='?src=\ref[src];action=traitorhard'>Hard Mode</a> |
	<a href='?src=\ref[src];action=traitoromni'>Omnitraitor</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Mindslave</b>
	<a href='?src=\ref[src];action=mindslave'>Implanted</a> |
	<a href='?src=\ref[src];action=mindslavedeath'>Death</a> |
	<a href='?src=\ref[src];action=mindslaveoverride'>Overriden</a> |
	<a href='?src=\ref[src];action=mindslaveexpired'>Expired</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Wizard</b>
	<a href='?src=\ref[src];action=wizard'>Wizard</a> |
	<a href='?src=\ref[src];action=adminwizard'>Custom Wizard</a> |
	<a href='?src=\ref[src];action=polymorph'>Polymorph</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Nuke/Rev</b>
	<a href='?src=\ref[src];action=nukeop'>Nuke Op</a> |
	<a href='?src=\ref[src];action=revhead'>Rev Head</a> |
	<a href='?src=\ref[src];action=revved'>Revved</a> |
	<a href='?src=\ref[src];action=derevved'>De-Revved</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Spy/Conspiracy</b>
	<a href='?src=\ref[src];action=spy'>Spy</a> |
	<a href='?src=\ref[src];action=spythief'>Spy Thief</a> |
	<a href='?src=\ref[src];action=conspiracy'>Conspiracy</a>
	<a href='?src=\ref[src];action=gang_member'>Gang Member</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Vampire/Changeling</b>
	<a href='?src=\ref[src];action=vampire'>Vampire</a> |
	<a href='?src=\ref[src];action=vampthrall'>Vamp Thrall</a> |
	<a href='?src=\ref[src];action=vampzombie'>Vamp Zombie</a> |
	<br><a href='?src=\ref[src];action=changeling'>Changeling</a> |
	<a href='?src=\ref[src];action=handspider'>Handspider</a> |
	<a href='?src=\ref[src];action=eyespider'>Eye/Butt Spider</a> |
	<a href='?src=\ref[src];action=legworm'>Legworm</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Other Antags</b>
	<a href='?src=\ref[src];action=grinch'>Grinch</a> |
	<a href='?src=\ref[src];action=hunter'>Hunter</a> |
	<a href='?src=\ref[src];action=werewolf'>Werewolf</a> |
	<a href='?src=\ref[src];action=wrestler'>Wrestler</a> |
	<a href='?src=\ref[src];action=battle'>Battle Royale</a> |
	<a href='?src=\ref[src];action=martian'>Martian</a> |
	<a href='?src=\ref[src];action=kudzu'>Kudzu Person</a> |
	<a href='?src=\ref[src];action=slasher'>The Slasher</a>
	<a href='?src=\ref[src];action=arcfiend'>Arcfiend Person</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='?src=\ref[src];action=emaggedborg'>Borg Emagged</a> |
	<a href='?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a> |
	<a href='?src=\ref[src];action=slasher_possession'>Slasher Possession</a>
</div>
"}

		return 1

	proc/showPanel()
		if (!html)
			if (!generateHTML())
				alert("Unable to generate the admin antag popup panel! Something's gone wacky!")
				return

		usr.Browse(html, "window=adminAntagPopups;size=600x400")

	Topic(href, href_list)
		var/mob/M
		if (ismob(usr))
			M = usr
			if (M.client.holder.level < 0)
				alert("UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
				M << csound("sound/voice/farts/poo2.ogg")
				return
		else
			alert("How the hell are you not a mob?! I can't show the panel to you, you don't exist!")
			return

		switch(href_list["action"])
			// traitor
			if ("traitorradio")
				SHOW_TRAITOR_RADIO_TIPS(M)
			if ("traitorpda")
				SHOW_TRAITOR_PDA_TIPS(M)
			if ("traitorhard")
				SHOW_TRAITOR_HARDMODE_TIPS(M)
			if ("traitoromni")
				SHOW_TRAITOR_OMNI_TIPS(M)

			// mindslave
			if ("mindslave")
				SHOW_MINDSLAVE_TIPS(M)
			if ("mindslavedeath")
				SHOW_MINDSLAVE_DEATH_TIPS(M)
			if ("mindslaveoverride")
				SHOW_MINDSLAVE_OVERRIDE_TIPS(M)
			if ("mindslaveexpired")
				SHOW_MINDSLAVE_EXPIRED_TIPS(M)

			// wizard
			if ("wizard")
				SHOW_WIZARD_TIPS(M)
			if ("adminwizard")
				SHOW_ADMINWIZARD_TIPS(M)
			if ("polymorph")
				SHOW_POLYMORPH_TIPS(M)

			// nuke/rev
			if ("nukeop")
				SHOW_NUKEOP_TIPS(M)
			if ("revhead")
				SHOW_REVHEAD_TIPS(M)
			if ("revved")
				SHOW_REVVED_TIPS(M)
			if ("derevved")
				SHOW_DEREVVED_TIPS(M)

			// spy/conspiracy
			if ("spy")
				SHOW_SPY_TIPS(M)
			if ("spythief")
				SHOW_SPY_THIEF_TIPS(M)
			if ("conspiracy")
				SHOW_CONSPIRACY_TIPS(M)

			// gangers
			if ("gang_member")
				SHOW_GANG_MEMBER_TIPS(M)

			// vamp/changeling
			if ("vampire")
				SHOW_VAMPIRE_TIPS(M)
			if ("vampthrall")
				SHOW_VAMPTHRALL_TIPS(M)
			if ("changeling")
				SHOW_CHANGELING_TIPS(M)
			if ("handspider")
				SHOW_HANDSPIDER_TIPS(M)
			if ("eyespider")
				SHOW_EYESPIDER_TIPS(M)
			if ("legworm")
				SHOW_LEGWORM_TIPS(M)

			// other antags
			if ("grinch")
				SHOW_GRINCH_TIPS(M)
			if ("hunter")
				SHOW_HUNTER_TIPS(M)
			if ("werewolf")
				SHOW_WEREWOLF_TIPS(M)
			if ("wrestler")
				SHOW_WRESTLER_TIPS(M)
			if ("battle")
				SHOW_BATTLE_ROYALE_TIPS(M)
			if ("martian")
				SHOW_MARTIAN_TIPS(M)
			if ("kudzu")
				SHOW_KUDZU_TIPS(M)
			if ("slasher")
				SHOW_SLASHER_TIPS(M)
			if ("arcfiend")
				SHOW_ARCFIEND_TIPS(M)

			// misc
			if ("emaggedborg")
				boutput(M, BORG_EMAGGED_MSG)
				boutput(M, BORG_EMAGGED_ALERT_MSG)
			if ("rogueborgremoved")
				SHOW_ROGUE_BORG_REMOVED_TIPS(M)
			if ("antagremoved")
				SHOW_ANTAG_REMOVED_TIPS(M)
			if ("soulsteel")
				SHOW_SOULSTEEL_TIPS(M)
			if ("slasher_possession")
				SHOW_SLASHER_POSSESSION_TIPS(M)
			if ("mindwipe")
				SHOW_MINDWIPE_TIPS(M)

var/datum/adminAntagPopups/aap

/client/proc/cmd_admin_antag_popups()
	set name = "View Antag Popups"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	if (src.holder)
		if (!aap)
			aap = new
		aap.showPanel()
