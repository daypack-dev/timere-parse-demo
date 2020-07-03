SRCFILES = src/*.ml

OCAMLFORMAT = ocamlformat \
	--inplace \
	$(SRCFILES)

OCPINDENT = ocp-indent \
	--inplace \
	$(SRCFILES)

.PHONY: all
all : build

.PHONY: build
build :
	dune build @js
	cp html/index.html _build/default/src/
ifneq ($(DEBUG), 1)
	find _build/ -name "dune" -type f -delete
	find _build/ -name "*.ml" -type f -delete
	find _build/ -name "*.mli"      -type f -delete
	find _build/ -name "*.mly"      -type f -delete
	find _build/ -name "*.mll"      -type f -delete
	find _build/ -name "*.inferred" -type f -delete
	find _build/ -name "*.mock"     -type f -delete
	find _build/ -name "*.cmi"      -type f -delete
	find _build/ -name "*.bc"       -type f -delete
	rm -r _build/default/src/.demo.eobjs/
	find _build/ -name ".merlin" -type f -delete
	find _build/ -name ".merlin-exists" -type f -delete
endif

.PHONY: test
test :
	OCAMLRUNPARAM=b dune exec ./tests/main.exe

.PHONY: format
format :
	$(OCAMLFORMAT)
	$(OCPINDENT)

.PHONY : clean
clean:
	dune clean
