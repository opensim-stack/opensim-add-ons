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

### The Manifest

```json
{
    /* Simple name, all lower case, no punctuation except '-', no spaces */
    "name": "blender",
    /* Icon */
    "icon" : "blender.svg",    
    /* Author - Github user for preference */
    "author": "github-user",   
    /* Version - version of the add on */
    "version": "0.0.1",
    /* Full description */
    "description": "This add-on provides a Blender instance with MCP tools enabled, allowing your Bots access to a 3D pipeline.",
    /* Default values for environment variables that aren't provided */
    "constants": {
        "OPENSIM_BLENDER_IMAGE": "bithatch/opensim-blender:latest",
        "BLENDER_MCP_HOST": "0.0.0.0",
        "BLENDER_MCP_PORT": "8996",
        "BLENDER_TCP_PROTOCOL_HOST" : "127.0.0.1",
        "BLENDER_TCP_PROTOCOL_PORT" : "9876",
        "BLENDER_PROJECT_DIR" : "/workspace/blender"
    },
    /* Extensions in this add-on */
    "extensions": {
        "STACK": {
            /* Containers in this stack extension */
            "containers": {
                /* The image reference */
                "%env.OPENSIM_BLENDER_IMAGE%": {
                    /* Container name */
                    "name": "%cfg.COMPOSE_PROJECT_NAME%-blender",
                    /* Environment */
                    "environment": {
                        "BLENDER_MCP_HOST": "%env.BLENDER_MCP_HOST%",
                        "BLENDER_MCP_PORT": "%env.BLENDER_MCP_PORT%",
                        "BLENDER_TCP_PROTOCOL_HOST": "%env.BLENDER_TCP_PROTOCOL_HOST%",
                        "BLENDER_TCP_PROTOCOL_PORT": "%env.BLENDER_TCP_PROTOCOL_PORT%",
                        "BLENDER_PROJECT_DIR": "%env.BLENDER_PROJECT_DIR%",
                        "BLENDER_EXTRA_ARGS": "%env.BLENDER_EXTRA_ARGS%"
                    },
                    /* Volumes */
                    "volumes": {
                        "%cfg.COMPOSE_PROJECT_NAME%_opensim-workspace": "/workspace",
                        "%cfg.COMPOSE_PROJECT_NAME%_blender-config": "/root/.config/blender",
                        "%cfg.COMPOSE_PROJECT_NAME%_blender-cache": "/root/.cache/opencode",
                        "%cfg.COMPOSE_PROJECT_NAME%_blender-data": "/root/.local/share/blender"
                    },
                    /* Directories to create */
                    "directories": [
                        "%env.BLENDER_PROJECT_DIR%"
                    ],
                    /* Managed files allow an add-on to drop in 
                      configuration files to other parts of the stack.
                      
                      When this add-on is installed and configuration is
                      generated, any stack element that uses managed files,
                      and has a matching "resource", and a matching "drop-ins"
                      directory, OUR resource will be copied to that
                      directory and its contents will be used to generate
                      the other elements config files (e.g. by merging)
                    */
                    "managed": [
                        {
                        "resource": "governor-opencode.json",
                        "dropIns": "/config/add-ons/opencode/opencode.json.d"
                        },
                        {
                        "resource": "builder-opencode.json",
                        "dropIns": "/config/add-ons/opencode/opencode.json.d"
                        },
                        {
                        "resource": "actor-opencode.json",
                        "dropIns": "/config/add-ons/opencode/opencode.json.d"
                        }
                    ]
                }
            }
        }
    }
}

```
