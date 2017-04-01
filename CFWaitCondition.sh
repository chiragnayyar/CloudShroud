#!/bin/bash
ping -c 4 -W 1 8.8.8.8

RESULT=$?

if [ "$RESULT" == 0 ]
 then	
	curl -X PUT -H 'Content-Type:' --data-binary '{"Status" : "SUCCESS","Reason" : "ControlBox has internet access","UniqueId" : "ID1234","Data" : "Application has completed configuration."}' "$SignalURL"
else
	curl -X PUT -H 'Content-Type:' --data-binary '{"Status" : "FAILURE","Reason" : "ControlBox does NOT have interent access","UniqueId" : "ID1235","Data" : "Application has NOT completed configuration."}' "$SignalURL"
fi