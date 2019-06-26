OSFLAG :=
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSFLAG=linux
	endif
	ifeq ($(UNAME_S),Darwin)
		OSFLAG=darwin
	endif

wt_version = 1.0.4

compile: bin/wt $(wildcard scss/*.scss)
	bin/wt compile $^ -b css/ || rm -f css/*

watch: $(wildcard scss/*.scss)
	bin/wt watch $^ -b css/

bin/wt:
	@echo "Downloading wellington $(wt_version)"
	@mkdir -p bin
	@cd bin && \
	 curl -LO https://github.com/wellington/wellington/releases/download/v$(wt_version)/wt_v$(wt_version)_$(OSFLAG)_amd64.tar.gz && \
	 tar xzf wt_v$(wt_version)_$(OSFLAG)_amd64.tar.gz && \
	 rm -f wt_v$(wt_version)_$(OSFLAG)_amd64.tar.gz
	@echo "Wellington $(wt_version) was installed"
