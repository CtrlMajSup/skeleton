#!/bin/bash

FILE="/var/log/increment_test.log"

if [ ! -f "$FILE" ]; then
    echo "0" > "$FILE"
fi

LAST_NUMBER=$(tail -n 1 "$FILE")
NEXT_NUMBER=$((LAST_NUMBER + 1))

echo "$NEXT_NUMBER" >> "$FILE"
