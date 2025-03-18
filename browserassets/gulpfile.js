import fs from "fs";
import path from "path";
import { series, parallel, src, dest } from "gulp";
import { deleteAsync } from "del";
import replace from "gulp-replace";
import htmlmin from "gulp-htmlmin";
import postcss from "gulp-postcss";
import babel from "gulp-babel";
import autoprefixer from "autoprefixer";
import cssnano from "cssnano";
import hash from "gulp-hash-filename";
import rename from "gulp-rename";

const uglify = (await import("gulp-uglify-es")).default.default;

const CDN_VERSION = process.env.CDN_VERSION || 1;
const SERVER_TARGET = process.env.SERVER_TARGET || "main1";

// Build Directories
const dirs = {
	src: ".",
	dest: "build",
};

// File Sources
const sources = {
	all: `${dirs.src}/(css|html|images|js|misc|tgui|vendor)/**/*.*`,
	styles: `${dirs.src}/css/**/*.css`,
	html: `${dirs.src}/html/**/*.(html|htm)`,
	scripts: `${dirs.src}/js/**/*.js`,
	copyable: `${dirs.src}/(css/fonts|images|misc|tgui|vendor)/**/*.*`,
	// Files that tgui includes via resource() calls
	tguiManifest: `${dirs.src}/images/**/*.*`,
};

// Build CDN subdomain from server type argument
const cdn = `https://cdn-${SERVER_TARGET}.goonhub.com`;

// Replace {{resource(path/to/file)}} in files with proper CDN URLs
const resourceMacroRegex = /\{\{resource\(\"(.*?)\"\)\}\}/gi;

const hashFormat = `{name}.{hash:8}{ext}?v=${CDN_VERSION}`;

let buildManifest = {};

function macroReplacer() {
	return replace(resourceMacroRegex, function handleReplace(m, filePath) {
		if (buildManifest[filePath]) filePath = buildManifest[filePath];
		return `${cdn}/${filePath}`;
	});
}

function hashRenamer(filePath, file) {
	const lookup = file.path
		.replace(path.join(file.cwd, "/"), "")
		.replaceAll("\\", "/");
	const hashName = buildManifest[lookup];
	if (hashName) {
		filePath.basename = path.basename(hashName, path.extname(hashName));
	}
}

async function clean(cb) {
	await deleteAsync(dirs.dest);
	fs.mkdir(dirs.dest, cb);
}

function generateManifest(source, manifestName) {
	return new Promise((resolve) => {
		let localManifest = {};
		source
			.pipe(hash({ format: hashFormat }))
			.on("data", function (file) {
				const originalPath = file.history[0]
					.replace(path.join(file.cwd, "/"), "")
					.replaceAll("\\", "/");
				const newPath = file.path
					.replace(path.join(file.cwd, "/"), "")
					.replaceAll("\\", "/");
				localManifest[originalPath] = newPath;
			})
			.on("finish", function () {
				fs.writeFile(
					`${dirs.dest}/${manifestName}`,
					JSON.stringify(localManifest, null, 2),
					"utf8",
					() => {},
				);
				resolve(localManifest);
			});
	});
}

async function manifest(cb) {
	buildManifest = await generateManifest(src(sources.all), "manifest.json");
}

async function generateTguiManifest(cb) {
	await generateManifest(src(sources.tguiManifest), "tgui-manifest.json");
}

function html(cb) {
	return src(sources.html)
		.pipe(macroReplacer())
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
		.pipe(rename(hashRenamer))
		.pipe(dest(dirs.dest + "/html"));
}

function css(cb) {
	return src(sources.styles)
		.pipe(macroReplacer())
		.pipe(postcss([autoprefixer(), cssnano()]))
		.pipe(rename(hashRenamer))
		.pipe(dest(dirs.dest + "/css"));
}

function javascript(cb) {
	return src(sources.scripts)
		.pipe(macroReplacer())
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
		.pipe(rename(hashRenamer))
		.pipe(dest(dirs.dest + "/js"));
}

function copy(cb) {
	return src(sources.copyable, { encoding: false })
		.pipe(macroReplacer())
		.pipe(rename(hashRenamer))
		.pipe(dest(dirs.dest));
}

export const tguiManifest = series(clean, generateTguiManifest);

tguiManifest.displayName = "tgui:manifest";
tguiManifest.description = "Generate a manifest for TGUI";

export const build = series(
	clean,
	manifest,
	parallel(html, css, javascript),
	copy,
);

build.description = "Build CDN Assets";
