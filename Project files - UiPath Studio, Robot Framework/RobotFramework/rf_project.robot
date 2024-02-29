*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Library    validation.py

*** Variables ***
${PATH}    C:/Users/royha/OneDrive - Hämeen ammattikorkeakoulu/Software Robotics and Automation/SoftwareRoboticsProject/Project files - UiPath Studio, Robot Framework/RobotFramework/
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


*** Keywords ***
Add Row Data to list
    [Arguments]    ${items}
    
    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}



*** Test Cases ***
Read CSV file to list
    #Make Connection    ${dbname}
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

    
    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

*** Keywords ***
Add Invoice Header to DB 
    [Arguments]    ${items}    ${rows}
    Make Connection    ${dbname}

    # Set dateformat
    ${invoiceDate}=    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

    # Invoice status variable
    ${InvoiceStatus}=    Set Variable    0
    ${InvoiceComment}=    Set Variable    All OK 

    # Reference number validation
    ${refStatus}=    Is Reference Correct    ${items}[2]
    IF    not ${refStatus}
        ${InvoiceStatus}=    Set Variable    1
        ${InvoiceComment}=    Set Variable    Reference number error 
    END
    
    # IBAN number validation
    ${ibanStatus}=    Check IBAN    ${items}[6]
    IF    not ${ibanStatus}
        ${InvoiceStatus}=    Set Variable    2
        ${InvoiceComment}=    Set Variable    IBAN number error 
    END

    # Amount validation
    ${sumStatus}=    Check Amounts From Invoice    ${items}[9]    ${rows}
    IF    not ${sumStatus}
        ${InvoiceStatus}=    Set Variable    3
        ${InvoiceComment}=    Set Variable    Amount difference 
    END


    ${foreignKeyChecks0}=    Set Variable    SET FOREIGN_KEY_CHECKS=0;
    ${insertStmt}=    Set Variable    insert into invoiceheader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments) values ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${invoiceDate}', '${dueDate}', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', '${InvoiceStatus}', '${InvoiceComment}');
   # ${foreignKeyChecks1}=    Set Variable    SET FOREIGN_KEY_CHECKS=1;

    Execute Sql String    ${foreignKeyChecks0}
    Execute Sql String    ${insertStmt}
   # Execute Sql String    ${foreignKeyChecks1}

*** Keywords ***
Check Amounts From Invoice
    [Arguments]    ${totalSumFromHeader}    ${invoiceRows}
    ${status}=    Set Variable    ${False}
    
    ${totalAmountFromRows}=    Evaluate    0

    FOR    ${element}    IN    @{invoiceRows}
        #Log    ${element}[8]
        ${totalAmountFromRows}=    Evaluate    ${totalAmountFromRows}+${element}[8]
    END


    ${diff}=    Convert To Number    0.01
    ${totalSumFromHeader}=    Convert To Number    ${totalSumFromHeader} 
    ${totalAmountFromRows}=    Convert To Number    ${totalAmountFromRows}

    ${status}=    Is Equal    ${totalSumFromHeader}    ${totalAmountFromRows}    ${diff}

    [Return]    ${status}

*** Keywords ***
Check IBAN 
    [Arguments]    ${iban}
    ${iban}=    Remove String    ${iban}    ${SPACE}
    ${status}=    Set Variable    ${False}
    #Log To Console   ${iban}

    ${length}=    Get Length    ${iban}

    #Log To Console    ${length}

    IF    ${length} == 18
        ${status}=    Set Variable    ${True}
    END
    [Return]    ${status}


*** Keywords ***
Add Invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoicerow (invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, vat, total) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]', '${items}[7]', '${items}[8]');
    Execute Sql String    ${insertStmt}


*** Test Cases ***
Loop all invoicerows 
    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        # Splitting row's data to their own elements
        @{items}=    Split String    ${element}    ; 

        # The invoice number of the line being processed is retrieved
        ${rowInvoiceNumber}=    Set Variable    ${items}[7]
        
        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}

        # Check if the processing invoice number changes according to the process diagram
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Add rows to the invoice 

            # Add processing invoice data to list
            Add Row Data to List    ${items}        
    

        ELSE
            Log    Need to check if database list already has rows 
            ${length}=    Get Length    ${ListToDB}

            IF    ${length} == ${0}
                Log    First invoice case
                # Update invoice number
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Add processing invoice data to list
                Add Row Data to List    ${items}

            ELSE
                Log    Invoice changes, need to also process header data

                # Search invoice header row 
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}=    Split String    ${headerElement}    ;
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'

                        Log    Invoice found

                        # Validations when adding

                        # Input invoice header row into DB
                        Add Invoice Header to DB    ${headerItems}    ${ListToDB}

                        # Input invoice rows into DB
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add Invoice Row To DB    ${rowElement}
                            
                        END

                    END
                    
                END


                # Prepare process for the next invoice
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Add processing invoice data to list
                Add Row Data to List    ${items}
            END
                
        END

    END

    # Last invoice case 
    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Processing last invoice header 
            # Search invoice header row 
            FOR    ${headerElement}    IN    @{headers}
                ${headerItems}=    Split String    ${headerElement}    ;
                IF    '${headerItems}[0]' == '${InvoiceNumber}'

                    Log    Invoice found
                    
                    # Validations when adding

                    # Input invoice header row into DB
                    Add Invoice Header to DB    ${headerItems}    ${ListToDB}

                    # Input invoice rows into DB
                    FOR    ${rowElement}    IN    @{ListToDB}
                        Add Invoice Row To DB    ${rowElement}
                        
                    END            
                END
                
         END
    END