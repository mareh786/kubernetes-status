#!/bin/bash

echo "Hello"

report=""

df -h >> $report
ps -ef >> $report
echo $report
