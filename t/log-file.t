#!/usr/bin/perl
#===============================================================================
#         FILE:  log_file.t
#
#  DESCRIPTION:  Test Log::File
#
#       AUTHOR:  Trevor S. Cornpropst, <tscornpropst@gmail.com>
#      COMPANY:  -
#      VERSION:  1.0
#      CREATED:  05/03/2006 21:00:31 EDT
#===============================================================================

use strict;
use warnings;

use Test::More tests => 73;
use Test::Exception;
#use Test::Strict;
use Fcntl;

BEGIN { use_ok('Log::File'); }

my $module = 'Log::File';
my $mod_file = '../Log/File.pm';
my @methods = qw(
    new
    close
    _log
    _msg
    debug
    error
    info
    notice
    warn
    die
    level
);

#strict_ok($module);
#warnings_ok($module);
#syntax_ok($module);

my $logfile = "./t/sampdata/test.log";

unlink $logfile;

is(-e $logfile, undef, 'old log file deleted');

ok(my $log = Log::File->new( { file => $logfile } ), 'basic constructor');

isa_ok($log, 'Log::File');
can_ok($log, @methods);

my @stat = stat $logfile;
#my $mode = sprintf '%04o', $stat[2] & oct(7777);
#cmp_ok($mode, '==', 644, 'default perms');

is($stat[2],                             33188, 'default perms');
is($stat[7],                                 0, 'zero byte file');
is($log->debug("This is a debug message"),   1, 'log->debug');
is($log->error("This is an error message"),  1, 'log->error');
is($log->info("This is an info message"),    1, 'log->info');
is($log->notice("This is a notice message"), 1, 'log->notice');
is($log->warn("This is a warning message"),  1, 'log->warn');
throws_ok { $log->die("This is a die message") } qr/This is a die message/, 'log die output';
is($log->close(),                            1, 'close default mode');
ok($log = Log::File->new( { file => $logfile, append => 1 } ), 'constructor w/ append');
is((stat($logfile))[7],                    349, 'log size');
is($log->debug("Appended debug message"),    1, 'log->debug append mode');
is($log->error("Appended error message"),    1, 'log->error append mode');
is($log->info("Appended info message"),      1, 'log->info append mode');
is($log->notice("Appended notice message"),  1, 'log->notice append mode');
is($log->warn("Appended warning message"),   1, 'log->warn append mode');
is((stat($logfile))[7],                    633, 'append write');
is($log->level(5),                           5, 'set log level 5');
is($log->debug("Debug at level 5"),          1, 'log->debug level 5');
is($log->info("Info at level 5"),            1, 'log->info level 5');
is($log->notice("Notice at level 5"),        1, 'log->notice level 5');
is($log->warn("Warn at level 5"),            1, 'log->warn level 5');
is($log->error("Error at level 5"),          1, 'log->error level 5');
throws_ok { $log->die("Die at level 5") } qr/Die at level 5/, 'die level 5';
is($log->level(4),                             4, 'set log level 4');
is($log->debug("Debug at level 4"),      undef, 'log->debug level 4');
is($log->info("Info at level 4"),            1, 'log->info level 4');
is($log->notice("Notice at level 4"),        1, 'log->notice level 4');
is($log->warn("Warn at level 4"),            1, 'log->warn level 4');
is($log->error("Error at level 4"),          1, 'log->error level 4');
throws_ok { $log->die("Die at level 4") } qr/Die at level 4/, 'log->die level 4';
is($log->level(3),                           3, 'set log level 3');
is($log->debug("Debug at level 3"),      undef, 'log->debug level 3');
is($log->info("Info at level 3"),        undef, 'log->info level 3');
is($log->notice("Notice at level 3"),        1, 'log->notice level 3');
is($log->warn("Warn at level 3"),            1, 'log->warn level 3');
is($log->error("Error at level 3"),          1, 'log->error level 3');
throws_ok { $log->die("Die at level 3") } qr/Die at level 3/, 'log->die level 3';
is($log->level(2),                           2, 'set log level 2');
is($log->debug("Debug at level 2"),      undef, 'log->debug level 2');
is($log->info("Info at level 2"),        undef, 'log->info level 2');
is($log->notice("Notice at level 2"),    undef, 'log->notice level 2');
is($log->warn("Warn at level 2"),            1, 'log->warn level 2');
is($log->error("Error at level 2"),          1, 'log->error level 2');
throws_ok { $log->die("Die at level 2") } qr/Die at level 2/, 'log->die level 2';
is($log->level(1),                           1, 'set log level 1');
is($log->debug("Debug at level 1"),      undef, 'log->debug level 1');
is($log->info("Info at level 1"),        undef, 'log->info level 1');
is($log->notice("Notice at level 1"),    undef, 'log->notice level 1');
is($log->warn("Warn at level 1"),        undef, 'log->warn level 1');
is($log->error("Error at level 1"),          1, 'log->error level 1');
throws_ok { $log->die("Die at level 1") } qr/Die at level 1/, 'log->die level 1';
is($log->close(),                            1, 'log->close');
is((stat($logfile))[7],                   1644, 'log size');

ok($log = Log::File->new( { file => $logfile, perms => 0777, level => 1 } ), 'open level 1');

@stat = ();
@stat = stat $logfile;

is($stat[2],                                   33279, 'default perms');
is($log->debug("Debug at level 1"),      undef, 'log->debug new level 1');
is($log->info("Info at level 1"),        undef, 'log->info new level 1');
is($log->notice("Notice at level 1"),    undef, 'log->notice new level 1');
is($log->warn("Warn at level 1"),        undef, 'log->warn new level 1');
is($log->error("Error at level 1"),          1, 'log->error new level 1');
throws_ok { $log->die("Die at level 1") } qr/Die at level 1/, 'log->die new level 1';
is($log->close(),                              1, 'close');
is((stat($logfile))[7],                      101, 'log size');

$log = undef;

dies_ok { $log = Log::File->() } 'constructor with no parameters';
ok($log = Log::File->new({file => $logfile}), 'constructor');
is($log->notice("Message without line feed"), 1, 'message without linefeed');

SKIP: {

    if ( getpwuid($<) =~ m/root/msx ) {
        skip q{Root reads everything}, 1;
    }

    dies_ok { $log = Log::File->new({ file => './t/sampdata/immutable.log' }) }'constructor to innaccessible file'; 
}
