<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
	Deploy-Application.ps1
.EXAMPLE
	Deploy-Application.ps1 -DeployMode 'Silent'
.EXAMPLE
	Deploy-Application.ps1 -AllowRebootPassThru -AllowDefer
.EXAMPLE
	Deploy-Application.ps1 -DeploymentType Uninstall
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.codeplex.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Silent',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Otto Bock'
	[string]$appName = 'Patient Care CAD'
	[string]$appVersion = '1.1.03'
	[string]$appArch = 'X64'
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '05/06/2025'
	[string]$appScriptAuthor = 'Bart Gillis'
	##*===============================================
	
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Patient Care CAD'
	[version]$deployAppScriptVersion = [version]'1.1.0'
	[string]$deployAppScriptDate = '05/06/2025'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	[string]$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -Path $moduleAppDeployToolkitMain -PathType Leaf)) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		[int32]$mainExitCode = 60008
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		Exit $mainExitCode
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

        $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
        $sourcePath   = "$PSScriptRoot\Files\"
        $sourceZip    = Get-ChildItem -Path $sourcePath -filter Patient_Care_CAD.zip
        
			
		## Show Progress Message (with the default message)
		Show-InstallationProgress 

        		
		## <Perform Pre-Installation tasks here>
        		
        ##***===============================================
		##*** Expand to C drive
		##***===============================================
    
        $destinationFolder = Get-Item -Path "C:\Patient_Care_CAD" -ErrorAction SilentlyContinue
    
        if ( $destinationFolder -and ( Test-Path $destinationFolder) ) 
        {
            remove-item -Force -Recurse $destinationFolder.FullName
        }

        Expand-Archive -Path $sourceZip.fullname -DestinationPath C:\

    
		
		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'
	 
        
        # add shortcut to the desktop. 
        New-Item -ItemType SymbolicLink -Path "C:\Users\Public\Desktop" -Name "Patient Care Cad" -Value "C:\Patient_Care_CAD\Starter\Patient_Care_CAD_Starter.exe" -errorAction SilentlyContinue
        
        
        $shell = New-Object -comObject WScript.Shell
        $shortcut = $shell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Patient Care Cad.lnk")
        $shortcut.TargetPath = "C:\Patient_Care_CAD\Starter\Patient_Care_CAD_Starter.exe"
        $shortcut.Save()




		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>
        $rhino = 'C:\Program Files\Rhino 8\System\Rhino.exe'

        # The RHP plugin files cannot be added from within the script. To do this some python will be required or 
        # like it is done now the software must be started the first time as administrator. 
        # to do find a way to install the rhino package from command line for all users. With yak this doesn't seem to work.         
        if ( test-path $rhino ) 
        {
            $patientcare_package = "C:\Patient_Care_CAD\Plugin\Patient_Care.rhp"
            $patientcareGH_package = "C:\Patient_Care_CAD\Plugin\Patient_Care_GH.rhp"
            $patientcareGH_2_package = "C:\Patient_Care_CAD\Plugin\Patient_Care_GH_2.rhp"

            ## to add: 
            ### check if rhino is running before running another process
            ### 
            ### 

            if ( (test-path   $patientcare_package ) -and (test-path   $patientcareGH_package  ) -and (test-path   $patientcareGH_2_package  ) ) 
            {
                start-process $rhino -ArgumentList " -Options -Plugins -Load  $patientcare_package,$patientcareGH_package,$patientcareGH_2_package"
                do
                {
                    Start-Sleep -Milliseconds 500
                } 
                until (  (get-process rhino -ErrorAction SilentlyContinue) -and ( (get-process rhino).MainWindowHandle -ne 0  )) 
                
                start-sleep -Seconds 2     
                get-process rhino | stop-process -force 

            }


            ## also need to start Patient Care CAD once as a administrator
            ## 
            ## 
            $PCC_Binary = get-childitem 'C:\Patient_Care_CAD\Starter\Patient_Care_CAD_Starter.exe' -ErrorAction SilentlyContinue
            if ( (test-path $PCC_Binary))
            {
                start-process $PCC_Binary 
                do
                {
                    Start-Sleep -Milliseconds 500
                } 
                until (  (get-process Patient_Care_CAD_Starter -ErrorAction SilentlyContinue) -and ( (get-process Patient_Care_CAD_Starter).MainWindowHandle -ne 0  )) 
                
                start-sleep -Seconds 3     
                get-process Patient_Care_CAD_Starter | stop-process -force 
            }



        }
		## Display a message at the end of the install
		
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
			
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Uninstallation tasks here>
		
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
        #remove destkop shortcut if it exist
        $shortcut = get-item -Path "C:\Users\Public\Desktop\Patient Care Cad" -ErrorAction SilentlyContinue

        if ( $shortcut -and (test-path $shortcut)) 
        {
            remove-item -force $shortcut.FullName
        }

         #remove start menu shortcut if it exist
        $shortcut = get-item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Patient Care Cad.lnk" -ErrorAction SilentlyContinue

        if ( $shortcut -and (test-path $shortcut)) 
        {
            remove-item -force $shortcut.FullName
        }
        
        # removing the installation files. 
        $InstallFolder = get-item -Path "C:\Patient_Care_CAD"  -ErrorAction SilentlyContinue
        if ( $InstallFolder -and (test-path $InstallFolder) ) 
        {
		    remove-item -recurse -force $InstallFolder.FullName
        }

		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
		
		
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}