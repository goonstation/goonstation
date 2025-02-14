// Determines the minimap types the icon/area should be displayed on.
#define MAP_ALL						(~0) // Sets all bits to 1, being the binary not of 0; in effect, enabling all flags in the bitflag.
#define MAP_AI						(1<<0)
#define MAP_SYNDICATE				(1<<1)
#define MAP_POD_WARS_NANOTRASEN		(1<<2)
#define MAP_POD_WARS_SYNDICATE		(1<<3)
#define	MAP_INFO 					(1<<4) //! Map that just shows station rooms
#define MAP_ALERTS					(1<<5) //! Station General Alerts
#define MAP_CAMERA_SECURITY			(1<<6) //! Cameras, Security Network
#define MAP_CAMERA_PUBLIC			(1<<7) //! Cameras, Public Network
#define MAP_CAMERA_THUNDER			(1<<8) //! Cameras, Thunderdome Network
#define MAP_HTR_TEAM 				(1<<20)

// Area groups, which will be treated as one atom/movable by the renderer, allowing for efficient recolouring across minimaps.
#define GROUP_NSV_RELIANT "nsv_reliant"
#define GROUP_FORTUNA "fortuna"
#define GROUP_UVB67 "uvb67"

// Area colours on minimaps.
#define MAPC_DEFAULT "#808080"
#define MAPC_MAINTENANCE "#474747"
#define MAPC_HALLWAY "#ffffff"

#define MAPC_COMMAND "#1e2861"

#define MAPC_CAFETERIA "#90d467"
#define MAPC_BAR "#907e47"
#define MAPC_KITCHEN "#d4d4d4"
#define MAPC_CHAPEL "#75602d"
#define MAPC_HYDROPONICS "#0da70d"
#define MAPC_RANCH "#59703a"

#define MAPC_SECURITY "#b10202"
#define MAPC_ARMOURY "#711122"
#define MAPC_BRIG "#d37610"

#define MAPC_MEDICAL "#1ba7e9"
#define MAPC_MEDLOBBY "#78c5e9"
#define MAPC_ROBOTICS "#5b6eb1"
#define MAPC_MORGUE "#2b6a92"
#define MAPC_MEDRESEARCH "#3fb583"
#define MAPC_PATHOLOGY "#167970"

#define MAPC_RESEARCH "#8e0bc2"
#define MAPC_CHEMISTRY "#5a1d8a"
#define MAPC_TOXINS "#441668"
#define MAPC_TELESCI "#660bc2"
#define MAPC_ARTLAB "#b320c3"

#define MAPC_ENGINEERING "#d3cb21"
#define MAPC_MECHLAB "#fffa8f"
#define MAPC_QUARTERMASTER "#b97f2e"
#define MAPC_MINING "#8f5b12"

#define MAPC_NANOTRASEN "#0a4882"
#define MAPC_SYNDICATE "#820a16"
#define MAPC_UNCLAIMED "#500a82"
#define MAPC_NEUTRAL "#d1a600"
#define MAPC_ASTEROID "#a6a6a6"
