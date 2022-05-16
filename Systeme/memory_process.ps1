$report = get-process | select ProcessName , WorkingSet64

$report | Group-Object ProcessName | %{
    New-Object psobject -Property @{
        Process = $_.Name
        Sum = ($_.Group | Measure-Object WorkingSet64 -Sum).Sum 
    }
}

$array = ($report | Measure-Object WorkingSet64 -Sum).Sum

echo "TOTAL = $array"
