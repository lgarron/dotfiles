#!/usr/bin/env -S fish --no-config

set ADAPTER_DETAILS (ioreg -a -w 0 -f -r -c AppleSmartBattery | python3 -c 'import plistlib,sys,json,base64; print(json.dumps(plistlib.loads(sys.stdin.read().encode("utf-8")), default=lambda o:"base64:"+base64.b64encode(o).decode("ascii")))' | jq -e -r ".[0].AdapterDetails")

if echo $ADAPTER_DETAILS | jq -e -r ".Watts" > /dev/null
  echo -n "🔌 "
  echo $ADAPTER_DETAILS | jq -e -r -j ".Watts"
  echo " watts" # The SI unit is not capitalized, even though it is named after a person.
else
  echo "Not connected to a charger."
end
