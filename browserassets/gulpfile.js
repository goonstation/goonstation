import fs from "fs";
import minimist from "minimist";
import { series, parallel, src, dest } from "gulp";
import { deleteAsync } from "del";
import replace from "gulp-replace";
import htmlmin from "gulp-htmlmin";
import postcss from "gulp-postcss";
import babel from "gulp-babel";
import autoprefixer from "autoprefixer";
import cssnano from "cssnano";

const uglify = (await import("gulp-uglify-es")).default.default;
const argv = minimist(process.argv.slice(2));

// Build Directories
const dirs = {
	src: ".",
	dest: "build",
};

// File Sources
const sources = {
	styles: `${dirs.src}/css/**/*.css`,
	html: `${dirs.src}/html/**/*.html`,
	scripts: `${dirs.src}/js/**/*.js`,
	images: `${dirs.src}/images/**/*`,
};

// Build CDN subdomain from server type argument
const server = argv.server || "main1";
const cdn = argv.cdn || `https://cdn-${server}.goonhub.com`;

// Read git revision from stamped file (stamped during build process)
let rev = fs.readFileSync("./revision", "utf-8") || "1";
rev = rev.replace(/(\r\n|\n|\r)/gm, ""); // begone newlines

// Replace {{resource(path/to/file)}} in files with proper CDN URLs
const resourceMacroRegex = /\{\{resource\(\"(.*?)\"\)\}\}/gi;

function clean(cb) {
	return deleteAsync(dirs.dest);
}

function html(cb) {
	return src(sources.html)
		.pipe(replace(resourceMacroRegex, `${cdn}/$1?v=${rev}`))
		.pipe(
			htmlmin({
				collapseBooleanAttributes: true,
				collapseWhitespace: true,
				conservativeCollapse: true,
				removeComments: false,
				removeAttributeQuotes: true,
				removeCommentsFromCDATA: true,
				removeEmptyAttributes: true,
				removeOptionalTags: false,
				// true would impact styles with attribute selectors
				removeRedundantAttributes: false,
				useShortDoctype: true,
			}),
		)
		.pipe(dest(dirs.dest + "/html"));
}

function css(cb) {
	return src(sources.styles)
		.pipe(replace(resourceMacroRegex, `${cdn}/$1?v=${rev}`))
		.pipe(postcss([autoprefixer(), cssnano()]))
		.pipe(dest(dirs.dest + "/css"));
}

function javascript(cb) {
	return src(sources.scripts)
		.pipe(replace(resourceMacroRegex, `${cdn}/$1?v=${rev}`))
		.pipe(
			babel({
				presets: ["@babel/env"],
				// Disables printing "use strict;" at the top of scripts
				// As not all of our terrible code is compliant with strict mode
				sourceType: "script",
			}),
		)
		.pipe(
			uglify({
				ecma: 5,
				mangle: {
					reserved: ["$", "exports", "require"],
				},
				compress: true,
				ie8: true,
				// output: {
				// 	comments: 'all'
				// }
			}),
		)
		.pipe(dest(dirs.dest + "/js"));
}

function copy(cb) {
	return src(["vendor/**/*", "css/fonts/**/*", "misc/**/*", "tgui/**/*", "images/**/*"], {
		base: dirs.src,
		encoding: false,
	})
		.pipe(replace(resourceMacroRegex, `${cdn}/$1?v=${rev}`))
		.pipe(dest(dirs.dest));
}

export const build = series(
	clean,
	parallel(html, css, javascript),
	copy,
);

build.description = "Build CDN Assets";
build.flags = { '--server': 'Server to build for' }
