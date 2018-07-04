#!/system/bin/sh

# This script launches lldb-server on Android device from application subfolder - /data/data/$packageId/lldb/bin.
# Native run configuration is expected to push this script along with lldb-server to the device prior to its execution.
# Following command arguments are expected to be passed - lldb package directory and lldb-server listen port.

umask 0002

LLDB_DIR=/data/local/tmp/lldb_server
LISTENER_SCHEME=unix-abstract
DOMAINSOCKET_DIR=$LLDB_DIR
PLATFORM_SOCKET=lldb_debug.sock
LOG_CHANNELS="lldb process:gdb-remote packets"

BIN_DIR=$LLDB_DIR/bin/arm64-v8a
LOG_DIR=$LLDB_DIR/log
TMP_DIR=$LLDB_DIR/tmp
PLATFORM_LOG_FILE=$LOG_DIR/platform.log

export LLDB_DEBUGSERVER_LOG_FILE=$LOG_DIR/lldb-server.log
export LLDB_SERVER_LOG_CHANNELS="$LOG_CHANNELS"
export LLDB_DEBUGSERVER_DOMAINSOCKET_DIR=$DOMAINSOCKET_DIR

# This directory already exists. Make sure it has the right permissions.
chmod 0775 "$LLDB_DIR"

rm -r $TMP_DIR
mkdir $TMP_DIR
export TMPDIR=$TMP_DIR

rm -r $LOG_DIR
mkdir $LOG_DIR

# LLDB would create these files with more restrictive permissions than our umask above. Make sure
# he doesn't get a chance.
# "touch" does not exist on pre API-16 devices. This is a poor man's replacement
cat </dev/null >"$LLDB_DEBUGSERVER_LOG_FILE" 2>"$PLATFORM_LOG_FILE"

cd $TMP_DIR # change cwd

#notice:if faile change the PLATFORM_SOCKET
$BIN_DIR/lldb-server platform --server --listen $LISTENER_SCHEME://$DOMAINSOCKET_DIR/$PLATFORM_SOCKET --log-file "$PLATFORM_LOG_FILE" --log-channels "$LOG_CHANNELS" </dev/null >$LOG_DIR/platform-stdout.log 2>&1
