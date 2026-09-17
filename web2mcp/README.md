# web2mcp Add-On

This add-on enables a Firecrawl MCP server as part of OpenSim AI Stack so OpenCode agents can access web crawling and extraction tools over HTTP.

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
