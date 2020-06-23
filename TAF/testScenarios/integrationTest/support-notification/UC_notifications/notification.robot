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
    [Tags]  done
    When Create device  create_device.json
    Then Notification has been created  Test-Device-POST

Notification should be created if device adminState has been updated
    [Tags]  done
    Given Create Device  create_locked_device.json
    When Update Device  adminState  UNLOCKED
    Then Notification has been created  Locked-Device-PUT
    [Teardown]  Delete Device by name

Notification should be created if device operationState has been updated
    [Tags]  done
    Given Create Device  create_disabled_device.json
    When Update Device  operatingState  ENABLED
    Then Notification has been created  Disabled-Device-PUT
    [Teardown]  Delete Device by name

Notification should be created if device profile has been changed
    [Tags]  Skipped
    Given Create Device
    When Update Device ${profileChanged}
    Then  Notification has been created

Notification should be created if autoEvent has been changed
    [Tags]  test
    @{data_types_skip_write_only}=  Skip write only commands
    ${last_reading}=  Get last support reading
    ${reading_name}=  set variable  ${data_types_skip_write_only}[${last_reading}][readingName]
    ${frequency_value}=  set variable  8
    ${onChange_value}=  set variable  false
    Creat device with autoEvents parameter  ${frequency_value}  ${onChange_value}  ${reading_name}
    When Update Device ${autoEventChanged}
    Then Notification has been created

Notification should be created if deleting device
    [Tags]  delete
    When Delete Device by name Test-Device
    Then Notification has been created  Test-Device-DELETE
