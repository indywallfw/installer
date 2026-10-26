SUBDIR=		src
SUBDIR_TARGETS=	upgrade

.include <bsd.subdir.mk>

SCRIPTS!=	find ${.CURDIR}/src -name "*.sh"

.for SCRIPT in ${SCRIPTS}
${SCRIPT:C/.*\///:S/.sh//}:
	@${MAKE} install
	@bsdinstall ${@}
	@sleep 2
	@clear
.endfor

mnt:
	if mount | awk '{ print $$3 }' | grep -qx /mnt/dev; then umount /mnt/dev; fi
	chflags -R noschg /mnt
	rm -rf /mnt
	mkdir -p /mnt

# unit tests in tests/ (Kyua/ATF; no src/*.sh is named test)
test:
	@RESULTS=$$(mktemp -d -t installer-test); \
	if (cd ${.CURDIR}/tests && kyua test --results-file=$${RESULTS}/results.db); then \
	    rm -rf $${RESULTS}; \
	else \
	    kyua report --verbose --results-file=$${RESULTS}/results.db; \
	    rm -rf $${RESULTS}; exit 1; \
	fi

.PHONY: test
