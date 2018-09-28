
define user-confirm
	@while true; do \
	  read -p ${1}'[y/n]: ' yn ;\
	  case $$yn in \
      [Yy]* ) break;; \
      [Nn]* ) echo "Aborted" && exit 1;; \
      * ) echo "Please answer yes or no.";; \
	  esac \
	done \

endef
