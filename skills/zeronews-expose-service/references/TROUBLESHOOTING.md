# Tunnel Troubleshooting

## Client is not configured

If `zeronews add` reports that the client is not configured, run the auth flow first.

## Running client became unavailable

The CLI can route tunnel creation through the running local runtime when `prg_runtime.json` points to a healthy local API. If that runtime disappears during the request, retry after checking local runtime health.

## Another control-plane request is running

The client uses a request lock for auth and tunnel creation. Wait for the current request to finish, then retry.

## Local service is not reachable

A tunnel can be accepted by the control-plane before the endpoint becomes active. If the endpoint later fails, inspect:

- `/api/v1/endpoints`
- the client log file
- whether the local service is actually listening on the requested IP and port

## TLS feature caveat

Webhook and file-sharing features on TLS tunnels may require compatible client-side TLS termination settings. If those features do not appear on a TLS tunnel, check the TLS termination setup first.
