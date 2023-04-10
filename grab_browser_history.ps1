$UserName = "wootf"
$output_path = "C:\Users\$UserName\"
$hostname = HOSTNAME.EXE
$destination_file = "${hostname}_${UserName}_history_files.zip"

Write-Output "Looking for history files..."

<# Finding Chrome History Path #>
$chrome_path = "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History"
if (-not (Test-Path -Path $chrome_path)) { 
    Write-Output "[!] Could not find Chrome History for $UserName" 
} 
else {
    Write-Output "Found Chrome History for $UserName at path: $chrome_path"
}

<# Finding Edge History Path #>
$edge_path = "$Env:systemdrive\Users\$UserName\AppData\Local\Microsoft\Edge\User Data\Default\History"
if (-not (Test-Path -Path $chrome_path)) { 
    Write-Output "[!] Could not find Edge History for $UserName"
} 
else {
    Write-Output "Found Edge History for $UserName at path: $edge_path"
}

<# Finding FireFox History Path #>

$default = "-release"
$esr = "-esr"
$firefox_path = "C:\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\"

if (Test-Path -Path "C:\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\" ) {

    switch (Get-ChildItem -Path $firefox_path) {
        { $_.Name -match $default } {
            $Path = "C:\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\" 
            $Profiles = Get-ChildItem -Path "$Path\*.default-release*\" -ErrorAction SilentlyContinue 
            ForEach ($item in $Profiles) { 
                $firefox_path = "$item\places.sqlite"
                Write-Output "Found FireFox History for $UserName at path: $firefox_path"
            }
        }
        { $_.Name -match $esr } {
            $Path = "C:\Users\$UserName\AppData\Roaming\Mozilla\Firefox\Profiles\" 
            $Profiles = Get-ChildItem -Path "$Path\*.default-esr*\" -ErrorAction SilentlyContinue 
            ForEach ($item in $Profiles) { 
                $firefox_path = "$item\places.sqlite"
                Write-Output "Found FireFox History for $UserName at path: $firefox_path"
            }
        }

    }
}
else {
    Write-Output "[!] Could not find Firefox History for $UserName"
}

<# Making copies of files #>

Write-Output "Copying Files..."

if (-not (Test-Path -Path $output_path)) { 
    New-Item -Type Directory "$output_path" | Out-Null 
} 

New-Item -Type Directory "$output_path\history_files\" | Out-Null
Copy-Item $chrome_path -Destination "$output_path\history_files\chrome_history" -ErrorAction SilentlyContinue
Copy-Item $edge_path -Destination "$output_path\history_files\edge_history" -ErrorAction SilentlyContinue
Copy-Item $firefox_path -Destination "$output_path\history_files\firefox_history.sqlite" -ErrorAction SilentlyContinue

<# Zipping Files #>

Write-Output "Zipping files..."

Compress-Archive -Path "$output_path\history_files\*" -DestinationPath $output_path\$destination_file

if (Test-Path -Path "$output_path\$destination_file") { 
    Write-Output "Zip successfully written at: $output_path\$destination_file"
} 
else {
    Write-Output "Issue writing Zip at: $output_path\$destination_file"
}

<# Clean up #>

Remove-Item "$output_path\history_files\" -Recurse -ErrorAction SilentlyContinue