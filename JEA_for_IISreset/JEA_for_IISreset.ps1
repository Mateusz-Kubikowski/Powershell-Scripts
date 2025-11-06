# Create JEA catalogs
$modPath = "C:\Program Files\WindowsPowerShell\Modules\IISJEARole"
New-Item -Path $modPath -ItemType Directory -Force
New-Item -Path $modPath\RoleCapabilities -ItemType Directory -Force

# Write files
Set-Content -Path "$modPath\RoleCapabilities\IISJEARole.psrc" -Value @'
@{
    GUID = 'Generate GUID'
    Author = ''
    CompanyName = ''
    Description = 'JEA Role allowing start/stop/restart of IIS services only'
    VisibleCmdlets = @(
        # Restart-Service z ograniczeniem do W3SVC i WAS oraz -Force
        @{
            Name = 'Restart-Service'
            Parameters = @{
                Name = 'Name'
                ValidateSet = @('W3SVC', 'WAS')
            }
        },
        @{
            Name = 'Restart-Service'
            Parameters = @{ Name = 'Force' }
        },

        # Stop-Service z ograniczeniem do W3SVC i WAS oraz -Force
        @{
            Name = 'Stop-Service'
            Parameters = @{
                Name = 'Name'
                ValidateSet = @('W3SVC', 'WAS')
            }
        },
        @{
            Name = 'Stop-Service'
            Parameters = @{ Name = 'Force' }
        },

        # Start-Service z ograniczeniem do W3SVC i WAS
        @{
            Name = 'Start-Service'
            Parameters = @{
                Name = 'Name'
                ValidateSet = @('W3SVC', 'WAS')
            }
        }
    )
}
'@

Set-Content -Path "$modPath\IISJEAConfig.pssc" -Value @'
@{
    SessionType = 'RestrictedRemoteServer'
    TranscriptDirectory = 'C:\JEA_Logs'
    RunAsVirtualAccount = $true
    RoleDefinitions = @{
        'BUILTIN\Remote Desktop Users' = @{ RoleCapabilities = @('IISJEARole') }
        'BUILTIN\Administrators'       = @{ RoleCapabilities = @('IISJEARole') }
    }
    ExecutionPolicy = 'Unrestricted'
    LanguageMode = 'NoLanguage'
}
'@

# Create log Catalog
New-Item -Path C:\JEA_Logs -ItemType Directory -Force

# Register JEA
Register-PSSessionConfiguration -Name JEA_IIS_Reset -Path "$modPath\IISJEAConfig.pssc" -Force

Write-Host "JEA Configured. RDP Users can restart IIS via JEA"


Enter-PSSession -ComputerName localhost -ConfigurationName JEA_IIS_Reset
