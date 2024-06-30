# HRMS Project Overview

Welcome to the documentation for the Human Resource Management System (HRMS) project. In this document, we'll provide an overview of the project's goals, functionalities, and architectural design.

## Project Goals:

 The HRMS project aims to streamline and automate various human resource management processes within an organization. Its primary objectives include:
- Efficient management of employee data.
- Automation of leave management processes.
- Facilitation of payroll processing.
- Centralization of employee onboarding and offboarding procedures.
- Generation of comprehensive reports for management insights.

## Folder Structure:

The project is structured into multiple folders, each representing a distinct aspect of the HRMS functionalities:

 **1. Auth :** Contains APIs related to user authentication and authorization.

 **2. Dashboard:** Manages APIs for providing insights and statistics through dashboards.

 **3. Department:** Handles APIs related to department management.

 **4. Designation:** Manages APIs related to designation or job roles within the organization. 

 **5. Employee:** Handles APIs related to employee management, such as profiles, roles, and permissions.

 **6. EmpType:** Manages APIs related to employment types or categories. 

 **7. Organization:** Handles APIs related to organizational management. 

 **8. upload:** Handles APIs related to employee data upload.

## Common Logic Across APIs:

- Each API within the project follows a standardized procedure for handling requests and interacting with the database:
- Define a Lambda function handler to process incoming requests.
- Import necessary modules, such as the PostgreSQL client for database operations.
- Establish a connection to the database using appropriate credentials.
- Parse request parameters or body data from the event object.
- Execute SQL queries to perform required operations, wrapped in try-catch blocks for error handling.
- Return appropriate HTTP responses with relevant data or error messages.

## API Documentation:

Detailed documentation for each API, including descriptions, endpoints, request parameters, response formats is provided within their respective folders.

### Auth

#### 1.signin

##### API Description:

##### Endpoint:
- Method: POST
- Endpoint: /signIn
- Request Body:
    - email: string - User's email address.
    - password: string - User's password.
##### Response:
- Success Response (HTTP 200):
  Body: {
  "message": "Successfully Signed-In",
  "result": {
  "id": "user_id",
  "email": "user_email",
  "work_email": "user_work_email",
  "first_name": "user_first_name",
  "last_name": "user_last_name",
  "gender": "user_gender",
  "dob": "user_dob",
  "number": "user_number",
  "emergency_number": "user_emergency_number",
  "highest_qualification": "user_highest_qualification",
  "emp_detail_id": "user_emp_detail_id",
  "description": "user_description",
  "current_task_id": "user_current_task_id",
  "invitation_status": "user_invitation_status",
  "org_id": "user_org_id",
  "image": "user_image",
  "email_verified": "user_email_verified"
  },
  "AccessToken": "access_token",
  "RefreshToken": "refresh_token"
  }
- Error Response (HTTP 500):
  Body: { "message": "error while sign-in" }

##### Pseudocode for signIn API:
1. Parse the request body to extract the user's email and password.
2. Validate the request body fields using Zod.
3. If validation fails:
  -  3.1. Return a 400 Bad Request response with the validation error message.
4. Establish a connection to the database.
5. Initialize a Cognito Identity Provider client.
6. Create an input object with user's email and password for Cognito authentication.
7. Send a request to Cognito to authenticate the user.
8. If authentication is successful:
  -  8.1. Update the user's access and refresh tokens in the database.
  -  8.2. Retrieve the user's details from the database.
  -  8.3. Return a 200 OK response with the user's details, access token, and refresh token.
9. If any error occurs during execution:

    9.1. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details. 

#### 2.signup

##### API Description:
The signUp API allows users to sign up and create an account. Upon successful signup, a verification email is sent to the user's email address.

##### Endpoint:
- Method: POST
- Endpoint: /signUp
- Request Body:
    - email: string - User's email address.
    - password: string - User's password.
    - confirm_password: string - Confirmation of the user's password.

##### Response:
- Success Response (HTTP 200):
  Body: { "Message": "Successfully Signed-up", "AccessToken": "access_token" }
- Error Response (HTTP 500):
  Body: { "message": "error" }

##### Pseudocode for signUp API:
1. Parse the request body to extract the user's email and password.
2. Validate the request body fields using Zod.
3. If validation fails:
  -  3.1. Return a 400 Bad Request response with the validation error message.
4. Establish a connection to the database.
5. Initialize a Cognito Identity Provider client.
6. Generate unique IDs for organization and user.
7. Create a user in Cognito User Pool with the provided email and password.
8. If successful:
  -  8.1. Send a verification email to the user's email address.
  -  8.2. Insert organization and employee records into the database.
  -  8.3. Commit the transaction.
  -  8.4. Return a 200 OK response with the success message and access token.
9. If any error occurs during execution:
  -  9.1. Rollback the transaction.
  -  9.2. Delete the user from Cognito User Pool.
  -  9.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details. 

#### 3.forgotPassword:

##### API Description:
The forgotPassword API allows users to request a password reset by sending a reset code to their email address.

##### Endpoint
- Method: POST
- Endpoint: /forgotPassword
- Request Body:
    - email: string (required) - The email address of the user requesting the password reset.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "Password reset code sent successfully" }
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for forgotPassword API:
1. Parse the request body to extract the user's email.
2. Validate the request body parameters (email).
3. If validation fails:
   - 3.1. Return a 400 Bad Request response with the validation error message.
4. Initialize a Cognito Identity Provider client.
5. Construct input parameters for the forgot password operation with Cognito.
6. Send a request to initiate the forgot password operation.
7. If the operation is successful:
   - 7.1. Return a 200 OK response with the message "Password reset code sent successfully".
8. If any step fails during execution:
   - 8.1. Log the error.
   - 8.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 4.resetPassword:

##### API Description:
The resetPassword API allows users to reset their passwords by confirming a forgot password operation using a confirmation code (OTP).

##### Endpoint
- Method: POST
- Endpoint: /resetPassword
- Body:
  - email: string (required) - The email address of the user requesting the password reset.
  - confirmationCode: string (required) - The confirmation code (OTP) sent to the user's email.
  - newPassword: string (required) - The new password to set for the user's account.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "Password confirmed successfully" }
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for resetPassword API:
1. Parse the request body to extract email, confirmation code (OTP), and new password.
2. Validate the request body parameters (email, confirmation code, and new password).
3. If validation fails:
   - 3.1. Return a 400 Bad Request response with the validation error message.
4. Initialize a Cognito Identity Provider client.
5. Construct input parameters for confirming the forgot password operation with Cognito.
6. Send a request to confirm the forgot password operation and set the new password.
7. If the password confirmation is successful:
   - 7.1. Return a 200 OK response with the message "Password confirmed successfully".
8. If any step fails during execution:
   - 8.1. Log the error.
   - 8.2. Return a 500 Internal Server Error response with the error message.
   
##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 5. newUserPassword

##### API Description:
The newUserPassword API allows users to set a new password upon initial login, typically after the account is created and the user is required to change the password.

##### Endpoint:
- Method: POST
- Endpoint: /newUserPassword
- Body:
  - email: string (required) - The email address of the user.
  - password: string (required) - The temporary password provided to the user.
  - newpassword: string (required) - The new password to be set by the user.

##### Response:
- Success Response (HTTP 301):
  Body: { "message": "Password-Reset Successfully" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
    - "Location": "https://workflow.synectiks.net/" (Redirects user after successful password reset)
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for newUserPassword API:
1. Parse the request body to extract email, temporary password, and new password.
2. Validate the request body parameters (email, temporary password, and new password).
3. If validation fails:
   - 3.1. Return a 400 Bad Request response with the validation error message.
4. Connect to the database.
5. Initialize a Cognito Identity Provider client.
6. Set up authentication parameters for admin-initiated authentication.
7. Send a request to authenticate the user using the temporary password.
8. Construct input parameters to respond to the new password challenge.
9. Send a request to set the new password for the user.
10. Update the invitation status in the database to indicate that the user's account is active.
11. Return a 301 Redirect response to the workflow application upon successful password reset.
12. If any step fails during execution:
    - 12.1. Log the error.
    - 12.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 6. refreshToken

##### API Description:
The refreshToken API allows users to refresh their access token using a refresh token provided by AWS Cognito.

##### Endpoint:
- Method: POST
- Endpoint: /refreshToken
- Body:
  - email: string (required) - The email address of the user.
- Headers:
  - Authorization: Bearer <refresh_token> (Token used for authentication)

##### Response:
- Success Response (HTTP 200):
  Body: { "Access_token": "<new_access_token>" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
- Error Response (HTTP 500):
  Body: { "message": "error_message" }
  Headers:
    - "Access-Control-Allow-Origin": "*"

##### Pseudocode for refreshToken API:
1. Parse the request body to extract the user's email.
2. Extract the refresh token from the Authorization header.
3. Connect to the database.
4. Set up parameters for initiating authentication with AWS Cognito using the refresh token.
5. Send a request to AWS Cognito to initiate authentication with the refresh token.
6. Update the access token in the database with the new token received from Cognito.
7. Return a 200 OK response with the new access token in the body.
8. If any error occurs during the process:
   - 8.1. Catch the error.
   - 8.2. Return a 500 Internal Server Error response with the error message in the body.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

### Dashboard

#### 1.dashboardStats

##### API Description:
The dashboardStats API retrieves summary details about total projects count and total employees count within the organization. It interacts with a PostgreSQL database to gather relevant data.

##### Endpoint:
- Method: GET
- Endpoint: /dashboard/dashboardStats

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "Successful response", "employeeCount": employeeCount, "projectCount": projectCount }
- Error Response (HTTP 500):
  Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for dashboardStats API:
1. Establish a connection to the database.
2. Try to execute the following SQL query to retrieve:
   - Total number of employees.
   - Total number of projects.
3. If successful:
  - 3.1. Extract employeeCount and projectCount from the query results.
  - 3.2. Return a 200 OK response with the following details:
        - Message: "Successful response".
        - Employee count.
        - Project count.
4. If any error occurs during execution:
  - 4.1. Catch the error.
  - 4.2. Log the error.
  - 4.3. Return a 500 Internal Server Error response with error details.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.   

### Department

#### 1.listDepartment

##### API Description:
The listDepartment API retrieves a list of all departments from the database.

##### Endpoint:
- Method: GET
- Endpoint: /department

##### Response:
- Success Response (HTTP 200):
  Body: Array of department objects
- Error Response (HTTP 500):
  Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for listDepartment API:
1. Establish a connection to the database.
2. Try to execute the following SQL query to retrieve all departments:
   - SELECT * FROM department
3. If successful:
  - 3.1. Extract the list of departments from the query result.
  - 3.2. Return a 200 OK response with the list of departments in JSON format.
4. If any error occurs during execution:
  - 4.1. Catch the error.
  - 4.2. Log the error.
  - 4.3. Return a 500 Internal Server Error response with error details.
5. Finally, close the database connection.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.  

### 2.addDepartment

#### API Description:
The addDepartment API adds a new department to the database.
##### Endpoint:
- Method: POST
- Endpoint: /department
- Request Body:
  - name: Department name (string, at least 3 characters long)
  - org_id: Organization ID (string, valid UUID)

##### Response:
- Success Response (HTTP 200):
  Body: Department object
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
    Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for addDepartment API:
1. Parse the request body to extract the department name and organization ID.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Establish a connection to the database.
5. Try to execute an SQL query to insert the department into the database.
6. If successful:
  - 6.1. Extract the inserted department data from the query result.
  - 6.2. Return a 200 OK response with the inserted department data.
7. If any error occurs during execution:
  - 7.1. Catch the error.
  - 7.2. Log the error.
  - 7.3. Return a 500 Internal Server Error response with error details.
8. Finally, close the database connection.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 3.updateDepartment

##### API Description:
The updateDepartment API updates an existing department in the database.

##### Endpoint:
- Method: PUT
- Endpoint: /department
- Request Body:
  - id: Department ID (string, valid    UUID)
  - name: Department name (string, at least 3 characters long)
##### Response:
- Success Response (HTTP 200):
  Body: Department object
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 404):
  Body: { "message": "Department not found" }
- Error Response (HTTP 500):
  Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for updateDepartment API:
1. Parse the request body to extract the department ID and name.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Establish a connection to the database.
5. Try to execute an SQL query to update the department in the database.
6. If successful:
  - 6.1. Check if any rows were affected by the update query.
  - 6.2. If no rows were affected, return a 404 Not Found response indicating that the department was not found.
  - 6.3. If rows were affected, retrieve the updated department data from the database.
  - 6.4. Return a 200 OK response with the updated department data.
7. If any error occurs during execution:
  - 7.1. Catch the error.
  - 7.2. Log the error.
  - 7.3. Return a 500 Internal Server Error response with error details.
8. Finally, close the database connection.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.  

### Designation

#### 1.listDesignation

##### API Description:
The listDesignation API retrieves a list of all employee designations from the database.

##### Endpoint:
- Method: GET
- Endpoint: /designation

##### Response:
- Success Response (HTTP 200):
  Body: Array of designation objects
- Error Response (HTTP 500):
  Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for listDesignation API:
1. Establish a connection to the database.
2. Try to execute an SQL query to retrieve all employee designations.
3. If successful:
   3.1. Extract the list of employee designations from the query result.
   3.2. Return a 200 OK response with the list of employee designations in JSON format.
4. If any error occurs during execution:
   4.1. Catch the error.
   4.2. Log the error.
   4.3. Return a 500 Internal Server Error response with error details.
5. Finally, close the database connection.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.  

#### 2. addDesignation

##### API Description:
The addDesignation API allows adding a new designation to the organization.

##### Endpoint:
- Method: POST
- Endpoint: /designation

##### Request Parameters:
- Body:
  - designation: string (required) - The name of the designation to be added.

##### Response:
- Success Response (HTTP 200):
  Body: JSON representation of the inserted designation.
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for addDesignation API:
1. Parse the request body to extract the designation name.
2. Validate the request body parameters (designation name).
3. If validation fails:
   - 3.1. Return a 400 Bad Request response with the validation error message.
4. Connect to the database.
5. Execute a SQL query to insert the new designation into the database for the organization.
6. Retrieve the inserted designation from the query result.
7. If insertion is successful:
   - 7.1. Return a 200 OK response with the JSON representation of the inserted designation.
8. If any step fails during execution:
   - 8.1. Log the error.
   - 8.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.  

#### 3. updateDesignation

##### API Description:
The updateDesignation API allows updating an existing designation in the organization.

##### Endpoint:
- Method: PUT
- Endpoint: /designation

##### Request Parameters:
- Body:
  - designation: string (required) - The updated name of the designation.
  - id: number (required) - The ID of the designation to be updated.

##### Response:
- Success Response (HTTP 200):
  Body: JSON representation of the updated designation.
- Error Response (HTTP 404):
  Body: { "message": "Designation not found" }
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for updateDesignation API:
1. Parse the request body to extract the updated designation name and the designation ID.
2. Validate the request body parameters (designation name and ID).
3. If validation fails:
   - 3.1. Return a 400 Bad Request response with the validation error message.
4. Connect to the database.
5. Execute a SQL query to update the existing designation in the database for the organization.
6. Check if the update operation affected any rows.
7. If no rows were affected:
   - 7.1. Return a 404 Not Found response with the message "Designation not found".
8. Retrieve the updated designation from the query result.
9. If the update operation is successful:
   - 9.1. Return a 200 OK response with the JSON representation of the updated designation.
10. If any step fails during execution:
   - 10.1. Log the error.
   - 10.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.  

### Employee

#### 1.addDocument

##### API Description:

##### Endpoint:
- Method: PUT
- Endpoint: employee/document
- Request Body:
    - emp_id: Employee ID (string, valid UUID)
    - documents: Array of document objects containing name and URL fields

##### Response:
- Success Response (HTTP 200):
  Body: Array of inserted document objects
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "message": "error_message" }

##### Pseudocode for addDocument API:
1. Parse the request body to extract the employee ID and documents array.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Define the SQL query template to add a document.
5. Establish a connection to the database.
6. Begin a database transaction.
7. Iterate over each document in the documents array:
  - 7.1. Execute the SQL query to add the document to the database.
  - 7.2. Extract the inserted document data excluding the employee ID.
  - 7.3. Append the extracted data to the insertedDocument array.
8. Commit the database transaction.
9. Return a 200 OK response with the array of inserted document objects in JSON format.
10. If any error occurs during execution:
  - 10.1. Rollback the database transaction.
  - 10.2. Catch the error.
  - 10.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Rollback the database transaction.
  - Catch the error.
  - Return a 500 Internal Server Error response with error message.

#### 2.addEquipmentDetailsInfo

##### API Description:
The addEquipmentdetailsInfo API adds equipment details to the database.

##### Endpoint:
- Method: PUT
- Endpoint: employee/equipmentInfo
- Request Body:
    - An array of equipment details objects containing:
        - owner: boolean
        - device_type_id: integer
        - manufacturer: string
        - serial_number: string
        - note: string
        - supply_date: date
        - emp_id: string (valid UUID)
##### Response:
- Success Response (HTTP 200):
  Body: Array of inserted equipment objects
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "message": "error_message" }

##### Pseudocode for addEquipmentdetailsInfo API:
1. Parse the request body to extract the array of equipment details.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Define the SQL query template to add equipment details.
5. Establish a connection to the database.
6. Begin a database transaction.
7. Iterate over each equipment detail in the array:
  - 7.1. Execute the SQL query to add the equipment detail to the database.
  - 7.2. Append the inserted equipment detail to the insertedEquipment array.
8. Commit the database transaction.
9. Return a 200 OK response with the array of inserted equipment objects in JSON format.
10. If any error occurs during execution:
  - 10.1. Rollback the database transaction.
  - 10.2. Catch the error.
  - 10.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Rollback the database transaction.
  - Catch the error.
  - Return a 500 Internal Server Error response with error message.
#### 3.addPersonalInfo

##### API Description:
The addPersonalInfo API adds personal information of an employee to the database.

##### Endpoint:
- Method: POST
- Endpoint:  employee/personalInfo
- Request Body:
    - first_name: string (at least 3 characters)
    - last_name: string (at least 3 characters)
    - email: string (valid email format, optional)
    - work_email: string (valid email format, optional)
    - gender: string (at least 1 character)
    - dob: date
    - number: string
    - emergency_number: string (optional)
    - highest_qualification: string (optional)
    - address_line_1: string (optional)
    - address_line_2: string (optional)
    - landmark: string (optional)
    - country: string (optional)
    - state: string (optional)
    - city: string (optional)
    - zipcode: string (optional)
    - emp_type: integer (optional)
    - image: string (optional)

##### Response:
- Success Response (HTTP 200):
  Body: Inserted personal information along with related address and professional information
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "message": "error_message" }

##### Pseudocode for addPersonalInfo API:
1. Parse the request body to extract the personal information.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Define the SQL queries to insert personal, address, and professional information.
5. Establish a connection to the database.
6. Begin a database transaction.
7. Execute the personal information insertion query.
8. Execute the address information insertion query.
9. Execute the professional information insertion query.
10. Extract necessary data from the query results and format the response.
11. Commit the database transaction.
12. Return a 200 OK response with the inserted personal information, address information, and professional information.
13. If any error occurs during execution:
  - 13.1. Rollback the database transaction.
  - 13.2. Catch the error.
  - 13.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Rollback the database transaction.
  - Catch the error.
  - Return a 500 Internal Server Error response with error message.
#### 4.addProfessionalInfo

##### API Description:
The addProfessionalInfo API updates the professional information of an employee in the database.

##### Endpoint:
- Method: PUT
- Endpoint: employee/professionalInfo
- Request Body:
    - designation_id: integer
    - pf: string
    - uan: string
    - department_id: integer
    - reporting_manager_id: string (UUID)
    - work_location: string
    - start_date: date
    - emp_id: string (UUID)

##### Response:
- Success Response (HTTP 200):
  Body: Updated professional information of the employee
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "message": "error_message" }

##### Pseudocode for addProfessionalInfo API:
1. Parse the request body to extract the professional information.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Define the SQL query to update the professional information.
5. Establish a connection to the database.
6. Begin a database transaction.
7. Execute the professional information update query.
8. Extract necessary data from the query results and format the response.
9. Commit the database transaction.
10. Return a 200 OK response with the updated professional information.
11. If any error occurs during execution:
  - 11.1. Rollback the database transaction.
  - 11.2. Catch the error.
  - 11.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Rollback the database transaction.
  - Catch the error.
  - Return a 500 Internal Server Error response with error message.

#### 5.getEmployee

##### API Description:
The getEmployee API retrieves detailed information about an employee from the database.

##### Endpoint:
- Method: GET
- Endpoint: /employee/{id}
- Request Parameters:
    - id: string (UUID) (Path parameter) - The unique identifier of the employee whose information needs to be retrieved.

##### Response:
- Success Response (HTTP 200):
  Body: Detailed information about the employee
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for getEmployee API:
1. Extract the employee ID from the path parameters.
2. Validate the employee ID to ensure it is a valid UUID.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation error message.
4. Establish a connection to the database.
5. Construct a SQL query to retrieve detailed employee information.
6. Execute the query with the employee ID as a parameter.
7. Format the query result into a structured response.
8. Return a 200 OK response with the formatted employee information.
9. If any error occurs during execution:
  - 9.1. Catch the error.
  - 9.2. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.

#### 6.getEmployees

##### API Description:
The getEmployees API retrieves a list of employees with pagination support from the database.
##### Endpoint:
- Method: GET
- Endpoint: /employee
- Request Parameters:
    - page: integer (Query parameter) - The page number of the result set to retrieve (default: 1).

##### Response:
- Success Response (HTTP 200):
  Body: A paginated list of employees with additional metadata.
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for getEmployees API:
1. Extract the page number from the query parameters. If not provided, default to page 1.
2. Calculate the offset based on the page number and the limit (number of records per page).
3. Establish a connection to the database.
4. Retrieve the total count of records in the employee table.
5. Calculate the total number of pages based on the total count and the limit.
6. Construct a SQL query to retrieve a paginated list of employees.
7. Execute the query with the calculated offset.
8. Format the query result into a structured response with additional metadata.
9. Return a 200 OK response with the paginated list of employees and metadata.
10. If any error occurs during execution:
  - 10.1. Catch the error.
  - 10.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.

#### 7.searchByName

##### API Description:
The searchByName API retrieves a list of employees matching a given name pattern from the database.

##### Endpoint:
- Method: GET
- Endpoint: /searchByName
- Request Parameters:
    - name: string (Query parameter) - The name pattern to search for.

##### Response:
- Success Response (HTTP 200):
  Body: A list of employees matching the name pattern.
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for searchByName API:
1. Extract the name pattern from the query parameters.
2. Validate the name pattern to ensure it is a valid string.
3. If validation fails:
  -  3.1. Return a 400 Bad Request response with the validation error message.
4. Establish a connection to the database.
5. Construct a SQL query to search for employees by name pattern.
6. Execute the query with the name pattern as a parameter.
7. Format the query result into a structured response.
8. Return a 200 OK response with the list of matching employees.
9. If any error occurs during execution:
  -  9.1. Catch the error.
  -  9.2. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.

#### 8.updatePersonalInfo

##### API Description:
The updatePersonalInfo API allows updating personal information of an employee in the database.

##### Endpoint:
- Method: PUT
- Endpoint: /employee/{id}
- Request Body Fields:
    - id: string (UUID) - The unique identifier of the employee.
    - first_name: string - The updated first name of the employee (min 3 characters).
    - last_name: string - The updated last name of the employee (min 3 characters).
    - email: string - The updated email address of the employee (must be a valid email format).
    - work_email: string - The updated work email address of the employee (must be a valid email format).
    - gender: string - The updated gender of the employee (min 1 character).
    - dob: string (datetime) - The updated date of birth of the employee.
    - number: string - The updated phone number of the employee.
    - emergency_number: string - The updated emergency contact number of the employee.
    - highest_qualification: string - The updated highest qualification of the employee.
    - address_line_1: string - The updated address line 1 of the employee.
    - address_line_2: string - The updated address line 2 of the employee.
    - landmark: string - The updated landmark of the employee's address.
    - country: string - The updated country of the employee's address.
    - state: string - The updated state of the employee's address.
    - city: string - The updated city of the employee's address.
    - zipcode: string - The updated zipcode of the employee's address.
    - image: string (URL) - The updated URL of the employee's image.
- Request Headers:
    - Content-Type: application/json

##### Response:
- Success Response (HTTP 200):
  Body: Updated personal information of the employee.
- Error Response (HTTP 400):
  Body: { "error": "error_message" }
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for updatePersonalInfo API:
1. Parse the request body and extract the employee ID from the path parameters.
2. Define the schema for the request body fields using Zod.
3. Validate the request body against the defined schema.
4. If validation fails:
  -  4.1. Return a 400 Bad Request response with the validation error message.
5. Establish a connection to the database.
6. Construct SQL queries to update personal information and address information.
7. Execute the queries with the updated information and employee ID.
8. Commit the transaction if both queries succeed.
9. Construct the response body with the updated information.
10. Return a 200 OK response with the updated personal information.
11. If any error occurs during execution:
  -  11.1. Rollback the transaction.
  -  11.2. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.

#### 9. employeeTracker

##### API Description:
The employeeTracker API fetches employee data with pagination support.

##### Endpoint:
- Method: GET
- Endpoint: /employee/tracker

##### Request Parameters:
- Query Parameters:
  - page: number (optional) - The page number of the employee data to fetch (default is 1).

##### Response:
- Success Response (HTTP 200):
  Body: JSON representation containing pagination metadata and employee data.
- Error Response (HTTP 500):
  Body: { "message": "error_message", "error": "error_details" }

##### Pseudocode for employeeTracker API:
1. Extract the page number from the query parameters.
2. If the page number is not provided, default it to 1.
3. Calculate the limit and offset for pagination.
4. Connect to the database.
5. Execute a query to fetch the total count of employees.
6. Calculate the total pages based on the total count and limit.
7. Execute a query to fetch employee data with pagination.
8. Map the fetched employee data into the desired format.
9. Return a 200 OK response with pagination metadata and the formatted employee data.
10. If any step fails during execution:
    - 10.1. Log the error.
    - 10.2. Return a 500 Internal Server Error response with the error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.

#### 10. deleteInvite

##### API Description:
The deleteInvite API allows authorized users to delete an invitation along with its associated scheduler.

##### Endpoint:
- Method: DELETE
- Endpoint: /deleteinvite
- Query Parameters:
  - id: string (required) - The unique identifier of the employee whose invitation is to be deleted.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "user invite deleted successfully." }
  Headers:
    - "Access-Control-Allow-Origin": "*"
    - "Access-Control-Allow-Credentials": true
- Error Response (HTTP 500):
  Body: { "message": "error_message" }
  Headers:
    - "Access-Control-Allow-Origin": "*"

##### Pseudocode for deleteInvite API:
1. Initialize a SchedulerClient from the AWS SDK for deleting the associated scheduler.
2. Extract the employee id from the query parameters.
3. Connect to the database.
4. Retrieve the scheduler name associated with the employee from the database.
5. Set up input parameters for deleting the scheduler.
6. Send a request to delete the scheduler.
7. If the scheduler deletion is successful:
   - 7.1. Update the invitation status of the employee in the database to "DRAFT".
8. Return a 200 OK response with a success message.
9. If any error occurs during the process:
   - 9.1. Log the error.
   - 9.2. Return a 500 Internal Server Error response with the error message in the body.

##### Authorization:
- Authorize the request using the authorize() middleware to ensure only authenticated users can delete invitations.

##### Query Parameters Validation:
- Validate the id query parameter using the queryParamsValidator middleware with the idSchema.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 11. deleteEmployee

##### API Description:
The deleteEmployee API allows authorized users to delete an employee from the database.

##### Endpoint
- Method: DELETE
- Endpoint: /employee/{id}
- Path Parameters:
  - emp_id: string (required) - The unique identifier of the employee to be deleted.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "resource deleted successfully" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
- No Content Response (HTTP 200):
  Body: { "message": "content not available" }
  Headers:
    - "Access-Control-Allow-Origin": "*"

##### Pseudocode for deleteEmployee API:
1. Extract the employee ID from the path parameters.
2. Connect to the database.
3. Set up a SQL query to delete the employee with the given ID.
4. Execute the delete query.
5. If the query returns no rows deleted:
   - 5.1. Return a 200 OK response with a message indicating that the content is not available.
6. If the deletion is successful:
   - 6.1. Return a 200 OK response with a success message.
7. If any error occurs during the process:
   - 7.1. Log the error.
   - 7.2. Return a 500 Internal Server Error response with error details.

##### Authorization:
- Authorize the request using the authorize() middleware to ensure only authenticated users can delete employees.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 12. inviteUser

##### API Description:
The inviteUser API allows authorized users to invite new users by creating accounts in Cognito and adding them to the appropriate user group.

##### Endpoint
- Method: POST
- Endpoint: /invite/{id}
- Path Parameters:
  - id: string (required) - The unique identifier of the employee to be invited.
- Query Parameters:
  - invitation_status: string (optional) - The status of the invitation (default: "SENT").

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "user invited successfully" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
    - "Access-Control-Allow-Credentials": true

##### Pseudocode for inviteUser API:
1. Extract the employee ID from the path parameters and the invitation status from the query parameters.
2. If the invitation status is not provided or is not "SCHEDULED", set it to "SENT".
3. Connect to the database.
4. Retrieve employee details (work email and organization ID) using the employee ID from the database.
5. Generate a temporary password for the new user.
6. Create input parameters for the AdminCreateUserCommand to create a new user in Cognito with the provided details.
7. Execute the AdminCreateUserCommand to create the user.
8. Add the user to the "User" group in Cognito.
9. Update the invitation status of the employee in the database.
10. Return a 200 OK response with a success message.
11. If the username already exists (UsernameExistsException):
    - 11.1. Delete the user from Cognito using the AdminDeleteUserCommand.
    - 11.2. Log the error and throw it again.

##### Authorization:
- Authorize the request using the authorize() middleware to ensure only authenticated users can invite new users.

##### Path Parameters Validation:
- Validate the id path parameter using the pathParamsValidator middleware with the idSchema.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 13. scheduleInvite

##### API Description:
The scheduleInvite API allows authorized users to schedule an invitation for a specific time.

##### Endpoint
- Method: POST
- Endpoint: /schedule
- Body:
  - timestamp: string (required) - The scheduled time for the invitation (format: "YYYY-MM-DDTHH:mm:ss").
  - id: string (required) - The unique identifier of the employee associated with the invitation.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "user invited scheduled successfully at <timestamp>" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
    - "Access-Control-Allow-Credentials": true

##### Pseudocode for scheduleInvite API:
1. Initialize a SchedulerClient from the AWS SDK.
2. Parse the request body to extract the scheduled time (timestamp) and the employee ID.
3. Generate a unique scheduler name using UUID.
4. Declare a variable to hold the response from the scheduler.
5. Define the insertInviteQuery to insert invitation details into the database.
6. Create input parameters for the scheduled Lambda function.
7. Send a request to create a schedule with the specified timestamp and Lambda function details.
8. If the schedule creation is successful:
   - 8.1. Connect to the database.
   - 8.2. Insert invitation details into the database.
9. Return a 200 OK response with a success message indicating the scheduled time.
10. If any error occurs during the process:
    - 10.1. Log the error.
    - 10.2. If a schedule was created before the error occurred, delete the schedule.
    - 10.3. Throw the error.

##### Authorization:
- Authorize the request using the authorize() middleware to ensure only authenticated users can schedule invitations.

##### Body Parameters Validation:
- Validate the request body parameters using the bodyValidator middleware with the provided schema.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

#### 14. updateInviteSchedule

##### API Description:
The updateInviteSchedule API allows authorized users to update the scheduled time for an invitation.

##### Endpoint
- Method: POST
- Endpoint: /updateschedule
- Body:
  - timestamp: string (required) - The new scheduled time for the invitation (format: "YYYY-MM-DDTHH:mm:ss").
  - id: string (required) - The unique identifier of the employee associated with the invitation.

##### Response:
- Success Response (HTTP 200):
  Body: { "message": "user invite updated to be scheduled at <timestamp>" }
  Headers:
    - "Access-Control-Allow-Origin": "*"
    - "Access-Control-Allow-Credentials": true

##### Pseudocode for updateInviteSchedule API:
1. Initialize a SchedulerClient from the AWS SDK.
2. Parse the request body to extract the new scheduled time (timestamp) and the employee ID.
3. Connect to the database.
4. Retrieve the scheduler name associated with the employee from the database.
5. Set up input parameters for the GetScheduleCommand to get the schedule information.
6. Send a request to get the schedule information.
7. Modify the schedule expression and target input with the new timestamp.
8. Set up input parameters for the UpdateScheduleCommand to update the schedule.
9. Send a request to update the schedule.
10. Update the scheduled time for the invitation in the database.
11. Return a 200 OK response with a success message indicating the updated scheduled time.
12. If any error occurs during the process:
    - Catch the error.
    - Log the error.
    - Return a 500 Internal Server Error response with error details.

##### Authorization:
- Authorize the request using the authorize() middleware to ensure only authenticated users can update invitation schedules.

##### Body Parameters Validation:
- Validate the request body parameters using the bodyValidator middleware with the provided schema.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

### EmpType

#### 1.listEmpType

##### API Description:
The listEmpType API retrieves a list of all employee types from the database.

##### Endpoint:
- Method: GET
- Endpoint: /empType

##### Response:
- Success Response (HTTP 200):
  Body: { "data": [ {empTypeObject1}, {empTypeObject2}, ... ] }
- Error Response (HTTP 500):
  Body: { "error": "Internal Server Error" }

##### Pseudocode for listEmpType API:
1. Establish a connection to the database.
2. Try to execute an SQL query to retrieve all employee types.
3. If successful:
  - 3.1. Extract the list of employee types from the query result.
  - 3.2. Return a 200 OK response with the list of employee types in JSON format.
4. If any error occurs during execution:
  - 4.1. Catch the error.
  - 4.2. Return a 500 Internal Server Error response.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Return a 500 Internal Server Error response with error details.

#### 2.addEmpType

##### API Description:
The addEmpType API adds a new employee type to the database.

##### Endpoint:
- Method: POST
- Endpoint:  /empType
- Request Body:
    - type: Employee type (string, at least 3 characters long)
    - org_id: Organization ID (string, valid UUID)

##### Response:
- Success Response (HTTP 201):
  Body: Newly inserted employee type object
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "error": "Internal Server Error" }

##### Pseudocode for addEmpType API:
1. Parse the request body to extract the employee type and organization ID.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Establish a connection to the database.
5. Try to execute an SQL query to insert the employee type into the database.
6. If successful:
  - 6.1. Extract the newly inserted employee type data from the query result.
  - 6.2. Return a 201 Created response with the inserted employee type data in JSON format.
7. If any error occurs during execution:
  - 7.1. Catch the error.
  - 7.2. Return a 500 Internal Server Error response.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Return a 500 Internal Server Error response with error details.  

#### 3.updateEmpType

##### API Description:
The updateEmpType API updates an existing employee type in the database.

##### Endpoint:
- Method: PUT
- Endpoint:  /empType
- Request Body:
    - type: Updated employee type (string, at least 3 characters long)
    - id: ID of the employee type to update (integer)

##### Response:
- Success Response (HTTP 200):
  Body: Updated employee type object
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 404):
  Body: { "message": "Emp_type not found" }
- Error Response (HTTP 500):
  Body: { "error": "Internal Server Error" }

##### Pseudocode for updateEmpType API:
1. Parse the request body to extract the updated employee type and its ID.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Establish a connection to the database.
5. Try to execute an SQL query to update the employee type in the database.
6. If successful:
  - 6.1. Check if any rows were affected by the update query.
  - 6.2. If no rows were affected, return a 404 Not Found response indicating that the employee type was not found.
  - 6.3. If rows were affected, retrieve the updated employee type data from the database.
  - 6.4. Return a 200 OK response with the updated employee type data in JSON format.
7. If any error occurs during execution:
  - 7.1. Catch the error.
  - 7.2. Return a 500 Internal Server Error response.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Return a 500 Internal Server Error response with error details.

### Organisation

#### 1.updateOrganization

##### API Description:
The updateOrganization API updates an existing organization's details in the database.

##### Endpoint:
- Method: PUT
- Endpoint: /organization
- Request Body:
    - name: Company name (string, at least 3 characters long)
    - email: Company email address (string, valid email format)
    - number: Company phone number (string, valid phone number format)
    - logo: Company logo URL (string, optional, default empty string)
    - address_line_1: Company address line 1 (string)
    - address_line_2: Company address line 2 (string)
    - landmark: Landmark (string, optional)
    - country: Country (string)
    - state: State (string)
    - city: City (string)
    - zipcode: Zip code (string, 6 digits)

##### Response:
- Success Response (HTTP 200):
  Body: Updated organization object
- Error Response (HTTP 400):
  Body: { "error": [ "error message 1", "error message 2", ... ] }
- Error Response (HTTP 500):
  Body: { "message": "Internal Server Error", "error": "error message" }

##### Pseudocode for updateOrganization API:
1. Parse the request body to extract the organization details.
2. Validate the input data using the provided schema.
3. If validation fails:
  - 3.1. Return a 400 Bad Request response with the validation errors.
4. Establish a connection to the database.
5. Try to execute an SQL query to update the organization details in the database.
6. If successful:
  - 6.1. Return a 200 OK response with the updated organization data.
7. If any error occurs during execution:
  - 7.1. Catch the error.
  - 7.2. Log the error.
  - 7.3. Return a 500 Internal Server Error response with error details.
8. Finally, close the database connection.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error details.

### upload

#### 1.docUpload

##### API Description:
The docUpload API uploads a document to an AWS S3 bucket and returns the download link.

##### Endpoint:
- Method: POST
- Endpoint: /docUpload
- Request Body:
    - Content-Type: MIME type of the multipart form data containing the file
    - body: Base64 encoded multipart form data containing the file

##### Response:
- Success Response (HTTP 200):
  Body: { "link": "download_link_to_the_uploaded_file" }
- Error Response (HTTP 500):
  Body: { "message": "error_message" }

##### Pseudocode for docUpload API:
1. Parse the request body to extract the multipart form data.
2. Determine the boundary of the multipart form data.
3. Parse the multipart form data to extract the file part.
4. Extract the file data and file type from the file part.
5. Generate a unique file name for the uploaded file.
6. Decode the Base64 encoded file data.
7. Prepare S3 upload parameters including bucket name, file key, decoded file data, and file content type.
8. Upload the file to the specified S3 bucket.
9. Generate the download link for the uploaded file.
10. Return a 200 OK response with the download link in JSON format.
11. If any error occurs during execution:
  -  11.1. Catch the error.
  -  11.2. Log the error.
  -  11.3. Return a 500 Internal Server Error response with error message.

##### Exception Handling:
- If any step encounters an error:
  - Catch the error.
  - Log the error.
  - Return a 500 Internal Server Error response with error message.
