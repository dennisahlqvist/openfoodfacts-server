/*eslint no-console: "off"*/
/*eslint no-await-in-loop: "off"*/

const process = require('process');
const util = require('util');
const glob = util.promisify(require('glob').glob);
const execFile = util.promisify(require('child_process').execFile);

async function main() {
  // 0 = node; 1 = check_perl.js
  for (const arg of process.argv.slice(2)) {
    const files = await glob(arg);
    for (var i = 0; i < files.length; ++i) {
      const path = files[i];
      console.log(`Checking ${path}`);
      try {
        const { stdout, stderr } = await execFile(`perl`, ['-c', '-CS', '-Ilib', files[i]]);
        if (stderr) {
          console.error(stderr);
        }

        console.log(stdout);
      } catch (e) {
        console.error(e);
        process.exitCode = e.code;
        throw e;
      }
    }
  }

  console.log('Done!');
}

main();
