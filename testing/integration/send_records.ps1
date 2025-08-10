Param(
  [string]$StreamName,
  [int]$Count = 5
)

if (-not $StreamName) {
  Write-Error "-StreamName is required"
  exit 1
}

for ($i=1; $i -le $Count; $i++) {
  $data = @{ id = $i; message = "hello-$i" } | ConvertTo-Json -Compress
  aws kinesis put-record --stream-name $StreamName --partition-key $i --data ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($data))) | Out-Null
  Start-Sleep -Milliseconds 250
}
Write-Host "Sent $Count records to $StreamName"
