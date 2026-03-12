import stream from 'stream';
import performHash from './performHash.js';

export default function hashFileName(options) {
  const assemblyStream = new stream.Transform({ objectMode: true });
  let opts = options;
  if (!opts || typeof opts !== 'object') {
    opts = {};
  }

  const format = opts.format || '{name}-{hash}{ext}';

  assemblyStream._transform = function (file, unused, callback) {
    this.push(performHash(format, file));
    callback();
  };

  return assemblyStream;
}
