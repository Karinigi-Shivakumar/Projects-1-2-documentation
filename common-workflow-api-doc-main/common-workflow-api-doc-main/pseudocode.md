# Workflow Management
Welcome to the documentation for the upcoming APIs that will power our workflow management system. In this document, we'll explore the pseudocode for various APIs.

## Project Overview
This project is designed to facilitate efficient workflow management by organizing components into distinct folders. Each folder represents a key aspect of the system, and APIs are developed using Node.js to handle the functionality within each category.

## Folder Structure
- **1. dashboard:** APIs related to the dashboard functionality.
- **2. projects:** APIs for managing projects.
- **3. workflow:** Handles workflow-related APIs.
- **4. usecase:** Manages use case APIs.
- **5. task:** APIs for task management.
- **6. resource:** Deals with resource-related functionalities.

### Common Logic For For All APIs
  1. Define a Lambda function handler that takes an event as a parameter.
  2. Import the PostgreSQL Client module.
  3. Create a new PostgreSQL Client instance database credentails.
  4. Attempt connection to database. Log success or error for the connection
  5. Parse request body data from the event object ( if there is a request body)
  6. Using the pg client create the SQL query required by the API in a try-catch block.
  7. On successfull query, return the data (if any) with a status code 200 and a success message.
  8. If there's an error during the database query, log the error and return a response with a status code 500 and a JSON body including an error message.

## APIs
Let's dive into the pseudocode for each API within the respective folders:

### 1. Dashboard
**1.getOrgProjectDetails**
**API Description:**
The getOrgProjectDetails API retrieves summary details about projects and tasks within the organization. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /org_projects_overview 

**Response:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error message" }

```SQL
-- Query 1: Total Projects
SELECT COUNT(*) AS total_projects FROM projects_table;

-- Query 2: Total Tasks
SELECT COUNT(DISTINCT id) AS task_count FROM tasks_table;

-- Query 3: Projects by Status
SELECT 
    COUNT(*) AS count,
    (project->>'status') AS status
FROM
    projects_table
GROUP BY
    project->>'status';

```
**2.getProjectsUsecaseOverview**
**API Description:**
The getProjectUsecaseOverview API provides an overview of a specific project's use cases, including completed and incomplete counts.

**Endpoint:**
Method: GET
Endpoint: /projects_usecase_overview

**Response:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error message" }

```SQL
-- Query: Project Usecase Overview
SELECT
    p.id AS project_id,
    (p.project->>'name') AS project_name,
    COUNT(u.id) AS usecase_count,
    COUNT(*) FILTER (WHERE u.usecase->>'status' = 'completed') AS completed_count
FROM
    projects_table AS p
LEFT JOIN
    usecases_table AS u ON p.id = u.project_id
WHERE
    p.id = $1 -- Conditionally filter by project_id
GROUP BY
    p.id;
```
**3.getResourcesTasksStatus**
**API Description:**
The getResourcesTasksStatus API retrieves the status of tasks for a specific resource, including the count of completed, in-progress, and pending tasks. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /resources_tasks_status
Request Parameters:
resource_id (Query Parameter): The ID of the resource for which the task status is requested.

**Response:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error message" }

```SQL
-- Query: Resource Tasks Status
SELECT
    r.id AS resource_id,
    (r.resource->>'name') AS resource_name,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'completed') AS completed,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'inprogress') AS inprogress,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'pending') AS pending
FROM
    resources_table AS r
LEFT JOIN
    tasks_table AS t ON r.id = t.assignee_id
WHERE
    r.id = $1::uuid -- Conditionally filter by resource_id
GROUP BY
    r.id;

```
**4.getProjectsOverview**
**API Description:**
The getProjectsOverview API retrieves an overview of projects, including details such as project name, status, due date, total use cases, total tasks, and the percentage of completed tasks. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /projects_overview
Request Parameters:
status (Query Parameter): Filters projects based on status (optional). Valid values: "unassigned," "completed," "inprogress."

**Response:**
Success Response (HTTP 200):
Body: { "message": S  uccessful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error message" }

```SQL
-- Query: Projects Overview
SELECT 
    p.id AS project_id,
    (p.project->>'name') AS project_name,
    (p.project->>'status') AS status,
    (p.project->>'end_date') AS due_date,
    COUNT(DISTINCT u.id) AS total_usecases,
    COUNT(t.id) AS total_tasks,
    COUNT(t.id) FILTER (WHERE t.task->>'status' = 'completed') AS tasks_completed
FROM
    projects_table AS p 
LEFT JOIN
    usecases_table AS u ON p.id = u.project_id 
LEFT JOIN
    tasks_table AS t ON u.id = t.usecase_id AND p.id = t.project_id
WHERE
    (p.project->>'status' = $1) -- Conditionally filter by status
GROUP BY 
    p.id;
```
**5.getProjectResourceOverview**
**API Description:**
The getProjectResourceOverview API retrieves an overview of a project, including details such as project name, manager information, current tasks, and a list of project resources. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /projects_resource_overview
Request Parameters:
status (Query Parameter): Filters projects based on status (optional). Valid values: "unassigned," "completed," "inprogress."
**Response:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error messag  e" }

```SQL
-- Query: Project Resource Overview
SELECT 
    p.id AS project_id,
    (p.project->>'name') AS project_name,
    (p.project->'project_manager') AS project_manager,
    (
        SELECT 
            r.resource->>'current_task' AS task_name,
            r.resource->>'created_date' AS created_date,
            r.resource->>'due_date' AS due_date
        FROM 
            resources_table AS r 
        WHERE 
            r.id = (p.project->'project_manager'->>'id')::uuid
    ) AS manager_current_task,
    (
        SELECT 
            count(t.id) AS total_tasks
        FROM 
            tasks_table AS t
        WHERE 
            t.assignee_id = (p.project->'project_manager'->>'id')::uuid
    ) AS total_tasks
FROM projects_table AS p
WHERE
    (p.project->>'status' = $1) -- Conditionally filter by status
GROUP BY 
    p.id;

```
### 2. Projects
**1.addProject**
**API Description:**
The addProject API adds a new project to the system. It expects a JSON payload containing project details such as name, description, department, start date, end date, and image URL. The API performs validation using Zod schema and interacts with a PostgreSQL database to insert the project.

**Endpoint:**
Method: POST
Endpoint: /project

**Request Body:**
JSON payload with the following attributes:
name (string): Project name (minimum 3 characters).
description (string): Project description.
department (string): Project department.
start_date (string): Start date of the project in datetime format.
end_date (string): End date of the project in datetime format.
image_url (string): URL of the project icon.

**Responce:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error", "error": "error message" }

```SQL
-- Query: Add Project
INSERT INTO projects_table (project) VALUES ($1::jsonb) RETURNING *;

```
**2.addTeamToProject**
**API Description:**
The addTeamToProject API adds a team to a specific project. It expects a project ID in the path parameters and a JSON payload containing team details such as team name, creator ID, creation time, and roles. The API performs validation using Zod schema and updates the project's team information in the PostgreSQL database.

**Endpoint:**
 Method: PUT
 Endpoint: /project/{id}/team

 **Request Body:**
JSON payload with the following attributes:
team_name (string): Team name (minimum 3 characters).
created_by_id (string): ID of the team creator (UUID format).
created_time (string): Creation time of the team in datetime format.
roles (array): Array of roles, each containing a role name and an array of user IDs assigned to that role.

**Responce:**
Success Response (HTTP 200):
Body: { "message": Team added to the project}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query: Add Team to Project
UPDATE projects_table
SET project = jsonb_set(
    project,
    '{team}',
    coalesce(project->'team', '{}'::jsonb) || $1::jsonb,
    true
)
WHERE 
    id = $2;
```
**3.getProject**
**API Description:**

**Endpoint:**
Method: GET
Endpoint: /project/{id}

**Responce:**
Success Response (HTTP 200):
Body: { "message": Team added to the project}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query 1: Get Project Details
SELECT
    p.id AS project_id,
    p.project->>'name' AS project_name,
    p.project->'last_updated' AS last_updated,
    p.project->>'project_description' AS project_description
FROM projects_table p
WHERE p.id = $1;

-- Query 2: Get Workflows and Usecases
SELECT
    u.workflow_id,
    w.name AS workflow_name,
    COUNT(DISTINCT u.id) AS total_usecases,
    COUNT(t.id) AS total_tasks,
    COUNT(t.id) FILTER (WHERE (t.task ->> 'status') = 'completed') AS task_completed
FROM usecases_table u
LEFT JOIN tasks_table t ON u.id = t.usecase_id
LEFT JOIN workflows_table w ON u.workflow_id = w.id
WHERE u.project_id = $1
GROUP BY u.workflow_id, w.name;

```
**4.getProjectTeam**
**API Description:**
The getProjectTeam API retrieves information about the team associated with a specific project, including roles and the resources assigned to those roles. It interacts with a PostgreSQL database to gather relevant data.
**Endpoint:**
Method: GET
Endpoint: /project/{id}/team
Path Parameters:
id (string): Project ID

**Responce:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query: Get Project Team
SELECT 
    p.project->'team'->'roles' as roles 
FROM  
    project s_table as p
WHERE p.id = $1::uuid;

```
**5.getProjectWorkflows**
**API Description:**
The getProjectWorkflows API retrieves information about workflows associated with a specific project, including the total number of usecases for each workflow and the percentage of completed tasks within those usecases. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /project/{id}/workflow
Path Parameters:
id (string): Project ID

**Responce:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query: Get Project Workflows
SELECT
    u.workflow_id,
    w.name AS workflow_name,
    COUNT(DISTINCT u.id) AS total_usecases,
    COUNT(t.id) AS total_tasks,
    COUNT(t.id) FILTER (WHERE (t.task ->> 'status') = 'completed') AS task_completed
FROM usecases_table u
LEFT JOIN tasks_table t ON u.id = t.usecase_id
LEFT JOIN workflows_table w ON u.workflow_id = w.id
WHERE u.project_id = $1
GROUP BY u.workflow_id, w.name;
```
**6.getProjects**
**API Description:**
The getProjects API retrieves information about projects, including project ID, name, icon URL, status, roles in the team, and the total number of usecases associated with each project. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /project
Query Parameters:
status (string, optional): Filters projects by status. Valid values: "unassigned", "completed", "inprogress".

**Responce:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query: Get Projects
SELECT
    p.id AS project_id,
    p.project->>'name' AS project_name,
    p.project->>'image_url' AS project_icon_url,
    p.project->>'status' AS status,
    p.project->'team'->'roles' AS roles,
    COUNT(u.id) AS total_usecases
FROM projects_table p
LEFT JOIN usecases_table u ON p.id = u.project_id
WHERE p.project->>'status' = $1
GROUP BY p.id;

```
**7.projectsResourcesTasksStatus**
**API Description:**
The projectsResourcesTasksStatus API retrieves the task status summary for resources associated with a specific project. It first validates the provided project ID and then fetches the roles associated with the project's team. Using the resource IDs from these roles, it counts the completed, in-progress, and pending tasks for each resource. The API returns a summary of task status for each resource in the project.

**Endpoint:**
Method: GET
Endpoint: /project/{id}/team/status
Path Parameters:
id (string, required): Project ID.

**Responce:**
Success Response (HTTP 200):
Body: { "message": Successful responce}
Error Response (HTTP 500):
Body: { "message": "Internal Server Error"}

```SQL
-- Query: Fetch Task Status Summary
SELECT
    r.id AS resource_id,
    (r.resource->>'name') AS resource_name,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'completed') AS completed,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'inprogress') AS inprogress,
    COUNT(*) FILTER (WHERE t.task->>'status' = 'pending') AS pending
FROM
    resources_table AS r
LEFT JOIN
    tasks_table AS t ON r.id = t.assignee_id
WHERE
    r.id = ANY($1::uuid[])
GROUP BY
    r.id, r.resource->>'name';

```
### 3. Workflow
**1.addWorkflow**
**API Description:**
The addWorkflow API creates a new workflow by generating a state machine using the AWS Step Functions service. It interacts with a PostgreSQL database to store information about the workflow.

**Endpoint:**
Method: POST
Endpoint: /workflow
Request Body:
```json
{
	"name": "ExampleWorkflow",
	"created_by_id": "user123",
	"project_id": "project456",
	"stages": [
		{"Stage1": {"checklist": ["Task1", "Task2"]}},
		{"Stage2": {"checklist": ["Task3", "Task4"]}}
	]
}
```
**Responce:**
Success Response (HTTP 200):
Body: Details of the newly created workflow.
Error Response (HTTP 500):
Body: { "error": "Internal Server Error" } or { "error": "Workflow with same name already exists" } in case of a name conflict.

```SQL
INSERT INTO workflows_table
	(name, arn, metadata, project_id)
VALUES
	($1, $2, $3::jsonb, $4)
RETURNING *;

```
**2.deleteWorkflow**
**API Description:**
The deleteWorkflow API initiates the deletion of a workflow by updating its status to "terminated" and then sending a request to delete the associated state machine using AWS Step Functions. It interacts with a PostgreSQL database to update the workflow status.

**Endpoint:**
Method: DELETE
Endpoint: /workflow/{id}
Path Parameters: {id} - ID of the workflow to be deleted.

**Response:**
Success Response (HTTP 200):
Body: "Workflow sent for deletion and updated workflow status success."
Error Response (HTTP 500):
Body: { "error": "Internal Server Error" }

```SQL
UPDATE workflows_table
SET metadata = jsonb_set(
    metadata,
    '{status}',
    '"terminated"',
    true
)
WHERE id = $1;
```
**3.generateStateMachine**
**API Description:**
The generateStateMachine2 function generates an AWS Step Functions state machine based on the provided stages. It creates a parallel state machine where each stage runs in parallel, and each stage can have multiple tasks running concurrently.

**Parameters:**
stages (array, required): An array of stages, where each stage is an object with the stage name and tasks.

**Return:**
An object representing the generated AWS Step Functions state machine.

**4.getAllWorkflows**
**API Description:**
The getAllWorkflows API retrieves information about workflows within the specified project. It interacts with a PostgreSQL database to gather relevant data, such as the total number of use cases, total tasks, and the percentage of completed tasks for each workflow.

**Endpoint:**
Method: GET
Endpoint: /workflows
Query Parameters:
project_id: ID of the project for which workflows are retrieved.

**Response:**
Success Response (HTTP 200):
Body: A list of workflows with details.
Error Response (HTTP 400):
Body: { "error": "Missing project_id parameter" }
Error Response (HTTP 500):
Body: { "error": "Internal Server Error" }


```SQL
SELECT
    u.workflow_id,
    w.name AS workflow_name,
    COUNT(DISTINCT u.id) AS total_usecases,
    COUNT(t.id) AS total_tasks,
    COUNT(t.id) FILTER (WHERE (t.task ->> 'status') = 'completed') AS task_completed
FROM usecases_table u
LEFT JOIN tasks_table t ON u.id = t.usecase_id
LEFT JOIN workflows_table w ON u.workflow_id = w.id
WHERE u.project_id = $1
GROUP BY u.workflow_id, w.name
```

**5.updateWorkflow**

**API Description:**
The updateWorkflow API modifies an existing workflow within the workflow management system. It interacts with a PostgreSQL database to update workflow details and updates the AWS Step Functions execution based on the changes.

**Endpoint:**
Method: PUT
Endpoint: /workflow/{id}
Path Parameters:
{id}: ID of the workflow to update.

**Response:**
Success Response (HTTP 200):
Body: Updated workflow details.
Error Response (HTTP 400):
Body: { "error": "Missing workflow id path parameter" }
Error Response (HTTP 500):
Body: { "error": "Workflow with same name already exists" } (if applicable)
Body: { "message": "Internal Server Error", "error": "error message" }


```SQL
SELECT arn, metadata FROM workflows_table WHERE id = $1;

SELECT (r.resource -> 'name') AS name,
        (r.resource -> 'image') AS image_url
FROM resources_table AS r
WHERE id = $2;

UPDATE workflows_table
SET metadata = $1
WHERE id = $2
RETURNING metadata->'stages' AS stages;
```
### 4. Usecase
**1.addUsecase**
**API Description:**
The addUsecase API creates a new use case within the workflow management system. It interacts with a PostgreSQL database to store use case details and initiates an AWS Step Functions execution for the use case.

**Endpoint:**
Method: POST
Endpoint: /usecase

**Request Body:**
```json
{
    "project_id": "0d64717c-0064-4d95-98ca-35c026aeed3c",
    "created_by_id": "94952764-e1b1-4e4d-b41a-679548015942",
    "usecase_name": "usecase-1",
    "assigned_to_id": "94952764-e1b1-4e4d-b41a-679548015942",
    "description": "usecase one for project",
    "workflow_id": "7b555243-de1c-49cd-b288-64506a63ed3e",
    "start_date": "2024-02-01T04:30:54.032Z",
    "end_date": "2024-03-01T04:30:54.032Z"
}
```
**Response:**
Success Response (HTTP 200):
Body: The newly created use case details.
Error Response (HTTP 500):
Body: { "message": "internal server error" }

```SQL
SELECT arn, metadata->'stages' as stages
FROM workflows_table
WHERE id = $1;

INSERT INTO usecases_table 
    (id, project_id, workflow_id, arn, usecase)
VALUES ($1, $2, $3, $4, $5::jsonb)
RETURNING *;
```
**2.deleteUsecase**
**API Description:**
The deleteUsecase API is responsible for stopping the execution of a use case and updating its status to "Stop" in a PostgreSQL database. It utilizes AWS Step Functions to stop the execution and interacts with the database to update the use case status.

**Endpoint:**
Method: DELETE
Endpoint: usecase/{id}
Path Parameters:
{id}: ID of the use case to be deleted.

**Response:**
Success Response (HTTP 204):
Body: Usecase delete successful .
Error Response (HTTP 500):
Body: { "error": "Internal Server Error" }

```SQL
UPDATE usecases_table
SET usecase = jsonb_set(
    usecase,
    '{status}',
    '"Stop"',
    true
) || jsonb_set(
    usecase,
    '{stop_date}',
    $2::jsonb,
    true
)
WHERE id = $1;

```
**3.getUsecase**
**API Description:**
The getUsecase API retrieves detailed information about a specific use case, including assigned tasks and associated resources. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /usecase/{id}
Path Parameters:
{id}: ID of the use case to retrieve details for.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 500):
Body: { "error": "Internal Server Error" }

```SQL
SELECT
    u.*,
    u.assignee_id AS assignee_id,
    u.workflow_id AS workflow_id,
    r.*,
    w.*,
    t.*
FROM
    usecases_table AS u
LEFT JOIN
    resources_table AS r ON u.assignee_id = r.id
LEFT JOIN
    tasks_table AS t ON u.id = t.usecase_id
LEFT JOIN 
    workflows_table AS w ON u.workflow_id = w.id
WHERE u.id =$1;
```

**4.getUsecases**
**API Description:**
The getUsecases API retrieves a list of use cases for a specific project and workflow. It interacts with a PostgreSQL database to gather relevant data.

**Endpoint:**
Method: GET
Endpoint: /usecases
Query Parameters:
project_id: ID of the project for which use cases are requested.
workflow_id: ID of the workflow for which use cases are requested.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 400):
Body: { "error": "Missing project_id parameter" } or { "error": "Missing workflow_id parameter" }

```SQL
SELECT
    usecases_table.id AS usecase_id,
    usecases_table.usecase->>'name' AS usecase_name,
    usecases_table.usecase->>'current_stage' AS current_stage,
    usecases_table.assignee_id AS usecase_assigned_id,
    resources_table.resource->>'name' AS assignee_name,
    COUNT(DISTINCT tasks_table.assignee_id) AS total_resources,
    usecases_table.usecase->>'start_date' AS start_date,
    usecases_table.usecase->>'end_date' AS end_date
FROM
    usecases_table
LEFT JOIN
    tasks_table ON usecases_table.id = tasks_table.usecase_id
LEFT JOIN
    resources_table ON usecases_table.assignee_id = resources_table.id
WHERE
    usecases_table.project_id = $1
    AND usecases_table.workflow_id = $2
GROUP BY 
    usecases_table.id, usecases_table.usecase, resources_table.resource;
```
**5.updateUsecase**
**API Description:**
The updateUsecase API updates an existing use case by modifying its name, stages, and associated tasks. It interacts with a PostgreSQL database and AWS Step Functions.

**Endpoint:**
Method: PUT
Endpoint: /usecases/{id}
Path Parameters:
id: ID of the use case to be updated.

**Request Body:**
JSON object containing:
name: New name for the use case.
updated_by_id: ID of the resource updating the use case.
stages: An array representing the updated stages for the use case.

**Response:**
Success Response (HTTP 200):
Body: JSON object containing the updated stages.
Error Response (HTTP 400):
Body: { "error": "Missing useCaseId parameter" } or error details.

```SQL 
UPDATE usecases_table
SET 
    usecase = jsonb_set(
        usecase, 
        '{name}', 
        '"Updated Usecase"'
    ),
    usecase = jsonb_set(
        usecase, 
        '{updated_by}', 
        '{"id": "resource123", "name": "Resource Name", "image_url": "Resource Image URL"}'
    ),
    usecase = jsonb_set(
        usecase, 
        '{stages}', 
        '[{"StageName1": {"checklist": ["Task 1", "Task 2"], "assignee_id": ""}}, {"StageName2": {"checklist": ["Task 3", "Task 4"], "assignee_id": ""}}]'
    )
WHERE id = 'usecase123';
```

### 5. Task
**1.addComment**
**API Description:**
The addComment API adds a comment to a specific task in the workflow management system. It interacts with a PostgreSQL database to update the task with the new comment.

**Endpoint:**
Method: PUT
Endpoint: /task/{id}/comment
Path Parameters:
id (required): The task ID to which the comment will be added.

**Request Body:**
```json
{
  "id": "resource_id", 
  "comment": "This is a new comment."
}
```
**Response:**
Success Response (HTTP 200):
Body: "Comment added"
Error Response (HTTP 400/500):
Body: { "error": "Missing task_id parameter" } (HTTP 400) or { "error": "Internal Server Error" } (HTTP 500)

```SQL
SELECT 
    id,
    (r.resource -> 'name') as name,
    r.resource -> 'image' as image_url
FROM 
    resources_table as r
WHERE 
    id = $1;

```

**2.completeTask**
**API Description:**
The completeTask API marks a specific task as completed in the workflow management system. It interacts with a PostgreSQL database to update the task status and utilizes AWS Step Functions to signal task completion.

**Endpoint:**
Method: PUT
Endpoint: /task/complete
Query Parameters:
task_id (required): The ID of the task to be marked as completed.

**Response:**
Success Response (HTTP 200):
Body: { "message": "Task completed" }
Error Responses (HTTP 400/404/500):
Body: { "message": "task id is required" } (HTTP 400)
Body: { "message": "Task not found" } (HTTP 404)
Body: { "error": "Internal Server Error", "message": "..." } (HTTP 500)

```SQL
SELECT token
FROM tasks_table 
WHERE id = $1::uuid;

UPDATE tasks_table 
SET task = jsonb_set(
    task,
    '{status}',
    '"completed"')
WHERE id = $1;

```
### 6. Resource

#### 1. addResource
**API Description:**
The addResource API is designed to add a new resource to the workflow management system. It interacts with a PostgreSQL database to store resource details. 
**Endpoint-**
Method: POST
Endpoint:/resource
Request Body:
```json
{
  "resource_name": "John Doe",
  "email": "john.doe@example.com",
  "role": "Developer",
  "project": "Project X",
  "description": "Senior developer responsible for frontend development."
}
```
**Response:**
Success Response (HTTP 200):
Body: { "message": "Successfully resource details inserted" }
Error Response (HTTP 500):
Body: { "message": "Internal server error" }

``` SQL
INSERT INTO resources_table (resource)
VALUES ($1);
```

**2.getResources**
**API Description:**
The getResources API retrieves resource details from the workflow management system. It returns a list of resources with associated projects and additional filtering based on the project ID.

**Endpoint:**
Method: GET
Endpoint: /resource
Query Parameters:
project_id (optional): Filter resources based on a specific project ID.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 500):
Body: { "message": "Internal Server Error" }

```SQL
 SELECT 
    id, 
    resource->>'name' AS name, 
    resource->>'role' AS role, 
    resource->>'image' AS image, 
    resource->>'email' AS email 
FROM 
    resources_table;
 
    SELECT
    id,
    project->>'name' AS name,
    project->>'project_icon_url' AS project_icon_url,
    project->>'team' AS team
FROM
    projects_table;     

```

**3.getResourcesByName**
**API Description:**
The getResourcesByName API retrieves resources based on a partial or full match of their name. It interacts with a PostgreSQL database to fetch resource details.

**Endpoint:**
Method: GET
Endpoint: /get_resource_by_name
Query Parameters:
name (required): Name of the resource or a partial match.
project_id (optional): Filter resources based on a specific project ID.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 500):
Body: { "message": "Internal Server Error" }

```SQL
 SELECT
    r.id as resource_id,
    r.resource->>'name' as resource_name,
    r.resource->>'image' as image_url,
    r.resource->>'email' as email
FROM
    resources_table as r
WHERE
    LOWER(r.resource->>'name') LIKE LOWER('%' || $1 || '%');    

```
**4.getResourcesByRole**
**API Description:**
The getResourcesByRole API retrieves resources based on their role, with an optional filter based on the resource name. It interacts with a PostgreSQL database to fetch resource details.

**Endpoint:**
Method: GET
Endpoint: /get_resource_by_role
Query Parameters:
role (required): Role of the resource.
name (optional): Filter resources by a partial or full match of the resource name.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 400/500):
Body: { "message": "Resource role is missing" } (HTTP 400) or { "message": "Internal Server Error"} (HTTP 500)

```SQL
SELECT
    r.id as resource_id,
    r.resource->>'name' as resource_name,
    r.resource->>'image' as image_url,
    r.resource->>'email' as email
FROM
    resources_table as r
WHERE
    LOWER(r.resource->>'role') = LOWER($1)
    AND ($2 IS NULL OR LOWER(r.resource->>'name') LIKE LOWER('%' || $2 || '%'));

```
**5.getResourcesListView**
**API Description:**
The getResourcesListView API provides a list  view of resources with associated tasks and projects. It retrieves information from the PostgreSQL database, including the total number of tasks assigned to each resource and the projects they are associated with.

**Endpoint:**
Method: GET
Endpoint: /resources/list
Query Parameters:
project_id (optional): Filter resources based on a specific project ID.

**Response:**
Success Response (HTTP 200):
Body: Successful responce.
Error Response (HTTP 500):
Body: { "message": "Internal Server Error" }

```SQL
SELECT
    r.id AS resource_id,
    r.resource->>'name' AS resource_name,
    r.resource->>'role' AS role,
    r.resource->>'image' AS resource_img_url,
    r.resource->>'email' AS resource_email,
    COUNT(t.id) AS total_tasks
FROM
    resources_table r
    LEFT JOIN tasks_table t ON r.id = t.assignee_id
GROUP BY
    r.id;


SELECT DISTINCT
    p.id AS project_id,
    p.project->>'name' AS project_name,
    p.project->>'project_icon_url' AS project_img_url,
    t.assignee_id AS resource_id
FROM
    projects_table p
    JOIN usecases_table u ON p.id = u.project_id
    JOIN tasks_table t ON u.id = t.usecase_id
WHERE
    p.id = $1;

```