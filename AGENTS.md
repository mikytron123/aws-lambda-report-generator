# Project Guidelines

## Architecture

- This is a LocalStack-backed AWS analysis pipeline managed by Terraform.
- [main.tf](main.tf) creates the `input`, `output`, and `lambda` S3 buckets, uploads Lambda archives, creates the Lambda functions, and creates the Step Functions state machine.
- [step_definition.json](step_definition.json) runs `corr` and `stat` in parallel, then invokes `report`.
- Each Lambda archive has `handler.py` at its root and uses `handler.lambda_handler`; function-specific dependencies are vendored into `lambda/<name>/pkg`.
- Treat [provider.tf](provider.tf) as LocalStack-only configuration unless the task explicitly adds a real AWS deployment path.

## Build And Validate

- Start LocalStack with `docker compose up -d`, or use the `start`, `ready`, and `stop` recipes in [Makefile](Makefile) when the LocalStack CLI is installed.
- Build deployment archives with `just build-lambdas`. This creates `lambda/corr/pkg.zip`, `lambda/stat/pkg.zip`, and `lambda/report/pkg.zip`.
- Run `terraform fmt -check`, `terraform validate`, and `terraform plan` after Terraform changes. Run `just lint` and `just format` for Python changes when the required tools are installed.
- There is no maintained automated test suite. Validate pipeline changes with a LocalStack smoke test: deploy, start the state machine, and inspect the `output` bucket.
- Build archives before Terraform planning or applying; `main.tf` hashes and uploads those files and Terraform does not create them.

## Conventions

- Keep the Lambda runtime and dependency build target aligned. The current Terraform runtime is Python 3.12 while [justfile](justfile) builds dependency wheels for Python 3.11; resolve that mismatch deliberately when changing either side.
- The report Lambda loads `templates/template.html` at runtime. Ensure the intended template is included in `lambda/report/pkg.zip` and keep the template path consistent with [lambda/report/handler.py](lambda/report/handler.py).
- Preserve the Step Functions event contract: the workflow input contains `bucket` and `key`; `corr` and `stat` return `func`, `bucket`, and `key`, which `report` consumes through each branch payload.
- Keep generated archives and vendored package directories out of source changes unless the task is specifically about packaging; they are ignored by [.gitignore](.gitignore).
- Prefer the current Terraform and `justfile` workflow. The `Makefile` contains an older demo flow with references to missing files such as `step-trust-policy.json` and `lambda_adam.py`.
- Use the existing handler and Terraform resource structure before introducing abstractions. Keep changes scoped to the owning Lambda, packaging recipe, state definition, or Terraform resource.

## Key Files

- [variables.tf](variables.tf): Lambda archive paths, S3 keys, and function names.
- [justfile](justfile): dependency installation and archive construction.
- [compose.yaml](compose.yaml): LocalStack container configuration and persistence.
- [lambda/corr/handler.py](lambda/corr/handler.py), [lambda/stat/handler.py](lambda/stat/handler.py), and [lambda/report/handler.py](lambda/report/handler.py): runtime behavior.