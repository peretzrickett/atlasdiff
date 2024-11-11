# AtlasDiff

This repository provides examples and demonstrations of using the `atlas schema diff` command with PostgreSQL. The goal is to explore various ways to compare database schemas, culminating in a visual diff using the `-w` flag.

## Project Setup

### Prerequisites

1. **Docker**: Ensure Docker is installed and running to host the PostgreSQL database container.
2. **Atlas CLI**: Install the Atlas CLI from [here](https://atlasgo.io/cli).

### Clone the Repository

```bash
git clone https://github.com/peretzrickett/atlasdiff.git
cd atlasdiff
```

## Database Setup

### Start PostgreSQL with Docker

Use Docker Compose to start a PostgreSQL container with an initial schema setup.

```bash
docker-compose up -d
```

This will set up a PostgreSQL container using the `docker-compose.yml` configuration file provided in this repository.

### Verify the Database

To connect to the PostgreSQL container and check the tables:

```bash
docker exec -it atlasdiff-postgres-1 psql -U atlasuser -d atlasdb
```

Use `\dt` to verify the tables and structure in the initial schema.

## Schema Diff Examples

This project includes multiple scenarios to demonstrate `atlas schema diff` with added and modified tables. Each example compares schemas and outputs the differences.

### Commands

- **Basic Diff**: Compare the current schema to a modified schema with additional tables.

  ```bash
  atlas schema diff --from "postgres://atlasuser:atlaspass@localhost:5432/atlasdb?sslmode=disable" --to "file://./new_schema.hcl"
  ```

  This command compares the current database schema with the schema defined in `new_schema.hcl`.

- **Diff with Additional Tables**: Run a diff after adding more tables to the schema to track structural changes.

  ```bash
  atlas schema diff --from "file://./base_schema.hcl" --to "file://./extended_schema.hcl"
  ```

  Here, `base_schema.hcl` and `extended_schema.hcl` represent different states of the schema. The output will show all changes needed to transform the base schema to the extended one.

- **Database-to-File Diff**: Compare a live database schema to a schema definition in HCL.

  ```bash
  atlas schema diff --from "postgres://atlasuser:atlaspass@localhost:5432/atlasdb?sslmode=disable" --to "file://./updated_schema.hcl"
  ```

  This example highlights schema differences between a live PostgreSQL database and a file-based schema.

- **Interactive Diff with Browser View**:

  Use the `-w` flag to open an interactive diff view in your web browser:

  ```bash
  atlas schema diff --from "postgres://atlasuser:atlaspass@localhost:5432/atlasdb?sslmode=disable" --to "file://./final_schema.hcl" -w
  ```

  This command opens a visual representation in your browser, allowing you to interactively explore schema differences.

## Scripts

### `setup_schemas.sh`

This script initializes the database with a series of schemas to enable various diff scenarios. It sets up the initial schema, then creates additional tables and columns to demonstrate changes in each example.

To run the script:

```bash
./setup_schemas.sh
```
