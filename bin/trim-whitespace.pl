#!/usr/bin/perl
## print STDIN or named files after remove any leading and trailing whitespace
## (does not use -p on #! line for DOS+ActivePerl support)
while (<>) {
  s(^\s+)();
  s(\s+$)(\n);
  print;
}
