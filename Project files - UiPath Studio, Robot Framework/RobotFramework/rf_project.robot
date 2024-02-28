*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    

*** Variables ***
${PATH}    C:/Users/royha/OneDrive - Hämeen ammattikorkeakoulu/Software Robotics and Automation/Project/RobotFramework/
@{ListToDB}
${InvoiceNumber}    empty

# Database related auxiliary variables

${dbname}    rpa
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    dbapiModuleName=pymysql    dbName=${dbtoconnect}    dbUsername=${dbuser}    dbPassword=${dbpass}    dbHost=${dbhost}    dbPort=${dbport}

*** Test Cases ***

Read CSV file to list
    Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv

    # Process each line as an individual element

    Log    ${outputHeader}
    Log    ${outputRows}

