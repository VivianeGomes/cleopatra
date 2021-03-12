;         Programa que soma 2 numeros de 16 bits
;
;               n1 n11
;           +   n2 n21
;              --------
;             c r1 r11
;
.code
lda n1
add n2
sta r1
jc carry1

volta:
  lda n11
  add n21
  sta r11
  jc carry
  jmp fim

carry:
  lda r1
  add #01h
  sta r1

fim:
   hlt

carry1:
  lda #01h
  sta c
  jmp volta
.endcode

.data
n1:  db #3fh
n11: db #84h
n2:  db #3eh
n21: db #0cah
c:   db #00h
r1:  db #00h
r11: db #00h
.enddata
