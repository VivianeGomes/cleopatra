.code
lda x
not
and y
sta r
lda y
not
and x
or r
sta r
hlt
.endcode


.data
x: db #33h
y: db #91h
r: db #00h
.enddata
