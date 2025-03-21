export default function formatStr(text, ...params) {
	let re = /\{(([^}]+)|(\d+))\}/gm;

	if (params.length > 0) {
		if (params.length === 1 && typeof params[0] === "object") {
			params = params[0];
			//re = reObj;
		} else {
			//re = reNum;
		}

		text = text.replace(re, (item) => {
			const [key, length = 0] = item.slice(1, -1).trim().split(":");

			let temp = params[key];

			if (temp != null) {
				if (length > 0) {
					temp = temp.substr(0, length);
				}
				return temp;
			}
			return item;
		});
	}

	return text;
}
