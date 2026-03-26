const http = require('http');
const { execFile } = require('child_process');

const PORT = Number(process.env.SMS_BRIDGE_PORT || 9099);
const SERIAL = process.env.EMULATOR_SERIAL || 'emulator-5554';
const ADB_PATH = process.env.ADB_PATH || 'C:/Users/LENOVO/AppData/Local/Android/Sdk/platform-tools/adb.exe';

function send(res, code, payload) {
  res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
}

function injectSms({ sender, message }, callback) {
  const args = ['-s', SERIAL, 'emu', 'sms', 'send', sender, message];
  execFile(ADB_PATH, args, { windowsHide: true }, (error, stdout, stderr) => {
    if (error) {
      callback(error, { stdout: stdout || '', stderr: stderr || '' });
      return;
    }

    const output = `${stdout || ''}${stderr || ''}`;
    callback(null, { output });
  });
}

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/health') {
    send(res, 200, { ok: true, service: 'emulator_sms_bridge', serial: SERIAL });
    return;
  }

  if (req.method !== 'POST' || req.url !== '/inject') {
    send(res, 404, { ok: false, message: 'Not found' });
    return;
  }

  let body = '';
  req.on('data', chunk => {
    body += chunk;
    if (body.length > 100000) {
      send(res, 413, { ok: false, message: 'Payload too large' });
      req.destroy();
    }
  });

  req.on('end', () => {
    try {
      const data = JSON.parse(body || '{}');
      const sender = String(data.sender || '').trim();
      const message = String(data.message || '').trim();

      if (!sender || !message) {
        send(res, 400, { ok: false, message: 'sender and message are required' });
        return;
      }

      injectSms({ sender, message }, (error, result) => {
        if (error) {
          send(res, 500, {
            ok: false,
            message: 'Failed to inject SMS into emulator',
            detail: (result && (result.stderr || result.stdout)) || String(error),
          });
          return;
        }

        send(res, 200, { ok: true, serial: SERIAL, result: result.output || 'OK' });
      });
    } catch (e) {
      send(res, 400, { ok: false, message: 'Invalid JSON body' });
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`SMS bridge running at http://0.0.0.0:${PORT}`);
  console.log(`Target emulator: ${SERIAL}`);
  console.log(`ADB path: ${ADB_PATH}`);
});
