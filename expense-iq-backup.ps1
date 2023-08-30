function Decode-ExpenseIqBackupLine {
    [CmdletBinding()]
    param(
        # Encoded line as it's presented in a backup file
        [parameter( Mandatory = $true, ValueFromPipeline=$true )]
        [System.String] $Line
    )

    begin {  }

    process {
        
        # Reversing characters order in the HEX string
        $arrLineChars = $Line.ToCharArray();
        [System.Array]::Reverse( $arrLineChars );
        $strReversedLine = -join $arrLineChars;

        # Removing excess symbols
        $strReversedLine = $strReversedLine -replace "[^ABCDEF0-9]", "";
        $strReversedLine = $strReversedLine.Trim();
        
        # Converting the HEX string to byte array
        $arrBytes = @();
        for ( $idx = 0; $idx -lt $strReversedLine.Length; $idx += 2 ) {
            $strByteString = $strReversedLine.Substring( $idx, 2 );
            $arrBytes += [System.Convert]::ToByte( $strByteString, 16 );
        }

        # Converting the byte array to a UTF8 string
        $strDecodedLine = [System.Text.Encoding]::UTF8.GetString( $arrBytes );

        return $strDecodedLine;
    }

    end {  }
}

function Encode-ExpenseIqBackupLine {
    [CmdletBinding()]
    param(
        [parameter( Mandatory = $true, ValueFromPipeline = $true )]
        [System.String] $Line
    )

    begin {  }

    process {

        # Converting the UTF8 string to a byte array
        $arrBytes = [System.Text.Encoding]::UTF8.GetBytes( $Line );
        
        # Converting the byte array to a HEX string
        $strReversedLine = "";
        for ( $idx = 0; $idx -lt $arrBytes.Count; $idx++ ) {
            $strReversedLine += [System.String]::Format( "{0:X2}", $arrBytes[$idx] );
        }

        # Reversing character in the HEX string
        $arrLineChars = $strReversedLine.ToCharArray();
        [System.Array]::Reverse( $arrLineChars );
        $strEncodedLine = -join $arrLineChars;

        return $strEncodedLine;
    }

    end {  }
}

# TODO: Add SQL header
# As the SQL database scheme in Expense IQ changes from time to time, it would be great
# to keep up-to-date 'the header' of the output SQL file which automatically creates 
# SQL tables to be able to upload the decoded file directly to MS SQL Server, BUT
# for now creation of SQL database header in the decoded output file is disabled as it 
# doesn't affect logic of the script.
function Decode-ExpenseIqBackup {
    [CmdletBinding()]
    param(
        # Expense IQ backup file
        [parameter( Mandatory = $true )]
        [System.String] $InputFile,
        
        # Decoded sql file
        [parameter( Mandatory = $true )]
        [System.String] $OutputFile
    )
    
    # Reading the backup file
    $arrLines = Get-Content -Path $InputFile;
    
    # Creating the output file 
    New-Item -ItemType File -Path $OutputFile | Out-Null;

    # Decoding backup file lines and writing them to the output file
    for ( $idx = 1; $idx -lt $arrLines.Count; $idx++ ) {
        $strDecodedLine = Decode-ExpenseIqBackupLine -Line $arrLines[$idx];
        $strDecodedLine | Out-File -Append -Encoding utf8 -LiteralPath $OutputFile
    }
}

function Encode-ExpenseIqBackup {
    [CmdletBinding()]
    param(
        # Previously decoded SQL file
        [parameter( Mandatory = $true )]
        [System.String] $InputFile,
        
        # Output file which will be encoded to Expense IQ backup file format
        [parameter( Mandatory = $true )]
        [System.String] $OutputFile
    )
    
    # Reading the decoded input file
    $arrLines = Get-Content -Path $InputFile;
    
    # Creating the output file with Expense IQ Backup signature line
    # NOTE: This is a hardcoded signature, which might be changed in newer versions of Expense IQ
    "[EASYMONEY_BACKUP_V3]" | Out-File -Encoding default -LiteralPath $OutputFile;
     
    # Encoding input file lines and writing them to the output file
    for ( $idx = 0; $idx -lt $arrLines.Count; $idx++ ) {
        $strEncodedLine = Encode-ExpenseIqBackupLine -Line $arrLines[$idx];
        $strEncodedLine | Out-File -Append -Encoding default -LiteralPath $OutputFile;
    }
}
