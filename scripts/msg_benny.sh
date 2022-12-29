#!/bin/bash

WEBHOOK_ID=PUT_WEBHOOK_ID_HERE
MSG="$*"
curl -XPOST -H "Content-Type: application/json" -d "{\"message\": \"$MSG\"}" https://ha.bertow.com/api/webhook/$WEBHOOK_ID

