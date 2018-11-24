# Apply version-specific LLVM patches
LLVM_PATCH_PREV:=
LLVM_PATCH_LIST:=
define LLVM_PATCH
$$(LLVM_SRC_DIR)/$1.patch-applied: $$(LLVM_SRC_DIR) | llvm-patches/$1.patch $$(LLVM_PATCH_PREV)
	cd $$(LLVM_SRC_DIR) && patch -p1 < ../../llvm-patches/$1.patch
	echo 1 > $$@
LLVM_PATCH_PREV := $$(LLVM_SRC_DIR)/$1.patch-applied
LLVM_PATCH_LIST += $$(LLVM_PATCH_PREV)
endef

ifeq ($(LLVM_VER_SHORT),6.0)
ifeq ($(LLVM_VER_PATCH), 0)
$(eval $(call LLVM_PATCH,llvm-D27629-AArch64-large_model_4.0))
else
$(eval $(call LLVM_PATCH,llvm-D27629-AArch64-large_model_6.0.1))
endif
$(eval $(call LLVM_PATCH,llvm-D34078-vectorize-fdiv))
$(eval $(call LLVM_PATCH,llvm-6.0-NVPTX-addrspaces)) # NVPTX
$(eval $(call LLVM_PATCH,llvm-D42262-jumpthreading-not-i1)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-PPC-addrspaces)) # remove for 7.0
ifeq ($(LLVM_VER_PATCH), 0)
$(eval $(call LLVM_PATCH,llvm-D42260)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-rL326843-missing-header)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-6.0-r327540)) # remove for 7.0
endif
$(eval $(call LLVM_PATCH,llvm-6.0.0_D27296-libssp)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-6.0-D44650)) # mingw32 build fix
ifeq ($(LLVM_VER_PATCH), 0)
$(eval $(call LLVM_PATCH,llvm-D45008)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-D45070)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-6.0.0-ifconv-D45819)) # remove for 7.0
endif
$(eval $(call LLVM_PATCH,llvm-D46460))
ifeq ($(LLVM_VER_PATCH), 0)
$(eval $(call LLVM_PATCH,llvm-rL332680)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-rL332682)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-rL332302)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-rL332694)) # remove for 7.0
endif
$(eval $(call LLVM_PATCH,llvm-rL327898)) # remove for 7.0
$(eval $(call LLVM_PATCH,llvm-6.0-DISABLE_ABI_CHECKS))
$(eval $(call LLVM_PATCH,llvm-OProfile-line-num))
$(eval $(call LLVM_PATCH,llvm-D44892-Perf-integration))
$(eval $(call LLVM_PATCH,llvm-D49832-SCEVPred)) # Remove for 7.0
$(eval $(call LLVM_PATCH,llvm-rL323946-LSRTy)) # Remove for 7.0
$(eval $(call LLVM_PATCH,llvm-D50010-VNCoercion-ni))
$(eval $(call LLVM_PATCH,llvm-D50167-scev-umin))
$(eval $(call LLVM_PATCH,llvm-rL326967-aligned-load)) # remove for 7.0
ifeq ($(LLVM_VER_PATCH), 0)
$(eval $(call LLVM_PATCH,llvm-windows-race))
endif
endif # LLVM_VER
