import path from 'path';
import formatStr from './formatStr.js';
import getDateStr from './getDateStr.js';
import generateHash from './generateHash.js';

export default function performHash(format, file, toHash) {
  file = file.clone();
  const ext = path.extname(file.path);
  const fname = path.basename(file.path, ext);
  const dir = path.dirname(file.path);
  const params = {
    name: fname,
    ext: ext,
    hash: generateHash(toHash || file.contents),
    size: file.stat ? file.stat.size : '',
    atime: file.stat && file.stat.atime ? getDateStr(file.stat.atime) : '',
    ctime: file.stat && file.stat.ctime ? getDateStr(file.stat.ctime) : '',
    mtime: file.stat && file.stat.mtime ? getDateStr(file.stat.mtime) : '',
  };
  const fileName = formatStr(format, params);
  file.path = path.join(dir, fileName);
  return file;
}
