.PHONY: paper.pdf refresh clean

paper.pdf: refresh
	latexrun/latexrun -W no-unbalanced -W no-overfull cv.tex 

refresh:
	rm -f cv.pdf

clean: refresh
	rm -rf latex.out
