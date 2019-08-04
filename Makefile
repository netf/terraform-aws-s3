all: init run-tests

init:  ## Install project dependencies
	@echo "Installing dependencies"
	bash -c "bundle install"

run-tests:  ## Run project tests
	@echo "Running tests"
	bash -c "bundle exec kitchen test"