<#
    Refactor JSF @ManagedProperty to @Inject and ensures the newly injected beans are Serializable.
#>

# --- Vars ---
$TargetDirectory = "D:\Users\user\app\path"

function Get-Capitalized {
    param ([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    return $Text.Substring(0,1).ToUpper() + $Text.Substring(1)
}

# --- pre-check ---
if (-not (Test-Path -Path $TargetDirectory)) {
    Write-Error "Directory '$TargetDirectory' does not exist."
    exit
}

$JavaFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.java" -Recurse
$BeanList = @()
$ModifiedFiles = @()
$ModifiedBeans = @()

foreach ($File in $JavaFiles) {
    $Content = Get-Content -Path $File.FullName
    $NewContent = @()
    $FileChanged = $false
    
    foreach ($Line in $Content) {

        # Regex to match: @ManagedProperty(value = "#{beanName}")
        # var captured is the bean name
        if ($Line -match '@ManagedProperty\s*\(\s*value\s*=\s*"#\{([^}]+)\}"\s*\)') {
            
            $BeanName = $matches[1]
            $BeanList += $BeanName
            
            # Replace the entire line with @Inject. preserve whitespace
            if ($Line -match "^(\s*)@ManagedProperty") {
                $NewContent += "$($matches[1])@Inject"
            } else {
                $NewContent += "@Inject"
            }
            
            $FileChanged = $true
            Write-Host "  [Refactor] Found '#{$BeanName}' in $($File.Name)" -ForegroundColor Gray
        }
        else {
            $NewContent += $Line
        }
    }

    if ($FileChanged) {
        Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8
        Write-Host "  [Saved] $($File.Name)" -ForegroundColor Green
    }
}

# remove duplicates
$BeanList = $BeanList | Select-Object -Unique

Write-Host "`n--- Update Class Definitions with Serializable ---" -ForegroundColor Cyan

foreach ($BeanName in $BeanList) {
    # case sensative just in case. edge cases/human error
    $CapitalizedBeanName = Get-Capitalized $BeanName
    
    # rescane files to ensure bean java files are bean java files
    $ClassFound = $false

    foreach ($File in $JavaFiles) {
        $Content = Get-Content -Path $File.FullName
        $NewContent = @()
        $FileModified = $false
        
        # We loop by index so we can peek/modify specific lines
        for ($i = 0; $i -lt $Content.Count; $i++) {
            $Line = $Content[$i]
            
            # Check if this line is the class definition
            # Matches: public class myBean OR public class MyBean
            if ($Line -match "public\s+class\s+($BeanName|$CapitalizedBeanName)\b") {
                
                $ClassFound = $true
                $CurrentLine = $Line

                # Check if it already has Serializable
                if ($CurrentLine -match "Serializable") {
                    Write-Host "  [Skip] $BeanName (Already Serializable) in $($File.Name)" -ForegroundColor DarkGray
                }
                else {
                    # Logic: Check for 'implements'
                    if ($CurrentLine -match "\bimplements\b") {
                        # Case A: Has implements -> Add ", Serializable" before the opening brace
                        if ($CurrentLine -match "\{") {
                            $CurrentLine = $CurrentLine -replace "\s*\{", ", Serializable {"
                        } else {
                            # Edge case: Brace is on next line, append to end of this line
                            $CurrentLine = $CurrentLine + ", Serializable"
                        }
                    }
                    else {
                        # Case B: No implements -> Add " implements Serializable"
                        if ($CurrentLine -match "\{") {
                            $CurrentLine = $CurrentLine -replace "\s*\{", " implements Serializable {"
                        } else {
                            $CurrentLine = $CurrentLine + " implements Serializable"
                        }
                    }

                    $Content[$i] = $CurrentLine # Update the array directly
                    $FileModified = $true
                    Write-Host "  [Update] Added Serializable to $BeanName in $($File.Name)" -ForegroundColor Green
                }
            }
        }

        if ($FileModified) {
            Set-Content -Path $File.FullName -Value $Content -Encoding UTF8
        }
        
        # If found, stop searching other files for this specific bean
        if ($ClassFound) { break }
    }
    
    if (-not $ClassFound) {
        Write-Warning "Could not find class definition for bean: $BeanName"
    }
}

Write-Host "`nComplete." -ForegroundColor Cyan