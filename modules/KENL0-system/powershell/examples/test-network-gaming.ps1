Remove-Module KENL.Network -Force -ErrorAction SilentlyContinue
Import-Module .\modules\KENL0-system\powershell\KENL.Network.psm1 -Force
Test-KenlNetwork -IncludeGaming
