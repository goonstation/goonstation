/*
(t)
(u)
(*)
*/
/datum/admin_changelog
	var/html = null

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ATTENTION: The changelog has moved into its own file: strings/admin_changelog.txt

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/datum/admin_changelog/New()
	..()
	//Changelog has moved to its own file.
	//Note: deliberately using double quotes so that it won't be included in the RSC -SpyGuy
	html = changelog_parse(file2text("strings/admin_changelog.txt"), "Admin Changelog")
