<#
    Recursively refactors JPA @Table annotations in .java files.
    Converts: @Table(name = "First.Second") 
    To:       @Table(name = "Second", schema = "First")
#>

# --- Vars ---
$TargetDirectory = "D:\Users\user\app\path"

# --- pre-check ---

if (-not (Test-Path -Path $TargetDirectory)) {
    Write-Error "Directory not found: $TargetDirectory"
    exit
}

# Get all java files recursively
$JavaFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.java" -Recurse

Write-Host "Scanning $($JavaFiles.Count) files in '$TargetDirectory'..." -ForegroundColor Cyan

foreach ($File in $JavaFiles) {
    # Read file content as a single raw string
    $Content = Get-Content -Path $File.FullName -Raw
    
    # Define the Regex
    # Explanation:
    # (?i)        -> Case-insensitive matching (matches @table, @Table, @TABLE)
    # @Table      -> Literal literal text
    # \s* -> Allow optional whitespace
    # \(          -> Literal opening parenthesis
    # \s*name\s*=\s* -> Matches 'name = ' with flexible whitespace
    # "           -> Literal opening quote
    # ([^."]+)    -> Capture Group 1: Any character EXCEPT dot or quote (The Table Name)
    # \.          -> Literal dot separator
    # ([^"]+)     -> Capture Group 2: Any character EXCEPT quote (The Schema Name)
    # "           -> Literal closing quote
    # \s*\)       -> Literal closing parenthesis
    $Pattern = '(?i)@Table\s*\(\s*name\s*=\s*"([^."]+)\.([^"]+)"\s*\)'
    
    # Check if the file contains the pattern before processing
    if ($Content -match $Pattern) {
        

        $NewContent = $Content -replace $Pattern, '@Table(name = "$2", schema = "$1")'
        
        # Save the file
        try {
            Set-Content -Path $File.FullName -Value $NewContent -NoNewline -Encoding UTF8
            Write-Host "  [UPDATED] $($File.Name)" -ForegroundColor Green
        }
        catch {
            Write-Error "  [ERROR] Could not write to $($File.Name): $_"
        }
    }
}

Write-Host "JPA Table Annotations Processing complete." -ForegroundColor Cyan