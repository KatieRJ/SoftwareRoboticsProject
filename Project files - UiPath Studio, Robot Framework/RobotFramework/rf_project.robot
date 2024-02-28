*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary

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
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}

*** Test Cases ***

Read CSV file to list
    Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}

    # Process each line as an individual element

    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n

    # Remove the first (title) line and the last (empty) line

    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}


    FOR    ${element}    IN    @{headers}
        Log    ${element}
        
    END

    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
    END
    
    Set Global Variable    ${headers}
    Set Global Variable    ${rows}