## FontAwesome for TGUI

Grab the woff2 and the all.min.css from https://cdnjs.com/libraries/font-awesome

Remove the brand shit and v4/v5 compat.

Due to the fact browse_rsc can't create subdirectories, every time you update font-awesome you'll need to change relative webfont references in fa-all.min.css
`../webfonts/([^\)]*)` -> `'{{resource("vendor/fonts/$1")}}'`

Remove useless `-moz-osx-font-smoothing:grayscale;`
