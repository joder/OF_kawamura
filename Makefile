define runcase
cd $1; ./Allrun $(addprefix ../../,$2); ! grep -isq 'error' $(addsuffix /log.*, $1) >/dev/null 2>&1
endef

define cleancase
cd $1; ./Allclean
endef

define residual
$(addsuffix /postProcessing/residuals/0/residuals.png,$1)
endef

define casedir
$(subst /postProcessing/residuals/0/residuals.png,,$1)
endef

# This makefile is written without actual dependencies. Mainly because I am lazy.

MESH:=$(addprefix mesh,1 2 3 4)
TAU:=$(addprefix tau/LSkEps/,$(MESH))
BULK:=$(addprefix bulk/LSkEps/,$(MESH))

CASE395TAU:=$(addprefix Ret395/,$(TAU))
CASE395BULK:=$(addprefix Ret395/,$(BULK))
CASE640TAU:=$(addprefix Ret640/,$(TAU) tau/LSkEps/mesh5)
CASE640BULK:=$(addprefix Ret640/,$(BULK) bulk/LSkEps/mesh5)
CASES:=$(CASE395TAU) $(CASE395BULK) $(CASE640TAU) $(CASE640BULK)
ADD_CASES:=$(addprefix Ret640/bulk/epsWall/mesh,1 2 3 4 5)
ADD_CASES+=$(addprefix Ret640/bulk/streamwise/mesh1-,2 3 4)
ADD_CASES+=$(addprefix Ret640/bulk/streamwise/mesh4-,2 3 4)
ADD_CASES+=$(addprefix Ret640/bulk/kOmegaSST/reAnalogy/mesh,1 2 3 4 5)
ADD_CASES+=$(addprefix Ret395/bulk/kOmegaSST/reAnalogy/mesh,1 2 3 4)

RESIDUALS:=$(addsuffix /postProcessing/residuals/0/residuals.png,$(CASES))
ADD_RESIDUALS:=$(addsuffix /postProcessing/residuals/0/residuals.png,$(ADD_CASES))

all: cases
cases: $(RESIDUALS)
additional: $(ADD_RESIDUALS)

$(call residual, Ret395/bulk/LSkEps/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/tau/LSkEps/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/bulk/LSkEps/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/tau/LSkEps/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/bulk/LSkEps/mesh2): $(call residual, Ret395/bulk/LSkEps/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/LSkEps/mesh2): $(call residual, Ret395/tau/LSkEps/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/LSkEps/mesh2): $(call residual, Ret640/bulk/LSkEps/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/LSkEps/mesh2): $(call residual, Ret640/tau/LSkEps/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/LSkEps/mesh3): $(call residual, Ret395/bulk/LSkEps/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/LSkEps/mesh3): $(call residual, Ret395/tau/LSkEps/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/LSkEps/mesh3): $(call residual, Ret640/bulk/LSkEps/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/LSkEps/mesh3): $(call residual, Ret640/tau/LSkEps/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/LSkEps/mesh4): $(call residual, Ret395/bulk/LSkEps/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/LSkEps/mesh4): $(call residual, Ret395/tau/LSkEps/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/LSkEps/mesh4): $(call residual, Ret640/bulk/LSkEps/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/LSkEps/mesh4): $(call residual, Ret640/tau/LSkEps/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/LSkEps/mesh5): $(call residual, Ret640/bulk/LSkEps/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/LSkEps/mesh5): $(call residual, Ret640/tau/LSkEps/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

plots: $(RESIDUALS)
	@for case in Ret{395,640}/{bulk,tau}/LSkEps; do pushd $$case; ./scripts/plots; popd; done
	@for case in Ret{395,640}; do pushd $$case; ./scripts/plots; popd; done

clean: clean_cases clean_plots
clean_cases:
	@for case in $(CASES); do pushd $$case; ./Allclean; popd; done
clean_plots:
	@for case in Ret{395,640}/{bulk,tau}/LSkEps; do pushd $$case; $(RM) *.png; popd; done
	@for case in Ret{395,640}; do pushd $$case; $(RM) *.png; popd; done

.PHONY: all cases clean clean_cases plots clean_plots


$(call residual, Ret640/bulk/epsWall/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/bulk/epsWall/mesh2): $(call residual, Ret640/bulk/epsWall/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/epsWall/mesh3): $(call residual, Ret640/bulk/epsWall/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/epsWall/mesh4): $(call residual, Ret640/bulk/epsWall/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/epsWall/mesh5): $(call residual, Ret640/bulk/epsWall/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh1-2): $(call residual, Ret640/bulk/LSkEps/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh1-3): $(call residual, Ret640/bulk/streamwise/mesh1-2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh1-4): $(call residual, Ret640/bulk/streamwise/mesh1-3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh4-2): $(call residual, Ret640/bulk/LSkEps/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh4-3): $(call residual, Ret640/bulk/streamwise/mesh4-2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/streamwise/mesh4-4): $(call residual, Ret640/bulk/streamwise/mesh4-3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh2): $(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh3): $(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh4): $(call residual, Ret395/bulk/reAnalogy/kOmegaSST/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh2): $(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh3): $(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh4): $(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh5): $(call residual, Ret640/bulk/reAnalogy/kOmegaSST/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

clean: clean_additional
clean_additional:
	@for case in $(ADD_CASES); do pushd $$case; ./Allclean; popd; done

.PHONY: additional clean_additional
