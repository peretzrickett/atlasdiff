# Company schema for departments, employees, projects, and employee_projects

table "departments" {
  schema = "company"

  column "department_id" {
    type = int
    null = false
  }
  column "name" {
    type = string
    null = false
  }
  column "location" {
    type = string
    null = true
  }
  primary_key {
    columns = ["department_id"]
  }
}

table "employees" {
  schema = "company"

  column "employee_id" {
    type = int
    null = false
  }
  column "first_name" {
    type = string
    null = false
  }
  column "last_name" {
    type = string
    null = false
  }
  column "email" {
    type = string
    null = false
  }
  column "phone_number" {
    type = string
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
    type = string
    null = true
  }
  primary_key {
    columns = ["employee_id"]
  }
  foreign_key "department_id" {
    columns = ["department_id"]
    ref_table = "departments"
    ref_columns = ["department_id"]
    on_delete = "SET NULL"
  }
}

table "projects" {
  schema = "company"

  column "project_id" {
    type = int
    null = false
  }
  column "name" {
    type = string
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
    columns = ["project_id"]
  }
}

table "employee_projects" {
  schema = "company"

  column "employee_id" {
    type = int
    null = false
  }
  column "project_id" {
    type = int
    null = false
  }
  column "role" {
    type = string
    null = true
  }
  primary_key {
    columns = ["employee_id", "project_id"]
  }
  foreign_key "employee_id" {
    columns = ["employee_id"]
    ref_table = "employees"
    ref_columns = ["employee_id"
    on_delete = "CASCADE"
  }
  foreign_key "project_id" {
    columns = ["project_id"]
    ref_table = "projects"
    ref_columns = ["project_id"]
    on_delete = "CASCADE"
  }
}

# Incremental changes introduced in dev: tasks table and employee_project_summary view

table "tasks" {
  schema = "company"

  column "task_id" {
    type = int
    null = false
  }
  column "description" {
    type = string
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
    columns = ["task_id"]
  }
  foreign_key "employee_id" {
    columns = ["employee_id"]
    ref_table = "employees"
    ref_columns = ["employee_id"]
    on_delete = "CASCADE"
  }
  foreign_key "project_id" {
    columns = ["project_id"]
    ref_table = "projects"
    ref_columns = ["project_id"]
    on_delete = "SET NULL"
  }
}

view "employee_project_summary" {
  schema = "company"
  sql = <<-SQL
    SELECT e.employee_id, e.first_name, e.last_name, p.name AS project_name
    FROM company.employees e
    JOIN company.employee_projects ep ON e.employee_id = ep.employee_id
    JOIN company.projects p ON ep.project_id = p.project_id;
  SQL
}

# New changes for the next iteration: clients and audit_logs tables, department_overview view

table "clients" {
  schema = "company"

  column "client_id" {
    type = int
    null = false
  }
  column "name" {
    type = string
    null = false
  }
  column "contact_email" {
    type = string
    null = true
  }
  primary_key {
    columns = ["client_id"]
  }
}

table "audit_logs" {
  schema = "company"

  column "log_id" {
    type = int
    null = false
  }
  column "employee_id" {
    type = int
    null = false
  }
  column "action" {
    type = string
    null = false
  }
  column "timestamp" {
    type = timestamp
    null = false
  }
  primary_key {
    columns = ["log_id"]
  }
  foreign_key "employee_id" {
    columns = ["employee_id"]
    ref_table = "employees"
    ref_columns = ["employee_id"]
    on_delete = "CASCADE"
  }
}

view "department_overview" {
  schema = "company"
  sql = <<-SQL
    SELECT d.department_id, d.name AS department_name, COUNT(p.project_id) AS project_count
    FROM company.departments d
    LEFT JOIN company.projects p ON d.department_id = p.department_id
    GROUP BY d.department_id;
  SQL
}
