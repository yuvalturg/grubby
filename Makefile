
VERSION = $(shell awk -F= '/^VERSION=/ { print $$2 }' mkinitrd)
RELEASE = $(shell awk '/^Release:/ { print $$2 }' mkinitrd.spec.in)
SUBDIRS = nash grubby

include Makefile.inc

test: all
	cd grubby; make test

install:
	for n in $(SUBDIRS); do make -C $$n install BUILDROOT=$(BUILDROOT); done
	for i in sbin $(mandir)/man8; do \
		if [ ! -d $(BUILDROOT)/$$i ]; then \
			mkdir -p $(BUILDROOT)/$$i; \
		fi; \
	done
	sed 's/%VERSIONTAG%/$(VERSION)/' < mkinitrd > $(BUILDROOT)/sbin/mkinitrd
	install -m755 installkernel $(BUILDROOT)/sbin/installkernel
	chmod 755 $(BUILDROOT)/sbin/mkinitrd
	install -m644 mkinitrd.8 $(BUILDROOT)/$(mandir)/man8/mkinitrd.8

archive:
	cvs tag -F $(CVSTAG) .
	@rm -rf /tmp/mkinitrd-$(VERSION)
	@cd /tmp; cvs -Q -d $(CVSROOT) export -r$(CVSTAG) mkinitrd || :
	@cd /tmp/mkinitrd; sed "s/VERSIONSUBST/$(VERSION)/" < mkinitrd.spec.in > mkinitrd.spec
	@mv /tmp/mkinitrd /tmp/mkinitrd-$(VERSION)
	@dir=$$PWD; cd /tmp; tar -cv --bzip2 -f $$dir/mkinitrd-$(VERSION).tar.bz2 mkinitrd-$(VERSION)
	@rm -rf /tmp/mkinitrd-$(VERSION)
	@echo "The archive is in mkinitrd-$(VERSION).tar.bz2"
