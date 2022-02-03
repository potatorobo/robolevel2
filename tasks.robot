*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTLM receipt as a PDF file.
...               Embeds the screenshot of the robot to the pdf receipt
...               Creates zip archive of the receipts and the image.
Library           RPA.Browser.Selenium    ##auto_close=${FALSE}
Library           RPA.Desktop.Windows
Library           RPA.HTTP
Library           RPA.Excel.Application
Library           RPA.Tables
Library           RPA.PDF
Library           Collections
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault
##Library         RPA.Excel.Files

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Input from dialog
    Open Webpage
    Fill form from CSV
    Create zip file of results
    ##[Teardown]    Close opened pdfs

Minimal task
    Log    Done.

*** Keywords ***
Open Webpage
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Click out of popup
    Click Button    I guess so...

Fill robot order form
    Click out of popup
    Select From List By Value    css:#head    1
    Select Radio Button    body    2
    Input Text When Element Is Visible    css:input[type=number]    1
    Input Text When Element Is Visible    address    1
    Preview robot
    Retry order 200 times to avoid errors
    ##Start another order

Fill robot order form using csv
    [Arguments]    ${order}
    Click out of popup
    Select From List By Value    css:#head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text When Element Is Visible    css:input[type=number]    ${order}[Legs]
    Input Text When Element Is Visible    address    ${order}[Address]
    Preview robot
    Take a screenshot of robot    ${order}[Order number]
    Retry order 200 times to avoid errors
    Store receipt pdf    ${order}[Order number]
    Embed the screenshot into pdf    ${order}[Order number]
    Start another order

Start another order
    Click Button When Visible    id:order-another

Input from dialog
    Add heading    Where is csv?
    Add text input    url    label=What is the name of the csv?    placeholder=orders
    ${result}=    Run dialog
    Download CSV    ${result.url}

Download CSV
    [Arguments]    ${csv_filename}    ##orders
    Download    https://robotsparebinindustries.com/${csv_filename}.csv    overwrite=True

Fill form from CSV
    ##Open Workbook    orders.csv
    ${orders}=    Read table from CSV    header=True    path=orders.csv
    ##${orders}=    Create table    orders.csv
    FOR    ${order}    IN    @{orders}
        Fill robot order form using csv    ${order}
    END
## #root > div > div.container > div > div.col-sm-7 > div

Preview robot
    Click Button    css:#preview
    Wait Until Element Contains    css:.col-sm-5    Admire your robot!

Retry order 200 times to avoid errors
    Wait Until Keyword Succeeds    200    1 sec    Send order

Send order
    Click Button    id:order
    Wait Until Page Contains    Receipt

Take a screenshot of robot
    [Arguments]    ${robot_id}
    RPA.Browser.Selenium.Screenshot    css:#robot-preview-image    ${OUTPUT_DIR}${/}${robot_id}.png

Store receipt pdf
    [Arguments]    ${robot_id}
    Wait Until Element Is Visible    id:receipt
    ${receipt} =    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${robot_id}.pdf

Embed the screenshot into pdf
    [Arguments]    ${robot_id}
    ${file_turned_into_list}=    Create List    ${OUTPUT_DIR}${/}${robot_id}.png
    Add Files To Pdf    files=${file_turned_into_list}    target_document=${OUTPUT_DIR}${/}${robot_id}.pdf    append=True
    ##Close Pdf    ${OUTPUT_DIR}${/}${robot_id}.pdf
    Close All Pdfs

Close opened pdfs
    Close All Pdfs

Create zip file of results
    Archive Folder With Zip    output    ${OUTPUT_DIR}${/}results.zip    include=*pdf

Get vault values
    ${secret}=    Get Secret    MeaningOfLife
    Log    ${secret}[MeaningOfLife]
