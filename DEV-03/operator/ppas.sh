#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/zux0x3a/PAS-mini-c2c-/DEV-02/operator/client
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2     -L. -o /home/zux0x3a/PAS-mini-c2c-/DEV-02/operator/client -T /home/zux0x3a/PAS-mini-c2c-/DEV-02/operator/link49689.res -e _start
if [ $? != 0 ]; then DoExitLink /home/zux0x3a/PAS-mini-c2c-/DEV-02/operator/client; fi
IFS=$OFS
