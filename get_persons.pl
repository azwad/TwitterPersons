#!/usr/bin/perl
use utf8;
use strict;
use warnings;
#use lib qw( /home/toshi/perl/lib );
use HashDump;
use feature 'say';
use TwitterPersons;
use Pause 'pause';

my $person1 = TwitterPersons->new;
$person1->named('toshi_local');

my $prof = $person1->prof;
my $friends = $person1->friends;
my $followers = $person1->followers;
my $mutuals = $person1->mutuals;
my $following = $person1->following;
my $followed = $person1->followed;

HashDump->load($prof);
pause;
HashDump->load($friends);
pause;
HashDump->load($followers);
pause;
HashDump->load($mutuals);
pause;
HashDump->load($following);
pause;
HashDump->load($followed);
pause;

say "get connection";
pause;
$person1->get_connection;

$prof = $person1->prof;
$friends = $person1->friends;
$followers = $person1->followers;
$mutuals = $person1->mutuals;
$following = $person1->following;
$followed = $person1->followed;

HashDump->load($prof);
pause;
HashDump->load($friends);
pause;
HashDump->load($followers);
pause;
HashDump->load($mutuals);
pause;
HashDump->load($following);
pause;
HashDump->load($followed);
pause;

say "renew";
pause;
$person1->renew;

$prof = $person1->prof;
$friends = $person1->friends;
$followers = $person1->followers;
$mutuals = $person1->mutuals;
$following = $person1->following;
$followed = $person1->followed;

HashDump->load($prof);
pause;
HashDump->load($friends);
pause;
HashDump->load($followers);
pause;
HashDump->load($mutuals);
pause;
HashDump->load($following);
pause;
HashDump->load($followed);
pause;
