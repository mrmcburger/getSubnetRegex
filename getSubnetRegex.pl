#!/usr/bin/perl
use strict;
use NetAddr::IP;
use POSIX qw(ceil);
use Data::Dumper;

my @regex_arr = getMatch('192.168.0.0', '255.255.254.0');

print Dumper(\@regex_arr);

# The goal of this function is to return an array with regex(s) to match every ip address in a subnet.
# Param 1 : subnet (ex 10.0.0.0)
# Param 2 : mast (ex 255.0.0.0)
# To achieve this we match /32, /24, /16 et /8 subnets. 
# Example with 192.168.0.0/23, we are getting an array with 2 entries :
#$VAR1 = [
#      '192\\.168\\.0\\.[0-9]{1,3}',
#      '192\\.168\\.1\\.[0-9]{1,3}'
#    ];

sub getMatch
{
	my ($ip_addr, $ip_mask) = @_;
	my $ip_obj = NetAddr::IP->new($ip_addr, $ip_mask);
	my $network = $ip_obj->network();
	my $prefix;

	# On récupère le nombre de sous réseaux que l'on va inclure
	$prefix = $1 if($network =~ m/\/([0-9]+)$/);
	return 0 unless(defined($prefix));
	my $regex_nb = (32 - $prefix) % 8;

	# On récupère quel octet/octets on va travailler
	my $working_byte = ceil($prefix / 8);

	# Découpage de l'ip pour pouvoir travailler par octet
	my @bytes_array = split(/\./, $ip_addr);
	return 0 unless(scalar(@bytes_array) == 4);

	# On récupère le nombres de sous-réseau /8, /16, /24 ou /32 à inclure
	my $subnet_nb = 2 ** $regex_nb;

	# On boucle et on fabrique la regex
	my $regex = '';
	for(1..$subnet_nb)
	{
		# Tous les premiers octets sur lesquels on ne travaille pas restent intacts
		for(0..$working_byte-2)
		{
			$regex .= $bytes_array[$_].'\.';
		}

		# On utilise l'octet sur lequel on travaille puis on l'incrémente à la fin de la boucle
		$regex .= $bytes_array[$working_byte-1].'\.';

		# on matche n'importe quel ip dans le sous réseau restant
		for(my $j=4;$j>$working_byte;$j--)
		{
			$regex .= '[0-9]{1,3}\.';
		}

		# On enlève le dernier point et on met un \n à la place
		$regex =~ s/(.*)\\\.$/\1;/;

		$bytes_array[$working_byte-1]++;
	}

	chop($regex) && return split(/;/, $regex);
}