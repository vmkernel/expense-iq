# Expense IQ (ex. Easy Money) backup decode / encode tool

# Background
Expense IQ (ex. Easy Money) has a very stupid and childish BUG.

If you accidently type somewhere (in description of account, transaction or may be somewhere else) a special character (like apostrophe) you won't be able to restore your backup. The most painfull thing about it is that you won't know it untill you try to restore a backup and Expense IQ failed to complete it, but succeeded wiping all your data.

And all of this because of tiny apostrophe character the user had put somewhere in project's description (or in a transaction notes, or somewhere else) a long time ago. 

There are some reasons for this bug, and all of them related to a brilliant work of ignoring best practices of working with special characters and restoring user backups done by Expense IQ developers, testers and product managers. So if you've run to the same problem as I did, please send some regards to HandyApps team ;)

I've been using the app for a very long time, liked it very much and actually believe that there's no worthy competitors at Google Play. I hoped developers would fix this bugs as soon as possible, because it very frustrating and leads to data loss during database restore. But 5 years passed since then and the developers proofed they don't give a f.ck about the issue.

Exception example:
```
07-09 21:29:50.405 13140  2541 E SQLiteLog: (1) near "s": syntax error
07-09 21:29:50.405 13140  2541 W System.err: android.database.sqlite.SQLiteException: near "s": syntax error (code 1): , while compiling: INSERT INTO project(_id, name, description, budget, color, activated, currency, uuid, updated, deleted ) VALUES(<id>,'<name>','it's a bad description',<budget>,'<color>',<activated>,'<currency>', '<uuid>', '<updated>', '<deleted>' )
```

# Workaround
A backup file itself stored in obfuscated format where each line represents as a UTF-8 string with SQL query line encoded to HEX string. So, you can't just get rid of the "malicious" special character in a backup file and restore it normally. 

To fix the problem you need to decode your backup file to SQL query format, search and destroy every "malicious" escape character and only after encode the SQL file back to obfuscated backup format.

Fortunately each line in the obfuscated backup related to a line in decoded SQL query, so I recommend to:
1. Use android adb shell and logcat to find a line that causes restoration failure.
(logcat can only show you (one?) line with text causing a restore process to fail, but not the line number in a backup file).
2. Decode an Expense IQ backup file using Decode-ExpenseIqBackup script.
3. Open a decoded file with any text editor (I suggest VS Code or Sublime Text).
4. Find the fauly line using search and the output from logcat.
5. Remove all special characters from the line and save the file.
6. Encode the file back to Expense IQ backup format using Encode-ExpenseIqBackup script.
7. Try to restore the new encoded backup file.

I wish you luck and hope that this tool will help someone!

# Step-by-step guide
(this is actually a draft based on a [comment](https://github.com/vmkernel/expense-iq/issues/2#issuecomment-1699676353) to issue #2, but it's better than nothing).

1. Download [the script](https://github.com/vmkernel/expense-iq/blob/master/expense-iq-backup.ps1) to your computer.

2. Download a corrupted backup file of Expense IQ from your device to your computer.

3. Run PowerShell in administrator mode.

4. Execute the following command which set less strict script execution policy allowing to run a local unsigned scripts: \
`Set-ExecutionPolicy RemoteSigned` \

5. Load the downloaded script in the running PowerShell session, e.g.: \
`. "D:\Users\<name>\Projects\expense-iq\expense-iq-backup.ps1"` \
The first symbol is a dot (`.`) and the path to the script sould be replaced to the path where you've saved the downloaded script.

6. Run a decoding command, e.g.: \
`Decode-ExpenseIqBackup -InputFile "C:\Users\<user>\Downloads\daily_autobackup.bak" -OutputFile "C:\Users\<user>\Downloads\expense_iq.txt"` \
The path "C:\Users\<user>\Downloads\daily_autobackup.bak" sould be replaced with the full path to your Expense IQ backup file on your PC. \
The path "C:\Users\<user>\Downloads\expense_iq.txt" should be replaced with a path to any folder which is good for you, as well as the file name (it will be created during the decoding).

7. Wait until PowerShell finishes running the script. \
Depending on your backup size in might take a while.

8. Open the decoded file (named expense_iq.txt in my example) in any text editor. \
I suggest using VS Code or Sublime Text as they support UTF-8 encoding.

9. Find the corrupting line. \
It's the most trickies part, 'cause I can't tell for sure what symbols and where causes your backup to be unable to restore from. \
At first, try to find all lines starting with `INSERT INTO project(` and delete single quote charecters (`'`) BETWEEN opening and closing single quote charecters. \
E.g. the sequence `'I'm a bad project description'` contains three single quote characters: at the start, at the end and in the middle (between `I` and `m`). You should remove all the quotes in the middle and KEEP the quotes at the start and at the end of the sequence. Repet the actions for all similar lines.

10. Save and close the file.

11. Switch back to PowerShell window and run an encoding command: \
`Encode-ExpenseIqBackup -InputFile "C:\Users\<user>\Downloads\expense_iq.txt" -OutputFile "C:\Users\<user>\Downloads\daily_autobackup_fixed.bak"`
The path "C:\Users\<user>\Downloads\expense_iq.txt" should be replaced with the same path you've used to decode a backup file (see point 6 above).
The path "C:\Users\<user>\Downloads\daily_autobackup_fixed.bak" should be replaced with path to any folder which is good for you as well as the file name (it will be created during the encoding).

12. Wait until PowerShell finishes running the script. \
Depending on your backup size in might take a while.

13. Upload the fixed encoded file (named daily_autobackup_fixed.bak in my example) to Expense IQ's backup folder on your device.

14. Try to restore the uploaded file in Expense IQ.

Wish you luck, and feel free to ask any questions by rising a new issue! \
(it's really inspiring how a simple 7-years-old PowerShell script is still useful :))
