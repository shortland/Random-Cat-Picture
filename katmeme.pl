#!/usr/bin/perl

use CGI;

BEGIN
{
    $cgi = new CGI;
}
STARTER:
# random page
$randomPage = (int(rand(137)) + 2);

$pageData = `curl -s -A "This is a script, please let us use your site to find random pics <3 ty." "http://www.lolcats.com/gallery/popular-$randomPage.html" -L`;

# 48 random cats per page
# remove 0-47 cats, to get a random cat
$randomPic = int(rand(48));

$pageData =~ s/gallery-item/Ω/g;
$pageData =~ s/<\/td>/∑/g;

for(0..$randomPic)
{
    ($rmThis) = ($pageData =~ /[^Ω]*Ω([^∑]+)/);
    $pageData =~ s/$rmThis//g;
}

# use this
($partitioned) = ($pageData =~ /[^Ω]*Ω([^∑]+)/);
($useThis) = ($partitioned =~ /src=[^"]*"([^"]+)/);

$useThis =~ s/thumbs\///g;
if(($useThis =~ "") || (!defined $useThis))
{
    goto STARTER;
}

print $cgi->header(-type => "image");

# directly print image rather than redirect
print `curl -s "http://www.lolcats.com/$useThis"`;

open(STDERR, ">&STDOUT");