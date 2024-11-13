# Atlas Diff & Apply Workflow: Managing Schema Changes Across Environments

This repository demonstrates a developer workflow for managing schema changes across environment such as **development** and **test** using Atlas. The workflow shows how to:
1. Identify schema differences between `dev` and `test`.
2. Apply changes to synchronize `test` with `dev`.
3. Introduce new local changes in `dev` from an HCL file and propagate them to `test`.

## Project Setup

### Prerequisites

1. **Docker**: Ensure Docker is installed and running.
2. **Atlas CLI**: Install from [here](https://atlasgo.io/cli) to use the `atlas schema diff` and `atlas schema apply` commands.

### Clone the Repository

```bash
git clone https://github.com/peretzrickett/atlasdiff.git
cd atlasdiff
```

### Database Setup

This setup involves two PostgreSQL databases running in Docker:
- **Test Database**: Represents a stable environment with the initial base schema with which we started in our previous `atlas schema inspect` module.
- **Dev Database**: Represents a development environment with an incremental schema change.

### Step 1: Start PostgreSQL Containers with Docker

Run the following command to start the `test` and `dev` database containers:

```bash
docker-compose up -d
```

This configuration:
- **Test Database** (`pg_test`, port `5432`): Initializes with the base schema from `init_db_test.sql`.
- **Dev Database** (`pg_dev`, port `5433`): Initializes with `init_db_dev.sql`, which contains an additional incremental schema change.

### Step 2: Verify the Databases

To connect to each environment and verify the initial setup:

- **Test Database**:

  ```bash
  docker exec -it atlasdiff-pg_test-1 psql -U atlasuser -d atlasdb_test
  ```

- **Dev Database**:

  ```bash
  docker exec -it atlasdiff-pg_dev-1 psql -U atlasuser -d atlasdb_dev
  ```

Use `\dt` within each environment to list tables and confirm that `pg_test` contains only the base schema, while `pg_dev` has the base schema plus an additional table (`tasks`) and a view (`employee_project_summary`).

---

## Workflow: Demonstrating Schema Change Management

This workflow demonstrates a sequence of steps that a developer might take to manage and propagate schema changes across multiple environments.

### Step 1: Diff Dev to Test

First, we check for any schema differences between `dev` and `test` to identify changes that have been applied in `dev` but are still missing from `test`.

```bash
atlas schema diff --to "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --from "postgres://atlasuser:atlaspass@localhost:5432/atlasdb_test?sslmode=disable"
```

The output will show differences between `dev` and `test`, such as the presence of the `tasks` table and `employee_project_summary` view in `dev`.

### Step 2: Apply Changes from Dev to Test

After identifying the schema differences, apply the changes from `dev` to `test` to synchronize the environments.

```bash
atlas schema apply --to "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --url "postgres://atlasuser:atlaspass@localhost:5432/atlasdb_test?sslmode=disable"
```

This command updates `test` to match the `dev` schema, applying the additional table and view that were previously only present in `dev`.

---

### Step 3: Diff Local HCL to Dev

Next, we introduce additional schema changes in the local HCL file (`next_version.pg.hcl`). Before applying these changes to `dev`, we check for any differences between the current state of `dev` and the schema defined in `next_version.pg.hcl`.

```bash
atlas schema diff --to "file://./next_version.pg.hcl" --from "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --dev-url "docker://postgres/latest/dev"
```

This diff allows us to confirm that the new tables and views defined in `next_version.pg.hcl` are not yet present in `dev`.

### Step 4: Apply Local HCL Changes to Dev

Apply the schema changes from `next_version.pg.hcl` to `dev` to bring the development environment up to the next planned version.

```bash

```

With this command, the `dev` database now includes the additional tables (`clients`, `audit_logs`) and a view (`department_overview`) defined in `ç`.

---

### Step 5: Diff Dev to Test

Now that `dev` has been updated with the latest schema changes, we compare `dev` to `test` to see which changes are still pending in `test`.

```bash
atlas schema diff --from "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --to "postgres://atlasuser:atlaspass@localhost:5432/atlasdb_test?sslmode=disable"
```

This diff should show the newly added tables and views in `dev` that have not yet been applied to `test`.

### Step 6: Apply Changes from Dev to Test

Finally, after confirming the latest schema differences, we apply the changes from `dev` to `test` to synchronize the environments fully.

```bash
atlas schema apply --from "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --to "postgres://atlasuser:atlaspass@localhost:5432/atlasdb_test?sslmode=disable"
```

With this final step, both `dev` and `test` are now synchronized to reflect the complete schema from `next_version.pg.hcl`.

---

## Summary

This workflow provides a structured approach to managing schema changes across `dev` and `test` environments, demonstrating how to:
1. **Diff Dev to Test**: Identify pending changes in `dev` that need to be applied to `test`.
2. **Apply Changes from Dev to Test**: Synchronize `test` with `dev`.
3. **Diff Local HCL to Dev**: Check for planned changes in `next_version.pg.hcl` not yet in `dev`.
4. **Apply Local HCL to Dev**: Update `dev` with the latest schema version from `next_version.pg.hcl`.
5. **Diff Dev to Test**: Confirm pending changes in `dev` that need to be applied to `test`.
6. **Apply Changes from Dev to Test**: Finalize updates by synchronizing `test` with the latest schema changes in `dev`.
atlas schema apply --url "postgres://atlasuser:atlaspass@localhost:5433/atlasdb_dev?sslmode=disable" --to "file://./next_version.pg.hcl"
This approach ensures consistency across environments, provides a clear view of schema differences, and supports incremental change management in a controlled manner.
