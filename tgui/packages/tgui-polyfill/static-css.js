/**
 * This script processes all CSS files in a given directory, polyfilling CSS variables & prefixing.
 *
 * Usage: node polyfill-css.js <directory>
 *
 * @module polyfill-css
 *
 * @param {string} dir - The (relative to this folder) directory containing CSS files to process.

 * @example
 * // Run the script with a directory containing CSS files
 * // yarn tgui-polyfill:static-css ..\..\..\browserassets\src\vendor\css\tgui\
 */
const { readdirSync, readFile, writeFile } = require('fs');
const { extname, join } = require('path');
const postcss = require('postcss');
const cssVariables = require('postcss-css-variables');
const autoprefixer = require('autoprefixer');

const dir = process.argv[2];
const files = readdirSync(dir);

files
  .filter((file) => extname(file) === '.css')
  .forEach((file) => {
    const filePath = join(dir, file);
    readFile(filePath, 'utf8', (err, css) => {
      if (err) {
        console.error(`Error reading ${filePath}:`, err);
        return;
      }
      postcss([
        cssVariables(),
        autoprefixer({ overrideBrowserslist: ['ie 11'] }),
      ])
        .process(css, { from: filePath, to: filePath })
        .then((result) => {
          writeFile(filePath, result.css, (err) => {
            if (err) {
              console.error(`Error writing ${filePath}:`, err);
              return;
            }
            console.log(`Processed ${filePath}`);
          });
        })
        .catch((err) => {
          console.error(`Error processing ${filePath}:`, err);
        });
    });
  });
