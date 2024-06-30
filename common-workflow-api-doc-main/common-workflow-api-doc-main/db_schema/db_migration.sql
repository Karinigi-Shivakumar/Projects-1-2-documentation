CREATE TABLE
	projects_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		project JSONB
	);

CREATE TABLE
	resources_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		resource JSONB
	);

CREATE TABLE
	usecases_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		project_id UUID,
		usecase JSONB
	);

ALTER TABLE usecases_table
ADD CONSTRAINT fk_usecase_project_id FOREIGN KEY (project_id) REFERENCES projects_table (id);

CREATE TABLE
	tasks_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		usecase_id UUID,
		project_id UUID,
		assignee_id UUID,
		stage VARCHAR(20),
		task JSONB
	);

ALTER TABLE tasks_table
ADD CONSTRAINT fk_task_usecase_id FOREIGN KEY (usecase_id) REFERENCES usecases_table (id) ON DELETE CASCADE,
ADD CONSTRAINT fk_task_project_id FOREIGN KEY (project_id) REFERENCES projects_table (id) ON DELETE CASCADE,
ADD CONSTRAINT fk_task_assignee_id FOREIGN KEY (assignee_id) REFERENCES resources_table (id) ON DELETE CASCADE;

CREATE TABLE
	workflows_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		workflow JSONB
	);

ALTER TABLE usecases_table
ADD COLUMN workflow_id UUID;

ALTER TABLE usecases_table
ADD CONSTRAINT fk_usecase_workflow_id FOREIGN KEY (workflow_id) REFERENCES workflows_table (id);

ALTER TABLE workflows_table
ADD COLUMN NAME VARCHAR(255) UNIQUE NOT NULL;

ALTER TABLE tasks_table 
ADD COLUMN arn VARCHAR(255) NOT NULL,
ADD COLUMN token VARCHAR(1000) NOT NULL;

ALTER TABLE workflows_table
ADD COLUMN arn VARCHAR(255) NOT null;

ALTER TABLE workflows_table
RENAME COLUMN workflow TO metadata;

alter table workflows_table 
drop constraint workflows_table_name_key;

alter table workflows_table 
add column project_id UUID not null,
add constraint fk_workflows_project
foreign key (project_id)
references projects_table(id);

alter table usecases_table 
add column arn VARCHAR(255) not null;

alter table tasks_table 
drop column stage;

alter table usecases_table 
add column assignee_id UUID,
add constraint fk_task_assignee
foreign key(assignee_id)
references resources_table(id);

alter table tasks_table  
add column comments JSONB;

CREATE TABLE
	metadocs_table (
		id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
		tasks_id UUID,
		created_by UUID,
		created_time date,
		doc_url VARCHAR(20)
	);

ALTER TABLE metadocs_table
ADD CONSTRAINT fk_metadocs_tasks_id FOREIGN KEY (tasks_id) REFERENCES tasks_table (id),
ADD CONSTRAINT fk_metadocs_created_by FOREIGN KEY (created_by) REFERENCES resources_table (id) ON DELETE CASCADE;

ALTER TABLE metadocs_table
ADD COLUMN doc_name VARCHAR(20);

ALTER TABLE metadocs_table
ALTER COLUMN created_time TYPE timestamp;


CREATE TYPE invitation_status_enum AS ENUM ('SENT', 'DRAFT', 'SCHEDULED');

ALTER TABLE resources_table
ADD COLUMN email VARCHAR(255) not null unique,
ADD COLUMN password VARCHAR(255),
ADD COLUMN work_email VARCHAR(255) unique ,
ADD COLUMN first_name VARCHAR(100),
ADD COLUMN last_name VARCHAR(100),
ADD COLUMN gender VARCHAR(10),
ADD COLUMN dob DATE,
ADD COLUMN number VARCHAR(20),
ADD COLUMN emergency_number VARCHAR(20),
ADD COLUMN highest_qualification VARCHAR(255),
ADD COLUMN address_id INT ,  
ADD COLUMN emp_detail_id UUID ,
ADD COLUMN description TEXT,
ADD COLUMN current_task_id UUID ,
ADD COLUMN access_token VARCHAR(255),
ADD COLUMN refresh_token VARCHAR(255),
ADD COLUMN role_id INT ,
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN created_by UUID ,
ADD COLUMN updated_by UUID ,
ADD COLUMN invitation_status invitation_status_enum not null,
ADD COLUMN org_id UUID ,
ADD CONSTRAINT unique_values CHECK (
    email != work_email AND
    number != emergency_number
);

CREATE TABLE organisation(
	id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
	name VARCHAR(100) not null ,
	email VARCHAR(255) not null unique ,
	number VARCHAR(20) not null ,
	logo VARCHAR(255) not null,
	address_id INT null
);


CREATE TABLE address(
	id SERIAL PRIMARY KEY,
	address_line_1 TEXT not null, 
	address_line_2 TEXT ,
	landmark TEXT not null, 
	country VARCHAR(100) not null,
	state VARCHAR(100) not null,
	city VARCHAR(100) not null, 
	zipcode VARCHAR(10) not null
);

CREATE TABLE role(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) not null,
	org_id UUID not null ,
	UNIQUE (name, org_id)
);

CREATE TABLE department(
	id SERIAL PRIMARY KEY, 
	name VARCHAR(100) not null,
	org_id UUID not null,
	UNIQUE (name, org_id)
);

CREATE TABLE emp_type (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) not null ,
	org_id UUID not null ,
	UNIQUE (type, org_id)
);

CREATE TABLE emp_designation (
    id SERIAL PRIMARY KEY,
    designation VARCHAR(50) not null ,
	org_id UUID not null ,
	UNIQUE (designation, org_id)
);

CREATE TABLE emp_detail (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    emp_id UUID NOT null unique,
    designation_id INT ,
    pf VARCHAR(100) unique,
    uan VARCHAR(100) unique,
    department_id INT ,
    reporting_manager_id UUID ,
    emp_type_id INT ,
    work_location VARCHAR(100),
    start_date DATE
);

CREATE TABLE device_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) ,
	org_id UUID ,
	UNIQUE (name, org_id)
);

CREATE TABLE equipment (
    id SERIAL PRIMARY KEY,
    owner BOOLEAN NOT null , --true if company owns it and false if employee owns it.
    device_type_id INT ,
    manufacturer VARCHAR(100),
    serial_number VARCHAR(100) unique,
    note TEXT,
    supply_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID ,
    updated_by UUID ,
    emp_id UUID
);

CREATE TABLE document(
    id SERIAL PRIMARY KEY,
	name VARCHAR(100) not null,
	url VARCHAR(255) not null,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	emp_id UUID
);

ALTER TABLE resources_table
RENAME TO employee;

ALTER TABLE employee
ADD CONSTRAINT fk_employee_addredd_id FOREIGN KEY (address_id) REFERENCES address(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_employee_detail_id FOREIGN KEY (emp_detail_id) REFERENCES emp_detail(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_current_task_id FOREIGN KEY (current_task_id) REFERENCES tasks_table(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_role_id FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_created_by_id FOREIGN KEY (created_by) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_updated_by_id FOREIGN KEY (updated_by) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_employee_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE organisation
ADD CONSTRAINT fk_org_address_id FOREIGN KEY (address_id) REFERENCES address(id);

ALTER TABLE role
ADD CONSTRAINT fk_role_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE department
ADD CONSTRAINT fk_department_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE emp_type
ADD CONSTRAINT fk_emp_type_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE emp_designation
ADD CONSTRAINT fk_emp_designation_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE emp_detail
ADD CONSTRAINT fk_emp_detail_emp_detail FOREIGN KEY (emp_id) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_emp_detail_designation_id FOREIGN KEY (designation_id) REFERENCES emp_designation(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_emp_detail_department_id FOREIGN KEY (department_id) REFERENCES department(id),
ADD CONSTRAINT fk_emp_detail_reporting_manager_id FOREIGN KEY (reporting_manager_id) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_emp_detail_emp_type_id FOREIGN KEY (emp_type_id) REFERENCES emp_type(id) ON DELETE CASCADE;

ALTER TABLE device_type
ADD CONSTRAINT fk_device_type_org_id FOREIGN KEY (org_id) REFERENCES organisation(id);

ALTER TABLE equipment
ADD CONSTRAINT fk_equipment_device_type FOREIGN KEY (device_type_id) REFERENCES device_type(id),
ADD CONSTRAINT fk_equipment_created_by FOREIGN KEY ( created_by) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_equipment_updated_by FOREIGN KEY (updated_by) REFERENCES employee(id) ON DELETE CASCADE,
ADD CONSTRAINT fk_equipment_emp_id FOREIGN KEY (emp_id) REFERENCES employee(id) ON DELETE CASCADE;

ALTER TABLE employee
DROP COLUMN resource;

ALTER TABLE emp_detail
ADD COLUMN employee_id VARCHAR(20) unique;

alter table	organisation 
add column address_line_1 TEXT, 
add column 	address_line_2 TEXT ,
add column 	landmark TEXT, 
add column 	country VARCHAR(100),
add column 	state VARCHAR(100),
add column 	city VARCHAR(100), 
add column 	zipcode VARCHAR(10);

alter table employee 
drop column address_id;

alter table address 
add column emp_id uuid unique;

alter table emp_detail 
drop column employee_id;

alter table employee 
drop column password;

alter table document
add constraint fk_document_emp_id foreign KEY(emp_id) references employee(id) ON DELETE CASCADE;

alter table employee 
add column image VARCHAR(255);

alter table emp_detail 
add column employee_id VARCHAR(20);

alter table organisation 
drop address_id;


ALTER TABLE address
ALTER COLUMN address_line_1 DROP NOT NULL,
ALTER COLUMN landmark DROP NOT NULL,
ALTER COLUMN country DROP NOT NULL,
ALTER COLUMN state DROP NOT NULL,
ALTER COLUMN city DROP NOT NULL,
ALTER COLUMN zipcode DROP NOT NULL;


ALTER TABLE public.workflows_table ADD CONSTRAINT workflows_table_name_unique UNIQUE (name);

ALTER TABLE workflows_table
ADD COLUMN created_by UUID,
ADD CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES employee(id) ON DELETE CASCADE;

ALTER TYPE invitation_status_enum ADD VALUE 'ACTIVE';

CREATE TABLE invite (
    id SERIAL PRIMARY KEY,
    employee_id UUID UNIQUE,
    scheduler UUID,
    scheduled_time VARCHAR(265)
);

ALTER TABLE invite 
ADD CONSTRAINT fk_employee_scheduler_id FOREIGN KEY (employee_id) REFERENCES employee (id);

ALTER TABLE metadocs_table 
ALTER COLUMN doc_url TYPE VARCHAR(255);

ALTER TABLE projects_table
ADD COLUMN org_id uuid,
ADD CONSTRAINT fk_org_id
    FOREIGN KEY (org_id)
    REFERENCES organisation(id);