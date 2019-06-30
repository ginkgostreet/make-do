# # #
# Utilities for using and managing environment configuration files.
#
# TO USE:
# Insert the following at the begining of your Makefile, listing all of your config files:
#	CONFIG_INCLUDES = conf/project.conf conf/db.conf
#	include utils/configure-utils.mk
#
# IMPORTANT: each of your config files must have a template file (.tpl). Config files must have a .conf file-extension.
#
# WARNING: escape spaces in paths your config-include list. 
#
# WARNING: ignores lines that do not contain an 'export'.
# SAMPLE: export PROJECT_ROOT ?= /var/www/# comments like this are used in user-prompts.
#	prompt: export PROJECT_ROOT ( comments liek this are used in user-prompts. ) = [/var/www/]?
#
# TIP: include a trailing-slash when configuring paths. 
# TIP: terminate paths with a hash/sharp to avoid the error of trailing-white-space.
#
# FEATURES:
# Includes the files in the CONFIG_INCLUDES list.
#
# Set AUTO_INCLUDE_CONFS instead of CONFIG_INCLUDES to include files that match conf/*.conf.
# e.g. AUTO_INCLUDE_CONFS = true # i.e. empty is false
#
# Provides an implicit recipe for %.conf files. This causes missing configuration files to be automatically (and interactively) generated.
#
# Provides a target, "reconfigure" that will interactively prompt you to enter the config values. Since the config file is always loaded first, you can run configure multiple times, and existing configs will be loaded as default values.
#
# TIP: to generate a specific conf file, just make it!
# e.g. make -B -f utils/configure-utils.mk  conf/db.conf
# -B will force if you want to re-configure an existing file.
#
# # #

CACHED_DG := ${.DEFAULT_GOAL}# ensure we don't interfere with the default goal

# # #
# Shell-escape spaces.
# e.g. $(call escape-spaces, string with spaces)
#
space := 
space += # hack that exploits implicit space added when concatenating assignment
escape-spaces = $(subst ${space},\${space},$(strip $1))

# # #
# keep track of this location
this-dir := $(call escape-spaces,$(realpath $(dir $(lastword $(MAKEFILE_LIST)))))/

ifdef AUTO_INCLUDE_CONFS
 CONFIG_INCLUDES = $(shell find conf -name *.conf)
endif

ifndef CONFIG_INCLUDES
$(error CONFIG_INCLUDES must be set before including configure-utils.mk)
endif
include ${CONFIG_INCLUDES}

%.conf: | ${this-dir}prompt-for-configs.sh-is-exec
	${this-dir}prompt-for-configs.sh ${*}.tpl ${@}

%-is-exec:
	chmod a+x ${*}

reconfigure:
	$(MAKE) -RrB ${CONFIG_INCLUDES}
.PHONY: reconfigure

# # #
# Shell command to replace {{TOKENs}} in a file
# Copy a template and then replace the tokens in the copy.
#
REPLACE_TOKENS = perl -p -i -e 's%\{\{([^}]+)\}\}%defined $$ENV{$$1} ? $$ENV{$$1} : $$&%eg'

.DEFAULT_GOAL := ${CACHED_DG}
