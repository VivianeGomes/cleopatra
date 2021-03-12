.code
lda m2
sta n21
lda m1
add #0ffh
sta m1

loop:
  lda m1
  add #0ffh
  sta m1
  lda m2
  sta n11
  jsr soma16
  lda r1
  sta n2
  lda r11
  sta n21
  lda m1
  jz fim
  jmp loop
fim:
  hlt

soma16:
  lda n1
  add n2
  sta r1
  jc carry1

volta:
  lda n11
  add n21
  sta r11
  jc carry
  jmp fim_soma16

carry:
  lda r1
  add #01h
  sta r1

fim_soma16:    rts

carry1: lda #01h
sta c
jmp volta
.endcode

org #080h
.data
n1:  db #00h
n11: db #00h
n2:  db #00h
n21: db #00h
c:   db #00h
r1:  db #00h
r11: db #00h

m1:  db #1Fh
m2:  db #3Fh
.enddata

