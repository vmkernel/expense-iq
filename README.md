# Expense IQ (ex. Easy Money) backup decode / encode tool

Expense IQ (ex. Easy Money) has a very stupid and childish BUG it can't stands escape characters in database backup file, so it fails to import it with an exception and leaves you database wiped out. Though it says that database has been restored successfully, that kinda frustrating. So,  if you "accidently" put somewhere in description (or may be somewhere else) an apostrophe character you will not be able to restore your backup.

A backup file stored in obfuscated format. Each line represents as a UTF-8 string with SQL query line encoded to HEX string (why???).
So, you can't just get rid of the "malicious" escape character in a backup file and restore it normally. To fix the problem you need to decode your backup file to SQL query format search and destroy every "malicious" escape character and only after that encode it back to obfuscated backup format.

Fortunately there's one-to-one correspondence from each line in a obfuscated backup to a line in decoded SQL query, so I recommend to (1) use android adb shell and logcat to find a line that causes restoration failure, (2) decode whole backup file first, (3) locate the line and "memorize" its number, (4) remove escape character from the line, (5) encode only this line to backup format, (6) replace only encoded fixed line in a backup file in the appropriate line number, (7) save the file with a new name and (8) try to restore it again.

I've been using the app for a very long time and I like it very much, and I actually believe that there's no worthy competitors at Google Play. I hope developers can fix this bugs as soon as possible, because it very frustrating and leads to data loss during database restore. And all this because of tiny apostrophe character that the user had put somewhere in project's description (or in a transaction notes, or somewhere else) a long time ago. It's very strange situation for the product that has been on the market for such a long time, because the escape characters processing is the one of the first things any developer should learn to handle.

I wish you luck and hope that this "tool" will help someone!

## Exception example
07-09 21:29:50.405 13140  2541 E SQLiteLog: (1) near "s": syntax error
07-09 21:29:50.405 13140  2541 W System.err: android.database.sqlite.SQLiteException: near "s": syntax error (code 1): , while compiling: INSERT INTO project(_id, name, description, budget, color, activated, currency, uuid, updated, deleted ) VALUES(<id>,'<name>','it's a bad description',<budget>,'<color>',<activated>,'<currency>', '<uuid>', '<updated>', '<deleted>' )
<...>
