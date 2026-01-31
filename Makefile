# Build resume PDFs for all job types
.PHONY: all General Backend MLE Infra Experiment clean

# Build all folders
all: General Backend MLE Infra Experiment

# Individual folder builds
General:
	./build.sh General

Backend:
	./build.sh Backend

MLE:
	./build.sh MLE

Infra:
	./build.sh Infra

Experiment:
	./build.sh Experiment

# Clean build artifacts
clean:
	rm -rf General/.tmp Backend/.tmp MLE/.tmp Infra/.tmp Experiment/.tmp
