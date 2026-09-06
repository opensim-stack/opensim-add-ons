# Blender OpenSim AI Stack Add-On

Adds a 3D pipeline capbilities by ...

 * Installs a headless [blender](https://www.blender.org/).
 * Enables the blender [MCP Server](https://github.com/ahujasid/blender-mcp/issues).
 * Configures bot's harness with the new MCP server.
 
## Variables

```bash
BLENDER_MCP_HOST=0.0.0.0
BLENDER_MCP_PORT=8996
BLENDER_TCP_PROTOCOL_HOST=127.0.0.1
BLENDER_TCP_PROTOCOL_PORT=9876
BLENDER_PROJECT_DIR=/workspace
BLENDER_EXTRA_ARGS=
OPENSIM_BLENDER_IMAGE=bithatch/opensim-blender:latest
```