WEBROOT=~/src/github.com/kubernetes/website
K8SROOT=~/k8s/src/k8s.io/kubernetes
MINOR_VERSION=16

APISRC=gen-apidocs/generators
APIDST=$(WEBROOT)/static/docs/reference/generated/kubernetes-api/v1.$(MINOR_VERSION)
APISRCFONT=$(APISRC)/build/node_modules/font-awesome
APIDSTFONT=$(APIDST)/node_modules/font-awesome

CLISRC=gen-kubectldocs/generators/build
CLIDST=$(WEBROOT)/static/docs/reference/generated/kubectl
CLISRCFONT=$(CLISRC)/node_modules/font-awesome
CLIDSTFONT=$(CLIDST)/node_modules/font-awesome

default:
	@echo "Support commands:\ncli api comp copycli copyapi copycomp updateapispec"

# Build kubectl docs
cleancli:
	sudo rm -f main
	sudo rm -rf $(shell pwd)/gen-kubectldocs/generators/includes
	sudo rm -rf $(shell pwd)/gen-kubectldocs/generators/build
	sudo rm -rf $(shell pwd)/gen-kubectldocs/generators/manifest.json

cli: cleancli
	go run gen-kubectldocs/main.go --kubernetes-version v1_$(MINOR_VERSION)
	docker run -v $(shell pwd)/gen-kubectldocs/generators/includes:/source -v $(shell pwd)/gen-kubectldocs/generators/build:/build -v $(shell pwd)/gen-kubectldocs/generators/:/manifest pwittrock/brodocs

copycli: cli
	cp gen-kubectldocs/generators/build/index.html $(WEBROOT)/static/docs/reference/generated/kubectl/kubectl-commands.html
	cp gen-kubectldocs/generators/build/navData.js $(WEBROOT)/static/docs/reference/generated/kubectl/navData.js
	cp $(CLISRC)/scroll.js $(CLIDST)/scroll.js
	cp $(CLISRC)/stylesheet.css $(CLIDST)/stylesheet.css
	cp $(CLISRC)/tabvisibility.js $(CLIDST)/tabvisibility.js
	cp $(CLISRC)/node_modules/bootstrap/dist/css/bootstrap.min.css $(CLIDST)/node_modules/bootstrap/dist/css/bootstrap.min.css
	cp $(CLISRC)/node_modules/highlight.js/styles/default.css $(CLIDST)/node_modules/highlight.js/styles/default.css
	cp $(CLISRC)/node_modules/jquery.scrollto/jquery.scrollTo.min.js $(CLIDST)/node_modules/jquery.scrollto/jquery.scrollTo.min.js
	cp $(CLISRC)/node_modules/jquery/dist/jquery.min.js $(CLIDST)/node_modules/jquery/dist/jquery.min.js
	cp $(CLISRCFONT)/css/font-awesome.min.css $(CLIDSTFONT)/css/font-awesome.min.css

# Build kube component docs
cleancomp:
	rm -rf $(shell pwd)/gen-compdocs/build

comp: cleancomp
	mkdir -p gen-compdocs/build
	go run gen-compdocs/main.go gen-compdocs/build kube-apiserver
	go run gen-compdocs/main.go gen-compdocs/build kube-controller-manager
	go run gen-compdocs/main.go gen-compdocs/build cloud-controller-manager
	go run gen-compdocs/main.go gen-compdocs/build kube-scheduler
	go run gen-compdocs/main.go gen-compdocs/build kubelet
	go run gen-compdocs/main.go gen-compdocs/build kube-proxy
	go run gen-compdocs/main.go gen-compdocs/build kubeadm
	go run gen-compdocs/main.go gen-compdocs/build kubectl

copycomp:
	cp $(shell pwd)/gen-compdocs/build/* $(WEBROOT)/docs/reference/generated/

# Build api docs
updateapispec:
	cp $(K8SROOT)/api/openapi-spec/swagger.json gen-apidocs/generators/openapi-spec/swagger.json

api: cleanapi
	go run gen-apidocs/main.go --config-dir=gen-apidocs/generators --munge-groups=false

# NOTE: The following "sudo" may go away when we remove docker based api doc generator
cleanapi:
	sudo rm -rf $(shell pwd)/gen-apidocs/generators/build
	sudo rm -rf $(shell pwd)/gen-apidocs/generators/includes

copyapi:
	cp $(APISRC)/build/index.html $(APIDST)/index.html
	cp $(APISRC)/build/navData.js $(APIDST)/navData.js
	cp $(APISRC)/static/scroll.js $(APIDST)/scroll.js
	mkdir -p $(APIDST)/css
	cp $(APISRC)/static/stylesheet.css $(APIDST)/css/stylesheet.css
	cp $(APISRC)/static/bootstrap.min.css $(APIDST)/css/bootstrap.min.css
	cp $(APISRC)/static/jquery.scrollTo.min.js $(APIDST)/jquery.scrollTo.min.js
	cp $(APISRC)/static/font-awesome.min.css $(APIDST)/css/font-awesome.min.css
	mkdir -p $(APIDST)/fonts
	cp $(APISRC)/static/FontAwesome.otf $(APIDST)/fonts/FontAwesome.otf
	cp $(APISRC)/static/fontawesome-webfont.eot $(APIDST)/fonts/fontawesome-webfont.eot
	cp $(APISRC)/static/fontawesome-webfont.svg $(APIDST)/fonts/fontawesome-webfont.svg
	cp $(APISRC)/static/fontawesome-webfont.ttf $(APIDST)/fonts/fontawesome-webfont.ttf
	cp $(APISRC)/static/fontawesome-webfont.woff $(APIDST)/fonts/fontawesome-webfont.woff
	cp $(APISRC)/static/fontawesome-webfont.woff2 $(APIDST)/fonts/fontawesome-webfont.woff2

# Build resource docs
resource: cleanapi
	go run gen-apidocs/main.go --build-operations=false --munge-groups=false --config-dir=gen-apidocs/generators
	docker run -v $(shell pwd)/gen-apidocs/generators/includes:/source -v $(shell pwd)/gen-apidocs/generators/build:/build -v $(shell pwd)/gen-apidocs/generators/:/manifest pwittrock/brodocs

copyresource: resource
	rm -rf gen-apidocs/generators/build/documents/
	rm -rf gen-apidocs/generators/build/runbrodocs.sh
	rm -rf gen-apidocs/generators/build/manifest.json
	rm -rf $(WEBROOT)/docs/resources-reference/v1.$(MINOR_VERSION)/*
	cp -r gen-apidocs/generators/build/* $(WEBROOT)/docs/resources-reference/v1.$(MINOR_VERSION)/
