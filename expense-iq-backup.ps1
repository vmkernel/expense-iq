function Decode-ExpenseIqBackupLine {
    [CmdletBinding()]
    param(
        # Encoded line as it's presented in a backup file
        [parameter( 
            Mandatory = $true, 
            ValueFromPipeline=$true )]
        [System.String]
        $Line
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
        [parameter( 
            Mandatory = $true,
            ValueFromPipeline = $true )]
        [System.String]
        $Line
    )

    begin {  }

    process {

        # Converting the UTF8 string to a byte array
        $arrBytes = [System.Text.Encoding]::UTF8.GetBytes( $Line );
        
        # Converting the byte array to a HEX string
        #-join ( $arrBytes | %{ "{0:X2}" -f $_ } )
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

function Decode-ExpenseIqBackup {
    [CmdletBinding()]
    param(
        # Encoded backup file (input)
        [parameter( Mandatory = $true )]
        [System.String]
        $SourceFile,
        
        # Decoded sql file (output)
        [parameter( Mandatory = $true )]
        [System.String]
        $DestinationFile,
        
        # Include header in output sql file
        [parameter( Mandatory = $false )]
        [switch]
        $IncludeHeader
    )
    
    # Reading the backup file
    $arrLines = Get-Content -Path $SourceFile;

    # Initializing sql query variable
    $arrSqlQuery = @();
    if ( $IncludeHeader.IsPresent ) {
        # SQL query header that absent in a backup file
        $arrSqlQuery += @(
            "create table account (_id integer primary key autoincrement, name text not null, description text not null, start_balance numeric not null, create_date integer not null, monthly_budget numeric null, currency numeric null, position numeric null, default_tran_status text null, exclude_from_total numeric null);",
            "create table budget (_id integer primary key autoincrement, account_id integer null, category_id integer null, amount numeric not null);",
            "create table category (_id integer primary key autoincrement, name text not null, description text null, color text not null, type text null, parent_id numeric null);",
            "create table category_color (_id integer primary key autoincrement, category_id integer null, color_code text not null);",
            "create table category_tag (_id integer primary key autoincrement, category_id integer not null, name text not null);",
            "create table currency (_id integer primary key autoincrement, currency_code text null, currency_symbol text null, placement text null, is_default text null, decimal_places integer null, decimal_separator text null, group_separator text null);",
            "create table currency_symbol (_id integer primary key autoincrement, currency_code text null, currency_symbol text null, is_default text null);",
            "create table license (_id integer primary key autoincrement, eula_agreed text null, install_date integer null, license_key text null);",
            "create table passcode (_id integer primary key autoincrement, passcode text null, enabled text null);",
            "create table project (_id integer primary key autoincrement, name text not null, description text null);",
            "create table reminder (_id integer primary key autoincrement, tran_id integer not null, title text not null, due_date integer not null, reminder_date integer null, reminder_days integer null, status text null, repeat_id integer null);",
            "create table repeat (_id integer primary key autoincrement, tran_id integer null, reminder_id integer null, next_date integer null, repeat integer null, repeat_param integer null);",
            "create table skin (_id integer primary key autoincrement, name text null, header_bg_start text null, header_bg_end text null, h1_left text null, h1_right text null, h2_left text null, h2_right text null, divider_background text null, divider_text text null, summary_background text null, summary_text text null, button_background text null);",
            "create table system_settings (_id integer primary key autoincrement, version text null);",
            "create table tran (_id integer primary key autoincrement, account_id integer null, title text not null, amount numeric not null, tran_date integer null, remarks text not null, category_id integer null, status text null, repeat_id integer null, photo_id integer null, split_id integer null, transfer_account_id numeric null)",
            "create table user_settings (_id integer primary key autoincrement, default_reminder_days integer null, reminder_time text null, currency_symbol text null, currency_code text null, bills_reminder_currency text null, autobackup_time text null, autobackup_enabled text null, account_balance_display text null, forward_period text null, forward_period_bills text null, auto_delete_backup_enabled text null, auto_delete_backup_days integer null, default_reporting_period text null, default_reporting_chart_period text null, sound_fx_enabled text null);"
        );
    }
    
    # Decoding lines
    for ( $idxLine = 1; $idxLine -lt $arrLines.Count; $idxLine ++ ) {
        $strSqlQuery = Decode-ExpenseIqBackupLine -Line $arrLines[$idx];
        $arrSqlQuery += $strSqlQuery;
    }
    
    # Writing decoded backup file
    $arrSqlQuery | Out-File -Force -Encoding utf8 -LiteralPath $DestinationFile;
}

function Encode-ExpenseIqBackup {
    [CmdletBinding()]
    param(
        # Decoded sql file (input)
        [parameter( Mandatory = $true )]
        [System.String]
        $SourceFile,
        
        # Encoded backup file (output)
        [parameter( Mandatory = $true )]
        [System.String]
        $DestinationFile
    )
    
    # TODO: Implementation
}
