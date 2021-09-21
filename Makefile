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

define caserule1
$(call residual, $(1)):
	$$(call runcase, $$(call casedir, $$@),)
endef

define caserule2
$(call residual, $(1)): $(call residual, $(2))
	$$(call runcase, $$(call casedir, $$@), $$(call casedir, $$<))
endef

define caserule2a
$(call residual, $(1)): $(call residual, $(2))
	$$(call runcase, $$(call casedir, $$@),)
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
KAY:=$(foreach i,1 2 3 4, $(addsuffix /mesh$(i),$(addprefix Ret395/bulk/kOmegaSST/kay/Pr,0.025 0.71 1 2 5 7 10)))
KAY+=$(foreach i,1 2 3 4 5, $(addsuffix /mesh$(i),$(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)))
MANSERVISI:=$(addsuffix /mesh4,$(addprefix Ret395/bulk/kOmegaSST/manservisi/Pr,0.025 0.71 1 2 5 7 10))
MANSERVISI+=$(addsuffix /mesh5,$(addprefix Ret640/bulk/kOmegaSST/manservisi/Pr,0.025 0.71))
AHFM:=$(addsuffix /mesh4,$(addprefix Ret395/bulk/kOmegaSST/AHFM/Pr,0.025 0.71 1 2 5 7 10))
AHFM+=$(addsuffix /mesh4,$(addprefix Ret640/bulk/kOmegaSST/AHFM/Pr,0.025 0.71))
ADD_CASES:=$(addprefix Ret640/bulk/epsWall/mesh,1 2 3 4 5)
ADD_CASES+=$(addprefix Ret640/bulk/streamwise/mesh1-,2 3 4)
ADD_CASES+=$(addprefix Ret640/bulk/streamwise/mesh4-,2 3 4)
ADD_CASES+=$(addprefix Ret640/bulk/kOmegaSST/reAnalogy/mesh,1 2 3 4 5)
ADD_CASES+=$(addprefix Ret395/bulk/kOmegaSST/reAnalogy/mesh,1 2 3 4)

RESIDUALS:=$(addsuffix /postProcessing/residuals/0/residuals.png,$(CASES))
ADD_RESIDUALS:=$(addsuffix /postProcessing/residuals/0/residuals.png,$(ADD_CASES))

all: cases
allinall: all additional kay manservisi ahfm
cases: $(RESIDUALS)
additional: $(ADD_RESIDUALS)

kay: $(addsuffix /postProcessing/residuals/0/residuals.png,$(KAY))

manservisi: $(addsuffix /postProcessing/residuals/0/residuals.png,$(MANSERVISI))

ahfm: $(addsuffix /postProcessing/residuals/0/residuals.png,$(AHFM))

$(foreach c, $(AHFM),\
	$(eval $(call caserule2a, $(c),\
		$(shell sed -e's!/AHFM/Pr[0-9.]*/!/reAnalogy/!' <<<"$(c)"))))

$(foreach c, $(MANSERVISI),\
	$(eval $(call caserule2a, $(c),\
		$(shell sed -e's!/manservisi/Pr[0-9.]*/!/reAnalogy/!' <<<"$(c)"))))

$(foreach c,\
	$(addsuffix /mesh1,$(addprefix Ret395/bulk/kOmegaSST/kay/Pr,0.025 0.71 1 2 5 7 10) $(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)),\
	$(eval $(call caserule1, $(c))))

$(foreach c,\
	$(addsuffix /mesh2,$(addprefix Ret395/bulk/kOmegaSST/kay/Pr,0.025 0.71 1 2 5 7 10) $(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)),\
	$(eval $(call caserule2, $(c),$(subst /mesh2,/mesh1,$(c)))))

$(foreach c,\
	$(addsuffix /mesh3,$(addprefix Ret395/bulk/kOmegaSST/kay/Pr,0.025 0.71 1 2 5 7 10) $(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)),\
	$(eval $(call caserule2, $(c),$(subst /mesh3,/mesh2,$(c)))))

$(foreach c,\
	$(addsuffix /mesh4,$(addprefix Ret395/bulk/kOmegaSST/kay/Pr,0.025 0.71 1 2 5 7 10) $(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)),\
	$(eval $(call caserule2, $(c),$(subst /mesh4,/mesh3,$(c)))))

$(foreach c,\
	$(addsuffix /mesh5,$(addprefix Ret640/bulk/kOmegaSST/kay/Pr,0.025 0.71)),\
	$(eval $(call caserule2, $(c),$(subst /mesh5,/mesh4,$(c)))))

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

clean_kay:
	@for case in $(KAY); do pushd $$case; ./Allclean; popd; done

clean_manservisi:
	@for case in $(MANSERVISI); do pushd $$case; ./Allclean; popd; done

clean_ahfm:
	@for case in $(AHFM); do pushd $$case; ./Allclean; popd; done

.PHONY: all cases kay manservisi ahfm allinall clean clean_cases plots clean_plots clean_kay clean_manservisi clean_ahfm


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

$(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh2): $(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh3): $(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh4): $(call residual, Ret395/bulk/kOmegaSST/reAnalogy/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh1):
	$(call runcase, $(call casedir, $@),)

$(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh2): $(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh1)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh3): $(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh2)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh4): $(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh3)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

$(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh5): $(call residual, Ret640/bulk/kOmegaSST/reAnalogy/mesh4)
	$(call runcase, $(call casedir, $@),$(call casedir, $<))

clean: clean_additional
clean_additional:
	@for case in $(ADD_CASES); do pushd $$case; ./Allclean; popd; done

.PHONY: additional clean_additional
