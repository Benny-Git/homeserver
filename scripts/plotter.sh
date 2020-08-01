#!/bin/bash

curl -s "https://www.plottermarie.de/suche?controller=search&orderby=position&orderway=desc&search_query=surprise&submit_search=" | grep -q "Keine Ergebnise gefunden"
_result=$?

#echo $_result

if [ $_result != 0 ]; then
	banner surprise found
	echo -e "\a"
fi

