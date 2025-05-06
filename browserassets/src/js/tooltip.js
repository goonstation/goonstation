function boutput(msg) {
	BYOND.winset(0, {
		command: `.output browseroutput:output "${encodeURIComponent(msg)}"`,
	});
}

function callByond(params, src) {
	src = src || window.tooltip_config.ref;
	const arrayParams = [`src=${src}`, `from_tooltip=1`];
	if (typeof params === "object") {
		for (const param in params) {
			arrayParams.push(`${param}=${encodeURIComponent(params[param])}`);
		}
	} else if (typeof params === "string") {
		arrayParams.push(params);
	}
	window.location = `byond://?${arrayParams.join("&")}`;
}

function handleError(message) {
	callByond({ action: "error", message });
}

window.addEventListener("error", (e) => {
	handleError(e.error?.message || e?.message);
});

window.addEventListener("unhandledrejection", (e) => {
	handleError(e.reason.stack);
});

class TooltipPerformanceTracking {
	timings = new Map();
	created = null;

	create() {
		this.timings.clear();
		this.created = performance.now();
	}

	start(label, caller) {
		const id = this.timings.size + 1;
		caller = caller.split(".");
		this.timings.set(id, {
			label,
			start: performance.now(),
			caller: caller[0] === "Tooltip" ? caller[1] : "",
		});
		return id;
	}

	end(id) {
		const timing = this.timings.get(id);
		if (!timing) return;
		this.timings.set(id, {
			...timing,
			duration: performance.now() - timing.start,
		});
	}

	round(num) {
		return num ? num.toFixed(2) : 0;
	}

	report() {
		let html = `
		<style>
			.tooltip-perf-report {
				border-collapse: collapse;
			}
			.tooltip-perf-report,
			.tooltip-perf-report th,
			.tooltip-perf-report td {
				border: 1px solid;
			}
			.tooltip-perf-report th,
			.tooltip-perf-report td {
				padding: 2px 10px;
			}
		</style>
		<table class="tooltip-perf-report">
			<thead>
				<tr>
					<th colspan="100%">Tooltip Performance Report</th>
				</tr>
				<tr>
					<th>Function</th>
					<th>Duration</th>
				</tr>
			</thead>
			<tbody>`;

		const findTiming = (label) => {
			let item = null;
			this.timings.forEach((timing) =>
				timing.label === label ? (item = timing) : null,
			);
			return item;
		};

		const getIndent = (timing) => {
			let indent = 0;
			while (timing.caller) {
				timing = findTiming(timing.caller);
				if (timing) indent++;
			}
			return indent;
		};

		this.timings.forEach((timing) => {
			const indent = getIndent(timing) * 20;
			html += `<tr>
				<td style="padding-left: ${indent || 10}px;">${timing.label}</td>
				<td>${this.round(timing.duration)}ms</td>
			</tr>`;
		});

		html += `<tr>
			<td><strong>Total</strong></td>
			<td>${this.round(performance.now() - this.created)}ms</td>
		</tr>`;

		html += `</tbody></table>`;
		boutput(html);
	}
}

class TooltipUI {
	eta = null;
	// cacheStorage = null;
	debug = false;
	options = {};

	constructor(debug = false) {
		this.debug = debug;
		this.eta = new window.eta.Eta();
		// this.cacheStorage = document.getElementById("cache-storage");
	}

	// fetch(resource, options) {
	// 	const promise = new Promise((resolve, reject) => {
	// 		const onMessage = ({ data }) => {
	// 			window.removeEventListener("message", onMessage);
	// 			let response = data.response;
	// 			if (ArrayBuffer[Symbol.species] === response.constructor) {
	// 				const decoder = new TextDecoder("utf-8");
	// 				response = decoder.decode(response);
	// 			}
	// 			if (data.error) reject({ status: data.status });
	// 			else resolve({ response, status: data.status });
	// 		};
	// 		window.addEventListener("message", onMessage);
	// 	});

	// 	if (this.cacheStorage?.contentWindow) {
	// 		this.cacheStorage.contentWindow.postMessage(
	// 			{ type: "fetch", resource, options },
	// 			"*",
	// 		);
	// 		return promise;
	// 	} else {
	// 		return fetch(resource, options).then((response) => {
	// 			if (!response.ok) throw new Error({ status: response.status });
	// 			return { response: response.text(), status: response.status };
	// 		});
	// 	}
	// }

	// async getContent(path) {
	// 	try {
	// 		const res = await this.fetch(path);
	// 		return res.response;
	// 	} catch (e) {
	// 		const err = `Unable to load ${path} (${e.status})`;
	// 		handleError(err);
	// 		throw new Error(err);
	// 	}
	// }

	async getContent(path, key) {
		const cacheKey = `tooltip-${key}`;
		let content = window.domainStorage.getItem(cacheKey);
		if (content && !this.debug) return content;

		const res = await fetch(path);
		if (!res.ok) {
			const err = `Unable to load ${path} (${res.status})`;
			handleError(err);
			throw new Error(err);
		}
		content = await res.text();
		if (content) window.domainStorage.setItem(cacheKey, content);
		return content;
	}

	async build(options) {
		this.options = options;
		const content = await this.getContent(options.file_resource, options.file);
		if (!content) return;
		return this.eta.renderString(content, options.data);
	}
}

class Tooltip {
	global = {};
	showing = false;
	hiding = false;
	moveTimeout = null;
	tracking = null;

	world = {};
	client = {};
	map = {};
	scaled = {};
	size = {};
	target = {};
	offsets = {};

	UIBuilder = null;
	$root = null;
	$wrap = null;

	constructor(options, args) {
		this.global = options;
		if (this.global.debug) this.tracking = new TooltipPerformanceTracking();
		this.options = args.options;
		this.world = args.world;
		this.client = args.client;

		this.UIBuilder = new TooltipUI(this.global.debug);
		this.$root = document.querySelector(":root");
		this.$wrap = document.getElementById("tt-wrap");
	}

	hookBefore(method) {
		if (this.isHiding()) return false;
		if (this.tracking) {
			const caller = new Error().stack?.split("\n")[3]?.trim()?.split(" ")[1];
			if (!caller) return true;
			const invokation = this.tracking.start(method, caller);
			return invokation;
		}
		return true;
	}

	hookAfter(method, invokation) {
		if (this.tracking) this.tracking.end(invokation);
	}

	onFinished() {
		if (this.tracking) this.tracking.report();
	}

	isHiding() {
		if (this.hiding) {
			this.moveTimeout && clearTimeout(this.moveTimeout);
			return true;
		}
		return false;
	}

	elementIsInteractive(el) {
		return ["input", "textarea", "select", "option"].includes(
			el.nodeName.toLowerCase(),
		);
	}

	onContentClick(e) {
		if (!this.elementIsInteractive(e.target)) {
			this.focusMap();
		}
	}

	onCloseClick(e) {
		e.preventDefault();
		e.stopPropagation();
		this.focusMap();
		this.hide();
	}

	onKeyDown(e) {
		if (!this.elementIsInteractive(e.target)) {
			this.focusMap();
			if (e.key === "Escape") {
				this.hide();
			}
		}
	}

	onSrcClick(e) {
		e.preventDefault();
		this.focusMap();
		const src = this.options.content?.data?.src;
		if (!src) return;
		let params = ``;
		const call = e.target.dataset.callSrc;
		if (call) {
			if (call === "href") params += e.target.getAttribute(call);
			else params += call;
		}
		callByond(params, src);
	}

	async getMapSizes() {
		return await BYOND.winget(this.global.mapControlId, ["size", "view-size"]);
	}

	async setMapSizes() {
		const mapSizes = await this.getMapSizes();
		this.map.pane = mapSizes["size"];
		this.map.view = mapSizes["view-size"];

		// Determine how many icons are displayed on the users map
		this.map.icons = {
			x: Math.min(this.client.view.x * 2 + 1, this.world.maxx),
			y: Math.min(this.client.view.y * 2 + 1, this.world.maxy),
		};

		// Determine how much map icons are stretched
		this.map.scale = {
			width: this.map.view.x / this.client.bounds.width,
			height: this.map.view.y / this.client.bounds.height,
		};

		// Constrain scale to lowest axis value (aka assume icons maintain aspect ratio when stretched)
		if (this.map.scale.width < this.map.scale.height)
			this.map.scale.height = this.map.scale.width;
		else this.map.scale.width = this.map.scale.height;

		// Determine if the map view has been expanded (e.g. by HUD icon offsets like NORTH+1)
		const extraWidth = Math.round(
			this.map.view.x / this.map.scale.width - this.client.bounds.width,
		);
		if (extraWidth) {
			this.map.icons.x += Math.ceil(extraWidth / this.world.icon_size.width);
		}

		const extraHeight = Math.round(
			this.map.view.y / this.map.scale.height - this.client.bounds.height,
		);
		if (extraHeight) {
			this.map.icons.y += Math.ceil(extraHeight / this.world.icon_size.height);
		}
	}

	async setContent() {
		// The clone places the old content over the new content while it renders
		// which avoids a "flash" of an empty tooltip during this process
		const $wrapClone = this.$wrap.cloneNode(true);
		$wrapClone.removeAttribute("id");
		$wrapClone.classList.add("tt-wrap-clone");
		this.$wrap.insertAdjacentElement("afterend", $wrapClone);

		this.$wrap.replaceChildren();
		this.$wrap.style.setProperty("--map-width", `${this.map.pane.x}px`);
		this.$wrap.style.setProperty("--map-height", `${this.map.pane.y}px`);
		this.$wrap.style.setProperty(
			"--scaling-factor",
			Math.min(this.map.scale.width, this.map.scale.height),
		);
		this.$wrap.style.setProperty("--dpr", window.devicePixelRatio);
		this.$wrap.setAttribute("data-theme", this.options.theme || "default");

		let title = this.options.title;
		let content = this.options.content;
		let showError = !title && !content;

		const $wrapContent = document.createElement("div");
		$wrapContent.classList.add("tt-content");
		this.$wrap.append($wrapContent);

		if (content && typeof content === "object") {
			try {
				content = await this.UIBuilder.build(content);
			} catch {
				showError = true;
			}
		}

		if (showError) {
			title = "Error";
			content = `<div class="box" style="margin-bottom: 0; text-align: center;">
				Unable to display tooltip
			</div>`;
			this.$wrap.setAttribute("data-theme", "error");
		}

		const $title = document.createElement("h1");
		if (title) $title.innerHTML = `<span>${title}</span>`;
		if (this.options.pinned) {
			const $close = document.createElement("button");
			$close.setAttribute("type", "button");
			$close.setAttribute("data-close-tooltip", true);
			$close.classList.add("tt-close");
			$close.innerHTML = `&#10005;`;
			$title.append($close);
		}
		$wrapContent.append($title);

		if (content) {
			const $content = document.createElement("div");
			$content.innerHTML = content;
			$wrapContent.append($content);
		}

		document.title = title || "Tooltip";
		const box = $wrapContent.getBoundingClientRect();
		$wrapClone.remove();
		this.size = {
			width: Math.ceil(box.width * window.devicePixelRatio),
			height: Math.ceil(box.height * window.devicePixelRatio),
		};
	}

	/*
    | xx yx xo | = | a b c |
    | xy yy yo |   | d e f |
  */
	transformPoint(x, y) {
		const matrix = this.options.transform;
		return {
			x: matrix[0] * x + matrix[1] * y + matrix[2],
			y: matrix[3] * x + matrix[4] * y + matrix[5],
		};
	}

	getPosition() {
		// Gather point coordinates for each corner
		const corners = [
			[-(this.options.bounds.width / 2), -(this.options.bounds.height / 2)], // bl
			[this.options.bounds.width / 2, -(this.options.bounds.height / 2)], // br
			[this.options.bounds.width / 2, this.options.bounds.height / 2], // tr
			[-(this.options.bounds.width / 2), this.options.bounds.height / 2], // tl
		];

		// Transform each corner point and group them by axis
		const edges = { x: [], y: [] };
		for (const corner of corners) {
			const point = this.transformPoint(corner[0], corner[1]);
			edges.x.push(point.x);
			edges.y.push(point.y);
		}

		// Determine the resultant bounds
		this.scaled.bounds = {
			top: Math.max(...edges.y),
			bottom: Math.min(...edges.y),
			left: Math.min(...edges.x),
			right: Math.max(...edges.x),
		};

		// Get the real dimensions considering transformation
		this.scaled.width = this.scaled.bounds.right - this.scaled.bounds.left;
		this.scaled.height = this.scaled.bounds.top - this.scaled.bounds.bottom;

		// Top left of tile the mouse entered into
		// (unscaled map pixels)
		let target = {
			x:
				this.options.mouse.left.tiles * this.world.icon_size.width -
				this.world.icon_size.width,
			y:
				(this.map.icons.y - this.options.mouse.bottom.tiles) *
					this.world.icon_size.height +
				this.world.icon_size.height,
		};

		// Cumulative pixel offsets to apply to the target position later
		// (real screen pixels, not unscaled map pixels)
		let offsets = {
			x: Math.min((this.map.pane.x - this.map.view.x) / 2, 0),
			y: Math.min((this.map.pane.y - this.map.view.y) / 2, 0),
		};

		// Apply letterbox offsets
		offsets.x += Math.max((this.map.pane.x - this.map.view.x) / 2, 0);
		offsets.y += Math.max((this.map.pane.y - this.map.view.y) / 2, 0);

		// Move to the center of the object, considering scale
		const leftMousePos = isNaN(this.options.mouse.left.vis)
			? this.options.mouse.left.icon
			: this.options.mouse.left.vis;
		const bottomMousePos = isNaN(this.options.mouse.bottom.vis)
			? this.options.mouse.bottom.icon
			: this.options.mouse.bottom.vis;
		target.x +=
			this.options.mouse.left.pixels - leftMousePos + this.scaled.width / 2;
		target.y +=
			bottomMousePos -
			this.options.mouse.bottom.pixels -
			this.scaled.height / 2;

		// Apply user size overrides
		if (this.options.size?.width)
			this.size.width = parseInt(this.options.size.width);
		if (this.options.size?.height)
			this.size.height = parseInt(this.options.size.height);

		// Apply user offsets
		if (this.options.offset?.x) target.x += parseFloat(this.options.offset.x);
		if (this.options.offset?.y) target.y += parseFloat(this.options.offset.y);
		if (Object.entries(this.options.offset?.tiles).length) {
			for (const dir in this.options.offset.tiles) {
				const tiles = parseInt(this.options.offset.tiles[dir]);
				if (dir === "up") target.y -= tiles * this.world.icon_size.height;
				else if (dir === "down")
					target.y += tiles * this.world.icon_size.height;
				else if (dir === "left") target.x -= tiles * this.world.icon_size.width;
				else if (dir === "right")
					target.x += tiles * this.world.icon_size.width;
			}
		}

		// Little margins to push the tooltip away from the target slightly
		const margins = { x: 2, y: 2 };

		// Determine where to place the tooltip around the target
		this.options.align = this.options.align || { x: "left", y: "bottom" };
		if (this.options.align.y === "top") {
			// Align bottom edge of tooltip to top edge of target
			target.y -= this.scaled.height / 2 + margins.y;
			offsets.y -= this.size.height;
		} else if (this.options.align.y === "bottom") {
			// Align top edge of tooltip to bottom edge of target
			target.y += this.scaled.height / 2 + margins.y;
		} else if (this.options.align.y === "center") {
			// Align vertical middle of tooltip to middle of target
			offsets.y -= this.size.height / 2;
		}

		if (this.options.align.x === "left") {
			// Align left edge of tooltip to left edge of target
			target.x -= this.scaled.width / 2;
			if (this.options.align.y !== "top" && this.options.align.y !== "bottom") {
				// Align right edge of tooltip to left edge of target
				offsets.x -= this.size.width;
				target.x -= margins.x;
			}
		} else if (this.options.align.x === "right") {
			if (this.options.align.y === "top" || this.options.align.y === "bottom") {
				// Align right edge of tooltip to right edge of target
				target.x += this.scaled.width / 2;
				offsets.x -= this.size.width;
			} else {
				// Align left edge of tooltip to right edge of target
				target.x += this.scaled.width / 2 + margins.x;
			}
		} else if (this.options.align.x === "center") {
			// Align horizontal middle of tooltip to middle of target
			offsets.x -= this.size.width / 2;
		}

		this.target = { ...target };
		this.offsets = { ...offsets };

		// Where to position the tooltip, in scaled pixels relative to screen map view
		const pos = {
			x: target.x * this.map.scale.width + offsets.x,
			y: target.y * this.map.scale.height + offsets.y,
		};

		// Avoid overflowing outside the map area
		const overflow = {
			left: pos.x < 0 ? pos.x * -1 : 0,
			top: pos.y < 0 ? pos.y * -1 : 0,
			right: pos.x + this.size.width - this.map.pane.x,
			bottom: pos.y + this.size.height - this.map.pane.y,
		};
		if (overflow.left > 0) pos.x = 0;
		if (overflow.top > 0) pos.y = 0;
		if (overflow.right > 0) pos.x -= overflow.right;
		if (overflow.bottom > 0) pos.y -= overflow.bottom;

		return pos;
	}

	attachEvents() {
		if (this.options.pinned) {
			this.$wrap.querySelectorAll("[data-close-tooltip]").forEach((el) => {
				el.addEventListener("click", this.onCloseClick.bind(this));
			});

			this.$wrap.firstElementChild.addEventListener(
				"click",
				this.onContentClick.bind(this),
			);
		}

		this.$wrap.firstElementChild.addEventListener(
			"keydown",
			this.onKeyDown.bind(this),
		);

		this.$wrap.querySelectorAll("[data-call-src]").forEach((el) => {
			el.addEventListener("click", this.onSrcClick.bind(this));
		});
	}

	position(size, pos) {
		const $wrapContent = this.$wrap.firstElementChild;
		$wrapContent.style.setProperty("width", `${this.size.width}px`);
		$wrapContent.style.setProperty("height", `${this.size.height}px`);

		BYOND.winset(this.global.windowId, {
			isVisible: true,
			size: `${size.width}x${size.height}`,
			pos: `${pos.x},${pos.y}`,
		});
		callByond({ action: "showing" });
		this.showing = true;
	}

	async show() {
		await this.setMapSizes();
		await this.setContent();
		const pos = this.getPosition();
		this.attachEvents();
		this.position(this.size, pos);
	}

	async update(args) {
		this.options = args.options;
		await this.setContent();
		const pos = this.getPosition();
		this.attachEvents();
		this.position(this.size, pos);
	}

	// move({ startingPos, endingPos, fps, glide_size, glide }) {
	// 	const diffs = {
	// 		x: endingPos.x - startingPos.x,
	// 		y: endingPos.y - startingPos.y,
	// 	};

	// 	function splitInt(num, parts, start, end, invert = false) {
	// 		const rem = num % parts;
	// 		const div = (num - rem) / parts;
	// 		return new Array(parts)
	// 			.fill(div)
	// 			.fill(div + 1, parts - rem)
	// 			.map((v, i) => {
	// 				let frame = start + (invert ? v * -1 : v) * (i + 1);
	// 				if (invert) frame = Math.max(frame, end);
	// 				else frame = Math.min(frame, end);
	// 				return frame;
	// 			});
	// 	}

	// 	const frameCounts = {
	// 		x: Math.ceil(Math.abs(diffs.x / glide.x)) || 0,
	// 		y: Math.ceil(Math.abs(diffs.y / glide.y)) || 0,
	// 		total: 0,
	// 	};
	// 	frameCounts.total = Math.max(frameCounts.x, frameCounts.y);
	// 	// const totalDuration = (1 / fps) * frameCounts.total * 1000; // in ms
	// 	const totalDuration = glide_size * 10; // in ms
	// 	const minFrameDuration = 1; // in ms
	// 	let frameDuration = totalDuration / frameCounts.total;
	// 	if (frameDuration < minFrameDuration) {
	// 		frameCounts.total = Math.floor(totalDuration / minFrameDuration);
	// 		frameDuration = totalDuration / frameCounts.total;
	// 	}

	// 	const axisFrames = {
	// 		x: splitInt(
	// 			Math.abs(diffs.x),
	// 			frameCounts.total,
	// 			startingPos.x,
	// 			endingPos.x,
	// 			diffs.x < 0,
	// 		),
	// 		y: splitInt(
	// 			Math.abs(diffs.y),
	// 			frameCounts.total,
	// 			startingPos.y,
	// 			endingPos.y,
	// 			diffs.y < 0,
	// 		),
	// 	};

	// 	const partialMove = (frame = 0) => {
	// 		BYOND.winset(this.global.windowId, {
	// 			pos: `${axisFrames.x[frame]},${axisFrames.y[frame]}`,
	// 		});
	// 		if (frame < frameCounts.total - 1) {
	// 			this.moveTimeout = setTimeout(() => {
	// 				partialMove(frame + 1);
	// 			}, frameDuration);
	// 		}
	// 	};

	// 	partialMove();
	// }

	hide() {
		if (this.hiding) return;
		this.showing = false;
		this.hiding = true;
		BYOND.winset(this.global.windowId, { isVisible: false });
		callByond({ action: "hidden" });
	}

	focusMap() {
		BYOND.winset(this.global.mapControlId, { focus: true });
	}
}

class TooltipOrchestrator {
	options = {};
	pool = new Set();

	constructor() {
		this.options = window.tooltip_config;

		if (document.readyState === "loading") {
			document.addEventListener("DOMContentLoaded", () => {
				this.onLoaded();
			});
		} else {
			this.onLoaded();
		}
	}

	onLoaded() {
		callByond({ action: "loaded" });
	}

	initTooltip(args) {
		const tooltip = new Tooltip(this.options, JSON.parse(args));

		for (const key of Object.getOwnPropertyNames(Tooltip.prototype)) {
			if (
				key === "constructor" ||
				key === "hookBefore" ||
				key === "hookAfter" ||
				key === "isHiding" ||
				key === "onFinished"
			)
				continue;
			if (Tooltip.prototype[key].constructor.name === "AsyncFunction") {
				tooltip[key] = async function (...args) {
					const invokation = tooltip.hookBefore(key);
					if (!invokation) return;
					const ret = await Tooltip.prototype[key].apply(this, args);
					tooltip.hookAfter(key, invokation);
					return ret;
				};
			} else {
				tooltip[key] = function (...args) {
					const invokation = tooltip.hookBefore(key);
					if (!invokation) return;
					const ret = Tooltip.prototype[key].apply(this, args);
					tooltip.hookAfter(key, invokation);
					return ret;
				};
			}
		}

		this.pool.add(tooltip);
		if (this.options.debug) tooltip.tracking.create();
		tooltip.show().then(() => {
			tooltip.onFinished();
		});
	}

	updateTooltip(args) {
		const tooltip = this.findActiveTooltip();
		if (tooltip) {
			if (this.options.debug) tooltip.tracking.create();
			tooltip.update(JSON.parse(args)).then(() => {
				tooltip.onFinished();
			});
		}
	}

	hideTooltips() {
		for (const tooltip of this.pool) {
			tooltip.hide();
			this.pool.delete(tooltip);
		}
	}

	init(args) {
		try {
			this.initTooltip(args);
		} catch (e) {
			handleError(e);
		}
	}

	update(args) {
		try {
			this.updateTooltip(args);
		} catch (e) {
			handleError(e);
		}
	}

	hide() {
		try {
			this.hideTooltips();
		} catch (e) {
			handleError(e);
		}
	}

	findActiveTooltip() {
		for (const tooltip of this.pool) {
			if (tooltip.showing) {
				return tooltip;
			}
		}
	}
}

window.tooltip = new TooltipOrchestrator();
