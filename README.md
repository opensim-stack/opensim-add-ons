# OpenSim AI Stack Add-Ons

OSAIS extensions enhance the functionality of OpenSim AI Stack by adding additional Docker containers and configuration to the stack.

For example, many people may not want Blender or Voice support, so these are provided as extensions.

## Behaviour

 * Add-ons are hosted on [Github](https://github.com/opensim-stack/opensim-add-ons). 
 * Add-ons (from Github) are just meta-data, they tell the stack how to get the actual software (from Docker hub) and set it up.
 * The spawner container lists the directory to `${OPENSIM_SPAWNER_ADD_ONS_DIRECTORY:-/config/cache/opensim-add-ons}` at startup (if `OPENSIM_SPAWNER_ADD_ONS_REFRESH_AT_STARTUP:-true}` is `true`, or when **Refresh** is called e.g. in "Add Ons" Web UI.
   - If there is a `.git` directory (i.e. is a Git repository), then a pull is done before refresh of directory (non fatally at startup).
   - If there is no directory at all, the directory is cloned from the `${OPENSIM_SPAWNER_ADD_ONS_REPOSITORY:-https://github.com/opensim-stack/opensim-add-ons}` before refresh of directory.
   - If the directory exists and has no `.git` directory, nothing additional happens.
   - A user can just copy or create their own add-on in this directory. As long as it's name doesn't conflict with a remote add-on, a pull is safe.
 * The web UI has an "Add-ons" page that lists all known add-ons with an option to either enable or disable each. Add-ons do not currently have any interactive configuration.
 * Users can contribute to the add-on repository through pull requests. 
 * A custom Git repository may be defined. 
 * An add-on usually consists of one **Extension**, may be may have more.
 * There are 4 **Extension** types (note only `STACK` and `SIMULATOR` are currently implemented).
   - `STACK`. Adds a service (container) to be shared by the whole stack. There will be one instance.
   - `SIMULATOR`. Adds a service (container) to be used only by a **Simulator** of `ROBUST` or `STANDALONE` type, i.e. the one that provides **Grid Services**. As there is only ever one `ROBUST` or `STANDALONE`, there will be one instance.
   - `BOT`. Adds a service (container) to be used only by **Bots**, given `N` bot instances, there will be `N` add-on instances.
   - `GRID`. Adds a service (container) to be used only by **Simulators** of `GRID` type. Given `N` grid instances, there will be `N` add-on instances.

## Creating An Add On

Creating an add-on assumes you know a little about Docker, which is central to OpenSim AI Stack.

### Docker Image

The add-on generally needs something to do some useful. It does not contain any executable code itself, but it does point to where the executable code can be obtained, i.e. a Docker repository ([Docker Hub](https://hub.docker.com/)).

Our example manifest below for Blender uses OpenSim AI Stack's own Blender build at `bithatch/opensim-blender:latest`, but it could come anywhere. For example say you wanted to integrate a "Brave Web Search" capability to your bots, you'd base your add-on on `mcp/brave-search:latest` and add the configuration merges so `opencode` knows about the the new MCP servers in the say way as we do with blender in the example.

### Environment Variable Resolution

 `%env.NAME%` will resolve from the passed in environment first. If that does not exist, it will come from the `const` table in the manifest. If that does not exist, the environment variable will be ignored unless the replacement itself contains other content. E.g `"MYHOST": "%env.MYHOST%-tail"` would resolve as `"MYHOST": "-tail"` if `MYHOST` does not exist as a `const` or passed in variable.
 
### Installation Hooks

`POST_INSTALL` and `PRE_UNINSTALL` hooks may be used to manipulate files, updating `.ini` and `.json` files and executing scripts for anything else that might be needed.

Each step in the "script" has a `type`, which may be one of.

 * `createJson` - Create or update a JSON element
 * `deleteJson` - Delete one or more JSON elements given their document path.
 * `createIni` - Similar as `createJson`, for `.ini` files.
 * `deleteJson` - Again, similar as `deleteJson` but for `.ini` files.
 * `exec` - Execute a script (supplied as a resource).
 * `copy` - Copy a resource to a file.
 * `delete` - Delete a file.

### The Manifest

```json
{
    "name": "blender",
    "description": "This add-on provides a Blender instance with MCP tools enabled, allowing your Bots access to a 3D pipeline.",
    "icon" : "blender.svg",
    "version": "0.0.1",
    "constants": {
        "OPENSIM_BLENDER_IMAGE": "%cfg.group%opensim-blender:%grid.updates.tag%",
        "BLENDER_MCP_HOST": "0.0.0.0",
        "BLENDER_MCP_PORT": "8996",
        "BLENDER_TCP_PROTOCOL_HOST" : "127.0.0.1",
        "BLENDER_TCP_PROTOCOL_PORT" : "9876",
        "BLENDER_PROJECT_DIR" : "%cfg.workspaceDir%/blender"
    },
    "hooks": {
        "POST_INSTALL": [
            {
                "type": "createJson",
                "addOn": "BOT",
                "level": "GOVERNOR",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "mcp",
                "mode": "merge",
                "json": {
                   "mcp": {
                    "blender_mcp": {
                      "type": "remote",
                      "url": "http://%cfg.projectName%-blender:%env.BLENDER_MCP_PORT%/mcp",
                      "enabled": true
                    }
                  }
                }
            },
            {
                "type": "createJson",
                "addOn": "BOT",
                "level": "GOVERNOR",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "permission",
                "mode": "merge",
                "json": {
                    "write": {
                      "/workspace/blender": "allow",
                      "/workspace/blender/**": "allow"
                    },
                    "edit": {
                      "/workspace/blender": "allow",
                      "/workspace/blender/**": "allow"
                    },
                    "bash": {
                      "python *": "allow"
                    },
                    "external_directory": {
                      "/workspace/blender/**": "allow",
                      "/workspace/blender/": "allow"
                    }
                }
            },
            {
                "type": "createJson",
                "addOn": "BOT",
                "level": "BUILDER",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "mcp",
                "mode": "merge",
                "json": {
                   "mcp": {
                    "blender_mcp": {
                      "type": "remote",
                      "url": "http://%cfg.projectName%-blender:%env.BLENDER_MCP_PORT%/mcp",
                      "enabled": true
                    }
                  }
                }
            },
            {
                "type": "createJson",
                "addOn": "BOT",
                "level": "BUILDER",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "permission",
                "mode": "merge",
                "json": {
                    "write": {
                      "/workspace/blender": "allow",
                      "/workspace/blender/**": "allow"
                    },
                    "edit": {
                      "/workspace/blender": "allow",
                      "/workspace/blender/**": "allow"
                    },
                    "bash": {
                      "python *": "allow"
                    },
                    "external_directory": {
                      "/workspace/blender/**": "allow",
                      "/workspace/blender/": "allow"
                    }
                }
            }
        ],
        "PRE_UNINSTALL": [
            {
                "type": "deleteJson",
                "addOn": "BOT",
                "level": "GOVERNOR",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "mcp.blender_mcp"
            },
            {
                "type": "deleteJson",
                "addOn": "BOT",
                "level": "GOVERNOR",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPaths": [
                    "/permission/write/workspace\\/blender",
                    "/permission/write/workspace\\/blender\\/**",
                    "/permission/edit/workspace\\/blender",
                    "/permission/edit/workspace\\/blender\\/**",
                    "/permission/bash/python *",
                    "/permission/external_directory/workspace\\/blender\\/",
                    "/permission/external_directory/workspace\\/blender\\/**"
                ]
            },
            {
                "type": "deleteJson",
                "addOn": "BOT",
                "level": "BUILDER",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPath": "mcp.blender_mcp"
            },
            {
                "type": "deleteJson",
                "addOn": "BOT",
                "level": "BUILDER",
                "path": "/config/bots/%bot.name%/opencode.json",
                "jsonPaths": [
                    "/permission/write/workspace\\/blender",
                    "/permission/write/workspace\\/blender\\/**",
                    "/permission/edit/workspace\\/blender",
                    "/permission/edit/workspace\\/blender\\/**",
                    "/permission/bash/python *",
                    "/permission/external_directory/workspace\\/blender\\/",
                    "/permission/external_directory/workspace\\/blender\\/**"
                ]
            }
        ]
    },
    "extensions": {
        "STACK": {
            "containers": {
                "%env.OPENSIM_BLENDER_IMAGE%": {
                    "name": "%cfg.projectName%-blender",
                    "environment": {
                        "BLENDER_MCP_HOST": "%env.BLENDER_MCP_HOST%",
                        "BLENDER_MCP_PORT": "%env.BLENDER_MCP_PORT%",
                        "BLENDER_TCP_PROTOCOL_HOST": "%env.BLENDER_TCP_PROTOCOL_HOST%",
                        "BLENDER_TCP_PROTOCOL_PORT": "%env.BLENDER_TCP_PROTOCOL_PORT%",
                        "BLENDER_PROJECT_DIR": "%env.BLENDER_PROJECT_DIR%",
                        "BLENDER_EXTRA_ARGS": "%env.BLENDER_EXTRA_ARGS%"
                    },
                    "volumes": {
                        "%cfg.projectName%_opensim-workspace": "/workspace",
                        "%cfg.projectName%_blender-config": "/root/.config/blender",
                        "%cfg.projectName%_blender-cache": "/root/.cache/opencode",
                        "%cfg.projectName%_blender-data": "/root/.local/share/blender"
                    },
                    "directories": [
                        "%env.BLENDER_PROJECT_DIR%"
                    ]
                }
            }
        }
    }
}
```
