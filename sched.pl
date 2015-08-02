#!/usr/bin/perl

# Copyright 2015 Michael Fayad
#
# This file is part of bus_stm.
#
# This file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this file.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

# Arguments
my $BusLine = $ARGV[0];
my $BusStop = $ARGV[1];
my $BusDirection = $ARGV[2];

my $Date = "";

if (@ARGV == 4)
{
$Date = $ARGV[3];
}
else
{
use Time::localtime;
my $tm = localtime;
my $Year = $tm->year + 1900;
my $Month = sprintf("%02d", $tm->mon + 1);
my $Day = sprintf("%02d", $tm->mday);
$Date = "$Year$Month$Day";
}

require LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0');
$ua->timeout(10);
$ua->env_proxy;

my $URL = "http://i-www.stm.info/fr/lines/$BusLine/stops/$BusStop/arrivals?callback=jQuery1820029253689932264293_1411829283604&d=$Date&t=1057&direction=$BusDirection&wheelchair=0&_=1411829351069";

my $response = $ua->get("$URL");
my $HTML = "";
if ($response->is_success)
   {
   $HTML = $response->decoded_content;
   }
else
   {
   die $response->status_line;
   }

$HTML =~ s/\},\{\"time\"/\}\n\{\"time\"/g;

open RedacteurDeFichier,">output.txt" or die $!;
print RedacteurDeFichier "$HTML";
close RedacteurDeFichier;


print "\n$BusLine $BusDirection, arrêt $BusStop\n\n";

open LecteurDeFichier,"<output.txt" or die "E/S : $!\n";
while (my $Ligne = <LecteurDeFichier>)
    {
    if ($Ligne =~ /\{\"time\":\"(\d\d)(\d\d)\",/)
        {
        print "$1h$2 ";
        }
    }
close LecteurDeFichier;

print "\n\n";

system("rm output.txt");
