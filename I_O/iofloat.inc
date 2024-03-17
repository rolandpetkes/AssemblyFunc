%ifndef __IOFLOAT_INC__
%define __IOFLOAT_INC__

; Reads a floating point number into xmm0.
extern ReadFloat

; Outputs the floating point number received in xmm0.
extern WriteFloat

; Reads an exponential number into xmm0.
extern ReadExponentFloat

; Outputs the floating point number received in xmm0.
extern WriteExponentFloat

%endif
