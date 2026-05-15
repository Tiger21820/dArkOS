#!/usr/bin/env bash

# AmiBerry launcher with automatic retry on segfault.
# Root cause: AmiBerry v5.6.8 segfaults during SDL2 KMS/DRM video init
# when EmulationStation hasn't fully released DRM master. Retrying works.

# Ensure XDG_RUNTIME_DIR exists (cleaned up between ES game launches)
if [[ ! -d "/run/user/1000" ]]; then
  mkdir -p /run/user/1000
  chown 1000:1000 /run/user/1000
  chmod 700 /run/user/1000
fi
export XDG_RUNTIME_DIR=/run/user/1000/

# Give GPU time to settle after perfmax governor/freq change
sleep 0.5

pushd "/opt/amiberry/" >/dev/null

filename=$(basename -- "$1")
extension="${filename##*.}"

# Launch AmiBerry with automatic retry on segfault (exit 139)
MAX_RETRIES=5
ATTEMPT=0

while [[ $ATTEMPT -le $MAX_RETRIES ]]; do
  ATTEMPT=$((ATTEMPT + 1))

  if [[ $extension == "lha" ]]; then
    /opt/amiberry/amiberry --autoload "$1"
  else
    /opt/amiberry/amiberry -G -0 "$1"
  fi

  EXITCODE=$?

  if [[ $EXITCODE -eq 139 ]]; then
    # Segfault — retry after short delay (DRM master may still be held)
    if [[ $ATTEMPT -le $MAX_RETRIES ]]; then
      sleep 0.5
    fi
  else
    break
  fi
done

popd >/dev/null
exit $EXITCODE
