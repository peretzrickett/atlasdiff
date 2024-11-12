# Company schema for departments, employees, projects, and employee_projects
schema "company" {}

table "departments" {
  schema = schema.company

  column "department_id" {
    type = int
    null = false
  }
  column "name" {
    type = text
    null = false
  }
  column "location" {
    type = text
    null = true
  }
  primary_key {
    columns = [column.department_id]
  }
}

table "employees" {
  schema = schema.company

  column "employee_id" {
    type = int
    null = false
  }
  column "first_name" {
    type = text
    null = false
  }
  column "last_name" {
    type = text
    null = false
  }
  column "email" {
    type = text
    null = false
  }
  column "phone_number" {
    type = text
    null = true
  }
  column "hire_date" {
    type = date
    null = false
  }
  column "department_id" {
    type = int
    null = true
  }
  column "salary" {
    type = decimal
    null = true
  }
  column "job_title" {
    type = text
    null = true
  }
  primary_key {
    columns = [column.employee_id]
  }
  foreign_key "department_id" {
    columns = [column.department_id]
    ref_columns = [table.departments.column.department_id]
    on_delete = SET_NULL
  }
}

table "projects" {
  schema = schema.company

  column "project_id" {
    type = int
    null = false
  }
  column "name" {
    type = text
    null = false
  }
  column "start_date" {
    type = date
    null = true
  }
  column "end_date" {
    type = date
    null = true
  }
  column "budget" {
    type = decimal
    null = true
  }
  primary_key {
    columns = [column.project_id]
  }
}

table "employee_projects" {
  schema = schema.company

  column "employee_id" {
    type = int
    null = false
  }
  column "project_id" {
    type = int
    null = false
  }
  column "role" {
    type = text
    null = true
  }
  primary_key {
    columns = [column.employee_id, column.project_id]
  }
  foreign_key "employee_id" {
    columns = [column.employee_id]
    ref_columns = [table.employees.column.employee_id]
    on_delete = CASCADE
  }
  foreign_key "project_id" {
    columns = [column.project_id]
    ref_columns = [table.projects.column.project_id]
    on_delete = CASCADE
  }
}

# Incremental changes introduced in dev: tasks table and employee_project_summary view

table "tasks" {
  schema = schema.company

  column "task_id" {
    type = int
    null = false
  }
  column "description" {
    type = text
    null = false
  }
  column "employee_id" {
    type = int
    null = false
  }
  column "project_id" {
    type = int
    null = true
  }
  primary_key {
    columns = [column.task_id]
  }
  foreign_key "employee_id" {
    columns = [column.employee_id]
    ref_columns = [table.employees.column.employee_id]
    on_delete = "CASCADE"
  }
  foreign_key "project_id" {
    columns = [column.project_id]
    ref_columns = [table.projects.column.project_id]
    on_delete = SET_NULL
  }
}

view "employee_project_summary" {
  schema = schema.company
  as         = <<-SQL
    SELECT e.employee_id, e.first_name, e.last_name, p.name AS project_name
    FROM company.employees e
    JOIN company.employee_projects ep ON e.employee_id = ep.employee_id
    JOIN company.projects p ON ep.project_id = p.project_id;
  SQL
}

# New changes for the next iteration: clients and audit_logs tables, department_overview view

table "clients" {
  schema = schema.company

  column "client_id" {
    type = int
    null = false
  }
  column "name" {
    type = text
    null = false
  }
  column "contact_email" {
    type = text
    null = true
  }
  primary_key {
    columns = [column.client_id]
  }
}

table "audit_logs" {
  schema = schema.company

  column "log_id" {
    type = int
    null = false
  }
  column "employee_id" {
    type = int
    null = false
  }
  column "action" {
    type = text
    null = false
  }
  column "timestamp" {
    type = timestamp
    null = false
  }
  primary_key {
    columns = [column.log_id]
  }
  foreign_key "employee_id" {
    columns = [column.employee_id]
    ref_columns = [table.employees.column.employee_id]
    on_delete = "CASCADE"
  }
}

view "department_overview" {
  schema = schema.company
  as = <<-SQL
    SELECT d.department_id, d.name AS department_name, COUNT(p.project_id) AS project_count
    FROM company.departments d
    LEFT JOIN company.projects p ON d.department_id = p.department_id
    GROUP BY d.department_id;
  SQL
}
