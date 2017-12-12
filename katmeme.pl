#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub random_kitty {
	my ($try) = @_;
	my $cgi = new CGI;
	my $base_url = "http://www.lolcats.com";
	#Max tries.
	if ($try eq 10) {
		print $cgi->header(-type => "text/plain");
		return "Error getting that picture :( Try refreshing the page.";
	}
	#random page
	#There ARE this many pages. But like ~5% of them return "BAD GATEWAY" for whatever reason?...
	#So we need to check to see if it returns bad GATEWAY then get a new page if it does...
	my $r_page = (int(rand(137)) + 2);
	my $p_data = request_curl("${base_url}/gallery/popular-${r_page}.html");
	if (is502($p_data)) {
		return random_kitty(++$try);
	}
	my @image_urls = ($p_data =~ m/<td class="gallery-item">\s+<a href="\/popular\/\d+\.html">\s+<img src=(\S+)/g);
	#48 random cats per page
	#remove 0-47 cats, to get a random cat
	my $random_pic = int(rand(48));
	my $url_use = $image_urls[$random_pic] =~ s/\/thumbs|"//gr;#/
	if (!defined $url_use || $url_use eq "") {
		return random_kitt(++$try);
	}
	my $img_data = request_curl("${base_url}${url_use}");
	if (is502($img_data)) {
		return random_kitty(++$try);
	}
	#mostly unecessary, but decent for debugging ¯\_(ツ)_/¯
	print $cgi->header(-type => "image", -cookie => ($cgi->cookie(-name => 'tries', -value => $try, -expires => '+4h', -path => '/')));
	#print $cgi->header();
	return $img_data;
}

sub request_curl {
	my ($url) = @_;
	my $data = `curl -s -A "This is a script, ilankleiman\@gmail.com" "$url" -L`;
	return $data;
}

sub is502 {
	my ($p_data) = @_;
	if ($p_data =~ m/<h\w{3}><t\w{4}>502/g) {
		return 1;
	}
	else {
		return 0;
	}
}

BEGIN {
    print random_kitty(0);
}
