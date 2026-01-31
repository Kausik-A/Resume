# Build resume PDFs for all job types
FOLDERS := General Backend MLE Infra Experiment

all: $(FOLDERS)

$(FOLDERS):
	./build.sh $@

clean:
	rm -rf */.tmp

.PHONY: all $(FOLDERS) clean
