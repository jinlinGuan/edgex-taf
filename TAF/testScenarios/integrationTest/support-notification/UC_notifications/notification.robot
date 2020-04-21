*** Settings ***
Documentation    Notification Test Case
Resource         TAF/testCaseModules/keywords/coreMetadataAPI.robot
Library          RequestsLibrary
#Suite Setup      Setup Suite
#Suite Teardown   Suite Teardown

*** Variables ***
${SUITE}         Create Notification
${NOTIFICATION_SERVICE_URL}   http://localhost:${SUPPORT_NOTIFICATION_PORT}

*** Keywords ***
Notification has been created
    [Arguments]  ${content}
    Create Session  Notification  url=${NOTIFICATION_SERVICE_URL}
    ${current_timestamp}=  Get current milliseconds epoch time
    ${start_time}=  evaluate  ${current_timestamp}-1000
    ${end_time}=  set variable  ${current_timestamp}
    ${resp}=  Get Request  Notification  /api/v1/notification/start/${start_time}/end/${end_time}/5
    ${result} =  convert to string   ${resp.content}
    Should contain  ${result}  ${content}



*** Test Cases ***
Notification should be created if adding new device
#    [Tags]  test
    When Create device  create_device.json
    Then Notification has been created  Test-Device-POST

Notification should be created if device adminState has been updated
   [Tags]  test
    #Given Create Device  create_disabled_device.json
    When Update Device  LOCKED
#    Then Notification has been created

Notification should be created if device operationState has been updated
    Given Create Device
    When Update Device  opstate
    Then Notification has been created
# /v1/deviceservice/name/{name}/opstate/{opState}
Notification should be created if device profile has been changed
    Given Create Device
    When Update Device ${profileChanged}
    Then Notification has been created

Notification should be created if autoEvent has been changed
    Given Create Device
    When Update Device ${autoEventChanged}
    Then Notification has been created

Notification should be created if deleting device
#    [Tags]  test
    When Delete Device by name Disabled-Device
    Then Notification has been created  Test-Device-DELETE