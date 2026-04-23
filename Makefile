# Enforce executable bits on all shell scripts after clone
fix-modes:
	@find . -name "*.sh" -o -name "prerun.sh" | grep -v ".git" | \
	  xargs -I{} git update-index --chmod=+x {}
	@echo "All shell scripts marked executable."

.PHONY: fix-modes
