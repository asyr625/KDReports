TEMPLATE = subdirs
SUBDIRS  = src examples include
unittests: SUBDIRS += unittests
CONFIG   += ordered
VERSION  = 1.5.99
MAJOR_VERSION = 1

unix:DEFAULT_INSTALL_PREFIX = /usr/local/KDAB/KDReports-$$VERSION
win32:DEFAULT_INSTALL_PREFIX = "C:\KDAB\KDReports"-$$VERSION

# for backw. compat. we still allow manual invocation of qmake using PREFIX:
isEmpty( KDREPORTS_INSTALL_PREFIX ): KDREPORTS_INSTALL_PREFIX=$$PREFIX

# if still empty we use the default:
isEmpty( KDREPORTS_INSTALL_PREFIX ): KDREPORTS_INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX

# if the default was either set by configure or set by the line above:
equals( KDREPORTS_INSTALL_PREFIX, $$DEFAULT_INSTALL_PREFIX ){
    INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX
    unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure.sh -prefix DIR to specify))
    !unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure -prefix DIR to specify))
} else {
    INSTALL_PREFIX=\"$$KDREPORTS_INSTALL_PREFIX\"
}

DEBUG_SUFFIX=""
VERSION_SUFFIX=""
CONFIG(debug, debug|release) {
  !unix: DEBUG_SUFFIX = d
}
!unix:!mac:!static:VERSION_SUFFIX=$$MAJOR_VERSION

KDREPORTSLIB = kdreports$$DEBUG_SUFFIX$$VERSION_SUFFIX
KDREPORTSTESTTOOLSLIB = kdreporttesttools$$DEBUG_SUFFIX$$VERSION_SUFFIX
message(Install prefix is $$INSTALL_PREFIX)
message(This is KD Reports version $$VERSION)

# These files are in the build directory (Because "somecommand >> somefile" puts them there)
CONFQMAKE_CACHE = "$${OUT_PWD}/.confqmake.cache"
QMAKE_CACHE = "$${OUT_PWD}/.qmake.cache"

# Create a .qmake.cache file
unix:MESSAGE = '\\'$$LITERAL_HASH\\' KDAB qmake cache file: autogenerated during qmake run'
!unix:MESSAGE = $$LITERAL_HASH' KDAB qmake cache file: autogenerated during qmake run'

system('echo $${MESSAGE} > $${QMAKE_CACHE}')

TMP_SOURCE_DIR = $${IN_PWD}
TMP_BUILD_DIR = $${OUT_PWD}
system('echo TOP_SOURCE_DIR=$${TMP_SOURCE_DIR} >> $${QMAKE_CACHE}')
system('echo TOP_BUILD_DIR=$${TMP_BUILD_DIR} >> $${QMAKE_CACHE}')
windows:INSTALL_PREFIX=$$replace(INSTALL_PREFIX, \\\\, /)
system('echo INSTALL_PREFIX=$$INSTALL_PREFIX >> $${QMAKE_CACHE}')
system('echo VERSION=$$VERSION >> $${QMAKE_CACHE}')
system('echo KDREPORTSLIB=$$KDREPORTSLIB >> $${QMAKE_CACHE}')
system('echo KDREPORTSTESTTOOLSLIB=$$KDREPORTSTESTTOOLSLIB >> $${QMAKE_CACHE}')

# forward make test calls to unittests:
test.target=test
unix:!macx:test.commands=export LD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(LD_LIBRARY_PATH); (cd unittests && $(MAKE) test)
macx:test.commands=export DYLD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(DYLD_LIBRARY_PATH); (cd unittests && $(MAKE) test)
win32:test.commands=(cd unittests && $(MAKE) test)
test.depends = $(TARGET)
QMAKE_EXTRA_TARGETS += test

# install licenses: 
licenses.files = LICENSE.txt LICENSE.US.txt LICENSE.LGPL.txt
licenses.path = $$INSTALL_PREFIX
INSTALLS += licenses

readme.files = README.txt
readme.path = $$INSTALL_PREFIX
INSTALLS += readme

# for qt-creator:
OTHER_FILES = \
    doc/CHANGES_1_1.txt \
    doc/CHANGES_1_2.txt \
    doc/CHANGES_1_3.txt \
    doc/CHANGES_1_4.txt \
    Install.rc
