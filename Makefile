# VARIABLES
TARG=sgs-enabler
PACKAGE="github.com/basilboli/forwardproxy"
BINARY_NAME="forwardproxy"
IMAGE_NAME="basilboli/forwardproxy"

print_success = echo -e "\e[1;32m$(1) $<\e[0m"
print_warning = echo -e "\e[1;33m$(1) $<\e[0m"
print_error = echo -e "\e[1;31m$(1) $<\e[0m"

export GOPATH=$(shell pwd)

# Default target : Do nothing
default:
	@echo "You must specify a target with this makefile"
	@echo "Usage : "
	@echo "make clean        Remove binary files"
	@echo "make install      Compile sources and build binaries"
	@echo "make test         Run all tests of your application"
	@echo "make run          Build application and run it !"
	@echo "make dockerize    Dockerize application !"

# Clean .o files and binary
clean:
	@echo "--> cleaning..."
	@go clean || (echo "Unable to clean project" && exit 1)
	@rm -rf bin/$(BINARY_NAME) 2> /dev/null
	@echo "Clean OK"

# Compile sources and build binary
install: clean
	@echo "--> installing..."
	@echo "GOPATH : $(GOPATH)"
	@go install $(PACKAGE) || ($(call print_error,Compilation error) && exit 1)
	@echo "Install OK"

# Run your application
run: clean install
	@echo "--> running application..."
	@./bin/$(BINARY_NAME)

# Test your application
test:
	@echo "--> testing..."
	@go test -v $(PACKAGE)/...

resolve-deps:
	@echo "--> resolving dependencies..."	
	cd src/github.com/basilboli/forwardproxy; go get -v $(go list -e ./... | grep -v vendor) && go get -t $(go list -e ./... | grep -v vendor)
	cd src/github.com/basilboli/forwardproxy; go test -v $(go list -e ./... | grep -v vendor)

# Dockerize your application
dockerize: resolve-deps
	@echo "--> dockerizing..."	
	@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $(BINARY_NAME) $(PACKAGE)|| ($(call print_error,Compilation error) && exit 1)
	docker build -t $(IMAGE_NAME) -f Dockerfile.scratch .
	@rm -f $(BINARY_NAME)