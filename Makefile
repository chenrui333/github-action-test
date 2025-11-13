.PHONY: fmt lint

# Format all Dockerfiles in the repository
fmt:
	@echo "Formatting Dockerfiles..."
	@dockerfmt -w $$(find . -type f -name "Dockerfile*" -o -name "*.dockerfile" | grep -v ".git")

# Check if all Dockerfiles are properly formatted
lint:
	@echo "Checking Dockerfile formatting..."
	@dockerfmt --check $$(find . -type f -name "Dockerfile*" -o -name "*.dockerfile" | grep -v ".git")
