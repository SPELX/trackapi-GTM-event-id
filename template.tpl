___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "VARIABLE",
  "id": "cvt_trackapi_event_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "TrackAPI - Event ID",
  "categories": ["ANALYTICS", "CONVERSIONS"],
  "brand": {
    "id": "brand_trackapi",
    "displayName": "TrackAPI"
  },
  "description": "Gera um event_id único por evento+rota com cache de 8s. Use no campo eventID da tag do Facebook Pixel para garantir deduplicação entre browser Pixel e TrackAPI CAPI.",
  "containerContexts": [
    "WEB"
  ],
  "termsOfServiceVersion": "1"
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "ttl",
    "displayName": "TTL do cache (ms)",
    "simpleValueType": true,
    "defaultValue": "8000",
    "help": "Tempo em milissegundos para reutilizar o mesmo event_id para o mesmo evento+rota. Padrão: 8000 (8s). Necessário para SPAs (React, Next.js, Vue) que podem disparar o mesmo evento duas vezes em um único ciclo de render.",
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var copyFromWindow = require('copyFromWindow');
var setInWindow = require('setInWindow');
var getTimestampMillis = require('getTimestampMillis');
var generateRandom = require('generateRandom');
var makeString = require('makeString');
var makeNumber = require('makeNumber');
var Object = require('Object');

var ttl = makeNumber(data.ttl) || 8000;

// Inicializa cache global na primeira execução
var cache = copyFromWindow('_tapiEventIdCache');
if (!cache) {
  cache = {};
  setInWindow('_tapiEventIdCache', cache, true);
}

// Chave de cache: evento + pathname + querystring
// Garante que o mesmo evento em rotas diferentes receba IDs distintos

// Lê evento diretamente do dataLayer via variável GTM padrão {{Event}}
var eventName = makeString(data.event || 'unknown');
var path = '';
var qs = '';

// Lê localização atual (se disponível no contexto sandboxed)
var loc = copyFromWindow('location');
if (loc) {
  path = makeString(loc.pathname || '');
  qs = makeString(loc.search || '');
}

var key = eventName + '|' + path + '|' + qs;
var now = getTimestampMillis();

// Remove entradas expiradas do cache
var keys = Object.keys(cache);
for (var i = 0; i < keys.length; i++) {
  var k = keys[i];
  if (now - cache[k].time > ttl) {
    delete cache[k];
  }
}

// Reutiliza ID se o mesmo evento+rota disparou dentro do TTL
if (cache[key] && (now - cache[key].time < ttl)) {
  return cache[key].id;
}

// Gera novo ID único
var rand = generateRandom(0, 9999999999).toString(36);
var newId = 'evt_' + now + '_' + rand;
cache[key] = { id: newId, time: now };

return newId;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 1,
            "listItem": [
              {
                "type": 2,
                "mapKey": ["key", "read", "write", "execute"],
                "mapValue": [
                  {"type": 1, "string": "_tapiEventIdCache"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false}
                ]
              },
              {
                "type": 2,
                "mapKey": ["key", "read", "write", "execute"],
                "mapValue": [
                  {"type": 1, "string": "location"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": false}
                ]
              },
              {
                "type": 2,
                "mapKey": ["key", "read", "write", "execute"],
                "mapValue": [
                  {"type": 1, "string": "location.pathname"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": false}
                ]
              },
              {
                "type": 2,
                "mapKey": ["key", "read", "write", "execute"],
                "mapValue": [
                  {"type": 1, "string": "location.search"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": false}
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByTemplateCreator": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              },
              {
                "type": 1,
                "string": "event_id"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByTemplateCreator": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

## TrackAPI - Event ID — GTM Variable Template

Gera um `event_id` único com cache por evento+rota. Projetado para garantir deduplicação
entre Facebook browser Pixel e TrackAPI CAPI (Conversions API).

### Como usar

1. Importe este template como Variável no GTM
2. Na tag do **Facebook Pixel**, configure:
   - Campo "Event ID" → {{TrackAPI - Event ID}}
3. O TrackAPI SDK lê o mesmo event_id do dataLayer e o envia ao CAPI automaticamente

### Por que o cache de 8s?

Em SPAs (React, Next.js, Vue), um único evento de usuário pode disparar duas tags GTM
no mesmo ciclo — por exemplo, um PageView de SPA e um trigger de formulário.
O cache garante que ambas as tags usem o mesmo event_id dentro da janela de 8s,
permitindo deduplicação correta no Meta Events Manager.

### Se o dataLayer.push() já inclui event_id

Se o seu código já faz dataLayer.push({ event_id: 'evt_...' }), você pode usar
uma Variável de Camada de Dados simples apontando para "event_id" em vez deste template.
Este template é ideal para quem não controla o event_id no código do site.

### Integração com TrackAPI SDK

O TrackAPI SDK intercepta o dataLayer e, se encontrar event_id no push, usa o mesmo
valor para o envio CAPI. Se não encontrar, gera um novo automaticamente.
Para deduplicação perfeita, garanta que o mesmo event_id chegue ao Pixel browser
(via esta variável) e ao CAPI (via SDK).

### Documentação completa

https://trackapi.app.br/docs/sdk
