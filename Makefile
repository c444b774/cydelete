BUNDLEDIR=/Library/MobileSubstrate/DynamicLibraries
BUNDLENAME=CyDelete.bundle
VERSION:=$(shell grep Version layout/DEBIAN/control | cut -d' ' -f2)

CFLAGS=-DBUNDLE="@\"$(BUNDLEDIR)/$(BUNDLENAME)\"" -DVERSION="$(VERSION)" -O2

tweak=CyDelete
subdirs=CyDeleteSettings.bundle
include /home/dustin/framework/itouch/makefiles/MSMakefile

project-all: setuid

setuid:
	$(CC) -o setuid setuid.c
	$(STRIP) -x setuid
	CODESIGN_ALLOCATE=$(CODESIGN_ALLOCATE) ldid -S $@

project-clean:
	rm -f setuid

project-package-local:
	cp CyDeleteSettings.bundle/CyDeleteSettings _/System/Library/PreferenceBundles/CyDeleteSettings.bundle/
	cp setuid _/usr/libexec/cydelete
	rm _$(BUNDLEDIR)/$(BUNDLENAME)/convert.sh
	sed -i "s/VERSION/$(VERSION)/g" _/System/Library/PreferenceBundles/CyDeleteSettings.bundle/Info.plist
	sed -i "s/VERSION/$(VERSION)/g" _/Library/MobileSubstrate/DynamicLibraries/CyDelete.bundle/Info.plist

project-package-post:
	chmod 6755 _/usr/libexec/cydelete/setuid
	-find _ -iname '*.plist' -print0 | xargs -0 /home/dustin/bin/plutil -convert binary1
	-find _ -iname '*.strings' -print0 | xargs -0 /home/dustin/bin/plutil -convert binary1
