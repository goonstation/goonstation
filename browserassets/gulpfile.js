import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { series, parallel, src, dest } from "gulp";
import { deleteAsync } from "del";
import replace from "gulp-replace";
import htmlmin from "gulp-htmlmin";
import postcss from "gulp-postcss";
import babel from "gulp-babel";
import autoprefixer from "autoprefixer";
import cssnano from "cssnano";
import rename from "gulp-rename";
import { isText } from "istextorbinary";
import vinyl from "vinyl";
import performHash from "./gulp-hash-filename/performHash.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const uglify = (await import("gulp-uglify-es")).default.default;

const CDN_VERSION = process.env.CDN_VERSION || 1;
const SERVER_TARGET = process.env.SERVER_TARGET || "main1";

// Build Directories
const dirs = {
	src: "src",
	dest: "build",
};

// File Sources
const sources = {
	all: `${dirs.src}/**/*.*`,
	styles: `${dirs.src}/css/**/*.css`,
	html: `${dirs.src}/html/**/*.(html|htm)`,
	scripts: `${dirs.src}/js/**/*.js`,
	copyable: `${dirs.src}/(css/fonts|images|misc|tgui|vendor)/**/*.*`,
	// Files that tgui includes via resource() calls
	tguiManifest: `${dirs.src}/images/**/*.*`,
};

// A list of glob patterns we ignore from all sources
const ignoreSources = ["**/*.md"];

// Build CDN subdomain from server type argument
const cdn = `https://cdn-${SERVER_TARGET}.goonhub.com`;

// Replace {{resource(path/to/file)}} in files with proper CDN URLs
const resourceMacroRegex = /\{\{resource\(\"(.*?)\"\)\}\}/gi;

const hashFormat = `{name}.{hash:8}{ext}`;

let buildManifest = new Map();

function cleanFilePath(filePath) {
	return filePath
		.replace(path.join(__dirname, dirs.src, "/"), "")
		.replaceAll("\\", "/");
}

function macroReplacer() {
	return replace(resourceMacroRegex, function handleReplace(m, filePath) {
		if (buildManifest.has(filePath)) {
			const manifestEntry = buildManifest.get(filePath);
			filePath = manifestEntry.path;
		}
		return `${cdn}/${filePath}?v=${CDN_VERSION}`;
	});
}

function hashRenamer(filePath, file) {
	const manifestEntry = buildManifest.get(cleanFilePath(file.path));
	if (manifestEntry) {
		filePath.basename = path.basename(
			manifestEntry.name,
			path.extname(manifestEntry.name),
		);
	}
}

function generateManifest(source, saveManifest) {
	return new Promise((resolve) => {
		const baseHashes = new Map();
		const manifest = new Map();

		function getBaseHash(cleanPath, file) {
			let baseFileHash = baseHashes.get(cleanPath);
			if (!baseFileHash) {
				const hashEntry = performHash(hashFormat, file);
				baseFileHash = {
					path: cleanFilePath(hashEntry.path),
					name: hashEntry.basename,
				};
				baseHashes.set(cleanPath, baseFileHash);
			}
			return baseFileHash;
		}

		function getFile(filePath) {
			return new vinyl({
				path: filePath,
				contents: fs.readFileSync(filePath),
				stat: fs.statSync(filePath),
			});
		}

		return src(source, { nocase: true, ignore: ignoreSources })
			.on("data", function (file) {
				const cleanPath = cleanFilePath(file.path);
				const fileHash = getBaseHash(cleanPath, file);

				const fileDeps = new Map();
				let fileDepsIdentifier = "";
				if (isText(file.path, file.contents)) {
					// Iterate through all other browser assets this file links to
					const matches = String(file.contents).matchAll(resourceMacroRegex);
					for (const match of matches) {
						const matchPath = match[1];
						const matchPathFull = path.join(__dirname, dirs.src, matchPath);

						if (!fs.existsSync(matchPathFull)) {
							console.warn(`Missing resource in ${cleanPath}: ${matchPath}`);
							continue;
						}

						const matchHash = getBaseHash(matchPath, getFile(matchPathFull));
						fileDeps.set(matchPath, matchHash);
						fileDepsIdentifier += matchHash.path;
					}
				}

				const manifestEntry = {
					path: fileHash.path,
					name: fileHash.name,
					deps: fileDeps,
				};

				if (fileDepsIdentifier) {
					// Re-hash the file considering the linked files
					const depsFileHash = performHash(
						hashFormat,
						file,
						fileDepsIdentifier + fileHash.path,
					);
					manifestEntry.path = cleanFilePath(depsFileHash.path);
					manifestEntry.name = depsFileHash.basename;
				}

				manifest.set(cleanPath, manifestEntry);
			})
			.on("finish", function () {
				if (saveManifest) {
					const jsonable = {};
					manifest.forEach(function (val, key) {
						jsonable[key] = `${val.path}?v=${CDN_VERSION}`;
					});
					fs.writeFile(
						`${dirs.dest}/${saveManifest}`,
						JSON.stringify(jsonable, null, 2),
						"utf8",
						() => {},
					);
				}

				resolve(manifest);
			});
	});
}

async function clean(cb) {
	await deleteAsync(dirs.dest);
	fs.mkdir(dirs.dest, cb);
}

async function manifest(cb) {
	buildManifest = await generateManifest(sources.all, "manifest.json");
}

async function generateTguiManifest(cb) {
	await generateManifest(sources.tguiManifest, "tgui-manifest.json");
}

function html(cb) {
	return src(sources.html, { nocase: true, ignore: ignoreSources })
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
	return src(sources.styles, { nocase: true, ignore: ignoreSources })
		.pipe(macroReplacer())
		.pipe(postcss([autoprefixer(), cssnano()]))
		.pipe(rename(hashRenamer))
		.pipe(dest(dirs.dest + "/css"));
}

function javascript(cb) {
	return src(sources.scripts, { nocase: true, ignore: ignoreSources })
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
	return src(sources.copyable, {
		encoding: false,
		nocase: true,
		ignore: ignoreSources,
	})
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
