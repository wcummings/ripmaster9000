package TUI;
use strict;
use warnings;
use Term::ReadKey;
use Term::ANSIColor;
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
	print STDERR "Terminal must be at least 80x24\n";
	exit;
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

    print color 'blue';

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

    my $title_text = 'RIPMASTER 9000';
    my $title = colored('| ', 'blue') . colored($title_text, 'bold blue') . colored(' |', 'blue');
    $self->mvprint($self->{width}-10 - length($title_text), 0, $title);
    print color 'reset';
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
	print color 'red';
	$self->mvprint($x, $y, $text);
	print color 'reset';
    }
}

1;
