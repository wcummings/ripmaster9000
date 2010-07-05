#!/usr/bin/perl
use strict;
use warnings;
use IO::Select;
use Configurator;
use TUI;

$SIG{INT} = \&cleanup;

my $cfg_file = shift || 'ripmaster9000.conf';

my $win = new TUI;
$win->init;
$win->draw_borders;

my $config = Configurator->new;
$config->parse($cfg_file);

$win->console_print("Loaded config: $cfg_file");

my @devs = $config->read_value('devs');

my $sel = new IO::Select;

my $procn = 0;
foreach my $dev (@devs) {
    if(open(my $child, "-|")) {
	$sel->add($child);
    } else {
	while(1) {
	    system("./cdpoll $dev");
	    my $ev = $? >> 8;
	    if($ev == 0) {
		open(ABCDE, "abcde -d $dev -N 2>&1|");
		print "STATUS:$procn:RIPPING\n";
		while(my $out = <ABCDE>) {
		    chomp $out;
		    print "$procn:$out\n";
		}
		close(ABCDE);
		print "STATUS:$procn:WAITING\n";
	    }
	}
    }
    $procn++;
}

while(1) {
    foreach my $fh ($sel->can_read) {
	my $line = <$fh>;
	chomp $line;
	if($line =~ /Grabbing/) {
	    $win->console_print($line);
	} elsif($line =~ /^STATUS:(\d+):(.*)$/) {
	    my ($procn, $text) = ($1, $2);
	    $win->canvas_print(1, $procn*2, "$procn: $text");
	}
    }
}

sub cleanup
{
    $win->clear;
    exit;
}
