# Function to check for null bytes in a file
function Get-NullByteCount {
    param (
        [string]$filePath
    )
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    return ($bytes | Where-Object { $_ -eq 0 }).Count
}

# Function to clean null bytes from a file
function Remove-NullBytes {
    param (
        [string]$filePath
    )
    try {
        $content = Get-Content $filePath -Raw
        [System.IO.File]::WriteAllText($filePath, $content)
        Write-Output "✅ Cleaned: $filePath"
    }
    catch {
        Write-Output "❌ Error cleaning $filePath : $_"
    }
}

# Get all text files recursively
$extensions = @("*.py", "*.txt", "*.md", "*.json", "*.yml", "*.yaml", "*.dart", "*.sql")
$files = Get-ChildItem -Recurse -File -Include $extensions

Write-Output "🔍 Scanning for files with null bytes..."
$filesWithNullBytes = @()

foreach ($file in $files) {
    $nullCount = Get-NullByteCount $file.FullName
    if ($nullCount -gt 0) {
        Write-Output "Found $nullCount null bytes in: $($file.FullName)"
        $filesWithNullBytes += $file.FullName
    }
}

if ($filesWithNullBytes.Count -eq 0) {
    Write-Output "✨ No files with null bytes found!"
    exit 0
}

Write-Output "`n📝 Found $($filesWithNullBytes.Count) files with null bytes."
Write-Output "🧹 Cleaning files..."

foreach ($file in $filesWithNullBytes) {
    Remove-NullBytes $file
}

Write-Output "`n✅ Cleaning complete!" 