# TrackAPI - Event ID (GTM Variable Template)

Variável para Google Tag Manager que gera um `event_id` único com cache por evento+rota. Garante deduplicação correta entre Facebook browser Pixel e TrackAPI CAPI.

## Como usar

1. No GTM, vá em **Modelos → Novo → ⋮ → Importar**
2. Importe `template.tpl` → salve como **"TrackAPI - Event ID"**
3. Na tag do **Facebook Pixel**, configure o campo **Event ID** → `{{TrackAPI - Event ID}}`

## Por que usar?

Quando o TrackAPI envia um evento via CAPI e o Facebook Pixel envia o mesmo evento pelo browser, o Meta Events Manager precisa do mesmo `event_id` nos dois canais para deduplicar corretamente e contabilizar **uma única conversão**.

## Fluxo

```
GTM dispara
  ├─ Tag TrackAPI: SDK → CAPI (event_id: evt_123)
  └─ Tag Facebook Pixel: fbq('track', 'PageView', {}, { eventID: {{TrackAPI - Event ID}} })
       └─ Retorna o mesmo evt_123 (cache 8s)
Meta Events Manager: event_id idêntico → 1 conversão contabilizada ✅
```

## Parâmetros

| Campo | Padrão | Descrição |
|---|---|---|
| TTL do cache (ms) | 8000 | Janela de reutilização do event_id para o mesmo evento+rota |

## Documentação completa

https://trackapi.app.br/docs/sdk
