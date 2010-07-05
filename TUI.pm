package TUI;
use strict;
use warnings;
use Term::ReadKey;
use IO::Handle;

sub new
{
    my ($class) = @_;
    my $self = {
	width => undef,
	height => undef,
	console_text => undef,
    };
    bless $self, $class;
    return $self;
}

sub init
{
    my ($self) = @_;
    ($self->{width}, $self->{height}) = GetTerminalSize();

    if($self->{width} < 80 || $self->{height} < 24) {
	$self->clear;
	print STDERR "Terminal must be at least 80x24\n";
    }

    $self->clear;
}

sub clear
{
    print "\e[2J"
}

sub cur_pos
{
    my ($self, $x, $y) = @_;

    print "\e[$y;$x"."H";
}

sub mvprint
{
    my ($self, $x, $y, $str) = @_;

    $self->cur_pos($x, $y);
    print $str;
    STDOUT->flush;
}

sub draw_borders
{
    my ($self) = @_;

    my $topbottom = '+';
    for(1..$self->{width}-2) {
	$topbottom .= '-';
    }
    $topbottom .= '+';

    $self->mvprint(0, 0, $topbottom);

    my $sides = '|';
    for(0..$self->{width}-3) {
	$sides .= ' ';
    }
    $sides .= '|';

    for(my $i = 2; $i < $self->{height}; $i++) {
	$self->mvprint(0, $i, $sides);
    }

    $self->mvprint(0, $self->{height}-8, $topbottom);
    $self->mvprint(0, $self->{height}+1, $topbottom);

    my $title = 'RIPMASTER 9000';
    $self->mvprint($self->{width}-10 - length($title), 0, '| RIPMASTER 9000 |');
}

sub console_print
{
    my ($self, $msg) = @_;

    push @{$self->{console_text}}, $msg;
    shift @{$self->{console_text}} if @{$self->{console_text}} > 7;

    my $i = 1;
    foreach my $line (@{$self->{console_text}}) {
	$line = substr($line, 0, $self->{width}-2);
	$self->mvprint(2, $self->{height}-8+$i, $line);
	$i++;
    }
}

sub canvas_print
{
    my ($self, $x, $y, $text) = @_;

    $x += 2;
    $y += 2;
    
    my $d = $self->{height} - (length($text) + $x);

    if($y < $self->{height}-2) {
	$self->mvprint($x, $y, $text);
    }
}

1;
