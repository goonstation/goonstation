import crypto from "crypto";

export default function generateHash(content) {
	const hash = crypto.createHash("md5");
	hash.update(content);
	return hash.digest("hex");
}
