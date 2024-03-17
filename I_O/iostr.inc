%ifndef __IOSTR_INC__
%define __IOSTR_INC__

; Input is in esi, ecx has the max number of characters.
extern ReadStr

; Receives string in esi.
extern WriteStr

; Input is in esi.
extern ReadLnStr

; Receives string in esi.
extern WriteLnStr

; Prints a newline character.
extern NewLine

%endif 