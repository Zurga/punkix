import { Encoder, Decoder } from "@msgpack/msgpack";
import PunkixHooks from "../_hooks";

const encoder = new Encoder({ ignoreUndefined: true });
const decoder = new Decoder();

const encode =  (payload, callback) => {
		// This is needed for fileUpload to work
		if (payload.payload instanceof ArrayBuffer) {
			payload.payload = new Uint8Array(payload.payload);
		}
		callback(encoder.encode(payload));
	}
const	decode = (payload, callback) => callback(decoder.decode(payload))
export {encode, decode, PunkixHooks};
