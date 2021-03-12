jmp inicio
.data
end1: db #00h
end2: db #00h
.enddata

inicio: lda #1

main_loop:lda #30h

fim:add #0ffh
sta end1
lda end2
add #01h
sta end2
lda end1
jz fim,R
jmp main_loop

hlt




