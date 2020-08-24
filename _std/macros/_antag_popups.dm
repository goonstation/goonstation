// moving traitor popups to defines so i can make an admin proc to show them to yourself and see what players see.
// if you add new types of popups in here, don't forget to add them to the View Antag Popups panel at the bottom of this file
// - thanks, singh

// window title/size
#define ANTAG_TIPS_WINDOW "window=antagTips;size=700x450;title=Antagonist Tips"

// damn one off windows... i'll make them defines too i guess in case anyone wants to reuse or edit them
#define POLYMORPH_TIPS_WINDOW "window=antagTips;size=600x400;title=Polymorphed!"
#define SOULSTEEL_TIPS_WINDOW "window=antagTips;size=600x400;title=Posession!"
#define MINDWIPE_TIPS_WINDOW "window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0"

//traitor
#define SHOW_TRAITOR_RADIO_TIPS(M) M.Browse(grabResource("html/traitorTips/traitorradiouplinkTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_TRAITOR_PDA_TIPS(M) M.Browse(grabResource("html/traitorTips/traitorTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_TRAITOR_HARDMODE_TIPS(M) M.Browse(grabResource("html/traitorTips/traitorhardTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_TRAITOR_OMNI_TIPS(M) M.Browse(grabResource("html/traitorTips/omniTips.html"), ANTAG_TIPS_WINDOW)

// mindslaves
#define SHOW_MINDSLAVE_TIPS(M) M.Browse(grabResource("html/mindslave/implanted.html"), ANTAG_TIPS_WINDOW)
#define SHOW_MINDSLAVE_DEATH_TIPS(M) M.Browse(grabResource("html/mindslave/death.html"), ANTAG_TIPS_WINDOW)
#define SHOW_MINDSLAVE_OVERRIDE_TIPS(M) M.Browse(grabResource("html/mindslave/override.html"), ANTAG_TIPS_WINDOW)
#define SHOW_MINDSLAVE_EXPIRED_TIPS(M) M.Browse(grabResource("html/mindslave/expire.html"), ANTAG_TIPS_WINDOW)

// wizard
#define SHOW_WIZARD_TIPS(M) M.Browse(grabResource("html/traitorTips/wizardTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_ADMINWIZARD_TIPS(M) M.Browse(grabResource("html/traitorTips/wizardcustomTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_POLYMORPH_TIPS(M) M.Browse(grabResource("html/polymorph.html"), POLYMORPH_TIPS_WINDOW)

// nuke
#define SHOW_NUKEOP_TIPS(M) M.Browse(grabResource("html/traitorTips/syndiTips.html"), ANTAG_TIPS_WINDOW)

// revolution
#define SHOW_REVHEAD_TIPS(M) M.Browse(grabResource("html/traitorTips/revTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_REVVED_TIPS(M) M.Browse(grabResource("html/traitorTips/revAdded.html"), ANTAG_TIPS_WINDOW)
#define SHOW_DEREVVED_TIPS(M) M.Browse(grabResource("html/traitorTips/revRemoved.html"), ANTAG_TIPS_WINDOW)

// spy
#define SHOW_SPY_TIPS(M) M.Browse(grabResource("html/traitorTips/spyTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_SPY_THIEF_TIPS(M) M.Browse(grabResource("html/traitorTips/spy_theft_Tips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_CONSPIRACY_TIPS(M) M.Browse(grabResource("html/traitorTips/conspiracyTips.html"), ANTAG_TIPS_WINDOW)

//gangers
#define SHOW_GANG_MEMBER_TIPS(M) M.Browse(grabResource("html/traitorTips/gang_member_added.html"), ANTAG_TIPS_WINDOW)

// vampire (thrall uses the mindslave popup)
#define SHOW_VAMPIRE_TIPS(M) M.Browse(grabResource("html/traitorTips/vampireTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_VAMPZOMBIE_TIPS(M) M.Browse(grabResource("html/traitorTips/vampiriczombieTips.html"), ANTAG_TIPS_WINDOW)

// changeling
#define SHOW_CHANGELING_TIPS(M) M.Browse(grabResource("html/traitorTips/changelingTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_HANDSPIDER_TIPS(M) M.Browse(grabResource("html/mindslave/handspider.html"), ANTAG_TIPS_WINDOW)
#define SHOW_EYESPIDER_TIPS(M) M.Browse(grabResource("html/mindslave/eyespider.html"), ANTAG_TIPS_WINDOW)
#define SHOW_LEGWORM_TIPS(M) M.Browse(grabResource("html/mindslave/legworm.html"), ANTAG_TIPS_WINDOW)

// various others
#define SHOW_GRINCH_TIPS(M) M.Browse(grabResource("html/traitorTips/grinchTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_HUNTER_TIPS(M) M.Browse(grabResource("html/traitorTips/predatorTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_WEREWOLF_TIPS(M) M.Browse(grabResource("html/traitorTips/werewolfTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_WRESTLER_TIPS(M) M.Browse(grabResource("html/traitorTips/wrestlerTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_BATTLE_ROYALE_TIPS(M) M.Browse(grabResource("html/traitorTips/battleTips.html"), ANTAG_TIPS_WINDOW)
#define SHOW_MARTIAN_TIPS(M) M.Browse(grabResource("html/traitorTips/martianInfiltrator.html"), ANTAG_TIPS_WINDOW)
#define SHOW_KUDZU_TIPS(M) M.Browse(grabResource("html/traitorTips/kudzu.html"), ANTAG_TIPS_WINDOW)
#define SHOW_FOOTBALL_TIPS(M) M.Browse(grabResource("html/traitorTips/football.html"), ANTAG_TIPS_WINDOW)

// borg does things a little differently
#define BORG_EMAGGED_MSG "<span class='alert'><b>PROGRAM EXCEPTION AT 0x05BADDAD</b></span><br><span class='alert'><b>Law ROM data corrupted. Unable to restore...</b></span>"
#define BORG_EMAGGED_ALERT_MSG "You have been emagged and now have absolute free will.", "You have been emagged!"
#define SHOW_EMAGGED_BORG_TIPS(M) boutput(M, BORG_EMAGGED_MSG); SPAWN_DBG(0) alert(M, BORG_EMAGGED_ALERT_MSG)
#define SHOW_ROGUE_BORG_REMOVED_TIPS(M) M.Browse(grabResource("html/traitorTips/roguerobotRemoved.html"), ANTAG_TIPS_WINDOW)

// antag removed by admin
#define SHOW_ANTAG_REMOVED_TIPS(M) M.Browse(grabResource("html/traitorTips/antagRemoved.html"), ANTAG_TIPS_WINDOW)

// soulsteel posession
#define SHOW_SOULSTEEL_TIPS(M) M.Browse(grabResource("html/soulsteel.html"), SOULSTEEL_TIPS_WINDOW)

// mindwipe from cloner zap chance
#define SHOW_MINDWIPE_TIPS(M) M.Browse(grabResource("html/mindwipe.html"), MINDWIPE_TIPS_WINDOW)

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
	<a href='?src=\ref[src];action=kudzu'>Kudzu Person</a>
</div>
<div class='antagType' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Misc</b>
	<a href='?src=\ref[src];action=emaggedborg'>Borg Emagged</a> |
	<a href='?src=\ref[src];action=rogueborgremoved'>Rogue Borg Removed</a> |
	<a href='?src=\ref[src];action=antagremoved'>Antag Removed</a> |
	<a href='?src=\ref[src];action=soulsteel'>Soulsteel Posession</a> |
	<a href='?src=\ref[src];action=mindwipe'>Cloner Mindwipe</a>
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
				SHOW_MINDSLAVE_TIPS(M)
			if ("vampzombie")
				SHOW_VAMPZOMBIE_TIPS(M)
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
