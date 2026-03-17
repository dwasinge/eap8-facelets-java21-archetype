<#
    Refactors @ManagedBean(name = "x") to @Named("x") in Java files.
    (removed) Updates imports from javax.faces.bean.ManagedBean to javax.inject.Named.
#>

# --- vars ---
$TargetDirectory = "D:\Users\user\app\path"

# --- pre-check ---

if (-not (Test-Path -Path $TargetDirectory)) {
    Write-Error "Directory '$TargetDirectory' does not exist."
    exit
}

$JavaFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.java" -Recurse
Write-Host "Scanning $($JavaFiles.Count) files in $TargetDirectory..." -ForegroundColor Cyan

foreach ($File in $JavaFiles) {
    $Content = Get-Content -Path $File.FullName -Raw
    $OriginalContent = $Content
    
    #  Update the Import Statement
   # if ($Content -match "import\s+javax\.faces\.bean\.ManagedBean\s*;") {
   #     $Content = $Content -replace "import\s+javax\.faces\.bean\.ManagedBean\s*;", "import javax.inject.Named;"
   # }

    #    Regex Breakdown:
    #    (?i)          -> Case-insensitive
    #    @ManagedBean  -> The old annotation
    #    \s*\(\s* -> Opening parenthesis with optional whitespace
    #    name\s*=\s* -> The 'name =' part (which is invalid for @Named)
    #    "([^"]+)"     -> Capture Group 1: The bean name inside quotes
    #    \s*\)         -> Closing parenthesis
    $Pattern = '(?i)@ManagedBean\s*\(\s*name\s*=\s*"([^"]+)"\s*\)'
    
    if ($Content -match $Pattern) {
        # Replacement: @Named("CapturedValue")
        # We strip 'name =' because @Named uses 'value' as the default attribute.
        $Content = $Content -replace $Pattern, '@Named("$1")'
    }

    if ($Content -ne $OriginalContent) {
        try {
            Set-Content -Path $File.FullName -Value $Content -NoNewline -Encoding UTF8
            Write-Host "  [UPDATED] $($File.Name)" -ForegroundColor Green
        }
        catch {
            Write-Error "  [ERROR] Could not save $($File.Name): $_"
        }
    }
}

Write-Host "Refactoring complete." -ForegroundColor Cyan