default: build

AUTHOR="Søren Mortensen & George Taylor"
GITHUB_URL="https://github.com/geosor/SymondsStudentApp"
JAZZY_SCHEME=SSACore
MODULE=SymondsStudentApp
DOCS_DIR="docs"

JAZZY_ARGS=--clean --author $(AUTHOR) --github_url $(GITHUB_URL) --xcodebuild-arguments -scheme,$(JAZZY_SCHEME) --module $(MODULE) --output $(DOCS_DIR)

get-deps:
	bundle install
	brew bundle

build:
	bundle exec fastlane ios build

test:
	bundle exec fastlane ios test

jazzy:
	bundle exec jazzy $(JAZZY_ARGS) --min-acl public

jazzy-internal:
	bundle exec jazzy $(JAZZY_ARGS) --min-acl internal

jazzy-private:
	bundle exec jazzy $(JAZZY_ARGS) --min-acl private

.PHONY: build test
