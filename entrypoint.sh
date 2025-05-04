#!/bin/bash
# This script is used to start the Photon geocoder service in a Docker container.

DATA_DIR="${DATA_DIR:-"/photon/photon_data/elasticsearch"}"
DOWNLOADS_DIR="${DOWNLOADS_DIR:-}"
COUNTRY=${COUNTRY:-"all"}
BOOTSTRAP=${BOOTSTRAP:-"false"}
FILE="photon-db-latest.tar.bz2"
LINK="http://download1.graphhopper.com/public/${FILE}"
if [ "$COUNTRY" != "all" ]; then
    echo "Using country code: $COUNTRY"
    FILE="photon-db-${COUNTRY}-latest.tar.bz2"
    LINK="http://download1.graphhopper.com/public/extracts/by-country-code/${COUNTRY}/${FILE}"
fi

# Check if reset.lock exists and remove it and the data directory.
if [ -f "reset.lock" ]; then
    echo "Removing reset.lock and $DATA_DIR"
    rm -f reset.lock
    rm -rf "$DATA_DIR"
fi

# Check if the downloads directory is set and exists.
if [ -n "$DOWNLOADS_DIR" ] && [ -d "$DOWNLOADS_DIR" ] && [ ! -d "$DATA_DIR" ]; then
    # Check if $DOWNLOADS_DIR/$FILE exists.
    if [ -f "$DOWNLOADS_DIR/$FILE" ]; then
        echo "Using previously downloaded file $FILE"
    
        # Extract the file to $DATA_DIR.
        echo "Extracting pre-existing $FILE to $DATA_DIR"
        mkdir -p "$DATA_DIR"
        tar -xjf "$DOWNLOADS_DIR/$FILE" -C "$DATA_DIR"
    fi
fi

# Download elasticsearch index.
if [ ! -d "$DATA_DIR" ]; then
    echo "Downloading search index..."

    # Let graphhopper know where the traffic is coming from
    USER_AGENT="docker: tonsnoei/photon-geocoder"

    # Check if DOWNLOADS_DIR is set and exists, if so, download the file there and extract it.
    # If it doesn't exist, extract it as a stream.
    if [ -n "$DOWNLOADS_DIR" ] && [ -d "$DOWNLOADS_DIR" ]; then
        echo "Downloading to $DOWNLOADS_DIR"
        mkdir -p "$DATA_DIR"
        wget --user-agent="${USER_AGENT}" -O "$DOWNLOADS_DIR/$FILE" "$LINK"
        echo "Extracting $FILE to $DATA_DIR"
        tar -xvjf "$DOWNLOADS_DIR/$FILE" -C "$DATA_DIR"
    else
        echo "WARNING: DOWNLOADS_DIR not set or does not exist, downloading to $DATA_DIR"
        echo "Downloading to $DATA_DIR"
        mkdir -p "$DATA_DIR"
        wget --user-agent="$USER_AGENT" -O - "$LINK" | bzip2 -cd | tar x
    fi
fi

if [ "$BOOTSTRAP" = "true" ] ; then
    echo "BOOTSTRAP is set to true, skipping photon start."
    exit 0
fi

# Start photon if elastic index exists and BOOTSTRAP is set to false.
if [ -d "$DATA_DIR" ]; then
    echo "Starting photon service..."
    (
        set -o pipefail

        java -jar photon.jar "$@" 2>&1 | tee /dev/stderr | grep -q 'IndexNotFoundException\[no such index\]'
        if [ $? -eq 0 ]; then
            touch reset.lock
        fi
    )
else
    echo "Could not start photon, the search index could not be found"
    exit 1
fi
