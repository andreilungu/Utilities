#get last Extension Number
$Folder = 'C:\ALExtensionIdsSample\Folder 1'
$Folder2 = 'C:\ALExtensionIdsSample\Folder 2'
#let's complicate things for practice purpose and extract the ID from the extension name instead of simply take the Id :)
[regex]$Regex = 'pageextension(?<num>\d+)'
$Files = Get-ChildItem $Folder -Filter '*.al'
$Files += Get-ChildItem $Folder2 -Filter '*.al'
$ExtensionNumbers = @()
foreach($file in $Files)
{
    $ExtHash = @{}
    $stringfirstline = Select-String -InputObject $file -Pattern $RegEx
    $m = $Regex.Matches($stringfirstline)
    $number = ($m[0].Groups["num"].Value) * 1
    $ExtHash.Add("FileName",$File.FullName)
    #match the object name from the first line (after word 'extends'): 
    $ExtHash.Add("ObjectName",(([regex]::Match($stringfirstline,'(?<=extends ).*').Value) -replace '"','').TrimEnd())
    #OR match the object name from file nam: ex Name of file is 'PEX50343 - Test.al' or 'PEX - Test.al'; Object Name is 'Test.al' 
    #$ExtHash.Add("ObjectName",[regex]::Match($File.Name,'(?<=PEX(?:\d+)? - ).*').Value)
    $ExtHash.Add("ExtensionNumber",$number)
    $PsObject = New-Object PSObject -property $ExtHash
    $ExtensionNumbers += $PsObject
}

$ExtensionNumbers
$MaxMinNo = $ExtensionNumbers | Measure-Object -Property ExtensionNumber -Maximum -Minimum
$MaxExtensionNo = $ExtensionNumbers | Where-Object {$_.ExtensionNumber -eq $MaxMinNo.Maximum}
Write-Output 'Last used Id for page Extensions is: '$($MaxExtensionNo.ExtensionNumber)'ExtensionName: '$($MaxExtensionNo.FileName)


$ExtensionNumbers | Where-Object{$_.ObjectName -like 'Transfer Order'}
$ExtensionNumbers | Where-Object{$_.ExtensionNumber -eq 50292} | Select-Object -Property ObjectName
