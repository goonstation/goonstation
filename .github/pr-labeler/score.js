// Picks area labels (A-*) for a PR
// Uses a basic linear classifier trained against all prior PRs and labels, with a lot of human training I did on top.
// Uses a basic logistic regression and a L2 regularization, plus some tweaks for rare labels.
"use strict";

const { readFileSync } = require("node:fs");
const { join } = require("node:path");

const WORD = /[a-z][a-z0-9]{2,}/g;

// Cuts a common endings off so e.g. "reagents" and "reagent" count as the same word.
function stem(word, suffixes) {
	const suffix = suffixes.find((s) => word.endsWith(s) && word.length - s.length >= 3);
	return suffix ? word.slice(0, -suffix.length) : word;
}

// Pulls words/folders/files from the PR and sorts them.
function features(model, { title, body, files }) {
	const stop = new Set(model.stop);
	const out = new Set();
	const addWords = (text, prefix) => {
		for (const [word] of text.toLowerCase().matchAll(WORD)) {
			if (!stop.has(word)) out.add(prefix + stem(word, model.suffixes));
		}
	};

	for (const file of files) {
		const parts = file.split("/");
		const name = parts.pop();
		for (let depth = 1; depth <= Math.min(parts.length, model.dir_depth); depth++) {
			out.add(`d:${parts.slice(0, depth).join("/")}`);
		}
		const dot = name.lastIndexOf(".");
		out.add(`n:${(dot === -1 ? name : name.slice(0, dot)).toLowerCase()}`);
		out.add(`x:${(dot === -1 ? "" : name.slice(dot + 1)).toLowerCase()}`);
	}

	// The title counts as itself and as part of the description.
	addWords(title ?? "", "w:");
	addWords(title ?? "", "b:");

	// Discard template comments, HTML, and links
	const text = (body ?? "")
		.replace(/<!--[\s\S]*?-->/g, "")
		.replace(/<[^>]*>/g, "")
		.replace(/https?:\/\/\S+/g, "")
		.trim();
	// Only the first 4000 characters
	addWords([...text].slice(0, 4000).join(""), "b:");

	return out;
}

// The vocab is sorted and front-coded to keep it small
// Each entry starts with one char saying how much of the previous name it reuses,
// e.g. "code/datums" followed by "B/controllers" is "code/datums/controllers"
const SHARED_LENGTH = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";

// model.bin is in format: a count, then that many (label index, int8) pairs.
let weights;
function loadWeights(model) {
	if (weights) return weights;
	const bin = readFileSync(join(__dirname, "model.bin"));
	let pos = 0;
	weights = new Map();
	for (const [prefix, names] of Object.entries(model.vocab)) {
		let previous = "";
		for (const entry of names.split("|")) {
			previous = previous.slice(0, SHARED_LENGTH.indexOf(entry[0])) + entry.slice(1);
			const pairs = [];
			for (let count = bin[pos++]; count > 0; count--) {
				pairs.push([bin.readUInt8(pos++), bin.readInt8(pos++) / model.scale]);
			}
			weights.set(`${prefix}:${previous}`, pairs);
		}
	}
	return weights;
}

/**
 * Scores every label and keeps the best `model.k` that clear the threshold (always at least the top one).
 * @returns {{ scores: Record<string, number>, labels: string[] }}
 */
function score(model, pr) {
	const totals = [...model.bias];
	const known = loadWeights(model);
	for (const feature of features(model, pr)) {
		for (const [label, weight] of known.get(feature) ?? []) totals[label] += weight;
	}

	const ranked = model.labels.map((label, i) => [label, totals[i]]).sort((a, b) => b[1] - a[1]);
	const picked = ranked
		.slice(0, model.k)
		.filter(([, total]) => total >= model.threshold_logit)
		.map(([label]) => label);

	return { scores: Object.fromEntries(ranked), labels: picked.length ? picked : [ranked[0][0]] };
}

module.exports = { features, score };
