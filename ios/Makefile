# Crisis Pulse iOS — convenience Makefile
#
# Usage:
#   make setup     — install xcodegen + generate the .xcodeproj
#   make project   — regenerate project from project.yml after changes
#   make open      — open project in Xcode
#   make clean     — remove generated files

.PHONY: setup project open clean

setup:
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	@$(MAKE) project

project:
	xcodegen generate

open:
	open CrisisPulse.xcodeproj

clean:
	rm -rf CrisisPulse.xcodeproj
	rm -rf build/ DerivedData/
