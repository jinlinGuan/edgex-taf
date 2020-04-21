*** Settings ***
Library  RequestsLibrary
Library  OperatingSystem
Library  TAF.utils.src.setup.setup_teardown
Library  String
Resource  ./commonKeywords.robot

*** Variables ***
${coreMetadataUrl}  http://${BASE_URL}:${CORE_METADATA_PORT}
${deviceProfileUri}    /api/v1/deviceprofile
${deviceUri}    /api/v1/device
${deviceServiceUri}  /api/v1/deviceservice
${LOG_FILE_PATH}     ${WORK_DIR}/TAF/testArtifacts/logs/coreMetadataAPI.log

*** Keywords ***
# Device Profile
Create device profile
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${file_data}=  Get Binary File  ${WORK_DIR}/TAF/config/${PROFILE}/sample_profile.yaml
    ${files}=  Create Dictionary  file=${file_data}
    ${resp}=  Post Request  Core Metadata  ${deviceProfileUri}/uploadfile  files=${files}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set suite variable  ${deviceProfileId}  ${resp.content}

Create device profile ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata    /api/v1/deviceprofile  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Query device profile by id and return by device profile name
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/${deviceProfileId}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=  get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "No device profile found"
    ${deviceProfileBody}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]    ${deviceProfileBody}[name]

Query device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=   get request  Core Metadata    ${deviceProfileUri}/name/${device_profile_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=  get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "The device profile ${device_profile_name} is not found"
    run keyword if  ${resp.status_code} == 200  set test variable  ${response}  ${resp.status_code}
    [Return]  ${resp.content}

Delete device profile by name
    [Arguments]   ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceProfileUri}/name/${device_profile_name}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Delete device profile by name ${device_profile_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceProfileUri}/name/${device_profile_name}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# Device
Create device
    [Arguments]  ${device_file}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${data}=  Get File  ${WORK_DIR}/TAF/config/${PROFILE}/${device_file}  encoding=UTF-8
    ${newdata}=  replace string  ${data}   %DeviceServiceName%    ${SERVICE_NAME}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata  ${deviceUri}  data=${newdata}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set suite variable  ${device_id}   ${resp.content}
    sleep  500ms

Create device with ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata    ${deviceUri}  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Creat device with autoEvents parameter
    [Arguments]  ${frequency_time}  ${onChange_value}  ${reading_name}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${data}=  Get File  ${WORK_DIR}/TAF/config/${PROFILE}/create_autoevent_device.json  encoding=UTF-8
    ${newdata}=  replace string  ${data}   %DeviceServiceName%    ${SERVICE_NAME}
    ${newdata}=  replace string  ${newdata}   %frequency%    ${frequency_time}
    ${newdata}=  replace string  ${newdata}   %onChangeValue%   ${onChange_value}
    ${newdata}=  replace string  ${newdata}   %ReadingName%    ${reading_name}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata  ${deviceUri}  data=${newdata}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    set test variable  ${device_id}   ${resp.content}

Query device by id and return device name
    # output device name
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Get Request  Core Metadata    ${deviceUri}/${device_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_length}=    get length  ${resp.content}
    run keyword if  ${resp_length} == 3   fail  "No device found"
    ${deviceResponseBody}=  evaluate  json.loads('''${resp.content}''')  json
    [Return]    ${deviceResponseBody}[name]

Delete device by name
    ${deviceName}=    Query device by id and return device name
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/name/${deviceName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Delete device by name ${deviceName}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceUri}/name/${deviceName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

Create device profile and device
    ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
    Should Be True  ${status}  Failed Suite Setup
    Create device profile
    Create device   create_device.json

Update Device
    [Arguments]  ${state}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${data}=  Get File  ${WORK_DIR}/TAF/config/${PROFILE}/create_disabled_device.json  encoding=UTF-8
    ${newdata}=  replace string  ${data}  UNLOCKED  ${state}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Put Request  Core Metadata  ${deviceUri}  json=${newdata}  headers=${headers}
    run keyword if  ${resp.status_code}!=200  log   ${resp.content}
    set test variable  ${response}  ${resp.status_code}

# Addressable
Create addressable ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata    /api/v1/addressable  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Delete addressable by name ${addressableName}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  api/v1/addressable/name/${addressableName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

# Device service
Create device service ${entity}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  Post Request  Core Metadata    ${deviceServiceUri}  json=${entity}   headers=${headers}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Set test variable  ${response}  ${resp.status_code}

Delete device service by name ${deviceServiceName}
    Create Session  Core Metadata  url=${coreMetadataUrl}
    ${resp}=  Delete Request  Core Metadata  ${deviceServiceUri}/name/${deviceServiceName}
    run keyword if  ${resp.status_code}!=200  log to console  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


