;#1) list-length
;Expected: 12
(list-length (list 1 2 3 4 5 "a" "b" "c" "d" "e" (cons "a" 1) "a bridge too far"))

;#2) nth-element
;Expected: "blue"
(nth-element (list "red" "green" "blue") 2)
;#2) nth-element
;Expected: "Try again with a smaller number"
(nth-element (list "red" "green" "blue") 4)

;#3) remove-first
;Expected: '("a" "e" "o" "u")
(remove-first "i" (list "a" "e" "i" "o" "u"))

;#4) occurs-free?
;Expected: #f
(occurs-free? 'x '(lambda (x) (x y)))
;#4) occurs-free?
;Expected: #t
(occurs-free? 'x '((lambda (x) x)(x y)))

;# NOTE: the following subst and substr are identical tests, 
;# just because some students used subst while others use substr.
;#5) subst - the same test as substr
;Expected: '((a c) (a () d))
(subst 'a 'b '((b c) (b () d)))
;#5) substr - the same test as subst
;Expected: '((a c) (a () d))
(substr 'a 'b '((b c) (b () d)))


;#6) number-elements-from
;Expected: '((1 1) (2 2) (3 3) (4 4) (5 5) (6 "a") (7 "b") (8 "c") (9 "d") (10 "e") (11 ("a" . 1)) (12 "a bridge too far"))
(number-elements-from (list 1 2 3 4 5 "a" "b" "c" "d" "e" (cons "a" 1) "a bridge too far") 1)

;#7) list-sum
;Expected: 45
(list-sum (list 0 1 2 3 4 5 6 7 8 9))

;#8) vector-sum
;Expected: 270
(vector-sum (vector 1 2 3 45 55 66 98))
;#8) partial-vector-sum
;Expected: 106
(partial-vector-sum (vector 1 2 3 45 55 66 98) 4)

;#9) duple
;Expected: '(4 4 4 4 4)
(duple 5 4)
;#9) duple
;Expected: '((0 1 2 3 4 5 6 7 8 9) (0 1 2 3 4 5 6 7 8 9) (0 1 2 3 4 5 6 7 8 9))
(duple 3 (list 0 1 2 3 4 5 6 7 8 9))

;#10) sort/predicate
;Expected: '(2 2 3 5 8 34)
(sort/predicate < '(3 5 8 34 2 2))
;#10) sort/predicate
;Expected: '(9 8 7 6 5 4 3 2 1 0)
(sort/predicate > (list 0 1 2 3 4 5 6 7 8 9))
