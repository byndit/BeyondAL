Param(
    [Hashtable]$parameters
)

# Fix for WinRM session instability in GitHub Actions
# Force BcContainerHelper to use docker exec instead of WinRM sessions
$bcContainerHelperConfig.useWinRmSession = "never"

$secrets = $ENV:Secrets | ConvertFrom-Json | ConvertTo-HashTable
$gitHubPackagesContext = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($secrets.gitHubPackagesContext))
$gitHubPackagesCredential = $gitHubPackagesContext | ConvertFrom-Json

$env:GITHUB_TOKEN = $gitHubPackagesCredential.token;
$ALGoPath = $PSScriptRoot;

$ProjectRoot = Join-Path $ALGoPath "..";
$PackageJsonPaths = Join-Path $ProjectRoot "*/package.json";

Write-Host "JS projects:"
$javascriptProjects = Get-ChildItem -Path $PackageJsonPaths | ForEach-Object {
    $parent = Split-Path $_.FullName;
    Write-Host $parent;
    $parent;
}

$javascriptProjects | ForEach-Object {
    try {
        Write-Host "Building" $_ "...";
        Push-Location $_;
        Add-Content -Path .npmrc -Value "`n//npm.pkg.github.com/:_authToken=`${GITHUB_TOKEN}"
        npm install --frozen-lockfile
        npm run build:prod
    }
    finally {
        Pop-Location;
    }
}

New-BcContainer @parameters;
Invoke-ScriptInBcContainer $parameters.ContainerName -scriptblock { $progressPreference = 'SilentlyContinue' }
