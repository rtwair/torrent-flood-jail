#!/bin/sh

# Wait for system to be fully ready (optional)
/bin/sleep 5

# Generate timestamp for session name
TIMESTAMP=$(/bin/date +"%Y%m%d_%H%M%S")
SESSION_NAME="rtorrent-${TIMESTAMP}"

# Create new screen session and run rtorrent as admin user
/usr/local/bin/screen -dmS "$SESSION_NAME" /bin/sh -c "cd /usr/home/admin && /usr/bin/su - admin -c 'rtorrent'"

# Wait longer for rtorrent to be fully ready before starting flood
/bin/sleep 10

# Create a new window in the same session for flood
/usr/local/bin/screen -S "$SESSION_NAME" -X screen /bin/sh -c "cd / && PATH=/usr/local/bin:/usr/bin:/bin HOME=/root /usr/local/bin/flood -h 127.0.0.10 2>&1 | tee -a /var/log/flood.log"

echo "Created screen session: $SESSION_NAME"
echo "- Window 0: rtorrent (running as admin user from /usr/home/admin)"
echo "- Window 1: flood (running as root from /)"
echo ""
echo "To attach to the session, run: screen -r $SESSION_NAME"
echo "To switch between windows: Ctrl+A then 0 or 1"

# Log the startup
echo "$(date): Started rtorrent-flood session $SESSION_NAME" >> /var/log/rtorrent-flood.log
