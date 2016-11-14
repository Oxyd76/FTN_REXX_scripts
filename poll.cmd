/* REXX BSO poller by Oxyd, [osFree team]       */
/* poll.cmd <address> [flavor]                  */
/* Address: zone:net/node[.point] numeric       */
/* Flavor: direct|crash|immediate|hold          */
/* If flavor unspecified, use DefFlavor         */

/* Default zone for outbound                    */
DefZone = 2

/* Path to base outbound directory, for DefZone */
Outbound = 'c:\var\cache\fido\binkd\outbound'

/* Default flavor if not specified              */
/* d - direct, c - crash,                       */
/* i - immediate, h - hold                      */
DefFlavor = 'd'


/* Begin polling! ;-)                           */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
FlavorSuffix = 'lo'
PntSuffix = 'pnt'
!dot = '.'
!bslash = '\'
!nothing =''
!num = 'NUM'
Flavors = 'DIRECT CRASH IMMEDIATE HOLD'
FlavSym = 'd c i h'
Parse Arg Address Flavor
If Address = '' Then call Usage
Flavor = Translate(Flavor)
If Flavor = !nothing Then
  Flavor = DefFlavor
Else Do
  !okflavor = ''
  Do word = 1 to Words(Flavors)
    If Flavor = Word(Flavors, word) then Do
      Flavor = Word(FlavSym, word)
      !okflavor = 'OK'
    End
    If !okflavor \= 'OK' Then Call Usage
  End
End
Flavor = Flavor || FlavorSuffix
Parse Var Address Zone ':' Net '/' Node '.' Point
If CheckNum() = 0 Then Call Usage
If Zone \= DefZone Then Do
  Zone =  D2X(Zone, 3)
  Outbound = Outbound || !dot || Zone
  Call SysMkDir Outbound
  Outbound = Outbound || !bslash
End
Else Outbound = Outbound || !bslash
Net = D2X(Net, 4)
Node = D2X(Node, 4)
If Point = !nothing | Point = 0 Then Do
  Outbound = Outbound || Net || Node || !dot || Flavor
  Call CharOut Outbound, !nothing
End
Else Do
  Outbound = Outbound || Net || Node || !dot || PntSuffix
  Call SysMkDir Outbound
  Point = D2X(Point, 8)
  Outbound = Outbound || !bslash || Point || !dot || Flavor
  Call CharOut Outbound, !nothing
End
If stream(Outbound,'c','query exists') \= '' Then
  Say 'Poll 'Outbound' succesfully created!'
Else
  Say 'Failed creating poll 'Outbound!
Call stream Outbound, 'c', 'close'
Exit

CheckNum:
If Datatype(Zone) = !num Then
  If Datatype(Net) = !num Then
    If Datatype(Node) = !num Then
    Do
      Select
        When Point = !nothing Then Return 1
        When Datatype(Point) = !num Then Return 1
        Otherwise Return 0
      End
    End

Usage:
  Say Substr(Sourceline(1), 4, 45)
  Say 'Usage: ' || Substr(Sourceline(2), 4, 45)
  Say Copies(' ',7) || Substr(Sourceline(3), 4, 45)
  Say Copies(' ',7) || Substr(Sourceline(4), 4, 45)
  Say Copies(' ',7) || Substr(Sourceline(5), 4, 45)
Exit
