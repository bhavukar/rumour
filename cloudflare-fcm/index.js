let cachedAccessToken = null;
let tokenExpiresAt = 0;

function pemToBinary(pem) {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

function base64UrlEncode(str) {
  return btoa(str)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function arrayBufferToBase64Url(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return base64UrlEncode(binary);
}

function getServiceAccount(env) {
  if (env && env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    try {
      return JSON.parse(env.FIREBASE_SERVICE_ACCOUNT_JSON);
    } catch (_) {}
  }
  return {
    client_email: (env && env.FIREBASE_CLIENT_EMAIL) || '',
    private_key: (env && env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
    project_id: (env && env.FIREBASE_PROJECT_ID) || 'rumour-anon-chat',
  };
}

async function getGoogleAccessToken(serviceAccount) {
  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && tokenExpiresAt > now + 60) {
    return cachedAccessToken;
  }

  const header = {
    alg: 'RS256',
    typ: 'JWT',
  };

  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const message = `${encodedHeader}.${encodedPayload}`;

  const keyBuffer = pemToBinary(serviceAccount.private_key);
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    keyBuffer,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: { name: 'SHA-256' },
    },
    false,
    ['sign']
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(message)
  );

  const jwt = `${message}.${arrayBufferToBase64Url(signature)}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Failed to exchange JWT for access token: ${res.status} ${errText}`);
  }

  const tokenData = await res.json();
  cachedAccessToken = tokenData.access_token;
  tokenExpiresAt = now + (tokenData.expires_in || 3600);
  return cachedAccessToken;
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type',
        },
      });
    }

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({ status: 'ok', service: 'rumour-fcm' }), {
        headers: { 'Content-Type': 'application/json' },
      });
    }

    if (url.pathname === '/notify' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { roomCode, senderName, senderId, text } = body;

        if (!roomCode || !text) {
          return new Response(JSON.stringify({ error: 'roomCode and text are required' }), {
            status: 400,
            headers: { 'Content-Type': 'application/json' },
          });
        }

        const serviceAccount = getServiceAccount(env);
        const cleanRoom = roomCode.trim().toUpperCase();
        const topic = `room_${cleanRoom}`;
        const accessToken = await getGoogleAccessToken(serviceAccount);

        const fcmPayload = {
          message: {
            topic: topic,
            notification: {
              title: `Room #${cleanRoom}`,
              body: `${senderName || 'Anonymous'}: ${text}`,
            },
            data: {
              roomCode: cleanRoom,
              senderId: senderId || '',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
              priority: 'HIGH',
              notification: {
                channel_id: 'rumour_chat_notifications',
                sound: 'default',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          },
        };

        const fcmRes = await fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
          {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(fcmPayload),
          }
        );

        const fcmData = await fcmRes.json();

        return new Response(JSON.stringify({ success: fcmRes.ok, data: fcmData }), {
          status: fcmRes.ok ? 200 : 500,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message, stack: err.stack }), {
          status: 500,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        });
      }
    }

    return new Response(JSON.stringify({ error: 'Not found' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' },
    });
  },
};
