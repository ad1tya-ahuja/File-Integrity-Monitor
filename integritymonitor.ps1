#Function for calculating File Hashes
Function Calculate-File-Hash($filepath){
    $filehash=Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists(){
    $baselineExists=Test-Path -Path .\baseline.txt

    if ($baselineExists -eq $true){
        Remove-Item -Path 'D:\WORK PROJECT\baseline.txt'
    }
}


Write-Host " "
$validinput=$false
while(-not $validinput)
{
    Write-Host "What would you like to do?"
    Write-Host "A)Collect New Baseline?"
    Write-Host "B)Begin monitoring with new baseline?"
    
    $response = Read-Host -Prompt "Please Enter A or B"

    if ($response -eq 'A' -or $response -eq 'B'){
        $validinput=$true
    }
}



if ($response -eq 'A'){
    Write-Host "Calculate Hashes and make new baseline.txt" -ForegroundColor Cyan
    #Delete baseline.txt if already exists
    Erase-Baseline-If-Already-Exists

    #Collect all the  files in the target folder
    $files=Get-ChildItem -Path 'D:\WORK PROJECT\FIM'
    
    #For each file calculate the hash and store it into baseline.txt
    foreach($f in $files){
        $hash=Calculate-File-Hash($f.FullName)
        "$($hash.Path)|$($hash.Hash)" | Out-File 'D:\WORK PROJECT\baseline.txt' -Append
    }

}

elseif ($response -eq 'B'){
    #Load file|hash from baseline.txt and store them in dictionary
    $filehashdictionary=@{}

    $fileData=Get-Content -Path 'D:\WORK PROJECT\baseline.txt'
    foreach ($file in $fileData){
        #Splitting by the pipe operator |
        $filehashdictionary.add($file.Split("|")[0],$file.Split("|")[1])
    }
    
    #Continuos checking of integrity of files
    while($true){
        Start-Sleep -Seconds 1
        Write-Host "Checking if Files match" -ForegroundColor White -BackgroundColor Black
        
        $files=Get-ChildItem -Path 'D:\WORK PROJECT\FIM' 
        foreach ($f in $files)
        {
            $hash= Calculate-File-Hash $f.FullName

                #Checking if new File has been added into the folder
                if ($filehashdictionary[$hash.Path] -eq $null)
                {
                    Write-Host "$($hash.Path) has been created" -ForegroundColor Green -BackgroundColor Black
                }

                else
                {
                     #Notify if file have been altered
                    if ($filehashdictionary[$hash.Path] -eq $hash.Hash){
                    #File has not been changed
                    }
                    else{
                    #File has been changed
                    Write-Host "$($hash.Path) has been compromised" -ForegroundColor red -BackgroundColor Black

                    }
                }
            
           
               
        }
        foreach($key in $filehashdictionary.keys){
                $baselineFileExists= Test-Path -Path $key
                    if (-Not $baselineFileExists){
                        #File is missing
                        Write-Host "$($key) has been deleted" -ForegroundColor Yellow -BackgroundColor Black
                    }
            }
        

    }

    Write-Host "Use existing baseline.txt, start monitoring files" -ForegroundColor Yellow
}


