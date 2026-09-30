#!/bin/bash

set -e

NAMENODE_DIR="/opt/hadoop/dfs/name"

echo "========================================"
echo "Hadoop NameNode initialization"
echo "========================================"

if [ ! -f "$NAMENODE_DIR/current/VERSION" ]; then
    echo "NameNode is not formatted."
    echo "Formatting NameNode..."
    
    hdfs namenode -format -force -nonInteractive
    
    echo "NameNode formatted successfully."
else
    echo "NameNode is already formatted."
fi

echo "Starting NameNode..."
exec hdfs namenode
