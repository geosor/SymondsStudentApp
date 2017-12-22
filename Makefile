default: build

AUTHOR="Søren Mortensen & George Taylor"
GITHUB_URL="https://github.com/geosor/SymondsStudentApp"
PROJECT_NAME="SymondsStudentApp"
SCHEME="SSACore"
MODULE=$(SCHEME)
DOCS_DIR="docs"
DEV_TEAM_ID="3JFQF766SZ"

build:
	if which xcpretty >/dev/null; \
	  then \
	  xcodebuild -project "$(PROJECT_NAME).xcodeproj" -scheme "$(SCHEME)" -sdk "macosx" -configuration Debug | xcpretty;\
	else\
	  xcodebuild -project "$(PROJECT_NAME).xcodeproj" -scheme "$(SCHEME)" -sdk "macosx" -configuration Debug;\
	fi

test:
	if which xcpretty >/dev/null; \
	  then \
	  xcodebuild test -project "$(PROJECT_NAME).xcodeproj" -scheme "$(SCHEME)" -sdk "macosx" -configuration Debug | xcpretty;\
	else\
	  xcodebuild test -project "$(PROJECT_NAME).xcodeproj" -scheme "$(SCHEME)" -sdk "macosx" -configuration Debug;\
	fi

jazzy:
	jazzy \
	  --clean \
	  --author $(AUTHOR) \
	  --github_url $(GITHUB_URL) \
	  --xcodebuild-arguments -scheme,$(SCHEME) \
	  --module $(MODULE) \
	  --output $(DOCS_DIR) \
	  --min-acl public

jazzy-internal:
	jazzy \
	  --clean \
	  --author $(AUTHOR) \
	  --github_url $(GITHUB_URL) \
	  --xcodebuild-arguments -scheme,$(SCHEME) \
	  --module $(MODULE) \
	  --output $(DOCS_DIR) \
	  --min-acl internal

jazzy-private:
	jazzy \
	  --clean \
	  --author $(AUTHOR) \
	  --github_url $(GITHUB_URL) \
	  --xcodebuild-arguments -scheme,$(SCHEME) \
	  --module $(MODULE) \
	  --output $(DOCS_DIR) \
	  --min-acl private

.PHONY: build test

