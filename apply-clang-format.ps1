param (
    [string]$path
)
# Define the file extensions to include (case-insensitive)
$includeExtensions = '*.h', '*.hh', '*.hpp', '*.c', '*.cc', '*.cpp', '*.cxx'

# Get all matching files recursively and pipe them to ForEach-Object
Get-ChildItem -Path $path -Recurse -Include $includeExtensions -File | ForEach-Object {
    Write-Host "Formatting file: $($_.FullName)"
    # Run clang-format on each file, using the -i (in-place) option and searching for a .clang-format style file
    clang-format -i -style=file $_.FullName
}
