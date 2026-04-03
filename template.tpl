___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "TrackAPI - Event ID",
  "description": "Generates a unique event_id per event+route with 8s cache. Use in the Facebook Pixel tag Event ID field to ensure deduplication between browser Pixel and TrackAPI CAPI.",
  "categories": [
    "UTILITY",
    "ANALYTICS"
  ],
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "ttl",
    "displayName": "Cache TTL (ms)",
    "simpleValueType": true,
    "defaultValue": "8000",
    "help": "Time in milliseconds to reuse the same event_id for the same event+route. Default: 8000 (8s). Required for SPAs (React, Next.js, Vue) that may fire the same event twice in a single render cycle.",
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
var getUrl = require('getUrl');
var ObjectApi = require('Object');

var ttl = makeNumber(data.ttl) || 8000;

var cache = copyFromWindow('_tapiEventIdCache');
if (!cache) {
  cache = {};
  setInWindow('_tapiEventIdCache', cache, true);
}

var eventName = makeString(data.event || 'unknown');
var path = makeString(getUrl('path') || '');
var qs = makeString(getUrl('query') || '');

var key = eventName + '|' + path + '|' + qs;
var now = getTimestampMillis();

var keys = ObjectApi.keys(cache);
var clean = {};
for (var i = 0; i < keys.length; i++) {
  var k = keys[i];
  if (now - cache[k].time <= ttl) {
    clean[k] = cache[k];
  }
}
cache = clean;
setInWindow('_tapiEventIdCache', cache, true);

if (cache[key] && (now - cache[key].time < ttl)) {
  return cache[key].id;
}

var rand = makeString(generateRandom(0, 2147483647));
var newId = 'evt_' + makeString(now) + '_' + rand;
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
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_tapiEventIdCache"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

TrackAPI - Event ID - GTM Variable Template

Generates a unique event_id with per-event+route cache. Designed to ensure
deduplication between Facebook browser Pixel and TrackAPI CAPI.

How to use:
1. Import this template as a Variable in GTM
2. In the Facebook Pixel tag, set Event ID to {{TrackAPI - Event ID}}
3. TrackAPI SDK reads the same event_id from dataLayer and sends it to CAPI

Documentation: https://trackapi.app.br/docs/sdk


