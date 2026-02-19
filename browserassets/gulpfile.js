import fs from 'fs';
import path from 'path';
import { compose } from 'node:stream';
import { fileURLToPath } from 'url';
import { series, parallel, src, dest } from 'gulp';
import { deleteAsync } from 'del';
import replace from 'gulp-replace';
import htmlmin from 'gulp-htmlmin';
import postcss from 'gulp-postcss';
import autoprefixer from 'autoprefixer';
import postcssClean from 'postcss-clean';
import postcssSimpleVars from 'postcss-simple-vars';
import postcssNesting from 'postcss-nesting';
import rename from 'gulp-rename';
import { isText } from 'istextorbinary';
import vinyl from 'vinyl';
import dotenv from 'dotenv';
import performHash from './gulp-hash-filename/performHash.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

dotenv.config({
  path: `.env.${process.env.NODE_ENV || 'development'}`,
  quiet: true,
});

// Import gulp-uglify-es dynamically in an async function to avoid top-level await
let uglify;
(async () => {
  uglify = (await import('gulp-uglify-es')).default.default;
})();

const CDN_VERSION = process.env.CDN_VERSION || 1;
const CDN_BASE_URL =
  process.env.CDN_BASE_URL || 'https://cdn-main1.goonhub.com';

// Build Directories
const dirs = {
  src: 'src',
  dest: 'build',
};

// File Sources
const sources = {
  all: `${dirs.src}/**/*.*`,
  styles: `${dirs.src}/css/**/*.css`,
  html: `${dirs.src}/html/**/*.(html|htm)`,
  scripts: `${dirs.src}/js/**/*.js`,
  // Files that require no special processing
  copyable: `${dirs.src}/(html/tooltips|css/fonts|images|misc|tgui|vendor)/**/*.*`,
  // Files that tgui includes via resource() calls
  tguiManifest: `${dirs.src}/images/**/*.*`,
};

// A list of glob patterns we ignore from all sources
const ignoreSources = ['**/*.md'];

// Replace {{resource(path/to/file)}} in files with proper CDN URLs
const resourceMacroRegex = /\{\{resource\([\"']?(.*?)[\"']?\)\}\}/gi;

// Replace {{CDN_VERSION}} in files with the current CDN version
const cdnVersionRegex = /{{.?CDN_VERSION.?}}/gi;

const hashFormat = `{name}.{hash:8}{ext}`;

let buildManifest = new Map();

function cleanFilePath(filePath) {
  return filePath
    .replace(path.join(__dirname, dirs.src, '/'), '')
    .replaceAll('\\', '/');
}

function macroReplacer() {
  const resources = replace(
    resourceMacroRegex,
    function handleReplace(m, filePath) {
      if (buildManifest.has(filePath)) {
        const manifestEntry = buildManifest.get(filePath);
        filePath = manifestEntry.path;
      }
      return `${CDN_BASE_URL}/${filePath}?v=${CDN_VERSION}`;
    }
  );
  const cdnVersions = replace(cdnVersionRegex, CDN_VERSION);
  return compose(resources, cdnVersions);
}

function hashRenamer(filePath, file) {
  const manifestEntry = buildManifest.get(cleanFilePath(file.path));
  if (manifestEntry) {
    filePath.basename = path.basename(
      manifestEntry.name,
      path.extname(manifestEntry.name)
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
      .on('data', function (file) {
        const cleanPath = cleanFilePath(file.path);
        const fileHash = getBaseHash(cleanPath, file);

        const fileDeps = new Map();
        let fileDepsIdentifier = '';
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
            fileDepsIdentifier + fileHash.path
          );
          manifestEntry.path = cleanFilePath(depsFileHash.path);
          manifestEntry.name = depsFileHash.basename;
        }

        manifest.set(cleanPath, manifestEntry);
      })
      .on('finish', function () {
        if (saveManifest) {
          const jsonable = {};
          manifest.forEach(function (val, key) {
            jsonable[key] = `${val.path}?v=${CDN_VERSION}`;
          });
          fs.writeFile(
            `${dirs.dest}/${saveManifest}`,
            JSON.stringify(jsonable, null, 2),
            'utf8',
            () => {}
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
  buildManifest = await generateManifest(sources.all, 'manifest.json');
}

async function generateTguiManifest(cb) {
  await generateManifest(sources.tguiManifest, 'tgui-manifest.json');
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
      })
    )
    .pipe(rename(hashRenamer))
    .pipe(dest(dirs.dest + '/html'));
}

function css(cb) {
  return src(sources.styles, { nocase: true, ignore: ignoreSources })
    .pipe(macroReplacer())
    .pipe(postcss([postcssSimpleVars(), postcssNesting(), autoprefixer()]))
    .pipe(postcss([postcssClean()]))
    .pipe(rename(hashRenamer))
    .pipe(dest(dirs.dest + '/css'));
}

function javascript(cb) {
  return src(sources.scripts, { nocase: true, ignore: ignoreSources })
    .pipe(macroReplacer())
    .pipe(
      uglify({
        mangle: {
          reserved: ['$', 'exports', 'require'],
        },
        compress: true,
      })
    )
    .pipe(rename(hashRenamer))
    .pipe(dest(dirs.dest + '/js'));
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

function dev(cb) {
  fs.copyFileSync(`${dirs.dest}/manifest.json`, '../cdn-manifest.json');
  cb();
}

export const tguiManifest = series(clean, generateTguiManifest);

tguiManifest.displayName = 'tgui:manifest';
tguiManifest.description = 'Generate a manifest for TGUI';

export const build = series(
  clean,
  manifest,
  parallel(html, css, javascript),
  copy
);

build.description = 'Build CDN Assets';

export const buildDev = series(build, dev);

buildDev.displayName = 'build:dev';
buildDev.description = 'Build CDN Assets for Development';
