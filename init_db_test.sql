CREATE SCHEMA IF NOT EXISTS company;

CREATE TABLE company.departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

CREATE TABLE company.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    hire_date DATE NOT NULL,
    department_id INT REFERENCES company.departments(department_id) ON DELETE SET NULL,
    salary NUMERIC(10, 2),
    job_title VARCHAR(50)
);

CREATE TABLE company.projects (
    project_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12, 2)
);

CREATE TABLE company.employee_projects (
    employee_id INT REFERENCES company.employees(employee_id) ON DELETE CASCADE,
    project_id INT REFERENCES company.projects(project_id) ON DELETE CASCADE,
    role VARCHAR(50),
    PRIMARY KEY (employee_id, project_id)
);
