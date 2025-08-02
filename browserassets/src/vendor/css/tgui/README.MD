Due to the fact browse_rsc can't create subdirectories, every time you update font-awesome you'll need to change relative webfont references in fa-all.min.css eg ../webfonts/fa-regular-400.ttf => fa-regular-400.ttf (or whatever you call it in asset datum)
`../webfonts/([^\)]*)` -> `'{{resource("css/fonts/$1")}}'`

You'll want to modify the .css as well to only include ttf.

Remove useless `-moz-osx-font-smoothing:grayscale;`

Remove brand related css.
