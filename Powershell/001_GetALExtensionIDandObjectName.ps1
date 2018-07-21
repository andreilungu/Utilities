#read more about this script at: https://andreilungu.com/al-extension-ids-nav-business-central
Function Get-ALExtensionileInfo{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][array]$ALExtensionFiles,
        [switch]$GetIDFromExtensionName,
        [switch]$GetObjectNameFromFileName
        )

    If($GetIDFromExtensionName) {
        #let's complicate things for practice with regex and extract the ID from the extension name instead of simply take the Id
        [regex]$Regex = '[a-zA-Z]+(?<num>\d+)'
    } else {
        [regex]$Regex = '(?<num>\b\d+)'
    }

    $ExtensionNumbers = @()
    foreach($File in $ALExtensionFiles)
    {
        $ExtHash = @{}
        $stringfirstline = (Select-String -InputObject $file -Pattern $RegEx | select-object -First 1).Line
        $m = $Regex.Matches($stringfirstline)
        $number = ($m[0].Groups["num"].Value) * 1
        $ExtHash.Add("FileName",$File.FullName)

        If(!$GetObjectNameFromFileName) {
            #match the object name from the first line (after word 'extends'): 
            $ExtHash.Add("ObjectName",(([regex]::Match($stringfirstline,'(?<=extends ).*').Value) -replace '"','').TrimEnd())
        } else {
            #OR match the object name from file name: ex Name of file is 'PEX50343 - Test.al' or 'PEX - Test.al'; Object Name is 'Test.al' 
            $ExtHash.Add("ObjectName",[regex]::Match($File.Name,'(?<=PEX(?:\d+)? - ).*').Value)
        }
        
        $ExtHash.Add("ExtensionNumber",$number)
        $ExtHash.Add("ExtensionType",[regex]::Match($stringfirstline,'^\b\w+'))
        $PsObject = New-Object PSObject -property $ExtHash
        $ExtensionNumbers += $PsObject
    }
    return $ExtensionNumbers
}

# Examples of how to use:

$Folder = 'C:\ALExtensionIdsSample\Folder 1'
$Folder2 = 'C:\ALExtensionIdsSample\Folder 2'
$Files = Get-ChildItem $Folder -Filter '*.al'
$Files += Get-ChildItem $Folder2 -Filter '*.al'

#get the info from extension files
$ExtensionInfo = Get-ALExtensionileInfo -ALExtensionFiles $Files
$ExtensionInfo

#get the maximum used id for page extensions
$MaxMinNo = $ExtensionInfo | 
            Where-Object{$_.ExtensionType -like 'pageextension'} | 
            Measure-Object -Property ExtensionNumber -Maximum -Minimum
$ExtensionInfo | Where-Object {($_.ExtensionNumber -eq $MaxMinNo.Maximum) -and 
                               ($_.ExtensionType -like 'pageextension')}

#get the id of an Extension by the Nav Object Name
$ExtensionInfo | Where-Object{($_.ObjectName -like 'Transfer Order') -and 
                              ($_.ExtensionType -like 'pageextension')}

#get the Nav object
$ExtensionInfo | Where-Object{($_.ExtensionNumber -eq 50292) -and
                              ($_.ExtensionType -like 'pageextension')} | 
                 Select-Object -Property ObjectName