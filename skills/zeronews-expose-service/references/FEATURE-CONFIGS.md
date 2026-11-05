# Supported Feature Config Shapes

Use these examples when building feature configuration for supported ZeroNews tunnels.

## Webhook: standard proxy

```json
{
  "webhook_type": "standard"
}
```

Use this for a standard webhook proxy tunnel.

## Webhook: verified WeChat Pay

Inline values:

```json
{
  "webhook_type": "verify",
  "verify_scene": "wechat_pay",
  "wechat_pay": {
    "config_source": "key_value",
    "appid": "wx123",
    "mch_id": "1900000109",
    "api_v3_key": "01234567890123456789012345678901",
    "platform_cert_pem": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
  }
}
```

Or load from YAML:

```json
{
  "webhook_type": "verify",
  "verify_scene": "wechat_pay",
  "wechat_pay": {
    "config_source": "yaml_file",
    "yaml_path": "/absolute/path/to/wechat-pay.yml"
  }
}
```

Use this for a WeChat Pay verified webhook tunnel.

## Webhook: verified WeChat Contract

Inline values:

```json
{
  "webhook_type": "verify",
  "verify_scene": "wechat_contract",
  "wechat_contract": {
    "config_source": "key_value",
    "appid": "wx123",
    "mch_id": "1900000109",
    "api_v2_key": "secret",
    "sign_type": "HMAC-SHA256"
  }
}
```

Or load from YAML:

```json
{
  "webhook_type": "verify",
  "verify_scene": "wechat_contract",
  "wechat_contract": {
    "config_source": "yaml_file",
    "yaml_path": "/absolute/path/to/wechat-contract.yml"
  }
}
```

Use this for a WeChat Contract verified webhook tunnel.

## File share

Creating a file-share tunnel requires `root_path` (absolute) and `admin_password` (at least 8 characters):

```json
{
  "file_share": {
    "root_path": "/absolute/path/to/share",
    "admin_password": "<at least 8 characters>"
  }
}
```

Use this for a file-sharing tunnel. Do not create with only `root_path`. Do not use an empty `admin_password` to turn off NAS / file-share login.

If an admin password is set but the client has not been upgraded, the public URL may still serve the whole share as anonymous read-only. Do not claim that filling in a password will make an old client require login.

## TLS caveat

If the tunnel type is `tls`, webhook and file-sharing behavior may depend on compatible TLS termination settings. Do not promise those features on TLS tunnels unless that configuration is clearly in place.
