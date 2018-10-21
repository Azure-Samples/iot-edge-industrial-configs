# remove all container with opc-plc or opc-client reference
docker container ls --all | Select-String -Pattern "(opcplc|opcclient|opc-plc|opc-client)" | ForEach-Object -Process {
    if ($_ -match "^(\w*){1}.*") {
        $containerId = $($matches[1])
        Write-Output "remove container with id $containerId"
        docker rm $containerId
        if ($LASTEXITCODE -ne 0) {
            Write-Output "cannot remove container with id $containerId"
        }
    }
    else {
        Write-Output "cannot parse out container id"
    }
}

# remove all volumes named opcplc or opcclient
docker volume ls -q | ForEach-Object -Process {
    if ($_ -eq "opcclient" -or $_ -eq "opcplc")
    {
        $volumeName = $_
        Write-Output "try to remove volume $volumeName"
        docker volume rm $_
        if ($LASTEXITCODE -ne 0) {
            docker container ls --all | Select-String -Pattern "(opcplc|opcclient|opc-plc|opc-client)" | ForEach-Object -Process {
                if ($_ -match "^(\w*){1}.*") {
                    $containerId = $($matches[1])
                    Write-Output "remove container with id $containerId"
                    docker rm $containerId 
                    if ($LASTEXITCODE -ne 0) {
                        Write-Output "cannot remove container with id $containerId"
                    }
                }
                else {
                    Write-Output "cannot parse out container id"
                }
            }
            docker volume rm $volumeName
            if ($LASTEXITCODE -ne 0) {
                Write-Output "cannot remove volume $volumeName. please remove it manually"
            }
            else {
                Write-Output "volume $volumeName successfully removed"
            }
        }
        else {
            Write-Output "volume $volumeName successfully removed"
        }
    }
}