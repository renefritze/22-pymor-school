IMAGE=zivgitlab.wwu.io/pymor/texlive-docker:ff58129

THIS_DIR = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ifndef CI
    NO_DOCKER = $(shell systemctl -q is-active docker; echo $$? )
    INTERACTIVE = -ti
    USERARGS = -e LOCAL_USER=${USER} -e LOCAL_UID=$(shell id -u) -e LOCAL_GID=$(shell id -g)
else
    NO_DOCKER = 0
    INTERACTIVE =
    USERARGS = -e LOCAL_USER=${USER} -e LOCAL_UID=$(shell id -u) -e LOCAL_GID=$(shell id -g)
endif

ifeq (${NO_DOCKER}, 0)
    DOCKER = docker run $(INTERACTIVE) $(USERARGS) -v $(THIS_DIR):/src $(IMAGE)
    # don't want to (and cannot) run a viewer from inside the image
    VIEW = -view=none
		VERA = docker run $(USERARGS) -v $(THIS_DIR):/src renefritze/verapdf:d1.13.29-1-g54a1035
else
    DOCKER =
    VIEW =
		VERA = echo verapdf not available w/o docker
endif

LATEXMK = $(DOCKER) latexmk -f

all: integration_with_pde_solvers

%.lbl:
	scripts/label.py $*.tex

includes/util/vc.tex: FORCE
	cd includes/util/ && sh ./vc.sh -m -f

%.pdf: FORCE
	$(LATEXMK) $(PREVIEW_CONTINUOUSLY) $(LATEXMK_EXTRA) -jobname=tmp$* $*.tex
	cp -f tmp$*.synctex.gz $*.synctex.gz
	cp -f tmp$*.pdf $*.pdf
	cp -f tmp$*.log $*.log

integration_with_pde_solvers: integration_with_pde_solvers.pdf

debug: LATEXMK_EXTRA=-f-
debug: integration_with_pde_solvers

run:
	$(DOCKER) bash

check: integration_with_pde_solvers
	$(DOCKER) chktex integration_with_pde_solvers.tex
	$(DOCKER) lacheck integration_with_pde_solvers.tex
	$(VERA) verapdf -f 1b --fixmetadata /src/integration_with_pde_solvers.pdf > verapdf.report.xml
	grep 'validationReports compliant="1"' verapdf.report.xml \
		|| (echo Validation failed ; false ) \
		&& echo Validation passed

FORCE:

.PHONY: watch clean pdf check FORCE
# Set the PREVIEW_CONTINUOUSLY variable to -pvc to switch latexmk into the preview continuously mode
watch: PREVIEW_CONTINUOUSLY=-pvc -halt-on-error $(VIEW)
watch: integration_with_pde_solvers

# -bibtex also removes the .bbl files
clean:
	# 	rm -f includes/labels.tex
	latexmk -f -verbose -C -bibtex
	latexmk -f -C -jobname=tmpintegration_with_pde_solvers integration_with_pde_solvers.tex
