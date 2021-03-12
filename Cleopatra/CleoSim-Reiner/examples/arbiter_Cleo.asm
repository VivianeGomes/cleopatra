;
; Ney Calazans
; Ultima alteracao em 08/07/2003
;
; Aplicativo para o Processador Cleópatra
;
; Programa que desempenha a função de um
; árbitro de barramento para um sistema com 3
; iniciadores de comunicação
;
; Nome do arquivo: arbiter_Cleo.asm
;

.code
vreq3:	lda  req3	; read first request signal
	and  #1		; mask to see if request exists
	jz   vreq2	; if no request, see next
greq3:	lda  #1		; prepare to set grant3
	sta  grant3	; set grant signal 3 to 1
	jsr  tempo	; wait time to pass
	lda  #0		; 
	sta  grant3	;

vreq2:	lda  req2	; read first request signal
	and  #1		; mask to see if request exists
	jz   vreq1	; if no request, see next
greq2:	lda  #1		; prepare to set grant3
	sta  grant2	; set grant signal 3 to 1
	jsr  tempo	; wait time to pass
	lda  #0		; 
	sta  grant2	;

vreq1:	lda  req1	; read first request signal
	and  #1		; mask to see if request exists
	jz   vreq3	; if no request, see next
greq1:	lda  #1		; prepare to set grant3
	sta  grant1	; set grant signal 3 to 1
	jsr  tempo	; wait time to pass
	lda  #0		; 
	sta  grant1	;
	jmp  vreq3	; go to next round robin priority

tempo:	lda  #0		; initialize counter with 0
loop:	add  #1h	; add 1
	jz   end_tp	; test if end found
	jmp  loop	; else, stay in loop
end_tp:	rts
.endcode

.data
req1:    db   #1	; bus access request signal for initiator 1
grant1:  db   #0	; bus grant signal for initiator 1
req2:    db   #1	; bus access request signal for initiator 2
grant2:  db   #0	; bus grant signal for initiator 2
req3:    db   #1	; bus access request signal for initiator 3
grant3:  db   #0	; bus grant signal for initiator 3
.enddata
