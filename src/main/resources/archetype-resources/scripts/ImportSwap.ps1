<#
    This script takes a target directory and a hashtable of search/replace pairs.
    for every java file in the target directory, it checks for the hastable search keys, and replaces them with the values.
    It saves the file only if changes were made to preserve timestamps on untouched files.
#>

# --- Vars ----
# 1. Define the directory to search (Change this to your path)
#    Can be the project root, or can select a subfolder for a more targeted approach.
#.   Root folder is suggested for first time use, Subfolder is suggested when running remedial times
$TargetDirectory = "D:\Users\user\app\path"

# 2. Define the Hashtable (Key = Search String, Value = Replace String)
$Replacements = @{
    "javax.ejb.EJB;" = "com.newcompany.core.utils"
    "javax.faces.bean.ManagedBean" = "jakarta.inject.Named;"
    "javax.faces.bean.SessionScoped" = "jakarta.enterprise.context.SessionScoped"
    "javax.faces.bean.ManagedProperty" = "jakarta.inject.Inject"
    "javax.ejb.EJB" = "jakarta.ejb.EJB"
    "javax.persistence.Transient" = "jakarta.persistence.Transient"
}
# TODO: Define List of import statements to be removed. this will remove the entire line in the file.
$RemovedImports = @("javax.faces.bean.ManagedProperty;") 

# -- pre-check ---

# Check if directory exists
if (-not (Test-Path -Path $TargetDirectory)) {
    Write-Error "The directory '$TargetDirectory' does not exist."
    exit
}

# Get all .java files recursively
$JavaFiles = Get-ChildItem -Path $TargetDirectory -Filter "*.java" -Recurse

Write-Host "Found $($JavaFiles.Count) .java files in $TargetDirectory. Processing..." -ForegroundColor Cyan

foreach ($File in $JavaFiles) {
    # Read content as single raw string to preserve line breaks
    $OriginalContent = Get-Content -Path $File.FullName -Raw
    
    # create copy of the content
    $NewContent = $OriginalContent
    $FileChanged = $false

    # Iterate through the hashtable
    foreach ($SearchString in $Replacements.Keys) {
        if ($NewContent.Contains($SearchString)) {
            $ReplaceString = $Replacements[$SearchString]
            
            # replacement
            $NewContent = $NewContent.Replace($SearchString, $ReplaceString)
            
            $FileChanged = $true
            Write-Host "  [$($File.Name)] Replacing '$SearchString' with '$ReplaceString'" -ForegroundColor Gray
        }
    }

    # Only write file if changes were made
    if ($FileChanged) {
        try {
            # Set-Content with -NoNewline ensures no add extra trailing whitespace
            # Encoding is set to UTF8 to match standard Java source file encoding
            Set-Content -Path $File.FullName -Value $NewContent -NoNewline -Encoding UTF8
            Write-Host "Updated: $($File.FullName)" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to write to $($File.FullName): $_"
        }
    }
}

Write-Host "Import Swap Complete." -ForegroundColor Cyan