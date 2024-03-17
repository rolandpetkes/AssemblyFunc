%ifndef __STRINGS_INC__
%define __STRINGS_INC__

; String input in esi, length out in eax. 
extern StrLen

; Returns edi + esi in edi.
extern StrCat

; Input in esi.
extern StrUpper

; Input in esi.
extern StrLower

; Input in esi, output in edi.
extern StrCompact

%endif