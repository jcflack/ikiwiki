package IkiWiki::Plugin::pagespec_alias;

use warnings;
use strict;
use IkiWiki '3.00';
use File::Basename;

sub import {
  hook(type => "getsetup", id=> "pagespec_alias", call => \&getsetup);
  hook(type => "checkconfig", id=> "pagespec_alias", call => \&checkconfig);
}

sub getsetup () {
    return
        plugin => {
            description => "description of this plugin",
            safe => 1,
            rebuild => 1,
            section => "misc",
        },
        pagespec_aliases => {
            type => "string",
            example => {"hello" => "hi" },
            description => "option bar",
            safe => 1,
            rebuild => 0,
        },
}

# ensure user-defined pagespec aliases are composed of word-characters only
sub safe_key() {
  my $key = shift;
  return 1 if $key =~ /^\w+$/;
  0;
}

sub checkconfig () {
    no strict 'refs';
    no warnings 'redefine';

    if ($config{pagespec_aliases}) {
        foreach my $key (keys %{$config{pagespec_aliases}}) {
	    next unless safe_key($key);
            my $value = ${$config{pagespec_aliases}}{$key};
            my $subname = "IkiWiki::PageSpec::match_$key";
            *{ $subname } = sub {
              my $path = shift;
              return IkiWiki::pagespec_match($path, $value);
            }
        }
    }
}

1;
