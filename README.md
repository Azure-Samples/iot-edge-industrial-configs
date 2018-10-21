# Using Microsoft Azure OPC Components
This repository contains several configurations to show how to configure and run Microsofts Azure OPC components:
- [OPC Publisher](https://github.com/Azure/iot-edge-opc-publisher)

# **Containers used in the configurations**
The setup is using 3 containers, which are all available via the Microsoft Container Registry or on Docker Hub.

### OPC Publisher
OPC Publisher allows to send telemetry from OPC UA server systems to IoTHub. The source is available in [this](https://github.com/Azure/iot-edge-opc-publisher) github repository.

A container is available as [mcr.microsoft.com/iotedge/opc-publisher](https://hub.docker.com/r/microsoft/iot-edge-opc-publisher/) in the Microsoft Container Registry.

### OPC PLC
An OPC UA server using the [OPC UA .NET Standard Console Reference stack](https://github.com/OPCFoundation/UA-.NETStandard), with some nodes generating random data and data with anomalies. The source could be found [here](https://github.com/Azure-Samples/iot-edge-opc-plc).
The nodeset of this server contains various nodes which can be used to generate random data or anomalies.

A container is available as [mcr.microsoft.com/iotedge/opc-plc](https://hub.docker.com/r/microsoft/iot-edge-opc-plc/) in the Microsoft Container Registry.

### OPC Client
An OPC UA client, using the [OPC UA .NET Standard Console Reference stack](https://github.com/OPCFoundation/UA-.NETStandard), which allows to run OPC operations on an OPC UA server. The source could be found [here](https://github.com/Azure-Samples/iot-edge-opc-client).

A container is available as [mcr.microsoft.com/iotedge/opc-client](https://hub.docker.com/r/microsoft/iot-edge-opc-client/) in the Microsoft Container Registry.

### OPC Testserver
An OPC UA server, based on the OPC UA .NET Standard Console Reference server. The source could be found [here](https://github.com/hansgschossmann/iot-edge-opc-publisher-testserver).
The nodeset of this server contains various nodes used by OPC Testclient to test OPC Publisher functionality.

A container is available as [hansgschossmann\iot-edge-opc-publisher-testserver](https://hub.docker.com/r/hansgschossmann/iot-edge-opc-publisher-testserver/) on Docker Hub.

### OPC Testclient
An OPC UA client, based on the .NET Standard Console client, which is calling OPC UA methods of OPC Publisher to publish/unpublish nodes in the testserver. The source could be found [here](https://github.com/hansgschossmann/iot-edge-opc-publisher-testclient.git).
The client does access OPC Publisher to publish/unpublish nodes of OPC Testserver.

A container is available as [hansgschossmann\iot-edge-opc-publisher-testclient](https://hub.docker.com/r/hansgschossmann/iot-edge-opc-publisher-testclient/) on Docker Hub.

### Nomenclature
- <reporoot> is the root directory of this repositories clone

### General Preparation
- Define an environment variable `$env:_HUB_CS` and set it to your iothubowner connection string of the IoTHub you are using
- If you are using docker to run the setup, create a docker bridge network with name `iot_edge` with `docker network create iot_edge`. Verify with `docker network ls`
- The samples are using Windows as the host OS, they are using Linux containers (means that LCOW is used) and they use PowerShell as the shell
- If you are using native executables, ensure you have installed Visual Studio, git and the required .NET SDKs
- If you are using configurations with Docker containers. Install Docker and ensure that you have shared the drive where `<reporoot>` is located via the Docker Settings dialog
- Define an environment variable `$env:_REPO_ROOT` and set it to the full qualified directory name of the root of this repository


# **Configurations with locally built docker containers**

## **OPC Publisher publishing data from OPC PLC**
### Quickstart
Run the following PowerShell commands in the root of the repository:
```
git clone https://github.com/Azure-Samples/iot-edge-opc-plc
cd ./iot-edge-opc-plc
docker build -t opc-plc .
docker run -h opcplc --name opcplc --network iot_edge --expose 51210 -p 51210:51210 opc-plc --aa
```
In a second PowerShell command window run the following commands in the root of the repository:
```
git clone https://github.com/Azure/iot-edge-opc-publisher
cd ./iot-edge-opc-publisher
docker build -t opc-publisher .
docker run -h publisher --name publisher --network iot_edge -v "$($env:_REPO_ROOT):/appdata" -e "_HUB_CS=$env:_HUB_CS" opc-publisher publisher --aa --pf /appdata/publishednodes_opcplc.json
```

### Verification
>Verify that opc-publisher is connected to opc-plc and that 7 items are monitored. You should see something like this in the log output of opc-publisher:
> ```
> [18:52:08 INF] Connect and monitor session and nodes on endpoint 'opc.tcp://opcplc:50000/'.
> [18:52:10 INF] Create secured session for endpoint URI 'opc.tcp://opcplc:50000/' with timeout of 10000 ms.
> [18:52:10 INF] Certificate 'CN=OpcPlc' will be trusted, since the autotrustservercerts options was specified.
> [18:52:10 INF] Session successfully created with Id ns=3;i=1792545597.
> [18:52:10 INF] The session to endpoint 'opc.tcp://opcplc:50000/' has 4 entries in its namespace array:
> [18:52:10 INF] Namespace index 0: http://opcfoundation.org/UA/
> [18:52:10 INF] Namespace index 1: urn:OpcPlc:opcplc
> [18:52:10 INF] Namespace index 2: http://microsoft.com/Opc/OpcPlc/
> [18:52:10 INF] Namespace index 3: http://opcfoundation.org/UA/Diagnostics
> [18:52:10 INF] The server on endpoint 'opc.tcp://opcplc:50000/' supports a minimal sampling interval of 0 ms.
> [18:52:10 INF] Created subscription with id 1 on endpoint 'opc.tcp://opcplc:50000/'
> [18:52:10 INF] Create subscription on endpoint 'opc.tcp://opcplc:50000/' requested OPC publishing interval is 0 ms. (revised: 0 ms)
> [18:52:10 INF] Start monitoring items on endpoint 'opc.tcp://opcplc:50000/'. Currently monitoring 0 items.
> [18:52:10 INF] Done processing unmonitored items on endpoint 'opc.tcp://opcplc:50000/' took 96 msec. Now monitoring 7 items in subscription with id '1'.
> ```

> Verify that data is sent to the IoTHub you configured by setting `_HUB_CS` using [Device Explorer](https://github.com/Azure/azure-iot-sdk-csharp/tree/master/tools/DeviceExplorer) or [iothub-explorer](https://github.com/Azure/iothub-explorer)

# **Configurations with prebuilt docker containers**

## **OPC Publisher publishing data from OPC PLC**
### Quickstart
Run the following PowerShell commands in the root of the repository:
```
docker run -h opcplc --name opcplc --network iot_edge --expose 51210 -p 51210:51210 mcr.microsoft.com/iotedge/opc-plc --autoaccept
```
In a second PowerShell command window run the following commands in the root of the repository:
```
docker run -h publisher --name publisher --network iot_edge -v "$($env:_REPO_ROOT):/appdata" -e "_HUB_CS=$env:_HUB_CS" mcr.microsoft.com/iotedge/opc-publisher publisher --aa --pf /appdata/publishednodes_opcplc.json
```

### Verification
>Verify that opc-publisher is connected to opc-plc and that 7 items are monitored. You should see something like this in the log output of opc-publisher:
> ```
> [19:10:51 INF] Connect and monitor session and nodes on endpoint 'opc.tcp://opcplc:50000/'.
> [19:10:52 INF] Create secured session for endpoint URI 'opc.tcp://opcplc:50000/' with timeout of 10000 ms.
> [19:10:52 INF] Certificate 'CN=OpcPlc' will be trusted, since the autotrustservercerts options was specified.
> [19:10:53 INF] Session successfully created with Id ns=3;i=474450433.
> [19:10:53 INF] The session to endpoint 'opc.tcp://opcplc:50000/' has 4 entries in its namespace array:
> [19:10:53 INF] Namespace index 0: http://opcfoundation.org/UA/
> [19:10:53 INF] Namespace index 1: urn:OpcPlc:opcplc
> [19:10:53 INF] Namespace index 2: http://microsoft.com/Opc/OpcPlc/
> [19:10:53 INF] Namespace index 3: http://opcfoundation.org/UA/Diagnostics
> [19:10:53 INF] The server on endpoint 'opc.tcp://opcplc:50000/' supports a minimal sampling interval of 0 ms.
> [19:10:53 INF] Created subscription with id 1 on endpoint 'opc.tcp://opcplc:50000/'
> [19:10:53 INF] Create subscription on endpoint 'opc.tcp://opcplc:50000/' requested OPC publishing interval is 0 ms. (revised: 0 ms)
> [19:10:53 INF] Start monitoring items on endpoint 'opc.tcp://opcplc:50000/'. Currently monitoring 0 items.
> [19:10:53 INF] Done processing unmonitored items on endpoint 'opc.tcp://opcplc:50000/' took 93 msec. Now monitoring 7 items in subscription with id '1'.> ```
> ```

> Verify that data is sent to the IoTHub you configured by setting `_HUB_CS` using [Device Explorer](https://github.com/Azure/azure-iot-sdk-csharp/tree/master/tools/DeviceExplorer) or [iothub-explorer](https://github.com/Azure/iothub-explorer)


# **Configurations using docker-compose**

## **OPC Publisher publishing data from OPC PLC**
### Quickstart
Run the following PowerShell commands in the root of the repository:
```
docker-compose -f simple.yml up
```

### Verification
>Verify that opc-publisher is connected to opc-plc and that 7 items are monitored. You should see something like this in the log output of opc-publisher:
> ```
> publisher    | [19:30:59 INF] Connect and monitor session and nodes on endpoint 'opc.tcp://opcplc:50000/'.
> publisher    | [19:31:00 INF] Create secured session for endpoint URI 'opc.tcp://opcplc:50000/' with timeout of 10000 ms.
> publisher    | [19:31:00 INF] Certificate 'CN=opcplc' will be trusted, since the autotrustservercerts options was specified.
> publisher    | [19:31:01 INF] Session successfully created with Id ns=3;i=736575751.
> publisher    | [19:31:01 INF] The session to endpoint 'opc.tcp://opcplc:50000/' has 4 entries in its namespace array:
> publisher    | [19:31:01 INF] Namespace index 0: http://opcfoundation.org/UA/
> publisher    | [19:31:01 INF] Namespace index 1: urn:opcplc
> publisher    | [19:31:01 INF] Namespace index 2: http://microsoft.com/Opc/OpcPlc/
> publisher    | [19:31:01 INF] Namespace index 3: http://opcfoundation.org/UA/Diagnostics
> publisher    | [19:31:01 INF] The server on endpoint 'opc.tcp://opcplc:50000/' supports a minimal sampling interval of 0 ms.
> publisher    | [19:31:01 INF] Created subscription with id 1 on endpoint 'opc.tcp://opcplc:50000/'
> publisher    | [19:31:01 INF] Create subscription on endpoint 'opc.tcp://opcplc:50000/' requested OPC publishing interval is 0 ms. (revised: 0 ms)
> publisher    | [19:31:01 INF] Start monitoring items on endpoint 'opc.tcp://opcplc:50000/'. Currently monitoring 0 items.
> publisher    | [19:31:01 INF] Done processing unmonitored items on endpoint 'opc.tcp://opcplc:50000/' took 94 msec. Now monitoring 7 items in subscription with id '1'.
> ```

> Verify that data is sent to the IoTHub you configured by setting `_HUB_CS` using [Device Explorer](https://github.com/Azure/azure-iot-sdk-csharp/tree/master/tools/DeviceExplorer) or [iothub-explorer](https://github.com/Azure/iothub-explorer)


## **OPC PLC for Connected Factory v1**
### Quickstart
Run the following PowerShell commands in the root of the repository:
```
docker-compose -f cfv1-simple.yml up
```

### Verification
> Verify that the telemetry is sent to the Connected factory dashboard. There should be a "New factory" with "New Production line" shown with one station and there should be several node values "AlternatingBoolean", "DipData", ...., which should be changing

> Verify that browsing the OPC UA Server "opc.tcp://opcplc:50000" via the Connected Factory dashboard is working



# **Testbeds**

## **Securing communication of OPC Client and OPC PLC by signing their certificates using OPC Vault CA**
In this setup the OPC Client is testing the connectivity to the OPC PLC. By default the connectivity is not possible, because the both components have not been provisioned with the right certificates. If an OPC UA component was not provisioned with a certificate yet, it will generate a self-signed certificate on startup. This certificate can be signed by a CA and installed in the OPC UA component. After this was done for OPC Client and OPC PLC, the connectivity is working. The workflow below describes this process.

Some background information on OPC UA security can be found in [this](https://opcfoundation.org/wp-content/uploads/2014/05/OPC-UA_Security_Model_for_Administrators_V1.00.pdf) whitepaper. The complete information can be found in the OPC UA specification.

## Step 1
### Preparation
- Ensure that the environment variables `$env:_PLC_OPT` and `$env:_CLIENT_OPT` are undefined. (e.g. `$env:_PLC_OPT=""` in your PowerShell)
- Set the environment variable `$env:_OPCVAULTID` to a string which allows you to find your data again in OPC Vault. Only alphanumeric characters are allowed. For our example "123456" was used as value for this variable.
- Ensure there are no docker volumes `opcclient` or `opcplc`. Check with `docker volume ls` and remove them with `docker volume rm <volumename>`. You may need to remove also containers with `docker rm <containerid>` if the volumes are still used by a container.

### Quickstart
Run the following PowerShell command in the root of the repository:
```
docker-compose -f connecttest.yml up
```

### Verification
> Verify in the log that there are no certificates installed on the first startup. Here the log output of OPC PLC (similar shows up for OPC Client):..
> ```
> opcplc-123456 | [20:51:32 INF] Trusted issuer store contains 0 certs
> opcplc-123456 | [20:51:32 INF] Trusted issuer store has 0 CRLs.
> opcplc-123456 | [20:51:32 INF] Trusted peer store contains 0 certs
> opcplc-123456 | [20:51:32 INF] Trusted peer store has 0 CRLs.
> opcplc-123456 | [20:51:32 INF] Rejected certificate store contains 0 certs
> ```
> If you do see certificates reported, please follow the preparation steps above and delete the docker volumes.

> Verify that the connection to the OPC PLC has failed. You should see the following output in the OPC Client log output:
> ```
> opcclient-123456 | [20:51:35 INF] Create secured session for endpoint URI 'opc.tcp://opcplc-123456:50000/' with timeout of 10000 ms.
> opcclient-123456 | [20:51:36 ERR] Session creation to endpoint 'opc.tcp://opcplc-123456:50000/' failed 1 time(s). Please verify if server is up and OpcClient configuration is correct.
> opcclient-123456 | Opc.Ua.ServiceResultException: Certificate is not trusted.
> ```
> Important is that the reason for the failure is: Certificate is not trusted. This means that `opc-client` tried to connect to `opc-plc` and got a response back that `opc-plc` does not trust `opc-client`, because `opc-plc` can not validate the certificate `opc-client` has provided. This is a self-signed certificate and without further certificate configuration on `opc-plc`  it will not be allowed to connect.

## Step 2
### Preparation
1. Look at the log output of Step 1 and fetch "CreateSigningRequest information" for the OPC PLC and the OPC Client. Here only shown for OPC PLC:
    ```
    opcplc-123456 | [20:51:32 INF] ----------------------- CreateSigningRequest information ------------------
    opcplc-123456 | [20:51:32 INF] ApplicationUri: urn:OpcPlc:opcplc-123456
    opcplc-123456 | [20:51:32 INF] ApplicationName: OpcPlc
    opcplc-123456 | [20:51:32 INF] ApplicationType: Server
    opcplc-123456 | [20:51:32 INF] ProductUri: https://github.com/azure-samples/iot-edge-opc-plc
    opcplc-123456 | [20:51:32 INF] DiscoveryUrl[0]: opc.tcp://opcplc-123456:50000
    opcplc-123456 | [20:51:32 INF] ServerCapabilities: DA
    opcplc-123456 | [20:51:32 INF] CSR (base64 encoded):
    opcplc-123456 | MIICmzCCAYMCAQAwETEPMA0GA1UEAwwGT3BjUGxjMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwTvlbinAPWPxR9Lw1ndGsrLGy8GiqVOxyGaDpPUcMchX0k0/ncg28h7xrB2H1PThdiZxUJuUwsNM74HrVgt
    ofmXhA4dLM1cTxZHyJVFjl2L3vK5M58NNf6UNdKcB0x3LyuoT6mAIMXmCioqymFCk1TMzIMzbAe7JVAdUaSRBP1vuqQ1rV/cfNAe35dKQW4aPYgl7pR5f1hqprcDu/oca67X8L4kTl4oN0/bCYTk+Ibcd9cG462oAN+bSwbHn8a2jNky8rGsofA
    o9DOT+0ALPhk6CApCYIP2yxoI/kT188eqUUxzAFF9nyU79AyCkpGPuY8DGMyf56pDofgtGpfY3wQIDAQABoEUwQwYJKoZIhvcNAQkOMTYwNDAyBgNVHREEKzAphhh1cm46T3BjUGxjOm9wY3BsYy0xMjM0NTaCDW9wY3BsYy0xMjM0NTYwDQYJK
    oZIhvcNAQELBQADggEBAAsZLoOLzS2VhDcQRu0QhRbG7CGAxX19l7fDCG2WjU7lTFnCvYVTWTYyaY61ljmrWc7IbCaQdMJM8GRnAnvAzUh/PBDxkOX7NqI2+8F1yQOHgs/AfKuppOd6DIP8EzFAHnc0H85jay6zFdmIDWoWwpy0ACqOVooOTKST
    7uty0mT87bj8Cdy1yf4mvBNQx+nsuTbKgxWCBxGYAyg9dIL2uKL0aeB/ROW5Gkelz5sCEzQ1fFDokUA4oC5QiATQBN3cY7EmvRbPgdToY7CpRN3iiO7J+7bC7BP9YKfuE34E8xOFpskHPHAPf3r002/L0S67HyuVSXLUj1+Jc0LeAAF9Bw0=
    opcplc-123456 | [20:51:32 INF] ---------------------------------------------------------------------------
    ```
1. Go to the [OPC Vault website](https://opcvault.azurewebsites.net/)
1. Select `Register New`
1. Enter the OPC PLC information from the log outputs `CreateSigningRequest information` area into the input fields on the `Register New OPC UA Application` page, please select `Server` as ApplicationType.
1. Select `Register`
1. On the next page `Request New Certificate for OPC UA Application` select `Request new Certificate with Signing Request`
1. On the next page `Generate a new Certificate with a Signing Request` paste in the `CSR (base64 encoded)` string from the log output into the `CreateRequest` input field. Ensure you copy the full string.
1. Select `Generate New Certificate`
1. You are now moving forward to `View Certificate Request Details`. On this page you can download all required information to provision the certificate stores of `opc-plc`.
1. On this page:  
    - Select `Certificate` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<applicationcertbase64-string>` later on. Select `Back`.
    - Select `Issuer` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<addissuercertbase64-string>` later on. Select `Back`.
    - Select `Crl` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<updatecrlbase64-string>` later on. Select `Back`.
1. Now set in your PowerShell a variable named `$env:_PLC_OPT`:

    ```
    `$env:_PLC_OPT="--applicationcertbase64 <applicationcertbase64-string> --addtrustedcertbase64 <addissuercertbase64-string> --addissuercertbase64 <addissuercertbase64-string> --updatecrlbase64 <updatecrlbase64-string>"`  
    ```
    Note: Replace the strings passed in as option values Base64 strings you fetched from the website.

Repeat the complete process starting with `Register New` (Step 3 above) for the OPC Client. There are only the following differences you need to be aware of:

- Use the log output from the `opcclient`.
- Select `Client` as ApplicationType during registration.
- Use `$env:_CLIENT_OPT` as name of the PowerShell variable.

Note: While working with this scenario, you may have recognized that the `<addissuercertbase64-string>` and `<updatecrlbase64-string>` values are identical for `opcplc` and `opcclient`. This is for our use case true and can save you some time while doing the steps.

### Quickstart
Run the following PowerShell command in the root of the repository:
```
docker-compose -f connecttest.yml up
```

### Verification
> Verify that the two components have now signed application certificates. Check the log output for the following:
> ```
> opcplc-123456 | [20:54:38 INF] Starting to add certificate(s) to the trusted issuer store.
> opcplc-123456 | [20:54:38 INF] Certificate 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' and thumbprint 'BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83' was added to the trusted issuer store.
> opcplc-123456 | [20:54:38 INF] Starting to add certificate(s) to the trusted peer store.
> opcplc-123456 | [20:54:38 INF] Certificate 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' and thumbprint 'BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83' was added to the trusted peer store.
> opcplc-123456 | [20:54:38 INF] Starting to update the current CRL.
> opcplc-123456 | [20:54:38 INF] Remove the current CRL from the trusted peer store.
> opcplc-123456 | [20:54:38 INF] The new CRL issued by 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' was added to the trusted peer store.
> opcplc-123456 | [20:54:38 INF] Remove the current CRL from the trusted issuer store.
> opcplc-123456 | [20:54:38 INF] The new CRL issued by 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' was added to the trusted issuer store.
> opcplc-123456 | [20:54:38 INF] Start updating the current application certificate.
> opcplc-123456 | [20:54:38 INF] The current application certificate has SubjectName 'CN=OpcPlc' and thumbprint '8FD43F66479398BDA3AAF5B193199A6657632B49'.
> opcplc-123456 | [20:54:39 INF] Remove the existing application certificate with thumbprint '8FD43F66479398BDA3AAF5B193199A6657632B49'.
> opcplc-123456 | [20:54:39 INF] The new application certificate 'CN=OpcPlc' and thumbprint 'DA6B8B2FB533FBC188F7017BAA8A36FDB77E2586' was added to the application certificate store.
> opcplc-123456 | [20:54:39 INF] Activating the new application certificate with thumbprint 'DA6B8B2FB533FBC188F7017BAA8A36FDB77E2586'.
> opcplc-123456 | [20:54:39 INF] Application certificate with thumbprint 'DA6B8B2FB533FBC188F7017BAA8A36FDB77E2586' found in the application certificate store.
> opcplc-123456 | [20:54:39 INF] Application certificate is for ApplicationUri 'urn:OpcPlc:opcplc-123456', ApplicationName 'OpcPlc' and Subject is 'OpcPlc'
> ```
> The Application certificate is there and signed by an CA.

> Verify in the log that there are now certificates installed. Here the log output of OPC PLC (similar shows up for OPC Client):
> ```
> opcplc-123456 | [20:54:39 INF] Trusted issuer store contains 1 certs
> opcplc-123456 | [20:54:39 INF] 01: Subject 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' (thumbprint: BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83)
> opcplc-123456 | [20:54:39 INF] Trusted issuer store has 1 CRLs.
> opcplc-123456 | [20:54:39 INF] 01: Issuer 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.', Next update time '10/19/2019 22:06:46'
> opcplc-123456 | [20:54:39 INF] Trusted peer store contains 1 certs
> opcplc-123456 | [20:54:39 INF] 01: Subject 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' (thumbprint: BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83)
> opcplc-123456 | [20:54:39 INF] Trusted peer store has 1 CRLs.
> opcplc-123456 | [20:54:39 INF] 01: Issuer 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.', Next update time '10/19/2019 22:06:46'
> opcplc-123456 | [20:54:39 INF] Rejected certificate store contains 0 certs
> ```
> The issuer of the application certificate is the CA `CN=Azure IoT OPC Vault CA, O=Microsoft Corp.` and the OPC PLC trust also all certificates signed by this CA.


> Verify that the connection to the OPC PLC has been created successfully and the OPC Client can successfully read data from OPC PLC. You should see the following output in the OPC Client log output:
> ```
> opcclient-123456 | [20:54:42 INF] Create secured session for endpoint URI 'opc.tcp://opcplc-123456:50000/' with timeout of 10000 ms.
> opcclient-123456 | [20:54:42 INF] Session successfully created with Id ns=3;i=1085867946.
> opcclient-123456 | [20:54:42 INF] The session to endpoint 'opc.tcp://opcplc-123456:50000/' has 4 entries in its namespace array:
> opcclient-123456 | [20:54:42 INF] Namespace index 0: http://opcfoundation.org/UA/
> opcclient-123456 | [20:54:42 INF] Namespace index 1: urn:OpcPlc:opcplc-123456
> opcclient-123456 | [20:54:42 INF] Namespace index 2: http://microsoft.com/Opc/OpcPlc/
> opcclient-123456 | [20:54:42 INF] Namespace index 3: http://opcfoundation.org/UA/Diagnostics
> opcclient-123456 | [20:54:42 INF] The server on endpoint 'opc.tcp://opcplc-123456:50000/' supports a minimal sampling interval of 0 ms.
> opcclient-123456 | [20:54:42 INF] Execute 'OpcClient.OpcTestAction' action on node 'i=2258' on endpoint 'opc.tcp://opcplc-123456:50000/' with security.
> opcclient-123456 | [20:54:42 INF] Action (ActionId: 000 ActionType: 'OpcTestAction', Endpoint: 'opc.tcp://opcplc-123456:50000/' Node 'i=2258') completed successfully
> opcclient-123456 | [20:54:42 INF] Value (ActionId: 000 ActionType: 'OpcTestAction', Endpoint: 'opc.tcp://opcplc-123456:50000/' Node 'i=2258'): 10/20/2018 20:54:42
> ```
> If you see this, then the OPC PLC is now trusting OPC Client an vice versa, since both have now certificates signed by a CA and both trust certificates which where signed by this CA.

Note: Even so we showed the first two verification steps only for OPC PLC, those need to be verified also for OPC Client.


## **Securing OPC UA Client and OPC UA Server Application with a new key pair and certificate using OPC Vault**
In this setup the OPC Client is testing the connectivity to the OPC PLC. By default the connectivity is not possible, because the both components have not yet been provisioned with the right certificates. In this workflow we do not use the OPC UA components self-signed certificates and sign them via OPC Vault (the previous testbed is showing how to do this), but provision the components with a new certificate as well as with a new private key, which both are generated by OPC Vault.

Some background information on OPC UA security can be found in [this](https://opcfoundation.org/wp-content/uploads/2014/05/OPC-UA_Security_Model_for_Administrators_V1.00.pdf) whitepaper. The complete information can be found in the OPC UA specification.

## Step 1
### Preparation
- Ensure that the environment variables `$env:_PLC_OPT` and `$env:_CLIENT_OPT` are undefined. (e.g. `$env:_PLC_OPT=""` in your PowerShell)
- Set the environment variable `$env:_OPCVAULTID` to a string which allows you to find your data again in OPC Vault. We recommend to set it to a 6 digit number. For our example "123456" was used as value for the variable.
- Ensure there are no docker volumes `opcclient` or `opcplc`. Check with `docker volume ls` and remove them with `docker volume rm <volumename>`. You may need to remove also containers with `docker rm <containerid>` if the volumes are still used by a container.

### Quickstart
1. Go to the [OPC Vault website](https://opcvault.azurewebsites.net/)
1. Select `Register New`
1. Enter the OPC PLC information as it was shown in the previous testbed's log output `CreateSigningRequest information` area into the input fields on the `Register New OPC UA Application` page, please select `Server` as ApplicationType.
1. Select `Register`
1. On the next page `Request New Certificate for OPC UA Application` select `Request new KeyPair and Certificate`
1. On the next page `Generate a new Certificate with a Signing Request` paste in the `CSR (base64 encoded)` string from the log output into the `CreateRequest` input field. Ensure you copy the full string.
1. On the next page `Request New Certificate for OPC UA Application` select `Request new Certificate with Signing Request`
1. On the next page `Generate a new KeyPair and for an OPC UA Application` enter `CN=OpcPlc` as SubjectName, `opcplc-<_OPCVAULTID>` (replace `<_OPCVAULTID>` with yours) as DomainName, select `PEM` as PrivateKeyFormat and enter a password (we rever later to it as `<certpassword-string>`)
1. Select `Generate New KeyPair`

1. You are now moving forward to `View Certificate Request Details`. On this page you can download all required information to provision the certificate stores of `opc-plc`.
1. On this page:  
    - Select `Certificate` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<applicationcertbase64-string>` later on. Select `Back`.
    - Select `PrivateKey` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<privatekeybase64-string>` later on. Select `Back`.
    - Select `Issuer` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<addissuercertbase64-string>` later on. Select `Back`.
    - Select `Crl` in `Download as Base64` and copy the text string presented in the `EncodedBase64` field and store it for later use. We refer to it as `<updatecrlbase64-string>` later on. Select `Back`.
1. Now set in your PowerShell a variable named `$env:_PLC_OPT`:

>    `$env:_PLC_OPT="--applicationcertbase64 <applicationcertbase64-string> --privatekeybase64 <privatekeybase64-string> --certpassword <certpassword-string> --addtrustedcertbase64 <addissuercertbase64-string> --addissuercertbase64 <addissuercertbase64-string> --updatecrlbase64 <updatecrlbase64-string>"`  
    (Replace the strings passed in as option values Base64 strings you fetched from the website.)  

1. Repeat the complete process starting with `Register New` for the OPC Client. There are only the following differences you need to be aware of:
    - Use the log output from the `opcclient`.
    - Select `Client` as ApplicationType during registration.
    - Use `$env:_CLIENT_OPT` as name of the PowerShell variable.

    Note: While working with this scenario, you may have recognized that the `<addissuercertbase64-string>` and `<updatecrlbase64-string>` values are identical for `opcplc` and `opcclient`. This is for our use case true and can save you some time while doing the steps.

### Quickstart
Run the following PowerShell command in the root of the repository:
```
docker-compose -f connecttest.yml up
```

### Verification
> Verify that the two components have not had an existing application certificate. Check the log output (here the output of OPC PLC (similar shows up for OPC Client) for the following:
> ```
> opcplc-123456 | [13:40:08 INF] There is no existing application certificate.
> ```
> If there is an application certificate, you need to remove the docker volumes as explained in the preparation steps.

> Verify in the log that the OPC Vault CA certificate was installed in the issuer certificate store as well as in the trusted peer certificate store. Here the log output of OPC PLC (similar shows up for OPC Client):
> ```
> opcplc-123456 | [13:40:09 INF] Trusted issuer store contains 1 certs
> opcplc-123456 | [13:40:09 INF] 01: Subject 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' (thumbprint: BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83)
> opcplc-123456 | [13:40:09 INF] Trusted issuer store has 1 CRLs.
> opcplc-123456 | [13:40:09 INF] 01: Issuer 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.', Next update time '10/19/2019 22:06:46'
> opcplc-123456 | [13:40:09 INF] Trusted peer store contains 1 certs
> opcplc-123456 | [13:40:09 INF] 01: Subject 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.' (thumbprint: BC78F1DDC3BB5D2D8795F3D4FF0C430AD7D68E83)
> opcplc-123456 | [13:40:09 INF] Trusted peer store has 1 CRLs.
> opcplc-123456 | [13:40:09 INF] 01: Issuer 'CN=Azure IoT OPC Vault CA, O=Microsoft Corp.', Next update time '10/19/2019 22:06:46'
> opcplc-123456 | [13:40:09 INF] Rejected certificate store contains 0 certs
> ```
> The OPC PLC does now trust all OPC UA Clients with certificates signed by OPC Vault.

> Verify in the log that the private key format is recognized as PEM and that the new application certificate is installed. Here the log output of OPC PLC (similar shows up for OPC Client):
> ```
> opcplc-123456 | [13:40:09 INF] The private key for the new certificate was passed in using PEM format.
> opcplc-123456 | [13:40:09 INF] Remove the existing application certificate.
> opcplc-123456 | [13:40:09 INF] The new application certificate 'CN=OpcPlc' and thumbprint 'A3CB288FC1D2B7A5C08AACF531CF4A85E44A6C4C' was added to the application certificate store.
> opcplc-123456 | [13:40:09 INF] Activating the new application certificate with thumbprint 'A3CB288FC1D2B7A5C08AACF531CF4A85E44A6C4C'.
> ```
> The application certificate and the private key are now installed in the application certfificate store and used by the OPC UA application.

> Verify that the connection between OPC Client and OPC PLC can be established successful and OPC Client can successfully read data from OPC PLC. You should see the following output in the OPC Client log output:
> ```
> opcclient-123456 | [13:40:12 INF] Create secured session for endpoint URI 'opc.tcp://opcplc-123456:50000/' with timeout of 10000 ms.
> opcclient-123456 | [13:40:12 INF] Session successfully created with Id ns=3;i=941910499.
> opcclient-123456 | [13:40:12 INF] The session to endpoint 'opc.tcp://opcplc-123456:50000/' has 4 entries in its namespace array:
> opcclient-123456 | [13:40:12 INF] Namespace index 0: http://opcfoundation.org/UA/
> opcclient-123456 | [13:40:12 INF] Namespace index 1: urn:OpcPlc:opcplc-123456
> opcclient-123456 | [13:40:12 INF] Namespace index 2: http://microsoft.com/Opc/OpcPlc/
> opcclient-123456 | [13:40:12 INF] Namespace index 3: http://opcfoundation.org/UA/Diagnostics
> opcclient-123456 | [13:40:12 INF] The server on endpoint 'opc.tcp://opcplc-123456:50000/' supports a minimal sampling interval of 0 ms.
> opcclient-123456 | [13:40:12 INF] Execute 'OpcClient.OpcTestAction' action on node 'i=2258' on endpoint 'opc.tcp://opcplc-123456:50000/' with security.
> opcclient-123456 | [13:40:12 INF] Action (ActionId: 000 ActionType: 'OpcTestAction', Endpoint: 'opc.tcp://opcplc-123456:50000/' Node 'i=2258') completed successfully
> opcclient-123456 | [13:40:12 INF] Value (ActionId: 000 ActionType: 'OpcTestAction', Endpoint: 'opc.tcp://opcplc-123456:50000/' Node 'i=2258'): 10/21/2018 13:40:12
> ```
> If you see this, then the OPC PLC is now trusting OPC Client an vice versa, since both have now certificates signed by a CA and both trust certificates which where signed by this CA.



## **A testbed for OPC Publisher**
### Quickstart
Run the following PowerShell command in the root of the repository:
```
docker-compose -f testbed.yml up
```

### Verification
- Verify that data is sent to the IoTHub you configured by setting `_HUB_CS` using [Device Explorer](https://github.com/Azure/azure-iot-sdk-csharp/tree/master/tools/DeviceExplorer) or [iothub-explorer](https://github.com/Azure/iothub-explorer)
- OPC Testclient is going to use IoTHub direct method calls and OPC method calls to configure OPC Publisher to publish/unpublish nodes from OPC Testserver
- Watch the output for error messages


# **How to solve problems**
- When starting a container you see the message:

      Error response from daemon: Conflict. The container name "/opcplc" is already in use by container "....". You have to remove (or rename) that container to be able to reuse that name.

  You need to run `docker stop opcplc` and then `docker rm opcplc` or the container id shown in the docker error message.