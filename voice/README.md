# Voice OpenSim AI Stack Add-On

Adds voice capabilities by ...

 * Installing [piper](https://github.com/OHF-Voice/piper1-gpl) to do TTS (text-to-speech).
 * Installs [Janus](https://janus.conf.meetecho.com/) as a local WebRTC server.
 * Configures the stack to enable voice capabilities.
 
## Variables

```bash
OPENSIM_PIPER_IMAGE=bithatch/opensim-piper:latest
OPENSIM_JANUS_IMAGE=misterblue/os-webrtc-janus-docker:latest

OPENSIM_JANUS_PUBLIC_HOST=${OPENSIM_HOSTNAME}

JANUS_SERVER_NAME=GridVoice
JANUS_HTTP_ENABLE=true
JANUS_HTTP_PORT=14223
JANUS_HTTP_BASEPATH=/voice
JANUS_HTTPS_ENABLE=false
JANUS_HTTPS_PORT=14224
JANUS_HTTP_ADMIN_ENABLE=true
JANUS_HTTP_ADMIN_PORT=14225
JANUS_HTTP_ADMIN_BASEPATH=/voiceAdmin
JANUS_UDP_RTP_MIN=10000
JANUS_UDP_RTP_MAX=10200

PIPER_HOST=${COMPOSE_PROJECT_NAME:-opensim-ai}-piper-1
PIPER_HTTP_HOST=0.0.0.0
PIPER_HTTP_PORT=8995
PIPER_DEFAULT_VOICE=en_US-lessac-medium
PIPER_TIMEOUT_SECONDS=60
```