FROM ocaml/opam2:4.08
RUN opam init
RUN opam pin add daypack-lib https://github.com/daypack-dev/daypack-lib.git
RUN make
