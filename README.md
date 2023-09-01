# Expense IQ (ex. Easy Money) backup decode / encode tool

# Background
Expense IQ (ex. Easy Money) has a very stupid and childish BUG.

If you accidently type somewhere (in description of account, transaction or may be somewhere else) a special character (like apostrophe) you won't be able to restore your backup. The most painfull thing about it is that you won't know it untill you try to restore a backup and Expense IQ failed to complete it, but succeeded wiping all your data.

And all of this because of tiny apostrophe character the user had put somewhere in project's description (or in a transaction notes, or somewhere else) a long time ago. 

There are some reasons for this bug, and all of them related to a brilliant work of ignoring best practices of working with special characters and restoring user backups done by Expense IQ developers, testers and product managers. So if you've run to the same problem as I did, please send some regards to HandyApps team ;)

I've been using the app for a very long time, liked it very much and actually believe that there's no worthy competitors at Google Play. I hoped developers would fix this bugs as soon as possible, because it very frustrating and leads to data loss during database restore. But 5 years passed since then and the developers proofed they don't give a f.ck about the issue.

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

## Exception example
07-09 21:29:50.405 13140  2541 E SQLiteLog: (1) near "s": syntax error
07-09 21:29:50.405 13140  2541 W System.err: android.database.sqlite.SQLiteException: near "s": syntax error (code 1): , while compiling: INSERT INTO project(_id, name, description, budget, color, activated, currency, uuid, updated, deleted ) VALUES(<id>,'<name>','it's a bad description',<budget>,'<color>',<activated>,'<currency>', '<uuid>', '<updated>', '<deleted>' )
