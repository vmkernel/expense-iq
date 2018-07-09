. .\expense-iq-backup.ps1

# Specific faulted line with ' symbol replacement
$strFaultedLineEncoded = $arrLines[10234]
$strFaultedLineDecoded = Decode-ExpenseIqBackupLine -Line $strFaultedLineEncoded;
$strEncodedLine = Encode-ExpenseIqBackupLine -Line $strFaultedLineDecoded;
[System.String]::Compare( $strFaultedLineEncoded, $strEncodedLine )

$strFixedLine = $strFaultedLineDecoded.Replace( "someone's", "someone" )
$strFixedLineEncoded = Encode-ExpenseIqBackupLine -Line $strFixedLine;
[System.String]::Compare( $strFaultedLineEncoded, $strFixedLineEncoded )