#!/bin/bash

token="TTTTTTTT-TTTT-TTTT-TTTT-TTTTTTTTTTTT"

# clear acme challenge
curl -s "https://www.duckdns.org/update?domains=localbertow.duckdns.org&token=$token&txt=$CERTBOT_VALIDATION&clear=true"

