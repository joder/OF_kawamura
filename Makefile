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
TAU:=$(addprefix tau/,$(MESH))
BULK:=$(addprefix bulk/,$(MESH))

CASE395TAU:=$(addprefix Ret395/,$(TAU))
CASE395BULK:=$(addprefix Ret395/,$(BULK))
CASE640TAU:=$(addprefix Ret640/,$(TAU) tau/mesh5)
CASE640BULK:=$(addprefix Ret640/,$(BULK) bulk/mesh5)
CASES:=$(CASE395TAU) $(CASE395BULK) $(CASE640TAU) $(CASE640BULK)

RESIDUALS:=$(addsuffix /postProcessing/residuals/0/residuals.png,$(CASES))

all: cases
cases: $(RESIDUALS)

$(call residual, Ret395/bulk/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/tau/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/bulk/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/tau/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/bulk/mesh2): $(call residual, Ret395/bulk/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/mesh2): $(call residual, Ret395/tau/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/mesh2): $(call residual, Ret640/bulk/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/mesh2): $(call residual, Ret640/tau/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/mesh3): $(call residual, Ret395/bulk/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/mesh3): $(call residual, Ret395/tau/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/mesh3): $(call residual, Ret640/bulk/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/mesh3): $(call residual, Ret640/tau/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/mesh4): $(call residual, Ret395/bulk/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/tau/mesh4): $(call residual, Ret395/tau/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/mesh4): $(call residual, Ret640/bulk/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/mesh4): $(call residual, Ret640/tau/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/mesh5): $(call residual, Ret640/bulk/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/tau/mesh5): $(call residual, Ret640/tau/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

plots: $(RESIDUALS)
	@for case in Ret{395,640}/{bulk,tau}; do pushd $$case; ./scripts/plots; popd; done
	@for case in Ret{395,640}; do pushd $$case; ./scripts/plots; popd; done

clean: clean_cases clean_plots
clean_cases:
	@for case in $(CASES); do pushd $$case; ./Allclean; popd; done
clean_plots:
	@for case in Ret{395,640}/{bulk,tau}; do pushd $$case; $(RM) *.png; popd; done
	@for case in Ret{395,640}; do pushd $$case; $(RM) *.png; popd; done

.PHONY: all cases clean clean_cases plots clean_plots
