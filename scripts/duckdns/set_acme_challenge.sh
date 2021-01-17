#!/bin/bash

token="TTTTTTTT-TTTT-TTTT-TTTT-TTTTTTTTTTTT"

# log
echo "renewal of $CERTBOT_DOMAIN with challenge $CERTBOT_VALIDATION" 

# set acme challenge
curl -s "https://www.duckdns.org/update?domains=localbertow.duckdns.org&token=$token&txt=$CERTBOT_VALIDATION"

