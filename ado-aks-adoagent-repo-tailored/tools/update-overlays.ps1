Param(
  [string]$Env = "dev",       # dev|prod
  [string]$CsvPath = "./tools/region-pools.csv",
  [string]$KustomizeRoot = "./kustomize"
)

if (-not (Test-Path $CsvPath)) { Write-Error "CSV not found: $CsvPath"; exit 1 }
$rows = Import-Csv $CsvPath | Where-Object { $_.region -and $_.region.Substring(0,1) -ne "#" }

foreach ($row in $rows) {
  $region = $row.region.Trim()
  $stdId  = $row.pool_std_id.Trim()
  $hvId   = $row.pool_heavy_id.Trim()
  $tag    = $row.image_tag.Trim()
  if (-not $region) { continue }

  $path = Join-Path $KustomizeRoot "env/$Env/regions/$region/kustomization.yaml"
  if (-not (Test-Path $path)) { Write-Warning "Missing overlay: $path"; continue }

  $text = Get-Content $path -Raw

  if ($stdId)  { $text = $text -replace 'value:\s*"?CHANGE_ME_POOLID_STD"?', "value: `"$stdId`"" }
  if ($hvId)   { $text = $text -replace 'value:\s*"?CHANGE_ME_POOLID_HEAVY"?', "value: `"$hvId`"" }
  if ($tag)    { $text = $text -replace '(/ado/agent:)[^"\s]+', "`$1$tag" }

  # Always ensure pool name matches "pool-<region>-std|heavy"
  $text = $text -replace 'value:\s*"pool-[a-z0-9-]+-std"',  "value: `"pool-$region-std`""
  $text = $text -replace 'value:\s*"pool-[a-z0-9-]+-heavy"', "value: `"pool-$region-heavy`""

  Set-Content -Path $path -Value $text -Encoding UTF8
  Write-Host "Updated $path"
}

Write-Host "Done. Validate with: kubectl kustomize kustomize/env/$Env/regions/<region>"
