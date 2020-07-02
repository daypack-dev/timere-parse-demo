FROM ocaml/opam2:4.08
RUN opam init
RUN sudo apt-get install --yes m4
RUN opam pin add daypack-lib https://github.com/daypack-dev/daypack-lib.git
RUN cd time-expr-demo; make
