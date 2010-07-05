package Configurator;
use strict;
use warnings;

sub new
{
    my ($class) = @_;
    my $self = {
	config => undef,
    };
    bless $self, $class;
    return $self;
}

sub parse
{
    my ($self, $filepath) = @_;

    my $line_num = 0;
    open FILE, $filepath;
    while(my $line = <FILE>) {
	chomp $line;
	$line =~ s/[ \t]*(?<!\\)#.*$//g;
	if($line eq '') {
	    $line_num++;
	    next;
	} elsif($line =~ /^(.*?)(?<!\\)=(.*?)$/) {
	    my ($key, $value) = ($1, $2);
	    if($value =~ /(?<!\\),/) {
		my @ary = split(/(?<!\\),/, $value);
		$self->{config}->{$key} = \@ary;
	    } else {
		$self->{config}->{$key} = $value;
	    }
	} else {
	    print STDERR "Configurator: $filepath:$line_num: syntax error\n";
	}
	$line_num++;
    }

    close FILE;
}

sub read_value
{
    my ($self, $key) = @_;
    
    if(defined $self->{config}->{$key}) {
	if(ref $self->{config}->{$key} eq 'ARRAY') {
	    return @{$self->{config}->{$key}};
	} else {
	    return $self->{config}->{$key};
	}
    } else {
	print STDERR "Configurator: $key undefined\n";
    }
}

1;
