%ifndef __IOINT_INC__
%define __IOINT_INC__

; Reads an integer into eax.
extern ReadInt

; Outputs the integer received in eax.
extern WriteInt

; Reads a binary number into eax.
extern ReadBin

; Outputs the binary number received in eax.
extern WriteBin

; Reads a hexadecimal number into eax.
extern ReadHex

; Outputs the hexadecimal number received in eax.
extern WriteHex

; Reads an integer into edx:eax.
extern ReadInt64

; Outputs the integer received in ebx:eax. 
extern WriteInt64

; Reads a binary number into edx:eax.
extern ReadBin64

; Outputs the binary number received in edx:eax.
extern WriteBin64

; Reads a hexadecimal number into edx:eax.
extern ReadHex64

; Outputs the hexadecimal number received in edx:eax.
extern WriteHex64

%endif