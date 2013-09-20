#!/usr/bin/env perl
use strict;
use warnings;

sub hoge {
	return map {  $_    }  @INC ;
}
print hoge;
