# firestorm-bridge Add-On

This add-on integrates OpenSim AI Stack with [Firestorm MCP](https://github.com/AochiToxx/firestorm-mcp).

*Note, you have to install and run Firestorm MCP yourself according to it's instructions. You
must run it in streamable HTTP or SSE mode.

## Tokens

- `WEB2MCP_HTTP_BEARER_TOKEN`: Bearer token required by OpenCode when calling this MCP endpoint.

## Required

- `FIRECRAWL_API_KEY`: API key to access Firecrawl API server. Sign up at https://www.firecrawl.dev/

## Defaults

The add-on defaults are defined in `manifest.json` and can be overridden through stack environment settings:

- `OPENSIM_WEB2MCP_IMAGE`: `mcp/server/firecrawl:latest`
- `WEB2MCP_TRANSPORT`: `http`
- `WEB2MCP_HOST`: `0.0.0.0`
- `WEB2MCP_PORT`: `8997`
- `WEB2MCP_ENDPOINT`: `/mcp`
- `FIRECRAWL_API_URL`: `https://api.firecrawl.dev`
