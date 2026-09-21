// © Mayanktaker Computers & Web Development | https://mayanktaker.com
// Plain-assert smoke tests for the GJS port of the console API logic

import * as Api from '../api.js';

// Minimal assert helpers so gjs runs without any dependency
let failures = 0;
function ok(cond, msg) {
    if (!cond) { console.error('FAIL: ' + msg); failures++; }
}
function eq(a, b, msg) { ok(a === b, msg + ' (got ' + JSON.stringify(a) + ', want ' + JSON.stringify(b) + ')'); }

// --- cookie normalization ---
eq(Api.buildCookieHeader('st_abcdefghijklmnopqrstuvwxyz'), '__Host-console_session=st_abcdefghijklmnopqrstuvwxyz', 'bare token wrapped with host cookie');
eq(Api.buildCookieHeader('abc=='), '__Host-console_session=abc==', 'bare token with padding still wrapped whole');
eq(Api.buildCookieHeader('Fe26.2**abc'), 'auth=Fe26.2**abc', 'legacy iron seal mapped to auth');
eq(Api.buildCookieHeader('__Host-console_session=x; console_session=y'), '__Host-console_session=x; console_session=y', 'full header passthrough');
eq(Api.buildCookieHeader('"__Host-console_session=x"'), '__Host-console_session=x', 'devtools quotes stripped');

// --- validation ---
ok(Api.checkCookieError('st_abcdefghijklmnopqrstuvwxyz') === '', 'valid cookie passes');
ok(Api.checkCookieError('short') !== '', 'short cookie rejected');
ok(Api.checkWorkspaceIdError('wrk_abc') === '', 'wrk id valid');
ok(Api.checkWorkspaceIdError('xyz') !== '', 'bad workspace rejected');

// --- status marker split uses LAST occurrence ---
let split = Api.splitHttpStatus('{"a":"HTTPSTATUS:200"}HTTPSTATUS:404');
eq(split.httpStatus, 404, 'last marker wins');
eq(split.body, '{"a":"HTTPSTATUS:200"}', 'body preserved before last marker');

// --- percentage mirrors the console formula ---
eq(Api.meterPercent(0, 10), 0, 'zero usage is zero');
eq(Api.meterPercent(5, 10), 50, 'half is half');
eq(Api.meterPercent(999, 10), 100, 'clamped to 100');
eq(Api.meterPercent(5, 0), 0, 'no limit means zero');

// --- console JSON parsing ---
let payload = {
    access: {
        endsAt: '2030-01-01T00:00:00Z',
        meters: {
            fiveHour: { usedMicroCents: '125000000', limitMicroCents: '500000000', resetsAt: '2030-01-01T01:00:00Z' },
            week: { usedMicroCents: '250000000', limitMicroCents: '1000000000', resetsAt: '2030-01-01T00:00:00Z' },
            month: { usedMicroCents: '2500000000', limitMicroCents: '10000000000' }
        }
    }
};
let model = Api.parseCurlOutput(JSON.stringify(payload), '', 0);
eq(model.error, null, 'console payload parses without error');
eq(model.data.usagePercent, 25, 'weekly headline percent from micro-cents');
eq(model.data.weekly[0].value, 25, 'weekly bar value');
eq(model.data.monthly[0].value, 25, 'monthly bar value');
ok(model.data.resetSeconds.monthly > 0, 'monthly reset from access.endsAt');

// --- tagged error responses ---
let authBody = JSON.stringify({ _tag: 'Unauthorized' });
eq(Api.parseCurlOutput(authBody, '', 0).error, 'Auth Cookie is invalid or expired. Please update Auth Cookie in settings.', '401 tag message');
eq(Api.parseCurlOutput('{"_tag":"BadRequest"}', '', 0).error, 'Console API rejected the request (400) — check the Workspace ID.', '400 tag message');

// --- 404 route walk signal and 5xx retry signal ---
eq(Api.parseCurlOutput('', '', 0).httpStatus, 404, 'empty body treated as 404 route-moved');
eq(Api.parseCurlOutput('HTTPSTATUS:500', '', 0).httpStatus, 500, '5xx surfaced for in-place retry');

// --- curl command shape ---
let cmd = Api.buildCurlCommand('wrk_x', 'st_abcdefghijklmnop', 0);
ok(cmd.indexOf('x-org-id') !== -1 && cmd.indexOf('wrk_x') !== -1, 'curl carries org header');
ok(cmd.indexOf('--max-time 15') !== -1, 'curl bounded at 15s');
ok(cmd.indexOf("'") !== -1, 'shell-quoted arguments present');

// --- demo mode ---
let mock = Api.getMockData();
ok(mock.isMock === true && mock.weekly.length > 0, 'mock data shaped for demo mode');

// --- reset formatting ---
eq(Api.formatResetFull(0), '', 'zero reset renders empty');
ok(Api.formatResetFull(13500).indexOf('hour') !== -1, 'hours shown in countdown');

// Summary and exit code for the runner
if (failures > 0) {
    console.error(failures + ' test(s) failed');
    throw new Error(failures + ' test(s) failed');
} else {
    print('All api tests passed');
}
